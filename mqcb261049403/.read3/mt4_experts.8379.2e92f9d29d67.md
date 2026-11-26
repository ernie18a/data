Calculation: spread = SMA(fast source price, shorter lookback)[1] - SMA(slow source price, longer lookback)[1]
Long: spread >= lower divergence threshold AND spread <= upper divergence threshold
Short: spread <= -lower divergence threshold AND spread >= -upper divergence threshold
Exit: long, (profit-target parameter > 0 AND close - entry price >= profit-target parameter × point size) OR (loss-limit parameter > 0 AND close - entry price <= -loss-limit parameter × point size)
Exit: short, (profit-target parameter > 0 AND entry price - close >= profit-target parameter × point size) OR (loss-limit parameter > 0 AND entry price - close <= -loss-limit parameter × point size)