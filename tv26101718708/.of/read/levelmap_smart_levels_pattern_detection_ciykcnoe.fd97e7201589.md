Calculation: Confirmed swing high/low = a pivot high/low with equal left and right lookbacks, available on its confirmation bar; retain the latest and preceding confirmed pivot of each type. Comparisons between pivots occur on the new pivot's confirmation bar.
Calculation: Bullish/bearish structure = the most recent unequal confirmed swing is a higher high or higher low / lower high or lower low; if both types update on the same bar, bearish structure takes precedence.
Calculation: Session VWAP = cumulative sum of ((high + low + close) / 3 × volume) divided by cumulative volume, resetting at each new trading day.
Calculation: Low/high key levels = the previous completed bar's low/high on each of two higher timeframes, the running low/high of a longer higher-timeframe bar still forming, and the lows/highs of each of two most recently completed sessions. Retain each completed session's level until that session next completes.
Calculation: Recent low/high = lowest low/highest high over a lookback ending on the previous chart bar.
Calculation: Low/high sweep = low < recent low AND close > recent low / high > recent high AND close < recent high.
Calculation: Body = abs(close - open); lower wick = min(open, close) - low; upper wick = high - max(open, close).
Calculation: Previous-pivot RSI = RSI at the bar one swing lookback before the preceding pivot bar, or zero if the preceding pivot price is not positive or that RSI is unavailable.
Long: A confirmed swing high > the preceding swing high OR a confirmed swing low > the preceding swing low.
Short: A confirmed swing high < the preceding swing high OR a confirmed swing low < the preceding swing low.
Long: close > short-term EMA AND short-term EMA > long-term EMA AND close > session VWAP AND bullish structure.
Short: close < short-term EMA AND short-term EMA < long-term EMA AND close < session VWAP AND bearish structure.
Long: close > open AND previous close < previous open AND close > previous open AND open < previous close AND body > previous body.
Short: close < open AND previous close > previous open AND close < previous open AND open > previous close AND body > previous body.
Long: low < recent low AND close > recent low.
Short: high > recent high AND close < recent high.
Long: high - low > 0 AND lower wick >= body × wick ratio AND upper wick <= body AND close > open AND (level filter disabled OR abs(low - any low key level) <= low × level tolerance) AND (RSI filter disabled OR RSI < lower threshold) AND (swing filter disabled OR a swing low was confirmed one swing lookback ago OR a low sweep occurred on this bar or either of the two preceding bars).
Short: high - low > 0 AND upper wick >= body × wick ratio AND lower wick <= body AND close < open AND (level filter disabled OR abs(high - any high key level) <= high × level tolerance) AND (RSI filter disabled OR RSI > upper threshold) AND (swing filter disabled OR a swing high was confirmed one swing lookback ago OR a high sweep occurred on this bar or either of the two preceding bars).
Long: A swing low is confirmed AND abs(new swing low - preceding swing low) / preceding swing low < double-pattern tolerance.
Short: A swing high is confirmed AND abs(new swing high - preceding swing high) / preceding swing high < double-pattern tolerance.
Long: A swing low is confirmed AND new swing low < preceding swing low AND RSI at the new pivot bar > previous-pivot RSI.
Short: A swing high is confirmed AND new swing high > preceding swing high AND RSI at the new pivot bar < previous-pivot RSI.