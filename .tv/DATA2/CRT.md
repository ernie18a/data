<!-- tradingview-pine-id: PUB;cbea0c57701a42e896dee314c06fceb3 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# CRT

Source: https://www.tradingview.com/script/x7oQy4VG/

## Description

CRT TCT — Market Structure & Liquidity Toolkit

CRT TCT is a complete price action and market structure indicator designed to help traders identify key liquidity areas, structural shifts, session ranges, and potential liquidity sweeps directly on the chart.

The indicator combines multiple concepts into one clean and customizable trading toolkit, allowing traders to analyze market structure and liquidity without overcrowding their charts.

Key Features

• BOS & CHoCH Detection
Automatically identifies Break of Structure (BOS) and Change of Character (CHoCH) to help visualize bullish and bearish market structure.

• Liquidity Levels
Automatically detects and tracks relevant swing highs and swing lows as potential liquidity areas. Levels remain visible until price trades through them.

• Liquidity Sweeps
Identifies potential bullish and bearish liquidity sweeps where price takes a previous high or low and rejects the level.

• Multi-Timeframe Key Levels
Displays important previous highs and lows from:

H4
Daily
8:00 AM New York H1
9:00 AM New York H1

• Trading Sessions / Kill Zones
Visualizes the main institutional trading sessions:

Asian Session
London Session
New York Session

Session highs and lows can also be extended forward as potential liquidity targets until they are reached.

• Custom Market Structure Timeframe
BOS and CHoCH analysis can use the current chart timeframe or a fixed timeframe such as 5m, 15m, 30m, 1H, 4H, or Daily.

• Market Structure Dashboard
A compact dashboard provides a quick overview of:

Current structural bias
Selected structure timeframe
Active liquidity above price
Active liquidity below price

• Fully Customizable
Traders can independently enable or disable market structure, liquidity, sweeps, higher-timeframe levels, sessions, and other visual elements.

How It Can Be Used

CRT TCT is designed as a confluence and market-reading tool rather than a standalone buy/sell signal system.

It can help traders identify:

Where liquidity may be resting
When liquidity has been swept
Changes in market structure
Continuation through BOS
Important higher-timeframe levels
Session highs and lows
Potential areas of interest during key trading sessions

The indicator can be used across different markets and timeframes depending on the trader's methodology.

Important: This indicator is intended for educational and analytical purposes only. It does not provide financial advice or guarantee profitable trades. Always use proper risk management and combine the information provided by the indicator with your own trading plan and analysis.

---

## Source Code

````pine
//@version=6
indicator("CRT", shorttitle="CRT", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=150)

// ─────────────────────────────────────────────
// VISIBILIDAD
// ─────────────────────────────────────────────

i_showBosChoch  = input.bool(true,  "Mostrar BOS / CHoCH",         group="Visibilidad")
i_showLiq       = input.bool(true,  "Mostrar Liquidez (bombitas)", group="Visibilidad")
i_showSweep     = input.bool(true,  "Mostrar Sweeps",              group="Visibilidad")
i_showH4        = input.bool(true,  "Mostrar H4 PH/PL",            group="Visibilidad")
i_showDaily     = input.bool(true,  "Mostrar Daily PH/PL",          group="Visibilidad")
i_showH1NY      = input.bool(true,  "Mostrar H1 9AM NY PH/PL",     group="Visibilidad")
i_showH1_8NY    = input.bool(true,  "Mostrar H1 8AM NY PH/PL",     group="Visibilidad")
i_showAsia      = input.bool(true,  "Mostrar Sesión Asia",          group="Visibilidad")
i_showLondon    = input.bool(false, "Mostrar Sesión Londres",       group="Visibilidad")
i_showNY        = input.bool(false, "Mostrar Sesión Nueva York",    group="Visibilidad")

i_swingLen = input.int(5, "Sensibilidad Swings",             minval=1, maxval=50, group="Configuración")
MAX_LIQ    = input.int(5, "Cantidad de niveles de liquidez", minval=1, maxval=20, group="Configuración")

i_useChartTF = input.bool(false, "Usar temporalidad del gráfico", group="BOS / CHoCH TF")
i_bosChochTF = input.string("30", "Temporalidad fija",
     options=["5", "15", "30", "60", "240", "D"], group="BOS / CHoCH TF")

