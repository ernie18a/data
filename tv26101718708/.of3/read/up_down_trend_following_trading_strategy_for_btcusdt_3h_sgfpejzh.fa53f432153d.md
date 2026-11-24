Calculation: RsiLevel(n) = bucket width * floor(RSI(close, n) / bucket width)
Calculation: RviLevel(n) = bucket width * floor(RVI(n) / bucket width)
Calculation: MfiLevel(n) = bucket width * floor(MFI(n) / bucket width)
Calculation: BopAvg = SMA(50 + 100 * BOP, BOP average length)
Calculation: RsiLow(t) = RsiLevel(RSI long period) <= t AND RsiLevel(RSI medium period) < RsiLevel(RSI long period) AND RsiLevel(RSI short period) <= RsiLevel(RSI medium period), with RSI short period < RSI medium period < RSI long period
Calculation: RsiHigh(t) = RsiLevel(RSI long period) >= t AND RsiLevel(RSI medium period) > RsiLevel(RSI long period) AND RsiLevel(RSI short period) >= RsiLevel(RSI medium period), with RSI short period < RSI medium period < RSI long period
Calculation: RviLow(t) = RviLevel(RVI long period) <= t AND RviLevel(RVI medium period) <= RviLevel(RVI long period) AND RviLevel(RVI short period) <= RviLevel(RVI medium period), with RVI short period < RVI medium period < RVI long period
Calculation: RviHigh(t) = RviLevel(RVI long period) >= t AND RviLevel(RVI medium period) >= RviLevel(RVI long period) AND RviLevel(RVI short period) >= RviLevel(RVI medium period), with RVI short period < RVI medium period < RVI long period
Calculation: MfiLow(t) = MfiLevel(MFI long period) <= t AND MfiLevel(MFI medium period) <= MfiLevel(MFI long period) AND MfiLevel(MFI short period) <= MfiLevel(MFI medium period), with MFI short period < MFI medium period < MFI long period
Calculation: MfiHigh(t) = MfiLevel(MFI long period) >= t AND MfiLevel(MFI medium period) >= MfiLevel(MFI long period) AND MfiLevel(MFI short period) >= MfiLevel(MFI medium period), with MFI short period < MFI medium period < MFI long period
Calculation: LowRegime = RsiLow(RSI low threshold) AND RviLow(RVI low threshold) AND MfiLow(MFI low threshold) AND BopAvg <= BOP low threshold
Calculation: CritLow = RsiLow(critical low threshold) AND RviLow(critical low threshold) AND MfiLow(critical low threshold) AND BopAvg <= critical low BOP threshold
Calculation: CritHigh = RsiHigh(critical high threshold) AND RviHigh(critical high threshold) AND MfiHigh(critical high threshold) AND BopAvg >= critical high threshold
Calculation: GenHigh = RsiHigh(RSI high threshold) AND RviHigh(RVI high threshold) AND MfiHigh(MFI high threshold) AND BopAvg >= BOP high threshold
Calculation: LowEnd = LowRegime[1] AND NOT LowRegime
Calculation: LowBand = Lowest(low, low lookback)
Calculation: BuyStage = 1 if cross(LowBand, low) AND LowBand[1] > LowBand; else 2 if BuyStage[1] = 1 AND (open > close OR open[2] > close); else 0
Calculation: UpLine = SMA(SuperTrend(supertrend factor, supertrend ATR length) if SuperTrend is in uptrend, else NA, trend SMA length)
Calculation: DownLine = SMA(SuperTrend(supertrend factor, supertrend ATR length) if SuperTrend is in downtrend, else NA, trend SMA length)
Calculation: TrendUpAll = high >= DownLine AND high >= UpLine AND high >= SMA(high, high SMA length) AND high >= SAR(SAR start, SAR increment, SAR maximum) AND ALMA(open, ALMA window, ALMA offset, ALMA sigma) > ALMA(open, ALMA window, ALMA offset, ALMA sigma)[1]
Calculation: UpPartialA = low < SMA(high, high SMA length) AND high >= DownLine AND high >= UpLine AND high >= SAR(SAR start, SAR increment, SAR maximum)
Calculation: UpPartialB = low < DownLine AND low < UpLine AND high >= SMA(high, high SMA length) AND high >= SAR(SAR start, SAR increment, SAR maximum) AND ALMA(open, ALMA window, ALMA offset, ALMA sigma) > ALMA(open, ALMA window, ALMA offset, ALMA sigma)[1]
Calculation: TrendDownAll = low < DownLine AND low < UpLine AND low < SMA(high, high SMA length) AND low < SAR(SAR start, SAR increment, SAR maximum) AND ALMA(open, ALMA window, ALMA offset, ALMA sigma) < ALMA(open, ALMA window, ALMA offset, ALMA sigma)[1]
Calculation: DownPartialA = low < SMA(high, high SMA length) AND low < SAR(SAR start, SAR increment, SAR maximum) AND high >= DownLine AND high >= UpLine
Calculation: DownPartialB = low < SAR(SAR start, SAR increment, SAR maximum) AND high >= DownLine AND high >= UpLine AND high >= SMA(high, high SMA length)
Calculation: DownPartialC = high >= UpLine AND low < DownLine AND low < SAR(SAR start, SAR increment, SAR maximum) AND low < SMA(high, high SMA length)
Calculation: DownPartialD = high >= UpLine AND low < DownLine AND low < SAR(SAR start, SAR increment, SAR maximum)
Calculation: TakeProfit = entry price * (1 + take-profit percent) if position size increased; NA if position side flat; otherwise TakeProfit[1]
Long: (BuyStage = 2 OR LowEnd) AND datetime within date range AND position side flat on the current bar AND position side flat on each of the previous cooldown bars
Long: (LowEnd OR low crosses under entry price * (1 - drop 1) OR low crosses under entry price * (1 - drop 2) OR low crosses under entry price * (1 - drop 3) OR low crosses under entry price * (1 - drop 4) OR (TrendUpAll AND NOT TrendUpAll[1]) OR (UpPartialA AND NOT UpPartialA[1]) OR (UpPartialB AND NOT UpPartialB[1])) AND SMA(low, low SMA length) < entry price * (1 - add discount) AND falling(SMA(close, close SMA length), falling bars) AND datetime within date range, with drop 1 < drop 2 < drop 3 < drop 4
Long: BuyStage = 2 AND high[1] < entry price
Long: LowEnd AND SMA(low, low SMA length) < entry price
Long: CritLow AND SMA(low, low SMA length) < entry price
Exit: long, (TrendDownAll OR DownPartialA OR DownPartialB OR DownPartialC OR DownPartialD OR low crosses under entry price * (1 + take-profit percent)) AND datetime within date range AND TakeProfit < SMA(low, low SMA length) AND open entry count >= exit entry count threshold
Exit: long, GenHigh AND datetime within date range AND TakeProfit < SMA(low, low SMA length) AND open entry count < exit entry count threshold
Exit: long, low crosses under entry price * (1 - stop-loss percent) AND open entry count >= stop-loss entry fraction * pyramid limit AND stop-loss enabled
Exit: long, high >= TakeProfit AND (close > entry price OR GenHigh) AND position side flat on each of the previous cooldown bars AND take-profit enabled
Exit: long, CritHigh
Exit: long, GenHigh AND SMA(low, low SMA length) > entry price * (1 + take-profit percent)