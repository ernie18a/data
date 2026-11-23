Calculation: Profile = volume profile of the bars within the most recently completed session window, with price bins spanning the session's low to high and each bar's volume spread evenly across the bins its low-to-high range covers
Calculation: POC = midpoint price of the bin with the largest volume in Profile
Long: close crosses above VAH(Profile, value area %)
Short: close crosses below VAL(Profile, value area %)
Long: low <= POC AND high >= POC AND close[1] > POC
Short: low <= POC AND high >= POC AND close[1] < POC