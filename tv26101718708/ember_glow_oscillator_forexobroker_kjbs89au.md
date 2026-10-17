# Ember Glow Oscillator [forexobroker]

- url: https://www.tradingview.com/script/KJBS89au-Ember-Glow-Oscillator-forexobroker/
- type: indicator
- pine_id: PUB;4d7237a954684be29ad8a987b367a970
- version: 1.0

## Description

Ember Glow Oscillator accumulates volume on small-range bars only -- the slow, quiet bars where accumulation or distribution tends to hide -- and signs it by candle direction. When the accumulated "ember" is strongly positive or negative and an ignition candle (large-range, directional) finally prints, the ember's direction has burst into flame.

Built for traders who want to catch moves born from stealth accumulation rather than chasing already-visible trends.

🔶 CONCEPTS

Large, obvious candles attract everyone's attention, but the real positioning often happens on small, boring bars that nobody pays attention to. If you track which small bars closed up vs down, weight by their volume, and sum over a window, you get a quiet signature of accumulation or distribution that isn't visible on the candles alone. When that hidden ember is strongly positive and an ignition candle finally arrives to release the stored energy, the move usually continues further than expected, because it's backed by the stealth positioning. This oscillator formalizes that "quiet before it catches fire" dynamic.

🔶 HOW IT WORKS

- Classifies each bar as small when its range <= Small Bar Ceiling (ATR multiple)
- Takes signed volume on small bars only: +volume for up-closes, -volume for down-closes, 0 otherwise
- Sums signed volume over the Ember Window to form the ember signal
- Normalizes by total small-bar absolute volume to get an ember ratio between -1 and +1
- Detects ignition candles when current bar range >= Ignition Range (ATR multiple) with directional close
- Combines ember ratio, ignition event, and bias EMA slope into a 0-100 Ember Score
- Classifies state as COLD, SMOLDERING, IGNITED, or BLAZING
- Fires signal when ember ratio and ignition align with bias EMA direction

🔶 HOW TO USE

1. Add the indicator -- background tints green for positive ember, pink for negative, gold when blazing
2. Watch the dashboard (top-right) for live ember ratio, small-bar flag, range/ATR, and ignition state
3. Green BUY triangles with "EMBER ↑" label fire on bullish ignition after positive ember accumulation; pink SELL triangles inverse
4. The Bias EMA plotted with glow filters signals to the macro direction
5. Raise Ignition Range (ATR) for only the most decisive releases; lower it for more frequent signals

🔶 FEATURES

- Non-repainting signals (barstate.isconfirmed)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- Small-bar-only volume accumulation that isolates stealth positioning
- Ignition-candle trigger that times entries to the visible release

🔶 SETTINGS GUIDE

- Ember Window -- Bars accumulated for the slow-burn ember
- ATR Length -- ATR period used for small-bar and ignition thresholds
- Small Bar Ceiling (ATR) -- Range <= this ATR multiple counts as small
- Ignition Range (ATR) -- Bar range required to qualify as ignition
- Bias EMA Length -- Macro EMA used to confirm the ignition direction
- Ember Score Threshold -- Minimum 0-100 score required at fire
- Signal Cooldown Bars -- Minimum bars between consecutive signals

🔶 ALERTS

- EGO Buy Ember -- Bullish ignition with positive ember ratio
- EGO Sell Ember -- Bearish ignition with negative ember ratio
- EGO Any Signal -- Any ember signal
- EGO Blazing -- Ember score reaches 85+
- EGO Positive Ember -- Sustained positive small-bar volume
- EGO Negative Ember -- Sustained negative small-bar volume
- EGO Bull Ignite -- Bullish ignition candle (informational)
- EGO Bear Ignite -- Bearish ignition candle (informational)
- EGO Webhook JSON -- Generic webhook payload for external automation

🔶 LIMITATIONS & DISCLAIMER

- This is a technical analysis tool, not financial advice. Always use proper risk management.
- Volume-based logic is weaker on instruments with unreliable volume.
- Stealth accumulation can persist before ignition; waiting is part of the design.
- The Ember Score is a composite heuristic, not a calibrated probability.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Ember Glow Oscillator [forexobroker]", shorttitle="EGO [fob]", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_ember  = "Ember Settings"
string g_signal = "Signal Settings"
string g_visual = "Visual Settings"

