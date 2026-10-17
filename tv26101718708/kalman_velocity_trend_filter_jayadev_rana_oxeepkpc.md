# Kalman Velocity Trend Filter [Jayadev Rana]

- url: https://www.tradingview.com/script/OXeepkpc-Kalman-Velocity-Trend-Filter-Jayadev-Rana/
- type: indicator
- pine_id: PUB;5da8b5e709514fab8f1c5d9e61c6a546
- version: 1.0

## Description

OVERVIEW

Kalman Velocity Trend Filter is a trend-following overlay that prints alternating BUY and SELL signals from the slope of a two-state Kalman filter. Instead of smoothing price with a moving average and then measuring its slope afterwards, the filter estimates two things at once on every bar: where the underlying price level is, and how fast it is moving (its velocity). The signals come from the velocity estimate, expressed in ATRs per bar so the same thresholds work on any instrument.

HOW IT WORKS

The model assumes that price is a level that advances by a velocity each bar, plus noise. On every bar the script first predicts the next level (previous level plus previous velocity), then compares the prediction with the actual price. The difference is called the innovation. A share of that innovation, set by the Kalman gain, is used to correct both the level and the velocity.

All three noise terms are scaled by ATR:
- Measurement noise: how noisy each new price is assumed to be. Larger values produce a smoother, slower line.
- Position process noise: how far the true level may jump outside the velocity model.
- Velocity process noise: how quickly the velocity itself is allowed to change.

Because the noise terms follow ATR, the filter loosens automatically when volatility expands and tightens when it contracts, without changing any setting.

SIGNALS

- BUY: the velocity rises above the Trend Entry Velocity on a closed bar and the last signal was not a BUY.
- SELL: the velocity falls below the negative Trend Entry Velocity on a closed bar and the last signal was not a SELL.

Signals strictly alternate. A pass through the neutral state does not repeat the previous signal. All signals are evaluated on closed bars and are not changed afterwards.

The line color shows the current state (up, down or neutral). The shaded envelope is the filter's own uncertainty about the level estimate (plus and minus a multiple of its standard deviation). It is not a volatility band and it is not used for signals. Optional shock markers flag bars where price landed unusually far from the filter's forecast, which often marks news bars or the start of a new leg.

DASHBOARD

State, velocity in ATR per bar, the latest innovation in standard deviations, and the current Kalman gain.

SETTINGS

Filter: Source, Noise Unit (ATR Length), Measurement Noise, Position Process Noise, Velocity Process Noise, Envelope Width.
Trend State: Trend Entry Velocity, Neutral Velocity, Allow Neutral State, Shock Threshold, Mark Shocks, Color Bars by State.
Dashboard: visibility and position.
Style: colors.

DEFAULT SETTINGS

The default values were chosen with a parameter search on BTCUSDT on the 1-hour timeframe. The search treated the signals as a stop-and-reverse system with trading costs, split the history into an earlier and a later segment, and kept only settings that held up in both segments. Other symbols and timeframes will usually need different values; treat the defaults as a starting point and not as a recommendation.

ALERTS

Buy Signal, Sell Signal, Price Shock.

LIMITATIONS

- This is a trend-following tool. In sideways markets the velocity crosses the threshold back and forth and signals will be late and often wrong.
- A smoother filter gives fewer false signals and also reacts later to real reversals. No setting removes this trade-off.
- The values of the current bar change until the bar closes. Signals are only printed on bar close.
- The envelope describes model uncertainty under the chosen noise settings; it is not a probability forecast for price.
- Settings tuned on past data can stop working when market behavior changes.

This script is for analysis and education. It does not provide financial advice, and past behavior of any signal does not guarantee future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// (c) Jayadev Rana
//@version=6
indicator("Kalman Velocity Trend Filter [Jayadev Rana]", shorttitle = "KVTF", overlay = true)

