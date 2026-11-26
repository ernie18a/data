Calculation: opening range high = highest of (high if range source is high/low, else max(open, close)) over bars inside the opening range session on the current day
Calculation: opening range low = lowest of (low if range source is high/low, else min(open, close)) over bars inside the opening range session on the current day
Calculation: upper target = opening range high + (opening range high - opening range low) * extension multiplier 3
Calculation: lower target = opening range low - (opening range high - opening range low) * extension multiplier 3
Calculation: long breakout = close crosses above opening range high AND bar is after the opening range session on the current day
Calculation: short breakout = close crosses below opening range low AND bar is after the opening range session on the current day
Calculation: display window = plotting limit disabled OR (bar is on a session day AND bar time in timezone is between opening range session start and plotting end time)
Calculation: long trailing stop(M) = MAX(long trailing stop(M)[1], low - ATR(trail ATR length) * M), with long trailing stop(M)[1] replaced by low - ATR(trail ATR length) * M when the previous bar had no open long position for multiplier M
Calculation: short trailing stop(M) = MIN(short trailing stop(M)[1], high + ATR(trail ATR length) * M), with short trailing stop(M)[1] replaced by high + ATR(trail ATR length) * M when the previous bar had no open short position for multiplier M
Long: long breakout AND display window AND no earlier bar on the current day had long breakout AND display window AND position side is flat
Long: long breakout
Long: close crosses upper target in either direction
Short: short breakout AND display window AND no earlier bar on the current day had short breakout AND display window AND position side is flat
Short: short breakout
Short: close crosses lower target in either direction
Exit: long, close < long trailing stop(trail multiplier) OR NOT display window OR bar starts a new day OR bar is inside opening range session
Exit: short, close > short trailing stop(trail multiplier) OR NOT display window OR bar starts a new day OR bar is inside opening range session
Exit: long, close < long trailing stop(optimizer multiplier 1) OR NOT display window OR bar starts a new day OR bar is inside opening range session
Exit: long, close < long trailing stop(optimizer multiplier 2) OR NOT display window OR bar starts a new day OR bar is inside opening range session
Exit: long, close < long trailing stop(optimizer multiplier 3) OR NOT display window OR bar starts a new day OR bar is inside opening range session
Exit: long, close < long trailing stop(optimizer multiplier 4) OR NOT display window OR bar starts a new day OR bar is inside opening range session
Exit: long, close < long trailing stop(optimizer multiplier 5) OR NOT display window OR bar starts a new day OR bar is inside opening range session
Exit: short, close > short trailing stop(optimizer multiplier 1) OR NOT display window OR bar starts a new day OR bar is inside opening range session
Exit: short, close > short trailing stop(optimizer multiplier 2) OR NOT display window OR bar starts a new day OR bar is inside opening range session
Exit: short, close > short trailing stop(optimizer multiplier 3) OR NOT display window OR bar starts a new day OR bar is inside opening range session
Exit: short, close > short trailing stop(optimizer multiplier 4) OR NOT display window OR bar starts a new day OR bar is inside opening range session
Exit: short, close > short trailing stop(optimizer multiplier 5) OR NOT display window OR bar starts a new day OR bar is inside opening range session