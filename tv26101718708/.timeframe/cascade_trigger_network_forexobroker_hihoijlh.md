# Cascade Trigger Network [forexobroker]

- url: https://www.tradingview.com/script/hIHoIJlh-Cascade-Trigger-Network-forexobroker/
- type: indicator
- pine_id: PUB;9d3a078f67f54fd0a5e69bb029f49a07
- version: 1.0

## Description

Cascade Trigger Network fires only when three linked conditions light up across three timeframes in the correct order: the low timeframe triggers, then the medium timeframe confirms, then the high timeframe is already biased the same way -- all within a configurable window. One level alone is common; the full cascade is rare, and rare setups outperform noisy ones.

Built for multi-timeframe traders who need the LTF entry to be validated by MTF structure and HTF direction before committing capital.

🔶 CONCEPTS

Multi-timeframe alignment is a well-known edge, but most tools simply stack three moving averages from different timeframes and ask "are they all up?" That misses the key idea: direction should flow downward in timeframe -- HTF sets the bias, MTF confirms the swing, LTF fires the trigger. If the LTF trigger fires in isolation it's noise; if it fires while MTF and HTF are already pointing the same way, it's an entry. Adding a time window forces the cascade to complete quickly, rejecting stale triggers that come long after the MTF/HTF setup existed.

🔶 HOW IT WORKS

- LTF trigger: close crosses above/below LTF EMA with RSI supporting (>50 for bull, <50 for bear)
- MTF confirm: MTF close above/below MTF EMA with positive/negative slope
- HTF bias: HTF close above/below HTF EMA with positive/negative slope
- Tracks the last LTF trigger bar and requires it to be within Cascade Window Bars
- All three levels must be aligned simultaneously for the cascade to complete
- Combines level alignment and RSI into a 0-100 Cascade Score
- Classifies state as BROKEN, PARTIAL, LINKED, or CHAINED
- Fires signal on the bar where the full three-level alignment first appears

🔶 HOW TO USE

1. Add the indicator -- background tints when levels are aligning
2. Watch the dashboard (top-right) for live LTF trigger, MTF state, HTF state, and level counts
3. Green BUY triangles with "CASCADE ↑" label fire on completed bullish cascades; pink SELL triangles on bearish
4. The LTF EMA plotted with glow shows where the LTF trigger happens
5. Choose MTF and HTF to match your trading style (e.g. 60/240 for a 15m chart)

🔶 FEATURES

- Non-repainting signals (barstate.isconfirmed, no lookahead in security calls)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- True multi-timeframe cascade logic rather than MA stacking
- Time-windowed trigger so only recent LTF triggers count

🔶 SETTINGS GUIDE

- MTF Timeframe / HTF Timeframe -- Higher timeframes whose state gates the signal
- LTF / MTF / HTF EMA Length -- EMA length used on each timeframe
- LTF RSI Length -- RSI length used on the trading timeframe
- Cascade Window Bars -- Max bars between LTF trigger and cascade completion
- Cascade Score Threshold -- Minimum 0-100 score required at fire
- Signal Cooldown Bars -- Minimum bars between consecutive signals

🔶 ALERTS

- CTN Buy Cascade -- Full bullish cascade completed
- CTN Sell Cascade -- Full bearish cascade completed
- CTN Any Signal -- Any cascade signal
- CTN Chained -- Cascade score reaches 85+
- CTN LTF Bull Trigger -- Low-timeframe bullish trigger (informational)
- CTN LTF Bear Trigger -- Low-timeframe bearish trigger (informational)
- CTN Higher-TF Bull -- MTF and HTF both bullish
- CTN Higher-TF Bear -- MTF and HTF both bearish
- CTN Webhook JSON -- Generic webhook payload for external automation

🔶 LIMITATIONS & DISCLAIMER

- This is a technical analysis tool, not financial advice. Always use proper risk management.
- request.security introduces standard one-bar MTF/HTF delay; expected and non-repainting.
- If HTF is already opposed, cascades on the trading timeframe will be rare by design.
- The Cascade Score is a composite heuristic, not a calibrated probability.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Cascade Trigger Network [forexobroker]", shorttitle="CTN [fob]", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_cascade = "Cascade Settings"
string g_signal  = "Signal Settings"
string g_visual  = "Visual Settings"

