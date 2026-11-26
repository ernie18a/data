Calculation: B = Blau CSI(T1) values sampled on chart bars; B[0] is the still-forming T1 bar, B[1] is the last completed T1 bar, and B[2] is the preceding completed T1 bar
Long: B[0] > 0
Short: B[0] < 0
Long: (the selected entry algorithm uses a zero-line break AND B[1] > 0 AND B[0] <= 0) OR (the selected entry algorithm uses a direction change AND B[1] < B[2] AND B[0] >= B[1])
Short: (the selected entry algorithm uses a zero-line break AND B[1] < 0 AND B[0] >= 0) OR (the selected entry algorithm uses a direction change AND B[1] > B[2] AND B[0] <= B[1])
Exit: Long, (the selected entry algorithm uses a zero-line break AND B[1] < 0) OR (the selected entry algorithm uses a direction change AND B[1] > B[2])
Exit: Short, (the selected entry algorithm uses a zero-line break AND B[1] > 0) OR (the selected entry algorithm uses a direction change AND B[1] < B[2])