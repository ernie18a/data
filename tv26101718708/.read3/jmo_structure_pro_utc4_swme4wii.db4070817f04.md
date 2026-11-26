Calculation: InBand(T) = EMA(close, trend fast length) is between EMA(close, HTF fast length, T, last completed bar) and EMA(close, HTF slow length, T, last completed bar), inclusive, OR EMA(close, trend slow length) is between EMA(close, HTF fast length, T, last completed bar) and EMA(close, HTF slow length, T, last completed bar), inclusive
Calculation: DemandBase(T) = on bars of T with bar 0 the last completed bar, the most recent bar k with 2 <= k <= lookback length + 1 that closes below its open, lies inside any of session windows 1-6, and whose bars k-1 and k+1 both do not close below their open (undefined if none)
Calculation: SupplyBase(T) = on bars of T with bar 0 the last completed bar, the most recent bar k with 2 <= k <= lookback length + 1 that closes above its open, lies inside any of session windows 1-6, and whose bars k-1 and k+1 both do not close above their open (undefined if none)
Calculation: DemandPush(T) = on bars of T with bar 0 the last completed bar, close[1] > open[1] AND abs(close - open)[1] >= push strength * SMA(abs(close - open), body average length)[1] AND close[1] > high of DemandBase(T)
Calculation: SupplyPush(T) = on bars of T with bar 0 the last completed bar, close[1] < open[1] AND abs(close - open)[1] >= push strength * SMA(abs(close - open), body average length)[1] AND close[1] < low of SupplyBase(T)
Long: (chart timeframe <= T1 OR chart timeframe <= T2) AND InBand(T6) AND NOT InBand(T6)[1]
Long: (chart timeframe <= T1 OR chart timeframe <= T2) AND InBand(T7) AND NOT InBand(T7)[1]
Long: (chart timeframe <= T1 OR chart timeframe <= T2) AND InBand(T8) AND NOT InBand(T8)[1]
Long: chart timeframe <= T1 AND DemandPush(T1) AND datetime of DemandBase(T1) != datetime of last zone base marked on T1
Long: chart timeframe <= T2 AND DemandPush(T2) AND datetime of DemandBase(T2) != datetime of last zone base marked on T2
Long: chart timeframe <= T3 AND DemandPush(T3) AND datetime of DemandBase(T3) != datetime of last zone base marked on T3
Short: chart timeframe <= T1 AND SupplyPush(T1) AND datetime of SupplyBase(T1) != datetime of last zone base marked on T1
Short: chart timeframe <= T2 AND SupplyPush(T2) AND datetime of SupplyBase(T2) != datetime of last zone base marked on T2
Short: chart timeframe <= T3 AND SupplyPush(T3) AND datetime of SupplyBase(T3) != datetime of last zone base marked on T3
Long: EMA(close, trend fast length) > EMA(close, trend slow length)
Short: EMA(close, trend fast length) <= EMA(close, trend slow length)
Long: EMA(close, trend fast length) > EMA(close, trend mid length) AND EMA(close, trend mid length) > EMA(close, trend slow length)
Short: EMA(close, trend fast length) < EMA(close, trend mid length) AND EMA(close, trend mid length) < EMA(close, trend slow length)
Long: EMA(close, trend fast length, T3, last completed bar) > EMA(close, trend slow length, T3, last completed bar)
Short: EMA(close, trend fast length, T3, last completed bar) <= EMA(close, trend slow length, T3, last completed bar)
Long: EMA(close, trend fast length, T3, last completed bar) > EMA(close, trend mid length, T3, last completed bar) AND EMA(close, trend mid length, T3, last completed bar) > EMA(close, trend slow length, T3, last completed bar)
Short: EMA(close, trend fast length, T3, last completed bar) < EMA(close, trend mid length, T3, last completed bar) AND EMA(close, trend mid length, T3, last completed bar) < EMA(close, trend slow length, T3, last completed bar)
Long: EMA(close, trend fast length, T4, last completed bar) > EMA(close, trend slow length, T4, last completed bar)
Short: EMA(close, trend fast length, T4, last completed bar) <= EMA(close, trend slow length, T4, last completed bar)
Long: EMA(close, trend fast length, T4, last completed bar) > EMA(close, trend mid length, T4, last completed bar) AND EMA(close, trend mid length, T4, last completed bar) > EMA(close, trend slow length, T4, last completed bar)
Short: EMA(close, trend fast length, T4, last completed bar) < EMA(close, trend mid length, T4, last completed bar) AND EMA(close, trend mid length, T4, last completed bar) < EMA(close, trend slow length, T4, last completed bar)
Long: EMA(close, trend fast length, T5, last completed bar) > EMA(close, trend slow length, T5, last completed bar)
Short: EMA(close, trend fast length, T5, last completed bar) <= EMA(close, trend slow length, T5, last completed bar)
Long: EMA(close, trend fast length, T5, last completed bar) > EMA(close, trend mid length, T5, last completed bar) AND EMA(close, trend mid length, T5, last completed bar) > EMA(close, trend slow length, T5, last completed bar)
Short: EMA(close, trend fast length, T5, last completed bar) < EMA(close, trend mid length, T5, last completed bar) AND EMA(close, trend mid length, T5, last completed bar) < EMA(close, trend slow length, T5, last completed bar)
Long: EMA(close, trend fast length, T6, last completed bar) > EMA(close, trend slow length, T6, last completed bar)
Short: EMA(close, trend fast length, T6, last completed bar) <= EMA(close, trend slow length, T6, last completed bar)
Long: EMA(close, trend fast length, T6, last completed bar) > EMA(close, trend mid length, T6, last completed bar) AND EMA(close, trend mid length, T6, last completed bar) > EMA(close, trend slow length, T6, last completed bar)
Short: EMA(close, trend fast length, T6, last completed bar) < EMA(close, trend mid length, T6, last completed bar) AND EMA(close, trend mid length, T6, last completed bar) < EMA(close, trend slow length, T6, last completed bar)
Long: EMA(close, trend fast length, T7, last completed bar) > EMA(close, trend slow length, T7, last completed bar)
Short: EMA(close, trend fast length, T7, last completed bar) <= EMA(close, trend slow length, T7, last completed bar)
Long: EMA(close, trend fast length, T7, last completed bar) > EMA(close, trend mid length, T7, last completed bar) AND EMA(close, trend mid length, T7, last completed bar) > EMA(close, trend slow length, T7, last completed bar)
Short: EMA(close, trend fast length, T7, last completed bar) < EMA(close, trend mid length, T7, last completed bar) AND EMA(close, trend mid length, T7, last completed bar) < EMA(close, trend slow length, T7, last completed bar)
Long: EMA(close, trend fast length, T8, last completed bar) > EMA(close, trend slow length, T8, last completed bar)
Short: EMA(close, trend fast length, T8, last completed bar) <= EMA(close, trend slow length, T8, last completed bar)
Long: EMA(close, trend fast length, T8, last completed bar) > EMA(close, trend mid length, T8, last completed bar) AND EMA(close, trend mid length, T8, last completed bar) > EMA(close, trend slow length, T8, last completed bar)
Short: EMA(close, trend fast length, T8, last completed bar) < EMA(close, trend mid length, T8, last completed bar) AND EMA(close, trend mid length, T8, last completed bar) < EMA(close, trend slow length, T8, last completed bar)