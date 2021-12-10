#!/usr/bin/python3

import sys

state = {
        ']' : 0,
        ')' : 0,
        '}' : 0,
        '>' : 0
}

values = {
        ']' : 57,
        ')' : 3,
        '}' : 1197,
        '>' : 25137,
}

close = {
        ']' : '[',
        ')' : '(',
        '}' : '{',
        '>' : '<',
}
opens = {
        '[' : ']',
        '(' : ')',
        '{' : '}',
        '<' : '>',
}

for line in sys.stdin.readlines():

    col = 0
    stack = []
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
                print(f"Syntax error col {col} - expected {opens[last]}, but found {c} instead")
                state[c] += 1
                break
        col += 1
print(state)
total = 0
for c, count in state.items():
    total += values[c] * count
print(total)
