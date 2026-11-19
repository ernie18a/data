Calculation: Body fraction = if high > low then abs(close - open) / (high - low) else 0
Calculation: Elephant bar = high - low > ATR(ATR lookback) * ATR range multiplier AND Body fraction > minimum body fraction
Calculation: Distance from long SMA = abs(close - SMA(close, long SMA lookback)) / SMA(close, long SMA lookback)
Long: (Elephant bar AND close > open) OR (NOT Elephant bar AND close > SMA(close, short SMA lookback))
Short: (Elephant bar AND close < open) OR (NOT Elephant bar AND close <= SMA(close, short SMA lookback))
Long: SMA(close, medium SMA lookback) > SMA(close, medium SMA lookback)[1]
Short: SMA(close, medium SMA lookback) <= SMA(close, medium SMA lookback)[1]
Long: SMA(close, medium SMA lookback) > SMA(close, long SMA lookback) AND Distance from long SMA >= trend range threshold
Short: SMA(close, medium SMA lookback) < SMA(close, long SMA lookback) AND Distance from long SMA >= trend range threshold
Long: low > high[FVG gap lookback]
Short: high < low[FVG gap lookback]
Long: chart-bar close crosses above EMA(source, EMA lookback) calculated on T1 bars using the still-forming T1 bar
Short: chart-bar close crosses below EMA(source, EMA lookback) calculated on T1 bars using the still-forming T1 bar