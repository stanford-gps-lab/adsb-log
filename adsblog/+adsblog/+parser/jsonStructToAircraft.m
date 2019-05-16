function aircraftData = jsonStructToAircraft(jsonStruct)
% jsonStructToAircraft  convert the JSON struct from a JSON log file to a
% list of Aircraft containing all the flight log information.
%
%   aircraftData = adsblog.parser.jsonStructToAircraft(jsonStruct) converts
%   the JSON struct from the JSON log files to a list of Aircraft that
%   contain all of the ADS-B sightings for all the flight segments for all
%   the aircraft within the log.
%
% See Also: adsblog.Aircraft, adsblog.FlightLog, adsblog.LogMessage


% get the aircraft in the log
aircraftCodes = fieldnames(jsonStruct.aircraft);
Naircraft = length(aircraftCodes);

% create the arrays to store the data
aircraftData(Naircraft) = Aircraft();

% loop through all the aircraft
for i = 1:Naircraft
    a = jsonStruct.aircraft.(aircraftCodes{i});
    
    % get each of the elements
    aircraftStruct = a{1};
    ad = Aircraft(aircraftStruct);
    
    % loop through all the segments
    allLogs = FlightLog();
    allLogs(ad.Nsegments) = FlightLog();
    for k = 1:ad.Nsegments
        
        % get the overview data on the logs
        logOverview = a{k+1}{1};
        log = FlightLog(logOverview);

        % get the actual log messages
        flightDetails = a{k+1}{2};
        messages = LogMessage(flightDetails);
        
        % save the elements to their properties
        log.Messages = messages;
        allLogs(k) = log;
    end
    
    % save the log set
    ad.FlightLogs = allLogs;
    
    % save the data to the aircraft data list
    aircraftData(i) = ad;
end

end