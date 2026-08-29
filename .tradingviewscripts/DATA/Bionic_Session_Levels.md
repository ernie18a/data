<!-- tradingview-pine-id: PUB;5873e655ec4d4981897a6a42a7dcfd23 -->
<!-- tradingviewscripts-format: 1 -->
# Bionic -- Session Levels 

Source: https://www.tradingview.com/script/s6spfDc2-Bionic-Session-Levels/

## Description

Session Levels

This indicator plots the key reference levels that intraday traders track into the New York open: the Asia session high and low, the pre-market high and low, the previous NY session high and low, and the volume Point of Control from the previous NY session. All seven levels render as clean horizontal lines anchored to the session where they formed and extended to the current bar, each with an inline text label at the right edge of the chart.

------------

The Seven Levels

Asia High / Asia Low: The high and low of the most recent completed Asia session (default 18:00 to 00:00 New York time). These levels lock in when the session closes and remain on the chart until the next Asia session completes.

Pre-Market High / Pre-Market Low: The high and low of the current day's pre-market session (default 04:00 to 09:30 New York time). These levels develop live while pre-market is in progress, expanding in real time as new extremes print.

Prev Session High / Prev Session Low: The high and low of the most recently completed NY regular trading hours session (default 09:30 to 16:00 New York time). These levels reflect the RTH range only, so overnight Globex extremes are intentionally excluded. During the current RTH session, these hold the prior session's range.

POC: The Point of Control of the previous NY session, calculated as the price level where the most volume traded. The level is anchored at the start of the session that produced it.

------------

How the POC Is Calculated

While the NY session is in progress, the script collects price and volume data from a lower timeframe (default 1 minute, configurable). When the session closes, that data is binned into a configurable number of price rows (default 24) spanning the session range, and the row with the highest accumulated volume becomes the POC. More rows produce a finer-grained profile; fewer rows produce a smoother one. Because the calculation uses intrabar data rather than tick data, the result is a close approximation of the session volume profile, with precision governed by the intrabar timeframe and row count you select.

-------------------

Configuration

Every level has four independent controls arranged on a single settings row: a show/hide toggle, an editable label text field, a color picker, and a line width setting. You can rename any level to match your own terminology, restyle it, or remove it from the display entirely.

Session windows and the timezone are fully configurable. The defaults assume US equity and index futures conventions in New York time, but the indicator adapts to any market by adjusting the three session inputs and the timezone.

----------------

Display Behavior

The indicator shows only the current, active set of levels. It does not accumulate historical lines across prior days, which keeps the chart clean and the drawing object count low. Lines begin at the session that generated them and extend to the live bar, so you always see how far price has traveled from each reference.

------------__

Requirements and Notes

The indicator is designed for intraday timeframes. Session detection requires an intraday chart, so no levels plot on daily or higher timeframes.
POC accuracy depends on lower-timeframe data availability. On instruments or chart histories where intrabar data is limited, the script falls back to chart-timeframe close and volume.

Asia levels update only when a session completes. During a live Asia session, the displayed high and low belong to the prior completed session.

-----------------

This indicator is a decision-support tool. It does not constitute financial advice. Test it on your instrument and timeframe before trading live.

---

## Source Code

````pine
//@version=6
indicator("Bionic -- Session Levels ", overlay = true, scale = scale.none, max_lines_count = 20, max_labels_count = 20)

//──────────────── Sessions ────────────────
grpS     = "Sessions"
tz       = input.string("America/New_York", "Timezone", group = grpS)
asiaSess = input.session("1800-0000", "Asia session", group = grpS)
pmSess   = input.session("0400-0930", "Pre-market session", group = grpS)
rthSess  = input.session("0930-1600", "NY session (RTH)", group = grpS)

grpP     = "POC (previous NY session)"
pocRows  = input.int(24, "Price rows", minval = 5, maxval = 200, group = grpP)
pocLtfIn = input.timeframe("1", "Intrabar timeframe", group = grpP)

