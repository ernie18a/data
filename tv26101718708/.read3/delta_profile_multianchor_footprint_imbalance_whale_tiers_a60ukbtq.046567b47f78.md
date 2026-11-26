Calculation: SignedVolume = sum over the T0 bars inside the bar of volume × sign(close − open) of each T0 bar
Calculation: ModifiedZ(x, N) = (x − median(x, N)) / (1.4826 × median(|x − median(x, N)|, N)), clamped to ±z bound, and 0 when the MAD is 0
Calculation: PressureZ = ModifiedZ(SignedVolume, standardization lookback)
Calculation: FlowZ(TF) = ModifiedZ(MFV, flow lookback) on bars of TF using the last completed bar of TF, where MFV = volume × CLV, CLV = ((close − low) − (high − close)) / (high − low), and CLV = 0 when high = low
Calculation: RungSign(TF) = +1 if FlowZ(TF) > neutral band, −1 if FlowZ(TF) < −neutral band, otherwise 0
Calculation: LadderAlignment = RungSign(chart bars) + RungSign(T1) + … + RungSign(Tn), with chart bars < T1 < … < Tn
Calculation: AlignThreshold = min(alignment threshold, 1 + n)
Calculation: FlowIndex = weighted mean of FlowZ over chart bars and T1…Tn, with weights rising with rung
Calculation: Conviction = 100 × |tanh(log-odds gain × FlowIndex / 2)| × Quality
Calculation: Quality = max(quality floor, quality blend × (1 − WeightedPenalty) + (1 − quality blend) × MinFactor)
Calculation: WeightedPenalty = weighted mean of (1 − ImpactFactor), (1 − VPINFactor), (1 − RegimeFactor), (1 − AbsorptionFactor), (1 − SizeFactor), (1 − LeadFactor) and (1 − LocationFactor), with per-factor penalty weights
Calculation: MinFactor = min(ImpactFactor, VPINFactor, RegimeFactor, AbsorptionFactor, SizeFactor, LeadFactor, LocationFactor)
Calculation: ImpactFactor = (1 + KyleR2) / 2
Calculation: KyleR2 = squared correlation of |SignedVolume| and |close − close[1]| over impact lookback
Calculation: VPIN = mean of the last toxicity bucket count of |sum of SignedVolume within bucket| / bucket size, where a bucket closes when its accumulated volume reaches bucket size = bucket multiple × SMA(volume, bucket average lookback)
Calculation: VPINPct = PercentRank(VPIN, VPIN percentile lookback)
Calculation: VPINFactor = toxic factor if VPINPct ≥ toxic percentile threshold, otherwise 1 − VPIN penalty × VPINPct / 100
Calculation: RegimeFactor = (1 + min(1, Efficiency ratio(close, regime lookback) / regime threshold)) / 2
Calculation: VolumeRatio = volume / average volume of the same time-of-day slot over prior sessions
Calculation: AbsorbTests = number of these four that hold: (a) |z| ≥ residual z threshold, where residual = (close − close[1]) − (intercept + slope × SignedVolume) from a rolling regression of (close − close[1]) on SignedVolume over absorption lookback, and z standardizes the residual over absorption lookback; (b) PercentRank(|SignedVolume| / (|close − close[1]| / tick size), absorption lookback) ≥ cost percentile threshold; (c) the larger of (buy dominance − buy result) and (sell dominance − sell result) ≥ dominance threshold, where Net = SignedVolume / volume, buy dominance = max(Net, 0), sell dominance = max(−Net, 0), buy result = (max(close − open, 0) / (high − low) + close location) / 2, sell result = (max(open − close, 0) / (high − low) + (1 − close location)) / 2, close location = (close − low) / (high − low); (d) PercentRank(VolumeRatio, absorption lookback) ≥ high-effort percentile AND PercentRank(high − low, absorption lookback) ≤ narrow-spread percentile
Calculation: Absorbing = AbsorbTests ≥ absorption agreement
Calculation: AbsorptionFactor = absorption factor if Absorbing, otherwise 1
Calculation: BigLotZ = ModifiedZ(BigLotDelta, big-lot lookback), where BigLotDelta = sum over the T0 bars inside the bar with volume ≥ big-lot multiple × mean T0 volume of volume × sign(close − open)
Calculation: BigLotAgainst = (LadderAlignment > 0 AND BigLotZ < −big-lot threshold) OR (LadderAlignment < 0 AND BigLotZ > big-lot threshold)
Calculation: SizeFactor = size factor if BigLotAgainst, otherwise 1
Calculation: LeadArea = EMA(area, smoothing), where area = (1 / W) × sum over the last W bars of (Xb × Yi − Yb × Xi), Xi = SignedVolume / stdev(SignedVolume, W), Yi = (close − close[1]) / stdev(close − close[1], W), and Xb and Yb are the running sums of Xi and Yi over the earlier bars of that window
Calculation: PriceLeads = LeadArea < 0 AND PercentRank(|LeadArea|, lead lookback) ≥ lead percentile threshold
Calculation: LeadFactor = lead factor if PriceLeads, otherwise 1
Calculation: AtValueNode = close is within node tolerance × ATR(ATR length) of the POC, VAH or VAL of the volume profile over the last profile lookback bars; the profile spreads each bar's volume evenly across the price bins its high-low range covers, POC is the highest-volume bin, the value area grows from POC toward the larger adjacent bin until it holds the value-area share of total volume, and VAH and VAL are its upper and lower bin edges
Calculation: LocationFactor = location factor if AtValueNode = false, otherwise 1
Calculation: ExhaustionPct = PercentRank(PressureZ, exhaustion lookback)
Calculation: CumDelta = running sum of SignedVolume, restarted at each new Td bar
Calculation: CumUpBreak = true at the first bar of a run where CumDelta has been above its upper band for at least confirmation bars in a row and at least channel cooldown bars have passed since the last channel break in either direction; upper band = linear regression of CumDelta over channel lookback + channel width × stdev of its regression residuals
Calculation: CumDnBreak = true at the first bar of a run where CumDelta has been below its lower band for at least confirmation bars in a row and at least channel cooldown bars have passed since the last channel break in either direction; lower band = linear regression of CumDelta over channel lookback − channel width × stdev of its regression residuals
Calculation: ChandeStop = stop value of a Chande volatility stop on close with distance d = trail multiplier × ATR(trail ATR length) on Tt, last completed bar; while up, stop = max(previous stop, close − d); while down, stop = min(previous stop, close + d)
Calculation: TrailUp = direction of the ChandeStop; it turns down when close < ChandeStop and up when close > ChandeStop, and on each turn the stop resets to close + d when turning down or close − d when turning up
Calculation: DivergenceBull = true when a confirmed pivot low (pivot length P) is lower than the previous confirmed pivot low while CumDelta at the pivot bar is higher than CumDelta at the previous pivot low bar
Calculation: DivergenceBear = true when a confirmed pivot high (pivot length P) is higher than the previous confirmed pivot high while CumDelta at the pivot bar is lower than CumDelta at the previous pivot high bar
Calculation: VolumePct = PercentRank(VolumeRatio, vsa lookback)
Calculation: SpreadPct = PercentRank(high − low, vsa lookback)
Calculation: Upthrust = high ≥ highest high of the prior K bars AND close location ≤ upthrust location AND VolumePct ≥ volume threshold
Calculation: Shakeout = low ≤ lowest low of the prior K bars AND close location ≥ shakeout location AND VolumePct ≥ volume threshold
Calculation: StoppingVolume = close < close[1] AND SpreadPct ≥ spread threshold AND VolumePct ≥ stopping volume threshold AND close location ≥ stopping location threshold
Calculation: WhalePrint = volume ≥ percentile of volume over the last whale lookback bars at the whale percentile
Calculation: LongFlipRaw = LadderAlignment ≥ AlignThreshold AND (speed filter off OR FlowIndex − FlowIndex[speed window] ≥ speed threshold) AND (HTF filter off OR (RungSign(Tn) ≥ 0 AND RungSign(Tn−1) ≥ 0)) AND Conviction ≥ conviction threshold AND the most recent LongFlipRaw or ShortFlipRaw occurred at least cooldown bars ago AND LadderAlignment < AlignThreshold at some bar since the most recent LongFlipRaw
Calculation: ShortFlipRaw = LadderAlignment ≤ −AlignThreshold AND (speed filter off OR FlowIndex − FlowIndex[speed window] ≤ −speed threshold) AND (HTF filter off OR (RungSign(Tn) ≤ 0 AND RungSign(Tn−1) ≤ 0)) AND Conviction ≥ conviction threshold AND the most recent LongFlipRaw or ShortFlipRaw occurred at least cooldown bars ago AND LadderAlignment > −AlignThreshold at some bar since the most recent ShortFlipRaw
Calculation: LongGate = (CVD gate off OR CumUpBreak occurred within the last confluence window bars) AND (toxicity suppression off OR VPINPct < toxic percentile threshold) AND MuteLong = false AND (sub-minute suppression off OR chart bar length ≥ minimum flip length)
Calculation: ShortGate = (CVD gate off OR CumDnBreak occurred within the last confluence window bars) AND (toxicity suppression off OR VPINPct < toxic percentile threshold) AND MuteShort = false AND (sub-minute suppression off OR chart bar length ≥ minimum flip length)
Calculation: MuteLong = state that becomes true when the mean trailing-exit R of the last N resolved long raw flips is below the mute floor with at least M resolved, becomes false when that mean is at or above the unmute ceiling, and otherwise keeps its value; always false when the edge gate is off; trailing-exit R of a long raw flip = (exit close − entry close) / (trail multiplier × ATR at entry), where the trail starts at entry close − trail multiplier × ATR at entry, ratchets up to the highest high since entry − trail multiplier × ATR, and exits at the first later bar with close ≤ trail or at the bar trail cap bars after entry
Calculation: MuteShort = state that becomes true when the mean trailing-exit R of the last N resolved short raw flips is below the mute floor with at least M resolved, becomes false when that mean is at or above the unmute ceiling, and otherwise keeps its value; always false when the edge gate is off; trailing-exit R of a short raw flip = (entry close − exit close) / (trail multiplier × ATR at entry), where the trail starts at entry close + trail multiplier × ATR at entry, ratchets down to the lowest low since entry + trail multiplier × ATR, and exits at the first later bar with close ≥ trail or at the bar trail cap bars after entry
Calculation: PlanStop = for a long entry, ChandeStop at the entry bar if TrailUp at the entry bar is true and that ChandeStop < entry price, otherwise entry price − stop barrier multiple × ATR(ATR length) at the entry bar; for a short entry, ChandeStop at the entry bar if TrailUp at the entry bar is false and that ChandeStop > entry price, otherwise entry price + stop barrier multiple × ATR(ATR length) at the entry bar
Calculation: PlanTarget = for a long entry, entry price + profit barrier multiple × TP2 multiple × ATR(ATR length) at the entry bar; for a short entry, entry price − profit barrier multiple × TP2 multiple × ATR(ATR length) at the entry bar
Long: PressureZ crosses above pressure threshold AND no earlier crossover above pressure threshold has occurred since the last bar where PressureZ ≤ 0 AND (regime gate is off OR (regime gate favours trending AND Efficiency ratio(close, regime lookback) ≥ regime threshold) OR (regime gate favours reverting AND Efficiency ratio(close, regime lookback) < regime threshold))
Short: PressureZ crosses below −pressure threshold AND no earlier crossover below −pressure threshold has occurred since the last bar where PressureZ ≥ 0 AND (regime gate is off OR (regime gate favours trending AND Efficiency ratio(close, regime lookback) ≥ regime threshold) OR (regime gate favours reverting AND Efficiency ratio(close, regime lookback) < regime threshold))
Long: PressureZ > bias threshold
Short: PressureZ < −bias threshold
Long: EMA(PressureZ, fast lookback) crosses above EMA(PressureZ, slow lookback), where slow lookback is longer than fast lookback
Short: EMA(PressureZ, fast lookback) crosses below EMA(PressureZ, slow lookback), where slow lookback is longer than fast lookback
Short: ExhaustionPct ≥ exhaustion percentile
Long: ExhaustionPct ≤ 100 − exhaustion percentile
Long: DivergenceBull = true
Short: DivergenceBear = true
Long: CumUpBreak = true
Short: CumDnBreak = true
Short: Upthrust = true
Long: Shakeout = true OR StoppingVolume = true
Long: WhalePrint = true AND close ≥ open
Short: WhalePrint = true AND close < open
Long: TrailUp = true AND TrailUp[1] = false
Short: TrailUp = false AND TrailUp[1] = true
Long: FlowZ(U) crosses above neutral band, for any stack timeframe U at or above the chart timeframe
Short: FlowZ(U) crosses below −neutral band, for any stack timeframe U at or above the chart timeframe
Long: LongGate = true AND, at the most recent bar where LongFlipRaw = true (within the last confluence window bars), ShortFlipRaw = false at every bar since that bar and LongGate = false at every bar from that bar to the previous bar
Short: ShortGate = true AND, at the most recent bar where ShortFlipRaw = true (within the last confluence window bars), LongFlipRaw = false at every bar since that bar and ShortGate = false at every bar from that bar to the previous bar
Exit: long, low ≤ PlanStop OR high ≥ PlanTarget
Exit: short, high ≥ PlanStop OR low ≤ PlanTarget