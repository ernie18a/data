Calculation: Kaufman adaptive moving average = previous value + smoothing constant × (HLC3 − previous value), where efficiency ratio = |HLC3 − HLC3[n bars ago]| / sum of absolute one-bar HLC3 changes over n bars, and smoothing constant = (efficiency ratio × (fast smoothing constant − slow smoothing constant) + slow smoothing constant)²; fast and slow smoothing constants are 2/(period+1)
Calculation: Fast line = higher-timeframe Heikin Ashi HLC3, shifted by its configured bar offset; use the last completed higher-timeframe bar
Calculation: Slow line = EMA of the chart-timeframe Heikin Ashi Kaufman adaptive moving average
Long: Fast line > Slow line AND previous Fast line ≤ previous Slow line
Short: Fast line < Slow line AND previous Fast line ≥ previous Slow line