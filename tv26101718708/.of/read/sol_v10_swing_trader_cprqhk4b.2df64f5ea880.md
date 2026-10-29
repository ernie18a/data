Calculation: Williams VIX Fix = (highest close over its lookback − current low) / highest close over its lookback × 100; its upper band = its moving average + a multiplier × its standard deviation; its range threshold = its lookback high × a fraction. A WVF event occurs when the previous value was at or above either threshold, the current value is below both, current low > previous low, current close > previous high, current close > close at the strength lookback, and current close < close at either the long or medium lookback. WVF armed = a WVF event occurred within the arm window.
Calculation: Normalized three-bar close location = (current close − lowest low over three bars) / (highest high over three bars − lowest low over three bars), or 0.5 if the range is zero.
Long: WVF event
Long: low <= lower Bollinger Band AND close > lower Bollinger Band
Long: WVF armed AND ADX < its threshold AND efficiency ratio < its threshold, on each evaluated chart or aggregated timeframe; use the latest completed bar of any aggregation above or below the chart timeframe
Short: close <= lower Bollinger Band
Short: previous normalized three-bar close location >= its threshold AND current normalized three-bar close location < its threshold
Exit: Long, low <= entry price − fixed stop distance OR high >= entry price + fixed target distance OR bars since entry >= timeout