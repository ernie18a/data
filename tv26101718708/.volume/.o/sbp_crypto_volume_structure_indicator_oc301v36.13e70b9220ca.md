Calculation: Volume center = volume-weighted average of typical price (high + low + close)/3 over the rolling structure window; fall back to its exponential moving average over that window
Calculation: Volatility deviation = greater of the standard deviation of typical price over the rolling structure window and 0.55 × ATR
Calculation: Direction = 0.45 × clipped signed-volume participation + 0.30 × clipped volume-center slope + 0.25 × clipped close displacement from the volume center
Calculation: Signed-volume participation = clipped EMA of (effective volume × (2 × close location in bar range − 1)) divided by EMA of effective volume, using the same lookback
Calculation: Effective volume = volume when positive, otherwise 1
Calculation: Value channel = volume center ± greater of 0.55 × volatility deviation and 0.48 × ATR × profile scale
Calculation: Session control = direction-adjusted volume center with half-width equal to the greater of 0.20 × volatility deviation and 0.18 × ATR × profile scale; session control upper/lower are its center ± half-width
Calculation: Session control levels = snapshot of session control levels on the first confirmed bar of each new day; hold those levels until the next daily reset
Calculation: Outer channel = volume center ± 1.80 × volatility deviation × profile scale
Calculation: Profile scale = selected asset profile scale, or the scale inferred from the ticker when automatic
Calculation: Body ratio = absolute close−open divided by high−low
Calculation: Close location = (close−low) divided by high−low, clipped to [0,1]
Calculation: Bull/bear votes = count of these respective conditions: close above/below open; close above/below prior close; momentum rising/falling; fast ribbon above/below slow ribbon; bull/bear ribbon; trend state bullish/bearish; lower/upper wick longer than candle body; direction positive/negative
Calculation: Momentum = short-lookback EMA of close minus longer-lookback EMA of close
Calculation: Fast and slow ribbons = twice-smoothed EMA of typical price, with the fast ribbon using the shorter lookback
Calculation: Ribbon state = bull when direction exceeds its positive threshold, ribbon slope is not materially negative, close is at/above volume center, and those conditions held on the prior bar; bear is the inverse
Calculation: Trend line = twice-smoothed EMA of a weighted average of recent closes, with greater weight on more recent closes
Calculation: Trend state = bullish or bearish after two consecutive confirmed bars with close and trend-line slope beyond the corresponding ATR-adjusted threshold; otherwise retain the prior state
Calculation: Bull acceptance = confirmed close above value-channel upper and session-control upper, direction and body ratio above their thresholds, and close location above its threshold
Calculation: Bear acceptance = confirmed close below value-channel lower and session-control lower, direction below its negative threshold, body ratio above its threshold, and close location below its threshold
Calculation: Bull reclaim = confirmed low reaches/breaches session-control lower, close exceeds session-control upper, direction and body ratio exceed thresholds, and lower wick exceeds upper wick
Calculation: Bear reclaim = confirmed high reaches/breaches session-control upper, close falls below session-control lower, direction is below its negative threshold, body ratio exceeds its threshold, and upper wick exceeds lower wick
Calculation: Bull liquidity setup = low sweeps below the prior short-lookback lows and closes back above them; close also breaks above the prior shorter-lookback highs on an up candle; relative volume passes its profile-adjusted threshold; direction is positive and close exceeds session-control center
Calculation: Bear liquidity setup = high sweeps above the prior short-lookback highs and closes back below them; close also breaks below the prior shorter-lookback lows on a down candle; relative volume passes its profile-adjusted threshold; direction is negative and close is below session-control center
Calculation: Structure buy = any of bull acceptance, bull reclaim, or bull liquidity setup; no rejection at outer upper channel; bull votes meet threshold
Calculation: Structure sale = any of bear acceptance, bear reclaim, or bear liquidity setup; no rejection at outer lower channel; bear votes meet threshold
Calculation: Rejected outer-channel breakout = high reaches/exceeds outer upper and close is below it, or low reaches/breaches outer lower and close is above it
Calculation: Compressed = value-channel half-width is below its ATR-relative threshold
Calculation: Turn buy = turn-buy setup holds for two consecutive confirmed bars, where the 10-bar range meets its ATR-relative threshold, the most recent low is 1–7 bars ago, close has risen from that low by the required ATR-relative amount, bull votes meet threshold, a bull break or sweep occurs, and market is not compressed
Calculation: Turn sale = turn-sale setup holds for two consecutive confirmed bars, where the 10-bar range meets its ATR-relative threshold, the most recent high is 1–7 bars ago, close has fallen from that high by the required ATR-relative amount, bear votes meet threshold, a bear break or sweep occurs, and market is not compressed
Calculation: Ribbon buy = a newly bullish ribbon with bullish trend state, sufficiently positive direction, and close above volume center; ribbon sale is the inverse
Calculation: Trend buy = trend state changes from bearish to bullish with bull ribbon and sufficiently positive direction; trend sale is the inverse
Calculation: Integrated buy = confirmed up candle closing above trend line and volume center, fast ribbon above slow ribbon, momentum rising, bull votes meeting threshold, and not compressed; integrated sale is the inverse
Calculation: Buy request = confirmed up candle and any of structure buy, turn buy, ribbon buy, trend buy, or integrated buy
Calculation: Sale request = confirmed down candle and any of structure sale, turn sale, ribbon sale, trend sale, or integrated sale
Calculation: Conflicting requests = if both requests occur, retain only the side with more votes; if votes tie, retain neither
Long: Close ≥ volume center (bull value-channel color)
Short: Close < volume center (bear value-channel color)
Long: Confirmed bull ribbon state begins
Short: Confirmed bear ribbon state begins
Long: Buy request is the sole remaining request and the prior signal direction is neutral or short
Short: Sale request is the sole remaining request and the prior signal direction is neutral or long