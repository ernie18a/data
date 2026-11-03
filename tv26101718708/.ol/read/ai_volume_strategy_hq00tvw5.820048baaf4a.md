Calculation: volume spike = volume > EMA(volume, lookback) × multiplier
Long: volume spike AND close > EMA(close, lookback) AND close > open
Short: volume spike AND close < EMA(close, lookback) AND close < open
Exit: long, bars since most recent entry signal (counting its bar as 1) >= exit-bar parameter
Exit: short, bars since most recent entry signal (counting its bar as 1) >= exit-bar parameter