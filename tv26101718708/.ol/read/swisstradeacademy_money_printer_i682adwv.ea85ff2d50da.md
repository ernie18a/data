Calculation: Upper band = SMA(high, lookback) + standard deviation(high, lookback) × multiplier
Calculation: Lower band = SMA(low, lookback) − standard deviation(low, lookback) × multiplier
Calculation: Super Bollinger baseline = 0 if either band is unavailable; otherwise, from the previous baseline, use the maximum of it and the lower band when close is above it, the minimum of it and the upper band when close is below it, and 0 when close equals it; after a cross above the baseline, set it to the lower band, and after a cross below, set it to the upper band
Calculation: MACD overlay = EMA(close, slow lookback minus fast lookback)
Calculation: MACD signal average = SMA(MACD overlay, signal lookback)
Long: close crosses above the Super Bollinger baseline OR MACD overlay > its previous value OR MACD signal average > its previous value OR long-period SMA(close) > its previous value OR MACD overlay > MACD signal average
Short: close crosses below the Super Bollinger baseline OR MACD overlay ≤ its previous value OR MACD signal average ≤ its previous value OR long-period SMA(close) ≤ its previous value OR MACD overlay ≤ MACD signal average