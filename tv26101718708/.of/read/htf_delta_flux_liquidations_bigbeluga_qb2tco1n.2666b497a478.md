Calculation: Signed volume = volume if chart-bar close > open, otherwise -volume.
Calculation: Cumulative delta = sum of signed volume from the first chart bar of the still-forming higher-timeframe bar through the current chart bar.
Calculation: Prior delta path = cumulative delta at the end of each preceding chart bar in the still-forming higher-timeframe bar.
Calculation: Historical bias average = average of +1 for each completed higher-timeframe bar whose close >= open and -1 otherwise, over the available bars in a configurable history lookback.
Long: Still-forming higher-timeframe bar close >= open.
Short: Still-forming higher-timeframe bar close < open.
Long: Completed higher-timeframe bar close >= open.
Short: Completed higher-timeframe bar close < open.
Long: Historical bias average > 0.
Short: Historical bias average <= 0.
Long: Prior delta path contains at least one value AND cumulative delta >= 0.
Short: Prior delta path contains at least one value AND cumulative delta < 0.
Long: Prior delta path contains at least two values AND absolute signed volume > configurable multiplier * standard deviation of prior delta path AND signed volume > 0.
Short: Prior delta path contains at least two values AND absolute signed volume > configurable multiplier * standard deviation of prior delta path AND signed volume < 0.