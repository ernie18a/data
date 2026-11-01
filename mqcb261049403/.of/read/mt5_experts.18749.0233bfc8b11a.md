Calculation: Trend state and bands = On the indicator timeframe, use a moving average of a selectable bar price and ATR. Initialize the previous trend to neutral and both previous bands to the close of the first eligible bar. For each bar, set raw upper band = moving average + volatility multiplier × ATR and raw lower band = moving average − volatility multiplier × ATR. Set trend to the previous trend; set it to bullish if high > previous upper band; then set it to bearish if low < previous lower band, overriding the bullish assignment. If bullish, set the lower band to the greater of its raw value and its previous value; otherwise use its raw value. If bearish, set the upper band to the lesser of its raw value and its previous value; otherwise use its raw value. Carry these bands and trend forward. The indicator timeframe may be the chart timeframe or a higher or lower timeframe; evaluate the selected completed indicator bar, or the still-forming indicator bar when configured for it.
Long: Trend = bullish
Long: Trend = bullish AND previous trend <= neutral
Short: Trend = bearish
Short: Trend = bearish AND previous trend >= neutral
Exit: long, trend = bearish
Exit: short, trend = bullish
Exit: long, low <= entry price − stop distance OR high >= entry price + profit target distance
Exit: short, high >= entry price + stop distance OR low <= entry price − profit target distance