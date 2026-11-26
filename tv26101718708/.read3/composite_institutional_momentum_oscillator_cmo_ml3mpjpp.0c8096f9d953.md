Calculation: Composite momentum = EMA((WMA(price source, dual lookback) - composite anchor) / StdDev(price source, macro lookback), momentum smoothing lookback), where dual lookback = WMA(price source, fast lookback) * price doubling factor - WMA(price source, micro lookback), composite anchor = SMA(price source * composite weight, macro lookback) / SMA(composite weight, macro lookback), and composite weight = max(abs(order-flow factor) * absorption factor * volume, weight floor); order-flow factor = SMA(((price source * price doubling factor - high - low) / max(high - low, range floor)) * volume, fast lookback) when enabled, otherwise the neutral factor; absorption factor = (volume / max(high - low, range floor)) / max(SMA(volume / max(high - low, range floor), macro lookback), range floor) when enabled, otherwise the neutral factor; compute on T1 bars and map to chart bars from the still-forming T1 bar.
Calculation: Bullish liquidity sweep = low(T1) < lowest(low, macro lookback, T1)[1] AND price source(T1) > lowest(low, macro lookback, T1)[1]; compute on T1 bars and map to chart bars from the still-forming T1 bar.
Calculation: Bearish liquidity sweep = high(T1) > highest(high, macro lookback, T1)[1] AND price source(T1) < highest(high, macro lookback, T1)[1]; compute on T1 bars and map to chart bars from the still-forming T1 bar.
Calculation: Volatility score = clamp((volatility base - StdDev(price source, short volatility lookback, T1) / StdDev(price source, macro lookback, T1)) * volatility scale + volatility offset, score floor, score ceiling).
Calculation: Momentum score = clamp((Composite momentum + momentum offset) / momentum range * score scale, score floor, score ceiling).
Calculation: Sentiment index = volatility score * volatility weight + momentum score * momentum weight + RSI(price source, RSI lookback, T1) * RSI weight; compute on T1 bars and map to chart bars from the still-forming T1 bar.
Calculation: Bullish divergence = low < lowest(low[1], divergence lookback) AND Composite momentum > lowest(Composite momentum[1], divergence lookback); evaluate on chart bars using the mapped T1 momentum values.
Calculation: Bearish divergence = high > highest(high[1], divergence lookback) AND Composite momentum < highest(Composite momentum[1], divergence lookback); evaluate on chart bars using the mapped T1 momentum values.
Calculation: Adjusted sentiment score = apply the divergence adjustment by subtracting it for bullish divergence, floored at the score floor, then adding it for bearish divergence, capped at the score ceiling.
Calculation: Capitulated state = set true on a chart bar when Composite momentum < -extreme threshold; remain true until a bar where the state is true and Composite momentum >= -extreme threshold and < near-zero boundary, then set false.
Calculation: Accumulation reclaim = Capitulated state AND Composite momentum >= -extreme threshold AND Composite momentum < near-zero boundary.
Long: price source(T1) >= WMA(price source, micro lookback, T1); compute on T1 bars and map to chart bars from the still-forming T1 bar.
Short: price source(T1) < WMA(price source, micro lookback, T1); compute on T1 bars and map to chart bars from the still-forming T1 bar.
Long: price source(T2) >= VWMA(price source, macro lookback, T2); compute on T2 bars and map to chart bars from the still-forming T2 bar.
Short: price source(T2) < VWMA(price source, macro lookback, T2); compute on T2 bars and map to chart bars from the still-forming T2 bar.
Long: Composite momentum > extreme threshold AND price source(T2) >= VWMA(price source, macro lookback, T2).
Short: Composite momentum < -extreme threshold AND price source(T2) < VWMA(price source, macro lookback, T2).
Long: Bullish liquidity sweep.
Short: Bearish liquidity sweep.
Long: Composite momentum >= near-zero boundary AND Composite momentum <= extreme threshold.
Short: (Composite momentum >= -extreme threshold AND Composite momentum <= -near-zero boundary) OR (Composite momentum <= -near-zero boundary AND NOT Accumulation reclaim AND NOT (Bullish liquidity sweep AND Composite momentum < 0)).
Long: Accumulation reclaim OR (Composite momentum crosses above -extreme threshold AND Capitulated state[1]).
Long: Adjusted sentiment score <= accumulation threshold.
Exit: long, Adjusted sentiment score >= profit-taking threshold.