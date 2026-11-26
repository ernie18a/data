Calculation: Close position(T) = (close(T) - low(T)) / (high(T) - low(T)), or zero when high(T) equals low(T); evaluated on chart bars from T's current sampled bar, which may still be forming.
Calculation: Proxy CVD(T) = cumulative sum on chart bars of volume(T) * (2 * Close position(T) - 1), using T's current sampled bar, which may still be forming.
Calculation: Buy percentage(T) = clamp(round(100 * Close position(T)) to the percentage range.
Calculation: Enabled TF count = number of enabled timeframes among T1, T2, T3, and T4.
Calculation: Bullish TF count = count of enabled T where CVD(T) is rising over the CVD direction lookback on chart bars.
Calculation: Bearish TF count = count of enabled T where CVD(T) is falling over the CVD direction lookback on chart bars.
Calculation: Weighted bullish score = sum of each enabled T's separate weight where CVD(T) is rising over the CVD direction lookback on chart bars.
Calculation: Weighted bearish score = sum of each enabled T's separate weight where CVD(T) is falling over the CVD direction lookback on chart bars.
Calculation: Bullish weighted dominance = weighted bullish score > weighted bearish score.
Calculation: Bearish weighted dominance = weighted bearish score > weighted bullish score.
Calculation: Alignment count = max(bullish TF count, bearish TF count).
Calculation: Average ADX = mean of ADX(high(T), low(T), close(T), ADX lookback) over enabled T; ADX is calculated on T bars and sampled on chart bars from T's current bar, which may still be forming; zero when no T is enabled.
Calculation: Bullish divergence(T) = close(T) < lowest(close(T)[prior chart bar], divergence lookback) AND CVD(T) >= lowest(CVD(T)[prior chart bar], divergence lookback), using chart bars sampled from T's current bar, which may still be forming.
Calculation: Bearish divergence(T) = close(T) > highest(close(T)[prior chart bar], divergence lookback) AND CVD(T) <= highest(CVD(T)[prior chart bar], divergence lookback), using chart bars sampled from T's current bar, which may still be forming.
Calculation: Divergence TF count = count of enabled T with bullish divergence(T) or bearish divergence(T).
Calculation: Momentum-building TF count = count of enabled T where EMA(CVD(T), CVD EMA lookback) is rising over the CVD EMA slope lookback on chart bars.
Calculation: Momentum-slowing TF count = count of enabled T where EMA(CVD(T), CVD EMA lookback) is falling over the CVD EMA slope lookback on chart bars.
Calculation: Fresh TF count = count of enabled T whose rounded age in minutes is within the freshness limit; age is bars since the chart-bar CVD direction state (rising, falling, or neither) last changed, multiplied by T's duration in minutes; use the stale-age sentinel if no change exists.
Calculation: T1-T2 bullish alignment = T1 and T2 are enabled AND CVD(T1) and CVD(T2) are both rising over the CVD direction lookback on chart bars.
Calculation: T1-T2 bearish alignment = T1 and T2 are enabled AND CVD(T1) and CVD(T2) are both falling over the CVD direction lookback on chart bars.
Calculation: Summary alignment threshold = high-count summary threshold when enabled TF count meets the high-count mode cutoff; medium-count summary threshold when enabled TF count equals the medium-count mode count; otherwise low-count summary threshold.
Calculation: Strong bullish trend = enabled TF count > 0 AND weighted bullish score >= strong trend score threshold AND average ADX >= strong trend ADX threshold AND fresh TF count >= strong trend minimum fresh count.
Calculation: Strong bearish trend = enabled TF count > 0 AND weighted bearish score >= strong trend score threshold AND average ADX >= strong trend ADX threshold AND fresh TF count >= strong trend minimum fresh count.
Calculation: Late trend risk = enabled TF count > 0 AND alignment count >= min(late trend alignment cap, enabled TF count) AND (fresh TF count <= late trend maximum fresh count OR momentum-slowing TF count >= late trend minimum slowing count).
Calculation: Transition expansion = enabled TF count > 0 AND average ADX >= expansion ADX threshold AND momentum-building TF count >= min(active alignment cap, enabled TF count) AND fresh TF count >= transition minimum fresh count AND alignment count >= min(active alignment cap, enabled TF count).
Long: on any enabled T, Buy percentage(T) >= high participation threshold AND CVD(T) is rising over the CVD direction lookback on chart bars.
Short: on any enabled T, Buy percentage(T) <= low participation threshold AND CVD(T) is falling over the CVD direction lookback on chart bars.
Long: on any enabled T, bullish divergence(T).
Short: on any enabled T, bearish divergence(T).
Long: bullish TF count >= summary alignment threshold OR (enabled TF count > 0 AND bullish weighted dominance).
Short: bearish TF count >= summary alignment threshold OR (enabled TF count > 0 AND bearish weighted dominance).
Long: bullish TF count < summary alignment threshold AND bearish TF count < summary alignment threshold AND T1-T2 bullish alignment AND bullish weighted dominance.
Short: bullish TF count < summary alignment threshold AND bearish TF count < summary alignment threshold AND T1-T2 bearish alignment AND bearish weighted dominance.
Long: strong bullish trend OR (divergence TF count = 0 AND NOT strong bullish trend AND NOT strong bearish trend AND ((enabled TF count > 0 AND bullish weighted dominance AND bullish TF count >= min(active alignment cap, enabled TF count) AND average ADX >= expansion ADX threshold AND momentum-building TF count >= min(active alignment cap, enabled TF count)) OR (late trend risk AND bullish weighted dominance) OR (transition expansion AND bullish weighted dominance)).
Short: (strong bearish trend AND NOT strong bullish trend) OR (divergence TF count = 0 AND NOT strong bullish trend AND NOT strong bearish trend AND ((enabled TF count > 0 AND bearish weighted dominance AND bearish TF count >= min(active alignment cap, enabled TF count) AND average ADX >= expansion ADX threshold AND momentum-building TF count >= min(active alignment cap, enabled TF count)) OR (late trend risk AND bearish weighted dominance) OR (transition expansion AND bearish weighted dominance))).