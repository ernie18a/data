Calculation: plan direction = long if side parameter forces long; short if side parameter forces short; long if close > open; short if close < open; long if close >= close[1]; else short
Calculation: candle range = high - low
Calculation: candle body = abs(close - open)
Calculation: Scale(x, a, b) = clamp((x - a) / (b - a) * 100, 0, 100)
Calculation: Peak(x, a, m, b) = x <= m ? Scale(x, a, m) : Scale(x, b, m)
Calculation: body score = Scale(candle body / candle range, body weak, body strong)
Calculation: close score = Scale(plan direction is long ? (close - low) / candle range : 1 - (close - low) / candle range, close weak, close strong)
Calculation: volume score = volume > 0 and SMA(volume, volume length) > 0 ? Scale(volume / SMA(volume, volume length), volume weak, volume strong) : volume neutral score
Calculation: readiness score = round(clamp(body weight * body score + wick weight * Scale(max(1 - candle body / candle range, wick multiplier * (plan direction is long ? high - max(open, close) : min(open, close) - low) / candle range), wick bad, wick good) + volume weight * volume score + expansion weight * Peak(candle range / ATR(atr length), expansion weak, expansion ideal, expansion hot) + close weight * close score + range weight * Peak(candle range / SMA(candle range, expansion lookback), range ratio low, range ratio ideal, range ratio high), 0, 100))
Calculation: long risk edge = low[bars since entry] - ATR(atr length)[bars since entry] * risk buffer
Calculation: short risk edge = high[bars since entry] + ATR(atr length)[bars since entry] * risk buffer
Calculation: long target = entry price + max(candle body[bars since entry] * target body multiple, ATR(atr length)[bars since entry] * target ATR floor)
Calculation: short target = entry price - max(candle body[bars since entry] * target body multiple, ATR(atr length)[bars since entry] * target ATR floor)
Long: plan direction is long AND readiness score >= ready threshold AND close score >= close gate threshold AND body score >= body gate threshold AND (volume confirmation not required OR volume score >= volume gate threshold) AND (edge confirmation not required OR close > high[1])
Short: plan direction is short AND readiness score >= ready threshold AND close score >= close gate threshold AND body score >= body gate threshold AND (volume confirmation not required OR volume score >= volume gate threshold) AND (edge confirmation not required OR close < low[1])
Exit: long, close < long risk edge
Exit: long, high >= long target
Exit: long, bars since entry > follow-through bars
Exit: short, close > short risk edge
Exit: short, low <= short target
Exit: short, bars since entry > follow-through bars