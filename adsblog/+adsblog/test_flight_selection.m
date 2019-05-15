% script to try and find the flights of interest using a different methods
%
% for the most part will do them based of location, not time, so I can plot
% all the flights for an entire day and look at them all together

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
    [arclen, az] = distance([37.659 -122.122], p(1:2,:)', referenceEllipsoid('wgs84'));

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
Nhwd = length(hwdAcrft);