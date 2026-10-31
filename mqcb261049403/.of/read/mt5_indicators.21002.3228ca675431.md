Calculation: Double-smoothed price = apply a selected moving-average method to a selected OHLC-derived price, then apply a second independently parameterized moving-average method to the result.
Calculation: Higher-timeframe slope = compare the double-smoothed price of the still-forming higher-timeframe bar with that of the preceding completed higher-timeframe bar; sample this comparison on the first chart bar of each higher-timeframe bar and hold it for the remaining chart bars in that higher-timeframe bar.
Long: Chart-timeframe double-smoothed price < its previous bar's value.
Short: Chart-timeframe double-smoothed price > its previous bar's value.
Long: Higher-timeframe slope is negative AND the preceding chart bar's higher-timeframe slope is not negative.
Short: Higher-timeframe slope is positive AND the preceding chart bar's higher-timeframe slope is not positive.