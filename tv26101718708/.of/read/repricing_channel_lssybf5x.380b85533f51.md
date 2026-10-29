Calculation: Block range = highest high minus lowest low within a completed higher-timeframe block aggregated from chart bars.
Calculation: Block volume = sum of volume within that completed block.
Calculation: Block efficiency = block range / block volume.
Calculation: Range ratio = current completed block range / average range of the preceding comparison-window blocks.
Calculation: Volume ratio = current completed block volume / average volume of the preceding comparison-window blocks.
Calculation: Efficiency ratio = current completed block efficiency / average efficiency of the preceding comparison-window blocks.
Calculation: Repricing direction = +1 when completed block close >= its open; otherwise -1.
Calculation: Recent direction average = average repricing direction across the latest channel-window repricing blocks.
Long: Sufficient preceding blocks exist and their average range, volume, and efficiency are positive AND efficiency ratio >= minimum efficiency threshold AND range ratio >= minimum range threshold AND volume cap is disabled OR volume ratio <= maximum volume threshold AND completed block close >= its open OR recent direction average > bullish bias threshold.
Short: Sufficient preceding blocks exist and their average range, volume, and efficiency are positive AND efficiency ratio >= minimum efficiency threshold AND range ratio >= minimum range threshold AND volume cap is disabled OR volume ratio <= maximum volume threshold AND completed block close < its open OR recent direction average < negative bearish bias threshold.