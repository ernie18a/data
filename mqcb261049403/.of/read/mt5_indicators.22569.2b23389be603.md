Calculation: Smoothed candle direction = Apply the same selected moving average method and parameters separately to open and close. Set adjusted open to the previous bar's smoothed close when abs(open - close) <= the gap threshold in price units; otherwise use the current smoothed open. Set direction to +1 when smoothed close > adjusted open, -1 when smoothed close < adjusted open, and retain the previous direction when they are equal; initialize direction to 0.
Long: Chart-timeframe smoothed candle direction > 0 AND previous direction <= 0
Short: Chart-timeframe smoothed candle direction < 0 AND previous direction >= 0
Long: Smoothed candle direction on the still-forming higher-timeframe bar > 0
Short: Smoothed candle direction on the still-forming higher-timeframe bar < 0