//------------------------------------------------------------------------------
// Constants
//------------------------------------------------------------------------------
string GRP_CORE  = "Filter"
string GRP_STATE = "Trend State"
string GRP_DASH  = "Dashboard"
string GRP_STYLE = "Style"

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
float src      = input.source(close, "Source", group = GRP_CORE)
int   atrLen   = input.int(14, "Noise Unit (ATR Length)", minval = 2, maxval = 200, group = GRP_CORE, tooltip = "All noise terms are expressed in ATR units so the filter behaves the same on any instrument or price scale.")
float measMult = input.float(3.0, "Measurement Noise", minval = 0.1, maxval = 10.0, step = 0.1, group = GRP_CORE, tooltip = "How noisy each new price is assumed to be, in ATRs. Higher values trust the model more than the price: smoother line, more lag.")
float posMult  = input.float(0.10, "Position Process Noise", minval = 0.0, maxval = 2.0, step = 0.01, group = GRP_CORE, tooltip = "How far the true price level may jump per bar outside the velocity model, in ATRs. Higher values make the line hug price.")
float velMult  = input.float(0.01, "Velocity Process Noise", minval = 0.001, maxval = 1.0, step = 0.005, group = GRP_CORE, tooltip = "How quickly the estimated velocity may change per bar, in ATRs. Higher values let the slope turn faster and also let it whipsaw more.")
float envMult  = input.float(2.0, "Envelope Width", minval = 0.5, maxval = 5.0, step = 0.25, group = GRP_CORE, tooltip = "Envelope half-width in standard deviations of the level estimate. It is the filter's own uncertainty about where the level is, not a volatility band.")

float enterThr   = input.float(0.12, "Trend Entry Velocity", minval = 0.0, maxval = 2.0, step = 0.01, group = GRP_STATE, tooltip = "Velocity, in ATRs per bar, required to switch the state to up or down.")
float exitThr    = input.float(0.03, "Neutral Velocity", minval = 0.0, maxval = 2.0, step = 0.01, group = GRP_STATE, tooltip = "When the absolute velocity falls below this value the state returns to neutral. Keep it below the entry velocity; the gap between the two is the hysteresis that prevents flicker.")
bool  useNeutral = input.bool(true, "Allow Neutral State", group = GRP_STATE, tooltip = "When off, the state only flips between up and down.")
float shockZ     = input.float(2.5, "Shock Threshold", minval = 1.0, maxval = 6.0, step = 0.25, group = GRP_STATE, tooltip = "A shock marker prints when the price lands this many predicted standard deviations away from the filter's forecast.")
bool  showShock  = input.bool(true, "Mark Shocks", group = GRP_STATE)
bool  colorBars  = input.bool(false, "Color Bars by State", group = GRP_STATE)

