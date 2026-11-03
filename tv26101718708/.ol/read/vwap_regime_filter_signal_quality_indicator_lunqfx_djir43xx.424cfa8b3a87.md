Calculation: Rolling volume-weighted VWAP = sum(hlc3 × volume) / sum(volume) over a lookback
Calculation: Rolling volume-weighted standard deviation = square root of sum(volume × (hlc3 − rolling volume-weighted VWAP)²) / sum(volume) over the VWAP lookback
Calculation: Inner lower band = rolling volume-weighted VWAP − rolling volume-weighted standard deviation × inner-band multiplier
Calculation: Inner upper band = rolling volume-weighted VWAP + rolling volume-weighted standard deviation × inner-band multiplier
Calculation: Normalized VWAP velocity = smoothed rate of change of VWAP divided by rolling volume-weighted standard deviation
Calculation: Turbulence ratio = short-term standard deviation of normalized VWAP velocity / its longer-term average
Calculation: Normalized pressure = smoothed distance of hlc3 from VWAP divided by rolling volume-weighted standard deviation
Calculation: Bullish reversal candle = a bullish pin bar (lower wick > 2 × body and > half the candle range) OR a bullish engulfing candle (current close > open, previous close < open, current close > previous open, and current open ≤ previous close)
Calculation: Bearish reversal candle = a bearish pin bar (upper wick > 2 × body and > half the candle range) OR a bearish engulfing candle (current close < open, previous close > open, current close < previous open, and current open ≥ previous close)
Long: current hlc3 > inner lower band AND previous hlc3 ≤ previous inner lower band AND normalized pressure < negative oversold threshold AND turbulence ratio < calm threshold AND (bullish reversal candle on current or previous bar) AND bars since previous signal ≥ cooldown interval
Short: current hlc3 < inner upper band AND previous hlc3 ≥ previous inner upper band AND normalized pressure > overbought threshold AND turbulence ratio < calm threshold AND (bearish reversal candle on current or previous bar) AND bars since previous signal ≥ cooldown interval