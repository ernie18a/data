# Session Ranges & Killzones + ORB

- url: https://www.tradingview.com/script/MmqPYLcZ-Session-Ranges-Killzones-ORB/
- type: indicator
- pine_id: PUB;8bd79ef46f5042c9b348142ec5bfdf8e
- version: 11.0

## Description

Session Ranges & Killzones + ORB

NY 8am, 9:30am, 2pm, 8pm and 2am ORB ranges

NY Midnight open, 9am and 10am open lines

## Source Code

````pine
//@version=6
indicator("Session Ranges & Killzones + ORB + Extras", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// =============================================================================
// GLOBAL & KILLZONE SETTINGS
// =============================================================================
showKillzones   = input.bool(true, "Show Killzone Boxes", group="Global Settings")
showText        = input.bool(true, "Show All Text Labels", group="Global Settings")
showSessHL      = input.bool(true, "Draw Session H/L (Orange)", group="Global Settings")

asiaSess        = input.session("2000-0000", "Asia Time", group="Killzones")
asiaColor       = input.color(color.new(#74a9ff, 70), "Asia Color", group="Killzones")
asiaText        = input.string("Asia", "Asia Label", group="Killzones")

londonSess      = input.session("0200-0500", "London Time", group="Killzones")
londonColor     = input.color(color.new(#f8adad, 70), "London Color", group="Killzones")
londonText      = input.string("London", "London Label", group="Killzones")

nyAMSess        = input.session("0930-1100", "NY AM Time", group="Killzones")
nyAMColor       = input.color(color.new(#a5d6a7, 70), "NY AM Color", group="Killzones")
nyAMText        = input.string("NY AM", "NY AM Label", group="Killzones")

nyLunchSess     = input.session("1200-1300", "NY Lunch Time", group="Killzones")
nyLunchColor    = input.color(color.new(#a5d6a7, 70), "NY Lunch Color", group="Killzones")
nyLunchText     = input.string("NY Lunch", "NY Lunch Label", group="Killzones")

nyPMSess        = input.session("1330-1600", "NY PM Time", group="Killzones")
nyPMColor       = input.color(color.new(#a5d6a7, 70), "NY PM Color", group="Killzones")
nyPMText        = input.string("NY PM", "NY PM Label", group="Killzones")

// =============================================================================
// ORB / OPENING RANGES SETTINGS
// =============================================================================
midStyleInput   = input.string("Dotted", "Midpoint Style", options=["Solid", "Dotted", "Dashed"], group="Opening Projections (High/Low)")
lineWidth       = input.int(1, "Line Thickness", minval=1, group="Opening Projections (High/Low)")

showNineThirty  = input.bool(true, "Show 9:30 ORB", group="Opening Projections (High/Low)")
nineThirtyTime  = input.session("0930-0931", "9:30 AM Candle", group="Opening Projections (High/Low)")
nineThirtyEnd   = input.session("0930-1700", "9:30 End", group="Opening Projections (High/Low)")
nineColor       = input.color(color.red, "9:30 Color", group="Opening Projections (High/Low)")
nineTextH       = input.string("9:30 ORB H", "9:30 High Label", group="Opening Projections (High/Low)")
nineTextL       = input.string("9:30 ORB L", "9:30 Low Label", group="Opening Projections (High/Low)")

showEightAm     = input.bool(true, "Show 8:00 AM ORB", group="Opening Projections (High/Low)")
eightAmTime     = input.session("0800-0801", "8:00 AM Candle", group="Opening Projections (High/Low)")
eightAmEnd      = input.session("0800-1700", "8:00 End", group="Opening Projections (High/Low)")
eightColor      = input.color(color.blue, "8:00 Color", group="Opening Projections (High/Low)")
eightTextH      = input.string("8:00 ORB H", "8:00 High Label", group="Opening Projections (High/Low)")
eightTextL      = input.string("8:00 ORB L", "8:00 Low Label", group="Opening Projections (High/Low)")

showTwoPm       = input.bool(true, "Show 2:00 PM ORB", group="Opening Projections (High/Low)")
twoPmTime       = input.session("1400-1401", "2:00 PM Candle", group="Opening Projections (High/Low)")
twoPmEnd        = input.session("1400-1700", "2:00 PM End", group="Opening Projections (High/Low)")
twoPmColor      = input.color(color.fuchsia, "2:00 PM Color", group="Opening Projections (High/Low)")
twoPmTextH      = input.string("2:00 PM ORB H", "2:00 PM High Label", group="Opening Projections (High/Low)")
twoPmTextL      = input.string("2:00 PM ORB L", "2:00 PM Low Label", group="Opening Projections (High/Low)")

showEightPm     = input.bool(true, "Show 8:00 PM ORB", group="Opening Projections (High/Low)")
eightPmTime     = input.session("2000-2001", "8:00 PM Candle", group="Opening Projections (High/Low)")
eightPmEnd      = input.session("2000-1700", "8:00 PM End", group="Opening Projections (High/Low)")
eightPmColor    = input.color(color.purple, "8:00 PM Color", group="Opening Projections (High/Low)")
eightPmTextH    = input.string("8:00 PM ORB H", "8:00 PM High Label", group="Opening Projections (High/Low)")
eightPmTextL    = input.string("8:00 PM ORB L", "8:00 PM Low Label", group="Opening Projections (High/Low)")

showTwoAm       = input.bool(true, "Show 2:00 AM ORB", group="Opening Projections (High/Low)")
twoAmTime       = input.session("0200-0201", "2:00 AM Candle", group="Opening Projections (High/Low)")
twoAmEnd        = input.session("0200-1700", "2:00 AM End", group="Opening Projections (High/Low)")
twoAmColor      = input.color(color.navy, "2:00 AM Color", group="Opening Projections (High/Low)")
twoAmTextH      = input.string("2:00 AM ORB H", "2:00 AM High Label", group="Opening Projections (High/Low)")
twoAmTextL      = input.string("2:00 AM ORB L", "2:00 AM Low Label", group="Opening Projections (High/Low)")

// =============================================================================
// EXTENDED SESSION H/L SETTINGS (NEW)
// =============================================================================
showAsiaHL      = input.bool(true, "Show Extended Asia H/L", group="Session Projections (High/Low)")
asiaHLTime      = input.session("2000-0000", "Asia Time", group="Session Projections (High/Low)")
asiaHLEnd       = input.session("2000-1700", "Asia End", group="Session Projections (High/Low)")
asiaHLColor     = input.color(color.new(#74a9ff, 0), "Asia Color", group="Session Projections (High/Low)")
asiaHLTextH     = input.string("Asia H", "Asia High Label", group="Session Projections (High/Low)")
asiaHLTextL     = input.string("Asia L", "Asia Low Label", group="Session Projections (High/Low)")

showLondonHL    = input.bool(true, "Show Extended London H/L", group="Session Projections (High/Low)")
londonHLTime    = input.session("0200-0500", "London Time", group="Session Projections (High/Low)")
londonHLEnd     = input.session("0200-1700", "London End", group="Session Projections (High/Low)")
londonHLColor   = input.color(color.new(#f8adad, 0), "London Color", group="Session Projections (High/Low)")
londonHLTextH   = input.string("London H", "London High Label", group="Session Projections (High/Low)")
londonHLTextL   = input.string("London L", "London Low Label", group="Session Projections (High/Low)")

// =============================================================================
// SPECIFIC OPEN PRICES
// =============================================================================
openStyleInput  = input.string("Solid", "Open Line Style", options=["Solid", "Dotted", "Dashed"], group="Specific Open Prices")

showMidOpen     = input.bool(true, "Show Midnight Open", group="Specific Open Prices")
midOpenTime     = input.session("0000-0001", "Midnight Open", group="Specific Open Prices")
midOpenEnd      = input.session("0000-1700", "Midnight End", group="Specific Open Prices")
midOpenColor    = input.color(color.black, "Midnight Color", group="Specific Open Prices")
midOpenText     = input.string("Midnight Open", "Midnight Label", group="Specific Open Prices")

showNineAmOpen  = input.bool(true, "Show 9:00 AM Open", group="Specific Open Prices")
nineAmOpenTime  = input.session("0900-0901", "9:00 AM Open", group="Specific Open Prices")
nineAmOpenEnd   = input.session("0900-1700", "9:00 AM End", group="Specific Open Prices")
nineAmOpenColor = input.color(color.teal, "9:00 AM Color", group="Specific Open Prices")
nineAmText      = input.string("9:00 AM Open", "9:00 AM Label", group="Specific Open Prices")

showTenAmOpen   = input.bool(true, "Show 10:00 AM Open", group="Specific Open Prices")
tenAmOpenTime   = input.session("1000-1001", "10:00 AM Open", group="Specific Open Prices")
tenAmOpenEnd    = input.session("1000-1700", "10:00 AM End", group="Specific Open Prices")
tenAmOpenColor  = input.color(color.maroon, "10:00 AM Color", group="Specific Open Prices")
tenAmText       = input.string("10:00 AM Open", "10:00 AM Label", group="Specific Open Prices")

// =============================================================================
// CANDLESTICK PATTERNS
// =============================================================================
grp_candles = "Candlestick Patterns"
showHighwave = input.bool(true, "Show Highwave Candle", group=grp_candles)
highwaveWickMult = input.float(3.0, minval=0.0, title="Highwave Wick Multiplier", group=grp_candles)
highwaveRangeMult = input.float(1.0, minval=0.0, title="Highwave Range Multiplier", group=grp_candles)
colorHighwave = input.color(color.fuchsia, "Highwave Color", group=grp_candles)

showOutside = input.bool(true, "Show Outside Candle", group=grp_candles)
colorOutside = input.color(color.orange, "Outside Color", group=grp_candles)

showInside = input.bool(true, "Show Inside Candle", group=grp_candles)
colorInside = input.color(color.orange, "Inside Color", group=grp_candles)

showMorningStar = input.bool(true, "Show Morning Star", group=grp_candles)
colorMorningStar = input.color(color.red, "Morning Star Color", group=grp_candles)

showEveningStar = input.bool(true, "Show Evening Star", group=grp_candles)
colorEveningStar = input.color(color.red, "Evening Star Color", group=grp_candles)

// =============================================================================
// PREV D/W/M, GAPS, DOW, 90M CYCLES
// =============================================================================

// Previous Day, Week, Month
grp_prev = 'Previous Day, Week, and Month'
i_pdhShow   = input.bool(true, 'PDH', inline = 'pdh', group = grp_prev)
i_pdhColor  = input.color(#2a2e39, '', inline = 'pdh', group = grp_prev)
i_pdhStyle  = input.string('Dotted', '', options = ['Solid', 'Dashed', 'Dotted'], inline = 'pdh', group = grp_prev)
i_pdlShow   = input.bool(true, 'PDL', inline = 'pdl', group = grp_prev)
i_pdlColor  = input.color(#2a2e39, '', inline = 'pdl', group = grp_prev)
i_pdlStyle  = input.string('Dotted', '', options = ['Solid', 'Dashed', 'Dotted'], inline = 'pdl', group = grp_prev)
i_pdeqShow  = input.bool(false, 'PD EQ', inline = 'pdeq', group = grp_prev)
i_pdeqColor = input.color(#2a2e39, '', inline = 'pdeq', group = grp_prev)
i_pdeqStyle = input.string('Dotted', '', options = ['Solid', 'Dashed', 'Dotted'], inline = 'pdeq', group = grp_prev)
i_pdcShow   = input.bool(false, 'PDC', inline = 'pdc', group = grp_prev)
i_pdcColor  = input.color(#2a2e39, '', inline = 'pdc', group = grp_prev)
i_pdcStyle  = input.string('Dotted', '', options = ['Solid', 'Dashed', 'Dotted'], inline = 'pdc', group = grp_prev)

i_pwhShow   = input.bool(true, 'PWH', inline = 'pwh', group = grp_prev)
i_pwhColor  = input.color(#2a2e39, '', inline = 'pwh', group = grp_prev)
i_pwhStyle  = input.string('Dotted', '', options = ['Solid', 'Dashed', 'Dotted'], inline = 'pwh', group = grp_prev)
i_pwlShow   = input.bool(true, 'PWL', inline = 'pwl', group = grp_prev)
i_pwlColor  = input.color(#2a2e39, '', inline = 'pwl', group = grp_prev)
i_pwlStyle  = input.string('Dotted', '', options = ['Solid', 'Dashed', 'Dotted'], inline = 'pwl', group = grp_prev)
i_pweqShow  = input.bool(false, 'PW EQ', inline = 'pweq', group = grp_prev)
i_pweqColor = input.color(#2a2e39, '', inline = 'pweq', group = grp_prev)
i_pweqStyle = input.string('Dotted', '', options = ['Solid', 'Dashed', 'Dotted'], inline = 'pweq', group = grp_prev)

i_pmhShow   = input.bool(true, 'PMH', inline = 'pmh', group = grp_prev)
i_pmhColor  = input.color(#2a2e39, '', inline = 'pmh', group = grp_prev)
i_pmhStyle  = input.string('Dotted', '', options = ['Solid', 'Dashed', 'Dotted'], inline = 'pmh', group = grp_prev)
i_pmlShow   = input.bool(true, 'PML', inline = 'pml', group = grp_prev)
i_pmlColor  = input.color(#2a2e39, '', inline = 'pml', group = grp_prev)
i_pmlStyle  = input.string('Dotted', '', options = ['Solid', 'Dashed', 'Dotted'], inline = 'pml', group = grp_prev)
remove_prev_mitigated = input.bool(false, 'Remove Mitigated Previous D/W/M Lines', group = grp_prev)

// New Day and Week Opening Gaps
grp_og = 'New Day and Week Opening Gaps'
i_ndogShow       = input.bool(false, 'NDOG', inline = 'ndog', group = grp_og)
i_ndogBgColor    = input.color(color.new(#808080, 85), '', inline = 'ndog', group = grp_og)
i_ndogShowMid    = input.bool(true, 'Midline', inline = 'ndog', group = grp_og)
i_ndogMid        = input.color(#2a2e39, '', inline = 'ndog', group = grp_og)
i_ndogMidStyl    = input.string('Dashed', '', options = ['Solid', 'Dashed', 'Dotted'], inline = 'ndog', group = grp_og)

i_nwogShow       = input.bool(false, 'NWOG', inline = 'nwog', group = grp_og)
i_nwogBgColor    = input.color(color.new(#808080, 85), '', inline = 'nwog', group = grp_og)
i_nwogShowMid    = input.bool(true, 'Midline', inline = 'nwog', group = grp_og)
i_nwogMid        = input.color(#2a2e39, '', inline = 'nwog', group = grp_og)
i_nwogMidStyl    = input.string('Dashed', '', options = ['Solid', 'Dashed', 'Dotted'], inline = 'nwog', group = grp_og)

i_ogMaxGaps    = input.bool(false, 'Limit to Max Gaps', inline = 'ogmax', group = grp_og)
i_ogMaxGapsVal = input.int(5, '', minval = 1, maxval = 30, inline = 'ogmax', group = grp_og)
i_ogRemoveMit  = input.bool(false, 'Remove Mitigated Gaps', group = grp_og)

// Day of Week
grp_dow = 'Day of Week'
i_showDow     = input.bool(false, 'Show Day of Week', inline = 'dow', group = grp_dow)
i_dowTxtColor = input.color(#787b86, '', inline = 'dow', group = grp_dow)
i_dowColor    = input.color(color.new(#808080, 80), 'Daily Separator Color', group = grp_dow)
i_dowLoc_str  = input.string('Top', 'Position', options = ['Top', 'Bottom'], group = grp_dow)
i_dowDays     = input.int(7, 'Days to Show', minval = 1, maxval = 30, group = grp_dow)
i_dowLoc      = i_dowLoc_str == 'Bottom' ? location.bottom : location.top

// 90 Minute Cycles
grp_90m = '90 Minute Cycles'
show_90m         = input.bool(false, 'Show 90M Cycles', group = grp_90m)
show_90m_outline = input.bool(false, 'Show Cycle Borders', group = grp_90m)
show_90m_labels  = input.bool(false, 'Show Cycle Labels', group = grp_90m)
use_90m_lbl_color = input.bool(false, 'Use One Color for Cycle Labels', inline = '90lbl', group = grp_90m)
custom_90m_lbl_css = input.color(#000000, '', inline = '90lbl', group = grp_90m)
lbl_90m_size_str = input.string('Tiny', 'Label Size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = grp_90m)

// =============================================================================
// UTILITIES & TYPES
// =============================================================================
getLineStyle(s) => s == "Solid" ? line.style_solid : s == "Dotted" ? line.style_dotted : line.style_dashed

type QCycle
    float hi = na
    float lo = na
    int start_t = na
    box bx = na
    label lbl = na

method process(QCycle this, bool show, float is_now, float is_prev, color css, string txt, bool outline, bool labels, bool use_lbl_css, color lbl_css, string lbl_sz) =>
    if show
        if is_now > is_prev
            this.start_t := time, this.hi := high, this.lo := low
            this.bx := box.new(bar_index, this.hi, bar_index, this.lo, bgcolor = css, border_color = outline ? color.new(css, 0) : na, border_style = line.style_dotted)
            if labels
                color txt_css = use_lbl_css ? lbl_css : color.new(css, 0)
                string sz = lbl_sz == 'Small' ? size.small : lbl_sz == 'Normal' ? size.normal : lbl_sz == 'Large' ? size.large : size.tiny
                this.lbl := label.new(time, this.hi, txt, xloc = xloc.bar_time, textcolor = txt_css, style = label.style_label_down, color = color.new(color.white, 100), size = sz)
        if bool(is_now) and is_now == is_prev
            if high > this.hi
                this.hi := high
            if low < this.lo
                this.lo := low
            if not na(this.bx)
                box.set_top(this.bx, this.hi), box.set_rightbottom(this.bx, bar_index, this.lo)
            if labels and not na(this.lbl)
                label.set_xy(this.lbl, int(math.avg(this.start_t, time)), this.hi)

// =============================================================================
// HTF DATA FETCHING
// =============================================================================
n  = bar_index
tf = timeframe.period
tz = "America/New_York"
is_intraday = timeframe.isintraday

[sec_pmH, sec_pmL] = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead = barmerge.lookahead_on)

// =============================================================================
// YOUR CUSTOM ORB / KILLZONE FUNCTIONS
// =============================================================================
processSession(string sess, color _color, bool _isKillzone, bool _isOrangeHL, string _name) =>
    var float hi = na
    var float lo = na
    var box b = na
    var line lHi = na
    var line lLo = na
    
    inSession = not na(time(timeframe.period, sess, "America/New_York"))
    isNew     = inSession and not inSession[1]
    
    if isNew
        hi := high
        lo := low
        if _isKillzone and showKillzones
            b := box.new(bar_index, hi, bar_index, lo, border_color=_color, bgcolor=_color)
            if showText
                box.set_text(b, _name), box.set_text_color(b, color.new(color.black, 30)), box.set_text_size(b, size.small)
        if _isOrangeHL and showSessHL
            lHi := line.new(bar_index, hi, bar_index, hi, color=color.orange, width=1)
            lLo := line.new(bar_index, lo, bar_index, lo, color=color.orange, width=1)
    else if inSession
        hi := math.max(high, hi)
        lo := math.min(low, lo)
        if _isKillzone and showKillzones and not na(b)
            box.set_top(b, hi), box.set_bottom(b, lo), box.set_right(b, bar_index)
        if _isOrangeHL and showSessHL and not na(lHi)
            line.set_xy1(lHi, line.get_x1(lHi), hi), line.set_xy2(lHi, bar_index, hi)
            line.set_xy1(lLo, line.get_x1(lLo), lo), line.set_xy2(lLo, bar_index, lo)
    int _dummy = 0 

renderOpening(string sessTime, string endTime, color _color, string _textH, string _textL) =>
    var float h = na
    var float l = na
    var line tL = na, var line bL = na, var line mL = na
    var label lblH = na, var label lblL = na
    
    isStart  = not na(time(timeframe.period, sessTime, "America/New_York"))
    isWithin = not na(time(timeframe.period, endTime, "America/New_York"))
    
    if isStart and not isStart[1]
        h := high
        l := low
        tL := line.new(bar_index, h, bar_index, h, color=_color, width=lineWidth)
        bL := line.new(bar_index, l, bar_index, l, color=_color, width=lineWidth)
        mL := line.new(bar_index, (h+l)/2, bar_index, (h+l)/2, color=color.black, width=lineWidth, style=getLineStyle(midStyleInput))
        if showText
            lblH := label.new(bar_index, h, _textH, color=color.new(color.white, 100), textcolor=_color, style=label.style_label_left, size=size.small)
            lblL := label.new(bar_index, l, _textL, color=color.new(color.white, 100), textcolor=_color, style=label.style_label_left, size=size.small)
    else if isWithin and not na(h)
        line.set_x2(tL, bar_index), line.set_x2(bL, bar_index), line.set_x2(mL, bar_index)
        if showText
            if not na(lblH)
                label.set_xy(lblH, bar_index, h)
            if not na(lblL)
                label.set_xy(lblL, bar_index, l)
    int _dummy = 0 

renderExtendedHL(string sessTime, string endTime, color _color, string _textH, string _textL) =>
    var float h = na
    var float l = na
    var line tL = na, var line bL = na, var line mL = na
    var label lblH = na, var label lblL = na
    
    inSession = not na(time(timeframe.period, sessTime, "America/New_York"))
    isWithin  = not na(time(timeframe.period, endTime, "America/New_York"))
    isNew     = inSession and not inSession[1]
    
    if isNew
        h := high
        l := low
        tL := line.new(bar_index, h, bar_index, h, color=_color, width=lineWidth)
        bL := line.new(bar_index, l, bar_index, l, color=_color, width=lineWidth)
        mL := line.new(bar_index, (h+l)/2, bar_index, (h+l)/2, color=color.black, width=lineWidth, style=getLineStyle(midStyleInput))
        if showText
            lblH := label.new(bar_index, h, _textH, color=color.new(color.white, 100), textcolor=_color, style=label.style_label_left, size=size.small)
            lblL := label.new(bar_index, l, _textL, color=color.new(color.white, 100), textcolor=_color, style=label.style_label_left, size=size.small)
    else if inSession
        h := math.max(high, nz(h, high))
        l := math.min(low, nz(l, low))
        line.set_y1(tL, h), line.set_y2(tL, h), line.set_x2(tL, bar_index)
        line.set_y1(bL, l), line.set_y2(bL, l), line.set_x2(bL, bar_index)
        line.set_y1(mL, (h+l)/2), line.set_y2(mL, (h+l)/2), line.set_x2(mL, bar_index)
        if showText
            if not na(lblH)
                label.set_xy(lblH, bar_index, h)
            if not na(lblL)
                label.set_xy(lblL, bar_index, l)
    else if isWithin and not na(h)
        line.set_x2(tL, bar_index), line.set_x2(bL, bar_index), line.set_x2(mL, bar_index)
        if showText
            if not na(lblH)
                label.set_xy(lblH, bar_index, h)
            if not na(lblL)
                label.set_xy(lblL, bar_index, l)
    int _dummy = 0

renderSingleOpen(string sessTime, string endTime, color _color, string _text) =>
    var float oPrice = na
    var line oLine = na
    var label lbl = na
    
    isStart  = not na(time(timeframe.period, sessTime, "America/New_York"))
    isWithin = not na(time(timeframe.period, endTime, "America/New_York"))
    
    if isStart and not isStart[1]
        oPrice := open
        oLine := line.new(bar_index, oPrice, bar_index, oPrice, color=_color, width=lineWidth, style=getLineStyle(openStyleInput))
        if showText
            lbl := label.new(bar_index, oPrice, _text, color=color.new(color.white, 100), textcolor=_color, style=label.style_label_left, size=size.small)
    else if isWithin and not na(oPrice)
        line.set_x2(oLine, bar_index)
        if showText and not na(lbl)
            label.set_xy(lbl, bar_index, oPrice)
    int _dummy = 0 

// =============================================================================
// MAIN EXECUTION
// =============================================================================

// --- 1. Your Custom Drawings ---
processSession(asiaSess, asiaColor, true, true, asiaText)
processSession(londonSess, londonColor, true, true, londonText)
processSession(nyAMSess, nyAMColor, true, false, nyAMText)
processSession(nyLunchSess, nyLunchColor, true, false, nyLunchText)
processSession(nyPMSess, nyPMColor, true, false, nyPMText)

if showNineThirty
    renderOpening(nineThirtyTime, nineThirtyEnd, nineColor, nineTextH, nineTextL)
if showEightAm
    renderOpening(eightAmTime, eightAmEnd, eightColor, eightTextH, eightTextL)
if showTwoPm
    renderOpening(twoPmTime, twoPmEnd, twoPmColor, twoPmTextH, twoPmTextL)
if showEightPm
    renderOpening(eightPmTime, eightPmEnd, eightPmColor, eightPmTextH, eightPmTextL)
if showTwoAm
    renderOpening(twoAmTime, twoAmEnd, twoAmColor, twoAmTextH, twoAmTextL)

if showAsiaHL
    renderExtendedHL(asiaHLTime, asiaHLEnd, asiaHLColor, asiaHLTextH, asiaHLTextL)
if showLondonHL
    renderExtendedHL(londonHLTime, londonHLEnd, londonHLColor, londonHLTextH, londonHLTextL)

if showMidOpen
    renderSingleOpen(midOpenTime, midOpenEnd, midOpenColor, midOpenText)
if showNineAmOpen
    renderSingleOpen(nineAmOpenTime, nineAmOpenEnd, nineAmOpenColor, nineAmText)
if showTenAmOpen
    renderSingleOpen(tenAmOpenTime, tenAmOpenEnd, tenAmOpenColor, tenAmText)

// --- 2. HTF Levels & Mitigation ---
bool newDay = (is_intraday or timeframe.isdaily) and ta.change(time("D")) != 0
var float tdH = na, var float tdL = na
var float pdH = na, var float pdL = na, var float pdEQ = na, var float pdC = na
if newDay
    pdH := tdH, pdL := tdL, pdEQ := (tdH + tdL) / 2.0, pdC := close[1]
    tdH := high, tdL := low
if not newDay
    if na(tdH)
        tdH := high, tdL := low
    if high > nz(tdH, high)
        tdH := high
    if low < nz(tdL, low)
        tdL := low

var line ln_pdh = na, var line ln_pdl = na, var line ln_pdeq = na, var line ln_pdc = na
var label lb_pdh = na, var label lb_pdl = na, var label lb_pdeq = na, var label lb_pdc = na

if newDay
    line.delete(ln_pdh), line.delete(ln_pdl), line.delete(ln_pdeq), line.delete(ln_pdc)
    label.delete(lb_pdh), label.delete(lb_pdl), label.delete(lb_pdeq), label.delete(lb_pdc)
    if i_pdhShow
        ln_pdh := line.new(bar_index, pdH, bar_index, pdH, color=i_pdhColor, style=getLineStyle(i_pdhStyle))
    if i_pdlShow
        ln_pdl := line.new(bar_index, pdL, bar_index, pdL, color=i_pdlColor, style=getLineStyle(i_pdlStyle))
    if i_pdeqShow
        ln_pdeq := line.new(bar_index, pdEQ, bar_index, pdEQ, color=i_pdeqColor, style=getLineStyle(i_pdeqStyle))
    if i_pdcShow
        ln_pdc := line.new(bar_index, pdC, bar_index, pdC, color=i_pdcColor, style=getLineStyle(i_pdcStyle))

if i_pdhShow and not na(ln_pdh)
    line.set_x2(ln_pdh, bar_index + 5)
if i_pdlShow and not na(ln_pdl)
    line.set_x2(ln_pdl, bar_index + 5)
if i_pdeqShow and not na(ln_pdeq)
    line.set_x2(ln_pdeq, bar_index + 5)
if i_pdcShow and not na(ln_pdc)
    line.set_x2(ln_pdc, bar_index + 5)

if remove_prev_mitigated
    if i_pdhShow and not na(ln_pdh) and high >= pdH
        line.delete(ln_pdh), label.delete(lb_pdh), ln_pdh := na, lb_pdh := na
    if i_pdlShow and not na(ln_pdl) and low <= pdL
        line.delete(ln_pdl), label.delete(lb_pdl), ln_pdl := na, lb_pdl := na

if barstate.islast
    if i_pdhShow and not na(ln_pdh)
        label.delete(lb_pdh), lb_pdh := label.new(bar_index + 5, pdH, 'PDH', style=label.style_label_left, color=color(na), textcolor=i_pdhColor, size=size.small)
    if i_pdlShow and not na(ln_pdl)
        label.delete(lb_pdl), lb_pdl := label.new(bar_index + 5, pdL, 'PDL', style=label.style_label_left, color=color(na), textcolor=i_pdlColor, size=size.small)
    if i_pdeqShow and not na(ln_pdeq)
        label.delete(lb_pdeq), lb_pdeq := label.new(bar_index + 5, pdEQ, 'PD EQ', style=label.style_label_left, color=color(na), textcolor=i_pdeqColor, size=size.small)
    if i_pdcShow and not na(ln_pdc)
        label.delete(lb_pdc), lb_pdc := label.new(bar_index + 5, pdC, 'PDC', style=label.style_label_left, color=color(na), textcolor=i_pdcColor, size=size.small)

bool newWeekPW = not timeframe.ismonthly and ta.change(time("W")) != 0
var float twH = na, var float twL = na
var float pwH = na, var float pwL = na, var float pwEQ = na
if newWeekPW
    pwH := twH, pwL := twL, pwEQ := (twH + twL) / 2.0
    twH := high, twL := low
if not newWeekPW
    if na(twH)
        twH := high, twL := low
    if high > nz(twH, high)
        twH := high
    if low < nz(twL, low)
        twL := low

var line ln_pwh = na, var line ln_pwl = na, var line ln_pweq = na
var label lb_pwh = na, var label lb_pwl = na, var label lb_pweq = na

if newWeekPW
    line.delete(ln_pwh), line.delete(ln_pwl), line.delete(ln_pweq)
    label.delete(lb_pwh), label.delete(lb_pwl), label.delete(lb_pweq)
    if i_pwhShow
        ln_pwh := line.new(bar_index, pwH, bar_index, pwH, color=i_pwhColor, style=getLineStyle(i_pwhStyle))
    if i_pwlShow
        ln_pwl := line.new(bar_index, pwL, bar_index, pwL, color=i_pwlColor, style=getLineStyle(i_pwlStyle))
    if i_pweqShow
        ln_pweq := line.new(bar_index, pwEQ, bar_index, pwEQ, color=i_pweqColor, style=getLineStyle(i_pweqStyle))

if i_pwhShow and not na(ln_pwh)
    line.set_x2(ln_pwh, bar_index + 5)
if i_pwlShow and not na(ln_pwl)
    line.set_x2(ln_pwl, bar_index + 5)
if i_pweqShow and not na(ln_pweq)
    line.set_x2(ln_pweq, bar_index + 5)

if remove_prev_mitigated
    if i_pwhShow and not na(ln_pwh) and high >= pwH
        line.delete(ln_pwh), label.delete(lb_pwh), ln_pwh := na, lb_pwh := na
    if i_pwlShow and not na(ln_pwl) and low <= pwL
        line.delete(ln_pwl), label.delete(lb_pwl), ln_pwl := na, lb_pwl := na

if barstate.islast and not timeframe.ismonthly
    if i_pwhShow and not na(ln_pwh)
        label.delete(lb_pwh), lb_pwh := label.new(bar_index + 5, pwH, 'PWH', style=label.style_label_left, color=color(na), textcolor=i_pwhColor, size=size.small)
    if i_pwlShow and not na(ln_pwl)
        label.delete(lb_pwl), lb_pwl := label.new(bar_index + 5, pwL, 'PWL', style=label.style_label_left, color=color(na), textcolor=i_pwlColor, size=size.small)
    if i_pweqShow and not na(ln_pweq)
        label.delete(lb_pweq), lb_pweq := label.new(bar_index + 5, pwEQ, 'PW EQ', style=label.style_label_left, color=color(na), textcolor=i_pweqColor, size=size.small)

bool newMonthPM = ta.change(time("M")) != 0
var float tmH = na, var float tmL = na
var float pmH = na, var float pmL = na
if newMonthPM
    pmH := sec_pmH, pmL := sec_pmL
    tmH := high, tmL := low
if not newMonthPM
    if na(tmH)
        tmH := high, tmL := low
    if high > nz(tmH, high)
        tmH := high
    if low < nz(tmL, low)
        tmL := low

var line ln_pmh = na, var line ln_pml = na
var label lb_pmh = na, var label lb_pml = na
if newMonthPM
    line.delete(ln_pmh), line.delete(ln_pml)
    label.delete(lb_pmh), label.delete(lb_pml)
    if i_pmhShow
        ln_pmh := line.new(bar_index, pmH, bar_index, pmH, color=i_pmhColor, style=getLineStyle(i_pmhStyle))
    if i_pmlShow
        ln_pml := line.new(bar_index, pmL, bar_index, pmL, color=i_pmlColor, style=getLineStyle(i_pmlStyle))

if i_pmhShow and not na(ln_pmh)
    line.set_x2(ln_pmh, bar_index + 5)
if i_pmlShow and not na(ln_pml)
    line.set_x2(ln_pml, bar_index + 5)

if na(pmH) and not na(sec_pmH)
    pmH := sec_pmH
if na(pmL) and not na(sec_pmL)
    pmL := sec_pmL

if not na(pmH) and not na(pmL) and na(ln_pmh) and i_pmhShow
    ln_pmh := line.new(bar_index, pmH, bar_index, pmH, color=i_pmhColor, style=getLineStyle(i_pmhStyle))
if not na(pmH) and not na(pmL) and na(ln_pml) and i_pmlShow
    ln_pml := line.new(bar_index, pmL, bar_index, pmL, color=i_pmlColor, style=getLineStyle(i_pmlStyle))

if remove_prev_mitigated
    if i_pmhShow and not na(ln_pmh) and high >= pmH
        line.delete(ln_pmh), label.delete(lb_pmh), ln_pmh := na, lb_pmh := na
    if i_pmlShow and not na(ln_pml) and low <= pmL
        line.delete(ln_pml), label.delete(lb_pml), ln_pml := na, lb_pml := na

if barstate.islast
    if i_pmhShow and not na(ln_pmh)
        label.delete(lb_pmh), lb_pmh := label.new(bar_index + 5, pmH, 'PMH', style=label.style_label_left, color=color(na), textcolor=i_pmhColor, size=size.small)
    if i_pmlShow and not na(ln_pml)
        label.delete(lb_pml), lb_pml := label.new(bar_index + 5, pmL, 'PML', style=label.style_label_left, color=color(na), textcolor=i_pmlColor, size=size.small)

// --- 3. Opening Gaps (NDOG/NWOG) ---
var box[] ndog_boxes = array.new_box(), var line[] ndog_mids = array.new_line(), var label[] ndog_lbls = array.new_label()
var float[] ndog_tops = array.new_float(), var float[] ndog_bots = array.new_float(), var bool[] ndog_top_hit = array.new_bool(), var bool[] ndog_bot_hit = array.new_bool()

var box[] nwog_boxes = array.new_box(), var line[] nwog_mids = array.new_line(), var label[] nwog_lbls = array.new_label()
var float[] nwog_tops = array.new_float(), var float[] nwog_bots = array.new_float(), var bool[] nwog_top_hit = array.new_bool(), var bool[] nwog_bot_hit = array.new_bool()

if is_intraday and i_ndogShow and newDay
    float dg_top = math.max(close[1], open), float dg_bot = math.min(close[1], open), float dg_mid = (dg_top + dg_bot) / 2.0
    if dg_top != dg_bot
        array.push(ndog_boxes, box.new(bar_index, dg_top, bar_index, dg_bot, bgcolor=i_ndogBgColor, border_color=na))
        array.push(ndog_mids, i_ndogShowMid ? line.new(bar_index, dg_mid, bar_index, dg_mid, color=i_ndogMid, style=getLineStyle(i_ndogMidStyl)) : na)
        array.push(ndog_lbls, label.new(bar_index + 1, dg_mid, 'NDOG', style=label.style_label_left, color=color(na), textcolor=i_ndogMid, size=size.small))
        array.push(ndog_tops, dg_top), array.push(ndog_bots, dg_bot), array.push(ndog_top_hit, false), array.push(ndog_bot_hit, false)
        if i_ogMaxGaps and array.size(ndog_boxes) > i_ogMaxGapsVal
            box.delete(array.shift(ndog_boxes)), line mid_old = array.shift(ndog_mids)
            if not na(mid_old)
                line.delete(mid_old)
            label.delete(array.shift(ndog_lbls)), array.shift(ndog_tops), array.shift(ndog_bots), array.shift(ndog_top_hit), array.shift(ndog_bot_hit)

if is_intraday and i_nwogShow and newWeekPW
    float wg_top = math.max(close[1], open), float wg_bot = math.min(close[1], open), float wg_mid = (wg_top + wg_bot) / 2.0
    if wg_top != wg_bot
        array.push(nwog_boxes, box.new(bar_index, wg_top, bar_index, wg_bot, bgcolor=i_nwogBgColor, border_color=na))
        array.push(nwog_mids, i_nwogShowMid ? line.new(bar_index, wg_mid, bar_index, wg_mid, color=i_nwogMid, style=getLineStyle(i_nwogMidStyl)) : na)
        array.push(nwog_lbls, label.new(bar_index + 1, wg_mid, 'NWOG', style=label.style_label_left, color=color(na), textcolor=i_nwogMid, size=size.small))
        array.push(nwog_tops, wg_top), array.push(nwog_bots, wg_bot), array.push(nwog_top_hit, false), array.push(nwog_bot_hit, false)
        if i_ogMaxGaps and array.size(nwog_boxes) > i_ogMaxGapsVal
            box.delete(array.shift(nwog_boxes)), line mid_old = array.shift(nwog_mids)
            if not na(mid_old)
                line.delete(mid_old)
            label.delete(array.shift(nwog_lbls)), array.shift(nwog_tops), array.shift(nwog_bots), array.shift(ndog_top_hit), array.shift(ndog_bot_hit)

if array.size(ndog_boxes) > 0
    for i = array.size(ndog_boxes) - 1 to 0
        bx = array.get(ndog_boxes, i), mid = array.get(ndog_mids, i), lbl = array.get(ndog_lbls, i), gt = array.get(ndog_tops, i), gb = array.get(ndog_bots, i)
        if high >= gt
            array.set(ndog_top_hit, i, true)
        if low <= gb
            array.set(ndog_bot_hit, i, true)
        if i_ogRemoveMit and array.get(ndog_top_hit, i) and array.get(ndog_bot_hit, i)
            box.delete(bx)
            if not na(mid)
                line.delete(mid)
            label.delete(lbl), array.remove(ndog_boxes, i), array.remove(ndog_mids, i), array.remove(ndog_lbls, i), array.remove(ndog_tops, i), array.remove(ndog_bots, i), array.remove(ndog_top_hit, i), array.remove(ndog_bot_hit, i)
        else
            box.set_right(bx, bar_index)
            if not na(mid)
                line.set_x2(mid, bar_index)
            label.set_x(lbl, bar_index + 1)

if array.size(nwog_boxes) > 0
    for i = array.size(nwog_boxes) - 1 to 0
        bx = array.get(nwog_boxes, i), mid = array.get(nwog_mids, i), lbl = array.get(nwog_lbls, i), gt = array.get(nwog_tops, i), gb = array.get(nwog_bots, i)
        if high >= gt
            array.set(nwog_top_hit, i, true)
        if low <= gb
            array.set(nwog_bot_hit, i, true)
        if i_ogRemoveMit and array.get(nwog_top_hit, i) and array.get(nwog_bot_hit, i)
            box.delete(bx)
            if not na(mid)
                line.delete(mid)
            label.delete(lbl), array.remove(nwog_boxes, i), array.remove(nwog_mids, i), array.remove(nwog_lbls, i), array.remove(nwog_tops, i), array.remove(nwog_bots, i), array.remove(nwog_top_hit, i), array.remove(nwog_bot_hit, i)
        else
            box.set_right(bx, bar_index)
            if not na(mid)
                line.set_x2(mid, bar_index)
            label.set_x(lbl, bar_index + 1)

// --- 4. Day of Week ---
var line[] dow_lines = array.new_line()
if is_intraday and i_showDow and newDay
    array.push(dow_lines, line.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, extend=extend.both, color=i_dowColor, style=line.style_dotted))
    if array.size(dow_lines) > i_dowDays
        line.delete(array.shift(dow_lines))

bool dowTime = hour == 5 and minute == 0
plotchar(i_showDow and dowTime and dayofweek == dayofweek.monday ? true : false, char=' ', text='M O N', color=color.new(i_dowTxtColor, 100), location=i_dowLoc, textcolor=i_dowTxtColor, editable=false)
plotchar(i_showDow and dowTime and dayofweek == dayofweek.tuesday ? true : false, char=' ', text='T U E', color=color.new(i_dowTxtColor, 100), location=i_dowLoc, textcolor=i_dowTxtColor, editable=false)
plotchar(i_showDow and dowTime and dayofweek == dayofweek.wednesday ? true : false, char=' ', text='W E D', color=color.new(i_dowTxtColor, 100), location=i_dowLoc, textcolor=i_dowTxtColor, editable=false)
plotchar(i_showDow and dowTime and dayofweek == dayofweek.thursday ? true : false, char=' ', text='T H U', color=color.new(i_dowTxtColor, 100), location=i_dowLoc, textcolor=i_dowTxtColor, editable=false)
plotchar(i_showDow and dowTime and dayofweek == dayofweek.friday ? true : false, char=' ', text='F R I', color=color.new(i_dowTxtColor, 100), location=i_dowLoc, textcolor=i_dowTxtColor, editable=false)

// --- 5. 90 Minute Cycles ---
var QCycle qcA1 = QCycle.new(), var QCycle qcA2 = QCycle.new(), var QCycle qcA3 = QCycle.new(), var QCycle qcA4 = QCycle.new()
var QCycle qcL1 = QCycle.new(), var QCycle qcL2 = QCycle.new(), var QCycle qcL3 = QCycle.new(), var QCycle qcL4 = QCycle.new()
var QCycle qcN1 = QCycle.new(), var QCycle qcN2 = QCycle.new(), var QCycle qcN3 = QCycle.new(), var QCycle qcN4 = QCycle.new()
var QCycle qcP1 = QCycle.new(), var QCycle qcP2 = QCycle.new(), var QCycle qcP3 = QCycle.new(), var QCycle qcP4 = QCycle.new()

is_qa1 = is_intraday ? math.sign(nz(time(tf, "1800-1930", tz))) : 0, is_qa2 = is_intraday ? math.sign(nz(time(tf, "1930-2100", tz))) : 0
is_qa3 = is_intraday ? math.sign(nz(time(tf, "2100-2230", tz))) : 0, is_qa4 = is_intraday ? math.sign(nz(time(tf, "2230-0000", tz))) : 0
is_ql1 = is_intraday ? math.sign(nz(time(tf, "0000-0130", tz))) : 0, is_ql2 = is_intraday ? math.sign(nz(time(tf, "0130-0300", tz))) : 0
is_ql3 = is_intraday ? math.sign(nz(time(tf, "0300-0430", tz))) : 0, is_ql4 = is_intraday ? math.sign(nz(time(tf, "0430-0600", tz))) : 0
is_qn1 = is_intraday ? math.sign(nz(time(tf, "0600-0730", tz))) : 0, is_qn2 = is_intraday ? math.sign(nz(time(tf, "0730-0900", tz))) : 0
is_qn3 = is_intraday ? math.sign(nz(time(tf, "0900-1030", tz))) : 0, is_qn4 = is_intraday ? math.sign(nz(time(tf, "1030-1200", tz))) : 0
is_qp1 = is_intraday ? math.sign(nz(time(tf, "1200-1330", tz))) : 0, is_qp2 = is_intraday ? math.sign(nz(time(tf, "1330-1500", tz))) : 0
is_qp3 = is_intraday ? math.sign(nz(time(tf, "1500-1630", tz))) : 0, is_qp4 = is_intraday ? math.sign(nz(time(tf, "1630-1800", tz))) : 0

c90 = color.new(#808080, 80)
qcA1.process(show_90m, is_qa1, is_qa1[1], c90, 'Asia Q1', show_90m_outline, show_90m_labels, use_90m_lbl_color, custom_90m_lbl_css, lbl_90m_size_str)
qcA2.process(show_90m, is_qa2, is_qa2[1], c90, 'Asia Q2', show_90m_outline, show_90m_labels, use_90m_lbl_color, custom_90m_lbl_css, lbl_90m_size_str)
qcA3.process(show_90m, is_qa3, is_qa3[1], c90, 'Asia Q3', show_90m_outline, show_90m_labels, use_90m_lbl_color, custom_90m_lbl_css, lbl_90m_size_str)
qcA4.process(show_90m, is_qa4, is_qa4[1], c90, 'Asia Q4', show_90m_outline, show_90m_labels, use_90m_lbl_color, custom_90m_lbl_css, lbl_90m_size_str)
qcL1.process(show_90m, is_ql1, is_ql1[1], c90, 'London Q1', show_90m_outline, show_90m_labels, use_90m_lbl_color, custom_90m_lbl_css, lbl_90m_size_str)
qcL2.process(show_90m, is_ql2, is_ql2[1], c90, 'London Q2', show_90m_outline, show_90m_labels, use_90m_lbl_color, custom_90m_lbl_css, lbl_90m_size_str)
qcL3.process(show_90m, is_ql3, is_ql3[1], c90, 'London Q3', show_90m_outline, show_90m_labels, use_90m_lbl_color, custom_90m_lbl_css, lbl_90m_size_str)
qcL4.process(show_90m, is_ql4, is_ql4[1], c90, 'London Q4', show_90m_outline, show_90m_labels, use_90m_lbl_color, custom_90m_lbl_css, lbl_90m_size_str)
qcN1.process(show_90m, is_qn1, is_qn1[1], c90, 'NY AM Q1', show_90m_outline, show_90m_labels, use_90m_lbl_color, custom_90m_lbl_css, lbl_90m_size_str)
qcN2.process(show_90m, is_qn2, is_qn2[1], c90, 'NY AM Q2', show_90m_outline, show_90m_labels, use_90m_lbl_color, custom_90m_lbl_css, lbl_90m_size_str)
qcN3.process(show_90m, is_qn3, is_qn3[1], c90, 'NY AM Q3', show_90m_outline, show_90m_labels, use_90m_lbl_color, custom_90m_lbl_css, lbl_90m_size_str)
qcN4.process(show_90m, is_qn4, is_qn4[1], c90, 'NY AM Q4', show_90m_outline, show_90m_labels, use_90m_lbl_color, custom_90m_lbl_css, lbl_90m_size_str)
qcP1.process(show_90m, is_qp1, is_qp1[1], c90, 'NY PM Q1', show_90m_outline, show_90m_labels, use_90m_lbl_color, custom_90m_lbl_css, lbl_90m_size_str)
qcP2.process(show_90m, is_qp2, is_qp2[1], c90, 'NY PM Q2', show_90m_outline, show_90m_labels, use_90m_lbl_color, custom_90m_lbl_css, lbl_90m_size_str)
qcP3.process(show_90m, is_qp3, is_qp3[1], c90, 'NY PM Q3', show_90m_outline, show_90m_labels, use_90m_lbl_color, custom_90m_lbl_css, lbl_90m_size_str)
qcP4.process(show_90m, is_qp4, is_qp4[1], c90, 'NY PM Q4', show_90m_outline, show_90m_labels, use_90m_lbl_color, custom_90m_lbl_css, lbl_90m_size_str)

// --- 6. Candlestick Pattern Calculations ---
c_day = high - low
c_day_1 = high[1] - low[1]
c_day_2 = high[2] - low[2]
c_day_3 = high[3] - low[3]
c_day_4 = high[4] - low[4]
c_day_5 = high[5] - low[5]
c_avg = (c_day_1 + c_day_2 + c_day_3 + c_day_4 + c_day_5) / 5

isHighwave = (((c_day) - (math.abs(open - close))) > ((math.abs(open - close)) * highwaveWickMult)) and ((c_day > (c_avg * highwaveRangeMult)))
isOutside = high > high[1] and low < low[1]
isInside = high <= high[1] and low >= low[1]
isMorningStar = (close[2] < open[2]) and (low[1] < low[2]) and (high[1] < hl2[2]) and (close > open) and (close > open[2]) and (close > high[1]) and (open[1] >= hl2[1]) and (close[1] >= hl2[1])
isEveningStar = (close[2] > open[2]) and (high[1] > high[2]) and (low[1] > hl2[2]) and (close < open) and (close < open[2]) and (close < low[1]) and (open[1] <= hl2[1]) and (close[1] <= hl2[1])

// Note: If multiple patterns trigger on the exact same candle, TradingView will display the color of the last one evaluated in this list.
barcolor(showHighwave and isHighwave ? colorHighwave : na, title="Highwave Candle")
barcolor(showOutside and isOutside ? colorOutside : na, title="Outside Candle")
barcolor(showInside and isInside ? colorInside : na, title="Inside Candle")
barcolor(showMorningStar and isMorningStar ? colorMorningStar : na, title="Morning Star")
barcolor(showEveningStar and isEveningStar ? colorEveningStar : na, title="Evening Star")

// --- Settings Inputs ---
grp_ma = "Moving Averages & VWAP"

showEma1   = input.bool(true, "Show EMA 1", group=grp_ma)
tf1        = input.timeframe("1", title="EMA 1 Timeframe", group=grp_ma)
lenEma1    = input.int(200, title="EMA 1 Length", minval=1, group=grp_ma)
color_ema1 = input.color(color.blue, title="EMA 1 Color", group=grp_ma)
thick_ema1 = input.int(2, title="EMA 1 Thickness", minval=1, maxval=4, group=grp_ma)

showEma2   = input.bool(true, "Show EMA 2", group=grp_ma)
tf2        = input.timeframe("5", title="EMA 2 Timeframe", group=grp_ma)
lenEma2    = input.int(200, title="EMA 2 Length", minval=1, group=grp_ma)
color_ema2 = input.color(color.red, title="EMA 2 Color", group=grp_ma)
thick_ema2 = input.int(2, title="EMA 2 Thickness", minval=1, maxval=4, group=grp_ma)

showVwap   = input.bool(true, "Show VWAP", group=grp_ma)
color_vwap = input.color(color.orange, title="VWAP Color", group=grp_ma)
thick_vwap = input.int(2, title="VWAP Thickness", minval=1, maxval=4, group=grp_ma)

// --- Smooth EMA Function ---
// Calculates a dynamically scaled EMA to avoid the "staircase" effect
f_smooth_ema(target_tf, base_length) =>
    // Get timeframe duration in seconds
    target_secs = timeframe.in_seconds(target_tf)
    chart_secs = timeframe.in_seconds(timeframe.period)
    
    // Fallbacks to prevent division errors on unusual chart types
    safe_target = target_secs == 0 ? 1 : target_secs
    safe_chart = chart_secs == 0 ? 1 : chart_secs
    
    // Calculate the multiplier (e.g., 300 secs / 60 secs = 5)
    multiplier = math.max(1, safe_target / safe_chart)
    
    // Calculate the newly scaled EMA
    ta.ema(close, math.round(base_length * multiplier))

// --- Calculations ---
ema1 = f_smooth_ema(tf1, lenEma1)
ema2 = f_smooth_ema(tf2, lenEma2)
vwap_value = ta.vwap

// --- Plotting ---
plot(showEma1 ? ema1 : na, color=color_ema1, linewidth=thick_ema1, title="EMA 1")
plot(showEma2 ? ema2 : na, color=color_ema2, linewidth=thick_ema2, title="EMA 2")
plot(showVwap ? vwap_value : na, color=color_vwap, linewidth=thick_vwap, title="VWAP")

type Candle
	float o
	float c
	float h
	float l
    int o_time
	int o_idx
	int c_idx
	int h_idx
	int l_idx
    string dow
	box body
	line wick_up
	line wick_down
    label dow_label

type Trace
	line o
	line c
	line h
	line l
	label o_l
	label c_l
	label h_l
	label l_l

type Imbalance
	box b
	int idx

type CandleSettings
	bool show
	string htf
	int max_display

type Settings
	int max_sets
	color bull_body
	color bull_border
	color bull_wick
	color bear_body
	color bear_border
	color bear_wick
	int offset
	int buffer
	int htf_buffer
	int width
	bool use_custom_daily
    string custom_daily
    bool daily_name
	bool trace_show
	color trace_o_color
	string trace_o_style
	int trace_o_size
	color trace_c_color
	string trace_c_style
	int trace_c_size
	color trace_h_color
	string trace_h_style
	int trace_h_size
	color trace_l_color
	string trace_l_style
	int trace_l_size
	string trace_anchor
	bool label_show
	color label_color
	string label_size
    string label_position
    string label_alignment
	bool fvg_show
	color fvg_color
	bool vi_show
	color vi_color
	bool htf_label_show
	color htf_label_color
	string htf_label_size
	bool htf_timer_show
	color htf_timer_color
	string htf_timer_size
    color dow_color
    string dow_size

type CandleSet
	array<Candle> candles
	array<Imbalance> imbalances
	CandleSettings settings
	label tfNameTop
    label tfNameBottom
	label tfTimerTop
    label tfTimerBottom

type Helper
	string name = 'Helper'

Settings settings = Settings.new()

var CandleSettings SettingsHTF1 = CandleSettings.new()
var CandleSettings SettingsHTF2 = CandleSettings.new()
var CandleSettings SettingsHTF3 = CandleSettings.new()
var CandleSettings SettingsHTF4 = CandleSettings.new()
var CandleSettings SettingsHTF5 = CandleSettings.new()
var CandleSettings SettingsHTF6 = CandleSettings.new()

var array<Candle> candles_1 = array.new<Candle>(0)
var array<Candle> candles_2 = array.new<Candle>(0)
var array<Candle> candles_3 = array.new<Candle>(0)
var array<Candle> candles_4 = array.new<Candle>(0)
var array<Candle> candles_5 = array.new<Candle>(0)
var array<Candle> candles_6 = array.new<Candle>(0)

var array<Imbalance> imbalances_1 = array.new<Imbalance>()
var array<Imbalance> imbalances_2 = array.new<Imbalance>()
var array<Imbalance> imbalances_3 = array.new<Imbalance>()
var array<Imbalance> imbalances_4 = array.new<Imbalance>()
var array<Imbalance> imbalances_5 = array.new<Imbalance>()
var array<Imbalance> imbalances_6 = array.new<Imbalance>()

var CandleSet htf1 = CandleSet.new()
htf1.settings := SettingsHTF1
htf1.candles := candles_1
htf1.imbalances := imbalances_1

var CandleSet htf2 = CandleSet.new()
htf2.settings := SettingsHTF2
htf2.candles := candles_2
htf2.imbalances := imbalances_2

var CandleSet htf3 = CandleSet.new()
htf3.settings := SettingsHTF3
htf3.candles := candles_3
htf3.imbalances := imbalances_3

var CandleSet htf4 = CandleSet.new()
htf4.settings := SettingsHTF4
htf4.candles := candles_4
htf4.imbalances := imbalances_4

var CandleSet htf5 = CandleSet.new()
htf5.settings := SettingsHTF5
htf5.candles := candles_5
htf5.imbalances := imbalances_5

var CandleSet htf6 = CandleSet.new()
htf6.settings := SettingsHTF6
htf6.candles := candles_6
htf6.imbalances := imbalances_6

//+------------------------------------------------------------------------------------------------------------+//
//+--- Settings                                                                                             ---+//
//+------------------------------------------------------------------------------------------------------------+//

string group_style              = "Styling  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_label              = "Label Settings  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_imbalance          = "Imbalance  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_trace              = "Trace  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

htf1.settings.show              := input.bool(true, 'HTF 1      ', inline = 'htf1')
htf_1                           = input.timeframe('5', '', inline = 'htf1')
htf1.settings.htf := htf_1
htf1.settings.max_display       := input.int(10, '', inline = 'htf1')

htf2.settings.show              := input.bool(true, 'HTF 2      ', inline = 'htf2')
htf_2                           = input.timeframe('15', '', inline = 'htf2')
htf2.settings.htf := htf_2
htf2.settings.max_display       := input.int(10, '', inline = 'htf2')

htf3.settings.show              := input.bool(true, 'HTF 3      ', inline = 'htf3')
htf_3                           = input.timeframe('60', '', inline = 'htf3')
htf3.settings.htf := htf_3
htf3.settings.max_display       := input.int(10, '', inline = 'htf3')

htf4.settings.show              := input.bool(true, 'HTF 4      ', inline = 'htf4')
htf_4                           = input.timeframe('240', '', inline = 'htf4')
htf4.settings.htf               := htf_4
htf4.settings.max_display       := input.int(10, '', inline = 'htf4')

htf5.settings.show              := input.bool(true, 'HTF 5      ', inline = 'htf5')
htf_5                           = input.timeframe('1D', '', inline = 'htf5')
htf5.settings.htf := htf_5
htf5.settings.max_display       := input.int(10, '', inline = 'htf5')

htf6.settings.show              := input.bool(true, 'HTF 6      ', inline = 'htf6')
htf_6                           = input.timeframe('1W', '', inline = 'htf6')
htf6.settings.htf               := htf_6
htf6.settings.max_display       := input.int(10, '', inline = 'htf6')

settings.max_sets               := input.int(6, 'Limit to next HTFs only', minval = 1, maxval = 6)
settings.use_custom_daily       := input.bool(false, 'Custom daily candle open     ', inline='customdaily')
settings.custom_daily           := input.string('Midnight', '', options=['Midnight', '8:30', '9:30'], inline='customdaily')
settings.bull_body              := input.color(color.new(color.green, 10), 'Body  ', inline = 'body', group=group_style)
settings.bear_body              := input.color(color.new(color.red, 10), '', inline = 'body', group=group_style)
settings.bull_border            := input.color(color.new(color.black, 10), 'Borders', inline = 'borders', group=group_style)
settings.bear_border            := input.color(color.new(color.black, 10), '', inline = 'borders', group=group_style)
settings.bull_wick              := input.color(color.new(color.black, 10), 'Wick  ', inline = 'wick', group=group_style)
settings.bear_wick              := input.color(color.new(color.black, 10), '', inline = 'wick', group=group_style)

settings.offset                 := input.int(10, 'padding from current candles', minval = 1, group=group_style)
settings.buffer                 := input.int(1, 'space between candles', minval = 1, maxval = 4, group=group_style)
settings.htf_buffer             := input.int(10, 'space between Higher Timeframes', minval = 1, maxval = 10, group=group_style)
settings.width                  := input.int(1, 'Candle Width', minval = 1, maxval = 4, group=group_style) * 2

settings.htf_label_show         := input.bool(true, 'HTF Label           ', group=group_label, inline = 'HTFlabel')
settings.htf_label_color        := input.color(color.new(color.black, 10), '', group=group_label, inline = 'HTFlabel')
settings.htf_label_size         := input.string(size.large, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'HTFlabel')

settings.label_position         := input.string("Both", 'Label Positions', options=['Both', 'Top', 'Bottom'], group=group_label)
settings.label_alignment        := input.string("Align", "Label Alignment", options=['Align', 'Follow Candles'], group=group_label)

settings.htf_timer_show         := input.bool(true, 'Remaining time      ', inline = 'timer', group=group_label)
settings.htf_timer_color        := input.color(color.new(color.black, 10), '', inline = 'timer', group=group_label)
settings.htf_timer_size         := input.string(size.normal, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'timer')

settings.daily_name             := input.bool(false, 'Interval Value        ', group=group_label, inline = 'dow')
settings.dow_color              := input.color(color.black , '', group=group_label, inline = 'dow')
settings.dow_size               := input.string(size.small, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'dow')

settings.fvg_show               := input.bool(true, 'Fair Value Gap   ', group = group_imbalance, inline = 'fvg')
settings.fvg_color              := input.color(color.new(color.gray, 80), '', inline = 'fvg', group = group_imbalance)

settings.vi_show                := input.bool(true, 'Volume Imbalance', group = group_imbalance, inline = 'vi')
settings.vi_color               := input.color(color.new(color.red, 50), '', inline = 'vi', group = group_imbalance)

settings.trace_show             := input.bool(false, 'Trace lines', group = group_trace)
settings.trace_o_color          := input.color(color.new(color.gray, 50), 'Open    ', inline = '1', group = group_trace)
settings.trace_o_style          := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], inline = '1', group = group_trace)
settings.trace_o_size           := input.int(1, '', options = [1, 2, 3, 4], inline = '1', group = group_trace)
settings.trace_c_color          := input.color(color.new(color.gray, 50), 'Close    ', inline = '2', group = group_trace)
settings.trace_c_style          := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], inline = '2', group = group_trace)
settings.trace_c_size           := input.int(1, '', options = [1, 2, 3, 4], inline = '2', group = group_trace)
settings.trace_h_color          := input.color(color.new(color.gray, 50), 'High     ', inline = '3', group = group_trace)
settings.trace_h_style          := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], inline = '3', group = group_trace)
settings.trace_h_size           := input.int(1, '', options = [1, 2, 3, 4], inline = '3', group = group_trace)
settings.trace_l_color          := input.color(color.new(color.gray, 50), 'Low     ', inline = '4', group = group_trace)
settings.trace_l_style          := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], inline = '4', group = group_trace)
settings.trace_l_size           := input.int(1, '', options = [1, 2, 3, 4], inline = '4', group = group_trace)
settings.trace_anchor           := input.string('First Timeframe', 'Anchor to', options = ['First Timeframe', 'Last Timeframe'], group = group_trace)

settings.label_show             := input.bool(false, 'Price Label           ', inline = 'label')
settings.label_color            := input.color(color.new(color.black, 10), '', inline = 'label')
settings.label_size             := input.string(size.small, '', [size.tiny, size.small, size.normal, size.large, size.huge], inline = 'label')

//+------------------------------------------------------------------------------------------------------------+//
//+--- Variables                                                                                            ---+//
//+------------------------------------------------------------------------------------------------------------+//

Helper helper = Helper.new()
var Trace trace = Trace.new()
color color_transparent = #ffffff00

//+------------------------------------------------------------------------------------------------------------+//
//+--- Internal Functions                                                                                   ---+//
//+------------------------------------------------------------------------------------------------------------+//

method LineStyle(Helper helper, string style) =>
    helper.name := style
    out = switch style
        '----' => line.style_dashed
        '····' => line.style_dotted
        => line.style_solid
    out

method DayofWeek(Helper helper, int index) =>
    helper.name := 'DOW'
    switch
        index == 1 => 'M'
        index == 2 => 'T'
        index == 3 => 'W'
        index == 4 => 'T'
        index == 5 => 'F'
        index == 6 => 'S'
        index == 7 => 'S'
        na(index) => ''

method ValidTimeframe(Helper helper, string HTF) =>
    helper.name := HTF
    if timeframe.in_seconds(HTF) >= timeframe.in_seconds('D') and timeframe.in_seconds(HTF) > timeframe.in_seconds()
        true
    else
        n1 = timeframe.in_seconds()
        n2 = timeframe.in_seconds(HTF)
        n3 = n1 % n2
        n1 < n2 and math.round(n2 / n1) == n2 / n1


method RemainingTime(Helper helper, string HTF) =>
    helper.name := HTF
    if barstate.isrealtime
        timeRemaining = (time_close(HTF) - timenow) / 1000
        days = math.floor(timeRemaining / 86400)
        hours = math.floor((timeRemaining - days * 86400) / 3600)
        minutes = math.floor((timeRemaining - days * 86400 - hours * 3600) / 60)
        seconds = math.floor(timeRemaining - days * 86400 - hours * 3600 - minutes * 60)

        r = str.tostring(seconds, '00')
        if minutes > 0 or hours > 0 or days > 0
            r := str.tostring(minutes, '00') + ':' + r
            r
        if hours > 0 or days > 0
            r := str.tostring(hours, '00') + ':' + r
            r
        if days > 0
            r := str.tostring(days) + 'D ' + r
            r
        r
    else
        'n/a'

method HTFName(Helper helper, string HTF) =>
    helper.name := 'HTFName'
    formatted = HTF

    seconds = timeframe.in_seconds(HTF)
    if seconds < 60
        formatted := str.tostring(seconds) + 's'
        formatted
    else if seconds / 60 < 60
        formatted := str.tostring(seconds / 60) + 'm'
        formatted
    else if seconds / 60 / 60 < 24
        formatted := str.tostring(seconds / 60 / 60) + 'H'
        formatted
    formatted

method HTFEnabled(Helper helper) =>
    helper.name := 'HTFEnabled'
    int enabled = 0
    enabled := enabled + (htf1.settings.show ? 1 : 0)
    enabled := enabled + (htf2.settings.show ? 1 : 0)
    enabled := enabled + (htf3.settings.show ? 1 : 0)
    enabled := enabled + (htf4.settings.show ? 1 : 0)
    enabled := enabled + (htf5.settings.show ? 1 : 0)
    enabled := enabled + (htf6.settings.show ? 1 : 0)
    int last = math.min(enabled, settings.max_sets)

    last

method CandleSetHigh(Helper helper, array<Candle> candles, float h) =>
    helper.name := 'CandlesSetHigh'
    float _h = h
    if array.size(candles) > 0
        for i = 0 to array.size(candles) - 1 by 1
            Candle c = array.get(candles, i)
            if c.h > _h
                _h := c.h
                _h
    _h

method CandleSetLow(Helper helper, array<Candle> candles, float l) =>
    helper.name := 'CandlesSetLow'
    float _l = l
    if array.size(candles) > 0
        for i = 0 to array.size(candles) - 1 by 1
            Candle c = array.get(candles, i)
            if c.l < _l
                _l := c.l
                _l
    _l

method CandlesHigh(Helper helper, array<Candle> candles) =>
    helper.name := 'CandlesHigh'
    h = 0.0
    int cnt = 0
    int last = helper.HTFEnabled()

    if htf1.settings.show and helper.ValidTimeframe(htf1.settings.htf)
        h := helper.CandleSetHigh(htf1.candles, h)
        cnt := cnt + 1
    if htf2.settings.show and helper.ValidTimeframe(htf2.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf2.candles, h)
        cnt := cnt + 1
    if htf3.settings.show and helper.ValidTimeframe(htf3.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf3.candles, h)
        cnt := cnt + 1
    if htf4.settings.show and helper.ValidTimeframe(htf4.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf4.candles, h)
        cnt := cnt + 1
    if htf5.settings.show and helper.ValidTimeframe(htf5.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf5.candles, h)
        cnt := cnt + 1
    if htf6.settings.show and helper.ValidTimeframe(htf6.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf6.candles, h)

    if array.size(candles) > 0
        for i = 0 to array.size(candles) - 1 by 1
            Candle c = array.get(candles, i)
            if c.h > h
                h := c.h
    h

method CandlesLow(Helper helper, array<Candle> candles, float h) =>
    helper.name := 'CandlesLow'
    l = h
    int cnt = 0
    int last = helper.HTFEnabled()

    if htf1.settings.show and helper.ValidTimeframe(htf1.settings.htf)
        l := helper.CandleSetLow(htf1.candles, l)
        cnt := cnt + 1
    if htf2.settings.show and helper.ValidTimeframe(htf2.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf2.candles, l)
        cnt := cnt + 1
    if htf3.settings.show and helper.ValidTimeframe(htf3.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf3.candles, l)
        cnt := cnt + 1
    if htf4.settings.show and helper.ValidTimeframe(htf4.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf4.candles, l)
        cnt := cnt + 1
    if htf5.settings.show and helper.ValidTimeframe(htf5.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf5.candles, l)
        cnt := cnt + 1
    if htf6.settings.show and helper.ValidTimeframe(htf6.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf6.candles, l)

    if array.size(candles) > 0
        for i = 0 to array.size(candles) - 1 by 1
            Candle c = array.get(candles, i)
            if c.l < l
                l := c.l
    l

method UpdateTime(CandleSet candleSet, int offset) =>
    if settings.htf_timer_show and (barstate.isrealtime or barstate.islast)
        string tmr = '(' + helper.RemainingTime(candleSet.settings.htf) + ')'

        if not na(candleSet.tfTimerTop)
            candleSet.tfTimerTop.set_text(tmr)

        if not na(candleSet.tfTimerBottom)
            candleSet.tfTimerBottom.set_text(tmr)
    candleSet

method Reorder(CandleSet candleSet, int offset) =>
    size = candleSet.candles.size()

    if size > 0
        for i = size - 1 to 0 by 1
            Candle candle = candleSet.candles.get(i)
            t_buffer = offset + (settings.width + settings.buffer) * (size - i - 1)
            box.set_left(candle.body, bar_index + t_buffer)
            box.set_right(candle.body, bar_index + settings.width + t_buffer)
            line.set_x1(candle.wick_up, bar_index + settings.width / 2 + t_buffer)
            line.set_x2(candle.wick_up, bar_index + settings.width / 2 + t_buffer)
            line.set_x1(candle.wick_down, bar_index + settings.width / 2 + t_buffer)
            line.set_x2(candle.wick_down, bar_index + settings.width / 2 + t_buffer)

            if settings.daily_name //and candleSet.settings.htf == '1D'
                if not na(candle.dow_label)
                    candle.dow_label.set_y(candle.h)
                    candle.dow_label.set_x(bar_index + settings.width / 2 + t_buffer)
                    candle.dow_label.set_text(candle.dow)
                else
                    candle.dow_label := label.new(bar_index + settings.width / 2 + t_buffer, candle.h, candle.dow, color = color_transparent, textcolor = settings.dow_color, style = label.style_label_down, size = settings.dow_size)

    top = 0.0
    bottom = 0.0

    if settings.label_alignment == 'Align'
        top := helper.CandlesHigh(candleSet.candles)
        bottom := helper.CandlesLow(candleSet.candles, top)
    if settings.label_alignment == 'Follow Candles'
        top := helper.CandleSetHigh(candleSet.candles, 0)
        bottom := helper.CandleSetLow(candleSet.candles, top)

    left = bar_index + offset + (settings.width + settings.buffer) * (size - 1) / 2

    if settings.htf_label_show
        string lblt = helper.HTFName(candleSet.settings.htf)
        string lbll = lblt
        if settings.htf_timer_show
            lblt := lblt + '\n'
            lbll := '\n' + lbll
        if settings.daily_name
            lblt := lblt + '\n'

        string tmr = '(' + helper.RemainingTime(candleSet.settings.htf) + ')' + (settings.daily_name ? '\n' : '')
        if settings.label_position == 'Both' or settings.label_position == 'Top'
            
            if not na(candleSet.tfNameTop)
                candleSet.tfNameTop.set_xy(left, top)
            else
                candleSet.tfNameTop := label.new(left, top, lblt, color = color_transparent, textcolor = settings.htf_label_color, style = label.style_label_down, size = settings.htf_label_size)
            if settings.htf_timer_show
                if not na(candleSet.tfTimerTop)
                    candleSet.tfTimerTop.set_xy(left, top)
                else
                    candleSet.tfTimerTop := label.new(left, top, tmr, color = color_transparent, textcolor = settings.htf_timer_color, style = label.style_label_down, size = settings.htf_timer_size)

        if settings.label_position == 'Both' or settings.label_position == 'Bottom'
            if not na(candleSet.tfNameBottom)
                candleSet.tfNameBottom.set_xy(left, bottom)
            else
                candleSet.tfNameBottom := label.new(left, bottom, lbll, color = color_transparent, textcolor = settings.htf_label_color, style = label.style_label_up, size = settings.htf_label_size)
            if settings.htf_timer_show
                if settings.htf_timer_show
                    if not na(candleSet.tfTimerBottom)
                        candleSet.tfTimerBottom.set_xy(left, bottom)
                    else
                        candleSet.tfTimerBottom := label.new(left, bottom, tmr, color = color_transparent, textcolor = settings.htf_timer_color, style = label.style_label_up, size = settings.htf_timer_size)

    candleSet

method FindImbalance(CandleSet candleSet) =>
    if barstate.isrealtime or barstate.islast
        if candleSet.imbalances.size() > 0
            for i = candleSet.imbalances.size() - 1 to 0 by 1
                Imbalance del = candleSet.imbalances.get(i)
                box.delete(del.b)
                candleSet.imbalances.pop()

        if candleSet.candles.size() > 3 and settings.fvg_show
            for i = 0 to candleSet.candles.size() - 3 by 1
                candle1 = candleSet.candles.get(i)
                candle2 = candleSet.candles.get(i + 2)
                candle3 = candleSet.candles.get(i + 1)

                if candle1.l > candle2.h and math.min(candle1.o, candle1.c) > math.max(candle2.o, candle2.c)
                    Imbalance imb = Imbalance.new()
                    imb.b := box.new(box.get_left(candle2.body), candle2.h, box.get_right(candle1.body), candle1.l, bgcolor = settings.fvg_color, border_color = color_transparent, xloc = xloc.bar_index)
                    candleSet.imbalances.push(imb)
                if candle1.h < candle2.l and math.max(candle1.o, candle1.c) < math.min(candle2.o, candle2.c)
                    Imbalance imb = Imbalance.new()
                    imb.b := box.new(box.get_right(candle1.body), candle1.h, box.get_left(candle2.body), candle2.l, bgcolor = settings.fvg_color, border_color = color_transparent)
                    candleSet.imbalances.push(imb)
                box temp = box.copy(candle3.body)
                box.delete(candle3.body)
                candle3.body := temp
                candle3.body

        if candleSet.candles.size() > 2 and settings.vi_show
            for i = 0 to candleSet.candles.size() - 2 by 1
                candle1 = candleSet.candles.get(i)
                candle2 = candleSet.candles.get(i + 1)
                if candle1.l < candle2.h and math.min(candle1.o, candle1.c) > math.max(candle2.o, candle2.c)
                    Imbalance imb = Imbalance.new()
                    imb.b := box.new(box.get_left(candle2.body), math.min(candle1.o, candle1.c), box.get_right(candle1.body), math.max(candle2.o, candle2.c), bgcolor = settings.vi_color, border_color = color_transparent)
                    candleSet.imbalances.push(imb)
                if candle1.h > candle2.l and math.max(candle1.o, candle1.c) < math.min(candle2.o, candle2.c)
                    Imbalance imb = Imbalance.new()
                    imb.b := box.new(box.get_right(candle1.body), math.min(candle2.o, candle2.c), box.get_left(candle2.body), math.max(candle1.o, candle1.c), bgcolor = settings.vi_color, border_color = color_transparent)
                    candleSet.imbalances.push(imb)
    candleSet

method Monitor(CandleSet candleSet) =>
    HTFBarTime = time(candleSet.settings.htf, 'america/New_York')
    isNewHTFCandle = ta.change(HTFBarTime) > 0

    if settings.use_custom_daily
        int _830 = 0
        if isNewHTFCandle
            _830 := timestamp("America/New_York", year(time), month(time), dayofmonth(time), 0, 0) + 30600000
        if candleSet.settings.htf == '1D'
            if settings.custom_daily == 'Midnight'
                isNewHTFCandle := dayofweek(time, 'America/New_York') != dayofweek(time - (time - time[1]), 'America/New_York')
            if settings.custom_daily == '8:30'    
                // Get 8:30 AM New York time for today 
                isNewHTFCandle := not na(time(timeframe.period, "0830-0831:123456", 'America/New_York')) and na(time(timeframe.period, "0830-0831:123456", 'America/New_York')[1])
            if settings.custom_daily == '9:30'    
                // Get 9:30 AM New York time for today 
                isNewHTFCandle := not na(time(timeframe.period, "0930-0931:123456", 'America/New_York')) and na(time(timeframe.period, "0930-0931:123456", 'America/New_York')[1])
    if isNewHTFCandle
        Candle candle = Candle.new()
        candle.o := open
        candle.c := close
        candle.h := high
        candle.l := low
        candle.o_time := time
        candle.o_idx := bar_index
        candle.c_idx := bar_index
        candle.h_idx := bar_index
        candle.l_idx := bar_index
        candle.dow := switch
            candleSet.settings.htf == '1D' =>
                helper.DayofWeek(dayofweek(time_tradingday, "America/New_York"))
            str.tonumber(candleSet.settings.htf) < 60 =>
                str.format_time(candle.o_time, 'm', 'America/New_York')
            str.tonumber(candleSet.settings.htf) >= 60 =>
                str.format_time(candle.o_time, 'H', 'America/New_York')
            candleSet.settings.htf == '1M' =>
                str.format_time(candle.o_time, 'M', 'America/New_York')
            =>
                ''
        log.info('dow: {1} |{0}|', candle.dow, candleSet.settings.htf)
        bull = candle.c > candle.o

        candle.body := box.new(bar_index, math.max(candle.o, candle.c), bar_index + 2, math.min(candle.o, candle.c), bull ? settings.bull_border : settings.bear_border, 1, bgcolor = bull ? settings.bull_body : settings.bear_body)
        candle.wick_up := line.new(bar_index + 1, candle.h, bar_index, math.max(candle.o, candle.c), color = bull ? settings.bull_wick : settings.bear_wick)
        candle.wick_down := line.new(bar_index + 1, math.min(candle.o, candle.c), bar_index, candle.l, color = bull ? settings.bull_wick : settings.bear_wick)

        candleSet.candles.unshift(candle)

        if candleSet.candles.size() > candleSet.settings.max_display
            Candle delCandle = array.pop(candleSet.candles)
            box.delete(delCandle.body)
            line.delete(delCandle.wick_up)
            line.delete(delCandle.wick_down)
            delCandle.dow_label.delete()

    candleSet

method Update(CandleSet candleSet, int offset, bool showTrace) =>
    if candleSet.candles.size() > 0
        Candle candle = candleSet.candles.first()
        candle.h_idx := high > candle.h ? bar_index : candle.h_idx
        candle.h := high > candle.h ? high : candle.h
        candle.l_idx := low < candle.l ? bar_index : candle.l_idx
        candle.l := low < candle.l ? low : candle.l
        candle.c := close
        candle.c_idx := bar_index

        bull = candle.c > candle.o

        box.set_top(candle.body, candle.o)
        box.set_bottom(candle.body, candle.c)
        box.set_bgcolor(candle.body, bull ? settings.bull_body : settings.bear_body)
        box.set_border_color(candle.body, bull ? settings.bull_border : settings.bear_border)
        line.set_color(candle.wick_up, bull ? settings.bull_wick : settings.bear_wick)
        line.set_color(candle.wick_down, bull ? settings.bull_wick : settings.bear_wick)
        line.set_y1(candle.wick_up, candle.h)
        line.set_y2(candle.wick_up, math.max(candle.o, candle.c))
        line.set_y1(candle.wick_down, candle.l)
        line.set_y2(candle.wick_down, math.min(candle.o, candle.c))

        if barstate.isrealtime or barstate.islast
            candleSet.Reorder(offset)
            if settings.trace_show and showTrace
                if bar_index - candle.o_idx < 5000
                    if na(trace.o)
                        trace.o := line.new(candle.o_idx, candle.o, box.get_left(candle.body), candle.o, xloc = xloc.bar_index, color = settings.trace_o_color, style = helper.LineStyle(settings.trace_o_style), width = settings.trace_o_size)
                        trace.o
                    else
                        line.set_xy1(trace.o, candle.o_idx, candle.o)
                        line.set_xy2(trace.o, box.get_left(candle.body), candle.o)

                    if settings.label_show
                        if na(trace.o_l)
                            trace.o_l := label.new(box.get_right(candle.body), candle.o, str.tostring(candle.o), textalign = text.align_center, style = label.style_label_left, size = settings.label_size, color = color_transparent, textcolor = settings.label_color)
                            trace.o_l
                        else
                            label.set_xy(trace.o_l, box.get_right(candle.body), candle.o)
                            label.set_text(trace.o_l, str.tostring(candle.o))

                if bar_index - candle.c_idx < 5000
                    if na(trace.c)
                        trace.c := line.new(candle.c_idx, candle.c, box.get_left(candle.body), candle.c, xloc = xloc.bar_index, color = settings.trace_c_color, style = helper.LineStyle(settings.trace_c_style), width = settings.trace_c_size)
                        trace.c
                    else
                        line.set_xy1(trace.c, candle.c_idx, candle.c)
                        line.set_xy2(trace.c, box.get_left(candle.body), candle.c)

                    if settings.label_show
                        if na(trace.c_l)
                            trace.c_l := label.new(box.get_right(candle.body), candle.c, str.tostring(candle.c), textalign = text.align_center, style = label.style_label_left, size = settings.label_size, color = color_transparent, textcolor = settings.label_color)
                            trace.c_l
                        else
                            label.set_xy(trace.c_l, box.get_right(candle.body), candle.c)
                            label.set_text(trace.c_l, str.tostring(candle.c))

                if bar_index - candle.h_idx < 5000
                    if na(trace.h)
                        trace.h := line.new(candle.h_idx, candle.h, line.get_x1(candle.wick_up), candle.h, xloc = xloc.bar_index, color = settings.trace_h_color, style = helper.LineStyle(settings.trace_h_style), width = settings.trace_h_size)
                        trace.h
                    else
                        line.set_xy1(trace.h, candle.h_idx, candle.h)
                        line.set_xy2(trace.h, line.get_x1(candle.wick_up), candle.h)

                    if settings.label_show
                        if na(trace.h_l)
                            trace.h_l := label.new(box.get_right(candle.body), candle.h, str.tostring(candle.h), textalign = text.align_center, style = label.style_label_left, size = settings.label_size, color = color_transparent, textcolor = settings.label_color)
                            trace.h_l
                        else
                            label.set_xy(trace.h_l, box.get_right(candle.body), candle.h)
                            label.set_text(trace.h_l, str.tostring(candle.h))

                if bar_index - candle.l_idx < 5000
                    if na(trace.l)
                        trace.l := line.new(candle.l_idx, candle.l, line.get_x1(candle.wick_down), candle.l, xloc = xloc.bar_index, color = settings.trace_l_color, style = helper.LineStyle(settings.trace_l_style), width = settings.trace_l_size)
                        trace.l
                    else
                        line.set_xy1(trace.l, candle.l_idx, candle.l)
                        line.set_xy2(trace.l, line.get_x1(candle.wick_down), candle.l)

                    if settings.label_show
                        if na(trace.l_l)
                            trace.l_l := label.new(box.get_right(candle.body), candle.l, str.tostring(candle.l), textalign = text.align_center, style = label.style_label_left, size = settings.label_size, color = color_transparent, textcolor = settings.label_color)
                            trace.l_l
                        else
                            label.set_xy(trace.l_l, box.get_right(candle.body), candle.l)
                            label.set_text(trace.l_l, str.tostring(candle.l))
    candleSet

int cnt = 0
int last = helper.HTFEnabled()

int offset = settings.offset
if htf1.settings.show and helper.ValidTimeframe(htf1.settings.htf)
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe'
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe' and settings.max_sets == 1
        showTrace := true
        showTrace
    htf1.UpdateTime(offset)
    htf1.Monitor().Update(offset, showTrace).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf1.candles.size() * settings.width + (htf1.candles.size() > 0 ? (htf1.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf2.settings.show and helper.ValidTimeframe(htf2.settings.htf) and cnt < last
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe' and cnt == 0
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
        showTrace := true
        showTrace
    htf2.UpdateTime(offset)
    htf2.Monitor().Update(offset, showTrace).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf2.candles.size() * settings.width + (htf2.candles.size() > 0 ? (htf2.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf3.settings.show and helper.ValidTimeframe(htf3.settings.htf) and cnt < last
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe' and cnt == 0
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
        showTrace := true
        showTrace
    htf3.UpdateTime(offset)
    htf3.Monitor().Update(offset, showTrace).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf3.candles.size() * settings.width + (htf3.candles.size() > 0 ? (htf3.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf4.settings.show and helper.ValidTimeframe(htf4.settings.htf) and cnt < last
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe' and cnt == 0
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
        showTrace := true
        showTrace
    htf4.UpdateTime(offset)
    htf4.Monitor().Update(offset, showTrace).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf4.candles.size() * settings.width + (htf4.candles.size() > 0 ? (htf4.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf5.settings.show and helper.ValidTimeframe(htf5.settings.htf) and cnt < last
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe' and cnt == 0
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
        showTrace := true
        showTrace
    htf5.UpdateTime(offset)
    htf5.Monitor().Update(offset, showTrace).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf5.candles.size() * settings.width + (htf5.candles.size() > 0 ? (htf5.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf6.settings.show and helper.ValidTimeframe(htf6.settings.htf) and cnt < last
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe' and cnt == 0
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe'
        showTrace := true
        showTrace
    htf6.UpdateTime(offset)
    htf6.Monitor().Update(offset, showTrace).FindImbalance()
````
