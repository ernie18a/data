Calculation: InWindow = datetime >= window start AND datetime <= window end
Calculation: ChannelHigh = HIGHEST(high, MAX(average lookback, price lookback))[1]
Calculation: ChannelLow = LOWEST(low, MAX(average lookback, price lookback))[1]
Calculation: CenterLine = (ChannelHigh + ChannelLow) / 2
Calculation: SmoothRange = EMA(EMA(ABS(close - close[1]), slow length), 2 * slow length - 1) * price lookback
Calculation: RangeFilterLine = RangeFilter(high, SmoothRange)
Calculation: UpCount = IF RangeFilterLine > RangeFilterLine[1] THEN UpCount[1] + 1 ELSE IF RangeFilterLine < RangeFilterLine[1] THEN 0 ELSE UpCount[1]
Calculation: DownCount = IF RangeFilterLine < RangeFilterLine[1] THEN DownCount[1] + 1 ELSE IF RangeFilterLine > RangeFilterLine[1] THEN 0 ELSE DownCount[1]
Calculation: UpTrend = high > RangeFilterLine AND high != high[1] AND UpCount > 0
Calculation: DownTrend = high < RangeFilterLine AND high != high[1] AND DownCount > 0
Calculation: TradingLine = EMA(EMA(EMA((2 * close + high + low) / 4, trading length), trading length), trading length)
Calculation: FastLine = ROC(TradingLine, 1)
Calculation: SlowLine = ALMA(SMA(ROC(TradingLine, 1), slow line smoothing length), ALMA window, ALMA offset, ALMA sigma)
Calculation: Flow = SUM(volume, price lookback, close > open) - SUM(volume, price lookback, close <= open)
Calculation: AverageUpVolume = SUM(volume, price lookback, close > open) / COUNT(price lookback, close > open)
Calculation: AverageDownVolume = SUM(volume, price lookback, close <= open) / COUNT(price lookback, close <= open)
Calculation: BullShit = Flow > 0 AND Flow[1] > 0 AND close < open AND AverageDownVolume <= volume OR Flow < 0 AND Flow[1] < 0 AND close > open AND AverageUpVolume <= volume
Calculation: FastStoch = (MA(close, fast length, MA type) - HIGHEST(high, fast length)) / (HIGHEST(high, fast length) - LOWEST(low, fast length))
Calculation: SlowStoch = (MA(close, slow length, MA type) - LOWEST(low, slow length)) / (HIGHEST(high, slow length) - LOWEST(low, slow length))
Calculation: STMACD = FastStoch - SlowStoch
Calculation: STMACDAvg = MA(STMACD, average lookback, MA type)
Calculation: Band1Upper = CenterLine * (1 + first band percent / 100)
Calculation: Band1Lower = CenterLine * (1 - first band percent / 100)
Calculation: Band2Upper = CenterLine * (1 + second band percent / 100)
Calculation: Band2Lower = CenterLine * (1 - second band percent / 100)
Calculation: Band3Upper = CenterLine * (1 + extreme band percent / 100)
Calculation: Band3Lower = CenterLine * (1 - extreme band percent / 100)
Calculation: FibUpper1 = CenterLine + ATR(price lookback) * fib level 1
Calculation: FibUpper2 = CenterLine + ATR(price lookback) * fib level 2
Calculation: FibLower1 = CenterLine - ATR(price lookback) * fib level 1
Calculation: FibLower2 = CenterLine - ATR(price lookback) * fib level 2
Long: low < ChannelLow AND UpTrend AND InWindow
Long: FastLine > SlowLine AND FastLine < 0 AND UpTrend AND InWindow
Short: high >= ChannelHigh AND DownTrend AND InWindow
Short: FastLine < SlowLine AND FastLine > 0 AND DownTrend AND InWindow
Short: (high[1] - close[1]) / close[1] > fakeout percent / 100 AND InWindow
Short: high > Band1Upper AND DownTrend AND InWindow
Short: high > Band1Upper AND STMACD crosses below STMACDAvg AND InWindow
Long: low < Band1Lower AND UpTrend AND InWindow
Long: low < Band1Lower AND STMACD crosses above STMACDAvg AND InWindow
Short: high > Band2Upper AND DownTrend AND InWindow
Short: high > Band2Upper AND STMACD crosses below STMACDAvg AND InWindow
Long: low < Band2Lower AND UpTrend AND InWindow
Long: low < Band2Lower AND STMACD crosses above STMACDAvg AND InWindow
Short: high > Band3Upper AND DownTrend AND InWindow
Short: high > Band3Upper AND STMACD crosses below STMACDAvg AND InWindow
Long: low < Band3Lower AND UpTrend AND InWindow
Long: low < Band3Lower AND STMACD crosses above STMACDAvg AND InWindow
Short: high[1] >= FibUpper1 AND high >= FibUpper2 AND InWindow
Short: high[1] >= FibUpper1 AND close < FibUpper2 AND InWindow
Short: high >= FibUpper1 AND BullShit AND InWindow
Short: high > FibUpper2 AND InWindow
Long: low[3] <= FibLower2 AND low[2] <= FibLower2 AND low[1] <= FibLower2 AND low <= FibLower2 AND InWindow
Long: low <= FibLower2 AND BullShit AND InWindow
Long: low <= FibLower1 AND STMACD crosses above STMACDAvg AND InWindow
Long: low < ChannelLow AND STMACD crosses above STMACDAvg AND InWindow
Long: low < ChannelLow AND BullShit AND InWindow
Short: high >= ChannelHigh AND STMACD crosses below STMACDAvg AND InWindow
Short: BullShit AND high >= ChannelHigh AND InWindow
Long: STMACD crosses above STMACDAvg
Short: STMACD crosses below STMACDAvg
Exit: long, low <= entry price * (1 - stop loss percent / 100)
Exit: long, high >= entry price * (1 + target profit percent / 100)
Exit: short, high >= entry price * (1 + stop loss percent / 100)
Exit: short, low <= entry price * (1 - target profit percent / 100)