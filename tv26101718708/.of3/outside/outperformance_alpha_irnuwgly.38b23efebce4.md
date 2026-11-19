Calculation: Relative alpha = if mode selects simple excess return, 100 × (instrument close / instrument close P1 bars earlier − 1) − 100 × (benchmark close / benchmark close P1 bars earlier − 1); otherwise, 100 × (instrument close / instrument close P1 bars earlier − 1) − (annual risk-free rate × P1 / P5 + β × (100 × (benchmark close / benchmark close P1 bars earlier − 1) − annual risk-free rate × P1 / P5)), where β is rolling covariance of one-bar instrument and benchmark returns over P2 divided by rolling variance of benchmark one-bar returns over P2, covariance is rolling correlation × both rolling standard deviations, and unavailable β is zero
Long: Relative alpha ≥ 0
Short: Relative alpha < 0
Long: Relative alpha crosses above zero
Short: Relative alpha crosses below zero
Long: Relative alpha = highest(Relative alpha, P3) AND Relative alpha ≠ highest(Relative alpha, P4)
Long: Relative alpha = highest(Relative alpha, P4)
Long: lead signal display enabled AND Relative alpha = highest(Relative alpha, P4) AND instrument high < highest(instrument high, P4)