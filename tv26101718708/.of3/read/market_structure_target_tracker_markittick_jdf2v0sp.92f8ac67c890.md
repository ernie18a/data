Calculation: Swing High = most recent Pivot High(high, swing length, swing length) confirmed on or before the current bar
Calculation: Swing Low = most recent Pivot Low(low, swing length, swing length) confirmed on or before the current bar
Calculation: Prior Swing High = the Swing High that was most recent before the current Swing High
Calculation: Prior Swing Low = the Swing Low that was most recent before the current Swing Low
Calculation: HTF RSI = RSI(close, HTF RSI length, T1)[1] computed on T1 bars, taken at the last completed T1 bar
Long: close crosses above Swing High AND HTF RSI > RSI threshold
Short: close crosses below Swing Low AND HTF RSI < RSI threshold
Exit: long, close < Swing Low at latest long entry OR high >= Prior Swing High at latest long entry
Exit: short, close > Swing High at latest short entry OR low <= Prior Swing Low at latest short entry