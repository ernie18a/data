Calculation: B = Bezier(close, parameter, T1, last completed bar)
Long: B[1] < B[2] AND B[0] > B[1]
Short: B[1] > B[2] AND B[0] < B[1]
Exit: long, B[0] < B[1]
Exit: short, B[0] > B[1]
Long: position side is long AND current chart bar high is more than parameter points above entry price
Short: position side is short AND current chart bar low is more than parameter points below entry price