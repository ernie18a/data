Calculation: XRSI candle close = smooth((RSI of close − 50) × selected volume) using the selected smoothing method and lookback.
Calculation: XRSI candle open = smooth((RSI of open − 50) × selected volume) using the same method and lookback as XRSI candle close; when |open − close| ≤ the gap threshold, replace it with the previous bar’s XRSI candle close.
Long: XRSI candle close ≥ XRSI candle open
Short: XRSI candle close < XRSI candle open