Calculation: CISD bias and level = After an initialization-delay parameter, set bias from the most recent non-doji candle within an initialization-lookback parameter (+ when close > open, − when close < open); set level to current open if the current candle is doji or opposes the bias, otherwise use the minimum open for bullish bias or maximum open for bearish bias across the current same-direction run, scanning backward through dojis until an opposite candle or the level-lookback parameter limit; set excursion to current high for bullish bias or current low for bearish bias. While biased, on a strict new high above the excursion for bullish bias or strict new low below it for bearish bias, update excursion and level: use the current same-direction run if the current candle matches bias, otherwise search backward within the level-lookback parameter for the most recent bias-direction candle, then use its same-direction run, scanning through dojis and stopping at an opposite candle. After updating level, flip bearish to bullish when close > level, or bullish to bearish when close < level; on a flip reset level from the current bar using the same rules and reset excursion to current high or low for the new bias. Doji candles have no direction.
Long: CISD bias after the current chart bar's update is bullish
Short: CISD bias after the current chart bar's update is bearish
Long: current CISD bias is bearish and close > current CISD level
Short: current CISD bias is bullish and close < current CISD level
Long: CISD bias computed on T1 bars and sampled on chart bars is bullish
Short: CISD bias computed on T1 bars and sampled on chart bars is bearish
Long: CISD bias computed on T2 bars and sampled on chart bars is bullish
Short: CISD bias computed on T2 bars and sampled on chart bars is bearish
Long: CISD bias computed on T3 bars and sampled on chart bars is bullish
Short: CISD bias computed on T3 bars and sampled on chart bars is bearish
Long: CISD bias computed on T4 bars and sampled on chart bars is bullish
Short: CISD bias computed on T4 bars and sampled on chart bars is bearish
Long: CISD bias computed on T5 bars and sampled on chart bars is bullish
Short: CISD bias computed on T5 bars and sampled on chart bars is bearish
Long: CISD bias computed on T6 bars and sampled on chart bars is bullish
Short: CISD bias computed on T6 bars and sampled on chart bars is bearish
Long: CISD bias computed on T7 bars and sampled on chart bars is bullish
Short: CISD bias computed on T7 bars and sampled on chart bars is bearish
Long: CISD bias computed on T8 bars and sampled on chart bars is bullish
Short: CISD bias computed on T8 bars and sampled on chart bars is bearish