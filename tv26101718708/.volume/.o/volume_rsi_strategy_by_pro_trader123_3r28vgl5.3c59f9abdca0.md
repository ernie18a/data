Calculation: RSI = relative strength index of close.
Calculation: RSI average = simple moving average of RSI.
Calculation: Extreme-volume condition = the highest volume over the shorter lookback equals the highest volume over the longer lookback.
Calculation: Oversold recovery state = 1 when RSI is below the oversold threshold; 2 when the prior bar's state is 1 and RSI is above the threshold; otherwise 0.
Calculation: Oversold volume latch = 1 when RSI is below the oversold threshold and the extreme-volume condition holds; otherwise 1 when the prior bar's latch is 1 and prior RSI is below the threshold; otherwise 0.
Calculation: Overbought recovery state = 1 when RSI is above the overbought threshold; 2 when the prior bar's state is 1 and RSI is below the threshold; otherwise 0.
Calculation: Overbought volume latch = 1 when RSI is above the overbought threshold and the extreme-volume condition holds; otherwise 1 when the prior bar's latch is 1 and prior RSI is above the threshold; otherwise 0.
Calculation: Long exit phase = 1 when oversold recovery state is 2 and RSI average is above RSI; 2 when oversold recovery state is 2 and RSI average is below RSI; otherwise retain phase 1 while RSI average is above RSI, retain phase 2 while RSI average is below RSI, or set phase 3 when the prior phase is 2 and RSI average is above RSI; otherwise 0.
Calculation: Short exit phase = 1 when oversold recovery state is 2 and RSI average is below RSI; 2 when oversold recovery state is 2 and RSI average is above RSI; otherwise retain phase 1 while RSI average is below RSI, retain phase 2 while RSI average is above RSI, or set phase 3 when the prior phase is 2 and RSI average is below RSI; otherwise 0.
Long: oversold recovery state = 2 AND oversold volume latch = 1
Short: overbought recovery state = 2 AND overbought volume latch = 1
Exit: long position, long exit phase = 3 OR low is at or below entry price minus the stop distance
Exit: short position, short exit phase = 3 OR high is at or above entry price plus the stop distance