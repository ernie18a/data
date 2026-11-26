Calculation: opening-range high/low = maximum high/minimum low of the configured opening-range bars from T1, excluding the initial segment unless enabled; chart bars take these values from T1
Calculation: body-confirmation percentage above/below a level = the percentage of the candle body beyond that level; zero for a zero-body candle
Calculation: synthetic CVD = session cumulative sum of volume × (2 × close − high − low) / (high − low); for a zero-range bar, use volume × sign(close − close[1])
Calculation: time-of-day relative volume = current volume in the intraday bucket divided by its average volume across prior sessions; when unavailable, use average chart-bar volume scaled to the bucket
Calculation: OR-level confluence weight = sum of the configured weights for prior and developing POC, VAH, VAL, HVN/LVN, prior-day high/low/close, prior-session VWAP, VIX expected-move bounds, ADR bounds, and active FVG edges within the smaller of an ATR-based tolerance and an OR-range-based tolerance; use prior POC as a profile fallback
Calculation: OR breakout score(up/down) = volume confirmation + body confirmation + ATR-distance confirmation + VWAP-side confirmation + OR-close RMI adjustment + daily RSI penalty + developing-POC adjustment; each term contributes its configured signed score
Calculation: VWAP reclaim/reject score = volume surge contribution + candle-close contribution + RMI direction-and-slope contribution + prime-session contribution; volume surge contributes its configured extra weight
Calculation: P2 touch score(level, bounce/rejection, test count) = clamp(base score by test count + session-character adjustment + breadth adjustment + breadth-velocity adjustment + breadth-divergence adjustment + higher-timeframe alignment adjustment + RMI, VWAP, relative-volume, wick, volume-node, OR-confluence, and developing-POC factors, between zero and the level's maximum score
Calculation: breadth score = sum of each valid sector index's separate signed weight, positive when its close is above its session VWAP and negative when below
Calculation: trend score = VWAP vote + swing-structure vote + chart EMA vote + T2 EMA vote + macro-SMT vote
Calculation: daily expected-move bounds = day open plus/minus day open × prior completed India VIX(T3) / square root of the configured annualization period
Calculation: ADR bounds = day open plus/minus half the prior completed average daily range over its configured T3 lookback
Calculation: weekly expected-move bounds = daily expected move multiplied by the square root of the configured number of sessions in a week
Long: opening-range formation is complete AND the opening candle range exceeds the configured ATR multiple AND its close is in the configured upper portion of that range
Short: opening-range formation is complete AND the opening candle range exceeds the configured ATR multiple AND its close is in the configured lower portion of that range
Long: opening candle body is below its configured range fraction AND its range is below the configured ATR multiple
Short: opening candle body is below its configured range fraction AND its range is below the configured ATR multiple
Long: before the opening range is set, the gap is down beyond its configured threshold AND RMI is oversold
Short: before the opening range is set, the gap is up beyond its configured threshold AND RMI is overbought
Long: a confirmed first upward opening-range break has body-confirmation percentage above OR high at least the configured threshold AND (OR breakout score meets the arrow threshold OR the macro-filtered breakout alert is allowed)
Short: a confirmed first downward opening-range break has body-confirmation percentage below OR low at least the configured threshold AND (OR breakout score meets the arrow threshold OR the macro-filtered breakout alert is allowed)
Long: a confirmed first upward opening-range break follows an up-gap beyond the configured threshold AND OR-close RMI is below its configured upper limit
Short: a confirmed first downward opening-range break follows a down-gap beyond the configured threshold AND OR-close RMI is above its configured lower limit
Long: a confirmed opening-range retest follows an upward break with stored breakout score at least its configured minimum, occurs after the configured minimum bars, touches within max(ATR × retest multiplier, OR range × retest fraction) of OR high, and closes above the configured close level; applies to the first and second retest
Short: a confirmed opening-range retest follows a downward break with stored breakout score at least its configured minimum, occurs after the configured minimum bars, touches within max(ATR × retest multiplier, OR range × retest fraction) of OR low, and closes below the configured close level; applies to the first and second retest
Long: a confirmed bullish trap candle follows a failed downward opening-range break within the configured bar window, has body size at least the configured fraction of OR range, and the trap cooldown and gap filter allow it
Short: a confirmed bearish trap candle follows a failed upward opening-range break within the configured bar window, has body size at least the configured fraction of OR range, and the trap cooldown and gap filter allow it
Long: during pre-OR formation, the first qualifying lower-wick sweep crosses below and closes above prior-day low, prior-day high, prior-session VWAP, or prior-day POC
Short: during pre-OR formation, the first qualifying upper-wick sweep crosses above and closes below prior-day high, prior-day low, prior-session VWAP, or prior-day POC
Long: a confirmed lower-wick sweep crosses below and closes above prior-day low, OR low, prior close, prior-session VWAP, prior POC, prior-week low, daily ADR lower bound, daily VIX floor, weekly VIX floor, or developing POC after its warmup
Short: a confirmed upper-wick sweep crosses above and closes below prior-day high, OR high, prior close, prior-session VWAP, prior POC, prior-week high, daily ADR upper bound, daily VIX ceiling, weekly VIX ceiling, or developing POC after its warmup
Long: on chart bars at a T4 close boundary, the T4 bar has a qualifying lower wick and crosses below then closes above prior-day low, OR low, prior close, prior-session VWAP, prior-week low, or daily ADR lower bound
Short: on chart bars at a T4 close boundary, the T4 bar has a qualifying upper wick and crosses above then closes below prior-day high, OR high, prior close, prior-session VWAP, prior-week high, or daily ADR upper bound
Long: on chart bars at a T5 close boundary, the T5 bar has a qualifying lower wick and crosses below then closes above prior-day low, OR low, prior close, prior-session VWAP, prior-week low, or daily ADR lower bound
Short: on chart bars at a T5 close boundary, the T5 bar has a qualifying upper wick and crosses above then closes below prior-day high, OR high, prior close, prior-session VWAP, prior-week high, or daily ADR upper bound
Long: after OR sets, a confirmed bar makes a lookback swing low, has a qualifying lower wick, and ToD relative volume meets its threshold
Short: after OR sets, a confirmed bar makes a lookback swing high, has a qualifying upper wick, and ToD relative volume meets its threshold
Long: a confirmed VWAP reclaim has close above VWAP, the preceding two chart closes below their respective VWAP values, reclaim score at least its threshold, and body-confirmation percentage above VWAP at least its threshold; in options mode use underlying price and VWAP
Short: a confirmed VWAP rejection has close below VWAP, the preceding two chart closes above their respective VWAP values, rejection score at least its threshold, and body-confirmation percentage below VWAP at least its threshold; in options mode use underlying price and VWAP
Long: after a VWAP reclaim, a confirmed retest not already used touches within the configured ATR proximity, closes above VWAP, and has at least half its body above VWAP
Short: after a VWAP rejection, a confirmed retest not already used touches within the configured ATR proximity, closes below VWAP, and has at least half its body below VWAP
Long: close is above prior-session VWAP, the preceding two chart closes were below their respective prior-session VWAP values, and body-confirmation percentage above it meets the configured threshold
Short: close is below prior-session VWAP, the preceding two chart closes were above their respective prior-session VWAP values, and body-confirmation percentage below it meets the configured threshold
Long: a confirmed developing-POC cross up has close above POC, at least half its body above POC, and the preceding two chart closes below their respective POC values
Short: a confirmed developing-POC cross down has close below POC, at least half its body below POC, and the preceding two chart closes above their respective POC values
Long: after a developing-POC cross down and a completed bear retest, a confirmed close moves above POC by more than the configured POC proximity and has at least half its body above POC
Short: after a developing-POC cross up and a completed bull retest, a confirmed close moves below POC by more than the configured POC proximity and has at least half its body below POC
Long: after a developing-POC cross up, a confirmed retest touches within configured POC proximity from above, closes above POC, and has at least half its body above POC; only the first retest per cross
Short: after a developing-POC cross down, a confirmed retest touches within configured POC proximity from below, closes below POC, and has at least half its body below POC; only the first retest per cross
Long: a confirmed higher low forms at a key level, with the current low above the prior bar's low, the prior bar's low below the bar before it, and the prior low within configured proximity of a key level
Short: a confirmed lower high forms at a key level, with the current high below the prior bar's high, the prior bar's high above the bar before it, and the prior high within configured proximity of a key level
Long: a W pattern forms from higher-low signals whose lows match within the configured ATR tolerance and bar-separation range, with at least one of value-area low, lower VWAP band, OR low, prior-month low, developing POC, prior-bar bottom sweep, or rising RMI at the second low
Short: an M pattern forms from lower-high signals whose highs match within the configured ATR tolerance and bar-separation range, with at least one of value-area high, upper VWAP band, OR high, prior-month high, developing POC, prior-bar top sweep, or falling RMI at the second high
Long: RMI bullish divergence is confirmed on an RMI slope flip up, with price making a lower low and RMI a higher low, and either the prior RMI pivot or current RMI trough is oversold
Short: RMI bearish divergence is confirmed on an RMI slope flip down, with price making a higher high and RMI a lower high, and either the prior RMI pivot or current RMI peak is overbought
Long: at a five-bar price pivot low, price makes a lower low than its prior pivot, synthetic CVD is above its prior pivot value, and close is in the upper half of the candle
Short: at a five-bar price pivot high, price makes a higher high than its prior pivot, synthetic CVD is below its prior pivot value, and close is in the lower half of the candle
Long: the traded instrument makes a lookback swing low while the correlated instrument does not; in equity mode, the traded instrument makes a lookback swing high while the correlated instrument does not
Short: the traded instrument makes a lookback swing high while the correlated instrument does not; in equity mode, the traded instrument makes a lookback swing low while the correlated instrument does not
Long: a bottom sweep and bullish SMT or bullish synthetic-CVD divergence occur within the configured sequence window, in either order
Short: a top sweep and bearish SMT or bearish synthetic-CVD divergence occur within the configured sequence window, in either order
Long: on a confirmed T4 close boundary, three successive T4 candles are nested by configured wick-or-body bounds, have successively smaller bodies, and all close above their opens
Short: on a confirmed T4 close boundary, three successive T4 candles are nested by configured wick-or-body bounds, have successively smaller bodies, and all close below their opens
Long: on a confirmed T5 close boundary, three successive T5 candles are nested by configured wick-or-body bounds, have successively smaller bodies, and all close above their opens
Short: on a confirmed T5 close boundary, three successive T5 candles are nested by configured wick-or-body bounds, have successively smaller bodies, and all close below their opens
Long: on a confirmed T4 close boundary, the last completed T4 candle has body/range below the configured doji threshold, lower wick/range above its configured threshold, and upper wick/range below its configured threshold
Short: on a confirmed T4 close boundary, the last completed T4 candle has body/range below the configured doji threshold, upper wick/range above its configured threshold, and lower wick/range below its configured threshold
Long: a confirmed chart-bar fair value gap forms when low exceeds high[2] and the middle candle closes above its open
Short: a confirmed chart-bar fair value gap forms when high is below low[2] and the middle candle closes below its open
Long: on chart bars at a T4 close boundary, the last completed T4 low exceeds the T4 high from the configured older offset by at least the configured ATR multiple; the active bullish gap remains until a confirmed chart close falls below its lower edge
Short: on chart bars at a T4 close boundary, the last completed T4 high is below the T4 low from the configured older offset by at least the configured ATR multiple; the active bearish gap remains until a confirmed chart close rises above its upper edge
Long: on a confirmed touch edge at OR high, OR low, or OR midpoint, price approaches from above, the OR is viable, and P2 touch score for a bounce meets the label threshold
Short: on a confirmed touch edge at OR high, OR low, or OR midpoint, price approaches from below, the OR is viable, and P2 touch score for a rejection meets the label threshold
Long: breadth score meets the configured bullish threshold with the configured minimum number of valid sector indices
Short: breadth score meets the configured bearish threshold with the configured minimum number of valid sector indices
Long: at least the configured number of sector indices flip from below to above their VWAP within the configured lookback and none flip oppositely
Short: at least the configured number of sector indices flip from above to below their VWAP within the configured lookback and none flip oppositely
Long: traded-instrument price change over the configured lookback is below the negative price threshold AND breadth-score change is above the positive breadth threshold
Short: traded-instrument price change over the configured lookback is above the positive price threshold AND breadth-score change is below the negative breadth threshold
Long: on a confirmed bar, daily RSI(T3, last completed bar) is oversold and breadth is bullish
Short: on a confirmed bar, daily RSI(T3, last completed bar) is overbought and breadth is bearish
Long: breadth is bullish, close is above EMA(close, lookback, T3, last completed bar), and close is above current-week VWAP accumulated from confirmed chart bars
Short: breadth is bearish, close is below EMA(close, lookback, T3, last completed bar), and close is below current-week VWAP accumulated from confirmed chart bars
Long: previous completed daily high(T3) exceeds the daily high before it while the correlated instrument's corresponding T3 highs do not make a higher high
Short: previous completed daily low(T3) is below the daily low before it while the correlated instrument's corresponding T3 lows do not make a lower low
Long: close is above EMA(close, lookback, T3, last completed bar)
Short: close is below EMA(close, lookback, T3, last completed bar)
Long: developing POC rises on at least one consecutive confirmed chart bar
Short: developing POC falls on at least one consecutive confirmed chart bar
Long: OR is set, trend score meets the configured positive threshold, at least the configured number of VWAP/swing/EMA votes are nonzero, VWAP is not trending down, activity filter is inactive, phase-four entry block is inactive, ADR used is below its threshold, bullish OR-break alignment holds, and bullish RMI and gap filters pass
Short: OR is set, trend score meets the configured negative threshold, at least the configured number of VWAP/swing/EMA votes are nonzero, VWAP is not trending up, activity filter is inactive, phase-four entry block is inactive, ADR used is below its threshold, bearish OR-break alignment holds, and bearish RMI and gap filters pass
Exit: long, the configured rolling count of bearish SMT signals against the position reaches its invalidation threshold
Exit: short, the configured rolling count of bullish SMT signals against the position reaches its invalidation threshold