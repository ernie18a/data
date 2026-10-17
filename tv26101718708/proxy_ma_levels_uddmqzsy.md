# Proxy MA Levels

- url: https://www.tradingview.com/script/uddmQzsY-Proxy-MA-Levels/
- type: indicator
- pine_id: PUB;bb2825b9b7764563b7d81bfb32a9c2fb
- version: 1.0

## Description

Proxy MA Levels

Multi-timeframe moving average proxy system with tolerance zones, touch alerts, and cycle extension tracking for SPY.

---

What it does:

Proxy MA Levels brings higher timeframe moving averages down to any chart without timeframe switching. Instead of manually jumping to Weekly or Daily charts, this indicator calculates precise proxies of the most important institutional moving averages and displays them directly on your current timeframe.

Three core levels:
- W EMA8 — Weekly 8-period EMA proxy (1H EMA 650 / Daily EMA 40). The primary short-term trend anchor used by institutional traders
- W EMA20 — Weekly 20-period EMA proxy (1H EMA 1600 / Daily EMA 100). Key medium-term support and resistance
- D SMMA10 — Daily smoothed 10-period MA proxy (1H EMA 300 / Daily RMA 10). Precise daily trend baseline

Tolerance zones:
Configurable percentage bands around W EMA8 and W EMA20 highlight approach zones before price actually touches the level — giving you early warning before the reaction happens.

Cycle Extension:
Tracks the last cross of price through W EMA20, marks the anchor price level with a horizontal line, and displays the percentage extension and days elapsed since the cross. Useful for identifying overextended moves and mean reversion setups.

---

Key features:
- Automatic TF detection — switches between 1H and Daily proxies depending on your chart timeframe
- Anti-spam pivot engine — alerts fire once per confirmed pivot leg, not on every bar
- Individual and master alerts for Near / Touch / Over / Under each level
- Fully customizable colors, line widths, and label visibility
- Works on all intraday and daily timeframes

---

Alert types:
- Near W EMA8 / W EMA20 — price approaching within tolerance zone
- Touch — price has intersected the level
- Over / Under — price has broken through tolerance zone after a touch

---

How to use:
- Watch for Touch alerts as potential entry or exit signals
- Near alerts give you preparation time before the level is reached
- Over/Under after a touch confirms breakout or rejection
- Cycle Extension helps identify when a trend leg is statistically stretched and due for a pullback

## Source Code

````pine
//@version=6
indicator("Proxy MA Levels", shorttitle="Proxy MA", overlay=true, max_labels_count=500)

// ╔══════════════════════════════════════════════════════════════════╗
// ║  PROXY MA LEVELS V1                                             ║
// ║  W EMA8  proxy  = 1H EMA650  / D EMA40                         ║
// ║  W EMA20 proxy  = 1H EMA1600 / D EMA100                        ║
// ║  D SMMA10 proxy = 1H EMA300  / D RMA10                         ║
// ║  Tolerance: W EMA8 = 0.20%, W EMA20 = 0.30%, SMMA10 = none     ║
// ║  Anti-spam: 1x per confirmed 15m pivot leg                      ║
// ╚══════════════════════════════════════════════════════════════════╝

// ── Label size ──
labelSizeOpt = input.string("Small", "Label size", options=["Tiny","Small","Normal","Large","Huge"])

labelSize = switch labelSizeOpt
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    =>          size.huge

// ── Pivot L/R ──
pivotLR = input.int(3, "Pivot L/R bars", minval=1, maxval=10)

// ── W EMA8 Proxy ──
showEMA8     = input.bool(true,  "W EMA8",        inline="e8")
colEMA8      = input.color(color.new(color.orange, 0), "", inline="e8")
widthEMA8    = input.int(2, "",  minval=1, maxval=5,       inline="e8")
showLblEMA8  = input.bool(true,  "W EMA8 label")
showTolEMA8  = input.bool(true,  "W EMA8 tolerance zone")
tolEMA8Pct   = input.float(0.20, "W EMA8 tolerance %", minval=0.05, maxval=1.0, step=0.05)

