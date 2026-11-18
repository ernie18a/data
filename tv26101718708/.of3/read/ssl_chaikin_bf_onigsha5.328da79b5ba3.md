Calculation: Smoothed ROC = EMA(ROC(close, ROC lookback), ROC lookback / 2)
Calculation: Long setup = (SSL Channel upper line > SSL Channel lower line AND (Smoothed ROC > movement threshold / 2 OR Smoothed ROC < -movement threshold / 2)) OR Chaikin Money Flow(close, high, low, volume, CMF lookback) crosses above upper threshold
Calculation: Short setup = (SSL Channel upper line < SSL Channel lower line AND (Smoothed ROC > movement threshold / 2 OR Smoothed ROC < -movement threshold / 2)) OR Chaikin Money Flow(close, high, low, volume, CMF lookback) crosses below lower threshold
Long: Long setup
Short: Short setup
Calculation: Latest Long Setup Time = most recent datetime when Long setup is true
Calculation: Latest Short Setup Time = most recent datetime when Short setup is true
Long: Latest Long Setup Time crosses above Latest Short Setup Time
Short: Latest Short Setup Time crosses above Latest Long Setup Time
Calculation: Latest Long Signal Time = most recent datetime when Latest Long Setup Time crosses above Latest Short Setup Time
Calculation: Latest Short Signal Time = most recent datetime when Latest Short Setup Time crosses above Latest Long Setup Time
Calculation: Recorded Long Signal Open = open when Latest Long Setup Time crosses above Latest Short Setup Time, otherwise its previous value
Calculation: Recorded Short Signal Open = open when Latest Short Setup Time crosses above Latest Long Setup Time, otherwise its previous value
Calculation: Long ATR Stop = undefined when Latest Short Setup Time crosses above Latest Long Setup Time; close - ATR(ATR stop period) * ATR stop multiplier when Latest Long Setup Time crosses above Latest Short Setup Time; otherwise its previous value
Calculation: Short ATR Stop = undefined when Latest Long Setup Time crosses above Latest Short Setup Time; close + ATR(ATR stop period) * ATR stop multiplier when Latest Short Setup Time crosses above Latest Long Setup Time; otherwise its previous value
Exit: long, fixed stop mode AND Latest Long Signal Time > Latest Short Signal Time AND low <= entry price * (1 - stop-loss percentage) AND barssince(Recorded Long Signal Open != Recorded Long Signal Open[1]) > 0
Exit: short, fixed stop mode AND Latest Short Signal Time > Latest Long Signal Time AND high >= entry price * (1 + stop-loss percentage) AND barssince(Recorded Short Signal Open != Recorded Short Signal Open[1]) > 0
Exit: long, ATR-derived stop mode AND low <= Long ATR Stop AND barssince(Recorded Long Signal Open != Recorded Long Signal Open[1]) > 0
Exit: short, ATR-derived stop mode AND high >= Short ATR Stop AND barssince(Recorded Short Signal Open != Recorded Short Signal Open[1]) > 0