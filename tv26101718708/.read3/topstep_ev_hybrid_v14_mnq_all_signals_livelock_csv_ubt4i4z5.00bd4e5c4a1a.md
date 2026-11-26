Calculation: Candle body ratio = abs(close - open) / (high - low), or 0 when high = low
Calculation: Upper wick ratio = (high - max(open, close)) / (high - low), or 0 when high = low
Calculation: Lower wick ratio = (min(open, close) - low) / (high - low), or 0 when high = low
Calculation: Chart EMA slope = EMA(close, shared EMA lookback) - EMA(close, shared EMA lookback)[shared slope lag]
Calculation: Relative volume = volume / SMA(volume, chart volume lookback), or 1 when volume or its SMA is unavailable or the SMA is 0
Calculation: Latest confirmed swing high = latest non-null Pivot High(high, swing lookback, swing lookback)
Calculation: Latest confirmed swing low = latest non-null Pivot Low(low, swing lookback, swing lookback)
Calculation: Low volatility = ATR(ATR lookback) < SMA(ATR(ATR lookback), ATR averaging lookback) * low-volatility threshold
Calculation: Range compression = highest(high, compression lookback) - lowest(low, compression lookback) < ATR(ATR lookback) * compression threshold
Calculation: Range expansion = highest(high, expansion lookback) - lowest(low, expansion lookback) > ATR(ATR lookback) * expansion threshold
Calculation: Adverse chart conditions = abs(chart EMA slope) < ATR(ATR lookback) * flat-slope threshold OR low volatility OR range compression OR candle body ratio < weak-body threshold OR (upper wick ratio > excessive-wick threshold OR lower wick ratio > excessive-wick threshold) AND (upper wick ratio[1] > excessive-wick threshold OR lower wick ratio[1] > excessive-wick threshold)
Calculation: Adequate follow-through = ATR(ATR lookback) > SMA(ATR(ATR lookback), ATR averaging lookback) * healthy-volatility threshold OR range expansion
Calculation: Higher-timeframe bullish trend = close[1] on T1's last completed bar > EMA(close, shared EMA lookback, T1, bar still forming)
Calculation: Higher-timeframe bearish trend = close[1] on T1's last completed bar < EMA(close, shared EMA lookback, T1, bar still forming)
Calculation: Higher-timeframe bullish slope = EMA(close, shared EMA lookback, T1, bar still forming) - EMA(close, shared EMA lookback, T1, bar still forming)[shared slope lag] > ATR(ATR lookback, T1, bar still forming) * bullish T1 slope threshold
Calculation: Higher-timeframe bearish slope = EMA(close, shared EMA lookback, T1, bar still forming) - EMA(close, shared EMA lookback, T1, bar still forming)[shared slope lag] < -ATR(ATR lookback, T1, bar still forming) * bearish T1 slope threshold
Calculation: Higher-timeframe extension = abs(close[1] on T1's last completed bar - EMA(close, shared EMA lookback, T1, bar still forming)) > ATR(ATR lookback, T1, bar still forming) * HTF extension threshold
Calculation: Higher-timeframe bullish score = max(0, bullish-trend points if higher-timeframe bullish trend + bullish-slope points if higher-timeframe bullish slope + bullish-displacement points if close > open on the T1 bar still forming and close - open > ATR(ATR lookback, T1, bar still forming) * displacement-body factor * displacement multiplier + bullish-volume-flow points if (volume or its SMA(volume, T1 volume lookback) is unavailable or the SMA is 0 or volume > that SMA) and close > open on the T1 bar still forming + bullish-gap points if low > high[2] on the T1 bar still forming + bullish-CISD points if close > high[1] on the T1 bar still forming + entry-window points during the configured entry window - midday penalty at or after the midday cutoff - extension penalty if higher-timeframe extension - adverse-condition penalty if adverse chart conditions); calculated on chart bars using T1 values, with close[1] from the last completed T1 bar and other T1 values from the bar still forming
Calculation: Higher-timeframe bearish score = max(0, bearish-trend points if higher-timeframe bearish trend + bearish-slope points if higher-timeframe bearish slope + bearish-displacement points if close < open on the T1 bar still forming and open - close > ATR(ATR lookback, T1, bar still forming) * displacement-body factor * displacement multiplier + bearish-volume-flow points if (volume or its SMA(volume, T1 volume lookback) is unavailable or the SMA is 0 or volume > that SMA) and close < open on the T1 bar still forming + bearish-gap points if high < low[2] on the T1 bar still forming + bearish-CISD points if close < low[1] on the T1 bar still forming + entry-window points during the configured entry window - midday penalty at or after the midday cutoff - extension penalty if higher-timeframe extension - adverse-condition penalty if adverse chart conditions); calculated on chart bars using T1 values, with close[1] from the last completed T1 bar and other T1 values from the bar still forming
Calculation: Bullish score dominance = higher-timeframe bullish score > higher-timeframe bearish score + dominance buffer
Calculation: Bearish score dominance = higher-timeframe bearish score > higher-timeframe bullish score + dominance buffer
Calculation: Strong bullish score dominance = higher-timeframe bullish score > higher-timeframe bearish score + strong-dominance buffer
Calculation: Strong bearish score dominance = higher-timeframe bearish score > higher-timeframe bullish score + strong-dominance buffer
Calculation: Bullish golden score = higher-timeframe bullish score is within the configured golden score range AND higher-timeframe bullish score > higher-timeframe bearish score
Calculation: Bearish golden score = higher-timeframe bearish score is within the configured golden score range AND higher-timeframe bearish score > higher-timeframe bullish score
Calculation: Bullish high clean score = high-score-clean setting enabled AND higher-timeframe bullish score >= high-score minimum AND NOT higher-timeframe extension AND range expansion AND candle body ratio >= minimum body ratio AND higher-timeframe bullish score > higher-timeframe bearish score
Calculation: Bearish high clean score = high-score-clean setting enabled AND higher-timeframe bearish score >= high-score minimum AND NOT higher-timeframe extension AND range expansion AND candle body ratio >= minimum body ratio AND higher-timeframe bearish score > higher-timeframe bullish score
Calculation: Bullish leverage score = higher-timeframe bullish score is within the configured bullish leverage range AND higher-timeframe bullish score > higher-timeframe bearish score
Calculation: Bearish leverage score = higher-timeframe bearish score is within the configured bearish leverage range AND higher-timeframe bearish score > higher-timeframe bullish score
Calculation: Bullish caution score = higher-timeframe bullish score is within the configured bullish caution range
Calculation: Bearish caution score = higher-timeframe bearish score is within the configured bearish caution range
Calculation: Bullish T1 setup = higher-timeframe bullish trend AND higher-timeframe bullish score >= configured HTF minimum score AND (bullish golden score OR bullish high clean score) AND (counter-trend blocking disabled OR bullish score dominance)
Calculation: Bearish T1 setup = higher-timeframe bearish trend AND higher-timeframe bearish score >= configured HTF minimum score AND (bearish golden score OR bearish high clean score) AND (counter-trend blocking disabled OR bearish score dominance)
Calculation: Bullish micro score = count of true conditions among low > high[2], close > high[1], and close[1] < open[1] AND close > high[1], evaluated on chart bars using T2 values from the bar still forming
Calculation: Bearish micro score = count of true conditions among high < low[2], close < low[1], and close[1] > open[1] AND close < low[1], evaluated on chart bars using T2 values from the bar still forming
Calculation: Bullish micro confirmation = bullish micro score >= golden-range micro threshold when bullish golden score, otherwise >= non-golden micro threshold
Calculation: Bearish micro confirmation = bearish micro score >= golden-range micro threshold when bearish golden score, otherwise >= non-golden micro threshold
Calculation: Bullish pivot rejection = low < latest confirmed swing low AND close > latest confirmed swing low
Calculation: Bearish pivot rejection = high > latest confirmed swing high AND close < latest confirmed swing high
Calculation: Bullish displacement = close > open AND close - open > ATR(ATR lookback) * displacement-body factor * displacement multiplier
Calculation: Bearish displacement = close < open AND open - close > ATR(ATR lookback) * displacement-body factor * displacement multiplier
Calculation: Bullish pressure = close > open AND relative volume > buy-pressure volume threshold
Calculation: Bearish pressure = close < open AND relative volume > sell-pressure volume threshold
Calculation: Strong bullish pressure = close > open AND relative volume > strong-pressure volume threshold
Calculation: Strong bearish pressure = close < open AND relative volume > strong-pressure volume threshold
Calculation: Bullish flow = bullish pressure AND close > EMA(close, shared EMA lookback)
Calculation: Bearish flow = bearish pressure AND close < EMA(close, shared EMA lookback)
Calculation: Bullish local trigger = (close > EMA(close, shared EMA lookback) AND chart EMA slope > ATR(ATR lookback) * chart slope threshold AND (bullish flow OR strong bullish pressure)) OR ((bullish pivot rejection OR low > high[2] OR close > high[1] OR (close[1] < open[1] AND close > high[1])) AND bullish flow) OR bullish micro confirmation
Calculation: Bearish local trigger = (close < EMA(close, shared EMA lookback) AND chart EMA slope < -ATR(ATR lookback) * chart slope threshold AND (bearish flow OR strong bearish pressure)) OR ((bearish pivot rejection OR high < low[2] OR close < low[1] OR (close[1] > open[1] AND close < low[1])) AND bearish flow) OR bearish micro confirmation
Calculation: Extreme bearish T1 trend = higher-timeframe bearish trend AND higher-timeframe bearish slope AND higher-timeframe bearish score >= extreme bearish score threshold AND strong bearish score dominance AND NOT higher-timeframe extension AND NOT adverse chart conditions
Calculation: Entry quality = candle body ratio >= minimum body ratio AND adequate follow-through AND NOT adverse chart conditions AND NOT higher-timeframe extension
Calculation: Bullish opening gate = outside the opening window OR (higher-timeframe bullish score >= opening score threshold AND strong bullish score dominance AND candle body ratio >= opening body threshold AND bullish micro score >= opening micro threshold)
Calculation: Bearish opening gate = outside the opening window OR (higher-timeframe bearish score >= opening score threshold AND strong bearish score dominance AND candle body ratio >= opening body threshold AND bearish micro score >= opening micro threshold)
Calculation: Bullish breakout exception = breakout exception enabled AND confirmation setting disabled or chart bar confirmed AND inside entry window AND close > EMA(close, shared EMA lookback) AND chart EMA slope > 0 AND close > highest(high[1], breakout lookback) AND candle body ratio >= breakout body threshold AND high - low >= ATR(ATR lookback) * breakout range threshold AND higher-timeframe bullish score >= breakout HTF score threshold AND (bullish micro score >= breakout micro threshold OR bullish displacement OR strong bullish pressure) AND higher-timeframe distance <= ATR(ATR lookback, T1, bar still forming) * breakout extension threshold AND NOT low volatility AND NOT range compression
Calculation: Bearish breakout exception = breakout exception enabled AND confirmation setting disabled or chart bar confirmed AND inside entry window AND close < EMA(close, shared EMA lookback) AND chart EMA slope < 0 AND close < lowest(low[1], breakout lookback) AND candle body ratio >= breakout body threshold AND high - low >= ATR(ATR lookback) * breakout range threshold AND higher-timeframe bearish score >= breakout HTF score threshold AND (bearish micro score >= breakout micro threshold OR bearish displacement OR strong bearish pressure) AND higher-timeframe distance <= ATR(ATR lookback, T1, bar still forming) * breakout extension threshold AND NOT low volatility AND NOT range compression
Calculation: Reversal short exception = reversal exception enabled AND confirmation setting disabled or chart bar confirmed AND inside entry window AND bearish pivot rejection AND bearish displacement AND close < low[1] AND candle body ratio >= reversal body threshold AND higher-timeframe bearish score >= reversal score threshold AND bearish micro score >= reversal micro threshold AND higher-timeframe distance <= ATR(ATR lookback, T1, bar still forming) * reversal extension threshold AND NOT low volatility AND NOT range compression
Calculation: Short objective = highest eligible price below close among low[1] through low[4] when closest-objective setting is enabled, otherwise lowest(low[1], short objective lookback); also include latest confirmed swing low when recent-swing liquidity is enabled and high[1] on T3's last completed bar when prior-period liquidity is enabled
Calculation: Short meaningful high = lowest price above close among signal-bar high when signal-high inclusion is enabled, high[1], highest(high[1], short invalidation lookback), and latest confirmed swing high; use signal-bar high if none qualify
Calculation: Short structure stop = short meaningful high + ATR(ATR lookback) * short structure buffer
Calculation: Short structure risk = short structure stop - close
Calculation: Short objective reward/risk = (close - short objective) / short structure risk when an objective exists and short structure risk > 0
Calculation: Short objective already tapped = an objective exists AND (low <= short objective when current-signal touch blocking is enabled, otherwise lowest(low, objective tap lookback) <= short objective)
Calculation: Short objective is open = an objective exists AND low > short objective
Calculation: Short close location = (close - low) / (high - low), or 0.5 when high = low
Calculation: Valid iceberg short = iceberg model enabled AND confirmation setting disabled or chart bar confirmed AND inside entry window AND (close < lowest(low[1], iceberg breakdown lookback)) AND (bearish pivot rejection OR upper wick ratio >= iceberg rejection-wick threshold OR close < open) AND (bearish micro score >= iceberg micro threshold OR bearish flow OR strong bearish pressure OR bearish displacement) AND higher-timeframe bearish score >= iceberg minimum bearish score AND close < open AND open - close > ATR(ATR lookback) * iceberg impulse threshold AND candle body ratio >= iceberg minimum body ratio AND relative volume >= iceberg minimum relative volume AND short close location <= iceberg maximum close location AND NOT short objective already tapped AND short objective is open AND abs(close - EMA(close, shared EMA lookback)) / ATR(ATR lookback) <= iceberg EMA-extension threshold AND short structure risk <= iceberg risk cap AND short objective reward/risk >= iceberg minimum objective reward/risk AND short structure risk > 0 AND NOT low volatility AND NOT range compression
Calculation: Prospective short stop = short structure stop when structure stops are enabled and the iceberg short is valid, otherwise signal-bar high + ATR(ATR lookback) * standard stop multiple
Calculation: Prospective short risk = prospective short stop - close
Calculation: Long target-space reward/risk = (nearest eligible high above close - close) / (close - long signal-bar low + ATR(ATR lookback) * long stop multiple), when an eligible high exists and long risk > 0; eligible highs are latest confirmed swing high and high[1] on T3's last completed bar, controlled by their respective liquidity settings
Calculation: Short target-space reward/risk = (close - nearest eligible low below close) / prospective short risk, when an eligible low exists and prospective short risk > 0; eligible lows are latest confirmed swing low and low[1] on T3's last completed bar, controlled by their respective liquidity settings
Calculation: Long target space is good = target-space tiering disabled OR no eligible high exists OR long target-space reward/risk >= minimum target-space reward/risk
Calculation: Short target space is good = target-space tiering disabled OR no eligible low exists OR short target-space reward/risk >= minimum target-space reward/risk
Calculation: Tuesday long exception = day-risk patch enabled AND Tuesday AND candle body ratio >= Tuesday long-body threshold
Calculation: Tuesday short exception = Tuesday shorts enabled AND Tuesday AND candle body ratio >= Tuesday short-body threshold
Calculation: Thursday late block = day-risk patch enabled AND Thursday late blocking enabled AND Thursday AND inside late window
Calculation: Thursday wide-short block = day-risk patch enabled AND Thursday AND prospective short risk >= Thursday short-risk limit
Calculation: Long weekday block = (Tuesday blocking enabled AND Tuesday) OR (Thursday blocking enabled AND Thursday) OR (day-risk patch enabled AND Tuesday AND candle body ratio < Tuesday long-body threshold) OR Thursday late block
Calculation: Short weekday block = (Thursday blocking enabled AND Thursday) OR (Tuesday blocking enabled AND Tuesday AND NOT Tuesday short exception) OR (day-risk patch enabled AND Tuesday short blocking enabled AND Tuesday) OR Thursday late block OR Thursday wide-short block
Calculation: Five-minute short permission = chart timeframe is not T4 OR five-minute short blocking disabled OR (extreme-only five-minute shorts enabled AND extreme bearish T1 trend)
Calculation: Bullish candidate = (confirmation setting disabled or chart bar confirmed) AND inside entry window AND bullish T1 setup AND bullish local trigger AND entry quality AND bullish opening gate OR bullish breakout exception
Calculation: Bearish candidate = ((confirmation setting disabled or chart bar confirmed) AND inside entry window AND bearish T1 setup AND bearish local trigger AND entry quality AND bearish opening gate AND five-minute short permission) OR bearish breakout exception OR reversal short exception OR valid iceberg short
Calculation: Unfiltered long event = bullish candidate AND NOT long weekday block AND NOT (weak-body long blocking enabled AND candle body ratio < live long-body threshold)
Calculation: Unfiltered short event = bearish candidate AND NOT short weekday block AND NOT (negative short-body blocking enabled AND candle body ratio is between the configured bad-short-body bounds, inclusive)
Calculation: Bullish high-liquidity target = nearest eligible price above close among latest confirmed swing high and high[1] on T3's last completed bar, subject to their liquidity settings
Calculation: Bearish low-liquidity target = nearest eligible price below close among latest confirmed swing low and low[1] on T3's last completed bar, subject to their liquidity settings
Calculation: Live long day permission = live-pocket day restriction disabled OR (NOT long weekday block AND (Monday OR Wednesday OR Friday OR Tuesday long exception OR (Thursday AND NOT Thursday late block)))
Calculation: Live short day permission = live-pocket day restriction disabled OR (NOT short weekday block AND (Monday OR Wednesday OR Friday OR (Thursday AND NOT Thursday late block AND NOT Thursday wide-short block)))
Calculation: Live long pocket = unfiltered long event AND live long day permission AND candle body ratio >= live long-body threshold AND lower wick ratio <= live long lower-wick limit AND NOT adverse chart conditions AND NOT higher-timeframe extension AND (bullish golden score OR bullish high clean score OR bullish breakout exception) AND bullish score dominance AND bullish micro confirmation
Calculation: Live long A+ pocket = live long pocket AND candle body ratio >= live long A+ body threshold AND long target space is good AND (bullish leverage score OR bullish breakout exception) AND strong bullish score dominance AND inside primary or secondary window
Calculation: Live reversal short pocket = unfiltered short event AND reversal short exception AND live short day permission AND candle body ratio >= live short-body threshold AND short close location <= live reversal close-location limit AND short target space is good AND bearish micro score >= live short micro threshold AND NOT low volatility AND NOT range compression
Calculation: Live reversal short A+ pocket = live reversal short pocket AND inside primary window AND bearish micro score >= live short A+ micro threshold AND strong bearish score dominance
Calculation: Live iceberg short pocket = unfiltered short event AND valid iceberg short AND live short day permission AND inside primary, secondary, or late window
Calculation: Live iceberg short A+ pocket = live iceberg short pocket AND inside primary window AND short objective reward/risk >= iceberg minimum objective reward/risk + iceberg A+ reward/risk increment AND short close location <= iceberg maximum close location AND (bearish micro score >= live iceberg micro threshold OR strong bearish pressure) AND (bearish score dominance OR higher-timeframe bearish score >= iceberg minimum bearish score)
Calculation: Live Tuesday short pocket = unfiltered short event AND Tuesday short exception AND NOT negative short-body block AND candle body ratio >= Tuesday short-body threshold AND bearish micro score >= Tuesday short micro threshold AND NOT low volatility AND NOT range compression
Calculation: Live Tuesday short A+ pocket = live Tuesday short pocket AND candle body ratio >= Tuesday A+ body threshold AND short target space is good AND inside primary or secondary window
Calculation: Base long A+ setup = (unfiltered long event AND bullish leverage score AND primary window AND Monday or Wednesday or Friday AND strong bullish score dominance AND bullish micro score >= base A+ micro threshold AND long target space is good AND NOT bullish caution score) OR (bullish breakout exception AND primary window AND Monday or Wednesday or Friday AND bullish micro score >= base A+ micro threshold AND long target space is good AND higher-timeframe bullish score >= breakout A+ score threshold)
Calculation: Base long A setup = (unfiltered long event AND (bullish golden score OR bullish high clean score) AND inside primary, secondary, or late window AND bullish score dominance AND bullish micro confirmation AND NOT higher-timeframe extension AND NOT adverse chart conditions) OR (bullish breakout exception AND inside primary, secondary, or late window AND bullish micro score >= base A micro threshold AND NOT low volatility AND NOT range compression)
Calculation: Base short A+ setup = (unfiltered short event AND bearish leverage score AND primary window AND Monday or Wednesday or Friday AND strong bearish score dominance AND bearish micro score >= base A+ micro threshold AND short target space is good AND NOT bearish caution score AND extreme bearish T1 trend) OR (reversal short exception AND primary window AND Monday or Wednesday or Friday AND bearish micro score >= base A+ micro threshold AND short target space is good) OR (valid iceberg short AND primary window AND short target space is good AND short objective reward/risk >= iceberg minimum objective reward/risk)
Calculation: Base short A setup = (unfiltered short event AND (bearish golden score OR bearish high clean score) AND primary or secondary window AND Monday or Wednesday or Friday AND strong bearish score dominance AND bearish micro confirmation AND NOT higher-timeframe extension AND NOT adverse chart conditions AND (extreme bearish T1 trend OR chart timeframe is not T4)) OR (reversal short exception AND primary, secondary, or late window AND bearish micro score >= base short A micro threshold AND NOT low volatility AND NOT range compression) OR (valid iceberg short AND primary, secondary, or late window AND NOT low volatility AND NOT range compression)
Calculation: Long tier = if live-pocket tiering is enabled, live long A+ pocket then live long pocket then unfiltered long event then no tier; otherwise base long A+ setup then base long A setup then unfiltered long event then no tier, lowering a tier above B by one tier for the first true condition among Tuesday or Thursday, late window, or poor long target space
Calculation: Short tier = if live-pocket tiering is enabled, any live reversal, iceberg, or Tuesday A+ pocket then any corresponding live pocket then unfiltered short event then no tier; when normal shorts are log-only, assign tier B to a tier above B without a live pocket; otherwise use base short A+ setup then base short A setup then unfiltered short event then no tier, lowering any tier above B by one tier
Calculation: Long signal = unfiltered long event AND flat AND (signal-permission enforcement disabled OR long tier >= configured minimum permitted tier)
Calculation: Short signal = unfiltered short event AND flat AND (signal-permission enforcement disabled OR short tier >= configured minimum permitted tier)
Calculation: Long stop at entry = signal-bar low - ATR(ATR lookback) * long stop multiple
Calculation: Long target at entry = entry price + (entry price - long stop at entry) * target reward/risk
Calculation: Short stop at entry = prospective short stop
Calculation: Short target at entry = short objective when structure stops are enabled and the iceberg short is valid and an objective exists, otherwise entry price - (short stop at entry - entry price) * target reward/risk
Calculation: Long break-even trigger = entry price + (entry price - long stop at entry) * break-even trigger reward/risk
Calculation: Short break-even trigger = entry price - (short stop at entry - entry price) * break-even trigger reward/risk
Long: low < latest confirmed swing low AND close > latest confirmed swing low
Short: high > latest confirmed swing high AND close < latest confirmed swing high
Long: low > high[2]
Short: high < low[2]
Long: close[1] < open[1] AND close > high[1]
Short: close[1] > open[1] AND close < low[1]
Long: close > open AND relative volume > buy-pressure volume threshold AND close > EMA(close, shared EMA lookback)
Short: close < open AND relative volume > sell-pressure volume threshold AND close < EMA(close, shared EMA lookback)
Long: bullish T1 setup
Short: bearish T1 setup
Long: bullish local trigger
Short: bearish local trigger
Long: bullish micro confirmation
Short: bearish micro confirmation
Long: bullish score dominance
Short: bearish score dominance
Long: higher-timeframe bullish score > higher-timeframe bearish score
Short: higher-timeframe bearish score > higher-timeframe bullish score
Long: higher-timeframe bullish score >= configured forecast score threshold AND higher-timeframe bullish score > higher-timeframe bearish score AND NOT higher-timeframe extension
Short: higher-timeframe bearish score >= configured forecast score threshold AND higher-timeframe bearish score > higher-timeframe bullish score AND NOT higher-timeframe extension
Long: long tier >= configured priority tier AND flat
Short: short tier >= configured priority tier AND flat
Long: unfiltered long event AND long tier is B AND flat
Short: unfiltered short event AND short tier is B AND flat
Long: unfiltered long event
Short: unfiltered short event
Long: long signal
Short: short signal
Exit: Long, high >= long target at entry
Exit: Long, low <= long stop at entry before break-even is armed
Exit: Long, break-even enabled AND the high since entry has reached the long break-even trigger AND low <= entry price
Exit: Long, time is at or after the management cutoff OR chart bars since entry >= backup timeout
Exit: Short, low <= short target at entry
Exit: Short, high >= short stop at entry before break-even is armed
Exit: Short, break-even enabled AND the low since entry has reached the short break-even trigger AND high >= entry price
Exit: Short, time is at or after the management cutoff OR chart bars since entry >= backup timeout