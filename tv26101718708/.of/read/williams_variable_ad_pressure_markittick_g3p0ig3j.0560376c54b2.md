Calculation: Raw pressure = (close - open) / (high - low) * volume, or zero when high equals low; pressure sum is its rolling sum over a configurable lookback.
Calculation: Filtered pressure = pressure sum, optionally smoothed with an SMA, EMA, RMA, HMA, two successive WMAs, three successive VWMAs, a slope-adjusted SMA, or a recursive estimator; successive averages use the same smoothing length.
Calculation: Slope-adjusted SMA = SMA of pressure sum plus (current pressure sum - pressure sum one smoothing length ago) / 2.
Calculation: Recursive estimator = initialize estimate to the first pressure sum and error to 1; on each bar set predicted error to error + 1 / smoothing length, gain to predicted error / (predicted error + 1), estimate to estimate + gain * (pressure sum - estimate), and error to (1 - gain) * predicted error.
Calculation: Signal average = SMA of filtered pressure over a configurable signal lookback; histogram = filtered pressure - signal average.
Calculation: Initial risk = ATR on the bar before the entry signal multiplied by a configurable stop multiplier; fix it at the signal. The entry reference is the close of the bar before the signal.
Long: On the previous chart bar, filtered pressure > signal average AND on the bar before that, filtered pressure <= signal average AND, if the ADX filter is enabled, previous chart bar ADX >= threshold AND, if higher-timeframe confirmation is enabled, last completed higher-timeframe close > its open.
Short: On the previous chart bar, filtered pressure < signal average AND on the bar before that, filtered pressure >= signal average AND, if the ADX filter is enabled, previous chart bar ADX >= threshold AND, if higher-timeframe confirmation is enabled, last completed higher-timeframe close < its open.
Long: Filtered pressure > signal average.
Short: Filtered pressure < signal average.
Long: Filtered pressure >= 0.
Short: Filtered pressure < 0.
Long: Histogram >= 0.
Short: Histogram < 0.
Long: Higher-timeframe confirmation is enabled AND last completed higher-timeframe close > its open.
Short: Higher-timeframe confirmation is enabled AND last completed higher-timeframe close < its open.
Exit: long, previous chart bar filtered pressure < signal average AND the bar before that filtered pressure >= signal average AND, if the ADX filter is enabled, previous chart bar ADX >= threshold AND, if higher-timeframe confirmation is enabled, last completed higher-timeframe close < its open.
Exit: short, previous chart bar filtered pressure > signal average AND the bar before that filtered pressure <= signal average AND, if the ADX filter is enabled, previous chart bar ADX >= threshold AND, if higher-timeframe confirmation is enabled, last completed higher-timeframe close > its open.
Exit: long, low <= entry reference - initial risk OR high >= entry reference + initial risk * any of three configurable target multipliers.
Exit: short, high >= entry reference + initial risk OR low <= entry reference - initial risk * any of three configurable target multipliers.