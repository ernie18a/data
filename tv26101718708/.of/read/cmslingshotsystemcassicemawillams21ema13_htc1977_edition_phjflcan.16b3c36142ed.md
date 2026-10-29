Long: fast EMA > slow EMA AND close < fast EMA
Short: fast EMA < slow EMA AND close > fast EMA
Long: fast EMA > slow EMA AND prior close < fast EMA AND close > fast EMA
Short: fast EMA < slow EMA AND prior close > fast EMA AND close < fast EMA
Long: fast EMA ≥ slow EMA
Short: fast EMA < slow EMA
Long: flat AND fast EMA > slow EMA AND low crosses below fast EMA AND prior low > current fast EMA AND (classic EMA filter disabled OR close > classic EMA)
Short: flat AND fast EMA < slow EMA AND high crosses above fast EMA AND prior high < current fast EMA AND (classic EMA filter disabled OR close < classic EMA)
Calculation: Williams %R = 100 × (close − highest high over the lookback) ÷ (highest high over the lookback − lowest low over the lookback)
Calculation: Smoothed Williams %R = EMA of Williams %R
Exit: long, fast EMA < slow EMA OR (smoothed Williams %R > −20 AND Williams %R > −20) OR close < entry close × (1 − stop-loss fraction)
Exit: short, fast EMA > slow EMA OR (smoothed Williams %R < −80 AND Williams %R < −80) OR close > entry close × (1 + stop-loss fraction)