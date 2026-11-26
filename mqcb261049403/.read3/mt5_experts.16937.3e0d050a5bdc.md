Calculation: Fast main = Adaptive CG Oscillator main line(close, fast parameters, T2, current bar at close)
Calculation: Fast trigger = Adaptive CG Oscillator trigger line(close, fast parameters, T2, current bar at close)
Calculation: Slow main = Adaptive CG Oscillator main line(close, slow parameters, T1, still-forming T1 bar mapped to chart bars)
Calculation: Slow trigger = Adaptive CG Oscillator trigger line(close, slow parameters, T1, still-forming T1 bar mapped to chart bars)
Long: Fast main <= Fast trigger AND Fast main[1] > Fast trigger[1] AND Slow main > Slow trigger
Short: Fast main >= Fast trigger AND Fast main[1] < Fast trigger[1] AND Slow main < Slow trigger
Exit: long, Slow main < Slow trigger OR Fast main[1] < Fast trigger[1]
Exit: short, Slow main > Slow trigger OR Fast main[1] > Fast trigger[1]