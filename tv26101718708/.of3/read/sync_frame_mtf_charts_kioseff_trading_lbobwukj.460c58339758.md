Calculation: Donchian midpoint = (highest(high, lookback) + lowest(low, lookback)) / 2 on raw OHLC from the latest lookback bars of each of T1, T2, T3, T4, and T5 returned on chart bars, including a still-forming bar when present
Calculation: Regression slope = linear regression slope(close, lookback) on the selected raw or Heikin Ashi series from the latest lookback bars of each of T1, T2, T3, T4, and T5 returned on chart bars, including a still-forming bar when present
Long: For each of T1, T2, T3, T4, and T5 separately, in raw candle mode, close >= open; in Heikin Ashi candle mode, Heikin Ashi close >= Heikin Ashi open
Short: For each of T1, T2, T3, T4, and T5 separately, in raw candle mode, close < open; in Heikin Ashi candle mode, Heikin Ashi close < Heikin Ashi open
Long: In Baseline mode, for each of T1, T2, T3, T4, and T5 separately, newest close > Donchian midpoint and older displayed closes >= Donchian midpoint
Short: In Baseline mode, for each of T1, T2, T3, T4, and T5 separately, newest close <= Donchian midpoint and older displayed closes < Donchian midpoint
Long: In raw or Heikin Ashi candle mode, Regression slope >= 0 for each of T1, T2, T3, T4, and T5 separately
Short: In raw or Heikin Ashi candle mode, Regression slope < 0 for each of T1, T2, T3, T4, and T5 separately