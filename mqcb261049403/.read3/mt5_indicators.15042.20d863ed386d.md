Calculation: x = JMA(FATL(applied price, FATL period), JMA length, JMA phase) - JMA(FATL(applied price, FATL period), JMA length, JMA phase)[1]
Calculation: s = population standard deviation of x over volatility lookback
Long: x > 0 OR x > first multiplier * s OR x > second multiplier * s
Short: x < 0 OR x < -first multiplier * s OR x < -second multiplier * s
Calculation: x_T1 = JMA(FATL(applied price, FATL period, T1), JMA length, JMA phase) - JMA(FATL(applied price, FATL period, T1), JMA length, JMA phase)[1], calculated on T1 bars including the still-forming bar and sampled on chart bars
Calculation: s_T1 = population standard deviation of x_T1 over volatility lookback, calculated on T1 bars including the still-forming bar and sampled on chart bars
Long: x_T1 > 0 OR x_T1 > first multiplier * s_T1 OR x_T1 > second multiplier * s_T1
Short: x_T1 < 0 OR x_T1 < -first multiplier * s_T1 OR x_T1 < -second multiplier * s_T1