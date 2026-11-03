Calculation: EP bar = most recent chart bar whose close rose from the preceding close by at least the configured EP threshold; retain it only up to the configured maximum age
Calculation: Outperformance = asset return since the EP bar minus benchmark return over the same interval
Calculation: Rolling high = highest high over the configured lookback
Calculation: EMA stack = short-term EMA > medium-term EMA > long-term EMA
Calculation: EMA cloud = close is between the medium-term EMA reduced by the configured tolerance and the short-term EMA increased by that tolerance
Calculation: Low-volume pullback = volume is at most the configured fraction of the short-term volume average
Calculation: Teal bar = low-volume pullback and close is between the short-term EMA and the configured maximum distance above it
Long: EP bar exists and is within its maximum age AND outperformance >= configured minimum AND close is within the configured maximum distance below the rolling high AND EMA stack AND EMA cloud AND low-volume pullback AND the most recent teal bar is within its configured validity lookback AND close > high of the most recent teal bar AND current bar is not a teal bar