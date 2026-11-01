Calculation: Sampled price and volume series = on each chart bar, take the close, high, low, and volume from the last completed bar of a selected higher timeframe; use chart bars directly when the selected timeframe equals the chart timeframe.
Long: The selected timeframe's close > its EMA of high AND each of the preceding three selected-timeframe closes < its corresponding EMA of high; use the last completed selected-timeframe bar when it is higher than the chart timeframe.
Long: Sampled close > highest sampled high over a price lookback ending on the preceding chart bar AND sampled volume > highest sampled volume over a separate volume lookback ending on the preceding chart bar AND sampled close > SMA of sampled close.
Short: Sampled close < lowest sampled low over a price lookback ending on the preceding chart bar AND sampled volume > highest sampled volume over a separate volume lookback ending on the preceding chart bar AND sampled close < SMA of sampled close.
Long: On the last completed bar of a higher timeframe, previous close < previous open AND open > previous open.
Long: On the last completed bar of a higher timeframe, open < previous low AND close > previous low.
Short: On the last completed bar of a higher timeframe, open > previous high AND close <= previous high.
Long: On the last completed bar of a higher timeframe, open = low.
Short: On the last completed bar of a higher timeframe, open = high AND open != low.
Long: On the last completed bar of a higher timeframe, high <= previous high AND low >= previous low.
Short: On the last completed bar of a higher timeframe, high > previous high AND low < previous low.
Long: On the last completed bar of a higher timeframe, high one bar ago < high three bars ago AND close > each of the highs of the preceding three bars.
Short: On the last completed bar of a higher timeframe, low one bar ago > low three bars ago AND close < each of the lows of the preceding three bars.