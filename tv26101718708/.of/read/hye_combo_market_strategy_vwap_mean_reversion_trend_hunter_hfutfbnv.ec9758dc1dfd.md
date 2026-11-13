Calculation: VWAP(n) = sum(typical price * volume, n) / sum(volume, n), typical price = (high+low+close)/3, rolling over the last n bars
Calculation: Mid(x,n) = (highest(x,n) + lowest(x,n)) / 2
Calculation: Lead(t,k) = average of Mid(VWAP(t),t) and Mid(VWAP(k),k), with k > t (kijun period longer than tenkan period)
Calculation: FastLead = Lead(t,k) with shorter periods than SlowLead = Lead(t,k)
Calculation: BBlead = average(FastLead, SlowLead); UpperBB = SMA(BBlead,n) + mult * stdev(BBlead,n)
Calculation: TSV = sum over n bars of (volume * (close - previous close)), counting only bars where close differs from previous close; TSVema = EMA(TSV,m) with m shorter than n
Calculation: Vidya = alpha*|CMO|*hl2 + (1 - alpha*|CMO|)*Vidya[1], alpha = 2/(n+1), CMO = (sum of positive hl2 changes - sum of absolute negative hl2 changes) / (sum of positive + sum of absolute negative changes) over n bars
Calculation: RsiEma = EMA(RSI(close, short period), m)
Calculation: BuyLevel = (1 - pct/100) * BigVWAP
Long: flat AND SmallVWAP crosses under BuyLevel (SmallVWAP lookback shorter than BigVWAP lookback) AND RsiEma < max RSI level AND close < MeanVWAP (MeanVWAP lookback longer than both SmallVWAP and BigVWAP lookbacks)
Long: flat AND FastLead > FastLead[1] AND SlowLead > SlowLead[1] AND TSV > 0 AND TSV > TSVema AND close > UpperBB AND close > Vidya
Exit: long opened by the mean-reversion Long, close > MeanVWAP
Exit: long opened by the trend Long, FastLead < FastLead[1] AND SlowLead < SlowLead[1]