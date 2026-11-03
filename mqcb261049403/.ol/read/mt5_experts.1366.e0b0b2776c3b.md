Calculation: Smoothed trend oscillator = Smooth the percentage of the lookback-ordered moving averages of LRMA that LRMA exceeds, where LRMA = 3 × LWMA(selected OHLC price) − 2 × SMA(selected OHLC price); evaluate on the configured indicator timeframe, using its selected signal bar and prior bars (last completed bar unless the selected bar is still forming).
Calculation: Volatility ratio = 100 × short-lookback standard deviation of close-price momentum / long-lookback standard deviation of close-price momentum; the short lookback is shorter than the long lookback. Evaluate on the configured indicator timeframe and selected signal bar as above.
Long: Smoothed trend oscillator > 0
Short: Smoothed trend oscillator < 0
Long: Breakdown mode AND prior oscillator ≤ upper level AND latest oscillator > upper level AND volatility ratio > trend threshold
Short: Breakdown mode AND prior oscillator ≥ lower level AND latest oscillator < lower level AND volatility ratio > trend threshold
Long: Twist mode AND oscillator was falling over the preceding interval AND latest oscillator > prior oscillator AND volatility ratio > trend threshold
Short: Twist mode AND oscillator was rising over the preceding interval AND latest oscillator < prior oscillator AND volatility ratio > trend threshold
Exit: short, oscillator crosses above upper level
Exit: long, oscillator crosses below lower level