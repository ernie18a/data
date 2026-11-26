Calculation: RangeHigh = Highest(high, lookback)
Calculation: RangeLow = Lowest(low, lookback)
Calculation: Mid = DonchianMidline(lookback)
Calculation: LastTurn = up if (Mid > Mid[1] AND Mid[1] <= Mid[2]), down if (Mid < Mid[1] AND Mid[1] >= Mid[2]), otherwise LastTurn[1]
Calculation: BuyShare = if close > open then clamp(base share + body weight * abs(close - open) / R - wick weight * (high - max(open, close)) / R, min share, max share), if close < open then 1 - clamp(base share + body weight * abs(close - open) / R - wick weight * (min(open, close) - low) / R, min share, max share), otherwise base share, where R = max(high - low, tick size)
Calculation: Bins = clamp(round((RangeHigh - RangeLow) / (tick size * ticks per bin)), min bins, max bins)
Calculation: BinShare(i, k) = max(0, min(high[i], RangeLow + (k + 1) * (RangeHigh - RangeLow) / Bins) - max(low[i], RangeLow + k * (RangeHigh - RangeLow) / Bins)) / max(high[i] - low[i], tick size)
Calculation: BinVolume(k) = sum over i from 0 to lookback - 1 of volume[i] * BinShare(i, k)
Calculation: BinBuyVolume(k) = sum over i from 0 to lookback - 1 of volume[i] * BuyShare[i] * BinShare(i, k)
Calculation: BinSellVolume(k) = BinVolume(k) - BinBuyVolume(k)
Calculation: PeakVolume = max over k from 0 to Bins - 1 of BinVolume(k)
Calculation: ScanBins = max(min scan bins, round(Bins * scan depth))
Calculation: HighAcceptance = (BinVolume(Bins - 1) >= PeakVolume * HVN threshold) AND (BinSellVolume(Bins - 1) <= BinBuyVolume(Bins - 1))
Calculation: HighRejection = ((BinVolume(Bins - 1) >= PeakVolume * HVN threshold) AND (BinSellVolume(Bins - 1) > BinBuyVolume(Bins - 1))) OR ((BinVolume(Bins - 1) <= PeakVolume * LVN threshold) AND (for some j from Bins - ScanBins to Bins - 2, ((BinVolume(j) >= PeakVolume * HVN threshold) AND (BinSellVolume(j) > BinBuyVolume(j))) OR ((BinSellVolume(j) > imbalance ratio * BinBuyVolume(j)) AND (BinVolume(j) > PeakVolume * minor node share))))
Calculation: LowAcceptance = (BinVolume(0) >= PeakVolume * HVN threshold) AND (BinBuyVolume(0) <= BinSellVolume(0))
Calculation: LowRejection = ((BinVolume(0) >= PeakVolume * HVN threshold) AND (BinBuyVolume(0) > BinSellVolume(0))) OR ((BinVolume(0) <= PeakVolume * LVN threshold) AND (for some j from 1 to ScanBins - 1, ((BinVolume(j) >= PeakVolume * HVN threshold) AND (BinBuyVolume(j) > BinSellVolume(j))) OR ((BinBuyVolume(j) > imbalance ratio * BinSellVolume(j)) AND (BinVolume(j) > PeakVolume * minor node share))))
Long: Mid > Mid[1] AND Mid[1] <= Mid[2] AND LastTurn[1] <> up AND close < Mid AND LowRejection
Short: Mid < Mid[1] AND Mid[1] >= Mid[2] AND LastTurn[1] <> down AND close > Mid AND HighRejection
Exit: short, HighAcceptance OR high > RangeHigh[1] OR low < RangeLow[1]
Exit: long, LowAcceptance OR high > RangeHigh[1] OR low < RangeLow[1]