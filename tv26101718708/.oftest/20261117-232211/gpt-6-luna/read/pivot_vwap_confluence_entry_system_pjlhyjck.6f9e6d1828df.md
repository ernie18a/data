Calculation: Pivot = (high + low + close) / 3 of the last completed T1 bar
Calculation: Resistance 1 = 2 × Pivot − low of the last completed T1 bar
Calculation: Resistance 2 = Pivot + (high − low) of the last completed T1 bar
Calculation: Resistance 3 = high + 2 × (Pivot − low) of the last completed T1 bar
Calculation: Support 1 = 2 × Pivot − high of the last completed T1 bar
Calculation: Support 2 = Pivot − (high − low) of the last completed T1 bar
Calculation: Support 3 = low − 2 × (high − Pivot) of the last completed T1 bar
Calculation: Pivot range = Resistance 1 − Support 1
Calculation: Resistance 4 = Resistance 3 + Pivot range
Calculation: Resistance 5 = Resistance 4 + Pivot range
Calculation: Support 4 = Support 3 − Pivot range
Calculation: Support 5 = Support 4 − Pivot range
Calculation: VWAP = sum(hlc3 × volume since start of current day) / sum(volume since start of current day), where hlc3 = (high + low + close) / 3
Long: within session (session start, session end) on T2 and number of entries taken today < daily entry limit AND, for any of Pivot, Resistance 1, Resistance 2, Resistance 3, Resistance 4, Resistance 5, Support 1, Support 2, Support 3, Support 4, Support 5: low < level AND low < VWAP AND close > level AND close > VWAP
Short: within session (session start, session end) on T2 and number of entries taken today < daily entry limit AND, for any of Pivot, Resistance 1, Resistance 2, Resistance 3, Resistance 4, Resistance 5, Support 1, Support 2, Support 3, Support 4, Support 5: high > level AND high > VWAP AND close < level AND close < VWAP
Exit: long, close < VWAP for the consecutive bar limit
Exit: short, close > VWAP for the consecutive bar limit