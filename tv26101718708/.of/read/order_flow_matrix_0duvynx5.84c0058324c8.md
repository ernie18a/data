Calculation: Timeframe bars = For each selected timeframe, use chart bars or aggregate bars to the selected higher or lower timeframe. Use the bar still forming, or optionally the previous completed bar. For a lower timeframe, use the last available lower-timeframe bar within each chart bar.
Calculation: Estimated volume delta = Sum estimated buy volume minus sell volume over a lookback. For each bar, choose one method: allocate volume by close position within high–low, splitting equally if high equals low; allocate all volume to buying when close > open, all to selling when close < open, and split equally when equal; or sum the same directional allocations across available bars of a lower intrabar timeframe, falling back to close-position allocation if their total volume is zero or unavailable. Use intrabars available within the selected timeframe bar, including the still-forming intrabar.
Calculation: Cumulative estimated delta = Cumulative sum of each timeframe bar's estimated buy volume minus estimated sell volume, starting at the first available bar.
Calculation: Structure = Compare the latest two confirmed pivot highs and the latest two confirmed pivot lows, using the same number of left and right bars for each pivot.
Calculation: Timeframe bull score = Weighted average of four component scores; use equal component weights if their sum is zero. The delta score is clamp(neutral score + delta scaling factor × estimated volume delta / moving average of its absolute value over a longer lookback, minimum score, maximum score), or the neutral score if that average is zero or unavailable. The cumulative-delta score is maximum when cumulative estimated delta > its EMA AND cumulative estimated delta > its value at a prior slope lookback, minimum when both comparisons are reversed, and neutral otherwise. The EMA score is maximum when close > shorter EMA AND shorter EMA > longer EMA, minimum when close < shorter EMA AND shorter EMA < longer EMA, and neutral otherwise. The structure score is maximum when the latest pivot high > the preceding pivot high AND the latest pivot low > the preceding pivot low, minimum when both comparisons are reversed, and neutral otherwise.
Calculation: Overall bull score = Weighted average of the available timeframe bull scores for selected visible timeframes, with weights renormalized over those timeframes.
Calculation: Latest fair value gap direction = Bullish if the most recent gap has low > high two bars earlier; bearish if it has high < low two bars earlier. Choose the bullish gap if both occur equally recently.
Calculation: Latest order block direction = Bullish if the latest qualifying impulse has close > open AND close − open >= an ATR multiple AND the preceding bar has close < open; bearish if it has close < open AND open − close >= the ATR multiple AND the preceding bar has close > open. Choose bullish if both occur equally recently.
Long: Estimated volume delta > 0.
Short: Estimated volume delta < 0.
Long: Cumulative estimated delta > its EMA AND cumulative estimated delta > its value at the prior slope lookback.
Short: Cumulative estimated delta < its EMA AND cumulative estimated delta < its value at the prior slope lookback.
Long: Close > shorter EMA AND shorter EMA > longer EMA.
Short: Close < shorter EMA AND shorter EMA < longer EMA.
Long: Latest confirmed pivot high > preceding confirmed pivot high AND latest confirmed pivot low > preceding confirmed pivot low.
Short: Latest confirmed pivot high < preceding confirmed pivot high AND latest confirmed pivot low < preceding confirmed pivot low.
Long: Timeframe bull score >= bull threshold.
Short: Timeframe bull score <= bear threshold, provided it is below the bull threshold.
Long: Overall bull score crosses above the bull threshold.
Short: Overall bull score crosses below the bear threshold.
Long: At least one timeframe is visible AND every visible timeframe bull score >= bull threshold AND this was not true on the previous chart bar.
Short: At least one timeframe is visible AND every visible timeframe bull score <= bear threshold AND below the bull threshold AND this was not true on the previous chart bar.
Long: The designated timeframe bull score >= bull threshold AND its previous chart-bar score <= bear threshold AND below the bull threshold.
Short: The designated timeframe bull score <= bear threshold AND below the bull threshold AND its previous chart-bar score >= bull threshold.
Long: RSI > its midpoint AND RSI < its overbought threshold OR RSI >= its bullish-color threshold.
Short: RSI < its midpoint AND RSI > its oversold threshold OR RSI <= its bearish-color threshold.
Long: Shorter EMA > 0 AND close > shorter EMA.
Short: Shorter EMA > 0 AND close < shorter EMA.
Long: Latest fair value gap direction is bullish.
Short: Latest fair value gap direction is bearish.
Long: Latest order block direction is bullish.
Short: Latest order block direction is bearish.