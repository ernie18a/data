Calculation: Mini-chart bars = bars aggregated to a selected timeframe; for a higher timeframe, index 0 is the still-forming bar; for a lower timeframe, index 0 is the latest completed bar; for the chart timeframe, index 0 is the current bar. Higher indices are successively older bars.
Long: Mini-chart bar 1 high > bar 2 high AND bar 1 low >= bar 2 low AND bar 1 close > bar 2 high.
Long: Mini-chart bar 1 low < bar 2 low AND bar 1 high <= bar 2 high AND bar 1 close >= bar 2 low.
Short: Mini-chart bar 1 high > bar 2 high AND bar 1 low >= bar 2 low AND bar 1 close <= bar 2 high.
Short: Mini-chart bar 1 low < bar 2 low AND bar 1 high <= bar 2 high AND bar 1 close < bar 2 low.
Long: For a mini-chart bar at index i >= 0, bar i+1 low > bar i+3 high AND every bar from index i through index 0 has close >= bar i+3 high.
Short: For a mini-chart bar at index i >= 0, bar i+3 low > bar i+1 high AND every bar from index i through index 0 has close <= bar i+3 low.