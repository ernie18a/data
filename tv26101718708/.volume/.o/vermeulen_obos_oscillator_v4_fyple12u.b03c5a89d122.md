Calculation: Smoothed RSI = 3-period EMA of RSI(close)
Calculation: Panic ratio = max(0, 50 − Smoothed RSI) / 10 × volume / average volume over the volume lookback; 0 when volume is unavailable
Calculation: FOMO ratio = max(0, Smoothed RSI − 50) / 10 × volume / average volume over the volume lookback; 0 when volume is unavailable
Calculation: Price extension = absolute difference between close and the 5-period EMA of close > ATR
Calculation: Momentum reading = 100 + ((close − lowest low over 5 bars) / (highest high over 5 bars − lowest low over 5 bars) − 0.5) × 4; 100 when the range is zero
Long: Smoothed RSI crosses above the oversold level AND Panic ratio ≤ the panic/FOMO threshold
Long: Momentum reading < the momentum oversold level
Long: FOMO ratio > the panic/FOMO threshold AND close > open AND Price extension
Long: close > long-term SMA AND long-term SMA > its value five bars earlier
Short: Panic ratio > the panic/FOMO threshold AND close < open
Short: Momentum reading > the momentum overbought level
Short: Smoothed RSI crosses below the overbought level AND FOMO ratio ≤ the panic/FOMO threshold
Short: close < long-term SMA AND long-term SMA < its value five bars earlier