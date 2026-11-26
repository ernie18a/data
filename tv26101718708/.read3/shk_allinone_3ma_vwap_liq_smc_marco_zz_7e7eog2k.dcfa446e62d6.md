Calculation: Trend score = sum of enabled filter votes: +1 for bullish and -1 for bearish Heikin Ashi, Supertrend, and UT Bot conditions; 0 otherwise. UT Bot uses Heikin Ashi close as its source.
Long: Trend score > 0
Short: Trend score < 0
Long: MA(close, first type, first lookback) crosses above MA(close, second type, second lookback) OR MA(close, second type, second lookback) crosses above MA(close, third type, third lookback)
Short: MA(close, first type, first lookback) crosses below MA(close, second type, second lookback) OR MA(close, second type, second lookback) crosses below MA(close, third type, third lookback)
Calculation: Structure pivots(n) = when high[n] > Highest(high, n), set the leg bearish; otherwise, when low[n] < Lowest(low, n), set the leg bullish. On a leg change, store high[n] for a new high or low[n] for a new low as the latest pivot, retaining each level until the next corresponding pivot.
Long: close crosses above the latest unbroken swing pivot high
Short: close crosses below the latest unbroken swing pivot low
Long: close crosses above the latest unbroken internal pivot high AND (the internal confluence filter is disabled OR (the internal pivot high differs from the latest swing pivot high AND high - max(close, open) > min(close, open - low)))
Short: close crosses below the latest unbroken internal pivot low AND (the internal confluence filter is disabled OR (the internal pivot low differs from the latest swing pivot low AND high - max(close, open) < min(close, open - low)))
Long: a confirmed swing pivot high is greater than the previous swing pivot high OR a confirmed swing pivot low is greater than or equal to the previous swing pivot low
Short: a confirmed swing pivot high is less than or equal to the previous swing pivot high OR a confirmed swing pivot low is less than the previous swing pivot low
Long: low two bars ago on T1 > current forming bar high on T1 AND (low two bars ago on T1 - current forming bar high on T1) > (automatic threshold enabled ? ATR(chart bars, ATR lookback parameter) × threshold multiplier : 0), evaluated on chart bars using T1 values
Short: high two bars ago on T1 < current forming bar low on T1 AND (current forming bar low on T1 - high two bars ago on T1) > (automatic threshold enabled ? ATR(chart bars, ATR lookback parameter) × threshold multiplier : 0), evaluated on chart bars using T1 values
Calculation: Marco pivots = candidate highs are high[depth] greater than or equal to every high from the current bar through depth bars ago; candidate lows are low[depth] less than or equal to every low over those bars. Choose a high if both qualify. Accept an opposite-side candidate if no pivot has been accepted or abs(100 × (candidate price - last accepted pivot price) / candidate price) > ATR(ATR lookback parameter) / close × 100 × deviation multiplier; replace a same-side accepted pivot only with a more extreme candidate.
Long: an accepted Marco low pivot OR (low[2] < lower Bollinger Band(close, BB lookback, BB multiplier)[2] AND close[2] < open[2] AND close[1] > lower Bollinger Band(close, BB lookback, BB multiplier)[1] AND close[1] > open[1] AND close > high[1])
Short: an accepted Marco high pivot OR (high[2] > upper Bollinger Band(close, BB lookback, BB multiplier)[2] AND close[2] > open[2] AND close[1] < upper Bollinger Band(close, BB lookback, BB multiplier)[1] AND close[1] < open[1] AND close < low[1])
Calculation: ZigZag pivots(depth, backstep) = use rolling depth-bar highs and lows; start with a qualifying high if available, otherwise a qualifying low. In an up leg, update the pivot on a qualifying high when it exceeds the current pivot high or occurs fewer than backstep bars after the last reversal; otherwise reverse to a qualifying low after at least backstep bars. Apply the symmetric rules in a down leg. Label a high HH if there is no prior pivot high or it is greater than or equal to that high, otherwise LH; label a low LL if there is no prior pivot low or it is less than or equal to that low, otherwise HL.
Calculation: Internal ZigZag pivots = ZigZag pivots(depth, backstep) with separate depth and backstep parameters.
Long: swing ZigZag pivot label is HH or HL
Short: swing ZigZag pivot label is LH or LL
Long: internal ZigZag pivot label is HH or HL
Short: internal ZigZag pivot label is LH or LL
Calculation: Order blocks = on an upward structure break, select the bar with the lowest low from the pivot bar through the break as a bullish block; on a downward break, select the bar with the highest high as a bearish block. Each block uses that bar's high and low and is mitigated when its configured mitigation source moves below its low (bullish) or above its high (bearish).
Long: a bearish order block is mitigated when its configured mitigation source > its high
Short: a bullish order block is mitigated when its configured mitigation source < its low
Calculation: Trailing swing high and low = the latest confirmed swing pivot high and low.
Long: close is between the trailing swing low and (0.95 × trailing swing low + 0.05 × trailing swing high)
Short: close is between (0.95 × trailing swing high + 0.05 × trailing swing low) and the trailing swing high