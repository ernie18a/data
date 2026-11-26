Calculation: Session VWAP = VWAP(hlc3) when available, otherwise EMA(hlc3, fallback lookback), calculated on chart bars.
Calculation: Adaptive baseline = EMA(blended value, smoothing lookback), where blended value = EMA(close, baseline lookback) + (KAMA(close, efficiency lookback, fast period, slow period) - EMA(close, baseline lookback)) * clamp(efficiency ratio, 0, 1), and efficiency ratio = abs(close - close[efficiency lookback]) / sum(abs(close - close[prior bar]), efficiency lookback), using zero when the denominator is zero.
Calculation: Volatility score = clamp(midpoint score + score half-range * tanh(ATR z-score / score scale), score minimum, score maximum), where ATR z-score = (ATR(ATR lookback) - SMA(ATR(ATR lookback), volatility lookback)) / standard deviation of ATR over the volatility lookback, using zero when the denominator is zero.
Calculation: Order-flow pressure = EMA(100 * volume * (close - open) / (max(high - low, minimum tick) * max(volume, minimum volume divisor)), pressure lookback), calculated on chart bars.
Calculation: VWAP sigma = max(STDEV(hlc3 - session VWAP, channel lookback), minimum tick), calculated on chart bars.
Calculation: Volatility channel center = EMA((adaptive baseline + session VWAP) / 2, max(minimum center lookback, floor(channel lookback / center divisor))); channel half-width = ATR(ATR lookback) * base channel factor * (floor fraction + clamp(volatility score normalized to its full scale, 0, 1)); channel boundaries = center plus or minus half-width.
Calculation: Squeeze is on when Bollinger Bands(close, squeeze lookback, band deviation multiplier) are inside Keltner Channels(close, squeeze lookback, true-range multiplier), calculated on chart bars.
Calculation: Range span = max(highest high(anchor lookback) - lowest low(anchor lookback), minimum tick); equilibrium = lowest low(anchor lookback) + range span * midpoint fraction; discount level = lowest low(anchor lookback) + range span * discount fraction; premium level = lowest low(anchor lookback) + range span * premium fraction.
Calculation: Prior T1 high and low = high and low of the last completed T1 bar, calculated on T1 bars and sampled on chart bars.
Calculation: Higher-timeframe bullish bias = last completed T2 close > EMA(close, fast T2 lookback) AND EMA(close, fast T2 lookback) > EMA(close, slow T2 lookback); calculate close and EMAs on T2 bars and sample them on chart bars.
Calculation: Higher-timeframe bearish bias = last completed T2 close < EMA(close, fast T2 lookback) AND EMA(close, fast T2 lookback) < EMA(close, slow T2 lookback); calculate close and EMAs on T2 bars and sample them on chart bars.
Calculation: Volatility gate = volatility score >= minimum volatility score AND volatility score <= maximum volatility score AND ATR(ATR lookback) / close * 100 <= maximum ATR percentage.
Calculation: Compression gate = compression avoidance disabled OR squeeze is off.
Calculation: Session gate = session restriction disabled OR chart bar is in the configured session.
Calculation: Cooldown gate = no prior entry OR chart bars elapsed since the last entry > cooldown lookback.
Calculation: Daily equity drawdown percentage = (equity recorded on the first chart bar of the current calendar day - current equity) / recorded equity * 100, or zero when recorded equity is not positive.
Calculation: Daily loss gate = daily loss limit is not positive OR daily equity drawdown percentage < daily loss limit.
Calculation: Bullish regime = close > adaptive baseline AND adaptive baseline is rising AND EMA(close, fast chart lookback) > EMA(close, slow chart lookback) AND NOT (ADX(DMI lookback) < range ADX threshold AND volatility score < range volatility threshold).
Calculation: Bearish regime = close < adaptive baseline AND adaptive baseline is falling AND EMA(close, fast chart lookback) < EMA(close, slow chart lookback) AND NOT (ADX(DMI lookback) < range ADX threshold AND volatility score < range volatility threshold).
Calculation: Volume spike = volume > SMA(volume, volume lookback) * volume spike multiplier.
Calculation: Bullish sweep = confirmed chart bar AND ((low < lowest high[prior bar](swing lookback) AND close > lowest high[prior bar](swing lookback) AND close > open AND volume spike) OR (low < prior T1 low AND close > prior T1 low)).
Calculation: Bearish sweep = confirmed chart bar AND ((high > highest high[prior bar](swing lookback) AND close < highest high[prior bar](swing lookback) AND close < open AND volume spike) OR (high > prior T1 high AND close < prior T1 high)).
Calculation: Long VWAP bounce = confirmed chart bar AND low <= session VWAP - VWAP sigma AND close > session VWAP - VWAP sigma AND close > open.
Calculation: Short VWAP rejection = confirmed chart bar AND high >= session VWAP + VWAP sigma AND close < session VWAP + VWAP sigma AND close < open.
Calculation: Long channel reclaim = confirmed chart bar AND low < lower volatility channel boundary AND close > lower volatility channel boundary AND close > open.
Calculation: Short channel rejection = confirmed chart bar AND high > upper volatility channel boundary AND close < upper volatility channel boundary AND close < open.
Calculation: Squeeze release = confirmed chart bar AND squeeze is off AND squeeze was on at the prior chart bar.
Calculation: Long score = count of true conditions: bullish regime; close > session VWAP; close < equilibrium; RSI(close, RSI lookback) > long RSI threshold AND EMA(close, fast chart lookback) > EMA(close, slow chart lookback) AND order-flow pressure > lower pressure threshold; volatility gate; bullish sweep; long VWAP bounce OR long channel reclaim OR squeeze release; higher-timeframe bullish bias.
Calculation: Short score = count of true conditions: bearish regime; close < session VWAP; close > equilibrium; RSI(close, RSI lookback) < short RSI threshold AND EMA(close, fast chart lookback) < EMA(close, slow chart lookback) AND order-flow pressure < upper pressure threshold; volatility gate; bearish sweep; short VWAP rejection OR short channel rejection OR squeeze release; higher-timeframe bearish bias.
Calculation: Long initial stop = min(close - ATR(ATR lookback) * stop ATR multiple, prior T1 low if available, otherwise close - ATR(ATR lookback) * stop ATR multiple).
Calculation: Short initial stop = max(close + ATR(ATR lookback) * stop ATR multiple, prior T1 high if available, otherwise close + ATR(ATR lookback) * stop ATR multiple).
Calculation: Long target = signal close + ATR(ATR lookback) * target ATR multiple; if unavailable during an open position, use average entry price + current ATR(ATR lookback) * target ATR multiple.
Calculation: Short target = signal close - ATR(ATR lookback) * target ATR multiple; if unavailable during an open position, use average entry price - current ATR(ATR lookback) * target ATR multiple.
Calculation: Long trailing stop = min(average entry price - minimum tick, max(previous long stop or average entry price - ATR(ATR lookback) * stop ATR multiple, close - ATR(ATR lookback) * trailing ATR multiple)).
Calculation: Short trailing stop = max(average entry price + minimum tick, min(previous short stop or average entry price + ATR(ATR lookback) * stop ATR multiple, close + ATR(ATR lookback) * trailing ATR multiple)).
Long: bullish regime.
Short: bearish regime.
Long: confirmed chart bar AND bullish regime AND bullish regime was false at the prior chart bar.
Short: confirmed chart bar AND bearish regime AND bearish regime was false at the prior chart bar.
Long: bullish sweep.
Short: bearish sweep.
Long: higher-timeframe bullish bias.
Short: higher-timeframe bearish bias.
Long: close < equilibrium.
Short: close > equilibrium.
Long: close < discount level.
Short: close > premium level.
Long: long score >= minimum confluence score AND (crossover(close, adaptive baseline) OR crossover(close, session VWAP) OR bullish sweep OR long VWAP bounce OR long channel reclaim).
Short: short score >= minimum confluence score AND (crossunder(close, adaptive baseline) OR crossunder(close, session VWAP) OR bearish sweep OR short VWAP rejection OR short channel rejection).
Long: confirmed chart bar AND long score >= minimum confluence score AND (crossover(close, adaptive baseline) OR crossover(close, session VWAP) OR bullish sweep OR long VWAP bounce OR long channel reclaim) AND longs enabled AND session gate AND cooldown gate AND volatility gate AND compression gate AND (long target - close) / (close - long initial stop) >= minimum planned reward-risk AND close > long initial stop AND daily loss gate AND position is flat or short.
Short: confirmed chart bar AND short score >= minimum confluence score AND (crossunder(close, adaptive baseline) OR crossunder(close, session VWAP) OR bearish sweep OR short VWAP rejection OR short channel rejection) AND shorts enabled AND session gate AND cooldown gate AND volatility gate AND compression gate AND (close - short target) / (short initial stop - close) >= minimum planned reward-risk AND close < short initial stop AND daily loss gate AND position is flat or long.
Exit: Long, low <= long trailing stop OR high >= long target OR (regime-flip exits enabled AND confirmed chart bar AND bearish regime AND close < adaptive baseline) OR (confirmed chart bar AND elapsed chart bars since entry >= maximum hold bars).
Exit: Short, high >= short trailing stop OR low <= short target OR (regime-flip exits enabled AND confirmed chart bar AND bullish regime AND close > adaptive baseline) OR (confirmed chart bar AND elapsed chart bars since entry >= maximum hold bars).