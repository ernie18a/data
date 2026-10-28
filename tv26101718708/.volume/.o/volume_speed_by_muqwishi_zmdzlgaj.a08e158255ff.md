Calculation: Volume measure = volume or HLC3 × volume, using the selected size type
Calculation: Average volume = mean volume measure of the configured sample of selected lower-timeframe bars, excluding the two oldest bars and including the latest bar
Calculation: Direction = sign of the latest nonzero close change across selected lower-timeframe bars; carry the last direction forward when closes are unchanged
Long: latest selected lower-timeframe bar’s volume measure >= Average volume × configured threshold AND Direction > 0
Short: latest selected lower-timeframe bar’s volume measure >= Average volume × configured threshold AND Direction < 0