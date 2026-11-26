Calculation: log return = ln(close / close[1]) when both closes are positive, otherwise 0
Calculation: momentum evidence z = (average(EMA(log return, fast horizon), EMA(log return, slow horizon))) / (max(sqrt(EMA(log return², volatility lookback)), half minimum price increment / close) × sqrt((v_f + v_s + 2c) / 4)), where a_f = 2 / (fast horizon + 1), a_s = 2 / (slow horizon + 1), v_f = a_f / (2 − a_f), v_s = a_s / (2 − a_s), and c = a_f × a_s / (1 − (1 − a_f) × (1 − a_s)); use 0 if the denominator is not positive
Calculation: volume factor = 1 when volume confirmation is disabled; otherwise, retention + (1 − retention) × clamp(support / support divisor, 0, 1), where support = sign(z) × sum(w × sign(log return), slow horizon) / sum(w) × sqrt(sum(w)² / sum(w²)); w is volume capped at cap multiplier × its moving average over the volume-normalization lookback, or 1 per bar when volume is unavailable; use 0 support when a denominator is not positive
Calculation: trend score = clamp(EMA(sign(z) × tanh(min((abs(z) / sensitivity scale)^evidence exponent, exponent cap)) × volume factor, smoothing lookback), −1, 1)
Calculation: alert regime = on each ready, paintable chart bar, 1 if trend score ≥ strong-trend level, −1 if trend score ≤ −strong-trend level, 0 if abs(trend score) < strong-trend level − reset gap, otherwise the prior regime; retain the prior regime on other bars; initialize at 0
Long: trend score > indecision band AND bar index ≥ max(volatility lookback, startup multiplier × slow horizon) AND (confirmed-only mode is disabled OR the chart bar is confirmed)
Short: trend score < −indecision band AND bar index ≥ max(volatility lookback, startup multiplier × slow horizon) AND (confirmed-only mode is disabled OR the chart bar is confirmed)
Long: alert regime = 1 AND alert regime[1] ≠ 1
Short: alert regime = −1 AND alert regime[1] ≠ −1
Exit: long, alert regime = 0 AND alert regime[1] = 1
Exit: short, alert regime = 0 AND alert regime[1] = −1