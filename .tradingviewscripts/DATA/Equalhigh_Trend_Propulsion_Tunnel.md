<!-- tradingview-pine-id: PUB;eb6346af23f14ff5b942c1ea40112b2a -->
<!-- tradingviewscripts-format: 1 -->
# Equalhigh Trend Propulsion Tunnel

Source: https://www.tradingview.com/script/vRLnU0Np-Equalhigh-Trend-Propulsion-Tunnel/

## Description

EQUALHIGH — TREND PROPULSION TUNNEL v2

OVERVIEW

Trend Propulsion Tunnel is a multi-horizon trend-following indicator designed to distinguish between:

• A trend beginning to accelerate
• A healthy established trend
• A powerful but advanced trend
• A rising price with deteriorating propulsion
• A confirmed bearish reversal

Instead of relying on moving-average crossovers, the indicator models a trend as a moving system with five components:

• Direction
• Propulsion
• Coherence
• Friction
• Trend Reserve

The results are displayed directly on the price chart through an adaptive colored tunnel, a luminous trend core, a regime ribbon and event markers.

HOW IT WORKS

The indicator applies linear regression to the logarithm of price over three horizons:

• Fast horizon: 13 bars
• Medium horizon: 26 bars
• Slow horizon: 52 bars

Each regression slope is normalized by realized return volatility. The three normalized slopes are then combined into a single Direction score.

The default weighting is:

• Fast horizon: 45%
• Medium horizon: 35%
• Slow horizon: 20%

This gives greater importance to recent information while preserving the influence of the longer-term trend.

THE PROPULSION TUNNEL

The tunnel is centered on the slow logarithmic regression trend.

Its width adapts to:

• Average True Range
• Trend friction
• Multi-horizon coherence

The tunnel expands when the price path becomes noisy or unstable. It contracts when the trend becomes cleaner and more coherent.

The tunnel is not intended to operate as conventional support or resistance. It visualizes the estimated trend path and its current structural uncertainty.

TREND CORE

The luminous central line represents the slow regression trend.

Its color changes according to the active propulsion regime.

Price above the core is not automatically bullish, and price below it is not automatically bearish. Direction, propulsion and coherence must be interpreted together.

REGIME RIBBON

The colored ribbon below the candles provides a compact historical view of the detected regimes.

• Violet: Ignition
• Blue: Launch
• Cyan: Cruise
• Gold: Overdrive
• Orange: Engine Failure
• Red: Reversal

The ribbon can be disabled independently from the tunnel.

COCKPIT METRICS

DIRECTION

Direction measures the combined orientation of the fast, medium and slow regression slopes.

• Positive values indicate an upward trend structure.
• Negative values indicate a downward trend structure.
• Larger absolute values indicate stronger directional alignment.

Direction is not the same as propulsion. A trend can remain positive while losing acceleration.

PROPULSION

Propulsion measures the smoothed change in the Direction score.

• Positive propulsion: the trend is strengthening.
• Near zero: the trend is moving at a relatively stable speed.
• Negative propulsion: the trend is losing strength.

A declining Propulsion score can therefore warn of deterioration before Direction becomes negative.

COHERENCE

Coherence measures how broadly the trend is supported.

It combines:

• Agreement between the three regression horizons
• Percentage of recent returns moving with the dominant direction

High coherence means the trend is broadly distributed across timeframes and bars.

Low coherence suggests that the movement may depend on only a small number of exceptional candles.

FRICTION

Friction measures the amount of noise opposing the useful movement.

It is derived from path efficiency:

Efficiency = Net displacement ÷ Total distance travelled

Friction = 1 − Efficiency

• Low friction: clean and directional movement
• High friction: unstable, erratic or range-bound movement

Higher friction causes the tunnel to widen.

TREND RESERVE

Trend Reserve is a composite score between 0% and 100%.

It combines:

• Coherence
• Path efficiency
• Propulsion support
• Price extension from the slow regression trend

A high Reserve score indicates that the current trend remains structurally supported.

A low Reserve score indicates that the trend may be vulnerable, even if price has not yet reversed.

Trend Reserve is not a forecast of how many bars the trend will continue.

REGIME DEFINITIONS

IGNITION — VIOLET

The first signs of positive direction and acceleration are appearing.

The structure is not yet sufficiently strong or coherent for confirmation.

Typical use:

• Add the asset to a watchlist
• Check fundamentals and valuation
• Wait for Launch or Cruise confirmation

LAUNCH — BLUE

A new accelerating bullish trend has been confirmed.

Default requirements include:

• Direction at or above the Launch threshold
• Propulsion at or above the minimum threshold
• Coherence at or above 70%
• Efficiency at or above 25%
• Price extension below the maximum permitted level
• Completed chart bar

A blue “L” marker identifies the first confirmed Launch bar.

Launch is the earliest fully confirmed bullish regime, but it is not an automatic buy signal.

CRUISE — CYAN

The trend is positive, coherent and structurally healthy, while acceleration has normalized.

Cruise often represents a more stable phase than Launch.

A cyan “C” marker appears when the indicator newly enters Cruise.

Potential interpretation:

• Existing position: trend-following hold
• New position: possible pullback or reinforcement phase
• Risk management: monitor Reserve and Propulsion

OVERDRIVE — GOLD

The trend has reached a very high Direction score with strong coherence and sufficient Reserve.

Overdrive represents exceptional trend strength, but the move may already be advanced.

It should not automatically be interpreted as the best entry point.

ENGINE FAILURE — ORANGE

Price direction remains positive, but the underlying trend engine is deteriorating.

Engine Failure can be triggered by:

• Strongly negative propulsion
• Trend Reserve below 30%
• Coherence below 50%

An orange “!” marker identifies the beginning of this condition.

This is the indicator’s principal early-warning signal. It may appear while price is still rising.

BEAR FADE — GREEN/TURQUOISE

A previously negative trend begins losing bearish propulsion.

This does not yet confirm a bullish reversal. It indicates that bearish pressure is weakening.

BEAR DRIVE — RED/PINK

The downward trend is accelerating with sufficient coherence and efficiency.

This is the bearish counterpart of Launch.

REVERSAL — RED

A confirmed negative multi-horizon trend structure is present.

A red “R” marker appears when Reversal becomes newly active on a completed bar.

Reversal should be treated as a risk-management signal rather than an automatic short entry.

EVENT MARKERS

L — LAUNCH

New accelerating bullish trend confirmed.

C — CRUISE

New stable and coherent bullish regime.

! — ENGINE FAILURE

Direction remains positive, but propulsion, coherence or Reserve has deteriorated.

R — REVERSAL

Bearish multi-horizon reversal confirmed.

RECOMMENDED SETTINGS

WEEKLY INVESTING PROFILE

• Fast horizon: 13
• Medium horizon: 26
• Slow horizon: 52
• Propulsion smoothing: 3
• Minimum Launch Direction: 28
• Minimum Launch Propulsion: 4
• Minimum Coherence: 70%
• Minimum Efficiency: 25%
• Maximum Extension: 2.50 Z
• Engine Failure Propulsion: −3
• Tunnel width: 1.80 ATR

This is the recommended starting configuration for medium- and long-term stock analysis.

DAILY SWING PROFILE

• Fast horizon: 10
• Medium horizon: 21
• Slow horizon: 50
• Propulsion smoothing: 3–5
• Minimum Coherence: 70%
• Minimum Efficiency: 25–30%

Shorter settings generate earlier but potentially noisier signals.

CONSERVATIVE PROFILE

For fewer and stronger signals:

• Increase Minimum Launch Direction
• Increase Minimum Launch Propulsion
• Increase Minimum Coherence to 75–80%
• Increase Minimum Efficiency to 30%
• Keep the maximum extension filter enabled

PRACTICAL WORKFLOW

A preferred bullish sequence is:

Ignition → Launch → Cruise → Overdrive

A typical deterioration sequence is:

Overdrive or Cruise → Engine Failure → Reversal

A complete investment process may use the indicator as follows:

1. Confirm that company fundamentals are stable or improving.
2. Estimate fair value and the available margin of safety.
3. Look for Ignition, Launch or a healthy Cruise regime.
4. Avoid chasing excessively extended prices.
5. Monitor Propulsion, Coherence and Reserve after entry.
6. Reassess the position when Engine Failure appears.
7. Review the thesis and risk exposure after a confirmed Reversal.

The indicator is designed to improve timing and trend monitoring. It does not replace fundamental analysis or valuation.

