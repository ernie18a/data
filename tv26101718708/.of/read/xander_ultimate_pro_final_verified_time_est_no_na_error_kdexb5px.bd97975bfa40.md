Calculation: Confirmed swing high/low = most recent pivot high/low confirmed using equal numbers of bars before and after the pivot; use an independently adjustable, longer lookback on the specified higher chart timeframes.
Calculation: Zone pivot high/low = pivot high/low confirmed using equal numbers of bars before and after the pivot, with an independent lookback.
Calculation: Tolerance = close multiplied by a parameter selected according to the chart timeframe.
Calculation: Stochastic RSI K = SMA of 100 × (RSI − lowest RSI) / (highest RSI − lowest RSI), using the RSI period as the high/low lookback and zero when the range is zero; D = SMA of K.
Long: Fast EMA of close > slow EMA of close AND close > long-term EMA of close.
Short: Fast EMA of close < slow EMA of close AND close < long-term EMA of close.
Short: Confirmed swing high and low exist AND (fast EMA of close <= slow EMA of close OR close <= long-term EMA of close).
Long: A swing low or zone pivot low is confirmed.
Short: A swing high or zone pivot high is confirmed.
Long: Fast EMA of close > slow EMA of close AND close > long-term EMA of close AND ((low <= fast EMA AND high >= slow EMA) OR (low <= slow EMA AND high >= fast EMA) OR (low >= confirmed swing low − tolerance AND low <= confirmed swing low + tolerance) OR close <= confirmed swing low + 2 × tolerance) AND K crosses above D AND K < oversold threshold AND volume > SMA of volume.
Short: Fast EMA of close < slow EMA of close AND close < long-term EMA of close AND ((low <= fast EMA AND high >= slow EMA) OR (low <= slow EMA AND high >= fast EMA) OR (high >= confirmed swing high − tolerance AND high <= confirmed swing high + tolerance) OR close >= confirmed swing high − 2 × tolerance) AND K crosses below D AND K > overbought threshold AND volume > SMA of volume.