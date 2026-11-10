Calculation: Torque Flow Oscillator = Let the normalization denominator be the prior bar's ATR, floored at a positive minimum. Divide the candle body (close minus open), upper wick (high minus max(open, close)), and lower wick (min(open, close) minus low) by that denominator. Calculate relative volume as current volume divided by the median of prior volumes over a lookback, clamped between lower and upper bounds. Mass is the square root of relative volume; use zero for a zero-volume bar and one for missing volume. If positive volume lacks a valid positive median, torque is unavailable. Raw torque is mass times the sum of weighted normalized body and weighted normalized lower wick minus upper wick. Set decay to exp(-1 / memory length). Initialize flow to the first available raw torque; thereafter, flow = decay * previous flow + (1 - decay) * raw torque, retaining previous flow when raw torque is unavailable. The oscillator is an EMA of flow.
Calculation: Extreme threshold = nearest-rank percentile of the absolute oscillator values over a lookback ending at the prior bar.
Long: Torque Flow Oscillator >= 0
Short: Torque Flow Oscillator < 0
Long: Torque Flow Oscillator > EMA of Torque Flow Oscillator
Short: Torque Flow Oscillator < EMA of Torque Flow Oscillator
Long: Torque Flow Oscillator > extreme threshold
Short: Torque Flow Oscillator < -extreme threshold