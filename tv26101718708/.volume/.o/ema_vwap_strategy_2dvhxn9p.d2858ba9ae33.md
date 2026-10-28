Calculation: Fast EMA = EMA of close with a shorter lookback than the Slow EMA
Calculation: Slow EMA = EMA of close with a longer lookback than the Fast EMA
Calculation: VWAP slope = 100 × (current session VWAP − session VWAP from the lookback bars ago) / session VWAP from the lookback bars ago
Calculation: Long stop price = at entry, either entry price − ATR × multiplier, lowest low over the swing lookback, Slow EMA, or entry price × (1 − stop percentage / 100), according to the selected stop type
Calculation: Short stop price = at entry, either entry price + ATR × multiplier, highest high over the swing lookback, Slow EMA, or entry price × (1 + stop percentage / 100), according to the selected stop type
Long: Fast EMA > VWAP AND previous Fast EMA ≤ previous VWAP AND Fast EMA > Slow EMA AND VWAP slope ≥ flat threshold AND datetime is Monday through Friday
Short: Fast EMA < VWAP AND previous Fast EMA ≥ previous VWAP AND Fast EMA < Slow EMA AND VWAP slope ≤ −flat threshold AND datetime is Monday through Friday
Exit: long, low ≤ long stop price OR high ≥ entry price + (entry price − long stop price) × reward/risk ratio
Exit: short, high ≥ short stop price OR low ≤ entry price − (short stop price − entry price) × reward/risk ratio