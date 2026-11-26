Calculation: blended average entry = sum(fill quote size) / sum(fill quote size / fill close) across the base order and all filled safety-order rungs, each with its own order-size parameter
Long: flat and RSI(close, RSI lookback, T1, last completed bar), sampled on chart bars, < RSI threshold at chart bar close
Long: long position open, a next unfilled safety-order rung exists, and chart close <= base-order entry price * (1 - that rung's independently parameterized deviation / 100)
Exit: long, chart close >= blended average entry * (1 + take-profit percentage / 100)