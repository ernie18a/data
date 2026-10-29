Calculation: Average entry price = total entry notional divided by total quantity, including the base order and filled safety orders.
Calculation: Safety order price at level n = base entry price × (1 − cumulative deviation through level n / 100), where each level’s deviation is the first-level percentage step multiplied by the step coefficient to the power of (level − 1).
Long: Position is flat AND bar is confirmed
Long: Position is long AND another safety order is available AND low ≤ next safety order price AND bar is confirmed
Exit: long, RSI crosses above its threshold on the last completed bar of its configured timeframe AND close ≥ average entry price × (1 + minimum profit percentage) AND bar is confirmed