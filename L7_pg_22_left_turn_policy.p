# ----------
# User Instructions:
# 
# Implement the function optimum_policy2D below.
#
# You are given a car in grid with initial state
# init. Your task is to compute and return the car's 
# optimal path to the position specified in goal; 
# the costs for each motion are as defined in cost.
#
# There are four motion directions: up, left, down, and right.
# Increasing the index in this array corresponds to making a
# a left turn, and decreasing the index corresponds to making a 
# right turn.

forward = [[-1,  0], # go up
           [ 0, -1], # go left
           [ 1,  0], # go down
           [ 0,  1]] # go right
forward_name = ['up', 'left', 'down', 'right']

# action has 3 values: right turn, no turn, left turn
action = [-1, 0, 1]
action_name = ['R', '#', 'L']

# EXAMPLE INPUTS:
# grid format:
#     0 = navigable space
#     1 = unnavigable space 
grid = [[1, 1, 1, 0, 0, 0],
        [1, 1, 1, 0, 1, 0],
        [0, 0, 0, 0, 0, 0],
        [1, 1, 1, 0, 1, 1],
        [1, 1, 1, 0, 1, 1]]
#print(len(grid))
#print(len(grid[0]))

init = [4, 3, 0] # given in the form [row,col,direction]
                 # direction = 0: up
                 #             1: left
                 #             2: down
                 #             3: right
                
goal = [2, 0] # given in the form [row,col]

cost = [2, 1, 15] # cost has 3 values, corresponding to making 
                  # a right turn, no turn, and a left turn

# EXAMPLE OUTPUT:
# calling optimum_policy2D with the given parameters should return 
# [[' ', ' ', ' ', 'R', '#', 'R'],
#  [' ', ' ', ' ', '#', ' ', '#'],
#  ['*', '#', '#', '#', '#', 'R'],
#  [' ', ' ', ' ', '#', ' ', ' '],
#  [' ', ' ', ' ', '#', ' ', ' ']]
# ----------

# ----------------------------------------
# modify code below
# ----------------------------------------

def optimum_policy2D(grid,init,goal,cost):
    
    policy2D = [[' ' for row in range(len(grid[0]))] for col in range(len(grid))]
    value2D = [[999 for row in range(len(grid[0]))] for col in range(len(grid))]
    
    policy = [[[' ' for row in range(len(grid[0]))] for col in range(len(grid))],
              [[' ' for row in range(len(grid[0]))] for col in range(len(grid))],
              [[' ' for row in range(len(grid[0]))] for col in range(len(grid))],
              [[' ' for row in range(len(grid[0]))] for col in range(len(grid))]]

    value = [[[999 for row in range(len(grid[0]))] for col in range(len(grid))],
             [[999 for row in range(len(grid[0]))] for col in range(len(grid))],
             [[999 for row in range(len(grid[0]))] for col in range(len(grid))],
             [[999 for row in range(len(grid[0]))] for col in range(len(grid))]]
    change = True
    number_of_times = 0
    while change:
        change = False
        number_of_times+=1
        print('number_of_times = ',number_of_times)
        for x in range(len(grid)):
            for y in range(len(grid[0])):
                print('[x, y] = ', [x,y])
                for orientation in range(4):
                    #print('just printing [o,x,y]')
                    #print([orientation,x,y])   
                    if goal[0]==x and goal[1]==y:
                        policy[orientation][x][y] = '*'
                        if value[orientation][x][y] >0:
                            value[orientation][x][y] = 0
                            change = True
                            #print('I ran if part')
                    elif grid[x][y]==0:
                        #print('I ran elseif part: o, x, y:',[orientation,x,y])
                        for a in range(3):
                            o2 = (orientation + action[a]) % 4
                            x2 = x + forward[o2][0]
                            y2 = y + forward[o2][1]
                            #print('     range loop: o2, x2, y2:',[o2,x2,y2])
                            if x2>=0 and x2<len(grid) and y2>=0 and y2<len(grid[0]) and grid[x2][y2]==0:
                                v2 = cost[a] + value[o2][x2][y2]
                                #print('orientation = ',orientation, 'cost = ',cost[a],' + value = ',value[o2][x2][y2],' Final Value = ',v2)

                                if v2 < value[orientation][x][y]:
                                    value[orientation][x][y] = v2
                                    policy[orientation][x][y] = action_name[a]
                                    change = True
                            
    #print('orientation = ',len(value))
    #print('x coord = ',len(value[0]))
    #print('y coord = ',len(value[0][0]))
    
    #for i in range(len(value)):
    #    print('new orientation')
    #    for j in range(len(value[0])):
    #        #print(value[i][j])
    #        print(policy[i][j])
    
    x = init[0]
    y = init[1]
    orientation = init[2]
    policy2D[x][y] = policy[orientation][x][y]
    value2D[x][y] = value[orientation][x][y]
    while policy[orientation][x][y]!='*':
        if policy[orientation][x][y] == '#':
            o2 = orientation
        elif policy[orientation][x][y] == 'R':
            o2 = (orientation - 1) % 4
        if policy[orientation][x][y] == 'L':
            o2 = (orientation + 1) % 4
        x = x + forward[o2][0]
        y = y + forward[o2][1]
        orientation = o2
        
        policy2D[x][y] = policy[orientation][x][y]
        value2D[x][y] = value[orientation][x][y]
                
    
    return policy2D # value2D

policy2D = optimum_policy2D(grid,init,goal,cost)
for i in range(len(policy2D)):
    print(policy2D[i])
