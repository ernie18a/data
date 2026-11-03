Calculation: CCI = Commodity Channel Index of typical price on the configured indicator timeframe, evaluated on the selected signal bar and its immediately preceding bar; the timeframe may be higher or lower than the chart timeframe, and the selected bar may be completed or still forming according to the configured signal-bar offset.
Calculation: ATR = Average True Range on the configured indicator timeframe and selected signal bar.
Calculation: Bullish SuperTrend line = when CCI is above its threshold, the lower of low minus ATR and the prior bullish line if CCI was at or above the threshold on the prior bar; when CCI crosses from below to at or above the threshold, use the prior bearish SuperTrend line.
Calculation: Bearish SuperTrend line = when CCI is below its threshold, the higher of high plus ATR and the prior bearish line if CCI was at or below the threshold on the prior bar; when CCI crosses from above to at or below the threshold, use the prior bullish SuperTrend line.
Long: prior bearish SuperTrend line exists AND CCI crosses from below to at or above its threshold.
Short: prior bullish SuperTrend line exists AND CCI crosses from above to at or below its threshold.
Exit: long, bearish SuperTrend line exists on the selected signal bar.
Exit: short, bullish SuperTrend line exists on the selected signal bar.