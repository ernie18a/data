Calculation: BodyPctAbove(level) = 0 if close <= level; otherwise 100 if open = close; otherwise 100 * (max(open, close) - max(min(open, close), level)) / abs(close - open)
Calculation: BodyPctBelow(level) = 0 if close >= level; otherwise 100 if open = close; otherwise 100 * (min(max(open, close), level) - min(open, close)) / abs(close - open)
Calculation: PremarketHigh = highest high over premarket-session bars of the current day up to the current bar; undefined if none
Calculation: PremarketLow = lowest low over premarket-session bars of the current day up to the current bar; undefined if none
Calculation: TradeSessionHigh = highest high over trade-session bars of the current day up to the current bar; undefined if none
Calculation: TradeSessionLow = lowest low over trade-session bars of the current day up to the current bar; undefined if none
Calculation: RegimePass = regime filter disabled OR (abs(AnchoredVWAP(VWAP source, trade session) - AnchoredVWAP(VWAP source, trade session)[slope period]) / tick >= min slope ticks AND (Highest(high, range lookback) - Lowest(low, range lookback)) / tick >= min range ticks)
Calculation: TradeCooldownOn = cooldown enabled AND elapsed time since the most recent bar where the position went from open to flat is less than cooldown minutes; false if no such bar
Calculation: LongStopLevel = Lowest(low, stop lookback) - stop buffer * tick, evaluated on the bar of the long entry signal and held while the long is open
Calculation: ShortStopLevel = Highest(high, stop lookback) + stop buffer * tick, evaluated on the bar of the short entry signal and held while the short is open
Calculation: LongVwapOverride = VWAP exit override enabled AND entry price < EMA(close, exit EMA length) on the bar the long opened AND no bar since the long opened, inclusive, has close > EMA(close, exit EMA length) AND close > entry price + min profit ticks * tick
Calculation: ShortVwapOverride = VWAP exit override enabled AND entry price > EMA(close, exit EMA length) on the bar the short opened AND no bar since the short opened, inclusive, has close < EMA(close, exit EMA length) AND close < entry price - min profit ticks * tick
Calculation: LongBreakevenArmed = breakeven enabled AND PM partial enabled AND entry price < PremarketHigh AND some bar since the long opened, inclusive, has high >= PremarketHigh
Calculation: ShortBreakevenArmed = breakeven enabled AND ((PM partial enabled AND entry price > PremarketLow AND some bar since the short opened, inclusive, has low <= PremarketLow) OR (Day partial enabled AND some bar since the short opened, inclusive, has low <= TradeSessionLow))
Long: position flat AND bar in trade session AND TradeCooldownOn = false AND RegimePass = true AND VWAP retest enabled AND low <= AnchoredVWAP(VWAP source, trade session) + retest buffer * tick AND close > AnchoredVWAP(VWAP source, trade session) AND close > EMA(close, longer EMA length, T1, last completed bar) AND (EMA filter disabled OR close > EMA(close, shorter EMA length))
Long: position flat AND bar in trade session AND TradeCooldownOn = false AND RegimePass = true AND PM breakout enabled AND PM breakout mode = Close AND PremarketHigh defined AND BodyPctAbove(PremarketHigh) >= PM breakout body percent AND close > EMA(close, longer EMA length, T1, last completed bar) AND (VWAP filter disabled OR close > AnchoredVWAP(VWAP source, trade session)) AND (EMA filter disabled OR close > EMA(close, shorter EMA length))
Long: position flat AND bar in trade session AND TradeCooldownOn = false AND RegimePass = true AND PM breakout enabled AND PM breakout mode = Retest AND PremarketHigh defined AND low <= PremarketHigh + retest buffer * tick AND close > PremarketHigh AND close > EMA(close, longer EMA length, T1, last completed bar) AND (VWAP filter disabled OR close > AnchoredVWAP(VWAP source, trade session)) AND (EMA filter disabled OR close > EMA(close, shorter EMA length))
Long: position flat AND bar in trade session AND TradeCooldownOn = false AND RegimePass = true AND EMA retest enabled AND low <= EMA(close, shorter EMA length) + retest buffer * tick AND close > EMA(close, shorter EMA length) AND close > EMA(close, longer EMA length, T1, last completed bar) AND (VWAP filter disabled OR close > AnchoredVWAP(VWAP source, trade session))
Short: position flat AND bar in trade session AND TradeCooldownOn = false AND RegimePass = true AND VWAP retest enabled AND high >= AnchoredVWAP(VWAP source, trade session) - retest buffer * tick AND close < AnchoredVWAP(VWAP source, trade session) AND close <= EMA(close, longer EMA length, T1, last completed bar) AND (EMA filter disabled OR close < EMA(close, shorter EMA length))
Short: position flat AND bar in trade session AND TradeCooldownOn = false AND RegimePass = true AND PM breakout enabled AND PM breakout mode = Close AND PremarketLow defined AND BodyPctBelow(PremarketLow) >= PM breakout body percent AND close <= EMA(close, longer EMA length, T1, last completed bar) AND (VWAP filter disabled OR close < AnchoredVWAP(VWAP source, trade session)) AND (EMA filter disabled OR close < EMA(close, shorter EMA length))
Short: position flat AND bar in trade session AND TradeCooldownOn = false AND RegimePass = true AND PM breakout enabled AND PM breakout mode = Retest AND PremarketLow defined AND high >= PremarketLow - retest buffer * tick AND close < PremarketLow AND close <= EMA(close, longer EMA length, T1, last completed bar) AND (VWAP filter disabled OR close < AnchoredVWAP(VWAP source, trade session)) AND (EMA filter disabled OR close < EMA(close, shorter EMA length))
Short: position flat AND bar in trade session AND TradeCooldownOn = false AND RegimePass = true AND EMA retest enabled AND high >= EMA(close, shorter EMA length) - retest buffer * tick AND close < EMA(close, shorter EMA length) AND close <= EMA(close, longer EMA length, T1, last completed bar) AND (VWAP filter disabled OR close < AnchoredVWAP(VWAP source, trade session))
Exit: Long, bar not in trade session
Exit: Long, LongVwapOverride = false AND BodyPctBelow(EMA(close, exit EMA length)) >= EMA exit body percent
Exit: Long, LongVwapOverride = true AND BodyPctBelow(AnchoredVWAP(VWAP source, trade session)) >= VWAP exit body percent
Exit: Long, low <= LongStopLevel
Exit: Long, PM partial enabled AND high >= PremarketHigh AND entry price < PremarketHigh
Exit: Long, Day partial enabled AND high >= TradeSessionHigh
Exit: Long, LongBreakevenArmed = true AND low <= entry price
Exit: Short, bar not in trade session
Exit: Short, ShortVwapOverride = false AND BodyPctAbove(EMA(close, exit EMA length)) >= EMA exit body percent
Exit: Short, ShortVwapOverride = true AND BodyPctAbove(AnchoredVWAP(VWAP source, trade session)) >= VWAP exit body percent
Exit: Short, high >= ShortStopLevel
Exit: Short, PM partial enabled AND low <= PremarketLow AND entry price > PremarketLow
Exit: Short, Day partial enabled AND low <= TradeSessionLow
Exit: Short, ShortBreakevenArmed = true AND high >= entry price