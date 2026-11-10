Calculation: CVD momentum z-score = Accumulate volume × (2 × (close − low) / (high − low) − 1), using zero increment when high = low. Subtract its value a lookback ago; subtract the rolling mean of that difference and divide by its rolling standard deviation. Use zero when the standard deviation is unavailable or not greater than a small positive tolerance.
Long: ATR > 0 AND high two bars ago < current low AND current low − high two bars ago >= minimum gap size × ATR
Short: ATR > 0 AND low two bars ago > current high AND low two bars ago − current high >= minimum gap size × ATR
Long: CVD momentum z-score >= 0
Short: CVD momentum z-score < 0