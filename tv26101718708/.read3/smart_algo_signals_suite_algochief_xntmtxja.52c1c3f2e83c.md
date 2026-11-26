Calculation: Swing baseline = Swing baseline[1] + min(alpha cap, max(alpha floor, sensitivity multiplier * (Efficiency Ratio(close, swing lookback) * (2/(fast smoothing period+1) - 2/(swing lookback+1)) + 2/(swing lookback+1))^2)) * (close - Swing baseline[1])
Calculation: Swing band = ATR(core ATR lookback) * band factor / max(sensitivity multiplier, sensitivity floor)
Calculation: Swing state = 1 if close > Swing baseline + Swing band; -1 if close < Swing baseline - Swing band; otherwise Swing state[1]
Calculation: Scalp state = 1 if EMA(close, shorter scalp EMA lookback) > EMA(close, longer scalp EMA lookback) AND RSI(close, scalp RSI lookback) > RSI midline; -1 if EMA(close, shorter scalp EMA lookback) < EMA(close, longer scalp EMA lookback) AND RSI(close, scalp RSI lookback) < RSI midline; otherwise Scalp state[1]
Calculation: Engine direction = Swing state if swing engine flag, otherwise Scalp state
Calculation: Bull exhaustion = (low <= SMA(close, basis lookback) - deviation multiplier * STDEV(close, basis lookback) OR RSI(close, reversal RSI lookback) < lower reversal RSI level) AND close > open AND close > high[1]
Calculation: Bear exhaustion = (high >= SMA(close, basis lookback) + deviation multiplier * STDEV(close, basis lookback) OR RSI(close, reversal RSI lookback) > upper reversal RSI level) AND close < open AND close < low[1]
Calculation: Bull trigger = (trend signal flag AND Engine direction == 1 AND Engine direction[1] != 1) OR (NOT trend signal flag AND Bull exhaustion AND NOT Bull exhaustion[1])
Calculation: Bear trigger = (trend signal flag AND Engine direction == -1 AND Engine direction[1] != -1) OR (NOT trend signal flag AND Bear exhaustion AND NOT Bear exhaustion[1])
Calculation: Volume expansion = volume >= SMA(volume, volume MA lookback) * volume multiplier
Calculation: Strong bull = Bull trigger AND Volume expansion AND RSI(close, conviction RSI lookback) > bull RSI level AND close > EMA(close, conviction EMA lookback) AND strong signals flag
Calculation: Normal bull = Bull trigger AND NOT Strong bull
Calculation: Strong bear = Bear trigger AND Volume expansion AND RSI(close, conviction RSI lookback) < bear RSI level AND close < EMA(close, conviction EMA lookback) AND strong signals flag
Calculation: Normal bear = Bear trigger AND NOT Strong bear
Calculation: FVT basis = VWMA(hlc3, FVT lookback)
Calculation: FVT width = ATR(FVT lookback) * FVT width factor
Calculation: FVT trail = if FVT direction is up: MAX(FVT trail[1], FVT basis - FVT width) when FVT direction[1] is up, otherwise FVT basis - FVT width; if FVT direction is down: MIN(FVT trail[1], FVT basis + FVT width) when FVT direction[1] is down, otherwise FVT basis + FVT width
Calculation: FVT direction = up if (FVT direction[1] is up AND close >= MAX(FVT trail[1], FVT basis - FVT width)) OR (FVT direction[1] is down AND close > MIN(FVT trail[1], FVT basis + FVT width)), otherwise down
Calculation: Optimal long setup = FVT direction is up AND low <= FVT trail + FVT width AND low >= FVT trail - retest tolerance * FVT width AND close > open AND NOT Bull trigger
Calculation: Optimal short setup = FVT direction is down AND high >= FVT trail - FVT width AND high <= FVT trail + retest tolerance * FVT width AND close < open AND NOT Bear trigger
Calculation: Optimal long fire = Optimal long setup AND bars since previous Optimal long fire > optimal cooldown
Calculation: Optimal short fire = Optimal short setup AND bars since previous Optimal short fire > optimal cooldown
Calculation: Spine level = EMA(hl2, spine lookback) if abs(EMA(hl2, spine lookback) - EMA(hl2, spine lookback)[spine lag]) > ATR(spine lookback) * spine threshold, otherwise Spine level[1]
Calculation: Regime score = chop weight * (100 - Choppiness Index(regime lookback)) + efficiency weight * (Efficiency Ratio(close, regime lookback) * 100) + ADX weight * ADX(ADX DI length, ADX smoothing length)
Calculation: Trending regime = Regime score >= regime threshold
Calculation: Cloud status = -1 if high >= SMA(close, clouds baseline) + clouds inner multiplier * ATR(clouds baseline); +1 if low <= SMA(close, clouds baseline) - clouds inner multiplier * ATR(clouds baseline); otherwise 0
Calculation: Bull count = (Engine direction == 1) + (FVT direction is up) + (close >= Spine level) + (MOM(WMA(close, bias lookback), bias smoothing lookback) >= 0) + (Cloud status == 1) + (Trending regime AND close >= EMA(close, regime lookback))
Calculation: Bear count = (Engine direction == -1) + (FVT direction is down) + (close < Spine level) + (MOM(WMA(close, bias lookback), bias smoothing lookback) < 0) + (Cloud status == -1) + (Trending regime AND close < EMA(close, regime lookback))
Calculation: Candle long = Cloud status == 1 OR (Cloud status == 0 AND Trending regime AND ((trend candle coloring flag AND Engine direction == 1) OR (volume candle coloring flag AND close >= open)))
Calculation: Candle short = Cloud status == -1 OR (Cloud status == 0 AND Trending regime AND ((trend candle coloring flag AND Engine direction != 1) OR (volume candle coloring flag AND close < open)))
Calculation: Long confluence = (NOT regime requirement flag OR Trending regime) AND (NOT FVT requirement flag OR FVT direction is up) AND (NOT spine requirement flag OR close >= Spine level) AND (NOT bias requirement flag OR MOM(WMA(close, bias lookback), bias smoothing lookback) >= 0)
Calculation: Short confluence = (NOT regime requirement flag OR Trending regime) AND (NOT FVT requirement flag OR FVT direction is down) AND (NOT spine requirement flag OR close < Spine level) AND (NOT bias requirement flag OR MOM(WMA(close, bias lookback), bias smoothing lookback) < 0)
Calculation: Long exit signal = RSI(close, exit RSI lookback) crosses below long exit RSI level OR (high = Highest(high, exit extreme lookback) AND close < open AND high - close > wick ratio * (close - low))
Calculation: Short exit signal = RSI(close, exit RSI lookback) crosses above short exit RSI level OR (low = Lowest(low, exit extreme lookback) AND close > open AND close - low > wick ratio * (high - close))
Calculation: Level distance(M) = ATR(core ATR lookback) at entry bar * M if ATR level flag, otherwise entry price * M / 100
Long: Bull trigger
Long: Strong bull
Long: Normal bull
Long: Optimal long fire
Long: all-signals alert mode AND Bull trigger AND Long confluence
Long: strong-only alert mode AND Strong bull AND Long confluence
Long: normal-only alert mode AND Normal bull AND Long confluence
Long: optimal-only alert mode AND Optimal long fire AND Long confluence
Long: Engine direction == 1
Long: FVT direction is up
Long: close >= Spine level
Long: MOM(WMA(close, bias lookback), bias smoothing lookback) >= 0
Long: Cloud status == 1
Long: Trending regime AND close >= EMA(close, regime lookback)
Long: Candle long
Long: Bull count > Bear count
Short: Bear trigger
Short: Strong bear
Short: Normal bear
Short: Optimal short fire
Short: all-signals alert mode AND Bear trigger AND Short confluence
Short: strong-only alert mode AND Strong bear AND Short confluence
Short: normal-only alert mode AND Normal bear AND Short confluence
Short: optimal-only alert mode AND Optimal short fire AND Short confluence
Short: Engine direction == -1
Short: FVT direction is down
Short: close < Spine level
Short: MOM(WMA(close, bias lookback), bias smoothing lookback) < 0
Short: Cloud status == -1
Short: Trending regime AND close < EMA(close, regime lookback)
Short: Candle short
Short: Bear count > Bull count
Exit: Long, Long exit signal AND bars since previous momentum exit > exit cooldown
Exit: Short, Short exit signal AND bars since previous momentum exit > exit cooldown
Exit: Long, exit-only alert mode AND Long exit signal
Exit: Short, exit-only alert mode AND Short exit signal
Exit: Long, low crosses below entry price - Level distance(stop multiplier)
Exit: Long, high crosses above entry price + Level distance(first target multiplier)
Exit: Long, high crosses above entry price + Level distance(second target multiplier)
Exit: Long, high crosses above entry price + Level distance(third target multiplier)
Exit: Short, high crosses above entry price + Level distance(stop multiplier)
Exit: Short, low crosses below entry price - Level distance(first target multiplier)
Exit: Short, low crosses below entry price - Level distance(second target multiplier)
Exit: Short, low crosses below entry price - Level distance(third target multiplier)