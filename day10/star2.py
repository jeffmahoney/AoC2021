#!/usr/bin/python3

import sys

values = {
        '(' : 1,
        '[' : 2,
        '{' : 3,
        '<' : 4,
}

opens = {
        '[' : ']',
        '(' : ')',
        '{' : '}',
        '<' : '>',
}

close = dict([(value, key) for key, value in opens.items()])

scores = []
for line in sys.stdin.readlines():

    col = 0
    stack = []
    total = 0
    for c in list(line.rstrip()):
        if c in opens:
            stack.append(c)
        else:
            try:
                last = stack.pop()
            except IndexError:
                print(f"Syntax error col {col} - expected opener, but found {c} instead")
                break

            if last != close[c]:
                stack = []
                break
        col += 1

    for c in stack[::-1]:
        total *= 5
        total += values[c]
    if total:
        scores.append(total)

print(sorted(scores)[int(len(scores)/2)])
