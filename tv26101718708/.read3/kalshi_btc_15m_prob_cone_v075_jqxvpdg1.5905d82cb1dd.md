Calculation: Target = SMA(close, N) of the previous chart bar, taken at the first chart bar of each T1 interval and held until the next such bar; if that SMA is undefined, Target keeps its previous value
Calculation: Ps = seconds from the current chart bar's open to the end of its T1 interval, truncated to whole seconds
Calculation: Remain = Ps rounded to the nearest multiple of Rs
Calculation: Sm[j] = SMA(close, N) on chart bars, read at the last completed T2 bar j samples ago
Calculation: Weight[j] = exp(-lambda * j) * Vw * Pw, where Vw = exp(-(Vm - V)^2 / (2 * (sigma * V / 100)^2)) if sigma * V > 0, else 1; Pw = exp(-(Pm - Ps)^2 / (2 * phi^2)) if phase weighting is enabled and phi > 0, else 1; Vm and Pm are the volume and Ps at the last completed T2 bar j samples ago; V is the current chart bar's volume
Calculation: Win(W, M) = {j : W <= j <= min(L - 1, W + M - 1), Sm[j] != 0, Weight[j] > 0}, empty unless L > W + G, where L is the number of recorded T2 samples
Calculation: Proj(H, j) = SMA(close, N) of the current chart bar * Sm[j - round(H / T2)] / Sm[j]
Calculation: ESS = (sum of Weight[j])^2 / (sum of Weight[j]^2), both over j in Win(round(Remain / T2), M_t); 0 if Target is undefined or Remain = 0
Calculation: ProbAbove = 100 * (sum of Weight[j] over j in Win(round(Remain / T2), M_t) with Proj(Remain, j) > Target) / (sum of Weight[j] over j in Win(round(Remain / T2), M_t))
Calculation: ConeMedian(H) = value at half the total weight of the piecewise-linear curve through (0, smallest Proj(H, j)) and (running sum of Weight[j], Proj(H, j)) for j in Win(round(H / T2), M_c) in ascending order of Proj(H, j); undefined if Win is empty
Calculation: TerminalMedian = ConeMedian(H) for the largest multiple H of C with H <= Remain at which ConeMedian(H) is defined; undefined if none
Long: ESS >= K AND TerminalMedian > Target
Short: ESS >= K AND TerminalMedian < Target
Long: SMA(close, N) > Target
Short: SMA(close, N) <= Target OR Target is undefined
Long: ESS >= K AND ProbAbove >= Q
Short: ESS >= K AND ProbAbove <= Q