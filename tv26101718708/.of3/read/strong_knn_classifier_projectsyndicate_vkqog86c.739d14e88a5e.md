Calculation: Zscore(x, n) = (x - SMA(x, n)) / STDEV(x, n) if STDEV(x, n) > 0, else 0
Calculation: Delta = sum over T1 bars i inside the current chart bar, excluding the first, of w_i * sign(close_i(T1) - close_(i-1)(T1)), where w_i = volume_i(T1) if volume weighting flag is on, else 1
Calculation: Imbalance = Delta / (sum of w_i over the same T1 bars), or 0 if that sum is 0
Calculation: Absorption = (Zscore(volume, normalisation length) if volume > absorption multiplier * SMA(volume, volume average length), else 0) / (1 + abs(close - open) / ATR(ATR length))
Calculation: CvdSlope = (CVD(Delta) - CVD(Delta)[CVD slope length]) / (CVD slope length * (SMA(volume, volume average length) + 1))
Calculation: Location = (close - VWAP(hlc3)) / ATR(ATR length)
Calculation: Feature1 = Zscore(Delta / (volume + 1), normalisation length)
Calculation: Feature2 = Zscore(Imbalance, normalisation length)
Calculation: Feature3 = Zscore(Absorption, normalisation length)
Calculation: Feature4 = Zscore(CvdSlope, normalisation length)
Calculation: Feature5 = Zscore(Location, normalisation length)
Calculation: SignedMove = (close - close[outcome horizon]) * sign(close[outcome horizon] - close[outcome horizon + trend reference length])
Calculation: Library = most recent max library size entries of (Feature1[outcome horizon], ..., Feature5[outcome horizon], label), appended on each bar where abs(SignedMove) > outcome threshold * ATR(ATR length)[outcome horizon], with label = CONT if SignedMove > 0, else REV
Calculation: LorentzianDistance(j) = sum over m = 1..5 of ln(1 + abs(Feature_m - Feature_m(j))), where Feature_m(j) is the m-th feature stored in library entry j
Calculation: Neighbours = the neighbour count k library entries with smallest LorentzianDistance(j)
Calculation: RevWeight = sum over j in Neighbours with label REV of exp(-LorentzianDistance(j) / distance temperature)
Calculation: ContWeight = sum over j in Neighbours with label CONT of exp(-LorentzianDistance(j) / distance temperature)
Calculation: ReversalProbability = 1 / (1 + exp(-probability sharpness * (RevWeight - ContWeight) / (RevWeight + ContWeight + prior strength)))
Calculation: Conviction = abs(ReversalProbability - 0.5) * 2
Calculation: NearStructure = (VWAP zone flag is on AND abs(close - VWAP(hlc3)) <= zone width * ATR(ATR length)) OR (pivot zone flag is on AND (abs(close - last confirmed PivotHigh(high, pivot length, pivot length)) <= zone width * ATR(ATR length) OR abs(close - last confirmed PivotLow(low, pivot length, pivot length)) <= zone width * ATR(ATR length)))
Long: library size >= min library size AND Conviction >= min conviction AND ReversalProbability <= 0.5
Long: library size >= min library size AND Conviction >= min conviction AND ReversalProbability <= 0.5 AND (zone requirement flag is off OR NearStructure) AND bars since last Long or Short signal > cooldown
Short: library size >= min library size AND Conviction >= min conviction AND ReversalProbability > 0.5
Short: library size >= min library size AND Conviction >= min conviction AND ReversalProbability > 0.5 AND (zone requirement flag is off OR NearStructure) AND bars since last Long or Short signal > cooldown