//──────────────── Levels: show / text / color / text size / line style ────────────────
grpL        = "Levels"
SZOPTS      = "normal"
STYOPTS     = "solid"
showPrice   = input.bool(true, "Show price in labels", group = grpL)
lineWidth   = input.int(2, "Line width", minval = 1, maxval = 10, group = grpL)
labelStyle  = input.string("Text", "Label display", options = ["Tag", "Text"], group = grpL)
tagTextCol  = input.color(color.white, "Tag text color", group = grpL)
labelOffset = input.int(5, "Label offset (bars)", minval = 0, maxval = 500, group = grpL)

showAsiaH = input.bool(true, "", inline = "1", group = grpL)
txtAsiaH  = input.string("Asia High", "", inline = "1", group = grpL)
colAsiaH  = input.color(color.orange, "", inline = "1", group = grpL)
szAsiaH   = input.string(SZOPTS, "", options = ["tiny", "small", "normal", "large", "huge"], inline = "1", group = grpL)
styAsiaH  = input.string(STYOPTS, "", options = ["solid", "dotted", "dashed"], inline = "1", group = grpL)

showAsiaL = input.bool(true, "", inline = "2", group = grpL)
txtAsiaL  = input.string("Asia Low", "", inline = "2", group = grpL)
colAsiaL  = input.color(color.orange, "", inline = "2", group = grpL)
szAsiaL   = input.string(SZOPTS, "", options = ["tiny", "small", "normal", "large", "huge"], inline = "2", group = grpL)
styAsiaL  = input.string(STYOPTS, "", options = ["solid", "dotted", "dashed"], inline = "2", group = grpL)

showPoc   = input.bool(true, "", inline = "3", group = grpL)
txtPoc    = input.string("POC", "", inline = "3", group = grpL)
colPoc    = input.color(color.yellow, "", inline = "3", group = grpL)
szPoc     = input.string(SZOPTS, "", options = ["tiny", "small", "normal", "large", "huge"], inline = "3", group = grpL)
styPoc    = input.string(STYOPTS, "", options = ["solid", "dotted", "dashed"], inline = "3", group = grpL)

showPmH   = input.bool(true, "", inline = "4", group = grpL)
txtPmH    = input.string("Pre-Market High", "", inline = "4", group = grpL)
colPmH    = input.color(color.aqua, "", inline = "4", group = grpL)
szPmH     = input.string(SZOPTS, "", options = ["tiny", "small", "normal", "large", "huge"], inline = "4", group = grpL)
styPmH    = input.string(STYOPTS, "", options = ["solid", "dotted", "dashed"], inline = "4", group = grpL)

showPmL   = input.bool(true, "", inline = "5", group = grpL)
txtPmL    = input.string("Pre-Market Low", "", inline = "5", group = grpL)
colPmL    = input.color(color.aqua, "", inline = "5", group = grpL)
szPmL     = input.string(SZOPTS, "", options = ["tiny", "small", "normal", "large", "huge"], inline = "5", group = grpL)
styPmL    = input.string(STYOPTS, "", options = ["solid", "dotted", "dashed"], inline = "5", group = grpL)

showPdH   = input.bool(true, "", inline = "6", group = grpL)
txtPdH    = input.string("Prev Day High", "", inline = "6", group = grpL)
colPdH    = input.color(color.lime, "", inline = "6", group = grpL)
szPdH     = input.string(SZOPTS, "", options = ["tiny", "small", "normal", "large", "huge"], inline = "6", group = grpL)
styPdH    = input.string(STYOPTS, "", options = ["solid", "dotted", "dashed"], inline = "6", group = grpL)

showPdL   = input.bool(true, "", inline = "7", group = grpL)
txtPdL    = input.string("Prev Day Low", "", inline = "7", group = grpL)
colPdL    = input.color(color.red, "", inline = "7", group = grpL)
szPdL     = input.string(SZOPTS, "", options = ["tiny", "small", "normal", "large", "huge"], inline = "7", group = grpL)
styPdL    = input.string(STYOPTS, "", options = ["solid", "dotted", "dashed"], inline = "7", group = grpL)

