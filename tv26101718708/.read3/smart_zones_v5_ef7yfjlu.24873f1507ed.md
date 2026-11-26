Calculation: Volume spike = volume >= SMA(volume, volume lookback) * volume multiplier
Calculation: Bullish engulfing = abs(close - open) >= ATR(ATR lookback) * displacement multiplier AND close > open AND high > low AND (close - low) / (high - low) >= bullish close-position threshold AND close > open[prior-bar offset] AND open < close[prior-bar offset] AND volume spike
Calculation: Bearish engulfing = abs(close - open) >= ATR(ATR lookback) * displacement multiplier AND close < open AND high > low AND (close - low) / (high - low) <= bearish close-position threshold AND close < open[prior-bar offset] AND open > close[prior-bar offset] AND volume spike
Calculation: Bullish chart FVG = low > high[second-prior-bar offset] AND low - high[second-prior-bar offset] >= close * chart FVG size fraction
Calculation: Bearish chart FVG = high < low[second-prior-bar offset] AND low[second-prior-bar offset] - high >= close * chart FVG size fraction
Calculation: Bullish T2 FVG = low(T2, last completed bar) > high(T2, second-prior completed bar) AND the gap is at least chart close * higher-timeframe FVG size percentage / 100
Calculation: Bearish T2 FVG = high(T2, last completed bar) < low(T2, second-prior completed bar) AND the gap is at least chart close * higher-timeframe FVG size percentage / 100
Calculation: Bullish T3 FVG = low(T3, last completed bar) > high(T3, second-prior completed bar) AND the gap is at least chart close * higher-timeframe FVG size percentage / 100
Calculation: Bearish T3 FVG = high(T3, last completed bar) < low(T3, second-prior completed bar) AND the gap is at least chart close * higher-timeframe FVG size percentage / 100
Calculation: Bullish chart liquidity sweep = low[prior-bar offset] <= lowest(low, liquidity lookback)[prior-bar offset] AND close > lowest(low, liquidity lookback)[prior-bar offset]
Calculation: Bearish chart liquidity sweep = high[prior-bar offset] >= highest(high, liquidity lookback)[prior-bar offset] AND close < highest(high, liquidity lookback)[prior-bar offset]
Calculation: Bullish T1 liquidity sweep = previous chart bar's T1 low <= lowest(low, T1 liquidity lookback, T1, last completed bar) AND current T1 close (still forming) > that lowest low
Calculation: Bearish T1 liquidity sweep = previous chart bar's T1 high >= highest(high, T1 liquidity lookback, T1, last completed bar) AND current T1 close (still forming) < that highest high
Calculation: T1 sweep bias = direction of the most recent T1 liquidity sweep, with a bullish sweep taking precedence if both occur on one chart bar
Calculation: Correlated-instrument bullish liquidity sweep = previous chart bar's correlated-instrument low <= lowest(correlated-instrument low, liquidity lookback)[prior-bar offset] AND current correlated-instrument close > that lowest low
Calculation: Correlated-instrument bearish liquidity sweep = previous chart bar's correlated-instrument high >= highest(correlated-instrument high, liquidity lookback)[prior-bar offset] AND current correlated-instrument close < that highest high
Calculation: Relative strength = (close / close[relative-strength lookback] - 1) - (correlated-instrument close / correlated-instrument close[relative-strength lookback] - 1)
Calculation: Volatility-index rising = volatility-index close(T3, still forming) > volatility-index close(T3, last completed bar)
Calculation: Volatility-index falling = volatility-index close(T3, still forming) < volatility-index close(T3, last completed bar)
Calculation: In enabled session = current chart bar is within either enabled session window
Calculation: At long structure = abs(close - low(T3, last completed bar)) <= ATR(ATR lookback) * previous-low distance multiplier OR abs(close - open(T4, still forming)) <= ATR(ATR lookback) * reference-open distance multiplier OR abs(close - open(T3, still forming)) <= ATR(ATR lookback) * reference-open distance multiplier OR close is within ATR(ATR lookback) * T2-gap proximity multiplier of the latest stored bullish T2 FVG midpoint OR close is within ATR(ATR lookback) * T3-gap proximity multiplier of the latest stored bullish T3 FVG midpoint
Calculation: At short structure = abs(close - high(T3, last completed bar)) <= ATR(ATR lookback) * previous-low distance multiplier OR abs(close - open(T4, still forming)) <= ATR(ATR lookback) * reference-open distance multiplier OR abs(close - open(T3, still forming)) <= ATR(ATR lookback) * reference-open distance multiplier OR close is within ATR(ATR lookback) * T2-gap proximity multiplier of the latest stored bearish T2 FVG midpoint OR close is within ATR(ATR lookback) * T3-gap proximity multiplier of the latest stored bearish T3 FVG midpoint
Calculation: Bullish structure flip = bullish engulfing AND at long structure
Calculation: Bearish structure flip = bearish engulfing AND at short structure
Calculation: Bullish chart FVG retest = a bullish chart FVG zone is stored, its age is within the FVG retest age parameter, close is between its stored lower and upper edges inclusive, and bullish engulfing; clear the stored zone after this condition occurs
Calculation: Bearish chart FVG retest = a bearish chart FVG zone is stored, its age is within the FVG retest age parameter, close is between its stored lower and upper edges inclusive, and bearish engulfing; clear the stored zone after this condition occurs
Calculation: T3 bearish FVG overrides T2 bullish FVG = bullish T2 FVG AND bearish T3 FVG AND rounded T3 gap size >= rounded T2 gap size * FVG dominance multiplier AND abs(high(T3, last completed bar) - close) <= FVG override proximity
Calculation: T3 bullish FVG overrides T2 bearish FVG = bearish T2 FVG AND bullish T3 FVG AND rounded T3 gap size >= rounded T2 gap size * FVG dominance multiplier AND abs(low(T3, last completed bar) - close) <= FVG override proximity
Calculation: Long sweep count = number of bullish chart liquidity sweeps since the latest bearish chart liquidity sweep or long setup invalidation
Calculation: Short sweep count = number of bearish chart liquidity sweeps since the latest bullish chart liquidity sweep or short setup invalidation
Calculation: Long score = min(score cap, base score weight * count of true conditions [T1 sweep bias bullish, in enabled session, volume spike, correlation enabled and correlated-instrument bullish liquidity sweep, relative strength > 0, bullish T2 FVG without T3 bearish override, bullish T3 FVG, close near the last completed T3 low using the previous-low distance multiplier, volatility-index falling when its filter is enabled, long sweep count >= sweep-count threshold, at long structure] + bonus score weight for each true condition [bullish structure flip, bullish chart FVG retest])
Calculation: Short score = min(score cap, base score weight * count of true conditions [T1 sweep bias bearish, in enabled session, volume spike, correlation enabled and correlated-instrument bearish liquidity sweep, relative strength < 0, bearish T2 FVG without T3 bullish override, bearish T3 FVG, close near the last completed T3 high using the previous-low distance multiplier, volatility-index rising when its filter is enabled, short sweep count >= sweep-count threshold, at short structure] + bonus score weight for each true condition [bearish structure flip, bearish chart FVG retest])
Calculation: Chart sweep bias = direction of the most recent chart liquidity sweep, with a bullish sweep taking precedence if both occur on one chart bar
Calculation: Bullish range break = a consolidation range is active AND close > its stored high AND open < its stored high AND abs(close - open) >= ATR(ATR lookback) * range-break body multiplier; the range forms when highest(high, range lookback) - lowest(low, range lookback) <= ATR(ATR lookback) * range-height multiplier, persists for the minimum range duration, tracks its high and low, and ends on a range break
Calculation: Bearish range break = a consolidation range is active AND close < its stored low AND open > its stored low AND abs(close - open) >= ATR(ATR lookback) * range-break body multiplier
Calculation: Long BOS confirmation = a bullish chart liquidity sweep has set or updated a pending long BOS level to highest(high, BOS lookback)[prior-bar offset], the long setup has not been invalidated, and close > that level; clear the pending long BOS after confirmation
Calculation: Short BOS confirmation = a bearish chart liquidity sweep has set or updated a pending short BOS level to lowest(low, BOS lookback)[prior-bar offset], the short setup has not been invalidated, and close < that level; clear the pending short BOS after confirmation
Long: bullish engulfing
Short: bearish engulfing
Long: bullish chart FVG
Short: bearish chart FVG
Long: bullish T2 FVG
Short: bearish T2 FVG
Long: bullish T3 FVG
Short: bearish T3 FVG
Long: bullish chart liquidity sweep
Short: bearish chart liquidity sweep
Long: chart sweep bias is bullish
Short: chart sweep bias is bearish
Long: bullish structure flip
Short: bearish structure flip
Long: bullish chart FVG retest
Short: bearish chart FVG retest
Long: bullish range break
Short: bearish range break
Long: Long BOS confirmation
Short: Short BOS confirmation
Long: bullish chart liquidity sweep AND long score >= minimum sweep-signal score
Short: bearish chart liquidity sweep AND short score >= minimum sweep-signal score
Long: long score >= maximum-confluence threshold
Short: short score >= maximum-confluence threshold
Long: short score <= low-score cutoff AND long score >= strong-score cutoff
Short: long score <= low-score cutoff AND short score >= strong-score cutoff
Long: bearish chart liquidity sweep AND long score > short score AND long score >= fade-score cutoff
Short: bullish chart liquidity sweep AND short score > long score AND short score >= fade-score cutoff
Long: bullish chart liquidity sweep AND long score > short score AND (long score >= call-score threshold OR (long score >= marginal-score threshold AND long score - short score >= score-gap threshold)) AND NOT ((bullish chart FVG AND bearish chart liquidity sweep) OR (bearish chart FVG AND bullish chart liquidity sweep))
Short: bearish chart liquidity sweep AND short score > long score AND (short score >= call-score threshold OR (short score >= marginal-score threshold AND short score - long score >= score-gap threshold)) AND NOT ((bullish chart FVG AND bearish chart liquidity sweep) OR (bearish chart FVG AND bullish chart liquidity sweep))
Exit: long, while the long setup is active after a bullish chart liquidity sweep, close < the stored stop level (lowest(low, liquidity lookback)[prior-bar offset] at the sweep - ATR(ATR lookback) * stop-distance multiplier)
Exit: short, while the short setup is active after a bearish chart liquidity sweep, close > the stored stop level (highest(high, liquidity lookback)[prior-bar offset] at the sweep + ATR(ATR lookback) * stop-distance multiplier)