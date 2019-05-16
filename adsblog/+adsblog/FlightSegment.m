classdef FlightSegment < matlab.mixin.Copyable
% FlightSegment     a container for a set of ADS-B sighting messages in a
% given segment
%   contains the metadata for a given aircraft flight segment and a list of
%   all the ADS-B sighting messages that make up the given flight segment.
%
%   log = adsblog.FlightSegment(jsonStruct) creates a FlightSegment
%   instance from the metadata provided in the log parsed JSON structure
%   with the following fields:
%       - .segment
%       - .gap
%       - .segment_start
%       - .segment_end
%       - .x__sightings
%       - .gps_max
%       - .gps_min
%       - .origin
%       - .destination
%
% See Also: adsblog.Sighting, adsblog.Aircraft
    
    properties
        Segment         % the ID of the this flight segment
        Gap             % unknown
        Tstart          % start time of the flight segment
        Tend            % end time of the segment
        Nsightings      % number of messages (sightings)
        GPSMax          % max GPS (?)
        GPSMin          % min GPS (?)
        Origin          % origin (string) - best guess of
        Destination     % destination (string) - best guess of
        Sightings       % the list of Sightings for this flight log
        
    end
    
    methods
        
        function obj = FlightSegment(jsonStruct)
            
            % handle the empty constructor
            if nargin < 1
                return;
            end
            
            % parse out the structure
            obj.Segment = jsonStruct.segment;
            obj.Gap = jsonStruct.gap;
            obj.Tstart = jsonStruct.segment_start;
            obj.Tend = jsonStruct.segment_end;
            obj.Nsightings = jsonStruct.x__sightings;
            obj.GPSMax = jsonStruct.gps_max;
            obj.GPSMin = jsonStruct.gps_min;
            obj.Origin = jsonStruct.origin;
            obj.Destination = jsonStruct.destination;
        end

    end
    
    methods(Access = protected)

        % Override copyElement method:
        function newobj = copyElement(obj)
            % make copy of the core elements
            newobj = copyElement@matlab.mixin.Copyable(obj);
            
            % make sure to properly copy custom classes
            newobj.Messages = copy(obj.Messages);
        end
   end

end