# ALN Sessions [NQ Stats x CantoLab]

- url: https://www.tradingview.com/script/KNTFWlm2-ALN-Sessions-NQ-Stats-x-CantoLab/
- type: indicator
- pine_id: PUB;a4d29628df844d85ba3fa58a9d1755ce
- version: 1.0

## Description

A statistical tool for NQ intraday traders built around research from NQ Stats (NQStats on twitter / [url=https://nqstats.com/]https://nqstats.com/[/url]). Credit to NQ Stats for the original concept and data — published here as an open source indicator with permission.

[b]Introduction[/b]
This indicator visualizes Asia and London session ranges on NQ (NASDAQ futures), then overlays statistically-derived probability levels showing how likely price is to sweep each session's high or low — based on historical pattern data compiled by NQ Stats.

How to Read the Probability Numbers
When London session closes, two horizontal lines appear — one above (London High) and one below (London Low) — each labeled with a percentage like 81.1% or 74.9%.

These numbers answer: [i]"Historically, how often does price return to sweep this level after London closes?"[/i]

For example, if you see 81.1% on the high line, it means: in roughly 8 out of 10 historical sessions matching this pattern, price eventually traded back up to or through the London High
[image]https://www.tradingview.com/x/4mknF1e1/[/image]

[b]What happens when a level is hit?[/b]
[image]https://www.tradingview.com/x/Wqjk0fph/[/image]
[list]
[*]The label updates to show [Done] in blue — confirming that level was reached
[*]The other line's probability updates to a new conditional probability, e.g. 46%[-19%], shown in brackets
[*]This delta [+X%] tells you how the odds of sweeping the second level changed now that the first was reached
[/list]

[b]The Four Patterns (Asia vs London relationship)[/b]

The probabilities change depending on how London's range relates to Asia's range that day. The indicator detects four patterns automatically:

[list]
[*][b]London Engulfs Asia[/b] — London trades both above AND below Asia's range. The most expansive session structure.
[*][b]Asia Engulfs London[/b] — Asia's range fully contains London's range. London consolidates inside the prior overnight range.
[*][b]London High Break[/b] — London breaks only above Asia's high, leaving Asia's low intact.
[*][b]London Low Break[/b] — London breaks only below Asia's low, leaving Asia's high intact.
[/list]

Each pattern has its own set of historical probabilities, so the percentages you see are always contextual to that day's Asia/London relationship — not a fixed number.

[b]Settings[/b]

[list]
[*][b]Asia Session[/b] — color, session time window, and label text
[*][b]London Session[/b] — color, session time window, and label text
[*][b]Label Size[/b] — Tiny / Small / Normal / Large
[*][b]Border[/b] — toggle, style (Solid/Dashed/Dotted), and width for session boxes
[*][b]Probability Lines[/b] — toggle, Auto color or manual color pick, style (Solid/Dashed/Dotted), and width
[*][b]Daily Dividers[/b] — toggle, color, style (Solid/Dashed/Dotted), and width
[/list]

[b]Notes[/b]

[list]
[*]Built for NQ Futures. Behaviour on other instruments is untested
[*]All times are New York time
[*]Probability data is derived from 10 years of NQ historical data by [url=https://nqstats.com/]https://nqstats.com/[/url]
[*]This indicator does not provide financial advice or a complete strategy. You are responsible for how you build around and execute on this data
[/list]

[b]⚠️ Important[/b]
This is a statistical study indicator. It does not guarantee that the London high or low will be hit. Over a large sample, this is the expected behaviour based on 10 years of NQ data. It is best combined with other confluences to confirm direction — this indicator alone is not a strategy.

## Source Code

````pine
//@version=6
indicator("ALN Sessions [NQ Stats x CantoLab]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)


//#region [UTILS]
color  NOCOLOR = color.new(color.black, 100)
string TZ      = "America/New_York"

f_lineStyle(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        =>          line.style_dotted

f_labelSize(string s) =>
    switch s
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        =>          size.tiny
//#endregion


//#region [INPUTS]
string G_TF = "SESSION SETTINGS"

color  asiaColor   = input.color(color.new(#ff5252, 88), "", group=G_TF, inline="asia")
string asiaText    = input.string("Asia",                 "", group=G_TF, inline="asia")
string asiaSession = input.session("2000-0200",           "", group=G_TF, inline="asia")

color  lonColor   = input.color(color.new(#2962ff, 88), "", group=G_TF, inline="lon")
string lonText    = input.string("London",               "", group=G_TF, inline="lon")
string lonSession = input.session("0200-0800",           "", group=G_TF, inline="lon")

string G_C = "CUSTOMISATION"
string labelSize = input.string("Small", "Label Size", group=G_C, options=["Tiny","Small","Normal","Large"])

bool   enableBorder = input.bool(true,  "Border                 ", group=G_C, inline="bdr")
string borderStyle  = input.string("Solid",  "", group=G_C, inline="bdr", options=["Solid","Dashed","Dotted"], active=enableBorder)
int    borderWidth  = input.int(1, "",            group=G_C, inline="bdr", options=[1,2,3,4], active=enableBorder)

bool   enablePL  = input.bool(true, "Probability Lines", group=G_C, inline="pl")
string plStyle   = input.string("Dotted", "", group=G_C, inline="pl", options=["Solid","Dashed","Dotted"], active=enablePL)
int    plWidth   = input.int(1, "",           group=G_C, inline="pl", options=[1,2,3,4], active=enablePL)
bool   plAuto    = input.bool(true, "Auto",              group=G_C, inline="pl", active=enablePL)
color  plColor   = input.color(color.new(#ffffff, 0), "", group=G_C, inline="pl", active=enablePL and not plAuto, tooltip = "disable Auto Color to change color")

bool   enableDiv = input.bool(true, "Daily Dividers     ", group=G_C, inline="div")
string divStyle  = input.string("Dotted", "", group=G_C, inline="div", options=["Solid","Dashed","Dotted"], active=enableDiv)
int    divWidth  = input.int(1, "",           group=G_C, inline="div", options=[1,2,3,4], active=enableDiv)
color  divColor  = input.color(color.new(#1a1a1a, 0), "", group=G_C, inline="div", active=enableDiv)

//#endregion


//#region [PROB DATA]
var float[] PROB_HI         = array.from(71.5, 81.1, 80.8, 68.6)
var float[] PROB_LO         = array.from(70.4, 74.9, 65.5, 75.0)
var float[] PROB_HI_THEN_LO = array.from(42.8, 52.7, 46.4, 46.2)
var float[] PROB_LO_THEN_HI = array.from(42.6, 59.8, 51.2, 44.1)
//#endregion


//#region [TYPES]
type SessionBox
    box bx

type ProbTracker
    line[]  hiLines
    line[]  loLines
    float[] hiLevels
    float[] loLevels
    bool[]  hiReached
    bool[]  loReached
    label[] hiLabels
    label[] loLabels
    line[]  connectors
    int[]   patIdxs
    bool[]  contReached
    bool[]  contIsLo

type Session
    SessionBox[] history
    label        liveLabel
    ProbTracker  probLines

method freeze(ProbTracker self) =>
    int sz = self.hiReached.size()
    if sz > 0
        for i = 0 to sz - 1
            self.hiReached.set(i, true)
            self.loReached.set(i, true)
            self.contReached.set(i, true)

method updateLines(ProbTracker self) =>
    int sz = self.hiLines.size()
    if sz > 0
        for i = 0 to sz - 1
            bool bothReached = self.hiReached.get(i) and self.loReached.get(i)

            if not bothReached
                if not self.hiReached.get(i)
                    self.hiLines.get(i).set_x2(bar_index)
                    self.hiLabels.get(i).set_x(bar_index - 3)
                if not self.loReached.get(i)
                    self.loLines.get(i).set_x2(bar_index)
                    self.loLabels.get(i).set_x(bar_index - 3)
                bool hiReached = not self.hiReached.get(i) and high > self.hiLevels.get(i)
                bool loReached = not self.loReached.get(i) and low  < self.loLevels.get(i)
                if hiReached or loReached
                    self.hiReached.set(i, true)
                    self.loReached.set(i, true)
                    int   patIdx    = self.patIdxs.get(i)
                    label reachedLbl = hiReached ? self.hiLabels.get(i) : self.loLabels.get(i)
                    label contLbl    = hiReached ? self.loLabels.get(i) : self.hiLabels.get(i)
                    string origProb  = hiReached
                         ? (patIdx >= 0 ? str.tostring(array.get(PROB_HI, patIdx)) : "")
                         : (patIdx >= 0 ? str.tostring(array.get(PROB_LO, patIdx)) : "")
                    float origContP  = hiReached
                         ? (patIdx >= 0 ? array.get(PROB_LO, patIdx)         : float(na))
                         : (patIdx >= 0 ? array.get(PROB_HI, patIdx)         : float(na))
                    float newContP   = hiReached
                         ? (patIdx >= 0 ? array.get(PROB_HI_THEN_LO, patIdx) : float(na))
                         : (patIdx >= 0 ? array.get(PROB_LO_THEN_HI, patIdx) : float(na))
                    float delta      = not na(newContP) and not na(origContP) ? newContP - origContP : float(na)
                    string deltaStr  = not na(delta) ? " [" + (delta >= 0 ? "+" : "") + str.tostring(math.round(delta, 1)) + "%]" : ""
                    reachedLbl.set_text(origProb + "% [Done]")
                    reachedLbl.set_textcolor(#2962ff)
                    reachedLbl.set_style(hiReached ? label.style_label_down : label.style_label_up)
                    reachedLbl.set_tooltip(origProb + "% — Level reached ✓")
                    contLbl.set_text(not na(newContP) ? str.tostring(newContP) + "%" + deltaStr : "")
                    contLbl.set_textcolor(chart.fg_color)
                    contLbl.set_style(hiReached ? label.style_label_up : label.style_label_down)
                    contLbl.set_tooltip(str.tostring(newContP) + "% probability price will reach this level | Was: " + str.tostring(origContP) + "% | Change: " + (delta >= 0 ? "+" : "") + str.tostring(math.round(delta, 1)) + "%")
                    self.connectors.set(i, line.new(bar_index, self.hiLevels.get(i), bar_index, self.loLevels.get(i),
                         xloc=xloc.bar_index, color=chart.fg_color, style=line.style_dotted, width=plWidth))
                    self.contIsLo.set(i, hiReached)

            if bothReached and not self.contReached.get(i)
                bool   contIsLo = self.contIsLo.get(i)
                line   contLn   = contIsLo ? self.loLines.get(i)  : self.hiLines.get(i)
                label  contLb   = contIsLo ? self.loLabels.get(i) : self.hiLabels.get(i)
                float  contLvl  = contIsLo ? self.loLevels.get(i) : self.hiLevels.get(i)
                contLn.set_x2(bar_index)
                contLb.set_x(bar_index - 3)
                if contIsLo ? low < contLvl : high > contLvl
                    self.contReached.set(i, true)

method spawnProbLines(ProbTracker self, int fromBar, float hiP, float loP, int patternIdx) =>
    color  _c    = plAuto ? chart.fg_color : plColor
    string txtHi = patternIdx >= 0 ? str.tostring(array.get(PROB_HI, patternIdx)) + "%" : ""
    string txtLo = patternIdx >= 0 ? str.tostring(array.get(PROB_LO, patternIdx)) + "%" : ""
    string tipHi = patternIdx >= 0 ? txtHi + " probability price will reach this level (London High)" : ""
    string tipLo = patternIdx >= 0 ? txtLo + " probability price will reach this level (London Low)"  : ""
    self.hiLines.unshift(line.new(fromBar, hiP, fromBar, hiP, xloc=xloc.bar_index, color=_c, style=f_lineStyle(plStyle), width=plWidth))
    self.loLines.unshift(line.new(fromBar, loP, fromBar, loP, xloc=xloc.bar_index, color=_c, style=f_lineStyle(plStyle), width=plWidth))
    self.hiLabels.unshift(label.new(fromBar, hiP, txtHi, xloc=xloc.bar_index, yloc=yloc.price,
         color=NOCOLOR, textcolor=chart.fg_color, style=label.style_label_down, size=f_labelSize(labelSize),
         text_font_family=font.family_monospace, tooltip=tipHi))
    self.loLabels.unshift(label.new(fromBar, loP, txtLo, xloc=xloc.bar_index, yloc=yloc.price,
         color=NOCOLOR, textcolor=chart.fg_color, style=label.style_label_up, size=f_labelSize(labelSize),
         text_font_family=font.family_monospace, tooltip=tipLo))
    self.hiLevels.unshift(hiP)         , self.loLevels.unshift(loP)
    self.hiReached.unshift(false)      , self.loReached.unshift(false)
    self.connectors.unshift(line(na))
    self.patIdxs.unshift(patternIdx)
    self.contReached.unshift(false)
    self.contIsLo.unshift(false)

method processSession(Session self, bool active, bool wasActive, color sessColor, string sessName) =>
    color BORDER = enableBorder ? color.rgb(color.r(sessColor), color.g(sessColor), color.b(sessColor)) : NOCOLOR

    if active and not wasActive
        self.history.unshift(SessionBox.new(
             box.new(bar_index, high, bar_index, low,
                  border_color=BORDER, border_style=f_lineStyle(borderStyle),
                  border_width=borderWidth, bgcolor=sessColor)))
        self.liveLabel := label.new(bar_index, high, sessName, xloc=xloc.bar_index, yloc=yloc.price,
             color=NOCOLOR, textcolor=chart.fg_color, style=label.style_label_down, size=f_labelSize(labelSize))

    if active and wasActive and self.history.size() > 0
        SessionBox sb = self.history.get(0)
        float newTop  = math.max(sb.bx.get_top(), high)
        float newBot  = math.min(sb.bx.get_bottom(), low)
        sb.bx.set_top(newTop)
        sb.bx.set_bottom(newBot)
        sb.bx.set_right(bar_index)
        if not na(self.liveLabel)
            self.liveLabel.set_x(math.round((sb.bx.get_left() + sb.bx.get_right()) / 2))
            self.liveLabel.set_y(newTop)

    if not active and wasActive
        self.liveLabel := na
        if self.history.size() > 0
            SessionBox sb = self.history.get(0)
            label.new(math.round((sb.bx.get_left() + sb.bx.get_right()) / 2), sb.bx.get_top(),
                 sessName, xloc=xloc.bar_index, yloc=yloc.price,
                 color=NOCOLOR, textcolor=chart.fg_color, style=label.style_label_down, size=f_labelSize(labelSize))
//#endregion


//#region [LOGIC]
var Session asia   = Session.new(array.new<SessionBox>(), na, ProbTracker.new(array.new_line(), array.new_line(), array.new_float(), array.new_float(), array.new_bool(), array.new_bool(), array.new_label(), array.new_label(), array.new_line(), array.new_int(), array.new_bool(), array.new_bool()))
var Session london = Session.new(array.new<SessionBox>(), na, ProbTracker.new(array.new_line(), array.new_line(), array.new_float(), array.new_float(), array.new_bool(), array.new_bool(), array.new_label(), array.new_label(), array.new_line(), array.new_int(), array.new_bool(), array.new_bool()))

var float asiaHi = na
var float asiaLo = na

f_inSession(simple string sess, simple int barsBack=0) =>
    not na(time(timeframe.period, sess, TZ, bars_back=barsBack))

f_patternIdx(float lHi, float lLo, float aHi, float aLo) =>
    if lHi > aHi and lLo < aLo
        0
    else if aHi > lHi and aLo < lLo
        1
    else if lHi > aHi and lLo > aLo and lLo < aHi
        2
    else if lLo < aLo and lHi < aHi and lHi > aLo
        3
    else
        -1

bool isNewDay      = ta.change(time("D", TZ)) != 0
bool stopActive    = not na(time(timeframe.period, "1600-1601", TZ))
bool stopWasActive = not na(time(timeframe.period, "1600-1601", TZ, bars_back=1))
bool asiaActive    = f_inSession(asiaSession)
bool asiaWasActive = f_inSession(asiaSession, 1)
bool lonActive     = f_inSession(lonSession)
bool lonWasActive  = f_inSession(lonSession, 1)

if isNewDay and enableDiv
    line.new(time, high, time, low, xloc=xloc.bar_time, extend=extend.both,
         color=divColor, style=f_lineStyle(divStyle), width=divWidth)

if stopActive and not stopWasActive
    london.probLines.freeze()

if not asiaActive and asiaWasActive and asia.history.size() > 0
    SessionBox sb = asia.history.get(0)
    asiaHi := sb.bx.get_top()
    asiaLo := sb.bx.get_bottom()

if not lonActive and lonWasActive and enablePL and london.history.size() > 0
    SessionBox sb = london.history.get(0)
    london.probLines.spawnProbLines(sb.bx.get_right(), sb.bx.get_top(), sb.bx.get_bottom(),
         f_patternIdx(sb.bx.get_top(), sb.bx.get_bottom(), asiaHi, asiaLo))

if not lonActive
    london.probLines.updateLines()

asia.processSession(asiaActive, asiaWasActive, asiaColor, asiaText)
london.processSession(lonActive, lonWasActive, lonColor, lonText)
//#endregion
````
