Calculation: Bollinger bands = selected moving average of close ± selected standard-deviation multiple of close
Calculation: MACD = short-period EMA of close − long-period EMA of close; signal = moving average of MACD
Calculation: CCI = (HLC3 − its moving average) / (0.015 × mean absolute deviation of HLC3)
Calculation: Stochastic RSI K = moving average of stochastic RSI; D = moving average of K
Calculation: Percent change = 100 × (close − previous close) / previous close
Long: all enabled required buy-indicator conditions pass AND the number of enabled buy-indicator conditions that pass is at least the buy consensus threshold; each enabled indicator uses its selected detector comparing its value to its threshold or another indicator, or testing a cross of those values
Exit: long, any enabled take-profit condition (highest high since entry ≥ entry price × (1 + profit threshold) AND low ≤ highest high × (1 − trailing-profit threshold)), stop-loss condition (low ≤ entry price × (1 − loss threshold)), trailing-stop condition (low ≤ highest high since entry × (1 − trailing-stop threshold)), or sell consensus condition changes from false to true