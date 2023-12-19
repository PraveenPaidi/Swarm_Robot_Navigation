#!/usr/bin/env python
# coding: utf-8

# In[1]:


import numpy as np
import ast
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation


class Node:
    def __init__(self, parent=None, position=None,DIR='N'):
        self.parent = parent
        self.position = position

        self.g = 0
        self.h = 0
        self.f = 0
        self.rotation= DIR
    def __eq__(self, other):
        return self.position == other.position

    
#This function return the path of the search
def return_path(Frontier_node,maze):
    path = []
    no_rows, no_columns = np.shape(maze)
    
    result = [[-1 for i in range(no_columns)] for j in range(no_rows)]
    Frontier = Frontier_node
    
    while Frontier is not None:
        path.append(Frontier.position)
        Frontier = Frontier.parent

    path = path[::-1]
    start_value = 0
    
    for i in range(len(path)):
        result[path[i][0]][path[i][1]] = start_value
        start_value += 1
    return result

def visit(unexplored_list, explored_list):
    
    unexplored_list = sorted(unexplored_list, key=lambda x: x.g)    # g      
    Frontier_node = unexplored_list[0]
    del unexplored_list[0]
    explored_list.append(Frontier_node)
    
    return explored_list, unexplored_list,Frontier_node

def direction_difference(a, b):
    directions = [['N', 'E', 'S', 'W'], ['N', 'W', 'S', 'E']]
    
    min_steps = float('inf')
    
    for sequence in directions:
        steps = abs(sequence.index(a) - sequence.index(b))
        steps = min(steps, len(sequence) - steps)
        min_steps = min(min_steps, steps)
    
    return min_steps

def Chidren_nodes(no_rows,no_columns, node_position, Frontier_node,DIR):
    
    
    if 0 <= node_position[0] < no_rows and 0<= node_position[1] < no_columns and maze[node_position[0]][node_position[1]]==0:
                
        # Create new node
        new_node = Node(Frontier_node, node_position,DIR)
        return new_node
    
def Total_cost(Frontier_node, cost, child, end_node):
    # Create the f, g, and h values
    result = direction_difference(Frontier_node.rotation, child.rotation) 
    Or_cost= 2*result

    child.g = Frontier_node.g + cost + Or_cost   
                 

    ## Heuristic costs calculated here, this is using eucledian distance
    child.h = (((child.position[0] - end_node.position[0]) ** 2) + 
               ((child.position[1] - end_node.position[1]) ** 2)) 

    child.f = child.g + child.h*0.5
    
    return child.f
    

    
def search(maze, cost, start, end):

    start_node = Node(None, tuple(start))
    end_node = Node(None, tuple(end))
    unexplored_list = []  
    explored_list = [] 
    unexplored_list.append(start_node)
    move  =  [[-1, 0 ], [ 0, -1],  [ 1, 0 ],[ 0, 1 ]]  # UP, left, Down, right 
    no_rows, no_columns = np.shape(maze)
    
    i=0
    while len(unexplored_list) > 0:
           
        explored_list, unexplored_list, Frontier_node= visit(unexplored_list, explored_list)
        
        if Frontier_node == end_node:
            return return_path(Frontier_node,maze)
        
        # Generate children from all adjacent squares
        children = []

        for new_position in move: 
            
            # Get node position
           
            if (new_position[0],new_position[1])==(-1,0):
                node_position = (Frontier_node.position[0] + new_position[0], Frontier_node.position[1] + new_position[1])
                chi= Chidren_nodes(no_rows,no_columns, node_position, Frontier_node,'W')
            elif (new_position[0],new_position[1])==(1,0):
                
                node_position = (Frontier_node.position[0] + new_position[0], Frontier_node.position[1] + new_position[1])
                chi= Chidren_nodes(no_rows,no_columns, node_position, Frontier_node,'E')
                
            elif (new_position[0],new_position[1])==(0,1):
                
                node_position = (Frontier_node.position[0] + new_position[0], Frontier_node.position[1] + new_position[1])
                chi= Chidren_nodes(no_rows,no_columns, node_position, Frontier_node,'N')
                
            elif (new_position[0],new_position[1])==(0,-1):
                
                node_position = (Frontier_node.position[0] + new_position[0], Frontier_node.position[1] + new_position[1])
                chi= Chidren_nodes(no_rows,no_columns, node_position, Frontier_node,'S')
            else:
                print('There is an error')
                
            if chi is not None:
                children.append(chi)


        # Loop through children
        for child in children:
            j=0 
            
            #Child is on the explored list (search entire explored list)
            for i in explored_list:
                if i == child:
                    j=1
                    continue 
            if j==1:
                continue

            child.f =Total_cost(Frontier_node, cost, child, end_node)
            
            j=0
            
            # Child is already in the unexplored list and g cost is already lower
            for i in unexplored_list:
                if i == child and child.f > i.f:  
                    j=1
                    continue
            if j==1:
                continue


            # Add the child to the unexplored list
            unexplored_list.append(child)
            
def read_maze(file_name):
    with open(file_name, 'r') as file:
        content = file.read()
        maze_data = ast.literal_eval(content)

    return maze_data


def convert_path(path):
    new_path = []
    
    a=0;
    while a>-1:
        b=0
        c = len(new_path)
        for row in range(len(path)):
            for col in range(len(path[row])):

                if path[row][col] == a:
                    new_path.append([row, col])
                    
                    b= 1
                    if b==1:
                        break
            
            if b==1:
                a=a+1;
                break
        if c==len(new_path):
            break
                   
    return new_path

# File containing the maze data
maze_file = r'C:\Users\prave\Desktop\tct.txt'  # Replace with your file path

