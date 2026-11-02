Calculation: Drawdown = (running maximum close since the first bar − close) / running maximum close; maximum drawdown = highest drawdown over the risk lookback.
Calculation: Smoothed drawdowns = recursively smoothed drawdown and maximum drawdown, each initialized to its first available value and updated as previous value + alpha × (current value − previous value). Alpha is either a fixed EMA alpha or an increasing linear function of the percentile rank of close volatility; close volatility is standard deviation of close / SMA of close × 100.
Calculation: Risk-adjusted momentum = selected close momentum, using percentage rate of change, price difference, or log return × 100, multiplied by max(1 − risk scaling × smoothed drawdown / smoothed maximum drawdown, minimum risk factor).
Calculation: Acceleration = EMA of (risk-adjusted momentum − risk-adjusted momentum at the acceleration lookback), using the acceleration lookback as its EMA period; zero when leading mode is disabled.
Calculation: Oscillator = z-score of final momentum over the normalization lookback, clipped to symmetric upper and lower limits; use zero when the input or its mean or standard deviation is unavailable or the standard deviation is zero. Final momentum is risk-adjusted momentum when leading mode is disabled; otherwise it is a weighted sum of risk-adjusted momentum and acceleration, with the momentum weight greater than the acceleration weight and the weights summing to one.
Calculation: Signal = recursive smoothing of the oscillator, initialized to its first available value and updated as previous signal + alpha × (oscillator − previous signal). Alpha is either a fixed EMA alpha or an increasing linear function of the percentile rank of close volatility; its adaptive alpha bounds may differ from those for smoothed drawdowns.
Calculation: Upper and lower thresholds = either fixed upper and lower levels, respectively, or SMA of the oscillator over the normalization lookback plus and minus a positive multiplier times its standard deviation over that lookback.
Long: Oscillator crosses above signal AND oscillator > lower threshold AND smoothed drawdown < risk limit × smoothed maximum drawdown.
Long: Acceleration > 0 AND oscillator < signal AND oscillator > previous oscillator AND oscillator > lower threshold AND smoothed drawdown < risk limit × smoothed maximum drawdown.
Short: Oscillator crosses below signal AND oscillator < upper threshold.
Short: Acceleration < 0 AND oscillator > signal AND oscillator < previous oscillator AND oscillator < upper threshold.
Exit: long, oscillator crosses below signal OR oscillator > upper threshold.
Exit: short, oscillator crosses above signal OR oscillator < lower threshold.
Long: Oscillator < lower threshold AND oscillator < previous oscillator.
Short: Oscillator > upper threshold AND oscillator > previous oscillator.
Long: Low < previous low AND previous low < low two bars ago AND oscillator > previous oscillator AND previous oscillator > oscillator two bars ago.
Short: High > previous high AND previous high > high two bars ago AND oscillator < previous oscillator AND previous oscillator < oscillator two bars ago.
Long: Acceleration > 0.
Short: Acceleration < 0.
Long: Oscillator > signal AND oscillator > lower threshold.
Short: Oscillator < signal AND oscillator < upper threshold.
Long: Oscillator < 0 OR oscillator − signal >= 0.
Short: Oscillator > 0 OR oscillator − signal < 0.