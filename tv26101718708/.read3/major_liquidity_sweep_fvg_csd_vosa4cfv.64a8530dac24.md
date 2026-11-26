Long: low < latest confirmed Pivot Low(low, major swing lookback, major swing lookback) AND close > that pivot low AND that pivot low - low >= ATR(ATR lookback) * minimum sweep ATR multiple AND (volume filter disabled OR volume > SMA(volume, volume lookback))
Short: high > latest confirmed Pivot High(high, major swing lookback, major swing lookback) AND close < that pivot high AND high - that pivot high >= ATR(ATR lookback) * minimum sweep ATR multiple AND (volume filter disabled OR volume > SMA(volume, volume lookback))
Long: low > high[2] AND low - high[2] >= ATR(ATR lookback) * minimum FVG ATR multiple
Short: high < low[2] AND low[2] - high >= ATR(ATR lookback) * minimum FVG ATR multiple
Long: a bullish liquidity sweep is pending CSD AND close > latest confirmed Pivot High(high, internal swing lookback, internal swing lookback)
Short: a bearish liquidity sweep is pending CSD AND close < latest confirmed Pivot Low(low, internal swing lookback, internal swing lookback)