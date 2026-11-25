Calculation: Master RSI = clamp the weighted mean of RSI(close, separate RSI lookback for each T1–T5, calculated on that timeframe’s bars and sampled on chart bars from its current, possibly still-forming bar); ignore unavailable values and use the neutral RSI midpoint if all are unavailable; T1 is fastest, T5 slowest, and weights satisfy W1=W5<W2<W3=W4.
Calculation: Dynamic RSI envelope on chart bars: U=EMA(highest(Master RSI, channel lookback), channel smoothing), L=EMA(lowest(Master RSI, channel lookback), channel smoothing), M=(U+L)/2, upper distance=max(U−M, distance floor), lower distance=max(M−L, distance floor).
Calculation: RSI zone boundaries = Z-Alert high band from M + upper distance × breathing multiplier to U; Z-Alert low band from L to M − lower distance × breathing multiplier; Z-Exhaustion high/low = M ± respective distance × exhaustion multiplier; Black Swan high/low = M ± respective distance × Black Swan multiplier in dynamic mode, otherwise configured fixed high/low levels; clamp boundaries to the RSI range.
Long: For each T1–T5 RSI, using its separate RSI lookback, and Master RSI, value ≤ oversold signal cutoff OR value ≥ bullish-state cutoff AND value < overbought signal cutoff.
Short: For each T1–T5 RSI, using its separate RSI lookback, and Master RSI, value ≥ overbought signal cutoff OR value > bearish-state lower cutoff AND value ≤ bearish-state upper cutoff.
Short: On bars of each T1–T5, a confirmed RSI pivot high using the divergence pivot lookback has a higher price high and lower RSI value than the immediately preceding RSI pivot high.
Long: On bars of each T1–T5, a confirmed RSI pivot low using the divergence pivot lookback has a lower price low and higher RSI value than the immediately preceding RSI pivot low.
Short: On chart bars, a confirmed Master RSI pivot high using the divergence pivot lookback has a higher chart high and lower Master RSI value than the immediately preceding Master RSI pivot high.
Long: On chart bars, a confirmed Master RSI pivot low using the divergence pivot lookback has a lower chart low and higher Master RSI value than the immediately preceding Master RSI pivot low.
Short: On confirmed chart bars, T1 RSI ≥ strong upper cutoff AND T5 RSI ≤ strong lower cutoff.
Long: On confirmed chart bars, T1 RSI ≤ strong lower cutoff AND T5 RSI ≥ strong upper cutoff.
Short: On confirmed chart bars, no strong MTF divergence is active AND T1 RSI ≥ moderate top-fast cutoff AND T5 RSI ≤ moderate top-slow cutoff.
Long: On confirmed chart bars, no strong MTF divergence is active AND T1 RSI ≤ moderate bottom-fast cutoff AND T5 RSI ≥ moderate bottom-slow cutoff.
Long: Master RSI is within the Z-Alert high band AND no strong or moderate MTF divergence is active on the confirmed chart bar.
Short: Master RSI is within the Z-Alert low band AND no strong or moderate MTF divergence is active on the confirmed chart bar.
Short: Master RSI crosses above the selected Black Swan high boundary on a confirmed chart bar.
Long: Master RSI crosses below the selected Black Swan low boundary on a confirmed chart bar.
Short: Master RSI crosses above the Z-Exhaustion high boundary on a confirmed chart bar.
Long: Master RSI crosses below the Z-Exhaustion low boundary on a confirmed chart bar.
Short: Master bearish regular divergence AND at least the divergence-confluence count of T1–T5 bearish regular divergences.
Long: Master bullish regular divergence AND at least the divergence-confluence count of T1–T5 bullish regular divergences.
Short: Master RSI is in the Z-Exhaustion high zone AND Master bearish regular divergence AND at least the divergence-confluence count of T1–T5 bearish regular divergences.
Long: Master RSI ≤ Black Swan low boundary AND Master bullish regular divergence AND T1 RSI ≤ strong lower cutoff AND T5 RSI ≥ strong upper cutoff.