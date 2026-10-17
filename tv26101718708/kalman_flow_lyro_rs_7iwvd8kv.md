# Kalman Flow | Lyro RS

- url: https://www.tradingview.com/script/7iwvD8Kv-Kalman-Flow-Lyro-RS/
- type: indicator
- pine_id: PUB;d7a02e0a692449e1aa028a719fd0eb74
- version: 1.0

## Description

The [b]Kalman Flow[/b] is an adaptive trend-following tool designed to identify and track market direction by combining a two-state Kalman filter with noise-scaled deviation bands. Unlike traditional moving-average systems, this indicator estimates both the underlying price level and its velocity (drift per bar) simultaneously, requiring agreement between price displacement and directional drift before confirming a trend change.

[b]How It Works[/b]

1. [b]Kalman Baseline [Level + Velocity][/b]
This is the core engine of the indicator — a constant-velocity Kalman filter that recursively predicts the next price level from its current level and velocity states, then corrects the prediction using actual price. Because the filter gain depends only on the process-to-measurement noise ratio, behavior is consistent across all assets and price scales.
[list]
[*]Higher Sensitivity → the baseline tracks price closely and reacts faster.
[*]Lower Sensitivity → a smoother baseline with fewer, more selective flips.
[/list]

2. [b]Adaptive Noise Bands[/b]
Instead of ATR or standard deviation, the bands are scaled by the filter's own tracking error — the average absolute distance between price and the Kalman estimate.
[list]
[*]Upper Band = Kalman Baseline + (Tracking Error × + Multiplier)
[*]Lower Band = Kalman Baseline − (Tracking Error × − Multiplier)
[/list]
The two multipliers are independent, allowing asymmetric tuning of bullish and bearish flip thresholds. The bands automatically widen in choppy conditions and tighten in clean trends, so flips require a move that is large relative to recent noise — not a fixed size.

3. [b]Velocity-Confirmed Trend Engine[/b]
A trend flip requires both conditions at once:
[list]
[*]A close beyond the opposite noise band (displacement).
[*]Kalman velocity agreeing with the new direction (drift).
[/list]
Anything less holds the current state, creating built-in hysteresis that filters out displacement without follow-through.

[b]Practical Application[/b]

[b]Signal Interpretation[/b]
[list]
[*]A Long signal is generated when price closes above the upper band while Kalman velocity is positive.
[*]A Short signal is generated when price closes below the lower band while Kalman velocity is negative.
[*]Candle coloring and the baseline color always reflect the current trend state.
[/list]

[b]Trend Confirmation[/b]
The velocity requirement serves as a confirmation layer — a single spike through a band without genuine drift behind it will not flip the trend, reducing the likelihood of false signals during choppy or low-volatility conditions. Built-in alerts cover bullish flips, bearish flips, and any flip.

[b]⚠️ Disclaimer[/b]
This indicator is a technical analysis tool and does not guarantee results. It should be used in conjunction with additional analysis methods and proper risk management strategies. The creators of this indicator are not responsible for any financial decisions made based on its signals.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LyroRS

//@version=6
indicator("Kalman Flow | Lyro RS", overlay=true)

// ╔══════════════════════════════════════════════════╗
// ║                INPUT GROUPS                      ║
// ╚══════════════════════════════════════════════════╝
settings_g = '𝗦𝗘𝗧𝗧𝗜𝗡𝗚𝗦'
features_g = '𝗙𝗘𝗔𝗧𝗨𝗥𝗘𝗦'
color_g    = '𝗖𝗢𝗟𝗢𝗥'

// ╔══════════════════════════════════════════════════╗
// ║               CORE SETTINGS                      ║
// ╚══════════════════════════════════════════════════╝
src         = input.source(close, "𝗦𝗼𝘂𝗿𝗰𝗲", group=settings_g, tooltip="The price series fed into the Kalman filter. Close is the default and recommended source.")

