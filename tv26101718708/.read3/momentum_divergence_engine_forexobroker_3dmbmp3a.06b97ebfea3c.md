Calculation: RSI = RSI(close, RSI lookback)
Calculation: Paired pivot lows = the latest two chart-bar events where pivotlow(low, left pivot lookback, right pivot lookback) and pivotlow(RSI, left pivot lookback, right pivot lookback) are both nonmissing; store both returned values and their pivot bars, right pivot lookback bars before each event
Calculation: Paired pivot highs = the latest two chart-bar events where pivothigh(high, left pivot lookback, right pivot lookback) and pivothigh(RSI, left pivot lookback, right pivot lookback) are both nonmissing; store both returned values and their pivot bars, right pivot lookback bars before each event
Calculation: Regular bullish divergence = regular divergence enabled AND a new paired pivot low is confirmed on the current chart bar AND current paired pivot-low price < previous paired pivot-low price AND current paired pivot-low RSI > previous paired pivot-low RSI AND current pivot bar - previous pivot bar <= maximum pivot spacing
Calculation: Hidden bullish divergence = hidden divergence enabled AND a new paired pivot low is confirmed on the current chart bar AND current paired pivot-low price > previous paired pivot-low price AND current paired pivot-low RSI < previous paired pivot-low RSI AND current pivot bar - previous pivot bar <= maximum pivot spacing
Calculation: Regular bearish divergence = regular divergence enabled AND a new paired pivot high is confirmed on the current chart bar AND current paired pivot-high price > previous paired pivot-high price AND current paired pivot-high RSI < previous paired pivot-high RSI AND current pivot bar - previous pivot bar <= maximum pivot spacing
Calculation: Hidden bearish divergence = hidden divergence enabled AND a new paired pivot high is confirmed on the current chart bar AND current paired pivot-high price < previous paired pivot-high price AND current paired pivot-high RSI > previous paired pivot-high RSI AND current pivot bar - previous pivot bar <= maximum pivot spacing
Calculation: Trend EMA = EMA(close, trend lookback)
Calculation: Volume average = SMA(volume, volume lookback)
Calculation: Bars since last composite signal = current chart bar index minus the chart bar index of the last composite bullish or bearish signal, initialized at chart bar index zero
Long: Regular bullish divergence
Long: Hidden bullish divergence
Long: close > Trend EMA
Short: Regular bearish divergence
Short: Hidden bearish divergence
Short: close <= Trend EMA
Long: (Regular bullish divergence OR hidden bullish divergence) AND current chart bar is confirmed AND volume > Volume average AND Bars since last composite signal >= cooldown AND (EMA trend filter disabled OR close <= Trend EMA * upper EMA multiplier)
Short: (Regular bearish divergence OR hidden bearish divergence) AND current chart bar is confirmed AND volume > Volume average AND Bars since last composite signal >= cooldown AND (EMA trend filter disabled OR close >= Trend EMA * lower EMA multiplier)