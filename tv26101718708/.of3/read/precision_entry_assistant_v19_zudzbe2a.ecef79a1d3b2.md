Calculation: Directional close percentage = if high > low then 100 × (close - low) / (high - low) else 50
Calculation: ORB levels = highest high and lowest low of chart bars in the ORB window, reset at the window start and locked after it ends
Calculation: VWAP-side crossing count = count of strict side changes between close and VWAP across pairs of bars n and n+1 bars ago, for n from 1 through the chop lookback
Calculation: EMA-side crossing count = count of strict side changes between the short-lookback and long-lookback EMA(close) across pairs of bars n and n+1 bars ago, for n from 1 through the chop lookback
Calculation: Market-state filter passes = filter disabled OR (abs(VWAP(close) - VWAP(close)[slope lookback]) > ATR(ATR lookback) × VWAP-slope multiplier AND Highest(high, expansion lookback) - Lowest(low, expansion lookback) > ATR(ATR lookback) × expansion multiplier AND abs(close - VWAP(close)) >= ATR(ATR lookback) × VWAP-distance multiplier AND VWAP-side crossing count <= VWAP-cross limit AND EMA-side crossing count <= EMA-cross limit)
Calculation: Cooldown passes = no prior signal OR current chart bar index - prior signal chart bar index > cooldown bars
Calculation: Bullish displacement = close > open AND abs(close - open) > ATR(ATR lookback) × displacement-body multiplier AND directional close percentage >= directional-close threshold
Calculation: Bearish displacement = close < open AND abs(close - open) > ATR(ATR lookback) × displacement-body multiplier AND directional close percentage <= 100 - directional-close threshold
Calculation: VWAP bounce = low <= VWAP(close) AND close > VWAP(close) AND close > open
Calculation: VWAP rejection = high >= VWAP(close) AND close < VWAP(close) AND close < open
Calculation: Low sweep = low < Lowest(low of preceding sweep lookback bars) AND close > low
Calculation: High sweep = high > Highest(high of preceding sweep lookback bars) AND close < high
Long: EMA(close, short EMA lookback) > EMA(close, long EMA lookback) AND close > VWAP(close)
Short: EMA(close, short EMA lookback) < EMA(close, long EMA lookback) AND close < VWAP(close)
Long: NY AM session AND fewer than the NY signal limit signals have occurred in the current NY session AND cooldown passes AND market-state filter passes AND EMA(close, short EMA lookback) > EMA(close, long EMA lookback) AND close > VWAP(close) AND bullish displacement AND (ORB levels locked AND close > ORB high OR VWAP bounce)
Short: NY AM session AND fewer than the NY signal limit signals have occurred in the current NY session AND cooldown passes AND market-state filter passes AND EMA(close, short EMA lookback) < EMA(close, long EMA lookback) AND close < VWAP(close) AND bearish displacement AND (ORB levels locked AND close < ORB low OR VWAP rejection)
Long: (Asia session OR London session) AND fewer than the off-session signal limit signals have occurred in the current Asia/London session AND cooldown passes AND market-state filter passes AND bullish displacement AND close > VWAP(close) AND (low sweep OR VWAP bounce)
Short: (Asia session OR London session) AND fewer than the off-session signal limit signals have occurred in the current Asia/London session AND cooldown passes AND market-state filter passes AND bearish displacement AND close < VWAP(close) AND (high sweep OR VWAP rejection)