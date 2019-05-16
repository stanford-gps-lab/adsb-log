function [] = createKMLFromAircraft(acs, kmlfilename)
% createKMLFromAircraft     create a set of KML files from the sightings
% contained within an aircraft.
%   Two KML files are generated: one with a time slider
%   (`<filename>-gx.kml`) and one without a time slider (`<filename>.kml`).
%   The KML files contain the flight paths for each flight segment for each
%   aircraft in the aircraft list.  Each of the sightings is colored
%   according to whether or not the sighting was an interpolated point or
%   was a geniune sighting (green is genuine, red is an interpolated
%   point).  In creating the KML files, this function creates a temporary
%   directory (`kml-data`) in the current working directory.  It will be
%   removed when the function completes.
%
%   adsblog.createKMLFromAircraft(acs, filename) creates the 2 KML files
%   from the given list of aircraft (or signal aircraft) into files given
%   by the filename.  Note that the filename is only the base filename and
%   should not contain an extension.
%
% See Also: adsblog.Aircraft.createKML

% TODO: add ability to keep the CSV files if desired...
%   ideally this will create a KML from aircraft data
%   first a CSV will be generated and then it will call a python script
%   that converts that to a KML and then the CSV will be deleted
%
%   the CSV is formatted as follows
%       segment index, estimated, timestamp, lat, lon, alt

% create the temp directory for the kml data
mkdir('kml-data');

if nargin < 2
    kmlfilename = 'flight-data';
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

        combined = [combined; segInds estimated' allT' allPos'];
    end

    % write to the csv file
    dlmwrite(fullfile('kml-data', sprintf('%s.csv', ac.ICAO)), ...
             combined, 'delimiter', ',', 'precision', 20);
end

% run the python script
scriptDir = mfilename('fullpath');  % returns path with this filename
[scriptDir, ~, ~] = fileparts(scriptDir);  % returns package path

% create the path to the scripts which reside 2 above the matlab package
% path
csv2kmlScript = fullfile(scriptDir, '..', '..', 'csv-to-kml.py');
csv2gxkmlScript = fullfile(scriptDir, '..', '..', 'csv2gxkml.py');
[~, ~] = system(sprintf('python %s %s.kml', csv2kmlScript, kmlfilename));
[~, ~] = system(sprintf('python %s %s-gx.kml', csv2gxkmlScript, kmlfilename));

% delete all the csv files
delete 'kml-data/*.csv'

% remove the temp directory
rmdir('kml-data');
