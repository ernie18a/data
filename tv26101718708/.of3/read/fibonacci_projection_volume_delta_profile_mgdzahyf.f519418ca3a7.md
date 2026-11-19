Calculation: Latest rolling high price = valuewhen(high == highest(high, lookback), high, 0)
Calculation: Latest rolling low price = valuewhen(low == lowest(low, lookback), low, 0)
Calculation: Bars since latest rolling high = barssince(high == highest(high, lookback))
Calculation: Bars since latest rolling low = barssince(low == lowest(low, lookback))
Calculation: Fibonacci projection price(level) = if bars since latest rolling high < bars since latest rolling low then latest rolling high - (latest rolling high - latest rolling low) * level else latest rolling low + (latest rolling high - latest rolling low) * level
Calculation: Second projected price = if bars since latest rolling low < bars since latest rolling high then Fibonacci projection price(projection level) - (Fibonacci projection price(projection level) - latest rolling low) * projection level else latest rolling high + (Fibonacci projection price(projection level) - latest rolling high) * projection level
Calculation: Projected prices = [if bars since latest rolling high < bars since latest rolling low then latest rolling high else latest rolling low, Fibonacci projection price(projection level), second projected price, Fibonacci projection price(trend extension level)]
Calculation: Bullish volume per profile row = sum of volume for bars from the older latest-extreme bar through the newer latest-extreme bar whose HLC3 is within the row and whose close > open; rows are equal-height partitions of the latest-high/low price range
Calculation: Bearish volume per profile row = sum of volume for bars from the older latest-extreme bar through the newer latest-extreme bar whose HLC3 is within the row and whose close <= open
Calculation: Maximum profile-row volume = maximum across profile rows of bullish volume per profile row + bearish volume per profile row
Calculation: Profile span = number of bars from the older latest-extreme bar through the newer latest-extreme bar, inclusive
Calculation: Fibonacci delta bands = adjacent pairs after sorting the latest rolling high, latest rolling low, and the Fibonacci projection prices for each Fibonacci delta-level parameter
Calculation: Fibonacci band volume delta = sum of volume for bars from the older latest-extreme bar through the newer latest-extreme bar whose HLC3 is within the band and whose close > open, minus the corresponding sum for bars whose close <= open
Long: any consecutive pair (a,b) in projected prices has a < b OR (b-a)/a > 0
Short: any consecutive pair (a,b) in projected prices has a >= b OR (b-a)/a <= 0
Long: latest high bar != latest low bar AND latest rolling high price != latest rolling low price AND maximum profile-row volume > 0 AND any profile row has int((bullish volume per profile row / maximum profile-row volume) * profile span) > 0
Short: latest high bar != latest low bar AND latest rolling high price != latest rolling low price AND maximum profile-row volume > 0 AND any profile row has int((bearish volume per profile row / maximum profile-row volume) * profile span) > 0
Long: latest high bar != latest low bar AND any Fibonacci delta band has Fibonacci band volume delta > 0
Short: latest high bar != latest low bar AND any Fibonacci delta band has Fibonacci band volume delta < 0