sensitivity = input.float(4,
 "𝗦𝗲𝗻𝘀𝗶𝘁𝗶𝘃𝗶𝘁𝘆",
 step=0.5, minval=1, maxval=10,
 group=settings_g,
 tooltip="Controls how quickly the Kalman filter reacts to new price information. Higher values track price closely and flip faster, lower values produce a smoother line with fewer, more selective signals.")

mad_multp   = input.float(1.65, "+ 𝗠𝘂𝗹𝘁𝗶𝗽𝗹𝗶𝗲𝗿", step=0.1, minval=0.5, maxval=5, group=settings_g, tooltip="A multiplier applied to the tracking-error distance from the Kalman estimate to create the upper band. Price must close above it — with positive velocity — to flip bullish.")
mad_multn   = input.float(1, "- 𝗠𝘂𝗹𝘁𝗶𝗽𝗹𝗶𝗲𝗿", step=0.1, minval=0.5, maxval=5, group=settings_g, tooltip="A multiplier applied to the tracking-error distance from the Kalman estimate to create the lower band. Price must close below it — with negative velocity — to flip bearish.")

volLen      = input.int(50, "𝗡𝗼𝗶𝘀𝗲 𝗟𝗲𝗻𝗴𝘁𝗵", minval=5, maxval=500, group=settings_g, tooltip="Lookback used to measure how noisy price has been around the Kalman estimate. This tracking error is what scales the bands, so they automatically widen in choppy markets and tighten in clean trends.")

// ╔══════════════════════════════════════════════════╗
// ║                 FEATURES                         ║
// ╚══════════════════════════════════════════════════╝
showSignals = input.bool(true, "𝗦𝗵𝗼𝘄 𝗦𝗶𝗴𝗻𝗮𝗹𝘀", group=features_g, tooltip="Displays Long and Short labels on the chart whenever the trend engine flips direction.")
showBands   = input.bool(true, "𝗦𝗵𝗼𝘄 𝗕𝗮𝗻𝗱𝘀", group=features_g, tooltip="Displays the adaptive noise bands around the Kalman baseline. These are the levels price must break — with velocity agreement — to flip the trend.")
candleColor = input.bool(true, "𝗖𝗮𝗻𝗱𝗹𝗲 𝗖𝗼𝗹𝗼𝗿𝗶𝗻𝗴", group=features_g, tooltip="Colors the chart candles according to the current trend state.")

// ╔══════════════════════════════════════════════════╗
// ║                   COLOR                          ║
// ╚══════════════════════════════════════════════════╝
ColMode = input.string("Mystic", "Custom Color Palette", inline="drop", options=["Classic", "Mystic", "Accented", "Royal"], display=display.none, group=color_g, tooltip="Choose a predefined color scheme for indicator visualization.")

