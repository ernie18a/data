Calculation: Window = bars since the current T1 period started, including the current bar, if VWAP mode is anchored; rolling lookback bars if VWAP mode is rolling by bars; consecutive bars ending at the current bar whose times are at or after the current bar's time minus rolling lookback days, if VWAP mode is rolling by days
Calculation: FlipPrice = close if flip trigger mode is close, otherwise price source
Calculation: Dispersion = sqrt(max(VWAP(price source^2, Window) - VWAP(price source, Window)^2, 0))
Calculation: Spread = max(deviation multiplier * Dispersion, ATR minimum multiplier * ATR(ATR length))
Calculation: UpperTrail = min(VWAP(price source, Window) + Spread, UpperTrail[1]) if FlipPrice[1] < UpperTrail[1], otherwise VWAP(price source, Window) + Spread
Calculation: LowerTrail = max(VWAP(price source, Window) - Spread, LowerTrail[1]) if FlipPrice[1] > LowerTrail[1], otherwise VWAP(price source, Window) - Spread
Calculation: InitRegime = (1 if FlipPrice >= VWAP(price source, Window), otherwise -1) if Regime[1] = 0 and VWAP(price source, Window) is not NA, otherwise Regime[1]
Calculation: Regime = 1 if InitRegime != 1 AND FlipPrice > UpperTrail AND (slope confirmation off OR VWAP(price source, Window) > VWAP(price source, Window)[slope lookback]), otherwise -1 if InitRegime != -1 AND FlipPrice < LowerTrail AND (slope confirmation off OR VWAP(price source, Window) < VWAP(price source, Window)[slope lookback]), otherwise InitRegime
Long: Regime[1] = -1 AND FlipPrice > UpperTrail AND (slope confirmation off OR VWAP(price source, Window) > VWAP(price source, Window)[slope lookback])
Long: Regime = 1
Short: Regime[1] = 1 AND FlipPrice < LowerTrail AND (slope confirmation off OR VWAP(price source, Window) < VWAP(price source, Window)[slope lookback])
Short: Regime = -1