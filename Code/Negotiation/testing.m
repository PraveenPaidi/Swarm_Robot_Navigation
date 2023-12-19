clc;
clear;
% Read the file as text
fid = fopen('C:\Users\prave\Desktop\tct.txt', 'r');
data = fread(fid, '*char')'; % Read the entire file as a character array
fclose(fid);

% Extract numerical values from the text
values = str2num(data);

% Reshape the values into a 90 by 60 matrix
maze = reshape(values, 50, 50);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file_path = 'C:\Users\prave\Desktop\MRS project\paths2.txt';  % Replace with the path to your file

fid = fopen(file_path, 'r');
if fid == -1
    error('Could not open the file.');
end
    
path = {};  % Initialize a cell array to store lists of tuples

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

% Display the contents of the 'path' cell array
%for idx = 1:numel(path)
 %   disp(['Path ', num2str(idx), ':']);
  %  disp(path{idx});
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assuming path_list contains the first list of coordinates from your spatial map
% Assuming spatial_map is generated from your previous code

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

% Read the file as text
fid = fopen('C:\Users\prave\Desktop\tct.txt', 'r');
data = fread(fid, '*char')'; % Read the entire file as a character array
fclose(fid);

% Extract numerical values from the text
values = str2num(data);

% Reshape the values into a 90 by 60 matrix
maze = reshape(values, 50, 50);

% Create a spatial map with coordinates for each obstacle point
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


set(gcf, 'Position', get(0, 'Screensize'))
hold on;
axis equal;
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

FINAL=plotPathOnMap(path_list,path_list_2,path_list_3,path_list_4,path_list_5,maze,spatial_map);
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
    scatter(print_list(1,i)+0.5, print_list(2,i)+0.5, 30, 'red', 'filled');
    scatter(print_list(3,i)+0.5, print_list(4,i)+0.5, 30, 'red', 'filled');
    scatter(print_list(5,i)+0.5, print_list(6,i)+0.5, 30, 'red', 'filled');
    scatter(print_list(7,i)+0.5, print_list(8,i)+0.5, 30, 'red', 'filled');
    scatter(print_list(9,i)+0.5, print_list(10,i)+0.5, 30, 'red', 'filled');
    pause(1e-10000000)

    xlim([0 50.5]);
    ylim([0 50.5]);
end




% Assuming you have generated the spatial_map and accessed the first list (let's call it path_list)
function List1=plotPathOnMap(path_list,path_list_2,path_list_3,path_list_4,path_list_5,maze,spatial_map)
    %figure; % Create a new figure
    
    List1 = {};
    for a=1:5
        if a==2
            path_list=path_list_2;
        end
        if a==3
            path_list=path_list_3;
        end
        if a==4
            path_list=path_list_4;
        end
        if a==5
            path_list=path_list_5;
        end
        List=[];
        for i = 1:numel(path_list)/2

            current_point = path_list(i,:);
            y = current_point(1);
            x = current_point(2);
    
            % Plotting the current point in the path in red
            hold on;
            %scatter(x+0.5, y+0.5, 100, 'red', 'filled');
            xlim([0 50.5]);
            ylim([0 50.5]);
            
            % Plotting past points in the path in blue with a smaller size
            if i > 1
                past_point = path_list(i-1,:);
                %scatter(past_point(2)+0.5, past_point(1)+0.5, 50, 'blue', 'filled');
                xlim([0 50.5]);
                ylim([0 50.5]);
                hold on;
            end
            
            %pause(1); % Pause for 1 second before plotting the next point
            i+1
            if i+1<numel(path_list)/2 ||i+1==numel(path_list)/2 
                next_point = path_list(i+1,:)
                if i+2<numel(path_list)/2 
                    euc = path_list(i+2,:);
                end
            end
            y_n = next_point(1) ;
            x_n = next_point(2) ;
            x,y,x_n,y_n;
            
            Values = LQRNEGO(x,y,x_n,y_n);
    
            move = [[-1, 0 ], [ 0, -1],  [ 1, 0 ],[ 0, 1 ]]; 
            Frontier_node_x = x;
            Frontier_node_y = y;
            List=[List, Values]

        end
        List1{end+1} = List;
    end
    
    title('Path on Spatial Map');
    xlabel('X Coordinate');
    ylabel('Y Coordinate');
    xlim([0 50.5]); % Assuming the spatial map has dimensions of 90x60
    ylim([0 50.5]);
    %grid on;

end

