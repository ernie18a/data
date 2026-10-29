Calculation: Volume ratio = 100 × volume on bars where close ≥ open summed over the lookback ÷ total volume summed over the same lookback; use 50 when total volume is zero
Calculation: Average lower-wick ratio = average over the lookback of 100 × (min(close, open) − low) ÷ (high − low); use 50 when high = low
Calculation: Momentum score = clamp(10 × (100 × (close − close[lookback]) ÷ close[lookback] + 5), 0, 100)
Calculation: Buy score = 0.40 × volume ratio + 0.20 × average lower-wick ratio + 0.20 × momentum score + 0.20 × (100 − RSI)
Calculation: Sell score = 100 − buy score
Long: fast EMA crosses above slow EMA AND RSI < overbought threshold AND buy score ≥ buy threshold
Short: fast EMA crosses below slow EMA AND RSI > oversold threshold AND sell score ≥ sell threshold