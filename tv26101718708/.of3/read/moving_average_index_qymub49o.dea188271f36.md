Calculation: MA(n) = type_n(source_n, length_n) on bars of timeframe_n, taking the last completed bar's value, where type_n is SMA, EMA, WMA, VWMA, HMA, or RMA
Long: fill_1_enabled AND MA(primary_1) enabled AND MA(secondary_1) enabled AND MA(primary_1) > MA(secondary_1)
Short: fill_1_enabled AND MA(primary_1) enabled AND MA(secondary_1) enabled AND primary_1 != secondary_1 AND MA(primary_1) <= MA(secondary_1)
Long: fill_2_enabled AND MA(primary_2) enabled AND MA(secondary_2) enabled AND MA(primary_2) > MA(secondary_2)
Short: fill_2_enabled AND MA(primary_2) enabled AND MA(secondary_2) enabled AND primary_2 != secondary_2 AND MA(primary_2) <= MA(secondary_2)
Long: fill_3_enabled AND MA(primary_3) enabled AND MA(secondary_3) enabled AND MA(primary_3) > MA(secondary_3)
Short: fill_3_enabled AND MA(primary_3) enabled AND MA(secondary_3) enabled AND primary_3 != secondary_3 AND MA(primary_3) <= MA(secondary_3)