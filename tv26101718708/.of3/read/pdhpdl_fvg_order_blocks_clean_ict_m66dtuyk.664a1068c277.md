Long: Chart-bar low < prior completed T1 low AND chart-bar close > prior completed T1 low
Short: Chart-bar high > prior completed T1 high AND chart-bar close < prior completed T1 high
Long: Chart-bar low > high[2] AND low - high[2] > ATR(lookback) * FVG-size parameter
Short: Chart-bar high < low[2] AND low[2] - high > ATR(lookback) * FVG-size parameter
Long: Chart-bar close > open AND abs(close - open) > ATR(lookback) * displacement parameter AND close[1] < open[1] AND high[1] - low[1] > ATR(lookback) * minimum OB-size parameter AND (FVG filter disabled OR (low > high[2] AND low - high[2] > ATR(lookback) * FVG-size parameter))
Short: Chart-bar close < open AND abs(close - open) > ATR(lookback) * displacement parameter AND close[1] > open[1] AND high[1] - low[1] > ATR(lookback) * minimum OB-size parameter AND (FVG filter disabled OR (high < low[2] AND low[2] - high > ATR(lookback) * FVG-size parameter))