#!/usr/bin/python3

import sys

depthmap = []
potentials = []

y=0
for line in sys.stdin.readlines():
    line = line.rstrip()
    points = []
    for x in range(0, len(line)):
        points.append((int(line[x]), (x, y)))
    y += 1
        
    depthmap.append(points)

max_x = len(depthmap[0])
max_y = len(depthmap)

def neighbors(x, y):
    for nx, ny in [(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)]:
        if nx >= 0 and ny >= 0 and nx < max_x and ny < max_y:
            yield (nx, ny)

def collect_basin(x, y):
    count = 1
    depthmap[y][x] = (9, (x, y))
    for nx, ny in neighbors(x, y):
        if depthmap[ny][nx][0] < 9:
            count += collect_basin(nx, ny)
    return count

basins = []
for y in range(0, len(depthmap)):
    for x in range(0, len(depthmap[0])):
        if depthmap[y][x][0] < 9:
            basins.append(collect_basin(x, y))

total = 1
for basin in sorted(basins)[-3:]:
    total *= basin
print(total)
