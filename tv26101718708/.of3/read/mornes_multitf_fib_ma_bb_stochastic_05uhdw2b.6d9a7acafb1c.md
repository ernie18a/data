Calculation: FastMA = EMA(close, fast lookback)
Calculation: SlowMA = EMA(close, slow lookback)
Calculation: MidBand = SMA(close, bb lookback)
Calculation: UpperBand = BollingerUpper(close, bb lookback, bb deviation)
Calculation: LowerBand = BollingerLower(close, bb lookback, bb deviation)
Calculation: AtrValue = ATR(atr lookback)
Calculation: LongAlignment = FastMA > MidBand AND FastMA > SlowMA
Calculation: ShortAlignment = FastMA < MidBand AND FastMA < SlowMA
Calculation: LongFilterPass = close - MidBand <= max break distance * AtrValue AND high - low <= max candle range * AtrValue
Calculation: ShortFilterPass = MidBand - close <= max break distance * AtrValue AND high - low <= max candle range * AtrValue
Calculation: LongArmed = LongAlignment has been true for at most setup window consecutive bars including the current bar AND no position was open on any of those bars
Calculation: ShortArmed = ShortAlignment has been true for at most setup window consecutive bars including the current bar AND no position was open on any of those bars
Calculation: LongStop = highest LowerBand from the entry bar through the previous bar
Calculation: ShortStop = lowest UpperBand from the entry bar through the previous bar
Long: position side was flat before the bar AND NOT LongAlignment AND (FastMA crosses above MidBand OR FastMA crosses above SlowMA)
Long: position side was flat before the bar AND LongAlignment AND NOT LongAlignment[1] AND (close <= MidBand OR NOT LongFilterPass)
Long: LongArmed AND close > MidBand AND LongFilterPass
Long: LongArmed AND close > MidBand AND NOT LongFilterPass
Short: position side was flat before the bar AND NOT ShortAlignment AND (FastMA crosses below MidBand OR FastMA crosses below SlowMA)
Short: position side was flat before the bar AND ShortAlignment AND NOT ShortAlignment[1] AND (close >= MidBand OR NOT ShortFilterPass)
Short: ShortArmed AND close < MidBand AND ShortFilterPass
Short: ShortArmed AND close < MidBand AND NOT ShortFilterPass
Exit: long, low <= LongStop OR high >= UpperBand OR SlowMA crosses below MidBand
Exit: short, high >= ShortStop OR low <= LowerBand OR SlowMA crosses above MidBand