// ── W EMA20 Proxy ──
showEMA20    = input.bool(true,  "W EMA20",       inline="e20")
colEMA20     = input.color(color.new(color.green, 0), "",  inline="e20")
widthEMA20   = input.int(2, "",  minval=1, maxval=5,       inline="e20")
showLblEMA20 = input.bool(true,  "W EMA20 label")
showTolEMA20 = input.bool(true,  "W EMA20 tolerance zone")
tolEMA20Pct  = input.float(0.30, "W EMA20 tolerance %", minval=0.05, maxval=1.0, step=0.05)

// ── D SMMA10 Proxy ──
showSMMA10   = input.bool(true,  "D SMMA10",      inline="s10")
colSMMA10    = input.color(color.new(color.red, 0), "",    inline="s10")
widthSMMA10  = input.int(2, "",  minval=1, maxval=5,       inline="s10")
showLblSMMA10 = input.bool(true, "D SMMA10 label")

// ── Cycle Extension ──
showCycleExt  = input.bool(true,  "Cycle extension", inline="cyc")
colCycle      = input.color(color.black, "",          inline="cyc")
widthCycle    = input.int(1, "",  minval=1, maxval=5,  inline="cyc")
showLblCycle  = input.bool(true,  "Cycle label")

// ╔══════════════════════════════════════════════════════════════════╗
// ║  MA CALCULATION                                                 ║
// ╚══════════════════════════════════════════════════════════════════╝
isDailyOrHigher = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly

// ETH ticker for higher TF requests
ethTicker = ticker.new(syminfo.prefix, syminfo.ticker, session.extended)

// 1H proxies (used on intraday TFs)
[proxy8_1h, proxy20_1h, proxyS10_1h] = request.security(ethTicker, "60",
     [ta.ema(close, 650), ta.ema(close, 1600), ta.ema(close, 300)],
     barmerge.gaps_off, barmerge.lookahead_off)

// Daily proxies (used on daily+ TFs)
[proxy8_d, proxy20_d, proxyS10_d] = request.security(ethTicker, "D",
     [ta.ema(close, 40), ta.ema(close, 100), ta.rma(close, 10)],
     barmerge.gaps_off, barmerge.lookahead_off)

// Select proxy based on current TF
ema8_proxy   = isDailyOrHigher ? proxy8_d   : proxy8_1h
ema20_proxy  = isDailyOrHigher ? proxy20_d  : proxy20_1h
smma10_proxy = isDailyOrHigher ? proxyS10_d : proxyS10_1h

// Fixed Weekly EMA20 removed – now using 1H request.security in cycle engine

// ╔══════════════════════════════════════════════════════════════════╗
// ║  HELPER FUNCTIONS                                               ║
// ╚══════════════════════════════════════════════════════════════════╝
f_upper(_lv, _t) => _lv * (1.0 + _t / 100.0)
f_lower(_lv, _t) => _lv * (1.0 - _t / 100.0)
f_near (_lv, _t) => high >= f_lower(_lv, _t) and low <= f_upper(_lv, _t)
f_touch(_lv)     => high >= _lv and low <= _lv

// ╔══════════════════════════════════════════════════════════════════╗
// ║  PIVOT ENGINE                                                   ║
// ╚══════════════════════════════════════════════════════════════════╝
pivHigh = ta.pivothigh(high, pivotLR, pivotLR)
pivLow  = ta.pivotlow (low,  pivotLR, pivotLR)

var int pivLegId = 0
bool newPivot = not na(pivHigh) or not na(pivLow)
if newPivot
    pivLegId += 1

// ╔══════════════════════════════════════════════════════════════════╗
// ║  CYCLE EXTENSION LINE                                           ║
// ║                                                                 ║
// ║  Cross logic runs inside request.security("60") context.       ║
// ║  Returns fixed anchor price + bar → consistent across all TFs. ║
// ╚══════════════════════════════════════════════════════════════════╝

