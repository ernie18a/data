Calculation: Globex VWAP = VWAP((open + high + low + close) / 4, volume, Globex day)
Calculation: Globex VWAP bands = VWAP standard deviation bands((open + high + low + close) / 4, volume, Globex day, band multiplier)
Calculation: Active session VWAP = VWAP((open + high + low + close) / 4, volume, active Tokyo, London, or RTH session)
Calculation: Active session VWAP bands = VWAP standard deviation bands((open + high + low + close) / 4, volume, active Tokyo, London, or RTH session, band multiplier)
Calculation: Globex value area = SVP(high, low, volume, Globex day, row count, value-area percentage)
Calculation: Active session value area = SVP(high, low, volume, active Tokyo, London, or RTH session, row count, value-area percentage)
Long: Globex VWAP is defined AND close >= Globex VWAP
Short: Globex VWAP is defined AND close < Globex VWAP
Long: Globex VWAP bands are defined AND close > upper Globex VWAP band
Short: Globex VWAP bands are defined AND close < lower Globex VWAP band
Long: an active Tokyo, London, or RTH session is in progress AND Active session VWAP is defined AND close >= Active session VWAP
Short: an active Tokyo, London, or RTH session is in progress AND Active session VWAP is defined AND close < Active session VWAP
Long: an active Tokyo, London, or RTH session is in progress AND Active session VWAP bands are defined AND close > upper Active session VWAP band
Short: an active Tokyo, London, or RTH session is in progress AND Active session VWAP bands are defined AND close < lower Active session VWAP band
Long: Globex value area VAH is defined AND close > Globex value area VAH
Short: Globex value area VAL is defined AND close < Globex value area VAL
Long: an active Tokyo, London, or RTH session is in progress AND Active session value area VAH is defined AND close > Active session value area VAH
Short: an active Tokyo, London, or RTH session is in progress AND Active session value area VAL is defined AND close < Active session value area VAL