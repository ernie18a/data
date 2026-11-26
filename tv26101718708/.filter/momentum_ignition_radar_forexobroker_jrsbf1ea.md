# Momentum Ignition Radar [forexobroker]

- url: https://www.tradingview.com/script/jrsBf1Ea-Momentum-Ignition-Radar-forexobroker/
- type: indicator
- pine_id: PUB;1ea2a87a461447f98d77d003da78b2a4
- version: 1.0

## Description

Momentum Ignition Radar detects "ignition events" -- bars where four independent conditions line up simultaneously to produce an explosive directional move. A volume spike, a range expansion, a close at the very edge of the bar, and a compressed prior window all combine into a single 0-100 Ignition Score. When the score breaches the threshold, the bar is classified as BUILDING, STRONG, EXPLOSIVE, or NUCLEAR, and a directional signal fires.

This indicator is designed for momentum traders who want to catch breakouts at their earliest high-conviction bar rather than chasing them several bars later. By scoring four compound factors instead of relying on a single condition, it filters out average breakouts and highlights only the bars where all the ingredients for a sustained move are present.

🔶 CONCEPTS

Sustained momentum moves rarely begin with a random wide bar. They almost always begin with a specific structural signature: the market has been quiet (prior compression), volume suddenly floods in, the range dilates well beyond recent norms, and the bar closes decisively at one of its extremes rather than in the middle. Each of these alone is a weak signal; together they form an ignition. Scoring them additively produces a robust filter that rewards the combination rather than any single ingredient.

🔶 HOW IT WORKS

- Calculates four components, each scored 0-25: Volume Spike, Range Expansion, Close Extreme, Prior Compression
- Sums them into a 0-100 Ignition Score and assigns a grade (BUILDING/STRONG/EXPLOSIVE/NUCLEAR)
- Fires BUY when score >= threshold on a bullish close; SELL when score >= threshold on a bearish close
- Cooldown prevents repeated signals within a user-defined window
- Optional radar-sweep background tints the entire ignition bar

🔶 HOW TO USE

1. Add the indicator -- the ignition dashboard (top-right) updates every bar with current component scores
2. Watch the Ignition Score: BUILDING (40+) shows conditions assembling, EXPLOSIVE (75+) is the prime entry zone
3. Green BUY triangles with "IGNITE ↑" label fire on bullish ignitions; pink SELL triangles on bearish ones
4. The radar-sweep background tints the ignition bar so you can scan history quickly for prior setups
5. Raise the Ignition Score Threshold for only NUCLEAR-grade entries; lower it for more frequent signals on faster timeframes

🔶 FEATURES

- Non-repainting signals (barstate.isconfirmed)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- Four-component additive scoring system with live breakdown
- Ignition grade classifier (BUILDING / STRONG / EXPLOSIVE / NUCLEAR)

🔶 SETTINGS GUIDE

- Volume SMA Length -- Baseline for volume spike detection
- ATR Length -- Volatility reference for range expansion and compression measurement
- Volume Spike Multiplier -- Volume must exceed this multiple of SMA to earn full volume score
- Range Expansion Multiplier -- Bar range must exceed this multiple of ATR for full range score
- Close Extreme Threshold -- How close (as fraction of bar range) the close must be to the top/bottom extreme
- Prior Compression Bars -- Number of bars whose average range is checked for prior quietness
- Compression Ratio -- Prior average range must be below this fraction of ATR to earn full compression score
- Ignition Score Threshold -- Minimum 0-100 composite score to trigger signal
- Signal Cooldown Bars -- Minimum bars between consecutive signals

🔶 ALERTS

- MIR Buy Ignition -- Bullish ignition event confirmed
- MIR Sell Ignition -- Bearish ignition event confirmed
- MIR Any Signal -- Any directional ignition
- MIR Nuclear -- Ignition score reaches 90+
- MIR Volume Spike -- Volume exceeds spike multiplier
- MIR Range Expansion -- Range exceeds expansion multiplier
- MIR Compression -- Prior-bar compression detected
- MIR Any Ignition Bar -- Ignition bar detected (before direction filter)
- MIR Webhook JSON -- Generic webhook payload for external automation

🔶 LIMITATIONS & DISCLAIMER

- This is a technical analysis tool, not financial advice. Always use proper risk management.
- Past ignition events do not guarantee future price movements.
- Signals fire on bar close; acting on unconfirmed live bars will introduce repaint risk.
- The Ignition Score is an additive heuristic over four structural factors, not a statistically calibrated probability of a profitable outcome.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Momentum Ignition Radar [forexobroker]", shorttitle="MIR [fob]", overlay=true, max_labels_count=500, max_boxes_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_ign    = "Ignition Settings"
string g_signal = "Signal Settings"
string g_visual = "Visual Settings"

int    i_volLen       = input.int(20, "Volume SMA Length", minval=5, maxval=100, group=g_ign, tooltip="Baseline for volume spike detection")
int    i_atrLen       = input.int(14, "ATR Length", minval=5, maxval=50, group=g_ign)
float  i_volSpikeMult = input.float(2.0, "Volume Spike Multiplier", minval=1.2, maxval=5.0, step=0.1, group=g_ign, tooltip="Volume must be this multiple of SMA to be a spike")
float  i_rangeMult    = input.float(1.5, "Range Expansion Multiplier", minval=1.0, maxval=3.0, step=0.1, group=g_ign, tooltip="Range must be this multiple of ATR")
float  i_closeExtreme = input.float(0.2, "Close Extreme Threshold", minval=0.05, maxval=0.4, step=0.05, group=g_ign, tooltip="Close must be within this fraction of top/bottom of bar")
int    i_compressLen  = input.int(3, "Prior Compression Bars", minval=2, maxval=8, group=g_ign, tooltip="Prior N bars average range must be compressed")
float  i_compressRatio = input.float(0.8, "Compression Ratio", minval=0.3, maxval=1.0, step=0.05, group=g_ign, tooltip="Prior range avg must be below this fraction of ATR")
int    i_ignThresh    = input.int(70, "Ignition Score Threshold", minval=50, maxval=95, group=g_signal, tooltip="Minimum 0-100 ignition score for signal")
int    i_cooldown     = input.int(10, "Signal Cooldown Bars", minval=3, maxval=50, group=g_signal)
bool   i_showTable    = input.bool(true, "Show Ignition Dashboard", group=g_visual)
bool   i_showRadar    = input.bool(true, "Show Radar Sweep BG", group=g_visual)
bool   i_showGlow     = input.bool(true, "Show 3-Layer Signal Glow", group=g_visual)
color  i_buyColor     = input.color(#39ff14, "Buy Color", group=g_visual)
color  i_sellColor    = input.color(#ff2d78, "Sell Color", group=g_visual)

// ─── COLORS ────────────────────────────────────────────────────────────────────
color c_cyan   = #00d4ff
color c_pink   = #ff2d78
color c_green  = #39ff14
color c_purple = #a855f7
color c_gold   = #ffaa00

// ─── CALCULATIONS ──────────────────────────────────────────────────────────────
float atrVal = ta.atr(i_atrLen)
float volSma = ta.sma(volume, i_volLen)
float barRange = high - low
float priorRangeAvg = ta.sma(high - low, i_compressLen)[1]
bool  isBullish = close > open

// ─── IGNITION SCORING (4 components, each 0-25 = total 0-100) ─────────────────
// 1. Volume spike
float volRatio = volSma > 0 ? volume / volSma : 0.0
float s_vol = math.min(volRatio / i_volSpikeMult * 25.0, 25.0)

// 2. Range expansion
float rangeRatio = atrVal > 0 ? barRange / atrVal : 0.0
float s_range = math.min(rangeRatio / i_rangeMult * 25.0, 25.0)

// 3. Close at extreme (bullish=top, bearish=bottom)
float closePos = barRange > 0 ? (close - low) / barRange : 0.5
float s_close = isBullish ? math.min((closePos - (1.0 - i_closeExtreme)) / i_closeExtreme * 25.0, 25.0) : math.min((i_closeExtreme - closePos) / i_closeExtreme * 25.0, 25.0)
s_close := math.max(s_close, 0.0)

// 4. Prior compression
float compRatio = atrVal > 0 and not na(priorRangeAvg) ? priorRangeAvg / atrVal : 1.0
float s_comp = math.min((i_compressRatio - compRatio) / i_compressRatio * 25.0, 25.0)
s_comp := math.max(s_comp, 0.0)

float ignitionScore = math.round(s_vol + s_range + s_close + s_comp)
bool  isIgnition = ignitionScore >= i_ignThresh

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed

bool rawBuy  = isIgnition and isBullish and cooldownOk and confirmed
bool rawSell = isIgnition and not isBullish and cooldownOk and confirmed

bool buySignal  = rawBuy and not rawSell
bool sellSignal = rawSell and not rawBuy

if buySignal or sellSignal
    lastSignalBar := bar_index

// ─── STATS ─────────────────────────────────────────────────────────────────────
var int totalIgnitions = 0
var int bullIgnitions  = 0
var int bearIgnitions  = 0
if buySignal
    totalIgnitions := totalIgnitions + 1
    bullIgnitions := bullIgnitions + 1
if sellSignal
    totalIgnitions := totalIgnitions + 1
    bearIgnitions := bearIgnitions + 1

// ─── GRADE ─────────────────────────────────────────────────────────────────────
string ignGrade = ignitionScore >= 90 ? "NUCLEAR" : ignitionScore >= 75 ? "EXPLOSIVE" : ignitionScore >= 60 ? "STRONG" : ignitionScore >= 40 ? "BUILDING" : "WEAK"
color  gradeCol = ignitionScore >= 90 ? c_gold : ignitionScore >= 75 ? c_green : ignitionScore >= 60 ? c_cyan : ignitionScore >= 40 ? c_purple : color.gray

// ─── VISUAL: Radar Sweep Background ───────────────────────────────────────────
color bgCol = i_showRadar and isIgnition ? color.new(isBullish ? i_buyColor : i_sellColor, 88) : na
bgcolor(bgCol)

// ─── VISUAL: 3-Layer Glow Signal Arrows (rocket style) ────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="IGNITE ↑",  textcolor=color.white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="IGNITE ↓", textcolor=color.white)

// ─── VISUAL: Ignition Score Label on Signal Bars ──────────────────────────────
if buySignal
    label.new(bar_index, low - atrVal * 1.5, "IGN: " + str.tostring(ignitionScore) + "/100\n" + ignGrade + "\nVOL " + str.tostring(math.round(volRatio, 1)) + "x", style=label.style_label_up, color=color.new(i_buyColor, 15), textcolor=color.white, size=size.small)
if sellSignal
    label.new(bar_index, high + atrVal * 1.5, "IGN: " + str.tostring(ignitionScore) + "/100\n" + ignGrade + "\nVOL " + str.tostring(math.round(volRatio, 1)) + "x", style=label.style_label_down, color=color.new(i_sellColor, 15), textcolor=color.white, size=size.small)

// ─── VISUAL: Bar Color ─────────────────────────────────────────────────────────
barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)

// ─── VISUAL: Ignition Dashboard ────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 10, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    table.cell(dash, 0, 0, "Momentum Ignition Radar", text_color=c_cyan, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "", text_color=color.white)
    table.cell(dash, 0, 1, "Ignition Score", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(ignitionScore) + "/100", text_color=gradeCol, text_size=size.small)
    table.cell(dash, 0, 2, "Grade", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, ignGrade, text_color=gradeCol, text_size=size.small)
    table.cell(dash, 0, 3, "Volume Ratio", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(math.round(volRatio, 2)) + "x", text_color=volRatio >= i_volSpikeMult ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 4, "Range Ratio", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(math.round(rangeRatio, 2)) + "x", text_color=rangeRatio >= i_rangeMult ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 5, "Close Position", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(math.round(closePos * 100)) + "%", text_color=(closePos >= 1.0 - i_closeExtreme or closePos <= i_closeExtreme) ? c_green : color.white, text_size=size.small)
    table.cell(dash, 0, 6, "Prior Compression", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(math.round(compRatio, 2)) + "x", text_color=compRatio <= i_compressRatio ? c_green : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Bull Ignitions", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bullIgnitions), text_color=c_green, text_size=size.small)
    table.cell(dash, 0, 8, "Bear Ignitions", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(bearIgnitions), text_color=c_pink, text_size=size.small)
    table.cell(dash, 0, 9, "Last Signal", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(bar_index - lastSignalBar) + " bars ago", text_color=color.white, text_size=size.small)

// ─── ALERTS (2x alert() with JSON) ─────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"MIR","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"ignition":' + str.tostring(ignitionScore) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"MIR","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"ignition":' + str.tostring(ignitionScore) + '}', alert.freq_once_per_bar_close)

// ─── ALERTCONDITIONS (9x global scope) ─────────────────────────────────────────
alertcondition(buySignal,                  "MIR Buy Ignition",       "Momentum Ignition Radar BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                 "MIR Sell Ignition",      "Momentum Ignition Radar SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,    "MIR Any Signal",         "Any ignition signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(ignitionScore >= 90,        "MIR Nuclear",            "Nuclear ignition score (90+) on {{ticker}} {{interval}}")
alertcondition(volRatio >= i_volSpikeMult, "MIR Volume Spike",       "Volume spike detected on {{ticker}} {{interval}}")
alertcondition(rangeRatio >= i_rangeMult,  "MIR Range Expansion",    "Range expansion on {{ticker}} {{interval}}")
alertcondition(compRatio <= i_compressRatio, "MIR Compression",      "Prior-bar compression detected on {{ticker}} {{interval}}")
alertcondition(isIgnition,                 "MIR Any Ignition Bar",   "Ignition bar detected (pre-direction) on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,    "MIR Webhook JSON",       "{\"action\":\"signal\",\"indicator\":\"MIR\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
