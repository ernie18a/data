Calculation: Rolling lowest low = lowest low over the current and previous Length−1 chart-timeframe bars.
Calculation: Rolling highest high = highest high over the current and previous Length−1 chart-timeframe bars.
Calculation: Lower threshold = maximum of the rolling lowest low and its prior value; reset it to the rolling lowest low when the short condition is true. Initialize to 1.
Calculation: Upper threshold = minimum of the rolling highest high and its prior value; reset it to the rolling highest high when the long condition is true. Initialize to 99999999.
Long: Moving average of low > upper threshold AND close > previous bar high.
Short: Moving average of high < lower threshold AND close < previous bar low.
Calculation: In the higher-timeframe version, evaluate these calculations on the higher timeframe’s still-forming bar and carry its values across chart-timeframe bars.