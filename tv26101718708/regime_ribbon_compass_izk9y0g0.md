# Regime Ribbon + Compass

- url: https://www.tradingview.com/script/iZk9y0g0-Regime-Ribbon-Compass/
- type: indicator
- pine_id: PUB;982ef0cdf05b4d1abf5952acf4be1e1c
- version: 1.0

## Description

Traditional ADX asks you to read three tangled lines at once — +DI, −DI, and the ADX line — and combine them in your head in real time. This tool collapses all three into a single, intuitive read: direction by color, trend strength by height. No sub-pane needed — the entire regime picture lives right on your price chart.

◈ WHAT IT DOES

The Regime Ribbon recolors a smoothed baseline directly on your candles: green when the directional index confirms an uptrend with strength, red for a downtrend with strength, and muted gray during low-ADX chop. An optional faint background tint reinforces the current regime at a glance.

The Regime Compass — a floating right-edge gauge — turns the same read into a live instrument you can check at a glance:

Fill direction shows who's in control: the meter fills upward from its midline when bulls lead (+DI over −DI) and downward when bears lead (−DI over +DI).
Fill color matches the regime: green for an up-regime, red for a down-regime, dim gray during chop.
Fill height encodes conviction: the stronger the trend (higher ADX), the further the meter fills toward its pole. A weak or ranging market barely lifts off the midline; a powerful trend pushes the fill close to the edge.
Bull / Bear poles mark the top and bottom of the gauge so you always know which way is which.
A live readout on the meter prints the current state and ADX value — for example "▲ TREND 34", "▼ TREND 28", or "◈ CHOP 12" — and a light-blue dashed midline marks the neutral point.

One glance answers both questions traders normally have to compute from three separate lines: which way, and how much to trust it. The gauge floats to the right of the last candle so it never sits on top of your price action, and it can be slid further out to taste.

An on-chart dashboard ties everything together in one row along the bottom of the chart — no separate pane. Each cell is a live readout:

REGIME — the current state in plain terms: BULL ▲, BEAR ▼, or CHOP ◈, colored to match.
ADX — the raw ADX value plus a word for context: WEAK (below the trend threshold), TREND (trend confirmed), or STRONG (a powerful move).
STRENGTH — a compact bar that fills with ADX, so you can gauge trend power without reading the number.
+DI — the positive directional value (up-pressure).
−DI — the negative directional value (down-pressure).
BALANCE — the two directional values distilled into a single signed percentage. Positive means bulls lead, negative means bears lead, and the size shows how lopsided it is. This is the "collapsed" read at the heart of the tool.
TP/SL — the take-profit and stop-loss distances currently configured, with their unit (percent or ATR).
COOLDOWN — how many bars remain before a new signal is allowed, or "clear" when it's ready.
STATUS — the current position state: FLAT, LONG ●, or SHORT ●.

Together the ribbon, compass, and dashboard give you the full regime picture — direction, strength, the underlying directional balance, your trade parameters, and current state — all on the price chart, readable in a single glance.

◈ HOW TO USE

Read it in two steps — direction, then conviction:

Ribbon and compass green with the meter filling high → an uptrend with conviction. Continuation-style approaches tend to suit these conditions, and the taller the compass fill, the more decisive the move.
Red with the meter filling low → a downtrend with conviction.
Ribbon dim gray and the compass short (hugging the midline) → ADX is low; a chop/range regime where trend-following is prone to whipsaw and range tactics tend to fit better. Many traders simply stand aside here.
Watch the BALANCE cell and the compass together: when balance swings from negative to positive (or vice-versa) and the compass starts filling with height, that's the regime waking up — the shift from chop into a directional move.
Optional markers and funnel labels highlight the exact moment the regime flips into a confirmed strong trend, drawing example take-profit and stop-loss reference levels on the chart so you can see the setup framed end to end.

A practical workflow: use the ribbon for your at-a-glance bias, the compass for how much weight to give it, the BALANCE cell to spot early shifts, and the STATUS/COOLDOWN cells to keep your own entries disciplined.

◈ SETTINGS

