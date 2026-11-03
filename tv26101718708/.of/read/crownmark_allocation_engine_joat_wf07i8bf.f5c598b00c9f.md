Calculation: Source = a selectable price series derived from OHLC, defaulting to close.
Calculation: Efficiency = absolute source change over its lookback divided by the sum of absolute one-bar source changes over that lookback; use 0 when the denominator is zero.
Calculation: Regime score = 35 × signed range scaling of fast EMA(source) minus slow EMA(source) over the slow EMA lookback + 10 × clamp(z-score of the linear-regression slope of that EMA difference over the fast EMA lookback, using the volatility lookback, −2, 2) + sign of the EMA difference × [25 × clamp((ADX − 20) / 25, −1, 1) + 20 × clamp(2 × efficiency − 1, −1, 1) + 5 × clamp(z-score of volatility expansion over the volatility lookback, −2, 2)]. Volatility expansion = standard deviation of close divided by max(SMA of close, minimum price increment), using the same volatility lookback. Signed range scaling maps the lookback minimum to −1 and maximum to 1, or returns 0 for a zero range. A z-score returns 0 for zero standard deviation.
Calculation: Baseline = KAMA(source), with a shorter fast smoothing length and longer slow smoothing length. Its efficiency ratio is calculated over the baseline lookback; initialize the baseline to source and subsequently update it by (source − prior baseline) × [efficiency ratio × (2 / (fast length + 1) − 2 / (slow length + 1)) + 2 / (slow length + 1)]².
Calculation: Corridor width = width multiplier × (0.65 × ATR + 0.35 × standard deviation of source), with a shared width lookback. Upper and lower corridor = baseline ± corridor width; inner upper and lower corridor = baseline ± half the corridor width.
Calculation: Rolling VWAP = sum(typical price × volume) / sum(volume) over the auction lookback; use SMA of typical price over that lookback when the volume sum is zero. Typical price = (high + low + close) / 3. Auction upper and lower bounds = rolling VWAP ± auction width multiplier × standard deviation of typical price over the auction lookback.
Calculation: Pressure = EMA of 100 × relative volume × [0.40 × clamp((close − open) / range, −1, 1) + 0.35 × tanh(4 × (close − open) / ATR) + 0.25 × clamp((2 × close − low − high) / range, −1, 1)]. Range = max(high − low, minimum price increment); relative volume = volume / SMA(volume), or 1 when the denominator is zero; the body-to-ATR ratio is 0 when ATR is zero. Pressure signal = EMA of pressure with a longer smoothing length. Range z-score uses the volatility lookback.
Calculation: Divergence oscillator = EMA of 1.2 × (RSI(close) − 50) + rate of change of close, with separate RSI, rate-of-change, and smoothing lengths.
Calculation: Bearish divergence = a confirmed price-high pivot and oscillator-high pivot on the same pivot bar, where that price high is higher and oscillator high is lower than at the preceding jointly confirmed high pivots. Bullish divergence = a confirmed price-low pivot and oscillator-low pivot on the same pivot bar, where that price low is lower and oscillator low is higher than at the preceding jointly confirmed low pivots. Both use the same left and right pivot lookbacks. A divergence is recent from its confirmation bar until the number of bars since confirmation reaches the suppression-window length.
Long: Regime score > bullish regime threshold AND close > baseline AND baseline > prior baseline AND low ≤ inner upper corridor AND close > baseline − pullback tolerance × ATR AND close ≤ upper corridor AND (auction acceptance filter disabled OR auction lower bound ≤ close AND close ≤ auction upper bound) AND (VWAP filter disabled OR close ≥ rolling VWAP) AND pressure > positive pressure threshold AND pressure > pressure signal AND (expansion filter disabled OR range z-score > expansion threshold) AND (divergence guard disabled OR bearish divergence is not recent).
Short: Regime score < bearish regime threshold AND close < baseline AND baseline < prior baseline AND high ≥ inner lower corridor AND close < baseline + pullback tolerance × ATR AND close ≥ lower corridor AND (auction acceptance filter disabled OR auction lower bound ≤ close AND close ≤ auction upper bound) AND (VWAP filter disabled OR close ≤ rolling VWAP) AND pressure < negative pressure threshold AND pressure < pressure signal AND (expansion filter disabled OR range z-score > expansion threshold) AND (divergence guard disabled OR bullish divergence is not recent).
Long: Regime score > bullish regime threshold.
Short: Regime score < bearish regime threshold.
Long: Regime score ≥ 0.
Short: Regime score < 0.
Long: Close > baseline AND baseline > prior baseline.
Short: Close < baseline AND baseline < prior baseline.
Long: Close ≥ rolling VWAP.
Short: Close < rolling VWAP.
Long: Pressure > positive pressure threshold.
Short: Pressure < negative pressure threshold.
Long: Pressure ≥ 0.
Short: Pressure < 0.
Long: Bullish divergence is recent.
Short: Bearish divergence is recent.
Long: Pressure crosses above pressure signal.
Short: Pressure crosses below pressure signal.
Exit: Long, low ≤ max(entry price − stop multiplier × ATR, lower corridor − corridor stop offset × ATR, baseline − trailing multiplier × ATR) OR high ≥ entry price + target multiplier × ATR.
Exit: Short, high ≥ min(entry price + stop multiplier × ATR, upper corridor + corridor stop offset × ATR, baseline + trailing multiplier × ATR) OR low ≤ entry price − target multiplier × ATR.
Exit: Long, regime score < 0 OR pressure < 0 OR close < baseline OR bars since entry ≥ maximum trade duration OR bearish divergence is recent OR (opposite-signal exit enabled AND the complete short-entry condition is true).
Exit: Short, regime score > 0 OR pressure > 0 OR close > baseline OR bars since entry ≥ maximum trade duration OR bullish divergence is recent OR (opposite-signal exit enabled AND the complete long-entry condition is true).