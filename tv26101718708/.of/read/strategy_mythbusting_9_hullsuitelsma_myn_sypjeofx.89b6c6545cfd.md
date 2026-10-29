Calculation: LSMA = least-squares linear regression of close over a lookback, with an offset
Calculation: Hull moving average = weighted moving average of 2 × weighted moving average of close over half the lookback minus weighted moving average of close over the full lookback, over the rounded square root of the full lookback
Long: LSMA crosses above the Hull moving average AND the Hull moving average is less than or equal to its value 2 bars ago
Short: LSMA crosses below the Hull moving average AND the Hull moving average is greater than its value 2 bars ago
Exit: long, close < entry price × (1 − stop-loss fraction) OR high ≥ entry price × (1 + take-profit fraction)
Exit: short, close > entry price × (1 + stop-loss fraction) OR low ≤ entry price × (1 − take-profit fraction)