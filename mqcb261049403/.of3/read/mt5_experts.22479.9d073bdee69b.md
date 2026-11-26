Calculation: upper channel = open(T1, first bar at configured start hour of the day) + channel offset parameter in points
Calculation: lower channel = open(T1, first bar at configured start hour of the day) - channel offset parameter in points
Long: long-entry permission enabled AND on chart bars using T1 values, close of the selected signal bar (last completed T1 bar in READ) > upper channel AND close of the preceding T1 bar <= its upper channel
Short: short-entry permission enabled AND on chart bars using T1 values, close of the selected signal bar (last completed T1 bar in READ) < lower channel AND close of the preceding T1 bar >= its lower channel
Exit: long, long-exit permission enabled AND on chart bars using T1 values, close of the selected signal bar < lower channel AND (short-entry permission disabled OR the preceding T1 bar was already below its lower channel)
Exit: short, short-exit permission enabled AND on chart bars using T1 values, close of the selected signal bar > upper channel AND (long-entry permission disabled OR the preceding T1 bar was already above its upper channel)
Exit: long, timed exits enabled AND elapsed time since position entry > holding-duration parameter
Exit: short, timed exits enabled AND elapsed time since position entry > holding-duration parameter