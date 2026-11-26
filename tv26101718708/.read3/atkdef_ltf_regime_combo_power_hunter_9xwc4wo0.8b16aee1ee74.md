Calculation: short_ema = EMA(close, shorter EMA lookback)
Calculation: long_ema = EMA(close, longer EMA lookback)
Calculation: short_ema_slope = short_ema - short_ema[1]
Calculation: rsi = RSI(close, RSI lookback)
Calculation: atr_to_avg = ATR(ATR lookback) / SMA(ATR(ATR lookback), average lookback)
Calculation: band_width = BBW(close, bollinger lookback, bollinger multiplier)
Calculation: volume_to_avg = volume / SMA(volume, average lookback)
Calculation: abs_move = abs(ROC(close, 1))
Calculation: mean_abs_move = SMA(abs_move, velocity lookback)[1]
Calculation: bar_range = high - low
Calculation: range_to_avg = bar_range / SMA(bar_range, average lookback)
Calculation: candle_body = abs(close - open)
Calculation: body_to_range = candle_body / bar_range
Calculation: wick_total = (high - max(close, open)) + (min(close, open) - low)
Calculation: body_to_avg = candle_body / SMA(candle_body, body average lookback)[1]
Calculation: key_high = highest(high, key level lookback)
Calculation: key_low = lowest(low, key level lookback)
Calculation: pctl(src, n, k) = value at index floor(k * (n - 1) / 100) of src[0] through src[n - 1] sorted ascending
Calculation: band_width_pctl = pctl(band_width, percentile window, percentile rank)
Calculation: range_pctl = pctl(bar_range, percentile window, percentile rank)
Calculation: mean_move_impact = SMA(abs_move, impact average lookback)[1]
Calculation: bull_run_3 = close > open AND close[1] > open[1] AND close[2] > open[2]
Calculation: close_breaks_key = close > key_high[1] OR close < key_low[1]
Calculation: false_break = (high > key_high[1] OR low < key_low[1]) AND close <= key_high[1] AND close >= key_low[1]
Calculation: shrinking_3 = abs_move < abs_move[1] AND abs_move[1] < abs_move[2]
Calculation: direction_score = IF(close > short_ema AND short_ema > long_ema AND short_ema_slope > 0 AND close > high - bar_range * P1, P2, IF(close > short_ema AND short_ema > long_ema, P3, IF(close > short_ema AND short_ema < long_ema, P4, IF(close < short_ema AND short_ema > long_ema, P5, IF(close < short_ema AND short_ema < long_ema AND short_ema_slope < 0 AND close < low + bar_range * P1, P6, IF(close < short_ema AND short_ema < long_ema, P7, P8))))))
Calculation: momentum_score = IF(rsi >= P9 AND rsi > rsi[1] AND close > high[1], P16, IF(rsi >= P10 AND rsi < P9 AND rsi > rsi[1], P17, IF(rsi >= P11 AND rsi <= P10 AND abs_move < P15, P18, IF(rsi >= P12 AND rsi < P11 AND rsi < rsi[1], P19, IF(rsi >= P13 AND rsi < P12 AND rsi < rsi[1] AND close < low[1], P20, IF(rsi < P13 OR rsi > P14, P21, P22))))))
Calculation: velocity_score = IF(abs_move > mean_abs_move * P23 AND volume_to_avg > P24, P32, IF(abs_move > mean_abs_move * P25 AND volume_to_avg > P26, P33, IF(abs_move >= mean_abs_move * P28 AND abs_move <= mean_abs_move * P27, P34, IF(abs_move < mean_abs_move * P28 AND abs_move > mean_abs_move * P29, P35, IF(abs_move < mean_abs_move * P29 AND volume_to_avg < P30, P36, IF(abs_move < P31, P37, P38))))))
Calculation: behavior_score = IF(body_to_range > P39 AND wick_total < candle_body * P40, P47, IF(body_to_range > P41 AND wick_total < candle_body * P42, P48, IF(body_to_range >= P43 AND body_to_range <= P41, P49, IF(body_to_range >= P44 AND body_to_range < P43, P50, IF(body_to_range >= P45 AND body_to_range < P44, P51, IF(body_to_range < P45 AND wick_total > candle_body * P46, P52, P53))))))
Calculation: group_a_score = (direction_score + momentum_score + velocity_score + behavior_score) / 4
Calculation: game_score = IF((close > open AND close[1] < open[1] AND close[2] > open[2]) OR (close < open AND close[1] > open[1] AND close[2] < open[2]), P54, IF((close > open AND close[1] < open[1]) OR (close < open AND close[1] > open[1]), P55, IF(NOT bull_run_3, P56, IF(close[3] > open[3] AND close[4] > open[4], P58, P57))))
Calculation: hunting_score = IF(volume_to_avg > P59 AND ((high > key_high[1] AND close <= key_high[1]) OR (low < key_low[1] AND close >= key_low[1])), P63, IF((high > key_high[1] * P60 AND high < key_high[1]) OR (low < key_low[1] * P61 AND low > key_low[1]), P64, IF(volume_to_avg > P62 AND (close > key_high[1] OR close < key_low[1]), P65, P66)))
Calculation: squeeze_score = IF(band_width < band_width_pctl * P67 AND atr_to_avg < P72, P75, IF(band_width < band_width_pctl * P68 AND atr_to_avg < P73, P76, IF(band_width < band_width_pctl * P69 AND atr_to_avg < P74, P77, IF(band_width >= band_width_pctl * P69 AND band_width <= band_width_pctl * P70, P78, IF(band_width > band_width_pctl * P70 AND band_width < band_width_pctl * P71, P79, IF(band_width >= band_width_pctl * P71, P80, P81))))))
Calculation: destruction_score = IF(close_breaks_key AND body_to_avg > P82 AND volume_to_avg > P83, P87, IF(close_breaks_key AND body_to_avg > P84, P88, IF(close > key_high[1] * P85 OR close < key_low[1] * P86, P89, IF(false_break AND (close - open) * (close[1] - open[1]) < 0, P90, IF(false_break, P91, P92)))))
Calculation: group_b_score = (game_score + hunting_score + squeeze_score + destruction_score) / 4
Calculation: absorption_score = IF(range_to_avg > P93 AND abs_move < P94 AND volume_to_avg > P95, P104, IF(range_to_avg > P96 AND abs_move < P97 AND volume_to_avg > P98, P105, IF(range_to_avg > P99 AND abs_move < P100 AND volume_to_avg > P101, P106, IF(abs_move > P102 AND volume_to_avg > P103, P107, P108))))
Calculation: expansion_score = IF(range_to_avg > range_pctl * P109 AND volume_to_avg > P110, P117, IF(range_to_avg > range_pctl * P111 AND volume_to_avg > P112, P118, IF(range_to_avg > range_pctl * P113 AND volume_to_avg > P114, P119, IF(range_to_avg >= range_pctl * P115 AND range_to_avg <= range_pctl * P113, P120, IF(range_to_avg < range_pctl * P116, P121, P122)))))
Calculation: impact_score = IF(abs_move > mean_move_impact * P123 AND volume_to_avg > P124 AND close_breaks_key, P131, IF(abs_move > mean_move_impact * P125 AND volume_to_avg > P126, P132, IF(abs_move > mean_move_impact * P127 AND volume_to_avg > P128, P133, IF(abs_move < mean_move_impact * P129 AND volume_to_avg < P130, P134, P135))))
Calculation: decay_score = IF(shrinking_3 AND volume_to_avg < volume_to_avg[1] AND volume_to_avg[1] < volume_to_avg[2], P136, IF(shrinking_3, P137, IF(abs_move < abs_move[1] AND abs_move[1] > abs_move[2], P138, IF(NOT (abs_move > abs_move[1] AND abs_move[1] > abs_move[2]), P139, IF(volume_to_avg > volume_to_avg[1] AND volume_to_avg[1] > volume_to_avg[2], P141, P140)))))
Calculation: group_c_score = (absorption_score + expansion_score + impact_score + decay_score) / 4
Calculation: overall_score = (group_a_score + group_b_score + group_c_score) / 3
Long: group_a_score >= P142
Short: group_a_score < P143
Long: overall_score >= P144
Short: overall_score < P145