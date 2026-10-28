Calculation: Body-size ratio = abs(close − open) / (high − low) when high > low; otherwise 0
Calculation: Close-to-high position = (close − low) / (high − low) when high > low; otherwise 0
Calculation: Close-to-low position = (high − close) / (high − low) when high > low; otherwise 0
Long: close > open AND body-size ratio ≥ body-ratio threshold AND high − low > ATR × ATR multiplier AND close-to-high position ≥ close-position threshold AND volume > volume SMA × volume multiplier
Short: close < open AND body-size ratio ≥ body-ratio threshold AND high − low > ATR × ATR multiplier AND close-to-low position ≥ close-position threshold AND volume > volume SMA × volume multiplier