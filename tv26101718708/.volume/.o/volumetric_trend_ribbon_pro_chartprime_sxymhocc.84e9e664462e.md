Calculation: Smoothed VWMA = EMA of the close-based VWMA
Calculation: VWSD = square root of the volume-weighted mean of squared deviations of close from Smoothed VWMA, using the same lookback as the VWMA
Calculation: Upper ribbon = Smoothed VWMA + width multiplier × VWSD
Calculation: Lower ribbon = Smoothed VWMA − width multiplier × VWSD
Long: close crosses above Upper ribbon AND Smoothed VWMA > its previous value AND close > Smoothed VWMA
Short: close crosses below Lower ribbon AND Smoothed VWMA < its previous value AND close < Smoothed VWMA