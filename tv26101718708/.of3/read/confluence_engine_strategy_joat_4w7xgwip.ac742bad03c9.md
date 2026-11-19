Calculation: LR value = LinearRegression(close, LR lookback)
Calculation: LR average = SMA(LR value, signal lookback)
Calculation: Fast EMA = EMA(close, shorter EMA lookback) on chart bars
Calculation: Slow EMA = EMA(close, longer EMA lookback) on chart bars
Calculation: HTF fast EMA = EMA(close, shorter EMA lookback) on T1 bars, sampled on chart bars with lookahead_off from the still-forming T1 bar
Calculation: HTF slow EMA = EMA(close, longer EMA lookback) on T1 bars, sampled on chart bars with lookahead_off from the still-forming T1 bar
Calculation: Current ATR = ATR(shorter ATR lookback) on chart bars
Calculation: Regime ATR = ATR(longer ATR lookback) on chart bars
Calculation: ATR ratio = Current ATR / Regime ATR
Calculation: Regime passes = regime filter disabled OR ATR ratio > regime ATR ratio threshold
Calculation: Volume average = SMA(volume, volume lookback)
Calculation: Volume passes = volume filter disabled OR volume > Volume average × entry volume multiplier
Calculation: RSI = RSI(close, RSI lookback)
Calculation: Volume score = high-volume points if volume > Volume average × high-volume score multiplier, otherwise above-average points if volume > Volume average, otherwise zero
Calculation: Long RSI score = min(RSI score cap, (long RSI score anchor − RSI) × RSI score scale) if RSI < RSI score midpoint, otherwise zero
Calculation: Short RSI score = min(RSI score cap, (RSI − short RSI score anchor) × RSI score scale) if RSI > RSI score midpoint, otherwise zero
Calculation: Long confluence score = truncate(min(confluence score cap, chart trend points if Fast EMA > Slow EMA else zero + HTF trend points if HTF fast EMA > HTF slow EMA else zero + Volume score + Long RSI score + regime points if Regime passes else zero))
Calculation: Short confluence score = truncate(min(confluence score cap, chart trend points if Fast EMA < Slow EMA else zero + HTF trend points if HTF fast EMA < HTF slow EMA else zero + Volume score + Short RSI score + regime points if Regime passes else zero))
Long: Fast EMA > Slow EMA
Short: Fast EMA <= Slow EMA
Long: HTF fast EMA > HTF slow EMA
Short: HTF fast EMA < HTF slow EMA
Long: Long confluence score >= minimum confluence score
Short: Short confluence score >= minimum confluence score
Long: LR value crosses above LR average AND Fast EMA > Slow EMA AND HTF fast EMA > HTF slow EMA AND Volume passes AND RSI < long RSI ceiling AND Regime passes AND Long confluence score >= minimum confluence score AND long trading enabled AND warmup bars elapsed AND confirmed chart bar
Short: LR value crosses below LR average AND Fast EMA < Slow EMA AND HTF fast EMA < HTF slow EMA AND Volume passes AND RSI > short RSI floor AND Regime passes AND Short confluence score >= minimum confluence score AND short trading enabled AND warmup bars elapsed AND confirmed chart bar
Long: LR value crosses above LR average AND Fast EMA > Slow EMA AND HTF fast EMA > HTF slow EMA AND Volume passes AND RSI < long RSI ceiling AND Regime passes AND Long confluence score >= minimum confluence score AND long trading enabled AND warmup bars elapsed AND confirmed chart bar AND position size = 0 AND no prior exit or cooldown bars elapsed since last exit
Short: LR value crosses below LR average AND Fast EMA < Slow EMA AND HTF fast EMA < HTF slow EMA AND Volume passes AND RSI > short RSI floor AND Regime passes AND Short confluence score >= minimum confluence score AND short trading enabled AND warmup bars elapsed AND confirmed chart bar AND position size = 0 AND no prior exit or cooldown bars elapsed since last exit
Exit: long, high >= entry price + ATR(shorter ATR lookback) sampled on entry bar × take-profit ATR multiple OR low <= entry price − ATR(shorter ATR lookback) sampled on entry bar × stop-loss ATR multiple OR chart bars since entry >= maximum bars in trade OR (Fast EMA < Slow EMA AND confirmed chart bar)
Exit: short, low <= entry price − ATR(shorter ATR lookback) sampled on entry bar × take-profit ATR multiple OR high >= entry price + ATR(shorter ATR lookback) sampled on entry bar × stop-loss ATR multiple OR chart bars since entry >= maximum bars in trade OR (Fast EMA > Slow EMA AND confirmed chart bar)