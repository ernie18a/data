Calculation: Compression = 100 - PercentRank(ATR(vol_len), rank_len)
Calculation: LoadScore = w_comp * Compression + w_conv * PercentRank(|Change(LogReturn(close), 1)|, rank_len) + w_eff * (100 - 100 * EfficiencyRatio(close, er_len)) + vol_on * PercentRank(|ImpliedVolIndex - RealizedVolRef|, rank_len) + basis_on * PercentRank(|Change(Basis, basis_len)|, rank_len)
Calculation: CoreLoadScore = LoadScore without its ImpliedVolIndex and Basis terms
Calculation: LoadPct = PercentRank(LoadScore, rank_len)
Calculation: CoreLoadPct = PercentRank(CoreLoadScore, rank_len)
Calculation: Basis = (derivative close - underlying close) / underlying close * 100, where the derivative close is the chart close if the chart is a derivative and the companion close otherwise, and the underlying close is the other one
Calculation: RealizedVolRef = VolForecast if vol_fcast_on and bar_index > vf_cal_len + vf_slow, else HistoricalVolatility(vol_len)
Calculation: VolForecast = max(0, b0 + b1 * F1 + b2 * sqrt(F2)), where b0, b1, b2 are the least-squares intercept and slopes of HistoricalVolatility(vol_len) regressed on F1 and sqrt(F2) over the last vf_cal_len bars, F1 = vf_w * EMA(LogReturn(close)[1], vf_fast) + (1 - vf_w) * EMA(LogReturn(close)[1], vf_slow), and F2 = vf_w * EMA(LogReturn(close)[1]^2, vf_fast) + (1 - vf_w) * EMA(LogReturn(close)[1]^2, vf_slow)
Calculation: CloudBias = +1 if close > max(SpanA, SpanB), -1 if close < min(SpanA, SpanB), 0 otherwise, with SpanA and SpanB evaluated ichi_displacement bars earlier, where SpanA = (Conversion + Base) / 2, SpanB = (Highest(high, ichi_long_len) + Lowest(low, ichi_long_len)) / 2, Conversion = (Highest(high, ichi_short_len) + Lowest(low, ichi_short_len)) / 2, and Base = (Highest(high, ichi_mid_len) + Lowest(low, ichi_mid_len)) / 2
Calculation: UpPts = w_break * (close > Highest(high, trig_len)[1]) + w_loc * ((close - low) >= (high - close)) + w_mom * (Change(close, rel_bars) >= 0)
Calculation: DnPts = w_break * (close < Lowest(low, trig_len)[1]) + w_loc * ((close - low) < (high - close)) + w_mom * (Change(close, rel_bars) < 0)
Calculation: Dir = +1 if UpPts >= DnPts, else -1
Calculation: RangeExpansion = Clamp(((high - low) / ATR(vol_len) - range_base) / range_scale, 0, 1)
Calculation: RunCount(Q) = consecutive bars, ending at the current bar, where Highest(Q, load_len) >= sig_pct AND RangeExpansion >= rel_thr; 0 otherwise
Calculation: ExpiryBar = bar weekday is expiry_weekday (if expiry_monthly, the next such weekday falls in another month) AND bar time is later than session_start
Calculation: BoxTop = Highest(high, box_len) on the first bar of the current run where Compression > comp_threshold
Calculation: Signal = RunCount(LoadPct) = confirm_bars AND bars since last Signal >= min_gap AND (NOT regime_filter_on OR (ExpiryBar AND NOT regime_gate_expiry) OR NOT (regime_on AND VarianceRatio(close, vr_k, vr_len) <= 1 - vr_band AND (NOT vr_sig_on OR LoMacKinlayZ(close, vr_k, vr_len) <= -vr_z))) AND (NOT ichi_filter_on OR (ExpiryBar AND NOT ichi_gate_expiry) OR (number of the four values CloudBias(chart), CloudBias(T6, last completed bar - ichi_lag), CloudBias(T7, last completed bar - ichi_lag), CloudBias(T8, last completed bar - ichi_lag) that equal Dir) >= min_agree)
Calculation: CoreSignal(T) = RunCount(CoreLoadPct) = confirm_bars AND bars since last CoreSignal >= min_gap, evaluated on bars of timeframe T
Calculation: CoreLong(T) = CoreSignal(T) AND Dir = +1, evaluated on bars of timeframe T
Calculation: CoreShort(T) = CoreSignal(T) AND Dir = -1, evaluated on bars of timeframe T
Long: Signal AND Dir = +1
Short: Signal AND Dir = -1
Long: LoadPct >= colour_pct AND close > EMA(close, vol_len)
Short: LoadPct >= colour_pct AND close <= EMA(close, vol_len)
Long: Compression[1] > comp_threshold AND Compression <= comp_threshold AND close > BoxTop
Short: Compression[1] > comp_threshold AND Compression <= comp_threshold AND close <= BoxTop
Long: CoreLong(T1, last completed bar - htf_lag) AND NOT CoreLong(T1, last completed bar - htf_lag)[1]
Short: CoreShort(T1, last completed bar - htf_lag) AND NOT CoreShort(T1, last completed bar - htf_lag)[1]
Long: CoreLong(T2, last completed bar - htf_lag) AND NOT CoreLong(T2, last completed bar - htf_lag)[1]
Short: CoreShort(T2, last completed bar - htf_lag) AND NOT CoreShort(T2, last completed bar - htf_lag)[1]
Long: CoreLong(T3, last completed bar - htf_lag) AND NOT CoreLong(T3, last completed bar - htf_lag)[1]
Short: CoreShort(T3, last completed bar - htf_lag) AND NOT CoreShort(T3, last completed bar - htf_lag)[1]
Long: CoreLong(T4, last completed bar - htf_lag) AND NOT CoreLong(T4, last completed bar - htf_lag)[1]
Short: CoreShort(T4, last completed bar - htf_lag) AND NOT CoreShort(T4, last completed bar - htf_lag)[1]
Long: CoreLong(T5, last completed bar - htf_lag) AND NOT CoreLong(T5, last completed bar - htf_lag)[1]
Short: CoreShort(T5, last completed bar - htf_lag) AND NOT CoreShort(T5, last completed bar - htf_lag)[1]