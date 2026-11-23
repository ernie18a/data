Calculation: RangeDelta = volume * (close - open) / (high - low)
Calculation: BubbleThreshold = max(Percentile(abs(RangeDelta), bubble lookback, bubble percentile), 1)
Calculation: StrongBuyDelta = RangeDelta > 0 AND abs(RangeDelta) >= BubbleThreshold
Calculation: StrongSellDelta = RangeDelta < 0 AND abs(RangeDelta) >= BubbleThreshold
Calculation: HighVolume = volume > SMA(volume, volume average lookback) * volume spike multiplier
Calculation: InDemandZone = (low <= DemandTop(A) AND high >= DemandBottom(A)) OR (low <= DemandTop(B) AND high >= DemandBottom(B)), where DemandBottom(X) = latest confirmed pivot low of low with pivot X left and right lookbacks, DemandTop(X) = DemandBottom(X) + ATR(trade ATR lookback) at its confirming bar * zone depth, and pivot A lookbacks are longer than pivot B lookbacks
Calculation: InSupplyZone = (high >= SupplyBottom(A) AND low <= SupplyTop(A)) OR (high >= SupplyBottom(B) AND low <= SupplyTop(B)), where SupplyTop(X) = latest confirmed pivot high of high with pivot X left and right lookbacks, SupplyBottom(X) = SupplyTop(X) - ATR(trade ATR lookback) at its confirming bar * zone depth
Calculation: QTBand = QT multiplier * ATR(QT ATR lookback)[1]
Calculation: QTMidline = midpoint of highest and lowest close over QT lookback during the first QT lookback bars, afterwards QTMidline[1] if (QTUp OR QTDown) AND QTMidline[1] != QTMidline[2], else QTMidline[1] + QTBand if QTUp, else QTMidline[1] - QTBand if QTDown, else QTMidline[1]
Calculation: QTUp = close > QTMidline[1] + QTBand
Calculation: QTDown = close < QTMidline[1] - QTBand
Calculation: QTState = bull if QTUp, bear if QTDown, otherwise QTState[1]
Calculation: QTNewBuy = QTUp AND QTState[1] != bull
Calculation: QTNewSell = QTDown AND QTState[1] != bear
Calculation: UTState = 1 if close[1] < UTBot(close, UT ATR lookback, UT key value)[1] AND close > UTBot(close, UT ATR lookback, UT key value)[1], -1 if close[1] > UTBot(close, UT ATR lookback, UT key value)[1] AND close < UTBot(close, UT ATR lookback, UT key value)[1], otherwise UTState[1]
Calculation: UTBuyCross = close crosses above UTBot(close, UT ATR lookback, UT key value)
Calculation: UTSellCross = close crosses below UTBot(close, UT ATR lookback, UT key value)
Calculation: DEMABullCross = DEMA(close, shorter lookback) crosses above DEMA(close, longer lookback)
Calculation: DEMABearCross = DEMA(close, shorter lookback) crosses below DEMA(close, longer lookback)
Calculation: SmoothedMomentum = EMA(Momentum(close, momentum lookback), momentum smoothing)
Calculation: OpeningRangeHigh = highest high over the first opening-range bars of the day
Calculation: OpeningRangeLow = lowest low over the first opening-range bars of the day
Calculation: DailyBullOK = close(T1, last completed bar) > EMA(close, long EMA lookback, T1, last completed bar) AND ADX(ADX lookback, T1, last completed bar) >= ADX threshold
Calculation: DailyBearOK = close(T1, last completed bar) < EMA(close, long EMA lookback, T1, last completed bar) AND ADX(ADX lookback, T1, last completed bar) >= ADX threshold
Calculation: BullScore = count of true among: DailyBullOK; DEMA(close, shorter lookback) > DEMA(close, longer lookback); QTState = bull; close > UTBot(close, UT ATR lookback, UT key value); InDemandZone; StrongBuyDelta; close > VWAP(hlc3, volume); bars since day start >= opening-range bars AND close > OpeningRangeHigh; SmoothedMomentum > 0
Calculation: BearScore = count of true among: DailyBearOK; DEMA(close, shorter lookback) < DEMA(close, longer lookback); QTState = bear; close < UTBot(close, UT ATR lookback, UT key value); InSupplyZone; StrongSellDelta; close < VWAP(hlc3, volume); bars since day start >= opening-range bars AND close < OpeningRangeLow; SmoothedMomentum < 0
Calculation: BullSetup = datetime within session AND (QTNewBuy OR UTBuyCross OR DEMABullCross) AND BullScore >= minimum score AND HighVolume AND DailyBullOK AND no BullSetup in previous cooldown bars
Calculation: BearSetup = datetime within session AND (QTNewSell OR UTSellCross OR DEMABearCross) AND BearScore >= minimum score AND HighVolume AND DailyBearOK AND no BearSetup in previous cooldown bars
Calculation: StateRange(buy, sell) = 100 * SMA(position of close between running low and running high, state smoothing), where position is 0.5 when running high equals running low, the state switches to buy when buy holds and to sell when sell holds, running high resets to close on a switch to buy, running low resets to close on a switch to sell, and otherwise both extend with close
Calculation: BiasScore = average of 11 scores: rescale(RSI(close, sentiment RSI lookback)); rescale(SMA(Stochastic(close, high, low, stochastic lookback), stochastic smoothing)); rescale(SMA(StochRSI(close, StochRSI lookback, StochRSI stochastic lookback), StochRSI smoothing)); rescale(CCI(hlc3, CCI lookback)); rescale(BullBearPower), where BullBearPower = high + low - 2 * EMA(close, bull bear lookback) and rescale uses BollingerBands(BullBearPower, band lookback, band deviation); StateRange(close > SMA(close, MA lookback), close < SMA(close, MA lookback)); StateRange(close > VWAP(hlc3, volume) + VWAP deviation * StDev(close, VWAP band lookback), close < VWAP(hlc3, volume) - VWAP deviation * StDev(close, VWAP band lookback)); StateRange(close > SMA(close, Bollinger lookback) + BB deviation * StDev(close, Bollinger lookback), close < SMA(close, Bollinger lookback) - BB deviation * StDev(close, Bollinger lookback)); StateRange(close > Supertrend(supertrend factor, supertrend lookback), close < Supertrend(supertrend factor, supertrend lookback)); 50 * Correlation(close, bar index, correlation lookback) + 50; StateRange(close first exceeds latest confirmed market structure pivot high after that pivot is confirmed, close first falls below latest confirmed market structure pivot low after that pivot is confirmed); rescale maps a value piecewise-linearly to 0-100 through the oscillator's threshold levels and clips beyond its extremes
Long: QTNewBuy
Long: QTState = bull
Long: UTBuyCross
Long: UTState = 1
Long: DEMABullCross AND datetime within session
Long: SmoothedMomentum crosses above 0
Long: SmoothedMomentum > 0
Long: InDemandZone AND StrongBuyDelta AND HighVolume
Long: BullSetup
Long: BullSetup AND RSI(close, RSI lookback) < RSI overbought threshold
Long: BiasScore > bullish threshold
Short: QTNewSell
Short: QTState = bear
Short: UTSellCross
Short: UTState = -1
Short: DEMABearCross AND datetime within session
Short: SmoothedMomentum crosses below 0
Short: SmoothedMomentum < 0
Short: InSupplyZone AND StrongSellDelta AND HighVolume
Short: BearSetup
Short: BearSetup AND RSI(close, RSI lookback) > RSI oversold threshold
Short: BiasScore < bearish threshold
Exit: long, low <= close[1] - ATR(trade ATR lookback)[1] * stop ATR multiplier OR high >= close[1] + ATR(trade ATR lookback)[1] * stop ATR multiplier * reward ratio
Exit: short, high >= close[1] + ATR(trade ATR lookback)[1] * stop ATR multiplier OR low <= close[1] - ATR(trade ATR lookback)[1] * stop ATR multiplier * reward ratio