h4Col     = input.color(color.new(color.orange, 20), "Color H4",        group="H4 / Daily / H1")
dailyCol  = input.color(color.new(color.yellow, 20), "Color Daily",     group="H4 / Daily / H1")
h1NYCol   = input.color(color.new(color.aqua,   20), "Color H1 9AM NY", group="H4 / Daily / H1")
h1_8NYCol = input.color(color.new(color.purple, 20), "Color H1 8AM NY", group="H4 / Daily / H1")

sweepCooldown = input.int(10, "Cooldown Sweep (barras)", minval=0,          group="Sweep")
sweepBullCol  = input.color(color.new(color.teal, 0),   "Color Sweep Alcista", group="Sweep")
sweepBearCol  = input.color(color.new(color.red,  0),   "Color Sweep Bajista", group="Sweep")

asiaCol          = input.color(color.new(color.red, 80),  "Color Asia",      group="Kill Zone — Asia")
asiaBorderCol    = input.color(color.new(color.red, 20),  "Borde Asia",      group="Kill Zone — Asia")
asiaSessionStart = input.session("1900-0001",              "Asia Session",    group="Kill Zone — Asia")
i_asiaLines      = input.bool(true, "Líneas PH/PL Asia",                     group="Kill Zone — Asia")

londonCol          = input.color(color.new(color.blue, 80),  "Color Londres",   group="Kill Zone — Londres")
londonBorderCol    = input.color(color.new(color.blue, 20),  "Borde Londres",   group="Kill Zone — Londres")
londonSessionStart = input.session("0200-0830",               "Londres Session", group="Kill Zone — Londres")
i_londonLines      = input.bool(true, "Líneas PH/PL Londres",                   group="Kill Zone — Londres")

nyCol          = input.color(color.new(color.orange, 80), "Color Nueva York",    group="Kill Zone — Nueva York")
nyBorderCol    = input.color(color.new(color.orange, 20), "Borde Nueva York",    group="Kill Zone — Nueva York")
nySessionStart = input.session("0930-1600",                "Nueva York Session",  group="Kill Zone — Nueva York")
i_nyLines      = input.bool(true, "Líneas PH/PL Nueva York",                     group="Kill Zone — Nueva York")

i_showTimeLine = input.bool(false, "Línea vertical de horario",   group="Línea Horario")
i_timeHour     = input.int(9,  "H", minval=0, maxval=23,          group="Línea Horario", inline="hora")
i_timeMin      = input.int(30, "M", minval=0, maxval=59,          group="Línea Horario", inline="hora")
i_timeColor    = input.color(color.new(color.white, 40), "Color", group="Línea Horario")

string bcTF = i_useChartTF ? timeframe.period : i_bosChochTF

// ─────────────────────────────────────────────
// PIVOTS GRÁFICO
// ─────────────────────────────────────────────

phVal  = ta.pivothigh(high, i_swingLen, i_swingLen)
plVal  = ta.pivotlow(low,  i_swingLen, i_swingLen)
phTime = time[i_swingLen]
plTime = time[i_swingLen]

// ─────────────────────────────────────────────
// LIQUIDEZ
// ─────────────────────────────────────────────

var float[] liqHighs     = array.new_float(0)
var int[]   liqHighTimes = array.new_int(0)
var line[]  liqHighLines = array.new_line(0)
var label[] liqHighDots  = array.new_label(0)
var float[] liqLows      = array.new_float(0)
var int[]   liqLowTimes  = array.new_int(0)
var line[]  liqLowLines  = array.new_line(0)
var label[] liqLowDots   = array.new_label(0)

if not na(phVal) and i_showLiq
    array.unshift(liqHighs, phVal)
    array.unshift(liqHighTimes, phTime)
    _lh = line.new(x1=phTime, y1=phVal, x2=time, y2=phVal, xloc=xloc.bar_time,
                   color=color.new(color.red, 50), style=line.style_dotted, width=1)
    array.unshift(liqHighLines, _lh)
    _dh = label.new(x=phTime, y=phVal, text="●", xloc=xloc.bar_time, yloc=yloc.price,
                    style=label.style_none, textcolor=color.new(color.red, 20), size=size.normal)
    array.unshift(liqHighDots, _dh)
    if array.size(liqHighs) > MAX_LIQ
        array.pop(liqHighs)
        array.pop(liqHighTimes)
        line.delete(array.pop(liqHighLines))
        label.delete(array.pop(liqHighDots))

