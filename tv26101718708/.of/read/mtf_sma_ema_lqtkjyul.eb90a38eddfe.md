Calculation: Moving averages = enabled SMAs and EMAs of close on the chart timeframe and enabled timeframes equal to or higher than the chart timeframe; SMA lookbacks are shorter than EMA lookbacks, and each lookback is distinct. Use either the still-forming bar or the last completed bar consistently for each timeframe.
Calculation: Rounded value = value rounded to the nearest price increment, with the increment treated as a parameter.
Calculation: Bullish fraction = number of available enabled higher-timeframe or chart-timeframe moving averages whose rounded value is at or below the rounded current chart close, divided by the number of available enabled moving averages across those timeframes.
Calculation: Radar price = rounded chart close from the still-forming bar in live mode or the last completed bar in confirmed mode.
Calculation: Closest support = highest rounded moving average below radar price by more than a parameterized price gap; closest resistance = lowest rounded moving average above radar price by more than the same gap. Consider all available enabled moving averages on the chart timeframe and enabled equal or higher timeframes.
Long: Rounded current chart close >= rounded enabled moving average on an equal or higher timeframe.
Short: Rounded current chart close < rounded enabled moving average on an equal or higher timeframe.
Long: Bullish fraction >= one half.
Short: Bullish fraction < one half.
Long: Closest support exists AND closest resistance exists AND radar price - closest support <= closest resistance - radar price.
Short: Closest support exists AND closest resistance exists AND radar price - closest support > closest resistance - radar price.