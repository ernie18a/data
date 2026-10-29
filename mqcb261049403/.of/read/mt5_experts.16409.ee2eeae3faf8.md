Calculation: Waddah Attar histogram = (short-lookback smoothed applied price − long-lookback smoothed applied price) × smoothed applied price, with the short lookback shorter than the long lookback; all inputs use the configured indicator timeframe, which may be higher, equal to, or lower than the chart timeframe.
Calculation: Histogram color = rising/equal when the current histogram value is greater than or equal to the preceding value; otherwise falling.
Long: On the last completed indicator-timeframe bar, histogram color changes from falling to rising/equal.
Short: On the last completed indicator-timeframe bar, histogram color changes from rising/equal to falling.
Exit: Long, on the last completed indicator-timeframe bar histogram color changes from rising/equal to falling.
Exit: Short, on the last completed indicator-timeframe bar histogram color changes from falling to rising/equal.