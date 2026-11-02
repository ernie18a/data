Calculation: Normalized VWAP slope = (session VWAP of typical price minus its value a slope-lookback ago) / (ATR × square root of the slope-lookback); use zero if ATR is not positive and the current VWAP if the earlier VWAP is unavailable.
Calculation: Squeeze = Bollinger Band width, defined as 100 × (upper band − lower band) / middle band when the middle band is positive and zero otherwise, has a rolling percentile rank below a threshold.
Calculation: Regime = squeeze if Squeeze is true; otherwise up if normalized VWAP slope exceeds its positive threshold OR short SMA > medium SMA > long SMA; otherwise down if normalized VWAP slope is below its negative threshold OR short SMA < medium SMA < long SMA; otherwise range. The SMA lengths are ordered short < medium < long.
Calculation: Structure = initially neutral; on each completed bar, update the latest confirmed pivot high and low using equal left and right lookbacks, then set structure bullish if close > latest pivot high and structure was neutral or bearish, and subsequently set it bearish if close < latest pivot low and structure is neutral or bullish.
Calculation: SMI = 100 × EMA(EMA(close − midpoint of the rolling highest high and lowest low, first smoothing length), second smoothing length) / (0.5 × EMA(EMA(rolling highest high − rolling lowest low, first smoothing length), second smoothing length)); use zero if the denominator is zero.
Calculation: Cumulative volume delta = cumulative sum of 2 × estimated buy volume − volume, where estimated buy volume is full volume when close >= open and otherwise volume × (close − low) / (high − low).
Calculation: Bullish displacement = close > open AND high > low AND absolute candle body / (high − low) >= body-ratio threshold AND absolute candle body >= its SMA × body multiplier. Bearish displacement uses the same conditions with close < open.
Calculation: Bullish pattern = enabled pattern detection AND ((close > open AND previous close < previous open AND close > previous open AND open < previous close AND current absolute body > previous absolute body AND volume > volume SMA × volume multiplier) OR (lower wick > absolute body × lower-wick multiplier AND upper wick < absolute body × upper-wick multiplier AND high > low)). Bearish pattern = enabled pattern detection AND ((close < open AND previous close > previous open AND close < previous open AND open > previous close AND current absolute body > previous absolute body AND volume > volume SMA × volume multiplier) OR (upper wick > absolute body × lower-wick multiplier AND lower wick < absolute body × upper-wick multiplier AND high > low)).
Calculation: Entry gate = daily executed-entry count < maximum, resetting on each new exchange day, AND bar opening day is an enabled weekday in the configured timezone AND (session filter disabled OR bar belongs to an enabled session in that timezone).
Calculation: Entry risk distance = ATR at the signal bar × stop multiplier; initial stop and target are fixed from that signal bar's close at entry risk distance and entry risk distance × reward-to-risk multiplier respectively. The tracked entry price is the signal bar's close.
Calculation: Long stop = initial long stop, raised to the greatest eligible close − current ATR × trail multiplier since entry when trailing is enabled and (close − tracked entry price) / (current ATR × stop multiplier) >= trail activation threshold. Short stop = initial short stop, lowered to the least eligible close + current ATR × trail multiplier since entry when trailing is enabled and (tracked entry price − close) / (current ATR × stop multiplier) >= trail activation threshold.
Long: short SMA > medium SMA.
Short: short SMA <= medium SMA.
Long: regime = up.
Short: regime = down.
Long: structure = bullish.
Short: structure = bearish.
Long: RSI > bullish threshold AND SMI > 0.
Short: RSI < bearish threshold AND SMI < 0.
Long: CVD confirmation enabled AND cumulative volume delta > its SMA.
Short: CVD confirmation enabled AND cumulative volume delta < its SMA.
Long: bullish displacement OR bullish pattern.
Short: bearish displacement OR bearish pattern.
Long: entry gate AND regime = up AND structure = bullish AND RSI > bullish threshold AND SMI > 0 AND (CVD confirmation disabled OR cumulative volume delta > its SMA) AND (bullish displacement OR bullish pattern OR (close > short SMA AND close > session VWAP)).
Short: entry gate AND regime = down AND structure = bearish AND RSI < bearish threshold AND SMI < 0 AND (CVD confirmation disabled OR cumulative volume delta < its SMA) AND (bearish displacement OR bearish pattern OR (close < short SMA AND close < session VWAP)).
Exit: long, low <= long stop OR high >= initial long target.
Exit: short, high >= short stop OR low <= initial short target.
Exit: long OR short, forced close enabled AND bar opening day is a weekday in the configured timezone AND bar opening hour = configured close hour AND bar opening minute >= configured close minute.