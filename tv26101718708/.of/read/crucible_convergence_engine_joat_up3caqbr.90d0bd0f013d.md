Calculation: Directional bias = let upward movement be max(high − previous high, 0) and downward movement be max(previous low − low, 0); smooth upward movement with an EMA, substituting zero unless upward movement exceeds downward movement, and smooth downward movement likewise; return (smoothed upward movement − smoothed downward movement) / their sum, or zero if their sum is zero.
Calculation: EMA bias = (shorter-period EMA of close − longer-period EMA of close) / ATR, or zero if ATR is zero.
Calculation: Raw regime = bullish when ATR percentile rank exceeds the trend threshold but does not exceed the volatility threshold AND directional bias exceeds its positive threshold AND EMA bias exceeds its positive threshold; bearish when the same ATR conditions hold AND directional bias is below its negative threshold AND EMA bias is below its negative threshold; volatile when ATR percentile rank exceeds the volatility threshold; neutral otherwise.
Calculation: Confirmed regime = the raw regime after it has remained unchanged for the current and preceding bar; otherwise retain the previous confirmed regime, initially neutral.
Calculation: Pressure index = EMA of the difference between a shorter-period EMA and a longer-period EMA of volume-weighted price change, where volume-weighted price change = (close − previous close) × ln(1 + volume sensitivity × shorter-period SMA of volume / longer-period SMA of volume).
Calculation: Pressure signal = a longer-period EMA of the pressure index than the EMA used to smooth the pressure index.
Calculation: Upper and lower bands = SMA of close plus or minus a multiplier times the standard deviation of close over the same lookback.
Calculation: Volume ratio = shorter-period SMA of volume / longer-period SMA of volume, or one if the denominator is zero.
Calculation: Upper rail = grid increment × ceiling(EMA of close / grid increment); lower rail = grid increment × floor(EMA of close / grid increment); rail tolerance = (upper rail − lower rail) × proximity multiplier.
Calculation: Long convergence = (regime gate disabled OR confirmed regime is bullish) AND shorter-period close MA > longer-period close MA AND pressure index > pressure signal AND close < upper band AND (volume gate disabled OR volume ratio >= volume threshold); both MAs use the same selected EMA or SMA type.
Calculation: Short convergence = (regime gate disabled OR confirmed regime is bearish) AND shorter-period close MA < longer-period close MA AND pressure index < pressure signal AND close > lower band AND (volume gate disabled OR volume ratio >= volume threshold); both MAs use the same selected EMA or SMA type.
Calculation: Long trailing stop = highest value of close − trailing multiplier × ATR since the long position was opened, reset on an entry signal.
Calculation: Short trailing stop = lowest value of close + trailing multiplier × ATR since the short position was opened, reset on an entry signal.
Long: Long convergence is true AND long convergence on the preceding bar is false.
Short: Short convergence is true AND short convergence on the preceding bar is false.
Long: Confirmed regime is bullish.
Short: Confirmed regime is bearish.
Long: Shorter-period close MA > longer-period close MA.
Short: Shorter-period close MA <= longer-period close MA.
Long: Pressure index > pressure signal.
Short: Pressure index <= pressure signal.
Long: Directional bias > 0.
Short: Directional bias <= 0.
Long: (close − SMA of close) / standard deviation of close < negative deviation threshold.
Short: (close − SMA of close) / standard deviation of close > positive deviation threshold.
Exit: long, low <= entry price − stop multiplier × ATR on the entry signal bar OR high >= entry price + target multiplier × ATR on the entry signal bar.
Exit: short, high >= entry price + stop multiplier × ATR on the entry signal bar OR low <= entry price − target multiplier × ATR on the entry signal bar.
Exit: long, trailing stop enabled AND low <= long trailing stop.
Exit: short, trailing stop enabled AND high >= short trailing stop.
Exit: long, confirmed regime is bearish.
Exit: short, confirmed regime is bullish.
Exit: long, band exit enabled AND close >= upper band.
Exit: short, band exit enabled AND close <= lower band.
Exit: long, rail exit enabled AND high >= upper rail − rail tolerance AND high <= upper rail + rail tolerance.
Exit: short, rail exit enabled AND low >= lower rail − rail tolerance AND low <= lower rail + rail tolerance.