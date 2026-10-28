Calculation: Delta = sum of lower-timeframe volume signed by the sign of each lower-timeframe close minus its previous close, within the current bar
Calculation: Expected move = intercept + slope × current Delta; slope = correlation of Delta and actual open-to-close movement over prior completed chart bars × standard deviation of movement ÷ standard deviation of Delta; intercept = mean movement − slope × mean Delta over those bars
Calculation: Failure score = z-score of sign(Expected move) × (Expected move − actual open-to-close movement), standardized over a rolling window including the current bar
Long: Failure score ≥ absorption threshold AND Expected move < 0
Short: Failure score ≥ absorption threshold AND Expected move > 0