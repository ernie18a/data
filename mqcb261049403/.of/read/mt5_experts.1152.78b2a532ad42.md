Calculation: Band center = moving average of the selected OHLC-derived price.
Calculation: Band deviation = square root of the mean squared difference between each selected price in the moving-average lookback and the current band center.
Calculation: Upper band = band center + deviation multiplier × band deviation; lower band = band center − the same deviation multiplier × band deviation.
Long: Chart-timeframe selected price > upper band.
Short: Chart-timeframe selected price < lower band.
Long: Selected price on the last completed higher- or lower-timeframe bar > its upper band AND selected price on the preceding bar <= its upper band.
Short: Selected price on the last completed higher- or lower-timeframe bar < its lower band AND selected price on the preceding bar >= its lower band.
Exit: long, selected price on the last completed higher- or lower-timeframe bar <= its upper band OR low <= entry price − stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, selected price on the last completed higher- or lower-timeframe bar >= its lower band OR high >= entry price + stop-loss distance OR low <= entry price − take-profit distance.