Calculation: y = Heikin-Ashi open[1] - Heikin-Ashi open[0]
Calculation: x = Heikin-Ashi open[2] - Heikin-Ashi open[1]
Calculation: w = Heikin-Ashi open[3] - Heikin-Ashi open[2]
Calculation: minimum distance = distance parameter × point size
Long: Heikin-Ashi close[2] > Heikin-Ashi open[3] AND Heikin-Ashi close[1] > Heikin-Ashi open[2] AND Heikin-Ashi close[0] > Heikin-Ashi open[1] AND y > 0 AND y < x AND x < w AND close >= Heikin-Ashi open[0] + minimum distance AND (margin level <= 0 OR margin level >= margin threshold)
Short: Heikin-Ashi close[2] < Heikin-Ashi open[3] AND Heikin-Ashi close[1] < Heikin-Ashi open[2] AND Heikin-Ashi close[0] < Heikin-Ashi open[1] AND y < 0 AND y > x AND x > w AND close <= Heikin-Ashi open[0] - minimum distance AND (margin level <= 0 OR margin level >= margin threshold)
Exit: long, Heikin-Ashi close[2] < Heikin-Ashi open[3] AND Heikin-Ashi close[1] < Heikin-Ashi open[2] AND Heikin-Ashi close[0] < Heikin-Ashi open[1] AND y < 0 AND y > x AND x > w
Exit: short, Heikin-Ashi close[2] > Heikin-Ashi open[3] AND Heikin-Ashi close[1] > Heikin-Ashi open[2] AND Heikin-Ashi close[0] > Heikin-Ashi open[1] AND y > 0 AND y < x AND x < w