
clear
clc
% % q = [15,5];
% q = [10,30];
% % qd = [49,48];
% qd = [15,30];
% 
obs_x = [7, 48]; % obstacle postion
obs_y = [20,2];
% [x,y] = artificial_potential_field_function(q,qd, obs_x, obs_y);



 % Read the file as text
    fid = fopen('tct.txt', 'r');
    data = fread(fid, '*char')'; % Read the entire file as a character array
    fclose(fid);
    
    % Extract numerical values from the text
    values = str2num(data);
    
    % Reshape the values into a 90 by 60 matrix
    maze1 = transpose(reshape(values, 50, 50));
    i_obx = obs_x;
    i_oby = obs_y;
    for mx= 1:size(maze1, 1)
        for my = 1:size(maze1, 2)
            % y_coord = j + 0.5;  % Shift x-coordinate by 0.5
            % x_coord = i + 0.5;  % Shift y-coordinate by 0.5
            if maze1(mx, my) == 1  % If it's an obstacle
                % spatial_map{end+1} = [my, mx];  % Append coordinates to spatial_map
                obs_x = [obs_x, mx];
                obs_y = [obs_y, my];
            end
        end
    end

    maze = reshape(values, 50, 50);
    spatial_map = {};
    for mx= 1:size(maze, 1)
        for my = 1:size(maze, 2)
            % y_coord = j + 0.5;  % Shift x-coordinate by 0.5
            % x_coord = i + 0.5;  % Shift y-coordinate by 0.5
            if maze(mx, my) == 1  % If it's an obstacle
                spatial_map{end+1} = [my, mx];  % Append coordinates to spatial_map
            end
        end
    end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file_path = 'paths2.txt';  % Replace with the path to your file

fid = fopen(file_path, 'r');
if fid == -1
    error('Could not open the file.');
end
path ={};
tline = fgetl(fid);
while ischar(tline)
    % Extract tuples using regular expressions
    tuples = regexp(tline, '\((\d+), (\d+)\)', 'tokens');
    
    % Convert strings to numeric tuples
    numeric_tuples = cellfun(@(x) [str2double(x{1}), str2double(x{2})], tuples, 'UniformOutput', false);
    
    % Append numeric tuples to the path cell array
    path{end+1} = vertcat(numeric_tuples{:});
    
    tline = fgetl(fid);  % Read the next line
end

fclose(fid);

path_list = path{1}; % Replace this with your actual path list
path_list_2 = path{2};
path_list_3 = path{3};
path_list_4 = path{4};
path_list_5 = path{5};

t1 = path_list(end,:);
t2 = path_list_2(end,:);
t3 = path_list_3(end,:);
t4 = path_list_4(end,:);
t5 = path_list_5(end,:);

% figure();    
spatial_map = {};
for i = 1:size(maze, 1)
    for j = 1:size(maze, 2)
        y_coord = j - 0.5;  % Shift x-coordinate by 0.5
        x_coord = i - 0.5;  % Shift y-coordinate by 0.5
        if maze(i, j) == 1  % If it's an obstacle
            spatial_map{end+1} = [x_coord, y_coord];  % Append coordinates to spatial_map
        end
    end
end

% figure();    
set(gcf, 'Position', get(0, 'Screensize'))
axis equal;
hold on;
% Plotting the spatial map without modifying it
if ~isempty(spatial_map)
    % Extract x and y coordinates from spatial_map
    y_coords = cellfun(@(point) point(1), spatial_map);
    x_coords = cellfun(@(point) point(2), spatial_map);
           
    % Define the range for the square (e.g., 0 to 1 in both x and y)
    x_range = [0, 1];
    y_range = [0, 1];
        
    % Loop through each point to draw squares around them
    for a = 1:numel(x_coords)
      
        x = x_coords(a);
        y = y_coords(a);

        x_width = diff(x_range);
        y_width = diff(y_range);

        % Define the vertices of the square
        vertices = [x - x_width/2, y - y_width/2;
                    x + x_width/2, y - y_width/2;
                    x + x_width/2, y + y_width/2;
                    x - x_width/2, y + y_width/2];

        % Draw the square using the patch function
        
        
        patch(vertices(:, 1), vertices(:, 2), 'black', 'FaceColor', 'black', 'EdgeColor','none');
        

                       
    end

    
