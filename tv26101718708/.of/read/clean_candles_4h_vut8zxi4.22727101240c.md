Calculation: Selected-timeframe OHLC = OHLC from a configurable timeframe. For a higher timeframe, use the final OHLC of the bar aligned to every chart bar within it, as historical lookahead does; this requires future data while the higher-timeframe bar is still forming. For a lower timeframe, use the first completed lower-timeframe bar within each chart bar. For the chart timeframe, use the chart bar's OHLC.
Calculation: Upper wick = selected-timeframe high − max(selected-timeframe open, selected-timeframe close).
Calculation: Lower wick = min(selected-timeframe open, selected-timeframe close) − selected-timeframe low.
Long: Selected-timeframe close >= selected-timeframe open AND upper wick <= wick-tolerance parameter.
Long: Selected-timeframe close >= selected-timeframe open AND lower wick <= wick-tolerance parameter.
Short: Selected-timeframe close < selected-timeframe open AND upper wick <= wick-tolerance parameter.
Short: Selected-timeframe close < selected-timeframe open AND lower wick <= wick-tolerance parameter.