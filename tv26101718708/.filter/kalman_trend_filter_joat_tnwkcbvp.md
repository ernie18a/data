# Kalman Trend Filter [JOAT]

- url: https://www.tradingview.com/script/tnWkCBVp-Kalman-Trend-Filter-JOAT/
- type: indicator
- pine_id: PUB;d0c1a08c06a04a7a99ee28466e8f2a77
- version: 1.0

## Description

[b]Kalman Trend Filter [JOAT][/b]

[b]Introduction[/b]

Kalman Trend Filter is an open-source trend detection indicator that applies a two-state Kalman filter to price, tracking both the filtered price level and its velocity simultaneously. Unlike exponential moving averages — which apply a fixed exponential decay to past data — the Kalman filter dynamically adjusts its responsiveness based on the ratio of process noise to measurement noise. When price is moving consistently in one direction, the filter trusts new measurements more heavily. When price is noisy, it trusts its own model more heavily.

The practical result is a trend line that responds faster than an equivalent EMA during genuine trends while remaining smoother during chop. The velocity state is the direct indicator of trend direction and strength — it is what drives signal generation and candle coloring.

[b]Core Concepts[/b]

[b]1. Two-State Kalman Filter[/b]

The filter tracks two quantities: price (position state) and the rate at which price is changing (velocity state). The prediction step projects both states forward using simple kinematic equations. The correction step updates them based on how much the current close deviates from prediction:

[pine]
// Prediction
float xPred = xEst + vEst
float pPred = pEst + qNoise

// Kalman gain
float kGain = pPred / (pPred + rNoise)

// Correction
float xEst = xPred + kGain * (close - xPred)
float vEst = vEst  + kGain * (close - xPred)
[/pine]

The process noise (qNoise) and measurement noise (rNoise) parameters control how much the filter trusts its own momentum model versus new price data.

[b]2. Velocity as Trend Proxy[/b]

The velocity state is the most analytically useful output. Positive velocity means the filtered price is accelerating upward; negative means downward. The magnitude of velocity indicates trend strength. Velocity crossing zero is a higher-quality trend reversal signal than a moving average crossover because it reflects the momentum of the filtered series, not the level.

[image]https://www.tradingview.com/x/sZxCMqyf/[/image]

[b]3. Gradient Candle Coloring[/b]

Candles are painted using a two-sided gradient driven by the velocity state. Strongly positive velocity produces bright cyan candles; strongly negative produces bright magenta. Near-zero velocity transitions to neutral. The gradient intensity scales with velocity magnitude rather than applying a binary color switch.

[b]4. Velocity Oscillator[/b]

The velocity state is plotted as a separate sub-indicator below the main chart, providing a visual oscillator that crosses zero at trend reversals. Unlike momentum oscillators derived from price differences, this oscillator represents the Kalman filter's internal estimate of trend rate — it is inherently smooth without additional EMA smoothing.

[b]Features[/b]

[list]
[*][b]Two-state Kalman filter:[/b] Tracks price level and velocity simultaneously
[*][b]Configurable noise parameters:[/b] Process and measurement noise control filter responsiveness
[*][b]Filtered price line overlay:[/b] Smooth trend line drawn on the price chart
[*][b]Velocity oscillator:[/b] Kalman velocity state as a zero-line oscillator
[*][b]Velocity zero-cross signals:[/b] Bull and bear signals when velocity crosses zero
[*][b]Gradient candle coloring:[/b] Cyan for upward velocity, magenta for downward, scaled by magnitude
[*][b]Dashboard:[/b] Current filtered price, velocity, trend state, and noise parameters
[*][b]Alerts:[/b] Velocity zero-cross and extreme velocity alerts
[/list]

[b]Input Parameters[/b]

[b]Kalman Engine:[/b]
[list]
[*]Process Noise (Q): How much the filter trusts its own velocity model (default: 0.01)
[*]Measurement Noise (R): How much the filter trusts new price measurements (default: 1.0)
[*]Initial Velocity: Starting velocity state (default: 0.0)
[/list]

[b]Display:[/b]
[list]
[*]Show Filter Line toggle
[*]Show Velocity Oscillator toggle
[*]Show Candle Color toggle
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read Velocity Direction[/b]
Positive velocity (oscillator above zero, cyan candles) indicates the filter is trending upward. Negative velocity (below zero, magenta candles) indicates downward trend. The magnitude tells you how strong.

