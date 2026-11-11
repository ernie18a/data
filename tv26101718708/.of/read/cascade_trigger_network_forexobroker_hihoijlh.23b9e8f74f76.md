Calculation: Higher-timeframe bullish state = last completed higher-timeframe close > its EMA AND its EMA > that EMA a lookback ago.
Calculation: Higher-timeframe bearish state = last completed higher-timeframe close < its EMA AND its EMA < that EMA a lookback ago.
Calculation: Recent bullish trigger = chart-timeframe close crossed above its EMA AND chart-timeframe RSI was above its midpoint on a bar within the trigger window, including the current bar.
Calculation: Recent bearish trigger = chart-timeframe close crossed below its EMA AND chart-timeframe RSI was below its midpoint on a bar within the trigger window, including the current bar.
Calculation: Bullish cascade = recent bullish trigger AND bullish state on each of two higher timeframes, one longer than the other.
Calculation: Bearish cascade = recent bearish trigger AND bearish state on each of two higher timeframes, one longer than the other.
Calculation: Cascade score = the greater of the bullish and bearish counts of satisfied conditions among the recent trigger and the two higher-timeframe states, multiplied by a level weight, plus an RSI bonus if that count equals all three levels AND chart-timeframe RSI is above an upper threshold OR below a lower threshold; cap the result at a maximum score and round to the nearest integer.
Long: Recent bullish trigger.
Short: Recent bearish trigger.
Long: Bullish state on either higher timeframe.
Short: Bearish state on either higher timeframe.
Long: Chart-timeframe RSI > upper threshold.
Short: Chart-timeframe RSI < lower threshold.
Long: Bullish cascade AND cascade score >= background threshold.
Short: Bearish cascade AND cascade score >= background threshold.
Long: Bullish cascade AND previous chart bar's bullish cascade = false AND cascade score >= signal threshold AND bars since the last long or short cascade signal >= cooldown AND bearish cascade signal conditions = false.
Short: Bearish cascade AND previous chart bar's bearish cascade = false AND cascade score >= signal threshold AND bars since the last long or short cascade signal >= cooldown AND bullish cascade signal conditions = false.
Calculation: Before the first cascade signal, bars since the last long or short cascade signal = chart bar index, with the first chart bar indexed from zero.