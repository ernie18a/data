Calculation: VWRSI = Let VWRMA(x, n) = RMA(x × volume, n) / RMA(volume, n); gain = VWRMA(max(change(close), 0), length), loss = VWRMA(max(-change(close), 0), length); VWRSI = 100 if loss = 0, else 0 if gain = 0, else 100 − 100 / (1 + gain / loss)
Long: VWRSI > its EMA AND prior VWRSI ≤ its prior EMA OR prior VWRSI ≤ oversold level AND VWRSI > oversold level
Short: VWRSI < its EMA AND prior VWRSI ≥ its prior EMA OR prior VWRSI ≥ overbought level AND VWRSI < overbought level
Exit: long, VWRSI < its EMA AND prior VWRSI ≥ its prior EMA
Exit: short, VWRSI > its EMA AND prior VWRSI ≤ its prior EMA