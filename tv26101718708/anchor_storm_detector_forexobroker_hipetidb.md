# Anchor Storm Detector [forexobroker]

- url: https://www.tradingview.com/script/HiPetIdB-Anchor-Storm-Detector-forexobroker/
- type: indicator
- pine_id: PUB;a5764f358899431b86eadb193d89e163
- version: 1.0

## Description

Anchor Storm Detector plots three anchored VWAPs at once (daily, weekly, monthly) and fires when price breaks two or more of them in the same direction while ATR is expanding. Breaking one anchored VWAP is normal; breaking multiple simultaneously with expanding volatility is an anchor storm.

Built for traders who use anchored VWAPs as structural institutional bias lines and want signals on days when multiple anchors are losing the market at once.

🔶 CONCEPTS

Each anchored VWAP is a proxy for the average cost of participants who entered since that anchor date. Break above the daily VWAP and the day's longs are in profit; break above the weekly and the week's longs join; break above the monthly and the month's longs do too. That cascade of anchor breaks is institutionally meaningful -- it means multiple timeframes of participants are forced to reassess. Combining it with ATR expansion confirms the event isn't happening in sleepy conditions; it is a true storm.

🔶 HOW IT WORKS

- Computes anchored VWAPs at daily, weekly, and monthly anchors using cumulative hlc3 * volume / cumulative volume, resetting at each anchor
- Tracks price position vs each anchor (+1 above, -1 below, 0 at)
- Detects break events when close crosses each anchor by the Break Margin (ATR)
- Counts simultaneous break events in each direction
- Combines break count, ATR expansion, and anchor alignment sum into a 0-100 Storm Score
- Classifies state as ANCHORED, PRESSURING, RIPPING, or STORM
- Fires signal when two or more anchors break in the same direction with ATR expansion and bias EMA agreement

🔶 HOW TO USE

1. Add the indicator -- cyan line is daily VWAP, purple is weekly, gold is monthly, each with glow
2. Watch the dashboard (top-right) for live Storm Score, ATR expansion, each anchor's position, and break counts
3. Green BUY triangles with "ANCHOR ↑" label fire on bullish multi-anchor break storms; pink SELL triangles on bearish
4. Turn individual anchors on/off via the input toggles
5. Tune Break Margin (ATR) and ATR Expansion Ratio to match instrument behavior

🔶 FEATURES

- Non-repainting signals (barstate.isconfirmed)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- Three simultaneous anchored VWAPs (D/W/M) on the same chart
- Multi-anchor break storm logic with ATR-expansion confirmation

🔶 SETTINGS GUIDE

- Daily / Weekly / Monthly Anchored VWAP -- Toggle individual anchors
- ATR Length / ATR Baseline Length -- Short ATR vs longer-baseline ATR for expansion ratio
- ATR Expansion Ratio -- Minimum ATR / baseline ratio required during storm
- Break Margin (ATR) -- ATR fraction needed to confirm each anchor break
- Bias EMA Length -- Macro EMA used to gate the multi-anchor direction
- Storm Score Threshold -- Minimum 0-100 score required at fire
- Signal Cooldown Bars -- Minimum bars between consecutive signals

🔶 ALERTS

- ASD Buy Storm -- Bullish multi-anchor storm confirmed
- ASD Sell Storm -- Bearish multi-anchor storm confirmed
- ASD Any Signal -- Any storm signal
- ASD Storm Peak -- Storm score reaches 85+
- ASD Multi Up Break -- Two or more anchors broken up
- ASD Multi Down Break -- Two or more anchors broken down
- ASD ATR Expansion -- ATR expanded beyond threshold
- ASD Full Bull Stack -- All enabled anchors bullish (price above each)
- ASD Webhook JSON -- Generic webhook payload for external automation

🔶 LIMITATIONS & DISCLAIMER

