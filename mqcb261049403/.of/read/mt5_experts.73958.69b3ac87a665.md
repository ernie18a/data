Calculation: dist = abs(close - EMA of close) / ATR, evaluated per bar
Calculation: SL distance = SL multiplier * ATR of the last completed bar at the time of entry; TP distance = SL distance * reward-risk ratio
Long: no position open AND ADX of last completed bar > ADX threshold AND ADX of last completed bar > ADX of the bar before it AND dist of last completed bar < pullback ratio AND dist of the bar before it >= pullback ratio AND +DI > -DI on last completed bar
Short: no position open AND ADX of last completed bar > ADX threshold AND ADX of last completed bar > ADX of the bar before it AND dist of last completed bar < pullback ratio AND dist of the bar before it >= pullback ratio AND -DI > +DI on last completed bar
Exit: long, low <= entry price - SL distance OR high >= entry price + TP distance
Exit: short, high >= entry price + SL distance OR low <= entry price - TP distance