DISPLAY SETTINGS

SHOW PROPULSION TUNNEL

Displays the adaptive channel around the regression trend.

SHOW LUMINOUS TREND CORE

Displays the central trend line and its glow.

SHOW REGIME RIBBON

Displays the historical sequence of trend regimes below price.

SHOW EVENT MARKERS

Displays the L, C, ! and R markers.

SHOW COCKPIT

Displays the current Direction, Propulsion, Coherence, Friction and Reserve values.

COLOR CHART BARS

Applies the current regime color to the chart candles.

BASE TUNNEL WIDTH

Controls the tunnel’s initial width in ATR units.

A higher value produces a wider and less sensitive tunnel.

RIBBON DISTANCE

Controls the distance between the regime ribbon and the candle lows.

ALERTS

Four alert conditions are included:

• TPE — Launch Confirmed
• TPE — Cruise Entry
• TPE — Engine Failure
• TPE — Reversal Confirmed

For reliable notifications, configure TradingView alerts using:

Once Per Bar Close

NON-REPAINTING BEHAVIOR

The indicator uses:

• No future pivots
• No negative plotting offsets
• No lookahead data
• No future-bar confirmation
• Event markers confirmed only at bar close

Values may naturally change while the current realtime candle is still open. Confirmed markers are only generated when that candle closes.

LIMITATIONS

Trend Propulsion Tunnel does not:

• Calculate fair value
• Analyse company fundamentals
• Predict earnings or news events
• Guarantee that a trend will continue
• Provide automatic investment recommendations
• Replace position sizing or risk management

Signals may be delayed after large price gaps. The indicator may also be less reliable on illiquid assets or during highly discontinuous market conditions.

DISCLAIMER

This indicator is provided for educational and analytical purposes only. It does not constitute financial, trading or investment advice. Past statistical relationships do not guarantee future results.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Stevesyl

//@version=6
indicator("Equalhigh Trend Propulsion Tunnel", shorttitle="EH Propulsion v2", overlay=true, max_bars_back=500)

// ═════════════════════════════════════════════════════════════════════════════
// 1. INPUTS
// ═════════════════════════════════════════════════════════════════════════════
groupEngine = "1. Propulsion engine"
lenFast     = input.int(13, "Fast horizon", minval=5, maxval=100, group=groupEngine)
lenMid      = input.int(26, "Medium horizon", minval=10, maxval=150, group=groupEngine)
lenSlow     = input.int(52, "Slow horizon", minval=20, maxval=250, group=groupEngine)
accelSmooth = input.int(3, "Propulsion smoothing", minval=1, maxval=20, group=groupEngine)

groupSignal = "2. Signal filters"
launchDir   = input.float(28.0, "Minimum direction for Launch", minval=5, maxval=80, step=1, group=groupSignal)
launchProp  = input.float(4.0, "Minimum propulsion for Launch", minval=0, maxval=40, step=0.5, group=groupSignal)
minCoherence = input.float(0.70, "Minimum coherence", minval=0.50, maxval=1.00, step=0.05, group=groupSignal)
minEfficiency = input.float(0.25, "Minimum efficiency", minval=0.05, maxval=1.00, step=0.05, group=groupSignal)
maxExtension = input.float(2.50, "Maximum extension (Z)", minval=1.0, maxval=5.0, step=0.25, group=groupSignal)
dragProp    = input.float(-3.0, "Engine-failure propulsion", minval=-30, maxval=0, step=0.5, group=groupSignal)

