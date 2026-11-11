Calculation: Basis = selected EMA, SMA, HMA, WMA, VWMA, or RMA of a selected price source.
Calculation: Upper band = basis + band-width multiplier × ATR; lower band = basis − band-width multiplier × ATR.
Calculation: Up-burst magnitude = (high − upper band) / ATR when ATR > 0 AND high > upper band AND (closing-burst filter is disabled OR close > upper band); otherwise 0.
Calculation: Down-burst magnitude = (lower band − low) / ATR when ATR > 0 AND low < lower band AND (closing-burst filter is disabled OR close < lower band); otherwise 0.
Long: Previous bar's down-burst magnitude > 0 AND previous bar's down-burst magnitude >= down-burst magnitude two bars ago AND previous bar's down-burst magnitude > current down-burst magnitude.
Short: Previous bar's up-burst magnitude > 0 AND previous bar's up-burst magnitude >= up-burst magnitude two bars ago AND previous bar's up-burst magnitude > current up-burst magnitude.