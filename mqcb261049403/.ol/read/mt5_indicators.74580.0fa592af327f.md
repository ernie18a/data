Calculation: VQ = (close − close n bars earlier) / n
Calculation: KD = close − the average close of the last n bars
Calculation: ED = the population standard deviation of closes over the last n bars
Calculation: PV = current VQ − previous VQ
Calculation: Raw KCI = the sum of the absolute rolling z-scores of VQ, KD, ED, and PV, using the same lookback for each
Calculation: KCI = 100 × exp(−c × Raw KCI), with positive sign when KD ≥ 0 and negative sign when KD < 0
Calculation: E = volume × (close − previous close)²
Long: KD ≥ 0 OR (Raw KCI at bar t < Raw KCI at the previous bar AND Raw KCI at bar t < Raw KCI at the next bar AND Raw KCI at bar t ≤ the compression threshold AND E at bar t < E at the previous bar AND close at bar t < close at the previous bar)
Short: KD < 0 OR (Raw KCI at bar t < Raw KCI at the previous bar AND Raw KCI at bar t < Raw KCI at the next bar AND Raw KCI at bar t ≤ the compression threshold AND E at bar t < E at the previous bar AND close at bar t ≥ close at the previous bar)