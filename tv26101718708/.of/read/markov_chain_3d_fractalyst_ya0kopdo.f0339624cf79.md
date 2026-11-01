Calculation: Return z-score = (current close-to-close percentage return minus its rolling mean) divided by its rolling standard deviation; use zero when the standard deviation is not positive.
Calculation: Custom consensus = equally weighted average of three selected series' regime scores. For each series, calculate its rolling z-score, use zero when its standard deviation is not positive, and clamp it to symmetric positive and negative limits. Assign a score of +1 when the clamped z-score is above its positive threshold, -1 when below its negative threshold, and 0 otherwise. Use the same lookback for all three series and the return z-score.
Long: Price-based mode AND return z-score > positive threshold
Short: Price-based mode AND return z-score < negative threshold
Long: Custom-indicator mode AND custom consensus > positive threshold
Short: Custom-indicator mode AND custom consensus < negative threshold
Exit: long, price-based mode AND return z-score <= positive threshold
Exit: long, custom-indicator mode AND custom consensus <= positive threshold
Long: Close > Parabolic SAR
Short: Close <= Parabolic SAR
Long: Ichimoku conversion line > Ichimoku base line
Short: Ichimoku conversion line <= Ichimoku base line
Long: RSI of close > midpoint plus threshold
Short: RSI of close < midpoint minus threshold