Calculation: Raw upper and lower bands = moving average ± volatility multiplier × ATR, calculated on the configured indicator timeframe (higher or lower than the chart timeframe) using completed bars.
Calculation: Trailing upper and lower bands = each bar, start with the raw bands; if the trend state is bullish, keep the lower band at least as high as its previous value; if bearish, keep the upper band at most as high as its previous value. These trailing bands are the thresholds used on the next bar.
Calculation: Trend state = retain the previous state unless the bar's high exceeds the previous trailing upper band, which sets it bullish; then, if the bar's low is below the previous trailing lower band, set it bearish (this takes precedence if both conditions hold). Initialize the state as neutral.
Long: Previous trend state was neutral or bearish AND current trend state is bullish.
Short: Previous trend state was neutral or bullish AND current trend state is bearish.
Exit: long, current trend state is bearish.
Exit: short, current trend state is bullish.