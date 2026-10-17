# TL Structure Pro - Mechanical SMC Engine: BOS, CHoCH, Sweeps

- url: https://www.tradingview.com/script/ncNEMMAd-TL-Structure-Pro-Mechanical-SMC-Engine-BOS-CHoCH-Sweeps/
- type: indicator
- pine_id: PUB;2d66739c2f2d4632ae768643272f7c48
- version: 5.0

## Description

TL STRUCTURE PRO — Mechanical Smart Money Concepts (SMC) Engine: Market Structure, BOS/CHoCH, Liquidity Sweeps, Supply & Demand POI, FVG, Sessions, Signals & Webhook Automation

WHAT THIS INDICATOR DOES

TL Structure Pro turns a complete, fully mechanical Smart Money Concepts (SMC) trading model into one indicator. It automates the exact rule set many price-action traders apply manually: market structure mapping (HH/HL/LL/LH), Break of Structure (BOS), Change of Character (CHoCH), liquidity sweeps, supply and demand points of interest (POI), fair value gaps (FVG/imbalance), session timing (Asia / Frankfurt / London), a two-step entry model with internal realignment, and rule-based trade management with break-even logic — all with zero discretion and zero repainting (the engine only works on confirmed/closed candles).

Every element is drawn and labeled directly on the chart, so you can SEE why each signal happened: every zone is named, every structure point is tagged, and every BUY/SELL label explains its own reason.

THE MECHANICAL RULE SET (HOW IT THINKS)

1. BREAK & CLOSE RULE — A swing high/low only counts as broken when a candle BREAKS AND CLOSES beyond it. A wick through the level without a close is NOT a break.
2. LIQUIDATION ($) — If price wicks beyond a swing but fails to close beyond it, the indicator prints a "$" marker: that was a liquidity sweep / liquidity grab, not a break. These sweeps often precede reversals.
3. PULLBACK RULE — A new swing high/low is only confirmed after a valid pullback: N opposing candles in a row (default 3) with successive closes. No valid pullback = no new structure point; the move is just internal noise.
4. BOS — Break of Structure in the direction of the trend = continuation. Drawn as a gold dashed line with a BOS label.
5. CHoCH — Break & close AGAINST the current direction = Change of Character. Bias flips (bullish <-> bearish). Drawn in pink. After a bearish CHoCH the engine only looks for shorts; after a bullish CHoCH only longs.
6. POI ZONES — On every qualifying break the engine stores two zones: the DECISIONAL candle (last opposing candle before the breaking impulse) and, on CHoCH, the ORIGIN (last opposing candle at the origin of the impulse). Zones are drawn as labeled supply/demand boxes, extended in time, marked as "tapped" on first touch and deleted when invalidated by a close beyond them.
7. FVG / GAPS — Three-candle imbalances above a minimum size are boxed and removed once filled ("gaps get filled").
8. SESSIONS — Asian session, Frankfurt open and the London trade window are boxed with configurable times and timezone (defaults follow GMT+4 / Dubai time as in the original model: London window 11:00–14:00).

THE ENTRY MODEL (WHEN A SIGNAL FIRES)

A signal needs three conditions in sequence — the same checklist is shown live in the cockpit panel:
Step 1 — BIAS: structure must be clearly bullish or bearish (after BOS/CHoCH).
Step 2 — POI TAP: price returns INTO a supply zone (bearish bias) or demand zone (bullish bias) or a matching FVG. The setup is now "armed".
Step 3 — INTERNAL SHIFT (REALIGNMENT): inside the POI, the smaller internal structure (pivot-based, the "lower timeframe inside your chart") must shift in trade direction — a close beyond the last internal pivot. Only then a BUY/SELL label prints.

Risk placement is automatic and printed on the chart:
• ENTRY = close of the trigger candle
• STOP LOSS = POI extreme + a pip buffer (default 3.5 pips — capital preservation first)
• TAKE PROFIT = the weak swing low/high of the current range (structure target)
• R multiple of the setup is calculated and shown on the signal label
• BREAK-EVEN: once the trade runs the configured R distance (default 1R), the panel/alert moves the stop logic to break-even; TP hit, SL hit and BE exit are all labeled on the chart.

THE COCKPIT PANEL

The side panel shows: current bias, the live SMC checklist (structure / pullback / liquidity sweep / POI tap / entry shift / management) with OK-status per rule, active session window, structure timeframe and internal pivot length, SL buffer, current position with entry/SL/TP, the last signal with its R multiple, and a counter of active supply/demand/FVG zones. If a checklist row shows "‥" you immediately know which condition is still missing before the next signal can fire.

HOW TO USE IT — STEP BY STEP

1. Add the indicator to a clean chart. Recommended: liquid FX pairs (GBPUSD, EURUSD), gold (XAUUSD) or indices, timeframes M5–H1 for the session-based model (M15 is the classic choice). It works on any symbol/timeframe; sessions display on intraday charts up to 1h.
2. Set your timezone and session times in group ④ if you do not trade the default GMT+4 windows. Enable "Signals ONLY inside London window" if you want to trade the London session model strictly.
3. Read the structure first: follow the SWING HIGH / SWING LOW lines, the HH/HL/LH/LL tags and the BOS/CHoCH lines until you understand the current bias (also shown in the panel).
4. Watch the zones: price returning into a labeled SUPPLY/DEMAND (DECISIONAL/ORIGIN) box or FVG arms the setup — the panel switches to "ARMED (POI tapped)".
5. Wait for the printed BUY/SELL label — never front-run it. The label shows the R multiple and the reason (POI TAP + SHIFT); the tooltip lists entry, stop and target.
6. Manage by the printed levels: entry line (gold), SL line (pink, includes the pip buffer), TP line (mint, the weak swing). BE marker prints when break-even logic activates.
7. Tune mechanically, not emotionally: "Pullback rule candles" (2–5) controls how strict new structure confirmation is; "Internal pivot length" controls how fine the entry trigger is (smaller = earlier, noisier); "Min gap size" filters small FVGs; "Max zones" limits chart clutter.
8. Hover anything: every label, zone and marker has an explanatory tooltip, so the chart teaches the model while you trade it.

ALERTS & WEBHOOK AUTOMATION

Create ONE alert with condition "Any alert() function call" and paste your webhook URL — the indicator sends ready-to-parse JSON for every event:
{"id":"TL-STRUCTURE-PRO","symbol":"GBPUSD","action":"SELL","price":1.27201,"sl":1.27236,"tp":1.26350,"rr":"24.30","tf":"15","time":"2026-07-18 12:45"}
Actions: BUY, SELL, BREAK_EVEN, TP_HIT, SL_HIT, plus optional BOS_UP/BOS_DOWN/CHOCH_UP/CHOCH_DOWN. This makes the indicator plug-and-play with trade-automation bridges, bots and journaling tools. Classic alertconditions (BUY/SELL/BOS/CHoCH) are also available for simple popup/app notifications.

NON-REPAINT BEHAVIOUR

