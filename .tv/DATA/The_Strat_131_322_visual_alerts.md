<!-- tradingview-pine-id: PUB;7c1822a1910442cd8ee9870725175768 -->
<!-- tradingviewscripts-format: 1 -->
# The Strat — 1-3-1 & 3-2-2 (visual + alerts)

Source: https://www.tradingview.com/script/l3bdKVoT-Miyagi-1-3-1-and-3-2-2-Setups/

## Description

This indicator detects and manages two specific setups from "The Strat", the price-action methodology created by Rob Smith (credit to him for the underlying concepts; this implementation is my own original code using AYCE's setups). It classifies candles the standard Strat way — relative to the previous candle, a bar is a 1 (inside bar: took out neither side), a 2 (directional bar: took out one side only), or a 3 (outside bar: took out both sides) — and applies that classification to two rule-based setups on their proper timeframes. These specific setups were created by AYCE, credit must be given.

SETUP 1: THE 1-3-1 (12-hour chart for stocks, 6-hour chart for SPX)

With extended trading hours enabled, the 12-hour session candles split the day into a market candle (04:00–16:00 ET) and an overnight candle (16:00–04:00 ET). The setup requires an inside bar, then an outside bar, then a second inside bar (the strict leading-1 requirement can be relaxed in settings). The trailing 1 bar's 50% level — (high + low) / 2 — becomes the reference for the next session:

If pre-market touches the 50% level, the setup is invalidated.
If it survives to the open: opening above the 50% gives a short-side plan (trigger at the 50%, first target the 1 bar's low); opening below gives the mirrored long-side plan (first target the 1 bar's high).

On the SPX index there is no pre-market, so the 6-hour chart is used instead and the plan activates directly at the open. The script automatically disables the 12-hour logic on SPX.

SETUP 2: THE 3-2-2 REVERSAL (1-hour chart, stocks with pre-market data)

The 08:00 ET hourly candle must be a 3, the 09:00 candle must be a 2, and only the 10:00 candle may complete the setup — by taking out the 9am candle's opposite extreme (a reversal 2). A continuation break, or an hour that ends without the reversal, cancels the setup. Continuation 2s are never signaled: this is strictly a reversal pattern. When a valid reversal fires, the three bars are marked 3-2-2 on the chart, with the entry at the break and the first target at the 3 bar's outside.

WHAT MAKES IT ORIGINAL

Timeframe-aware behavior in one script: on the 12H/6H/1H charts it detects natively on the chart's own candles; on any chart below 1H it switches to projection mode and draws the live higher-timeframe levels (requested with request.security using a one-bar offset, so only confirmed higher-timeframe values are used — no future data is accessed).
Sequenced outcome scoring: past 1-3-1 setups are graded by replaying the following session in time order with lower-timeframe data (request.security_lower_tf), so a session that filled at the 50% and reached the target before reversing is correctly scored a success even if the candle later became a 3. Marks: cancelled pre-market, target reached, stop side first, no fill, flat at close.
Event-driven alert architecture: every state change (setup detected, confirmed at the open with direction and levels, invalidated, entry touched, reversal triggered, cancelled) is an alert() event you can enable per event in the settings, so a single "Any alert() function call" alert per symbol carries everything. Classic per-event alert conditions are also included, each with its required trigger frequency written into its name.

HOW TO USE IT

Add the indicator to a 12-hour chart (stocks, extended hours ON), a 6-hour chart (SPX), a 1-hour chart (stocks), or any sub-1-hour chart for projection mode. Auto mode picks the right behavior from the timeframe.
On the 12H/6H chart, valid 1-3-1 patterns are numbered on their candles and later scored. On the 1H chart, a 3-then-2 sequence shows its trigger and target lines during the 10am hour only. On lower timeframes, the higher-timeframe levels appear as live lines: three lines pre-market, reduced to the active side at the open.
For alerts, open the settings, choose the events you want under "All-in-one alert", then create one alert with the condition set to this indicator and "Any alert() function call", open-ended. Alerts are bound to the symbol and settings at creation time, so re-create the alert after changing settings. Alternatively, use the individual alert conditions and set each one's frequency as written in its name (Once Per Bar Close for close-based events, Once Per Bar for intrabar events).
The status panel summarizes the current state of both setups; it can be moved, resized, or hidden.

LIMITATIONS AND TRANSPARENCY

Higher-timeframe values are requested with a one-bar offset and confirmed bars only; live watch labels update in real time by design, and their state at bar close is final.
On historical 1-hour bars that touched both the trigger and the invalidation level within the same bar, the sequence cannot be known after the fact; such cases are marked cancelled rather than counted as signals. In real time the script evaluates tick order as it happens.
Intrabar alert events require live trades, so use liquid symbols. Outcome scoring depends on available lower-timeframe history, so older setups show the pattern without a score.
Session times are US Eastern and configurable. Extended trading hours must be enabled on stock charts for the pattern windows to exist.

This is a chart-analysis tool for studying a rule-based methodology. It does not predict the market, and nothing here is financial advice. Test it and draw your own conclusions.

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  THE STRAT — 1-3-1 & 3-2-2  ·  CLEAN VISUALS · ALL-IN-ONE ALERT · PROJECTION
//
//  Where to run it (Auto mode reads the chart timeframe):
//      12H chart (stocks, ETH ON)   → native 1-3-1
//      6H  chart (SPX)              → native 1-3-1
//      1H  chart (stocks, ETH ON)   → native 3-2-2
//      Any chart UNDER 1H (5m etc.) → PROJECTION of both setups + the
//                                      ALL-IN-ONE alert home
//
//  SPX RULES (auto when the ticker is SPX, or force in settings):
//      · 12H chart shows NOTHING — only the 6H is valid for SPX
//      · no 3-2-2 anywhere on SPX (no pre-market)
//
//  CLEAN CHART:
//      · No candle numbering, no boxes, no permanent lines.
//      · 12H/6H: a valid 1-3-1 prints yellow  1 3 1  over its three candles.
//        The next session is then SCORED IN SEQUENCE (using lower-TF bars):
//          ✕  pre-market touched the 50%  → cancelled
//          ✓  50% filled after the open, PT hit — even if the candle became
//             a 3 LATER: in and out first still counts as a win
//          ✗  50% filled, stop side hit before the PT
//          ∅  never came back to the 50%   ·   —  entered, flat at the close
//      · 1H: yellow  3 2 2  prints only when the 10am bar truly reverses the
//        9am 2 bar. Entry/PT lines exist only while the watch is live.
//
//  THE ALL-IN-ONE ALERT (one alert per ticker):
//      Open the ticker's 5-minute chart (ETH on) → add this indicator →
//      tick the events you want in "④ All-in-one alert" → Alt+A →
//      condition: this indicator → "Any alert() function call" → Open-ended.
//      That single alert then sends: 1-3-1 setup detected · confirmed at the
//      open with direction/entry/TP (only if pre-market never touched the
//      50%) · cancelled pre-market · entry hit · potential 3-2-2 · reversal
//      triggered · cancelled.  NOTE: TradingView snapshots settings into the
//      alert — after changing the checkboxes, delete & re-create the alert.
// ═══════════════════════════════════════════════════════════════════════════

indicator("The Strat — 1-3-1 & 3-2-2 (visual + alerts)",
     shorttitle = "STRAT 131/322",
     overlay = true,
     max_labels_count = 500,
     max_lines_count = 500)

// ─────────────────────────── ① What to detect ──────────────────────────────
gM = "① What to detect"
detectMode = input.string("Auto (by chart timeframe)", "Mode", options = ["Auto (by chart timeframe)", "1-3-1 on this chart's candles", "3-2-2 on this chart's candles", "Lower-TF projection (12H/6H + 1H setups)"], group = gM,
     tooltip = "Auto: 1H chart → 3-2-2 · above 1H → 1-3-1 · under 1H → projection of the higher-timeframe setups.")
spxIn = input.string("Auto (ticker = SPX)", "SPX rules", options = ["Auto (ticker = SPX)", "Yes — treat as SPX", "No"], group = gM,
     tooltip = "SPX has no pre-market: the 3-2-2 is disabled everywhere and the 1-3-1 only exists on the 6H (the 12H chart shows nothing).")
strict131  = input.bool(true, "1-3-1 requires the leading 1 bar", group = gM)
classic322 = input.bool(true, "3-2-2 only from the 8am → 9am ET bars", group = gM,
     tooltip = "The 3 bar must be the 8-9am ET hourly candle, the first 2 the 9-10am candle, and ONLY the 10am bar may fire the reversal.")
revWindow  = input.int(1, "3-2-2 reversal window (bars)", minval = 1, maxval = 3, group = gM,
     tooltip = "1 = the 10am bar only (no reversal inside that hour = cancelled).")

// ─────────────────────────────── ② Display ─────────────────────────────────
gD = "② Display"
show131Lv  = input.bool(false, "Also draw 1-3-1 level lines on the 12H/6H chart", group = gD,
     tooltip = "OFF by default to keep the chart clean — the yellow 1 3 1 + score marks are the highlight. Levels always draw in projection mode.")
hiSize     = input.string("Large", "Pattern highlight size", options = ["Normal", "Large", "Huge"], group = gD)
showPanel  = input.bool(true, "Status panel", inline = "p", group = gD)
panelPos   = input.string("Top right", "", options = ["Top right", "Top left", "Bottom right", "Bottom left"], inline = "p", group = gD)
panelSize  = input.string("Medium", "Panel size", options = ["Small", "Medium", "Large"], group = gD)
colBull = input.color(#26a69a, "Calls / up",  inline = "c1", group = gD)
colBear = input.color(#ef5350, "Puts / down", inline = "c1", group = gD)
colLine = input.color(#ff9800, "50% entry",   inline = "c2", group = gD)
colHi   = input.color(#ffd54f, "Pattern numbers", inline = "c2", group = gD)

// ─────────────────────────────── ③ Alerts ──────────────────────────────────
gA = "③ Alerts"
useAlertFn = input.bool(true, "Master switch — send alert() events", group = gA,
     tooltip = "Create ONE alert per ticker with 'Any alert() function call' (best on the 5m chart, where both strats are watched). Pick the events below in ④.")
tz = input.string("America/New_York", "Timezone", group = gA)

gAE = "④ All-in-one alert — events it sends"
aOn131Setup = input.bool(true,  "1-3-1 · setup detected (overnight close)", group = gAE)
aOn131Conf  = input.bool(true,  "1-3-1 · CONFIRMED at the open + direction/entry/TP", group = gAE)
aOn131Cxl   = input.bool(true,  "1-3-1 · cancelled (pre-market hit the 50%)", group = gAE)
aOn131Entry = input.bool(true,  "1-3-1 · entry (50%) hit", group = gAE)
aOn322Watch = input.bool(true,  "3-2-2 · potential (3 then 2 closed)", group = gAE)
aOn322Trig  = input.bool(true,  "3-2-2 · reversal TRIGGERED", group = gAE)
aOn322Cxl   = input.bool(false, "3-2-2 · cancelled (continuation / no reversal)", group = gAE)

// ─────────────────────────────── Helpers ───────────────────────────────────
stratType(pH, pL, cH, cL) =>
    up = cH > pH
    dn = cL < pL
    up and dn ? 3 : up ? 2 : dn ? -2 : 1

fmt(x) =>
    str.tostring(x, format.mintick)

cDim   = color.new(#787b86, 0)
cSoft  = color.new(#b2b5be, 0)
tickSz = syminfo.mintick
mNow   = hour(time, tz) * 60 + minute(time, tz)
szHi   = hiSize == "Normal" ? size.normal : hiSize == "Huge" ? size.huge : size.large

// ─────────────────────────────── Mode flags ────────────────────────────────
tfM    = timeframe.isminutes ? timeframe.multiplier : 999
autoM  = detectMode == "Auto (by chart timeframe)"
isSPX  = spxIn == "Yes — treat as SPX" or (spxIn == "Auto (ticker = SPX)" and syminfo.ticker == "SPX")
nat322 = (detectMode == "3-2-2 on this chart's candles" or (autoM and tfM == 60)) and not isSPX
nat131 = (detectMode == "1-3-1 on this chart's candles" or (autoM and tfM > 60)) and (not isSPX or tfM == 360)
projOn = detectMode == "Lower-TF projection (12H/6H + 1H setups)" or (autoM and tfM < 60)

// ─────────── Pattern series (evaluated on ANY context, incl. HTF) ──────────
ty = stratType(high[1], low[1], high, low)

pat131 = ty == 1 and ty[1] == 3 and (not strict131 or ty[2] == 1)
mid_   = (high + low) / 2

okHrs = not classic322 or (hour(time[1], tz) == 8 and hour(time, tz) == 9)
patL  = ty == -2 and ty[1] == 3 and okHrs and high[1] > high + tickSz
patS  = ty == 2  and ty[1] == 3 and okHrs and low[1]  < low  - tickSz
trigV = patL ? high + tickSz : patS ? low - tickSz : na
stopV = patL ? low : patS ? high : na
targV = patL ? high[1] : patS ? low[1] : na

// panel state
var string st131p = "Waiting for a 1-3-1"
var color  c131p  = cDim
var string st322p = "Waiting for a 3 → 2"
var color  c322p  = cDim

// ═════════════════════ NATIVE 1-3-1 (12H / 6H chart) ═══════════════════════
is131 = nat131 and pat131

var float m131 = na
var float h131 = na
var float l131 = na
var int   b131 = na
var int   sc131 = 0        // scoring: 0 idle · 1 pre-mkt · 2/3 short/long wait · 4/5 in trade

if is131 and barstate.isconfirmed
    m131 := mid_
    h131 := high
    l131 := low
    b131 := bar_index
    sc131 := 1
    st131p := "SETUP ✓ · 50% " + fmt(m131)
    c131p  := colLine
    // the clean highlight: yellow 1 3 1 over the three candles
    label.new(bar_index - 2, high[2] + (high[2] - low[2]) * 0.25, "1", style = label.style_none, textcolor = colHi, size = szHi)
    label.new(bar_index - 1, high[1] + (high[1] - low[1]) * 0.25, "3", style = label.style_none, textcolor = colHi, size = szHi)
    label.new(bar_index,     high + (high - low) * 0.25,          "1", style = label.style_none, textcolor = colHi, size = szHi)
    if show131Lv
        line.new(bar_index, m131, bar_index + 3, m131, color = colLine, width = 2, style = line.style_dashed)
        line.new(bar_index, h131, bar_index + 3, h131, color = colBull, style = line.style_dotted)
        line.new(bar_index, l131, bar_index + 3, l131, color = colBear, style = line.style_dotted)
    if useAlertFn and aOn131Setup and barstate.isrealtime
        alert("📐 1-3-1 on " + syminfo.ticker + " " + timeframe.period + " — 50% line " + fmt(m131) + ". Open ABOVE → puts, PT " + fmt(l131) + ". Open BELOW → calls, PT " + fmt(h131) + ". Pre-market must NOT touch the 50%.", alert.freq_once_per_bar_close)

// ── sequenced scoring of the next session, via lower-timeframe sub-bars ────
ltTF = tfM >= 360 ? "15" : "1"
[ltT, ltO, ltH, ltL] = request.security_lower_tf(syminfo.tickerid, ltTF, [time, open, high, low])

if nat131 and sc131 != 0 and barstate.isconfirmed and not na(b131) and bar_index > b131
    res = 0    // 1 cancelled · 2 won · 3 lost · 4 no fill · 5 flat at close
    n = array.size(ltT)
    if n > 0
        for j = 0 to n - 1
            mn = hour(array.get(ltT, j), tz) * 60 + minute(array.get(ltT, j), tz)
            oj = array.get(ltO, j)
            hj = array.get(ltH, j)
            lj = array.get(ltL, j)
            if sc131 == 1
                if mn < 570
                    if hj >= m131 and lj <= m131
                        res := 1
                        sc131 := 0
                        break
                else
                    sc131 := oj > m131 ? 2 : 3
            if sc131 == 2 or sc131 == 3
                if mn >= 960
                    res := 4
                    sc131 := 0
                    break
                if sc131 == 2 ? lj <= m131 : hj >= m131
                    sc131 := sc131 == 2 ? 4 : 5
            if sc131 == 4 or sc131 == 5
                if mn >= 960
                    res := 5
                    sc131 := 0
                    break
                ptHit = sc131 == 4 ? lj <= l131 : hj >= h131
                stHit = sc131 == 4 ? hj >= h131 : lj <= l131
                if ptHit and not stHit
                    res := 2
                    sc131 := 0
                    break
                else if stHit
                    res := 3
                    sc131 := 0
                    break
    if bar_index > b131 + 6
        sc131 := 0
    if res != 0
        oTxt = res == 1 ? "✕" : res == 2 ? "✓" : res == 3 ? "✗" : res == 4 ? "∅" : "—"
        oCol = res == 2 ? colBull : res == 3 ? colBear : color.new(#787b86, 30)
        oTip = res == 1 ? "Cancelled — pre-market hit the 50% line." : res == 2 ? "Worked — 50% filled after the open and the PT was hit. (Becoming a 3 later doesn't matter: in and out first.)" : res == 3 ? "Failed — the stop side was hit before the PT." : res == 4 ? "No fill — price never came back to the 50%." : "Entered, but neither PT nor stop by the close."
        label.new(bar_index, high, oTxt, style = label.style_label_down, color = color.new(oCol, 25), textcolor = color.white, size = size.small, tooltip = oTip)
        st131p := res == 1 ? "Cancelled ✕ pre-market" : res == 2 ? "Last setup ✓ worked" : res == 3 ? "Last setup ✗ failed" : res == 4 ? "Last setup ∅ no fill" : "Last setup — flat at close"
        c131p  := oCol

// ═════════════════════ NATIVE 3-2-2 (1H chart) ═════════════════════════════
armL   = nat322 and patL
armS   = nat322 and patS
newArm = armL or armS

var int   dir322  = 0
var float trig322 = na
var float stop322 = na
var float targ322 = na
var int   armBar  = na
var bool  done322 = false
var bool  out322  = false

if newArm and barstate.isconfirmed
    dir322  := armL ? 1 : -1
    trig322 := trigV
    stop322 := stopV
    targ322 := targV
    armBar  := bar_index
    done322 := false
    out322  := false
    st322p := (armL ? "WATCHING ▲ · entry " : "WATCHING ▼ · entry ") + fmt(trig322)
    c322p  := colLine
    line.new(bar_index, trig322, bar_index + revWindow, trig322, color = color.new(color.blue, 0), width = 2)
    line.new(bar_index, targ322, bar_index + revWindow, targ322, color = armL ? colBull : colBear, style = line.style_dotted)
    if useAlertFn and aOn322Watch and barstate.isrealtime
        alert("👀 POTENTIAL 3-2-2 on " + syminfo.ticker + " — 3 then 2 closed. The 10am bar must reverse: entry " + fmt(trig322) + " | PT " + fmt(targ322) + " | continuation past " + fmt(stop322) + " cancels.", alert.freq_once_per_bar_close)

liveWin  = dir322 != 0 and not done322 and not na(armBar) and bar_index > armBar and bar_index <= armBar + revWindow
hitTrigL = liveWin and (dir322 > 0 ? high >= trig322 : low <= trig322)
hitStopL = liveWin and (dir322 > 0 ? low <= stop322 : high >= stop322)

varip bool stopFirst = false
varip int  stopRef   = -1
if barstate.isrealtime and liveWin
    if stopRef != armBar
        stopRef   := armBar
        stopFirst := false
    if hitStopL and not hitTrigL
        stopFirst := true

condTrig   = hitTrigL and not stopFirst
condCancel = hitStopL and not (dir322 > 0 ? high >= trig322 : low <= trig322)

varip int aTrigRef = -1
varip int aCanRef  = -1
if useAlertFn and barstate.isrealtime
    if aOn322Trig and condTrig and aTrigRef != armBar
        aTrigRef := armBar
        alert("🚨 3-2-2 REVERSAL TRIGGERED — " + syminfo.ticker + " " + (dir322 > 0 ? "CALLS ▲" : "PUTS ▼") + " @ " + fmt(close) + " | PT " + fmt(targ322) + " | Stop " + fmt(stop322), alert.freq_all)
    if aOn322Cxl and condCancel and aCanRef != armBar
        aCanRef := armBar
        alert("❌ 3-2-2 CANCELLED — " + syminfo.ticker + ": continuation broke " + fmt(stop322) + " first. Reversals only.", alert.freq_all)

if liveWin and barstate.isconfirmed
    hitT = dir322 > 0 ? high >= trig322 : low <= trig322
    hitS = dir322 > 0 ? low <= stop322 : high >= stop322
    if hitT and not hitS
        done322 := true
        out322  := true
        st322p := (dir322 > 0 ? "TRIGGERED ▲ · PT " : "TRIGGERED ▼ · PT ") + fmt(targ322)
        c322p  := dir322 > 0 ? colBull : colBear
        o3 = bar_index - (armBar - 1)
        o2 = bar_index - armBar
        label.new(armBar - 1, high[o3] + (high[o3] - low[o3]) * 0.3, "3", style = label.style_none, textcolor = colHi, size = szHi)
        label.new(armBar,     high[o2] + (high[o2] - low[o2]) * 0.3, "2", style = label.style_none, textcolor = colHi, size = szHi)
        label.new(bar_index,  high + (high - low) * 0.3,             "2", style = label.style_none, textcolor = colHi, size = szHi)
    else if hitS
        done322 := true
        st322p := "Cancelled ✕ · continuation first"
        c322p  := cDim
        label.new(bar_index, dir322 > 0 ? low : high, "✕", style = dir322 > 0 ? label.style_label_up : label.style_label_down, color = color.new(#787b86, 45), textcolor = color.white, size = size.tiny,
             tooltip = "3-2-2 cancelled — continuation broke first (or both sides in one bar). Reversals only.")
    else if bar_index >= armBar + revWindow
        done322 := true
        st322p := "Cancelled · no reversal in the 10am bar"
        c322p  := cDim
        label.new(bar_index, high, "✕", style = label.style_label_down, color = color.new(#787b86, 45), textcolor = color.white, size = size.tiny,
             tooltip = "3-2-2 cancelled — the 10am bar did not reverse the 9am 2 bar.")

if out322 and barstate.isconfirmed
    hitP = dir322 > 0 ? high >= targ322 : low <= targ322
    hitX = bar_index > armBar + revWindow and (dir322 > 0 ? low <= stop322 : high >= stop322)
    eod  = hour(time, tz) >= 16
    if hitP
        out322 := false
        label.new(bar_index, high, "✓", style = label.style_label_down, color = color.new(colBull, 25), textcolor = color.white, size = size.small, tooltip = "3-2-2 worked — PT (the 3 bar's outside) hit.")
        st322p := "Last 3-2-2 ✓ worked"
        c322p  := colBull
    else if hitX
        out322 := false
        label.new(bar_index, low, "✗", style = label.style_label_up, color = color.new(colBear, 25), textcolor = color.white, size = size.small, tooltip = "3-2-2 failed — the 9am extreme hit before the PT.")
        st322p := "Last 3-2-2 ✗ stopped"
        c322p  := colBear
    else if eod
        out322 := false
        label.new(bar_index, high, "—", style = label.style_label_down, color = color.new(#787b86, 35), textcolor = color.white, size = size.small, tooltip = "3-2-2 — neither PT nor stop by the close.")

// ════════════ LOWER-TF PROJECTION (5m etc.) + ALL-IN-ONE ALERT HOME ════════
projTF = isSPX ? "360" : "720"

[q131, qMidS, qHS, qLS, qTS] = request.security(syminfo.tickerid, projTF, [pat131[1], mid_[1], high[1], low[1], time[1]], lookahead = barmerge.lookahead_on)
[wLS, wSS, wTrigS, wStopS, wTargS, wTS] = request.security(syminfo.tickerid, "60", [patL[1], patS[1], trigV[1], stopV[1], targV[1], time[1]], lookahead = barmerge.lookahead_on)

// ── projected 1-3-1 ── state: 1 pre-open · 2 puts side · 3 calls side ──────
var int   pjKey   = na
var int   pjState = 0
var float pjMid = na
var float pjH   = na
var float pjL   = na
var line  lnMid = na
var line  lnUp  = na
var line  lnDn  = na
var label pjLab = na

bool evPjSetup = false
bool evPjDead  = false
bool evPjDir   = false
bool evPjEntry = false

if projOn and q131 and (na(pjKey) or qTS != pjKey)
    pjKey := qTS
    pjMid := qMidS
    pjH   := qHS
    pjL   := qLS
    line.delete(lnMid)
    line.delete(lnUp)
    line.delete(lnDn)
    label.delete(pjLab)
    lnMid := line.new(bar_index, pjMid, bar_index + 1, pjMid, extend = extend.right, color = colLine, width = 2, style = line.style_dashed)
    lnUp  := line.new(bar_index, pjH, bar_index + 1, pjH, extend = extend.right, color = colBull, style = line.style_dotted)
    lnDn  := line.new(bar_index, pjL, bar_index + 1, pjL, extend = extend.right, color = colBear, style = line.style_dotted)
    if mNow < 570
        pjState := 1
        evPjSetup := true
        pjLab := label.new(bar_index, pjMid, (isSPX ? "6H" : "12H") + " 1-3-1 · 50% " + fmt(pjMid), style = label.style_label_left, color = color.new(colLine, 25), textcolor = color.white, size = size.small,
             tooltip = "Pre-market: touching the 50% cancels it.\nAt the open: above 50% → puts to " + fmt(pjL) + " · below → calls to " + fmt(pjH))
        st131p := "Pre-open · 50% " + fmt(pjMid) + " · don't touch it"
        c131p  := colLine
    else
        goShort = open > pjMid
        pjState := goShort ? 2 : 3
        evPjDir := true
        line.delete(goShort ? lnUp : lnDn)
        pjLab := label.new(bar_index, pjMid, goShort ? "PUTS ▼ · entry " + fmt(pjMid) + " · PT " + fmt(pjL) : "CALLS ▲ · entry " + fmt(pjMid) + " · PT " + fmt(pjH), style = label.style_label_left, color = color.new(goShort ? colBear : colBull, 20), textcolor = color.white, size = size.small)
        st131p := goShort ? "PUTS ▼ · entry " + fmt(pjMid) : "CALLS ▲ · entry " + fmt(pjMid)
        c131p  := goShort ? colBear : colBull

if pjState == 1
    if mNow < 570
        if high >= pjMid and low <= pjMid
            pjState := -1
            evPjDead := true
            line.delete(lnMid)
            line.delete(lnUp)
            line.delete(lnDn)
            label.delete(pjLab)
            label.new(bar_index, pjMid, "1-3-1 ✕", style = label.style_label_down, color = color.new(#787b86, 40), textcolor = color.white, size = size.small,
                 tooltip = "Cancelled — pre-market hit the 50% line.")
            st131p := "Cancelled ✕ · pre-market hit the 50%"
            c131p  := cDim
    else
        goShort = open > pjMid
        pjState := goShort ? 2 : 3
        evPjDir := true
        line.delete(goShort ? lnUp : lnDn)
        label.delete(pjLab)
        pjLab := label.new(bar_index, pjMid, goShort ? "PUTS ▼ · entry " + fmt(pjMid) + " · PT " + fmt(pjL) : "CALLS ▲ · entry " + fmt(pjMid) + " · PT " + fmt(pjH), style = label.style_label_left, color = color.new(goShort ? colBear : colBull, 20), textcolor = color.white, size = size.small)
        st131p := goShort ? "PUTS ▼ · entry " + fmt(pjMid) : "CALLS ▲ · entry " + fmt(pjMid)
        c131p  := goShort ? colBear : colBull

evPjEntry := (pjState == 2 or pjState == 3) and high >= pjMid and low <= pjMid

if pjState > 0 and mNow >= 960
    pjState := 0
    line.delete(lnMid)
    line.delete(lnUp)
    line.delete(lnDn)
    label.delete(pjLab)

varip int aSetRef = -1
varip int aDirRef = -1
varip int aEntRef = -1
varip int aDedRef = -1
if useAlertFn and barstate.isrealtime and projOn
    if aOn131Setup and evPjSetup and aSetRef != pjKey
        aSetRef := pjKey
        alert("📐 1-3-1 SETUP for today — " + syminfo.ticker + " (" + (isSPX ? "6H" : "12H") + "): 50% " + fmt(pjMid) + " · puts PT " + fmt(pjL) + " · calls PT " + fmt(pjH) + ". Pre-market must NOT touch the 50%.", alert.freq_all)
    if aOn131Conf and evPjDir and aDirRef != pjKey
        aDirRef := pjKey
        alert("✅ 1-3-1 CONFIRMED at the open — " + syminfo.ticker + ": pre-market never touched the 50%. " + (pjState == 2 ? "PUTS ▼ · entry 50% " + fmt(pjMid) + " · TP " + fmt(pjL) : "CALLS ▲ · entry 50% " + fmt(pjMid) + " · TP " + fmt(pjH)), alert.freq_all)
    if aOn131Entry and evPjEntry and aEntRef != pjKey
        aEntRef := pjKey
        alert("🎯 1-3-1 ENTRY HIT — " + syminfo.ticker + " @ 50% " + fmt(pjMid) + " · TP " + fmt(pjState == 2 ? pjL : pjH), alert.freq_all)
    if aOn131Cxl and evPjDead and aDedRef != pjKey
        aDedRef := pjKey
        alert("❌ 1-3-1 CANCELLED — " + syminfo.ticker + ": pre-market hit the 50% line " + fmt(pjMid) + ". No trade today.", alert.freq_all)

// ── projected 3-2-2 (from the 1H) ── active only during the 10am hour ──────
var int   wKey   = na
var int   wState = 0
var bool  wUp    = false
var float wTrig = na
var float wStop = na
var float wTarg = na
var line  lnT = na
var line  lnP = na
var label wLab = na

bool evWWatch = false
bool evWTrig  = false
bool evWCan   = false

wActive = projOn and not isSPX and (wLS or wSS)

if wActive and (na(wKey) or wTS != wKey)
    wKey  := wTS
    wUp   := wLS
    wTrig := wTrigS
    wStop := wStopS
    wTarg := wTargS
    wState := 1
    evWWatch := true
    line.delete(lnT)
    line.delete(lnP)
    label.delete(wLab)
    lnT := line.new(bar_index, wTrig, bar_index + 1, wTrig, extend = extend.right, color = color.new(color.blue, 0), width = 2)
    lnP := line.new(bar_index, wTarg, bar_index + 1, wTarg, extend = extend.right, color = wUp ? colBull : colBear, style = line.style_dotted)
    wLab := label.new(bar_index, wTrig, "3-2-2? · entry " + fmt(wTrig) + " · PT " + fmt(wTarg), style = label.style_label_left, color = color.new(color.blue, 30), textcolor = color.white, size = size.small,
         tooltip = "The 10am bar must reverse the 9am 2 bar.\nEntry " + fmt(wTrig) + " · PT " + fmt(wTarg) + "\nContinuation past " + fmt(wStop) + " cancels.")
    st322p := "WATCHING " + (wUp ? "▲" : "▼") + " · entry " + fmt(wTrig)
    c322p  := colLine

if wState == 1
    if not wActive
        wState := 0
        line.delete(lnT)
        line.delete(lnP)
        label.delete(wLab)
        st322p := "Cancelled · no reversal in the 10am bar"
        c322p  := cDim
    else if wUp ? low <= wStop : high >= wStop
        wState := -1
        evWCan := true
        line.delete(lnT)
        line.delete(lnP)
        label.delete(wLab)
        label.new(bar_index, wUp ? low : high, "✕", style = wUp ? label.style_label_up : label.style_label_down, color = color.new(#787b86, 45), textcolor = color.white, size = size.tiny, tooltip = "3-2-2 cancelled — continuation broke first.")
        st322p := "Cancelled ✕ · continuation first"
        c322p  := cDim
    else if wUp ? high >= wTrig : low <= wTrig
        wState := 2
        evWTrig := true
        label.delete(wLab)
        wLab := label.new(bar_index, wTrig, "3-2-2 " + (wUp ? "▲" : "▼") + " · PT " + fmt(wTarg), style = wUp ? label.style_label_up : label.style_label_down, color = color.new(wUp ? colBull : colBear, 15), textcolor = color.white, size = size.small)
        st322p := "TRIGGERED " + (wUp ? "▲" : "▼") + " · PT " + fmt(wTarg)
        c322p  := wUp ? colBull : colBear

if wState == 2 and (mNow >= 960 or not projOn)
    wState := 0
    line.delete(lnT)
    line.delete(lnP)
    label.delete(wLab)

varip int aWWRef = -1
varip int aWTRef = -1
varip int aWCRef = -1
if useAlertFn and barstate.isrealtime and projOn
    if aOn322Watch and evWWatch and aWWRef != wKey
        aWWRef := wKey
        alert("👀 POTENTIAL 3-2-2 — " + syminfo.ticker + ": 3 then 2 closed. The 10am bar must reverse. Entry " + fmt(wTrig) + " · PT " + fmt(wTarg) + " · continuation past " + fmt(wStop) + " cancels.", alert.freq_all)
    if aOn322Trig and evWTrig and aWTRef != wKey
        aWTRef := wKey
        alert("🚨 3-2-2 REVERSAL TRIGGERED — " + syminfo.ticker + " " + (wUp ? "CALLS ▲" : "PUTS ▼") + " @ " + fmt(close) + " · PT " + fmt(wTarg), alert.freq_all)
    if aOn322Cxl and evWCan and aWCRef != wKey
        aWCRef := wKey
        alert("❌ 3-2-2 CANCELLED — " + syminfo.ticker + ": continuation broke " + fmt(wStop) + " first.", alert.freq_all)

// ══════════════════ Hidden plots → alert-message placeholders ══════════════
plot(projOn ? pjMid : m131,    "131 mid",     display = display.none)
plot(projOn ? pjH : h131,      "131 high",    display = display.none)
plot(projOn ? pjL : l131,      "131 low",     display = display.none)
plot(projOn ? wTrig : trig322, "322 trigger", display = display.none)
plot(projOn ? wTarg : targ322, "322 target",  display = display.none)
plot(projOn ? wStop : stop322, "322 stop",    display = display.none)

// ═══ Classic per-event alert conditions (optional — for webhook routing) ═══
alertcondition(is131,      "1-3-1 setup  →  set: Once Per Bar Close",
     "1-3-1 detected for {{ticker}} ({{interval}}). 50% Trigger: {{plot(\"131 mid\")}}. If we open above {{plot(\"131 mid\")}} first PT is {{plot(\"131 low\")}} (puts). If we open below {{plot(\"131 mid\")}} first PT is {{plot(\"131 high\")}} (calls).")
alertcondition(newArm,     "3-2-2 armed (watching)  →  set: Once Per Bar Close",
     "3-2-2 WATCH on {{ticker}}: 3 then 2 closed. The 10am bar must reverse. Entry {{plot(\"322 trigger\")}} | PT {{plot(\"322 target\")}} | Cancel past {{plot(\"322 stop\")}}.")
alertcondition(condTrig,   "3-2-2 REVERSAL TRIGGERED  →  set: Once Per Bar",
     "🚨 3-2-2 REVERSAL FIRED on {{ticker}} at {{close}}. Entry {{plot(\"322 trigger\")}} | PT {{plot(\"322 target\")}} | Stop {{plot(\"322 stop\")}}.")
alertcondition(condCancel, "3-2-2 cancelled (continuation)  →  set: Once Per Bar",
     "❌ 3-2-2 CANCELLED on {{ticker}} — continuation broke {{plot(\"322 stop\")}} first. No trade.")
alertcondition(evPjSetup,  "PROJ: 1-3-1 setup detected  →  set: Once Per Bar",
     "📐 1-3-1 setup for today on {{ticker}} — 50% {{plot(\"131 mid\")}} · puts PT {{plot(\"131 low\")}} · calls PT {{plot(\"131 high\")}}. Pre-market must not touch the 50%.")
alertcondition(evPjDead,   "PROJ: 1-3-1 cancelled pre-market  →  set: Once Per Bar",
     "❌ 1-3-1 CANCELLED on {{ticker}} — pre-market hit the 50% line {{plot(\"131 mid\")}}.")
alertcondition(evPjDir,    "PROJ: 1-3-1 CONFIRMED at open  →  set: Once Per Bar",
     "✅ 1-3-1 CONFIRMED on {{ticker}} — entry 50% {{plot(\"131 mid\")}}. Above → puts PT {{plot(\"131 low\")}} · below → calls PT {{plot(\"131 high\")}}.")
alertcondition(evPjEntry,  "PROJ: 1-3-1 entry (50%) hit  →  set: Once Per Bar",
     "🎯 1-3-1 ENTRY HIT on {{ticker}} @ {{plot(\"131 mid\")}}.")
alertcondition(evWWatch,   "PROJ: potential 3-2-2  →  set: Once Per Bar",
     "👀 Potential 3-2-2 on {{ticker}} — entry {{plot(\"322 trigger\")}} · PT {{plot(\"322 target\")}}.")
alertcondition(evWTrig,    "PROJ: 3-2-2 reversal triggered  →  set: Once Per Bar",
     "🚨 3-2-2 REVERSAL FIRED on {{ticker}} at {{close}} — PT {{plot(\"322 target\")}}.")
alertcondition(evWCan,     "PROJ: 3-2-2 cancelled  →  set: Once Per Bar",
     "❌ 3-2-2 CANCELLED on {{ticker}} — continuation first.")

// ═══════════════════════════ Status panel ══════════════════════════════════
posP = panelPos == "Top right" ? position.top_right : panelPos == "Top left" ? position.top_left : panelPos == "Bottom right" ? position.bottom_right : position.bottom_left
szP  = panelSize == "Small" ? size.tiny : panelSize == "Large" ? size.normal : size.small

var table pan = table.new(posP, 2, 4, frame_width = 1, frame_color = color.new(#787b86, 60), border_width = 1, border_color = color.new(#787b86, 85))
if barstate.isfirst
    table.merge_cells(pan, 0, 0, 1, 0)
    table.merge_cells(pan, 0, 3, 1, 3)

if showPanel and barstate.islast
    hdrBg = #1e222d
    rowBg = #131722
    ethWarn = syminfo.session != session.extended and not isSPX and (nat322 or nat131 or projOn)
    footTxt = isSPX and tfM == 720 ? "SPX → use the 6H chart (12H is off)" : ethWarn ? "⚠ TURN ON EXTENDED HOURS" : projOn ? "Projecting " + (isSPX ? "6H 1-3-1" : "12H 1-3-1 + 1H 3-2-2") + " · all-in-one alert home" : nat322 ? "3-2-2 · 1H candles" : nat131 ? "1-3-1 · " + timeframe.period + " candles" : isSPX ? "SPX: no 3-2-2 (no pre-market)" : "Off on this timeframe"
    footCol = ethWarn or isSPX and tfM == 720 ? color.new(#ffb74d, 0) : color.new(#787b86, 10)
    table.cell(pan, 0, 0, "THE STRAT · " + syminfo.ticker, text_color = color.white, text_size = szP, bgcolor = hdrBg, text_halign = text.align_center)
    table.cell(pan, 0, 1, "1-3-1", text_color = cSoft, text_size = szP, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(pan, 1, 1, nat131 or projOn ? st131p : "Off here", text_color = nat131 or projOn ? c131p : cDim, text_size = szP, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(pan, 0, 2, "3-2-2", text_color = cSoft, text_size = szP, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(pan, 1, 2, nat322 or projOn and not isSPX ? st322p : "Off here", text_color = nat322 or projOn and not isSPX ? c322p : cDim, text_size = szP, bgcolor = rowBg, text_halign = text.align_left)
    table.cell(pan, 0, 3, footTxt, text_color = footCol, text_size = size.tiny, bgcolor = rowBg, text_halign = text.align_center)
````
