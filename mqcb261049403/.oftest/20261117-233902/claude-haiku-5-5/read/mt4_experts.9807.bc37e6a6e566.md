Calculation: OsMA = OsMA(applied price, fast EMA period, slow EMA period, signal period) on T1 bars, where [0] is the bar still forming
Long: position side is flat AND OsMA[3] > OsMA[2] AND OsMA[2] < OsMA[1] AND OsMA[1] < OsMA[0]
Short: position side is flat AND OsMA[3] < OsMA[2] AND OsMA[2] > OsMA[1] AND OsMA[1] > OsMA[0]
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance