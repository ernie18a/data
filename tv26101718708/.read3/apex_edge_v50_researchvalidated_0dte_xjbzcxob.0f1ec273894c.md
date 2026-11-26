Calculation: CLOCK = minutes since midnight of the chart bar time in Chicago time
Calculation: RELATIVE_VOLUME = volume / SMA(volume, volume lookback)
Calculation: T1_BULL = EMA(close, shorter lookback, T1, last completed bar) > EMA(close, longer lookback, T1, last completed bar)
Calculation: T1_BEAR = EMA(close, shorter lookback, T1, last completed bar) < EMA(close, longer lookback, T1, last completed bar)
Calculation: T2_OPEN = open of the current T2 bar, which is still forming
Calculation: GAP_PCT = (T2_OPEN - close of the last completed T2 bar) / close of the last completed T2 bar * 100
Calculation: OR_HIGH = highest high of chart bars in the current T2 bar with CLOCK within opening range window
Calculation: OR_LOW = lowest low of chart bars in the current T2 bar with CLOCK within opening range window
Calculation: OR_DIRECTION = sign(close of the last chart bar in the current T2 bar with CLOCK within opening range window - open of the first such chart bar)
Calculation: BARS_SINCE_OR = chart bars since the first chart bar after opening range window in the current T2 bar, or 0 before that bar
Calculation: NB_BAND = SMA(TR, NB lookback * chart bars per T2 bar) * NB multiplier
Calculation: OR_VOLATILE = (OR_HIGH - OR_LOW) > ATR(ATR lookback) * OR volatility multiplier
Calculation: REST_OF_DAY_PCT = (close - T2_OPEN) / T2_OPEN * 100
Calculation: RISK = ATR(ATR lookback) * stop multiplier
Calculation: ORB_LONG = CLOCK after opening range window AND CLOCK within AM window AND BARS_SINCE_OR <= ORB max bars AND close > OR_HIGH AND close > open AND RELATIVE_VOLUME >= relative volume threshold AND (T1_BULL OR close > VWAP(high, low, close)) AND NOT (ORB_LONG OR ORB_SHORT on any earlier chart bar in the current T2 bar)
Calculation: ORB_SHORT = CLOCK after opening range window AND CLOCK within AM window AND BARS_SINCE_OR <= ORB max bars AND close < OR_LOW AND close < open AND RELATIVE_VOLUME >= relative volume threshold AND (T1_BEAR OR close < VWAP(high, low, close)) AND NOT (ORB_LONG OR ORB_SHORT on any earlier chart bar in the current T2 bar)
Calculation: NB_UP = close crosses above T2_OPEN + NB_BAND AND CLOCK within AM window
Calculation: NB_DOWN = close crosses below T2_OPEN - NB_BAND AND CLOCK within AM window
Calculation: GAO_LONG = CLOCK within Gao window AND CLOCK before hard exit time AND OR_DIRECTION = 1 AND OR_VOLATILE AND close > VWAP(high, low, close) AND volume > SMA(volume, volume lookback)
Calculation: GAO_SHORT = CLOCK within Gao window AND CLOCK before hard exit time AND OR_DIRECTION = -1 AND OR_VOLATILE AND close < VWAP(high, low, close) AND volume > SMA(volume, volume lookback)
Calculation: BDLM_LONG = CLOCK within Gao window AND CLOCK before hard exit time AND REST_OF_DAY_PCT > rest-of-day threshold AND close > VWAP(high, low, close) AND volume > SMA(volume, volume lookback)
Calculation: BDLM_SHORT = CLOCK within Gao window AND CLOCK before hard exit time AND REST_OF_DAY_PCT < -rest-of-day threshold AND close < VWAP(high, low, close) AND volume > SMA(volume, volume lookback)
Calculation: BREAKOUT = ORB_LONG OR ORB_SHORT OR NB_UP OR NB_DOWN
Calculation: TREND = ADX(ADX lookback) > ADX threshold AND ((DI+(ADX lookback) > DI-(ADX lookback) AND T1_BULL) OR (DI-(ADX lookback) > DI+(ADX lookback) AND T1_BEAR))
Calculation: QUALITY_LONG = (RELATIVE_VOLUME >= strong relative volume threshold ? strong volume points : RELATIVE_VOLUME >= relative volume threshold ? volume points : 0) + (TREND ? trend points : 0) + (BREAKOUT ? primary points : secondary points) + (close > VWAP(high, low, close) ? VWAP points : 0) + (T1_BULL OR NOT T1_BEAR ? HTF points : 0)
Calculation: QUALITY_SHORT = (RELATIVE_VOLUME >= strong relative volume threshold ? strong volume points : RELATIVE_VOLUME >= relative volume threshold ? volume points : 0) + (TREND ? trend points : 0) + (BREAKOUT ? primary points : secondary points) + (close <= VWAP(high, low, close) ? VWAP points : 0) + (NOT T1_BULL OR T1_BEAR ? HTF points : 0)
Calculation: LONG_SIGNAL = CLOCK before hard exit time AND (ORB_LONG OR NB_UP OR GAO_LONG OR BDLM_LONG) AND NOT (GAP_PCT < -gap threshold AND BARS_SINCE_OR <= gap bars) AND QUALITY_LONG >= quality threshold AND NOT (LONG_SIGNAL OR SHORT_SIGNAL on any of the previous cooldown bars)
Calculation: SHORT_SIGNAL = CLOCK before hard exit time AND (ORB_SHORT OR NB_DOWN OR GAO_SHORT OR BDLM_SHORT) AND NOT (GAP_PCT > gap threshold AND BARS_SINCE_OR <= gap bars) AND QUALITY_SHORT >= quality threshold AND NOT (LONG_SIGNAL OR SHORT_SIGNAL on any of the previous cooldown bars)
Calculation: LONG_STOP = entry price if the highest high since entry, including the current bar, >= entry price + TP1 multiple * RISK; otherwise entry price - RISK
Calculation: SHORT_STOP = entry price if the lowest low since entry, including the current bar, <= entry price - TP1 multiple * RISK; otherwise entry price + RISK
Long: ORB_LONG
Long: NB_UP
Long: GAO_LONG
Long: BDLM_LONG
Long: previous chart bar was the first chart bar of a T2 bar AND GAP_PCT > gap threshold
Long: LONG_SIGNAL
Long: LONG_SIGNAL AND QUALITY_LONG >= A+ quality threshold
Short: ORB_SHORT
Short: NB_DOWN
Short: GAO_SHORT
Short: BDLM_SHORT
Short: previous chart bar was the first chart bar of a T2 bar AND GAP_PCT < -gap threshold
Short: SHORT_SIGNAL
Short: SHORT_SIGNAL AND QUALITY_SHORT >= A+ quality threshold
Exit: long, high >= entry price + TP2 multiple * RISK OR low <= LONG_STOP OR bars since entry >= max hold bars OR CLOCK >= hard exit time
Exit: short, low <= entry price - TP2 multiple * RISK OR high >= SHORT_STOP OR bars since entry >= max hold bars OR CLOCK >= hard exit time