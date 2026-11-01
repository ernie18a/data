Calculation: Fast rate = (shorter-period moving average of the selected price - its previous-bar value) / its previous-bar value; use zero if the previous value is zero. The averaging method and price are selectable.
Calculation: Slow rate = (longer-period moving average of the same selected price, using the same averaging method - its previous-bar value) / its previous-bar value; use zero if the previous value is zero.
Long: Fast rate on the chart timeframe >= slow rate on the chart timeframe OR fast rate on the forming higher-timeframe bar >= slow rate on the forming higher-timeframe bar
Short: Fast rate on the chart timeframe < slow rate on the chart timeframe OR fast rate on the forming higher-timeframe bar < slow rate on the forming higher-timeframe bar
Long: Fast rate on the forming higher-timeframe bar >= fast rate on the previous completed higher-timeframe bar
Short: Fast rate on the forming higher-timeframe bar < fast rate on the previous completed higher-timeframe bar
Long: Fast rate on the chart timeframe > 0 AND fast rate on the chart timeframe != fast rate on the previous chart bar
Short: Fast rate on the chart timeframe < 0 AND fast rate on the chart timeframe != fast rate on the previous chart bar