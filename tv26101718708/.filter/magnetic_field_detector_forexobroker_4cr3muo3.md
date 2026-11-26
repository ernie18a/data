# Magnetic Field Detector [forexobroker]

- url: https://www.tradingview.com/script/4CR3MUO3-Magnetic-Field-Detector-forexobroker/
- type: indicator
- pine_id: PUB;4d86439989884ad68c075e47aafe4970
- version: 1.0

## Description

Magnetic Field Detector bins recent price history and counts how many bars touched each bin. The bins with the most touches are the market's most "magnetic" levels -- prices the market cannot leave alone. The strongest magnet gets a gold line, the second-strongest gets a cyan dashed line, and signals fire on high-volume breaks beyond the primary magnet.

Built for traders who want support/resistance based on objective evidence of how many times price has visited a level.

🔶 CONCEPTS

Round numbers, prior highs, and drawn lines are subjective support/resistance. True support/resistance is evidence-based: the levels the market actually keeps returning to. If you bin recent price history and count how many bars' high-low ranges covered each bin, the bins with the most coverage are the levels that have magnetic pull. Price spends extra time near them; breakouts away from them are meaningful because they represent a release from repeated attraction. Volume confirmation on those breaks distinguishes a real rupture from a drift.

🔶 HOW IT WORKS

- Scans the last N bars (Scan Length)
- Divides the observed price range into Price Bins horizontal bins
- For each bar, increments every bin whose price is covered by that bar's high-low range
- Identifies the bin with the most touches (primary magnet) and the second strongest (informational)
- Draws the strongest magnet as a gold solid line and the second as a cyan dashed line
- Detects break events when close clears the primary magnet by the Break Margin with volume confirmation
- Combines top touch count, volume, and break into a 0-100 Magnet Score
- Classifies state as DORMANT, CHARGED, BREAKING, or RUPTURED

🔶 HOW TO USE

1. Add the indicator -- gold line marks the strongest magnetic level, cyan dashed line the second
2. Watch the dashboard (top-right) for live touch counts, distance to top magnet in ATR, and volume confirmation
3. Green BUY triangles with "MAGNET ↑" label fire on bullish break of the primary magnet; pink SELL triangles on bearish break
4. The Bias EMA plotted with glow gates breaks to the macro direction
5. Raise Break Margin (ATR) to reduce false breaks right at the level

🔶 FEATURES

- Non-repainting signals (barstate.isconfirmed)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- Objective magnet detection from actual price residency, not drawn lines
- Two-line display (primary + secondary) so alternative targets are visible

🔶 SETTINGS GUIDE

- Scan Length (bars) -- Window whose touches are counted
- Price Bins -- Number of horizontal price bins
- Min Touches per Level -- Minimum touches required to qualify a valid magnet
- Touch Zone (ATR) -- Informational ATR-scaled width around magnet lines
- ATR Length -- ATR period for width and break margin
- Break Margin (ATR) -- Close must exceed magnet by this ATR fraction
- Volume Confirm Multiplier -- Required volume / average volume for break confirmation
- Volume Average Length -- Lookback for average volume
- Bias EMA Length -- Macro EMA used to gate break direction
- Magnet Score Threshold -- Minimum 0-100 score required at fire
- Signal Cooldown Bars -- Minimum bars between consecutive signals

🔶 ALERTS

- MFD Buy Magnet -- Bullish magnet break confirmed
- MFD Sell Magnet -- Bearish magnet break confirmed
- MFD Any Signal -- Any magnet signal
- MFD Ruptured -- Magnet score reaches 85+
- MFD Up Break -- Close broke above magnetic line
- MFD Down Break -- Close broke below magnetic line
- MFD Magnet Valid -- Primary magnet meets minimum-touch criterion
- MFD Volume Confirm -- Volume multiplier condition met
- MFD Webhook JSON -- Generic webhook payload for external automation

🔶 LIMITATIONS & DISCLAIMER

- This is a technical analysis tool, not financial advice. Always use proper risk management.
- Binning discretizes price; magnets near bin boundaries may split across bins.
- Very long scan lengths may mix regimes; shorter scans adapt faster but are less robust.
- The Magnet Score is a composite heuristic, not a calibrated probability.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Magnetic Field Detector [forexobroker]", shorttitle="MFD [fob]", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_mag    = "Magnetic Settings"
string g_signal = "Signal Settings"
string g_visual = "Visual Settings"