//──────────────── Session detection ────────────────
inSess(sess) =>
    timeframe.isintraday and not na(time(timeframe.period, sess, tz))

inAsia = inSess(asiaSess)
inPm   = inSess(pmSess)
inRth  = inSess(rthSess)

prevInAsia = bar_index > 0 ? inAsia[1] : false
prevInPm   = bar_index > 0 ? inPm[1] : false
prevInRth  = bar_index > 0 ? inRth[1] : false

//──────────────── Asia session (most recent completed) ────────────────
var float asiaCurH = na
var float asiaCurL = na
var int   asiaCurT = na
var float asiaH    = na
var float asiaL    = na
var int   asiaT    = na

if inAsia
    if not prevInAsia or na(asiaCurH)
        asiaCurH := high
        asiaCurL := low
        asiaCurT := time
    else
        asiaCurH := math.max(asiaCurH, high)
        asiaCurL := math.min(asiaCurL, low)
else if prevInAsia
    asiaH := asiaCurH
    asiaL := asiaCurL
    asiaT := asiaCurT

//──────────────── Pre-market (current day, develops live) ────────────────
var float pmH = na
var float pmL = na
var int   pmT = na

if inPm
    if not prevInPm or na(pmH)
        pmH := high
        pmL := low
        pmT := time
    else
        pmH := math.max(pmH, high)
        pmL := math.min(pmL, low)

//──────────────── Previous NY session H/L + POC ────────────────
ltfEff = timeframe.in_seconds(pocLtfIn) < timeframe.in_seconds(timeframe.period) ? pocLtfIn : timeframe.period
[ltfC, ltfV] = request.security_lower_tf(syminfo.tickerid, ltfEff, [close, volume])

var float rthCurH = na
var float rthCurL = na
var int   rthCurT = na
var float pdH     = na
var float pdL     = na
var int   pdT     = na
var float pocLvl  = na

var pocP = array.new_float()
var pocV = array.new_float()

computePoc() =>
    float poc = na
    int n = array.size(pocP)
    if n > 0
        float pMin = array.min(pocP)
        float pMax = array.max(pocP)
        if pMax > pMin
            rowVol = array.new_float(pocRows, 0.0)
            rowH   = (pMax - pMin) / pocRows
            for i = 0 to n - 1
                idx = math.min(int((array.get(pocP, i) - pMin) / rowH), pocRows - 1)
                array.set(rowVol, idx, array.get(rowVol, idx) + array.get(pocV, i))
            bestIdx = 0
            for i = 1 to pocRows - 1
                if array.get(rowVol, i) > array.get(rowVol, bestIdx)
                    bestIdx := i
            poc := pMin + (bestIdx + 0.5) * rowH
        else
            poc := pMin
    poc

if inRth
    if not prevInRth or na(rthCurH)
        rthCurH := high
        rthCurL := low
        rthCurT := time
        array.clear(pocP)
        array.clear(pocV)
    else
        rthCurH := math.max(rthCurH, high)
        rthCurL := math.min(rthCurL, low)
    if array.size(ltfC) > 0
        for i = 0 to array.size(ltfC) - 1
            array.push(pocP, array.get(ltfC, i))
            array.push(pocV, nz(array.get(ltfV, i)))
    else
        array.push(pocP, close)
        array.push(pocV, nz(volume))
else if prevInRth
    pdH    := rthCurH
    pdL    := rthCurL
    pdT    := rthCurT
    pocLvl := computePoc()
    array.clear(pocP)
    array.clear(pocV)

