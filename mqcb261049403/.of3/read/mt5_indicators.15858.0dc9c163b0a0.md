Calculation: VWMA change = VWMA(applied price, Length, volume type) - VWMA(applied price, Length, volume type)[1]; calculated on chart bars or on T1 bars using the still-forming T1 bar, sampled at its opening and held across chart bars
Long: VWMA change > 0
Short: VWMA change < 0
Long: (VWMA change > dK1 * standard deviation(VWMA change, std_period) AND VWMA change <= dK2 * standard deviation(VWMA change, std_period)) OR VWMA change > dK2 * standard deviation(VWMA change, std_period)
Short: (VWMA change < -dK1 * standard deviation(VWMA change, std_period) AND VWMA change >= -dK2 * standard deviation(VWMA change, std_period)) OR VWMA change < -dK2 * standard deviation(VWMA change, std_period)