if not na(plVal) and i_showLiq
    array.unshift(liqLows, plVal)
    array.unshift(liqLowTimes, plTime)
    _ll = line.new(x1=plTime, y1=plVal, x2=time, y2=plVal, xloc=xloc.bar_time,
                   color=color.new(color.teal, 50), style=line.style_dotted, width=1)
    array.unshift(liqLowLines, _ll)
    _dl = label.new(x=plTime, y=plVal, text="●", xloc=xloc.bar_time, yloc=yloc.price,
                    style=label.style_none, textcolor=color.new(color.teal, 20), size=size.normal)
    array.unshift(liqLowDots, _dl)
    if array.size(liqLows) > MAX_LIQ
        array.pop(liqLows)
        array.pop(liqLowTimes)
        line.delete(array.pop(liqLowLines))
        label.delete(array.pop(liqLowDots))

if i_showLiq
    if array.size(liqHighLines) > 0
        for i = 0 to array.size(liqHighLines) - 1
            line.set_x2(array.get(liqHighLines, i), time)
    if array.size(liqLowLines) > 0
        for i = 0 to array.size(liqLowLines) - 1
            line.set_x2(array.get(liqLowLines, i), time)

if array.size(liqHighs) > 0
    i = 0
    while i < array.size(liqHighs)
        if high >= array.get(liqHighs, i)
            array.remove(liqHighs, i)
            array.remove(liqHighTimes, i)
            line.delete(array.remove(liqHighLines, i))
            label.delete(array.remove(liqHighDots, i))
        else
            i += 1

if array.size(liqLows) > 0
    i = 0
    while i < array.size(liqLows)
        if low <= array.get(liqLows, i)
            array.remove(liqLows, i)
            array.remove(liqLowTimes, i)
            line.delete(array.remove(liqLowLines, i))
            label.delete(array.remove(liqLowDots, i))
        else
            i += 1

// ─────────────────────────────────────────────
// BOS / CHoCH
// ─────────────────────────────────────────────

htfPH     = request.security(syminfo.tickerid, bcTF, ta.pivothigh(high, 5, 5), lookahead=barmerge.lookahead_off)
htfPL     = request.security(syminfo.tickerid, bcTF, ta.pivotlow(low,  5, 5),  lookahead=barmerge.lookahead_off)
htfPHTime = request.security(syminfo.tickerid, bcTF, time[5], lookahead=barmerge.lookahead_off)
htfPLTime = request.security(syminfo.tickerid, bcTF, time[5], lookahead=barmerge.lookahead_off)
htfClose  = request.security(syminfo.tickerid, bcTF, close,   lookahead=barmerge.lookahead_off)

var float htfLastSH     = na
var int   htfLastSHTime = na
var float htfLastSL     = na
var int   htfLastSLTime = na
var int   trend         = 0

if not na(htfPH)
    htfLastSH     := htfPH
    htfLastSHTime := htfPHTime
if not na(htfPL)
    htfLastSL     := htfPL
    htfLastSLTime := htfPLTime

bool htfBullBreakBody = not na(htfLastSH) and htfClose > htfLastSH and barstate.isconfirmed
bool htfBearBreakBody = not na(htfLastSL) and htfClose < htfLastSL and barstate.isconfirmed

color grisCol = color.new(color.gray, 30)
f_midTime(_t1, _t2) => int(_t1 + (_t2 - _t1) / 2)

f_drawStructure(_x1, _y, _x2, _txt) =>
    line.new(x1=_x1, y1=_y, x2=_x2, y2=_y, xloc=xloc.bar_time,
             color=grisCol, style=line.style_solid, width=1)
    label.new(x=f_midTime(_x1, _x2), y=_y, text=_txt, xloc=xloc.bar_time, yloc=yloc.price,
              style=label.style_none, textcolor=grisCol, size=size.small)

