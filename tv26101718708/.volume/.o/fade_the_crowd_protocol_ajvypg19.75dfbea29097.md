Calculation: Signal-bar ATR% = ATR / signal-bar close × 100; capture on the entry signal bar and hold for the trade
Calculation: Long take-profit price = entry price × (1 + signal-bar ATR% × take-profit multiplier / 100)
Calculation: Long stop price = max(entry price × (1 − signal-bar ATR% × stop-loss multiplier / 100), entry price × (1 − hard-stop percentage / 100))
Calculation: Short take-profit price = entry price × (1 − signal-bar ATR% × take-profit multiplier / 100)
Calculation: Short stop price = min(entry price × (1 + signal-bar ATR% × stop-loss multiplier / 100), entry price × (1 + hard-stop percentage / 100))
Long: flat AND MACD line crosses its signal line AND MACD histogram < 0 AND low ≤ VWMA AND Choppiness Index < threshold AND ADX > threshold AND (no prior exit OR bars since most recent exit ≥ cooldown period)
Short: flat AND MACD line crosses its signal line AND MACD histogram > 0 AND high ≥ VWMA AND Choppiness Index < threshold AND ADX > threshold AND (no prior exit OR bars since most recent exit ≥ cooldown period)
Exit: long, high ≥ long take-profit price OR low ≤ long stop price
Exit: short, low ≤ short take-profit price OR high ≥ short stop price