Calculation: Highest high = Maximum high over the lookback, including the current bar; calculated on the chart timeframe or selected higher timeframe using its still-forming bar.
Calculation: Lowest low = Minimum low over the lookback, including the current bar; calculated on the chart timeframe or selected higher timeframe using its still-forming bar.
Calculation: Median price = (high + low) / 2.
Calculation: Short moving average = 1-bar simple moving average of median price.
Calculation: Long moving average = Simple moving average of median price over a longer lookback than the short moving average.
Calculation: Williams %R = Williams %R over its lookback.
Long: Position is not long AND ((high = highest high AND close > short moving average AND close > long moving average AND high > long moving average AND Williams %R >= upper threshold) OR (close >= previous short-position stop level AND high > highest high))
Short: Position is not short AND ((low = lowest low AND close < short moving average AND close < long moving average AND low < long moving average AND Williams %R <= lower threshold) OR (close <= previous long-position stop level AND low < lowest low))