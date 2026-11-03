Calculation: Breadth ratio = daily close of advancing stocks ÷ (daily close of advancing stocks + daily close of declining stocks), using the still-forming higher-timeframe bar
Calculation: Volume ratio = daily close of advancing volume ÷ (daily close of advancing volume + daily close of declining volume), using the still-forming higher-timeframe bar
Calculation: Combined ratio = (breadth ratio + volume ratio) ÷ 2 when volume is included; otherwise breadth ratio
Calculation: Smoothed combined ratio = simple moving average of combined ratio
Calculation: Stop-loss level = entry price − volatility multiplier × 14-period ATR on entry; while the position is open, update to the greater of the prior stop-loss level and close − volatility multiplier × 14-period ATR
Long: Current smoothed combined ratio > low threshold AND prior smoothed combined ratio ≤ low threshold
Exit: long, low ≤ stop-loss level OR current bar index − entry bar index ≥ hold periods