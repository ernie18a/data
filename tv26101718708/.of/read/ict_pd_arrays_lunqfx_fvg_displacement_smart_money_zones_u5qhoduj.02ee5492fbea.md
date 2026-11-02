Calculation: Swing midpoint = midpoint of the latest confirmed pivot high and latest confirmed pivot low, each confirmed using the same number of bars on both sides.
Calculation: Bullish inducement = low < lowest low of the preceding inducement lookback AND close > that lowest low AND that lowest low - low >= ATR × inducement wick multiplier.
Calculation: Bearish inducement = high > highest high of the preceding inducement lookback AND close < that highest high AND high - that highest high >= ATR × inducement wick multiplier.
Calculation: Bullish displacement = close > open AND close - open >= ATR × displacement body multiplier AND (high - close) / (high - low) <= displacement wick ratio AND (volume filter disabled OR volume > volume SMA × volume multiplier). Use a positive fallback denominator when high = low.
Calculation: Bearish displacement = close < open AND open - close >= ATR × displacement body multiplier AND (close - low) / (high - low) <= displacement wick ratio AND (volume filter disabled OR volume > volume SMA × volume multiplier). Use a positive fallback denominator when high = low.
Calculation: Sequence direction and score = initially no direction and score zero. On each confirmed bar, reset after a previous score of three, or when the bars elapsed since inducement exceed the timeout. If inactive and either inducement occurs, set score to one and direction to bullish if bullish inducement occurs, otherwise bearish. If score is one and, respectively, low < lowest low or high > highest high of the preceding sweep lookback, set score to two. If score is two and either bullish or bearish displacement occurs, set score to three. Apply these steps in order, allowing multiple steps on the same bar.
Long: low of the previous bar > high three bars ago AND their difference >= current ATR × gap-size multiplier.
Short: low three bars ago > high of the previous bar AND their difference >= current ATR × gap-size multiplier.
Long: close < swing midpoint.
Short: close > swing midpoint.
Long: bullish displacement.
Short: bearish displacement.
Long: bullish inducement.
Short: bearish inducement.
Long: sequence direction is bullish AND sequence score crosses above the configured label threshold from below OR sequence direction is bullish AND sequence score reaches the configured label threshold from below.
Short: sequence direction is bearish AND sequence score crosses above the configured label threshold from below OR sequence direction is bearish AND sequence score reaches the configured label threshold from below.