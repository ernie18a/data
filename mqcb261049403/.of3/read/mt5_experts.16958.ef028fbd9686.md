Calculation: fast MA[n] = MovingAverage(close, shorter lookback, T1 bar n periods ago; n=0 is the forming bar and n=1 is the last completed bar)
Calculation: slow MA[n] = MovingAverage(close, longer lookback, T1 bar n periods ago; n=0 is the forming bar and n=1 is the last completed bar)
Long: (long entry enabled AND fast MA[1] > slow MA[1] AND fast MA[0] < slow MA[0]) OR (long position AND integer-truncated point distance from the most recent long entry price to current ask > add-distance parameter)
Short: (short entry enabled AND fast MA[1] < slow MA[1] AND fast MA[0] > slow MA[0]) OR (short position AND integer-truncated point distance from current bid to the most recent short entry price > add-distance parameter)
Exit: Long, long exit enabled AND fast MA[1] < slow MA[1]
Exit: Short, short exit enabled AND fast MA[1] > slow MA[1]