Long: MFI(hlc3) < long threshold AND RSI(hlc3) < long threshold AND Stoch RSI %K < long threshold AND Stoch RSI %D < long threshold
Short: MFI(hlc3) > short threshold AND RSI(hlc3) > short threshold AND Stoch RSI %K > short threshold AND Stoch RSI %D > short threshold
Exit: long, low <= entry price * long stop multiplier
Exit: short, high >= entry price * short stop multiplier