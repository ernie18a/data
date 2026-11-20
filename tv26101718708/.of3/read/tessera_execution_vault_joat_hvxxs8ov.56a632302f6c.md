Calculation: Candle range = max(high - low, minimum tick-size parameter)
Calculation: Body direction = positive unit if close > open, zero if close < open, half if close = open
Calculation: Estimated buy share = clamp(((close - low) / candle range) * close-position coefficient + body direction * body-direction coefficient + (abs(close - open) / candle range) * (body direction - half) * body-power coefficient + baseline coefficient, between zero and one)
Calculation: Estimated buy volume = volume * estimated buy share; estimated sell volume = volume * (one minus estimated buy share)
Calculation: Pressure imbalance = rolling sum(estimated buy volume - estimated sell volume, pressure lookback) / rolling sum(estimated buy volume + estimated sell volume, pressure lookback), scaled as a percentage, or zero if the denominator is not positive
Calculation: CVD proxy = cumulative sum(estimated buy volume - estimated sell volume)
Calculation: Uptrend = EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) AND close > EMA(close, shorter EMA lookback); shorter EMA lookback is less than longer EMA lookback
Calculation: Downtrend = EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback) AND close < EMA(close, shorter EMA lookback)
Calculation: ATR percentage = ATR(close, ATR lookback) as a percentage of close, or zero if close is zero
Calculation: Volume expansion = volume > SMA(volume, volume lookback) * volume multiplier OR volume z-score > volume z-score threshold, where volume z-score is (volume - SMA(volume, volume lookback)) / STDEV(volume, volume lookback), or zero if the standard deviation is not positive
Calculation: CVD signal = EMA(CVD proxy, CVD signal lookback)
Calculation: Rising CVD proxy = CVD proxy > CVD signal AND CVD signal >= its value on the previous chart bar
Calculation: Falling CVD proxy = CVD proxy < CVD signal AND CVD signal <= its value on the previous chart bar
Calculation: VWAP ATR distance = (close - session VWAP(hlc3)) / ATR(close, ATR lookback), or zero if ATR is not positive
Calculation: Lower-band reclaim = VWAP ATR distance < negative VWAP-band ATR multiple AND close > open
Calculation: Upper-band rejection = VWAP ATR distance > VWAP-band ATR multiple AND close < open
Calculation: Bullish rejection = lower wick > max(abs(close - open), minimum tick size) * bullish-wick multiple AND close > open AND close > low + candle range * bullish-close-location parameter
Calculation: Bearish rejection = upper wick > max(abs(close - open), minimum tick size) * bearish-wick multiple AND close < open AND close < low + candle range * bearish-close-location parameter
Calculation: Prior low = lowest low over the structure lookback bars immediately preceding the current bar; prior high = highest high over those bars
Calculation: Downside sweep = low < prior low AND close > prior low AND close > open
Calculation: Upside sweep = high > prior high AND close < prior high AND close < open
Calculation: Compression = (highest high minus lowest low over the compression lookback, divided by close and expressed as a percentage) < ATR percentage * compression-range multiple AND abs(EMA(close, shorter EMA lookback) - EMA(close, longer EMA lookback)) < ATR(close, ATR lookback) * compression-spread multiple
Calculation: Long expansion break = compression on the previous chart bar AND close > the highest high over the breakout lookback bars immediately preceding the current bar AND volume expansion
Calculation: Short expansion break = compression on the previous chart bar AND close < the lowest low over the breakout lookback bars immediately preceding the current bar AND volume expansion
Calculation: Regime = bullish when uptrend AND close >= session VWAP(hlc3); bearish when downtrend AND close <= session VWAP(hlc3); neutral otherwise
Calculation: Bullish continuation rate = bullish-hold tally / (bullish-hold tally + bullish-reversal tally) as a percentage; bearish continuation rate = bearish-hold tally / (bearish-hold tally + bearish-reversal tally) as a percentage; flat-break rate = the greater of the neutral-to-bullish and neutral-to-bearish tallies divided by their sum, as a percentage. Each tally starts with one count; on confirmed chart bars, increment the hold tally when the previous and current regimes match bullish or bearish, the reversal tally when they change from bullish to bearish or bearish to bullish, and the corresponding neutral-to-direction tally when the previous regime is neutral and the current regime is directional. Do not reset tallies.
Calculation: Long confluence score = clamp(sum of: trend weight if uptrend; VWAP weight if close >= session VWAP(hlc3); ATR weight if ATR percentage >= minimum ATR percentage; DMI weight if ADX(DI lookback, ADX smoothing) > ADX threshold AND +DI > -DI; RSI weight if RSI(close, RSI lookback) > RSI midpoint AND RSI >= its value on the previous chart bar; volume weight if volume expansion; strong-pressure weight if pressure imbalance > strong-pressure threshold, otherwise weak-pressure weight if pressure imbalance is positive; CVD weight if rising CVD proxy; auction weight if lower-band reclaim; rejection weight if bullish rejection; sweep weight if downside sweep; breakout weight if long expansion break; continuation weight if bullish continuation rate > continuation threshold, otherwise flat-break weight if flat-break rate > flat-break threshold AND regime is bullish; zero for each unmet condition), to the score floor and ceiling
Calculation: Short confluence score = clamp(sum of: trend weight if downtrend; VWAP weight if close <= session VWAP(hlc3); ATR weight if ATR percentage >= minimum ATR percentage; DMI weight if ADX(DI lookback, ADX smoothing) > ADX threshold AND -DI > +DI; RSI weight if RSI(close, RSI lookback) < RSI midpoint AND RSI <= its value on the previous chart bar; volume weight if volume expansion; strong-pressure weight if pressure imbalance < negative strong-pressure threshold, otherwise weak-pressure weight if pressure imbalance is negative; CVD weight if falling CVD proxy; auction weight if upper-band rejection; rejection weight if bearish rejection; sweep weight if upside sweep; breakout weight if short expansion break; continuation weight if bearish continuation rate > continuation threshold, otherwise flat-break weight if flat-break rate > flat-break threshold AND regime is bearish; zero for each unmet condition), to the score floor and ceiling
Calculation: Bias = bullish if long confluence score > short confluence score + score-spread parameter; bearish if short confluence score > long confluence score + score-spread parameter; neutral otherwise
Calculation: Confirmation gate = close-confirmation parameter is disabled OR the current chart bar is confirmed
Calculation: Cooldown ready = no prior signal bar exists OR current chart bar index minus the most recent bar index with either long or short signal > cooldown-bars parameter; after either signal, store the current bar index
Long: confirmation gate AND cooldown ready AND ATR percentage >= minimum ATR percentage AND (trend filter disabled OR uptrend) AND (volume filter disabled OR volume expansion) AND long confluence score >= setup-score threshold AND long confluence score > short confluence score + score-spread parameter
Short: confirmation gate AND cooldown ready AND ATR percentage >= minimum ATR percentage AND (trend filter disabled OR downtrend) AND (volume filter disabled OR volume expansion) AND short confluence score >= setup-score threshold AND short confluence score > long confluence score + score-spread parameter
Long: Bias is bullish
Short: Bias is bearish
Long: bullish memory display enabled AND confirmation gate AND (downside sweep OR long expansion break OR lower-band reclaim)
Short: bullish memory display enabled AND confirmation gate AND (upside sweep OR short expansion break OR upper-band rejection)
Long: rising CVD proxy
Short: falling CVD proxy
Long: lower-band reclaim
Short: upper-band rejection
Long: confirmation gate AND lower-band reclaim
Short: confirmation gate AND upper-band rejection
Long: pressure imbalance > bid-lean threshold
Short: pressure imbalance < negative offer-lean threshold
Long: confirmation gate AND pressure imbalance > pressure-expansion threshold
Short: confirmation gate AND pressure imbalance < negative pressure-expansion threshold
Long: auction-band display enabled AND pressure imbalance >= zero
Short: auction-band display enabled AND pressure imbalance < zero
Long: auction-band display enabled AND pressure imbalance > pressure-expansion threshold
Short: auction-band display enabled AND pressure imbalance < negative pressure-expansion threshold