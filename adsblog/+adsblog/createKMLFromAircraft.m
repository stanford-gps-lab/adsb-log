function [] = createKMLFromAircraft(acs, kmlfilename)
% TODO: better help file
%   ideally this will create a KML from aircraft data
%   first a CSV will be generated and then it will call a python script
%   that converts that to a KML and then the CSV will be deleted
%
%   the CSV is formatted as follows
%       segment index, estimated, timestamp, lat, lon, alt


if nargin < 2
    kmlfilename = 'flight-data.kml';
end

for ai = 1:length(acs)
    ac = acs(ai);

    % setup the matrix that will contain the data
    combined = [];

    % get messages by flight segment to add segment index
    Nsegments = length(ac.FlightLogs);
    for i = 1:Nsegments

        % get all the messages and the details from the message
        msgs = [ac.FlightLogs(i).Messages];
        segInds = i * ones(length(msgs), 1);
        estimated = [msgs.Estimated];
        allT = posixtime([msgs.DateTime]);
        allPos = [msgs.Position];

        combined = [combined;segInds estimated' allT' allPos'];
    end

    % write to the csv file
    dlmwrite(sprintf('kml-data/%s.csv', ac.ICAO), combined, 'delimiter', ',', 'precision', 20);
end

% run the python script
[~, ~] = system(sprintf('python csv-to-kml.py %s.kml', kmlfilename));
[~, ~] = system(sprintf('python csv2gxkml.py %s-gx.kml', kmlfilename));

% delete all the csv files
delete kml-data/*.csv