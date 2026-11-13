Calculation: UpperBand = highest high over a lookback window ending two bars before the current bar (excludes current and previous bar)
Calculation: LowerBand = lowest low over a lookback window ending two bars before the current bar (excludes current and previous bar); its lookback is independent of UpperBand's and may be equal or different
Long: high > UpperBand AND simple moving average of close on a higher timeframe than the chart, computed on the still-forming higher-timeframe bar, > the same moving average on the previous higher-timeframe bar (rising)
Exit: long, low < LowerBand