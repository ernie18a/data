Calculation: DMI Balance = positive directional indicator divided by the sum of positive and negative directional indicators, multiplied by 100; use 50 if the sum is zero
Calculation: Aroon = (Aroon Up − Aroon Down + 100) / 2, where each Aroon value is 100 × (lookback − bars since the period’s highest high or lowest low) / lookback
Calculation: Trend Correlation = (Pearson correlation of source and bar index over the lookback + 1) × 50
Calculation: Bollinger %B = source’s position between the bands formed by the lookback SMA ± 2 standard deviations, expressed as a percentage; use 50 if band width is zero
Calculation: Up Bars = percentage of the lookback bars where source is greater than its prior-bar value
Calculation: Normalized oscillator = clamp each raw oscillator to 0–100, replace unavailable values with 50, then apply optional EMA smoothing; use the same lookback and smoothing settings for each oscillator
Calculation: Composite = average of the enabled normalized oscillators
Calculation: Bull-zone count = number of enabled normalized oscillators at or above the bull-zone threshold
Calculation: Bear-zone count = number of enabled normalized oscillators at or below the bear-zone threshold
Long: Composite crosses above its midpoint OR Bull-zone count reaches the confluence count from below
Short: Composite crosses below its midpoint OR Bear-zone count reaches the confluence count from below