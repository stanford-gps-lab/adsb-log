classdef LogMessage < matlab.mixin.Copyable
    % TODO: the name might change...
    
    properties
        Timestamp       % the timestamp for this message
        Track           % heading in [deg]
        Speed           % speed in [knts] (?)
        Position        % position in [lat, lon, alt] in [deg deg ft]
        Distance        % unknown
        VerticalRate    % vertical rate in [ft/min]
        FeederId        % the ID of the feeder for this message
        
        Estimated      % true if an interpolated datapoint
    end
    
    properties (Dependent)
        DateTime    % the timestamp for the message as a MATLAB datetime object
    end
    
    
    methods
        function obj = LogMessage(jsonStruct)
            
            % allow an empty constructor
            if nargin < 1
                return;
            end
            
            % copy the data from the struct to this class (setup to be able
            % to handle getting a list of JSON Structs)
            Nstructs = length(jsonStruct);
            obj(Nstructs) = LogMessage();
            obj(1) = copy(obj(Nstructs));
            
            % need to do some quick adjustment if there is only one struct
            % to not fail with the {} indexing
            if Nstructs == 1
                js{1} = jsonStruct;
                jsonStruct = js;
            end
            
            % loop through all the structs
            for i = 1:Nstructs
                if iscell(jsonStruct)
                    js = jsonStruct{i};
                else
                    js = jsonStruct(i);
                end
                obj(i).Timestamp = js.seen_pos;
                obj(i).Track = js.track;
                obj(i).Speed = js.speed;
                obj(i).Position = [js.lat; js.lon; js.altitude];
                obj(i).Distance = js.distance;
                obj(i).VerticalRate = js.vert_rate;
                obj(i).FeederId = js.feeder_id;
                
                % check the struct for the interp flag and if it is set
                obj(i).Estimated = (isfield(js, 'interp') && strcmp(js.interp, 'y'));
            end
            
        end
        
        
        function dt = get.DateTime(obj)
            % convert to datetime with the correct timezone
            dt = datetime(obj.Timestamp, 'ConvertFrom', 'posixtime', ...
                'TimeZone', 'Local');
        end
        
    end
    
end