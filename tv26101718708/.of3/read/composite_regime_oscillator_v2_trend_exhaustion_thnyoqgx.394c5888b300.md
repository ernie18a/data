Calculation: Bounded score(value, lower bound, upper bound) = midpoint score if lower bound = upper bound; otherwise 100 × clamp((value − lower bound) / (upper bound − lower bound), 0, 1)
Calculation: Volatility ratio = ATR(high, low, close, shorter ATR lookback) / ATR(high, low, close, longer ATR lookback)
Calculation: Drawdown fraction = (highest(high, drawdown lookback) − close) / highest(high, drawdown lookback)
Calculation: Range rebound = (close − lowest(low, range lookback)) / lowest(low, range lookback)
Calculation: EMA stretch = (close − EMA(close, EMA lookback)) / ATR(high, low, close, shorter ATR lookback)
Calculation: Range position = (close − lowest(low, range lookback)) / (highest(high, range lookback) − lowest(low, range lookback)); midpoint if the denominator is zero
Calculation: Relative volume = volume / SMA(volume, volume lookback)
Calculation: Distance above range low = (close − lowest(low, range lookback)) / lowest(low, range lookback)
Calculation: Distance below range high = (highest(high, range lookback) − close) / highest(high, range lookback)
Calculation: Regime stress score = 50 if volatility ratio, drawdown fraction, or range rebound is unavailable; otherwise regime volatility weight × bounded score(volatility ratio, volatility lower bound, volatility upper bound) + drawdown weight × bounded score(drawdown fraction, drawdown lower bound, drawdown upper bound) + rebound weight × bounded score(range rebound, rebound lower bound, rebound upper bound)
Calculation: Stretch score = 50 if EMA stretch is unavailable; otherwise stretch weight × bounded score(EMA stretch, stretch lower bound, stretch upper bound) + range weight × bounded score(range position, stretch range lower bound, stretch range upper bound)
Calculation: Price location score = 50 if either distance from a range extreme is unavailable; otherwise range position weight × bounded score(range position, location range lower bound, location range upper bound) + low distance weight × bounded score(distance above range low, low distance lower bound, low distance upper bound) + high distance weight × (100 − bounded score(distance below range high, high distance lower bound, high distance upper bound))
Calculation: Overreaction score = 50 if RSI(close, RSI lookback) is unavailable; otherwise RSI weight × bounded score(RSI(close, RSI lookback), RSI lower bound, RSI upper bound) + stretch weight × bounded score(EMA stretch, overreaction stretch lower bound, overreaction stretch upper bound)
Calculation: Volume pressure score = 50 if relative volume is unavailable; otherwise volume weight × bounded score(relative volume, volume lower bound, volume upper bound) + volatility weight × bounded score(volatility ratio, pressure volatility lower bound, pressure volatility upper bound)
Calculation: Exhaustion oscillator = EMA((regime weight × regime stress score + stretch weight × stretch score + location weight × price location score + overreaction weight × overreaction score + pressure weight × volume pressure score) / sum of those weights, oscillator smoothing lookback); midpoint score if the weight sum is zero
Calculation: Trend exhaustion = exhaustion oscillator ≥ bullish momentum boundary AND falling(exhaustion oscillator, exhaustion lookback)
Long: exhaustion oscillator < lower extreme boundary OR crosses above the upper extreme boundary
Short: exhaustion oscillator ≥ upper extreme boundary OR crosses below the lower extreme boundary
Exit: long, exhaustion oscillator > bullish momentum boundary AND exhaustion oscillator < upper extreme boundary AND trend exhaustion
Exit: short, exhaustion oscillator < lower exhaustion boundary AND exhaustion oscillator ≥ lower extreme boundary AND trend exhaustion