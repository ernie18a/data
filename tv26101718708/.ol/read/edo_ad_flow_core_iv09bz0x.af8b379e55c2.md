Calculation: A/D = cumulative sum of ((close - open) / (high - low)) * volume; use 0 when high = low
Calculation: Normalized A/D = 100 * (A/D - midpoint of its rolling highest and lowest values) / (half their range); use 0 when the range is 0
Calculation: Fast flow = EMA or SMA of Normalized A/D over a shorter lookback than Slow flow
Calculation: Slow flow = EMA or SMA of Normalized A/D over a longer lookback than Fast flow
Calculation: Histogram = Fast flow - Slow flow
Long: Fast flow > Slow flow OR Fast flow > Slow flow and previous Fast flow <= previous Slow flow OR Histogram >= 0 OR a confirmed bilateral Fast flow pivot low is higher than its prior pivot low while the corresponding price low is lower than its prior price low, and the pivot distance is within the maximum range
Short: Fast flow < Slow flow OR Fast flow < Slow flow and previous Fast flow >= previous Slow flow OR Histogram < 0 OR a confirmed bilateral Fast flow pivot high is lower than its prior pivot high while the corresponding price high is higher than its prior price high, and the pivot distance is within the maximum range