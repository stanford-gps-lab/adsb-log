% cleaned up script for converting the JSON files to mat files of the data
% and then saving a KML with the data from each day

directory = 'D:\adsb';

files = dir(fullfile(directory, '*.json'));

% loop through all the files
for i = 1:length(files)
    % get the base name for saving the outputs
    basefilename = files(i).name(1:19);
    fprintf('parsing: %s\n', basefilename);
    
    % open the file and decode the json
    fname = fullfile(files(i).folder, files(i).name);
    fid = fopen(fname);
    raw = fread(fid,inf);
    fclose(fid);
    val = jsondecode(char(raw'));
    
    % convert from the json struct to some classes
    aircraftData = jsonStructToAircraft(val);
    
    % save the data as a mat file
    save(fullfile(files(i).folder, strcat(basefilename, '.mat')), 'aircraftData');
    
    % clear the unused data
    clear raw; clear str; clear val;
    
    % get the list of aircraft that are near hayward
    hwdAcrft = getAircraftCloseToHayward(aircraftData);
    
    % create the KML
    hwdAcrft.createKML(fullfile(files(i).folder, basefilename));
end




function aircraftData = jsonStructToAircraft(jsonStruct)
% helper function to get the aircraft data from the json log data

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



function hwdAcrft = getAircraftCloseToHayward(aircraftData)

% get the number of aircraft
Naircraft = length(aircraftData);

% loop through and determine which have paths close to the airport
closeToHWD = zeros(1, Naircraft);
for i = 1:Naircraft
    
    ac = aircraftData(i);
    fl = [ac.FlightLogs];
    m = [fl.Messages];
    p = [m.Position];

    % compute the distance to all the points for this aircraft
    [arclen, ~] = distance([37.659 -122.122], p(1:2,:)', referenceEllipsoid('wgs84'));

    % find the closest approach distance and altitude at that point
    [v, ind] = min(arclen);
    h = p(3,ind);
    
    % check thresholds on closest approach and altitude
    if v < 2e3 && h < 500
        closeToHWD(i) = 1;
    end
end

fprintf('number of aircraft of interest: %d\n', sum(closeToHWD));

% make the hayward aircraft list
hwdAcrft = copy(aircraftData(closeToHWD == 1));

end