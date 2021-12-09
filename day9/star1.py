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
        if x > 0:
            if int(line[x]) >= int(line[x-1]):
                continue
        if x < len(line) - 1:
            if int(line[x]) >= int(line[x+1]):
                    continue
        potentials.append((int(line[x]), (x,y)))

    y += 1
        
    depthmap.append(points)



max_x = len(depthmap[0])
max_y = len(depthmap)

lowpoints = []
for point in potentials:
    (x, y) = point[1]
    valid=True
    for nx, ny in [(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)]:
        if nx >= 0 and ny >= 0 and nx < max_x and ny < max_y:
            if point[0] > depthmap[ny][nx][0]:
                valid=False
                break
    if valid:
        lowpoints.append(point)

total=0
for point in lowpoints:
    total += point[0] + 1

print(total)
