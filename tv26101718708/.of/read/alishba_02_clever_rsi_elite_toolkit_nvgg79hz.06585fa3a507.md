Calculation: Higher-timeframe RSI = RSI with the chart RSI length on higher-timeframe bars, using the previous completed higher-timeframe bar; with historical lookahead disabled, update this value only on the last chart bar of each higher-timeframe bar and carry it forward between updates.
Calculation: Signal spacing = number of chart bars since the most recent filtered RSI-crossing buy or sell signal, initialized as the number of bars since chart bar index zero.
Long: RSI crosses above the oversold threshold AND (trend filter disabled OR (shorter-period EMA > longer-period EMA AND close > shorter-period EMA)) AND (higher-timeframe filter disabled OR higher-timeframe RSI > RSI midpoint) AND signal spacing >= cooldown.
Short: RSI crosses below the overbought threshold AND (trend filter disabled OR (shorter-period EMA < longer-period EMA AND close < shorter-period EMA)) AND (higher-timeframe filter disabled OR higher-timeframe RSI < RSI midpoint) AND signal spacing >= cooldown.
Long: RSI crosses above the oversold threshold AND signal spacing >= cooldown AND shorter-period EMA > longer-period EMA AND close > shorter-period EMA AND higher-timeframe RSI > RSI midpoint AND absolute change in RSI from the previous bar >= velocity threshold AND the lowest RSI over the depth lookback ending on the previous bar <= oversold threshold minus depth threshold.
Short: RSI crosses below the overbought threshold AND signal spacing >= cooldown AND shorter-period EMA < longer-period EMA AND close < shorter-period EMA AND higher-timeframe RSI < RSI midpoint AND absolute change in RSI from the previous bar >= velocity threshold AND the highest RSI over the depth lookback ending on the previous bar >= overbought threshold plus depth threshold.
Long: RSI <= oversold threshold.
Short: RSI >= overbought threshold.
Long: shorter-period EMA > longer-period EMA AND close > shorter-period EMA.
Short: shorter-period EMA < longer-period EMA AND close < shorter-period EMA.
Long: higher-timeframe RSI > RSI midpoint.
Short: higher-timeframe RSI <= RSI midpoint.