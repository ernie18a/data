Calculation: CRSI = mean of RSI(close), RSI(signed consecutive-close streak), and percentile rank of close-to-close change, each using its own lookback.
Calculation: Keltner upper/lower = EMA(close) ± channel multiplier × ATR, using the same chart-timeframe bars.
Calculation: Candle body = absolute(close − open); bullish/bearish candle requires close above/below open and body at least the configured fraction of high − low.
Calculation: Higher-timeframe CRSI = CRSI calculated on higher-timeframe bars; use the last completed higher-timeframe bar.
Long: signal bar AND minimum entry spacing elapsed AND ((higher-timeframe CRSI is in the configured neutral range AND chart low < Keltner lower AND chart CRSI <= oversold threshold AND bullish candle) OR (higher-timeframe CRSI > upper trend threshold AND ((chart CRSI <= oversold threshold AND chart close <= Keltner lower × pullback factor) OR (chart high > prior chart bar's Keltner upper AND chart close < Keltner upper AND chart CRSI <= oversold threshold)))
Short: signal bar AND minimum entry spacing elapsed AND ((higher-timeframe CRSI is in the configured neutral range AND chart high > Keltner upper AND chart CRSI >= overbought threshold AND bearish candle) OR (higher-timeframe CRSI < lower trend threshold AND ((chart CRSI >= overbought threshold AND chart close >= Keltner upper × pullback factor) OR (chart low < prior chart bar's Keltner lower AND chart close > Keltner lower AND chart CRSI >= overbought threshold)))
Exit: long, chart low <= entry-signal close − stop-loss multiple × chart ATR at entry
Exit: long, chart high >= entry-signal close + take-profit multiple × stop distance
Exit: long, trailing stop is activated after price rises by the configured activation distance from entry and chart low <= highest price since activation − configured trailing offset
Exit: long, minimum holding period elapsed AND short signal
Exit: short, chart high >= entry-signal close + stop-loss multiple × chart ATR at entry
Exit: short, chart low <= entry-signal close − take-profit multiple × chart ATR at entry
Exit: short, trailing stop is activated after price falls by the configured activation distance from entry and chart high >= lowest price since activation + configured trailing offset
Exit: short, minimum holding period elapsed AND long signal