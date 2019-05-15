% script to go through and play around with the JSON ADS-B data
%
% for 190120 -> looking for a6f305
% clear; clc;

% fname = 'C:\Users\adrienp\Documents\Research Projects\Hayward\adsb-logs-alonso\FA_Sightings.190106.airport_ids.json';
fname = 'C:\Users\adrienp\Documents\Research Projects\Hayward\adsb-logs-alonso\FA_Sightings.190117.airport_ids.json';
% fname = 'C:\Users\adrienp\Documents\Research Projects\Hayward\adsb-logs-alonso\FA_Sightings.190120.airport_ids.json';
% fname = 'C:\Users\adrienp\Documents\Research Projects\Hayward\adsb-logs-alonso\FA_Sightings.190121.airport_ids.json';
% fname = 'C:\Users\adrienp\Documents\Research Projects\Hayward\adsb-logs-alonso\FA_Sightings.190215.airport_ids.json';
fid = fopen(fname);
raw = fread(fid,inf);
str = char(raw');
fclose(fid);
val = jsondecode(str);

% %% Exploration

% % get the aircraft codes from the list
% aircraftCodes = fieldnames(val.aircraft);
% 
% % get the specific aircraft of interest
% % cell array containing:
% %   {1} - details on the aircraft as a struct
% %   {2} - another cell array containing:
% %       {1} - segment information and high level info on the track
% %       {2} - cell array containing all the sightings (each sighting is a
% %       struct)
% n55kt = val.aircraft.a6fe05;
% logOverview = n55kt{2}{1};   % this contains a destination field!
% flightDetails = n55kt{2}{2};


% TODO: loop through all the log overviews to be able to get the
% destinations
%   want to be able to find all the flights going to KHWD

% TODO: might be nice to make some classes to contain the data and convert
% from the JSON data to mat files containing the same data in more usable
% classes

% TODO: need to loop through the flight details to make the data of
% interest into arrays


%% Parsing
%
% convert the json struct stuff to the new classes and see how well it
% works

% get the aircraft in the log
aircraftCodes = fieldnames(val.aircraft);
Naircraft = length(aircraftCodes);

% create the arrays to store the data
aircraftData(Naircraft) = Aircraft();


% loop through all the aircraft
for i = 1:Naircraft
    a = val.aircraft.(aircraftCodes{i});
    
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

% clear the unused data
clear raw; clear str; clear val;








