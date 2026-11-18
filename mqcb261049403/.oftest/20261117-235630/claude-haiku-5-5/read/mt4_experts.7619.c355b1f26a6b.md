Calculation: StartClose = close of the T1 bar containing WindowStartHour:00 of the current day
Calculation: LongStop = entry price - InitialStopDistance on the entry bar, else if LongStop[1] < entry price AND close - entry price >= TrailTriggerDistance then entry price + TrailStepDistance, else if LongStop[1] > entry price AND close - LongStop[1] >= TrailTriggerDistance then LongStop[1] + TrailStepDistance, else LongStop[1]
Calculation: ShortStop = entry price + InitialStopDistance on the entry bar, else if ShortStop[1] > entry price AND entry price - close >= TrailTriggerDistance then entry price - TrailStepDistance, else if ShortStop[1] < entry price AND ShortStop[1] - close >= TrailTriggerDistance then ShortStop[1] - TrailStepDistance, else ShortStop[1]
Long: current time > WindowStartHour:00 + WindowStartDelay AND current time < WindowEndHour:00 AND close[1] > StartClose + LongDistance AND position side is not long
Short: current time > WindowStartHour:00 + WindowStartDelay AND current time < WindowEndHour:00 AND close[1] < StartClose - ShortDistance AND position side is not short
Exit: long, low <= LongStop[1]
Exit: short, high >= ShortStop[1]