cpyn   = input.bool(true, "Use Custom Palette", tooltip="Enable manual selection of custom colors for trend signals.", group=color_g, display=display.none)
cp_UpC = input.color(#00ff00, "Custom Up", inline="Custom Palette", tooltip="Set a custom color for bullish signals.", group=color_g, display=display.none)
cp_DnC = input.color(#ff0000, "Custom Down", inline="Custom Palette", tooltip="Set a custom color for bearish signals.", group=color_g, display=display.none)

color UpC = na
color DnC = na

switch ColMode
    "Classic" =>
        UpC := #00E676
        DnC := #880E4F
    "Mystic" =>
        UpC := #30FDCF
        DnC := #E117B7
    "Accented" =>
        UpC := #9618F7
        DnC := #FF0078
    "Royal" =>
        UpC := #FFC107
        DnC := #673AB7

if cpyn
    UpC := cp_UpC
    DnC := cp_DnC

// ╔══════════════════════════════════════════════════╗
// ║          KALMAN FILTER [LEVEL + VELOCITY]        ║
// ╚══════════════════════════════════════════════════╝
// Two-state constant-velocity Kalman filter.
// State 1 = price level, State 2 = velocity (drift per bar).
// Only the process-to-measurement noise ratio matters for the
// filter gain, so behaviour is scale-independent across assets.

kf_q = math.pow(10, sensitivity / 2 - 6)   // process noise
kf_r = 1.0                                 // measurement noise

var float kf_level = na
var float kf_veloc = 0.0
var float p11 = 1.0
var float p12 = 0.0
var float p21 = 0.0
var float p22 = 1.0

if na(kf_level)
    kf_level := src
else
    // ── Predict ──
    predLevel = kf_level + kf_veloc
    predVeloc = kf_veloc
    p11p = p11 + p12 + p21 + p22 + kf_q
    p12p = p12 + p22
    p21p = p21 + p22
    p22p = p22 + kf_q
    // ── Update ──
    s  = p11p + kf_r
    k1 = p11p / s
    k2 = p21p / s
    innov = src - predLevel
    kf_level := predLevel + k1 * innov
    kf_veloc := predVeloc + k2 * innov
    p11 := (1 - k1) * p11p
    p12 := (1 - k1) * p12p
    p21 := p21p - k2 * p11p
    p22 := p22p - k2 * p12p

// ╔══════════════════════════════════════════════════╗
// ║                 TREND ENGINE                     ║
// ╚══════════════════════════════════════════════════╝
// Tracking error = average absolute distance between price and
// the Kalman estimate. Bands scale with it, so flips require a
// move that is large relative to recent noise — not a fixed size.
trackErr = ta.sma(math.abs(src - kf_level), volLen)
upperBand = kf_level + mad_multp * trackErr
lowerBand = kf_level - mad_multn * trackErr

// A flip requires BOTH:
//  1. A close beyond the opposite noise band (displacement)
//  2. Kalman velocity agreeing with the new direction (drift)
// Anything less holds the current state — built-in hysteresis.
var int trend = 0
if close > upperBand and kf_veloc > 0
    trend := 1
else if close < lowerBand and kf_veloc < 0
    trend := -1

flipUp   = trend == 1  and trend[1] != 1
flipDown = trend == -1 and trend[1] != -1

// ╔══════════════════════════════════════════════════╗
// ║                   VISUALS                        ║
// ╚══════════════════════════════════════════════════╝
trendCol = trend == 1 ? UpC : trend == -1 ? DnC : color.gray

// Baseline with glow
plot(kf_level, "Kalman Baseline [Glow]", color=color.new(trendCol, 80), linewidth=6, editable=false)
plot(kf_level, "Kalman Baseline", color=trendCol, linewidth=2)

// Adaptive noise bands
pUp = plot(showBands ? upperBand : na, "Upper Band", color=color.new(trendCol, 70), linewidth=1)
pDn = plot(showBands ? lowerBand : na, "Lower Band", color=color.new(trendCol, 70), linewidth=1)
fill(pUp, pDn, color=showBands ? color.new(trendCol, 92) : na, title="Band Fill")

// Signals
plotshape(showSignals and flipUp, "Buy Signal", style=shape.labelup, location=location.belowbar, color=UpC, text="𝓛𝓸𝓷𝓰", textcolor=#000000, size=size.small)
plotshape(showSignals and flipDown, "Sell Signal", style=shape.labeldown, location=location.abovebar, color=DnC, text="𝓢𝓱𝓸𝓻𝓽", textcolor=#000000, size=size.small)

// Candle coloring
plotcandle(open, high, low, close, "Candle Plot", trendCol, trendCol, true, bordercolor = trendCol, display=display.pane, force_overlay=true)

// ╔══════════════════════════════════════════════════╗
// ║                    ALERTS                        ║
// ╚══════════════════════════════════════════════════╝
alertcondition(flipUp, "Bullish Trend Flip", "Kalman Flow | Lyro RS: Bullish trend flip on {{ticker}} ({{interval}})")
alertcondition(flipDown, "Bearish Trend Flip", "Kalman Flow | Lyro RS: Bearish trend flip on {{ticker}} ({{interval}})")
alertcondition(flipUp or flipDown, "Any Trend Flip", "Kalman Flow | Lyro RS: Trend flip on {{ticker}} ({{interval}})")
````
