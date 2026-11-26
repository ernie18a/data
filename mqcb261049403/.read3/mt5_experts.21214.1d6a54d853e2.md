Calculation: JFATL color = 2 when the JFATL line rises, 0 when it falls, and the previous color when unchanged
Long: JFATL color on the current chart bar = 2
Short: JFATL color on the current chart bar = 0
Long: SilverTrend color on the current chart bar < 2
Short: SilverTrend color on the current chart bar > 2
Long: SilverTrend color on the chart bar n bars ago < 2 AND SilverTrend color on the chart bar n+1 bars ago > 1
Short: SilverTrend color on the chart bar n bars ago > 2 AND SilverTrend color on the chart bar n+1 bars ago < 3
Long: SilverTrend color(T1, last completed bar) < 2 AND SilverTrend color(T1, preceding completed bar) > 1
Short: SilverTrend color(T1, last completed bar) > 2 AND SilverTrend color(T1, preceding completed bar) < 3
Exit: long, SilverTrend color(T1, last completed bar) > 2
Exit: short, SilverTrend color(T1, last completed bar) < 2
Long: JFATL color(T2, last completed bar) = 2 AND JFATL color(T2, preceding completed bar) < 2
Short: JFATL color(T2, last completed bar) = 0 AND JFATL color(T2, preceding completed bar) > 0
Exit: long, JFATL color(T2, last completed bar) = 0
Exit: short, JFATL color(T2, last completed bar) = 2