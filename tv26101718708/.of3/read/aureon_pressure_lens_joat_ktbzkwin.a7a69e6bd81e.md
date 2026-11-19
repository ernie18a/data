Calculation: normalized impulse = tanh(pressure sensitivity * (close - close[core lookback]) / max(abs(ATR(fast lookback) * sqrt(core lookback)), minimum tick))
Calculation: normalized slope = tanh(pressure sensitivity * (EMA(close, fast lookback) - EMA(close, slow lookback)) / max(abs(ATR(fast lookback)), minimum tick))
Calculation: normalized momentum = tanh(pressure sensitivity * ROC(close, fast lookback) / max(abs(STDEV(ROC(close, fast lookback), core lookback)), minimum tick))
Calculation: normalized range = tanh(pressure sensitivity * clamp((close - (highest(high, core lookback) + lowest(low, core lookback)) / 2) / (max(abs(highest(high, core lookback) - lowest(low, core lookback)), minimum tick) / 2), -1, 1))
Calculation: normalized body = tanh(pressure sensitivity * (close - open) / max(abs(high - low), minimum tick))
Calculation: relative volume = 1 if SMA(volume, core lookback) is unavailable or <= 0, otherwise volume / SMA(volume, core lookback)
Calculation: pressure = score scale * tanh(pressure saturation * (impulse weight * normalized impulse + slope weight * normalized slope + momentum weight * normalized momentum + range weight * normalized range + body weight * normalized body + participation weight * (clamp((relative volume - quiet-volume offset) / participation span, 0, 1) - neutral participation)))
Calculation: conviction = clamp(1 - (abs(normalized impulse - normalized slope) + abs(normalized slope - normalized momentum) + abs(normalized momentum - normalized range) + abs(normalized range - normalized body)) / conviction normalization, 0, 1)
Long: pressure > 0
Short: pressure < 0
Long: pressure > bias threshold
Short: pressure < -bias threshold
Long: pressure > EMA(pressure, signal lookback) AND pressure > 0
Short: pressure < EMA(pressure, signal lookback) AND pressure < 0
Long: pressure >= EMA(pressure, signal lookback)
Short: pressure < EMA(pressure, signal lookback)
Long: on a closed bar, crossover(pressure, EMA(pressure, signal lookback)) AND pressure > 0 AND conviction >= minimum conviction AND relative volume >= minimum relative volume AND pressure > signal threshold
Short: on a closed bar, crossunder(pressure, EMA(pressure, signal lookback)) AND pressure < 0 AND conviction >= minimum conviction AND relative volume >= minimum relative volume AND pressure < -signal threshold