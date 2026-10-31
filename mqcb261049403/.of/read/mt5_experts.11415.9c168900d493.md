Calculation: Bull-bear difference = high + low - 2 × moving average of the selected bar price
Long: Chart-timeframe bull-bear difference > 0
Short: Chart-timeframe bull-bear difference < 0
Long: Higher-timeframe bull-bear difference on the last completed bar > 0 AND its value on the preceding bar <= 0
Short: Higher-timeframe bull-bear difference on the last completed bar < 0 AND its value on the preceding bar >= 0
Exit: long, higher-timeframe bull-bear difference on the last completed bar < 0
Exit: short, higher-timeframe bull-bear difference on the last completed bar > 0
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance