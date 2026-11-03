Calculation: Oscillator = 100 × (short-period WMA of close − long-period WMA of close) / ATR; the short WMA period is shorter than the long WMA period
Calculation: σ1 = standard deviation of the oscillator over a lookback period
Calculation: Chaikin Money Flow = SMA(((close − low) − (high − close)) / max(high − low, ε) × volume) / SMA(volume), using the same lookback for both SMAs
Calculation: BTC halving-cycle value = cos(2π × max(timestamp − 2024-04-20 00:00 UTC, 0) / four years − π/4)
Long: Oscillator crosses above −σ1 AND higher-timeframe last completed bar close > EMA50 > EMA200 AND RSI < overbought threshold AND MACD histogram >= its prior value AND Chaikin Money Flow > −0.05 AND volume > its moving average × 0.80 AND BTC halving-cycle value > −0.70
Short: Oscillator crosses below σ1 AND higher-timeframe last completed bar close < EMA50 < EMA200 AND RSI > oversold threshold AND MACD histogram <= its prior value AND Chaikin Money Flow < 0.05 AND volume > its moving average × 0.80 AND BTC halving-cycle value < 0.70
Exit: long, Oscillator crosses below zero OR (RSI > overbought threshold AND RSI crosses below overbought threshold AND higher-timeframe last completed bar close < EMA50 < EMA200)
Exit: short, Oscillator crosses above zero OR (RSI < oversold threshold AND RSI crosses above oversold threshold AND higher-timeframe last completed bar close > EMA50 > EMA200)