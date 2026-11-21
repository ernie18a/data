Calculation: volatility ratio = ATR(regime ATR length) / SMA(ATR(regime ATR length), regime baseline length)
Calculation: balance ratio = (highest(high, balance window) - lowest(low, balance window)) / (ATR(regime ATR length) * balance window)
Calculation: regime candidate = accumulation if volatility ratio < accumulation volatility threshold AND balance ratio < balance ratio threshold, else expansion if volatility ratio > expansion volatility threshold AND abs(pressure signal) > expansion pressure fraction * pressure band, else exhaustion
Calculation: regime state = regime candidate if regime candidate[k] = regime candidate[0] for every k from 0 to regime persistence length - 1, else regime state[1]
Calculation: pressure composite = average of ROC(close, fast ROC length), ROC(close, medium ROC length), ROC(close, slow ROC length), ROC(close, macro ROC length)
Calculation: pressure signal = EMA(pressure composite, pressure smoothing length)
Calculation: pressure band = STDEV(pressure signal, pressure volatility lookback) * pressure band multiplier
Calculation: last pivot high(L) = high at the most recent confirmed pivot high with L bars on each side
Calculation: last pivot low(L) = low at the most recent confirmed pivot low with L bars on each side
Calculation: structure bias = -1 if close < last pivot low(longer pivot length), else +1 if close > last pivot high(longer pivot length), else structure bias[1]
Calculation: upper anchor = lowest high among the last liquidity window bars whose high >= highest(max(open, close), liquidity window)
Calculation: lower anchor = highest low among the last liquidity window bars whose low <= lowest(min(open, close), liquidity window)
Calculation: upper touches = number of the last liquidity window bars whose high >= upper anchor
Calculation: lower touches = number of the last liquidity window bars whose low <= lower anchor
Calculation: relative volume = volume / SMA(volume, relative volume length)
Calculation: day drawdown = (equity at first chart bar of current T2 period - equity) / equity at first chart bar of current T2 period * 100
Calculation: long stop = min(last pivot low(shorter pivot length) - structural stop buffer * ATR(regime ATR length), entry price - stop ATR multiple * ATR(regime ATR length)), using only the second term when no pivot low exists, evaluated at entry
Calculation: long target = entry price + target R multiple * (entry price - long stop), evaluated at entry
Calculation: long trail = max(long trail[1], close - trail ATR multiple * ATR(regime ATR length)), with long trail = entry price - trail ATR multiple * ATR(regime ATR length) at entry
Calculation: short stop = max(last pivot high(shorter pivot length) + structural stop buffer * ATR(regime ATR length), entry price + stop ATR multiple * ATR(regime ATR length)), using only the second term when no pivot high exists, evaluated at entry
Calculation: short target = entry price - target R multiple * (short stop - entry price), evaluated at entry
Calculation: short trail = min(short trail[1], close + trail ATR multiple * ATR(regime ATR length)), with short trail = entry price + trail ATR multiple * ATR(regime ATR length) at entry
Calculation: bars since dynamic exit = bars since the most recent bar where (position side is long AND (close < long trail OR regime state is exhaustion OR close < last pivot low(longer pivot length))) OR (position side is short AND (close > short trail OR regime state is exhaustion OR close > last pivot high(longer pivot length)))
Long: regime state is not exhaustion AND structure bias = +1 AND EMA(close, shorter EMA length) > EMA(close, longer EMA length) AND close > EMA(close, shorter EMA length) AND (HTF filter disabled OR last completed T1 close >= last completed T1 open) AND pressure signal > entry pressure fraction * pressure band AND upper touches <= lower touches + touch tolerance AND ((low < lower anchor - sweep depth ATR multiple * ATR(regime ATR length) AND close > lower anchor) OR pressure signal > -(liquidity pressure fraction * pressure band) OR close > EMA(close, shorter EMA length)) AND relative volume >= relative volume floor AND position side is flat AND day drawdown < daily lockout percent AND bars since dynamic exit >= cooldown length
Short: regime state is not exhaustion AND structure bias = -1 AND EMA(close, shorter EMA length) < EMA(close, longer EMA length) AND close < EMA(close, shorter EMA length) AND (HTF filter disabled OR last completed T1 close <= last completed T1 open) AND pressure signal < -(entry pressure fraction * pressure band) AND lower touches <= upper touches + touch tolerance AND ((high > upper anchor + sweep depth ATR multiple * ATR(regime ATR length) AND close < upper anchor) OR pressure signal < liquidity pressure fraction * pressure band OR close < EMA(close, shorter EMA length)) AND relative volume >= relative volume floor AND position side is flat AND day drawdown < daily lockout percent AND bars since dynamic exit >= cooldown length
Exit: Long, low <= long stop
Exit: Long, high >= long target
Exit: Long, close < long trail
Exit: Long, regime state is exhaustion
Exit: Long, close < last pivot low(longer pivot length)
Exit: Long, day drawdown >= daily lockout percent
Exit: Short, high >= short stop
Exit: Short, low <= short target
Exit: Short, close > short trail
Exit: Short, regime state is exhaustion
Exit: Short, close > last pivot high(longer pivot length)
Exit: Short, day drawdown >= daily lockout percent