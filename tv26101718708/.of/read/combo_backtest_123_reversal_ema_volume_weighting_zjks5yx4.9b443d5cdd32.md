Calculation: Fast stochastic = short-lookback SMA of %K, where %K = 100 × (close − lowest low over the lookback) ÷ (highest high − lowest low) over the same lookback
Calculation: Slow stochastic = longer-lookback SMA of Fast stochastic
Calculation: Reversal state = +1 when close > previous close > close two bars ago AND Fast stochastic < Slow stochastic AND Fast stochastic > threshold; −1 when close < previous close < close two bars ago AND Fast stochastic > Slow stochastic AND Fast stochastic < threshold; otherwise retain its previous value
Calculation: Volume-weighted EMA price = EMA(volume × close, lookback) ÷ EMA(volume, same lookback)
Calculation: Volume-weighted EMA state = +1 when Volume-weighted EMA price < previous close; −1 when Volume-weighted EMA price > previous close; otherwise retain its previous value
Calculation: Combined signal = +1 when Reversal state = +1 AND Volume-weighted EMA state = +1; −1 when both states = −1; otherwise 0
Long: Combined signal = +1
Short: Combined signal = −1
Exit: long, Combined signal = 0
Exit: short, Combined signal = 0