if i_showBosChoch
    if htfBullBreakBody and trend != 1
        f_drawStructure(htfLastSHTime, htfLastSH, time, "CHoCH")
        trend     := 1
        htfLastSH := na
    else if htfBullBreakBody and trend == 1
        f_drawStructure(htfLastSHTime, htfLastSH, time, "BOS")
        htfLastSH := na
    if htfBearBreakBody and trend != -1
        f_drawStructure(htfLastSLTime, htfLastSL, time, "CHoCH")
        trend     := -1
        htfLastSL := na
    else if htfBearBreakBody and trend == -1
        f_drawStructure(htfLastSLTime, htfLastSL, time, "BOS")
        htfLastSL := na

// ─────────────────────────────────────────────
// SWEEP
// ─────────────────────────────────────────────

sweepLB    = 20
pLowSweep  = ta.pivotlow(low,   sweepLB, sweepLB)
pHighSweep = ta.pivothigh(high, sweepLB, sweepLB)
pLowVal    = ta.valuewhen(not na(pLowSweep),  low[sweepLB],        0)
pHighVal   = ta.valuewhen(not na(pHighSweep), high[sweepLB],       0)
prevLowIdx = ta.valuewhen(not na(pLowSweep),  bar_index[sweepLB],  0)
prevHiIdx  = ta.valuewhen(not na(pHighSweep), bar_index[sweepLB],  0)
lp = ta.lowest(low,    sweepLB)
hp = ta.highest(high,  sweepLB)
hc = ta.highest(close, sweepLB)
lc = ta.lowest(close,  sweepLB)
bullSFP = low  < pLowVal  and close > pLowVal  and open > pLowVal  and low  == lp and lc >= pLowVal
bearSFP = high > pHighVal and close < pHighVal and open < pHighVal and high == hp and hc <= pHighVal
var int bullSweepIdx = 0
var int bearSweepIdx = 0
bullCond = bullSFP[3] and close > pLowVal   and close[1] > pLowVal[1]  and close[2] > pLowVal[2]  and bar_index >= bullSweepIdx + sweepCooldown
bearCond = bearSFP[3] and close < pHighVal  and close[1] < pHighVal[1] and close[2] < pHighVal[2] and bar_index >= bearSweepIdx + sweepCooldown
if i_showSweep and bullCond
    bullSweepIdx := bar_index
    line.new(prevLowIdx, pLowVal, bar_index - 3, pLowVal, color=sweepBullCol, style=line.style_dashed, width=1)
if i_showSweep and bearCond
    bearSweepIdx := bar_index
    line.new(prevHiIdx, pHighVal, bar_index - 3, pHighVal, color=sweepBearCol, style=line.style_dashed, width=1)
alertcondition(bullCond, title="⚡ SWEEP ▲", message="⚡ SWEEP ▲ — Barrida de mínimos")
alertcondition(bearCond, title="⚡ SWEEP ▼", message="⚡ SWEEP ▼ — Barrida de máximos")

// ─────────────────────────────────────────────
// H4
// ─────────────────────────────────────────────

h4High      = request.security(syminfo.tickerid, "240", high[1], lookahead=barmerge.lookahead_on)
h4Low       = request.security(syminfo.tickerid, "240", low[1],  lookahead=barmerge.lookahead_on)
h4StartTime = request.security(syminfo.tickerid, "240", time[1], lookahead=barmerge.lookahead_on)
var line  h4PHLine = na
var line  h4PLLine = na
var label h4PHLbl  = na
var label h4PLLbl  = na
if i_showH4 and barstate.islast
    line.delete(h4PHLine)
    line.delete(h4PLLine)
    label.delete(h4PHLbl)
    label.delete(h4PLLbl)
    int h4End = time + (time - time[1]) * 5
    h4PHLine := line.new(x1=h4StartTime, y1=h4High, x2=h4End, y2=h4High, xloc=xloc.bar_time, color=h4Col, style=line.style_dotted, width=1)
    h4PLLine := line.new(x1=h4StartTime, y1=h4Low,  x2=h4End, y2=h4Low,  xloc=xloc.bar_time, color=h4Col, style=line.style_dotted, width=1)
    h4PHLbl  := label.new(x=h4End, y=h4High, text="H4 PH", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=h4Col, size=size.small)
    h4PLLbl  := label.new(x=h4End, y=h4Low,  text="H4 PL", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=h4Col, size=size.small)

// ─────────────────────────────────────────────
// DAILY
// ─────────────────────────────────────────────