Regime Engine — DI Length, ADX Smoothing, Trend Threshold (the ADX level separating trend from chop), Strong-Trend level.
Regime Ribbon — baseline length, background tint toggle.
Regime Compass — right-edge offset, width, height (in ATR).
Trade Levels — TP/SL in Percent or ATR, ATR length, TP/SL box toggle.
Risk Management — cooldown between signals, max bars in trade, optional EOD flatten window.
Webhook — optional alert payload with a configurable strategy ID.
Dashboard — on/off.

◈ NON-REPAINTING

All signals evaluate only on confirmed (closed) bars, and every directional value is read from closed bars — so a signal that prints will not disappear or shift intrabar. Entry logic arms on the signal bar's close and references the next bar's open, matching realistic order timing. No future data is used anywhere in the logic.

◈ DISCLAIMER

This script is a technical-analysis tool provided for educational and informational purposes only. It is not financial advice, does not predict future price movement, and does not guarantee any outcome. Trading carries a substantial risk of loss. Always do your own research and manage your own risk. The past behavior of any indicator or market condition does not indicate future results.

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0
// © CodaPro
//@version=6
indicator("Regime Ribbon + Compass", shorttitle="Regime Compass", overlay=true, max_boxes_count=30, max_lines_count=100, max_labels_count=200)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
grpADX  = "◈ Regime Engine"
adxLen      = input.int(14,   "DI Length",        group=grpADX, minval=2)
adxSmooth   = input.int(14,   "ADX Smoothing",    group=grpADX, minval=2)
trendGate   = input.float(23, "Trend Threshold (ADX)", group=grpADX, minval=5, maxval=60, step=1, tooltip="ADX above this = a real trend. Below = chop / dead-zone (no signals).")
strongGate  = input.float(40, "Strong Trend (ADX)",    group=grpADX, minval=20, maxval=90, step=1)

grpRib  = "🎨 Regime Ribbon"
showRibbon  = input.bool(true, "Show Ribbon",     group=grpRib)
ribLen      = input.int(34,   "Ribbon Baseline (EMA)", group=grpRib, minval=2)
showBgTint  = input.bool(true, "Background Regime Tint", group=grpRib)

grpCmp  = "🧭 Regime Compass"
showCompass = input.bool(true, "Show Compass",    group=grpCmp)
cmpOffset   = input.int(14,   "Compass Offset (bars right)", group=grpCmp, minval=2, maxval=200)
cmpWidth    = input.int(5,    "Compass Width (bars)", group=grpCmp, minval=1, maxval=20)
cmpSpanATR  = input.float(6.0,"Compass Height (ATR)", group=grpCmp, minval=1.0, maxval=30.0, step=0.5)

grpTrade = "🎯 Trade Levels"
tradeUnit   = input.string("Percent", "TP/SL Unit", options=["Percent","ATR"], group=grpTrade)
tpVal       = input.float(0.50, "Take Profit", group=grpTrade, minval=0.0, step=0.05)
slVal       = input.float(0.25, "Stop Loss",   group=grpTrade, minval=0.0, step=0.05)
atrLen      = input.int(14,    "ATR Length",   group=grpTrade, minval=1)
showLevels  = input.bool(true, "Show TP/SL Boxes", group=grpTrade)

grpRisk = "🛡️ Risk Management"
useCooldown = input.bool(true, "Cooldown Between Signals", group=grpRisk)
cooldownBars= input.int(8,    "Cooldown Bars",   group=grpRisk, minval=1, maxval=200)
maxBars     = input.int(40,   "Max Bars In Trade", group=grpRisk, minval=3, maxval=500)
useEOD      = input.bool(false,"Flatten in EOD Window", group=grpRisk)
eodHour     = input.int(16,   "EOD Start Hour (NY)", group=grpRisk, minval=0, maxval=23)
eodMinute   = input.int(40,   "EOD Start Min (NY)",  group=grpRisk, minval=0, maxval=59)
eodEndHour  = input.int(18,   "EOD End Hour (NY)",   group=grpRisk, minval=0, maxval=23)
eodEndMin   = input.int(5,    "EOD End Min (NY)",    group=grpRisk, minval=0, maxval=59)

