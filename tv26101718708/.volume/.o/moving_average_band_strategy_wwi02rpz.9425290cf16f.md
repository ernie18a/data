Calculation: Upper band = selected moving average of high × (1 + band offset)
Calculation: Lower band = selected moving average of low × (1 − band offset)
Calculation: Long stop = lower band at long entry
Calculation: Short stop = upper band at short entry
Calculation: Long target = entry price + (entry price − long stop) × risk:reward ratio
Calculation: Short target = entry price − (short stop − entry price) × risk:reward ratio
Long: previous close ≤ previous upper band AND close > upper band AND no long position
Short: previous close ≥ previous lower band AND close < lower band AND no short position
Exit: long, low ≤ long stop OR (take-profit enabled AND high ≥ long target) OR (take-profit disabled AND previous close ≥ previous lower band AND close < lower band)
Exit: short, high ≥ short stop OR (take-profit enabled AND low ≤ short target) OR (take-profit disabled AND previous close ≤ previous upper band AND close > upper band)