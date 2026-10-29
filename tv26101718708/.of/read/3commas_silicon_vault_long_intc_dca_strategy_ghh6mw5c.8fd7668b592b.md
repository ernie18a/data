Calculation: Safety-order trigger price = base entry price × (1 − cumulative deviation), where cumulative deviation through level n is the sum of the first step multiplied by the step multiplier raised to powers 0 through n−1.
Long: bar is confirmed AND within the configured date window AND no active deal
Long: active deal AND another safety-order level is available AND low ≤ next safety-order trigger price
Exit: long, RSI on the chart timeframe using the last completed bar crosses above its threshold AND close ≥ average entry price × (1 + minimum profit fraction)