# SRJ India VIX Widget

- url: https://www.tradingview.com/script/kgljaX7P-SRJ-India-VIX-Widget/
- type: indicator
- pine_id: PUB;45eefd1086bb48628d04e41bd5f5b992
- version: 1.0

## Description

**SRJ India VIX Widget – Volatility Regime & Expected Range Tool**

The SRJ India VIX Widget combines real-time volatility regime tracking with a custom expected range model to support intraday planning and risk management for Indian index traders.

This indicator uses India VIX to estimate potential daily movement and plots volatility-adjusted levels around the previous day’s close. It also includes a live dashboard that tracks volatility shifts and short-term changes throughout the session.

**🔹 What it shows**

* Live VIX value with regime classification
* Change vs previous 15-minute interval and previous day close
* Volatility-based expected range levels
* Extended range bands for potential expansion scenarios

**🔹 How to use**

* Use the range bands as dynamic support and resistance zones
* Rising VIX indicates increasing volatility and possible trend expansion
* Falling VIX suggests compression and range-bound conditions
* Helps define intraday bias, targets, and risk levels

**🔹 Best suited for**

* Index intraday traders
* Volatility-based trading strategies
* Traders seeking objective, data-driven reference levels

**🔹Multi-use behavior**

On NSE indices: Displays both volatility dashboard and expected range levels
On other symbols (stocks, crypto, etc.): Works as a standalone India VIX dashboard for broader market context

**⚠️ Notes**

* Expected range levels are available only on supported NSE indices due to India VIX dependency
* These levels are statistical estimates and should not be treated as fixed support/resistance

**Disclaimer**
This script is an independent implementation combining volatility regime analysis with a custom expected range model.
The concept of volatility-based expected move estimation is widely used in financial markets; this indicator provides a structured adaptation with additional logic, visualization, and intraday context.

## Source Code

````pine
//@version=6
indicator("SRJ India VIX Widget", overlay=true)

// ══════════════════════════════════════
// USER INPUTS
// ══════════════════════════════════════

// Timezone used for intraday session alignment (important for India markets)
iTz  = input.string("Asia/Kolkata", "Timezone",       group="SETUP",  display = display.all-display.status_line)

// UI table position and sizing
iPos = input.string("Top Right", "Table Position", group="SETUP", options=["Top Left","Top Right","Bottom Left","Bottom Right"],  display = display.all-display.status_line)
iSz  = input.string("Small",        "Font Size",      group="SETUP", options=["Tiny","Small","Normal"],  display = display.all-display.status_line)

// Volatility modelling parameters
// Trading days ~246 (Indian markets), used to annualize VIX
iTredingDays = input.int(246, minval = 200, maxval = 300, step = 1, title = "Treding Days",  display = display.all-display.status_line)

// 0.5 means 2 standard deviations of typical daily moves (empirically observed)
iSigma = input.float(0.5, minval = 0, title = 'σ value',  display = display.all-display.status_line)

// Master switch for Sentient (expected range) levels
iEnableSentient = input.bool(true, "Enable Sentient Levels",  display = display.all-display.status_line)

// Import VIX + Sentient utilities
import sanjeevrjha/IndiaVix/1 as pmkt

// ══════════════════════════════════════
// COLOR / UI HELPERS
// ══════════════════════════════════════

// VIX regime → color
regimeCol(float _v) => na(_v)  ? color.gray   : _v > 25 ? color.red    : _v > 20 ? color.orange : _v > 15 ? color.yellow : color.green

// Change formatting (▲/▼)
chgStr(float _v) => na(_v)  ? "—" : _v > 0  ? "▲ " + str.tostring(math.round(_v, 2)) : _v < 0  ? "▼ " + str.tostring(math.round(math.abs(_v), 2)) : "— 0"

// Change coloring (rising risk = red, falling = green)
chgCol(float _v) =>na(_v)  ? color.gray  :_v > 0  ? color.red   : color.green

// Table  helperd
tpos(string _p) =>
    switch _p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        =>                position.bottom_right

tsz(string _s) =>
    switch _s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        =>          size.small

// ══════════════════════════════════════
// STATE
// ══════════════════════════════════════

