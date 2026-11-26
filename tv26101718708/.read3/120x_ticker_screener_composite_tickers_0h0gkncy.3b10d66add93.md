Long: (external market close from the still-forming T1 bar sampled on chart bars / previous completed T1 close - 1) * 100 > 0
Short: (external market close from the still-forming T1 bar sampled on chart bars / previous completed T1 close - 1) * 100 < 0
Long: external market close from the still-forming T1 bar > SMA(T1 closes, length measured in T1 bars), calculated on chart bars using the still-forming T1 close
Short: external market close from the still-forming T1 bar < SMA(T1 closes, length measured in T1 bars), calculated on chart bars using the still-forming T1 close
Long: external market close from the still-forming T1 bar > RMA(T1 closes, length measured in T1 bars), calculated on chart bars using the still-forming T1 close
Short: external market close from the still-forming T1 bar < RMA(T1 closes, length measured in T1 bars), calculated on chart bars using the still-forming T1 close
Calculation: PC-RSI = 100 - 100 / (1 + RMA(max(pctChange, 0), length) / RMA(max(-pctChange, 0), length)), where pctChange = (external market close from the still-forming T1 bar / previous completed T1 close - 1) * 100, both RMAs calculated on chart bars using the still-forming T1 close and length measured in T1 bars
Long: PC-RSI < lower RSI threshold
Short: PC-RSI > upper RSI threshold