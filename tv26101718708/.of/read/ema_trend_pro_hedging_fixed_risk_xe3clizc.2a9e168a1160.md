Calculation: EMA = exponential moving average of close; lengths satisfy fast < medium < slow < trend
Calculation: +DI, -DI, ADX = standard DMI/ADX on the chart timeframe
Calculation: D = stop multiplier * ATR (Wilder, on the chart timeframe) of the entry bar, fixed at entry
Calculation: Stop = entry price - D for long, or entry price + D for short. After price has reached the first profit target (long: high >= entry + m1*D; short: low <= entry - m1*D), Stop = entry price shifted by the round-trip fee fraction in the profit direction (long: entry*(1+fee); short: entry*(1-fee))
Long: no open long AND (EMA_fast crosses above EMA_trend on this bar OR EMA_medium crosses above EMA_trend on this bar) AND EMA_fast > EMA_medium AND EMA_medium > EMA_slow AND +DI > -DI AND ADX > threshold
Short: no open short AND (EMA_fast crosses below EMA_trend on this bar OR EMA_medium crosses below EMA_trend on this bar) AND EMA_fast < EMA_medium AND EMA_medium < EMA_slow AND -DI > +DI AND ADX > threshold
Exit: long, low <= Stop (close all remaining)
Exit: long, high >= entry + m1*D (close a partial fraction) OR high >= entry + m2*D (close a further partial fraction), with m1 < m2 < m3
Exit: long, high >= entry + m3*D (close all remaining)
Exit: short, high >= Stop (close all remaining)
Exit: short, low <= entry - m1*D (close a partial fraction) OR low <= entry - m2*D (close a further partial fraction), with m1 < m2 < m3
Exit: short, low <= entry - m3*D (close all remaining)