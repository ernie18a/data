Calculation: short-lookback VWMA = VWMA(SMA(close, smoothing lookback), shorter VWMA lookback)
Calculation: long-lookback VWMA = VWMA(SMA(close, smoothing lookback), longer VWMA lookback)
Calculation: stop-lookback VWMA = VWMA(SMA(close, smoothing lookback), stop VWMA lookback)
Short: short-lookback VWMA crosses above long-lookback VWMA
Long: short-lookback VWMA crosses below long-lookback VWMA
Exit: short, short-lookback VWMA crosses below stop-lookback VWMA
Exit: long, short-lookback VWMA crosses above stop-lookback VWMA