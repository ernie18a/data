Calculation: Mid = EMA(source price, EMA lookback) if mid mode is EMA, else VWAP(hlc3) if mid mode is VWAP and volume source is not NA and SMA(volume source, volume average lookback) > 0, else Median(source price, median lookback)
Calculation: Deviation = source price - Mid
Calculation: MinWidth = minimum width factor * ATR(ATR lookback)
Calculation: Normalizer = max(EMA(abs(Deviation), local volatility lookback)[1], MinWidth) if normalized, else 1
Calculation: Score = abs(Deviation) / Normalizer
Calculation: StepScale = 1 if normalized, else max(EMA(abs(Deviation), local volatility lookback), MinWidth, 1)
Calculation: UpdateSize = learning rate * StepScale * (max(decay floor, sqrt(calibration window / (calibration window + updates))) if decay on, else 1), where updates is the number of threshold updates made on earlier bars
Calculation: Integral(c, f) = Integral(c, f)[1] + c - (1 if Score < Threshold(c, f)[1] else 0)
Calculation: Correction(c, f) = integrator gain * StepScale * (2 / pi) * atan(Integral(c, f) / integral scale) if integrator on, else 0
Calculation: Threshold(c, f) = max(X, f), where X is the element at index round(c * (n - 1)) of the ascending-sorted Score values in the calibration window of size n on the first bar that window is full, and X = Threshold(c, f)[1] + UpdateSize * (c - (1 if Score < Threshold(c, f)[1] else 0)) + Correction(c, f) on each later bar, with outer coverage > inner coverage
Calculation: Upper = Mid + max(Threshold(outer coverage, Threshold(inner coverage, 0))[1] * Normalizer, MinWidth)
Calculation: Lower = Mid - max(Threshold(outer coverage, Threshold(inner coverage, 0))[1] * Normalizer, MinWidth)
Calculation: Oscillator = RSI(source price, RSI lookback) if divergence oscillator is RSI, else Deviation / Normalizer
Calculation: LowPivotPrice = source price[pivot right] if PivotLow(Oscillator, pivot left, pivot right) is not NA, else LowPivotPrice[1]
Calculation: LowPivotOsc = PivotLow(Oscillator, pivot left, pivot right) if not NA, else LowPivotOsc[1]
Calculation: HighPivotPrice = source price[pivot right] if PivotHigh(Oscillator, pivot left, pivot right) is not NA, else HighPivotPrice[1]
Calculation: HighPivotOsc = PivotHigh(Oscillator, pivot left, pivot right) if not NA, else HighPivotOsc[1]
Long: NOT confirm close AND source price < Lower
Long: confirm close AND source price[1] < Lower[1] AND source price >= Lower
Short: NOT confirm close AND source price > Upper
Short: confirm close AND source price[1] > Upper[1] AND source price <= Upper
Long: LowPivotPrice < LowPivotPrice[1] AND LowPivotOsc > LowPivotOsc[1]
Short: HighPivotPrice > HighPivotPrice[1] AND HighPivotOsc < HighPivotOsc[1]
Long: source price >= Mid
Short: source price < Mid