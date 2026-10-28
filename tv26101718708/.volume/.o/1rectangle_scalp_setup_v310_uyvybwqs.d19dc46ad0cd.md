Calculation: Source OHLC = chart OHLC or Heikin Ashi OHLC, according to the selected source
Calculation: Previous rectangle high/low = highest source high / lowest source low over the consolidation lookback ending on the last completed bar
Calculation: Previous rectangle is valid = (previous rectangle high − previous rectangle low) / previous source close < configured maximum range percentage
Calculation: Long stop = previous rectangle low − configured stop buffer; buffer is calculated from entry price or rectangle height, according to the selected basis
Calculation: Short stop = previous rectangle high + configured stop buffer; buffer is calculated from entry price or rectangle height, according to the selected basis
Calculation: Long target 2 = entry price + (entry price − long stop) × configured risk-reward multiple
Calculation: Short target 2 = entry price − (short stop − entry price) × configured risk-reward multiple
Long: Previous rectangle is valid AND current source close > previous rectangle high AND previous source close ≤ previous rectangle high AND last signal direction was not long AND current bar is inside the configured session if the session filter is enabled
Short: Previous rectangle is valid AND current source close < previous rectangle low AND previous source close ≥ previous rectangle low AND last signal direction was not short AND current bar is inside the configured session if the session filter is enabled
Exit: long, source low ≤ long stop OR source high ≥ long target 2
Exit: short, source high ≥ short stop OR source low ≤ short target 2