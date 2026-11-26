Calculation: BullT(Tn) = close(Tn, last completed bar) > MA(close, MA lookback, MA type, Tn, last completed bar) AND close(Tn, last completed bar) > Supertrend(ATR lookback, factor, Tn, last completed bar)
Calculation: BearT(Tn) = close(Tn, last completed bar) < MA(close, MA lookback, MA type, Tn, last completed bar) AND close(Tn, last completed bar) < Supertrend(ATR lookback, factor, Tn, last completed bar)
Calculation: MaxScore = sum over enabled Tn of weight(Tn)
Calculation: BullScore = sum over enabled Tn of weight(Tn)*BullT(Tn) + [close > MA(close, MA lookback, MA type) AND close > Supertrend(ATR lookback, factor)]
Calculation: BearScore = sum over enabled Tn of weight(Tn)*BearT(Tn) + [close < MA(close, MA lookback, MA type) AND close < Supertrend(ATR lookback, factor)]
Calculation: UltraStrong = ultra mode AND ADX filter enabled AND ADX(ADX lookback) >= ADX threshold + ADX margin
Calculation: Restricted = (ADX filter enabled AND ADX(ADX lookback) < ADX threshold) OR close = MA(close, MA lookback, MA type) OR close = Supertrend(ATR lookback, factor) OR (T1 enabled AND NOT BullT(T1) AND NOT BearT(T1)) OR (T2 enabled AND NOT BullT(T2) AND NOT BearT(T2))
Calculation: BullCond = close > MA(close, MA lookback, MA type) AND (UltraStrong OR close > Supertrend(ATR lookback, factor))
Calculation: BearCond = close < MA(close, MA lookback, MA type) AND (UltraStrong OR close < Supertrend(ATR lookback, factor))
Calculation: BuySig = BullCond AND close > close[1] AND (UltraStrong OR close > high[1]) AND (NOT BullCond[1] OR (EndBlocked[1] AND NOT Restricted))
Calculation: SellSig = BearCond AND close < close[1] AND (UltraStrong OR close < low[1]) AND (NOT BearCond[1] OR (EndBlocked[1] AND NOT Restricted))
Calculation: EndBlocked = Restricted OR (ultra mode AND NOT UltraStrong) OR (BuySig AND BullScore < score fraction*MaxScore) OR (SellSig AND BearScore < score fraction*MaxScore)
Long: BuySig
Long: BuySig AND NOT Restricted
Short: SellSig
Short: SellSig AND NOT Restricted