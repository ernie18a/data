Calculation: EMA21, EMA50, EMA200 = exponential moving averages of close on chart-timeframe bars; EMA21 uses a shorter lookback than EMA50, which uses a shorter lookback than EMA200
Calculation: Volume average = simple moving average of volume on chart-timeframe bars
Calculation: Strong Start = current daily open > previous completed daily close AND current daily low >= 99.5% of previous completed daily close
Calculation: Prior uptrend gain = (current close − lowest low over the longer lookback) / lowest low over that lookback × 100; use chart-timeframe bars
Calculation: Recent Purple Dot = within the last 30 chart-timeframe bars, including the current bar, a bar had (close − open) / open × 100 >= the minimum move AND volume >= the minimum volume
Calculation: Daily range % = (high − low) / low × 100 on chart-timeframe bars
Calculation: SVRO contraction phase = EMA21 > EMA50 > EMA200 AND prior uptrend gain >= minimum gain AND Recent Purple Dot AND daily range % <= maximum contraction range AND volume < Volume average × dry-up factor AND close >= EMA21 × (1 − maximum EMA pierce %), where the pierce allowance applies only when close < EMA21
Calculation: Inside bar = current high < previous chart-timeframe bar high AND current low > previous chart-timeframe bar low
Calculation: Reversal base = EMA50 > EMA200 AND EMA21 > EMA21 from three chart-timeframe bars earlier AND (highest high over the shorter lookback − close) / highest high × 100 >= minimum pullback AND bearish bars among the last seven chart-timeframe bars >= minimum count AND absolute distance from close to EMA21 / EMA21 × 100 <= maximum distance
Calculation: Stop Volume = volume >= Volume average × minimum volume factor AND daily range % <= maximum range AND close >= high − 30% of (high − low)
Calculation: Climax Volume = close < open AND (open − close) / open × 100 >= minimum drop AND volume >= Volume average × minimum volume factor
Calculation: SVRO stop = entry price × 0.99; reversal stop = low of the pullback bar (the previous chart-timeframe bar on the entry bar)
Long: (SVRO contraction phase AND Strong Start AND volume > Volume average) OR (SVRO contraction phase on the previous chart-timeframe bar AND inside bar on the previous bar AND Strong Start)
Long: Reversal base AND (Strong Start OR Stop Volume OR Climax Volume)
Long: EMA50 > EMA200 AND EMA21 > EMA21 from three chart-timeframe bars earlier AND (highest high over the shorter lookback − close) / highest high × 100 >= minimum pullback AND bearish bars among the last seven chart-timeframe bars >= minimum count
Exit: Long, close < SVRO stop for an SVRO entry OR close < reversal stop for a reversal entry