Calculation: Shifted upper channel = highest high over a configurable lookback ending a configurable number of bars before the evaluated bar.
Calculation: Shifted lower channel = lowest low over the same lookback ending the same number of bars before the evaluated bar.
Long: Chart bar close > shifted upper channel.
Short: Chart bar close < shifted lower channel.
Long: Selected indicator-timeframe bar close > its shifted upper channel AND previous indicator-timeframe bar close <= its shifted upper channel. The indicator timeframe is configurable as higher, lower, or equal to the chart timeframe; the selected bar is a configurable historical bar, including the last completed bar or the still-forming bar.
Short: Selected indicator-timeframe bar close < its shifted lower channel AND previous indicator-timeframe bar close >= its shifted lower channel. The indicator timeframe and selected bar follow the same rules as for the indicator-timeframe long decision.
Exit: long, selected indicator-timeframe bar close < its shifted lower channel.
Exit: short, selected indicator-timeframe bar close > its shifted upper channel.
Exit: long, low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.