- This is a technical analysis tool, not financial advice. Always use proper risk management.
- Anchored VWAPs are cumulative from the anchor; very long-running charts can produce numerically large cumulators (precision is still adequate).
- On instruments with synthetic volume, anchored VWAP values may be less meaningful.
- The Storm Score is a composite heuristic, not a calibrated probability.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Anchor Storm Detector [forexobroker]", shorttitle="ASD [fob]", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_anchor = "Anchor Settings"
string g_signal = "Signal Settings"
string g_visual = "Visual Settings"

bool   i_useD     = input.bool(true, "Daily Anchored VWAP", group=g_anchor)
bool   i_useW     = input.bool(true, "Weekly Anchored VWAP", group=g_anchor)
bool   i_useM     = input.bool(true, "Monthly Anchored VWAP", group=g_anchor)
int    i_atrLen   = input.int(14, "ATR Length", minval=5, maxval=50, group=g_anchor)
float  i_atrExp   = input.float(1.25, "ATR Expansion Ratio", minval=1.0, maxval=3.0, step=0.05, group=g_anchor, tooltip="Current ATR / baseline ATR required during storm")
int    i_atrBase  = input.int(50, "ATR Baseline Length", minval=20, maxval=300, group=g_anchor)
float  i_breakAtr = input.float(0.15, "Break Margin (ATR)", minval=0.05, maxval=1.0, step=0.05, group=g_anchor)
int    i_biasLen  = input.int(50, "Bias EMA Length", minval=10, maxval=200, group=g_anchor)
int    i_scoreThr = input.int(70, "Storm Score Threshold", minval=40, maxval=95, group=g_signal)
int    i_cooldown = input.int(15, "Signal Cooldown Bars", minval=3, maxval=50, group=g_signal)
bool   i_showTable = input.bool(true, "Show Anchor Dashboard", group=g_visual)
bool   i_showBg    = input.bool(true, "Show Storm Background", group=g_visual)
bool   i_showGlow  = input.bool(true, "Show 3-Layer Signal Glow", group=g_visual)
bool   i_showVwap  = input.bool(true, "Show Anchored VWAPs", group=g_visual)
color  i_buyColor  = input.color(#39ff14, "Buy Color", group=g_visual)
color  i_sellColor = input.color(#ff2d78, "Sell Color", group=g_visual)

// ─── COLORS ────────────────────────────────────────────────────────────────────
color c_cyan   = #00d4ff
color c_pink   = #ff2d78
color c_green  = #39ff14
color c_purple = #a855f7
color c_gold   = #ffaa00

// ─── CALCULATIONS ──────────────────────────────────────────────────────────────
float atrVal   = ta.atr(i_atrLen)
float atrBase  = ta.sma(atrVal, i_atrBase)
float atrRatio = atrBase > 0 ? atrVal / atrBase : 1.0
float biasEma  = ta.ema(close, i_biasLen)
float emaSlope = ta.change(biasEma, 3)

// Anchored VWAP helper
anchoredVwap(bool anchorBar) =>
    var float cumPV = 0.0
    var float cumV  = 0.0
    if anchorBar
        cumPV := 0.0
        cumV  := 0.0
    cumPV := cumPV + hlc3 * volume
    cumV  := cumV  + volume
    cumV > 0 ? cumPV / cumV : hlc3

bool newD = ta.change(time("D"))  != 0
bool newW = ta.change(time("W"))  != 0
bool newM = ta.change(time("M"))  != 0

float avwapD = anchoredVwap(newD)
float avwapW = anchoredVwap(newW)
float avwapM = anchoredVwap(newM)

// Each anchor: +1 if close above, -1 if below, 0 if not used
int sD = i_useD ? (close > avwapD ? 1 : close < avwapD ? -1 : 0) : 0
int sW = i_useW ? (close > avwapW ? 1 : close < avwapW ? -1 : 0) : 0
int sM = i_useM ? (close > avwapM ? 1 : close < avwapM ? -1 : 0) : 0
int enabledCount = (i_useD ? 1 : 0) + (i_useW ? 1 : 0) + (i_useM ? 1 : 0)
int sumAnchor = sD + sW + sM

// Break events: close crosses anchor by margin
bool dBreakUp = i_useD and close > avwapD + atrVal * i_breakAtr and close[1] <= avwapD[1] + atrVal * i_breakAtr
bool wBreakUp = i_useW and close > avwapW + atrVal * i_breakAtr and close[1] <= avwapW[1] + atrVal * i_breakAtr
bool mBreakUp = i_useM and close > avwapM + atrVal * i_breakAtr and close[1] <= avwapM[1] + atrVal * i_breakAtr
bool dBreakDn = i_useD and close < avwapD - atrVal * i_breakAtr and close[1] >= avwapD[1] - atrVal * i_breakAtr
bool wBreakDn = i_useW and close < avwapW - atrVal * i_breakAtr and close[1] >= avwapW[1] - atrVal * i_breakAtr
bool mBreakDn = i_useM and close < avwapM - atrVal * i_breakAtr and close[1] >= avwapM[1] - atrVal * i_breakAtr

int upBreaks = (dBreakUp ? 1 : 0) + (wBreakUp ? 1 : 0) + (mBreakUp ? 1 : 0)
int dnBreaks = (dBreakDn ? 1 : 0) + (wBreakDn ? 1 : 0) + (mBreakDn ? 1 : 0)

// ─── STORM SCORING (0-100) ────────────────────────────────────────────────────
int maxBreak = math.max(upBreaks, dnBreaks)
float sBreak = maxBreak * 25.0
float sAtr   = math.min(math.max(atrRatio - 1.0, 0.0) * 60.0, 30.0)
float sAlign = enabledCount > 0 ? math.min(math.abs(sumAnchor) / enabledCount * 25.0, 25.0) : 0.0
float stormScore = math.round(math.min(sBreak + sAtr + sAlign, 100.0))

string stormState = stormScore >= 85 ? "STORM" : stormScore >= 70 ? "RIPPING" : stormScore >= 50 ? "PRESSURING" : "ANCHORED"
color  stateCol   = stormScore >= 85 ? c_gold : stormScore >= 70 ? c_green : stormScore >= 50 ? c_cyan : color.gray

// ─── DIRECTIONAL BIAS ──────────────────────────────────────────────────────────
bool bullBias = upBreaks >= 2 and atrRatio > i_atrExp and close > biasEma and emaSlope > 0
bool bearBias = dnBreaks >= 2 and atrRatio > i_atrExp and close < biasEma and emaSlope < 0

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool scoreOk    = stormScore >= i_scoreThr

bool rawBuy  = bullBias and scoreOk and cooldownOk and confirmed
bool rawSell = bearBias and scoreOk and cooldownOk and confirmed
bool buySignal  = rawBuy and not rawSell
bool sellSignal = rawSell and not rawBuy

if buySignal or sellSignal
    lastSignalBar := bar_index

// ─── VISUAL: Storm Background Gradient ────────────────────────────────────────
color stormBg = na
if i_showBg
    if stormScore >= 85
        stormBg := color.new(bullBias ? i_buyColor : bearBias ? i_sellColor : c_gold, 90)
    else if stormScore >= 70
        stormBg := color.new(bullBias ? i_buyColor : bearBias ? i_sellColor : c_cyan, 94)
    else if stormScore >= 50
        stormBg := color.new(c_purple, 96)
bgcolor(stormBg)

// ─── VISUAL: Anchored VWAPs with Glow ─────────────────────────────────────────
plot(i_showVwap and i_useD ? avwapD : na, "Daily VWAP Glow", color=color.new(c_cyan, 70), linewidth=3)
plot(i_showVwap and i_useD ? avwapD : na, "Daily VWAP",      color=color.new(c_cyan, 20), linewidth=1)
plot(i_showVwap and i_useW ? avwapW : na, "Weekly VWAP Glow", color=color.new(c_purple, 70), linewidth=3)
plot(i_showVwap and i_useW ? avwapW : na, "Weekly VWAP",      color=color.new(c_purple, 20), linewidth=1)
plot(i_showVwap and i_useM ? avwapM : na, "Monthly VWAP Glow", color=color.new(c_gold, 70), linewidth=3)
plot(i_showVwap and i_useM ? avwapM : na, "Monthly VWAP",      color=color.new(c_gold, 20), linewidth=1)

// ─── VISUAL: 3-Layer Glow Signal Arrows ───────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="ANCHOR ↑",  textcolor=color.white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="ANCHOR ↓", textcolor=color.white)

// ─── VISUAL: Storm Context Label ──────────────────────────────────────────────
if buySignal
    label.new(bar_index, low - atrVal * 1.5, "ANCHOR STORM ↑\nScore: " + str.tostring(stormScore) + "/100\nBreaks: " + str.tostring(upBreaks), style=label.style_label_up, color=color.new(i_buyColor, 15), textcolor=color.white, size=size.small)
if sellSignal
    label.new(bar_index, high + atrVal * 1.5, "ANCHOR STORM ↓\nScore: " + str.tostring(stormScore) + "/100\nBreaks: " + str.tostring(dnBreaks), style=label.style_label_down, color=color.new(i_sellColor, 15), textcolor=color.white, size=size.small)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)

// ─── VISUAL: Anchor Dashboard ─────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 10, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    table.cell(dash, 0, 0, "Anchor Storm Detector", text_color=c_cyan, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "", text_color=color.white)
    table.cell(dash, 0, 1, "Storm Score", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(stormScore) + "/100", text_color=stateCol, text_size=size.small)
    table.cell(dash, 0, 2, "State", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, stormState, text_color=stateCol, text_size=size.small)
    table.cell(dash, 0, 3, "ATR Expansion", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(math.round(atrRatio, 2)) + "x", text_color=atrRatio > i_atrExp ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 4, "Daily VWAP", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, i_useD ? (sD == 1 ? "ABOVE" : sD == -1 ? "BELOW" : "AT") : "-", text_color=sD == 1 ? c_green : sD == -1 ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 5, "Weekly VWAP", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, i_useW ? (sW == 1 ? "ABOVE" : sW == -1 ? "BELOW" : "AT") : "-", text_color=sW == 1 ? c_green : sW == -1 ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 6, "Monthly VWAP", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, i_useM ? (sM == 1 ? "ABOVE" : sM == -1 ? "BELOW" : "AT") : "-", text_color=sM == 1 ? c_green : sM == -1 ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 7, "Up / Dn Breaks", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(upBreaks) + " / " + str.tostring(dnBreaks), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 8, "Anchor Sum", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(sumAnchor), text_color=sumAnchor > 0 ? c_green : sumAnchor < 0 ? c_pink : color.white, text_size=size.small)
    table.cell(dash, 0, 9, "Last Signal", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(bar_index - lastSignalBar) + " bars ago", text_color=color.white, text_size=size.small)

// ─── ALERTS (2x alert() with JSON) ─────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"ASD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"storm":' + str.tostring(stormScore) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"ASD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"storm":' + str.tostring(stormScore) + '}', alert.freq_once_per_bar_close)

// ─── ALERTCONDITIONS (9x global scope) ─────────────────────────────────────────
alertcondition(buySignal,                         "ASD Buy Storm",        "Anchor Storm BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                        "ASD Sell Storm",       "Anchor Storm SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,           "ASD Any Signal",       "Any anchor storm signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(stormScore >= 85,                  "ASD Storm Peak",       "Storm score 85+ on {{ticker}} {{interval}}")
alertcondition(upBreaks >= 2,                     "ASD Multi Up Break",   "Two or more anchored VWAPs broken up on {{ticker}} {{interval}}")
alertcondition(dnBreaks >= 2,                     "ASD Multi Down Break", "Two or more anchored VWAPs broken down on {{ticker}} {{interval}}")
alertcondition(atrRatio > i_atrExp,               "ASD ATR Expansion",    "ATR expansion beyond threshold on {{ticker}} {{interval}}")
alertcondition(sumAnchor >= 2,                    "ASD Full Bull Stack",  "All anchors bullish on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,           "ASD Webhook JSON",     "{\"action\":\"signal\",\"indicator\":\"ASD\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
