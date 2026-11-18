Calculation: fast line = EMA(HLC3 from the T1 bar still forming, mapped onto chart bars and shifted by the chart-bar shift parameter, shorter lookback)
Calculation: slow line = EMA(KAMA(HLC3, efficiency-ratio lookback, fast smoothing length, slow smoothing length), longer lookback), calculated on chart bars
Long: fast line crosses above slow line
Short: fast line crosses below slow line