cyc_anchor_calc() =>
    float _ema20 = ta.ema(close, 1600)
    bool _cross_up   = ta.crossover (close, _ema20)
    bool _cross_down = ta.crossunder(close, _ema20)
    var float _anchor_price = na
    var int   _anchor_time  = 0
    if _cross_up or _cross_down
        _anchor_price := _ema20
        _anchor_time  := time
    // Extension also calculated in 1H context using 1H close
    float _ext_pct = na
    if not na(_anchor_price) and _anchor_price != 0
        _ext_pct := (close / _anchor_price - 1.0) * 100.0
    // Days since cross – calendar days from anchor time to now
    int _days_since = _anchor_time > 0 ? int(math.floor((time - _anchor_time) / 86400000.0)) : 0
    [_anchor_price, _anchor_time, _ext_pct, _days_since]

[cyc_anchor_price, cyc_anchor_time, cycleExtPct, cycleDaysSince] = request.security(ethTicker, "60",
     cyc_anchor_calc(),
     barmerge.gaps_off, barmerge.lookahead_off)

// Horizontal line FROM anchor time TO current bar (right direction)
// extend=extend.none, x1=anchor time, x2=current time
var line cycleLine = na

if showCycleExt and not na(cyc_anchor_price) and cyc_anchor_time > 0
    if na(cycleLine)
        cycleLine := line.new(
             x1=cyc_anchor_time, y1=cyc_anchor_price,
             x2=time,            y2=cyc_anchor_price,
             xloc=xloc.bar_time,
             color=colCycle, width=widthCycle,
             style=line.style_solid, extend=extend.none)
    else
        line.set_x1(cycleLine, cyc_anchor_time)
        line.set_x2(cycleLine, time)
        line.set_y1(cycleLine, cyc_anchor_price)
        line.set_y2(cycleLine, cyc_anchor_price)
        line.set_color(cycleLine, colCycle)
        line.set_width(cycleLine, widthCycle)
else
    if not na(cycleLine)
        line.delete(cycleLine)
        cycleLine := na

// ╔══════════════════════════════════════════════════════════════════╗
// ║  ANTI-SPAM STATE                                                ║
// ╚══════════════════════════════════════════════════════════════════╝
var int  e8_nearLeg  = -1,  e8_touchLeg  = -1,  e8_overLeg  = -1,  e8_underLeg  = -1
var bool e8_touched  = false
var int  e20_nearLeg = -1,  e20_touchLeg = -1,  e20_overLeg = -1,  e20_underLeg = -1
var bool e20_touched = false
var int  s10_nearLeg = -1,  s10_touchLeg = -1,  s10_overLeg = -1,  s10_underLeg = -1
var bool s10_touched = false

if newPivot
    e8_touched  := false
    e20_touched := false
    s10_touched := false

// ╔══════════════════════════════════════════════════════════════════╗
// ║  ALERT LOGIC                                                    ║
// ╚══════════════════════════════════════════════════════════════════╝
f_alerts(_show, _lv, _t, _nL, _tL, _oL, _uL, _tched) =>
    bool _isNr = _show and f_near(_lv, _t) and not f_touch(_lv)
    bool _isTh = _show and f_touch(_lv)
    bool _isOv = _show and _tched and close > f_upper(_lv, _t) and not f_touch(_lv)
    bool _isUn = _show and _tched and close < f_lower(_lv, _t) and not f_touch(_lv)
    [_isNr and pivLegId != _nL,
     _isTh and pivLegId != _tL,
     _isOv and pivLegId != _oL,
     _isUn and pivLegId != _uL]

// W EMA8
[e8_nr, e8_th, e8_ov, e8_un] = f_alerts(showEMA8,  ema8_proxy,  tolEMA8Pct,
     e8_nearLeg, e8_touchLeg, e8_overLeg, e8_underLeg, e8_touched)
if e8_nr
    e8_nearLeg  := pivLegId
if e8_th
    e8_touchLeg := pivLegId
    e8_touched  := true
if e8_ov
    e8_overLeg  := pivLegId
if e8_un
    e8_underLeg := pivLegId

// W EMA20
[e20_nr, e20_th, e20_ov, e20_un] = f_alerts(showEMA20, ema20_proxy, tolEMA20Pct,
     e20_nearLeg, e20_touchLeg, e20_overLeg, e20_underLeg, e20_touched)
