Calculation: GaussMA = sum_{i=0..N-1}(w_i*close[i]) / sum(w_i), close[i] = close i bars ago (i=0 is the current bar), w_i = exp(-0.5*((i-m)/sigma)^2), m = floor(offset*(N-1)), offset in 0..1
Calculation: ResidSD = standard deviation over the same N bars of (close - GaussMA)
Calculation: Upper = GaussMA + k*ResidSD; Lower = GaussMA - k*ResidSD; MidUpper = GaussMA + 0.5*k*ResidSD; MidLower = GaussMA - 0.5*k*ResidSD
Calculation: SlopeNorm = ((GaussMA - GaussMA 5 bars ago)/5) / ATR; TrendUp = SlopeNorm > small positive constant; TrendDn = SlopeNorm < the negative of that constant
Calculation: Z = (close - SMA(close,n)) / standard deviation(close,n)
Calculation: VolOK = volume > f * SMA(volume,n), with f > 1
Calculation: CooldownOK(side) = bars since the last signal of that side (any of its three types) > c
Calculation: Entry price = close of the signal bar; ATR_e = ATR on the signal bar
Long: (low <= MidLower AND TrendUp AND Z on the previous bar < negative threshold AND VolOK AND CooldownOK(long)) OR (close crosses above Upper AND ADX > trend level AND DI+ > DI- AND fast EMA(close) > slow EMA(close) AND VolOK AND CooldownOK(long)) OR (fast EMA(close) crosses above slow EMA(close) AND close > GaussMA AND ADX > trend level AND VolOK AND CooldownOK(long))
Short: (high >= MidUpper AND TrendDn AND Z on the previous bar > positive threshold AND VolOK AND CooldownOK(short)) OR (close crosses below Lower AND ADX > trend level AND DI- > DI+ AND fast EMA(close) < slow EMA(close) AND VolOK AND CooldownOK(short)) OR (fast EMA(close) crosses below slow EMA(close) AND close < GaussMA AND ADX > trend level AND VolOK AND CooldownOK(short))
Exit: long, low <= entry price - s*ATR_e (stop loss)
Exit: long, high >= entry price + t1*ATR_e (take profit 1)
Exit: long, high >= entry price + t2*ATR_e (take profit 2)
Exit: short, high >= entry price + s*ATR_e (stop loss)
Exit: short, low <= entry price - t1*ATR_e (take profit 1)
Exit: short, low <= entry price - t2*ATR_e (take profit 2)
Note on parameter relationships: fast EMA length < slow EMA length; s < t1 < t2.