Calculation: Range = max(high − low, ε)
Calculation: Normalized volume = volume / SMA(volume, flow window)
Calculation: Body pressure = (close − open) / Range
Calculation: Wick pressure = ((high − close) − (close − low)) / Range
Calculation: Liquidity pulse = (0.6 × Body pressure − 0.4 × Wick pressure) × Normalized volume / sqrt(max(Normalized volume, ε))
Calculation: Liquidity density = Normalized volume / max(Range / close, ε)
Calculation: Return = ln(close / previous close)
Calculation: Volatility curvature = rolling standard deviation of Return over the volatility window − 2 × its previous value + its value two bars ago
Calculation: Impact efficiency = abs(close − previous close) / (Range + ε) × sqrt(max(Normalized volume, ε))
Calculation: Energy = z-score of Liquidity pulse over the energy window + z-score of Liquidity density over the energy window − z-score of Volatility curvature over the energy window
Calculation: Adaptive gain = minimum gain + (maximum gain − minimum gain) × min(1, logistic(Energy) × (0.5 + 0.5 × logistic(Impact efficiency)))
Calculation: Flow push = EMA of Liquidity pulse over max(5, flow window / 3) × Range
Calculation: Trend = close on the first bar; thereafter previous Trend + Adaptive gain × ((close − previous Trend) + 0.25 × Flow push)
Calculation: One-bar projection = Trend + (Trend − previous Trend)
Long: close < Trend AND One-bar projection > Trend
Short: close > Trend AND One-bar projection < Trend
Exit: long, close > Trend AND One-bar projection < Trend