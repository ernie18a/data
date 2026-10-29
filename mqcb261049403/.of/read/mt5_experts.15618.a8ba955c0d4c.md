Calculation: Smoothed close = configured price smoother applied to each indicator-timeframe bar’s close; use completed bars.
Calculation: Smoothed open = the same configured price smoother and parameters applied to each indicator-timeframe bar’s open; use completed bars.
Long: Previous completed indicator-timeframe bar: smoothed close > smoothed open AND latest completed indicator-timeframe bar: smoothed close <= smoothed open.
Short: Previous completed indicator-timeframe bar: smoothed close < smoothed open AND latest completed indicator-timeframe bar: smoothed close >= smoothed open.
Exit: long, latest completed indicator-timeframe bar: smoothed close < smoothed open.
Exit: short, latest completed indicator-timeframe bar: smoothed close > smoothed open.