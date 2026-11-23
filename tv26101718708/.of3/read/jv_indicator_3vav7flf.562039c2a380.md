Calculation: inversion_window = inv_window_T4 if chart timeframe <= T4 else inv_window_T5 if chart timeframe <= T5 else inv_window_rest
Calculation: inversion_candle = high - low > ATR(impulse_atr_len) * impulse_atr_mult AND abs(close - open) > (high - low) * doji_body_frac
Calculation: session_ok = (current bar time within core_session) OR ((current bar time within ext_session) AND ATR(vol_atr_len) > SMA(ATR(vol_atr_len), vol_avg_len) * vol_mult)
Calculation: smt_ok = (NOT smt_filter_enabled) OR (abs(ref_close - ref_high_T1[1]) / ref_high_T1[1] <= smt_pct / 100 OR abs(ref_close - ref_low_T1[1]) / ref_low_T1[1] <= smt_pct / 100); ref_close is the reference close of the current chart bar; T1[1] is the last completed T1 bar
Calculation: trend_liquidity = (count of i in 1..trend_lookback-1 where high[i] > high[i+1]) >= trend_min_count OR (count of i in 1..trend_lookback-1 where low[i] < low[i+1]) >= trend_min_count
Calculation: swing_low_level = low[2] if low[2] < low[3] AND low[2] < low[1] else swing_low_level[1]
Calculation: swing_high_level = high[2] if high[2] > high[3] AND high[2] > high[1] else swing_high_level[1]
Calculation: bull_poi = (top, bottom) = (low_T[0], high_T[2]) of the first T in (T1, T2, T3) with high_T[2] < low_T[0], else bull_poi[1]; T[0] is the still-forming current T bar
Calculation: bear_poi = (top, bottom) = (low_T[2], high_T[0]) of the first T in (T1, T2, T3) with low_T[2] > high_T[0], else bear_poi[1]; T[0] is the still-forming current T bar
Calculation: no_poi = NOT (bull_poi.bottom <= close <= bull_poi.top) AND NOT (bear_poi.bottom <= close <= bear_poi.top)
Calculation: bull_score = w_major * [bull_poi.bottom <= close <= bull_poi.top] + w_major * [exists k in 0..sweep_window: low[k] <= swing_low_level[k] AND close[k] > swing_low_level[k]] + w_minor * [session_ok] + w_minor * [smt_ok] + w_minor * [trend_liquidity]
Calculation: bear_score = w_major * [bear_poi.bottom <= close <= bear_poi.top] + w_major * [exists k in 0..sweep_window: high[k] >= swing_high_level[k] AND close[k] < swing_high_level[k]] + w_minor * [session_ok] + w_minor * [smt_ok] + w_minor * [trend_liquidity]
Calculation: bull_setup = inversion_candle AND (exists k in 0..inversion_window: low[k+2] > high[k] AND close > low[k+2]) AND bull_score >= min_score
Calculation: bear_setup = inversion_candle AND (exists k in 0..inversion_window: high[k+2] < low[k] AND close < high[k+2]) AND bear_score >= min_score
Calculation: bull_leg_open = (bull_leg_open[1] AND NOT bull_setup[1]) OR high > max(high[k] for k >= 1) OR no_poi
Calculation: bear_leg_open = (bear_leg_open[1] AND NOT bear_setup[1]) OR low < min(low[k] for k >= 1) OR no_poi
Long: bull_setup AND bull_leg_open
Short: bear_setup AND bear_leg_open