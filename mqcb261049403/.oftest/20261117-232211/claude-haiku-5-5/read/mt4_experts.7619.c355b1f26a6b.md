Calculation: session window = time of day is after session start plus T1 duration AND time of day is before session end
Calculation: start close = close of the T1 bar whose open time is session start on the current date
Calculation: long stop = IF bar is entry bar THEN entry price - initial stop distance ELSE IF long stop[1] < entry price AND current close - entry price >= trail trigger distance THEN entry price + trail distance ELSE IF long stop[1] > entry price AND current close - long stop[1] >= trail trigger distance THEN long stop[1] + trail distance ELSE long stop[1]
Calculation: short stop = IF bar is entry bar THEN entry price + initial stop distance ELSE IF short stop[1] > entry price AND entry price - current close >= trail trigger distance THEN entry price - trail distance ELSE IF short stop[1] < entry price AND short stop[1] - current close >= trail trigger distance THEN short stop[1] - trail distance ELSE short stop[1]
Long: position side is not long AND session window AND close[1] > start close + long distance
Short: position side is not short AND session window AND close[1] < start close - short distance
Exit: long, low <= long stop
Exit: short, high >= short stop