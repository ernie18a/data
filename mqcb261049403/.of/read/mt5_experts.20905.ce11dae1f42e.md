Calculation: Bullish regime = Awesome Oscillator >= its previous-bar value AND Accelerator Oscillator >= its previous-bar value
Calculation: Bearish regime = Awesome Oscillator <= its previous-bar value AND Accelerator Oscillator <= its previous-bar value AND bullish regime is false
Calculation: Trading interval = if start hour < end hour, (hour = start hour AND minute >= start minute) OR (hour > start hour AND hour < end hour) OR (hour = end hour AND minute < end minute); if start hour = end hour, hour = start hour AND minute >= start minute AND minute < end minute; if start hour > end hour, (hour >= start hour AND minute >= start minute) OR hour < end hour OR (hour = end hour AND minute < end minute)
Long: Bullish regime on the chart timeframe
Short: Bearish regime on the chart timeframe
Long: Bullish regime on the last completed higher-timeframe bar AND bullish regime was false on the preceding higher-timeframe bar AND (trading interval filter is disabled OR current time is in the trading interval)
Short: Bearish regime on the last completed higher-timeframe bar AND bearish regime was false on the preceding higher-timeframe bar AND (trading interval filter is disabled OR current time is in the trading interval)
Exit: long, bearish regime on the last completed higher-timeframe bar
Exit: short, bullish regime on the last completed higher-timeframe bar
Exit: long, trading interval filter is enabled AND current time is outside the trading interval
Exit: short, trading interval filter is enabled AND current time is outside the trading interval
Exit: long, stop loss is enabled AND low <= entry price minus stop-loss distance OR take profit is enabled AND high >= entry price plus take-profit distance
Exit: short, stop loss is enabled AND high >= entry price plus stop-loss distance OR take profit is enabled AND low <= entry price minus take-profit distance