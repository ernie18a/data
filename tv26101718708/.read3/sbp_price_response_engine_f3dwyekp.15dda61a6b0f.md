Calculation: SafeRatio(a, b) = b != 0 ? a / b : 0
Calculation: Bound(v, lo, hi) = MAX(lo, MIN(v, hi))
Calculation: Flag(x) = x ? 1 : 0
Calculation: BodyShare = SafeRatio(ABS(close - open), high - low)
Calculation: UpShadowShare = SafeRatio(high - MAX(open, close), high - low)
Calculation: LowShadowShare = SafeRatio(MIN(open, close) - low, high - low)
Calculation: CloseFromLow = SafeRatio(close - low, high - low)
Calculation: CloseFromHigh = SafeRatio(high - close, high - low)
Calculation: UsableVolume = volume > 0 AND SMA(volume, volume_avg_window) > 0
Calculation: EffVolume = UsableVolume ? volume : 1
Calculation: VolumeExpansion = NOT UsableVolume OR (volume / SMA(volume, volume_avg_window) >= volume_expansion_min)
Calculation: Center = VWMA(hlc3, structure_window)
Calculation: StructDev = MAX(STDEV(hlc3, structure_window), ATR(atr_window) * structure_dev_atr_floor)
Calculation: PartBias = Bound(SafeRatio(EMA(EffVolume * (CloseFromLow - 0.5) * 2, participation_window), EMA(EffVolume, participation_window)), -1, 1)
Calculation: DirEv = weight_part_bias * PartBias + weight_center_slope * Bound(SafeRatio(Center - Center[1], ATR(atr_window)), -1, 1) + weight_displacement * Bound(SafeRatio(close - Center, StructDev), -1, 1)
Calculation: DynControl = Center + StructDev * PartBias * control_bias_factor
Calculation: CtrlHalf = MAX(StructDev * control_half_dev_factor, ATR(atr_window) * control_half_atr_factor)
Calculation: ValueHalf = MAX(StructDev * value_half_dev_factor, ATR(atr_window) * value_half_atr_factor)
Calculation: SessionStart(x) = x evaluated on the chart bar that opens the current T1 period, held constant until the next T1 period begins
Calculation: SessCtrl = SessionStart(DynControl)
Calculation: SessUpper = SessionStart(DynControl + CtrlHalf)
Calculation: SessLower = SessionStart(DynControl - CtrlHalf)
Calculation: SessMean = EffVolume-weighted mean of hlc3 accumulated over chart bars from the start of the current T1 period through the current bar
Calculation: SessSecond = EffVolume-weighted mean of hlc3 * hlc3 accumulated over the same bars as SessMean
Calculation: EnvDist = MAX(envelope_dev_factor * SQRT(MAX(SessSecond - SessMean * SessMean, 0)), ATR(atr_window) * envelope_atr_floor)
Calculation: HighAnchor = cluster level of confirmed pivot highs P = PivotHigh(high, pivot_half_window, pivot_half_window): when P is defined, if HighAnchor exists and ABS(P - HighAnchor) <= cluster_tol_atr * ATR(atr_window) at the pivot bar, then HighAnchor = (HighAnchor * n + P) / (n + 1) and n = n + 1; otherwise HighAnchor = P and n = 1
Calculation: HighAnchorReady = HighAnchor exists AND (bar index - bar index of the most recent defined PivotHigh) <= max_anchor_age
Calculation: LowAnchor = cluster level of confirmed pivot lows P = PivotLow(low, pivot_half_window, pivot_half_window): when P is defined, if LowAnchor exists and ABS(P - LowAnchor) <= cluster_tol_atr * ATR(atr_window) at the pivot bar, then LowAnchor = (LowAnchor * n + P) / (n + 1) and n = n + 1; otherwise LowAnchor = P and n = 1
Calculation: LowAnchorReady = LowAnchor exists AND (bar index - bar index of the most recent defined PivotLow) <= max_anchor_age
Calculation: ChanSlope = SafeRatio(EMA(hlc3, short_ema_lookback) - EMA(hlc3, short_ema_lookback)[1], ATR(atr_window))
Calculation: ChanUp = DirEv >= channel_ev AND ChanSlope >= -channel_slope_tol AND close >= Center
Calculation: ChanDown = DirEv <= -channel_ev AND ChanSlope <= channel_slope_tol AND close <= Center
Calculation: UpMicroBreak = close > open AND close > highest(high[1], short_lookback)
Calculation: DownMicroBreak = close < open AND close < lowest(low[1], short_lookback)
Calculation: UpAccept = close > open AND close > Center + ValueHalf AND close > SessUpper AND DirEv >= accept_ev AND BodyShare >= accept_body AND CloseFromLow >= accept_close_share AND VolumeExpansion
Calculation: DownAccept = close < open AND close < Center - ValueHalf AND close < SessLower AND DirEv <= -accept_ev AND BodyShare >= accept_body AND CloseFromHigh >= accept_close_share AND VolumeExpansion
Calculation: UpReclaim = close > open AND low <= SessLower AND close > SessUpper AND DirEv >= reclaim_ev AND LowShadowShare > UpShadowShare AND BodyShare >= reclaim_body
Calculation: DownReclaim = close < open AND high >= SessUpper AND close < SessLower AND DirEv <= -reclaim_ev AND UpShadowShare > LowShadowShare AND BodyShare >= reclaim_body
Calculation: UpTurn = low < lowest(low[1], medium_lookback) AND close > lowest(low[1], medium_lookback) AND UpMicroBreak AND DirEv >= turn_ev AND close > SessCtrl AND VolumeExpansion
Calculation: DownTurn = high > highest(high[1], medium_lookback) AND close < highest(high[1], medium_lookback) AND DownMicroBreak AND DirEv <= -turn_ev AND close < SessCtrl AND VolumeExpansion
Calculation: FlowBalance = SafeRatio(X - Y, X + Y), where X = SMA(EffVolume * CloseFromLow, flow_window) and Y = SMA(EffVolume * CloseFromHigh, flow_window)
Calculation: FlowShift = FlowBalance - FlowBalance[1]
Calculation: TrendChange = EMA(close, long_ema_lookback) - EMA(close, long_ema_lookback)[trend_slope_lag]
Calculation: AdaptiveLine = KAMA(close, kama_efficiency_window, shorter_smoothing_lookback, longer_smoothing_lookback)
Calculation: UpFlowSweep = low < lowest(low[1], long_lookback) AND close > lowest(low[1], long_lookback) AND CloseFromLow >= flow_sweep_close_share
Calculation: DownFlowSweep = high > highest(high[1], long_lookback) AND close < highest(high[1], long_lookback) AND CloseFromHigh >= flow_sweep_close_share
Calculation: UpRejection = MIN(open, close) - low >= rej_wick_factor * MAX(ABS(close - open), minimum price increment) AND CloseFromLow >= rej_close_share
Calculation: DownRejection = high - MAX(open, close) >= rej_wick_factor * MAX(ABS(close - open), minimum price increment) AND CloseFromHigh >= rej_close_share
Calculation: UpInitiative = VolumeExpansion AND close > open AND ABS(close - open) >= ATR(atr_window) * init_body_atr AND CloseFromLow >= init_close_share
Calculation: DownInitiative = VolumeExpansion AND close < open AND ABS(close - open) >= ATR(atr_window) * init_body_atr AND CloseFromHigh >= init_close_share
Calculation: UpScore = w_flow_balance * Flag(FlowBalance >= flow_balance_thr) + w_flow_shift * Flag(FlowShift >= flow_shift_thr) + w_flow_sweep * Flag(UpFlowSweep) + w_rejection * Flag(UpRejection) + w_initiative * Flag(UpInitiative) + w_adaptive * Flag(close > AdaptiveLine AND AdaptiveLine > AdaptiveLine[1]) + w_trend * Flag(TrendChange > 0) + w_micro * Flag(UpMicroBreak) + w_channel * Flag(ChanUp)
Calculation: DownScore = w_flow_balance * Flag(FlowBalance <= -flow_balance_thr) + w_flow_shift * Flag(FlowShift <= -flow_shift_thr) + w_flow_sweep * Flag(DownFlowSweep) + w_rejection * Flag(DownRejection) + w_initiative * Flag(DownInitiative) + w_adaptive * Flag(close < AdaptiveLine AND AdaptiveLine < AdaptiveLine[1]) + w_trend * Flag(TrendChange < 0) + w_micro * Flag(DownMicroBreak) + w_channel * Flag(ChanDown)
Calculation: UpSupport = chart timeframe is shorter than T1 AND UpScore >= score_min AND UpScore >= DownScore + score_margin AND (UpFlowSweep OR UpInitiative OR (UpRejection AND FlowShift > 0))
Calculation: DownSupport = chart timeframe is shorter than T1 AND DownScore >= score_min AND DownScore >= UpScore + score_margin AND (DownFlowSweep OR DownInitiative OR (DownRejection AND FlowShift < 0))
Calculation: UpCore = UpAccept OR UpReclaim OR UpTurn
Calculation: DownCore = DownAccept OR DownReclaim OR DownTurn
Calculation: UpVotes = core_vote_w * (Flag(UpAccept) + Flag(UpReclaim) + Flag(UpTurn)) + Flag(UpSupport) + Flag(ChanUp) + Flag(DirEv >= vote_ev)
Calculation: DownVotes = core_vote_w * (Flag(DownAccept) + Flag(DownReclaim) + Flag(DownTurn)) + Flag(DownSupport) + Flag(ChanDown) + Flag(DirEv <= -vote_ev)
Calculation: UpCandidate = close > open AND NOT ChanDown AND NOT (HighAnchorReady AND high >= HighAnchor AND close < HighAnchor) AND NOT (high >= SessMean + EnvDist AND close < SessMean + EnvDist AND UpShadowShare >= envelope_wick_share) AND (NOT HighAnchorReady OR close > HighAnchor OR HighAnchor - close >= ATR(atr_window) * room_atr_factor) AND ((UpAccept AND DirEv >= strong_ev AND BodyShare >= strong_body) OR (UpVotes >= higher_vote_threshold AND UpCore) OR (UpVotes >= lower_vote_threshold AND UpCore AND UpSupport))
Calculation: DownCandidate = close < open AND NOT ChanUp AND NOT (LowAnchorReady AND low <= LowAnchor AND close > LowAnchor) AND NOT (low <= SessMean - EnvDist AND close > SessMean - EnvDist AND LowShadowShare >= envelope_wick_share) AND (NOT LowAnchorReady OR close < LowAnchor OR close - LowAnchor >= ATR(atr_window) * room_atr_factor) AND ((DownAccept AND DirEv <= -strong_ev AND BodyShare >= strong_body) OR (DownVotes >= higher_vote_threshold AND DownCore) OR (DownVotes >= lower_vote_threshold AND DownCore AND DownSupport))
Long: position side is not long AND UpCandidate AND (NOT DownCandidate OR DirEv > 0)
Long: position side is short AND ChanUp AND NOT ChanUp[1]
Short: position side is not short AND DownCandidate AND NOT (UpCandidate AND DirEv >= 0)
Short: position side is long AND ChanDown AND NOT ChanDown[1]