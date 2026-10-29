Calculation: Momentum = clip((close − close from a shorter lookback ago) / (ATR × scale), −1, +1)
Calculation: Volatility pressure = clip(−change in the symbol-appropriate volatility index over a lookback / scale, −1, +1)
Calculation: Session volume flow = clip(decayed prior session flow plus current volume signed by close versus open, divided by a multiple of average volume, −1, +1); reset at each new session
Calculation: Trend agreement = average of the clipped ATR-scaled slopes of fast and slow EMAs; the fast EMA uses a shorter lookback than the slow EMA
Calculation: Dollar pressure = clip(−change in DXY over a lookback / scale, −1, +1)
Calculation: Candle conviction = clip((close − open) / (high − low) × min(volume / average volume, cap), −1, +1); use zero body ratio when high equals low
Calculation: Pressure = 100 × EMA of the weighted average of Momentum, Volatility pressure, Session volume flow, Trend agreement, Dollar pressure, and Candle conviction
Long: Pressure crosses above 0 OR Pressure crosses above a positive threshold OR Pressure is above a higher positive threshold
Short: Pressure crosses below 0 OR Pressure crosses below a negative threshold OR Pressure is below a lower negative threshold