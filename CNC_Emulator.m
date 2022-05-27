%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% CNC_Emulator.m                                                          % 
%                                                                         %
% Matlab object allowing the assembly and emulation of complex CNC system %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% (c) Valentin Boutrouche, University of Massachusetts Lowell, 2020       %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


classdef CNC_Emulator < handle
    
    properties (Access = private)
        
        m_state   = 0                       % state connection (0 <-> closed)
        m_init    = struct('G17'  , 0, ...  % Flag to check that the coordinates system was initialized
                           'G20'  , 0, ...  
                           'G90'  , 0, ...
                           'G94'  , 0, ...
                           'G54'  , 0, ...
                           'Check', 0)
        m_axisX        = CNC_Axis           %      Axis X
        m_axisA        = CNC_Axis           %      Axis A
        m_axisY        = CNC_Axis           %      Axis Y
        m_axisZ        = CNC_Axis           %      Axis Z
        m_position     = [0.0 0.0 0.0]      % [in] displacement vector of the central moving block
        m_fps          = 20                 % [Hz] aimed fps
        
    end
    
    methods (Access = public)
        
        % function CNC_Emulator::fopen:
        % define the figure and initialize the axis
        function  fopen(obj)
            
            if ~obj.m_state 
                obj.m_state    = 1      ;
                hold on
                grid on
                axis equal
                view(30,30)
                xlabel('X')
                ylabel('Y')
                zlabel('Z')
                set(gcf, 'Position', [220,250,2*560,2*420])
                init(obj.m_axisX, 15, 0.0, [1 0 0], [0  1 0], [ 0.5   0.0  0.0], [1 1 0 1 1], '#0072BD') % All of those axis could be modified (size,
                init(obj.m_axisA, 15, 0.0, [1 0 0], [0 -1 0], [ 0.5  18.0  0.0], [1 1 0 1 1], '#0072BD') % orientation, color, etc..) to fit different
                init(obj.m_axisY, 15, 0.0, [0 1 0], [0  0 1], [ 8.0   1.5  0.0], [1 1 0 1 1], '#D95319') % complex CNC system
                init(obj.m_axisZ, 15, 0.0, [0 0 1], [1  0 0], [ 8.0   9.0  1.5], [1 1 1 1 1], '#77AC30')
                
            else
                error("Hint: you are already connected to the control box") % Throw error if student code is not correct (ie, trying to connect to the system twice)
            end
            
        end
        
        % function CNC_Emulator::fclose:
        % close the emulator, mimic the actual control box system
        function fclose(obj)
            
            if obj.m_state
                obj.m_state = 0;
            else
                error('Hint: you are not connected to the control box') % Throw error if student code would try to disconnect a control box that wasnt connected
            end
            
        end
        
        % function CNC_Emulator::fprintf:
        % define fprintf for the CNC_Emulator
        % it mimics the way used to communicate with the physical control
        % box
        function fprintf(obj, str)
            if     (contains(str, "G1 ") || contains(str, "G01 "))
                
                % Check that G17 G20 G90 G94 G54 before to move the axis
                if (~obj.m_init.Check)
                    error("Hint: G17 G20 G90 G94 G54")
                end
                % parse the target vector in the G1 command
                xyz = obj.m_position;
                foo = extractBetween(str, 'x', ' ');
                if (~isempty(foo))
                    xyz(1) = str2double(foo);
                end
                foo = extractBetween(str, 'X', ' ');
                if (~isempty(foo))
                    xyz(1) = str2double(foo);
                end
                foo = extractBetween(str, 'y', ' ');
                if (~isempty(foo))
                    xyz(2) = str2double(foo);
                end
                foo = extractBetween(str, 'Y', ' ');
                if (~isempty(foo))
                    xyz(2) = str2double(foo);
                end
                foo = extractBetween(str, 'z', ' ');
                if (~isempty(foo))
                    xyz(3) = str2double(foo);
                end
                foo = extractBetween(str, 'Z', ' ');
                if (~isempty(foo))
                    xyz(3) = str2double(foo);
                end
                % parse feed rate
                foo = extractBetween(str, 'F', ' ');
                if (~isempty(foo))
                    f = str2double(foo);
                end
                foo = extractBetween(str, 'f', ' ');
                if (~isempty(foo))
                    f = str2double(foo);
                end
                foo = extractAfter(str, 'F');
                if (~isempty(foo))
                    f = str2double(foo);
                end
                foo = extractAfter(str, 'f');
                if (~isempty(foo))
                    f = str2double(foo);
                end
                % Make the axis move
                G1(obj, xyz, f)
                
            elseif (contains(str, "G2 ") || contains(str, "G02 "))
                % Check that G17 G20 G90 G94 G54 before to move the axis
                if (~obj.m_init.Check)
                    error("Hint: G17 G20 G90 G94 G54")
                end
                % parse the target vector in the G2 command
                xyz = obj.m_position;
                foo = extractBetween(str, 'x', ' ');
                if (~isempty(foo))
                    xyz(1) = str2double(foo);
                end
                foo = extractBetween(str, 'X', ' ');
                if (~isempty(foo))
                    xyz(1) = str2double(foo);
                end
                foo = extractBetween(str, 'y', ' ');
                if (~isempty(foo))
                    xyz(2) = str2double(foo);
                end
                foo = extractBetween(str, 'Y', ' ');
                if (~isempty(foo))
                    xyz(2) = str2double(foo);
                end
                foo = extractBetween(str, 'z', ' ');
                if (~isempty(foo))
                    xyz(3) = str2double(foo);
                end
                foo = extractBetween(str, 'Z', ' ');
                if (~isempty(foo))
                    xyz(3) = str2double(foo);
                end
                % parse the target vector in the G2 command
                ijk = obj.m_position;
                foo = extractBetween(str, 'i', ' ');
                if (~isempty(foo))
                    ijk(1) = str2double(foo);
                end
                foo = extractBetween(str, 'I', ' ');
                if (~isempty(foo))
                    ijk(1) = str2double(foo);
                end
                foo = extractBetween(str, 'j', ' ');
                if (~isempty(foo))
                    ijk(2) = str2double(foo);
                end
                foo = extractBetween(str, 'J', ' ');
                if (~isempty(foo))
                    ijk(2) = str2double(foo);
                end
                foo = extractBetween(str, 'k', ' ');
                if (~isempty(foo))
                    ijk(3) = str2double(foo);
                end
                foo = extractBetween(str, 'K', ' ');
                if (~isempty(foo))
                    ijk(3) = str2double(foo);
                end
                % parse feed rate
                foo = extractBetween(str, 'F', ' ');
                if (~isempty(foo))
                    f = str2double(foo);
                end
                foo = extractBetween(str, 'f', ' ');
                if (~isempty(foo))
                    f = str2double(foo);
                end
                foo = extractAfter(str, 'F');
                if (~isempty(foo))
                    f = str2double(foo);
                end
                foo = extractAfter(str, 'f');
                if (~isempty(foo))
                    f = str2double(foo);
                end
                % Make the axis move
                G2(obj, xyz, ijk, f)
                
            elseif (contains(str, "G3 ") || contains(str, "G03 "))
                % Check that G17 G20 G90 G94 G54 before to move the axis
                if (~obj.m_init.Check)
                    error("Hint: G17 G20 G90 G94 G54")
                end
                % parse the target vector in the G2 command
                xyz = obj.m_position;
                foo = extractBetween(str, 'x', ' ');
                if (~isempty(foo))
                    xyz(1) = str2double(foo);
                end
                foo = extractBetween(str, 'X', ' ');
                if (~isempty(foo))
                    xyz(1) = str2double(foo);
                end
                foo = extractBetween(str, 'y', ' ');
                if (~isempty(foo))
                    xyz(2) = str2double(foo);
                end
                foo = extractBetween(str, 'Y', ' ');
                if (~isempty(foo))
                    xyz(2) = str2double(foo);
                end
                foo = extractBetween(str, 'z', ' ');
                if (~isempty(foo))
                    xyz(3) = str2double(foo);
                end
                foo = extractBetween(str, 'Z', ' ');
                if (~isempty(foo))
                    xyz(3) = str2double(foo);
                end
                % parse the target vector in the G2 command
                ijk = obj.m_position;
                foo = extractBetween(str, 'i', ' ');
                if (~isempty(foo))
                    ijk(1) = str2double(foo);
                end
                foo = extractBetween(str, 'I', ' ');
                if (~isempty(foo))
                    ijk(1) = str2double(foo);
                end
                foo = extractBetween(str, 'j', ' ');
                if (~isempty(foo))
                    ijk(2) = str2double(foo);
                end
                foo = extractBetween(str, 'J', ' ');
                if (~isempty(foo))
                    ijk(2) = str2double(foo);
                end
                foo = extractBetween(str, 'k', ' ');
                if (~isempty(foo))
                    ijk(3) = str2double(foo);
                end
                foo = extractBetween(str, 'K', ' ');
                if (~isempty(foo))
                    ijk(3) = str2double(foo);
                end
                % parse feed rate
                foo = extractBetween(str, 'F', ' ');
                if (~isempty(foo))
                    f = str2double(foo);
                end
                foo = extractBetween(str, 'f', ' ');
                if (~isempty(foo))
                    f = str2double(foo);
                end
                foo = extractAfter(str, 'F');
                if (~isempty(foo))
                    f = str2double(foo);
                end
                foo = extractAfter(str, 'f');
                if (~isempty(foo))
                    f = str2double(foo);
                end
                % Make the axis move
                G3(obj, xyz, ijk, f)
                
            else
                % Parse the different: G17 G20 G90 G94 G54
                if (contains(str, "G17"))
                    obj.m_init.G17 = 1.0;
                    checkInit(obj)
                end
                if (contains(str, "G20"))
                    obj.m_init.G20 = 1.0;
                    checkInit(obj)
                end
                if (contains(str, "G90"))
                    obj.m_init.G90 = 1.0;
                    checkInit(obj)
                end
                if (contains(str, "G94"))
                    obj.m_init.G94 = 1.0;
                    checkInit(obj)
                end
                if (contains(str, "G54"))
                    obj.m_init.G54 = 1.0;
                    checkInit(obj)
                end
            end  
        end
        
        % function CNC_Emulator::set:
        % set transparency and tracing tool for the different axis
        function set(obj, str)
             if     (strcmp(str, 'EnableTrace'))
                 set(obj.m_axisX, 'Transparancy')
                 set(obj.m_axisY, 'Transparancy')
                 set(obj.m_axisA, 'Transparancy')
                 set(obj.m_axisZ, 'Trace') % This will have to be modified for a different axis system
                                           % In the current state, the sliding block of the Z-axis
                                           % represent our central moving block
             end
        end
        
    end 
    
    methods (Access = private)
        
        % function CNC_Emulator::checkInit:
        % Check that the coordinates system was initialized correctly
        % Could be modified to fit system different than the one studied in
        % the lab
        function checkInit(obj)
            
            if (obj.m_init.G17 && ...
                obj.m_init.G20 && ...
                obj.m_init.G90 && ...
                obj.m_init.G94 && ...
                obj.m_init.G54      )
                obj.m_init.Check = 1;
            end
            
        end
        
        % function CNC_Emulator::moveTo:
        % Absolute translation movement to xyz
        % This function should be modified to fit the needs of different
        % axis system than the one studied in the lab
        function moveTo(obj, xyz)
            
            vec = xyz - obj.m_position;
            % --- X-axis mvt:
            slide(obj.m_axisX,  vec(1)               )
            slide(obj.m_axisA,  vec(1)               )
            move( obj.m_axisY, [vec(1) 0      0    ] )
            move( obj.m_axisZ, [vec(1) 0      0    ] )
            % --- Y-axis mvt:
            slide(obj.m_axisY,         vec(2)        )
            move( obj.m_axisZ, [0      vec(2) 0    ] )
            % --- Z-axis mvt:
            slide(obj.m_axisZ,                vec(3) )
            obj.m_position = xyz;
            
        end
        
        % function CNC_Emulator::moveBy:
        % Relative translation movement by xyz
        % This function should be modified to fit the needs of different
        % axis system than the one studied in the lab
        function moveBy(obj, vec)
            
            % --- X-axis mvt:
            slide(obj.m_axisX,  vec(1)               )
            slide(obj.m_axisA,  vec(1)               )
            move( obj.m_axisY, [vec(1) 0      0    ] )
            move( obj.m_axisZ, [vec(1) 0      0    ] )
            % --- Y-axis mvt:
            slide(obj.m_axisY,         vec(2)        )
            move( obj.m_axisZ, [0      vec(2) 0    ] )
            % --- Z-axis mvt:
            slide(obj.m_axisZ,                vec(3) )
            obj.m_position = obj.m_position + vec;
            
        end
        
        % function CNC_Emulator::G1:
        % G1 function for translation movement in G-Code
        function G1(obj, xyz, feedRate)
            
            pos0 = obj.m_position       ; % [in] original position
            pos1 = xyz                  ; % [in] final position
            vec  = pos1 - pos0          ; % [in] travel vector
            dist = norm(vec)            ; % [in] distance
            dt   = 1/obj.m_fps          ; % [s]  time step
            alph = 0                    ; % [-]  percentage of distanced traveled
            da   = 0.05*feedRate*dt/dist; % [-]  alpha increment
            while (alph < 1.0)
                if (alph + da > 1.0)
                    moveTo(obj, pos1)
                    trace(obj.m_axisZ)
                end
                moveBy(obj, da*vec)
                alph = alph + da;
                trace(obj.m_axisZ)
                pause(dt)
            end
            
        end
        
        % function CNC_Emulator::G1:
        % G2 function for clockwise rotation in G-Code
        function G2(obj, xyz, ijk, feedRate)
            
            pos  = obj.m_position ; % [in] current position
            vec1 =     - ijk      ;
            vec2 = xyz - ijk - pos;
            rad  = norm(vec1)     ;
            % rotation axis
            x    = cross(vec1,vec2)/norm(cross(vec1,vec2));
            % rotation angle
            tf   = acos( dot(vec1,vec2) / (norm(vec1)*norm(vec2)) );
            dt   = 1/obj.m_fps          ; % [s]  time step
            dist = abs(rad*tf)          ; % [in] traveled distance
            alph = 0                    ; % [-]  percentage of distanced traveled
            da   = 0.05*feedRate*dt/dist; % [-]  alpha increment
            while (alph < 1.0)
                if (alph + da > 1.0)
                    moveTo(obj, xyz)
                    trace(obj.m_axisZ)
                end
                A = [0 -x(3) x(2); x(3) 0 -x(1); -x(2) x(1) 0];
                R = eye(3) + sin(alph*tf)*A + (1-cos(alph*tf))*A^2;
                xi = (R*vec1')' ;
                xi = xi+pos+ijk ; 
                moveTo(obj, xi)
                alph = alph + da;
                trace(obj.m_axisZ)
                pause(dt)
            end
            
        end
        
        % function CNC_Emulator::G3:
        % G2 function for counter-clockwise rotation in G-Code
        function G3(obj, xyz, ijk, feedRate)
            
            pos  = obj.m_position ; % [in] current position
            vec1 =     - ijk      ;
            vec2 = xyz - ijk - pos;
            rad  = norm(vec1)     ;
            % rotation axis
            x    = cross(vec1,vec2)/norm(cross(vec1,vec2));
            % rotation angle
            tf   = acos( dot(vec1,vec2) / (norm(vec1)*norm(vec2)) ) - 2*pi;
            dt   = 1/obj.m_fps          ; % [s]  time step
            dist = abs(rad*tf)          ; % [in] traveled distance
            alph = 0                    ; % [-]  percentage of distanced traveled
            da   = 0.05*feedRate*dt/dist; % [-]  alpha increment
            while (alph < 1.0)
                if (alph + da > 1.0)
                    moveTo(obj, xyz)
                    trace(obj.m_axisZ)
                end
                A = [0 -x(3) x(2); x(3) 0 -x(1); -x(2) x(1) 0];
                R = eye(3) + sin(alph*tf)*A + (1-cos(alph*tf))*A^2;
                xi = (R*vec1')' ;
                xi = xi+pos+ijk ; 
                moveTo(obj, xi)
                alph = alph + da;
                trace(obj.m_axisZ)
                pause(dt)
            end
            
        end
        
    end
end


