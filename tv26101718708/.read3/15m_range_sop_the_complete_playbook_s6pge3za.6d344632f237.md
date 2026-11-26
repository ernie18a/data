Calculation: Range high = highest high of chart bars in the parameterized session window, held until the next session
Calculation: Range low = lowest low of chart bars in the parameterized session window, held until the next session
Calculation: Prior swing high = Highest(high, lookback)[1] on the first chart bar in the session, held until the next session
Calculation: Prior swing low = Lowest(low, lookback)[1] on the first chart bar in the session, held until the next session
Calculation: Active window = after the session range ends, while outside the session and chart-bar time is at or before the last session bar time plus extension length × T1
Calculation: Double sweep complete = during the active window, a chart bar has had high > Range high AND close <= Range high, and a chart bar has had low < Range low AND close >= Range low, both since the current session began
Long: Active window AND Double sweep complete AND close > Range high AND no long signal has fired for this session
Short: Active window AND Double sweep complete AND close < Range low AND no short signal has fired for this session
Exit: long, after a long signal and before its first TP1 marker, Prior swing high > Range high AND high >= Range high + (Prior swing high - Range high) / 2
Exit: long, after a long signal and before its first final-target marker, high >= Prior swing high
Exit: short, after a short signal and before its first TP1 marker, Prior swing low < Range low AND low <= Range low - (Range low - Prior swing low) / 2
Exit: short, after a short signal and before its first final-target marker, low <= Prior swing low