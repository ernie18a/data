Calculation: Rolling high = highest high over the current bar and the preceding lookback bars
Calculation: Rolling low = lowest low over the current bar and the preceding lookback bars
Calculation: Median-price moving average = simple moving average of (high + low) / 2
Calculation: Long stop = rolling low − 2 × current-bar spread; while long, keep it from decreasing unless the preceding bar had a short stop
Calculation: Long take-profit = rolling high + 3 × current-bar spread; while long, keep it from decreasing unless the preceding bar had a short stop
Calculation: Short stop = rolling high + 3 × current-bar spread; while short, keep it from increasing unless the preceding bar had a long stop
Calculation: Short take-profit = rolling low − 2 × current-bar spread; while short, keep it from increasing unless the preceding bar had a long stop
Long: (position is flat or short) AND ((high >= rolling high AND close > (high + low) / 2 AND close > median-price moving average AND high > median-price moving average AND RSI >= upper threshold) OR (close >= preceding bar's short stop AND high > rolling high))
Short: (position is flat or long) AND ((low <= rolling low AND close < (high + low) / 2 AND close < median-price moving average AND low < median-price moving average AND RSI <= lower threshold) OR (close <= preceding bar's long stop AND low < rolling low))
Exit: long, low <= long stop OR high >= long take-profit
Exit: short, high >= short stop OR low <= short take-profit