dHigh      = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
dLow       = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)
dStartTime = request.security(syminfo.tickerid, "D", time[1], lookahead=barmerge.lookahead_on)
var line  dPHLine = na
var line  dPLLine = na
var label dPHLbl  = na
var label dPLLbl  = na
if i_showDaily and barstate.islast
    line.delete(dPHLine)
    line.delete(dPLLine)
    label.delete(dPHLbl)
    label.delete(dPLLbl)
    int dEnd = time + (time - time[1]) * 5
    dPHLine := line.new(x1=dStartTime, y1=dHigh, x2=dEnd, y2=dHigh, xloc=xloc.bar_time, color=dailyCol, style=line.style_dotted, width=1)
    dPLLine := line.new(x1=dStartTime, y1=dLow,  x2=dEnd, y2=dLow,  xloc=xloc.bar_time, color=dailyCol, style=line.style_dotted, width=1)
    dPHLbl  := label.new(x=dEnd, y=dHigh, text="D PH", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=dailyCol, size=size.small)
    dPLLbl  := label.new(x=dEnd, y=dLow,  text="D PL", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=dailyCol, size=size.small)

// ─────────────────────────────────────────────
// H1 9AM NY — termina a las 5PM NY (9AM + 8h)
// ─────────────────────────────────────────────

int chartHourNY = hour(time, "America/New_York")
int chartDayNY  = dayofmonth(time, "America/New_York") + month(time, "America/New_York") * 100

var float h1NYHigh       = na
var float h1NYLow        = na
var int   h1NYStartTime  = na
var int   h1NYDay        = na
var float h1NYHighFixed  = na
var float h1NYLowFixed   = na
var int   h1NYStartFixed = na
var bool  h1NYFijado     = false
var line  h1NYPHLine = na
var line  h1NYPLLine = na
var label h1NYPHLbl  = na
var label h1NYPLLbl  = na

if i_showH1NY
    if chartHourNY == 9
        if na(h1NYDay) or h1NYDay != chartDayNY
            h1NYHigh      := high
            h1NYLow       := low
            h1NYStartTime := time
            h1NYDay       := chartDayNY
            h1NYFijado    := false
        else
            h1NYHigh := math.max(h1NYHigh, high)
            h1NYLow  := math.min(h1NYLow,  low)
    if chartHourNY == 10 and not na(h1NYDay) and h1NYDay == chartDayNY and not h1NYFijado and not na(h1NYHigh)
        h1NYHighFixed  := h1NYHigh
        h1NYLowFixed   := h1NYLow
        h1NYStartFixed := h1NYStartTime
        h1NYFijado     := true

if i_showH1NY and barstate.islast and not na(h1NYHighFixed)
    line.delete(h1NYPHLine)
    line.delete(h1NYPLLine)
    label.delete(h1NYPHLbl)
    label.delete(h1NYPLLbl)
    int h1End = h1NYStartFixed + 8 * 60 * 60 * 1000  // 9AM + 8h = 5PM NY
    h1NYPHLine := line.new(x1=h1NYStartFixed, y1=h1NYHighFixed, x2=h1End, y2=h1NYHighFixed, xloc=xloc.bar_time, color=h1NYCol, style=line.style_dotted, width=1)
    h1NYPLLine := line.new(x1=h1NYStartFixed, y1=h1NYLowFixed,  x2=h1End, y2=h1NYLowFixed,  xloc=xloc.bar_time, color=h1NYCol, style=line.style_dotted, width=1)
    h1NYPHLbl  := label.new(x=h1End, y=h1NYHighFixed, text="H1 9AM", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=h1NYCol, size=size.small)
    h1NYPLLbl  := label.new(x=h1End, y=h1NYLowFixed,  text="H1 9AM", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=h1NYCol, size=size.small)

// ─────────────────────────────────────────────
// H1 8AM NY — termina a las 5PM NY (8AM + 9h)
// ─────────────────────────────────────────────

var float h1_8NYHigh       = na
var float h1_8NYLow        = na
var int   h1_8NYStartTime  = na
var int   h1_8NYDay        = na
var float h1_8NYHighFixed  = na
var float h1_8NYLowFixed   = na
var int   h1_8NYStartFixed = na
var bool  h1_8NYFijado     = false
var line  h1_8NYPHLine = na
var line  h1_8NYPLLine = na
var label h1_8NYPHLbl  = na
var label h1_8NYPLLbl  = na

