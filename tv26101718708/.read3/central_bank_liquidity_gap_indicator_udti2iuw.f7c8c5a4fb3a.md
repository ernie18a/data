Calculation: net liquidity = Fed total assets - Treasury General Account - reverse repo balance, each as last completed T1 values on chart bars
Calculation: weighted M2 growth = SUM over enabled M2 series i of (USD value_i / SUM over enabled M2 series j of USD value_j) * ROC(M2_i, lookback), where USD value = M2 * currency-to-USD rate * China discount, China discount is a parameter for China and 1 otherwise, currency-to-USD rate is 1 for USD and otherwise the exchange rate to USD (inverted where quoted per USD) or a fallback rate when that rate is not positive; M2 and exchange rates are last completed T1 values on chart bars
Calculation: liquidity growth = if net liquidity enabled and US M2 enabled: weighted M2 growth + US weight * blend fraction * (ROC(net liquidity, lookback) - ROC(US M2, lookback)); else if net liquidity enabled: (1 - standalone weight) * weighted M2 growth + standalone weight * ROC(net liquidity, lookback); else: weighted M2 growth
Calculation: divergence = liquidity growth - ROC(comparison index close, lookback), where comparison index close is last completed T1 values on chart bars
Long: divergence >= buy threshold
Long: divergence crosses above buy threshold
Long: divergence >= 0
Long: divergence crosses above 0
Long: divergence > alert threshold