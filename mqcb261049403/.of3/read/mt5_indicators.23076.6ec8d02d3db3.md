Calculation: Corrected VWMA = first VWMA; otherwise previous Corrected VWMA + α × (VWMA − previous Corrected VWMA), where α = 0 if (previous Corrected VWMA − VWMA)² ≤ rolling price variance, otherwise 1 − rolling price variance / (previous Corrected VWMA − VWMA)²; rolling price variance = SUM(applied price², correction lookback) / correction lookback − [SUM(applied price, correction lookback) / correction lookback]², with sums using current and up to correction lookback − 1 available prior bars; VWMA uses applied price and selected volume with zero volume replaced by one.
Long: Corrected VWMA > Corrected VWMA[1]
Short: Corrected VWMA < Corrected VWMA[1]
Long: Corrected VWMA > min(Corrected VWMA, level lookback) + upper level percentage × [max(Corrected VWMA, level lookback) − min(Corrected VWMA, level lookback)] / 100
Short: Corrected VWMA < min(Corrected VWMA, level lookback) + lower level percentage × [max(Corrected VWMA, level lookback) − min(Corrected VWMA, level lookback)] / 100
Long: Corrected VWMA > min(Corrected VWMA, level lookback) + [(upper level percentage + lower level percentage) / 2] × [max(Corrected VWMA, level lookback) − min(Corrected VWMA, level lookback)] / 100
Short: Corrected VWMA < min(Corrected VWMA, level lookback) + [(upper level percentage + lower level percentage) / 2] × [max(Corrected VWMA, level lookback) − min(Corrected VWMA, level lookback)] / 100
Long: VWMA > Corrected VWMA
Short: VWMA < Corrected VWMA