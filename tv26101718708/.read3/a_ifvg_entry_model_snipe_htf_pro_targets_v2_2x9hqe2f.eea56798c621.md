Calculation: ATR = ATR(ATR lookback parameter) on chart bars.
Calculation: Bullish sweep = low < the most recent confirmed pivot low (using the swing-length parameter on both sides) AND close > that pivot low.
Calculation: Bearish sweep = high > the most recent confirmed pivot high (using the swing-length parameter on both sides) AND close < that pivot high.
Calculation: Bullish displacement = close > open AND abs(close - open) > ATR * displacement-strength parameter.
Calculation: Bearish displacement = close < open AND abs(close - open) > ATR * displacement-strength parameter.
Calculation: Bullish IFVG = low[1] > high[2] OR close > high[1].
Calculation: Bearish IFVG = high[1] < low[2] OR close < low[1].
Calculation: Bullish setup = a bullish sweep, bullish displacement, and bullish IFVG each occurred within the setup-window parameter chart bars; their order does not matter.
Calculation: Bearish setup = a bearish sweep, bearish displacement, and bearish IFVG each occurred within the setup-window parameter chart bars; their order does not matter.
Calculation: Equal-high liquidity level = the high of the most recent chart bar where abs(high - high[1]) < ATR * equal-level tolerance parameter; retain the level until another such bar.
Calculation: Equal-low liquidity level = the low of the most recent chart bar where abs(low - low[1]) < ATR * equal-level tolerance parameter; retain the level until another such bar.
Calculation: Long stop = the lowest low from the most recent bullish sweep through the current chart bar, minus ATR * stop-buffer parameter.
Calculation: Short stop = the highest high from the most recent bearish sweep through the current chart bar, plus ATR * stop-buffer parameter.
Calculation: SNIPE long target = equal-high liquidity level if above close; otherwise the highest high over the SNIPE target lookback parameter if above close; otherwise close + ATR * SNIPE fallback ATR multiple; undefined unless above close.
Calculation: SNIPE short target = equal-low liquidity level if below close; otherwise the lowest low over the SNIPE target lookback parameter if below close; otherwise close - ATR * SNIPE fallback ATR multiple; undefined unless below close.
Calculation: Runner long target = the highest high over the runner target lookback parameter, which is longer than the SNIPE target lookback parameter, if above close; otherwise close + ATR * runner fallback ATR multiple; undefined unless above close.
Calculation: Runner short target = the lowest low over the runner target lookback parameter, which is longer than the SNIPE target lookback parameter, if below close; otherwise close - ATR * runner fallback ATR multiple; undefined unless below close.
Calculation: Long risk = close - long stop.
Calculation: Short risk = short stop - close.
Calculation: SNIPE long reward = SNIPE long target - close.
Calculation: SNIPE short reward = close - SNIPE short target.
Calculation: Runner long reward = runner long target - close.
Calculation: Runner short reward = close - runner short target.
Long: sweep markers enabled AND bullish sweep.
Short: sweep markers enabled AND bearish sweep.
Long: SNIPE signals enabled AND bullish setup AND close > open AND close > high[1] AND (entry display disabled OR no SNIPE long entry marker occurred within the cooldown parameter chart bars) AND (reward-to-risk filter disabled OR (long risk > 0 AND SNIPE long target exists AND SNIPE long reward > long risk * minimum reward-to-risk parameter)).
Short: SNIPE signals enabled AND bearish setup AND close < open AND close < low[1] AND (entry display disabled OR no SNIPE short entry marker occurred within the cooldown parameter chart bars) AND (reward-to-risk filter disabled OR (short risk > 0 AND SNIPE short target exists AND SNIPE short reward > short risk * minimum reward-to-risk parameter)).
Long: runner signals enabled AND bullish setup AND close > open AND close > high[1] AND close of the current T1 bar > EMA(close, HTF EMA lookback parameter, calculated on T1 bars and projected onto chart bars; uses the forming T1 bar in real time and the last completed T1 value historically) AND (entry display disabled OR no runner long entry marker occurred within the cooldown parameter chart bars) AND (reward-to-risk filter disabled OR (long risk > 0 AND runner long target exists AND runner long reward > long risk * minimum reward-to-risk parameter)).
Short: runner signals enabled AND bearish setup AND close < open AND close < low[1] AND close of the current T1 bar < EMA(close, HTF EMA lookback parameter, calculated on T1 bars and projected onto chart bars; uses the forming T1 bar in real time and the last completed T1 value historically) AND (entry display disabled OR no runner short entry marker occurred within the cooldown parameter chart bars) AND (reward-to-risk filter disabled OR (short risk > 0 AND runner short target exists AND runner short reward > short risk * minimum reward-to-risk parameter)).