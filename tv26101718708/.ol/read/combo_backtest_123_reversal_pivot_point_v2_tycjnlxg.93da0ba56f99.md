Calculation: Fast stochastic = simple moving average of the lookback-period stochastic, where stochastic = 100 × (close − lowest low) ÷ (highest high − lowest low)
Calculation: Slow stochastic = simple moving average of the fast stochastic
Calculation: Pivot point = (higher timeframe’s last completed bar high + low + close) ÷ 3
Calculation: S1 = 2 × pivot point − high; R1 = 2 × pivot point − low
Calculation: S2 = pivot point − (R1 − S1); R2 = pivot point + (R1 − S1)
Calculation: S3 = low − 2 × (high − pivot point); R3 = high + 2 × (pivot point − low)
Long: close[2] < close[1] AND close > close[1] AND fast stochastic < slow stochastic AND fast stochastic > threshold AND close > selected resistance
Short: close[2] > close[1] AND close < close[1] AND fast stochastic > slow stochastic AND fast stochastic < threshold AND close < selected support
Exit: long or short, NOT (close[2] < close[1] AND close > close[1] AND fast stochastic < slow stochastic AND fast stochastic > threshold AND close > selected resistance) AND NOT (close[2] > close[1] AND close < close[1] AND fast stochastic > slow stochastic AND fast stochastic < threshold AND close < selected support)