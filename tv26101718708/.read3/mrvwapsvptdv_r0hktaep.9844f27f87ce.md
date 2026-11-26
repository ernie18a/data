Calculation: Anchored VWAP = VWAP(source parameter, selected anchor parameter), calculated on chart bars and reset by the selected anchor/session settings.
Calculation: VWAP deviation = anchored VWAP standard deviation × VWAP band-width parameter.
Calculation: Upper band = Anchored VWAP + VWAP deviation.
Calculation: Lower band = Anchored VWAP − VWAP deviation.
Calculation: Upper entry-zone bounds = [Upper band − VWAP deviation × upper inner-offset parameter, Upper band + VWAP deviation × upper inner-offset parameter].
Calculation: Upper value-area-high zone = [Upper band, Upper band + VWAP deviation × upper outer-offset parameter].
Calculation: Lower entry-zone bounds = [Lower band − VWAP deviation × lower inner-offset parameter, Lower band + VWAP deviation × lower inner-offset parameter].
Calculation: Lower value-area-low zone = [Lower band − VWAP deviation × lower outer-offset parameter, Lower band].
Long: The following condition changes from false to true on successive chart bars: Anchored VWAP is available AND close[1] is within the upper entry-zone bounds[1] AND volume × close ≥ dollar-volume-rate parameter × chart-timeframe multiplier AND developing POC source is within the upper entry-zone bounds[1] AND developing value-area-high source is between Upper band[1] and the upper value-area-high zone's upper bound[1] AND floor(risk-per-trade parameter ÷ abs(Upper band − Anchored VWAP)) > 0.
Short: The following condition changes from false to true on successive chart bars: Anchored VWAP is available AND close[1] is within the lower entry-zone bounds[1] AND volume × close ≥ dollar-volume-rate parameter × chart-timeframe multiplier AND developing POC source is within the lower entry-zone bounds[1] AND developing value-area-low source is between the lower value-area-low zone's lower bound[1] and Lower band[1] AND floor(risk-per-trade parameter ÷ abs(Upper band − Anchored VWAP)) > 0.
Exit: Long, low ≤ Anchored VWAP − (minimum price increment × stop-offset parameter).
Exit: Short, high ≥ Anchored VWAP + (minimum price increment × stop-offset parameter).