Calculation: Upper band = selected moving average of high × (1 + band offset)
Calculation: Lower band = selected moving average of low × (1 − band offset)
Calculation: Long stop = lower band at long entry
Calculation: Short stop = upper band at short entry
Calculation: Long target = long entry price + (long entry price − long stop) × risk:reward ratio
Calculation: Short target = short entry price − (short stop − short entry price) × risk:reward ratio
Long: close crosses above upper band AND long trades are enabled AND position is flat or short
Short: close crosses below lower band AND short trades are enabled AND position is flat or long
Exit: long, low ≤ long stop OR (risk:reward target enabled AND high ≥ long target) OR (risk:reward target disabled AND close crosses below lower band)
Exit: short, high ≥ short stop OR (risk:reward target enabled AND low ≤ short target) OR (risk:reward target disabled AND close crosses above upper band)