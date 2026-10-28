Calculation: Center = selected moving average of the selected source over a lookback, on the selected timeframe bars (last completed bar historically; still-forming bar in real time)
Calculation: Upper and lower thresholds = selected-timeframe close standard deviation over the same lookback, multiplied by a deviation factor, added to and subtracted from Center
Calculation: Follow Line = if selected-timeframe close is above the upper threshold, the greater of the previous Follow Line and selected-timeframe low minus selected-timeframe ATR; if close is below the lower threshold, the lesser of the previous Follow Line and selected-timeframe high plus selected-timeframe ATR; otherwise the previous Follow Line
Calculation: Trend direction = +1 when Follow Line rises from the previous bar, -1 when it falls, otherwise retain the previous direction
Long: Previous trend direction = -1 AND current trend direction = +1
Short: Previous trend direction = +1 AND current trend direction = -1