//──────────────── Drawing (objects created once, reused) ────────────────
var line  lnAsiaH = line.new(time, close, time, close, xloc = xloc.bar_time, color = color.new(color.gray, 100), force_overlay = true)
var line  lnAsiaL = line.new(time, close, time, close, xloc = xloc.bar_time, color = color.new(color.gray, 100), force_overlay = true)
var line  lnPoc   = line.new(time, close, time, close, xloc = xloc.bar_time, color = color.new(color.gray, 100), force_overlay = true)
var line  lnPmH   = line.new(time, close, time, close, xloc = xloc.bar_time, color = color.new(color.gray, 100), force_overlay = true)
var line  lnPmL   = line.new(time, close, time, close, xloc = xloc.bar_time, color = color.new(color.gray, 100), force_overlay = true)
var line  lnPdH   = line.new(time, close, time, close, xloc = xloc.bar_time, color = color.new(color.gray, 100), force_overlay = true)
var line  lnPdL   = line.new(time, close, time, close, xloc = xloc.bar_time, color = color.new(color.gray, 100), force_overlay = true)

var label lbAsiaH = label.new(bar_index, close, "", style = label.style_label_left, color = color.new(color.black, 100), force_overlay = true)
var label lbAsiaL = label.new(bar_index, close, "", style = label.style_label_left, color = color.new(color.black, 100), force_overlay = true)
var label lbPoc   = label.new(bar_index, close, "", style = label.style_label_left, color = color.new(color.black, 100), force_overlay = true)
var label lbPmH   = label.new(bar_index, close, "", style = label.style_label_left, color = color.new(color.black, 100), force_overlay = true)
var label lbPmL   = label.new(bar_index, close, "", style = label.style_label_left, color = color.new(color.black, 100), force_overlay = true)
var label lbPdH   = label.new(bar_index, close, "", style = label.style_label_left, color = color.new(color.black, 100), force_overlay = true)
var label lbPdL   = label.new(bar_index, close, "", style = label.style_label_left, color = color.new(color.black, 100), force_overlay = true)

toSize(string s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "normal" ? size.normal : s == "large" ? size.large : size.huge

toStyle(string s) =>
    s == "dotted" ? line.style_dotted : s == "dashed" ? line.style_dashed : line.style_solid

drawLevel(line ln, label lb, bool show, float lvl, int t1, string txt, color col, string szTxt, string styTxt) =>
    bool visible = show and not na(lvl) and not na(t1)
    bool tagMode = labelStyle == "Tag"
    string priceTxt = showPrice ? " (" + str.tostring(lvl, format.mintick) + ")" : ""
    line.set_xy1(ln, visible ? t1 : time, visible ? lvl : close)
    line.set_xy2(ln, time, visible ? lvl : close)
    line.set_color(ln, visible ? col : color.new(col, 100))
    line.set_width(ln, lineWidth)
    line.set_style(ln, toStyle(styTxt))
    label.set_xy(lb, bar_index + labelOffset, visible ? lvl : close)
    label.set_text(lb, visible ? txt + priceTxt : "")
    label.set_color(lb, visible and tagMode ? col : color.new(color.black, 100))
    label.set_textcolor(lb, tagMode ? tagTextCol : col)
    label.set_size(lb, toSize(szTxt))

if barstate.islast
    drawLevel(lnAsiaH, lbAsiaH, showAsiaH, asiaH, asiaT, txtAsiaH, colAsiaH, szAsiaH, styAsiaH)
    drawLevel(lnAsiaL, lbAsiaL, showAsiaL, asiaL, asiaT, txtAsiaL, colAsiaL, szAsiaL, styAsiaL)
    drawLevel(lnPoc,   lbPoc,   showPoc,   pocLvl, pdT,  txtPoc,   colPoc,   szPoc,   styPoc)
    drawLevel(lnPmH,   lbPmH,   showPmH,   pmH,   pmT,   txtPmH,   colPmH,   szPmH,   styPmH)
    drawLevel(lnPmL,   lbPmL,   showPmL,   pmL,   pmT,   txtPmL,   colPmL,   szPmL,   styPmL)
    drawLevel(lnPdH,   lbPdH,   showPdH,   pdH,   pdT,   txtPdH,   colPdH,   szPdH,   styPdH)
    drawLevel(lnPdL,   lbPdL,   showPdL,   pdL,   pdT,   txtPdL,   colPdL,   szPdL,   styPdL)
````
