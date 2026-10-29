Calculation: Short-, intermediate-, and long-lookback simple moving averages = simple moving averages of (high + low) / 2
Calculation: TrendZones upper curve = long-lookback simple moving average of the rolling highest value of the intermediate-lookback median of high
Calculation: TrendZones lower curve = long-lookback simple moving average of the rolling lowest value of the intermediate-lookback median of low
Calculation: TrendZones center = midpoint of the upper and lower curves
Calculation: High-volume threshold = configured event cutoff relative to the median volume of prior bars
Long: close >= highest close of the previous two bars
Long: intermediate-lookback moving average < long-lookback moving average AND short-lookback moving average > intermediate-lookback moving average AND short-lookback moving average > its previous value
Long: intermediate-lookback moving average > long-lookback moving average AND short-lookback moving average > intermediate-lookback moving average AND short-lookback moving average > its previous value
Long: low > TrendZones upper curve OR (low > TrendZones center AND low < TrendZones upper curve)
Long: close >= highest close of the previous two bars AND current volume exceeds the high-volume threshold
Short: close < highest close of the previous two bars
Short: intermediate-lookback moving average > long-lookback moving average AND short-lookback moving average < intermediate-lookback moving average AND short-lookback moving average < its previous value
Short: intermediate-lookback moving average < long-lookback moving average AND short-lookback moving average < intermediate-lookback moving average AND short-lookback moving average < its previous value
Short: high < TrendZones center AND high > TrendZones lower curve OR high < TrendZones lower curve
Short: close < highest close of the previous two bars AND current volume exceeds the high-volume threshold