int    i_scanLen   = input.int(120, "Scan Length (bars)", minval=30, maxval=500, group=g_mag)
int    i_bins      = input.int(25, "Price Bins", minval=10, maxval=60, group=g_mag)
int    i_minTouch  = input.int(3, "Min Touches per Level", minval=2, maxval=10, group=g_mag)
float  i_zoneAtr   = input.float(0.35, "Touch Zone (ATR)", minval=0.1, maxval=1.5, step=0.05, group=g_mag)
int    i_atrLen    = input.int(14, "ATR Length", minval=5, maxval=50, group=g_mag)
float  i_breakAtr  = input.float(0.25, "Break Margin (ATR)", minval=0.05, maxval=1.0, step=0.05, group=g_mag, tooltip="Close must exceed level by this ATR fraction")
float  i_volMult   = input.float(1.15, "Volume Confirm Multiplier", minval=1.0, maxval=2.5, step=0.05, group=g_mag)
int    i_volLen    = input.int(20, "Volume Average Length", minval=5, maxval=100, group=g_mag)
int    i_biasLen   = input.int(50, "Bias EMA Length", minval=10, maxval=200, group=g_mag)
int    i_scoreThr  = input.int(70, "Magnet Score Threshold", minval=40, maxval=95, group=g_signal)
int    i_cooldown  = input.int(12, "Signal Cooldown Bars", minval=3, maxval=50, group=g_signal)
bool   i_showTable = input.bool(true, "Show Magnet Dashboard", group=g_visual)
bool   i_showBg    = input.bool(true, "Show Magnet Background", group=g_visual)
bool   i_showGlow  = input.bool(true, "Show 3-Layer Signal Glow", group=g_visual)
bool   i_showEma   = input.bool(true, "Show Bias EMA Glow", group=g_visual)
bool   i_showLines = input.bool(true, "Show Magnetic Lines", group=g_visual)
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
float avgVol = ta.sma(volume, i_volLen)
bool volOk = volume >= avgVol * i_volMult

float hi = ta.highest(high, i_scanLen)
float lo = ta.lowest(low,   i_scanLen)
float binSize = (hi - lo) / i_bins

var array<int> touches = array.new<int>(60, 0)
if array.size(touches) != i_bins
    array.clear(touches)
    for b = 0 to i_bins - 1
        array.push(touches, 0)

array.clear(touches)
for b = 0 to i_bins - 1
    array.push(touches, 0)

// Count touches: a touch is any bar whose HL range covers a bin
for i = 0 to i_scanLen - 1
    int startBin = int(math.floor((low[i] - lo) / binSize))
    int endBin   = int(math.floor((high[i] - lo) / binSize))
    startBin := math.max(math.min(startBin, i_bins - 1), 0)
    endBin   := math.max(math.min(endBin,   i_bins - 1), 0)
    for b = startBin to endBin
        array.set(touches, b, array.get(touches, b) + 1)

int maxTouch = array.max(touches)
int magBinIdx = array.indexof(touches, maxTouch)
float magLevel = na(magBinIdx) or magBinIdx < 0 ? na : lo + (magBinIdx + 0.5) * binSize

// Second strongest magnetic level
var array<int> touches2 = array.new<int>(60, 0)
array.clear(touches2)
for b = 0 to i_bins - 1
    array.push(touches2, array.get(touches, b))
if not na(magBinIdx) and magBinIdx >= 0
    array.set(touches2, magBinIdx, 0)
int maxTouch2 = array.max(touches2)
int magBinIdx2 = array.indexof(touches2, maxTouch2)
float magLevel2 = na(magBinIdx2) or magBinIdx2 < 0 ? na : lo + (magBinIdx2 + 0.5) * binSize

bool magValid = maxTouch >= i_minTouch and not na(magLevel)

float biasEma = ta.ema(close, i_biasLen)
float emaSlope = ta.change(biasEma, 3)

// Magnetic break: close clears magnetic level by margin with volume confirm
bool upBreak = magValid and close > magLevel + atrVal * i_breakAtr and close[1] <= magLevel + atrVal * i_breakAtr and volOk
bool dnBreak = magValid and close < magLevel - atrVal * i_breakAtr and close[1] >= magLevel - atrVal * i_breakAtr and volOk

// ─── MAGNET SCORING (0-100) ───────────────────────────────────────────────────
float sTouch = math.min(maxTouch * 6.0, 40.0)
float sVol   = math.min(math.max((volume / avgVol - 1.0) * 40.0, 0.0), 25.0)
float sBreak = (upBreak or dnBreak) ? 35.0 : 0.0
float magScore = math.round(math.min(sTouch + sVol + sBreak, 100.0))

string magState = magScore >= 85 ? "RUPTURED" : magScore >= 70 ? "BREAKING" : magScore >= 50 ? "CHARGED" : "DORMANT"
color  stateCol = magScore >= 85 ? c_gold : magScore >= 70 ? c_green : magScore >= 50 ? c_cyan : color.gray

// ─── DIRECTIONAL BIAS ──────────────────────────────────────────────────────────
bool bullBias = upBreak and close > biasEma and emaSlope > 0
bool bearBias = dnBreak and close < biasEma and emaSlope < 0

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool scoreOk    = magScore >= i_scoreThr

bool rawBuy  = bullBias and scoreOk and cooldownOk and confirmed
bool rawSell = bearBias and scoreOk and cooldownOk and confirmed
bool buySignal  = rawBuy and not rawSell
bool sellSignal = rawSell and not rawBuy

