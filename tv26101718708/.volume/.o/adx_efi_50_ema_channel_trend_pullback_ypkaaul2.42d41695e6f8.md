Calculation: Short EFI = 15-period RMA of (current close − previous close) × volume
Calculation: Long EFI = 120-period RMA of (current close − previous close) × volume
Calculation: EMA channel = 50-period EMA of high and 50-period EMA of low
Calculation: Pullback average = 10-period RMA of HLC3
Long: Long EFI > 0 AND Short EFI < 0 AND previous Short EFI < current Short EFI AND ADX(20, 20) ≥ 20 AND open < EMA channel of high AND Pullback average ≥ EMA channel of low
Short: Long EFI < 0 AND Short EFI > 0 AND previous Short EFI > current Short EFI AND ADX(20, 20) ≥ 20 AND open > EMA channel of low AND Pullback average ≤ EMA channel of high
Exit: Long, bar high ≥ long signal bar high + 4 × ATR(14) OR bar low ≤ long signal bar low − 8 × ATR(14)
Exit: Short, bar low ≤ short signal bar low − 4 × ATR(14) OR bar high ≥ short signal bar high + 8 × ATR(14)