if e20_nr
    e20_nearLeg  := pivLegId
if e20_th
    e20_touchLeg := pivLegId
    e20_touched  := true
if e20_ov
    e20_overLeg  := pivLegId
if e20_un
    e20_underLeg := pivLegId

// D SMMA10 – touch and near only (no tolerance band, so no over/under)
bool s10_isNear  = showSMMA10 and f_touch(smma10_proxy) == false and
     high >= smma10_proxy * 0.997 and low <= smma10_proxy * 1.003
bool s10_isTouch = showSMMA10 and f_touch(smma10_proxy)
bool s10_nr = s10_isNear  and pivLegId != s10_nearLeg
bool s10_th = s10_isTouch and pivLegId != s10_touchLeg
if s10_nr
    s10_nearLeg  := pivLegId
if s10_th
    s10_touchLeg := pivLegId
    s10_touched  := true

// ╔══════════════════════════════════════════════════════════════════╗
// ║  MASTER ALERT                                                   ║
// ╚══════════════════════════════════════════════════════════════════╝
string masterMsg = ""

if e8_nr
    masterMsg := masterMsg != "" ? masterMsg + " | Near W EMA8"   : "Near W EMA8"
if e8_th
    masterMsg := masterMsg != "" ? masterMsg + " | W EMA8 Touch"  : "W EMA8 Touch"
if e8_ov
    masterMsg := masterMsg != "" ? masterMsg + " | W EMA8 Over"   : "W EMA8 Over"
if e8_un
    masterMsg := masterMsg != "" ? masterMsg + " | W EMA8 Under"  : "W EMA8 Under"
if e20_nr
    masterMsg := masterMsg != "" ? masterMsg + " | Near W EMA20"  : "Near W EMA20"
if e20_th
    masterMsg := masterMsg != "" ? masterMsg + " | W EMA20 Touch" : "W EMA20 Touch"
if e20_ov
    masterMsg := masterMsg != "" ? masterMsg + " | W EMA20 Over"  : "W EMA20 Over"
if e20_un
    masterMsg := masterMsg != "" ? masterMsg + " | W EMA20 Under" : "W EMA20 Under"
if s10_nr
    masterMsg := masterMsg != "" ? masterMsg + " | Near D SMMA10" : "Near D SMMA10"
if s10_th
    masterMsg := masterMsg != "" ? masterMsg + " | D SMMA10 Touch" : "D SMMA10 Touch"

bool masterTrigger = e8_nr or e8_th or e8_ov or e8_un or
     e20_nr or e20_th or e20_ov or e20_un or s10_nr or s10_th

if masterTrigger
    alert("Proxy MA | " + masterMsg + " @ " + str.tostring(math.round(close, 2)), alert.freq_once_per_bar)

// ── Individual alerts ──
alertcondition(e8_nr,  title="Near W EMA8",    message="Proxy MA: Near W EMA8 @ {{close}}")
alertcondition(e8_th,  title="W EMA8 Touch",   message="Proxy MA: W EMA8 Touch @ {{close}}")
alertcondition(e8_ov,  title="W EMA8 Over",    message="Proxy MA: W EMA8 Over @ {{close}}")
alertcondition(e8_un,  title="W EMA8 Under",   message="Proxy MA: W EMA8 Under @ {{close}}")
alertcondition(e20_nr, title="Near W EMA20",   message="Proxy MA: Near W EMA20 @ {{close}}")
alertcondition(e20_th, title="W EMA20 Touch",  message="Proxy MA: W EMA20 Touch @ {{close}}")
alertcondition(e20_ov, title="W EMA20 Over",   message="Proxy MA: W EMA20 Over @ {{close}}")
alertcondition(e20_un, title="W EMA20 Under",  message="Proxy MA: W EMA20 Under @ {{close}}")
alertcondition(s10_nr, title="Near D SMMA10",  message="Proxy MA: Near D SMMA10 @ {{close}}")
alertcondition(s10_th, title="D SMMA10 Touch", message="Proxy MA: D SMMA10 Touch @ {{close}}")

