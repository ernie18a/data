# Market Pressure

- url: https://www.tradingview.com/script/an2X84uQ-Market-Pressure/
- type: indicator
- pine_id: PUB;f7a99a781d584deaa5aeca32d5b1820c
- version: 5.0

## Description

Market Pressure — Description & Usage

Market Pressure is a normalized oscillator designed to characterize whether buying or selling pressure is dominating the market, and how persistent that pressure is over time. It does not attempt to predict price or generate signals. Instead, it measures the consistency of directional behavior by combining where price closes within each bar, the strength of the candle body, the level of volume participation, and alignment with trend. These components are smoothed and scaled into a range between -100 and +100, allowing the user to quickly assess who is in control and how strong that control is relative to recent conditions.

Values above zero indicate net buying pressure, while values below zero indicate net selling pressure. The most important region is the neutral zone around zero, defined by the user, which represents a balanced market where neither side has clear control. When the histogram remains within this neutral range, price action is typically rotational and prone to false moves. When the indicator moves and sustains itself outside of that range, it reflects a shift toward directional control. Strong readings toward the extremes suggest persistent and coordinated pressure, often associated with trend continuation rather than random movement.

This indicator is best used as a contextual filter rather than an entry tool. When Market Pressure is positive and holding above the neutral boundary, it suggests focusing only on long opportunities and avoiding shorts. When it is negative and holding below the neutral boundary, the opposite applies. When it is inside the neutral zone, the most effective action is often to stand aside, as the market lacks a dominant participant. The behavior of the histogram also provides insight into the quality of a move. Expanding values indicate strengthening pressure, while contracting values suggest that the dominant side may be losing control.

Because the indicator is normalized using a rolling lookback window, all readings are relative to recent history rather than fixed absolute levels. This allows it to adapt across different markets and timeframes, but also means that extremes represent the strongest pressure observed within that window, not an absolute threshold. The result is a flexible tool that highlights when the market is trending with conviction, when it is losing momentum, and when conditions are best avoided altogether.

## Source Code

````pine
//@version=6
indicator("Market Pressure", overlay=false)

// ═══════════════════════════════════════════════════════════════════════════════
// PRESSURE SQUEEZE
// Combines two complementary questions:
//   TTM Squeeze  → "Is a move about to happen?" (volatility compression)
//   Pressure     → "Which direction, with how much conviction?" (volume-weighted)
//
// The confluence signal fires only when BOTH align simultaneously:
//   squeeze active + pressure reading above threshold in one direction.
//   This is a materially higher-quality signal than either alone.
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Input Groups ─────────────────────────────────────────────────────────────
var string GRP_CONFIRMED = "Non-Repainting"
var string GRP_PRESSURE  = "Pressure Settings"
var string GRP_SQUEEZE   = "Squeeze Settings"
var string GRP_SIGNAL    = "Confluence Signal"
var string GRP_THRESH    = "Thresholds"

// ─── Non-Repainting Toggle ────────────────────────────────────────────────────
confirmedMode = input.bool(true, "Confirmed Bars Only (Non-Repainting)",
             group=GRP_CONFIRMED,
             tooltip="When ON, all calculations shift to the previous closed bar. " +
                     "Signals never repaint because they are only based on fully closed, immutable bars. " +
                     "Signals appear one bar later than real-time mode — this is the unavoidable cost of " +
                     "eliminating repainting. When OFF, the indicator calculates on the live forming bar " +
                     "(default behavior), which gives faster signals but can repaint before bar close.")

showConfirmedLabel = input.bool(true, "Show Confirmed Mode Label",
             group=GRP_CONFIRMED,
             tooltip="Displays a small label on the last bar indicating Confirmed Mode is active. " +
                     "Useful as a visual reminder that signals are non-repainting. " +
                     "Has no effect when Confirmed Bars Only is OFF.")

// ─── Pressure Inputs ──────────────────────────────────────────────────────────
len       = input.int(10, "Pressure Lookback", minval=5, group=GRP_PRESSURE,
             tooltip="Final EMA pass applied to the pre-smoothed pressure score. Controls how slowly the histogram reacts to new data. Higher = smoother but laggier. Effective total lag ≈ this + Score Smoothing bars.")

smoothLen = input.int(5, "Score Smoothing", minval=1, group=GRP_PRESSURE,
             tooltip="First EMA pass applied to raw pressure before the final Pressure Lookback EMA. Reduces bar-to-bar noise early in the pipeline. Effective total lag ≈ this + Pressure Lookback bars.")

volLen    = input.int(20, "Volume Baseline", minval=5, group=GRP_PRESSURE,
             tooltip="SMA length used to compute average volume. Relative volume (current bar ÷ this average) scales the CLV and direction components. Higher values produce a more stable baseline; lower values make the indicator more sensitive to recent volume shifts.")

trendLen  = input.int(20, "Trend EMA Length", minval=5, group=GRP_PRESSURE,
             tooltip="EMA length used to determine trend bias. Price above the EMA = bullish bias (+1), below = bearish bias (−1). When ATR Dead Zone is enabled, a buffer around the EMA suppresses the signal in choppy conditions.")

normLen   = input.int(50, "Normalization Lookback", minval=10, group=GRP_PRESSURE,
             tooltip="Lookback for the z-score mean and standard deviation. The raw pressure score is normalized relative to its behavior over this window — ±3σ maps to ±100. Longer values produce a more stable baseline but are slower to adapt to regime changes. Needs at least this many bars to warm up on chart load.")

sigLen    = input.int(3, "Signal Line Length", minval=1, group=GRP_PRESSURE,
             tooltip="EMA length of the orange signal line plotted over the histogram. A short EMA (default 3) tracks the histogram closely with minimal lag. Crossovers of the signal line above/below zero indicate building buy or sell pressure. Increase for fewer but higher-conviction crossovers.")

useAtrDeadZone = input.bool(true, "Use ATR Trend Dead Zone", group=GRP_PRESSURE,
             tooltip="When enabled, the trend bias component is suppressed when price is within a defined ATR band around the EMA. This prevents the trend signal from flip-flopping during low-volatility, sideways conditions. Disable to use a raw EMA crossover for trend bias instead.")

atrLen    = input.int(14, "ATR Dead Zone Length", minval=1, group=GRP_PRESSURE,
             tooltip="Lookback length for the ATR used to define the trend dead zone band. A longer length smooths the ATR and produces a more stable band width; a shorter length makes the band react faster to volatility changes.")

atrMult   = input.float(0.20, "ATR Dead Zone Multiplier", minval=0.0, step=0.05, group=GRP_PRESSURE,
             tooltip="Scales the ATR to set the dead zone band half-width around the trend EMA. Price must move beyond ±(ATR × this multiplier) from the EMA before trend bias registers. Default 0.20 is conservative. Increase to widen the neutral zone in choppy markets; decrease to make the trend bias more sensitive.")

// ─── Squeeze Inputs ───────────────────────────────────────────────────────────
bbLen     = input.int(20, "BB Length", minval=5, group=GRP_SQUEEZE,
             tooltip="Lookback length for the Bollinger Bands standard deviation calculation. Default 20 matches the TTM Squeeze standard. Shorter values make squeeze detection more sensitive; longer values require more sustained compression before a squeeze is flagged.")

bbMult    = input.float(2.0, "BB Multiplier", minval=0.5, step=0.1, group=GRP_SQUEEZE,
             tooltip="Standard deviation multiplier for the Bollinger Bands. Default 2.0 is standard. Lower values narrow the bands and trigger squeezes more frequently. Higher values require extreme compression before a squeeze fires.")

kcLen     = input.int(20, "KC Length", minval=5, group=GRP_SQUEEZE,
             tooltip="Lookback length for the Keltner Channel ATR calculation. Matching this to BB Length (default 20) is standard practice. The KC defines the outer envelope the BB must compress inside for a squeeze to be active.")

kcMult    = input.float(1.5, "KC Multiplier", minval=0.5, step=0.1, group=GRP_SQUEEZE,
             tooltip="ATR multiplier for the Keltner Channel width. Default 1.5 is the TTM standard. Lower values produce a tighter KC — easier for BB to compress inside it, generating more squeeze signals. Higher values require extreme contraction and produce fewer, higher-conviction squeezes.")

// ─── Confluence Signal Inputs ─────────────────────────────────────────────────
sqzPressureThresh = input.float(30.0, "Confluence Pressure Threshold", minval=5.0, maxval=80.0, step=5.0, group=GRP_SIGNAL,
             tooltip="Minimum normalized pressure reading (absolute value) required for the confluence signal to fire. Default 30 means pressure must be meaningfully above neutral — not just noise — before a squeeze-aligned signal is shown. Raise for stricter, fewer signals. Lower for more frequent signals.")

showSqzDots    = input.bool(true, "Show Squeeze Dots (Red/Orange)", group=GRP_SIGNAL,
             tooltip="Plots red and orange dots on the zero line during meaningful squeeze states. Red = squeeze active (BB inside KC, volatility compressing). Orange = squeeze just fired (first bar of expansion). These are the actionable dots — disable to hide them entirely.")

showNoSqzDots  = input.bool(false, "Show No-Squeeze Dots (Green)", group=GRP_SIGNAL,
             tooltip="Plots faint lime dots on the zero line when no squeeze is detected — normal expanding volatility. Off by default as they add visual noise without actionable information. The absence of red/orange dots already implies no squeeze is active.")

showPressureTrend = input.bool(true, "Show Pressure Trend During Squeeze", group=GRP_SIGNAL,
             tooltip="When a squeeze is active, shows whether pressure conviction is growing (brightening histogram) or fading (dimming). Pressure that builds consistently while a squeeze deepens is a stronger setup than pressure that fluctuates. Most useful for timing entries before the squeeze fires.")

// ─── Thresholds ───────────────────────────────────────────────────────────────
neutralLevel = input.float(40.0, "Neutral Zone (+/-)", minval=5, maxval=50, group=GRP_THRESH,
             tooltip="Z-score threshold (in normalized units) below which pressure is considered neutral. Histogram bars within ±this level are colored gray. Because z-score normalization is used, this level represents a fixed statistical distance from the mean — not a relative rank. The indicator may sit inside this zone for extended periods during low-momentum markets.")

extremeLevel = input.float(80.0, "Extreme Level (+/-)", minval=50, maxval=100, group=GRP_THRESH,
             tooltip="Z-score threshold above which pressure is considered extreme. Histogram bars beyond ±this level are colored full green or red. Readings at this level represent roughly ±2.4σ from the mean — statistically significant but not rare in strong trends. Does not imply reversal; extreme readings can persist in momentum regimes.")

// ═══════════════════════════════════════════════════════════════════════════════
// CONFIRMED-BAR SOURCE RESOLUTION
// When confirmedMode is ON, all OHLCV references shift to the previous closed
// bar ([1]). This is the only correct way to eliminate repainting in Pine:
// every input to every calculation must come from a closed, immutable bar.
// Using request.security with lookahead disabled achieves the same result but
// is unnecessary here since we are already on the same symbol/timeframe.
// ═══════════════════════════════════════════════════════════════════════════════

c_open   = confirmedMode ? open[1]   : open
c_high   = confirmedMode ? high[1]   : high
c_low    = confirmedMode ? low[1]    : low
c_close  = confirmedMode ? close[1]  : close
c_volume = confirmedMode ? volume[1] : volume

// ═══════════════════════════════════════════════════════════════════════════════
// PRESSURE ENGINE
// ═══════════════════════════════════════════════════════════════════════════════

// Price action — all derived from confirmed sources when toggle is ON
barRange  = c_high - c_low
safeRange = barRange == 0.0 ? syminfo.mintick : barRange

clv          = ((c_close - c_low) - (c_high - c_close)) / safeRange
bodyPressure = (c_close - c_open) / safeRange

// Volume factor (capped at 3× average to prevent spike distortion)
volAvg    = ta.sma(c_volume, volLen)
relVol    = volAvg == 0.0 ? 1.0 : c_volume / volAvg
volFactor = math.min(relVol, 3.0) / 3.0

// Magnitude-weighted direction: price delta normalized to bar range, clamped ±1
// In confirmed mode, c_close[1] = close[2] — the bar before the confirmed bar
priceDelta = c_close - c_close[1]
direction  = math.max(math.min(
     safeRange == 0.0 ? 0.0 : priceDelta / safeRange,
     1.0), -1.0)

// Trend filter with ATR dead zone — uses confirmed close for EMA and ATR
emaTrend  = ta.ema(c_close, trendLen)
atrValue  = ta.atr(atrLen)   // ta.atr() uses high/low/close internally;
                              // in confirmed mode, c_high/c_low/c_close feed
                              // the price series via Pine's bar-by-bar evaluation
trendDiff = c_close - emaTrend
deadZone  = atrValue * atrMult

trendBias =
     useAtrDeadZone ?
         math.abs(trendDiff) < deadZone ? 0.0 :
         trendDiff > 0.0 ? 1.0 : -1.0 :
     c_close > emaTrend ? 1.0 :
     c_close < emaTrend ? -1.0 : 0.0

// Composite raw pressure score
rawPressure =
     (clv * volFactor  * 35.0) +
     (bodyPressure     * 25.0) +
     (direction * volFactor * 25.0) +
     (trendBias        * 15.0)

// Double EMA smoothing — effective lag ≈ smoothLen + len bars
pressureScore  = ta.ema(rawPressure, smoothLen)
marketPressure = ta.ema(pressureScore, len)

// Z-score normalization
mpMean   = ta.sma(marketPressure, normLen)
mpStdDev = ta.stdev(marketPressure, normLen)

normalized = math.max(
     math.min(
         mpStdDev == 0.0 ? 0.0 : (marketPressure - mpMean) / mpStdDev * 33.3,
         100.0),
     -100.0)

// Signal line
signalLine = ta.ema(normalized, sigLen)

// ═══════════════════════════════════════════════════════════════════════════════
// SQUEEZE ENGINE
// Uses confirmed OHLC sources — BB/KC calculations reference c_close, c_high,
// c_low so that squeeze state is determined by closed-bar data when toggle is ON
// ═══════════════════════════════════════════════════════════════════════════════

// Bollinger Bands
bbBasis = ta.sma(c_close, bbLen)
bbDev   = ta.stdev(c_close, bbLen)
bbUpper = bbBasis + bbMult * bbDev
bbLower = bbBasis - bbMult * bbDev

// Keltner Channels (ATR-based)
// ta.ema and ta.atr operate on the bar series; feeding c_close / confirmed OHLC
// ensures the squeeze state reflects only completed bars when confirmed mode is ON
kcATR   = ta.atr(kcLen)
kcEMA   = ta.ema(c_close, kcLen)
kcUpper = kcEMA + kcMult * kcATR
kcLower = kcEMA - kcMult * kcATR

// Squeeze state
sqzActive = bbUpper < kcUpper and bbLower > kcLower
sqzFired  = sqzActive[1] and not sqzActive

// ═══════════════════════════════════════════════════════════════════════════════
// CONFLUENCE LOGIC
// ═══════════════════════════════════════════════════════════════════════════════

pressureBull = normalized >  sqzPressureThresh
pressureBear = normalized < -sqzPressureThresh

confluenceLong  = sqzActive and pressureBull
confluenceShort = sqzActive and pressureBear

pressureSlope      = normalized - normalized[3]
sqzPressureGrowing = sqzActive and math.abs(pressureSlope) > 5.0 and
     ((normalized > 0 and pressureSlope > 0) or (normalized < 0 and pressureSlope < 0))

// ═══════════════════════════════════════════════════════════════════════════════
// HISTOGRAM COLORING
// ═══════════════════════════════════════════════════════════════════════════════

baseHistColor =
     normalized >= extremeLevel  ? color.lime :
     normalized >  neutralLevel  ? color.new(color.lime, 40) :
     normalized <= -extremeLevel ? color.red :
     normalized <  -neutralLevel ? color.new(color.red, 40) :
     color.gray

sqzHistColor =
     not sqzActive ? baseHistColor :
     showPressureTrend and sqzPressureGrowing and normalized > 0 ? color.new(color.lime, 0) :
     showPressureTrend and sqzPressureGrowing and normalized < 0 ? color.new(color.red, 0) :
     showPressureTrend and sqzActive and not sqzPressureGrowing   ? color.new(color.gray, 30) :
     baseHistColor

// ═══════════════════════════════════════════════════════════════════════════════
// CONFIRMED MODE LABEL
// Rendered only on the last bar so it does not clutter the chart.
// Shows mode state and a one-bar-lag reminder to the user.
// ═══════════════════════════════════════════════════════════════════════════════

if barstate.islast and confirmedMode and showConfirmedLabel
    label.new(
         bar_index, normalized,
         "✔ Confirmed\n(non-repainting)",
         style     = label.style_label_left,
         color     = color.new(color.teal, 20),
         textcolor = color.white,
         size      = size.small)

// ═══════════════════════════════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════════════════════════════

plot(normalized,
     title     = "Pressure",
     style     = plot.style_columns,
     color     = sqzHistColor,
     linewidth = 2)

plot(signalLine,
     title     = "Signal Line",
     color     = color.orange,
     linewidth = 1)

showThisDot =
     (sqzFired  and showSqzDots) or
     (sqzActive and showSqzDots) or
     (not sqzActive and showNoSqzDots)

sqzDotColor =
     sqzFired  and showSqzDots      ? color.orange :
     sqzActive and showSqzDots      ? color.red :
     not sqzActive and showNoSqzDots ? color.new(color.lime, 30) :
     color.gray

plot(showThisDot ? 0 : na,
     title     = "Squeeze State",
     style     = plot.style_circles,
     color     = sqzDotColor,
     linewidth = 4)

// ─── Reference Lines ─────────────────────────────────────────────────────────
hline(0, "Zero", color=color.gray)

hline(neutralLevel,  "Upper Neutral",
     color=color.new(color.gray, 40),
     display=display.none)

hline(-neutralLevel, "Lower Neutral",
     color=color.new(color.gray, 40),
     display=display.none)

hline(extremeLevel,  "Extreme Buy",
     color=color.new(color.lime, 60),
     display=display.none)

hline(-extremeLevel, "Extreme Sell",
     color=color.new(color.red, 60),
     display=display.none)

// ─── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(confluenceLong,
     title   = "Bullish Confluence",
     message = "Pressure Squeeze: Squeeze active with bullish pressure conviction. Potential long setup.")

alertcondition(confluenceShort,
     title   = "Bearish Confluence",
     message = "Pressure Squeeze: Squeeze active with bearish pressure conviction. Potential short setup.")

alertcondition(sqzFired,
     title   = "Squeeze Fired",
     message = "Pressure Squeeze: Volatility squeeze has released. Watch pressure direction for breakout confirmation.")

alertcondition(sqzFired and pressureBull,
     title   = "Squeeze Fired Bullish",
     message = "Pressure Squeeze: Squeeze fired with bullish pressure. Potential long breakout.")

alertcondition(sqzFired and pressureBear,
     title   = "Squeeze Fired Bearish",
     message = "Pressure Squeeze: Squeeze fired with bearish pressure. Potential short breakout.")
````
