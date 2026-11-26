Calculation: LadderDeviation(k) = sum over i from 1 to k of (first deviation * deviation step multiplier^(i - 1))
Long: position is flat AND RSI(close, RSI length, T1, last completed bar) < RSI level AND datetime >= window start AND datetime <= window end
Long: position is long AND filled averaging orders < maximum averaging orders AND close <= base entry price * (1 - LadderDeviation(filled averaging orders + 1) / 100) AND datetime >= window start AND datetime <= window end
Exit: long, close >= average entry price * (1 + take profit percent / 100)