[b]Step 2: Use Velocity Zero-Cross as Trend Change Signal[/b]
When velocity crosses from negative to positive, the filter's internal momentum model has flipped bullish. This is more reliable than a price crossover because it reflects the rate of change of the filtered series.

[b]Step 3: Tune Noise Parameters to Timeframe[/b]
On faster timeframes, increase Q slightly (0.02–0.05) to make the filter more responsive. On weekly charts, reduce Q (0.001–0.005) for a smoother, slower-adjusting filter.

[b]Step 4: Combine with Regime Context[/b]
The Kalman filter performs best in trending regimes. Combine with Fractal Dimension Oscillator: when FDO shows a trending regime, Kalman velocity direction provides the trend bias.

[b]Indicator Limitations[/b]

[list]
[*]The Kalman filter assumes a linear motion model; non-linear price dynamics (sudden gaps, news events) produce temporary distortion in the filter state
[*]Optimal Q and R values are instrument and timeframe dependent; no universal setting works everywhere
[*]Velocity zero-crosses during low-volatility consolidation can produce frequent false signals
[/list]

[b]Originality Statement[/b]

The two-state Kalman filter implementation combined with a velocity-driven gradient candle coloring system, a dedicated velocity oscillator, and dual-input noise parameter configuration in a single publication is the original contribution here. Most published Kalman filter scripts on TradingView implement a single-state position filter with no velocity tracking and no gradient visualization.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Kalman filter outputs are mathematical estimates based on prior observations and do not predict future price. Trading involves substantial risk of loss.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Kalman Trend Filter [JOAT]", shorttitle="KTF [JOAT]", overlay=true,
     max_lines_count=100, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — COLOR SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════
color BULL_CYAN   = color.rgb(  0, 220, 200)
color BEAR_MAGENTA= color.rgb(220,   0, 180)
color ACCEL_GOLD  = color.rgb(255, 185,  20)
color DECEL_BLUE  = color.rgb( 50, 120, 255)
color VOID_BG     = color.rgb( 10,  14,  26)
color SLATE_BRD   = color.rgb( 40,  55,  90)
color LAVEN_HDR   = color.rgb(140, 160, 210)
color GOLD_VAL    = color.rgb(255, 215,  60)
color NEON_CYAN   = color.rgb(  0, 243, 255)

lerpCol(color cA, color cB, float t) =>
    float ct = math.max(0.0, math.min(1.0, t))
    int r = int(color.r(cA) + (color.r(cB) - color.r(cA)) * ct)
    int g = int(color.g(cA) + (color.g(cB) - color.g(cA)) * ct)
    int b = int(color.b(cA) + (color.b(cB) - color.b(cA)) * ct)
    color.rgb(r, g, b)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
string G_KALMAN = "━━ Kalman Filter Parameters ━━"
string G_SIG    = "━━ Signal Settings ━━"
string G_VIZ    = "━━ Visual Settings ━━"
string G_DASH   = "━━ Dashboard ━━"

float  i_Q      = input.float(0.01,  "Process Noise (Q)",         minval=0.0001, maxval=1.0, step=0.001, group=G_KALMAN,
     tooltip="How fast the filter adapts to new data. Higher = faster response, less smoothing.")
float  i_R      = input.float(1.0,   "Measurement Noise (R)",     minval=0.01, maxval=100.0, step=0.1, group=G_KALMAN,
     tooltip="How much the filter trusts incoming measurements. Higher = smoother (more lag).")
float  i_velQ   = input.float(0.001, "Velocity Process Noise (Q_v)", minval=0.0001, step=0.0001, group=G_KALMAN,
     tooltip="Smoothing for velocity state. Lower = smoother velocity.")
float  i_bandMult= input.float(2.0,  "Uncertainty Band Width",    minval=0.5, maxval=5.0, step=0.1, group=G_KALMAN)
bool   i_useHTF = input.bool(false,  "HTF Kalman Alignment",      group=G_SIG)
string i_htfTf  = input.timeframe("D","HTF Timeframe",            group=G_SIG)
float  i_velThr = input.float(0.0,   "Velocity Signal Threshold", minval=0.0, step=0.0001, group=G_SIG,
     tooltip="Velocity must exceed this absolute value to trigger a signal.")
