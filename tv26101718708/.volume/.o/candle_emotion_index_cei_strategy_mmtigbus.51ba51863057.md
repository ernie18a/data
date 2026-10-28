Calculation: For each candlestick-pattern score P, P = (previous P + number of matches among the prior N completed bars) / N; initialize P = 0. For engulfing and three-white-soldiers patterns, compare each candidate candle with the immediately preceding older candle(s).
Calculation: Doji = body / range < doji threshold.
Calculation: Spinning top = body / range < spinning-top threshold AND body / range >= doji threshold.
Calculation: Shooting star = upper wick / body > shooting-star threshold AND lower wick < body.
Calculation: Hanging man = lower wick / body > hanging-man threshold AND upper wick < body.
Calculation: Bearish engulfing = close < prior open AND open > prior close AND body / prior body > engulfing threshold.
Calculation: Marubozu = body / range > marubozu threshold.
Calculation: Hammer = lower wick / body > hammer threshold AND upper wick < body.
Calculation: Bullish engulfing = close > prior open AND open < prior close AND body / prior body > engulfing threshold.
Calculation: Three white soldiers = current, prior, and two-bars-prior closes each exceed their opens AND current close > prior close AND prior close > two-bars-prior close.
Calculation: Indecision = (Doji score + spinning-top score) / 2.
Calculation: Fear = (shooting-star score + hanging-man score + bearish-engulfing score) / 3.
Calculation: Greed = (marubozu score + hammer score + bullish-engulfing score + three-white-soldiers score) / 4.
Calculation: CEI = (Indecision + Fear + Greed) / 3.
Long: CEI crosses above the lower threshold AND position is flat AND cooldown has expired.
Short: CEI crosses above the higher threshold AND position is flat AND cooldown has expired.
Exit: long, (close > open AND volume > volume SMA over N bars × volume multiplier AND close > entry price) OR (bars held >= maximum holding period AND close >= entry price) OR (bars held >= loss holding period AND close < entry price × (1 − loss threshold)).
Exit: short, (close < open AND volume > volume SMA over N bars × volume multiplier AND close < entry price) OR (bars held >= maximum holding period AND close <= entry price) OR (bars held >= loss holding period AND close > entry price × (1 + loss threshold)).