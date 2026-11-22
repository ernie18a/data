Calculation: SmoothedDelta = EMA(0.5 * volume * (directional weight * (((close > open OR close > close[1]) ? 1 : 0) - ((close < open OR close < close[1]) ? 1 : 0)) + (1 - directional weight) * (sign(close - open) + (high = low ? 0 : (close - open) / (high - low)))), delta smoothing length)
Calculation: NormalizedDelta = clamp((EMA(abs(SmoothedDelta), normalization length) = 0 ? 0 : SmoothedDelta / EMA(abs(SmoothedDelta), normalization length)), -histogram clamp, histogram clamp)
Calculation: TsiScaled = TSI(close, shorter TSI length, longer TSI length) / 100
Calculation: BoostedAccel = acceleration multiplier * EMA(TsiScaled - TsiScaled[1], acceleration smoothing length)
Calculation: GatedRaw = ((NormalizedDelta * base weight * (NormalizedDelta * BoostedAccel < 0 ? max(penalty floor, 1 - opposition penalty * abs(BoostedAccel)) : 1) + (NormalizedDelta * BoostedAccel > 0 ? NormalizedDelta * abs(BoostedAccel) * boost weight : 0)) * histogram power) * (chop gate on AND abs(NormalizedDelta) < chop threshold AND abs(BoostedAccel) < chop threshold ? chop compression : 1)
Calculation: SmoothedRaw = EMA(GatedRaw * (ignition assist on AND abs(GatedRaw[1]) < ignition threshold AND abs(GatedRaw) > abs(GatedRaw[1]) AND NormalizedDelta * BoostedAccel > 0 ? 1 + ignition boost : 1), histogram smoothing length)
Calculation: Adjusted = SmoothedRaw * (sustain on AND SmoothedRaw * SmoothedRaw[1] > 0 AND NormalizedDelta * BoostedAccel > 0 AND abs(SmoothedRaw) > sustain threshold AND abs(NormalizedDelta) > chop threshold AND abs(SmoothedRaw) >= abs(SmoothedRaw[1]) ? sustain boost : 1) * (decay on AND SmoothedRaw * SmoothedRaw[1] > 0 AND abs(SmoothedRaw) < abs(SmoothedRaw[1]) AND abs(BoostedAccel) < abs(BoostedAccel[1]) AND abs(NormalizedDelta) < abs(NormalizedDelta[1]) ? max(decay floor, 1 - decay sensitivity) : 1)
Calculation: TailCleaned = Adjusted * (tail cleanup on AND abs(Adjusted) < tail threshold AND NormalizedDelta * BoostedAccel < 0 AND abs(NormalizedDelta) < abs(NormalizedDelta[1]) ? tail decay : 1)
Calculation: Histogram = clamp(TailCleaned * (reset assist on AND abs(TailCleaned) < reset threshold AND abs(NormalizedDelta) < chop threshold ? reset factor : 1), -histogram clamp, histogram clamp)
Calculation: BuyShare = (high = low ? 0 : round(100 * (close - low) / (high - low)))
Calculation: AvgBuyShare = round((BuyShare(T1, last completed bar) + BuyShare(T2, last completed bar) + BuyShare(T3, last completed bar)) / 3)
Calculation: UpVotes = (Histogram(T1, last completed bar) >= bull threshold ? 1 : 0) + (Histogram(T2, last completed bar) >= bull threshold ? 1 : 0) + (Histogram(T3, last completed bar) >= bull threshold ? 1 : 0)
Calculation: DownVotes = (Histogram(T1, last completed bar) <= bear threshold ? 1 : 0) + (Histogram(T2, last completed bar) <= bear threshold ? 1 : 0) + (Histogram(T3, last completed bar) <= bear threshold ? 1 : 0)
Calculation: StrongVotes = (abs(Histogram(T1, last completed bar)) >= strong level ? 1 : 0) + (abs(Histogram(T2, last completed bar)) >= strong level ? 1 : 0) + (abs(Histogram(T3, last completed bar)) >= strong level ? 1 : 0)
Long: Histogram >= bull threshold
Short: Histogram <= bear threshold
Long: Histogram > 0
Short: Histogram < 0
Long: Histogram >= bull threshold AND Histogram > Histogram[1]
Short: Histogram <= bear threshold AND Histogram < Histogram[1]
Long: Histogram(T1, last completed bar) >= bull threshold
Long: Histogram(T2, last completed bar) >= bull threshold
Long: Histogram(T3, last completed bar) >= bull threshold
Short: Histogram(T1, last completed bar) <= bear threshold
Short: Histogram(T2, last completed bar) <= bear threshold
Short: Histogram(T3, last completed bar) <= bear threshold
Long: UpVotes = 3 AND StrongVotes >= strong count
Long: DownVotes = 0 AND UpVotes >= dominance count AND (UpVotes < 3 OR StrongVotes < strong count)
Long: UpVotes >= dominance count AND DownVotes > 0
Short: DownVotes = 3 AND StrongVotes >= strong count
Short: UpVotes = 0 AND DownVotes >= dominance count AND (DownVotes < 3 OR StrongVotes < strong count)
Short: DownVotes >= dominance count AND UpVotes > 0
Long: AvgBuyShare > 50
Short: AvgBuyShare < 50