end

FINAL=plotPathOnMap(path,obs_x,obs_y,i_obx,i_oby);
size_v = max([length(FINAL{1}),length(FINAL{2}),length(FINAL{3}),length(FINAL{4}),length(FINAL{5})]);
print_list = [];
for i=1:5
    each_list = [];
    diff = size_v - length(FINAL{i});
    append_list = ones(2,diff).*FINAL{i}(:,end);
    each_list = [FINAL{i},append_list];
    print_list = [print_list;each_list];
end

scatter(t1(2)+0.5,t1(1)+0.5,50,"hexagram","blue","filled");
text(t1(2)+0.75,t1(1)+0.75, '1', 'FontSize', 8, 'Color', 'blue');
scatter(t2(2)+0.5,t2(1)+0.5,50,"hexagram","blue","filled");
text(t2(2)+0.75,t2(1)+0.75, '2', 'FontSize', 8, 'Color', 'blue');
scatter(t3(2)+0.5,t3(1)+0.5,50,"hexagram","blue","filled");
text(t3(2)+0.75,t3(1)+0.75, '3', 'FontSize', 8, 'Color', 'blue');
scatter(t4(2)+0.5,t4(1)+0.5,50,"hexagram","blue","filled");
text(t4(2)+0.75,t4(1)+0.75, '4', 'FontSize', 8, 'Color', 'blue');
scatter(t5(2)+0.5,t5(1)+0.5,50,"hexagram","blue","filled");
text(t5(2)+0.75,t5(1)+0.75, '5', 'FontSize', 8, 'Color', 'blue');
for i=1:size_v
    if print_list(2,i) > 5
        scatter(20.5, 7.5, 100, 'pentagram', 'filled', ...
            'MarkerEdgeColor', [0, 0.3, 0], 'MarkerFaceColor', [0, 0.3, 0]);
    end
    
    scatter(print_list(2,i)+0.5, print_list(1,i)+0.5, 30, 'red', 'filled');
    scatter(print_list(4,i)+0.5, print_list(3,i)+0.5, 30, 'red', 'filled');
    scatter(print_list(6,i)+0.5, print_list(5,i)+0.5, 30, 'red', 'filled');
    scatter(print_list(8,i)+0.5, print_list(7,i)+0.5, 30, 'red', 'filled');
    scatter(print_list(10,i)+0.5, print_list(9,i)+0.5, 30, 'red', 'filled');
    pause(1e-10000000000000000000000)
end



function List1 =plotPathOnMap(path,obs_x,obs_y,i_obx,i_oby)
    List1 = {};
    path_new = [];
    obs_xy = [obs_x.' obs_y.'];
    for i=1:5
        List2 = [];
        path_e = path{i};
        for each_pnt=1:length(path{i})-3
           
            for ox = 1:length(i_obx)
                obs_pt = [i_obx(ox),i_oby(ox)];
                if [path_e(each_pnt+1,1),path_e(each_pnt+1,2)]== obs_pt
                    q = path_e(each_pnt,:);
                    mm = 1;
                    while  ismember(path_e(each_pnt+1+mm,:), i_obx, 'rows') 
                       mm = mm+1;
                       if each_pnt+mm+2 > length(path_e) 
                           break
                       end
                    end
                    qd = path_e(each_pnt+1+mm,:);
                    [x,y] = artificial_potential_field_function(q,qd, obs_x, obs_y);
                    apf_pts = [x.' y.'];
                    path_e = [path_e(1:each_pnt-1,:);apf_pts; path_e(each_pnt+1+mm:end,:)];
                    
                end
            end 
            
        end
        % path{i} = path_e;
        for gg = 1:length(path_e)-1
            Values =LQR_shape(path_e(gg,1),path_e(gg,2),path_e(gg+1,1),path_e(gg+1,2));
            List2=[List2, Values];
        end
        List1{i} = List2;
    end
end


% figure()
% heatmap(maze)
% hold on
% plot(y,x)