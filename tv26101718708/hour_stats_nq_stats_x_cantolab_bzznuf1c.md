# Hour Stats [NQ Stats x CantoLab]

- url: https://www.tradingview.com/script/BzZnUf1C-Hour-Stats-NQ-Stats-x-CantoLab/
- type: indicator
- pine_id: PUB;5136df7c3b1f4ed1bb30acbcb87ddeaa
- version: 1.0

## Description

A statistical tool for NQ intraday traders built around research from NQ Stats (NQStats on twitter / nqstats.com). Credit to NQ Stats for the original concept and data — published here as an open source indicator with permission.

[b]What it does?[/b]
For each New York session hour (08:00 – 16:00 NY time), the indicator tracks a specific setup:

1)Price opens strictly inside the prior hour's range
2)Price breaches the prior hour high or low by at least 1 tick (0.25 pts)
3)Whether price reverts back to the current hour open before the hour closes

Only the first breach per hour is counted. Reversion is confirmed when any bar's wick touches or crosses the hour open after the breach occurs.

[b]What gets plotted[/b]
When the setup triggers, the indicator draws the following levels for that hour:
[list]
[*]Hour Open — the high probability reversion target. In Simple mode labelled as "High Prob. Retrace", in Advanced mode shows the statistical probability based on which 20-minute segment the breach occurred in
[*]PHH / PHL Swept — marks the breached prior hour high or low
[*]PHH / PHL Target — the opposite side of the prior hour range, the secondary target if reversion extends further
[*]PHM (Prior Hour Mid) — the equilibrium of the prior hour range, visible in Advanced mode only
[*]Sweep Mark — a small shape plotted on the candle where the breach is first detected (x, +, or diamond, configurable)
[*]Vertical dividers — split each hour into its three 20-minute segments
[/list]

[b]Simple vs Advanced mode[/b]
Simple — shows Hour Open, swept level, and opposite target. Clean and uncluttered for execution focus.
Advanced — adds the Prior Hour Mid level and overlays per-segment reversion probabilities directly on the prior hour high and low, showing the statistical likelihood of reversion depending on when in the hour the breach occurs.

[b]Advanced Mode - The 20-minute breakdown[/b]
Each hour is divided into three 20-minute windows (00–20, 20–40, 40–60). The timing of the breach within these windows significantly affects reversion probability. 

As a general rule, first segment breaches carry the highest probability of reversion — the 09:00 hour first segment sits at 87.4% historically. Probabilities are pulled from 10 years of NQ data.

[b]Settings[/b]
[list]
[*]Mode — Simple or Advanced
[*]Show History — keep or clear previous setups as new ones form
[*]Time Filter — toggle NY session filter on/off, adjustable session window
[*]Show Optimal Timeframe Message — on-chart warning if you are above 5min timeframe
[*]Per-level toggles — color, style (Solid/Dotted/Dashed) and width for each plotted level
[*]Sweep Mark — toggle, color, and shape
[/list]

[b]Notes[/b]
[list]
[*]Built for NQ Futures. Behaviour on other instruments is untested
[*]Best used on 1m – 5min timeframes. Warning displays above 5min, error displays at 60min and above
[*]All times are New York time
[*]Probability data is derived from 10 years of NQ historical data by @NQStats
[*][b]This indicator does not provide financial advice or a complete strategy. You are responsible for how you build around and execute on this data[/b]
[/list]

## Source Code

````pine
//@version=6
indicator("Hour Stats [NQ Stats x CantoLab]", overlay=true, max_lines_count=500, max_labels_count=500)


