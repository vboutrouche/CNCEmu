%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% CNC_Axis.m                                                              % 
%                                                                         %
% Matlab object defining a single CNC axis                                %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% (c) Valentin Boutrouche, University of Massachusetts Lowell, 2020       %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef CNC_Axis < handle
    properties (Access = private)
        
        % Plotting flags:
        m_PlottingFlag = [0 0 0 0 0] % [FirstBase SecondBase MovingBlock FirstRod SecondRod] Flag to enable/disable plotting
        
        % Geometrical parameter:
        m_length    =  0.0     % [in] overall length of the axis
        m_position  =  0       % [- ] initial position of the axis:
                               %     0 <-> middle
                               %     1 <-> base 1
                               %     2 <-> base 2
        m_direction = [1 0 0]  % [in] vector direction of the axis
        m_normal    = [0 1 0]  % [in] vector normal of the axis
        m_x0        = [0 0 0]  % [in] anchor of the axis
        
        % Plotting parameters for the blocks:
        m_blockColor = '#A2142F'; % Default color of the block
        
        % Patches
        m_palpha   = 1.0
        m_pBlock1
        m_pBlock2 
        m_pSlide
        m_pRod1   
        m_pRod2
        % trace
        m_trace  = 0;
        m_pTrace = 0;
        % flag init
        m_flagInit = 0;
    end
    
	methods (Access = public)
        
        % function CNC_Axis::init:
        % initialize the geometry and plotting of a single axis system
        function init(obj, length, pos, dir, nor, x0, plotFlag, color)
            
            % Reset the plotting flag:
            obj.m_PlottingFlag = plotFlag;
            
            % Reset the blocks color:
            obj.m_blockColor   = color;
            
            % Load the geometric feature to the block (previously generated):
            fBlock = [ 1  2  6  5;  2  3  7  6;  7  3  4  8;  1  5  8  4; 9 10 14 13; 10 11 15 14; 15 11 12 16; 16 12  9 13; 1  2 10  9;  2 10 11  3;  3 11 12  4; 12  4  1  9; 5  6 14 13;  6 14 15  7;  7 15 16  8;  5 13 16  8];
            vBlock = [-2.0 -2.0 -0.5;  2.0 -2.0 -0.5;  2.0  2.0 -0.5; -2.0  2 -0.5; -1.0 -1.0 -0.5;  1.0 -1.0 -0.5;  1.0  1.0 -0.5; -1.0  1 -0.5; -2.0 -2.0  0.5;  2.0 -2.0  0.5;  2.0  2.0  0.5; -2.0  2  0.5; -1.0 -1.0  0.5;  1.0 -1.0  0.5;  1.0  1.0  0.5; -1.0  1  0.5];
            fRod   = [1,6,7;2,7,8;3,8,9;4,9,10;6,11,12;7,12,13;8,13,14;9,14,15;11,16,17;12,17,18;13,18,19;14,19,20;16,21,22;17,22,23;18,23,24;19,24,25;21,26,27;22,27,28;23,28,29;24,29,30;26,31,32;27,32,33;28,33,34;29,34,35;31,36,37;32,37,38;33,38,39;34,39,40;36,41,42;37,42,43;38,43,44;39,44,45;41,46,47;42,47,48;43,48,49;44,49,50;1,7,2;2,8,3;3,9,4;4,10,5;6,12,7;7,13,8;8,14,9;9,15,10;11,17,12;12,18,13;13,19,14;14,20,15;16,22,17;17,23,18;18,24,19;19,25,20;21,27,22;22,28,23;23,29,24;24,30,25;26,32,27;27,33,28;28,34,29;29,35,30;31,37,32;32,38,33;33,39,34;34,40,35;36,42,37;37,43,38;38,44,39;39,45,40;41,47,42;42,48,43;43,49,44;44,50,45];
            vRod1  = [0,0,0;0,0,1;0.187500000000000,0,1;0.187500000000000,0,0;0,0,0;0,0,0;0,0,1;0.143633333084808,0.120522676816226,1;0.143633333084808,0.120522676816226,0;0,0,0;0,0,0;0,0,1;0.0325590333125495,0.184651453689789,1;0.0325590333125495,0.184651453689789,0;0,0,0;0,0,0;0,0,1;-0.0937500000000000,0.162379763209582,1;-0.0937500000000000,0.162379763209582,0;0,0,0;0,0,0;0,0,1;-0.176192366397358,0.0641287768735629,1;-0.176192366397358,0.0641287768735629,0;0,0,0;0,0,0;0,0,1;-0.176192366397358,-0.0641287768735629,1;-0.176192366397358,-0.0641287768735629,0;0,0,0;0,0,0;0,0,1;-0.0937500000000001,-0.162379763209582,1;-0.0937500000000001,-0.162379763209582,0;0,0,0;0,0,0;0,0,1;0.0325590333125494,-0.184651453689789,1;0.0325590333125494,-0.184651453689789,0;0,0,0;0,0,0;0,0,1;0.143633333084808,-0.120522676816226,1;0.143633333084808,-0.120522676816226,0;0,0,0;0,0,0;0,0,1;0.187500000000000,-4.59242549680257e-17,1;0.187500000000000,-4.59242549680257e-17,0;0,0,0];
            vRod2  = [0,0,0;0,0,1;0.187500000000000,0,1;0.187500000000000,0,0;0,0,0;0,0,0;0,0,1;0.143633333084808,0.120522676816226,1;0.143633333084808,0.120522676816226,0;0,0,0;0,0,0;0,0,1;0.0325590333125495,0.184651453689789,1;0.0325590333125495,0.184651453689789,0;0,0,0;0,0,0;0,0,1;-0.0937500000000000,0.162379763209582,1;-0.0937500000000000,0.162379763209582,0;0,0,0;0,0,0;0,0,1;-0.176192366397358,0.0641287768735629,1;-0.176192366397358,0.0641287768735629,0;0,0,0;0,0,0;0,0,1;-0.176192366397358,-0.0641287768735629,1;-0.176192366397358,-0.0641287768735629,0;0,0,0;0,0,0;0,0,1;-0.0937500000000001,-0.162379763209582,1;-0.0937500000000001,-0.162379763209582,0;0,0,0;0,0,0;0,0,1;0.0325590333125494,-0.184651453689789,1;0.0325590333125494,-0.184651453689789,0;0,0,0;0,0,0;0,0,1;0.143633333084808,-0.120522676816226,1;0.143633333084808,-0.120522676816226,0;0,0,0;0,0,0;0,0,1;0.187500000000000,-4.59242549680257e-17,1;0.187500000000000,-4.59242549680257e-17,0;0,0,0];
            
            % Reset direction, normal, length and initial position of the block:
            obj.m_direction = (dir / norm(dir))'         ;
            obj.m_normal    = (nor / norm(nor))'         ;
            obj.m_length    = length * obj.m_direction'  ;
            obj.m_position  = pos    * obj.m_direction'  ;
            obj.m_x0        = x0                         ;
            
            % Initialize the first base block:
            vFoo = vBlock;
            Rt   = [ obj.m_normal                         ...
                    -cross(obj.m_normal, obj.m_direction) ...
                     obj.m_direction                       ];      
            for i = 1:size(vBlock,1)
                vFoo(i,:) = (Rt * vBlock(i,:)')' + obj.m_x0;
            end      
            if (obj.m_PlottingFlag(1))
                obj.m_pBlock1 = patch(  'Faces'    , fBlock           , ...
                                        'Vertices' , vFoo             , ...
                                        'FaceColor', obj.m_blockColor , ...
                                        'FaceAlpha', obj.m_palpha     , ...
                                        'EdgeAlpha', obj.m_palpha     );
            end
            
            % Initialize the second base block:
            vFoo  = vBlock;
            for i = 1:size(vBlock,1)
                vFoo(i,:) = (Rt * vBlock(i,:)')' + obj.m_x0 + obj.m_length ;
            end
            if (obj.m_PlottingFlag(2))
                obj.m_pBlock2 = patch(  'Faces'    , fBlock           , ...
                                        'Vertices' , vFoo             , ...
                                        'FaceColor', obj.m_blockColor , ...
                                        'FaceAlpha', obj.m_palpha     , ...
                                        'EdgeAlpha', obj.m_palpha     );
            end
            
            % Initialize the moving block:
            vFoo = vBlock;
            Rt   = [ obj.m_direction                      ...
                    -cross(obj.m_direction, obj.m_normal) ...
                     obj.m_normal                           ];
            for i = 1:size(vBlock,1)
                vFoo(i,:) = (Rt * vBlock(i,:)')' + obj.m_x0 + 0.5*obj.m_length + 1.5*obj.m_normal';
            end
            if (obj.m_PlottingFlag(3))
                obj.m_pSlide  = patch(  'Faces'    , fBlock           , ...
                                        'Vertices' , vFoo             , ...
                                        'FaceColor', obj.m_blockColor , ...
                                        'FaceAlpha', obj.m_palpha     , ...
                                        'EdgeAlpha', obj.m_palpha     );
            end
            
            % Initialize the axis' rods:
            vRod1(:,3) = vRod1(:,3) * length;
            vRod2(:,3) = vRod2(:,3) * length;
            Rt      = [  obj.m_normal                         ...
                        -cross(obj.m_normal, obj.m_direction) ...
                         obj.m_direction                        ];
            for i = 1:size(vRod1,1)
                vRod1(i,:) = (Rt * vRod1(i,:)')' + 0.5*obj.m_direction'          ...
                             + obj.m_x0 + 1.5*obj.m_normal' + 1.3*cross(obj.m_direction',obj.m_normal');
                vRod2(i,:) = (Rt * vRod2(i,:)')' + 0.5*obj.m_direction'          ...
                             + obj.m_x0 + 1.5*obj.m_normal' - 1.3*cross(obj.m_direction',obj.m_normal');
            end
            if (obj.m_PlottingFlag(4))
                obj.m_pRod1   = patch(  'Faces'    , fRod             , ...
                                        'Vertices' , vRod1            , ...
                                        'FaceColor', '#8c8c8c'        , ...
                                        'EdgeColor', '#8c8c8c'        , ...
                                        'FaceAlpha', obj.m_palpha     , ...
                                        'EdgeAlpha', obj.m_palpha     );
            end
            if (obj.m_PlottingFlag(5))
                obj.m_pRod2   = patch(  'Faces'    , fRod             , ...
                                        'Vertices' , vRod2            , ...
                                        'FaceColor', '#8c8c8c'        , ...
                                        'EdgeColor', '#8c8c8c'        , ...
                                        'FaceAlpha', obj.m_palpha     , ...
                                        'EdgeAlpha', obj.m_palpha     );
            end
            
            % Initialize the tracing tool:
            if (obj.m_trace && obj.m_PlottingFlag(3))
                xyz = mean(obj.m_pSlide.Vertices);
                obj.m_pTrace = plot3(xyz(1), xyz(2), xyz(3), 'LineWidth', 2, 'Color', 'k');
            end
            
            % Change the axis status to "Initialized"
            obj.m_flagInit = 1.0;
        end
        
        % function CNC_Axis::set:
        % enable tracing and transparancy of the axis system
        function set(obj, str)
            
            if (~obj.m_flagInit)
                if (strcmp(str, 'Trace')) 
                    obj.m_palpha = 0.3;
                    obj.m_trace  = 1.0;
                end
                if (strcmp(str, 'Transparancy')) 
                    obj.m_palpha = 0.3;
                end
            else
                if (strcmp(str, 'Transparancy') || strcmp(str, 'Trace')) 
                    obj.m_palpha = 0.3;
                    if (obj.m_PlottingFlag(1))
                        obj.m_pBlock1.FaceAlpha = obj.m_palpha;
                        obj.m_pBlock1.EdgeAlpha = obj.m_palpha;
                    end
                    if (obj.m_PlottingFlag(2))
                        obj.m_pBlock2.FaceAlpha = obj.m_palpha;
                        obj.m_pBlock2.EdgeAlpha = obj.m_palpha;
                    end
                    if (obj.m_PlottingFlag(3))
                        obj.m_pSlide.FaceAlpha  = obj.m_palpha;
                        obj.m_pSlide.EdgeAlpha  = obj.m_palpha;
                        xyz = mean(obj.m_pSlide.Vertices);
                        obj.m_pTrace = plot3(xyz(1), xyz(2), xyz(3), 'LineWidth', 2, 'Color', 'k');
                    end
                    if (obj.m_PlottingFlag(4))
                        obj.m_pRod1.FaceAlpha   = obj.m_palpha;
                        obj.m_pRod1.EdgeAlpha   = obj.m_palpha;
                    end
                    if (obj.m_PlottingFlag(5))
                        obj.m_pRod2.FaceAlpha   = obj.m_palpha;
                        obj.m_pRod2.EdgeAlpha   = obj.m_palpha;
                    end
                end
                
            end
            
        end      
        
        % function CNC_Axis::slide:
        % slide the moving block along the rod of the system
        function slide(obj, value)
            
            if (obj.m_PlottingFlag(3))
                obj.m_pSlide.Vertices  = obj.m_pSlide.Vertices  ...
                                       + obj.m_direction'*value;
            end
            
        end
        
        % function CNC_Axis::move:
        % move the whole axis system in the 3D space
        function move(obj, value)
            
            if (obj.m_PlottingFlag(1))
                obj.m_pBlock1.Vertices = obj.m_pBlock1.Vertices + value;
            end
            if (obj.m_PlottingFlag(2))
                obj.m_pBlock2.Vertices = obj.m_pBlock2.Vertices + value;
            end
            if (obj.m_PlottingFlag(3))
                obj.m_pSlide.Vertices  = obj.m_pSlide.Vertices  + value;
            end
            if (obj.m_PlottingFlag(4))
                obj.m_pRod1.Vertices   = obj.m_pRod1.Vertices   + value;
            end
            if (obj.m_PlottingFlag(5))
                obj.m_pRod2.Vertices   = obj.m_pRod2.Vertices   + value;
            end
            
        end
        
        % function CNC_Axis::trace:
        % function to update the trace of the axis if enabled
        function trace(obj)
            
            if (obj.m_trace && obj.m_PlottingFlag(3))
                xyz = mean(obj.m_pSlide.Vertices);
                obj.m_pTrace.XData = [obj.m_pTrace.XData xyz(1)];
                obj.m_pTrace.YData = [obj.m_pTrace.YData xyz(2)];
                obj.m_pTrace.ZData = [obj.m_pTrace.ZData xyz(3)];
            end
            
        end
                        
    end
    
end