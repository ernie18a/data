Calculation: Doji = abs(current close - current open) <= (current high - current low) × doji-size parameter
Calculation: Long entry stop = current high if the previous candle's absolute body divided by its range exceeds the long-candle-ratio parameter and its range exceeds the current range; otherwise, the greater of current high and previous high
Calculation: Short entry stop = current low if the previous candle's absolute body divided by its range exceeds the long-candle-ratio parameter and its range exceeds the current range; otherwise, the lesser of current low and previous low
Long: Doji AND datetime is within the configured date window AND (volume filter is disabled OR current volume > current volume moving average) AND current high >= long entry stop
Short: Doji AND datetime is within the configured date window AND (volume filter is disabled OR current volume > current volume moving average) AND current low <= short entry stop
Exit: Long, stop-loss/take-profit is enabled AND (current low <= entry price - stop-loss distance OR current high >= entry price + take-profit distance)
Exit: Short, stop-loss/take-profit is enabled AND (current high >= entry price + stop-loss distance OR current low <= entry price - take-profit distance)
Exit: Long, stop-loss/take-profit is disabled AND (current close < current Doji low OR current high >= entry price + take-profit distance)
Exit: Short, stop-loss/take-profit is disabled AND (current close > current Doji high OR current low <= entry price - take-profit distance)