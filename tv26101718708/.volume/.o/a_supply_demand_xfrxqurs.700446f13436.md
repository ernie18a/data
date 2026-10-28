Calculation: qualifying displacement = abs(close − open) > configured multiple of ATR AND volume / average volume over its configured lookback >= configured minimum
Calculation: demand zone = previous bar’s low-to-high range when a qualifying displacement bar closes above its open
Calculation: supply zone = previous bar’s low-to-high range when a qualifying displacement bar closes below its open
Calculation: long stop = demand zone bottom − configured ATR buffer; long target = entry price + configured risk/reward multiple × (entry price − long stop)
Calculation: short stop = supply zone top + configured ATR buffer; short target = entry price − configured risk/reward multiple × (short stop − entry price)
Long: a fresh demand zone is intersected for the first time (low <= zone top AND high >= zone bottom AND low >= zone bottom) AND close > EMA
Short: a fresh supply zone is intersected for the first time (low <= zone top AND high >= zone bottom AND high <= zone top) AND close < EMA
Exit: long, high >= long target OR low <= long stop
Exit: short, low <= short target OR high >= short stop