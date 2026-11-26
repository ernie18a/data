Calculation: Chart-bar CVD delta = sum of volume × sign(close − close[1]) over T1 bars within each chart bar, including the still-forming T1 bar
Calculation: Chart-bar CVD acceleration = current chart-bar CVD delta − prior chart-bar CVD delta
Calculation: Profile CVD at each price bin = cumulative sum since profile start of each T1 bar’s volume × sign(close − close[1]), divided equally among the bins between that bar’s low and high; computed on chart bars using T1 bars, including the still-forming bars
Calculation: Profile buy and sell volume at each price bin = the latest positive and negative T1-bar volume allocations since profile start, each divided equally among the bins between that bar’s low and high; update only the corresponding side and retain the other side
Long: Chart-bar CVD delta >= 0
Short: Chart-bar CVD delta < 0
Long: Chart-bar CVD acceleration >= 0
Short: Chart-bar CVD acceleration < 0
Long: Profile CVD > 0
Short: Profile CVD < 0
Long: Profile buy volume >= Profile sell volume AND Profile buy volume > 0
Short: Profile buy volume < Profile sell volume OR Profile buy volume = 0 AND Profile sell volume = 0