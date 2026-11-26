Calculation: Opening-range high = maximum high of T1 bars in the configured opening-range interval beginning at the configured session start; reset each New York calendar day and lock at interval end
Calculation: Opening-range low = minimum low of T1 bars in the configured opening-range interval beginning at the configured session start; reset each New York calendar day and lock at interval end
Calculation: Selected EMA = EMA(close, EMA lookback, T2, last completed bar when the confirmed-bar setting is enabled, otherwise the still-forming bar)
Calculation: Live T2 EMA = EMA(close, same EMA lookback, T2, still-forming bar)
Long: Bullish-armed state starts when the opening range is locked and selected EMA > opening-range high; it remains active until close is between opening-range low and high inclusive or selected EMA <= opening-range high, and resets each New York calendar day
Short: Bearish-armed state starts when the opening range is locked and selected EMA < opening-range low; it remains active until close is between opening-range low and high inclusive or selected EMA >= opening-range low, and resets each New York calendar day
Calculation: Bullish touch = bullish-armed state AND (structure filter disabled OR close > opening-range high) AND no pending prior bullish touch AND low <= selected EMA AND close > selected EMA AND chart bar confirmed; a touch remains pending until a later bar has low > selected EMA, and disarming or daily reset clears pending state
Calculation: Bearish touch = bearish-armed state AND (structure filter disabled OR close < opening-range low) AND no pending prior bearish touch AND high >= selected EMA AND close < selected EMA AND chart bar confirmed; a touch remains pending until a later bar has high < selected EMA, and disarming or daily reset clears pending state
Long: Bullish touch
Long: Bullish touch AND (T2 confirmation disabled OR (low of the T2 bar containing this chart bar < live T2 EMA AND close of that bar > live T2 EMA))
Short: Bearish touch
Short: Bearish touch AND (T2 confirmation disabled OR (high of the T2 bar containing this chart bar > live T2 EMA AND close of that bar < live T2 EMA))