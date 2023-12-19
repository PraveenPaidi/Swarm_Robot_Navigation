function [x_step,y_step] = artificial_potential_field_function(q,qd,obs_x,obs_y)
    sx = q(1);  % current position
    sy = q(2);  
    tx = qd(1);  % Target position
    ty = qd(2);  
    
    grid_units = 1.0;               % Map grid size
    robot_radius = 1.01;             % Bot radius
    % grid_x = 50;                    % max grid size
    % grid_y = 50;
    % obs_x = [5.0, 20.0]; % obstacle postion
    % obs_y = [25.0, 25.0]; 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Read the file as text
    % fid = fopen('tct.txt', 'r');
    % data = fread(fid, '*char')'; % Read the entire file as a character array
    % fclose(fid);
    % 
    % % Extract numerical values from the text
    % values = str2num(data);
    % 
    % % Reshape the values into a 50 by 50 matrix
    % maze = reshape(values, 50, 50);
    % 
    % % Create a spatial map with coordinates for each obstacle point
    % spatial_map = {};
    % i_obx = obs_x;
    % i_oby = obs_y;
    % for mx= 1:size(maze, 1)
    %     for my = 1:size(maze, 2)
    %         % y_coord = j + 0.5;  % Shift x-coordinate by 0.5
    %         % x_coord = i + 0.5;  % Shift y-coordinate by 0.5
    %         if maze(mx, my) == 1  % If it's an obstacle
    %             % spatial_map{end+1} = [my, mx];  % Append coordinates to spatial_map
    %             obs_x = [obs_x, mx];
    %             obs_y = [obs_y, my];
    %         end
    %     end
    % end
    % 
    % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    gain_attract = 5;
    gain_repel = 100;
    
    
    % estimating the potential field
    potential_map_matrix = potential_field_estiamtor(tx, ty, obs_x, obs_y, grid_units, robot_radius, gain_attract,gain_repel);
    min_value = min(potential_map_matrix(:));
    max_value = max(potential_map_matrix(:));
    
    n_potential_map_matrix =(potential_map_matrix - min_value) / (max_value - min_value);

    % Defining allowed sets of movement possible for the robot.
    move_lst =[1, 0;0, 1;-1, 0;0, -1];
    [x_step,y_step] = potential_field_planner(sx, sy, tx, ty, grid_units, n_potential_map_matrix,move_lst,obs_x,obs_y);
    
    % figure(1)
    % figure;
    % 
    % % Plot something (you can replace this with your specific data or leave it empty)
    % plot(); 
    % grid on;
    % xlim([1, grid_x]);
    % ylim([1, grid_y]);
    % 
    % % Set the grid lines to 1x1
    % ax = gca;
    % ax.XTick = 0:1:50;
    % ax.YTick = 0:1:50;
    % 
    % % Set the grid to be on at the ticks
    % ax.XGrid = 'on';
    % ax.YGrid = 'on';
    % ax.GridLineStyle = '-';
    % xlabel('X-axis');
    % ylabel('Y-axis');
    % title('50x50 Plot with 1x1 Grid Lines');
    % set(gcf, 'Position', [100, 100, 800, 600]);
    
    
end
    
function[potential_grid] = potential_field_estiamtor(tx, ty, obs_x, obs_y, grid_units, robot_radius, gain_attract,gain_repel)
    % estimating workspace range
    % x_workspace =grid_x;
    % y_workspace =grid_y;
    potential_grid = zeros(50,50);
    potential_grid1 = zeros(50,50);
    potential_grid2 = zeros(50,50);
    for mm=1:1:50
        x = mm * 1;
        for nn = 1:1:50
            y = nn*1;
            U_att = (1/2) * gain_attract * (distance_est(x, y, tx,ty)^2);
            U_rep = repulsion_potential_est(x,y,obs_x, obs_y, robot_radius, gain_repel);
            U_total = U_rep + U_att;
            potential_grid(mm,nn) = U_total;
            potential_grid1(mm,nn) = U_att;
            potential_grid2(mm,nn) = U_rep;

        end
    end


end


function U_rep = repulsion_potential_est(x,y,obs_x, obs_y, robot_radius, gain_repel)
    d_minimum_at = 0;
    dmin = inf;
    for i = 1:numel(obs_x)
        d = distance_est(x, y, obs_x(i), obs_y(i));
        if dmin >= d
            d_minimum_at = i;
            % least distance from the robot
            dmin = d;
        end
    end
    distance_obstacle = distance_est(x, y, obs_x(d_minimum_at), obs_y(d_minimum_at));
    if distance_obstacle <= robot_radius
        if distance_obstacle <= 0.1
            distance_obstacle = 0.1;
        end

        U_rep = 0.5 * gain_repel * (1.0 / distance_obstacle - 1.0 / robot_radius)^2;
    else
        U_rep = 0.0;
    end
end


function d = distance_est(x1,y1,x2,y2)
    d = sqrt((x1 - x2)^2 + (y1 - y2)^2);
end

