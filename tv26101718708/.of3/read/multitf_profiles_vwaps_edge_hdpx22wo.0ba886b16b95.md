Calculation: RelVol = volume / SMA(volume, volume_lookback)
Calculation: CvdSign = sign(CVD - CVD[cvd_lookback]), where CVD = running sum since the start of the T1 period of volume x ((close - low) - (high - close)) / (high - low), 0 if high = low
Calculation: BullFrac = (close - low) / (high - low), neutral value if high = low
Calculation: BearFrac = (high - close) / (high - low), neutral value if high = low
Calculation: BodyFrac = |close - open| / (high - low), 0 if high = low
Calculation: touch(L, o) = high[o] >= L - tol AND low[o] <= L + tol, with L as of the current bar
Calculation: LevelTouch[o] = touch(L, o) for any L among POC, VAH, VAL of the current and all prior T1, T2 and T3 profiles, VWAP(T1), VWAP(T2), VWAP(NY session) while in the NY session, and IB high and IB low once the IB session has ended
Calculation: ZoneTouch[o] = touch(L, o) for any L among POC, VAH, VAL of the current and all prior T1, T2 and T3 profiles
Calculation: LocPriority[o] = 3 if touch(L, o) for any L among VWAP(T1), VWAP(T2), VWAP(NY session), POC(T1, current); else 2 if touch(L, o) for any L among VAH(T1, current), VAL(T1, current), POC(T2, current), IB high, IB low; else 1 if LevelTouch[o]; else 0
Calculation: PriorVA(T) = 2 if close > VAH(T, prior); else 1 if close > POC(T, prior); else -2 if close < VAL(T, prior); else -1 if close < POC(T, prior); else 0
Calculation: ProfileShape(T) = 0 if the current T profile has fewer than min_bins bins or zero range; else, with pos = (POC - low) / range and top, mid, bot = volume shares in the upper, middle and lower thirds of the range: 2 if pos >= tu_pos and mid <= tu_mid and top >= tu_top; else -2 if pos <= td_pos and mid <= td_mid and bot >= td_bot; else if peaks >= 2 and mid <= dd_mid and top >= dd_top and bot >= dd_bot: 1 if top > bot + dd_gap, -1 if bot > top + dd_gap, else 0; else 1 if top >= pb_top and bot <= pb_bot and pos >= pb_pos; else -1 if bot >= bb_bot and top <= bb_top and pos <= bb_pos; else 0; peaks = count of local maxima of the 3-bin smoothed volume profile that are at least pk_factor times both smoothed neighbours, at least pk_height times the largest bin, and at least pk_sep bins apart
Calculation: BiasTotal = ProfileShape(T1) + PriorVA(T1) + clip(ProfileShape(T2)) + clip(PriorVA(T2)), where clip(x) = 1 if x >= 2, -1 if x <= -2, else 0
Calculation: TrendBull = PriorVA(T1) >= 1 OR (PriorVA(T1) = 0 AND CvdSign > 0)
Calculation: TrendBear = PriorVA(T1) <= -1 OR (PriorVA(T1) = 0 AND CvdSign < 0)
Calculation: VwapZ = (close - VWAP(T1)) / SD, where SD = sqrt(sum(typical price^2 x volume) / sum(volume) - VWAP(T1)^2) over the T1 period, typical price = (high + low + close) / 3; VwapZ = 0 if the radicand is not positive
Calculation: InKillZone = bar time is inside the ET kill-zone windows
Calculation: InLevelCluster = close lies within a cluster box, a cluster being at least 2 LevelTouch levels with consecutive gaps within cluster_width
Calculation: SweepLow = low[1] < VAL(T1) - sweep_margin OR low[1] < POC(T1) - sweep_margin OR low[1] < VAL(T2) - sweep_margin
Calculation: SweepHigh = high[1] > VAH(T1) + sweep_margin OR high[1] > POC(T1) + sweep_margin OR high[1] > VAH(T2) + sweep_margin
Calculation: FailLow = close > VAL(T1) AND (close[1] < VAL(T1) OR close[2] < VAL(T1))
Calculation: FailHigh = close < VAH(T1) AND (close[1] > VAH(T1) OR close[2] > VAH(T1))
Calculation: StrongBull = close > open AND BodyFrac >= trig_body AND close > high[1]
Calculation: StrongBear = close < open AND BodyFrac >= trig_body AND close < low[1]
Calculation: LongBias = 3·I(PriorVA(T1) >= 2) + I(PriorVA(T1) = 1) + I(CvdSign > 0) + 2·I(close > VAH(T2)) + I(close > POC(T1) + accept_margin) + 2·I(FailLow) + I(close > VAH(T1) + accept_margin AND close[1] > VAH(T1) - tol), where I(x) = 1 if x is true else 0
Calculation: ShortBias = 3·I(PriorVA(T1) <= -2) + I(PriorVA(T1) = -1) + I(CvdSign < 0) + 2·I(close < VAL(T2)) + I(close < POC(T1) - accept_margin) + 2·I(FailHigh) + I(close < VAL(T1) - accept_margin AND close[1] < VAL(T1) + tol)
Calculation: BO_L = S if G and S >= max(floor_bc, min_pattern), else 0; G = close > VAH(T1) + accept_margin; S = 2 + 2·I(close[1] > VAH(T1) - tol) + I(BodyFrac >= disp_body) + I(|close - open| >= disp_atr x ATR) + I(RelVol >= vol_spike) + I(CvdSign > 0) + I(close > VAH(T2)) - 2·I(TrendBear)
Calculation: BO_S = S if G and S >= max(floor_bc, min_pattern), else 0; G = close < VAL(T1) - accept_margin; S = 2 + 2·I(close[1] < VAL(T1) + tol) + I(BodyFrac >= disp_body) + I(|close - open| >= disp_atr x ATR) + I(RelVol >= vol_spike) + I(CvdSign < 0) + I(close < VAL(T2)) - 2·I(TrendBull)
Calculation: CT_L = S if G and S >= max(floor_bc, min_pattern), else 0; G = TrendBull AND LevelTouch[1]; S = 2 + (2 if StrongBull, else I(close > open AND BullFrac >= frac_cont)) + 2·I(SweepLow) + I(VAL(T1) <= close <= VAL(T1) + cont_band) + I(CvdSign >= 0) + I(RelVol >= vol_min) + I(InKillZone) + I(InLevelCluster)
Calculation: CT_S = S if G and S >= max(floor_bc, min_pattern), else 0; G = TrendBear AND LevelTouch[1]; S = 2 + (2 if StrongBear, else I(close < open AND BearFrac >= frac_cont)) + 2·I(SweepHigh) + I(VAH(T1) - cont_band <= close <= VAH(T1)) + I(CvdSign <= 0) + I(RelVol >= vol_min) + I(InKillZone) + I(InLevelCluster)
Calculation: RV_L = S if G and S >= max(floor_rv, min_pattern), else 0; G = close[1] < VAL(T1) AND close[2] < VAL(T1) AND LevelTouch[1]; S = 2 + 2·I(SweepLow) + 2·I(StrongBull) + I(close > VAL(T1)) + I(CvdSign > 0) + I(InKillZone) + I(InLevelCluster) - I(TrendBear)
Calculation: RV_S = S if G and S >= max(floor_rv, min_pattern), else 0; G = close[1] > VAH(T1) AND close[2] > VAH(T1) AND LevelTouch[1]; S = 2 + 2·I(SweepHigh) + 2·I(StrongBear) + I(close < VAH(T1)) + I(CvdSign < 0) + I(InKillZone) + I(InLevelCluster) - I(TrendBull)
Calculation: MR_L = S if G and S >= max(floor_rv, min_pattern), else 0; G = (close < POC(T1) AND |close - POC(T1)| >= poc_far x ATR) OR VwapZ <= -sig_mid; S = 2 + 2·I(close > open AND BullFrac >= frac_mr) + I(StrongBull) + 2·I(RelVol >= vol_hi) + I(CvdSign > 0) + I(VwapZ <= -sig_hi)
Calculation: MR_S = S if G and S >= max(floor_rv, min_pattern), else 0; G = (close > POC(T1) AND |close - POC(T1)| >= poc_far x ATR) OR VwapZ >= sig_mid; S = 2 + 2·I(close < open AND BearFrac >= frac_mr) + I(StrongBear) + 2·I(RelVol >= vol_hi) + I(CvdSign < 0) + I(VwapZ >= sig_hi)
Calculation: FB_L = S if FailLow and S >= max(floor_rv, min_pattern), else 0; S = 3 + 2·I(SweepLow) + 2·I(StrongBull) + I(BodyFrac >= disp_body) + I(RelVol >= vol_spike) + I(CvdSign > 0) + I(InKillZone)
Calculation: FB_S = S if FailHigh and S >= max(floor_rv, min_pattern), else 0; S = 3 + 2·I(SweepHigh) + 2·I(StrongBear) + I(BodyFrac >= disp_body) + I(RelVol >= vol_spike) + I(CvdSign < 0) + I(InKillZone)
Calculation: SW_L = S if G and S >= max(floor_rv, min_pattern), else 0; G = SweepLow AND LevelTouch[1]; S = 4 + (2 if StrongBull, else I(close > open AND BullFrac >= frac_sweep)) + I(CvdSign >= 0) + I(RelVol >= vol_spike)
Calculation: SW_S = S if G and S >= max(floor_rv, min_pattern), else 0; G = SweepHigh AND LevelTouch[1]; S = 4 + (2 if StrongBear, else I(close < open AND BearFrac >= frac_sweep)) + I(CvdSign <= 0) + I(RelVol >= vol_spike)
Calculation: DP_L = S if G and S >= min_pattern, else 0; G = open[1] > close[1] AND close > (open[1] + close[1]) / 2; S = (4 if close > open[1], else 2) + I(LevelTouch[1]) + I(CvdSign > 0)
Calculation: DP_S = S if G and S >= min_pattern, else 0; G = open[1] < close[1] AND close < (open[1] + close[1]) / 2; S = (4 if close < open[1], else 2) + I(LevelTouch[1]) + I(CvdSign < 0)
Calculation: FG_L = S if G and S >= min_pattern, else 0; G = latest bullish fair value gap (low > high[2], top = low, bottom = high[2]) formed within fvg_age bars AND high[1] <= top AND low[1] >= bottom; S = 3 + 2·I(close > top) + I(CvdSign > 0)
Calculation: FG_S = S if G and S >= min_pattern, else 0; G = latest bearish fair value gap (high < low[2], top = low[2], bottom = high) formed within fvg_age bars AND low[1] >= bottom AND high[1] <= top; S = 3 + 2·I(close < bottom) + I(CvdSign < 0)
Calculation: AC_L = S if G and S >= min_pattern, else 0; G = close > VAH(T1) + accept_margin AND close[1] > VAH(T1) - tol; S = 3 + I(close[2] > VAH(T1) - tol) + I(CvdSign > 0)
Calculation: AC_S = S if G and S >= min_pattern, else 0; G = close < VAL(T1) - accept_margin AND close[1] < VAL(T1) + tol; S = 3 + I(close[2] < VAL(T1) + tol) + I(CvdSign < 0)
Calculation: RJ_L = S if G and S >= min_pattern, else 0; G = LevelTouch[1] AND high[1] > low[1] AND (close[1] - low[1]) >= wick_frac x (high[1] - low[1]) AND close > open; S = 2 + I(BullFrac >= frac_reject) + I(CvdSign > 0)
Calculation: RJ_S = S if G and S >= min_pattern, else 0; G = LevelTouch[1] AND high[1] > low[1] AND (high[1] - close[1]) >= wick_frac x (high[1] - low[1]) AND close < open; S = 2 + I(BearFrac >= frac_reject) + I(CvdSign < 0)
Calculation: BullSetup = max(BO_L, CT_L, RV_L, MR_L, FB_L, SW_L, DP_L, FG_L, AC_L, RJ_L)
Calculation: BearSetup = max(BO_S, CT_S, RV_S, MR_S, FB_S, SW_S, DP_S, FG_S, AC_S, RJ_S)
Calculation: MRIsBullSetup = MR_L > max(BO_L, CT_L, RV_L) AND MR_L >= max(FB_L, SW_L, DP_L, FG_L, AC_L, RJ_L)
Calculation: MRIsBearSetup = MR_S > max(BO_S, CT_S, RV_S) AND MR_S >= max(FB_S, SW_S, DP_S, FG_S, AC_S, RJ_S)
Calculation: ConfirmsLong = I(SW_L > 0) + I(StrongBull) + I(open[1] > close[1] AND close > (open[1] + close[1]) / 2) + I(FG_L > 0) + I(AC_L > 0) + I(RJ_L > 0) + I(FailLow)
Calculation: ConfirmsShort = I(SW_S > 0) + I(StrongBear) + I(open[1] < close[1] AND close < (open[1] + close[1]) / 2) + I(FG_S > 0) + I(AC_S > 0) + I(RJ_S > 0) + I(FailHigh)
Calculation: RiskLong = close - min(low[1], low[2], low[3])
Calculation: RiskShort = max(high[1], high[2], high[3]) - close
Calculation: ChaseLong = max(0, close - (VAL(T1) if SweepLow, else high[1]))
Calculation: ChaseShort = max(0, (VAH(T1) if SweepHigh, else low[1]) - close)
Calculation: RRLong = a level above close exists among LevelTouch levels excluding monthly ones AND (nearest such level - close) >= min_rr x RiskLong
Calculation: RRShort = a level below close exists among LevelTouch levels excluding monthly ones AND (close - nearest such level) >= min_rr x RiskShort
Calculation: TradeScore(Long) = trunc(min(2.5 x LongBias, 20)) + LocTerm + trunc(min(30 x ConfirmsLong / 4, 30)) + trunc(EntryTerm(RiskLong)), where LocTerm = 30 if LocPriority[1] >= 3, 20 if >= 2, 10 if >= 1, else 0, and EntryTerm(R) = 20 if R <= pref_stop; 0 if R <= 0 or R > max_stop; else 20 x (max_stop - R) / (max_stop - pref_stop)
Calculation: TradeScore(Short) = trunc(min(2.5 x ShortBias, 20)) + LocTerm + trunc(min(30 x ConfirmsShort / 4, 30)) + trunc(EntryTerm(RiskShort)), with the same LocTerm and EntryTerm
Calculation: NeedConfirmsLong = max(min_conf, 3 if TradeScore(Long) >= grade_A, 2 if >= grade_B, else 1) + I(ShortBias > LongBias + 1 AND ShortBias >= counter_bias)
Calculation: NeedConfirmsShort = max(min_conf, 3 if TradeScore(Short) >= grade_A, 2 if >= grade_B, else 1) + I(LongBias > ShortBias + 1 AND LongBias >= counter_bias)
Calculation: EarlyScore(side) = (2 if LocPriority[0] >= 3; 1 if LocPriority[0] = 2; else 0) + (1 if RelVol >= vol_early_hi; -1 if RelVol < vol_early_lo; else 0) + d·PriorVA(T1) + d·CvdSign + I(InKillZone) + 2·I(InLevelCluster), where d = +1 for Long and -1 for Short
Calculation: MidValue = VAL(T1) <= close <= VAH(T1) AND |close - VAH(T1)| > bound_atr x ATR AND |close - VAL(T1)| > bound_atr x ATR AND |close - POC(T1)| > bound_atr x ATR AND NOT LevelTouch[1]
Calculation: LongLatched = a confirmed Long fired since the last bar where LevelTouch[0] and LevelTouch[1] are both false
Calculation: ShortLatched = a confirmed Short fired since the last bar where LevelTouch[0] and LevelTouch[1] are both false
Calculation: EarlyLongLatched = an early Long fired since the last bar where LevelTouch[0] and LevelTouch[1] are both false
Calculation: EarlyShortLatched = an early Short fired since the last bar where LevelTouch[0] and LevelTouch[1] are both false
Calculation: LongGate = BullSetup > 0 AND min(10 x BullSetup, 100) >= min_setup AND ConfirmsLong >= NeedConfirmsLong AND LevelTouch[1] AND (LevelTouch[1] OR SweepLow OR |close - VWAP(T1)| <= vwap_near x ATR OR close < VAL(T1) - accept_margin OR (close < POC(T1) AND |close - POC(T1)| >= poc_far x ATR)) AND NOT (MidValue AND NOT MRIsBullSetup) AND last confirmed Long at least cooldown bars ago AND 0 < RiskLong <= max_stop AND ChaseLong <= max_chase AND RRLong
Calculation: ShortGate = BearSetup > 0 AND min(10 x BearSetup, 100) >= min_setup AND ConfirmsShort >= NeedConfirmsShort AND LevelTouch[1] AND (LevelTouch[1] OR SweepHigh OR |close - VWAP(T1)| <= vwap_near x ATR OR close > VAH(T1) + accept_margin OR (close > POC(T1) AND |close - POC(T1)| >= poc_far x ATR)) AND NOT (MidValue AND NOT MRIsBearSetup) AND last confirmed Short at least cooldown bars ago AND 0 < RiskShort <= max_stop AND ChaseShort <= max_chase AND RRShort
Long: LongGate AND NOT LongLatched
Long: ZoneTouch[0] AND BullFrac >= early_body AND PriorVA(T1) >= 0 AND CvdSign >= 0 AND EarlyScore(Long) >= min_early AND NOT EarlyLongLatched AND NOT (LongGate AND NOT LongLatched)
Long: BiasTotal >= bias_strong AND RelVol >= vol_go AND CvdSign >= 0
Short: ShortGate AND NOT ShortLatched
Short: ZoneTouch[0] AND BearFrac >= early_body AND PriorVA(T1) <= 0 AND CvdSign <= 0 AND EarlyScore(Short) >= min_early AND NOT EarlyShortLatched AND NOT (ShortGate AND NOT ShortLatched)
Short: BiasTotal <= -bias_strong AND RelVol >= vol_go AND CvdSign <= 0