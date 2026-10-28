# HTF Fair Value Gaps Anchored

- url: https://www.tradingview.com/script/ChNLWSpJ-HTF-Fair-Value-Gaps-Anchored/
- type: indicator
- pine_id: PUB;08ef2c92b35f49898a5f2125966ec796
- version: 8.0

## Description

This is a HTF FVG indicator where the user can see the higher Time Frame Gaps on the lower time frames.
Example on the 1m the user can see the 5m/15m/30m/1h/4h.
If you the user is on the 15m you can only see the 30m/1h/4h.
You can turn on/off Time Frames. If you the user does not want to see the 4h Fvg you can manually turn it off.
The user can also change the colors of the FVG' such as the border and the fill.
There is also a color for the Current Time Frame, example if user makes the current "TF"= (Time Frame) purple, on what ever TF you switch to the FVG will be purple.
There is also a session look back option, where the user is allowed to look back at FVG's from 1-99 session back, So if user only want to see the last 3 session's FVG the user can, or 2 sessions Users choice.
If the FVG is filled completely the Fair Value Gap will despiser. All FVG's come with a EQ or 50% range line.
We all Know if this is paired with VP ( Volume Profile ) The gaps will be more accurate. So its probably best practice to put anchor the VP to however many session the indicator is set to.

Disclaimer: There is a "Filled" option that is currently being tested.
Feed back is appreciated

## Source Code

````pine
//@version=6
//ImOpario And this is HTF FVGs anchored 
// 4/27/26 Fixed the Session Lookback Feature.
// The Session Lookback option was not telling the HTF FVGs to stop at the sessions 
// requested of the user. This is now fixed. 
// User can now set Session Lookback to 1-99 sessions.
// The Indicator will look back at the last 1-99 previous trading sessions.
// 4/28/26
// Extended the FVGs by 3 bars (In the future I might add an option where User can decide how much bars to extend by
// to the current price)
// The indicator now allows users to "show" (TURN/OFF) HTF FVGs that are currently being made. 
// In the previous version HTF FVGs that where in the process of being made where being displayed as time progressed, leading into 
// unnecessary noise. EX: User could be on 1m TF and could see live as a 15m FVG was being made even though the 15m FVG was not confirmed by 
// candle closure.
// Users can now also Turn ON/OFF Current TF FVGs. If User is in 1m TF and no longer wishes to see 1m FVGs,
// Users can turn off "Show Current Time Frame FVGs"
// 7/21/26
// The indicator now allows users to select when the FVG gets deleted after price mitigation. 
// Previously the indicator deleted FVGs after mitigation of the C/E. This updated allows users to select "Full GAP".
// "Full GAP" when selected makes it where, price has to wick/close above/below the FVG so the FVG can be deleted.
// As long as price is trading inside the gap. The gap won't be deleted.
// This updated version of the indicator will allow users to see from what HTF FVGs price is delivering.
// 7/23/26
// The indicator now allows users to chose from "Full GAP" to now "Full GAP (CLOSE)" & "FUll GAP (WICK)"
// This Update allows the user to chose the how the FVG gets deleted. 
// Users can chose the FVG to get deleted from the "C/E" (50% Range)
// Users can chose the FVG to get deleted from the "FULL GAP" (The closure of any the Candle outside the FVG)
// Users can chose the FVG to get deleted from the "WICK" (Any Candle Wicking out the FVG)
// Users can chose the Label Size of "TF FVG"
//10/4/26
//Compressed Code by over 500 lines 
// Fixed 15m Bearish FVG overlay
// user can now customize FVG 
// - Line EQ / - Border Thickness / - Border Thickness

