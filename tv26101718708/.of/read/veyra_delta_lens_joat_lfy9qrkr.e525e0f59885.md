Calculation: Estimated delta = EMA(((((close - low) - (high - close)) / max(high - low, minimum tick)) * volume) * 0.65 + (((close - open) / max(high - low, minimum tick)) * volume) * 0.35, delta smoothing)
Calculation: CVD z-score = z-score of cumulative estimated delta over the CVD normalization lookback
Calculation: Delta impulse z-score = z-score of estimated delta over the impulse memory lookback
Calculation: Volume z-score = z-score of volume over the participation lookback
Calculation: Range z-score = z-score of bar range over the participation lookback
Calculation: Execution center = ALMA of close with a shorter lookback
Calculation: Auction mean = ALMA of close with a longer lookback
Calculation: Participation = absolute estimated delta / max(SMA of absolute estimated delta over the participation lookback, 1)
Calculation: Absorption ratio = absolute estimated delta / max(volume, 1)
Calculation: Bullish absorption = confirmed bar AND volume z-score > 1.1 AND absorption ratio < 0.18 AND close > open AND low < prior low
Calculation: Bearish absorption = confirmed bar AND volume z-score > 1.1 AND absorption ratio < 0.18 AND close < open AND high > prior high
Calculation: Upward vacuum = confirmed bar AND delta impulse z-score > 1.15 AND range z-score > 0.65 AND close > execution center AND EMA of estimated-delta change over 5 bars > 0
Calculation: Downward vacuum = confirmed bar AND delta impulse z-score < -1.15 AND range z-score > 0.65 AND close < execution center AND EMA of estimated-delta change over 5 bars < 0
Calculation: Disagreement z-score = z-score over 55 bars of (EMA of close change over 6 bars / max(ATR(14), minimum tick) - EMA of estimated-delta change over 6 bars / max(SMA of absolute estimated delta over the impulse memory lookback, 1))
Calculation: Positive divergence = confirmed bar AND disagreement z-score < -1.25 AND close > prior close AND CVD z-score > prior CVD z-score
Calculation: Negative divergence = confirmed bar AND disagreement z-score > 1.25 AND close < prior close AND CVD z-score < prior CVD z-score
Calculation: Bull score = clamp((execution center > auction mean ? 18 : 0) + (close > VWAP(hlc3) ? 12 : 0) + clamp((delta impulse z-score + 1.5) * 9, 0, 24) + clamp((CVD z-score + 1.2) * 7, 0, 20) + (upward vacuum ? 14 : 0) + (bullish absorption ? 10 : 0) + (positive divergence ? 8 : 0) + clamp(participation * 4, 0, 8), 0, 100)
Calculation: Bear score = clamp((execution center < auction mean ? 18 : 0) + (close < VWAP(hlc3) ? 12 : 0) + clamp((-delta impulse z-score + 1.5) * 9, 0, 24) + clamp((-CVD z-score + 1.2) * 7, 0, 20) + (downward vacuum ? 14 : 0) + (bearish absorption ? 10 : 0) + (negative divergence ? 8 : 0) + clamp(participation * 4, 0, 8), 0, 100)
Long: confirmed bar AND (no prior event OR bars since most recent long or short event >= cooldown) AND bull score >= event-score threshold AND bull score > bear score AND execution center > auction mean
Long: (bullish absorption OR positive divergence) AND bull score > bear score + 8 AND NOT (confirmed bar AND (no prior event OR bars since most recent long or short event >= cooldown) AND bull score >= event-score threshold AND bull score > bear score AND execution center > auction mean)
Short: confirmed bar AND (no prior event OR bars since most recent long or short event >= cooldown) AND bear score >= event-score threshold AND bear score > bull score AND execution center < auction mean
Short: (bearish absorption OR negative divergence) AND bear score > bull score + 8 AND NOT (confirmed bar AND (no prior event OR bars since most recent long or short event >= cooldown) AND bear score >= event-score threshold AND bear score > bull score AND execution center < auction mean)