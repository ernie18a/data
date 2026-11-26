Calculation: RawBase = IF(use_rsi_base, RSI(source, rsi_len), source)
Calculation: Base = IF(use_roof, RoofingFilter(RawBase, roof_hp_len, roof_ss_len), RawBase)
Calculation: DomCycle = HomodyneDominantCycle(hl2, cycle_min, cycle_max)
Calculation: Lookback = IF(use_adapt_len, CLAMP(ROUND(DomCycle * adapt_mult), adapt_min, adapt_max), stoch_len)
Calculation: StochK(n) = IF(Highest(Hi, n) - Lowest(Lo, n) = 0, 50, 100 * (Val - Lowest(Lo, n)) / (Highest(Hi, n) - Lowest(Lo, n))), where (Hi, Lo, Val) = (high, low, source) if NOT use_rsi_base AND NOT use_roof, else (Base, Base, Base)
Calculation: Smooth(x, n) = IF(smooth_mode is SMA, SMA(x, n), IF(smooth_mode is 2-pole, SuperSmoother(x, n), UltimateSmoother(x, n)))
Calculation: KS = Smooth(IF(use_comp, (StochK(MAX(2, comp_short_mult * Lookback)) + StochK(Lookback) + StochK(comp_long_mult * Lookback)) / 3, StochK(Lookback)), k_smooth_len), where comp_short_mult < 1 < comp_long_mult
Calculation: DS = Smooth(KS, d_smooth_len)
Calculation: InverseFisher(x) = 50 * (1 + TANH(0.1 * (x - 50)))
Calculation: K = IF(use_ift, InverseFisher(KS), KS)
Calculation: D = IF(use_ift, InverseFisher(DS), DS)
Calculation: OB = Percentile(K, calib_len, ob_pct)
Calculation: OS = Percentile(K, calib_len, os_pct), where os_pct < ob_pct
Calculation: StreakUp = IF(K >= OB, StreakUp[1] + 1, 0)
Calculation: StreakDn = IF(K <= OS, StreakDn[1] + 1, 0)
Calculation: Detrended = HilbertDetrender(hl2, DomCycle)
Calculation: IsTrend = ADX(adx_len) > adx_thr AND EfficiencyRatio(source, er_len) > er_thr
Calculation: ClusterI = ClusterI[1] * EXP(-clust_decay) + ABS(LN(close / close[1]))
Calculation: IsRange = NOT IsTrend AND (ClusterI - SMA(ClusterI, norm_len)) / STDEV(ClusterI, norm_len) <= clust_thr
Calculation: Trail = OptimizedTrendTracker(VIDYA(K, trail_len), IF(vol_adapt_trail, CLAMP(trail_pct * STDEV(K, vol_window) / vol_ref, pct_min, pct_max), trail_pct))[2]
Calculation: TrailBull = VIDYA(K, trail_len) > Trail
Calculation: SnrOK = NOT use_snr OR STDEV(Detrended, norm_len) / ATR(atr_len) >= snr_min
Calculation: MtfSign(T) = SIGN(SMA(StochasticK(close, high, low, mtf_len), mtf_smooth) - 50), computed on bars of T, using the last completed T bar
Calculation: MtfBull = IF(use_mtf, (MtfSign(T1) > 0) + (MtfSign(T2) > 0) + (MtfSign(T3) > 0) + (MtfSign(T4) > 0), 0)
Calculation: MtfBear = IF(use_mtf, (MtfSign(T1) < 0) + (MtfSign(T2) < 0) + (MtfSign(T3) < 0) + (MtfSign(T4) < 0), 0)
Calculation: XaMom = IF(cross-asset feed present, SIGN(XaClose - XaClose[xa_len]) * xa_sign, 0), where XaClose is the cross-asset feed close on chart bars
Calculation: VarRatio = VarianceRatio(source, vr_len, norm_len)
Calculation: RangeFadeLong = IsRange AND StreakDn < embed_bars AND K[1] <= OS[1] AND K crosses above D AND (NOT use_phase OR (Detrended <= 0 AND Detrended >= Detrended[1])) AND SnrOK
Calculation: RangeFadeShort = IsRange AND StreakUp < embed_bars AND K[1] >= OB[1] AND K crosses below D AND (NOT use_phase OR (Detrended >= 0 AND Detrended < Detrended[1])) AND SnrOK
Calculation: TrendRideLong = IsTrend AND close > EMA(close, regime_ma_len) AND (VIDYA(K, trail_len) crosses above Trail OR (TrailBull AND K crosses above D AND K < 50)) AND SnrOK AND (NOT use_htf_gate OR MtfSign(T5) >= 0)
Calculation: TrendRideShort = IsTrend AND close <= EMA(close, regime_ma_len) AND (VIDYA(K, trail_len) crosses below Trail OR (NOT TrailBull AND K crosses below D AND K > 50)) AND SnrOK AND (NOT use_htf_gate OR MtfSign(T5) <= 0)
Calculation: Direction = IF(RangeFadeLong OR TrendRideLong, 1, IF(RangeFadeShort OR TrendRideShort, -1, 0))
Calculation: FadeSig = RangeFadeLong OR RangeFadeShort
Calculation: StretchScore = IF(FadeSig, IF(K >= OB, (K - OB) / MAX(100 - OB, 1), IF(K <= OS, (OS - K) / MAX(OS, 1), 0)), IF(TrailBull = (Direction > 0), 0.5 + 0.5 * MIN(1, MAX(StreakUp, StreakDn) / (2 * embed_bars)), 0.3))
Calculation: RegScore = IF(use_vr, IF(FadeSig, IF(VarRatio < 1, 1, 0.7), IF(VarRatio < 1, 0.8, 1)), 1)
Calculation: EmbScore = IF(FadeSig, IF(StreakUp >= embed_bars OR StreakDn >= embed_bars, 0.2, 1), IF((Direction > 0 AND StreakUp >= embed_bars) OR (Direction < 0 AND StreakDn >= embed_bars), 1, IF(TrailBull = (Direction > 0), 0.7, 0.4)))
Calculation: MtfScore = IF(FadeSig, 1 - ABS(MtfBull - MtfBear) / 4, IF(use_mtf, IF(Direction > 0, MtfBull, MtfBear) / 4, 0.5))
Calculation: DivScore = IF(FadeSig, IF((Direction > 0 AND BullDiv) OR (Direction < 0 AND BearDiv), 1, 0.4), IF((Direction > 0 AND HidBull) OR (Direction < 0 AND HidBear), 1, 0.5))
Calculation: VolScore = IF((cumulative volume = 0) OR volume > vol_mult * SMA(volume, vol_len), 1, 0.4)
Calculation: XaScore = IF(XaMom = Direction, 1, IF(cross-asset feed present, 0.4, 0.5))
Calculation: Conviction = IF(Direction = 0, 0, ROUND(100 * (w_stretch * StretchScore + w_reg * RegScore + w_emb * EmbScore + w_mtf * MtfScore + w_div * DivScore + w_vol * VolScore + w_xa * XaScore) / (w_stretch + w_reg + w_emb + w_mtf + w_div + w_vol + w_xa)))
Calculation: Veto = (FadeSig AND (VolIdx - SMA(VolIdx, vix_len)) / STDEV(VolIdx, vix_len) >= vix_spike_z) OR ((TrendRideLong OR TrendRideShort) AND ((use_mtf AND ((Direction > 0 AND MtfBull < min_align) OR (Direction < 0 AND MtfBear < min_align))) OR (XaMom <> 0 AND XaMom <> Direction))), where VolIdx is the volatility-index feed close
Calculation: PivotLowK = PivotLow(K, pivot_left, pivot_right)
Calculation: PivotHighK = PivotHigh(K, pivot_left, pivot_right)
Calculation: LastLowK = IF(PivotLowK is not NA, PivotLowK, LastLowK[1])
Calculation: PrevLowK = IF(PivotLowK is not NA, LastLowK[1], PrevLowK[1])
Calculation: LastLowPx = IF(PivotLowK is not NA, Low[pivot_right], LastLowPx[1])
Calculation: PrevLowPx = IF(PivotLowK is not NA, LastLowPx[1], PrevLowPx[1])
Calculation: LastHighK = IF(PivotHighK is not NA, PivotHighK, LastHighK[1])
Calculation: PrevHighK = IF(PivotHighK is not NA, LastHighK[1], PrevHighK[1])
Calculation: LastHighPx = IF(PivotHighK is not NA, High[pivot_right], LastHighPx[1])
Calculation: PrevHighPx = IF(PivotHighK is not NA, LastHighPx[1], PrevHighPx[1])
Calculation: BullDiv = PivotLowK is not NA AND LastLowPx < PrevLowPx AND LastLowK > PrevLowK
Calculation: HidBull = PivotLowK is not NA AND LastLowPx > PrevLowPx AND LastLowK < PrevLowK
Calculation: BearDiv = PivotHighK is not NA AND LastHighPx > PrevHighPx AND LastHighK < PrevHighK
Calculation: HidBear = PivotHighK is not NA AND LastHighPx < PrevHighPx AND LastHighK > PrevHighK
Long: RangeFadeLong
Long: TrendRideLong
Long: BullDiv
Long: HidBull
Long: VIDYA(K, trail_len) crosses above Trail
Long: Direction > 0 AND Conviction >= min_conv AND NOT Veto
Long: IsTrend AND close > EMA(close, regime_ma_len)
Long: MtfSign(T5) > 0
Long: TrailBull
Long: StreakUp >= embed_bars
Long: K >= 50
Short: RangeFadeShort
Short: TrendRideShort
Short: BearDiv
Short: HidBear
Short: VIDYA(K, trail_len) crosses below Trail
Short: Direction < 0 AND Conviction >= min_conv AND NOT Veto
Short: IsTrend AND close <= EMA(close, regime_ma_len)
Short: MtfSign(T5) < 0
Short: NOT TrailBull
Short: StreakDn >= embed_bars
Short: K < 50