Calculation: Bullish trend score = count of true conditions: close > long-term EMA; medium-term EMA > long-term EMA; short-term EMA > medium-term EMA; positive directional indicator > negative directional indicator. Bearish trend score = count of the corresponding reversed inequalities.
Calculation: Confirmed pivot = a high or low with the same number of bars on each side; it becomes available after the right-side bars complete. Price and RSI pivots use the same lookback.
Calculation: Paired pivot = a price pivot and an RSI pivot of the same high or low type confirmed on the same bar. Compare each paired pivot with the preceding paired pivot of that type, including pairs that did not produce a divergence signal.
Calculation: Higher-timeframe bullish bias = higher-timeframe close > both higher-timeframe medium-term and long-term EMAs. Bearish bias reverses both inequalities. Use the last completed higher-timeframe bar; EMA lengths match the corresponding chart-timeframe EMAs.
Long: Bullish trend score >= trend threshold OR bullish trend score = two conditions AND bearish trend score < trend threshold.
Short: Bullish trend score < trend threshold AND bearish trend score >= trend threshold OR bullish trend score < trend threshold AND bullish trend score != two conditions AND bearish trend score = two conditions.
Long: Higher-timeframe bullish bias.
Short: Higher-timeframe bearish bias.
Long: Bullish trend score >= trend threshold AND ADX > quality threshold AND RSI > lower neutral threshold AND RSI < upper neutral threshold AND higher-timeframe bullish bias AND bars since the preceding long quality signal > cooldown.
Short: Bearish trend score >= trend threshold AND ADX > quality threshold AND RSI > lower neutral threshold AND RSI < upper neutral threshold AND higher-timeframe bearish bias AND bars since the preceding short quality signal > cooldown.
Long: Paired low price pivot < preceding paired low price pivot AND paired low RSI pivot > preceding paired low RSI pivot AND bars since the preceding long divergence signal > the same cooldown used for quality signals.
Short: Paired high price pivot > preceding paired high price pivot AND paired high RSI pivot < preceding paired high RSI pivot AND bars since the preceding short divergence signal > the same cooldown used for quality signals.
Long: Bars since the last long divergence signal < divergence display window AND bars since the last short divergence signal >= divergence display window OR bars since the last long divergence signal < divergence display window AND the last long divergence signal is at least as recent as the last short divergence signal.
Short: Bars since the last short divergence signal < divergence display window AND bars since the last long divergence signal >= divergence display window OR bars since the last short divergence signal < divergence display window AND the last short divergence signal is more recent than the last long divergence signal.
Long: Close crosses above the most recently confirmed high pivot, comparing the current close and pivot with their respective previous-bar values.
Short: Close crosses below the most recently confirmed low pivot, comparing the current close and pivot with their respective previous-bar values.
Long: A low pivot is confirmed AND the pivot bar close < its open.
Short: A high pivot is confirmed AND the pivot bar close > its open.
Long: Current low > high two bars earlier.
Short: Current high < low two bars earlier.
Long: A high pivot is confirmed AND its value > the preceding confirmed high pivot OR a low pivot is confirmed AND its value > the preceding confirmed low pivot.
Short: A high pivot is confirmed AND its value <= the preceding confirmed high pivot OR a low pivot is confirmed AND its value <= the preceding confirmed low pivot.
Long: RSI < oversold threshold.
Short: RSI > overbought threshold.