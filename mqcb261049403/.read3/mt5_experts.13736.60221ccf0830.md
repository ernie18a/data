Calculation: O = JJMA(100*(applied price-(XMA(applied price, shared lookback, method 1, phase 1)-XMA(high-low, shared lookback, method 2, phase 2)))/(2*XMA(high-low, shared lookback, method 2, phase 2))-50, final lookback, final phase), calculated on T1 bars
Long: on chart bars using T1 values, O(T1, previous completed bar)>upper threshold AND O(T1, current bar at close)<=upper threshold
Short: on chart bars using T1 values, O(T1, previous completed bar)<lower threshold AND O(T1, current bar at close)>=lower threshold
Exit: long, on chart bars using T1 values, O(T1, last completed bar)<0
Exit: short, on chart bars using T1 values, O(T1, last completed bar)>0