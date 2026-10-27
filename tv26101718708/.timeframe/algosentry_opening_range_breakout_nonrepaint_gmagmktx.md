# AlgoSentry Opening Range Breakout [Non-Repaint]

- url: https://www.tradingview.com/script/gmAGMKtX-AlgoSentry-Opening-Range-Breakout-Non-Repaint/
- type: indicator
- pine_id: PUB;1e55a8a571ea487ea6b9b403360e2694
- version: 1.0

## Description

The Opening Range is the high and low of the first minutes of a session. This indicator maps that range and then tracks the classic Break -> Retest -> Trend sequence that opening-range traders watch — built non-repaint from the ground up.

How it works
Once your opening window closes, the range high and low freeze. From there the script tracks three events:

• Break — the first candle to CLOSE beyond the frozen range, confirmed on the timeframe you choose (chart, 5m, 10m, or 15m). Higher confirmation = fewer fakeouts, later signal.
• Retest — the first pullback that taps an enabled zone: the broken edge, a percent level inside the range, or the session volume Point of Control.
• Trend — the first re-close beyond the range after the retest, marking continuation.

Why non-repaint matters here
Most "breakout" tools look perfect on history because they quietly use future data or redraw as you scroll. This one does not:

• The range freezes at session close and never moves.
• The volume Point of Control is computed once, over a fixed time window — no visible-range tricks, so it never shifts when you scroll or zoom.
• Every signal is committed on bar close.
• Higher-timeframe confirmation is read only after the higher-timeframe candle has closed (lookahead off).

What you saw in real time is what stays on the chart.

Settings
• Opening range session and timezone (default 09:30-09:45, exchange time).
• Confirmation timeframe for the breakout.
• Three retest zones — broken edge, percent of range, and volume Point of Control — each can be toggled on or off.
• Volume POC window: the opening range itself, or the full trading day.
• A compact dashboard shows session state, range size, the live Break/Retest/Trend state, the confirmation timeframe, and the volume POC level.

Every parameter is an input, and every filter can be turned on or off, so you can adapt the tool to your own market and style. It is designed for index futures on intraday charts (1-5 minute), but works on any symbol — validate it on your own instrument and timeframe before relying on it.

A note on honesty
Opening-range breakout is a well-known, widely-published concept. This tool does not invent an edge or promise results — it gives you a clean, disciplined, non-repaint way to see the sequence and study how it actually behaves on your charts.

Educational and informational use only. This is not financial advice, and nothing here is a recommendation to buy or sell. Past or hypothetical behavior does not predict future results. Always test thoroughly before trading.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  AlgoSentry — Opening Range Breakout  [v1]
//  Free educational indicator · In-sample lies. Out-of-sample is truth.
//
//  WHAT IT DOES
//  Marks the Opening Range (the first minutes of a chosen session), then tracks
//  the classic Break -> Retest -> Trend sequence:
//    BREAK   first confirmed close beyond the frozen range (on your chosen TF)
//    RETEST  first pullback that taps an enabled zone — the broken edge, a % level
//            inside the range, or the session volume POC (point of control)
//    TREND   first re-close beyond the range after the retest (continuation)
//
//  NON-REPAINT BY DESIGN
//  - The range FREEZES when the session ends and never changes afterwards.
//  - The volume POC is computed ONCE, over a FIXED time window, the moment the
//    range closes — no visible-range, no lookahead -> it never shifts on scroll.
//  - Every signal is committed on BAR CLOSE (barstate.isconfirmed).
//  - Higher-TF confirmation uses request.security with lookahead_off, read only
//    after the HTF bar has closed. Nothing is painted on unconfirmed data.
//
//  Original work. Validate across instruments/timeframes — do not tune to one chart.
// ════════════════════════════════════════════════════════════════════════════
indicator("AlgoSentry Opening Range Breakout [Non-Repaint]", "AlgoSentry Opening Range Breakout", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 100, max_bars_back = 500)

// ── AlgoSentry brand palette ────────────────────────────────────────────────
color AS_MAGENTA = #E61EB4
color AS_GREEN   = #8CE800
color AS_CYAN    = #00E5FF
color AS_GOLD    = #FF9410
color AS_RED     = #FF2D6B
color AS_DIM     = #6B7280
color AS_NAVY    = #0E1226
color AS_WHITE   = #EAF0FA
color AS_TEAL    = #1DE9B6

