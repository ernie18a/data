Calculation: BaseMA = MA(close, lengthMA, typeMA, factorT3, offsetALMA, sigmaALMA) if smoothingEnabled is false, else MA(MA(close, lengthMA, typeMA, factorT3, offsetALMA, sigmaALMA), lengthSmooth, typeSmooth)
Calculation: PriceLowSource = low if highLowSource is true, else close
Calculation: PriceHighSource = high if highLowSource is true, else close
Long: trendPivotEnabled is true AND PivotLow(BaseMA, pivotLength, pivotLength) is not NA
Long: trendPivotEnabled is false AND maFilterEnabled is false AND PivotLow(PriceLowSource, pivotLength, pivotLength) is not NA
Long: trendPivotEnabled is false AND maFilterEnabled is true AND close > BaseMA AND PivotLow(PriceLowSource, pivotLength, pivotLength) is not NA
Short: trendPivotEnabled is true AND PivotHigh(BaseMA, pivotLength, pivotLength) is not NA
Short: trendPivotEnabled is false AND maFilterEnabled is false AND PivotHigh(PriceHighSource, pivotLength, pivotLength) is not NA
Short: trendPivotEnabled is false AND maFilterEnabled is true AND close < BaseMA AND PivotHigh(PriceHighSource, pivotLength, pivotLength) is not NA