Calculation: Six chart-timeframe simple moving averages of close, ordered from shortest to longest lookback.
Calculation: Confirmed break below a moving average = close is below it for the configured number of consecutive bars; the break event occurs on the first bar this becomes true.
Calculation: Near a moving average = close is within the configured percentage distance of it and above 99% of its value.
Calculation: First touch = the condition is true on this bar and was false on the prior bar.
Long: (shortest moving average > second-shortest moving average > third-shortest moving average AND close > second-shortest moving average) OR (downtrend AND first touch of the third-shortest moving average) OR (downtrend AND first touch of the fifth-shortest moving average), where downtrend = shortest moving average < second-shortest moving average < third-shortest moving average AND close < second-shortest moving average
Short: shortest moving average < second-shortest moving average < third-shortest moving average AND close < second-shortest moving average OR first confirmed break below any of the second-, third-, fourth-, or fifth-shortest moving averages
Exit: long, first confirmed break below the second-shortest moving average
Exit: long, first confirmed break below the third-shortest moving average
Exit: long, first confirmed break below the fifth-shortest moving average