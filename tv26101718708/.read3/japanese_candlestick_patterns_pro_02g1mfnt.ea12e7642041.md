Calculation: Body = abs(close - open)
Calculation: Range = high - low
Calculation: UpperShadow = high - max(open, close)
Calculation: LowerShadow = min(open, close) - low
Calculation: BodyMid = (open + close) / 2
Calculation: MeanBody = SMA(Body, average lookback)
Calculation: TrendMA = SMA(close, trend lookback) if MA type is SMA, else EMA(close, trend lookback)
Calculation: MeanVolume = SMA(volume, volume lookback)
Calculation: LongCandle = Body / close >= long body price ratio AND Body / Range >= long body range ratio AND Body / MeanBody >= long body average ratio
Calculation: ShortCandle = Body / Range <= short body range ratio
Calculation: HammerForm = LowerShadow > Body * shadow body ratio AND UpperShadow < Range * shadow range ratio AND Range > MeanBody * shape range ratio AND Body > 0
Calculation: InvertedForm = UpperShadow > Body * shadow body ratio AND LowerShadow < Range * shadow range ratio AND Range > MeanBody * shape range ratio AND Body > 0
Long: close[1] < open[1] AND close > open AND open <= close[1] AND close > open[1] AND Body > Body[1] * engulfing body multiple AND (trend filter disabled OR close[1] < TrendMA[1]) AND (volume filter disabled OR volume > MeanVolume * volume threshold)
Long: close[1] < open[1] AND close > open AND open > close[1] AND close < open[1] AND Body < Body[1] * harami body ratio AND LongCandle[1] AND (trend filter disabled OR close[1] < TrendMA[1])
Long: HammerForm AND (trend filter disabled OR close < TrendMA)
Long: InvertedForm AND (trend filter disabled OR close < TrendMA)
Long: close[2] < open[2] AND Body[2] > MeanBody AND ShortCandle[1] AND close[1] < close[2] AND close > open AND close > close[1] AND (trend filter disabled OR close[2] < TrendMA[2])
Long: close[1] < open[1] AND Body[1] > MeanBody * piercing body ratio AND close > open AND open < close[1] AND close > BodyMid[1] AND close < open[1] AND (trend filter disabled OR close[1] < TrendMA[1])
Long: close > open AND close[1] > open[1] AND close[2] > open[2] AND close > close[1] AND close[1] > close[2] AND open > open[1] AND open[1] > open[2] AND open < close[1] AND open[1] < close[2] AND Body > MeanBody * soldier body ratio AND Body[1] > MeanBody * soldier body ratio AND Body[2] > MeanBody * soldier body ratio AND (trend filter disabled OR close[2] < TrendMA[2])
Long: close[2] < open[2] AND LongCandle[2] AND close[1] > open[1] AND high[1] < high[2] AND low[1] > low[2] AND open[1] > close[2] AND close[1] < open[2] AND close > open AND close > high[2] AND (trend filter disabled OR close[2] < TrendMA[2])
Long: close[2] < open[2] AND close[1] > open[1] AND open[1] < close[2] AND close[1] > open[2] AND high[1] > high[2] AND low[1] < low[2] AND close > open AND close > close[1] AND (trend filter disabled OR close[2] < TrendMA[2])
Short: close[1] > open[1] AND close < open AND open >= close[1] AND close < open[1] AND Body > Body[1] * engulfing body multiple AND (trend filter disabled OR close[1] > TrendMA[1]) AND (volume filter disabled OR volume > MeanVolume * volume threshold)
Short: close[1] > open[1] AND close < open AND open < close[1] AND close > open[1] AND Body < Body[1] * harami body ratio AND LongCandle[1] AND (trend filter disabled OR close[1] > TrendMA[1])
Short: HammerForm AND (trend filter disabled OR close > TrendMA)
Short: InvertedForm AND (trend filter disabled OR close > TrendMA)
Short: close[2] > open[2] AND Body[2] > MeanBody AND ShortCandle[1] AND close[1] > close[2] AND close < open AND close < close[1] AND (trend filter disabled OR close[2] > TrendMA[2])
Short: close[1] > open[1] AND Body[1] > MeanBody * piercing body ratio AND close < open AND open > close[1] AND close < BodyMid[1] AND close > open[1] AND (trend filter disabled OR close[1] > TrendMA[1])
Short: close < open AND close[1] < open[1] AND close[2] < open[2] AND close < close[1] AND close[1] < close[2] AND open < open[1] AND open[1] < open[2] AND open > close[1] AND open[1] > close[2] AND Body > MeanBody * soldier body ratio AND Body[1] > MeanBody * soldier body ratio AND Body[2] > MeanBody * soldier body ratio AND (trend filter disabled OR close[2] > TrendMA[2])
Short: close[2] > open[2] AND LongCandle[2] AND close[1] < open[1] AND high[1] < high[2] AND low[1] > low[2] AND open[1] < close[2] AND close[1] > open[2] AND close < open AND close < low[2] AND (trend filter disabled OR close[2] > TrendMA[2])
Short: close[2] > open[2] AND close[1] < open[1] AND open[1] > close[2] AND close[1] < open[2] AND high[1] > high[2] AND low[1] < low[2] AND close < open AND close < close[1] AND (trend filter disabled OR close[2] > TrendMA[2])