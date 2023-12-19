import numpy as np
import random
from PIL import Image
from scipy.stats import norm
import matplotlib.pyplot as plt
import ast
B = []
# Reading Map
def until_fucntion(filename, N, robot_positions):
    # filename with extension list of lists of Map
    # Number of bots
    # List of tuple of agent position[(x1,y1),(x2,y2)]
    # Output is list of tuple - target robot position
    with open(filename, 'r') as file:
        content = file.read()
        matrix = np.array(ast.literal_eval(content))
        B =np.array([[matrix[j][i] for j in range(len(matrix))] for i in range(len(matrix[0]))])


    # Print the resulting NumPy array
    np.subtract(1, B, out=B)
    # print(B)
    r = len(B)
    c = len(B[0])


    # Setting Agent positions
    A1 = np.zeros((r,c))

    for coord in robot_positions:
        row, col = coord
        A1[row][col] = 1

    # def place_bots(matrix, num_bots=N):
    #     rows, cols = len(matrix), len(matrix[0])
    #     i = 0
    #     while i < num_bots:
    #         row = random.randint(0, rows - 1)
    #         col = random.randint(0, cols - 1)
    #         if B[row, col] != 0 and ((row,col) not in robot_positions):
    #             matrix[row][col] = random.randint(1,4)
    #             robot_positions.append((row,col))
    #             i += 1
    #     return matrix
    # A1 = place_bots(A1, num_bots=N)


    # Bot coverage:
    AC = np.ones((r, c))
    row = list(range(r))
    col = list(range(c))
    for i in range(r):
        for j in range(c):
            # row_ind = row.index(i)
            # col_ind = col.index(j)

            if A1[i, j] == 1:
                AC[i, j] == 0
                # AC[i-2, max(0,j-1):j+2] = 0
                AC[i-1,max(0,j-1):j+2] = 0
            if A1[i, j] == 2:
                AC[i, j] == 0
                AC[max(0,i-1):i+2, j+1:j + 2] = 0
            if A1[i, j] == 3:
                AC[i, j] == 0
                AC[i+1:i+2, max(0,j-1):j+2] = 0
            if A1[i, j] == 4:
                AC[i, j] == 0
                AC[max(0,i-1):i+2, max(0,j-1):j] = 0
    #
    # plt.figure()
    # plt.imshow(AC)
    # for coord in robot_positions:
    #     plt.scatter(coord[1], coord[0], marker='o', color='red', s=20)
    # plt.gca().invert_yaxis()



    x =  np.linspace(0,r)
    y = np.linspace(0,c)
    X, Y = np.meshgrid(x, y)

    A_XY = np.zeros((r,c))
    B_XY = np.zeros((r,c))
    rows, cols = len(AC), len(AC[0])
    for i in range(rows):
        for j in range(cols):
            if AC[i,j] !=0:
                A_XY[i,j] = AC[i,j]
            if B[i,j]!= 0:
                B_XY[i, j] = B[i, j]

    x_values, y_values = zip(*robot_positions)
    XY = A_XY+B_XY

    # Parameters
    mean = 0
    std_dev =1
    # Create a normal distribution
    gaussian_distribution = norm(loc=mean, scale=std_dev).rvs()


    Sa = A_XY * gaussian_distribution
    Sb = B_XY * gaussian_distribution

    C = np.divide(Sa, Sb, out=np.zeros_like(Sa), where=(Sb != 0))

    min_val = np.min(C)
    max_val = np.max(C)

    normalized_matrix = (C - min_val) / (max_val - min_val)

    x_values, y_values = zip(*robot_positions)

    # Create a grid plot
    plt.figure(1)
    plt.imshow(C)
    # for i in range(rows):
    #     for j in range(cols):
    #         text = plt.text(j, i, f'{C[i, j]}', ha='center', va='center', color='w', fontsize=8)
    for coord in robot_positions:
        plt.scatter(coord[1], coord[0], marker='o', color='red', s=20)
    plt.xlabel('x')
    plt.ylabel('y')
    plt.gca().invert_yaxis()
    plt.title('Grid Plot from Matrix with coverage')


    plt.figure(2)
    plt.title('Density of Accessible Cells C')
    plt.contourf(C, cmap='viridis', origin='lower')
    for coord in robot_positions:
        plt.scatter(coord[1], coord[0], marker='o', color='red', s=20)
    plt.xlabel('x')
    plt.ylabel('y')
    # plt.gca().invert_yaxis()
    plt.colorbar()


    ### Cost estimate
    cost_matrix = A1
    k = 1
    robot_target_list = []
    prt_complete = np.zeros((r,c))
    for each_bot in robot_positions:
        # print(each_bot)
        selected_grid = each_bot  # Replace with the coordinates of your selected grid
        orientation = np.zeros_like(cost_matrix)
        # Calculate distances
        distances = np.zeros_like(cost_matrix, dtype=float)
        for i in range(cost_matrix.shape[0]):
            for j in range(cost_matrix.shape[1]):
                distances[i, j] = np.sqrt((i - selected_grid[0]) ** 2 + (j - selected_grid[1]) ** 2)

                if cost_matrix[selected_grid] == 1:
                    if j != selected_grid[1]:
                        orientation[i,j] += 1
                    if j == selected_grid[1] and i>selected_grid[0]:
                        orientation[i,j] += 1
                    if i > selected_grid[0]:
                        orientation[i,j] += 1
                if cost_matrix[selected_grid] == 3:
                    if j != selected_grid[1]:
                        orientation[i,j] += 1
                    if j == selected_grid[1] and i<selected_grid[0]:
                        orientation[i,j] += 1
                    if i < selected_grid[0]:
                        orientation[i,j] += 1
                if cost_matrix[selected_grid] == 2:
                    if j < selected_grid[1]:
                        orientation[i,j] += 1
                    if i == selected_grid[0] and j < selected_grid[1]:
                        orientation[i,j] += 1
                    if i != selected_grid[0]:
                        orientation[i,j] += 1
                if cost_matrix[selected_grid] == 4:
                    if j > selected_grid[1]:
                        orientation[i,j] += 1
                    if i == selected_grid[0] and j>selected_grid[1]:
                        orientation[i,j] += 1
                    if i != selected_grid[0]:
                        orientation[i,j] += 1
                if B[i,j] == 0:
                    distances[i, j] = 0
                    orientation[i, j] = 0

        distances = distances+orientation
        # Min-Max normalization
        min_value = np.min(distances)
        max_value = np.max(distances )
        profit = (distances - min_value) / (max_value - min_value)
        for each_point in robot_target_list:
            profit[max(0,each_point[0]-10):min(49,each_point[0]+10+1),max(0,each_point[1]-10):min(49,each_point[1]+10+1)] = -1
        # profit = (np.ones_like(normalized_matrix)-normalized_matrix) - (np.ones_like(normalized_matrix)-normalized_distance)
        max_element = np.argmax(profit)
        max_value_position = np.unravel_index(max_element, profit.shape)


        added = False
        while not added:
            if max_value_position in robot_target_list:
                profit[max_value_position] = -1
                max_element = np.argmax(profit)
                max_value_position = np.unravel_index(max_element, profit.shape)


            if max_value_position not in robot_target_list:
                robot_target_list.append(max_value_position)
                # for ss in range(6):
                    # profit[max(0,max_value_position[0] - ss):, max(0,max_value_position[1]-ss)] = -1
                    # profit[min(49,max_value_position[0] + ss),min(max_value_position[1]+ss, 49)] = -1
                    # profit[max(0, max_value_position[0] - ss), min(49, max_value_position[1] + ss)] = -1
                    # profit[min(49, max_value_position[0] + ss), max(max_value_position[1] - ss, 0)] = -1



                added = True

        prt_complete += profit

    plt.figure(3)
    plt.title('Combined density function')
    plt.contourf(prt_complete, cmap='viridis', origin='lower')
    for coord in robot_positions:
        plt.scatter(coord[1], coord[0], marker='o', color='red', s=20)
    for coord1 in robot_target_list:
        plt.scatter(coord1[1], coord1[0], marker='*', color='red', s=50)
    # plt.gca().invert_yaxis()
    plt.xlabel('x')
    plt.ylabel('y')
    plt.colorbar()

    print(robot_positions)
    print(robot_target_list)

    # plt.figure(4)
    # plt.title('Robot positions')
    # plt.contourf(B, cmap='gray', origin='lower')
    # for coord in robot_positions:
    #     plt.scatter(coord[1], coord[0], marker='o', color='red', s=50)
    # for coord1 in robot_target_list:
    #     plt.scatter(coord1[1], coord1[0], marker='*', color='red', s=50)
    # plt.xlabel('x')
    # plt.ylabel('y')
    plt.show()
    return robot_target_list


#
# robot_position = [(12,20),(14,22),(38,24),(19,41), (10,28)]
# t_p = until_fucntion("tct.txt", 5, robot_position)
