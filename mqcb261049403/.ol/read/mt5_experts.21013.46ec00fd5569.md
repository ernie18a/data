Calculation: Oscillator H = apply a moving average to the selected bar price, subtract that average from the price, and smooth the difference successively with two moving averages using independently chosen lengths. Use the same averaging method for all stages.
Calculation: Signal S = moving average of H using a separately chosen length and the same averaging method.
Calculation: Expert oscillator and signal = H and S calculated on a higher timeframe, using the last completed bar or the still-forming bar according to the selected signal-bar offset; previous values refer to preceding higher-timeframe bars.
Long: Chart-timeframe H > 0 AND H > previous H OR chart-timeframe H < 0 AND H > previous H OR chart-timeframe H > S
Short: Chart-timeframe H > 0 AND H < previous H OR chart-timeframe H < 0 AND H < previous H OR chart-timeframe H < S
Long: Selected zero-crossing mode AND expert H > 0 AND previous expert H <= 0
Short: Selected zero-crossing mode AND expert H < 0 AND previous expert H >= 0
Long: Selected turning-point mode AND expert H > previous expert H AND previous expert H < expert H two bars ago
Short: Selected turning-point mode AND expert H < previous expert H AND previous expert H > expert H two bars ago
Long: Selected signal-crossing mode AND expert H > expert S AND previous expert H <= previous expert S
Short: Selected signal-crossing mode AND expert H < expert S AND previous expert H >= previous expert S
Exit: long, selected zero-crossing mode AND expert H < 0 OR selected turning-point mode AND expert H < previous expert H OR selected signal-crossing mode AND expert H < expert S
Exit: short, selected zero-crossing mode AND expert H > 0 OR selected turning-point mode AND expert H > previous expert H OR selected signal-crossing mode AND expert H > expert S
Exit: long, low <= entry price - stop distance OR high >= entry price + profit distance
Exit: short, high >= entry price + stop distance OR low <= entry price - profit distance
Exit: long, time restriction enabled AND current hour and minute fail all of these comparisons: start hour < end hour AND ((hour = start hour AND minute >= start minute) OR (hour > start hour AND hour < end hour) OR (hour = end hour AND minute < end minute)); start hour = end hour AND hour = start hour AND minute >= start minute AND minute < end minute; start hour > end hour AND ((hour >= start hour AND minute >= start minute) OR hour < end hour OR (hour = end hour AND minute < end minute))
Exit: short, time restriction enabled AND current hour and minute fail all of these comparisons: start hour < end hour AND ((hour = start hour AND minute >= start minute) OR (hour > start hour AND hour < end hour) OR (hour = end hour AND minute < end minute)); start hour = end hour AND hour = start hour AND minute >= start minute AND minute < end minute; start hour > end hour AND ((hour >= start hour AND minute >= start minute) OR hour < end hour OR (hour = end hour AND minute < end minute))