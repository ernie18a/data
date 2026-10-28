# Daily Sessions Lines

- url: https://www.tradingview.com/script/T5WVvhcc-Daily-Sessions-Lines/
- type: indicator
- pine_id: PUB;a1799b8d68b14fbe877960664e9acb3c
- version: 2.0

## Description

[b]Daily Sessions Lines
[/b]
Automatic horizontal-ray plotter for ICT-style day trading. Marks every key reference level you'd otherwise draw by hand each morning, using the CME electronic-session convention (not calendar days).

[b]If "Reset chart view" zooms the chart out to fit weekly levels, right-click the price scale and enable Scale price chart only.[/b]

[b]Levels drawn (all New York time)[/b]

Previous Week High / Low
Week Open
Previous Day High / Low
Asia High / Low — 20:00 to 00:00
Midnight Open — 00:00
London High / Low — 02:00 to 05:00
AM Session High / Low — 09:30 to 12:00
RTH Close — 16:15
How it works
Every day at 18:00 NY the indicator wipes the previous trading day's session lines and starts fresh. Weekly and daily levels keep rolling using the futures session boundary (Sun 18:00 → Fri 17:00), so PDH/PDL and Week Open reflect the actual session structure — not a misaligned calendar day. Session highs and lows update live during their window and lock in once the window closes. Lines extend right and end just before a clean label hugging the right edge of the chart.

Customization
Each level has its own toggle plus full styling:

Color (17 preset options)
Style: Solid, Dashed, Dotted
Width: 1 to 5
Transparency: 0 to 100
Custom label text
Global controls for timezone, reset hour, label size, label text color, label background transparency, and the gap between line and label.

Defaults

All lines: thin Black + Dashed for a clean look on light themes.
Previous Day High / Low: Solid for emphasis.
Labels: black background, white text, right-edge anchored.
Notes

Timezone defaults to America/New_York (DST-aware). Fixed UTC offsets are also available.

Built for lower time frame charts on MES, MNQ, ES, NQ, XAUUSD, and other 24-hour futures or FX instruments.

## Source Code

