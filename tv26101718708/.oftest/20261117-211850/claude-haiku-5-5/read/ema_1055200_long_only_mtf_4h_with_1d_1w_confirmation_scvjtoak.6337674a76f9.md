Calculation: EMA_A = exponential moving average of close with length A over primary timeframe bars, where A < B < C < D
Calculation: EMA_B = exponential moving average of close with length B over primary timeframe bars
Calculation: EMA_C = exponential moving average of close with length C over primary timeframe bars
Calculation: EMA_D = exponential moving average of close with length D over primary timeframe bars
Calculation: HTF_EMA_E = exponential moving average of close with length E computed on timeframe T1 bars, value taken from the last completed T1 bar, where E < F and T1 < T2 and both T1 and T2 are higher than the primary timeframe
Calculation: HTF_EMA_F = exponential moving average of close with length F computed on timeframe T1 bars, value taken from the last completed T1 bar
Calculation: HTF_EMA_G = exponential moving average of close with length G computed on timeframe T2 bars, value taken from the last completed T2 bar, where G < H
Calculation: HTF_EMA_H = exponential moving average of close with length H computed on timeframe T2 bars, value taken from the last completed T2 bar
Long: EMA_A crosses above EMA_B AND high > EMA_B AND HTF_EMA_E > HTF_EMA_F AND HTF_EMA_G > HTF_EMA_H
Long: EMA_B crosses above EMA_C AND HTF_EMA_E > HTF_EMA_F AND HTF_EMA_G > HTF_EMA_H
Long: EMA_A crosses above EMA_D AND HTF_EMA_E > HTF_EMA_F AND HTF_EMA_G > HTF_EMA_H
Exit: long, EMA_A crosses below EMA_C OR EMA_A crosses below EMA_D
Exit: long, low <= entry price * (1 - stop percentage P)