if buySignal or sellSignal
    lastSignalBar := bar_index

// ─── VISUAL: Magnet Background Gradient ───────────────────────────────────────
color magBg = na
if i_showBg
    if magScore >= 85
        magBg := color.new(bullBias ? i_buyColor : bearBias ? i_sellColor : c_gold, 90)
    else if magScore >= 70
        magBg := color.new(bullBias ? i_buyColor : bearBias ? i_sellColor : c_cyan, 94)
    else if magValid
        magBg := color.new(c_purple, 96)
bgcolor(magBg)

// ─── VISUAL: Bias EMA with 3-Layer Glow ───────────────────────────────────────
plot(i_showEma ? biasEma : na, "EMA Glow 1", color=color.new(c_purple, 70), linewidth=5)
plot(i_showEma ? biasEma : na, "EMA Glow 2", color=color.new(c_purple, 40), linewidth=3)
plot(i_showEma ? biasEma : na, "EMA Core",   color=color.new(c_purple, 0),  linewidth=1)

// ─── VISUAL: Magnetic Lines ───────────────────────────────────────────────────
var line magL1 = na
var line magL2 = na
if i_showLines and magValid
    line.delete(magL1)
    magL1 := line.new(bar_index - i_scanLen, magLevel, bar_index, magLevel, color=color.new(c_gold, 20), width=3)
if i_showLines and not na(magLevel2) and maxTouch2 >= i_minTouch
    line.delete(magL2)
    magL2 := line.new(bar_index - i_scanLen, magLevel2, bar_index, magLevel2, color=color.new(c_cyan, 40), width=2, style=line.style_dashed)

// ─── VISUAL: 3-Layer Glow Signal Arrows ───────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="MAGNET ↑",  textcolor=color.white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="MAGNET ↓", textcolor=color.white)

// ─── VISUAL: Magnet Context Label ─────────────────────────────────────────────
if buySignal
    label.new(bar_index, low - atrVal * 1.5, "MAGNET ↑\nScore: " + str.tostring(magScore) + "/100\nTouches: " + str.tostring(maxTouch), style=label.style_label_up, color=color.new(i_buyColor, 15), textcolor=color.white, size=size.small)
if sellSignal
    label.new(bar_index, high + atrVal * 1.5, "MAGNET ↓\nScore: " + str.tostring(magScore) + "/100\nTouches: " + str.tostring(maxTouch), style=label.style_label_down, color=color.new(i_sellColor, 15), textcolor=color.white, size=size.small)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)

// ─── VISUAL: Magnet Dashboard ─────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    table.cell(dash, 0, 0, "Magnetic Field Detector", text_color=c_cyan, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "", text_color=color.white)
    table.cell(dash, 0, 1, "Magnet Score", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(magScore) + "/100", text_color=stateCol, text_size=size.small)
    table.cell(dash, 0, 2, "State", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, magState, text_color=stateCol, text_size=size.small)
    table.cell(dash, 0, 3, "Top Magnet", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, not na(magLevel) ? str.tostring(math.round(magLevel, 5)) : "-", text_color=c_gold, text_size=size.small)
    table.cell(dash, 0, 4, "Top Touches", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(maxTouch), text_color=maxTouch >= i_minTouch ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 5, "2nd Magnet", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, not na(magLevel2) ? str.tostring(math.round(magLevel2, 5)) : "-", text_color=c_cyan, text_size=size.small)
    table.cell(dash, 0, 6, "Dist to Top", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, not na(magLevel) ? str.tostring(math.round((close - magLevel) / atrVal, 2)) + " ATR" : "-", text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 7, "Vol Confirm", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, volOk ? "YES" : "NO", text_color=volOk ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 8, "Last Signal", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(bar_index - lastSignalBar) + " bars ago", text_color=color.white, text_size=size.small)

// ─── ALERTS (2x alert() with JSON) ─────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"MFD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"magnet":' + str.tostring(magScore) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"MFD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"magnet":' + str.tostring(magScore) + '}', alert.freq_once_per_bar_close)

// ─── ALERTCONDITIONS (9x global scope) ─────────────────────────────────────────
alertcondition(buySignal,                         "MFD Buy Magnet",       "Magnet BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                        "MFD Sell Magnet",      "Magnet SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,           "MFD Any Signal",       "Any magnet signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(magScore >= 85,                    "MFD Ruptured",         "Magnet score 85+ on {{ticker}} {{interval}}")
alertcondition(upBreak,                           "MFD Up Break",         "Break above magnetic line on {{ticker}} {{interval}}")
alertcondition(dnBreak,                           "MFD Down Break",       "Break below magnetic line on {{ticker}} {{interval}}")
alertcondition(magValid,                          "MFD Magnet Valid",     "Magnetic line qualified on {{ticker}} {{interval}}")
alertcondition(volOk,                             "MFD Volume Confirm",   "Volume confirmation present on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,           "MFD Webhook JSON",     "{\"action\":\"signal\",\"indicator\":\"MFD\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