int    i_emberLen   = input.int(30, "Ember Window", minval=10, maxval=200, group=g_ember, tooltip="Bars accumulated for the slow-burn ember")
int    i_atrLen     = input.int(14, "ATR Length", minval=5, maxval=50, group=g_ember)
float  i_smallBarMax = input.float(0.7, "Small Bar Ceiling (ATR)", minval=0.2, maxval=2.0, step=0.05, group=g_ember, tooltip="A bar counts as small if range <= this ATR multiple")
float  i_ignRange   = input.float(1.5, "Ignition Range (ATR)", minval=1.0, maxval=4.0, step=0.1, group=g_ember, tooltip="Current bar range must exceed this ATR multiple to ignite")
int    i_biasLen    = input.int(34, "Bias EMA Length", minval=10, maxval=200, group=g_ember)
int    i_scoreThr   = input.int(70, "Ember Score Threshold", minval=40, maxval=95, group=g_signal)
int    i_cooldown   = input.int(12, "Signal Cooldown Bars", minval=3, maxval=50, group=g_signal)
bool   i_showTable = input.bool(true, "Show Ember Dashboard", group=g_visual)
bool   i_showBg    = input.bool(true, "Show Ember Background", group=g_visual)
bool   i_showGlow  = input.bool(true, "Show 3-Layer Signal Glow", group=g_visual)
bool   i_showEma   = input.bool(true, "Show Bias EMA Glow", group=g_visual)
color  i_buyColor  = input.color(#39ff14, "Buy Color", group=g_visual)
color  i_sellColor = input.color(#ff2d78, "Sell Color", group=g_visual)

// ─── COLORS ────────────────────────────────────────────────────────────────────
color c_cyan   = #00d4ff
color c_pink   = #ff2d78
color c_green  = #39ff14
color c_purple = #a855f7
color c_gold   = #ffaa00

// ─── CALCULATIONS ──────────────────────────────────────────────────────────────
float atrVal = ta.atr(i_atrLen)
float barRange = high - low
bool smallBar  = barRange <= atrVal * i_smallBarMax

// Signed volume: positive on up-close small bars, negative on down-close small bars
float signedVol = smallBar ? (close > open ? volume : close < open ? -volume : 0.0) : 0.0
float emberSum  = math.sum(signedVol, i_emberLen)

// Total small-bar volume in window (for normalization)
float absSmallVol = smallBar ? volume : 0.0
float emberAbs = math.sum(absSmallVol, i_emberLen)
float emberRatio = emberAbs > 0 ? emberSum / emberAbs : 0.0

// Ignition candle: large range bar with directional close
bool ignitionBar = barRange >= atrVal * i_ignRange
bool bullIgnite = ignitionBar and close > open and close > close[1]
bool bearIgnite = ignitionBar and close < open and close < close[1]

float biasEma = ta.ema(close, i_biasLen)
float emaSlope = ta.change(biasEma, 3)

// ─── EMBER SCORING (0-100) ────────────────────────────────────────────────────
float sRatio = math.min(math.abs(emberRatio) * 70.0, 40.0)
float sIgnite = (bullIgnite or bearIgnite) ? 35.0 : 0.0
float sBias   = math.abs(emaSlope) / (atrVal + 0.00001)
sBias := math.min(sBias * 25.0, 25.0)
float egoScore = math.round(math.min(sRatio + sIgnite + sBias, 100.0))

string egoState = egoScore >= 85 ? "BLAZING" : egoScore >= 70 ? "IGNITED" : egoScore >= 50 ? "SMOLDERING" : "COLD"
color  stateCol = egoScore >= 85 ? c_gold : egoScore >= 70 ? c_green : egoScore >= 50 ? c_cyan : color.gray

// ─── DIRECTIONAL BIAS ──────────────────────────────────────────────────────────
bool bullBias = emberRatio > 0 and bullIgnite and close > biasEma and emaSlope > 0
bool bearBias = emberRatio < 0 and bearIgnite and close < biasEma and emaSlope < 0

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool scoreOk    = egoScore >= i_scoreThr

bool rawBuy  = bullBias and scoreOk and cooldownOk and confirmed
bool rawSell = bearBias and scoreOk and cooldownOk and confirmed
bool buySignal  = rawBuy and not rawSell
bool sellSignal = rawSell and not rawBuy

if buySignal or sellSignal
    lastSignalBar := bar_index

// ─── VISUAL: Ember Background Gradient ────────────────────────────────────────
color egoBg = na
if i_showBg
    if egoScore >= 85
        egoBg := color.new(bullBias ? i_buyColor : bearBias ? i_sellColor : c_gold, 90)
    else if egoScore >= 70
        egoBg := color.new(bullBias ? i_buyColor : bearBias ? i_sellColor : c_cyan, 94)
    else if egoScore >= 50
        egoBg := color.new(emberRatio > 0 ? c_green : c_pink, 96)
bgcolor(egoBg)

// ─── VISUAL: Bias EMA with 3-Layer Glow ───────────────────────────────────────
plot(i_showEma ? biasEma : na, "EMA Glow 1", color=color.new(c_purple, 70), linewidth=5)
plot(i_showEma ? biasEma : na, "EMA Glow 2", color=color.new(c_purple, 40), linewidth=3)
plot(i_showEma ? biasEma : na, "EMA Core",   color=color.new(c_purple, 0),  linewidth=1)

// ─── VISUAL: 3-Layer Glow Signal Arrows ───────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="EMBER ↑",  textcolor=color.white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="EMBER ↓", textcolor=color.white)

// ─── VISUAL: Ember Context Label ──────────────────────────────────────────────
if buySignal
    label.new(bar_index, low - atrVal * 1.5, "IGNITE ↑\nScore: " + str.tostring(egoScore) + "/100\nRatio: " + str.tostring(math.round(emberRatio, 2)), style=label.style_label_up, color=color.new(i_buyColor, 15), textcolor=color.white, size=size.small)
if sellSignal
    label.new(bar_index, high + atrVal * 1.5, "IGNITE ↓\nScore: " + str.tostring(egoScore) + "/100\nRatio: " + str.tostring(math.round(emberRatio, 2)), style=label.style_label_down, color=color.new(i_sellColor, 15), textcolor=color.white, size=size.small)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)

// ─── VISUAL: Ember Dashboard ──────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    table.cell(dash, 0, 0, "Ember Glow Oscillator", text_color=c_cyan, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "", text_color=color.white)
    table.cell(dash, 0, 1, "Ember Score", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(egoScore) + "/100", text_color=stateCol, text_size=size.small)
    table.cell(dash, 0, 2, "State", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, egoState, text_color=stateCol, text_size=size.small)
    table.cell(dash, 0, 3, "Ember Ratio", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(math.round(emberRatio, 2)), text_color=emberRatio > 0.2 ? c_green : emberRatio < -0.2 ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 4, "Small Bar", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, smallBar ? "YES" : "NO", text_color=smallBar ? c_cyan : color.white, text_size=size.small)
    table.cell(dash, 0, 5, "Range / ATR", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(math.round(barRange / atrVal, 2)) + "x", text_color=barRange / atrVal >= i_ignRange ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 6, "Ignition", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, bullIgnite ? "BULL" : bearIgnite ? "BEAR" : "-", text_color=bullIgnite ? c_green : bearIgnite ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 7, "EMA Slope", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(math.round(emaSlope, 3)), text_color=emaSlope > 0 ? c_green : c_pink, text_size=size.small)
    table.cell(dash, 0, 8, "Last Signal", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(bar_index - lastSignalBar) + " bars ago", text_color=color.white, text_size=size.small)

// ─── ALERTS (2x alert() with JSON) ─────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"EGO","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"ember":' + str.tostring(egoScore) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"EGO","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"ember":' + str.tostring(egoScore) + '}', alert.freq_once_per_bar_close)

// ─── ALERTCONDITIONS (9x global scope) ─────────────────────────────────────────
alertcondition(buySignal,                         "EGO Buy Ember",        "Ember BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                        "EGO Sell Ember",       "Ember SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,           "EGO Any Signal",       "Any ember signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(egoScore >= 85,                    "EGO Blazing",          "Ember score 85+ on {{ticker}} {{interval}}")
alertcondition(emberRatio > 0.3,                  "EGO Positive Ember",   "Sustained positive small-bar volume on {{ticker}} {{interval}}")
alertcondition(emberRatio < -0.3,                 "EGO Negative Ember",   "Sustained negative small-bar volume on {{ticker}} {{interval}}")
alertcondition(bullIgnite,                        "EGO Bull Ignite",      "Bullish ignition candle on {{ticker}} {{interval}}")
alertcondition(bearIgnite,                        "EGO Bear Ignite",      "Bearish ignition candle on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,           "EGO Webhook JSON",     "{\"action\":\"signal\",\"indicator\":\"EGO\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
