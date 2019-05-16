function aircraftData = importJSONLog(filename)
% importJSONLog     import a JSON log of ADS-B data into a list of Aircraft
% types containing all the log data.
%
%   aircraftData = adsblog.parser.importJSONLog(filename) imports the
%   contents of the JSON log specified by the filename (should be a full
%   path).


% open the file and decode the json
fid = fopen(filename);
raw = fread(fid, inf);
fclose(fid);
val = jsondecode(char(raw'));

% convert from the json struct to list of Aircraft
aircraftData = jsonStructToAircraft(val);