function [x_step,y_step] = potential_field_planner(sx, sy, tx, ty, grid_units, potential_map_matrix,move_lst,i_obx, i_oby)
    x_step = [];
    y_step = [];
    
    % Getting distance between starting x,y and target x,y
    d = distance_est(sx, sy, tx, ty);
    
    % Run as long as distance between current position and target position
    % is more than the cell size
    x_step = [x_step sx];
    y_step = [y_step sy];
    current_x = sx;
    current_y = sy;
    % prev_move = 1;
    min_x = -100;
    min_y = -100;
    % hold on;
    % % scatter(obs_y,obs_x,50,'yellow','square','filled')
    % % scatter(ty,tx,50,'yellow','x','filled')
    % % Set axis properties for the origin at the bottom-left
    % axis equal;
    % axis tight;
    % set(gca, 'YDir', 'normal');  % Reverse the Y-axis direction
    % 
    % % Add labels and title
    % xlabel('X-axis');
    % ylabel('Y-axis');
    % title('Matrix Grid with Origin at Bottom-Left');



    position_list = {};


    while d >= 1
        mimimum_potential = inf;
        cell_potential = zeros(length(move_lst),4);

        for i = 1:length(move_lst)
            movement = move_lst(i, :);
            next_x =  current_x + movement(1);
            % cell_potential(i,3) = next_x;
            next_y=  current_y + movement(2);
            % cell_potential(i,4) = next_y;
            
            if next_x >= 1 && next_y >= 1 && next_x <= size(potential_map_matrix, 1)  && next_y <= size(potential_map_matrix, 2)
                % cell_potential(i,2) = potential_map_matrix(next_x, next_y);
                % cell_potential(i,1) = i;
                current_potential = potential_map_matrix(next_x,next_y);
            else
                current_potential = inf;
            end 

            if current_potential < mimimum_potential
                mimimum_potential = current_potential;
                min_x = next_x;
                min_y = next_y;
            end
        end
        % [least_cell_potential, min_row] = min(cell_potential(:,2));
        current_x = min_x;
        current_y = min_y;
        potential_step_x = min_x * grid_units;
        potential_step_y = min_y * grid_units;
        
        % for mm=1:length(x_step)
        %     % if ismember(pos,position_list)
        %     if x_step(max(1,mm)) == potential_step_x && y_step(max(mm,1)) == potential_step_y
        %         mimimum_potential1 = inf;
        %         for i = 1:length(move_lst)
        %             indx = 0;
        %             movement = move_lst(i, :);
        %             next_x = x_step(mm) + movement(1);
        %             % cell_potential(i,3) = next_x;
        %             next_y=  y_step(mm) + movement(2);
        %             % cell_potential(i,4) = next_y;
        % 
        %             if next_x >= 1 && next_y >= 1 && next_x <= size(potential_map_matrix, 1) && next_y <= size(potential_map_matrix, 2)
        %                 % cell_potential(i,2) = potential_map_matrix(next_x, next_y);
        %                 % cell_potential(i,1) = i;
        %                 current_potential1 = potential_map_matrix(next_x,next_y);
        %             else
        %                 current_potential1 = inf;
        %             end 
        %             indx = find(x_step == next_x & y_step == next_y);
        %             if indx~=0
        %                 current_potential1 = inf;
        %             end
        %             if next_y == potential_step_y && next_x ==potential_step_x
        %                 current_potential1 = inf;
        %             end
        % 
        % 
        %             if current_potential1 < mimimum_potential1
        %                 mimimum_potential1 = current_potential1;
        %                 min_x = next_x;
        %                 min_y = next_y;
        %             end
        %         end
        %         current_x = min_x;
        %         current_y = min_y;
        %         potential_step_x = min_x * grid_units;
        %         potential_step_y = min_y * grid_units;
        %     end
        % 
        % end
        % 
        % position_list = [position_list pos];
        x_step = [x_step, potential_step_x];
        y_step = [y_step, potential_step_y];
        % looping_fucntion(potential_step_x,potential_step_y);
        
        % hold on;
        % scatter(potential_step_y,potential_step_x,'or','filled')
        % set(gca, 'YDir', 'reverse');
        % xlim([0 50])
        % ylim([0 50])
        % 
        % pause(1)
        d = distance_est(potential_step_x, potential_step_y,tx,ty);
        
    end

%     function isOscillating = looping_fucntion(previousIds, ix, iy)
%     previousIds = [previousIds; [ix, iy]];
% 
%     % Ensure the length of previousIds does not exceed a specified limit
%     if size(previousIds, 1) > 4
%         previousIds(1, :) = [];
%     end
% 
%     % Check for duplicates
%     previousIdsSet = zeros(size(previousIds, 1), 1);
%     isOscillating = false;
% 
%     for i = 1:size(previousIds, 1)
%         if ismember(previousIds(i, :), previousIdsSet, 'rows')
%             isOscillating = true;
%             return;
%         else
%             previousIdsSet(i, :) = previousIds(i, :);
%         end
%     end
% end

end

