Calculation: Current VWAP = cumulative sum of chart-bar typical price times volume divided by cumulative volume, reset at each daily boundary; typical price is (high + low + close) / 3.
Calculation: Previous VWAP = VWAP calculated on higher-timeframe bars using typical price and the same daily reset, taken from the last completed higher-timeframe bar; use current VWAP if unavailable.
Calculation: Bullish score = sum of the truth values of close > open, close > current VWAP, close > previous VWAP, and close crossing above current VWAP. A cross above requires current close > current VWAP and prior close <= prior current VWAP.
Calculation: Bearish score = sum of the truth values of close < open, close < current VWAP, close < previous VWAP, and close crossing below current VWAP. A cross below requires current close < current VWAP and prior close >= prior current VWAP.
Long: Bullish score > bearish score.
Short: Bearish score >= bullish score.