if i_showH1_8NY
    if chartHourNY == 8
        if na(h1_8NYDay) or h1_8NYDay != chartDayNY
            h1_8NYHigh      := high
            h1_8NYLow       := low
            h1_8NYStartTime := time
            h1_8NYDay       := chartDayNY
            h1_8NYFijado    := false
        else
            h1_8NYHigh := math.max(h1_8NYHigh, high)
            h1_8NYLow  := math.min(h1_8NYLow,  low)
    if chartHourNY == 9 and not na(h1_8NYDay) and h1_8NYDay == chartDayNY and not h1_8NYFijado and not na(h1_8NYHigh)
        h1_8NYHighFixed  := h1_8NYHigh
        h1_8NYLowFixed   := h1_8NYLow
        h1_8NYStartFixed := h1_8NYStartTime
        h1_8NYFijado     := true

if i_showH1_8NY and barstate.islast and not na(h1_8NYHighFixed)
    line.delete(h1_8NYPHLine)
    line.delete(h1_8NYPLLine)
    label.delete(h1_8NYPHLbl)
    label.delete(h1_8NYPLLbl)
    int h1_8End = h1_8NYStartFixed + 9 * 60 * 60 * 1000  // 8AM + 9h = 5PM NY
    h1_8NYPHLine := line.new(x1=h1_8NYStartFixed, y1=h1_8NYHighFixed, x2=h1_8End, y2=h1_8NYHighFixed, xloc=xloc.bar_time, color=h1_8NYCol, style=line.style_dotted, width=1)
    h1_8NYPLLine := line.new(x1=h1_8NYStartFixed, y1=h1_8NYLowFixed,  x2=h1_8End, y2=h1_8NYLowFixed,  xloc=xloc.bar_time, color=h1_8NYCol, style=line.style_dotted, width=1)
    h1_8NYPHLbl  := label.new(x=h1_8End, y=h1_8NYHighFixed, text="H1 8AM", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=h1_8NYCol, size=size.small)
    h1_8NYPLLbl  := label.new(x=h1_8End, y=h1_8NYLowFixed,  text="H1 8AM", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=h1_8NYCol, size=size.small)

// ─────────────────────────────────────────────
// KILL ZONE — ASIA + líneas PH/PL
// ─────────────────────────────────────────────

bool inAsia        = not na(time(timeframe.period, asiaSessionStart, "America/New_York"))
var int   asiaStartBar = na
var float asiaHigh     = na
var float asiaLow      = na
var bool  wasInAsia    = false

var float[] asiaHighLevels = array.new_float(0)
var float[] asiaLowLevels  = array.new_float(0)
var line[]  asiaHighLines  = array.new_line(0)
var line[]  asiaLowLines   = array.new_line(0)

if i_showAsia
    if inAsia and not wasInAsia
        asiaStartBar := bar_index
        asiaHigh     := high
        asiaLow      := low
    if inAsia
        asiaHigh := math.max(asiaHigh, high)
        asiaLow  := math.min(asiaLow,  low)
    if not inAsia and wasInAsia and not na(asiaStartBar)
        box.new(left=asiaStartBar, top=asiaHigh, right=bar_index - 1,
                bottom=asiaLow, bgcolor=asiaCol,
                border_color=asiaBorderCol, border_width=1, border_style=line.style_dashed)
        label.new(x=math.round((asiaStartBar + bar_index - 1) / 2), y=asiaHigh,
                  text="Asian", xloc=xloc.bar_index, yloc=yloc.price,
                  style=label.style_label_down, color=color.new(color.black, 100),
                  textcolor=asiaBorderCol, size=size.small)
        if i_asiaLines
            array.push(asiaHighLevels, asiaHigh)
            array.push(asiaLowLevels,  asiaLow)
            array.push(asiaHighLines,
                 line.new(x1=bar_index, y1=asiaHigh, x2=bar_index + 1, y2=asiaHigh,
                 color=asiaBorderCol, style=line.style_dashed, width=1))
            array.push(asiaLowLines,
                 line.new(x1=bar_index, y1=asiaLow, x2=bar_index + 1, y2=asiaLow,
                 color=asiaBorderCol, style=line.style_dashed, width=1))
        asiaStartBar := na
        asiaHigh     := na
        asiaLow      := na
    wasInAsia := inAsia

