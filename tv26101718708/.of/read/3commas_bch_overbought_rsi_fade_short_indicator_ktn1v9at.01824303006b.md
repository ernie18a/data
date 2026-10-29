Short: flat AND the last completed RSI bar on the chart timeframe was at or above its crossing level AND the current completed RSI bar is below its crossing level
Short: short position open AND fewer than the allowed averaging orders have filled AND close >= base entry price × (1 + next cumulative averaging deviation)
Calculation: Next cumulative averaging deviation = first-order deviation plus each subsequent rung's deviation, with rung deviations scaled by the deviation-step multiplier
Calculation: Average entry price = total quote amount deployed / total asset quantity
Exit: short, close >= average entry price × (1 + stop distance) OR (take-profit threshold has been reached AND close >= lowest close since the threshold was reached × (1 + trailing distance))