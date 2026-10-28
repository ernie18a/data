Calculation: Bull trend = shorter-period EMA > medium-period EMA > longer-period EMA.
Calculation: Bear trend = shorter-period EMA < medium-period EMA < longer-period EMA.
Calculation: Bullish RSI momentum = RSI > its midpoint and below its overbought threshold.
Calculation: Bearish RSI momentum = RSI < its midpoint and above its oversold threshold.
Calculation: Bullish hidden divergence = current low > low at the configured earlier-bar lookback, current RSI < RSI at that lookback, and current RSI below its configured upper bound.
Calculation: Bearish hidden divergence = current high < high at the configured earlier-bar lookback, current RSI > RSI at that lookback, and current RSI above its configured lower bound.
Calculation: Volume spike = current volume > its moving average × configured multiplier.
Calculation: Strong candle = high > low and absolute(close − open) / (high − low) > configured threshold.
Calculation: Long score = count of true conditions among bull trend, bullish RSI momentum, close > VWAP, volume spike, bullish hidden divergence, and strong candle.
Calculation: Short score = count of true conditions among bear trend, bearish RSI momentum, close < VWAP, volume spike, bearish hidden divergence, and strong candle.
Long: Long score ≥ configured minimum score AND long score > previous bar's long score AND the configured cooldown since the previous long signal has elapsed.
Short: Short score ≥ configured minimum score AND short score > previous bar's short score AND the configured cooldown since the previous short signal has elapsed.