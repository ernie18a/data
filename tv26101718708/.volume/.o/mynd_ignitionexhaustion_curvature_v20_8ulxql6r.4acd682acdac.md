Calculation: Smoothed momentum = EMA of RSI(close)
Calculation: Momentum velocity = smoothed momentum minus its prior-bar value
Calculation: Smoothed velocity = EMA of momentum velocity
Calculation: Momentum acceleration = smoothed velocity minus its prior-bar value
Calculation: Acceleration z-score = (smoothed acceleration minus its rolling mean) divided by its rolling standard deviation; use 0 if standard deviation is 0
Calculation: Higher-timeframe smoothed momentum = EMA of RSI(close) on the higher timeframe’s last completed bar
Calculation: Volume average = rolling average of volume
Long: Acceleration z-score crosses above the positive ignition threshold AND momentum velocity > 0 AND smoothed momentum > oversold level AND smoothed momentum < overbought level AND higher-timeframe smoothed momentum < overbought level
Long: Acceleration z-score crosses above the positive exhaustion threshold AND smoothed momentum <= oversold level AND smoothed momentum was falling over the required lookback ending on the prior bar AND higher-timeframe smoothed momentum <= oversold level AND volume >= volume-climax multiple × volume average
Short: Acceleration z-score crosses below the negative ignition threshold AND momentum velocity < 0 AND smoothed momentum > oversold level AND smoothed momentum < overbought level AND higher-timeframe smoothed momentum > oversold level
Short: Acceleration z-score crosses below the negative exhaustion threshold AND smoothed momentum >= overbought level AND smoothed momentum was rising over the required lookback ending on the prior bar AND higher-timeframe smoothed momentum >= overbought level AND volume >= volume-climax multiple × volume average