// ── Inputs · Opening Range ──────────────────────────────────────────────────
grpS = "Opening Range"
orSession   = input.session("0930-0945", "Opening range session", group = grpS, tooltip = "The opening window whose high/low define the range. Default 09:30-09:45 (US cash open).")
useExchTz   = input.bool(true, "Use exchange timezone", group = grpS)
utcOffset   = input.int(-5, "UTC offset (if not exchange)", minval = -12, maxval = 14, group = grpS)
showRange   = input.bool(true,  "Show range box", group = grpS)
showPoints  = input.bool(true,  "Show range size", group = grpS)
extendRight = input.bool(true,  "Extend range across the day", group = grpS)

// ── Inputs · Breakout ───────────────────────────────────────────────────────
grpB = "Breakout"
confTF    = input.string("5", "Confirmation timeframe", options = ["Chart", "5", "10", "15"], group = grpB, tooltip = "The candle that must CLOSE beyond the range to confirm a break. Higher = fewer fakeouts, later signal.")
allowBoth = input.bool(false, "Allow both directions in one session", group = grpB)

// ── Inputs · Retest -> Trend ────────────────────────────────────────────────
grpR = "Retest to Trend"
enRetest   = input.bool(true,  "Enable Retest -> Trend sequence", group = grpR)
enBreakBox = input.bool(true,  "Retest zone: broken edge", group = grpR)
enPct      = input.bool(true,  "Retest zone: % inside range", group = grpR)
retPct     = input.float(25.0, "Retest depth (% of range)", minval = 0.1, maxval = 100, step = 1, group = grpR)
enSVP      = input.bool(true,  "Retest zone: volume POC", group = grpR)
svpMode    = input.string("Opening Range", "Volume POC window", options = ["Opening Range", "Trading Day"], group = grpR, tooltip = "Window for the volume Point of Control. Opening Range = POC of the range itself. Trading Day = POC from the day's open to the range close.")
svpRows    = input.int(100, "Volume POC resolution (rows)", minval = 20, maxval = 250, step = 10, group = grpR)
maxBars    = input.int(120, "Max bars to track after range closes", minval = 5, group = grpR, tooltip = "Stop tracking the sequence this many bars after the range freezes.")
showZones  = input.bool(true,  "Show retest zones", group = grpR)

// ── Inputs · Visual ─────────────────────────────────────────────────────────
grpV = "Visual"
colUp     = input.color(AS_GREEN,   "Bullish",        group = grpV)
colDn     = input.color(AS_RED,     "Bearish",        group = grpV)
colBreak  = input.color(AS_CYAN,    "Break marker",   group = grpV)
colRet    = input.color(AS_GOLD,    "Retest marker",  group = grpV)
colBox    = input.color(AS_MAGENTA, "Range box",      group = grpV)
colPOC    = input.color(AS_TEAL,    "Volume POC",     group = grpV)
showPanel = input.bool(true, "Show AlgoSentry dashboard", group = grpV)

// ── Inputs · Alerts ─────────────────────────────────────────────────────────
grpA = "Alerts"
enAlerts = input.bool(true, "Enable alerts", group = grpA)

// Volume Point of Control over a FIXED [t0, t1] window. Pure + called ONCE per
// session (on close) -> never repaints, and the cost is paid once, not per bar.
f_poc(_rows, _t0, _t1) =>
    float poc = na
    if not (na(_t0) or na(_t1) or _t1 <= _t0)
        int lookback = math.min(500, bar_index + 1)
        float vmin = na
        float vmax = na
        for i = 0 to lookback - 1
            if time[i] >= _t0 and time[i] <= _t1
                vmin := na(vmin) ? low[i]  : math.min(vmin, low[i])
                vmax := na(vmax) ? high[i] : math.max(vmax, high[i])
        if not (na(vmin) or na(vmax) or vmax <= vmin)
            float step = (vmax - vmin) / _rows
            float[] bins = array.new_float(_rows, 0.0)
            for i = 0 to lookback - 1
                if time[i] >= _t0 and time[i] <= _t1
                    float v  = nz(volume[i], 0.0)
                    int   b0 = math.max(0, math.min(_rows - 1, int(math.floor((low[i]  - vmin) / step))))
                    int   b1 = math.max(0, math.min(_rows - 1, int(math.floor((high[i] - vmin) / step))))
                    float sh = v / math.max(1, b1 - b0 + 1)
                    for b = b0 to b1
                        bins.set(b, bins.get(b) + sh)
            float best = -1.0
            int   bi   = 0
            for j = 0 to _rows - 1
                if bins.get(j) > best
                    best := bins.get(j)
                    bi   := j
            poc := vmin + (bi + 0.5) * step
    poc

