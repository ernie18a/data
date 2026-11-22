Calculation: filledAveragingOrders = number of averaging order entries since the current position was opened
Long: position side is flat AND datetime >= window start AND datetime <= window end AND RSI(close, lookback, T1, last completed bar) < entry level
Long: position side is long AND datetime >= window start AND datetime <= window end AND filledAveragingOrders = 0 AND close <= entry price * (1 - first deviation / 100)
Long: position side is long AND datetime >= window start AND datetime <= window end AND filledAveragingOrders = 1 AND close <= entry price * (1 - second deviation / 100)
Long: position side is long AND datetime >= window start AND datetime <= window end AND filledAveragingOrders = 2 AND close <= entry price * (1 - third deviation / 100)
Long: position side is long AND datetime >= window start AND datetime <= window end AND filledAveragingOrders = 3 AND close <= entry price * (1 - fourth deviation / 100)
Long: position side is long AND datetime >= window start AND datetime <= window end AND filledAveragingOrders = 4 AND close <= entry price * (1 - fifth deviation / 100)
Exit: long, close >= average entry price * (1 + take-profit / 100)