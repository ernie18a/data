Calculation: Renko close = close of bricks formed by applying each lower-timeframe one-minute bar’s open, low, high, close in that order when close > open, otherwise open, high, low, close; extend a brick after a one-brick move in its direction and reverse after a two-brick move. Include the still-forming one-minute bar.
Calculation: Renko tick volume = accumulated source-bar tick volume assigned to the brick.
Long: Renko tick volume > 0 AND current Renko close > previous Renko close
Short: Renko tick volume > 0 AND current Renko close <= previous Renko close