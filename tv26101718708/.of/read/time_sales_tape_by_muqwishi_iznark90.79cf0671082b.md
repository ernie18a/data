Calculation: Tick side = evaluated on each bar of a timeframe lower than the chart timeframe: up if close > previous close, down if close < previous close, otherwise the previous tick side is carried forward (initial state is down).
Calculation: Up volume / Down volume = sum of volume over the most recent N lower-timeframe bars with volume > 0, split by tick side up / down.
Long: lower-timeframe bar volume > 0 AND tick side is up
Short: lower-timeframe bar volume > 0 AND tick side is down
Long: Up volume >= Down volume
Short: Down volume > Up volume