bool   i_showBands= input.bool(true, "Show Uncertainty Bands",    group=G_VIZ)
bool   i_showVel  = input.bool(true, "Show Velocity Histogram",   group=G_VIZ)
bool   i_showDash = input.bool(true, "Show Dashboard",            group=G_DASH)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — KALMAN FILTER (2-State: Position + Velocity)
// State vector: [price, velocity]
// Prediction: price_pred = price + velocity; vel_pred = velocity
// Update: Kalman gain K = P_pred / (P_pred + R)
//         price = price_pred + K * (measurement - price_pred)
// ═══════════════════════════════════════════════════════════════════════════════
var float kf_price = close       // State: filtered price
var float kf_vel   = 0.0         // State: velocity (trend momentum)
var float kf_P     = 1.0         // Uncertainty (error covariance) - price
var float kf_Pv    = 1.0         // Uncertainty - velocity

// Predict step
float pred_price = kf_price + kf_vel
float pred_vel   = kf_vel
float pred_P     = kf_P  + i_Q
float pred_Pv    = kf_Pv + i_velQ

// Update step
float innov = close - pred_price        // Innovation (measurement residual)
float S     = pred_P + i_R             // Innovation covariance
float K     = pred_P / S               // Kalman gain (price)
float Kv    = pred_Pv / (pred_Pv + i_R * 2.0) // Velocity gain

kf_price := pred_price + K  * innov
kf_vel   := pred_vel   + Kv * innov * 0.1
kf_P     := (1.0 - K)  * pred_P
kf_Pv    := (1.0 - Kv) * pred_Pv

// Uncertainty bands
float uncertBand = math.sqrt(kf_P) * i_bandMult * ta.atr(14)
float upperBand  = kf_price + uncertBand
float lowerBand  = kf_price - uncertBand

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — HTF KALMAN (optional)
// ═══════════════════════════════════════════════════════════════════════════════
float htfKFPrice = request.security(syminfo.tickerid, i_htfTf, kf_price[1], lookahead=barmerge.lookahead_on)
float htfKFVel   = request.security(syminfo.tickerid, i_htfTf, kf_vel[1],   lookahead=barmerge.lookahead_on)
bool  htfBull    = not i_useHTF or (not na(htfKFVel) and htfKFVel > 0.0)
bool  htfBear    = not i_useHTF or (not na(htfKFVel) and htfKFVel < 0.0)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — SIGNAL LOGIC
// ═══════════════════════════════════════════════════════════════════════════════
bool velPosX = barstate.isconfirmed and ta.crossover (kf_vel, i_velThr)   and close > kf_price
bool velNegX = barstate.isconfirmed and ta.crossunder(kf_vel, -i_velThr)  and close < kf_price

bool longSignal  = velPosX and htfBull
bool shortSignal = velNegX and htfBear

bool isBullish = kf_vel > 0.0 and close > kf_price
bool isBearish = kf_vel < 0.0 and close < kf_price

// Acceleration detection (velocity increasing/decreasing)
bool accel = math.abs(kf_vel) > math.abs(kf_vel[1])
bool decel = math.abs(kf_vel) < math.abs(kf_vel[1])

// ── KTF Candle Coloring ────────────────────────────────────────────────────
// Colors based on Kalman velocity sign + magnitude
float velAbs     = math.abs(kf_vel)
float velMaxEst  = ta.highest(velAbs, 50)
float velNormBar = velMaxEst > 0.0 ? velAbs / velMaxEst : 0.0

color ktfCandleColor = na
if kf_vel > 0.0
    // Bullish: cyan to bright mint based on velocity strength
    int alphaVal = int(math.max(10, 50 - velNormBar * 40))
    ktfCandleColor := color.new(color.rgb(0, 220, 200), alphaVal)
else if kf_vel < 0.0
    // Bearish: magenta to hot pink based on velocity strength
    int alphaVal = int(math.max(10, 50 - velNormBar * 40))
    ktfCandleColor := color.new(color.rgb(220, 0, 180), alphaVal)
barcolor(ktfCandleColor, title="KTF Velocity Candle Color")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — VISUAL RENDERING
// ═══════════════════════════════════════════════════════════════════════════════
// Kalman filter line — color transitions with direction and momentum
float velNorm = math.max(-1.0, math.min(1.0, kf_vel / (ta.atr(14) * 0.01 + 0.0001)))
color filterColor = velNorm >= 0.0 ?
     lerpCol(LAVEN_HDR, BULL_CYAN, velNorm) :
     lerpCol(LAVEN_HDR, BEAR_MAGENTA, -velNorm)

