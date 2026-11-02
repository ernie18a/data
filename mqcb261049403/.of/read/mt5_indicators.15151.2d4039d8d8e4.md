Calculation: Input price = a selectable series: open, high, low, (high + low) / 2, (high + low + close) / 3, (high + low + 2 × close) / 4, close, (open + close) / 2, (open + high + low + close) / 4, high if close > open otherwise low if close < open otherwise close, (high + close) / 2 if close > open otherwise (low + close) / 2 if close < open otherwise close, or (high + low + close + low if close < open, otherwise high if close > open, otherwise close) / 2 - (high + low) / 2.
Calculation: JMA change = current Jurik moving average of input price minus its previous value.
Calculation: Rounded change and thresholds = round the JMA change and each of two independent multipliers of the population standard deviation of JMA changes over a lookback to the same price precision.
Calculation: Apply the decisions either on the chart timeframe or using the corresponding still-forming higher-timeframe bar and its previous higher-timeframe bars.
Long: Current JMA > previous JMA.
Short: Current JMA < previous JMA.
Long: Rounded change > first threshold AND rounded change <= second threshold.
Long: Rounded change > second threshold.
Short: Rounded change < -first threshold AND rounded change >= -second threshold.
Short: Rounded change < -second threshold.