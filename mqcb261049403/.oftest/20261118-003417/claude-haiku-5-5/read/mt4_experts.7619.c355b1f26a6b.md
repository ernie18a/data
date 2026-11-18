Calculation: BeginClose = close of the last completed T1 bar opened at begin time on the current date
Calculation: LongStop = IF LongStop[1] < entry price AND close - entry price >= trail trigger distance THEN entry price + trail distance ELSE IF LongStop[1] > entry price AND close - LongStop[1] >= trail trigger distance THEN LongStop[1] + trail distance ELSE LongStop[1], with LongStop[1] = entry price - initial stop distance on the entry bar
Calculation: ShortStop = IF ShortStop[1] > entry price AND entry price - close >= trail trigger distance THEN entry price - trail distance ELSE IF ShortStop[1] < entry price AND ShortStop[1] - close >= trail trigger distance THEN ShortStop[1] - trail distance ELSE ShortStop[1], with ShortStop[1] = entry price + initial stop distance on the entry bar
Long: close[1] > BeginClose + long target distance AND time of datetime > begin time + window start offset AND time of datetime < end time AND no long position open
Short: close[1] < BeginClose - short target distance AND time of datetime > begin time + window start offset AND time of datetime < end time AND no short position open
Exit: long, low <= LongStop[1]
Exit: short, high >= ShortStop[1]