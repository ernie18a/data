Calculation: Normalized(x, lookback) = 100 * (x - Lowest(x, lookback)) / (Highest(x, lookback) - Lowest(x, lookback)), or midline if Highest(x, lookback) equals Lowest(x, lookback)
Calculation: Bias score = EMA(100 * (X + Y) / 2, bias smoothing length), where X = 1 if close > EMA(close, short EMA length) AND close > EMA(close, long EMA length), else 0, and Y = 1 if EMA(close, short EMA length) > EMA(close, long EMA length), else 0
Calculation: DI-spread score = Normalized(PlusDI(DI length) - MinusDI(DI length), DI-spread normalization lookback)
Calculation: Volatility score = (100 - Normalized(100 * ATR(ATR length) / close, volatility normalization lookback) + Bias score) / 2
Calculation: Delta score = Normalized(close - open, delta normalization lookback)
Calculation: Volume score = midline + (min(100, max(0, (Z + H) / (2 * H) * 100)) - midline) * D, where Z = (volume - SMA(volume, volume lookback)) / STDEV(volume, volume lookback), or 0 if STDEV(volume, volume lookback) is 0; H = volume z-score half-range; D = 1 if close >= open, else -1
Calculation: Momentum score = Normalized(ROC(close, momentum length), momentum normalization lookback)
Calculation: Composite = EMA((EMA-bias weight * Bias score + MFI weight * MFI(HLC3, MFI length) + DI-spread weight * DI-spread score + volatility weight * Volatility score + delta weight * Delta score + volume weight * Volume score + momentum weight * Momentum score) / (sum of the seven weights), composite smoothing length)
Calculation: Bull agreement = number of the seven components (Bias score, MFI(HLC3, MFI length), DI-spread score, Volatility score, Delta score, Volume score, Momentum score) that are above midline
Calculation: Bear agreement = 7 - Bull agreement
Calculation: Signal = EMA(Composite, signal length)
Calculation: Velocity = Normalized(Composite - Composite[velocity lookback], velocity normalization lookback)
Calculation: HTF composite = Composite computed on T1 bars, taken from the last completed T1 bar for each chart bar
Long: Composite crosses above bull threshold AND Bull agreement >= confirmed agreement count AND HTF filter disabled
Long: Composite crosses above bull threshold AND Bull agreement >= confirmed agreement count AND HTF composite >= HTF bull minimum
Long: Composite crosses above Signal AND Bull agreement >= early agreement count AND Composite < bull threshold AND HTF filter disabled
Long: Composite crosses above Signal AND Bull agreement >= early agreement count AND Composite < bull threshold AND HTF composite >= HTF bull minimum
Long: Composite >= midline AND Bull agreement >= high-confidence agreement count AND Velocity > upper velocity threshold
Short: Composite crosses below bear threshold AND Bear agreement >= confirmed agreement count AND HTF filter disabled
Short: Composite crosses below bear threshold AND Bear agreement >= confirmed agreement count AND HTF composite <= HTF bear maximum
Short: Composite crosses below Signal AND Bear agreement >= early agreement count AND Composite > bear threshold AND HTF filter disabled
Short: Composite crosses below Signal AND Bear agreement >= early agreement count AND Composite > bear threshold AND HTF composite <= HTF bear maximum
Short: Composite < midline AND Bear agreement >= high-confidence agreement count AND Velocity < lower velocity threshold