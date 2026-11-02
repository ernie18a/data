Calculation: Swing high and swing low = the most recently confirmed pivot high and pivot low, respectively; a pivot is confirmed after its specified right-side bars and is compared with the specified numbers of bars on both sides. Update each swing on its confirmation bar before evaluating that bar's decisions.
Calculation: Upward break = close > current swing high AND previous close <= current swing high. Downward break = close < current swing low AND previous close >= current swing low.
Calculation: Bullish sweep = bars elapsed since the current swing low's pivot bar <= sweep lookback AND low < swing low AND close > swing low AND (swing low - low) / max(ATR, minimum price increment) >= sweep-depth threshold. Bearish sweep = bars elapsed since the current swing high's pivot bar <= sweep lookback AND high > swing high AND close < swing high AND (high - swing high) / max(ATR, minimum price increment) >= sweep-depth threshold.
Calculation: Trend state = bullish when close > KAMA AND KAMA >= previous KAMA; bearish when close < KAMA AND KAMA <= previous KAMA; otherwise neutral.
Calculation: Context state = bullish when the shorter EMA of close > the longer EMA of close, bearish when the shorter EMA < the longer EMA, and neutral when they are equal; both EMAs use the last completed higher-timeframe bar.
Calculation: Impulse score = the sum of separate weights for volume > volume SMA times a multiplier, absolute close-minus-open > ATR times a multiplier, and trend state = context state AND trend state is non-neutral.
Calculation: Close location = (close - low) / max(high - low, minimum price increment), or zero if the denominator is zero.
Long: upward break OR bullish sweep.
Short: downward break OR bearish sweep.
Long: (upward break OR bullish sweep) AND (context state is bullish or neutral OR impulse score >= qualification threshold) AND close location >= bullish threshold.
Short: (downward break OR bearish sweep) AND (context state is bearish or neutral OR impulse score >= qualification threshold) AND close location <= bearish threshold.
Long: trend state is bullish OR (trend state is neutral AND impulse score >= candle impulse threshold).
Short: trend state is bearish.
Long: context state is bullish.
Short: context state is bearish.
Long: close > current swing high AND no earlier close > that swing high has occurred since its confirmation.
Short: close < current swing low AND no earlier close < that swing low has occurred since its confirmation.