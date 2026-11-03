Calculation: Bullish regime = trend source > SMA of trend source AND RSI of RSI source is within the inclusive bullish range for each of the most recent confirmation-count bars.
Calculation: Bearish regime = trend source < SMA of trend source AND RSI of RSI source is within the inclusive bearish range for each of the most recent confirmation-count bars.
Calculation: Higher-timeframe bullish condition = on the last completed higher-timeframe bar, trend source > SMA of trend source AND RSI of RSI source is within the inclusive bullish range; use the same sources, lengths, and range as on the chart timeframe.
Calculation: Higher-timeframe bearish condition = on the last completed higher-timeframe bar, trend source < SMA of trend source AND RSI of RSI source is within the inclusive bearish range; use the same sources, lengths, and range as on the chart timeframe.
Calculation: Entry ATR = ATR on the signal bar, fixed for the life of the trade; the entry price is the close of the bar preceding the signal bar.
Long: Bullish regime is true.
Short: Bearish regime is true.
Long: Bullish regime is true AND bullish regime was false on the previous bar AND (higher-timeframe confirmation is disabled OR higher-timeframe bullish condition is true) AND (ADX filter is disabled OR ADX >= minimum strength) AND datetime >= history start.
Short: Bearish regime is true AND bearish regime was false on the previous bar AND (higher-timeframe confirmation is disabled OR higher-timeframe bearish condition is true) AND (ADX filter is disabled OR ADX >= minimum strength) AND datetime >= history start.
Exit: long, low <= entry price - entry ATR * stop multiplier OR high >= entry price + entry ATR * selected target multiplier.
Exit: short, high >= entry price + entry ATR * stop multiplier OR low <= entry price - entry ATR * selected target multiplier.