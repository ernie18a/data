Calculation: Bandwidth = BollingerBandwidth(close, compression lookback, BB deviation)
Calculation: Compressed = Bandwidth < compression threshold * SMA(Bandwidth, bandwidth baseline)
Calculation: Separation = ABS(EMA(close, shorter lookback) - EMA(close, longer lookback)) / ATR(ATR length)
Calculation: Choppy = Compressed OR (ADX(DMI length, ADX smoothing) < range ADX threshold AND Separation < minimum EMA separation)
Calculation: Trending = NOT Choppy AND (ADX(DMI length, ADX smoothing) >= trend ADX threshold OR Separation >= structure regime separation OR ATR(ATR length) > SMA(ATR(ATR length), ATR baseline) * volatility expansion multiplier)
Calculation: UpTrend = EMA(close, shorter lookback) > EMA(close, longer lookback) AND close > EMA(close, shorter lookback)
Calculation: DownTrend = EMA(close, shorter lookback) < EMA(close, longer lookback) AND close < EMA(close, shorter lookback)
Calculation: MeanValue = VWAP(hlc3) if chart is intraday, else EMA(close, mean lookback)
Calculation: HtfUp = EMA(close, shorter lookback, T1, last completed bar) > EMA(close, longer lookback, T1, last completed bar) AND close(T1, last completed bar) > EMA(close, shorter lookback, T1, last completed bar)
Calculation: HtfDown = EMA(close, shorter lookback, T1, last completed bar) < EMA(close, longer lookback, T1, last completed bar) AND close(T1, last completed bar) < EMA(close, shorter lookback, T1, last completed bar)
Calculation: UpAdx = ADX(DMI length, ADX smoothing) >= trend ADX threshold AND PlusDI(DMI length, ADX smoothing) > MinusDI(DMI length, ADX smoothing)
Calculation: DownAdx = ADX(DMI length, ADX smoothing) >= trend ADX threshold AND MinusDI(DMI length, ADX smoothing) > PlusDI(DMI length, ADX smoothing)
Calculation: UpScore = trend weight * [UpTrend] + HTF weight * [HtfUp] + structure weight * [BreakDirection = 1] + RSI weight * [RSI(RSI length) > RSI bull threshold] + MACD weight * [MACD histogram(MACD fast length, MACD slow length, MACD signal length) > 0] + location weight * [close > MeanValue] + volume weight * [volume > SMA(volume, volume average lookback) * general volume multiplier AND close > close[1]] + ADX weight * [UpAdx]
Calculation: DownScore = trend weight * [DownTrend] + HTF weight * [HtfDown] + structure weight * [BreakDirection = -1] + RSI weight * [RSI(RSI length) < RSI bear threshold] + MACD weight * [MACD histogram(MACD fast length, MACD slow length, MACD signal length) < 0] + location weight * [close < MeanValue] + volume weight * [volume > SMA(volume, volume average lookback) * general volume multiplier AND close < close[1]] + ADX weight * [DownAdx]
Calculation: ScoreGap = UpScore - DownScore
Calculation: NewHigh = PivotHigh(high, major swing lookback, major swing lookback) is not NA
Calculation: SwingHigh = PivotHigh(high, major swing lookback, major swing lookback) if NewHigh, else SwingHigh[1]
Calculation: NewLow = PivotLow(low, major swing lookback, major swing lookback) is not NA
Calculation: SwingLow = PivotLow(low, major swing lookback, major swing lookback) if NewLow, else SwingLow[1]
Calculation: UpBreak = Trending AND (NewHigh OR NOT HighBroken[1]) AND close > SwingHigh + ATR(ATR length) * structure break buffer
Calculation: HighBroken = UpBreak OR (HighBroken[1] AND NOT NewHigh)
Calculation: DownBreak = Trending AND (NewLow OR NOT LowBroken[1]) AND close < SwingLow - ATR(ATR length) * structure break buffer
Calculation: LowBroken = DownBreak OR (LowBroken[1] AND NOT NewLow)
Calculation: BreakDirection = -1 if DownBreak, else 1 if UpBreak, else BreakDirection[1]
Calculation: UpLevel = SwingHigh if UpBreak, else UpLevel[1]
Calculation: UpAge = 0 if UpBreak, else UpAge[1] + 1
Calculation: UpRetestOpen = UpBreak OR (UpRetestOpen[1] AND NOT DownBreak AND NOT UpRetest)
Calculation: UpRetest = UpRetestOpen[1] AND NOT DownBreak AND UpAge >= 1 AND UpAge <= retest window AND NOT Choppy AND low <= UpLevel + ATR(ATR length) * retest tolerance AND low >= UpLevel - ATR(ATR length) * maximum retest penetration AND close > UpLevel AND close > open
Calculation: DownLevel = SwingLow if DownBreak, else DownLevel[1]
Calculation: DownAge = 0 if DownBreak, else DownAge[1] + 1
Calculation: DownRetestOpen = DownBreak OR (DownRetestOpen[1] AND NOT UpBreak AND NOT DownRetest)
Calculation: DownRetest = DownRetestOpen[1] AND NOT UpBreak AND DownAge >= 1 AND DownAge <= retest window AND NOT Choppy AND high >= DownLevel - ATR(ATR length) * retest tolerance AND high <= DownLevel + ATR(ATR length) * maximum retest penetration AND close < DownLevel AND close < open
Calculation: UpFailStreak = 0 if (UpTrend AND NOT Choppy AND ScoreGap > 0), else UpFailStreak[1] + 1
Calculation: DownFailStreak = 0 if (DownTrend AND NOT Choppy AND ScoreGap < 0), else DownFailStreak[1] + 1
Long: Trending AND UpTrend AND close > MeanValue AND HtfUp AND BreakDirection = 1 AND UpAdx AND volume >= SMA(volume, volume average lookback) * signal volume multiplier AND close > open AND UpScore >= minimum signal score AND ScoreGap >= minimum score advantage AND position side is not long
Short: Trending AND DownTrend AND close < MeanValue AND HtfDown AND BreakDirection = -1 AND DownAdx AND volume >= SMA(volume, volume average lookback) * signal volume multiplier AND close < open AND DownScore >= minimum signal score AND ScoreGap <= -minimum score advantage AND position side is not short
Long: UpBreak
Short: DownBreak
Long: UpRetest
Short: DownRetest
Exit: long, UpFailStreak >= trend reset bars
Exit: short, DownFailStreak >= trend reset bars