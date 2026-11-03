Calculation: Basis = EMA of the VWMA of close weighted by volume over the channel lookback, using the smoothing lookback
Calculation: Upper band = EMA of (VWMA of close weighted by volume over the channel lookback + ATR over the same lookback × band multiplier), using the smoothing lookback
Calculation: Lower band = EMA of (VWMA of close weighted by volume over the channel lookback − ATR over the same lookback × band multiplier), using the smoothing lookback
Long: close > basis
Short: close ≤ basis
Long: close crosses above upper band
Short: close crosses below lower band