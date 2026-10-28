Calculation: Confirmed swing high/low = pivot high/low with equal left and right lookbacks; use the most recently confirmed pivot level
Calculation: Structural trend = bullish after a close above the latest confirmed swing high; bearish after a close below the latest confirmed swing low; otherwise retain the prior trend
Calculation: ATR = average true range
Calculation: Confluence score = count of these six true conditions: recent same-direction sweep (current or prior bar), matching structural trend, correct premium/discount zone, matching higher-timeframe EMA bias, matching momentum, and matching volume delta
Calculation: Matching momentum = linear-regression momentum of close minus the average of the midpoint of the lookback high-low range and the lookback average close; positive and rising for bullish, negative and falling for bearish
Calculation: Matching volume delta = the smoothed difference between exponentially averaged estimated bull and bear volume, confirmed by OBV change over a lookback; all three values must be positive for bullish or negative for bearish
Calculation: Higher-timeframe EMA bias = fast EMA versus slower EMA, calculated on higher-timeframe bars, including the bar still forming
Long: Low < latest confirmed swing low − ATR × minimum sweep-wick factor AND close > latest confirmed swing low AND close > open
Short: High > latest confirmed swing high + ATR × minimum sweep-wick factor AND close < latest confirmed swing high AND close < open
Long: Close > latest confirmed swing high AND prior structural trend was bearish (bullish CHoCH)
Long: Close > latest confirmed swing high AND prior structural trend was bullish (bullish BOS)
Short: Close < latest confirmed swing low AND prior structural trend was bullish (bearish CHoCH)
Short: Close < latest confirmed swing low AND prior structural trend was bearish (bearish BOS)
Long: Bullish setup is true and was false on the prior bar; bullish setup requires a bullish sweep on this or the prior bar, bullish structural trend with continuation setups enabled or a bullish CHoCH with reversal setups enabled, confluence score at least the configured minimum, ADX at least its configured minimum when enabled, active session when enabled, elapsed same-direction cooldown, close above session VWAP when enabled, and discount-zone close when that filter is enabled
Short: Bearish setup is true and was false on the prior bar; bearish setup requires a bearish sweep on this or the prior bar, bearish structural trend with continuation setups enabled or a bearish CHoCH with reversal setups enabled, confluence score at least the configured minimum, ADX at least its configured minimum when enabled, active session when enabled, elapsed same-direction cooldown, close below session VWAP when enabled, and premium-zone close when that filter is enabled
Exit: long, High ≥ entry price + ATR × first-target multiple
Exit: short, Low ≤ entry price − ATR × first-target multiple
Exit: long, Low ≤ long stop OR Low ≤ long trailing stop OR High ≥ entry price + ATR × full-target multiple
Exit: short, High ≥ short stop OR High ≥ short trailing stop OR Low ≤ entry price − ATR × full-target multiple