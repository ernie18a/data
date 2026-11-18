Calculation: begin close = close of the last completed T1 bar that opens at begin time on the current date
Calculation: trail long = IF trail long[1] < entry price AND high - entry price >= trailing trigger THEN entry price + trailing step ELSE IF trail long[1] > entry price AND high - trail long[1] >= trailing trigger THEN trail long[1] + trailing step ELSE trail long[1], where trail long[1] on the first bar after entry = entry price - initial stop
Calculation: trail short = IF trail short[1] > entry price AND entry price - low >= trailing trigger THEN entry price - trailing step ELSE IF trail short[1] < entry price AND trail short[1] - low >= trailing trigger THEN trail short[1] - trailing step ELSE trail short[1], where trail short[1] on the first bar after entry = entry price + initial stop
Long: no long position open AND bar time-of-day >= begin time + one T1 bar AND bar time-of-day < end time AND close[1] > begin close + long target
Short: no short position open AND bar time-of-day >= begin time + one T1 bar AND bar time-of-day < end time AND close[1] < begin close - short target
Exit: long, low <= trail long[1]
Exit: short, high >= trail short[1]