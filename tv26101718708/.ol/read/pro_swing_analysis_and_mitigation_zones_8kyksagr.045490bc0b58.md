Calculation: Climax = pivot-bar volume > its 20-bar volume SMA × a multiplier AND pivot-bar high − low > its 20-bar SMA of high − low × a multiplier
Calculation: Confirmed pivot low/high = a local low/high with a configurable left lookback, confirmed by 2 bars to its right
Calculation: Structural trendline = line through the two most recent confirmed pivot lows in a long trend or pivot highs in a short trend, extended forward
Calculation: Pivot zone = interval from a confirmed pivot price − 0.1 × ATR(14) to that price + 0.1 × ATR(14); demand zones come from pivot lows and supply zones from pivot highs. A zone becomes inactive when price breaches its outer edge (demand: low < lower edge; supply: high > upper edge), and reactivates when a later close is beyond its inner edge (demand: close > lower edge; supply: close < upper edge).
Long: confirmed pivot low AND Climax AND pivot-bar close > pivot-bar EMA
Short: confirmed pivot high AND Climax AND pivot-bar close < pivot-bar EMA
Exit: Long, close < structural trendline
Exit: Short, close > structural trendline
Exit: Long, an inactive supply zone intersects the bar range (high ≥ lower edge AND low ≤ upper edge)
Exit: Short, an inactive demand zone intersects the bar range (low ≤ upper edge AND high ≥ lower edge)