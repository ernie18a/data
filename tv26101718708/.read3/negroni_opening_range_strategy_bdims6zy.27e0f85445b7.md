Calculation: Pre-market range = highest high and lowest low during the configured pre-market interval
Calculation: Opening range = highest high and lowest low during the configured opening-range interval
Calculation: ATR value = ATR(lookback, T1), calculated on T1 bars and requested on chart bars with default lookahead off (last completed T1 bar historically; forming T1 bar live)
Calculation: ATR stop distance = ATR value × stop-loss multiplier ÷ 100
Calculation: ATR full-target distance = ATR value × full-target multiplier ÷ 100
Calculation: ATR first-target distance = ATR value × first-target multiplier ÷ 100
Long: (pre-market range selected AND close crosses above pre-market range high OR opening range selected AND close crosses above opening-range high) AND bar time is within the configured entry window AND long entries are enabled AND today's entry count is below the daily limit
Short: (pre-market range selected AND close crosses below pre-market range low OR opening range selected AND close crosses below opening-range low) AND bar time is within the configured entry window AND short entries are enabled AND today's entry count is below the daily limit
Exit: long, full ATR mode selected AND bar time is before the configured close time AND (low ≤ entry price − ATR stop distance OR high ≥ entry price + ATR full-target distance)
Exit: short, full ATR mode selected AND bar time is before the configured close time AND (high ≥ entry price + ATR stop distance OR low ≤ entry price − ATR full-target distance)
Exit: long, partial ATR mode selected AND bar time is before the configured close time AND (low ≤ entry price − ATR stop distance OR high ≥ entry price + ATR first-target distance OR high ≥ entry price + ATR full-target distance)
Exit: short, partial ATR mode selected AND bar time is before the configured close time AND (high ≥ entry price + ATR stop distance OR low ≤ entry price − ATR first-target distance OR low ≤ entry price − ATR full-target distance)
Exit: long, trailing-stop mode selected AND after high reaches the configured trail parameter as an activation price, low reaches the trailing stop at the highest high since activation minus the configured trail offset in ticks
Exit: short, trailing-stop mode selected AND high ≥ entry price + configured trail distance
Exit: long, moving-average mode selected AND bar time is before the configured close time AND (low ≤ selected EMA, SMA, VWMA, or HMA of hlc3 with its lookback OR low ≤ entry price − ATR stop distance)
Exit: short, moving-average mode selected AND bar time is before the configured close time AND (high ≥ selected EMA, SMA, VWMA, or HMA of hlc3 with its lookback OR high ≥ entry price + ATR stop distance)
Exit: long, scalp mode selected AND bar time is before the configured close time AND (low ≤ entry price − configured stop points OR high ≥ entry price + configured target points)
Exit: short, scalp mode selected AND bar time is before the configured close time AND (high ≥ entry price + configured stop points OR low ≤ entry price − configured target points)
Exit: long, pre-market multiplier mode selected AND bar time is before the configured close time AND (low ≤ pre-market range high − (pre-market range high − pre-market range low) × multiplier ÷ 100 OR high ≥ entry price + ATR full-target distance)
Exit: short, pre-market multiplier mode selected AND bar time is before the configured close time AND (high ≥ pre-market range low + (pre-market range high − pre-market range low) × multiplier ÷ 100 OR low ≤ entry price − ATR full-target distance)
Exit: long, bar time is at or after the configured close time
Exit: short, bar time is at or after the configured close time