//#region [UTILS]
f_sz(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.auto

f_st(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        =>          line.style_dashed

noColor = color.new(color.white, 100)
//#endregion


//#region [TYPES]
type HourSetup
    line[]  lines
    label[] labels

method clear(HourSetup self) =>
    if self.lines.size() > 0
        for i = self.lines.size() - 1 to 0
            line.delete(self.lines.get(i))
        self.lines.clear()
    if self.labels.size() > 0
        for i = self.labels.size() - 1 to 0
            label.delete(self.labels.get(i))
        self.labels.clear()

method addLine(HourSetup self, float y, int t1, int t2, string txt, color c, string st, int w, bool vis, string sz) =>
    if vis
        self.lines.push(line.new(t1, y, t2, y, xloc.bar_time, color=c, style=f_st(st), width=w))
        self.labels.push(label.new(t2, y, txt, xloc.bar_time, style=label.style_label_left, color=noColor, textcolor=c, size=f_sz(sz), text_font_family=font.family_monospace))

method addProbLabel(HourSetup self, int t, float y, string txt, string st, color c, string sz) =>
    _st = st == "up" ? label.style_label_up : label.style_label_down
    self.labels.push(label.new(t, y, txt, xloc.bar_time, style=_st, color=noColor, textcolor=c, size=f_sz(sz), text_font_family=font.family_monospace))
//#endregion


//#region [INPUTS]
G_GEN = "General Settings"
G_STY = "STYLE"

mode          = input.string("Simple",    "Mode?",                 options=["Simple","Advanced"],                                                                   group=G_GEN)
showHistory   = input.bool  (true,        "History?",                                                                                                               group=G_GEN)
useTimeFilter = input.bool  (true,        "Time Filter (NYT)",                                                                                                      group=G_GEN, inline="sess")
sessionInput  = input.session("0800-1600","",                                                                                                                       group=G_GEN, inline="sess")
showWarnings  = input.bool  (true,        "Show Optimal Timeframe Message",                                                                                         group=G_GEN)
lblSize       = input.string("Small",     "LabelSize?",                     options=["Tiny","Small","Normal","Large","Huge"],                                       group=G_STY, inline="lbl")
showDiv  = input.bool(true, "",                      group=G_STY, inline="div"), c_div = input.color(color.new(#808080, 50), "Vertical LinesL                  ", group=G_STY, inline="div"), s_div = input.string("Dotted", "", options=["Solid","Dotted","Dashed"], group=G_STY, inline="div"), w_div = input.int(1, "", minval=1, group=G_STY, inline="div")
showOpen = input.bool(true, "",                      group=G_STY, inline="opn"), c_opn = input.color(color.new(#2962ff,  0), "Hour Open                        ", group=G_STY, inline="opn"), s_opn = input.string("Dotted", "", options=["Solid","Dotted","Dashed"], group=G_STY, inline="opn"), w_opn = input.int(1, "", minval=1, group=G_STY, inline="opn")
showMid  = input.bool(true, "",                      group=G_STY, inline="mid"), c_mid = input.color(color.new(#808080,  0), "Prev Hour Mid (PHM)"              , group=G_STY, inline="mid"), s_mid = input.string("Dotted", "", options=["Solid","Dotted","Dashed"], group=G_STY, inline="mid"), w_mid = input.int(1, "", minval=1, group=G_STY, inline="mid")
showSwp  = input.bool(true, "",                      group=G_STY, inline="swp"), c_swp = input.color(color.new(#ff5252,  0), "Sweep (PHH/PHL)        "          , group=G_STY, inline="swp"), s_swp = input.string("Dotted", "", options=["Solid","Dotted","Dashed"], group=G_STY, inline="swp"), w_swp = input.int(1, "", minval=1, group=G_STY, inline="swp")
showOpp  = input.bool(true, "",                      group=G_STY, inline="opp"), c_opp = input.color(color.new(#808080,  0), "Target (PHH/PHL)          "       , group=G_STY, inline="opp"), s_opp = input.string("Dotted", "", options=["Solid","Dotted","Dashed"], group=G_STY, inline="opp"), w_opp = input.int(1, "", minval=1, group=G_STY, inline="opp")
showMrk  = input.bool(true, " Sweep Mark          ", group=G_STY, inline="mrk"), c_mrk = input.color(color.new(#ff5252,  0), ""                                 , group=G_STY, inline="mrk"), mrk_shape = input.string("x", "", options=["x","+","◆"],                group=G_STY, inline="mrk")

isSimple   = mode == "Simple"
isAdvanced = mode == "Advanced"
//#endregion


//#region [WARNINGS]
var table warnTbl = table.new(position.bottom_center, 1, 1)

isHTF      = not timeframe.isintraday or timeframe.multiplier >= 60
isMediumTF = timeframe.isintraday and timeframe.multiplier > 5 and timeframe.multiplier < 60

if barstate.islast and showWarnings
    if isHTF
        table.cell(warnTbl, 0, 0, "⚠️ Please drop to lower than 5min for clearly viewing the 'Hour Stats' indicator", bgcolor=color.red,    text_color=color.white, text_size=size.normal)
    else if isMediumTF
        table.cell(warnTbl, 0, 0, "Optimal timeframe to view 'Hour Stats' indicator is 1m-5min",                      bgcolor=color.yellow, text_color=color.black, text_size=size.normal)
    else
        table.clear(warnTbl, 0, 0, 0, 0)
//#endregion


//#region [PROB DATA]
var float[] high00 = array.from(35.0, 17.0, 43.0, 39.0, 40.0, 39.0, 39.0, 33.0, 59.0)
var float[] high20 = array.from(30.0, 33.0, 20.0, 23.0, 20.0, 22.0, 20.0, 20.0, 12.0)
var float[] high40 = array.from(35.0, 50.0, 37.0, 38.0, 40.0, 40.0, 41.0, 47.0, 29.0)
var float[] low00  = array.from(37.0, 17.0, 48.0, 47.0, 46.0, 45.0, 45.0, 39.0, 73.0)
var float[] low20  = array.from(27.0, 35.0, 21.0, 22.0, 21.0, 22.0, 22.0, 18.0,  9.0)
var float[] low40  = array.from(36.0, 48.0, 31.0, 31.0, 33.0, 33.0, 32.0, 44.0, 18.0)
//#endregion


//#region [LOGIC]
TZ = "America/New_York"

var HourSetup setup = HourSetup.new(array.new_line(), array.new_label())
var float phh = na
var float phl = na
var bool  swH = false
var bool  swL = false

inSess  = useTimeFilter ? not na(time(timeframe.period, sessionInput, TZ)) : true
valid   = not isHTF
hourIdx = hour(time, TZ) - 8

[t1, t2, o, h1, l1] = request.security(syminfo.tickerid, "60", [time, time_close, open, high[1], low[1]], lookahead=barmerge.lookahead_on)

if timeframe.change("60") and valid
    phh := h1
    phl := l1
    swH := false
    swL := false
    if showDiv and inSess
        line.new(t1, low, t1, high, xloc.bar_time, extend.both, c_div, f_st(s_div), w_div)

sweepL = not swL and not swH and low  < phl and inSess and valid
sweepH = not swH and not swL and high > phh and inSess and valid

if sweepL or sweepH
    swL := sweepL ? true : swL
    swH := sweepH ? true : swH

// Rising edge: only the first bar where sweep condition becomes true
triggerL = sweepL and not swL[1]
triggerH = sweepH and not swH[1]

if triggerL or triggerH
    if not showHistory
        setup.clear()

    isBearSweep = triggerL
    mid         = (phh + phl) / 2
    swpPrice    = isBearSweep ? phl  : phh
    tgtPrice    = isBearSweep ? phh  : phl
    openLbl     = isSimple ? "High Prob. Retrace"              : "89% @ Open"
    swpLbl      = isBearSweep ? "PHL Swept"                   : "PHH Swept"
    oppLbl      = isSimple ? (isBearSweep ? "PHL" : "PHH")    : (isBearSweep ? "18% @ PHH" : "18% @ PHL")

    setup.addLine(o,        t1, t2, openLbl,     c_opn, s_opn, w_opn, showOpen,                 lblSize)
    setup.addLine(mid,      t1, t2, "49% @ PHM", c_mid, s_mid, w_mid, showMid and isAdvanced,   lblSize)
    setup.addLine(swpPrice, t1, t2, swpLbl,      c_swp, s_swp, w_swp, showSwp,                 lblSize)
    setup.addLine(tgtPrice, t1, t2, oppLbl,      c_opp, s_opp, w_opp, showOpp,                 lblSize)

    if isAdvanced and hourIdx >= 0 and hourIdx <= 8
        t_00 = t1 + 600000
        t_20 = t1 + 1800000
        t_40 = t1 + 3000000

        setup.addProbLabel(t_00, phh, str.tostring(int(array.get(high00, hourIdx))) + "%", "down", c_mid, lblSize)
        setup.addProbLabel(t_20, phh, str.tostring(int(array.get(high20, hourIdx))) + "%", "down", c_mid, lblSize)
        setup.addProbLabel(t_40, phh, str.tostring(int(array.get(high40, hourIdx))) + "%", "down", c_mid, lblSize)
        setup.addProbLabel(t_00, phl, str.tostring(int(array.get(low00,  hourIdx))) + "%", "up",   c_mid, lblSize)
        setup.addProbLabel(t_20, phl, str.tostring(int(array.get(low20,  hourIdx))) + "%", "up",   c_mid, lblSize)
        setup.addProbLabel(t_40, phl, str.tostring(int(array.get(low40,  hourIdx))) + "%", "up",   c_mid, lblSize)

    if showDiv
        setup.lines.push(line.new(t1 + 1200000, phl, t1 + 1200000, phh, xloc.bar_time, color=c_div, style=f_st(s_div), width=w_div))
        setup.lines.push(line.new(t1 + 2400000, phl, t1 + 2400000, phh, xloc.bar_time, color=c_div, style=f_st(s_div), width=w_div))
//#endregion


//#region [SWEEP MARK]
_shape = switch mrk_shape
    "+"  => shape.cross
    "◆"  => shape.diamond
    =>      shape.xcross

plotshape(showMrk and triggerL, title="Sweep Low",  style=_shape, location=location.belowbar, color=c_mrk, size=size.tiny)
plotshape(showMrk and triggerH, title="Sweep High", style=_shape, location=location.abovebar, color=c_mrk, size=size.tiny)
//#endregion
````
