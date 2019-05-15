classdef Aircraft < matlab.mixin.Copyable
    % a specific aircraft from the log -> I'm assuming that a mode s code
    % is unique to an aircraft
    
    properties
        TailNumber          % tail number of the aircraft
        ICAO                % ICAO hex ID
        Type                % type (?)
        Manufacturer        % aircraft manufacturer
        EngineModel         % engine model
        EngineManufacturer  % engine manufacturer
        Nsegments           % number of flight segments (length of flight log list?)
        FlightLogs          % list of flight logs for this aircraft
    end
    
    
    
    methods
        
        function obj = Aircraft(jsonStruct)
            
            % allow empty constructor
            if nargin < 1
                return;
            end
            
            % populate object
            obj.TailNumber = jsonStruct.tail__;
            obj.ICAO = jsonStruct.icao;
            obj.Type = jsonStruct.ac_type;
            obj.Manufacturer = jsonStruct.ac_mfr;
            obj.EngineModel = jsonStruct.eng_model;
            obj.EngineManufacturer = jsonStruct.eng_mfr;
            obj.Nsegments = jsonStruct.x__segments;
            obj.FlightLogs = [];
        end

        function dest = getDestination(obj)
            % get the unique destinations
            dest = unique({obj.FlightLogs.Destination});
        end
        
        function createKML(obj, filename)
            if nargin < 2
                filename = 'flight-data.kml';
            end
            createKMLFromAircraft(obj, filename);
        end
        
        function ac = getAircraftByICAO(obj, icao)
            % get the aircraft with that ICAO number from the list
            ac = obj(strcmp({obj.ICAO}, icao));
        end
        
        function plot(obj)
            allLogs = [obj.FlightLogs];
            allMsgs = [allLogs.Messages];
            allPos = [allMsgs.Position];
            plot(allPos(2,:), allPos(1,:), 'x');
        end
        
    end
    
    methods(Access = protected)

        % Override copyElement method:
        function newobj = copyElement(obj)
            % make copy of the core elements
            newobj = copyElement@matlab.mixin.Copyable(obj);
            
            % make sure to properly copy custom classes
            newobj.FlightLogs = copy(obj.FlightLogs);
        end
   end
    
    
    
end