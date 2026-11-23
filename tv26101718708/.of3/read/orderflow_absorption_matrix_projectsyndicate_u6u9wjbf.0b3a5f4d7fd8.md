Calculation: NetDelta = sum over the T1 bars composing the current chart bar of volume * sign(close - open)
Calculation: Absorption = sum of volume over the T1 bars composing the current chart bar where (T1 close > T1 open AND high > max(open, close) AND max(open, close) <= T1 close <= high) OR (T1 close < T1 open AND low < min(open, close) AND low <= T1 close <= min(open, close)), using the open, close, high, low of the current chart bar
Calculation: Profile = Nb equal-width price bins from Lowest(low, L) to Highest(high, L) over the last L bars, each bar assigned to the bin containing (high + low + close) / 3, clamped to the outer bins
Calculation: VolumeCluster = at least K of the windows of lengths L_s < L_m < L_l have volume >= Percentile(volume, window length, P_s), where Percentile(x, n, p) is the linearly interpolated p-th percentile of x over the last n bars including the current bar
Calculation: DeltaCluster = at least K of the windows of lengths L_s < L_m < L_l have abs(NetDelta) >= Percentile(abs(NetDelta), window length, P_s)
Calculation: PrintCluster = VolumeCluster, or DeltaCluster, or VolumeCluster AND DeltaCluster, or VolumeCluster OR DeltaCluster, as selected by the trigger-mode parameter
Calculation: BuySide = close >= open, or NetDelta > 0, or both (AND), as selected by the classification-mode parameter
Calculation: SellSide = close < open, or NetDelta < 0, or both (AND), as selected by the classification-mode parameter
Calculation: LastClusterSide = +1 if BuySide, -1 if SellSide, else 0, on the most recent bar where PrintCluster is true and carried forward to later bars; 0 before the first such bar
Calculation: CandleImbalance = sum over the last L bars of volume * (+1 if close >= open, else -1) / sum of volume over the last L bars
Calculation: CumDeltaBias = sum of NetDelta over the last L bars / max(sum of abs(NetDelta) over the last L bars, 1)
Calculation: AbsorptionBias = (sum of Absorption over the last L bars whose Profile bin midpoint < close - sum of Absorption over the last L bars whose Profile bin midpoint >= close) / max(sum of Absorption over the last L bars, 1)
Calculation: FlowScore = w1 * CandleImbalance + w2 * CumDeltaBias + w3 * AbsorptionBias + w4 * LastClusterSide
Calculation: FlowNorm(timeframe) = EMA(volume * (+1 if close >= open, else -1), N) / max(EMA(volume, N), 1), computed on bars of the timeframe
Calculation: ZoneDelta(Z) = sum of NetDelta over the last L bars whose Profile bin is the bin of Zone Z
Calculation: Zone = for each interior Profile bin i (0 < i < Nb - 1) with Signal[i] > Signal[i-1], Signal[i] >= Signal[i+1], Signal[i] > 0 and Strength[i] >= max(Smin, the Nz-th highest Strength over all such bins), the zone Z with Z.Low and Z.High = the bin's price edges, Z.Mid = their average, Z.Strength = Strength[i], Z.AbsorptionShare = AbsShare[i]; where Signal = a * VolShare + b * AbsShare, Strength = 10 * (wV * VolShare + wA * AbsShare + wT * min(Touches / TN, 1) + wR * RejShare + wC * (1 - min(Recency / L, 1))) / (wV + wA + wT + wR + wC), VolShare = sum of volume of bars assigned to the bin / max over bins, AbsShare = sum of Absorption of bars assigned to the bin / max over bins, RejShare = (bars whose upper wick exceeds half their range with high in the bin + bars whose lower wick exceeds half their range with low in the bin) / max over bins, Touches = bars whose low-to-high range overlaps the bin, Recency = bars back to the latest bar overlapping the bin (L if none)
Long: PrintCluster AND BuySide
Short: PrintCluster AND SellSide
Long: BuySide
Short: SellSide
Long: FlowScore > F
Short: FlowScore < -F
Long: FlowNorm(T2, last completed bar) > m
Long: FlowNorm(T3, last completed bar) > m
Long: FlowNorm(T4, last completed bar) > m
Short: FlowNorm(T2, last completed bar) < -m
Short: FlowNorm(T3, last completed bar) < -m
Short: FlowNorm(T4, last completed bar) < -m
Long: some Zone Z with Z.Strength < W AND Z.AbsorptionShare < H AND ZoneDelta(Z) > 0 AND FlowScore > F AND FlowNorm(T2, last completed bar) > m AND FlowNorm(T3, last completed bar) > m AND FlowNorm(T4, last completed bar) > m AND close crosses above Z.High AND DeltaCluster AND NetDelta > 0
Long: some Zone Z with Z.Strength < W AND Z.AbsorptionShare < H AND ZoneDelta(Z) > 0 AND FlowScore > F AND FlowNorm(T2, last completed bar) > m AND FlowNorm(T3, last completed bar) > m AND FlowNorm(T4, last completed bar) > m AND low <= Z.High AND close > Z.High
Short: some Zone Z with Z.Strength < W AND Z.AbsorptionShare < H AND ZoneDelta(Z) < 0 AND FlowScore < -F AND FlowNorm(T2, last completed bar) < -m AND FlowNorm(T3, last completed bar) < -m AND FlowNorm(T4, last completed bar) < -m AND close crosses below Z.Low AND DeltaCluster AND NetDelta < 0
Short: some Zone Z with Z.Strength < W AND Z.AbsorptionShare < H AND ZoneDelta(Z) < 0 AND FlowScore < -F AND FlowNorm(T2, last completed bar) < -m AND FlowNorm(T3, last completed bar) < -m AND FlowNorm(T4, last completed bar) < -m AND high >= Z.Low AND close < Z.Low
Short: some Zone Z with Z.Strength >= S_hi AND Z.AbsorptionShare >= H AND Z.Mid > close AND high >= Z.Low AND close > POC(Profile)
Long: some Zone Z with Z.Strength >= S_hi AND Z.AbsorptionShare >= H AND Z.Mid < close AND low <= Z.High AND close < POC(Profile)
Exit: short, high > Z.High for the Zone Z with the smallest Z.Mid above the entry price
Exit: short, low <= POC(Profile)
Exit: long, low < Z.Low for the Zone Z with the largest Z.Mid below the entry price
Exit: long, high >= POC(Profile)
Exit: long, close < Z.High for the Zone Z with the largest Z.Mid below the entry price
Exit: long, high >= VAH(Profile, V)
Exit: long, high >= Z.Low for the Zone Z with the smallest Z.Mid above the entry price
Exit: short, close > Z.Low for the Zone Z with the smallest Z.Mid above the entry price
Exit: short, low <= VAL(Profile, V)
Exit: short, low <= Z.High for the Zone Z with the largest Z.Mid below the entry price