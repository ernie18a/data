Calculation: Cumulative volume delta = running sum over T1 bars of the volume delta of each T1 bar, restarted at the open of each T2 bar, using the T1 bar still forming
Calculation: Bar volume delta = Cumulative volume delta at the close of the chart bar still forming - Cumulative volume delta at the open of that chart bar
Calculation: Volume delta RSI = balance level if RMA(max(Bar volume delta, 0), RSI length) = 0 and RMA(max(-Bar volume delta, 0), RSI length) = 0; 100 if RMA(max(-Bar volume delta, 0), RSI length) = 0; otherwise 100 - 100 / (1 + RMA(max(Bar volume delta, 0), RSI length) / RMA(max(-Bar volume delta, 0), RSI length))
Long: Volume delta RSI >= balance level
Short: Volume delta RSI < balance level