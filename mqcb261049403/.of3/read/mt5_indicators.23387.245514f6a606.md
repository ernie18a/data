Calculation: Bullish setup = SMA(close, shorter lookback, T1, bar still forming) crosses above SMA(close, longer lookback, T1, bar still forming) AND (RSI filter disabled OR RSI(close, RSI lookback, T1, bar still forming) > RSI threshold); evaluate on chart bars when T1 changes
Calculation: Bearish setup = SMA(close, shorter lookback, T1, bar still forming) crosses below SMA(close, longer lookback, T1, bar still forming) AND (RSI filter disabled OR RSI(close, RSI lookback, T1, bar still forming) < RSI threshold); evaluate on chart bars when T1 changes
Calculation: Pending long level = low at the latest bullish setup while confirmation is enabled; reset on a bearish setup and clear when high − pending long level reaches the confirmation distance
Calculation: Pending short level = high at the latest bearish setup while confirmation is enabled; reset on a bullish setup and clear when pending short level − low reaches the confirmation distance AND open >= close
Calculation: Long update = (bullish setup AND confirmation is disabled) OR (pending long level exists AND high − pending long level >= confirmation distance)
Calculation: Short update = (bearish setup AND confirmation is disabled) OR (pending short level exists AND pending short level − low >= confirmation distance AND open >= close)
Calculation: Long anchor = low on the latest long update with abs(low − prior long anchor) >= flat distance; initialize at zero
Calculation: Short anchor = high on the latest short update with abs(high − prior short anchor) >= flat distance; initialize at zero
Calculation: Indicator direction state = neutral initially; set to long or short when the respective update passes its flat-distance condition
Long: Long update AND abs(low − prior long anchor) >= flat distance AND prior indicator direction state is neutral or short
Short: Short update AND abs(high − prior short anchor) >= flat distance AND prior indicator direction state is neutral or long