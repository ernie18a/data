Calculation: Flow ownership = buyers when MFI(source, MFI lookback) > upper ownership boundary; sellers when it is < lower ownership boundary; otherwise retain the previous ownership.
Calculation: Flow impulse = EMA(change(MFI(source, MFI lookback), one bar), impulse smoothing lookback).
Calculation: Displayed pulse = change(MFI(source, MFI lookback), one bar) when raw pulse display is selected; otherwise Flow impulse.
Calculation: Compression = 100 − PercentRank(StDev(MFI(source, MFI lookback), compression lookback), rank lookback).
Calculation: Disagreement starts at zero and each bar first becomes its previous value × retention plus confirmed divergence weights. Add the larger weight when a confirmed price pivot high exceeds the previous pivot high while MFI at that pivot is lower and Flow impulse is negative, or when a confirmed price pivot low is below the previous pivot low while MFI at that pivot is higher and Flow impulse is positive; otherwise add the smaller weight. Use the same pivot span on each side and compare MFI at the pivot. After the bar's regime and signals are evaluated, add the failure weight when a bullish continuation or lower reversal signal is followed by MFI crossing below the center line within its effective cooldown, or a bearish continuation or upper fade signal is followed by MFI crossing above the center line within its effective cooldown. A new same-side signal restarts its failure window; expired windows add nothing. Failure weights affect later bars.
Calculation: Effective cooldown = base cooldown × extended-regime multiplier when the current regime is Exhaustion or Capitulation; otherwise it is the base cooldown.
Calculation: Bull continuation = MFI crosses above the bull-tier/continuation threshold, consecutive chart bars with MFI above the center line meet the event persistence requirement, Flow impulse > zero, and elapsed chart bars since the previous bull continuation exceeds the effective cooldown.
Calculation: Bear continuation = MFI crosses below the bear-tier/continuation threshold, consecutive chart bars with MFI below the center line meet the event persistence requirement, Flow impulse < zero, and elapsed chart bars since the previous bear continuation exceeds the effective cooldown.
Calculation: Upper fade = MFI crosses below the upper extreme threshold, Flow impulse < zero, and elapsed chart bars since the previous upper fade exceeds the effective cooldown.
Calculation: Lower reversal = MFI crosses above the lower extreme threshold, Flow impulse > zero, and elapsed chart bars since the previous lower reversal exceeds the effective cooldown.
Calculation: Regime is the first matching candidate in this priority order: Dead Zone when Compression > the dead-zone compression boundary and the absolute difference between MFI and the center line is < the dead-zone band width; Exhaustion when MFI ≥ the upper extreme threshold and Flow impulse ≤ zero; Capitulation when MFI ≤ the lower extreme threshold and Flow impulse ≤ zero; Accumulation when MFI < the lower ownership boundary and Flow impulse > zero; Distribution when MFI > the upper ownership boundary and (Flow impulse < zero or Disagreement ≥ the distribution disagreement threshold); Bull Expansion when Flow ownership is buyers and Flow impulse > zero; Bear Expansion when Flow ownership is sellers and Flow impulse < zero; otherwise Drift. Change the regime only after the same candidate persists for the regime inertia duration; reset its count when the candidate changes or equals the current regime.
Calculation: Flow volatility = StDev(change(MFI(source, MFI lookback), one bar), volatility lookback).
Long: Flow ownership is buyers.
Short: Flow ownership is sellers.
Long: MFI(source, MFI lookback) > the bull-tier/continuation threshold and ≤ the upper extreme threshold.
Short: MFI(source, MFI lookback) ≥ the lower extreme threshold and < the bear-tier/continuation threshold.
Long: Displayed pulse ≥ zero.
Short: Displayed pulse < zero.
Long: Chart-bar Regime is Bull Expansion or Accumulation.
Short: Chart-bar Regime is Bear Expansion, Distribution, Exhaustion, or Capitulation.
Long: On an intraday chart, Regime calculated on T1 bars with the T1 parameter set is Bull Expansion or Accumulation on the last completed T1 bar.
Short: On an intraday chart, Regime calculated on T1 bars with the T1 parameter set is Bear Expansion, Distribution, Exhaustion, or Capitulation on the last completed T1 bar.
Long: Bull continuation or Lower reversal.
Short: Bear continuation or Upper fade.
Long: Flow impulse crosses above zero and the absolute change in Flow impulse over the diamond swing lookback exceeds the mode-specific diamond multiplier × Flow volatility × the threshold coefficient × the diamond scale.
Short: Flow impulse crosses below zero and the absolute change in Flow impulse over the diamond swing lookback exceeds the mode-specific diamond multiplier × Flow volatility × the threshold coefficient × the diamond scale.