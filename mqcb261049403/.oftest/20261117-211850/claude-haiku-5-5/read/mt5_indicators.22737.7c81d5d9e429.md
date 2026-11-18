Calculation: momentum = selected price - selected price of previous bar, or 0 on the first bar
Calculation: EMA(x, n) = previous EMA(x, n) + 2/(1+n) * (x - previous EMA(x, n)), with EMA(x, n) = x on the first bar
Calculation: TSI = 100 * EMA(EMA(momentum, first period), second period) / EMA(EMA(|momentum|, first period), second period), or 0 if the denominator is 0
Calculation: TSI color = 0 on the first bar; otherwise 1 if TSI > TSI of previous bar, 2 if TSI < TSI of previous bar, else TSI color of previous bar
Long: TSI color = 1 AND TSI color of previous bar != 1
Short: TSI color = 2 AND TSI color of previous bar != 2
Long: TSI > 0 AND TSI of previous bar <= 0
Short: TSI < 0 AND TSI of previous bar >= 0