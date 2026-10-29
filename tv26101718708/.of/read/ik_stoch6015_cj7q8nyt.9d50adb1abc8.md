Calculation: Stochastic %D = SMA(SMA(100 × (close − lowest low) / (highest high − lowest low), short smoothing), longer smoothing)
Calculation: Higher-timeframe %D = the same stochastic %D calculated on bars aggregated to a timeframe higher than the chart timeframe
Calculation: Long stop = entry close × (1 − loss fraction) if fixed; otherwise, highest close since entry × (1 − loss fraction)
Long: chart-timeframe %D < entry threshold AND chart-timeframe %D > prior chart-timeframe %D AND higher-timeframe %D four completed bars ago ≥ higher-timeframe %D eight completed bars ago
Exit: long, low ≤ long stop OR close > entry price × (1 + profit fraction) OR (chart-timeframe %D < exit threshold AND prior chart-timeframe %D ≥ exit threshold)