if i_showAsia and i_asiaLines
    if array.size(asiaHighLines) > 0
        i = 0
        while i < array.size(asiaHighLines)
            line.set_x2(array.get(asiaHighLines, i), bar_index)
            if high >= array.get(asiaHighLevels, i)
                line.delete(array.remove(asiaHighLines, i))
                array.remove(asiaHighLevels, i)
            else
                i += 1
    if array.size(asiaLowLines) > 0
        i = 0
        while i < array.size(asiaLowLines)
            line.set_x2(array.get(asiaLowLines, i), bar_index)
            if low <= array.get(asiaLowLevels, i)
                line.delete(array.remove(asiaLowLines, i))
                array.remove(asiaLowLevels, i)
            else
                i += 1

// ─────────────────────────────────────────────
// KILL ZONE — LONDRES + líneas PH/PL
// ─────────────────────────────────────────────

bool inLondon        = not na(time(timeframe.period, londonSessionStart, "America/New_York"))
var int   londonStartBar = na
var float londonHigh     = na
var float londonLow      = na
var bool  wasInLondon    = false

var float[] londonHighLevels = array.new_float(0)
var float[] londonLowLevels  = array.new_float(0)
var line[]  londonHighLines  = array.new_line(0)
var line[]  londonLowLines   = array.new_line(0)

if i_showLondon
    if inLondon and not wasInLondon
        londonStartBar := bar_index
        londonHigh     := high
        londonLow      := low
    if inLondon
        londonHigh := math.max(londonHigh, high)
        londonLow  := math.min(londonLow,  low)
    if not inLondon and wasInLondon and not na(londonStartBar)
        box.new(left=londonStartBar, top=londonHigh, right=bar_index - 1,
                bottom=londonLow, bgcolor=londonCol,
                border_color=londonBorderCol, border_width=1, border_style=line.style_dashed)
        label.new(x=math.round((londonStartBar + bar_index - 1) / 2), y=londonHigh,
                  text="London", xloc=xloc.bar_index, yloc=yloc.price,
                  style=label.style_label_down, color=color.new(color.black, 100),
                  textcolor=londonBorderCol, size=size.small)
        if i_londonLines
            array.push(londonHighLevels, londonHigh)
            array.push(londonLowLevels,  londonLow)
            array.push(londonHighLines,
                 line.new(x1=bar_index, y1=londonHigh, x2=bar_index + 1, y2=londonHigh,
                 color=londonBorderCol, style=line.style_dashed, width=1))
            array.push(londonLowLines,
                 line.new(x1=bar_index, y1=londonLow, x2=bar_index + 1, y2=londonLow,
                 color=londonBorderCol, style=line.style_dashed, width=1))
        londonStartBar := na
        londonHigh     := na
        londonLow      := na
    wasInLondon := inLondon

if i_showLondon and i_londonLines
    if array.size(londonHighLines) > 0
        i = 0
        while i < array.size(londonHighLines)
            line.set_x2(array.get(londonHighLines, i), bar_index)
            if high >= array.get(londonHighLevels, i)
                line.delete(array.remove(londonHighLines, i))
                array.remove(londonHighLevels, i)
            else
                i += 1
    if array.size(londonLowLines) > 0
        i = 0
        while i < array.size(londonLowLines)
            line.set_x2(array.get(londonLowLines, i), bar_index)
            if low <= array.get(londonLowLevels, i)
                line.delete(array.remove(londonLowLines, i))
                array.remove(londonLowLevels, i)
            else
                i += 1

// ─────────────────────────────────────────────
// KILL ZONE — NUEVA YORK + líneas PH/PL
// ─────────────────────────────────────────────

bool inNY        = not na(time(timeframe.period, nySessionStart, "America/New_York"))
var int   nyStartBar = na
var float nyHigh     = na
var float nyLow      = na
var bool  wasInNY    = false

var float[] nyHighLevels = array.new_float(0)
var float[] nyLowLevels  = array.new_float(0)
var line[]  nyHighLines  = array.new_line(0)
var line[]  nyLowLines   = array.new_line(0)

