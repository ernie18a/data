Calculation: Relative deviation difference = in MA mode, ((traded close - SMA(traded close, MA lookback)) / sqrt(ATR(traded close, normalization lookback) × MA lookback)) - ((base market close - SMA(base market close, MA lookback)) / sqrt(ATR(base market close, normalization lookback) × MA lookback)); in RSI mode, RSI(traded close, RSI lookback) - RSI(base market close, RSI lookback); use chart-timeframe series from the current completed bar historically and the preceding bar in realtime.
Calculation: Smoothed Hurst = Super Smoother(Hurst Exponent(close, Hurst lookback), smoothing length) on chart bars.
Calculation: Fisher transformed difference = Ehlers Fisher Transform(relative deviation difference, Fisher lookback).
Calculation: Donchian Channel = upper: highest of the preceding upper-lookback closes on T2 bars; lower: lowest of the preceding lower-lookback closes on T2 bars; sample these levels on chart bars.
Calculation: Period equity change = current account equity - account equity on the preceding chart bar.
Calculation: Period risk guard state = on the first chart bar of each T1 period, set to false if flat, otherwise set to whether period equity change is at or beyond the period loss cap or period gain cap; retain the state on other chart bars.
Calculation: Entry ATR = ATR(ATR exit lookback), sampled at entry from the current historical bar or preceding realtime bar.
Long: momentum strategy selected AND ((MA mode AND relative deviation difference[1] >= MA threshold AND relative deviation difference[2] < MA threshold) OR (RSI mode AND relative deviation difference[1] >= RSI lookback AND relative deviation difference[2] < RSI lookback)) AND (Hurst filter disabled OR smoothed Hurst >= Hurst threshold).
Short: momentum strategy selected AND ((MA mode AND relative deviation difference[1] <= -MA threshold AND relative deviation difference[2] > -MA threshold) OR (RSI mode AND relative deviation difference[1] <= -RSI lookback AND relative deviation difference[2] > -RSI lookback)) AND (Hurst filter disabled OR smoothed Hurst >= Hurst threshold).
Long: mean-reversion strategy selected AND Fisher transformed difference[1] >= Fisher threshold AND Fisher transformed difference[2] < Fisher threshold AND (Hurst filter disabled OR smoothed Hurst < Hurst threshold).
Short: mean-reversion strategy selected AND Fisher transformed difference[1] <= -Fisher threshold AND Fisher transformed difference[2] > -Fisher threshold AND (Hurst filter disabled OR smoothed Hurst < Hurst threshold).
Long: momentum strategy selected AND ((MA mode AND relative deviation difference[1] >= MA threshold AND relative deviation difference[2] < MA threshold) OR (RSI mode AND relative deviation difference[1] >= RSI lookback AND relative deviation difference[2] < RSI lookback)) AND (Hurst filter disabled OR smoothed Hurst >= Hurst threshold) AND close > Donchian lower AND close < Donchian upper AND position was flat on the preceding chart bar.
Short: momentum strategy selected AND ((MA mode AND relative deviation difference[1] <= -MA threshold AND relative deviation difference[2] > -MA threshold) OR (RSI mode AND relative deviation difference[1] <= -RSI lookback AND relative deviation difference[2] > -RSI lookback)) AND (Hurst filter disabled OR smoothed Hurst >= Hurst threshold) AND close > Donchian lower AND close < Donchian upper AND position was flat on the preceding chart bar.
Long: mean-reversion strategy selected AND Fisher transformed difference[1] >= Fisher threshold AND Fisher transformed difference[2] < Fisher threshold AND (Hurst filter disabled OR smoothed Hurst < Hurst threshold) AND close > Donchian lower AND close < Donchian upper AND position was flat on the preceding chart bar.
Short: mean-reversion strategy selected AND Fisher transformed difference[1] <= -Fisher threshold AND Fisher transformed difference[2] > -Fisher threshold AND (Hurst filter disabled OR smoothed Hurst < Hurst threshold) AND close > Donchian lower AND close < Donchian upper AND position was flat on the preceding chart bar.
Exit: long, low <= Donchian lower.
Exit: short, high >= Donchian upper.
Exit: long, low <= entry price - Entry ATR × ATR stop multiplier.
Exit: short, high >= entry price + Entry ATR × ATR stop multiplier.
Exit: long, ATR take-profit enabled AND high >= entry price + Entry ATR × ATR take-profit multiplier.
Exit: short, ATR take-profit enabled AND low <= entry price - Entry ATR × ATR take-profit multiplier.
Exit: long, period guard enabled AND position open AND period risk guard state.
Exit: short, period guard enabled AND position open AND period risk guard state.
Exit: long, per-trade loss guard enabled AND open profit < -per-trade loss cap.
Exit: short, per-trade loss guard enabled AND open profit < -per-trade loss cap.