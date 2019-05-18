classdef Aircraft < matlab.mixin.Copyable
% Aircraft  a representation of a given aircraft in an ADSB log
%   An Aircraft contains the high level meta data that defines the aircraft
%   itself and a list of FlightSegment the contain the various sightings of
%   the given aircraft in a given log.
%
%   aircraft = adsblog.Aircraft(jsonStruct) creates an instance of an
%   Aircraft with the data contained in the parsed JSON struct.  The JSON
%   struct should contain the following fields:
%       - .tail__
%       - .ica
%       - .ac_type
%       - .ac_mfr
%       - .eng_model
%       - .eng_mfr
%       - .x__segments
%
% See Also: adsblog.FlightSegment, adsblog.Sighting

    properties
        TailNumber          % tail number of the aircraft
        ICAO                % ICAO hex ID
        Type                % type (?)
        Manufacturer        % aircraft manufacturer
        EngineModel         % engine model
        EngineManufacturer  % engine manufacturer
        Nsegments           % number of flight segments (length of flight log list)
        FlightSegments      % list of flight segments for this aircraft
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
            obj.FlightSegments = [];
        end

        function dest = getDestination(obj)
            % getDestination    retrieve the unique list of destinations
            % for this aircraft from the set of flight logs contained in
            % this object.
            %   dest = aircraft.getDestination() returns a cell array of
            %   the unique destinations of all the flight logs

            dest = unique({obj.FlightSegments.Destination});
        end
        
        function ac = getAircraftByICAO(obj, icao)
            % getAircraftByICAO     retrieve a specific aircraft from a
            % list of Aircraft by ICAO number
            %   ac = aircraft.getAircraftByICAO(icao) returns the Aircraft
            %   object containing the data for the aircraft with the
            %   specified ICAO number from a list of Aircraft types
            %   (aircraft).  If it is not found, the result in an empty
            %   object.
            
            % get the aircraft with that ICAO number from the list
            ac = obj(strcmp({obj.ICAO}, icao));
        end
        
        function ac = getAircraftByType(obj, type)
            % getAircraftByICAO     retrieve a specific aircraft from a
            % list of Aircraft by ICAO number
            %   ac = aircraft.getAircraftByICAO(icao) returns the Aircraft
            %   object containing the data for the aircraft with the
            %   specified ICAO number from a list of Aircraft types
            %   (aircraft).  If it is not found, the result in an empty
            %   object.
            
            % get the aircraft with that ICAO number from the list
            ac = obj(strcmp({obj.Type}, type));
        end
        
        function createKML(obj, filename)
            % createKML     create a KML file containing the flight path of
            % all the flight logs.
            %   aircraft.createKML() creates a KML that contains all of the
            %   flight segments for the given aircraft.  If aircraft is a
            %   list of Aircraft types, then the resulting KML will contain
            %   all of the flight segments for all the given aircraft in
            %   the list.  The KML file generated is called
            %   'flight-data.kml'
            %
            %   aircraft.createKML(filename) specifies the filename (and
            %   path if the filename is a full path) for where to save the
            %   KML file.
            %
            % See Also: adsblog.createKMLFromAircraft

            % default filename
            if nargin < 2
                filename = 'flight-data.kml';
            end
            
            % call the helper function
            adsblog.createKMLFromAircraft(obj, filename);
        end

        function plot(obj)
            % plot  plot the latitude and longitude position for all the
            % flight segments for a single aircraft.
            %   aircraft.plot() plots the latitude, longitude position of
            %   all the received ADS-B messages for this specific aircraft.

            allLogs = [obj.FlightSegments];
            allMsgs = [allLogs.Sightings];
            allPos = [allMsgs.Position];
            plot(allPos(2,:), allPos(1,:), 'x');
            xlabel('longitude'); ylabel('latitude');
            title('ADS-B Messages');
        end
        
    end
    
    % methods defined in functions for clarity
    methods
        ac = getAircraftByLocation(obj, lat, lon, varargin)
    end
    
    methods(Access = protected)

        % Override copyElement method:
        function newobj = copyElement(obj)
            % make copy of the core elements
            newobj = copyElement@matlab.mixin.Copyable(obj);
            
            % make sure to properly copy custom classes
            newobj.FlightSegments = copy(obj.FlightSegments);
        end
   end
    
    
    
end