Calculation: Baseline = NadarayaWatson(close, nw_len, nw_bw)
Calculation: Slope = Baseline - Baseline[1]
Calculation: Vel = AlphaBetaVelocity(close, ab_alpha, ab_beta)
Calculation: Mid = ALMA(close, alma_len, alma_off, alma_sig)
Calculation: ATR = ATR(atr_len)
Calculation: ATRMean = SMA(ATR, mean_len), with mean_len longer than atr_len
Calculation: ATRRel = ATR / ATRMean
Calculation: TrendFit = clamp(1 - STDEV(close - LinReg(close, fit_len, 0), fit_len) / STDEV(close, fit_len), 0, 1)
Calculation: ERFast = abs(KaufmanER(close, er_fast_len)), with er_fast_len shorter than er_slow_len
Calculation: R2Blend = r2_w * TrendFit + (1 - r2_w) * abs(KaufmanER(close, er_slow_len))
Calculation: Stretch = abs(close - Baseline) / ATR
Calculation: TrendStrength = tw_vel * abs(Vel) / ATR + tw_slope * abs(Slope) / ATR + tw_r2 * R2Blend
Calculation: DirScore = (dir_w * Vel + (1 - dir_w) * Slope) / ATR
Calculation: RegimeDir = DirScore > dir_dz ? 1 : (DirScore < -dir_dz ? -1 : 0)
Calculation: RegimeRun = (RegimeDir != 0 AND RegimeDir == RegimeDir[1]) ? RegimeRun[1] + 1 : (RegimeDir == 0 ? 0 : 1)
Calculation: RawState = (R2Blend >= cont_r2 AND Stretch <= max_stretch) ? 1 : ((R2Blend < chop_r2 OR Stretch > max_stretch) ? -1 : 0), with chop_r2 below cont_r2
Calculation: StateRun = RawState == RawState[1] ? StateRun[1] + 1 : 0
Calculation: MarketState = StateRun >= state_hold ? RawState : MarketState[1]
Calculation: CloseLoc = (close - low) / (high - low)
Calculation: HighBreak = Highest(high, brk_len)[1]
Calculation: LowBreak = Lowest(low, brk_len)[1]
Calculation: RangeExp = (high - low) / SMA(high - low, rng_len)
Calculation: Thrust = abs(close - close[1]) / ATR
Calculation: VolExp = volume / SMA(volume, vol_len)
Calculation: ContL = RegimeDir > 0 AND RegimeDir[1] > 0 AND close > HighBreak AND close > Baseline
Calculation: ContS = RegimeDir < 0 AND RegimeDir[1] < 0 AND close < LowBreak AND close < Baseline
Calculation: RevL = RegimeDir > 0 AND RegimeDir[1] <= 0 AND close > Baseline AND close > Mid
Calculation: RevS = RegimeDir < 0 AND RegimeDir[1] >= 0 AND close < Baseline AND close < Mid
Calculation: ReclaimL = ((close crosses above Baseline AND barssince(close crosses below Baseline) <= rc_bars) OR (close crosses above LowBreak AND barssince(close crosses below LowBreak) <= rc_bars)) AND CloseLoc > close_frac
Calculation: ReclaimS = ((close crosses below Baseline AND barssince(close crosses above Baseline) <= rc_bars) OR (close crosses below HighBreak AND barssince(close crosses above HighBreak) <= rc_bars)) AND (1 - CloseLoc) > close_frac
Calculation: F1 = 0.5 * (tanh(Vel / (featvel_k * ATR)) + 1)
Calculation: F2 = clamp(0.5 * (ATR - ATRMean) / (featz * STDEV(ATR, mean_len)) + 0.5, 0, 1)
Calculation: F3 = clamp(R2Blend - 0.5 * (F2 - 0.5), 0, 1)
Calculation: F4 = clamp(0.5 * (close - Baseline) / (feat_s * ATR) + 0.5, 0, 1)
Calculation: F5 = clamp(0.5 * (close - Mid) / (feat_s * ATR) + 0.5, 0, 1)
Calculation: Stored = last mem_M setups to mature; record i holds Dir_i (setup direction), Fk_i (k=1..5, Fk on the setup's entry bar), Term_i = ln(close / entry price) at maturity, MAE_i = max(0, max of Adv over bars after entry through maturity), Age_i = bars since maturity; Adv = ln(entry price / low) for a long setup, ln(high / entry price) for a short setup
Calculation: MemSize = count(Stored)
Calculation: SD_k (k=1..5) = (a setup i matures on this bar) ? max(sd_floor, (1 - diag_alpha) * SD_k[1] + diag_alpha * abs(Fk_i - 0.5)) : SD_k[1]; initial value sd_init
Calculation: RealMAE = (a setup i matures on this bar) ? (1 - diag_alpha) * RealMAE[1] + diag_alpha * MAE_i : RealMAE[1]; initial value mae_init
Calculation: Dist_i = sum over k=1..5 of ((Fk - Fk_i) / SD_k)^2, for records i in Stored with Dir_i = RegimeDir
Calculation: Nbr = up to nb_k records i with Dir_i = RegimeDir and smallest Dist_i
Calculation: Cnt = count(Nbr)
Calculation: W_i = exp(-recency_lambda * Age_i) / (sqrt(Dist_i) + dist_off), for i in Nbr
Calculation: MeanT = sum(W_i * Term_i) / sum(W_i) over Nbr, 0 if Cnt = 0
Calculation: TStd = sqrt(max(0, sum(W_i * Term_i^2) / sum(W_i) - MeanT^2)) over Nbr if Cnt > 1, else 0
Calculation: AvgDist = sum(sqrt(Dist_i)) / Cnt over Nbr
Calculation: Agreement = (MeanT > 0 ? count(Term_i > 0) : (MeanT < 0 ? count(Term_i < 0) : max(count(Term_i > 0), count(Term_i < 0)))) / Cnt over Nbr, 0 if Cnt = 0
Calculation: MeanM = sum(W_i * MAE_i) / sum(W_i) over Nbr, 0 if Cnt = 0
Calculation: StdRef = TStd > 0 ? (1 - diag_alpha) * StdRef[1] + diag_alpha * TStd : StdRef[1]; initial value std_init
Calculation: DistRef = Cnt > 0 ? (1 - diag_alpha) * DistRef[1] + diag_alpha * AvgDist : DistRef[1]; initial value dist_init
Calculation: MemReady = MemSize >= mem_min AND Cnt >= nb_min
Calculation: ConfNow = (min(1, Cnt / n_sat) * min(1, MemSize / (mem_mult * mem_min)) * (1 - min(1, TStd / StdRef)) * (1 - min(1, AvgDist / DistRef)) * Agreement)^(1/5)
Calculation: LiveConf = lc_w1 * clamp((TrendStrength - 0.5 * gate_thr) / (1.5 * gate_thr), 0, 1) + lc_w2 * (1 - clamp(Stretch / max_stretch, 0, 1)) + lc_w3 * clamp((ERFast - 0.5 * min_er) / (1 - 0.5 * min_er), 0, 1) + lc_w4 * clamp(lc_mix * R2Blend + (1 - lc_mix) * ERFast, 0, 1)
Calculation: MemFill = min(1, MemSize / (fill_mult * mem_min))
Calculation: SetupConfBase = MemReady ? (w_mem * ConfNow + (1 - w_mem) * LiveConf) : ((1 - MemFill) * LiveConf + MemFill * ConfNow)
Calculation: OpenWin = intraday equity bar whose time is within the first open_min minutes of the regular session
Calculation: SetupConf = SetupConfBase - (OpenWin ? open_pen : 0)
Calculation: DispTooHigh = MemReady AND MeanT != 0 AND TStd / abs(MeanT) > disp_max
Calculation: AgreeTooLow = MemReady AND Agreement < agree_min
Calculation: LiveZone = clamp(zone_k * ATR / close * sqrt(horizon), zone_min, zone_max)
Calculation: UseMemNow = MemReady AND ConfNow >= mem_conf AND ATRRel >= vol_lo AND ATRRel <= vol_hi AND NOT DispTooHigh AND NOT AgreeTooLow
Calculation: InvalMAE = UseMemNow ? max(MeanM, stop_m * RealMAE) : max(stop_l * LiveZone, max(RealMAE, zone_min))
Calculation: StopLevel = close * exp(-RegimeDir * InvalMAE), evaluated on the entry bar
Calculation: SinceEntry = barssince(Long OR Short)[1] + 1
Calculation: LongsActive = count of Long over the previous horizon-1 bars
Calculation: ShortsActive = count of Short over the previous horizon-1 bars
Long: RegimeDir > 0 AND RegimeRun >= reg_persist AND ATRRel >= vol_lo AND ATRRel <= vol_hi AND TrendStrength > gate_thr AND Stretch <= max_stretch AND ERFast >= min_er AND ((MarketState == 1 AND ContL) OR (MarketState == -1 AND (RevL OR ReclaimL))) AND (no prior entry OR SinceEntry >= cooldown) AND abs(Vel) > vel_atr * ATR AND Thrust >= thrust_min AND RangeExp >= rng_min AND (volume <= 0 OR VolExp >= vol_min) AND SetupConf >= conf_min AND NOT DispTooHigh AND NOT AgreeTooLow AND LongsActive < max_dir AND LongsActive + ShortsActive < max_pend
Short: RegimeDir < 0 AND RegimeRun >= reg_persist AND ATRRel >= vol_lo AND ATRRel <= vol_hi AND TrendStrength > gate_thr AND Stretch <= max_stretch AND ERFast >= min_er AND ((MarketState == 1 AND ContS) OR (MarketState == -1 AND (RevS OR ReclaimS))) AND (no prior entry OR SinceEntry >= cooldown) AND abs(Vel) > vel_atr * ATR AND Thrust >= thrust_min AND RangeExp >= rng_min AND (volume <= 0 OR VolExp >= vol_min) AND SetupConf >= conf_min AND NOT DispTooHigh AND NOT AgreeTooLow AND ShortsActive < max_dir AND LongsActive + ShortsActive < max_pend
Exit: long, low <= StopLevel of its entry AND bars since its entry <= horizon
Exit: short, high >= StopLevel of its entry AND bars since its entry <= horizon