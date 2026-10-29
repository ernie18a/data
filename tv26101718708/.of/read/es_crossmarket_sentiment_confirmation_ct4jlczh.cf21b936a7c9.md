Calculation: ES ROC and NQ ROC = percentage change in each market’s close over the same lookback on the confirmation timeframe; use the latest value returned with lookahead off (confirmation timeframe may be higher or lower than the chart timeframe; its current bar may still be forming in real time)
Calculation: VIX ROC = percentage change in VIX close over the lookback on the confirmation timeframe, using the same lookback as ES and NQ ROC and the same bar timing
Calculation: Smoothed TICK = simple moving average of TICK close over its smoothing lookback on the confirmation timeframe, with the same bar timing
Calculation: NQ vote = +1 if ES ROC > 0 AND NQ ROC > 0; -1 if ES ROC < 0 AND NQ ROC < 0; otherwise 0
Calculation: VIX vote = +1 if VIX ROC is at or below the negative spike threshold; -1 if VIX ROC is at or above the positive spike threshold; otherwise 0
Calculation: TICK vote = in confirmation mode, +1 if Smoothed TICK is at or above the bullish extreme threshold or is > 200 but below that threshold; -1 if at or below the bearish extreme threshold or is < -200 but above that threshold; otherwise 0. In contrarian mode, reverse the vote at either extreme; retain the > 200 and < -200 votes outside the extremes.
Calculation: Total score = NQ vote + VIX vote + TICK vote
Long: NQ vote = +1 OR VIX vote = +1 OR TICK vote = +1 OR Total score > 0
Short: NQ vote = -1 OR VIX vote = -1 OR TICK vote = -1 OR Total score < 0