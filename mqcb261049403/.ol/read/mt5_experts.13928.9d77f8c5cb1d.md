Calculation: KPrmSt oscillator = EMA(P2) of the close’s percentage position within the high-low range formed by the highest P4-bar high and lowest P4-bar low across the outer P1-bar lookback; use 50 if the range is zero. Round to an integer for comparisons. Calculate on the chart timeframe.
Calculation: KPrmSt signal = EMA(P3) of the unrounded KPrmSt oscillator, rounded to an integer for comparisons. Calculate on the chart timeframe.
Long: On the last completed bar, KPrmSt oscillator > KPrmSt signal AND on the preceding completed bar, KPrmSt oscillator <= KPrmSt signal
Short: On the last completed bar, KPrmSt oscillator < KPrmSt signal AND on the preceding completed bar, KPrmSt oscillator >= KPrmSt signal
Exit: long, KPrmSt oscillator < KPrmSt signal on the last completed bar
Exit: short, KPrmSt oscillator > KPrmSt signal on the last completed bar