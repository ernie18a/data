Calculation: Ribbon midpoint = mean of EMA(high, each of eight separate ribbon lookbacks ordered longest to shortest)
Calculation: Ribbon high band = maximum of those eight EMAs
Calculation: Ribbon low band = minimum of those eight EMAs
Calculation: RSI-level price = close + n when n >= 0, otherwise close + n * (100 - L) / L, where n = (P - 1) * (average loss * L / (100 - L) - average gain), L is the RSI level parameter, P is its lookback parameter, and average gains and losses are exponentially smoothed positive and negative close changes with alpha 1/P and initial prior values 1
Calculation: Stored candle midpoint = the most recently stored value of (high + low) / 2
Long: EMA(high, shortest ribbon lookback) >= EMA(high, longest ribbon lookback)
Short: EMA(high, shortest ribbon lookback) < EMA(high, longest ribbon lookback)
Long: high > Ribbon midpoint
Short: high < Ribbon midpoint
Long: close > RSI-level price
Short: close <= RSI-level price
Long: close crosses above RSI-level price
Short: close crosses below RSI-level price
Long: open crosses above the stored candle midpoint
Short: open crosses below the stored candle midpoint
Long: high crosses above Ribbon high band at the nonnegative ribbon offset bars ago
Short: high crosses below Ribbon low band at the nonnegative ribbon offset bars ago
Long: high crosses above Ribbon high band at the nonnegative ribbon offset bars ago AND the stored candle midpoint exists AND open > the stored candle midpoint
Short: high crosses below Ribbon low band at the nonnegative ribbon offset bars ago AND the stored candle midpoint exists AND open < the stored candle midpoint
Long: close >= SMA(high, PMA lookback)
Short: close < SMA(high, PMA lookback)