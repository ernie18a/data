Calculation: DEMA = double exponential moving average of close, long lookback
Calculation: Band = ATR(short lookback, shorter than TPUnit's ATR lookback) * band factor
Calculation: Adj = on the first bar equals DEMA; afterwards Adj = min(max(Adj[1], DEMA - Band), DEMA + Band)
Calculation: TPUnit = ATR(lookback much longer than Band's ATR lookback) * TP factor, taken on the entry bar and held fixed for that trade; entry price = close of the entry bar
Long: Adj > Adj[2] AND Adj[1] <= Adj[3] (Adj crosses above its value 2 bars earlier), evaluated on the completed bar, AND current position is not long (flat or short)
Short: Adj < Adj[2] AND Adj[1] >= Adj[3] (Adj crosses below its value 2 bars earlier), evaluated on the completed bar, AND current position is long
Exit: long, Adj < Adj[2] AND Adj[1] >= Adj[3] (full close, reverses to short)
Exit: short, Adj > Adj[2] AND Adj[1] <= Adj[3] (full close, reverses to long)
Exit: long, high > entry price + k * TPUnit for k = 1, 2, 3 (each level triggers once and closes a partial fraction of the position; the position is fully closed after all three have triggered)
Exit: short, low < entry price - k * TPUnit for k = 1, 2, 3 (each level triggers once and closes a partial fraction of the position; the position is fully closed after all three have triggered)