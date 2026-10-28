Calculation: Bullish bias = the last three confirmed pivot highs and last three confirmed pivot lows are each strictly rising
Calculation: Bearish bias = the last three confirmed pivot highs and last three confirmed pivot lows are each strictly falling
Calculation: Bullish BOS = close crosses above the second most recent confirmed pivot high from a prior close at or below it
Calculation: Bearish BOS = close crosses below the second most recent confirmed pivot low from a prior close at or above it
Calculation: Liquidity sweep = high exceeds the highest high of the preceding 10 bars and close is below it, or low falls below the lowest low of the preceding 10 bars and close is above it
Calculation: Large body = absolute candle body exceeds twice the 20-bar average absolute candle body
Calculation: Fair value gap = low > high two bars earlier and prior close > that earlier high, or high < low two bars earlier and prior close < that earlier low
Calculation: BOS retest = after a bearish BOS, high reaches within 0.1% below its broken pivot level and close is below it; or after a bullish BOS, low reaches within 0.1% above its broken pivot level and close is above it; each retest is counted once per BOS
Calculation: Confirmed supply/demand zone = a pivot-high/low price ±0.1% whose zone has at least two pivot highs/lows; price is inside the zone when close is within its bounds
Calculation: Confirmation score = count of: either bias; either liquidity sweep; large body; either fair value gap; either BOS; either BOS retest; RSI > 60 with bullish bias or RSI < 40 with bearish bias; either confirmed supply or demand zone; ATR × stop distance multiplier > 0
Long: Bullish bias OR (confirmation score >= minimum confirmations AND bullish bias AND bullish BOS AND no active buy or sell signal AND not trade-locked AND in the configured session if session filtering is enabled AND current bar is more than the configured cooldown after the prior buy signal)
Short: Bearish bias OR (confirmation score >= minimum confirmations AND bearish bias AND bearish BOS AND no active buy or sell signal AND not trade-locked AND in the configured session if session filtering is enabled AND current bar is more than the configured cooldown after the prior sell signal)
Exit: long, low <= entry price - ATR-based stop distance OR high >= entry price + 3 × ATR-based stop distance
Exit: short, high >= entry price + ATR-based stop distance OR low <= entry price - 3 × ATR-based stop distance