Calculation: ZScore(x) = (x - SMA(x, ZLen)) / STDEV(x, ZLen), or 0 when STDEV(x, ZLen) = 0
Calculation: Sigmoid(z) = 1 / (1 + e^(-z))
Calculation: RangeHigh = T1 pivot high (PivotLeft bars left, PivotRight bars right) computed on T1 bars and read from the last completed T1 bar, if defined and (RangeLow[1] undefined or pivot high > RangeLow[1]); otherwise RangeHigh[1]
Calculation: RangeLow = T1 pivot low (PivotLeft bars left, PivotRight bars right) computed on T1 bars and read from the last completed T1 bar, if defined and (RangeHigh undefined or pivot low < RangeHigh); otherwise RangeLow[1]
Calculation: RangeValid = RangeHigh > RangeLow
Calculation: PositionClamp = clamp((close - RangeLow) / (RangeHigh - RangeLow), 0, 1) when RangeValid, else 0
Calculation: PositionZ = ZScore(PositionClamp) when RangeValid, else 0
Calculation: DwellDensity = (number of the last DwellLen bars, current bar included, whose close is within (RangeHigh - RangeLow) / DwellBands of the current close) / DwellLen when RangeValid, else 0
Calculation: DwellZ = ZScore(DwellDensity) when RangeValid, else 0
Calculation: MomentumZ = ZScore(ROC(close, MomLen))
Calculation: TrainErr = (1 if ROC(close, LabelLen)[1] > 0, else 0) - Sigmoid(W0[1] + W1[1] × PositionZ[1] + W2[1] × DwellZ[1] + W3[1] × MomentumZ[1])
Calculation: W0 = W0[1] + LearnRate × TrainErr when bar index ≥ ZLen + LabelLen + 2, else 0
Calculation: W1 = W1[1] + LearnRate × (TrainErr × PositionZ[1] - L2 × W1[1]) when bar index ≥ ZLen + LabelLen + 2, else 0
Calculation: W2 = W2[1] + LearnRate × (TrainErr × DwellZ[1] - L2 × W2[1]) when bar index ≥ ZLen + LabelLen + 2, else 0
Calculation: W3 = W3[1] + LearnRate × (TrainErr × MomentumZ[1] - L2 × W3[1]) when bar index ≥ ZLen + LabelLen + 2, else 0
Calculation: PBull = Sigmoid(W0 + W1 × PositionZ + W2 × DwellZ + W3 × MomentumZ)
Calculation: LongState = bar index ≥ ZLen + LabelLen + TrainMin + 1 AND RangeValid AND RangeLow ≤ close ≤ (RangeHigh + RangeLow) / 2 - EqBand × (RangeHigh - RangeLow) AND PBull ≥ Threshold
Long: LongState
Long: LongState AND NOT LongState[1]
Calculation: ShortState = bar index ≥ ZLen + LabelLen + TrainMin + 1 AND RangeValid AND (RangeHigh + RangeLow) / 2 + EqBand × (RangeHigh - RangeLow) ≤ close ≤ RangeHigh AND 1 - PBull ≥ Threshold
Short: ShortState
Short: ShortState AND NOT ShortState[1]