// Restrict Sentient model to NSE indices only
// (INDIAVIX is NSE-only; BSE indices have no matching VIX)
isValidSymbol = syminfo.type == "index" and syminfo.prefix == "NSE"
showSentient = iEnableSentient and isValidSymbol

// VIX snapshot object (from library)
var pmkt.Vix vixSnap = pmkt.Vix.new()

// Detect new day & new 15-minute interval within trading session
bool newDay    = ta.change(time("D", "0915-1530", iTz)) != 0
bool new15min  = ta.change(time("15", "0915-1530", iTz)) != 0

// Cached previous day index close (to avoid repeated calls)
var float indexClose = na

// ══════════════════════════════════════
// DAILY INITIALIZATION
// ══════════════════════════════════════
if newDay
    vixSnap := pmkt.Vix.new()
    // intentional to use barmerge.lookahead_on to get close[1] as prv day value
    [vixNow, vixPrev] = pmkt.getVix("15")
    vixSnap.eod       := vixPrev
    vixSnap.now       := vixNow
    vixSnap.prev      := vixPrev
    if isValidSymbol
        indexClose := pmkt.getPrevDayClose(syminfo.tickerid)
// ── refresh every 15min bar ──
else if new15min
    [vixNow, vixPrev] = pmkt.getVix("15")
    vixSnap.now       := vixNow
    vixSnap.prev      := vixPrev

[index, hr, lr, hr1, lr1] = pmkt.getSentientValues(showSentient, vixSnap.eod, indexClose, syminfo.tickerid, iSigma, iTredingDays)

plot(index, title = 'Middle Line', color = color.black, style = plot.style_line, linewidth = 2)
plot(hr, title = 'Top Line', color = color.red, style = plot.style_line, linewidth = 2)
plot(lr, title = 'Bottom Line', color = color.blue, style = plot.style_line, linewidth = 2)
plot(hr1, title = 'Higher range +1', color = color.black, style = plot.style_line)
plot(lr1, title = 'Lower range -1', color = color.black, style = plot.style_line)

// ══════════════════════════════════════
// TABLE — render only on last bar
// 2 rows × 4 cols
// ══════════════════════════════════════

var table tbl = table.new(tpos(iPos), 4, 2, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray, frame_width=1, frame_color=color.gray)

if barstate.islast and not na(vixSnap.now)
    
    table.set_position(tbl, tpos(iPos))
    string sz      = tsz(iSz)
    color  cW      = color.white
    color  rCol    = regimeCol(vixSnap.now)
    color  chgPCol = chgCol(vixSnap.chgVsPrev())
    color  chgDCol = chgCol(vixSnap.chgVsPDC())
    // ── Row 0: live VIX ──
    table.cell(tbl, 0, 0,"VIX " + str.tostring(math.round(vixSnap.now, 2)),bgcolor=rCol, text_color=cW, text_size=sz)
    table.cell(tbl, 1, 0, vixSnap.regime(), bgcolor=color.new(rCol, 30), text_color=cW, text_size=sz)
    table.cell(tbl, 2, 0, "15m: " + chgStr(vixSnap.chgVsPrev()),bgcolor=color.new(chgPCol, 20),      text_color=cW, text_size=sz)
    table.cell(tbl, 3, 0, "PDC: " + chgStr(vixSnap.chgVsPDC()), bgcolor=color.new(chgDCol, 20),      text_color=cW, text_size=sz)

    // ── Row 1: reference ──
    table.cell(tbl, 0, 1,"PDC " + str.tostring(math.round(nz(vixSnap.eod), 2)), bgcolor=color.new(color.gray, 30),   text_color=cW, text_size=sz)
    table.cell(tbl, 1, 1,"Prev " + str.tostring(math.round(nz(vixSnap.prev), 2)), bgcolor=color.new(color.gray, 30),   text_color=cW, text_size=sz)
    table.cell(tbl, 2, 1,vixSnap.isRising() ? "Rising from PD" : "Falling from PD", bgcolor=color.new(chgDCol, 30),      text_color=cW, text_size=sz)
    table.cell(tbl, 3, 1, "±" + str.tostring(math.round(vixSnap.dailyMovePts(close), 0)) + "pts", bgcolor=color.new(rCol, 40),         text_color=cW, text_size=sz)
````
