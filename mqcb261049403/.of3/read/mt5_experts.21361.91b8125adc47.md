Calculation: SilverTrend color = 0 when state is 0; for positive state, 0 if open<=close and 1 otherwise; for negative state, 4 if open>=close and 3 otherwise. State starts at 0, changes to -1 when close<lower threshold or +1 when close>upper threshold, and otherwise retains its prior value. Over lookback L bars including the current bar, lower threshold = minimum low + (maximum high - minimum low) × (risk baseline - risk parameter) / 100; upper threshold = maximum high - (maximum high - minimum low) × (risk baseline - risk parameter) / 100.
Calculation: JFATL color = 2 when the current rounded value is greater than the prior rounded value, 0 when it is lower, and the prior color when equal; rounded value = JMA(FATL(applied price, lookback), JMA length, JMA phase) + point size × price shift, rounded to increments of point size × 10^digits.
Long: SilverTrend color<2 on the current chart bar.
Short: SilverTrend color>2 on the current chart bar.
Long: SilverTrend color at offset nAlert on chart bars<2 AND SilverTrend color at offset nAlert+1 on chart bars>1.
Short: SilverTrend color at offset nAlert on chart bars>2 AND SilverTrend color at offset nAlert+1 on chart bars<3.
Long: SilverTrend color at offset nA on T1 bars<2 AND SilverTrend color at offset nA+1 on T1 bars>1.
Short: SilverTrend color at offset nA on T1 bars>2 AND SilverTrend color at offset nA+1 on T1 bars<3.
Long: JFATL color=2 on the current chart bar.
Short: JFATL color=0 on the current chart bar.
Long: JFATL color at offset nB on T2 bars=2 AND JFATL color at offset nB+1 on T2 bars<2.
Short: JFATL color at offset nB on T2 bars=0 AND JFATL color at offset nB+1 on T2 bars>0.