All structure logic, zones and signals are computed on CONFIRMED candles only (barstate.isconfirmed). Once printed, BOS/CHoCH lines, zones and signal labels do not repaint. Alerts fire on bar close.

NOTES

• The R multiples shown are the structural setup quality, not a performance promise. Nothing here is financial advice — backtest and forward-test before risking money.
• The panel is a table: if your main chart series is set above indicators, use right-click on the indicator legend -> Visual order -> Bring to front.
• Best visual experience with the dark TradingView theme (the indicator brings its own navy chart theme, mint/red candles and paints the future margin).

Concepts covered: Smart Money Concepts, SMC, ICT-style market structure, break of structure, change of character, liquidity sweep, liquidity grab, stop hunt, supply and demand zones, order block style POIs, decisional candle, origin, fair value gap, imbalance, premium discount, London session, killzone, session trading, scalping, day trading, price action, forex, gold, indices, webhook automation, algo bridge.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════════
//   STRUCTURE PRO  v1.1
//  1:1 rebuild of the mechanical market-structure model (Prosperity Academy,
//  "28R London Session" video) as a TradingView indicator in a dark cockpit design.
//
//  Rules from the video (fully mechanical, zero discretion):
//   • Break of Structure  = candle breaks AND closes above/below the swing
//   • Wick only, no close = LIQUIDATION (not a break!)
//   • Pullback rule       = 3 opposing candles succeeding each other
//   • CHoCH               = structure break against direction -> bias flip
//   • POIs                = decisional candle + origin (last opposing candle before impulse)
//   • Gap/FVG             = imbalance as area of interest
//   • Entry               = POI tapped + internal shift (realignment) -> signal
//   • SL = POI extreme + 3.5 pip buffer | TP = weak swing low/high
//   • Break-even once 1R is reached (video: internal low broken)
// ═══════════════════════════════════════════════════════════════════════════════

//  v2 - House Rules compliance: no logo, no brand or company names, no external links.

