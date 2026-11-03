Calculation: Ribbon moving averages = each enabled configured moving average (SMA, EMA, RMA, WMA, or VWMA) of its configured price source; use the same set for all ribbon calculations
Calculation: Midline = average of the enabled ribbon moving averages
Calculation: Smoothed width = EMA of the maximum absolute difference between each enabled ribbon moving average and its mirror value (2 × its source − its moving average)
Calculation: Volume boost = 1 + max(0, volume / SMA(volume) − 1) × volume sensitivity
Calculation: Upper and lower wick averages = RMA(14) of upper wick (high − max(open, close)) and lower wick (min(open, close) − low), respectively
Calculation: Asymmetry factors = 1 + asymmetry strength × upper or lower wick average / ATR(14)
Calculation: Core upper/lower = EMA(midline ± (smoothed width / 2 × core multiplier × volume boost × corresponding asymmetry factor), final edge smoothing)
Calculation: Expansion envelope upper/lower = EMA(core upper/lower ± smoothed width / 2 × envelope multiplier × volume boost × corresponding asymmetry factor, final edge smoothing)
Long: Close crosses above the expansion envelope upper boundary
Short: Close crosses below the expansion envelope lower boundary