// ── Session detection ───────────────────────────────────────────────────────
tz = useExchTz ? syminfo.timezone : str.format("UTC{0}{1}", utcOffset >= 0 ? "+" : "-", math.abs(utcOffset))
inSes    = not na(time(timeframe.period, orSession, tz))
sesStart = inSes and not inSes[1]
sesEnd   = (not inSes) and inSes[1]

// ── Opening range: build during session, FREEZE on session close ────────────
var float rngHi    = na
var float rngLo    = na
var int   startBar = na
var int   endBar   = na
var int   orStartT = na
var bool  ready    = false        // true once the session has closed (range frozen)
var float svpPoc   = na           // volume POC, frozen at session close

// Break -> Retest -> Trend state (per direction)
var bool brokeUp = false
var bool brokeDn = false
var bool retUp   = false
var bool retDn   = false
var bool trUp    = false
var bool trDn    = false
var int  brkUpBar = na
var int  brkDnBar = na
var int  retUpBar = na
var int  retDnBar = na

if sesStart
    rngHi    := high
    rngLo    := low
    startBar := bar_index
    orStartT := time
    svpPoc   := na
    ready    := false
    brokeUp  := false
    brokeDn  := false
    retUp    := false
    retDn    := false
    trUp     := false
    trDn     := false
    brkUpBar := na
    brkDnBar := na
    retUpBar := na
    retDnBar := na
else if inSes
    rngHi := math.max(rngHi, high)
    rngLo := math.min(rngLo, low)

if sesEnd
    ready  := true
    endBar := bar_index - 1
    int   t0 = svpMode == "Trading Day" ? time("D") : orStartT
    int   t1 = time[1]
    float p  = enSVP ? f_poc(svpRows, t0, t1) : na
    // keep the POC only if it landed inside the frozen range (else it is not a retest level)
    svpPoc := (not na(p) and not na(rngHi) and not na(rngLo) and p >= rngLo and p <= rngHi) ? p : na

// Derived levels (valid only once the range exists)
rng    = (not na(rngHi) and not na(rngLo)) ? rngHi - rngLo : na
zPctUp = not na(rng) ? rngHi - rng * (retPct / 100.0) : na
zPctDn = not na(rng) ? rngLo + rng * (retPct / 100.0) : na
within = (not na(endBar)) and (bar_index - endBar <= maxBars)

// ── Range box ───────────────────────────────────────────────────────────────
var box rBox = na
if showRange and sesStart
    rBox := box.new(bar_index, high, bar_index, low, border_color = colBox, border_width = 1, bgcolor = color.new(colBox, 90))
else if showRange and inSes and not na(rBox)
    box.set_top(rBox, rngHi)
    box.set_bottom(rBox, rngLo)
    box.set_right(rBox, bar_index)
if showRange and ready and extendRight and not na(rBox)
    box.set_right(rBox, bar_index)

// Range size label (price height + ticks)
var label ptsLbl = na
if showPoints and sesEnd and not na(rng)
    txt = str.tostring(rng, format.mintick) + "  (" + str.tostring(math.round(rng / syminfo.mintick)) + " ticks)"
    ptsLbl := label.new(int(math.avg(startBar, endBar)), rngLo, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(AS_NAVY, 0), textcolor = AS_WHITE, size = size.small)

// ── Breakout confirmation (chart bar-close, or a CLOSED higher-TF candle) ─────
useChart = confTF == "Chart"
htfClose = request.security(syminfo.tickerid, useChart ? timeframe.period : confTF, close, lookahead = barmerge.lookahead_off)
htfTime  = request.security(syminfo.tickerid, useChart ? timeframe.period : confTF, time,  lookahead = barmerge.lookahead_off)
confClose = useChart ? close : htfClose
newConf   = useChart ? barstate.isconfirmed : (ta.change(htfTime) != 0)

canBreak   = ready and within and not na(rngHi) and not na(rngLo)
breakUpNow = canBreak and not brokeUp and (allowBoth or not brokeDn) and newConf and confClose > rngHi
breakDnNow = canBreak and not brokeDn and (allowBoth or not brokeUp) and newConf and confClose < rngLo

if breakUpNow
    brokeUp  := true
    brkUpBar := bar_index
if breakDnNow
    brokeDn  := true
    brkDnBar := bar_index

// ── Retest (first pullback that taps an enabled zone, bar-close) ─────────────
retUpTouch = (enBreakBox and low  <= rngHi) or (enPct and low  <= zPctUp) or (enSVP and not na(svpPoc) and low  <= svpPoc)
retDnTouch = (enBreakBox and high >= rngLo) or (enPct and high >= zPctDn) or (enSVP and not na(svpPoc) and high >= svpPoc)