string i_mtfRes   = input.timeframe("60",  "MTF Timeframe", group=g_cascade)
string i_htfRes   = input.timeframe("240", "HTF Timeframe", group=g_cascade)
int    i_ltfEma   = input.int(20, "LTF EMA Length", minval=5, maxval=100, group=g_cascade)
int    i_mtfEma   = input.int(20, "MTF EMA Length", minval=5, maxval=100, group=g_cascade)
int    i_htfEma   = input.int(20, "HTF EMA Length", minval=5, maxval=100, group=g_cascade)
int    i_rsiLen   = input.int(14, "LTF RSI Length", minval=3, maxval=50, group=g_cascade)
int    i_window   = input.int(6,  "Cascade Window Bars", minval=2, maxval=20, group=g_cascade, tooltip="Max bars between LTF trigger and final fire")
int    i_scoreThr = input.int(70, "Cascade Score Threshold", minval=40, maxval=95, group=g_signal)
int    i_cooldown = input.int(15, "Signal Cooldown Bars", minval=3, maxval=50, group=g_signal)
bool   i_showTable = input.bool(true, "Show Cascade Dashboard", group=g_visual)
bool   i_showBg    = input.bool(true, "Show Cascade Background", group=g_visual)
bool   i_showGlow  = input.bool(true, "Show 3-Layer Signal Glow", group=g_visual)
bool   i_showEma   = input.bool(true, "Show LTF EMA Glow", group=g_visual)
color  i_buyColor  = input.color(#39ff14, "Buy Color", group=g_visual)
color  i_sellColor = input.color(#ff2d78, "Sell Color", group=g_visual)

// ─── COLORS ────────────────────────────────────────────────────────────────────
color c_cyan   = #00d4ff
color c_pink   = #ff2d78
color c_green  = #39ff14
color c_purple = #a855f7
color c_gold   = #ffaa00

// ─── CALCULATIONS ──────────────────────────────────────────────────────────────
float ltfEma = ta.ema(close, i_ltfEma)
float ltfSlope = ta.change(ltfEma, 3)
float ltfRsi = ta.rsi(close, i_rsiLen)
bool ltfBullTrig = ta.crossover(close, ltfEma)  and ltfRsi > 50
bool ltfBearTrig = ta.crossunder(close, ltfEma) and ltfRsi < 50

float mtfClose = request.security(syminfo.tickerid, i_mtfRes, close, lookahead=barmerge.lookahead_off)
float mtfEma   = request.security(syminfo.tickerid, i_mtfRes, ta.ema(close, i_mtfEma), lookahead=barmerge.lookahead_off)
float mtfEmaSl = request.security(syminfo.tickerid, i_mtfRes, ta.change(ta.ema(close, i_mtfEma), 3), lookahead=barmerge.lookahead_off)

float htfClose = request.security(syminfo.tickerid, i_htfRes, close, lookahead=barmerge.lookahead_off)
float htfEma   = request.security(syminfo.tickerid, i_htfRes, ta.ema(close, i_htfEma), lookahead=barmerge.lookahead_off)
float htfEmaSl = request.security(syminfo.tickerid, i_htfRes, ta.change(ta.ema(close, i_htfEma), 3), lookahead=barmerge.lookahead_off)

bool mtfBull = mtfClose > mtfEma and mtfEmaSl > 0
bool mtfBear = mtfClose < mtfEma and mtfEmaSl < 0
bool htfBull = htfClose > htfEma and htfEmaSl > 0
bool htfBear = htfClose < htfEma and htfEmaSl < 0

// Track last LTF trigger bar
var int lastLtfBullBar = na
var int lastLtfBearBar = na
if ltfBullTrig
    lastLtfBullBar := bar_index
if ltfBearTrig
    lastLtfBearBar := bar_index

bool ltfBullRecent = not na(lastLtfBullBar) and (bar_index - lastLtfBullBar) <= i_window
bool ltfBearRecent = not na(lastLtfBearBar) and (bar_index - lastLtfBearBar) <= i_window

// Cascade completion: LTF trigger + MTF confirm + HTF bias all aligned within window
bool cascadeBull = ltfBullRecent and mtfBull and htfBull
bool cascadeBear = ltfBearRecent and mtfBear and htfBear

// ─── CASCADE SCORING (0-100) ──────────────────────────────────────────────────
int levelsBull = (ltfBullRecent ? 1 : 0) + (mtfBull ? 1 : 0) + (htfBull ? 1 : 0)
int levelsBear = (ltfBearRecent ? 1 : 0) + (mtfBear ? 1 : 0) + (htfBear ? 1 : 0)
int maxLevels = math.max(levelsBull, levelsBear)
float sLevels = maxLevels * 30.0
float sRsi    = maxLevels >= 3 and (ltfRsi > 55 or ltfRsi < 45) ? 10.0 : 0.0
float cascadeScore = math.round(math.min(sLevels + sRsi, 100.0))

string cascadeState = cascadeScore >= 85 ? "CHAINED" : cascadeScore >= 70 ? "LINKED" : cascadeScore >= 50 ? "PARTIAL" : "BROKEN"
color  stateCol = cascadeScore >= 85 ? c_gold : cascadeScore >= 70 ? c_green : cascadeScore >= 50 ? c_cyan : color.gray

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool scoreOk    = cascadeScore >= i_scoreThr

// Fire on the bar where cascade first completes
bool cascadeFreshBull = cascadeBull and not cascadeBull[1]
bool cascadeFreshBear = cascadeBear and not cascadeBear[1]

bool rawBuy  = cascadeFreshBull and scoreOk and cooldownOk and confirmed
bool rawSell = cascadeFreshBear and scoreOk and cooldownOk and confirmed
bool buySignal  = rawBuy and not rawSell
bool sellSignal = rawSell and not rawBuy

if buySignal or sellSignal
    lastSignalBar := bar_index

// ─── VISUAL: Cascade Background Gradient ──────────────────────────────────────
color casBg = na
if i_showBg
    if cascadeScore >= 85
        casBg := color.new(cascadeBull ? i_buyColor : cascadeBear ? i_sellColor : c_gold, 90)
    else if cascadeScore >= 70
        casBg := color.new(cascadeBull ? i_buyColor : cascadeBear ? i_sellColor : c_cyan, 94)
    else if cascadeScore >= 50
        casBg := color.new(c_purple, 96)
bgcolor(casBg)

// ─── VISUAL: LTF EMA with 3-Layer Glow ────────────────────────────────────────
plot(i_showEma ? ltfEma : na, "EMA Glow 1", color=color.new(c_cyan, 70), linewidth=5)
plot(i_showEma ? ltfEma : na, "EMA Glow 2", color=color.new(c_cyan, 40), linewidth=3)
plot(i_showEma ? ltfEma : na, "EMA Core",   color=color.new(c_cyan, 0),  linewidth=1)

// ─── VISUAL: 3-Layer Glow Signal Arrows ───────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="CASCADE ↑",  textcolor=color.white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="CASCADE ↓", textcolor=color.white)

// ─── VISUAL: Cascade Context Label ────────────────────────────────────────────
float atrVal = ta.atr(14)
if buySignal
    label.new(bar_index, low - atrVal * 1.5, "CASCADE ↑\nScore: " + str.tostring(cascadeScore) + "/100\nLevels: " + str.tostring(levelsBull) + "/3", style=label.style_label_up, color=color.new(i_buyColor, 15), textcolor=color.white, size=size.small)
if sellSignal
    label.new(bar_index, high + atrVal * 1.5, "CASCADE ↓\nScore: " + str.tostring(cascadeScore) + "/100\nLevels: " + str.tostring(levelsBear) + "/3", style=label.style_label_down, color=color.new(i_sellColor, 15), textcolor=color.white, size=size.small)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)

// ─── VISUAL: Cascade Dashboard ────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    table.cell(dash, 0, 0, "Cascade Trigger Network", text_color=c_cyan, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "", text_color=color.white)
    table.cell(dash, 0, 1, "Cascade Score", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(cascadeScore) + "/100", text_color=stateCol, text_size=size.small)
    table.cell(dash, 0, 2, "State", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, cascadeState, text_color=stateCol, text_size=size.small)
    table.cell(dash, 0, 3, "LTF Trigger", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, ltfBullRecent ? "BULL (fresh)" : ltfBearRecent ? "BEAR (fresh)" : "-", text_color=ltfBullRecent ? c_green : ltfBearRecent ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 4, "MTF (" + i_mtfRes + ")", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, mtfBull ? "BULL" : mtfBear ? "BEAR" : "NEUTRAL", text_color=mtfBull ? c_green : mtfBear ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 5, "HTF (" + i_htfRes + ")", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, htfBull ? "BULL" : htfBear ? "BEAR" : "NEUTRAL", text_color=htfBull ? c_green : htfBear ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 6, "LTF RSI", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(math.round(ltfRsi, 1)), text_color=ltfRsi > 55 ? c_green : ltfRsi < 45 ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 7, "Bull / Bear Lvls", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(levelsBull) + " / " + str.tostring(levelsBear), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 8, "Last Signal", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(bar_index - lastSignalBar) + " bars ago", text_color=color.white, text_size=size.small)

// ─── ALERTS (2x alert() with JSON) ─────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"CTN","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"cascade":' + str.tostring(cascadeScore) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"CTN","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"cascade":' + str.tostring(cascadeScore) + '}', alert.freq_once_per_bar_close)

// ─── ALERTCONDITIONS (9x global scope) ─────────────────────────────────────────
alertcondition(buySignal,                         "CTN Buy Cascade",      "Cascade BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                        "CTN Sell Cascade",     "Cascade SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,           "CTN Any Signal",       "Any cascade signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(cascadeScore >= 85,                "CTN Chained",          "Cascade score 85+ on {{ticker}} {{interval}}")
alertcondition(ltfBullTrig,                       "CTN LTF Bull Trigger", "LTF bullish trigger on {{ticker}} {{interval}}")
alertcondition(ltfBearTrig,                       "CTN LTF Bear Trigger", "LTF bearish trigger on {{ticker}} {{interval}}")
alertcondition(mtfBull and htfBull,               "CTN Higher-TF Bull",   "MTF and HTF both bullish on {{ticker}} {{interval}}")
alertcondition(mtfBear and htfBear,               "CTN Higher-TF Bear",   "MTF and HTF both bearish on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,           "CTN Webhook JSON",     "{\"action\":\"signal\",\"indicator\":\"CTN\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