grpWh   = "🔗 Webhook"
enableWebhook = input.bool(false, "Enable Webhook Alerts", group=grpWh)
STRATEGY_ID   = input.string("regime_compass_v1", "Strategy ID", group=grpWh)
whQty         = input.float(1.0, "Quantity", group=grpWh, minval=0.01, step=0.01)

grpDash = "📊 Dashboard"
showDash    = input.bool(true, "Show Dashboard", group=grpDash)

// ═══════════════════════════════════════════════════════════════════════════════
// COLORS
// ═══════════════════════════════════════════════════════════════════════════════
color C_BULL = #00FF88
color C_BEAR = #FF4466
color C_CHOP = #8892A0
color C_TEAL = #00F5D4
color C_GOLD = #FFD700
color C_INK  = #E8ECF2
color C_MUTED   = color.new(#AAAAAA, 40)
color C_HDR_BG  = color.new(#0d1f1e, 0)
color C_COL_BG  = color.new(#0a0a14, 10)
color C_COL_ALT = color.new(#0d1117, 30)
color C_STRIPE  = color.new(#00F5D4, 20)

// ═══════════════════════════════════════════════════════════════════════════════
// REGIME ENGINE (ADX / DI collapsed into one read)
// ═══════════════════════════════════════════════════════════════════════════════
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxSmooth)
float atrV = ta.atr(atrLen)
float atrS = atrV > 0 ? atrV : syminfo.mintick

bool trending  = adx >= trendGate
bool bullLead  = diPlus > diMinus
bool bull      = trending and bullLead
bool bear      = trending and not bullLead
bool chop      = not trending
color regC     = bull ? C_BULL : bear ? C_BEAR : C_CHOP
float diBalance = (diPlus + diMinus) > 0 ? (diPlus - diMinus) / (diPlus + diMinus) : 0.0   // -1..+1

f_dist(float v) => tradeUnit == "Percent" ? close * v / 100.0 : atrS * v

// ── Session / EOD window (America/New_York) ──
string tzNY = "America/New_York"
int    nowMin   = hour(time, tzNY) * 60 + minute(time, tzNY)
int    eodStart = eodHour * 60 + eodMinute
int    eodEnd   = eodEndHour * 60 + eodEndMin
bool   inEODWin = eodStart <= eodEnd ? (nowMin >= eodStart and nowMin < eodEnd) : (nowMin >= eodStart or nowMin < eodEnd)
bool   isEOD    = useEOD and inEODWin

// ═══════════════════════════════════════════════════════════════════════════════
// REGIME RIBBON (glowing baseline recolored by regime + bg tint)
// ═══════════════════════════════════════════════════════════════════════════════
float baseline = ta.ema(close, ribLen)
plot(showRibbon ? baseline : na, "Ribbon Glow 3", color=color.new(regC, 82), linewidth=8)
plot(showRibbon ? baseline : na, "Ribbon Glow 2", color=color.new(regC, 65), linewidth=4)
plot(showRibbon ? baseline : na, "Ribbon Core",   color=color.new(regC, 10), linewidth=1)
bgcolor(showBgTint and bull ? color.new(C_BULL, 94) : showBgTint and bear ? color.new(C_BEAR, 94) : na, title="Regime Tint")

// ═══════════════════════════════════════════════════════════════════════════════
// 🧭 REGIME COMPASS (right-edge gauge: dir = color, height = ADX strength)
// ═══════════════════════════════════════════════════════════════════════════════
var box   cmpFrame = na
var box   cmpFill  = na
var line  cmpMid   = na
var label cmpLbl   = na
var label cmpPoleU = na
var label cmpPoleD = na
if barstate.islast
    if not na(cmpFrame)
        box.delete(cmpFrame)
    if not na(cmpFill)
        box.delete(cmpFill)
    if not na(cmpMid)
        line.delete(cmpMid)
    if not na(cmpLbl)
        label.delete(cmpLbl)
    if not na(cmpPoleU)
        label.delete(cmpPoleU)
    if not na(cmpPoleD)
        label.delete(cmpPoleD)
if barstate.islast and showCompass
    float span = atrS * cmpSpanATR
    float mid  = close
    int   gx1  = bar_index + cmpOffset
    int   gx2  = gx1 + cmpWidth
    float adxN = math.min(adx, 50.0) / 50.0                 // 0..1 strength
    float fillTop = bull ? mid + span * adxN : chop ? mid + span * 0.04 : mid
    float fillBot = bear ? mid - span * adxN : chop ? mid - span * 0.04 : mid
    cmpFrame := box.new(gx1, mid + span, gx2, mid - span, border_color=color.new(C_TEAL, 45), border_width=1, bgcolor=color.new(#0a0a14, 70))
    cmpFill  := box.new(gx1, fillTop, gx2, fillBot, border_color=color.new(regC, 25), border_width=1, bgcolor=color.new(regC, 55))
    cmpMid   := line.new(gx1, mid, gx2, mid, color=color.new(#4FC3F7, 20), style=line.style_dashed, width=1)
    string state = bull ? "▲ TREND " + str.tostring(adx, "#") : bear ? "▼ TREND " + str.tostring(adx, "#") : "◈ CHOP " + str.tostring(adx, "#")
    cmpLbl   := label.new(gx2, bull ? fillTop : bear ? fillBot : mid, " " + state + " ", style=label.style_label_left, color=color.new(#0a0a14, 20), textcolor=regC, size=size.small, text_font_family=font.family_monospace)
    cmpPoleU := label.new(gx1, mid + span, "◈ BULL", style=label.style_label_down, color=color.new(color.black, 100), textcolor=color.new(C_BULL, 25), size=size.tiny, text_font_family=font.family_monospace)
    cmpPoleD := label.new(gx1, mid - span, "◈ BEAR", style=label.style_label_up, color=color.new(color.black, 100), textcolor=color.new(C_BEAR, 25), size=size.tiny, text_font_family=font.family_monospace)

// ═══════════════════════════════════════════════════════════════════════════════
// 🎯 SIGNALS + TRADE MANAGEMENT (funnel labels, TP/SL, arbiter, cooldown, TIME/EOD)
// ═══════════════════════════════════════════════════════════════════════════════
// Fire when regime FLIPS into a confirmed strong trend.
bool longSig  = bull and not bull[1] and barstate.isconfirmed
bool shortSig = bear and not bear[1] and barstate.isconfirmed

var bool   g_inTrade = false
var bool   g_isLong  = false
var float  g_entry   = na
var float  g_tp      = na
var float  g_sl      = na
var int    g_entryBar = na
var int    lastSigBar = na

bool cdOK      = not useCooldown or na(lastSigBar) or bar_index - lastSigBar >= cooldownBars
bool canFire   = not g_inTrade and cdOK and not isEOD and barstate.isconfirmed

var array<label> fireLabels = array.new<label>()
var array<label> exitTags   = array.new<label>()
var box   tpBox = na
var box   slBox = na

f_fireLabel(bool isLong, float e, float tp, float sl) =>
    float slD = math.max(math.abs(e - sl), syminfo.mintick)
    float rr  = math.abs(tp - e) / slD
    string txt = (isLong ? "▲ LONG  1:" : "▼ SHORT  1:") + str.tostring(rr, "#.##") + " RR\nTP " + str.tostring(tp, format.mintick) + "   IN " + str.tostring(e, format.mintick) + "   SL " + str.tostring(sl, format.mintick)
    label lb = label.new(bar_index, isLong ? low : high, txt, yloc=yloc.price, style=isLong ? label.style_label_up : label.style_label_down, color=isLong ? color.new(#003322, 20) : color.new(#330000, 20), textcolor=isLong ? C_BULL : C_BEAR, size=size.small, text_font_family=font.family_monospace)
    array.push(fireLabels, lb)
    while array.size(fireLabels) > 20
        label.delete(array.shift(fireLabels))

// ── Entry — signal ARMS on the confirmed bar's close; fills at the NEXT bar's OPEN ──
var bool pendLong  = false
var bool pendShort = false
var int  pendBar   = na

// 1) EXECUTE first: a signal armed on the PRIOR bar fills at THIS bar's open (or expires)
if (pendLong or pendShort) and not na(pendBar) and bar_index > pendBar
    if not g_inTrade and not isEOD
        bool  isL = pendLong
        float e   = open
        float tp  = isL ? e + f_dist(tpVal) : e - f_dist(tpVal)
        float sl  = isL ? e - f_dist(slVal) : e + f_dist(slVal)
        g_inTrade  := true
        g_isLong   := isL
        g_entry    := e
        g_tp       := tp
        g_sl       := sl
        g_entryBar := bar_index
        lastSigBar := bar_index
        f_fireLabel(isL, e, tp, sl)
        if showLevels
            if not na(tpBox)
                box.delete(tpBox)
            if not na(slBox)
                box.delete(slBox)
            tpBox := box.new(bar_index, e, bar_index + maxBars, tp, border_color=color.new(C_TEAL, 40), bgcolor=color.new(C_TEAL, 90))
            slBox := box.new(bar_index, e, bar_index + maxBars, sl, border_color=color.new(C_BEAR, 40), bgcolor=color.new(C_BEAR, 90))
        if enableWebhook
            alert('{"strategy_id":"' + STRATEGY_ID + '","instrument":"' + (na(syminfo.current_contract) ? syminfo.ticker : syminfo.current_contract) + '","action":"enter","side":"' + (isL ? "buy" : "sell") + '","entry":' + str.tostring(e, "#.##") + ',"stop":' + str.tostring(sl, "#.##") + ',"profit":' + str.tostring(tp, "#.##") + ',"instrument_multiplier":' + str.tostring(syminfo.pointvalue) + ',"quantity":' + str.tostring(whQty) + '}', alert.freq_once_per_bar)
    pendLong  := false
    pendShort := false

// 2) ARM on this bar's confirmed signal (executes next bar)
if canFire and longSig
    pendLong  := true
    pendShort := false
    pendBar   := bar_index
if canFire and shortSig
    pendShort := true
    pendLong  := false
    pendBar   := bar_index

// ── Exit management (TP / SL / TIME / EOD) ──
f_exitTag(string mark, color c, float pnl) =>
    label lb = label.new(bar_index, na, " " + mark + " " + str.tostring(pnl, "#.##") + "% ", yloc=g_isLong ? yloc.abovebar : yloc.belowbar, style=g_isLong ? label.style_label_down : label.style_label_up, color=color.new(c, 75), textcolor=c, size=size.tiny, text_font_family=font.family_monospace)
    array.push(exitTags, lb)
    while array.size(exitTags) > 20
        label.delete(array.shift(exitTags))

if g_inTrade and barstate.isconfirmed and bar_index > g_entryBar
    bool hitTP = g_isLong ? high >= g_tp : low <= g_tp
    bool hitSL = g_isLong ? low  <= g_sl : high >= g_sl
    bool timeUp = bar_index - g_entryBar >= maxBars
    bool eodOut = isEOD
    float exitPx = hitSL ? g_sl : hitTP ? g_tp : close
    float pnl = g_isLong ? (exitPx - g_entry) / g_entry * 100.0 : (g_entry - exitPx) / g_entry * 100.0
    if hitSL
        f_exitTag("SL", C_BEAR, pnl)
        g_inTrade := false
        lastSigBar := bar_index
    else if hitTP
        f_exitTag("✦ TP", C_TEAL, pnl)
        g_inTrade := false
        lastSigBar := bar_index
    else if eodOut
        f_exitTag("◈ EOD", C_GOLD, pnl)
        g_inTrade := false
        lastSigBar := bar_index
    else if timeUp
        f_exitTag("TIME", C_GOLD, pnl)
        g_inTrade := false
        lastSigBar := bar_index
    if not g_inTrade and enableWebhook
        alert('{"strategy_id":"' + STRATEGY_ID + '","instrument":"' + (na(syminfo.current_contract) ? syminfo.ticker : syminfo.current_contract) + '","action":"exit-all"}', alert.freq_once_per_bar)

// ── Simple alerts (const strings) ──
alertcondition(bull and not bull[1], "Regime → Bull", "Regime flipped BULL")
alertcondition(bear and not bear[1], "Regime → Bear", "Regime flipped BEAR")

// ═══════════════════════════════════════════════════════════════════════════════
// 📊 DASHBOARD (on-chart, bottom-center — no subpane)
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.bottom_center, 9, 3, bgcolor=C_COL_BG, border_width=1, border_color=color.new(C_TEAL, 55), frame_color=color.new(C_TEAL, 40), frame_width=2)
if barstate.islast and showDash
    string regTxt = bull ? "BULL ▲" : bear ? "BEAR ▼" : "CHOP ◈"
    string strTxt = adx >= strongGate ? "STRONG" : adx >= trendGate ? "TREND" : "WEAK"
    string posTxt = not g_inTrade ? "FLAT --" : g_isLong ? "LONG ●" : "SHORT ●"
    color  posClr = not g_inTrade ? C_MUTED : g_isLong ? C_BULL : C_BEAR
    int    adxFill = int(math.min(8, math.round(math.min(adx, 50.0) / 50.0 * 8)))
    string adxBar  = str.repeat("█", adxFill) + str.repeat("░", 8 - adxFill)
    float  balPct  = diBalance * 100.0
    color  balClr  = balPct >= 0 ? C_BULL : C_BEAR
    int    cdLeft  = (not useCooldown or na(lastSigBar)) ? 0 : math.max(0, cooldownBars - (bar_index - lastSigBar))
    string tpslTxt = str.tostring(tpVal, "#.##") + "/" + str.tostring(slVal, "#.##") + (tradeUnit == "Percent" ? "%" : "a")
    // Row 0 — stripe header
    for _c = 0 to 8
        table.cell(dash, _c, 0, "", bgcolor=C_STRIPE, text_size=size.tiny)
    table.cell(dash, 0, 0, " ◈ REGIME COMPASS ◈ ", text_color=C_TEAL, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)
    table.cell(dash, 8, 0, " v1.1 ◈ ",             text_color=C_TEAL, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)
    // Row 1 — labels
    table.cell(dash, 0, 1, " ◈ REGIME ",   text_color=regC,   text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)
    table.cell(dash, 1, 1, " ◈ ADX ",      text_color=C_GOLD, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_ALT)
    table.cell(dash, 2, 1, " ◈ STRENGTH ", text_color=C_GOLD, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)
    table.cell(dash, 3, 1, " ◈ +DI ",      text_color=C_BULL, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_ALT)
    table.cell(dash, 4, 1, " ◈ -DI ",      text_color=C_BEAR, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)
    table.cell(dash, 5, 1, " ◈ BALANCE ",  text_color=balClr, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_ALT)
    table.cell(dash, 6, 1, " ◈ TP/SL ",    text_color=C_TEAL, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)
    table.cell(dash, 7, 1, " ◈ COOLDOWN ", text_color=C_MUTED,text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_ALT)
    table.cell(dash, 8, 1, " ◈ STATUS ",   text_color=C_TEAL, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)
    // Row 2 — values
    table.cell(dash, 0, 2, " " + regTxt, text_color=regC, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 1, 2, " " + str.tostring(adx, "#.#") + " " + strTxt, text_color=C_GOLD, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 2, 2, " " + adxBar, text_color=regC, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 3, 2, " " + str.tostring(diPlus, "#.#"),  text_color=C_BULL, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 4, 2, " " + str.tostring(diMinus, "#.#"), text_color=C_BEAR, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 5, 2, " " + str.tostring(balPct, "#") + "%", text_color=balClr, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 6, 2, " " + tpslTxt, text_color=C_INK, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 7, 2, " " + (cdLeft > 0 ? str.tostring(cdLeft) + "b" : "clear"), text_color=cdLeft > 0 ? C_BEAR : C_BULL, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 8, 2, " " + posTxt, text_color=posClr, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)

// ── Regime shift markers (small, on-chart) ──
plotshape(showRibbon and bull and not bull[1] and barstate.isconfirmed, "Bull Flip", shape.triangleup,   location.belowbar, color.new(C_BULL, 20), size=size.tiny)
plotshape(showRibbon and bear and not bear[1] and barstate.isconfirmed, "Bear Flip", shape.triangledown, location.abovebar, color.new(C_BEAR, 20), size=size.tiny)
````
