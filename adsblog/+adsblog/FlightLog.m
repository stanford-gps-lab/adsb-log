classdef FlightLog < matlab.mixin.Copyable
    % TODO: description and maybe better name....
    
    properties
        Segment         % unknown
        Gap             % unknown
        Tstart          % start time of the flight segment
        Tend            % end time of the segment
        Nsightings      % number of messages (sightings)
        GPSMax          % max GPS (?)
        GPSMin          % min GPS (?)
        Origin          % origin
        Destination     % destination (string)
        Messages        % the list of LogMessage for this flight log
        
    end
    
    
    methods
        
        function obj = FlightLog(jsonStruct)
            
            % handle the empty constructor
            if nargin < 1
                return;
            end
            
            % parse out the results
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