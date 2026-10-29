Calculation: Opening volatility factor = clamp(1 + (opening-range / rolling average of opening ranges over the longer-term daily lookback − 1) × influence, lower bound, upper bound); opening range is the high minus low of the first N chart-timeframe bars of the current session, and the average uses prior completed sessions.
Calculation: CPR width factor = clamp(1 + (1 − current CPR width / rolling average CPR width over the longer-term daily lookback) × influence, lower bound, upper bound); CPR width is calculated from the previous completed daily bar's high, low, and close.
Calculation: Volatility-index factor = clamp(previous completed daily volatility-index close / neutral level, lower bound, upper bound), or 1 when disabled or unavailable.
Calculation: Projected range half-width = previous completed daily ATR × base-range multiplier × opening volatility factor × CPR width factor × volatility-index factor ÷ 2.
Calculation: Projected high/low = current session open ± projected range half-width.
Calculation: Expansion high/low = current session open ± (previous completed daily ATR × expansion multiplier × opening volatility factor × CPR width factor × volatility-index factor ÷ 2).
Long: opening window is complete AND current bar is confirmed AND low crosses below projected low
Long: opening window is complete AND current bar is confirmed AND high crosses above expansion high
Short: opening window is complete AND current bar is confirmed AND high crosses above projected high
Short: opening window is complete AND current bar is confirmed AND low crosses below expansion low