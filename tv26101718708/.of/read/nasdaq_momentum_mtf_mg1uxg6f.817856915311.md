Calculation: Chart momentum = EMA of (shorter-lookback EMA of close minus longer-lookback EMA of close), then smoothed by an EMA.
Calculation: Chart signal = EMA of chart momentum, with a longer lookback than the momentum smoothing.
Calculation: Higher-timeframe ×5 momentum and signal = the same calculations on bars aggregated to a timeframe higher than the chart timeframe, using the last completed higher-timeframe bar.
Long: Chart momentum > its value on the previous chart bar OR higher-timeframe ×5 momentum > higher-timeframe ×5 signal
Short: Chart momentum < its value on the previous chart bar OR higher-timeframe ×5 momentum < higher-timeframe ×5 signal