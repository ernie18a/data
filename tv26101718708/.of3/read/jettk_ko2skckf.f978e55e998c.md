Calculation: Overbought state = Highest(IIF(close < Highest(SMA(HLC3, shorter lookback), longer lookback), 1, 0), shorter lookback) == 0
Calculation: Oversold state = Sum(IIF(close < Lowest(SMA(HLC3, shorter lookback), longer lookback), 1, 0), shorter lookback) == shorter lookback
Long: Oversold state[1] AND NOT Oversold state
Short: Overbought state[1] AND NOT Overbought state
Long: low > high[2] AND (low - high[2]) / close * 100 >= minimum gap percentage
Short: high < low[2] AND (low[2] - high) / close * 100 >= minimum gap percentage