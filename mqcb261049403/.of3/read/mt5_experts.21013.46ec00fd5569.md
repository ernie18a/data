Calculation: Oscillator = MA(MA((selected applied price - MA(selected applied price, price lookback, selected smoothing method))/minimum price increment, first smoothing lookback, selected smoothing method), second smoothing lookback, selected smoothing method), evaluated on T1 bars; [0] is the selected signal bar, which may be forming, and [n] is n T1 bars earlier
Calculation: Signal line = MA(Oscillator, signal smoothing lookback, selected smoothing method), evaluated on T1 bars
Long: long entry enabled AND Oscillator[1] <= 0 AND Oscillator[0] > 0
Long: long entry enabled AND Oscillator[2] > Oscillator[1] AND Oscillator[0] > Oscillator[1]
Long: long entry enabled AND Oscillator[1] <= Signal line[1] AND Oscillator[0] > Signal line[0]
Short: short entry enabled AND Oscillator[1] >= 0 AND Oscillator[0] < 0
Short: short entry enabled AND Oscillator[2] < Oscillator[1] AND Oscillator[0] < Oscillator[1]
Short: short entry enabled AND Oscillator[1] >= Signal line[1] AND Oscillator[0] < Signal line[0]
Exit: long, long exit enabled AND Oscillator[0] < 0
Exit: long, long exit enabled AND Oscillator[0] < Oscillator[1]
Exit: long, long exit enabled AND Oscillator[0] < Signal line[0]
Exit: short, short exit enabled AND Oscillator[0] > 0
Exit: short, short exit enabled AND Oscillator[0] > Oscillator[1]
Exit: short, short exit enabled AND Oscillator[0] > Signal line[0]
Exit: long, low <= entry price - stop-loss points × minimum price increment OR high >= entry price + take-profit points × minimum price increment
Exit: short, high >= entry price + stop-loss points × minimum price increment OR low <= entry price - take-profit points × minimum price increment
Exit: long, time-window exits enabled AND broker server time is outside the configured trading interval
Exit: short, time-window exits enabled AND broker server time is outside the configured trading interval