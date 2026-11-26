Calculation: High-offset line = smooth(open - open of the bar with the highest high over lookback L, method M, smoothing length S, phase P)
Calculation: Low-offset line = smooth(open of the bar with the lowest low over lookback L - open, method M, smoothing length S, phase P)
Long: High-offset line[1] > Low-offset line[1] AND High-offset line[0] <= Low-offset line[0]
Short: High-offset line[1] < Low-offset line[1] AND High-offset line[0] >= Low-offset line[0]
Exit: long, High-offset line[1] < Low-offset line[1]
Exit: short, High-offset line[1] > Low-offset line[1]