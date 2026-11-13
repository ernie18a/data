Calculation: Resistance = most recent confirmed swing high (a bar whose high is the highest among an equal number of bars on its left and right; known only after the right-side bars complete); Support = most recent confirmed swing low (mirror of Resistance)
Calculation: VolumeSurge = volume > multiplier * simple moving average of volume (multiplier > 1)
Calculation: ATR = Average True Range, evaluated on the entry bar and then fixed
Calculation: LongStop = Support at entry - small multiple of ATR (buffer multiple smaller than the ATR stop multiple); if Support is unavailable, entry price - ATR stop multiple * ATR
Calculation: LongTarget = entry price + ATR target multiple * ATR (target multiple larger than the stop multiple)
Calculation: ShortStop = Resistance at entry + small multiple of ATR; if Resistance is unavailable, entry price + ATR stop multiple * ATR
Calculation: ShortTarget = entry price - ATR target multiple * ATR
Long: close crosses above Resistance (close > Resistance AND previous close <= previous Resistance) AND VolumeSurge AND (optional trend filter) close > long-term EMA of close
Short: close crosses below Support (close < Support AND previous close >= previous Support) AND VolumeSurge AND (optional trend filter) close < long-term EMA of close
Exit: long, low <= LongStop OR high >= LongTarget OR Short condition is true (position flips to short)
Exit: short, high >= ShortStop OR low <= ShortTarget OR Long condition is true (position flips to long)