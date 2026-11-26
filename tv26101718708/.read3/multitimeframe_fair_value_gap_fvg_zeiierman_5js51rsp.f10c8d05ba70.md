Calculation: Cumulative T1 body average = running arithmetic mean of abs(close − open) over T1 bars, including the current still-forming bar
Calculation: FVG trend average = on each new qualifying bullish or bearish FVG, average(chart-bar OHLC4, prior FVG trend average); otherwise prior FVG trend average, starting at 0
Long: On chart bars taking values from the still-forming T1 bar, low(T1) > high(T1, two bars ago) AND close(T1) > high(T1, two bars ago) AND the raw bullish gap condition was false on the previous chart bar AND abs(close(T1) − open(T1)) >= cumulative T1 body average × sensitivity parameter
Short: On chart bars taking values from the still-forming T1 bar, high(T1) < low(T1, two bars ago) AND close(T1) < low(T1, two bars ago) AND the raw bearish gap condition was false on the previous chart bar AND abs(close(T1) − open(T1)) >= cumulative T1 body average × sensitivity parameter
Long: FVG trend average > its value on the previous chart bar
Short: FVG trend average < its value on the previous chart bar
Long: For each existing FVG table row, chart close >= the row's gap bottom
Short: For each existing FVG table row, chart close < the row's gap bottom