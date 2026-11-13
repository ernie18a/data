Calculation: Offset = stdev(close, n_vol)/sqrt(n_vol) * volatility multiplier
Calculation: FastUB = EMA(close, n_fast)*(1+fast margin %) + Offset; FastLB = EMA(close, n_fast)*(1-fast margin %) - Offset
Calculation: SlowUB = EMA(EMA(close, n_slow), n_slow)*(1+slow margin %) + Offset; SlowLB = EMA(EMA(close, n_slow), n_slow)*(1-slow margin %) - Offset
Calculation: FastHMA = Hull moving average of close with a short length, not longer than n_fast
Calculation: Calm = abs(stdev(close, Lt)/close * restriction scale)*100 < sensitivity + weight*(close - close[Ll])/close, where Ll (long-term lookback) is longer than Lt (trend lookback)
Calculation: VolMA = EMA(volume, n_v); VolCut = EMA(VolMA[1]*(1 - cutoff %), short length)
Calculation: RocSm = EMA(ROC(close, Lr) in percent, Ls), where Ls is shorter than Lr
Calculation: OBVCorr = correlation(close, OBV, n_obv)
Calculation: StopPct = base stop % * (1 + stdev(close, Lt)*scale/close)
Long: position is not short AND OBVCorr > threshold AND FastHMA < FastUB AND FastLB < SlowLB AND (NOT Calm OR (close > close[Lt] AND close < close[1] AND VolMA < VolCut AND abs(RocSm) < ROC cutoff))
Short: position is not long AND OBVCorr > threshold AND FastHMA > FastUB AND FastUB > SlowUB AND (NOT Calm OR (close < close[Lt] AND close > close[1] AND VolMA < VolCut AND abs(RocSm) < ROC cutoff))
Exit: long, FastHMA > FastUB AND FastLB > SlowUB
Exit: short, FastHMA < FastLB AND FastUB < SlowLB
Exit: long, FastHMA crosses above FastUB (FastHMA > FastUB AND FastHMA[1] <= FastUB[1]) AND FastLB > SlowUB
Exit: short, FastHMA crosses below FastLB (FastHMA < FastLB AND FastHMA[1] >= FastLB[1]) AND FastUB < SlowLB
Exit: long, low <= entry price*(1 - StopPct/100)
Exit: short, high >= entry price*(1 + StopPct/100)