retestUpNow = enRetest and brokeUp and not retUp and not trUp and barstate.isconfirmed and within and not na(brkUpBar) and bar_index > brkUpBar and retUpTouch
retestDnNow = enRetest and brokeDn and not retDn and not trDn and barstate.isconfirmed and within and not na(brkDnBar) and bar_index > brkDnBar and retDnTouch

if retestUpNow
    retUp    := true
    retUpBar := bar_index
if retestDnNow
    retDn    := true
    retDnBar := bar_index

// ── Trend (first re-close beyond the range AFTER the retest, bar-close) ──────
trendUpNow = enRetest and retUp and not trUp and barstate.isconfirmed and within and not na(retUpBar) and bar_index > retUpBar and close > rngHi
trendDnNow = enRetest and retDn and not trDn and barstate.isconfirmed and within and not na(retDnBar) and bar_index > retDnBar and close < rngLo

if trendUpNow
    trUp := true
if trendDnNow
    trDn := true

// Tint the range border once a side resolves
if breakUpNow and showRange and not na(rBox)
    box.set_border_color(rBox, colUp)
if breakDnNow and showRange and not na(rBox)
    box.set_border_color(rBox, colDn)

// ── Volume POC line (drawn once the range closes, extends while tracked) ─────
// POC value also shown in the dashboard ("Vol POC") -> no on-chart label needed.
var line pocLine = na
if sesStart and not na(pocLine)
    line.delete(pocLine)
    pocLine := na
if showZones and enSVP and sesEnd and not na(svpPoc)
    pocLine := line.new(endBar, svpPoc, bar_index, svpPoc, xloc = xloc.bar_index, color = colPOC, width = 2, style = line.style_dashed)
if not na(pocLine) and not trUp and not trDn and within
    line.set_x2(pocLine, bar_index)

// ── Retest zone band (optional, gold) ───────────────────────────────────────
var box bandUp = na
var box bandDn = na
if sesStart
    if not na(bandUp)
        box.delete(bandUp)
        bandUp := na
    if not na(bandDn)
        box.delete(bandDn)
        bandDn := na

if showZones and enRetest and (enBreakBox or enPct) and breakUpNow and not na(rng)
    rtU = enBreakBox ? rngHi : zPctUp     // broken edge (if enabled)
    rbU = enPct ? zPctUp : rngHi          // % level inside range (if enabled)
    bandUp := box.new(bar_index, math.max(rtU, rbU), bar_index, math.min(rtU, rbU), border_color = color.new(colRet, 40), border_width = 1, bgcolor = color.new(colRet, 86))
if not na(bandUp) and brokeUp and not trUp and within
    box.set_right(bandUp, bar_index)

if showZones and enRetest and (enBreakBox or enPct) and breakDnNow and not na(rng)
    rtD = enBreakBox ? rngLo : zPctDn     // broken edge (if enabled)
    rbD = enPct ? zPctDn : rngLo          // % level inside range (if enabled)
    bandDn := box.new(bar_index, math.max(rtD, rbD), bar_index, math.min(rtD, rbD), border_color = color.new(colRet, 40), border_width = 1, bgcolor = color.new(colRet, 86))
if not na(bandDn) and brokeDn and not trDn and within
    box.set_right(bandDn, bar_index)

// ── Markers — anchored to the BROKEN range edge, tiered so they never overlap ─
// The break is what matters, so each marker sits relative to the edge that was
// broken (not the random bar the HTF confirmation landed on): down events below
// rngLo, up events above rngHi, tiered 1/2/3 * pad -> fixed spacing, zero pileup.
pad = ta.atr(14) * 0.5
f_mark(_cond, _isDn, _tier, _txt, _col, _filled) =>
    if _cond
        float edge = _isDn ? rngLo : rngHi
        float y    = _isDn ? edge - pad * _tier : edge + pad * _tier
        if _filled
            label.new(bar_index, y, _txt, style = _isDn ? label.style_label_up : label.style_label_down, color = _col, textcolor = AS_NAVY, size = size.small)
        else
            label.new(bar_index, y, _txt, style = label.style_none, textcolor = _col, size = size.small)
f_mark(breakDnNow,  true,  1.0, "BREAK",  colBreak, false)
f_mark(retestDnNow, true,  2.0, "RETEST", colRet,   false)
f_mark(trendDnNow,  true,  3.0, "TREND",  colDn,    true)
f_mark(breakUpNow,  false, 1.0, "BREAK",  colBreak, false)
f_mark(retestUpNow, false, 2.0, "RETEST", colRet,   false)
f_mark(trendUpNow,  false, 3.0, "TREND",  colUp,    true)

