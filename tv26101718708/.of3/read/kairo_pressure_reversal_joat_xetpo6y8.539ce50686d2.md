Calculation: Bar range = max(high - low, minimum price increment)
Calculation: Pressure contribution = volume * (close-location weight * 2 * ((close - low) / bar range - 0.5) + close-to-open weight * (close - open) / bar range + wick-balance weight * ((min(open, close) - low) - (high - max(open, close))) / bar range)
Calculation: Smoothed pressure = EMA(if EMA(abs(pressure contribution), tensor lookback) > division epsilon then pressure contribution / EMA(abs(pressure contribution), tensor lookback) else 0, pressure smoothing lookback)
Calculation: Pressure curvature = smoothed pressure - 2 * smoothed pressure[1] + smoothed pressure[2]
Calculation: Pressure jerk = pressure curvature - pressure curvature[1]
Calculation: Directional certainty = 100 - clamp((-positive share * ln(positive share) - negative share * ln(negative share)) / ln(2) * 100, 0, 100), where positive share = safeDivide(Sum(max(pressure contribution, 0), entropy lookback), Sum(abs(pressure contribution), entropy lookback), 0.5), negative share = 1 - positive share, and zero-share entropy terms equal 0
Calculation: Impulse score = clamp(abs(smoothed pressure) * pressure scale + range percentile * range weight + directional certainty * certainty weight, 0, 100), where range percentile = PercentRank(bar range / close * 100, stress lookback), or 50 when unavailable
Calculation: Convexity score = clamp(abs(pressure curvature) * curvature weight + abs(pressure jerk) * jerk weight, 0, 100)
Calculation: Stress score = clamp(stress percentile * stress-rank weight + impulse score * impulse weight + convexity score * convexity weight, 0, 100), where stress percentile = PercentRank(ATR(ATR lookback) / close * 100, stress lookback), or 50 when unavailable
Calculation: Tensor basis = EMA(close, tensor lookback)
Calculation: Tensor skew = EMA(smoothed pressure, tensor lookback)
Calculation: Tensor width = ATR(ATR lookback) * (base width + stress score / width divisor)
Calculation: Upper tensor band = tensor basis + tensor width * (1 + max(tensor skew, 0) * skew expansion)
Calculation: Lower tensor band = tensor basis - tensor width * (1 + max(-tensor skew, 0) * skew expansion)
Long: bar is confirmed AND ((smoothed pressure > 0 AND stress score >= shock threshold AND pressure curvature > 0) OR (close < lower tensor band AND pressure curvature > 0 AND stress score >= reversion threshold))
Short: bar is confirmed AND ((smoothed pressure < 0 AND stress score >= shock threshold AND pressure curvature < 0) OR (close > upper tensor band AND pressure curvature < 0 AND stress score >= reversion threshold))