groupVisual = "3. Display"
showTunnel  = input.bool(true, "Show propulsion tunnel", group=groupVisual)
showCore    = input.bool(true, "Show luminous trend core", group=groupVisual)
showRibbon  = input.bool(true, "Show regime ribbon", group=groupVisual)
showSignals = input.bool(true, "Show event markers", group=groupVisual)
showPanel   = input.bool(true, "Show cockpit", group=groupVisual)
colorBars   = input.bool(false, "Color chart bars", group=groupVisual)
widthMult   = input.float(1.80, "Base tunnel width (ATR)", minval=0.50, maxval=5.00, step=0.10, group=groupVisual)
ribbonGap   = input.float(0.60, "Ribbon distance (ATR)", minval=0.10, maxval=3.00, step=0.10, group=groupVisual)
panelPos    = input.string("Top right", "Cockpit position", options=["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group=groupVisual)

// ═════════════════════════════════════════════════════════════════════════════
// 2. MULTI-HORIZON DIRECTION
// ═════════════════════════════════════════════════════════════════════════════
float logPrice = math.log(close)
float logRet   = math.log(close / close[1])

f_tanh(float x) =>
    float e = math.exp(math.min(20.0, math.max(-20.0, 2.0 * x)))
    (e - 1.0) / (e + 1.0)

// One-bar change in the fitted regression line, normalized by realized noise.
f_slope_score(int len) =>
    float fitNow = ta.linreg(logPrice, len, 0)
    float fitPrev = ta.linreg(logPrice, len, 1)
    float slope = fitNow - fitPrev
    float noise = ta.stdev(logRet, len)
    noise > 0 ? 100.0 * f_tanh((slope / noise) * 2.5) : 0.0

float slopeFast = f_slope_score(lenFast)
float slopeMid  = f_slope_score(lenMid)
float slopeSlow = f_slope_score(lenSlow)
float direction = 0.45 * slopeFast + 0.35 * slopeMid + 0.20 * slopeSlow

// Propulsion is the smoothed acceleration of the multi-horizon direction.
float propRaw = ta.ema(ta.change(direction), accelSmooth)
float propulsion = 100.0 * f_tanh(propRaw / 12.0)

// ═════════════════════════════════════════════════════════════════════════════
// 3. COHERENCE, FRICTION, EXTENSION AND RESERVE
// ═════════════════════════════════════════════════════════════════════════════
float dominantSign = direction >= 0 ? 1.0 : -1.0
float horizonAgreement = ((slopeFast * dominantSign > 0 ? 1.0 : 0.0) +
                          (slopeMid  * dominantSign > 0 ? 1.0 : 0.0) +
                          (slopeSlow * dominantSign > 0 ? 1.0 : 0.0)) / 3.0

float agreeingBars = 0.0
for i = 0 to lenFast - 1
    agreeingBars += logRet[i] * dominantSign > 0 ? 1.0 : 0.0
float returnAgreement = agreeingBars / lenFast
float coherence = 0.65 * horizonAgreement + 0.35 * returnAgreement

float travelled = math.sum(math.abs(logRet), lenMid)
float displacement = math.abs(logPrice - logPrice[lenMid])
float efficiency = travelled > 0 ? math.min(1.0, displacement / travelled) : 0.0
float friction = 1.0 - efficiency

float slowFit = ta.linreg(logPrice, lenSlow, 0)
float residual = logPrice - slowFit
float residualNoise = ta.stdev(logPrice - ta.linreg(logPrice, lenSlow, 0), lenSlow)
float extensionZ = residualNoise > 0 ? residual / residualNoise : 0.0

float propSupport = 50.0 + 50.0 * dominantSign * propulsion / 100.0
float extensionPenalty = math.max(0.0, math.abs(extensionZ) - 1.0) * 12.0
float rawReserve = 45.0 * coherence + 35.0 * efficiency + 20.0 * math.max(0.0, math.min(1.0, propSupport / 100.0)) - extensionPenalty
float reserve = math.max(0.0, math.min(100.0, rawReserve))

bool enoughData = bar_index >= lenSlow + lenMid and not na(direction) and not na(propulsion) and not na(extensionZ)

// ═════════════════════════════════════════════════════════════════════════════
// 4. FLIGHT COMPUTER — REGIME CLASSIFICATION
// ═════════════════════════════════════════════════════════════════════════════
bool launchReady = enoughData and direction >= launchDir and propulsion >= launchProp and coherence >= minCoherence and efficiency >= minEfficiency and extensionZ <= maxExtension
bool bearLaunch  = enoughData and direction <= -launchDir and propulsion <= -launchProp and coherence >= minCoherence and efficiency >= minEfficiency and extensionZ >= -maxExtension
bool engineFailure = enoughData and direction > 10 and (propulsion <= dragProp or reserve < 30 or coherence < 0.50)
bool bearishFailure = enoughData and direction < -10 and (propulsion >= -dragProp or reserve < 30 or coherence < 0.50)

int regime = 0
string regimeName = "NEUTRAL"
color regimeColor = color.rgb(126, 87, 194)

if enoughData
    if direction <= -launchDir and propulsion < 0 and coherence >= minCoherence
        regime := -3
        regimeName := "REVERSAL"
        regimeColor := color.rgb(255, 48, 79)
    else if engineFailure
        regime := -1
        regimeName := "ENGINE FAILURE"
        regimeColor := color.rgb(255, 126, 35)
    else if bearishFailure
        regime := 1
        regimeName := "BEAR FADE"
        regimeColor := color.rgb(89, 255, 205)
    else if direction >= 65 and coherence >= 0.80 and reserve >= 55
        regime := 4
        regimeName := "OVERDRIVE"
        regimeColor := color.rgb(255, 196, 40)
    else if launchReady
        regime := 3
        regimeName := "LAUNCH"
        regimeColor := color.rgb(0, 174, 255)
    else if direction >= launchDir and coherence >= minCoherence and propulsion > dragProp
        regime := 2
        regimeName := "CRUISE"
        regimeColor := color.rgb(0, 229, 255)
    else if direction > 8 and propulsion > 0
        regime := 1
        regimeName := "IGNITION"
        regimeColor := color.rgb(153, 89, 255)
    else if bearLaunch
        regime := -2
        regimeName := "BEAR DRIVE"
        regimeColor := color.rgb(255, 76, 112)

bool firstLaunch = barstate.isconfirmed and launchReady and not launchReady[1]
bool firstFailure = barstate.isconfirmed and engineFailure and not engineFailure[1]
bool firstReversal = barstate.isconfirmed and regime == -3 and regime[1] != -3
bool firstCruise = barstate.isconfirmed and regime == 2 and regime[1] != 2

// ═════════════════════════════════════════════════════════════════════════════
// 5. PROPULSION TUNNEL — PRICE OVERLAY
// ═════════════════════════════════════════════════════════════════════════════
float atr = ta.atr(14)
float trendCore = math.exp(slowFit)
// Friction expands the tunnel; high coherence slightly tightens it.
float adaptiveWidth = atr * widthMult * (0.75 + 0.70 * friction) * (1.10 - 0.20 * coherence)
float tunnelUpper = trendCore + adaptiveWidth
float tunnelLower = trendCore - adaptiveWidth
float ribbonLevel = low - atr * ribbonGap

// Transparent outer glow, colored tunnel and a thin regression core.
plot(showTunnel ? tunnelUpper + atr * 0.12 : na, "Outer upper glow", color=color.new(regimeColor, 91), linewidth=4)
plot(showTunnel ? tunnelLower - atr * 0.12 : na, "Outer lower glow", color=color.new(regimeColor, 91), linewidth=4)
pUpper = plot(showTunnel ? tunnelUpper : na, "Tunnel upper", color=color.new(regimeColor, 62), linewidth=1)
pLower = plot(showTunnel ? tunnelLower : na, "Tunnel lower", color=color.new(regimeColor, 62), linewidth=1)
fill(pUpper, pLower, color=showTunnel ? color.new(regimeColor, 88) : na, title="Propulsion tunnel")
plot(showCore ? trendCore : na, "Core glow wide", color=color.new(regimeColor, 86), linewidth=8)
plot(showCore ? trendCore : na, "Core glow", color=color.new(regimeColor, 63), linewidth=5)
plot(showCore ? trendCore : na, "Trend core", color=regimeColor, linewidth=2)

// A compact state ribbon follows price without changing the chart scale.
plot(showRibbon ? ribbonLevel : na, "Regime ribbon glow", color=color.new(regimeColor, 78), linewidth=7, style=plot.style_linebr)
plot(showRibbon ? ribbonLevel : na, "Regime ribbon", color=regimeColor, linewidth=3, style=plot.style_linebr)

float bullMarkerLevel = low - atr * (ribbonGap + 0.35)
float bearMarkerLevel = high + atr * 0.45
plotshape(showSignals and firstLaunch ? bullMarkerLevel : na, title="Launch", style=shape.circle, location=location.absolute, color=color.rgb(0, 174, 255), size=size.small, text="L", textcolor=color.white)
plotshape(showSignals and firstCruise ? bullMarkerLevel : na, title="Cruise", style=shape.diamond, location=location.absolute, color=color.rgb(0, 229, 255), size=size.tiny, text="C", textcolor=color.rgb(5, 25, 45))
plotshape(showSignals and firstFailure ? bearMarkerLevel : na, title="Engine failure", style=shape.circle, location=location.absolute, color=color.rgb(255, 126, 35), size=size.small, text="!", textcolor=color.white)
plotshape(showSignals and firstReversal ? bearMarkerLevel : na, title="Reversal", style=shape.circle, location=location.absolute, color=color.rgb(255, 48, 79), size=size.small, text="R", textcolor=color.white)

barcolor(colorBars ? color.new(regimeColor, 25) : na)

// ═════════════════════════════════════════════════════════════════════════════
// 6. COCKPIT AND ALERTS
// ═════════════════════════════════════════════════════════════════════════════
f_position(string p) =>
    switch p
        "Top left"     => position.top_left
        "Top center"   => position.top_center
        "Middle left"  => position.middle_left
        "Middle right" => position.middle_right
        "Bottom left"  => position.bottom_left
        "Bottom center"=> position.bottom_center
        "Bottom right" => position.bottom_right
        => position.top_right

f_arrow(float value) => value > 3 ? "▲" : value < -3 ? "▼" : "►"
f_pct(float value) => str.tostring(value * 100.0, "#") + "%"

var table cockpit = table.new(f_position(panelPos), 2, 6, bgcolor=color.new(color.rgb(8, 13, 25), 10), frame_color=color.new(color.white, 82), frame_width=1)

if barstate.islast and showPanel
    table.cell(cockpit, 0, 0, "TPE // STATUS", text_color=color.white, bgcolor=color.new(regimeColor, 35), text_size=size.small)
    table.cell(cockpit, 1, 0, regimeName, text_color=color.white, bgcolor=color.new(regimeColor, 35), text_size=size.small)
    table.cell(cockpit, 0, 1, "DIRECTION", text_color=color.silver)
    table.cell(cockpit, 1, 1, f_arrow(direction) + " " + str.tostring(direction, "#.0"), text_color=direction >= 0 ? color.aqua : color.rgb(255, 91, 118))
    table.cell(cockpit, 0, 2, "PROPULSION", text_color=color.silver)
    table.cell(cockpit, 1, 2, f_arrow(propulsion) + " " + str.tostring(propulsion, "#.0"), text_color=propulsion >= 0 ? color.rgb(89, 255, 205) : color.orange)
    table.cell(cockpit, 0, 3, "COHERENCE", text_color=color.silver)
    table.cell(cockpit, 1, 3, f_pct(coherence), text_color=coherence >= minCoherence ? color.aqua : color.orange)
    table.cell(cockpit, 0, 4, "FRICTION", text_color=color.silver)
    table.cell(cockpit, 1, 4, f_pct(friction), text_color=friction <= 1.0 - minEfficiency ? color.rgb(89, 255, 205) : color.orange)
    table.cell(cockpit, 0, 5, "RESERVE", text_color=color.silver)
    table.cell(cockpit, 1, 5, str.tostring(reserve, "#") + "%", text_color=reserve >= 55 ? color.rgb(255, 196, 40) : reserve >= 30 ? color.aqua : color.orange)

if barstate.islast and not showPanel
    table.clear(cockpit, 0, 0, 1, 5)

alertcondition(firstLaunch, "TPE — Launch confirmed", "{{ticker}}: Trend Propulsion Engine has confirmed a new Launch at the close.")
alertcondition(firstCruise, "TPE — Cruise entry", "{{ticker}}: Trend Propulsion Engine has entered a stable Cruise regime.")
alertcondition(firstFailure, "TPE — Engine failure", "{{ticker}}: price direction remains positive, but trend propulsion is failing.")
alertcondition(firstReversal, "TPE — Reversal confirmed", "{{ticker}}: Trend Propulsion Engine has confirmed a bearish reversal.")

// Values available in TradingView's Data Window.
plot(propulsion, "Propulsion score", display=display.data_window)
plot(coherence * 100.0, "Coherence (%)", display=display.data_window)
plot(friction * 100.0, "Friction (%)", display=display.data_window)
plot(reserve, "Trend reserve (%)", display=display.data_window)
plot(extensionZ, "Extension Z-score", display=display.data_window)
````
