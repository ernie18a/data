Calculation: Volume ratio = clamp(volume / SMA(volume, volume window), volume ratio floor, volume ratio cap)
Calculation: Range pct = (high - low) / close * 100
Calculation: ATR pct = ATR(ATR window) / close * 100
Calculation: Range ratio = clamp(Range pct / ATR pct, range ratio floor, range ratio cap)
Calculation: Close position = (close - low) / (high - low), or 0.5 if high = low
Calculation: Energy = Volume ratio * (abs(close - open) / close * 100 * body weight + Range pct * range weight) * Range ratio * (1 + abs(Close position - 0.5) * 2 * location weight)
Calculation: Energy index = 100 * (Energy - Lowest(Energy, index window)) / (Highest(Energy, index window) - Lowest(Energy, index window))
Calculation: Extreme energy = Energy > SMA(Energy, energy window) + STDEV(Energy, energy window) * sensitivity AND Energy index >= extreme index minimum
Calculation: Direction base = ((close - open) / close * 100 * direction weight + (Range pct if close >= open, else -Range pct) * signed range weight + (Close position - 0.5) * 2 * ATR pct * bias weight) * Volume ratio
Calculation: Smoothed direction = EMA(Direction base, direction window)
Calculation: Direction index = 100 * Smoothed direction / Highest(abs(Smoothed direction), index window)
Calculation: Bull extreme = Extreme energy AND Direction index >= direction threshold
Calculation: Bear extreme = Extreme energy AND Direction index <= -direction threshold
Calculation: Bull burst = Direction index >= burst level AND Energy index < extreme index minimum
Calculation: Bear burst = Direction index <= -burst level AND Energy index < extreme index minimum
Calculation: Compression = NOT Extreme energy AND ATR pct < SMA(ATR pct, compression window) * compression factor AND (Volume ratio > volume creep level OR rising(Volume ratio, rising bars)) AND (abs(Direction index) > direction threshold OR rising(abs(Direction index), rising bars)) AND Energy index >= compression index minimum AND Energy index <= compression index maximum
Calculation: Bull compression = Compression AND Direction index > 0
Calculation: Bear compression = Compression AND Direction index < 0
Calculation: Bull memory = bars since Bull extreme <= memory window AND (no Bear extreme yet OR bars since Bull extreme < bars since Bear extreme)
Calculation: Bear memory = bars since Bear extreme <= memory window AND (no Bull extreme yet OR bars since Bear extreme < bars since Bull extreme)
Calculation: Bull reclaim = Bear memory AND Direction index >= burst level
Calculation: Bear reclaim = Bull memory AND Direction index <= -burst level
Calculation: Upside trap = high > Highest(high[1], trap lookback) AND close < Highest(high[1], trap lookback) AND high > low AND high - max(open, close) >= wick ratio * (high - low)
Calculation: Downside trap = low < Lowest(low[1], trap lookback) AND close > Lowest(low[1], trap lookback) AND high > low AND min(open, close) - low >= wick ratio * (high - low)
Calculation: Upside trap signal = (NOT trap confirmation AND Upside trap OR trap confirmation AND Upside trap[1] AND close < low[1]) AND (no previous Upside trap signal OR bars since previous Upside trap signal > trap cooldown)
Calculation: Downside trap signal = (NOT trap confirmation AND Downside trap OR trap confirmation AND Downside trap[1] AND close > high[1]) AND (no previous Downside trap signal OR bars since previous Downside trap signal > trap cooldown)
Calculation: Bull score = energy score weight * Energy index + direction score weight * max(Direction index, 0) + (mass bonus if Volume ratio > mass bonus threshold) + (range bonus if Range ratio > range bonus threshold) + (trend bonus if EMA(close, trend shorter lookback) >= EMA(close, trend longer lookback)) + (reclaim bonus if Bull reclaim) + (compression bonus if Bull compression)
Calculation: Bear score = energy score weight * Energy index + direction score weight * max(-Direction index, 0) + (mass bonus if Volume ratio > mass bonus threshold) + (range bonus if Range ratio > range bonus threshold) + (trend bonus if EMA(close, trend shorter lookback) <= EMA(close, trend longer lookback)) + (reclaim bonus if Bear reclaim) + (compression bonus if Bear compression)
Calculation: Overlay buy = (Bull extreme OR (overlay includes burst and reclaim AND (Bull burst OR Bull reclaim)) OR (overlay includes compression AND Bull compression)) AND (NOT trend filter switch OR EMA(close, trend shorter lookback) >= EMA(close, trend longer lookback)) AND (NOT T1 filter switch OR EMA(close, T1 shorter lookback, T1, last completed bar) >= EMA(close, T1 longer lookback, T1, last completed bar)) AND (NOT session filter switch OR datetime within session) AND Bull score >= minimum grade score AND (no previous Overlay buy OR bars since previous Overlay buy > overlay cooldown)
Calculation: Overlay sell = (Bear extreme OR (overlay includes burst and reclaim AND (Bear burst OR Bear reclaim)) OR (overlay includes compression AND Bear compression)) AND (NOT trend filter switch OR EMA(close, trend shorter lookback) <= EMA(close, trend longer lookback)) AND (NOT T1 filter switch OR EMA(close, T1 shorter lookback, T1, last completed bar) <= EMA(close, T1 longer lookback, T1, last completed bar)) AND (NOT session filter switch OR datetime within session) AND Bear score >= minimum grade score AND (no previous Overlay sell OR bars since previous Overlay sell > overlay cooldown)
Calculation: Target distance = entry price * take-profit percent / 100 if percent distance switch, else ATR(ATR window) at entry bar * take-profit ATR multiple
Calculation: Stop distance = entry price * stop percent / 100 if percent distance switch, else ATR(ATR window) at entry bar * stop ATR multiple
Long: Bull extreme
Long: Bull burst
Long: Bull compression
Long: Downside trap signal
Long: Overlay buy
Short: Bear extreme
Short: Bear burst
Short: Bear compression
Short: Upside trap signal
Short: Overlay sell
Exit: long, bars since entry > 0 AND (low <= entry price - Stop distance OR high >= entry price + Target distance)
Exit: short, bars since entry > 0 AND (high >= entry price + Stop distance OR low <= entry price - Target distance)