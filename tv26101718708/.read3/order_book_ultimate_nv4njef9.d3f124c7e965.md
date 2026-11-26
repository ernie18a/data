Calculation: ATR = ATR(ATR lookback)
Calculation: average volume = SMA(volume, short volume lookback)
Calculation: bar range = max(high - low, minimum tick size); body = abs(close - open); upper wick = high - max(open, close); lower wick = min(open, close) - low
Calculation: historical bid and ask zones = prior strongest synthetic bid and ask wall prices, merged within the wall merge distance, with strength decayed each bar and updated by new wall strengths; select the strongest bid zone at or below close and ask zone at or above close
Calculation: round-number score at price p = 1 + (round magnetism - 1) × Gaussian(distance to nearest minor round level, round zone width) + (round magnetism - 1) × major-level boost × Gaussian(distance to nearest major round level, major round zone width), clamped to its configured bounds; round levels use the manual step or the automatic price-magnitude step, adjusted for asset profile
Calculation: bar-touch liquidity memory at price p and side s = sum over the memory lookback of volume × recency weight × rejection quality for bars whose low-to-high range contains p; rejection quality is the clamped close position within the bar for bids and the clamped inverse close position for asks
Calculation: synthetic depth at price p and side s = (Gaussian(abs(p - close) / ATR, depth decay) × average volume × depth multiplier × round-number score(p) × clamped pressure multiplier × OBV side multiplier × regime multiplier + bar-touch liquidity memory(p,s)) × clamped volume ratio; pressure multiplier increases with pressure for bids and decreases for asks, OBV side multiplier favors bids when OBV exceeds its moving average and asks otherwise, and regime multiplier depends on market mode
Calculation: synthetic wall statistics = calculate synthetic depth at progressively spaced levels above and below close; for each side, record total depth, average depth, strongest depth, strongest wall price, and strongest-to-average wall ratio; bid/ask depth ratio = total bid depth / total ask depth
Calculation: confirmed bid wall = strongest bid depth > average bid depth × effective wall threshold AND bid wall ratio > ask wall ratio × wall-side comparison threshold; confirmed ask wall is the corresponding ask-side condition
Calculation: stable bid or ask wall = its confirmed wall persists for the configured wall stability duration
Calculation: flow pressure and buy/sell ratio = on chart bars, estimate classic buy and sell volume from close position within bar range, sum over the delta lookback, and calculate smoothed normalized candle delta; on chart bars using T1 lower-timeframe bars within each chart bar, including the still-forming bar when present, estimate buy, sell, and delta volume from each lower-timeframe bar's close position and open-to-close move, then aggregate; use classic values in classic mode, lower-timeframe values in intrabar mode with classic fallback when unavailable, and blend both by lower-timeframe quality × hybrid weight in hybrid mode
Calculation: lower-timeframe quality = clamp(abs(up lower-timeframe bars - down lower-timeframe bars) / lower-timeframe bar count + clamped(lower-timeframe bar count / participation count) × participation weight, zero, one)
Calculation: OBV flow = OBV(close, volume) compared with SMA(OBV(close, volume), OBV moving-average lookback)
Calculation: candle delta sum = sum(volume × clamped((close - open) / bar range, negative one, one), delta lookback)
Calculation: bid and ask wall power change = percentage change in the respective wall ratio from its prior value
Calculation: market mode = high volatility if ATR / SMA(ATR, volatility baseline) exceeds its threshold; otherwise low liquidity if volume / average volume is below its threshold; otherwise breakout if volume and bar range exceed their respective averages by their thresholds; otherwise trending if ADX exceeds its threshold and the absolute DI difference exceeds its threshold; otherwise ranging if ADX and relative ATR are below their thresholds; otherwise balanced
Calculation: trend score = clamp((fraction of valid bars with close > open - neutral fraction) × trend scaling, negative one, one), over the shorter of the volume lookback, available history, and trend cap
Calculation: pro score = 50 + 50 × clamp(pressure score × pressure weight + imbalance score × imbalance weight + wall score × wall weight + trend score × trend weight + OBV score × OBV weight + RSI score × RSI weight + absorption bias × absorption weight + sweep bias × sweep weight + regime bias × regime weight, negative one, one); imbalance score is the clamped logarithmic normalization of bid/ask depth ratio by the imbalance threshold; wall score is the clamped normalized difference between bid and ask wall ratios; RSI score favors oversold and penalizes overbought; absorption and sweep biases favor their bid-side and bullish forms and penalize their ask-side and bearish forms; regime bias follows the stronger DI only while trending
Calculation: confidence = clamp(sum of configured agreement credits for pressure, imbalance, wall, trend, OBV, absorption, sweep, lower-timeframe quality or its unavailable fallback, and regime quality, zero, one hundred)
Calculation: bid absorption = low is within the absorption ATR zone of the strongest bid wall or historical bid zone AND volume >= average volume × absorption volume multiplier AND lower wick > body × rejection threshold AND close > low + bar range × close-position threshold
Calculation: ask absorption = high is within the absorption ATR zone of the strongest ask wall or historical ask zone AND volume >= average volume × absorption volume multiplier AND upper wick > body × rejection threshold AND close < high - bar range × close-position threshold
Calculation: bullish sweep = low < strongest bid wall or historical bid zone minus ATR × sweep distance AND close > that level
Calculation: bearish sweep = high > strongest ask wall or historical ask zone plus ATR × sweep distance AND close < that level
Long: confirmed-bar setting disabled OR chart bar confirmed, AND pro score >= long bias threshold, AND confidence >= minimum confidence, AND (anti-noise filter disabled OR (volume >= average volume × minimum volume multiplier AND pressure > long pressure floor AND (stable bid wall OR bid absorption OR bullish sweep) AND NOT low liquidity))
Short: confirmed-bar setting disabled OR chart bar confirmed, AND pro score <= short bias threshold, AND confidence >= minimum confidence, AND (anti-noise filter disabled OR (volume >= average volume × minimum volume multiplier AND pressure < short pressure ceiling AND (stable ask wall OR ask absorption OR bearish sweep) AND NOT low liquidity))
Long: bid absorption
Short: ask absorption
Long: bullish sweep
Short: bearish sweep
Long: pro score >= long bias threshold
Short: pro score <= short bias threshold
Long: stable bid wall
Short: stable ask wall
Long: bid/ask depth ratio > imbalance threshold
Short: bid/ask depth ratio < reciprocal of imbalance threshold
Long: buy/sell volume ratio > buy-dominant threshold
Short: buy/sell volume ratio < sell-dominant threshold
Long: total bid depth >= total ask depth
Short: total bid depth < total ask depth
Long: pressure >= zero
Short: pressure < zero
Long: candle delta sum >= zero
Short: candle delta sum < zero
Long: OBV flow > its moving average
Short: OBV flow <= its moving average
Long: bid wall power change >= zero
Short: bid wall power change < zero
Long: ask wall power change < zero
Short: ask wall power change >= zero
Exit: long, close < strongest bid wall price - ATR × setup invalidation distance AND confirmed bid wall
Exit: short, close > strongest ask wall price + ATR × setup invalidation distance AND confirmed ask wall