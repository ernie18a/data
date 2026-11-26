Calculation: AverageTrueRange = ATR(high, low, close, ATR length)
Calculation: RelVol = volume / SMA(volume, volume average length)
Calculation: Features = (RSI(close, RSI length), RelVol, (close - SMA(close, z-score length)) / STDEV(close, z-score length), ADX(high, low, close, ADX length))
Calculation: LongLabel = 1 if Highest(high, forward window)[1] - close[forward window] > label ATR multiple * AverageTrueRange[forward window], else 0
Calculation: ShortLabel = 1 if close[forward window] - Lowest(low, forward window)[1] > label ATR multiple * AverageTrueRange[forward window], else 0
Calculation: LongExcursion = max(0, (Highest(high, forward window)[1] - close[forward window]) / AverageTrueRange[forward window])
Calculation: ShortExcursion = max(0, (close[forward window] - Lowest(low, forward window)[1]) / AverageTrueRange[forward window])
Calculation: Model(target, kind) = output for the current Features of a gradient-boosted model of kind (classifier or regressor) with boosting rounds and learning rate, fitted at the latest bar whose index is a multiple of retrain interval and exceeds training lookback, on pairs (Features[n], target[n - forward window]) for n from forward window + 1 to training lookback, with n counted back from the fit bar
Calculation: LongScore = Model(LongLabel, classifier)
Calculation: ShortScore = Model(ShortLabel, classifier)
Calculation: LongReg = max(0, Model(LongExcursion, regressor))
Calculation: ShortReg = max(0, Model(ShortExcursion, regressor))
Calculation: InitialStopLong = min(low[bars since entry] - SL buffer ATR multiple * AverageTrueRange[bars since entry], entry price - min stop ATR multiple * AverageTrueRange[bars since entry])
Calculation: InitialStopShort = max(high[bars since entry] + SL buffer ATR multiple * AverageTrueRange[bars since entry], entry price + min stop ATR multiple * AverageTrueRange[bars since entry])
Calculation: TargetLong = entry price + max(LongReg[bars since entry] * AverageTrueRange[bars since entry], (entry price - InitialStopLong) * TP3 floor R multiple)
Calculation: TargetShort = entry price - max(ShortReg[bars since entry] * AverageTrueRange[bars since entry], (InitialStopShort - entry price) * TP3 floor R multiple)
Calculation: StopLong = entry price if break-even enabled AND Highest(high, bars since entry) >= entry price + (entry price - InitialStopLong) * TP1 R multiple, else InitialStopLong
Calculation: StopShort = entry price if break-even enabled AND Lowest(low, bars since entry) <= entry price - (InitialStopShort - entry price) * TP1 R multiple, else InitialStopShort
Long: low < Lowest(low, sweep lookback)[1] AND close > (high + low) / 2 AND LongScore >= min model score AND LongScore - ShortScore >= min directional edge AND ADX(high, low, close, ADX length) >= ADX minimum AND ADX(high, low, close, ADX length) <= ADX maximum AND bars since last Long or Short entry >= cooldown bars AND (CCI filter off OR Lowest(CCI(hlc3, CCI length), CCI window) <= -CCI level) AND (EMA filter off OR (EMA filter with trend AND close > EMA(close, EMA length)) OR (EMA filter counter-trend AND close < EMA(close, EMA length))) AND (volume filter off OR RelVol >= min relative volume)
Short: high > Highest(high, sweep lookback)[1] AND close < (high + low) / 2 AND ShortScore >= min model score AND ShortScore - LongScore >= min directional edge AND ADX(high, low, close, ADX length) >= ADX minimum AND ADX(high, low, close, ADX length) <= ADX maximum AND bars since last Long or Short entry >= cooldown bars AND (CCI filter off OR Highest(CCI(hlc3, CCI length), CCI window) >= CCI level) AND (EMA filter off OR (EMA filter with trend AND close < EMA(close, EMA length)) OR (EMA filter counter-trend AND close > EMA(close, EMA length))) AND (volume filter off OR RelVol >= min relative volume)
Exit: long, bars since entry >= 1 AND (high >= TargetLong OR low <= StopLong)
Exit: short, bars since entry >= 1 AND (low <= TargetShort OR high >= StopShort)