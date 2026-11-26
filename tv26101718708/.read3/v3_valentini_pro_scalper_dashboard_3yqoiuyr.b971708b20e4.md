Long: position side is flat AND crosses above highest(high[1], breakout lookback) AND volume > SMA(volume, volume-average lookback) × aggression multiplier AND close > VWAP(hlc3)
Short: position side is flat AND crosses below lowest(low[1], breakout lookback) AND volume > SMA(volume, volume-average lookback) × aggression multiplier AND close < VWAP(hlc3)
Long: position side is long AND high >= entry price + scale-in trigger
Short: position side is short AND low <= entry price - scale-in trigger
Exit: long, low <= entry price when the scale-in trigger has been reached since entry, or low <= entry price - initial stop loss when it has not, or high >= entry price + take profit
Exit: short, high >= entry price when the scale-in trigger has been reached since entry, or high >= entry price + initial stop loss when it has not, or low <= entry price - take profit