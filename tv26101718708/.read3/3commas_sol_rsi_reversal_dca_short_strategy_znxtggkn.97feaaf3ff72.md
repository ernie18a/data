Calculation: LadderDeviation(k) = first deviation * sum over i from 0 to k-1 of deviation multiplier^i
Calculation: TrailLow = lowest close from the first bar where close <= average entry price * (1 - take-profit percent / 100) through the current bar; undefined before that bar
Short: position is flat AND datetime >= window start AND datetime <= window end AND RSI(close, RSI length) crosses below RSI level, computed on T1 bars and taken from the last completed T1 bar
Short: position is short AND datetime >= window start AND datetime <= window end AND filled averaging orders < averaging order count AND close >= entry price * (1 + LadderDeviation(filled averaging orders + 1) / 100)
Exit: short, close >= average entry price * (1 + stop-loss percent / 100)
Exit: short, close >= TrailLow * (1 + trailing percent / 100)