Calculation: Fast EMA = exponential moving average of close with a shorter lookback than the slow EMA
Calculation: Slow EMA = exponential moving average of close with a longer lookback than the fast EMA
Calculation: Bullish crossover = fast EMA moves from at or below slow EMA to above it
Calculation: Bearish crossover = fast EMA moves from at or above slow EMA to below it
Calculation: EMA slope = (slow EMA − slow EMA from a configurable number of bars earlier) / that earlier slow EMA / number of bars × 100
Calculation: Volume ratio = volume / its configurable simple moving average
Calculation: Bullish engulfing = current candle is bullish, prior candle bearish, current body is larger, current close ≥ prior open, and current open ≤ prior close
Calculation: Hammer = current body ≤ 35% of range, lower wick ≥ 60% of range, and upper wick ≤ 15% of range
Calculation: Morning star = two bars earlier is bearish with body ≥ 50% of its range; prior body ≤ half its body; current candle is bullish, closes above the midpoint of the candle two bars earlier, and has a larger body than the prior candle
Calculation: Piercing line = prior candle bearish; current candle bullish, opens below prior close, closes above prior midpoint, and closes below prior open
Calculation: Bullish harami = prior candle bearish with nonzero body; current candle bullish, body < 70% of prior body, and its body is inside the prior body
Calculation: Bearish engulfing = current candle is bearish, prior candle bullish, current body is larger, current open ≥ prior close, and current close ≤ prior open
Calculation: Shooting star = current body ≤ 35% of range, upper wick ≥ 60% of range, and lower wick ≤ 15% of range
Calculation: Evening star = two bars earlier is bullish with body ≥ 50% of its range; prior body ≤ half its body; current candle is bearish, closes below the midpoint of the candle two bars earlier, and has a larger body than the prior candle
Calculation: Dark cloud cover = prior candle bullish; current candle bearish, opens above prior close, closes below prior midpoint, and closes above prior open
Calculation: Bearish harami = prior candle bullish with nonzero body; current candle bearish, body < 70% of prior body, and its body is inside the prior body
Calculation: Target levels = over a configurable lookback of completed chart bars, average the opens of bullish EMA crossover bars and find the highest high among bars where fast EMA > slow EMA; if both exist and that high exceeds the average, base T1 and T2 are average + half and all of the difference, respectively. If rolling VPoC is enabled and above 108% of the average, use VPoC as T1 and average + twice (VPoC − average) as T2. Rolling VPoC is the midpoint of the price bin with the greatest volume-weighted overlap across configurable recent chart bars divided into configurable equal price bins.
Long: bullish crossover AND flat position AND T1 is available
Long: fast EMA < slow EMA AND fast EMA > its prior-bar value AND (slow EMA − fast EMA) / slow EMA ≤ configured anticipation threshold AND configured anticipation threshold > 0 AND flat position AND T1 is available
Long: fast EMA > slow EMA AND close ≥ 95% of T1 AND close ≤ 115% of T1 AND EMA slope > 0 AND EMA slope > prior-bar EMA slope AND prior-bar EMA slope ≤ 0.02 AND volume ratio ≥ 0.7 AND volume ratio ≥ prior-bar volume ratio AND (EMA slope ≥ 0.05 OR volume ratio ≥ 1.0)
Long: bullish engulfing OR hammer OR morning star OR piercing line OR bullish harami
Short: bearish crossover AND flat position
Short: evening star OR bearish engulfing OR dark cloud cover OR shooting star OR bearish harami
Exit: Long, high ≥ tracked T2
Exit: Long, low ≤ tracked stop AND high < tracked T2
Exit: Long, bearish crossover AND high < tracked T2 AND low > tracked stop
Exit: Long, EMA slope < 0 AND volume ratio < 0.7 for two consecutive bars