// ╔══════════════════════════════════════════════════════════════════╗
// ║  PLOTTING                                                       ║
// ╚══════════════════════════════════════════════════════════════════╝

// ── MA lines ──
plot(showEMA8   ? ema8_proxy   : na, title="W EMA8",   color=colEMA8,   linewidth=widthEMA8)
plot(showEMA20  ? ema20_proxy  : na, title="W EMA20",  color=colEMA20,  linewidth=widthEMA20)
plot(showSMMA10 ? smma10_proxy : na, title="D SMMA10", color=colSMMA10, linewidth=widthSMMA10)

// ── Tolerance bands – plot+fill, V19 style ──
// W EMA8: always shown when enabled (only 7 plots total, no limit issues)
p_e8_up = plot(showTolEMA8  and not na(ema8_proxy)  ? f_upper(ema8_proxy,  tolEMA8Pct)  : na,
     title="W EMA8 tol+",  color=color.new(colEMA8,  70), linewidth=1)
p_e8_dn = plot(showTolEMA8  and not na(ema8_proxy)  ? f_lower(ema8_proxy,  tolEMA8Pct)  : na,
     title="W EMA8 tol-",  color=color.new(colEMA8,  70), linewidth=1)
fill(p_e8_up, p_e8_dn, color=color.new(colEMA8, 85))

p_e20_up = plot(showTolEMA20 and not na(ema20_proxy) ? f_upper(ema20_proxy, tolEMA20Pct) : na,
     title="W EMA20 tol+", color=color.new(colEMA20, 70), linewidth=1)
p_e20_dn = plot(showTolEMA20 and not na(ema20_proxy) ? f_lower(ema20_proxy, tolEMA20Pct) : na,
     title="W EMA20 tol-", color=color.new(colEMA20, 70), linewidth=1)
fill(p_e20_up, p_e20_dn, color=color.new(colEMA20, 85))

// ╔══════════════════════════════════════════════════════════════════╗
// ║  LABELS                                                         ║
// ╚══════════════════════════════════════════════════════════════════╝
var label lbl_e8    = na
var label lbl_e20   = na
var label lbl_s10   = na
var label lbl_cycle = na

f_lbl(_lbl, _show, _y, _txt, _col) =>
    if _show and not na(_y) and barstate.islast
        if na(_lbl)
            label.new(bar_index, _y, _txt,
                 style=label.style_label_left, color=_col,
                 textcolor=color.white, size=labelSize)
        else
            label.set_xy(_lbl, bar_index, _y)
            label.set_text(_lbl, _txt)
            label.set_color(_lbl, _col)
            _lbl
    else
        if not _show and not na(_lbl)
            label.delete(_lbl)
        na

fmt_pct(_p) => (_p >= 0 ? "+" : "") + str.tostring(math.round(_p, 2)) + "%"

if barstate.islast
    lbl_e8  := f_lbl(lbl_e8,  showLblEMA8,   ema8_proxy,   "W EMA8",   colEMA8)
    lbl_e20 := f_lbl(lbl_e20, showLblEMA20,  ema20_proxy,  "W EMA20",  colEMA20)
    lbl_s10 := f_lbl(lbl_s10, showLblSMMA10, smma10_proxy, "D SMMA10", colSMMA10)

    // Cycle label – independent from line visibility
    if showLblCycle and not na(cyc_anchor_price) and not na(cycleExtPct)
        _cycTxt = "Cycle " + fmt_pct(cycleExtPct) + "  " + str.tostring(cycleDaysSince) + "d"
        if na(lbl_cycle)
            lbl_cycle := label.new(bar_index, cyc_anchor_price, _cycTxt,
                 style=label.style_label_left, color=colCycle,
                 textcolor=color.white, size=labelSize)
        else
            label.set_xy   (lbl_cycle, bar_index, cyc_anchor_price)
            label.set_text (lbl_cycle, _cycTxt)
            label.set_color(lbl_cycle, colCycle)
    else
        if not na(lbl_cycle)
            label.delete(lbl_cycle)
            lbl_cycle := na
````
