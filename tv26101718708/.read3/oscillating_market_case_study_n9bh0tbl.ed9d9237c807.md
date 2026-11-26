Calculation: Slope2(x) = x - x[2]
Calculation: LogTRIX(length) = change(EMA(EMA(EMA(log(close), length), length), length))
Calculation: ShortROC = ROC(close, short ROC lookback)
Calculation: ShortCMO = CMO(close, short CMO lookback)
Calculation: PlainRSI = RSI(close, RSI length)
Calculation: SmoothRSI = Butterworth(PlainRSI, short Butterworth period)
Calculation: StochK = SMA(StochRSI(close, stoch-RSI length, stochastic length), K smoothing length)
Calculation: StochD = SMA(StochK, D smoothing length)
Calculation: MACD = EMA(close, MACD fast length) - EMA(close, MACD slow length)
Calculation: MACDSignal = EMA(MACD, MACD signal length)
Calculation: MACDGapPct = (abs(Butterworth(MACD, short Butterworth period)) - abs(Butterworth(MACDSignal, short Butterworth period))) / abs(Butterworth(MACDSignal, short Butterworth period)) * 100
Calculation: SmoothChaikinShort = Butterworth(ChaikinOscillator(short Chaikin fast length, short Chaikin slow length), short Butterworth period)
Calculation: SmoothChaikinLong = Butterworth(ChaikinOscillator(long Chaikin fast length, long Chaikin slow length), mid Butterworth period)
Calculation: SmoothShortROC = Butterworth(ShortROC, short Butterworth period)
Calculation: SmoothShortCMO = Butterworth(ShortCMO, short Butterworth period)
Calculation: VIplusA = VI+(VI length A)
Calculation: VIminusA = VI-(VI length A)
Calculation: SmoothVIplusB = Butterworth(VI+(VI length B), VI Butterworth period)
Calculation: SmoothVIminusB = Butterworth(VI-(VI length B), VI Butterworth period)
Calculation: Coppock = WMA(ROC(close, Coppock long ROC length) + ROC(close, Coppock short ROC length), Coppock WMA length)
Calculation: LongMACD = EMA(close, long MACD fast length) - EMA(close, long MACD slow length)
Calculation: LongMACDSignal = EMA(LongMACD, long MACD signal length)
Calculation: SmoothChop = Butterworth(Choppiness(chop length), mid Butterworth period)
Calculation: MAGap = abs(LinearRegression(close, LSMA length) - TEMA(close, TEMA length))
Calculation: BandGapPct = abs(BBupper - BBlower) / BBlower * 100, BBupper = SMA(close, BB length) + BB multiplier * STDEV(close, BB length), BBlower = SMA(close, BB length) - BB multiplier * STDEV(close, BB length)
Calculation: AO = SMA(hl2, AO fast length) - SMA(hl2, AO slow length)
Calculation: AOpct = 100 * AO / close
Calculation: SmoothDIplusM = Butterworth(DI+(medium DMI length), mid Butterworth period)
Calculation: SmoothDIminusM = Butterworth(DI-(medium DMI length), mid Butterworth period)
Long: ShortROC <= 0 AND SmoothRSI <= OC1 smoothed-RSI threshold AND StochK <= OC1 stochastic threshold AND StochD <= OC1 stochastic threshold AND MACD < MACDSignal AND MACD < 0 AND MACDSignal < 0 AND ShortCMO < 0 AND VIplusA < VIminusA AND VIminusA < VIminusA[1]
Long: ShortROC <= 0 AND PlainRSI >= OC1 RSI lower bound AND PlainRSI <= OC1 RSI upper bound AND StochK <= OC1 stochastic threshold AND StochD <= OC1 stochastic threshold AND MACD < MACDSignal AND MACD < 0 AND MACDSignal < 0 AND ShortCMO < 0 AND VIplusA < VIminusA AND VIminusA < VIminusA[1]
Long: ShortROC < 0 AND PlainRSI <= OC2 RSI threshold AND (StochK <= OC2 stochastic threshold OR StochD <= OC2 stochastic threshold) AND MACD < MACDSignal AND MACD < 0 AND MACDSignal < 0 AND ShortCMO < 0 AND ShortCMO[1] < ShortCMO AND MAGap[1] > MAGap AND VIplusA < VIminusA AND BandGapPct > OC2 band gap threshold
Long: Slope2(SmoothChaikinShort) > 0 AND Slope2(LogTRIX(short TRIX length)) > 0 AND LogTRIX(short TRIX length) < 0 AND (Slope2(SmoothChaikinShort)[1] < 0 OR Slope2(LogTRIX(short TRIX length))[1] < 0)
Long: (SmoothShortROC[1] < 0 OR SmoothShortCMO[1] < 0) AND ((Slope2(SmoothShortROC) > 0 AND Slope2(SmoothShortROC)[1] < 0) OR (Slope2(SmoothShortCMO) > 0 AND Slope2(SmoothShortCMO)[1] < 0)) AND MACD < MACDSignal AND MACDGapPct[1] > MACDGapPct
Long: VI+(VI length B) < VI-(VI length B) AND (Slope2(SmoothVIminusB)[1] > 0 OR Slope2(SmoothVIminusB)[2] > 0) AND Slope2(SmoothVIplusB) > 0
Long: LongMACD < 0 AND LongMACD[1] < LongMACDSignal[1] AND LongMACD > LongMACDSignal AND SmoothChop < MTB4 entry chop threshold AND Slope2(LogTRIX(long TRIX length)) > 0
Long: LongMACD < 0 AND LongMACD[1] < LongMACDSignal[1] AND LongMACD > LongMACDSignal AND SmoothChop < MTB4 marker chop threshold AND Slope2(LogTRIX(long TRIX length)) > 0
Long: Slope2(Coppock) > 0 AND Slope2(Coppock)[2] < 0 AND Coppock < 0
Long: Slope2(Coppock) > 0 AND Slope2(Coppock)[1] < 0 AND Coppock < 0
Exit: long, StochK > OC exit stochastic threshold OR StochD > OC exit stochastic threshold
Exit: long, Slope2(LogTRIX(short TRIX length)) < 0
Exit: long, StochK > STB2 exit high stochastic threshold OR (Slope2(SmoothRSI) < 0 AND StochK > STB2 exit mid stochastic threshold)
Exit: long, SmoothVIplusB > SmoothVIminusB AND Slope2(SmoothVIplusB) < 0
Exit: long, Slope2(SmoothChaikinLong)[1] > 0 AND Slope2(SmoothChaikinLong) < 0 AND ChaikinOscillator(long Chaikin fast length, long Chaikin slow length) > 0
Exit: long, Slope2(Coppock) < 0 AND Slope2(Coppock)[1] > 0
Short: SmoothDIplusM[1] < SmoothDIminusM[1] AND SmoothDIplusM > SmoothDIminusM AND Slope2(SMA(DX(medium DMI length), medium DMI length)) > 0 AND Butterworth(ROC(close, medium ROC lookback), ROC Butterworth period) < 0
Short: AOpct > SC2 AO lower bound AND AOpct < SC2 AO upper bound AND AO[1] < AO AND StochK > SC2 stochastic threshold AND StochD > SC2 stochastic threshold AND ShortROC > 0 AND ShortCMO > 0
Short: AOpct > SC3 AO threshold AND AO[1] > AO AND (StochK > SC3 stochastic threshold OR StochD > SC3 stochastic threshold) AND ShortROC > 0 AND ShortCMO > 0
Exit: short, StochK <= SC1 exit stochastic threshold OR StochD <= SC1 exit stochastic threshold
Exit: short, StochK <= SC2/SC3 exit stochastic threshold OR StochD <= SC2/SC3 exit stochastic threshold