indicator("HTF Fair Value Gaps Anchored", shorttitle="HTF FVGs ", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ══════════════════════════════════════
// CURRENT TF SETTINGS
// ══════════════════════════════════════
showCurrentTF   = input.bool(true,                              "Show Current TF FVGs", group="Current TF")
bullColor       = input.color(color.rgb(255, 255, 255, 96),           "Bull Fill",            group="Current TF")
bearColor       = input.color(color.rgb(87, 87, 87, 97),           "Bear Fill",            group="Current TF")
midColor        = input.color(color.rgb(255, 255, 255, 93),                      "EQ Color",             group="Current TF")
midActiveColor  = input.color(color.orange,                     "EQ Active Color",      group="Current TF")
eqWidth         = input.int(1, "EQ Line Width", minval=1, maxval=7, group="Current TF")
bullBorderColor = input.color(color.rgb(255,255,255),           "Bull Border",          group="Current TF")
bearBorderColor = input.color(color.rgb(75, 73, 73),               "Bear Border",          group="Current TF")
sessionLookback = input.int(3, "Session Lookback", minval=1, maxval=100, group="Current TF", tooltip="Applies to ALL FVGs across all timeframes")
mitigationMode  = input.string("CE", "Mitigation Mode", options=["CE", "Full Gap (Wick)", "Full Gap (Close)"], group="Current TF", tooltip="CE: deletes at midpoint. Full Gap (Wick): deletes when price wicks through full gap. Full Gap (Close): deletes only when candle closes beyond full gap.")
labelSize       = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Current TF", tooltip="Controls the text size of all FVG labels")
lblSize         = labelSize == "Tiny" ? size.tiny : labelSize == "Small" ? size.small : labelSize == "Normal" ? size.normal : labelSize == "Large" ? size.large : size.huge

// ══════════════════════════════════════
// DAILY OPENING GAP SETTINGS
// ══════════════════════════════════════
showDOG       = input.bool(false,                          "Show Daily Opening Gaps",  group="Daily Opening Gap")
dogBullFill   = input.color(color.new(#55816c, 75),        "Bull Fill",                group="Daily Opening Gap")
dogBearFill   = input.color(color.new(#db443a, 75),        "Bear Fill",                group="Daily Opening Gap")
dogBullBorder = input.color(color.lime,                    "Bull Border",              group="Daily Opening Gap")
dogBearBorder = input.color(color.rgb(251, 64, 64),        "Bear Border",              group="Daily Opening Gap")
dogMidCol     = input.color(color.white,                   "EQ Color",                 group="Daily Opening Gap")

// ══════════════════════════════════════
// WEEKLY OPENING GAP SETTINGS
// ══════════════════════════════════════
showWOG       = input.bool(false,                          "Show Weekly Opening Gaps", group="Weekly Opening Gap")
wogBullFill   = input.color(color.new(#00bbd4, 92),     "Bull Fill",                group="Weekly Opening Gap")
wogBearFill   = input.color(color.new(#796d5c, 75),        "Bear Fill",                group="Weekly Opening Gap")
wogBullBorder = input.color(color.aqua,                    "Bull Border",              group="Weekly Opening Gap")
wogBearBorder = input.color(color.rgb(80, 77, 73),         "Bear Border",              group="Weekly Opening Gap")
wogMidCol     = input.color(color.white,                   "EQ Color",                 group="Weekly Opening Gap")

// ══════════════════════════════════════
// 15m SETTINGS
// ══════════════════════════════════════
show15m       = input.bool(true,                             "Show 15m FVGs", group="15m FVGs")
bull15mFill   = input.color(color.new(#6ceea2, 98),          "Bull Fill",     group="15m FVGs")
bear15mFill   = input.color(color.new(#ff5252, 92),        "Bear Fill",     group="15m FVGs")
bull15mBorder = input.color(color.teal,                      "Bull Border",   group="15m FVGs")
bear15mBorder = input.color(color.red,                       "Bear Border",   group="15m FVGs")
mid15mCol     = input.color(color.teal,                      "EQ Color",      group="15m FVGs")

// ══════════════════════════════════════
// 30m SETTINGS
// ══════════════════════════════════════
show30m       = input.bool(true,                             "Show 30m FVGs", group="30m FVGs")
bull30mFill   = input.color(color.new(#058eff, 0),           "Bull Fill",     group="30m FVGs")
bear30mFill   = input.color(color.new(#525252, 0),           "Bear Fill",     group="30m FVGs")
bull30mBorder = input.color(color.blue,                      "Bull Border",   group="30m FVGs")
bear30mBorder = input.color(color.rgb(53,52,50),             "Bear Border",   group="30m FVGs")
mid30mCol     = input.color(color.blue,                      "EQ Color",      group="30m FVGs")

// ══════════════════════════════════════
// 1H SETTINGS
// ══════════════════════════════════════
show1H       = input.bool(true,                              "Show 1H FVGs",  group="1H FVGs")
bull1HFill   = input.color(color.new(color.purple, 75),      "Bull Fill",     group="1H FVGs")
bear1HFill   = input.color(color.new(#ffeb3b, 89),      "Bear Fill",     group="1H FVGs")
bull1HBorder = input.color(color.rgb(39,41,176),             "Bull Border",   group="1H FVGs")
bear1HBorder = input.color(color.rgb(71, 67, 67),              "Bear Border",   group="1H FVGs")
mid1HCol     = input.color(color.purple,                     "EQ Color",      group="1H FVGs")

// ══════════════════════════════════════
// 4H SETTINGS
// ══════════════════════════════════════
show4H       = input.bool(true,                              "Show 4H FVGs",  group="4H FVGs")
bull4HFill   = input.color(color.new(#39c03e, 92),           "Bull Fill",     group="4H FVGs")
bear4HFill   = input.color(color.new(#53494e, 96),           "Bear Fill",     group="4H FVGs")
bull4HBorder = input.color(color.rgb(0,40,100),              "Bull Border",   group="4H FVGs")
bear4HBorder = input.color(color.rgb(77,74,74),              "Bear Border",   group="4H FVGs")
mid4HCol     = input.color(color.rgb(156, 132, 26, 64),            "EQ Color",      group="4H FVGs")

// ══════════════════════════════════════
// HTF SETTINGS
// ══════════════════════════════════════
showLiveHTF = input.bool(false, "Show Live/Forming HTF FVGs", group="HTF Settings", tooltip="When off, only shows confirmed closed HTF gaps. Recommended OFF on lower timeframes.")

// ══════════════════════════════════════
// LINE STYLE SETTINGS (apply to ALL gaps)
// ══════════════════════════════════════
eqStyleIn     = input.string("Dashed", "EQ Line Style", options=["Solid", "Dashed", "Dotted"], group="Line Settings", tooltip="Style of the C/E (50%) line inside every FVG")
borderWidth   = input.int(1, "Border Width", minval=1, maxval=5, group="Line Settings", tooltip="Thickness of the FVG box outline")
borderStyleIn = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group="Line Settings", tooltip="Style of the FVG box outline")

eqStyle     = eqStyleIn == "Solid" ? line.style_solid : eqStyleIn == "Dotted" ? line.style_dotted : line.style_dashed
borderStyle = borderStyleIn == "Dashed" ? line.style_dashed : borderStyleIn == "Dotted" ? line.style_dotted : line.style_solid

// ══════════════════════════════════════
// 3-BAR EXTENSION
// ══════════════════════════════════════
barMs     = int(timeframe.in_seconds(timeframe.period) * 1000)
ext3      = 3 * barMs
chartSecs = timeframe.in_seconds(timeframe.period)

// ══════════════════════════════════════
// SESSION TRACKING
// ══════════════════════════════════════
var int sessionCount = 0
if ta.change(dayofmonth(time)) != 0
    sessionCount += 1

// ══════════════════════════════════════
// TF LABEL
// ══════════════════════════════════════
tfLabel = timeframe.period == "1"   ? "1m"  :
          timeframe.period == "3"   ? "3m"  :
          timeframe.period == "5"   ? "5m"  :
          timeframe.period == "15"  ? "15m" :
          timeframe.period == "30"  ? "30m" :
          timeframe.period == "60"  ? "1H"  :
          timeframe.period == "120" ? "2H"  :
          timeframe.period == "240" ? "4H"  :
          timeframe.period == "D"   ? "1D"  :
          timeframe.period == "W"   ? "1W"  : timeframe.period

// ══════════════════════════════════════
// TYPES + STORAGE (one array holds every gap: current TF, 15m, 30m, 1H, 4H, DOG, WOG)
// ══════════════════════════════════════
type FVG
    box    bx
    line   ml
    label  lb
    float  top
    float  bot
    int    sess
    int    born
    bool   isBull
    bool   byIndex
    color  eqCol
    color  actCol

type LtfState
    float h1
    float l1
    int   t1
    float h2
    float l2
    int   t2

var array<FVG> gaps = array.new<FVG>()
var LtfState st15 = LtfState.new()
var LtfState st30 = LtfState.new()
var LtfState st1H = LtfState.new()
var LtfState st4H = LtfState.new()

// ══════════════════════════════════════
// FUNCTIONS
// ══════════════════════════════════════
f_mitigated(bool isBull, float top, float bot, float h, float l, float c) =>
    float mid = (top + bot) / 2
    bool res = false
    if isBull
        res := (mitigationMode == "CE" and l <= mid) or (mitigationMode == "Full Gap (Wick)" and l <= bot) or (mitigationMode == "Full Gap (Close)" and c <= bot)
    else
        res := (mitigationMode == "CE" and h >= mid) or (mitigationMode == "Full Gap (Wick)" and h >= top) or (mitigationMode == "Full Gap (Close)" and c >= top)
    res

f_addGap(bool isBull, float top, float bot, int leftX, bool byIndex, color bgCol, color bdCol, color eqCol, color actCol, color txtCol, string txt, bool intra) =>
    float mid    = (top + bot) / 2
    int   rightX = byIndex ? bar_index + 3 : time + ext3
    box   b      = na
    line  ml     = na
    label lb     = na
    if byIndex
        b  := box.new(leftX, top, rightX, bot, border_color=bdCol, border_width=borderWidth, border_style=borderStyle, bgcolor=bgCol)
        ml := line.new(leftX, mid, rightX, mid, color=eqCol, width=eqWidth, style=eqStyle)
        lb := label.new(rightX, mid, txt, color=color.new(color.black, 100), textcolor=txtCol, style=label.style_none, size=lblSize)
    else
        b  := box.new(leftX, top, rightX, bot, border_color=bdCol, border_width=borderWidth, border_style=borderStyle, xloc=xloc.bar_time, bgcolor=bgCol)
        ml := line.new(leftX, mid, rightX, mid, xloc=xloc.bar_time, color=eqCol, width=eqWidth, style=eqStyle)
        lb := label.new(rightX, mid, txt, xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=txtCol, style=label.style_none, size=lblSize)
    array.push(gaps, FVG.new(b, ml, lb, top, bot, sessionCount, intra ? bar_index : -1, isBull, byIndex, eqCol, actCol))
    array.size(gaps)

// Walks every intrabar candle (in order) of the current chart bar and detects FVGs on it.
// Only used when the chart timeframe is HIGHER than the gap timeframe.
f_scanLTF(array<float> aH, array<float> aL, array<float> aC, array<int> aT, LtfState s, bool showIt, string txt, color bullBg, color bearBg, color bullBd, color bearBd, color eqCol) =>
    int n = array.size(aH)
    if n > 0
        for k = 0 to n - 1
            float cH = array.get(aH, k)
            float cL = array.get(aL, k)
            int   cT = array.get(aT, k)
            if showIt and not na(s.h2)
                bool isBull = cL > s.h2
                bool isBear = cH < s.l2
                if isBull or isBear
                    float gTop = isBull ? cL : s.l2
                    float gBot = isBull ? s.h2 : cH
                    bool dead = false
                    if k < n - 1
                        for j = k + 1 to n - 1
                            if f_mitigated(isBull, gTop, gBot, array.get(aH, j), array.get(aL, j), array.get(aC, j))
                                dead := true
                    if not dead
                        f_addGap(isBull, gTop, gBot, s.t2, false, isBull ? bullBg : bearBg, isBull ? bullBd : bearBd, eqCol, color.yellow, isBull ? bullBd : bearBd, txt, true)
            s.h2 := s.h1
            s.l2 := s.l1
            s.t2 := s.t1
            s.h1 := cH
            s.l1 := cL
            s.t1 := cT
    n

// ══════════════════════════════════════
// CURRENT TF FVG DETECTION
// ══════════════════════════════════════
bullishFVG = showCurrentTF and low > high[2] and barstate.isconfirmed
bearishFVG = showCurrentTF and high < low[2] and barstate.isconfirmed

// ══════════════════════════════════════
// HTF DATA REQUESTS (used when chart TF is at or below the gap TF)
// ══════════════════════════════════════
[h15BullTop, h15BullBot, h15BullStart, h15BearTop, h15BearBot, h15BearStart, h15Conf] = request.security(
    syminfo.tickerid, "15",
    [low  > high[2] ? low    : float(na),
     low  > high[2] ? high[2]: float(na),
     low  > high[2] ? time[2]: int(na),
     high < low[2]  ? low[2] : float(na),
     high < low[2]  ? high   : float(na),
     high < low[2]  ? time[2]: int(na),
     barstate.isconfirmed],
    lookahead=barmerge.lookahead_off)

[h30BullTop, h30BullBot, h30BullStart, h30BearTop, h30BearBot, h30BearStart, h30Conf] = request.security(
    syminfo.tickerid, "30",
    [low  > high[2] ? low    : float(na),
     low  > high[2] ? high[2]: float(na),
     low  > high[2] ? time[2]: int(na),
     high < low[2]  ? low[2] : float(na),
     high < low[2]  ? high   : float(na),
     high < low[2]  ? time[2]: int(na),
     barstate.isconfirmed],
    lookahead=barmerge.lookahead_off)

[h1HBullTop, h1HBullBot, h1HBullStart, h1HBearTop, h1HBearBot, h1HBearStart, h1HConf] = request.security(
    syminfo.tickerid, "60",
    [low  > high[2] ? low    : float(na),
     low  > high[2] ? high[2]: float(na),
     low  > high[2] ? time[2]: int(na),
     high < low[2]  ? low[2] : float(na),
     high < low[2]  ? high   : float(na),
     high < low[2]  ? time[2]: int(na),
     barstate.isconfirmed],
    lookahead=barmerge.lookahead_off)

[h4HBullTop, h4HBullBot, h4HBullStart, h4HBearTop, h4HBearBot, h4HBearStart, h4HConf] = request.security(
    syminfo.tickerid, "240",
    [low  > high[2] ? low    : float(na),
     low  > high[2] ? high[2]: float(na),
     low  > high[2] ? time[2]: int(na),
     high < low[2]  ? low[2] : float(na),
     high < low[2]  ? high   : float(na),
     high < low[2]  ? time[2]: int(na),
     barstate.isconfirmed],
    lookahead=barmerge.lookahead_off)

// ══════════════════════════════════════
// INTRABAR DATA (used when chart TF is HIGHER than the gap TF, e.g. 15m gaps on a 1h chart)
// ══════════════════════════════════════
[ib15H, ib15L, ib15C, ib15T] = request.security_lower_tf(syminfo.tickerid, "15",  [high, low, close, time], ignore_invalid_timeframe = true)
[ib30H, ib30L, ib30C, ib30T] = request.security_lower_tf(syminfo.tickerid, "30",  [high, low, close, time], ignore_invalid_timeframe = true)
[ib1HH, ib1HL, ib1HC, ib1HT] = request.security_lower_tf(syminfo.tickerid, "60",  [high, low, close, time], ignore_invalid_timeframe = true)
[ib4HH, ib4HL, ib4HC, ib4HT] = request.security_lower_tf(syminfo.tickerid, "240", [high, low, close, time], ignore_invalid_timeframe = true)

useLtf15 = timeframe.in_seconds("15")  < chartSecs
useLtf30 = timeframe.in_seconds("30")  < chartSecs
useLtf1H = timeframe.in_seconds("60")  < chartSecs
useLtf4H = timeframe.in_seconds("240") < chartSecs

// ══════════════════════════════════════
// DAILY / WEEKLY OPENING GAP DATA
// ══════════════════════════════════════
[dOpen, dPrevClose, dBarTime] = request.security(syminfo.tickerid, "D",
    [open, close[1], time],
    lookahead=barmerge.lookahead_off)

[wOpen, wPrevClose, wBarTime] = request.security(syminfo.tickerid, "W",
    [open, close[1], time],
    lookahead=barmerge.lookahead_off)

newDOGBull = showDOG and barstate.isconfirmed and not na(dOpen) and not na(dPrevClose) and ta.change(dBarTime) != 0 and dOpen > dPrevClose
newDOGBear = showDOG and barstate.isconfirmed and not na(dOpen) and not na(dPrevClose) and ta.change(dBarTime) != 0 and dOpen < dPrevClose

newWOGBull = showWOG and barstate.isconfirmed and not na(wOpen) and not na(wPrevClose) and ta.change(wBarTime) != 0 and wOpen > wPrevClose
newWOGBear = showWOG and barstate.isconfirmed and not na(wOpen) and not na(wPrevClose) and ta.change(wBarTime) != 0 and wOpen < wPrevClose

// ══════════════════════════════════════
// HTF FVG DETECTION (chart TF at or below gap TF)
// ══════════════════════════════════════
htfConfirmed15 = showLiveHTF or h15Conf
htfConfirmed30 = showLiveHTF or h30Conf
htfConfirmed1H = showLiveHTF or h1HConf
htfConfirmed4H = showLiveHTF or h4HConf

new15Bull = show15m and not useLtf15 and htfConfirmed15 and not na(h15BullTop) and (na(h15BullTop[1]) or h15BullTop != h15BullTop[1] or h15BullBot != h15BullBot[1])
new15Bear = show15m and not useLtf15 and htfConfirmed15 and not na(h15BearTop) and (na(h15BearTop[1]) or h15BearTop != h15BearTop[1] or h15BearBot != h15BearBot[1])
new30Bull = show30m and not useLtf30 and htfConfirmed30 and not na(h30BullTop) and (na(h30BullTop[1]) or h30BullTop != h30BullTop[1] or h30BullBot != h30BullBot[1])
new30Bear = show30m and not useLtf30 and htfConfirmed30 and not na(h30BearTop) and (na(h30BearTop[1]) or h30BearTop != h30BearTop[1] or h30BearBot != h30BearBot[1])
new1HBull = show1H and not useLtf1H and htfConfirmed1H and not na(h1HBullTop) and (na(h1HBullTop[1]) or h1HBullTop != h1HBullTop[1] or h1HBullBot != h1HBullBot[1])
new1HBear = show1H and not useLtf1H and htfConfirmed1H and not na(h1HBearTop) and (na(h1HBearTop[1]) or h1HBearTop != h1HBearTop[1] or h1HBearBot != h1HBearBot[1])
new4HBull = show4H and not useLtf4H and htfConfirmed4H and not na(h4HBullTop) and (na(h4HBullTop[1]) or h4HBullTop != h4HBullTop[1] or h4HBullBot != h4HBullBot[1])
new4HBear = show4H and not useLtf4H and htfConfirmed4H and not na(h4HBearTop) and (na(h4HBearTop[1]) or h4HBearTop != h4HBearTop[1] or h4HBearBot != h4HBearBot[1])

// ══════════════════════════════════════
// CREATE CURRENT TF FVGs
// ══════════════════════════════════════
if bullishFVG
    f_addGap(true, low, high[2], bar_index - 2, true, bullColor, bullBorderColor, midColor, midActiveColor, color.white, tfLabel + " Fvg", false)

if bearishFVG
    f_addGap(false, low[2], high, bar_index - 2, true, bearColor, bearBorderColor, midColor, midActiveColor, color.white, tfLabel + " Fvg", false)

// ══════════════════════════════════════
// CREATE HTF FVGs (chart TF at or below gap TF)
// ══════════════════════════════════════
if new15Bull
    f_addGap(true, h15BullTop, h15BullBot, int(h15BullStart), false, bull15mFill, bull15mBorder, mid15mCol, color.yellow, bull15mBorder, "15m Fvg", false)
if new15Bear
    f_addGap(false, h15BearTop, h15BearBot, int(h15BearStart), false, bear15mFill, bear15mBorder, mid15mCol, color.yellow, bear15mBorder, "15m Fvg", false)

if new30Bull
    f_addGap(true, h30BullTop, h30BullBot, int(h30BullStart), false, bull30mFill, bull30mBorder, mid30mCol, color.yellow, bull30mBorder, "30m Fvg", false)
if new30Bear
    f_addGap(false, h30BearTop, h30BearBot, int(h30BearStart), false, bear30mFill, bear30mBorder, mid30mCol, color.yellow, bear30mBorder, "30m Fvg", false)

if new1HBull
    f_addGap(true, h1HBullTop, h1HBullBot, int(h1HBullStart), false, bull1HFill, bull1HBorder, mid1HCol, color.yellow, bull1HBorder, "1H Fvg", false)
if new1HBear
    f_addGap(false, h1HBearTop, h1HBearBot, int(h1HBearStart), false, bear1HFill, bear1HBorder, mid1HCol, color.yellow, bear1HBorder, "1H Fvg", false)

if new4HBull
    f_addGap(true, h4HBullTop, h4HBullBot, int(h4HBullStart), false, bull4HFill, bull4HBorder, mid4HCol, color.yellow, bull4HBorder, "4H Fvg", false)
if new4HBear
    f_addGap(false, h4HBearTop, h4HBearBot, int(h4HBearStart), false, bear4HFill, bear4HBorder, mid4HCol, color.yellow, bear4HBorder, "4H Fvg", false)

// ══════════════════════════════════════
// CREATE GAPS FROM INTRABAR DATA (chart TF higher than gap TF)
// ══════════════════════════════════════
if barstate.isconfirmed
    if useLtf15
        f_scanLTF(ib15H, ib15L, ib15C, ib15T, st15, show15m, "15m Fvg", bull15mFill, bear15mFill, bull15mBorder, bear15mBorder, mid15mCol)
    if useLtf30
        f_scanLTF(ib30H, ib30L, ib30C, ib30T, st30, show30m, "30m Fvg", bull30mFill, bear30mFill, bull30mBorder, bear30mBorder, mid30mCol)
    if useLtf1H
        f_scanLTF(ib1HH, ib1HL, ib1HC, ib1HT, st1H, show1H, "1H Fvg", bull1HFill, bear1HFill, bull1HBorder, bear1HBorder, mid1HCol)
    if useLtf4H
        f_scanLTF(ib4HH, ib4HL, ib4HC, ib4HT, st4H, show4H, "4H Fvg", bull4HFill, bear4HFill, bull4HBorder, bear4HBorder, mid4HCol)

// ══════════════════════════════════════
// CREATE DAILY / WEEKLY OPENING GAPS
// ══════════════════════════════════════
if newDOGBull
    f_addGap(true, dOpen, dPrevClose, bar_index, true, dogBullFill, dogBullBorder, dogMidCol, color.yellow, dogBullBorder, "DOG", false)
if newDOGBear
    f_addGap(false, dPrevClose, dOpen, bar_index, true, dogBearFill, dogBearBorder, dogMidCol, color.yellow, dogBearBorder, "DOG", false)

if newWOGBull
    f_addGap(true, wOpen, wPrevClose, bar_index, true, wogBullFill, wogBullBorder, wogMidCol, color.yellow, wogBullBorder, "WOG", false)
if newWOGBear
    f_addGap(false, wPrevClose, wOpen, bar_index, true, wogBearFill, wogBearBorder, wogMidCol, color.yellow, wogBearBorder, "WOG", false)

// ══════════════════════════════════════
// MANAGE ALL GAPS (session purge, extend, EQ color, mitigation)
// Gaps built from intrabar data skip the mitigation test on their birth bar
// (already checked against only the candles after the gap completed).
// ══════════════════════════════════════
if array.size(gaps) > 0
    int i = array.size(gaps) - 1
    while i >= 0
        FVG g = array.get(gaps, i)
        bool kill = false
        if sessionCount - g.sess >= sessionLookback
            kill := true
        else
            int x = g.byIndex ? bar_index + 3 : time + ext3
            box.set_right(g.bx, x)
            line.set_x2(g.ml, x)
            label.set_x(g.lb, x)
            if g.born != bar_index
                bool active = g.isBull ? (low <= g.top) : (high >= g.bot)
                line.set_color(g.ml, active ? g.actCol : g.eqCol)
                if f_mitigated(g.isBull, g.top, g.bot, high, low, close)
                    kill := true
        if kill
            box.delete(g.bx)
            line.delete(g.ml)
            label.delete(g.lb)
            array.remove(gaps, i)
        i -= 1
````
