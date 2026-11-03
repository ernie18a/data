Calculation: Active volume = volume ≥ 1.25 × simple moving average of volume
Calculation: Extreme volume = volume ≥ 1.75 × simple moving average of volume
Calculation: Bull breakout = close > highest high over the breakout lookback, excluding the current bar, AND active volume
Calculation: Bear breakout = close < lowest low over the breakout lookback, excluding the current bar, AND active volume
Calculation: Bias score = +2 when the short-term EMA > medium-term EMA > long-term EMA, −2 when short-term EMA < medium-term EMA < long-term EMA, otherwise 0; then add +1 when close > long-term EMA, otherwise −1; add +1 when RSI > 55, −1 when RSI < 45, otherwise 0; add +2 for a bull breakout, −2 for a bear breakout; add +1 for active volume; add +1 for extreme volume with a bullish EMA stack, or −1 for extreme volume with a bearish EMA stack. The EMA lookbacks are progressively longer from short-term to long-term.
Long: bull breakout OR (NOT bear breakout AND bias score > 0) OR (bias score ≥ 4 AND RSI > 55)
Short: bear breakout OR (NOT bull breakout AND bias score < 0) OR (bias score ≤ −4 AND RSI < 45)
Calculation timeframe: Use the configured scan-timeframe bars; for a higher timeframe, use its current, still-forming bar; for a lower timeframe, use its current, still-forming bar.