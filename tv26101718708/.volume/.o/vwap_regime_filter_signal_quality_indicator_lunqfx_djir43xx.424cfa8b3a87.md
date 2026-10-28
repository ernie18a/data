Calculation: VWAP = rolling volume-weighted average of (high + low + close) / 3 on the current chart timeframe
Calculation: VWAP deviation = square root of the rolling volume-weighted mean squared distance of (high + low + close) / 3 from VWAP
Calculation: Inner lower band = VWAP − inner-band multiplier × VWAP deviation
Calculation: Inner upper band = VWAP + inner-band multiplier × VWAP deviation
Calculation: Outer lower band = VWAP − outer-band multiplier × VWAP deviation
Calculation: Outer upper band = VWAP + outer-band multiplier × VWAP deviation
Calculation: Pressure = EMA of ((high + low + close) / 3 − VWAP) / VWAP deviation
Calculation: Turbulence = standard deviation of normalized VWAP velocity over a shorter lookback divided by its simple moving average over a longer lookback; normalized VWAP velocity is the EMA of the 3-bar rate of change of VWAP divided by VWAP deviation
Long: (current (high + low + close) / 3 > current inner lower band AND previous (high + low + close) / 3 ≤ previous inner lower band) AND Pressure < −0.8 AND Turbulence < 0.8 AND (bullish pin bar or bullish engulfing pattern on current or previous bar) AND bars since previous signal ≥ cooldown
Short: (current (high + low + close) / 3 < current inner upper band AND previous (high + low + close) / 3 ≥ previous inner upper band) AND Pressure > 0.8 AND Turbulence < 0.8 AND (bearish pin bar or bearish engulfing pattern on current or previous bar) AND bars since previous signal ≥ cooldown
Exit: Long, low ≤ outer lower band OR high ≥ next target VWAP band
Exit: Short, high ≥ outer upper band OR low ≤ next target VWAP band