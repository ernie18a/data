Calculation: A = the last completed bar of a selected timeframe that is higher than or equal to the chart timeframe; B = the completed bar immediately before A. Recalculate A and B at the start of each selected-timeframe period and retain them until the next period.
Long: A close > B high.
Long: A close < B high AND A close > B low AND A high < B high AND A low < B low.
Long: A high <= B high AND A low >= B low AND B close >= B open.
Short: A close < B low.
Short: A close < B high AND A close > B low AND A high > B high AND A low > B low.
Short: A high <= B high AND A low >= B low AND B close < B open.
Long: The selected timeframe is higher than the chart timeframe AND chart high >= A high AND no earlier chart bar in the current selected-timeframe period has high >= A high.
Short: The selected timeframe is higher than the chart timeframe AND chart low <= A low AND no earlier chart bar in the current selected-timeframe period has low <= A low.