//  v3 - Fix: the theme margin box no longer stretches the price scale.
indicator("Mechanical SMC Structure Engine", "SMC STRUCTURE ENGINE", overlay = true,
     max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// ─────────────────────────────── PALETTE ───────────────────────────────────
color COL_BG     = color.rgb(6, 17, 30)      // navy outer
color COL_PANEL  = color.rgb(10, 29, 46)     // panel glass
color COL_PANEL2 = color.rgb(15, 44, 66)     // panel section
color COL_BULL   = color.rgb(126, 224, 208)  // mint
color COL_BEAR   = color.rgb(244, 44, 58)    // red
color COL_CYAN   = color.rgb(53, 200, 255)
color COL_GOLD   = color.rgb(255, 215, 40)
color COL_GOLD2  = color.rgb(255, 236, 130)
color COL_GOLD3  = color.rgb(238, 190, 30)
color COL_GOLD4  = color.rgb(210, 160, 20)
color COL_GOLD5  = color.rgb(170, 125, 12)
color COL_GLINT  = color.rgb(255, 252, 214)
color COL_PINK   = color.rgb(255, 62, 130)
color COL_LIME   = color.rgb(214, 228, 78)
color COL_SUP_B  = color.rgb(196, 66, 92)    // supply border
color COL_DEM_B  = color.rgb(64, 196, 140)   // demand border
color COL_SELLBG = color.rgb(126, 32, 36)
color COL_BUYBG  = color.rgb(120, 154, 52)
color COL_TXT    = color.rgb(235, 235, 235)
color COL_GREY   = color.rgb(176, 182, 192)

// ─────────────────────────────── INPUTS ───────────────────────────────────────
grpS = "① Structure Engine (mechanical, as in the video)"
pbCandles   = input.int(3, "Pullback rule: opposing candles in a row", minval = 2, maxval = 5, group = grpS, tooltip = "Video: 'three candles in the opposing direction that succeed each other'. Only then the pullback is valid and the swing high/low gets confirmed.")
pbStrict    = input.bool(false, "Strict pullback: break & close of prior candle", group = grpS, tooltip = "ON: every opposing candle must CLOSE beyond the prior candle's extreme (strictest reading). OFF: series of opposing candles with successive closes.")
showBOS     = input.bool(true, "Show BOS", group = grpS)
showChoch   = input.bool(true, "Show CHoCH", group = grpS)
showLiq     = input.bool(true, "Mark liquidation wicks ($)", group = grpS)
showSwings  = input.bool(true, "SWING HIGH / SWING LOW lines", group = grpS)
showTags    = input.bool(true, "HH / HL / LH / LL tags", group = grpS)
showDots    = input.bool(true, "Structure points (gold)", group = grpS)
showIntern  = input.bool(true, "Internal structure points (cyan)", group = grpS)
intLen      = input.int(3, "Internal pivot length (realignment)", minval = 1, maxval = 10, group = grpS, tooltip = "Internal structure = the 'lower timeframe' inside your chart. Entries need an internal shift in trade direction (video: 1m realignment inside the 15m POI).")

grpZ = "② POI Zones (Decisional + Origin)"
showPoi     = input.bool(true, "Draw supply/demand POIs", group = grpZ)
poiLookback = input.int(20, "Lookback for origin/decisional candle", minval = 5, maxval = 50, group = grpZ)
maxZones    = input.int(8, "Max zones per side", minval = 2, maxval = 20, group = grpZ)

grpF = "③ Gap / FVG (Imbalance)"
showFvg     = input.bool(true, "Show FVGs / gaps", group = grpF)
fvgMinPips  = input.float(2.0, "Min gap size (pips)", minval = 0.0, step = 0.5, group = grpF, tooltip = "Video: the news gap was the #1 area of interest — 'gaps get filled'.")
maxFvg      = input.int(6, "Max open FVGs", minval = 2, maxval = 15, group = grpF)

grpX = "④ Sessions (as in the video: Asia / Frankfurt / London)"
showSess    = input.bool(true, "Show session boxes", group = grpX)
sessTz      = input.string("GMT+4", "Session timezone", group = grpX, tooltip = "Video: Dubai (GST = GMT+4). London open = 11:00 GST.")
sessAsia    = input.session("0100-0900", "Asian session", group = grpX)
sessFfm     = input.session("0900-1100", "Frankfurt open", group = grpX)
sessLdn     = input.session("1100-1400", "London window (trade time)", group = grpX, tooltip = "The 3-4h window traded in the video.")
sessOnly    = input.bool(false, "Signals ONLY inside London window", group = grpX)

grpT = "⑤ Signals & Trade Management"
showSignals = input.bool(true, "BUY/SELL signals active", group = grpT)
slBufPips   = input.float(3.5, "SL buffer above/below POI (pips)", minval = 0.0, step = 0.5, group = grpT, tooltip = "Video: 'three pips — I like to go with 3.5 to give a little bit of a buffer'. Capital preservation first!")
beRR        = input.float(1.0, "Break-even at (R)", minval = 0.25, step = 0.25, group = grpT, tooltip = "Video: BE once the internal low breaks — implemented mechanically as an R threshold.")
minRR       = input.float(1.0, "Min risk:reward to take a signal (R)", minval = 0.0, step = 0.25, group = grpT, tooltip = "Signals with a structural R:R below this are skipped. Prevents junk setups where the target is closer than the risk.")
showTrade   = input.bool(true, "Draw entry/SL/TP lines", group = grpT)

grpD = "⑥ Design"
useTheme    = input.bool(true, "Dark chart theme (navy + mint/red candles)", group = grpD)
showPanel   = input.bool(true, "Show Cockpit panel", group = grpD)
panelPos    = input.string("Middle Left", "Panel position", options = ["Middle Left", "Top Left", "Bottom Left", "Top Right", "Middle Right", "Bottom Right"], group = grpD)

grpA = "⑦ Alerts & Webhook (Automation)"
alSignals   = input.bool(true, "Alert on BUY/SELL (webhook JSON)", group = grpA, tooltip = "Create an alert with condition 'Any alert() function call' and paste your webhook URL into the alert. The message is ready-to-use JSON for bots/bridges.")
alStruct    = input.bool(false, "Alert on BOS/CHoCH", group = grpA)
alManage    = input.bool(true, "Alert on BE / TP / SL", group = grpA)
whId        = input.string("STRUCTURE-PRO", "Webhook strategy ID", group = grpA)

// ─────────────────────────────── BASICS ────────────────────────────────────────
float pip = syminfo.mintick * (syminfo.type == "forex" ? 10 : 1)
// universal buffer: pip-based on FX, ATR-based elsewhere (3.5 "pips" mean nothing on BTC/indices)
float atr14 = ta.atr(14)
float slBuffer = math.max(slBufPips * pip, atr14 * 0.1)
bool proc = barstate.isconfirmed

// Chart theme + navy future margin (paints the area right of the last candle)
bgcolor(useTheme ? color.new(COL_BG, 0) : na)
barcolor(useTheme ? (close >= open ? COL_BULL : COL_BEAR) : na)
float hh500 = ta.highest(high, 500)
float ll500 = ta.lowest(low, 500)

var box marginBox = na
if useTheme and na(marginBox)
    marginBox := box.new(bar_index + 1, high * 1.02, bar_index + 500, low * 0.98, border_color = color.new(COL_BG, 0), border_width = 1, bgcolor = color.new(COL_BG, 0))
if useTheme and not na(marginBox) and barstate.islast
    box.set_left(marginBox, bar_index + 1)
    box.set_right(marginBox, bar_index + 500)
    box.set_top(marginBox, hh500 * 1.02)
    box.set_bottom(marginBox, ll500 * 0.98)

// ─────────────────────────────── SESSIONS ─────────────────────────────────────
bool intraday = timeframe.in_seconds() <= 3600
bool inAsia = intraday and not na(time(timeframe.period, sessAsia, sessTz))
bool inFfm  = intraday and not na(time(timeframe.period, sessFfm,  sessTz))
bool inLdn  = intraday and not na(time(timeframe.period, sessLdn,  sessTz))

f_sessBox(bool active, color col, string tag) =>
    var box b = na
    if showSess and intraday
        if active and not active[1]
            b := box.new(bar_index, high, bar_index, low, border_color = color.new(col, 55), border_width = 1, border_style = line.style_dotted, bgcolor = color.new(col, 92), text = tag, text_size = size.tiny, text_color = color.new(col, 40), text_halign = text.align_center, text_valign = text.align_top)
        if active and not na(b)
            box.set_right(b, bar_index)
            box.set_top(b, math.max(box.get_top(b), high))
            box.set_bottom(b, math.min(box.get_bottom(b), low))
    b

sb1 = f_sessBox(inAsia, COL_GREY, "ASIA")
sb2 = f_sessBox(inFfm,  COL_CYAN, "FRANKFURT")
sb3 = f_sessBox(inLdn,  COL_GOLD, "LONDON")

// ─────────────────────────── INTERNAL STRUCTURE ───────────────────────────────
float iph = ta.pivothigh(high, intLen, intLen)
float ipl = ta.pivotlow(low, intLen, intLen)
var float lastIntHigh = na
var float lastIntLow  = na
if not na(iph)
    lastIntHigh := iph
    if showIntern
        label.new(bar_index - intLen, iph, "", style = label.style_circle, color = color.new(COL_CYAN, 45), size = size.tiny)
if not na(ipl)
    lastIntLow := ipl
    if showIntern
        label.new(bar_index - intLen, ipl, "", style = label.style_circle, color = color.new(COL_CYAN, 45), size = size.tiny)

// ─────────────────────────── STRUCTURE ENGINE ─────────────────────────────────
var int    dir          = 0          // 1 bullish, -1 bearish, 0 undefined
var float  rangeHigh    = na
var int    rangeHighBar = na
var float  rangeLow     = na
var int    rangeLowBar  = na
var bool   advUp        = false      // upward leg running, high not confirmed yet
var bool   advDn        = false
var float  extHigh      = na
var int    extHighBar   = na
var float  extLow       = na
var int    extLowBar    = na
var int    pbCount      = 0
var bool   pullbackOK   = false
var float  pullExt      = na         // retracement extreme = future HL/LH
var int    pullExtBar   = na
var string lastEvent    = "—"
var int    lastLiqBar   = -99999

// object storage for swing lines
var array<line>  swingLines  = array.new<line>()
var array<label> swingLabels = array.new<label>()
var line  liveHiLine = na
var label liveHiLab  = na
var line  liveLoLine = na
var label liveLoLab  = na

f_freeze(line ln, label lb) =>
    if not na(ln)
        array.push(swingLines, ln)
    if not na(lb)
        array.push(swingLabels, lb)
    while array.size(swingLines) > 40
        line.delete(array.shift(swingLines))
    while array.size(swingLabels) > 40
        label.delete(array.shift(swingLabels))

f_mkSwing(float y, int xbar, bool isHigh, string tag) =>
    line  nl = na
    label nb = na
    if showSwings
        nl := line.new(xbar, y, bar_index + 6, y, color = color.new(COL_GREY, 25), width = 1)
        nb := label.new(bar_index + 6, y, isHigh ? "SWING HIGH" : "SWING LOW", style = label.style_label_left, color = color.new(COL_PANEL, 25), textcolor = COL_TXT, size = size.tiny)
    if showDots
        label.new(xbar, y, "", style = label.style_circle, color = color.new(COL_GOLD, 15), size = size.tiny)
    if showTags and tag != ""
        label.new(xbar, y, tag, style = isHigh ? label.style_label_down : label.style_label_up, color = color.new(COL_BG, 100), textcolor = COL_GOLD, size = size.tiny, tooltip = isHigh ? (tag == "HH" ? "Higher High — confirmed by valid pullback" : "Lower High — confirmed by valid pullback") : (tag == "HL" ? "Higher Low — confirmed by break & close" : "Lower Low — confirmed by break & close"))
    [nl, nb]

f_eventLine(int fromBar, float y, string txt, color col, string tip) =>
    line.new(fromBar, y, bar_index, y, color = color.new(col, 30), width = 1, style = line.style_dashed)
    label.new((fromBar + bar_index) / 2, y, txt, style = label.style_label_center, color = color.new(COL_PANEL, 20), textcolor = col, size = size.tiny, tooltip = tip)

// POI zone storage
var array<box> supBoxes = array.new<box>()
var array<int> supState = array.new<int>()
var array<box> demBoxes = array.new<box>()
var array<int> demState = array.new<int>()

f_findOppCandle(bool wantBull, int startOffset) =>
    int found = -1
    for i = startOffset to startOffset + poiLookback
        if i <= bar_index and i >= 0
            if wantBull and close[i] > open[i]
                found := i
                break
            if not wantBull and close[i] < open[i]
                found := i
                break
    found

f_addSupply(int off, string tag) =>
    if showPoi and off >= 0
        b = box.new(bar_index - off, high[off], bar_index, low[off], border_color = color.new(COL_SUP_B, 25), border_width = 1, bgcolor = color.new(COL_SUP_B, 80), text = tag, text_size = size.tiny, text_color = color.new(COL_SUP_B, 15), text_halign = text.align_right, text_valign = text.align_center)
        array.push(supBoxes, b)
        array.push(supState, 0)
        while array.size(supBoxes) > maxZones
            box.delete(array.shift(supBoxes))
            array.shift(supState)

f_addDemand(int off, string tag) =>
    if showPoi and off >= 0
        b = box.new(bar_index - off, high[off], bar_index, low[off], border_color = color.new(COL_DEM_B, 25), border_width = 1, bgcolor = color.new(COL_DEM_B, 82), text = tag, text_size = size.tiny, text_color = color.new(COL_DEM_B, 10), text_halign = text.align_right, text_valign = text.align_center)
        array.push(demBoxes, b)
        array.push(demState, 0)
        while array.size(demBoxes) > maxZones
            box.delete(array.shift(demBoxes))
            array.shift(demState)

// events on this bar
bool evBosUp   = false
bool evBosDn   = false
bool evChochUp = false
bool evChochDn = false
bool evLiqUp   = false
bool evLiqDn   = false

if proc
    if na(rangeHigh)
        rangeHigh := high
        rangeHighBar := bar_index
        rangeLow := low
        rangeLowBar := bar_index

    // ── startup: set first direction via break & close ──
    if dir == 0
        if close > rangeHigh
            dir := 1
            advUp := true
            extHigh := high
            extHighBar := bar_index
            pullExt := low
            pullExtBar := bar_index
        else if close < rangeLow
            dir := -1
            advDn := true
            extLow := low
            extLowBar := bar_index
            pullExt := high
            pullExtBar := bar_index
        else
            rangeHigh := math.max(rangeHigh, high)
            rangeLow  := math.min(rangeLow, low)
            if high >= rangeHigh
                rangeHighBar := bar_index
            if low <= rangeLow
                rangeLowBar := bar_index

    // ── liquidation detection (wick beyond swing WITHOUT close) ──
    if dir != 0
        if not advUp and high > rangeHigh and close <= rangeHigh and high[1] <= rangeHigh
            evLiqUp := true
            lastLiqBar := bar_index
            if showLiq
                label.new(bar_index, high, "$", style = label.style_label_down, color = color.new(COL_BG, 100), textcolor = COL_PINK, size = size.small, tooltip = "LIQUIDATION\nWick above swing high, NO close above.\nRule: wick only = liquidity grab, NOT a break!")
        if not advDn and low < rangeLow and close >= rangeLow and low[1] >= rangeLow
            evLiqDn := true
            lastLiqBar := bar_index
            if showLiq
                label.new(bar_index, low, "$", style = label.style_label_up, color = color.new(COL_BG, 100), textcolor = COL_LIME, size = size.small, tooltip = "LIQUIDATION\nWick below swing low, NO close below.\nRule: wick only = liquidity grab, NOT a break!")

    // ── break & close UP ──
    bool breakUp = dir != 0 and not advUp and not na(rangeHigh) and close > rangeHigh
    if breakUp
        if dir == -1
            evChochUp := true
            if showChoch
                f_eventLine(rangeHighBar, rangeHigh, "CHoCH ▲", COL_PINK, "CHANGE OF CHARACTER\nCandle closed ABOVE the swing high while bearish.\nBias flips: bearish -> bullish. Now only longs.")
        else
            evBosUp := true
            if showBOS
                f_eventLine(rangeHighBar, rangeHigh, "BOS ▲", COL_GOLD, "BREAK OF STRUCTURE\nCandle closed ABOVE the swing high.\nBullish continuation confirmed.")
        float oldLo = rangeLow
        if dir == 1 and pullbackOK and not na(pullExt)
            rangeLow := pullExt
            rangeLowBar := pullExtBar
            [nl1, nb1] = f_mkSwing(rangeLow, rangeLowBar, false, rangeLow > oldLo ? "HL" : "LL")
            f_freeze(liveLoLine, liveLoLab)
            liveLoLine := nl1
            liveLoLab := nb1
        if dir == -1 and not na(extLow)
            rangeLow := extLow
            rangeLowBar := extLowBar
            [nl2, nb2] = f_mkSwing(rangeLow, rangeLowBar, false, rangeLow > oldLo ? "HL" : "LL")
            f_freeze(liveLoLine, liveLoLab)
            liveLoLine := nl2
            liveLoLab := nb2
        // demand POI: decisional = last sell candle before the break
        f_addDemand(f_findOppCandle(false, 1), "DEMAND · DECISIONAL")
        // origin POI on CHoCH: last sell candle at the origin of the up impulse
        if evChochUp and not na(extLowBar)
            f_addDemand(f_findOppCandle(false, math.max(bar_index - extLowBar, 0)), "DEMAND · ORIGIN")
        dir := 1
        advUp := true
        advDn := false
        extHigh := high
        extHighBar := bar_index
        pbCount := 0
        pullbackOK := false
        pullExt := low
        pullExtBar := bar_index
        lastEvent := (evChochUp ? "CHoCH ▲ " : "BOS ▲ ") + str.tostring(rangeHigh, format.mintick)

    // ── break & close DOWN ──
    bool breakDn = dir != 0 and not advDn and not na(rangeLow) and close < rangeLow and not breakUp
    if breakDn
        if dir == 1
            evChochDn := true
            if showChoch
                f_eventLine(rangeLowBar, rangeLow, "CHoCH ▼", COL_PINK, "CHANGE OF CHARACTER\nCandle closed BELOW the swing low while bullish.\nBias flips: bullish -> bearish. Now only shorts.")
        else
            evBosDn := true
            if showBOS
                f_eventLine(rangeLowBar, rangeLow, "BOS ▼", COL_GOLD, "BREAK OF STRUCTURE\nCandle closed BELOW the swing low.\nBearish continuation confirmed.")
        float oldHi = rangeHigh
        if dir == -1 and pullbackOK and not na(pullExt)
            rangeHigh := pullExt
            rangeHighBar := pullExtBar
            [nh1, hb1] = f_mkSwing(rangeHigh, rangeHighBar, true, rangeHigh > oldHi ? "HH" : "LH")
            f_freeze(liveHiLine, liveHiLab)
            liveHiLine := nh1
            liveHiLab := hb1
        if dir == 1 and not na(extHigh)
            rangeHigh := extHigh
            rangeHighBar := extHighBar
            [nh2, hb2] = f_mkSwing(rangeHigh, rangeHighBar, true, rangeHigh > oldHi ? "HH" : "LH")
            f_freeze(liveHiLine, liveHiLab)
            liveHiLine := nh2
            liveHiLab := hb2
        // supply POI: decisional = last buy candle before the break
        f_addSupply(f_findOppCandle(true, 1), "SUPPLY · DECISIONAL")
        // origin POI on CHoCH: last buy candle at the origin of the down impulse
        if evChochDn and not na(extHighBar)
            f_addSupply(f_findOppCandle(true, math.max(bar_index - extHighBar, 0)), "SUPPLY · ORIGIN")
        dir := -1
        advDn := true
        advUp := false
        extLow := low
        extLowBar := bar_index
        pbCount := 0
        pullbackOK := false
        pullExt := high
        pullExtBar := bar_index
        lastEvent := (evChochDn ? "CHoCH ▼ " : "BOS ▼ ") + str.tostring(rangeLow, format.mintick)

    // ── leg tracking + pullback rule (3 opposing candles in a row) ──
    if dir == 1 and not breakUp and not breakDn
        if advUp and high >= extHigh
            extHigh := high
            extHighBar := bar_index
            pbCount := 0
            pullExt := low
            pullExtBar := bar_index
        else
            if low < pullExt
                pullExt := low
                pullExtBar := bar_index
            bool opp = pbStrict ? close < low[1] : close < open and close < close[1]
            pbCount := opp ? pbCount + 1 : 0
            if pbCount >= pbCandles and not pullbackOK
                pullbackOK := true
                if advUp
                    float oldHi2 = rangeHigh
                    rangeHigh := extHigh
                    rangeHighBar := extHighBar
                    advUp := false
                    [nh3, hb3] = f_mkSwing(rangeHigh, rangeHighBar, true, rangeHigh > oldHi2 ? "HH" : "LH")
                    f_freeze(liveHiLine, liveHiLab)
                    liveHiLine := nh3
                    liveHiLab := hb3
    if dir == -1 and not breakUp and not breakDn
        if advDn and low <= extLow
            extLow := low
            extLowBar := bar_index
            pbCount := 0
            pullExt := high
            pullExtBar := bar_index
        else
            if high > pullExt
                pullExt := high
                pullExtBar := bar_index
            bool opp2 = pbStrict ? close > high[1] : close > open and close > close[1]
            pbCount := opp2 ? pbCount + 1 : 0
            if pbCount >= pbCandles and not pullbackOK
                pullbackOK := true
                if advDn
                    float oldLo2 = rangeLow
                    rangeLow := extLow
                    rangeLowBar := extLowBar
                    advDn := false
                    [nl3, lb3] = f_mkSwing(rangeLow, rangeLowBar, false, rangeLow > oldLo2 ? "HL" : "LL")
                    f_freeze(liveLoLine, liveLoLab)
                    liveLoLine := nl3
                    liveLoLab := lb3

// extend live lines
if barstate.islast and showSwings
    if not na(liveHiLine)
        line.set_x2(liveHiLine, bar_index + 6)
        label.set_x(liveHiLab, bar_index + 6)
    if not na(liveLoLine)
        line.set_x2(liveLoLine, bar_index + 6)
        label.set_x(liveLoLab, bar_index + 6)

// ─────────────────────────── POI MANAGEMENT ───────────────────────────────────
bool tapSupply = false
bool tapDemand = false
if proc
    int i = array.size(supBoxes) - 1
    while i >= 0
        box b = array.get(supBoxes, i)
        if close > box.get_top(b) + slBuffer
            box.delete(b)
            array.remove(supBoxes, i)
            array.remove(supState, i)
        else
            box.set_right(b, bar_index)
            if high >= box.get_bottom(b) and array.get(supState, i) == 0
                array.set(supState, i, 1)
                tapSupply := true
                box.set_bgcolor(b, color.new(COL_SUP_B, 68))
        i -= 1
    int j = array.size(demBoxes) - 1
    while j >= 0
        box b2 = array.get(demBoxes, j)
        if close < box.get_bottom(b2) - slBuffer
            box.delete(b2)
            array.remove(demBoxes, j)
            array.remove(demState, j)
        else
            box.set_right(b2, bar_index)
            if low <= box.get_top(b2) and array.get(demState, j) == 0
                array.set(demState, j, 1)
                tapDemand := true
                box.set_bgcolor(b2, color.new(COL_DEM_B, 70))
        j -= 1

// ─────────────────────────── FVG / GAP ────────────────────────────────────────
var array<box> fvgSup = array.new<box>()
var array<box> fvgDem = array.new<box>()
if proc and showFvg
    if low[2] - high > fvgMinPips * pip
        fb = box.new(bar_index - 2, low[2], bar_index, high, border_color = color.new(COL_PINK, 45), border_width = 1, border_style = line.style_dotted, bgcolor = color.new(COL_PINK, 88), text = "FVG", text_size = size.tiny, text_color = color.new(COL_PINK, 30), text_halign = text.align_right, text_valign = text.align_center)
        array.push(fvgSup, fb)
        while array.size(fvgSup) > maxFvg
            box.delete(array.shift(fvgSup))
    if low - high[2] > fvgMinPips * pip
        fb2 = box.new(bar_index - 2, low, bar_index, high[2], border_color = color.new(COL_CYAN, 45), border_width = 1, border_style = line.style_dotted, bgcolor = color.new(COL_CYAN, 88), text = "FVG", text_size = size.tiny, text_color = color.new(COL_CYAN, 30), text_halign = text.align_right, text_valign = text.align_center)
        array.push(fvgDem, fb2)
        while array.size(fvgDem) > maxFvg
            box.delete(array.shift(fvgDem))
    int k = array.size(fvgSup) - 1
    while k >= 0
        box fbk = array.get(fvgSup, k)
        if high >= box.get_top(fbk)
            box.delete(fbk)
            array.remove(fvgSup, k)
        else
            box.set_right(fbk, bar_index)
            if high >= box.get_bottom(fbk) and dir == -1
                tapSupply := true
        k -= 1
    int m = array.size(fvgDem) - 1
    while m >= 0
        box fbm = array.get(fvgDem, m)
        if low <= box.get_bottom(fbm)
            box.delete(fbm)
            array.remove(fvgDem, m)
        else
            box.set_right(fbm, bar_index)
            if low <= box.get_top(fbm) and dir == 1
                tapDemand := true
        m -= 1

// ─────────────────────────── SIGNAL ENGINE ────────────────────────────────────
var bool  armedSell   = false
var float armedSellSL = na
var bool  armedBuy    = false
var float armedBuySL  = na

var int    tradeDir = 0
var float  tEntry   = na
var float  tSL      = na
var float  tTP      = na
var bool   beDone   = false
var float  lastRR   = na
var string sigTxt   = "FLAT"

bool sellSignal  = false
bool buySignal   = false
bool beEvent     = false
bool tpEvent     = false
bool slEvent     = false
bool structEvent = false

// SL anchor = NEAREST tapped zone edge beyond price (not the farthest — a distant zone
// would produce absurd risk like SL thousands of points away)
f_maxPoiTopTapped() =>
    float t = na
    if array.size(supBoxes) > 0
        for x = 0 to array.size(supBoxes) - 1
            if array.get(supState, x) == 1
                float bt = box.get_top(array.get(supBoxes, x))
                if bt >= close
                    t := na(t) ? bt : math.min(t, bt)
    t

f_minPoiBotTapped() =>
    float t = na
    if array.size(demBoxes) > 0
        for x = 0 to array.size(demBoxes) - 1
            if array.get(demState, x) == 1
                float bb = box.get_bottom(array.get(demBoxes, x))
                if bb <= close
                    t := na(t) ? bb : math.max(t, bb)
    t

bool sessionOK = not sessOnly or inLdn

f_tradeLines(float e, float s, float t, float rr) =>
    line.new(bar_index, e, bar_index + 25, e, color = COL_GOLD, style = line.style_dashed, width = 1)
    line.new(bar_index, s, bar_index + 25, s, color = COL_PINK, style = line.style_dashed, width = 1)
    line.new(bar_index, t, bar_index + 25, t, color = COL_BULL, style = line.style_dashed, width = 1)
    label.new(bar_index + 25, e, "ENTRY", style = label.style_label_left, color = color.new(COL_PANEL, 20), textcolor = COL_GOLD, size = size.tiny)
    label.new(bar_index + 25, s, "SL +" + str.tostring(slBufPips, "#.#") + "p buffer", style = label.style_label_left, color = color.new(COL_PANEL, 20), textcolor = COL_PINK, size = size.tiny)
    label.new(bar_index + 25, t, "TP · weak swing · " + str.tostring(rr, "#.#") + "R", style = label.style_label_left, color = color.new(COL_PANEL, 20), textcolor = COL_BULL, size = size.tiny)

if proc and showSignals
    // ── arming: bias + POI tapped ──
    if dir == -1 and tapSupply
        armedSell := true
        float pt = f_maxPoiTopTapped()
        armedSellSL := na(pt) ? high : pt
    if dir == 1 and tapDemand
        armedBuy := true
        float pb2 = f_minPoiBotTapped()
        armedBuySL := na(pb2) ? low : pb2
    // disarm on bias flip or SL level overrun
    if evChochUp or (armedSell and close > armedSellSL + slBuffer)
        armedSell := false
    if evChochDn or (armedBuy and close < armedBuySL - slBuffer)
        armedBuy := false

    // ── SELL: internal shift down (realignment) ──
    if armedSell and tradeDir == 0 and sessionOK and not na(lastIntLow) and close < lastIntLow
        float slBase = f_maxPoiTopTapped()
        float slp = (na(slBase) ? armedSellSL : slBase) + slBuffer
        float tpp = rangeLow
        float rrC = (close - tpp) / (slp - close)
        if tpp < close and slp > close and rrC >= minRR
            sellSignal := true
            tradeDir := -1
            tEntry := close
            tSL := slp
            tTP := tpp
            beDone := false
            lastRR := (tEntry - tTP) / (tSL - tEntry)
            sigTxt := "SELL " + str.tostring(tEntry, format.mintick) + "  " + str.tostring(lastRR, "#.#") + "R"
            armedSell := false
            label.new(bar_index, high, "  SELL ▼  \n" + str.tostring(lastRR, "#.#") + "R · POI TAP + SHIFT", style = label.style_label_down, color = COL_SELLBG, textcolor = COL_TXT, size = size.normal, tooltip = "WHY THIS SELL?\n1) Bias bearish (structure)\n2) Price tapped supply POI\n3) Internal shift down = realignment\nEntry " + str.tostring(tEntry, format.mintick) + "\nSL " + str.tostring(tSL, format.mintick) + " (POI + " + str.tostring(slBufPips, "#.#") + "p)\nTP " + str.tostring(tTP, format.mintick) + " (weak low)\nR:R " + str.tostring(lastRR, "#.##"))
            if showTrade
                f_tradeLines(tEntry, tSL, tTP, lastRR)

    // ── BUY: internal shift up ──
    if armedBuy and tradeDir == 0 and sessionOK and not na(lastIntHigh) and close > lastIntHigh
        float slBase2 = f_minPoiBotTapped()
        float slp2 = (na(slBase2) ? armedBuySL : slBase2) - slBuffer
        float tpp2 = rangeHigh
        float rrC2 = (tpp2 - close) / (close - slp2)
        if tpp2 > close and slp2 < close and rrC2 >= minRR
            buySignal := true
            tradeDir := 1
            tEntry := close
            tSL := slp2
            tTP := tpp2
            beDone := false
            lastRR := (tTP - tEntry) / (tEntry - tSL)
            sigTxt := "BUY " + str.tostring(tEntry, format.mintick) + "  " + str.tostring(lastRR, "#.#") + "R"
            armedBuy := false
            label.new(bar_index, low, "  BUY ▲  \n" + str.tostring(lastRR, "#.#") + "R · POI TAP + SHIFT", style = label.style_label_up, color = COL_BUYBG, textcolor = COL_TXT, size = size.normal, tooltip = "WHY THIS BUY?\n1) Bias bullish (structure)\n2) Price tapped demand POI\n3) Internal shift up = realignment\nEntry " + str.tostring(tEntry, format.mintick) + "\nSL " + str.tostring(tSL, format.mintick) + " (POI - " + str.tostring(slBufPips, "#.#") + "p)\nTP " + str.tostring(tTP, format.mintick) + " (weak high)\nR:R " + str.tostring(lastRR, "#.##"))
            if showTrade
                f_tradeLines(tEntry, tSL, tTP, lastRR)

    // ── structure exit: CHoCH against the position kills the setup (video logic) ──
    if tradeDir == -1 and evChochUp
        structEvent := true
        tradeDir := 0
        sigTxt := "STRUCT EXIT ✖"
        label.new(bar_index, high, " STRUCT ✖ ", style = label.style_label_down, color = color.new(COL_PINK, 15), textcolor = COL_TXT, size = size.small, tooltip = "Structure flipped bullish (CHoCH) against the short — setup invalid, exit.")
    if tradeDir == 1 and evChochDn
        structEvent := true
        tradeDir := 0
        sigTxt := "STRUCT EXIT ✖"
        label.new(bar_index, low, " STRUCT ✖ ", style = label.style_label_up, color = color.new(COL_PINK, 15), textcolor = COL_TXT, size = size.small, tooltip = "Structure flipped bearish (CHoCH) against the long — setup invalid, exit.")

    // ── trade management: BE / TP / SL ──
    if tradeDir == -1
        float risk = tSL - tEntry
        if not beDone and low <= tEntry - beRR * risk
            beDone := true
            beEvent := true
            tSL := tEntry
            label.new(bar_index, high, "BE", style = label.style_label_down, color = color.new(COL_PANEL, 20), textcolor = COL_CYAN, size = size.tiny, tooltip = "Stop moved to break-even — video: 'stops are already at break even'")
        if low <= tTP
            tpEvent := true
            tradeDir := 0
            sigTxt := "TP HIT ✔ " + str.tostring(lastRR, "#.#") + "R"
            label.new(bar_index, low, " TP ✔ ", style = label.style_label_up, color = color.new(COL_BULL, 15), textcolor = COL_BG, size = size.small)
        else if high >= tSL
            slEvent := true
            tradeDir := 0
            sigTxt := beDone ? "BE EXIT" : "SL HIT ✖"
            label.new(bar_index, high, beDone ? " BE " : " SL ✖ ", style = label.style_label_down, color = color.new(beDone ? COL_CYAN : COL_BEAR, 15), textcolor = beDone ? COL_BG : COL_TXT, size = size.small)
    if tradeDir == 1
        float risk2 = tEntry - tSL
        if not beDone and high >= tEntry + beRR * risk2
            beDone := true
            beEvent := true
            tSL := tEntry
            label.new(bar_index, low, "BE", style = label.style_label_up, color = color.new(COL_PANEL, 20), textcolor = COL_CYAN, size = size.tiny)
        if high >= tTP
            tpEvent := true
            tradeDir := 0
            sigTxt := "TP HIT ✔ " + str.tostring(lastRR, "#.#") + "R"
            label.new(bar_index, high, " TP ✔ ", style = label.style_label_down, color = color.new(COL_BULL, 15), textcolor = COL_BG, size = size.small)
        else if low <= tSL
            slEvent := true
            tradeDir := 0
            sigTxt := beDone ? "BE EXIT" : "SL HIT ✖"
            label.new(bar_index, low, beDone ? " BE " : " SL ✖ ", style = label.style_label_up, color = color.new(beDone ? COL_CYAN : COL_BEAR, 15), textcolor = beDone ? COL_BG : COL_TXT, size = size.small)

// big MT5-style arrows on signal bars
plotshape(sellSignal, "SELL arrow", shape.triangledown, location.abovebar, COL_BEAR, size = size.small, display = display.pane)
plotshape(buySignal, "BUY arrow", shape.triangleup, location.belowbar, COL_BULL, size = size.small, display = display.pane)

// ─────────────────────────── ALERTS / WEBHOOK ─────────────────────────────────
f_json(string action, float px, float sl, float tp, float rr) =>
    '{"id":"' + whId + '","symbol":"' + syminfo.ticker + '","action":"' + action + '","price":' + str.tostring(px, format.mintick) + ',"sl":' + str.tostring(na(sl) ? px : sl, format.mintick) + ',"tp":' + str.tostring(na(tp) ? px : tp, format.mintick) + ',"rr":"' + str.tostring(na(rr) ? 0 : rr, "#.##") + '","tf":"' + timeframe.period + '","time":"' + str.format_time(time, "yyyy-MM-dd HH:mm", "GMT") + '"}'

if alSignals and sellSignal
    alert(f_json("SELL", tEntry, tSL, tTP, lastRR), alert.freq_once_per_bar_close)
if alSignals and buySignal
    alert(f_json("BUY", tEntry, tSL, tTP, lastRR), alert.freq_once_per_bar_close)
if alStruct and (evBosUp or evBosDn)
    alert(f_json(evBosUp ? "BOS_UP" : "BOS_DOWN", close, na, na, na), alert.freq_once_per_bar_close)
if alStruct and (evChochUp or evChochDn)
    alert(f_json(evChochUp ? "CHOCH_UP" : "CHOCH_DOWN", close, na, na, na), alert.freq_once_per_bar_close)
if alManage and beEvent
    alert(f_json("BREAK_EVEN", tEntry, tSL, tTP, lastRR), alert.freq_once_per_bar_close)
if alManage and structEvent
    alert(f_json("STRUCT_EXIT", close, tSL, tTP, lastRR), alert.freq_once_per_bar_close)
if alManage and tpEvent
    alert(f_json("TP_HIT", tTP, na, na, lastRR), alert.freq_once_per_bar_close)
if alManage and slEvent
    alert(f_json("SL_HIT", tSL, na, na, lastRR), alert.freq_once_per_bar_close)

alertcondition(sellSignal, "SELL Signal", "Structure Pro: SELL {{ticker}} @ {{close}}")
alertcondition(buySignal, "BUY Signal", "Structure Pro: BUY {{ticker}} @ {{close}}")
alertcondition(evChochUp or evChochDn, "CHoCH", "Structure Pro: Change of Character {{ticker}} {{interval}}")
alertcondition(evBosUp or evBosDn, "BOS", "Structure Pro: Break of Structure {{ticker}} {{interval}}")

// ───────────── PANEL v1.2 — CRT-Scalper-style cockpit (MT5 look) ─────────────
varip int glint = 0
if barstate.isrealtime
    glint += 1

f_pos() =>
    switch panelPos
        "Middle Left"  => position.middle_left
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        "Top Right"    => position.top_right
        "Middle Right" => position.middle_right
        => position.bottom_right




f_spacer(table t, int r) =>
    table.cell(t, 0, r, "", bgcolor = color.new(COL_BG, 0), text_size = size.tiny)

f_check(table t, int r, string num, string title, string sub, string status, color stCol) =>
    table.cell(t, 0, r, num, text_color = COL_GOLD, text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
    table.cell(t, 1, r, title + "\n" + sub, text_color = COL_TXT, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left)
    table.cell(t, 6, r, status, text_color = stCol, text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_right)

var table pan = na
if showPanel and barstate.islast
    if na(pan)
        pan := table.new(f_pos(), 8, 30, bgcolor = color.new(COL_PANEL, 0), frame_color = COL_CYAN, frame_width = 2, border_color = color.new(COL_CYAN, 88), border_width = 1)
        for r = 0 to 29
            for c = 0 to 7
                table.cell(pan, c, r, "", bgcolor = color.new(COL_PANEL, 0), text_size = size.tiny)
        table.merge_cells(pan, 0, 5, 6, 5)
        table.cell(pan, 0, 6, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 6, 7, 6)
        table.merge_cells(pan, 0, 8, 7, 8)
        table.merge_cells(pan, 0, 9, 7, 9)
        table.merge_cells(pan, 0, 10, 7, 10)
        table.merge_cells(pan, 0, 11, 3, 11)
        table.merge_cells(pan, 4, 11, 7, 11)
        table.merge_cells(pan, 0, 12, 3, 12)
        table.merge_cells(pan, 4, 12, 7, 12)
        table.merge_cells(pan, 0, 13, 7, 13)
        table.merge_cells(pan, 0, 14, 7, 14)
        for r = 15 to 20
            table.merge_cells(pan, 1, r, 5, r)
            table.merge_cells(pan, 6, r, 7, r)
        table.merge_cells(pan, 0, 21, 7, 21)
        table.merge_cells(pan, 0, 22, 7, 22)
        table.merge_cells(pan, 0, 23, 7, 23)
        table.merge_cells(pan, 0, 24, 7, 24)
        table.merge_cells(pan, 0, 25, 7, 25)
        table.cell(pan, 0, 26, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 26, 7, 26)
        table.cell(pan, 0, 27, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 27, 7, 27)
        table.cell(pan, 0, 28, "", bgcolor = color.rgb(6, 17, 30))
        table.merge_cells(pan, 0, 28, 7, 28)
        table.merge_cells(pan, 0, 29, 7, 29)
    int gcol = glint % 8
    for r = 0 to 4
        for c = 0 to 7
            table.cell(pan, c, r, "", bgcolor = color.new(COL_PANEL, 0), text_size = size.tiny)
    // ── header ──
    table.cell(pan, 0, 5, "SMC STRUCTURE ENGINE", text_color = COL_GOLD, text_size = size.normal, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(pan, 7, 5, glint % 2 == 0 ? "●" : "○", text_color = COL_CYAN, text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_right)
    // ── row 7: animated bull chevrons ──
    for c = 0 to 7
        table.cell(pan, c, 7, "▲", text_color = c == gcol ? COL_GOLD : color.new(COL_BULL, 35), text_size = size.small, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
    f_spacer(pan, 8)
    // ── row 9: session chip ──
    string chipTxt = inLdn ? "LONDON WINDOW ●" : inFfm ? "FRANKFURT OPEN" : inAsia ? "ASIAN SESSION" : "OUTSIDE WINDOW"
    color chipCol = inLdn ? COL_GOLD : inFfm ? COL_CYAN : inAsia ? COL_GREY : COL_GREY
    table.cell(pan, 0, 9, chipTxt, text_color = chipCol, text_size = size.small, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_center, text_font_family = font.family_monospace)
    f_spacer(pan, 10)
    // ── rows 11-12: TF / window info ──
    table.cell(pan, 0, 11, "STRUCT-TF\n" + timeframe.period + "  " + syminfo.ticker, text_color = COL_CYAN, text_size = size.tiny, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_left)
    table.cell(pan, 4, 11, "INTERNAL (ENTRY)\npivot " + str.tostring(intLen), text_color = COL_CYAN, text_size = size.tiny, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_left)
    table.cell(pan, 0, 12, "WINDOW\n" + sessLdn + " " + sessTz, text_color = COL_GOLD, text_size = size.tiny, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_left)
    table.cell(pan, 4, 12, "SL-BUFFER\n" + str.tostring(slBufPips, "#.#") + " pips", text_color = COL_GOLD, text_size = size.tiny, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_left)
    f_spacer(pan, 13)
    // ── checklist (the video rules) ──
    table.cell(pan, 0, 14, "SMC-CHECKLIST (VIDEO RULES)", text_color = COL_CYAN, text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_left)
    f_check(pan, 15, "❶", "MARKET STRUCTURE (HTF)", dir == 1 ? "HH/HL + BOS -> only BUYS" : dir == -1 ? "LL/LH + BOS -> only SELLS" : "waiting for break & close", dir != 0 ? "OK" : "‥", dir != 0 ? COL_BULL : COL_GREY)
    f_check(pan, 16, "❷", "PULLBACK RULE", str.tostring(pbCandles) + " opposing candles in a row", pullbackOK ? "OK" : str.tostring(pbCount) + "/" + str.tostring(pbCandles), pullbackOK ? COL_BULL : COL_GREY)
    f_check(pan, 17, "❸", "LIQUIDITY SWEEP ($)", "wick beyond swing, no close", bar_index - lastLiqBar <= 30 ? "OK" : "‥", bar_index - lastLiqBar <= 30 ? COL_BULL : COL_GREY)
    f_check(pan, 18, "❹", "POI TAP", armedSell ? "supply zone tapped" : armedBuy ? "demand zone tapped" : "waiting for zone tap", armedSell or armedBuy ? "OK" : "‥", armedSell or armedBuy ? COL_BULL : COL_GREY)
    f_check(pan, 19, "❺", "ENTRY SHIFT (LTF)", "internal realignment", tradeDir != 0 ? "OK" : armedSell or armedBuy ? "‥" : "—", tradeDir != 0 ? COL_BULL : COL_GREY)
    f_check(pan, 20, "❻", "MANAGEMENT", "BE @ " + str.tostring(beRR, "#.##") + "R · TP weak swing", tradeDir != 0 ? (beDone ? "BE✔" : "RUN") : "—", tradeDir != 0 ? (beDone ? COL_CYAN : COL_GOLD) : COL_GREY)
    f_spacer(pan, 21)
    // ── position box ──
    string posTxt = tradeDir == 0 ? "NO POSITION   — —" : (tradeDir == 1 ? "LONG " : "SHORT ") + str.tostring(tEntry, format.mintick) + " · SL " + str.tostring(tSL, format.mintick) + " · TP " + str.tostring(tTP, format.mintick)
    table.cell(pan, 0, 22, posTxt, text_color = tradeDir == 0 ? COL_GREY : tradeDir == 1 ? COL_BULL : COL_PINK, text_size = size.small, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_center, text_font_family = font.family_monospace)
    // ── big signal row ──
    color bigCol = str.contains(sigTxt, "TP HIT") ? COL_BULL : str.contains(sigTxt, "SL HIT") ? COL_BEAR : tradeDir != 0 ? COL_GOLD : COL_GREY
    table.cell(pan, 0, 23, sigTxt, text_color = bigCol, text_size = size.large, bgcolor = color.new(COL_PANEL2, 0), text_halign = text.align_center, text_font_family = font.family_monospace)
    table.cell(pan, 0, 24, str.tostring(array.size(supBoxes)) + " SUPPLY · " + str.tostring(array.size(demBoxes)) + " DEMAND · " + str.tostring(array.size(fvgSup) + array.size(fvgDem)) + " FVG", text_color = color.new(COL_GREY, 20), text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
    f_spacer(pan, 25)
    // ── buttons (links shown in tooltip — TradingView tables are not clickable) ──
    table.cell(pan, 0, 29, (glint % 2 == 0 ? "●" : "○") + " LIVE · webhook JSON ready", text_color = color.new(COL_BULL, 25), text_size = size.tiny, bgcolor = color.new(COL_PANEL, 0), text_halign = text.align_center)
````
