Calculation: Percentage change(X) = 100 × (X closing price / X closing price P1 chart bars ago − 1)
Calculation: Relative performance(X) = percentage change(X) − percentage change(SPY)
Calculation: Relative-strength state(X) = 1 when relative performance(X) > P2, −1 when relative performance(X) < P3, and 0 otherwise
Calculation: Defensive state(X) = −1 when relative performance(X) > P2, 1 when relative performance(X) < P3, and 0 otherwise
Calculation: Volatility state = −1 when UVXY percentage change > P2, 1 when UVXY percentage change < P3, and 0 otherwise
Calculation: Treasury state = −1 when UVXY percentage change > P2 or TLT relative performance > P2; 1 when UVXY percentage change ≤ P2 and TLT relative performance < P3; and 0 otherwise
Calculation: Consumer rotation state = 1 when XLY relative performance − XLP relative performance > P4 × P2, −1 when it is < P4 × P3, and 0 otherwise
Calculation: Total directional score = volatility state + HYG relative-strength state + Treasury state + UUP defensive state + BITO relative-strength state + ARKK relative-strength state + SMH relative-strength state + XLK relative-strength state + consumer rotation state + XLP defensive state + XLU defensive state + XLV defensive state
Calculation: Bullish count = number of the 12 ETF states equal to 1
Calculation: Bearish count = number of the 12 ETF states equal to −1
Long: Relative-strength state of HYG, BITO, ARKK, SMH, or XLK = 1
Short: Relative-strength state of HYG, BITO, ARKK, SMH, or XLK = −1
Long: Defensive state of UUP, XLP, XLU, or XLV = 1
Short: Defensive state of UUP, XLP, XLU, or XLV = −1
Long: Volatility state = 1
Short: Volatility state = −1
Long: Treasury state = 1
Short: Treasury state = −1
Long: Consumer rotation state = 1
Short: Consumer rotation state = −1
Long: Total directional score ≥ P5
Short: Total directional score ≤ −P6
Long: Bullish count ≥ P7
Short: Bearish count ≥ P7
Short: Volatility state = −1 AND HYG relative-strength state = −1
Short: Treasury state = −1 AND HYG relative-strength state = −1
Short: SMH relative-strength state = −1 AND XLK relative-strength state = 1
Long: XLP defensive state = 1 AND consumer rotation state = 1 AND SMH relative-strength state = 1