Long: signal-timeframe close > Parabolic SAR AND +DI > -DI AND (hour filter disabled OR configured start hour <= datetime hour < configured end hour)
Short: signal-timeframe close <= Parabolic SAR AND +DI <= -DI AND (hour filter disabled OR configured start hour <= datetime hour < configured end hour)
Exit: long, signal-timeframe close <= Parabolic SAR OR +DI <= -DI OR price reaches the long stop-loss or take-profit level
Exit: short, signal-timeframe close > Parabolic SAR OR +DI > -DI OR price reaches the short stop-loss or take-profit level