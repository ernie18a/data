Calculation: Trend source = EMA of (high + shadow if shadow > 0, else low + shadow), where shadow = (cumulative spread-volume − its 14-bar SMA) / standard deviation of that difference over 28 bars × standard deviation of high−low over 28 bars; spread-volume = (close−open) × volume / ((high−low)×100) × 100
Calculation: Custom Supertrend trend = 1 when source price > prior down band, −1 when source price < prior up band, otherwise prior trend; bands use the trend source ± multiplier × ATR, with the up band carried as the maximum while prior source is above its prior value and the down band carried as the minimum while prior source is below its prior value
Calculation: ZigZag bias = 1 when bars since the tracked ZigZag low candidate < bars since the tracked ZigZag high candidate, otherwise −1; candidates use the lowest low and highest high over the ZigZag lookback, rejecting unchanged candidates and candidates separated from the current low or high by more than the configured deviation in ticks; retain the prior direction when neither candidate updates
Calculation: SAR score = 3 if source price > Parabolic SAR, otherwise −3
Calculation: ROC score = 1 if source price rate of change over its lookback > 0, otherwise −1
Calculation: DMI score = 2 if positive directional movement index − negative directional movement index >= 0, otherwise −2
Calculation: CCI score = 1 if source price Commodity Channel Index > 0, otherwise −1
Calculation: Weis score = 2 if the current wave direction is up, otherwise −2; wave direction updates to a changed source-price direction when source price is rising or falling over the trend-detection lookback, and volume accumulates within each wave
Calculation: SMA score = 1 if source price > its 20-bar SMA, otherwise −1
Calculation: AO score = 1 if SMA(hl2, 5) − SMA(hl2, 34) > 0, −1 if < 0, otherwise 0
Calculation: Momentum score = 1 if source price − source price 14 bars earlier > 0, −1 if < 0, otherwise 0
Calculation: Histogram score = 3 if the MACD histogram (EMA(source, 12) − EMA(source, 26), minus its 9-bar EMA) > its prior value, otherwise −3
Calculation: Bull-bear score = 1 if the 30-bar SMA of bullish candle power minus bearish candle power > 0, otherwise −1; candle powers are the script’s bull and bear range calculations based on current and prior open, high, low, and close
Calculation: Ichimoku score = 2 if source price > the midpoint of the 26-bar highest high and lowest low, otherwise −2
Calculation: HMA score = 1 if source price > its Hull moving average, otherwise −1
Calculation: Total points = SAR score + 3 × custom Supertrend trend + ZigZag bias + ROC score + DMI score + CCI score + Weis score + SMA score + AO score + Momentum score + Histogram score + Bull-bear score + Ichimoku score + HMA score
Calculation: Bullish Supertrend divergence = a confirmed Supertrend-line pivot low where price makes a lower low and the Supertrend line makes a higher low, or price makes a higher low and the Supertrend line makes a lower low; the Supertrend line must be below zero
Calculation: Bearish Supertrend divergence = a confirmed Supertrend-line pivot high where price makes a higher high and the Supertrend line makes a lower high, or price makes a lower high and the Supertrend line makes a higher high; the Supertrend line must be above zero
Long: Custom Supertrend trend = 1 AND (total points > entry threshold OR ZigZag bias = 1)
Long: Bullish Supertrend divergence
Short: Custom Supertrend trend = −1 AND (total points < −entry threshold OR ZigZag bias = −1)
Short: Bearish Supertrend divergence