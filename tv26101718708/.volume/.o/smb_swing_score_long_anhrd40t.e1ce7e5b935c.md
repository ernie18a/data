Calculation: Relative volume = current bar volume / average volume over a longer lookback
Calculation: Daily uptrend = 20-day SMA > 50-day SMA > 200-day SMA AND latest daily close > 50-day SMA; use the daily bar still forming
Calculation: Relative strength = instrument’s percentage change over a daily lookback − benchmark’s percentage change over the same lookback; use daily bars still forming
Calculation: Coiled = Bollinger Bands are inside Keltner Channels now OR were inside them within a short recent lookback; use same-timeframe bars
Calculation: Prior range high/low = highest high / lowest low over a lookback of prior completed same-timeframe bars, excluding the current bar
Calculation: Long score = 20 if relative volume ≥ minimum, plus 15 if daily uptrend, plus 15 if relative strength > 0, plus 20 if either long setup below, plus 10 if coiled, plus 10 if absolute distance from close to prior range high divided by close × 100 ≤ proximity threshold, plus 10 if (prior range high − close) / max(close − prior range low, 0.001) ≥ minimum reward-to-risk
Long: close > prior range high AND relative volume ≥ minimum AND coiled AND daily uptrend
Long: prior completed bar’s range as a percentage of its low ≥ minimum move AND its close location within its range ≥ minimum fraction AND its close > its open AND its relative volume ≥ minimum AND current low < prior completed bar’s close AND current close > current open AND current close location within its range > 0.5
Long: long score ≥ 60