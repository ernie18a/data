Calculation: Cumulative averaging-order deviation = first-order deviation plus each subsequent order's deviation, with each step multiplied by the configured step multiplier
Short: Flat AND within the enabled backtest window AND RSI crosses below its configured level (previous RSI ≥ level AND current RSI < level)
Short: Short position open AND within the enabled backtest window AND averaging orders remain AND close ≥ base entry × (1 + cumulative deviation for the next order)
Exit: Short, close ≥ average entry × (1 + configured stop-loss percentage)
Exit: Short, price has reached or fallen below average entry × (1 − configured take-profit percentage) and close ≥ (lowest close since reaching that level) × (1 + configured trailing percentage)