````pine
//@version=6
indicator("Daily Sessions Lines", "Daily Sessions Lines", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================
//   Daily Sessions Lines  -  v1
//   NY-time ICT levels: PWH/PWL, WO, PDH/PDL, Asia, Midnight,
//   London, AM, RTH Close.  CME electronic session (18:00->17:00).
//   Daily reset at 18:00 NY wipes session lines.  PDH/PDL and
//   RTH Close roll over and persist into the next trading day.
// ============================================================

// ===================== INPUTS =====================
g_gen  = "General"
g_week = "Weekly Levels"
g_day  = "Daily Levels"
g_asia = "Asia (20:00-00:00)"
g_mid  = "Midnight Open (00:00)"
g_lon  = "London (02:00-05:00)"
g_am   = "AM (09:30-12:00)"
g_rth  = "RTH Close (16:15)"

tzInput         = input.string("America/New_York", "Timezone", options=["America/New_York","Etc/GMT+4","Etc/GMT+5","UTC"], group=g_gen, tooltip="America/New_York is DST-aware. Etc/GMT+4 is fixed UTC-4.")
resetHour       = input.int(18, "Daily Reset Hour (24h)", minval=0, maxval=23, group=g_gen, tooltip="Hour that wipes session lines and rolls the trading day.")
labelOffsetBars = input.int(15, "Label Offset (bars right)", minval=1, maxval=500, group=g_gen)
lineGapBars     = input.int(2, "Gap Between Line End & Label (bars)", minval=0, maxval=20, group=g_gen)
lineHistoryBars = input.int(1000, "Line History (bars back)", minval=50, maxval=5000, group=g_gen, tooltip="How far back the line is anchored from the current bar. Lower = safer for thin instruments; higher = lines reach further left on chart.")
labelSizeIn     = input.string("normal", "Label Size", options=["tiny","small","normal","large","huge"], group=g_gen)
labelTextMode   = input.string("White", "Label Text Color", options=["White","Match Line","Black","Yellow","Cyan","Gray"], group=g_gen, tooltip="Color of the text inside each label.")
labelTransp     = input.int(0, "Label BG Transparency", minval=0, maxval=100, group=g_gen)

// ===== Weekly =====
showWO   = input.bool(true,  "Week Open",       group=g_week, inline="wo")
woColor  = input.color(color.black, "C",        group=g_week, inline="wo")
woStyle  = input.string("Dashed","S", options=["Solid","Dashed","Dotted"], group=g_week, inline="wo")
woWidth  = input.int(1, "W", 1, 5,              group=g_week, inline="wo")
woTransp = input.int(0, "T", 0, 100,            group=g_week, inline="wo")
woText   = input.string("WO","Label",           group=g_week, inline="wo2")

showPWH   = input.bool(true,"Prev Week High",   group=g_week, inline="pwh")
pwhColor  = input.color(color.black, "C",       group=g_week, inline="pwh")
pwhStyle  = input.string("Dashed","S", options=["Solid","Dashed","Dotted"], group=g_week, inline="pwh")
pwhWidth  = input.int(1, "W", 1, 5,             group=g_week, inline="pwh")
pwhTransp = input.int(0, "T", 0, 100,           group=g_week, inline="pwh")
pwhText   = input.string("PWH","Label",         group=g_week, inline="pwh2")

showPWL   = input.bool(true,"Prev Week Low",    group=g_week, inline="pwl")
pwlColor  = input.color(color.black, "C",       group=g_week, inline="pwl")
pwlStyle  = input.string("Dashed","S", options=["Solid","Dashed","Dotted"], group=g_week, inline="pwl")
pwlWidth  = input.int(1, "W", 1, 5,             group=g_week, inline="pwl")
pwlTransp = input.int(0, "T", 0, 100,           group=g_week, inline="pwl")
pwlText   = input.string("PWL","Label",         group=g_week, inline="pwl2")

showWH    = input.bool(true,"Week High",        group=g_week, inline="wh")
whColor   = input.color(color.black, "C",       group=g_week, inline="wh")
whStyle   = input.string("Dashed","S", options=["Solid","Dashed","Dotted"], group=g_week, inline="wh")
whWidth   = input.int(1, "W", 1, 5,             group=g_week, inline="wh")
whTransp  = input.int(0, "T", 0, 100,           group=g_week, inline="wh")
whText    = input.string("WH","Label",          group=g_week, inline="wh2")

showWL    = input.bool(true,"Week Low",         group=g_week, inline="wl")
wlColor   = input.color(color.black, "C",       group=g_week, inline="wl")
wlStyle   = input.string("Dashed","S", options=["Solid","Dashed","Dotted"], group=g_week, inline="wl")
wlWidth   = input.int(1, "W", 1, 5,             group=g_week, inline="wl")
wlTransp  = input.int(0, "T", 0, 100,           group=g_week, inline="wl")
wlText    = input.string("WL","Label",          group=g_week, inline="wl2")

// ===== Daily =====
showPDH   = input.bool(true,"Prev Day High",    group=g_day, inline="pdh")
pdhColor  = input.color(color.black, "C",       group=g_day, inline="pdh")
pdhStyle  = input.string("Solid","S", options=["Solid","Dashed","Dotted"], group=g_day, inline="pdh")
pdhWidth  = input.int(1, "W", 1, 5,             group=g_day, inline="pdh")
pdhTransp = input.int(0, "T", 0, 100,           group=g_day, inline="pdh")
pdhText   = input.string("PDH","Label",         group=g_day, inline="pdh2")

showPDL   = input.bool(true,"Prev Day Low",     group=g_day, inline="pdl")
pdlColor  = input.color(color.black, "C",       group=g_day, inline="pdl")
pdlStyle  = input.string("Solid","S", options=["Solid","Dashed","Dotted"], group=g_day, inline="pdl")
pdlWidth  = input.int(1, "W", 1, 5,             group=g_day, inline="pdl")
pdlTransp = input.int(0, "T", 0, 100,           group=g_day, inline="pdl")
pdlText   = input.string("PDL","Label",         group=g_day, inline="pdl2")

// ===== Asia =====
showAH   = input.bool(true,"Asia High",         group=g_asia, inline="ah")
ahColor  = input.color(color.black, "C",        group=g_asia, inline="ah")
ahStyle  = input.string("Dashed","S", options=["Solid","Dashed","Dotted"], group=g_asia, inline="ah")
ahWidth  = input.int(1, "W", 1, 5,              group=g_asia, inline="ah")
ahTransp = input.int(0, "T", 0, 100,            group=g_asia, inline="ah")
ahText   = input.string("Asia High","Label",    group=g_asia, inline="ah2")

showAL   = input.bool(true,"Asia Low",          group=g_asia, inline="al")
alColor  = input.color(color.black, "C",        group=g_asia, inline="al")
alStyle  = input.string("Dashed","S", options=["Solid","Dashed","Dotted"], group=g_asia, inline="al")
alWidth  = input.int(1, "W", 1, 5,              group=g_asia, inline="al")
alTransp = input.int(0, "T", 0, 100,            group=g_asia, inline="al")
alText   = input.string("Asia Low","Label",     group=g_asia, inline="al2")

// ===== Midnight Open =====
showMO   = input.bool(true,"Midnight Open",     group=g_mid, inline="mo")
moColor  = input.color(color.black, "C",        group=g_mid, inline="mo")
moStyle  = input.string("Dashed","S", options=["Solid","Dashed","Dotted"], group=g_mid, inline="mo")
moWidth  = input.int(1, "W", 1, 5,              group=g_mid, inline="mo")
moTransp = input.int(0, "T", 0, 100,            group=g_mid, inline="mo")
moText   = input.string("00:00","Label",        group=g_mid, inline="mo2")

// ===== London =====
showLH   = input.bool(true,"London High",       group=g_lon, inline="lh")
lhColor  = input.color(color.black, "C",        group=g_lon, inline="lh")
lhStyle  = input.string("Dashed","S", options=["Solid","Dashed","Dotted"], group=g_lon, inline="lh")
lhWidth  = input.int(1, "W", 1, 5,              group=g_lon, inline="lh")
lhTransp = input.int(0, "T", 0, 100,            group=g_lon, inline="lh")
lhText   = input.string("London High","Label",  group=g_lon, inline="lh2")

showLL   = input.bool(true,"London Low",        group=g_lon, inline="ll")
llColor  = input.color(color.black, "C",        group=g_lon, inline="ll")
llStyle  = input.string("Dashed","S", options=["Solid","Dashed","Dotted"], group=g_lon, inline="ll")
llWidth  = input.int(1, "W", 1, 5,              group=g_lon, inline="ll")
llTransp = input.int(0, "T", 0, 100,            group=g_lon, inline="ll")
llText   = input.string("London Low","Label",   group=g_lon, inline="ll2")

// ===== AM Session =====
showAMH   = input.bool(true,"AM High",          group=g_am, inline="amh")
amhColor  = input.color(color.black, "C",       group=g_am, inline="amh")
amhStyle  = input.string("Dashed","S", options=["Solid","Dashed","Dotted"], group=g_am, inline="amh")
amhWidth  = input.int(1, "W", 1, 5,             group=g_am, inline="amh")
amhTransp = input.int(0, "T", 0, 100,           group=g_am, inline="amh")
amhText   = input.string("AM High","Label",     group=g_am, inline="amh2")

showAML   = input.bool(true,"AM Low",           group=g_am, inline="aml")
amlColor  = input.color(color.black, "C",       group=g_am, inline="aml")
amlStyle  = input.string("Dashed","S", options=["Solid","Dashed","Dotted"], group=g_am, inline="aml")
amlWidth  = input.int(1, "W", 1, 5,             group=g_am, inline="aml")
amlTransp = input.int(0, "T", 0, 100,           group=g_am, inline="aml")
amlText   = input.string("AM Low","Label",      group=g_am, inline="aml2")

// ===== RTH Close =====
showRTH   = input.bool(true,"RTH Close",        group=g_rth, inline="rth")
rthColor  = input.color(color.black, "C",       group=g_rth, inline="rth")
rthStyle  = input.string("Dashed","S", options=["Solid","Dashed","Dotted"], group=g_rth, inline="rth")
rthWidth  = input.int(1, "W", 1, 5,             group=g_rth, inline="rth")
rthTransp = input.int(0, "T", 0, 100,           group=g_rth, inline="rth")
rthText   = input.string("RTH Close","Label",   group=g_rth, inline="rth2")

// ===================== HELPERS =====================
getStyle(string name) =>
    switch name
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

getLabelSize(string name) =>
    switch name
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        "huge"   => size.huge
        => size.normal

resolveTextColor(string mode, color lineColor) =>
    switch mode
        "White"      => color.white
        "Match Line" => color.new(lineColor, 0)
        "Black"      => color.black
        "Yellow"     => color.yellow
        "Cyan"       => color.aqua
        "Gray"       => color.gray
        => color.white

// Manage one ray + right-side label.  Anchor is capped to stay inside the
// historical-bar buffer (fixes "historical offset beyond limit" runtime err).
manageRay(lnRef, lbRef, active, price, baseColor, lineTransp, styleName, width, txt) =>
    line  newLn  = lnRef
    label newLb  = lbRef
    lineCol     = color.new(baseColor, lineTransp)
    textCol     = resolveTextColor(labelTextMode, baseColor)
    bgCol       = color.new(color.black, labelTransp)
    safeAnchor  = math.max(bar_index - lineHistoryBars, 0)
    lineEndBar  = bar_index + math.max(labelOffsetBars - lineGapBars, 1)
    labelBar    = bar_index + labelOffsetBars
    if not active or na(price)
        if not na(newLn)
            line.delete(newLn)
            newLn := na
        if not na(newLb)
            label.delete(newLb)
            newLb := na
    else
        if na(newLn)
            newLn := line.new(safeAnchor, price, lineEndBar, price, xloc=xloc.bar_index, extend=extend.none, color=lineCol, style=getStyle(styleName), width=width)
        else
            line.set_xy1(newLn, safeAnchor, price)
            line.set_xy2(newLn, lineEndBar, price)
            line.set_color(newLn, lineCol)
            line.set_width(newLn, width)
            line.set_style(newLn, getStyle(styleName))
        if na(newLb)
            newLb := label.new(labelBar, price, txt, xloc=xloc.bar_index, color=bgCol, textcolor=textCol, style=label.style_label_left, size=getLabelSize(labelSizeIn))
        else
            label.set_xy(newLb, labelBar, price)
            label.set_text(newLb, txt)
            label.set_color(newLb, bgCol)
            label.set_textcolor(newLb, textCol)
            label.set_size(newLb, getLabelSize(labelSizeIn))
    [newLn, newLb]

// ===================== TIME =====================
h         = hour(time, tzInput)
m         = minute(time, tzInput)
dow       = dayofweek(time, tzInput)
minOfDay  = h * 60 + m
prevMinOfDay = nz(h[1] * 60 + m[1], -1)
resetMin  = resetHour * 60

// Bar-CLOSE time (used so RTH catches the bar that closes at 16:15 across any TF)
hClose    = hour(time_close, tzInput)
mClose    = minute(time_close, tzInput)

isResetBar = (minOfDay == resetMin) and (prevMinOfDay != resetMin)
// Trading day = 18:00 today -> 17:00 next day (CME electronic session).
// New trading day fires at the reset bar.  New trading week fires only at the
// Sunday reset bar (Sun 18:00 ET = futures week open).
isNewDay  = isResetBar
isNewWeek = isResetBar and dow == dayofweek.sunday

// Session windows (NY time)
inAsia   = h >= 20 and h <= 23                                  // 20:00 - 23:59
inLondon = h >= 2  and h <= 4                                   // 02:00 - 04:59
inAM     = (h == 9 and m >= 30) or h == 10 or h == 11           // 09:30 - 11:59
isMidnightBar = (minOfDay == 0) and (prevMinOfDay != 0)
// RTH close = the bar whose CLOSE timestamp lands on 16:15 NY.
// On 1m that's the 16:14 bar (closes at 16:15). On 5m that's the 16:10 bar.
isRTHCloseBar = (hClose == 16 and mClose == 15)

// ===================== ROLLING H/L =====================
// Day (CME electronic session, 18:00 -> 17:00)
var float dayHigh = na
var float dayLow = na
var float prevDayHigh = na
var float prevDayLow = na

if isNewDay
    prevDayHigh := dayHigh
    prevDayLow  := dayLow
    dayHigh     := high
    dayLow      := low
else
    if na(dayHigh) or high > dayHigh
        dayHigh := high
    if na(dayLow) or low < dayLow
        dayLow := low

// Week (Sun 18:00 -> Fri 17:00)
var float weekHigh = na
var float weekLow = na
var float weekOpen = na
var float prevWeekHigh = na
var float prevWeekLow = na

if isNewWeek
    prevWeekHigh := weekHigh
    prevWeekLow  := weekLow
    weekHigh := high
    weekLow  := low
    weekOpen := open
else
    if na(weekHigh) or high > weekHigh
        weekHigh := high
    if na(weekLow) or low < weekLow
        weekLow := low

// ===================== SESSION STATE =====================
var float asiaH      = na
var float asiaL      = na
var float lonH       = na
var float lonL       = na
var float amH        = na
var float amL        = na
var float midOpenVal = na
// RTH: rthCloseVal is captured at 16:15 each day; prevRthClose rolls at 18:00
// (same mechanic as PDH/PDL) so the displayed line persists into the next day.
var float rthCloseVal  = na
var float prevRthClose = na

// Asia (20:00 - 00:00)
if inAsia
    if na(asiaH) or not inAsia[1]
        asiaH := high
        asiaL := low
    else
        if high > asiaH
            asiaH := high
        if low < asiaL
            asiaL := low

// London (02:00 - 05:00)
if inLondon
    if na(lonH) or not inLondon[1]
        lonH := high
        lonL := low
    else
        if high > lonH
            lonH := high
        if low < lonL
            lonL := low

// AM (09:30 - 12:00)
if inAM
    if na(amH) or not inAM[1]
        amH := high
        amL := low
    else
        if high > amH
            amH := high
        if low < amL
            amL := low

// Midnight Open - first bar of 00:00
if isMidnightBar
    midOpenVal := open

// RTH Close - capture close of the bar whose close timestamp = 16:15 NY
if isRTHCloseBar
    rthCloseVal := close

// Roll RTH at 18:00 (becomes "previous RTH close", visible all next session)
if isNewDay
    prevRthClose := rthCloseVal

// ===================== 18:00 RESET =====================
// Wipe SESSION lines (Asia, Midnight, London, AM).  PDH/PDL/RTH and weekly
// keep rolling and stay visible into the new trading day.
var line  ln_wo  = na
var label lb_wo  = na
var line  ln_pwh = na
var label lb_pwh = na
var line  ln_pwl = na
var label lb_pwl = na
var line  ln_wh  = na
var label lb_wh  = na
var line  ln_wl  = na
var label lb_wl  = na
var line  ln_pdh = na
var label lb_pdh = na
var line  ln_pdl = na
var label lb_pdl = na
var line  ln_ah  = na
var label lb_ah  = na
var line  ln_al  = na
var label lb_al  = na
var line  ln_mo  = na
var label lb_mo  = na
var line  ln_lh  = na
var label lb_lh  = na
var line  ln_ll  = na
var label lb_ll  = na
var line  ln_amh = na
var label lb_amh = na
var line  ln_aml = na
var label lb_aml = na
var line  ln_rth = na
var label lb_rth = na

if isResetBar
    if not na(ln_ah)
        line.delete(ln_ah)
        ln_ah := na
    if not na(lb_ah)
        label.delete(lb_ah)
        lb_ah := na
    if not na(ln_al)
        line.delete(ln_al)
        ln_al := na
    if not na(lb_al)
        label.delete(lb_al)
        lb_al := na
    if not na(ln_mo)
        line.delete(ln_mo)
        ln_mo := na
    if not na(lb_mo)
        label.delete(lb_mo)
        lb_mo := na
    if not na(ln_lh)
        line.delete(ln_lh)
        ln_lh := na
    if not na(lb_lh)
        label.delete(lb_lh)
        lb_lh := na
    if not na(ln_ll)
        line.delete(ln_ll)
        ln_ll := na
    if not na(lb_ll)
        label.delete(lb_ll)
        lb_ll := na
    if not na(ln_amh)
        line.delete(ln_amh)
        ln_amh := na
    if not na(lb_amh)
        label.delete(lb_amh)
        lb_amh := na
    if not na(ln_aml)
        line.delete(ln_aml)
        ln_aml := na
    if not na(lb_aml)
        label.delete(lb_aml)
        lb_aml := na
    asiaH      := na
    asiaL      := na
    lonH       := na
    lonL       := na
    amH        := na
    amL        := na
    midOpenVal := na

// ===================== DRAW (every bar) =====================
// Weekly (drawn first per spec)
[r_wo_l, r_wo_b]   = manageRay(ln_wo,  lb_wo,  showWO,  weekOpen,     woColor,  woTransp,  woStyle,  woWidth,  woText)
ln_wo  := r_wo_l
lb_wo  := r_wo_b
[r_pwh_l, r_pwh_b] = manageRay(ln_pwh, lb_pwh, showPWH, prevWeekHigh, pwhColor, pwhTransp, pwhStyle, pwhWidth, pwhText)
ln_pwh := r_pwh_l
lb_pwh := r_pwh_b
[r_pwl_l, r_pwl_b] = manageRay(ln_pwl, lb_pwl, showPWL, prevWeekLow,  pwlColor, pwlTransp, pwlStyle, pwlWidth, pwlText)
ln_pwl := r_pwl_l
lb_pwl := r_pwl_b
[r_wh_l, r_wh_b]   = manageRay(ln_wh,  lb_wh,  showWH,  weekHigh,     whColor,  whTransp,  whStyle,  whWidth,  whText)
ln_wh  := r_wh_l
lb_wh  := r_wh_b
[r_wl_l, r_wl_b]   = manageRay(ln_wl,  lb_wl,  showWL,  weekLow,      wlColor,  wlTransp,  wlStyle,  wlWidth,  wlText)
ln_wl  := r_wl_l
lb_wl  := r_wl_b

// Daily (previous trading day's H/L)
[r_pdh_l, r_pdh_b] = manageRay(ln_pdh, lb_pdh, showPDH, prevDayHigh, pdhColor, pdhTransp, pdhStyle, pdhWidth, pdhText)
ln_pdh := r_pdh_l
lb_pdh := r_pdh_b
[r_pdl_l, r_pdl_b] = manageRay(ln_pdl, lb_pdl, showPDL, prevDayLow,  pdlColor, pdlTransp, pdlStyle, pdlWidth, pdlText)
ln_pdl := r_pdl_l
lb_pdl := r_pdl_b

// RTH Close - persists like PDH/PDL (previous trading day's RTH close)
[r_rth_l, r_rth_b] = manageRay(ln_rth, lb_rth, showRTH, prevRthClose, rthColor, rthTransp, rthStyle, rthWidth, rthText)
ln_rth := r_rth_l
lb_rth := r_rth_b

// Sessions (appear as they form, wiped at 18:00)
[r_ah_l, r_ah_b] = manageRay(ln_ah, lb_ah, showAH, asiaH, ahColor, ahTransp, ahStyle, ahWidth, ahText)
ln_ah := r_ah_l
lb_ah := r_ah_b
[r_al_l, r_al_b] = manageRay(ln_al, lb_al, showAL, asiaL, alColor, alTransp, alStyle, alWidth, alText)
ln_al := r_al_l
lb_al := r_al_b

[r_mo_l, r_mo_b] = manageRay(ln_mo, lb_mo, showMO, midOpenVal, moColor, moTransp, moStyle, moWidth, moText)
ln_mo := r_mo_l
lb_mo := r_mo_b

[r_lh_l, r_lh_b] = manageRay(ln_lh, lb_lh, showLH, lonH, lhColor, lhTransp, lhStyle, lhWidth, lhText)
ln_lh := r_lh_l
lb_lh := r_lh_b
[r_ll_l, r_ll_b] = manageRay(ln_ll, lb_ll, showLL, lonL, llColor, llTransp, llStyle, llWidth, llText)
ln_ll := r_ll_l
lb_ll := r_ll_b

[r_amh_l, r_amh_b] = manageRay(ln_amh, lb_amh, showAMH, amH, amhColor, amhTransp, amhStyle, amhWidth, amhText)
ln_amh := r_amh_l
lb_amh := r_amh_b
[r_aml_l, r_aml_b] = manageRay(ln_aml, lb_aml, showAML, amL, amlColor, amlTransp, amlStyle, amlWidth, amlText)
ln_aml := r_aml_l
lb_aml := r_aml_b
````
