Calculation: Renko open/close = open and close of Renko bars built from OHLC bars at the selected source resolution using configured ATR-based or traditional brick sizing; if the source resolution differs from the chart timeframe, use the still-forming Renko bar (lookahead enabled).
Calculation: Renko range = absolute value of Renko close minus Renko open.
Calculation: Smoothed stochastic K = moving average of the stochastic oscillator over its smoothing lookback; smoothed stochastic D = moving average of K over its smoothing lookback, using chart-timeframe bars.
Long: Renko close crosses above Renko open
Long: Renko close > Renko open AND previous K < previous D AND previous K < lower stochastic threshold AND K > D
Short: Renko close crosses below Renko open
Short: Renko close < Renko open AND previous K > previous D AND previous K > upper stochastic threshold AND K < D
Exit: long, close < Renko open - Renko range / 2
Exit: short, close > Renko open + Renko range / 2