if i_showNY
    if inNY and not wasInNY
        nyStartBar := bar_index
        nyHigh     := high
        nyLow      := low
    if inNY
        nyHigh := math.max(nyHigh, high)
        nyLow  := math.min(nyLow,  low)
    if not inNY and wasInNY and not na(nyStartBar)
        box.new(left=nyStartBar, top=nyHigh, right=bar_index - 1,
                bottom=nyLow, bgcolor=nyCol,
                border_color=nyBorderCol, border_width=1, border_style=line.style_dashed)
        label.new(x=math.round((nyStartBar + bar_index - 1) / 2), y=nyHigh,
                  text="New York", xloc=xloc.bar_index, yloc=yloc.price,
                  style=label.style_label_down, color=color.new(color.black, 100),
                  textcolor=nyBorderCol, size=size.small)
        if i_nyLines
            array.push(nyHighLevels, nyHigh)
            array.push(nyLowLevels,  nyLow)
            array.push(nyHighLines,
                 line.new(x1=bar_index, y1=nyHigh, x2=bar_index + 1, y2=nyHigh,
                 color=nyBorderCol, style=line.style_dashed, width=1))
            array.push(nyLowLines,
                 line.new(x1=bar_index, y1=nyLow, x2=bar_index + 1, y2=nyLow,
                 color=nyBorderCol, style=line.style_dashed, width=1))
        nyStartBar := na
        nyHigh     := na
        nyLow      := na
    wasInNY := inNY

if i_showNY and i_nyLines
    if array.size(nyHighLines) > 0
        i = 0
        while i < array.size(nyHighLines)
            line.set_x2(array.get(nyHighLines, i), bar_index)
            if high >= array.get(nyHighLevels, i)
                line.delete(array.remove(nyHighLines, i))
                array.remove(nyHighLevels, i)
            else
                i += 1
    if array.size(nyLowLines) > 0
        i = 0
        while i < array.size(nyLowLines)
            line.set_x2(array.get(nyLowLines, i), bar_index)
            if low <= array.get(nyLowLevels, i)
                line.delete(array.remove(nyLowLines, i))
                array.remove(nyLowLevels, i)
            else
                i += 1

// ─────────────────────────────────────────────
// LÍNEA VERTICAL DE HORARIO
// ─────────────────────────────────────────────

if i_showTimeLine
    barHour   = hour(time,   "America/New_York")
    barMinute = minute(time, "America/New_York")
    if barHour == i_timeHour and barMinute == i_timeMin
        line.new(x1=bar_index, y1=low * 0.95, x2=bar_index, y2=high * 1.05,
                 color=i_timeColor, style=line.style_dotted, width=1, extend=extend.both)

// ─────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────

var table dash = table.new(position.top_right, 2, 4,
     bgcolor=color.new(color.black, 70), border_color=color.new(color.gray, 50),
     border_width=1, frame_color=color.new(color.gray, 30), frame_width=1)

if barstate.islast
    string tfLabel     = i_useChartTF ? timeframe.period : i_bosChochTF
    string structTxt   = trend == 1 ? "▲ Alcista" : trend == -1 ? "▼ Bajista" : "— Neutro"
    color  structColor = trend == 1 ? color.new(color.teal, 0) : trend == -1 ? color.new(color.red, 0) : color.new(color.gray, 0)
    int   liqHighCount = array.size(liqHighs)
    int   liqLowCount  = array.size(liqLows)
    color liqHCol = liqHighCount >= 3 ? color.new(color.red,  0) : color.new(color.gray, 40)
    color liqLCol = liqLowCount  >= 3 ? color.new(color.teal, 0) : color.new(color.gray, 40)
    table.cell(dash, 0, 0, "STRUCT " + tfLabel,        text_color=color.new(color.white, 40), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, structTxt,                  text_color=structColor,                text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 1, "TF",                       text_color=color.new(color.white, 40), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, tfLabel,                    text_color=color.new(color.white, 20), text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 2, "LIQ ▲",                   text_color=color.new(color.teal, 20),  text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(liqLowCount),  text_color=liqLCol,                    text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 3, "LIQ ▼",                   text_color=color.new(color.red,  20),  text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(liqHighCount), text_color=liqHCol,                    text_size=size.small, text_halign=text.align_right)
````
