Calculation: Normalized energy = clamp(20 × EMA₃(0.6 × (RSIₛ(HLC3) − 50) + (RSIₘ(HLC3) − 50) + 1.4 × (RSIₗ(HLC3) − 50)) / standard deviation₅₀ of that EMA, −100, 100), using short-, medium-, and long-term RSI lookbacks
Long: normalized energy on the last completed higher-timeframe bar > 0
Short: normalized energy on the last completed higher-timeframe bar < 0