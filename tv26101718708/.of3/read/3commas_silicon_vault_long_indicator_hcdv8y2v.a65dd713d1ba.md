Calculation: average entry price = total entry notional / total entry quantity for the active deal
Calculation: safety order price(n) = base entry price × (1 − first step percentage × Σ(step coefficient^i, i=0..n−1) / 100)
Long: no active deal at the start of the bar AND (date filter disabled OR datetime is within the inclusive start and end dates), on confirmed chart bars
Long: active deal AND, for each next unfilled safety order n up to the maximum, low <= safety order price(n), on confirmed chart bars
Exit: long, active deal AND close >= average entry price × (1 + minimum profit percentage) AND (RSI close gate disabled OR RSI(close, RSI length, T1, last completed bar) crosses above RSI threshold on chart bars), on confirmed chart bars