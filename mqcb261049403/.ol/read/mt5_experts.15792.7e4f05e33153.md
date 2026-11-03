Calculation: Double-smoothed line = apply a configurable moving-average smoother to the selected applied price, then apply a second configurable moving-average smoother to the result; round the result to the configured decimal precision. Calculate on the indicator timeframe, which may be higher or lower than the chart timeframe, using completed bars.
Calculation: Line state = rising when the line is greater than its previous value, falling when it is less, and otherwise carry forward the previous state.
Long: On the signal bar, line state is rising AND the preceding bar’s line state is not rising.
Short: On the signal bar, line state is falling AND the preceding bar’s line state is not falling.
Exit: Long, on the signal bar, line state is falling AND the preceding bar’s line state is not falling.
Exit: Short, on the signal bar, line state is rising AND the preceding bar’s line state is not rising.