bool   showDash = input.bool(true, "Show Dashboard", group = GRP_DASH)
string dashPos  = input.string("Top Right", "Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = GRP_DASH)

color upCol   = input.color(#26a69a, "Up", group = GRP_STYLE)
color dnCol   = input.color(#ef5350, "Down", group = GRP_STYLE)
color neutCol = input.color(#787b86, "Neutral", group = GRP_STYLE)

//------------------------------------------------------------------------------
// Two-state (position + velocity) Kalman filter, scalar form
//------------------------------------------------------------------------------
float atr  = ta.atr(atrLen)
float unit = math.max(nz(atr, high - low), syminfo.mintick)
float R    = math.pow(unit * measMult, 2)
float qP   = math.pow(unit * posMult, 2)
float qV   = math.pow(unit * velMult, 2)

var float xP  = na
var float xV  = 0.0
var float p00 = 0.0
var float p01 = 0.0
var float p10 = 0.0
var float p11 = 0.0

float innov  = 0.0
float innovS = R
float gain   = 0.0

if na(xP)
    if not na(src)
        xP  := src
        p00 := R
        p11 := qV * 100
else if not na(src)
    // Predict: position advances by velocity, velocity persists.
    float pP  = xP + xV
    float a00 = p00 + p01 + p10 + p11 + qP
    float a01 = p01 + p11
    float a10 = p10 + p11
    float a11 = p11 + qV
    // Update with the new price.
    innov  := src - pP
    innovS := a00 + R
    float k0 = a00 / innovS
    float k1 = a10 / innovS
    xP   := pP + k0 * innov
    xV   := xV + k1 * innov
    p00  := (1 - k0) * a00
    p01  := (1 - k0) * a01
    p10  := a10 - k1 * a00
    p11  := a11 - k1 * a01
    gain := k0

float innovSd = math.sqrt(math.max(innovS, 0.0))
float innovZ  = innovSd > 0 ? innov / innovSd : 0.0
float velN    = xV / unit
float estSd   = math.sqrt(math.max(p00, 0.0))
float envUp   = xP + envMult * estSd
float envDn   = xP - envMult * estSd

//------------------------------------------------------------------------------
// Trend state with hysteresis
//------------------------------------------------------------------------------
var int trend = 0
if velN > enterThr
    trend := 1
else if velN < -enterThr
    trend := -1
else if useNeutral and math.abs(velN) < exitThr
    trend := 0

bool warm = bar_index > atrLen * 3

// BUY and SELL strictly alternate: a pass through neutral does not repeat the last signal.
var int lastSig = 0
bool turnUp = warm and barstate.isconfirmed and trend == 1 and lastSig != 1
bool turnDn = warm and barstate.isconfirmed and trend == -1 and lastSig != -1
if turnUp
    lastSig := 1
if turnDn
    lastSig := -1
bool shockU = warm and barstate.isconfirmed and innovZ >= shockZ
bool shockD = warm and barstate.isconfirmed and innovZ <= -shockZ

//------------------------------------------------------------------------------
// Visuals
//------------------------------------------------------------------------------
color stCol = trend == 1 ? upCol : trend == -1 ? dnCol : neutCol

plot(xP, "Kalman Estimate", color = stCol, linewidth = 2)
pUp = plot(warm ? envUp : na, "Envelope Upper", color = color.new(stCol, 75))
pDn = plot(warm ? envDn : na, "Envelope Lower", color = color.new(stCol, 75))
fill(pUp, pDn, color = color.new(stCol, 93), title = "Envelope Fill")

plotshape(turnUp, "Buy", shape.labelup, location.belowbar, color = upCol, text = "BUY", textcolor = color.white, size = size.small)
plotshape(turnDn, "Sell", shape.labeldown, location.abovebar, color = dnCol, text = "SELL", textcolor = color.white, size = size.small)
plotshape(showShock and shockU, "Upside Shock", shape.diamond, location.abovebar, color = color.new(upCol, 30), size = size.tiny)
plotshape(showShock and shockD, "Downside Shock", shape.diamond, location.belowbar, color = color.new(dnCol, 30), size = size.tiny)
barcolor(colorBars ? color.new(stCol, 20) : na, title = "State Bar Color")

plot(velN, "Velocity (ATR per bar)", display = display.data_window)
plot(innovZ, "Innovation Z", display = display.data_window)
plot(gain, "Kalman Gain", display = display.data_window)
plot(trend, "Trend State", display = display.data_window)

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
f_pos(string p) =>
    switch p
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        => position.bottom_left

var table dash = table.new(f_pos(dashPos), 2, 4, bgcolor = color.new(#131722, 15), border_color = color.new(neutCol, 70), border_width = 1)

f_row(int r, string k, string v, color c) =>
    table.cell(dash, 0, r, k, text_color = color.new(color.white, 30), text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, r, v, text_color = c, text_size = size.small, text_halign = text.align_right)

if showDash and barstate.islast
    f_row(0, "State", trend == 1 ? "Up" : trend == -1 ? "Down" : "Neutral", stCol)
    f_row(1, "Velocity", str.tostring(velN, "#.000") + " ATR/bar", velN >= 0 ? upCol : dnCol)
    f_row(2, "Innovation", str.tostring(innovZ, "#.00") + " sd", math.abs(innovZ) >= shockZ ? color.orange : color.white)
    f_row(3, "Gain", str.tostring(gain, "#.000"), color.white)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(turnUp, "Buy Signal", "Kalman Velocity: BUY signal on {{ticker}} ({{interval}})")
alertcondition(turnDn, "Sell Signal", "Kalman Velocity: SELL signal on {{ticker}} ({{interval}})")
alertcondition(shockU or shockD, "Price Shock", "Kalman Velocity: price shock versus forecast on {{ticker}} ({{interval}})")
````
