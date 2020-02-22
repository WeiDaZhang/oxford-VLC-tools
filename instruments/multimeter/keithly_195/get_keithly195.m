function [data] = get_keithly195()
%GET_KEITHLY195 Gets the reading from Keithly 195

%% Instrument Connection

% Find a GPIB object.
obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', 16, 'Tag', '');

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = gpib('NI', 0, 16);
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.
fopen(obj1);

%% Instrument Configuration and Control

% Communicating with instrument object, obj1.
data_s = string(fscanf(obj1));
data_c = char(data_s);
data = str2double(data_c(6:end));


%% Disconnect and Clean Up

% Disconnect from instrument object, obj1.
fclose(obj1);

end

