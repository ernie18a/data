Calculation: SignedVolume = volume if close >= open, else -volume
Calculation: CumSignedVolume = cumulative sum of SignedVolume
Calculation: WVFValue = WVF(WVF period)
Calculation: WVFBandUpper = BollingerUpper(WVFValue, WVF band length, WVF band multiplier)
Calculation: WVFRangeHigh = Highest(WVFValue, WVF range lookback) * WVF range fraction
Calculation: Setup = low > low[1] AND close > high[1] AND close > close[WVF strength lookback] AND (close < close[WVF longer lookback] OR close < close[WVF shorter lookback]) AND (WVFValue[1] >= WVFBandUpper[1] OR WVFValue[1] >= WVFRangeHigh[1]) AND WVFValue < WVFBandUpper AND WVFValue < WVFRangeHigh
Calculation: Gate = Setup[n] is true for some n from 0 to WVF arm window AND ADX(ADX length) < ADX threshold AND ER(close, ER length) < ER threshold
Calculation: BBLower = BollingerLower(close, BB length, BB multiplier)
Calculation: BBMid = SMA(close, BB length)
Calculation: KVal = StochK(high, low, close, CVI length)
Calculation: UpBarPct = 100 * Sum(close >= open, BP window) / BP window
Calculation: FastEMA = EMA(close, shorter EMA length)
Calculation: SlowEMA = EMA(close, longer EMA length)
Calculation: HTFFast = EMA(close, shorter HTF EMA length, T3, last completed bar)
Calculation: HTFSlow = EMA(close, longer HTF EMA length, T3, last completed bar)
Calculation: BTCEMA = EMA(BTC close, BTC EMA length)
Calculation: VWAPLine = VWAP(hlc3)
Calculation: BBAWEFast = EMA(close, BBAWE fast EMA length)
Calculation: AOVal = AO(hl2, shorter AO length, longer AO length)
Calculation: MBINorm = (close - close[MBI momentum lookback]) / EMA(high - low, MBI range EMA length) * 100 if that EMA > 0, else 0
Calculation: MBIUp = max(HMA(Sum(max(MBINorm, 0), MBI sum length), MBI smoothing length), 0)
Calculation: MBIDn = max(HMA(-Sum(min(MBINorm, 0), MBI sum length), MBI smoothing length), 0)
Calculation: ATFR = max over k from 0 to ATF length count - 1 of PearsonR(ln(close), bars ago, over the last (ATF first length + k * ATF length step) bars)
Calculation: ATFSlope = slope of the least-squares fit of ln(close) on bars ago over the last L bars, where L is the window length attaining ATFR
Long: Gate(T2, last completed bar) AND Gate(T3, last completed bar) AND NOT (Gate(T2, last completed bar) AND Gate(T3, last completed bar))[1]
Long: Gate(T1, last completed bar) AND Gate(T2, last completed bar) AND NOT (Gate(T1, last completed bar) AND Gate(T2, last completed bar))[1]
Long: Gate(T2, last completed bar) AND NOT Gate(T1, last completed bar) AND NOT (Gate(T2, last completed bar) AND NOT Gate(T1, last completed bar))[1]
Long: Gate(T1, last completed bar) AND NOT Gate(T2, last completed bar) AND NOT (Gate(T1, last completed bar) AND NOT Gate(T2, last completed bar))[1]
Long: Gate(T1, last completed bar) OR Gate(T2, last completed bar) OR Gate(T3, last completed bar)
Long: Gate
Long: Setup
Long: low <= BBLower AND close > BBLower
Long: low - high[2] > 0 AND (low - high[2]) / close * 100 >= FVG min gap percent
Long: HTFFast > HTFSlow
Long: BTC close > BTCEMA
Long: close > VWAPLine
Long: CumSignedVolume > CumSignedVolume[OBV lookback]
Long: EMA(SignedVolume, DELTA length) > 0
Long: FastEMA > SlowEMA
Long: MBIUp > MBIDn
Long: BBAWEFast > BBMid AND close > BBMid AND AOVal >= 0
Long: UpBarPct > BP bull threshold
Long: KVal < CVI midpoint
Long: ATFR >= ATF minimum R AND ATFSlope < 0
Short: close <= BBLower
Short: KVal[1] >= CVI top threshold AND KVal < CVI top threshold
Short: KVal >= CVI midpoint
Short: HTFFast <= HTFSlow
Short: BTC close <= BTCEMA
Short: close <= VWAPLine
Short: CumSignedVolume <= CumSignedVolume[OBV lookback]
Short: FastEMA <= SlowEMA
Short: MBIUp <= MBIDn
Short: BBAWEFast <= BBMid OR close <= BBMid OR AOVal < 0
Short: UpBarPct < BP bear threshold
Short: ATFR >= ATF minimum R AND ATFSlope >= 0
Exit: long, high >= entry price * (1 + take-profit fraction of T1) OR low <= entry price * (1 - stop-loss fraction of T1)
Exit: long, high >= entry price * (1 + take-profit fraction of T2) OR low <= entry price * (1 - stop-loss fraction of T2)
Exit: long, high >= entry price * (1 + take-profit fraction of T3) OR low <= entry price * (1 - stop-loss fraction of T3)
Exit: long, bars since entry >= timeout bars