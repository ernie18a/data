Calculation: Confirmed pivot low or high = a low or high confirmed using equal numbers of chart bars to its left and right; the latest pivot includes one confirmed on the current bar.
Calculation: Bullish sweep = low < latest confirmed pivot low AND open > that pivot low AND close > that pivot low AND low = lowest low over the pivot's left lookback including the current bar AND lowest close over that lookback >= that pivot low.
Calculation: Bearish sweep = high > latest confirmed pivot high AND open < that pivot high AND close < that pivot high AND high = highest high over the pivot's left lookback including the current bar AND highest close over that lookback <= that pivot high.
Long: Bullish sweep.
Short: Bearish sweep.
Long: Bullish sweep on the bar three bars ago AND each of the current and two preceding closes > the latest confirmed pivot low on its respective bar AND bars since the previous occurrence of this condition >= the bullish cooldown; initialize the previous occurrence at bar index zero.
Short: Bearish sweep on the bar three bars ago AND each of the current and two preceding closes < the latest confirmed pivot high on its respective bar AND bars since the previous occurrence of this condition >= the bearish cooldown; initialize the previous occurrence at bar index zero.
Long: A pivot low is confirmed on the current bar AND bullish sweep was false on the pivot bar.
Short: A pivot high is confirmed on the current bar AND bearish sweep was false on the pivot bar.