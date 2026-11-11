Calculation: Prior high and prior low = high and low of the last completed higher-timeframe bar.
Calculation: VWAP = session-anchored cumulative sum of typical price × volume divided by cumulative volume, where typical price = (high + low + close) / 3.
Long: Close > prior high AND previous close <= current prior high.
Long: Close > prior low AND previous close <= current prior low.
Long: Each of the preceding lookback bars closed below its own VWAP AND close > VWAP AND close > open AND close < prior high.
Short: High >= prior high AND close < prior high AND previous high < current prior high.
Short: Close < prior low AND previous close >= current prior low.
Short: Close < prior high AND previous close > current prior high AND a bar within the preceding sweep lookback had close > its prior high AND previous close <= that bar's prior high.
Short: Each of the preceding lookback bars closed above its own VWAP AND close < VWAP AND close < open AND close > prior low.