Calculation: ReturnFeature = min(max((close - close[return lookback]) / (ATR(atr length) * return lookback), -clip limit), clip limit)
Calculation: VolatilityFeature = min(max((ATR(atr length) - SMA(ATR(atr length), z-score lookback)) / STDEV(ATR(atr length), z-score lookback), -clip limit), clip limit)
Calculation: VolumeFeature = min(max((volume - SMA(volume, z-score lookback)) / STDEV(volume, z-score lookback), -clip limit), clip limit)
Calculation: MomentumFeature = min(max(MOM(close, momentum lookback) / (ATR(atr length) * momentum ATR multiplier), -clip limit), clip limit)
Calculation: RsiFeature = min(max(RSI scale * (RSI(close, RSI length) - 50) / 50, -clip limit), clip limit)
Calculation: TrendFeature = min(max(trend scale * (PlusDI(DMI length) - MinusDI(DMI length)) / 100, -clip limit), clip limit)
Calculation: NnRaw = returns weight * ReturnFeature + volatility weight * volatility damping * VolatilityFeature + RSI weight * RsiFeature + momentum weight * MomentumFeature + volume weight * volume damping * VolumeFeature + trend weight * TrendFeature
Calculation: NnAbs = returns weight * abs(ReturnFeature) + momentum weight * abs(MomentumFeature) + trend weight * abs(TrendFeature)
Calculation: NnSideRaw = sideways volatility factor * volatility weight * VolatilityFeature - sideways absolute factor * NnAbs
Calculation: NnUp = exp(NnRaw / temperature) / (exp(NnRaw / temperature) + exp(-NnRaw / temperature) + exp(NnSideRaw / temperature))
Calculation: NnDown = exp(-NnRaw / temperature) / (exp(NnRaw / temperature) + exp(-NnRaw / temperature) + exp(NnSideRaw / temperature))
Calculation: NnSide = exp(NnSideRaw / temperature) / (exp(NnRaw / temperature) + exp(-NnRaw / temperature) + exp(NnSideRaw / temperature))
Calculation: RecordLabel = Up if close - close[forward horizon] > sideways threshold * ATR(atr length)[forward horizon]; Down if close - close[forward horizon] < -sideways threshold * ATR(atr length)[forward horizon]; otherwise Side
Calculation: KnnWeight = 1 / (1 + d * d), where d is the Euclidean distance between the current six features (ReturnFeature, VolatilityFeature, RsiFeature, MomentumFeature, VolumeFeature, TrendFeature) and a stored record's six features; a stored record is made on each bar whose index exceeds forward horizon + warm-up length and holds the six features from forward horizon bars before its bar together with that bar's RecordLabel
Calculation: KnnUp = if stored record count >= neighbor count then (sum of KnnWeight over the neighbor count nearest records with RecordLabel Up) / (sum of KnnWeight over the neighbor count nearest records) else 1/3
Calculation: KnnDown = if stored record count >= neighbor count then (sum of KnnWeight over the neighbor count nearest records with RecordLabel Down) / (sum of KnnWeight over the neighbor count nearest records) else 1/3
Calculation: KnnSide = if stored record count >= neighbor count then (sum of KnnWeight over the neighbor count nearest records with RecordLabel Side) / (sum of KnnWeight over the neighbor count nearest records) else 1/3
Calculation: ProbUp = (1 - hybrid mix) * KnnUp + hybrid mix * NnUp
Calculation: ProbDown = (1 - hybrid mix) * KnnDown + hybrid mix * NnDown
Calculation: ProbSide = (1 - hybrid mix) * KnnSide + hybrid mix * NnSide
Calculation: Confidence = max(ProbUp, ProbDown, ProbSide) - second largest of (ProbUp, ProbDown, ProbSide)
Calculation: ProjectionSlope = ATR(atr length) at the entry bar * (slope base + slope gain * Confidence at the entry bar)
Calculation: CapacityExit = a prediction fires on this bar AND the count of open predictions including it exceeds max active predictions AND this prediction is among the oldest (that count - max active predictions) open predictions
Calculation: LongExit = high >= entry price + ProjectionSlope * projection length / projection divisor OR close < entry price + ProjectionSlope * bars since entry / projection divisor - ATR(atr length) * break multiplier OR bars since entry > projection length + expiry grace OR CapacityExit
Calculation: ShortExit = low <= entry price - ProjectionSlope * projection length / projection divisor OR close > entry price - ProjectionSlope * bars since entry / projection divisor + ATR(atr length) * break multiplier OR bars since entry > projection length + expiry grace OR CapacityExit
Calculation: SideExit = close > entry price + SideBand OR close < entry price - SideBand OR (bars since entry >= projection length AND abs(close - entry price) < SideBand * side hit fraction) OR bars since entry > projection length + expiry grace OR CapacityExit, where SideBand = ATR(atr length) * (1 - Confidence at the entry bar) * side band scale
Calculation: LastClosed = (last prediction is Up AND LongExit has held on some bar since it was created) OR (last prediction is Down AND ShortExit has held on some bar since it was created) OR (last prediction is Side AND SideExit has held on some bar since it was created)
Long: ProbUp >= ProbDown AND ProbUp >= ProbSide AND ProbUp >= minimum probability AND Confidence >= minimum probability - confidence offset AND bars since last prediction > cooldown length AND (no prediction OR LastClosed OR (last prediction is not Up AND Confidence > Confidence at last prediction entry bar + opposite margin) OR (last prediction is Up AND Confidence > Confidence at last prediction entry bar + same margin))
Long: ProbUp >= ProbDown AND ProbUp >= ProbSide AND Confidence > bar color threshold
Long: ProbUp >= ProbDown AND ProbUp >= ProbSide
Short: ProbDown > ProbUp AND ProbDown >= ProbSide AND ProbDown >= minimum probability AND Confidence >= minimum probability - confidence offset AND bars since last prediction > cooldown length AND (no prediction OR LastClosed OR (last prediction is not Down AND Confidence > Confidence at last prediction entry bar + opposite margin) OR (last prediction is Down AND Confidence > Confidence at last prediction entry bar + same margin))
Short: ProbDown > ProbUp AND ProbDown >= ProbSide AND Confidence > bar color threshold
Short: ProbDown > ProbUp AND ProbDown >= ProbSide
Exit: long, LongExit
Exit: short, ShortExit