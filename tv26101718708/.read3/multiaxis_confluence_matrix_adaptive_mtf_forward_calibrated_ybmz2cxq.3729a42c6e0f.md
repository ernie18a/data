Calculation: Vote_momentum = sign(MACDhist(close, fast, slow, signal)[1]), with fast < slow
Calculation: Grade_momentum = clamp(MACDhist(close, fast, slow, signal) / StdDev(MACDhist(close, fast, slow, signal), Zh) / g, -1, 1)[1]
Calculation: Vote_stretch = sign(close - EMA(close, F))[1]
Calculation: Grade_stretch = clamp((close - EMA(close, F)) / StdDev(close - EMA(close, F), Zs) / g, -1, 1)[1]
Calculation: CVD = CumSum(volume * (2 * NormalCDF((close - close[1]) / StdDev(close - close[1], J)) - 1))
Calculation: FlowResidual = CVD - EMA(CVD, Q)
Calculation: Vote_flow = sign(FlowResidual)[1]
Calculation: Grade_flow = clamp(FlowResidual / StdDev(FlowResidual, Q) / g, -1, 1)[1]
Calculation: FearDev = IV - EMA(IV, Vf), where IV is the close of an implied-volatility index
Calculation: Vote_fear = -sign(FearDev)[1]
Calculation: Grade_fear = clamp(-FearDev[1] / (ATR(Vf) * g), -1, 1), with ATR on chart bars
Calculation: LeaderGrade_i = clamp((close_i - close_i[Ll]) / StdDev(close_i - close_i[Ll], Zl) / g, -1, 1)[1], where close_i is the close of leader instrument i
Calculation: Grade_leader = sum over configured leaders i of s_i * w_i * LeaderGrade_i, divided by the sum of w_i over configured leaders
Calculation: Vote_leader = sign(Grade_leader)
Calculation: Score = sum over enabled axes a of Weight_a * Vote_a(T1, last completed bar), divided by the sum over enabled axes a of Weight_a
Calculation: GradedScore = sum over enabled axes a of Weight_a * Grade_a(T1, last completed bar), divided by the sum over enabled axes a of Weight_a
Calculation: ScoreLine = EMA(100 * (GradedScore if score mode is graded, else Score), Ls)
Calculation: Weight_a = wf + max(0, EdgeLB_a) if n_a >= S, else wf; for each enabled axis a
Calculation: EdgeLB_a = W_a / N_a - WilsonHalfWidth(W_a, N_a, zc) - B_a / n_a
Calculation: AxisEvent_a = on each confirmed chart bar, when enabled axis a has Vote_a(T1, last completed bar) != 0 and at least G bars have passed since axis a's previous event, open an event with direction Vote_a, entry close, risk unit ATR(K), and uniqueness u = 1 / (1 + number of open axis events)
Calculation: BarrierWin = 1 if the profit barrier (mp * risk unit, reached on the high for long or the low for short, measured from entry) is reached before the stop barrier (ms * risk unit, reached on the opposite extreme), with a bar reaching both counted as stop; else 0; an event resolves at its first barrier touch or H bars after entry
Calculation: BaseRate_d = cumulative mean of BarrierWin over resolved base events of direction d, or 0.5 if none; on each confirmed chart bar at least G bars after the previous base event, open one long and one short base event with entry close and risk unit ATR(K)
Calculation: on resolution of an axis event with direction d, uniqueness u, and win w: n_a += 1, N_a = lam * N_a + u, W_a = lam * W_a + u * w, B_a += BaseRate_d
Calculation: Warm = some enabled axis a has n_a >= S
Calculation: Conviction = round(abs(Score) * 100 * VolScale * EffScale), where VolScale = max(fv, 1 - sv * PercentRank(StdDev(close - close[1], V), V) / 100) and EffScale = max(fe, min(1, oe + KaufmanEfficiencyRatio(close, E)))
Calculation: BiasNet = sum over enabled axes a of Vote_a(T2, last completed bar), with T2 longer than T1
Calculation: LongAct = Score > 0 AND Conviction >= Cmin AND (number of enabled axes with Vote_a(T1, last completed bar) > 0) >= M AND BiasNet >= 0
Calculation: ShortAct = Score < 0 AND Conviction >= Cmin AND (number of enabled axes with Vote_a(T1, last completed bar) < 0) >= M AND BiasNet <= 0
Long: LongAct
Short: ShortAct
Calculation: BullDivergence = at bar t, ScoreLine(t-Rp) is the lowest of ScoreLine over bars t-Rp-Lp to t, and the most recent earlier bar b' with the same property satisfies (t-Rp) - b' <= D, ScoreLine(t-Rp) > ScoreLine(b'), and close(t-Rp) < close(b')
Calculation: BearDivergence = at bar t, ScoreLine(t-Rp) is the highest of ScoreLine over bars t-Rp-Lp to t, and the most recent earlier bar b' with the same property satisfies (t-Rp) - b' <= D, ScoreLine(t-Rp) < ScoreLine(b'), and close(t-Rp) > close(b')
Long: BullDivergence
Long: BullDivergence AND NOT (Score < 0 AND Conviction >= Cs)
Short: BearDivergence
Short: BearDivergence AND NOT (Score > 0 AND Conviction >= Cs)
Exit: long, Warm AND NOT LongAct AND NOT ShortAct AND Score * BiasNet >= 0
Exit: short, Warm AND NOT LongAct AND NOT ShortAct AND Score * BiasNet >= 0