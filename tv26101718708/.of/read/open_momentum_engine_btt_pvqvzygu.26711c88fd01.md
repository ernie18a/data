Calculation: Previous regular-session close = the close of the prior regular session
Calculation: Premarket high = the highest high from premarket start through the start of the regular session
Calculation: Opening-range high/low = the highest high / lowest low from the start of the regular session through the configured opening-range duration; freeze after that duration
Calculation: Gap percentage = (close − previous regular-session close) / previous regular-session close × 100
Calculation: Stop level = opening-range low − configured ATR cushion, using ATR from the primary entry bar
Calculation: Target levels = primary entry price + configured ATR multiples, using ATR from the primary entry bar
Long: During the configured early-session window after the opening range completes, close > opening-range high AND prior close <= prior opening-range high AND gap percentage >= configured minimum AND close > previous regular-session close AND close > VWAP AND close > premarket high AND fast EMA > slow EMA AND volume >= volume SMA × configured expansion multiplier
Long: After a primary long signal, once at least one later bar has touched the configured zone around opening-range high, close > opening-range high AND close > open AND close > VWAP AND fast EMA > slow EMA AND within the configured early-session window; fire at most once per primary signal
Exit: long, low <= stop level OR high >= first target level OR high >= second target level