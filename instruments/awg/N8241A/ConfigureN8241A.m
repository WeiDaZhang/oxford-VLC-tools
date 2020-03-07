function instrumentHandle = ConfigureN8241A(strIPAddress, bAmp, bSE, fGain, bFilter, bFilterBW500M, bPreDistort)
    addpath ('C:\Program Files\Agilent\N8241A\Matlab');
    %% %%%%%%%% AWG configuration %%%%%%%%%%%%
    IPAddress = [192,168,1,3];
    if ischar(strIPAddress)
        inxPoint = strfind(strIPAddress,'.');
        if size(inxPoint,2) == 3
            [nIP1, status1] = str2num(strIPAddress(1:inxPoint(1)-1));
            [nIP2, status2] = str2num(strIPAddress(inxPoint(1)+1:inxPoint(2)-1));
            [nIP3, status3] = str2num(strIPAddress(inxPoint(2)+1:inxPoint(3)-1));
            [nIP4, status4] = str2num(strIPAddress(inxPoint(3)+1:end));
            if status1 && status2 && status3 && status4
                IPAddress = [nIP1, nIP2, nIP3, nIP4];
            else
                disp('strIPAddress is not in Correct Format!')
            end
        else
            disp('strIPAddress is not in Correct Format!')
        end
    else
        disp('strIPAddress is not in Correct Format!')
    end

    if ~islogical(bAmp)
        bAmp = 0;
        disp('[bAmp] is not boolean value. Active Amplifier Disabled.')
    end

    if ~islogical(bSE)
        bSE = 0;
        disp('[bSE] is not boolean value. Differnetial Mode Enabled.')
    end

    % DIFF: 0.340 < X < 0.500                                               
    % SE: 0.170 < X < 0.250
    % ACTIVE: .340 < X < .500mVp
    if ~isfloat(fGain)
        fGain = 0.5;
        disp('[fGain] is not float-point number. Gain set to mode Maximum.')
    end

    if bSE
        if(fGain < 0.17 || fGain > 0.25)
            fGain = 0.25;
            disp('Single-End Mode. Gain set to 0.2500V')
        end
    else
        if(fGain < 0.34 || fGain > 0.5)
            fGain = 0.5;
            disp('Differential Mode. Gain set to 0.500V')
        end
    end

    if ~islogical(bFilter)
        bFilter = 0;                                     % internal filter 0(off) or 1(on)
        disp('[bFilter] is not boolean value. Internal Filter Set Off.')
    end

    if islogical(bFilterBW500M)
        if bFilterBW500M
            BW_filter = 500e6;                         % filter BW = either 250e6 or 500e6
        else
            BW_filter = 250e6;                         % filter BW = either 250e6 or 500e6
        end
    else
        BW_filter = 500e6;                             % filter BW = either 250e6 or 500e6
        disp('[bFilterBW500M] is not boolean value. Filter Bandwidth Set to 250MHz.')
    end

    if ~islogical(bPreDistort)
        bPreDistort = 0;                                % Predistortion 0(off) or 1(on)
        disp('[bPreDistort] is not boolean value. PreDistort Set Off.')
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Open a session
    %disp('Opening a session to the AWG');
    %  [ instrumentHandle, errorN, errorMsg ] = agt_awg_open('TCPIP','TCPIP0::169.254.187.21::inst0::INSTR');
    IPString = sprintf('TCPIP0::%d.%d.%d.%d::inst0::INSTR', IPAddress(1), IPAddress(2), IPAddress(3), IPAddress(4));
    [ instrumentHandle, errorN, errorMsg ] = agt_awg_open('TCPIP',IPString);
    if( errorN ~= 0 )
        % An error occurred while trying to open the session.
        disp('Could not open a session to the instrument');
        disp(errorMsg)
        fileID = fopen('awg_conn_failed.txt','w');
        fclose(fileID);
        return;
    end
    fileID = fopen('awg_conn_succeed.txt','w');
    fclose(fileID);

    %disp('Enabling the instrument output');
    [ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle, 'outputenabled', 'true');
    if( errorN ~= 0 )
        % An error occurred while trying to enable the output.
        disp('Could not enable the instrument output');
        disp(errorMsg)
        return;
    end

    %disp('Setting the instrument to ARB mode');
    [ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle, 'outputmode', 'arb');
    if( errorN ~= 0 )
        % An error occurred while trying to set the ARB mode.
        disp('Could not set the instrument to ARB mode');
        disp(errorMsg)
        return;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if bAmp
    %    disp('Setting the instrument to active (amp) mode');
        [ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle, 'outputconfig', 'amp');
        if( errorN ~= 0 )
            % An error occurred while trying to set the ARB mode.
            disp('Could not set the instrument to active mode');
            disp(errorMsg)
            return;
        end
    end

    if bSE
    %    disp('Setting the instrument to SE (single-ended) mode');
        [ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle, 'outputconfig', 'se');
        if( errorN ~= 0 )
            % An error occurred while trying to set the SE mode.
            disp('Could not set the instrument to SE mode');
            disp(errorMsg)
            return;
        end
    else
        [ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle, 'outputconfig', 'diff');
        if( errorN ~= 0 )
            % An error occurred while trying to set the SE mode.
            disp('Could not set the instrument to DIFF mode');
            disp(errorMsg)
            return;
        end
    end


    [ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle, 'outputgain', fGain);
    if( errorN ~= 0 )
        % An error occurred while trying to set the SE mode.
        disp('Could not set the instrument gain');
        disp(errorMsg)
        return;
    end

    if bFilter
    %    disp('Setting the instrument to filter mode');
        [ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle, 'outputfilterenabled', 'true');
        if( errorN ~= 0 )
            % An error occurred while trying to set the filter mode.
            disp('Could not set the instrument to filter mode');
            disp(errorMsg)
            return;
        end

        [ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle, 'outputbw', BW_filter);
        if( errorN ~= 0 )
            % An error occurred while trying to set the filter mode.
            disp('Could not set the instrument to filter mode');
            disp(errorMsg)
            return;
        end
    end


    if ~bPreDistort
    %    disp('Setting the instrument to pre-distortion mode');
        [ errorN, errorMsg ] = agt_awg_setstate( instrumentHandle, 'predistortenabled', 'false');
        if( errorN ~= 0 )
            % An error occurred while trying to set the filter mode.
            disp('Could not set the instrument to non-pre-distortion mode');
            disp(errorMsg)
            return;
        end
    end  

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% checking %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [returnValue, errorN, errorMsg] = agt_awg_getstate( instrumentHandle, 'outputenabled' );
    if( errorN ~= 0 )
        disp(['Error occurred reading instrument state: Error #', num2str(errorN), ' (', errorMsg, ')' ]);
        disp(errorMsg)
        return;
    else
        % Display the results to the console
    %    disp(['Attribute successfully read. OutputEnabled = ', returnValue, ' .' ] );
    end
end