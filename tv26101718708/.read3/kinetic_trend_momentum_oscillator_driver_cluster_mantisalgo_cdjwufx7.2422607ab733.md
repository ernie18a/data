Calculation: smoothed price = Ehlers SuperSmoother(hlc3, smoothing cutoff)
Calculation: velocity = EMA((smoothed price - smoothed price[1]) / max(ATR(ATR lookback), minimum tick), velocity smoothing lookback)
Calculation: acceleration = EMA(velocity - velocity[1], acceleration smoothing lookback)
Calculation: acceleration deviation = max(STDEV(acceleration, deviation lookback), deviation floor)
Calculation: normalized acceleration = acceleration / acceleration deviation
Calculation: relative volume = volume / max(nz(SMA(volume, volume lookback)), volume baseline floor)
Calculation: warm-up complete = bar_index >= max(warm-up minimum, smoothing cutoff × smoothing warm-up factor, efficiency lookback × efficiency warm-up factor)
Calculation: bullish launch ready = warm-up complete AND velocity > velocity deadband AND normalized acceleration > launch threshold × launch scaling factor AND KER(smoothed price, efficiency lookback) >= traction threshold AND (volume unavailable OR relative volume >= volume threshold)
Calculation: bearish launch ready = warm-up complete AND velocity < -velocity deadband AND normalized acceleration < -(launch threshold × launch scaling factor) AND KER(smoothed price, efficiency lookback) >= traction threshold AND (volume unavailable OR relative volume >= volume threshold)
Calculation: bullish brake = warm-up complete AND prior signal regime is long AND (acceleration < -(brake sensitivity × brake threshold factor × acceleration deviation) OR velocity crosses below velocity deadband × half-deadband factor OR velocity crosses below zero OR (velocity <= velocity deadband AND acceleration < 0))
Calculation: bearish brake = warm-up complete AND prior signal regime is short AND (acceleration > brake sensitivity × brake threshold factor × acceleration deviation OR velocity crosses above -(velocity deadband × half-deadband factor) OR velocity crosses above zero OR (velocity >= -velocity deadband AND acceleration > 0))
Calculation: signal regime and cooldown = initialize neutral with cooldown elapsed; accept a long launch from neutral or short only when bullish launch ready and bars since the last launch or brake >= cooldown; accept a short launch from neutral or long only when bearish launch ready and bars since the last launch or brake >= cooldown; in an active regime, an eligible opposite launch takes priority over its matching brake, otherwise the matching brake sets the regime neutral; reset elapsed bars on every accepted launch or brake and increment them otherwise; current signal regime is the resulting regime
Long: bullish launch ready AND (prior signal regime is neutral OR prior signal regime is short) AND bars since the last launch or brake >= cooldown
Short: bearish launch ready AND (prior signal regime is neutral OR prior signal regime is long) AND bars since the last launch or brake >= cooldown
Exit: long, bullish brake AND NOT (bearish launch ready AND bars since the last launch or brake >= cooldown)
Exit: short, bearish brake AND NOT (bullish launch ready AND bars since the last launch or brake >= cooldown)
Long: current signal regime is long AND acceleration >= 0
Short: current signal regime is short AND acceleration <= 0