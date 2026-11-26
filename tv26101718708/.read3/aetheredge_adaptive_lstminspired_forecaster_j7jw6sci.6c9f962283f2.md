Calculation: Z(x, n) = (x - SMA(x, n)) / STDEV(x, n)
Calculation: LnRet = LN(close / close[1])
Calculation: ReturnScale = STDEV(LnRet, Ns), Ns longer than Nz
Calculation: Htf(x, T) = x computed on T bars, last completed T bar value carried onto chart bars
Calculation: Ret1 = LN(Htf(close, T1) / Htf(close, T1)[1])
Calculation: Bias1 = (Htf(RSI(close, Nq), T1) - 50) / 50
Calculation: Gap2 = Htf(close, T2) - Htf(EMA(close, Ne), T2)
Calculation: Bias2 = SIGN(Gap2) * MIN(1, ABS(Gap2) / (Hm * ATR(Na)))
Calculation: F = [Z(LnRet, Nz), Z(ATR(Na) / close, Nv), RsiFeat, SlopeFeat, MomFeat, Ret1, Bias1, Bias2], Nz shorter than Nv, T1 shorter than T2
Calculation: Tau(u) = Tlo + Tsp * u / (Nh - 1)
Calculation: Pre(u, g) = SUM_{k=0..7}(F[k] * (Wa * SIN(Wb * u + Wc * k) + Wd * COS(We * (Wb * u + Wc * k)))) + Ba * SIN(Bb * u) + (g = forget ? Gf : g = output ? Go : 0)
Calculation: Mem(u) = (SIGMOID(Gs * Pre(u, forget)) * Tau(u) + (1 - Tau(u)) * Fb) * Mem(u)[1] + Lb * (1 + Mg * ABS(F[7])) * SIGMOID(Gs * Pre(u, input)) * TANH(Gc * Pre(u, cand)) + [ResOn] * [u < Nh / 2] * Rm * F[0] * (1 - Tau(u))
Calculation: MeanHidden = (1 / Nh) * SUM_{u=0..Nh-1}(SIGMOID(Gs * Pre(u, output)) * TANH(Mem(u)))
Calculation: AttnRet = SUM_{j=0..Nw-1}((EXP(s(j)) / SUM_{k=0..Nw-1}(EXP(s(k)))) * LnRet[j]), where s(j) = (MeanHidden * MeanHidden[j] - Sa * ABS(MeanHidden - MeanHidden[j])) * EXP(-j / (Sr * Nw)) / Tp
Calculation: Forecast = MAX(-Cl, MIN(Cl, Eh * MeanHidden * ReturnScale + [AttOn] * Ea * AttnRet + [ResOn] * Rm * Er * F[0] * ReturnScale))
Long: Forecast > Kt * ReturnScale AND (NOT AttOn OR AttnRet > 0)
Short: Forecast < -Kt * ReturnScale AND (NOT AttOn OR AttnRet < 0)
Long: Forecast crosses above 0
Short: Forecast crosses below 0
Long: Forecast > 0
Short: Forecast < 0