# Read the maze from the file
maze = read_maze(maze_file)
cost = 1 # cost per movement
      


# In[3]:


### robot position to be updated using values from utility function
# Start positions and end positions  
robo_start_positions =   [(12, 20), (14, 22), (38, 24), (19, 41), (10, 28)]
end_positions = [(48, 48), (48, 1), (1, 48), (37, 35), (48, 12)]


number_of_robo=5

Pairs=[]
DIFF_path =[]

for i in range(len(robo_start_positions)):
    for j in range(len(end_positions)):
        Pairs.append((robo_start_positions[i],end_positions[j]))
        #print(Pairs)
        
for i in range(len(Pairs)):
    
    start = Pairs[i][0] # starting position
    end = Pairs[i][1] # ending position
    
    cost = 1 # cost per movement
    path = search(maze,cost, start, end)
    totalcost = np.max(np.array(path))
    DIFF_path.append((start,end, path, totalcost))


# In[4]:


# Sorting costs for the best cost
sorted_values = sorted(DIFF_path, key=lambda x: x[3])
Total_list=[]
Costs=[]

# Findig the best set 
for i in range(len(sorted_values)):

    start_node = sorted_values[i]
    unexplored_list = []  
    Final_cost = 0
    unexplored_list.append(start_node)
    next_node= unexplored_list[0]

    i=1
    while len(unexplored_list) < number_of_robo:

        Frontier_node = next_node

        for i in sorted_values :

            if not any(i[0] == x[0] for x in unexplored_list):

                if not any(i[1] == x[1] for x in unexplored_list):

                    next_node = i
                    unexplored_list.append(next_node) 
                    break
    Final_cost = unexplored_list[0][3]+unexplored_list[1][3]+unexplored_list[2][3]
    Total_list.append(unexplored_list)
    Costs.append(Final_cost)

index = np.argmin(Costs)
FINAL_SET= Total_list[index]


paths = []

for i in range(number_of_robo):
    paths.append(FINAL_SET[i][2]) if i < len(FINAL_SET) else paths.append(None)

# Assign values to path variables dynamically
path_variables = [f"path{i+1}" for i in range(number_of_robo)]
for i, path_var in enumerate(path_variables):
    if i < len(paths):
        locals()[path_var] = paths[i]
    else:
        locals()[path_var] = None


# In[5]:


paths =[]
for path_var in path_variables:
    converted_path = convert_path(eval(path_var))
    locals()[path_var] = converted_path
    paths.append(converted_path)


# In[6]:


# find the intersections
matching_pairs = []
match_pair=[]

for idx, path in enumerate(paths):
    ending_point = path[-1]
    other_paths = paths[:idx] + paths[idx + 1:]  # Excluding the current path

    for other_path in other_paths:
        if ending_point in other_path:
            matching_pairs.append((ending_point, f"path{idx + 1} and path{paths.index(other_path) + 1}"))
            match_pair.append((idx + 1,paths.index(other_path) + 1))

# Display matching pairs
if matching_pairs:
    print("Matching ending points found:")
    for pair in matching_pairs:
        print(f"Ending point {pair[0]} is in {pair[1]}")
else:
    print("No matching ending points found.")
    


# In[7]:


unique_pairs = []

for pair in match_pair:
    if pair[0] not in [other_pair[1] for other_pair in match_pair if pair != other_pair]:
        unique_pairs.append(pair)

if unique_pairs:
    print("Unique pairs:", unique_pairs)
else:
    print("No such unique pairs found.")


# In[8]:


for pair in unique_pairs:

    intersection_point = None

    for point in paths[pair[0]-1]:
        if point in paths[pair[1]-1]:
            intersection_point = point
            index_path2 = paths[pair[0]-1].index(intersection_point)
            index_path3 = paths[pair[1]-1].index(intersection_point)
            break

    print("Intersection Point:", intersection_point)

    diff = abs(index_path2 - index_path3)
    
    path_variable_index = pair[0]  # Assuming pair[1] determines the index for the path
    dynamic_path = path_variables[path_variable_index-1]


    last_sublist = path3[index_path2-2]
    first_part = path3[:index_path2-2]
    second_part = path3[index_path2-2:]

    paths[pair[0]-1] = first_part + [last_sublist]*(diff+2) + second_part


# In[66]:


# Assuming path_for_matlab contains lists of paths, each path represented as a list of coordinate tuples (x, y)
path_for_matlab = [path1, path2, path3, path4, path5]  # Example paths

# save the path if you'd like to transfer this to input matlab 
# output_file_path = 'paths4.txt'

# Writing paths to the file
with open(output_file_path, 'w') as output_file:
    for path in path_for_matlab:
        output_file.write('[' + ', '.join([f'({x}, {y})' for x, y in path]) + ']\n')

print(f'Paths have been saved to "{output_file_path}".')


# In[36]:


# with negotiation.

paths_adjusted = []
    
for path in paths:
        
    max_path_length = max(len(path) for path in paths)
    diff = max_path_length - len(path)
    if diff > 0:

        last_sublist = path[-1]  # Get the last sublist
        path_padded = path + [last_sublist] * diff  # Replicate the last sublist 'diff' times and concatenate

        adjusted_path = path_padded

        paths_adjusted.append(adjusted_path)
    else:
        paths_adjusted.append(path)
        
        
# save the path if you'd like to transfer this to input matlab  after the negotiation
# output_file_path = 'paths5.txt'

        
with open(output_file_path, 'w') as output_file:
    for path in paths_adjusted:
        output_file.write('[' + ', '.join([f'({x}, {y})' for x, y in path]) + ']\n')

print(f'Paths have been saved to "{output_file_path}".')

