Calculation: Hull line(T1,n) = MA(2*MA(applied price, floor(lookback/2), method, phase) - MA(applied price, lookback, method, phase), floor(sqrt(lookback)), method, phase) on T1 at offset n; n=0 is the forming bar, n=1 is the last completed bar, and larger n values are older completed bars; evaluated on T1 bar updates for n>0 and each tick for n=0
Calculation: Smoothed Hull line(T1,n) = MA(Hull line(T1,n), floor(sqrt(lookback)), method, phase)
Long: Hull line(T1,n) crosses above Smoothed Hull line(T1,n)
Short: Hull line(T1,n) crosses below Smoothed Hull line(T1,n)
Exit: long, Hull line(T1,n) < Smoothed Hull line(T1,n)
Exit: short, Hull line(T1,n) > Smoothed Hull line(T1,n)