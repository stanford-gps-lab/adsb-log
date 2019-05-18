function ac = getAircraftByLocation(obj, lat, lon, varargin)
% getAircraftByLocation     retrieve a subset of the aircraft in the list
% that are close to a given location.
%   ac = aircraft.getAircraftByLocation(lat, lon) finds all the aircraft
%   that pass within 2km horizontally and 500m vertically of the location
%   specified as lat, lon in degrees.
%
%   ac = aircraft.getAircraftByLocation(..., 'ParamName', 'ParamValue')
%   allows specifying specific data in the name, value pairs.  The
%   parameter names are as follows:
%       - 'HorizontalDistance' - specify the horizontal range to consider
%       an aircraft close to the location in [m] (default is 2000m)
%
%       - 'VerticalDistance' - specify the vertical distance to consider an
%       aircraft close to the location in [m] (default is 500m)

% parse the inputs
parser = inputParser;
parser.addParameter('HorizontalDistance', 2000);
parser.addParameter('VerticalDistance', 500);
parser.parse(varargin{:});
res = parser.Results;

horizThresh = res.HorizontalDistance;
vertThresh = res.VerticalDistance;

% get the number of aircraft
Naircraft = length(obj);

% loop through and determine which have paths close to the airport
closeToLocation = zeros(1, Naircraft);
for i = 1:Naircraft

    ac = obj(i);
    fl = [ac.FlightSegments];
    m = [fl.Sightings];
    p = [m.Position];

    % compute the distance to all the points for this aircraft
    try
        [arclen, ~] = distance([lat lon], p(1:2,:)', ...
                               referenceEllipsoid('wgs84'));
        missingToolbox = false;
    catch ME
        if strcmp(ME.identifier, 'MATLAB:UndefinedFunction')
            % MAPPING toolbox not installed. Compute assuming spherical
            % earth
            missingToolbox = true;
            R_E = 6371000;
            arclen = R_E * 2 * asin(sqrt((sind(lat - p(1, :))/2).^2 ...
                + cosd(lat) .* cosd(p(1, :)) .* sind((lon - p(2, :))/2).^2));
        else
            rethrow(ME)
        end
    end
        

    % find the closest approach distance and altitude at that point
    [horizDist, ind] = min(arclen);
    height = p(3,ind);

    % check thresholds on closest approach and altitude
    if horizDist < horizThresh && height < vertThresh
        closeToLocation(i) = 1;
    end
end
if missingToolbox
    disp(['Missing MAPPING toolbox. ', ...
          'Distances are computed assuming spherical earth.'])
end
fprintf('number of aircraft of interest: %d\n', sum(closeToLocation));

% make the hayward aircraft list
ac = copy(obj(closeToLocation == 1));

