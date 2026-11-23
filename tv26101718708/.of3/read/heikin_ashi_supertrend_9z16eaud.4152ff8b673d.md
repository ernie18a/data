Calculation: SupertrendDir = Supertrend direction(Heikin Ashi high, Heikin Ashi low, Heikin Ashi close, ATR length, ATR multiplier), where 1 is up and -1 is down
Calculation: LongStopMoved = move stop enabled AND highest high since entry > entry price * (1 + move stop after percent / 100)
Calculation: ShortStopMoved = move stop enabled AND lowest low since entry < entry price * (1 - move stop after percent / 100)
Calculation: LongStopTrigger = if LongStopMoved then entry price * (1 + move stop to percent / 100) * (1 + stop offset percent / 100), else entry price * (1 - stop trigger percent / 100) * (1 + stop offset percent / 100)
Calculation: ShortStopTrigger = if ShortStopMoved then entry price * (1 - move stop to percent / 100) * (1 - stop offset percent / 100), else entry price * (1 + stop trigger percent / 100) * (1 - stop offset percent / 100)
Long: SupertrendDir > SupertrendDir[1]
Short: SupertrendDir < SupertrendDir[1]
Long: SupertrendDir > 0
Short: SupertrendDir < 0
Long: Heikin Ashi open < Heikin Ashi close
Short: Heikin Ashi open >= Heikin Ashi close
Exit: long, close > entry price * (1 + profit target percent / 100)
Exit: long, close < LongStopTrigger AND bars since entry > stop delay bars
Exit: long, manual close enabled AND datetime = manual close datetime
Exit: short, close < entry price * (1 - profit target percent / 100)
Exit: short, close > ShortStopTrigger AND bars since entry > stop delay bars
Exit: short, manual close enabled AND datetime = manual close datetime