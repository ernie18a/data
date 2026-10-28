Calculation: Williams Vix Fix = (highest close over its lookback − current low) / highest close over its lookback × 100
Calculation: Entry Williams Vix Fix = Williams Vix Fix on the entry bar
Calculation: RSI = Wilder RSI of HLC3
Calculation: Selected moving average = configured moving average of close on the chart or selected resolution, using the last completed resolution bar
Long: close > previous bar open AND current low < previous bar low AND current high > previous bar high AND current open ≤ previous bar open AND selected moving average ≥ its value at the configured color-smoothing lookback
Short: close < previous bar open AND current low < previous bar low AND current high > previous bar high AND current open ≥ previous bar open AND selected moving average < its value at the configured color-smoothing lookback
Exit: long, Williams Vix Fix < Entry Williams Vix Fix / 2 OR Williams Vix Fix > 2 × Entry Williams Vix Fix OR RSI < 35 OR RSI > 65
Exit: short, Williams Vix Fix < Entry Williams Vix Fix / 2 OR Williams Vix Fix > 2 × Entry Williams Vix Fix OR RSI < 35 OR RSI > 65