Calculation: Large-body bar = abs(close − open) > (high − low) × body-size threshold
Long: previous bar's MFI = overbought level AND close > open AND Large-body bar AND (trend filter disabled OR close > simple moving average) AND datetime within configured session
Short: previous bar's MFI = oversold level AND close < open AND Large-body bar AND (trend filter disabled OR close ≤ simple moving average) AND datetime within configured session
Exit: Long, low ≤ entry price × (1 − stop-loss fraction) OR high ≥ entry price × (1 + take-profit fraction) OR datetime outside configured session
Exit: Short, high ≥ entry price × (1 + stop-loss fraction) OR low ≤ entry price × (1 − take-profit fraction) OR datetime outside configured session