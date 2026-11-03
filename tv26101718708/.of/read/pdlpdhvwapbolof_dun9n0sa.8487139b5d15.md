Calculation: Prior-period high and low = high and low of the last completed higher-timeframe bar; use a shorter higher timeframe and a longer higher timeframe.
Calculation: VWAP = cumulative sum of ((high + low + close) / 3) * volume divided by cumulative volume, reset at each session.
Calculation: VWAP slope = (VWAP - VWAP a lookback number of chart bars ago) / VWAP a lookback number of chart bars ago; require the past VWAP to be nonzero.
Long: Close > prior-period high AND previous close <= current prior-period high, for either higher timeframe.
Long: Close > prior-period low AND previous close <= current prior-period low, for either higher timeframe.
Long: Each of the preceding setup-lookback bars closed below its own VWAP AND close > VWAP AND close > open AND close < shorter-higher-timeframe prior-period high.
Short: High >= prior-period high AND close < prior-period high AND previous high < current prior-period high, for either higher timeframe.
Short: Close < prior-period low AND previous close >= current prior-period low, for either higher timeframe.
Short: Close < shorter-higher-timeframe prior-period high AND previous close > current shorter-higher-timeframe prior-period high AND the most recent bar where close > that bar's prior-period high AND previous close <= that bar's prior-period high occurred within the sweep lookback.
Short: Each of the preceding setup-lookback bars closed above its own VWAP AND close < VWAP AND close < open AND close > shorter-higher-timeframe prior-period low.
Exit: long, close > shorter-higher-timeframe prior-period high AND VWAP slope <= positive slope threshold.