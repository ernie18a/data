Calculation: Indicator line = twice the shorter-lookback moving average of the selected price minus the longer-lookback moving average of the same price, using the same moving-average method for both; calculate on the chart timeframe or on a higher or lower timeframe, using a selected completed bar or the bar still forming.
Calculation: Change = indicator line on the selected bar minus its value on the preceding bar, rounded to the configured price precision plus two decimal places.
Calculation: Thresholds = population standard deviation of the indicator line's consecutive bar-to-bar changes over a lookback ending at the selected bar, multiplied separately by a lower and a higher coefficient; round each result to the configured price precision plus two decimal places.
Long: indicator line on the selected bar > indicator line on the preceding bar.
Long: (change > lower threshold AND change <= higher threshold) OR change > higher threshold.
Long: indicator line on the bar two bars before the selected bar > indicator line on the preceding bar AND indicator line on the selected bar > indicator line on the preceding bar.
Short: indicator line on the selected bar < indicator line on the preceding bar.
Short: (change < -lower threshold AND change >= -higher threshold) OR change < -higher threshold.
Short: indicator line on the bar two bars before the selected bar < indicator line on the preceding bar AND indicator line on the selected bar < indicator line on the preceding bar.
Exit: long, indicator line on the selected bar < indicator line on the preceding bar OR (change < -lower threshold AND change >= -higher threshold) OR change < -higher threshold.
Exit: short, indicator line on the selected bar > indicator line on the preceding bar OR (change > lower threshold AND change <= higher threshold) OR change > higher threshold.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.