Calculation: RSI signal = RSI of closes on the chart timeframe or a higher timeframe, using the last completed bar and the preceding completed bar; evaluate once at the start of each chart bar.
Calculation: MA signal = simple moving average of closes on the chart timeframe or a higher timeframe, using the last completed bar and the preceding completed bar; the current chart price is the close of the forming chart bar.
Long: Last completed RSI > preceding RSI AND last completed RSI < upper RSI threshold.
Long: Last completed MA > preceding MA AND last completed MA > current chart price.
Short: Last completed RSI < preceding RSI AND last completed RSI > lower RSI threshold.
Short: Last completed MA < preceding MA AND last completed MA < current chart price.
Exit: long, last completed RSI < preceding RSI AND last completed RSI > lower RSI threshold.
Exit: short, last completed RSI > preceding RSI AND last completed RSI < upper RSI threshold.
Exit: long, last completed MA < preceding MA AND last completed MA < current chart price.
Exit: short, last completed MA > preceding MA AND last completed MA > current chart price.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.