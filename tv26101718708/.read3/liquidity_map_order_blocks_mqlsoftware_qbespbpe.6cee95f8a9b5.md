Calculation: Protected-swing engine = on each confirmed bar, confirm PivotHigh(high, left-pivot lookback, right-pivot lookback) and PivotLow(low, left-pivot lookback, right-pivot lookback); maintain trend (initially flat), latest pivot high H and low L, and protected high PH and low PL. On a confirmed pivot high h: if trend is bullish and (H is unset or h>H), set PL=L and emit BOS-up; otherwise, if trend is not bullish, compare h with PH when trend is bearish or H otherwise, and if that reference exists and h exceeds it, set trend bullish, PL=L, and emit CHoCH-up if the prior trend was bearish, else BOS-up; then set H=h. On a confirmed pivot low l: if trend is bearish and (L is unset or l<L), set PH=H and emit BOS-down; otherwise, if trend is not bearish, compare l with PL when trend is bullish or L otherwise, and if that reference exists and l is below it, set trend bearish, PH=H, and emit CHoCH-down if the prior trend was bullish, else BOS-down; then set L=l.
Calculation: Higher-timeframe protected-swing bias(T) = Protected-swing engine calculated on T bars, read on chart bars from the last completed T bar.
Calculation: Liquidity pools = retain confirmed pivot highs and lows within the pool lookback, up to the pivot-retention cap per side; sort each side by price and group adjacent levels whose gap is at most cluster distance in ATR units; keep groups with at least the minimum touches. Each pool center is the mean level, its birth is its oldest pivot, and its score is 100 × (1−exp(−touch-decay rate × touches)) × exp(−ln(2) × age/age half-life) × volume factor × wick factor. The volume factor is the clipped ratio of average pivot volume to SMA(volume, volume-average lookback), between its floor and 1, when volume weighting is enabled and valid, otherwise 1; the wick factor is average pivot wick ratio clipped between its floor and 1. High-pivot wick ratio is upper wick divided by candle range; low-pivot wick ratio is lower wick divided by candle range. A pool is swept when a later stored sweep has the same side and is within cluster distance of its center.
Calculation: Pool pull = pool score/100 × exp(−absolute distance from close in ATR units/proximity scale) × structural prior × path clearance, for each unswept pool. Structural prior is 1 when trend is flat, 1+prior strength when the pool lies in the trend direction, and 1−prior strength otherwise. Path clearance is the product, over other unswept pools strictly between close and the candidate, of (1−clearance strength × other pool score/100).
Calculation: Draw target = unswept pool with maximum Pool pull; no target exists if there are no unswept pools.
Calculation: Draw confidence = when empirical calibration is enabled, the historical hit rate for the target's profile bucket, 100×(bucket hits+prior hits)/(bucket trials+prior trials); otherwise, 100×min(soft-share cap, target pull^(1/softmax temperature)/sum of unswept pool pulls^(1/softmax temperature)). A profile bucket uses target score bands and ATR-distance bands, plus trend alignment (flat, aligned, or opposed); a hit is price reaching the registered target within the calibration horizon.
Calculation: Net liquidity bias = (Draw target price above close ? 1 : −1) × Draw confidence/100.
Calculation: Active bullish order block = an unmitigated bullish block created on BOS-up from the nearest bearish candle among the preceding OB scan lookback bars; the zone is that candle's low-to-high range and is mitigated when a later or current low is at or below its high. Retain at most the OB box cap. Active bearish order block = an unmitigated bearish block created on BOS-down from the nearest bullish candle among the preceding OB scan lookback bars; the zone is that candle's low-to-high range and is mitigated when a later or current high is at or above its low. Retain at most the OB box cap.
Calculation: Active bullish FVG = an unmitigated gap created on BOS-up when low>high[2], with zone high[2] to low, mitigated when a later or current low is at or below high[2]. Active bearish FVG = an unmitigated gap created on BOS-down when high<low[2], with zone high to low[2], mitigated when a later or current high is at or above low[2]. Retain at most the OB box cap.
Long: confirmed chart bar AND Protected-swing engine emits BOS-up
Short: confirmed chart bar AND Protected-swing engine emits BOS-down
Long: confirmed chart bar AND Protected-swing engine emits CHoCH-up
Short: confirmed chart bar AND Protected-swing engine emits CHoCH-down
Long: confirmed chart bar AND close>latest pivot low−sweep penetration×ATR(close, ATR lookback) AND low<latest pivot low−sweep penetration×ATR(close, ATR lookback)
Short: confirmed chart bar AND high>latest pivot high+sweep penetration×ATR(close, ATR lookback) AND close<latest pivot high
Long: confirmed chart bar AND chart protected-swing trend is bullish
Short: confirmed chart bar AND chart protected-swing trend is bearish
Long: Higher-timeframe protected-swing bias(T1) is bullish
Short: Higher-timeframe protected-swing bias(T1) is bearish
Long: Higher-timeframe protected-swing bias(T2) is bullish
Short: Higher-timeframe protected-swing bias(T2) is bearish
Long: Higher-timeframe protected-swing bias(T3) is bullish
Short: Higher-timeframe protected-swing bias(T3) is bearish
Long: confirmed chart bar AND Higher-timeframe protected-swing bias(T1) is bullish AND Higher-timeframe protected-swing bias(T2) is bullish AND Higher-timeframe protected-swing bias(T3) is bullish
Short: confirmed chart bar AND Higher-timeframe protected-swing bias(T1) is bearish AND Higher-timeframe protected-swing bias(T2) is bearish AND Higher-timeframe protected-swing bias(T3) is bearish
Long: Draw target exists AND Draw target price>close
Short: Draw target exists AND Draw target price≤close
Long: Net liquidity bias>net-bias threshold
Short: Net liquidity bias<−net-bias threshold
Long: Draw target exists AND Draw confidence≥draw-confidence threshold AND (empirical calibration is disabled OR target-bucket trials≥minimum calibration samples)
Short: Draw target exists AND Draw confidence≥draw-confidence threshold AND (empirical calibration is disabled OR target-bucket trials≥minimum calibration samples)
Long: Active bullish order block exists
Short: Active bearish order block exists
Long: Active bullish FVG exists
Short: Active bearish FVG exists