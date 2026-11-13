Calculation: score = weighted sum of six flags (1 if true, else 0). Stage-2 trend carries the largest weight, then volume dry-up, then the other four. All inputs come from bars of a scan timeframe (equal to or higher than the chart timeframe), using the last completed bar.
Calculation: flag Stage2 = close > EMA(shortest length) AND EMA(shortest) > EMA(second) AND EMA(second) > EMA(third) AND EMA(third) > EMA(longest), with four EMAs of increasing length
Calculation: flag NearHigh = (highest high over a long lookback (about one year) - close) / that highest high <= max allowed fraction
Calculation: flag PriorGain = (close - lowest low over a medium lookback) / that lowest low >= min required gain
Calculation: flag VolDry = SMA(volume, short lookback) < fraction (below 1) * SMA(volume, longer lookback)
Calculation: flag AtrContract = SMA(ATR/close, short lookback) < fraction (below 1) * SMA(ATR/close, long lookback)
Calculation: flag Tight = (highest high - lowest low over a short lookback) < fraction (below 1) * (highest high - lowest low over a longer lookback)
Long: score >= threshold