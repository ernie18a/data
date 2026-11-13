Calculation: Return = percent change of an asset's close between the last two completed bars of a timeframe higher than the chart timeframe; computed for asset X (base) and asset Y (quote), and the observations are collected into a series (oldest dropped past a cap)
Calculation: Spread = Y return - (alpha + beta * X return), where alpha and beta come from an OLS regression of Y returns on X returns over the full collected sample
Calculation: Z = (latest Spread - mean of Spread) / stdev of Spread, where the mean and stdev use a recent window of Spread values no longer than the regression sample
Calculation: Score = 1 / stdev of Spread over that same recent window
Long: Z < -entry threshold AND Score >= minimum strength threshold; position is long Y and short X
Short: Z > +entry threshold AND Score >= minimum strength threshold; position is short Y and long X
Exit: long Y/short X or short Y/long X, abs(Z) <= small band around 0 (the spread has reverted to its mean; this band is much smaller than the entry threshold)