Calculation: Range(L) = Highest(high, L) - Lowest(low, L)
Calculation: Zone(L, deep, shallow) = [low, high] with low = Highest(high, L) - Range(L)*deep and high = Highest(high, L) - Range(L)*shallow, where deep > shallow
Calculation: Common(X1, ..., Xn) = [max of the lows, min of the highs]
Calculation: BestZone(A, B, C) = the first of Common(A, B, C), Common(A, B), Common(A, C), Common(B, C) whose low < high, otherwise A
Calculation: BuyZone = BestZone(Zone(L1, fibBuyDeep, fibBuyShallow), Zone(L2, fibBuyDeep, fibBuyShallow), Zone(L3, fibBuyDeep, fibBuyShallow)), where L1 > L2 > L3
Calculation: SellZone = BestZone(Zone(L1, fibSellDeep, fibSellShallow), Zone(L2, fibSellDeep, fibSellShallow), Zone(L3, fibSellDeep, fibSellShallow)), where L1 > L2 > L3
Calculation: Signed(c) = +1 if c is true, otherwise -1
Calculation: Bias = w_rsi*(RSI midline - RSI(close, RSI lookback))/50 + w_ema*Signed(EMA(close, shorter lookback) > EMA(close, longer lookback)) + w_sma*Signed(close > SMA(close, SMA lookback)) + w_emamom*Signed(EMA(close, shorter lookback) > EMA(close, shorter lookback)[lag]) + w_rsimom*Signed(RSI(close, RSI lookback) > RSI(close, RSI lookback)[lag]) + w_fib*(0.5 - (close - Lowest(low, L1))/Range(L1)) + (volume > SMA(volume, volume lookback) ? w_vol*Signed(close >= open) : 0)
Calculation: VolumePOC = midpoint of the bin with the largest summed volume over the last L1 bars, where [Lowest(low, L1), Highest(high, L1)] is split into bin count equal bins and each bar adds its volume to every bin its [low, high] overlaps; present only on the last bar
Calculation: LongEntry = VolumePOC if VolumePOC is present and BuyZone.low <= VolumePOC <= BuyZone.high, otherwise BuyZone.low
Calculation: ShortEntry = VolumePOC if VolumePOC is present and SellZone.low <= VolumePOC <= SellZone.high, otherwise SellZone.high
Calculation: RR(entry, target, stop) = Round(Abs(target - entry) / Abs(entry - stop), RR decimals)
Long: close >= BuyZone.low AND close <= BuyZone.high
Long: close >= BuyZone.low AND close <= BuyZone.high AND Round(50 + 0.5*Bias) >= percent threshold AND RSI(close, RSI lookback) <= RSI midline AND EMA(close, shorter lookback) >= EMA(close, longer lookback) AND RR(LongEntry, Highest(high, L1) - Range(L1)*fibTargetBuy, LongEntry*(1 - stop buffer/100)) >= min RR
Short: close >= SellZone.low AND close <= SellZone.high
Short: close >= SellZone.low AND close <= SellZone.high AND Round(50 - 0.5*Bias) >= percent threshold AND RSI(close, RSI lookback) >= RSI midline AND EMA(close, shorter lookback) <= EMA(close, longer lookback) AND RR(ShortEntry, Highest(high, L1) - Range(L1)*fibTargetSell, ShortEntry*(1 + stop buffer/100)) >= min RR