Calculation: Average entry = total quote cost of the base order and filled safety orders / total asset quantity acquired
Calculation: Next safety-order trigger = base entry price × (1 − configured deviation of the next unfilled order / 100)
Long: Flat AND RSI on the chart timeframe < configured threshold AND close < configured price ceiling AND (date filter disabled OR datetime is within the configured active window)
Long: Long position open AND fewer than four safety orders filled AND close ≤ next safety-order trigger AND (date filter disabled OR datetime is within the configured active window)
Exit: Long, close ≥ average entry × (1 + configured take-profit percentage / 100) AND (date filter disabled OR datetime is within the configured active window)