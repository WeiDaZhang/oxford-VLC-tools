function CloseN8241A(instrumentHandle)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Closing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [errorcode,errorcode_description]  = agt_awg_close(instrumentHandle);
    if( errorcode ~= 0 )
        % An error occurred while trying to transfer the waveform.
        disp('Could not close the instrument, but it''s probably closed anyway.');
        disp(errorcode_description)
    end

end