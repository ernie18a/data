Calculation: Vwap = VWAP(hlc3, volume, reset each T2 bar)
Calculation: VwapSd = sqrt(max(VWAP(hlc3*hlc3, volume, reset each T2 bar) - Vwap*Vwap, 0))
Calculation: MacdHist = MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback)
Calculation: StochK = Slow Stochastic %K(close, high, low, stoch K lookback, stoch smoothing lookback)
Calculation: TrendLong = EMA(close, fast EMA lookback) > EMA(close, mid EMA lookback) AND EMA(close, mid EMA lookback) > EMA(close, slow EMA lookback) AND close > EMA(close, fast EMA lookback)
Calculation: TrendShort = close < EMA(close, fast EMA lookback) AND close < EMA(close, mid EMA lookback)
Calculation: MomLong = RSI(close, RSI lookback) > RSI long threshold AND MacdHist > 0 AND MacdHist > MacdHist[1]
Calculation: MomShort = RSI(close, RSI lookback) < RSI short threshold AND MacdHist < 0 AND MacdHist < MacdHist[1]
Calculation: VolLong = volume > SMA(volume, volume lookback) * volume multiplier AND close > Vwap
Calculation: VolShort = volume > SMA(volume, volume lookback) * volume multiplier AND close < Vwap
Calculation: PullLong = StochK[n] <= stoch OS level for some n from 0 to stoch memory lookback AND StochK > stoch OS level AND StochK < long pullback cap AND close > EMA(close, mid EMA lookback)
Calculation: PullShort = StochK[n] >= stoch OB level for some n from 0 to stoch memory lookback AND StochK < stoch OB level AND StochK > short pullback floor AND close < EMA(close, mid EMA lookback)
Calculation: CandleBull = (close > open AND close > close[1] AND open < close[1]) OR (min(open, close) - low > abs(close - open) * pin body multiplier AND min(open, close) - low > (high - max(open, close)) * pin opposite-wick multiplier) OR (close > open AND abs(close - open) > SMA(abs(close - open), body average lookback) * momentum body multiplier)
Calculation: CandleBear = (close < open AND open >= close[1] AND close < close[1]) OR (high - max(open, close) > abs(close - open) * pin body multiplier AND high - max(open, close) > (min(open, close) - low) * pin opposite-wick multiplier) OR (close < open AND abs(close - open) > SMA(abs(close - open), body average lookback) * momentum body multiplier)
Calculation: TripleCrossLong = (EMA(close, fast EMA lookback) crosses above EMA(close, mid EMA lookback))[n] for some n from 0 to cross freshness lookback AND EMA(close, mid EMA lookback) > EMA(close, slow EMA lookback)
Calculation: TripleCrossShort = (EMA(close, fast EMA lookback) crosses below EMA(close, mid EMA lookback))[n] for some n from 0 to cross freshness lookback AND EMA(close, mid EMA lookback) < EMA(close, slow EMA lookback)
Calculation: LongScore = count of true among TrendLong, MomLong, VolLong, PullLong, CandleBull, TripleCrossLong
Calculation: ShortScore = count of true among TrendShort, MomShort, VolShort, PullShort, CandleBear, TripleCrossShort
Calculation: VolatilityOk = ATR min ratio <= ATR(ATR lookback) / SMA(ATR(ATR lookback), ATR average lookback) <= ATR max ratio
Calculation: HtfUp = EMA(close, HTF fast EMA lookback, T1, last completed bar) > EMA(close, HTF slow EMA lookback, T1, last completed bar)
Calculation: CooldownOk = bars since last long or short entry >= cooldown lookback
Calculation: LongExhausted = RSI(close, RSI lookback) >= RSI block high OR StochK >= stoch block high OR close >= Vwap + narrow band multiplier * VwapSd
Calculation: ShortExhausted = RSI(close, RSI lookback) <= RSI block low OR StochK <= stoch block low OR close <= Vwap - narrow band multiplier * VwapSd
Calculation: ExtendedUp = close > Vwap + wide band multiplier * VwapSd
Calculation: ExtendedDown = close < Vwap - wide band multiplier * VwapSd
Calculation: ArmedLong = state is ARMED in a long state machine: IDLE->SETUP when LongScore >= confirmation threshold AND NOT LongExhausted; SETUP->IDLE when LongScore < confirmation threshold - 1; SETUP->ARMED when LongScore >= confirmation threshold AND bars since SETUP began >= setup lookback; ARMED->IDLE when bars since ARMED began > armed lookback; a long entry sets TRIGGERED, which becomes IDLE on the next bar without starting SETUP
Calculation: ArmedShort = state is ARMED in a short state machine: IDLE->SETUP when ShortScore >= confirmation threshold AND NOT ShortExhausted; SETUP->IDLE when ShortScore < confirmation threshold - 1; SETUP->ARMED when ShortScore >= confirmation threshold AND bars since SETUP began >= setup lookback; ARMED->IDLE when bars since ARMED began > armed lookback; a short entry sets TRIGGERED, which becomes IDLE on the next bar without starting SETUP
Long: TripleCrossLong AND LongScore - 1 >= fast min other layers AND NOT LongExhausted AND VolatilityOk AND HtfUp AND NOT ExtendedUp AND CooldownOk
Long: ArmedLong AND CandleBull AND LongScore >= confirmation threshold AND ShortScore < confirmation threshold AND high > Highest(high, BOS swing lookback)[1] AND NOT LongExhausted AND NOT ExtendedUp AND CooldownOk AND VolatilityOk AND HtfUp
Long: EMA(close, fast EMA lookback) crosses above EMA(close, mid EMA lookback) AND EMA(close, mid EMA lookback) > EMA(close, slow EMA lookback)
Long: high > Highest(high, BOS swing lookback)[1]
Long: ArmedLong
Long: (LongScore == confirmation threshold - 1 OR ArmedLong) AND VolatilityOk AND NOT LongExhausted
Short: TripleCrossShort AND ShortScore - 1 >= fast min other layers AND NOT ShortExhausted AND VolatilityOk AND NOT ExtendedDown AND CooldownOk
Short: ArmedShort AND CandleBear AND ShortScore >= confirmation threshold AND LongScore < confirmation threshold AND low < Lowest(low, BOS swing lookback)[1] AND NOT ShortExhausted AND NOT ExtendedDown AND CooldownOk AND VolatilityOk
Short: EMA(close, fast EMA lookback) crosses below EMA(close, mid EMA lookback) AND EMA(close, mid EMA lookback) < EMA(close, slow EMA lookback)
Short: low < Lowest(low, BOS swing lookback)[1]
Short: ArmedShort
Short: (ShortScore == confirmation threshold - 1 OR ArmedShort) AND VolatilityOk AND NOT ShortExhausted
Exit: long, low <= entry price - stop ATR multiplier * ATR(ATR lookback) at entry bar OR high >= entry price + target R-multiple * stop ATR multiplier * ATR(ATR lookback) at entry bar
Exit: short, high >= entry price + stop ATR multiplier * ATR(ATR lookback) at entry bar OR low <= entry price - target R-multiple * stop ATR multiplier * ATR(ATR lookback) at entry bar