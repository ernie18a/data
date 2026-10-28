Calculation: Zero-lag EMA = EMA of close + (close minus close from floor((lookback - 1) / 2) bars ago), using the same lookback for the EMA and lag formula
Calculation: Volatility band width = 1.2 × the highest ATR over a lookback three times the ATR lookback
Calculation: Trend state = bullish after close crosses above zero-lag EMA + volatility band width; bearish after close crosses below zero-lag EMA − volatility band width; otherwise retain the previous state (initially neutral, displayed as bearish)
Calculation: Volume change percentage = 100 × (current bar volume − previous bar volume) / previous bar volume (0 when previous volume is 0)
Long: Trend state is bullish on any requested timeframe, using its last completed bar; OR volume change percentage exceeds the bullish threshold
Short: Trend state is bearish on any requested timeframe, using its last completed bar; OR volume change percentage is below the bearish threshold