plot(kf_price, "Kalman Filter", color=filterColor, linewidth=2, style=plot.style_line)

// Uncertainty bands
upperPlot = plot(i_showBands ? upperBand : na, "Upper Uncertainty", color=color.new(filterColor, 70), linewidth=1, style=plot.style_line)
lowerPlot = plot(i_showBands ? lowerBand : na, "Lower Uncertainty", color=color.new(filterColor, 70), linewidth=1, style=plot.style_line)
fill(upperPlot, lowerPlot, color=color.new(filterColor, 88), title="Uncertainty Band")

// Buy/sell signals
plotshape(longSignal,  "KTF Long",  shape.triangleup,   location.belowbar,
     color=BULL_CYAN,    size=size.small, text="KTF L", textcolor=BULL_CYAN)
plotshape(shortSignal, "KTF Short", shape.triangledown,  location.abovebar,
     color=BEAR_MAGENTA, size=size.small, text="KTF S", textcolor=BEAR_MAGENTA)

// Acceleration markers
plotshape(accel and isBullish, "Accel Bull", shape.circle, location.belowbar,
     color=color.new(ACCEL_GOLD, 40), size=size.tiny)
plotshape(accel and isBearish, "Accel Bear", shape.circle, location.abovebar,
     color=color.new(ACCEL_GOLD, 40), size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 7,
     bgcolor=color.new(VOID_BG, 5), frame_color=SLATE_BRD, frame_width=1,
     border_color=SLATE_BRD, border_width=1)

if i_showDash
    string dirStr  = isBullish ? "BULLISH" : isBearish ? "BEARISH" : "NEUTRAL"
    color  dirCol  = isBullish ? BULL_CYAN : isBearish ? BEAR_MAGENTA : LAVEN_HDR
    string velStr  = str.tostring(kf_vel, "#.#####")
    string uncStr  = str.tostring(uncertBand, format.mintick)
    string accStr  = accel ? "ACCELERATING" : decel ? "DECELERATING" : "STABLE"
    color  accCol  = accel ? ACCEL_GOLD : decel ? DECEL_BLUE : LAVEN_HDR
    string htfStr  = not i_useHTF ? "OFF" : htfBull ? "BULLISH" : htfBear ? "BEARISH" : "NEUTRAL"
    color  htfCol  = not i_useHTF ? LAVEN_HDR : htfBull ? BULL_CYAN : htfBear ? BEAR_MAGENTA : LAVEN_HDR

    table.cell(dash, 0, 0, "Kalman Trend Filter", text_color=LAVEN_HDR,
         text_size=size.small, bgcolor=color.new(VOID_BG, 5))
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "KF Price",    text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 1, str.tostring(kf_price, format.mintick),
         text_color=GOLD_VAL, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 2, "Velocity",    text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 2, velStr,        text_color=filterColor,text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 3, "Direction",   text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 3, dirStr,        text_color=dirCol,    text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 4, "Uncertainty", text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 4, uncStr,        text_color=NEON_CYAN, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 5, "Momentum",    text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 5, accStr,        text_color=accCol,    text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 6, "HTF Align",   text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 6, htfStr,        text_color=htfCol,    text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(longSignal,  "KTF Long Signal",  "Kalman Trend Filter [JOAT]: LONG signal — velocity turned positive on {{ticker}} {{interval}}")
alertcondition(shortSignal, "KTF Short Signal", "Kalman Trend Filter [JOAT]: SHORT signal — velocity turned negative on {{ticker}} {{interval}}")
alertcondition(accel and isBullish, "KTF Bull Acceleration", "Kalman Trend Filter [JOAT]: Bullish acceleration detected on {{ticker}}")
alertcondition(accel and isBearish, "KTF Bear Acceleration", "Kalman Trend Filter [JOAT]: Bearish acceleration detected on {{ticker}}")
alertcondition(ta.crossover(kf_vel, 0.0), "KTF Velocity Bull Cross", "Kalman Trend Filter [JOAT]: Velocity crossed above zero on {{ticker}}")
alertcondition(ta.crossunder(kf_vel, 0.0), "KTF Velocity Bear Cross", "Kalman Trend Filter [JOAT]: Velocity crossed below zero on {{ticker}}")
````
