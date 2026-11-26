Calculation: Deviation = SMA(hlc3, channel length) - EMA(SMA(hlc3, channel length), average length), on T1 bars
Calculation: WaveTrend = EMA(Deviation / (scale factor * EMA(abs(Deviation), average length)), smoothing length), 0 where the divisor is 0, on T1 bars
Calculation: WaveTrendSignal = SMA(WaveTrend, smoothing length), on T1 bars
Calculation: CenteredRange(x) = (x - lowest(x, normalization lookback)) / (highest(x, normalization lookback) - lowest(x, normalization lookback)) * 100 - 50, 0 where the range is 0
Calculation: MoneyFlow = (CenteredRange(ChaikinMoneyFlow(CMF length)) + CenteredRange(MFI(hlc3, MFI length))) / 2, on T1 bars
Calculation: BuyerRunEnd = crossunder(WaveTrend, 0), on T1 bars
Calculation: SellerRunEnd = crossover(WaveTrend, 0), on T1 bars
Calculation: BuyerPeakWT(k) = highest WaveTrend of the k-th most recent completed buyer run, a buyer run being the consecutive T1 bars with WaveTrend > 0 ending at BuyerRunEnd (k = 1 is most recent), on T1 bars
Calculation: BuyerArea(k) = sum of WaveTrend over the k-th most recent completed buyer run, on T1 bars
Calculation: BuyerPeakMF(k) = MoneyFlow on the bar where BuyerPeakWT(k) occurs, on T1 bars
Calculation: BuyerPeakClose(k) = close on the bar where BuyerPeakWT(k) occurs, on T1 bars
Calculation: BuyerHasData = at least three completed buyer runs exist, on T1 bars
Calculation: SellerPeakWT(k) = highest absolute WaveTrend of the k-th most recent completed seller run, a seller run being the consecutive T1 bars with WaveTrend < 0 ending at SellerRunEnd (k = 1 is most recent), on T1 bars
Calculation: SellerArea(k) = sum of absolute WaveTrend over the k-th most recent completed seller run, on T1 bars
Calculation: SellerPeakMF(k) = absolute MoneyFlow on the bar where SellerPeakWT(k) occurs, on T1 bars
Calculation: SellerPeakClose(k) = close on the bar where SellerPeakWT(k) occurs, on T1 bars
Calculation: SellerHasData = at least three completed seller runs exist, on T1 bars
Calculation: BuyerEfficiency = (BuyerPeakClose(1) - BuyerPeakClose(3)) / max(epsilon, BuyerPeakClose(3)) * 100 / max(floor, BuyerArea(1) + BuyerArea(2) + BuyerArea(3)), updated at each BuyerRunEnd where BuyerHasData, on T1 bars
Calculation: BuyerEfficiencyDecay = persistent flag, set at each BuyerRunEnd where BuyerHasData and a previous BuyerEfficiency exists to abs(BuyerEfficiency) / max(epsilon, abs(previous BuyerEfficiency)) < efficiency decay threshold, otherwise unchanged, on T1 bars
Calculation: BuyerAgeImpulse = sum of age increments 1 to 5, each included when its buyer age condition holds on the bar, on T1 bars
Calculation: BuyerPenalty = persistent value clamped to 0-100: at each BuyerRunEnd, previous + BuyerAgeImpulse * wave damage multiplier; on every other bar, previous + BuyerAgeImpulse * aging leak - recovery per bar, on T1 bars
Calculation: BuyerWaveScore = 100 if not BuyerHasData; otherwise min(100, WT score weight * min(1, BuyerPeakWT(1) / WT span) + area score weight * clamp(BuyerArea(1) / max(floor, BuyerArea(2)), 0, ratio cap) + MF score weight * clamp(BuyerPeakMF(1) / max(floor, BuyerPeakMF(2)), 0, ratio cap)), on T1 bars
Calculation: BuyerStructural = clamp(BuyerWaveScore * wave score weight + (100 - BuyerPenalty) * penalty score weight, 0, 100), on T1 bars
Calculation: BuyerLive = live base + min(1, max(0, WaveTrend + WT offset) / WT span) * live scale + min(1, max(0, MoneyFlow + MF offset) / MF span) * live scale, on T1 bars
Calculation: BuyerVitalityScore = round(clamp(BuyerStructural * structural weight + BuyerLive * live weight, 0, 100)), on T1 bars
Calculation: BuyerDecayTally = number of true of (BuyerPeakWT(1) < BuyerPeakWT(3)), (BuyerArea(1) < BuyerArea(3)), (BuyerPeakMF(1) < BuyerPeakMF(3)), 0 where not BuyerHasData, on T1 bars
Calculation: BuyerDominant = BuyerVitalityScore > SellerVitalityScore OR (BuyerVitalityScore = SellerVitalityScore AND close > SMA(close, trend length)), on T1 bars
Calculation: SellerEfficiency = (SellerPeakClose(3) - SellerPeakClose(1)) / max(epsilon, SellerPeakClose(3)) * 100 / max(floor, SellerArea(1) + SellerArea(2) + SellerArea(3)), updated at each SellerRunEnd where SellerHasData, on T1 bars
Calculation: SellerEfficiencyDecay = persistent flag, set at each SellerRunEnd where SellerHasData and a previous SellerEfficiency exists to abs(SellerEfficiency) / max(epsilon, abs(previous SellerEfficiency)) < efficiency decay threshold, otherwise unchanged, on T1 bars
Calculation: SellerAgeImpulse = sum of age increments 1 to 5, each included when its seller age condition holds on the bar, on T1 bars
Calculation: SellerPenalty = persistent value clamped to 0-100: at each SellerRunEnd, previous + SellerAgeImpulse * wave damage multiplier; on every other bar, previous + SellerAgeImpulse * aging leak - recovery per bar, on T1 bars
Calculation: SellerWaveScore = 100 if not SellerHasData; otherwise min(100, WT score weight * min(1, SellerPeakWT(1) / WT span) + area score weight * clamp(SellerArea(1) / max(floor, SellerArea(2)), 0, ratio cap) + MF score weight * clamp(SellerPeakMF(1) / max(floor, SellerPeakMF(2)), 0, ratio cap)), on T1 bars
Calculation: SellerStructural = clamp(SellerWaveScore * wave score weight + (100 - SellerPenalty) * penalty score weight, 0, 100), on T1 bars
Calculation: SellerLive = live base + min(1, max(0, -WaveTrend + WT offset) / WT span) * live scale + min(1, max(0, -MoneyFlow + MF offset) / MF span) * live scale, on T1 bars
Calculation: SellerVitalityScore = round(clamp(SellerStructural * structural weight + SellerLive * live weight, 0, 100)), on T1 bars
Calculation: SellerDecayTally = number of true of (SellerPeakWT(1) < SellerPeakWT(3)), (SellerArea(1) < SellerArea(3)), (SellerPeakMF(1) < SellerPeakMF(3)), 0 where not SellerHasData, on T1 bars
Calculation: SellerDominant = SellerVitalityScore > BuyerVitalityScore OR (SellerVitalityScore = BuyerVitalityScore AND close < SMA(close, trend length)), on T1 bars
Long: crossover(WaveTrend, WaveTrendSignal) AND WaveTrend < 0 AND SellerVitalityScore <= weak vitality threshold, (T1, last completed bar)
Short: crossunder(WaveTrend, WaveTrendSignal) AND WaveTrend > 0 AND BuyerVitalityScore <= weak vitality threshold, (T1, last completed bar)
Long: BuyerDominant, (T1, last completed bar)
Short: SellerDominant, (T1, last completed bar)
Exit: long, BuyerDominant AND BuyerVitalityScore < warning vitality threshold AND BuyerDecayTally >= decay tally threshold AND BuyerPenalty >= penalty threshold AND (BuyerLive < live threshold OR BuyerEfficiencyDecay OR BuyerLive - BuyerStructural >= gap threshold), (T1, last completed bar)
Exit: short, SellerDominant AND SellerVitalityScore < warning vitality threshold AND SellerDecayTally >= decay tally threshold AND SellerPenalty >= penalty threshold AND (SellerLive < live threshold OR SellerEfficiencyDecay OR SellerLive - SellerStructural >= gap threshold), (T1, last completed bar)