Calculation: Merge(list, p, h) = with tol = zone_merge_k * ATR(atr_len) and half = zone_half_k * ATR(atr_len), if the first level M in list (front to back) with abs(p - M.mid) <= tol exists, set M.mid = (M.mid * M.touches + p) / (M.touches + 1), M.upper = max(M.upper, p + half), M.lower = min(M.lower, p - half), M.touches += 1, M.last_touch = bar count; otherwise insert at the front a level with mid p, upper p + half, lower p - half, touches 1, born = last_touch = bar count, htf = h, and if list then holds more than max_levels levels, drop its last level; then drop every level in list with bar count - last_touch > decay_bars
Calculation: SupportLevels = list state after this bar's updates: Merge(SupportLevels, p, false) for p = PivotLow(low, pivot_len, pivot_len) if confirmed on this bar; then Merge(SupportLevels, q, true) for q = PivotLow(low, htf_pivot_len, htf_pivot_len, T2, last completed bar) if use_htf_levels and q is available
Calculation: ResistanceLevels = list state after this bar's updates: Merge(ResistanceLevels, p, false) for p = PivotHigh(high, pivot_len, pivot_len) if confirmed on this bar; then Merge(ResistanceLevels, q, true) for q = PivotHigh(high, htf_pivot_len, htf_pivot_len, T2, last completed bar) if use_htf_levels and q is available
Calculation: Strength(L) = L.touches + (L.htf ? htf_weight : 0) + (bar count - L.born < recency_bars ? 1 : 0)
Calculation: Near(p, L) = abs(p - L.mid) <= prox_k * ATR(atr_len) OR (L.lower <= p AND p <= L.upper)
Calculation: Gate = bar count > warmup_bars AND (not use_chop OR Choppiness(chop_len) < chop_max) AND (not use_session OR bar time within session_window)
Calculation: Cooled = no earlier Long or Short entry OR bar count - last Long or Short entry bar count >= cooldown_bars
Calculation: BullTrend = EMA(close, shorter_bias_len, T1, last completed bar) > EMA(close, longer_bias_len, T1, last completed bar) AND close(T1, last completed bar) > EMA(close, shorter_bias_len, T1, last completed bar)
Calculation: BearTrend = EMA(close, shorter_bias_len, T1, last completed bar) < EMA(close, longer_bias_len, T1, last completed bar) AND close(T1, last completed bar) < EMA(close, longer_bias_len, T1, last completed bar)
Calculation: VolOk = not use_vol OR volume >= SMA(volume, vol_len) * vol_mult
Calculation: RangeOk = high - low >= range_frac * ATR(atr_len)
Calculation: DefendLong(L) = use_defend AND min(open, close) - low >= wick_min * (high - low) AND close > min(open, close) + body_frac * (high - low) AND close > L.lower
Calculation: SweepLong(L) = use_sweep AND low < L.lower - sweep_k * ATR(atr_len) AND close > L.mid AND close > open
Calculation: RetestLong(L) = use_retest AND close[k] < L.lower for some k in 1..retest_bars AND low <= L.upper AND close > L.mid AND close > open
Calculation: CoilLong(L) = use_coil AND TrueRange[k] <= coil_frac * ATR(atr_len) for all k in 0..coil_bars-1 AND Near(close, L) AND close > L.mid
Calculation: DefendShort(R) = use_defend AND high - max(open, close) >= wick_min * (high - low) AND close < max(open, close) - body_frac * (high - low) AND close < R.upper
Calculation: SweepShort(R) = use_sweep AND high > R.upper + sweep_k * ATR(atr_len) AND close < R.mid AND close < open
Calculation: RetestShort(R) = use_retest AND close[k] > R.upper for some k in 1..retest_bars AND high >= R.lower AND close < R.mid AND close < open
Calculation: CoilShort(R) = use_coil AND TrueRange[k] <= coil_frac * ATR(atr_len) for all k in 0..coil_bars-1 AND Near(close, R) AND close < R.mid
Calculation: LongLayers = M if M >= min_layers, else 0, where M = max over support levels L with (not use_htf_bias OR BullTrend) AND Strength(L) >= min_strength AND Near(low, L) AND (DefendLong(L) OR SweepLong(L) OR RetestLong(L) OR CoilLong(L)) of 4 + VolOk + RangeOk + (not DefendLong(L) AND (SweepLong(L) OR RetestLong(L)))
Calculation: ShortLayers = M if M >= min_layers, else 0, where M = max over resistance levels R with (not use_htf_bias OR BearTrend) AND Strength(R) >= min_strength AND Near(high, R) AND (DefendShort(R) OR SweepShort(R) OR RetestShort(R) OR CoilShort(R)) of 4 + VolOk + RangeOk + (not DefendShort(R) AND (SweepShort(R) OR RetestShort(R)))
Long: Gate AND Cooled AND LongLayers > 0 AND LongLayers >= ShortLayers
Short: Gate AND Cooled AND ShortLayers > LongLayers