// ── Alerts (non-repaint: conditions are bar-close / closed-HTF gated) ────────
alertcondition(enAlerts and breakUpNow,  "ORB Break Up",    "AlgoSentry ORB: BREAK up")
alertcondition(enAlerts and breakDnNow,  "ORB Break Down",  "AlgoSentry ORB: BREAK down")
alertcondition(enAlerts and retestUpNow, "ORB Retest Up",   "AlgoSentry ORB: RETEST (long side)")
alertcondition(enAlerts and retestDnNow, "ORB Retest Down", "AlgoSentry ORB: RETEST (short side)")
alertcondition(enAlerts and trendUpNow,  "ORB Trend Up",    "AlgoSentry ORB: TREND continuation up")
alertcondition(enAlerts and trendDnNow,  "ORB Trend Down",  "AlgoSentry ORB: TREND continuation down")

// ── AlgoSentry dashboard ────────────────────────────────────────────────────
var table panel = na
if showPanel and barstate.islast
    if na(panel)
        panel := table.new(position.top_right, 2, 7, border_width = 1, border_color = color.new(AS_DIM, 55), frame_width = 1, frame_color = color.new(AS_MAGENTA, 35))
    cBg     = color.new(AS_NAVY, 10)
    sesTxt  = inSes ? "OPEN" : ready ? "CLOSED" : "—"
    sesCol  = inSes ? AS_CYAN : AS_DIM
    rngTxt  = not na(rng) ? str.tostring(rng, format.mintick) : "—"
    state   = trUp ? "TREND UP" : trDn ? "TREND DOWN" : retUp ? "RETEST (long)" : retDn ? "RETEST (short)" : brokeUp ? "BROKE UP" : brokeDn ? "BROKE DOWN" : ready ? "WAITING" : inSes ? "IN RANGE" : "—"
    stCol   = trUp or brokeUp ? colUp : trDn or brokeDn ? colDn : retUp or retDn ? colRet : AS_WHITE
    tfTxt   = useChart ? timeframe.period : confTF + "m"
    pocTxt  = enSVP ? (not na(svpPoc) ? str.tostring(svpPoc, format.mintick) : "out of range") : "off"
    table.cell(panel, 0, 0, "ALGOSENTRY", text_color = AS_WHITE, bgcolor = AS_MAGENTA, text_size = size.normal, text_halign = text.align_left)
    table.cell(panel, 1, 0, "ORB",        text_color = AS_WHITE, bgcolor = AS_MAGENTA, text_size = size.normal, text_halign = text.align_right)
    table.cell(panel, 0, 1, "Session",    text_color = AS_DIM, bgcolor = cBg, text_size = size.small, text_halign = text.align_left)
    table.cell(panel, 1, 1, sesTxt,       text_color = sesCol, bgcolor = cBg, text_size = size.small, text_halign = text.align_right)
    table.cell(panel, 0, 2, "Range",      text_color = AS_DIM, bgcolor = cBg, text_size = size.small, text_halign = text.align_left)
    table.cell(panel, 1, 2, rngTxt,       text_color = AS_WHITE, bgcolor = cBg, text_size = size.small, text_halign = text.align_right)
    table.cell(panel, 0, 3, "State",      text_color = AS_DIM, bgcolor = cBg, text_size = size.small, text_halign = text.align_left)
    table.cell(panel, 1, 3, state,        text_color = stCol, bgcolor = cBg, text_size = size.small, text_halign = text.align_right)
    table.cell(panel, 0, 4, "Confirm TF", text_color = AS_DIM, bgcolor = cBg, text_size = size.small, text_halign = text.align_left)
    table.cell(panel, 1, 4, tfTxt,        text_color = AS_CYAN, bgcolor = cBg, text_size = size.small, text_halign = text.align_right)
    table.cell(panel, 0, 5, "Vol POC",    text_color = AS_DIM, bgcolor = cBg, text_size = size.small, text_halign = text.align_left)
    table.cell(panel, 1, 5, pocTxt,       text_color = colPOC, bgcolor = cBg, text_size = size.small, text_halign = text.align_right)
    table.cell(panel, 0, 6, "In-sample lies.", text_color = color.new(AS_DIM, 10), bgcolor = color.new(AS_NAVY, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(panel, 1, 6, "OOS is truth.",   text_color = color.new(AS_MAGENTA, 10), bgcolor = color.new(AS_NAVY, 0), text_size = size.tiny, text_halign = text.align_right)
````
