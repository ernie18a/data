Calculation: Heikin-Ashi close = (open + high + low + close) / 4
Calculation: Heikin-Ashi open = (previous bar's open + previous bar's close) / 2
Calculation: Heikin-Ashi low = min(low, (previous bar's Heikin-Ashi open + previous bar's Heikin-Ashi close) / 2, Heikin-Ashi close)
Calculation: Initial stop price = entry price − risk multiplier × ATR for long positions; entry price + risk multiplier × ATR for short positions. When price reaches the break-even trigger, set the stop to entry price. After that, if trailing is enabled, update the long stop to max(current stop, close − trailing ATR multiple × ATR), or the short stop to min(current stop, close + trailing ATR multiple × ATR).
Calculation: Take-profit price = entry price + reward multiplier × ATR for long positions; entry price − reward multiplier × ATR for short positions.
Calculation: Break-even trigger = entry price + break-even ATR multiple × ATR for long positions; entry price − break-even ATR multiple × ATR for short positions.
Long: Heikin-Ashi close crosses the simple moving average OR (MFI of Heikin-Ashi low is below its lower threshold AND Heikin-Ashi close > simple moving average)
Short: Heikin-Ashi close crosses below the simple moving average OR (MFI of Heikin-Ashi close is above its upper threshold AND Heikin-Ashi close < simple moving average)
Exit: long, low ≤ stop price OR high ≥ take-profit price
Exit: short, high ≥ stop price OR low ≤ take-profit price