# DTR & ATR & RVol

- url: https://www.tradingview.com/script/ubMwzCOz-DTR-ATR-RVol/
- type: indicator
- pine_id: PUB;4332628363fb43fc9a7ce535a92ddd4e
- version: 1.0

## Description

[b]DTR & ATR with Live Zones + Relative Volume[/b]

Combines two essential intraday tools in a single overlay indicator:

[b]DTR vs ATR [/b]— compares today's Daily Trading Range (actual high–low) against the Average True Range (ATR). Displayed as a percentage so you instantly see where the day stands relative to its historical average range. The info box turns green (< 70%), yellow (70–90%), or red (≥ 90%) to signal how extended the move already is.

[b]ATR Zone Lines & Boxes[/b] — draws horizontal lines and shaded zones at 100%, 150%, 200%, 250%, and 300% of the ATR, anchored to the session open. Lines update dynamically as price discovers the day's range, then lock in once the full ATR is covered. Fully customisable colours, thickness, and label styles per level.

[b]Relative Volume (RVol)[/b] — measures today's volume activity versus the N-day historical average. Two modes:

[list]
[*][b][Cumulative (default):[/b] total volume accumulated so far today (including pre-market and after-hours) divided by the N-day average full-day total. Grows throughout the session; values above 100% mean today is running above average volume.

[*][b]Pace:[/b] compares each individual bar's volume to the N-session EWMA for that same bar slot — a stable per-bar reading that is not distorted by the naturally high opening volume.
[/list]

[b]All inputs are fully configurable: [/b] ATR length and smoothing method (EMA/RMA/SMA/WMA), RVol lookback period and mode, session time and time zone, individual on/off toggles and colour pickers for every ATR level, and table position/size.
Based on the original "DTR & ATR with live zones" by Mereep01, extended with a time-consistent Relative Volume engine.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Mereep01

//@version=5
// DTR & ATR with Lines - Live ATR Calculation - Modified

indicator("DTR & ATR with live zones", "DTR ATR RVol", true)

//== INPUTS ==
string G1 = "Input Data"
atrLen = input.int(14, title="ATR Length", group=G1)
atrSmooth = input.string("RMA", title="Smoothing Type", options=["EMA", "RMA", "SMA", "WMA"], group=G1)
vol_len  = input.int   (20,     title="RVol Lookback (days)", group=G1)
rvolMode = input.string("Cumulative", title="RVol Mode", options=["Pace", "Cumulative"], group=G1, tooltip="Cumulative: total volume so far today vs N-day average full-day total. Grows throughout the day including pre/post market.\nPace: each bar's volume vs the N-session average for that same bar slot — stable reading that does not decline throughout the day.")

string G2 = "Display"
txt_sizeopt = input.string("auto", title="Text Size", options=["auto", "tiny", "small", "normal", "large", "huge"], group=G2, inline="10")
txt_size = txt_sizeopt == "auto" ? size.auto : txt_sizeopt == "tiny" ? size.tiny : txt_sizeopt == "small" ? size.small : txt_sizeopt == "normal" ? size.normal : txt_sizeopt == "large" ? size.large : size.huge
i_tableYpos = input.string("top", "Panel position", options=["top", "middle", "bottom"], group=G2, inline="11")
i_tableXpos = input.string("right", "", options=["left", "center", "right"], group=G2, inline="11")
show_header = input.bool(true, title="Show Table Header", group=G2, inline="12")
header_color = input.color(#ba68c8, "", group=G2, inline="12")

string G_Sess = "Session Settings"
sessionTime = input.session("0930-1600", "Market Session", group=G_Sess, tooltip="Set the time range for the lines to be drawn.")
timeZone = input.string("America/New_York", "Time Zone", group=G_Sess, tooltip="Set the time zone for the market session.")

string G3 = "ATR Zones"
showZones = input.bool(true, title="Show ATR Zones", group=G3, inline="zones")
boxcolourRange100 = input.color(color.new(color.gray, 85), title="100% Range", group=G3, inline="zones")
boxcolour150RangeUp = input.color(color.new(color.green, 92), title="150% Range (Upside)", group=G3, inline="zones_1")
boxcolour150RangeDown = input.color(color.new(color.red, 92), title="150% Range (Downside)", group=G3, inline="zones_1")
boxcolour200RangeUp = input.color(color.new(color.green, 90), title="200% Range (Upside)", group=G3, inline="zones_2")
boxcolour200RangeDown = input.color(color.new(color.red, 90), title="200% Range (Downside) ", group=G3, inline="zones_2")
boxcolour250RangeUp = input.color(color.new(color.green, 88), title="250% Range (Upside)", group=G3, inline="zones_3")
boxcolour250RangeDown = input.color(color.new(color.red, 88), title="250% Range (Downside) ", group=G3, inline="zones_3")
boxcolour300RangeUp = input.color(color.new(color.green, 86), title="300% Range (Upside)", group=G3, inline="zones_4")
boxcolour300RangeDown = input.color(color.new(color.red, 86), title="300% Range (Downside) ", group=G3, inline="zones_4")

//== NEW: INDIVIDUAL LEVEL SETTINGS ==
string G100 = "100% ATR Level"
showLines100 = input.bool(true, "Show Lines", group=G100, inline="100_1")
showLabels100 = input.bool(true, "Show Labels", group=G100, inline="100_1")
uppercolour100 = input.color(color.rgb(0, 255, 21), "Upper Colour", group=G100, inline="100_2")
lowercolour100 = input.color(color.rgb(255, 0, 0), "Lower Colour", group=G100, inline="100_2")
lineWidth100 = input.int(1, "Thickness", minval=1, group=G100, inline="100_3")
lineStyleInput100 = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group=G100, inline="100_3")

string G150 = "150% ATR Level"
showLines150 = input.bool(true, "Show Lines", group=G150, inline="150_1")
showLabels150 = input.bool(true, "Show Labels", group=G150, inline="150_1")
uppercolour150 = input.color(color.rgb(0, 255, 21), "Upper Colour", group=G150, inline="150_2")
lowercolour150 = input.color(color.rgb(255, 0, 0), "Lower Colour", group=G150, inline="150_2")
lineWidth150 = input.int(1, "Thickness", minval=1, group=G150, inline="150_3")
lineStyleInput150 = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group=G150, inline="150_3")

string G200 = "200% ATR Level"
showLines200 = input.bool(true, "Show Lines", group=G200, inline="200_1")
showLabels200 = input.bool(true, "Show Labels", group=G200, inline="200_1")
uppercolour200 = input.color(color.rgb(0, 255, 21), "Upper Colour", group=G200, inline="200_2")
lowercolour200 = input.color(color.rgb(255, 0, 0), "Lower Colour", group=G200, inline="200_2")
lineWidth200 = input.int(1, "Thickness", minval=1, group=G200, inline="200_3")
lineStyleInput200 = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group=G200, inline="200_3")

string G250 = "250% ATR Level"
showLines250 = input.bool(true, "Show Lines", group=G250, inline="250_1")
showLabels250 = input.bool(true, "Show Labels", group=G250, inline="250_1")
uppercolour250 = input.color(color.rgb(0, 255, 21), "Upper Colour", group=G250, inline="250_2")
lowercolour250 = input.color(color.rgb(255, 0, 0), "Lower Colour", group=G250, inline="250_2")
lineWidth250 = input.int(1, "Thickness", minval=1, group=G250, inline="250_3")
lineStyleInput250 = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group=G250, inline="250_3")

string G300 = "300% ATR Level"
showLines300 = input.bool(true, "Show Lines", group=G300, inline="300_1")
showLabels300 = input.bool(true, "Show Labels", group=G300, inline="300_1")
uppercolour300 = input.color(color.rgb(0, 255, 21), "Upper Colour", group=G300, inline="300_2")
lowercolour300 = input.color(color.rgb(255, 0, 0), "Lower Colour", group=G300, inline="300_2")
lineWidth300 = input.int(1, "Thickness", minval=1, group=G300, inline="300_3")
lineStyleInput300 = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group=G300, inline="300_3")

string G4 = "Global Label Settings"
labelTxtColour = input.color(color.new(color.white, 20), "Text", group=G4, inline="label1")
labelBgColour = input.color(color.new(color.black, 50), "Background", group=G4, inline="label1")
labelSizeInput = input.string("normal", "Font Size", options=["tiny", "small", "normal", "large", "huge"], group=G4)
labelStyleInput = input.string("Label Right", "Style", options=["None", "Label Right", "Label Left", "Label Up", "Label Down", "Arrow Up", "Arrow Down", "Circle", "Square", "Diamond"], group=G4)
// MOD: Added new input to control price visibility on labels
showPriceOnLabel = input.bool(true, "Show Price", group=G4, inline="label2")

//== HELPER FUNCTIONS (REWRITTEN) ==
f_get_line_style(style_str) =>
    switch style_str
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_get_label_size(size_str) =>
    switch size_str
        "tiny" => size.tiny
        "small" => size.small
        "large" => size.large
        "huge" => size.huge
        => size.normal

f_get_label_style(style_str) =>
    switch style_str
        "None" => label.style_none
        "Label Left" => label.style_label_left
        "Label Up" => label.style_label_up
        "Label Down" => label.style_label_down
        "Arrow Up" => label.style_arrowup
        "Arrow Down" => label.style_arrowdown
        "Circle" => label.style_circle
        "Square" => label.style_square
        "Diamond" => label.style_diamond
        => label.style_label_right

f_getTablePosition(y, x) =>
    switch y
        "top" =>
            switch x
                "left" => position.top_left
                "center" => position.top_center
                => position.top_right
        "middle" =>
            switch x
                "left" => position.middle_left
                "center" => position.middle_center
                => position.middle_right
        => // bottom
            switch x
                "left" => position.bottom_left
                "center" => position.bottom_center
                => position.bottom_right

// MOD: Added new helper function to generate the label text
f_get_label_text(baseText, priceValue, showPrice) =>
    showPrice ? baseText + " " + str.tostring(priceValue, format.mintick) : baseText

//== TABLE SETUP ==
var table dtrDisplay = table.new(f_getTablePosition(i_tableYpos, i_tableXpos), 2, 2, border_width = 1, border_color=color.new(color.white, 50))

//== CALCULATIONS ==
timeFrame = timeframe.isweekly ? "W" : timeframe.ismonthly ? "M" : "D"
avg_atr = request.security(syminfo.tickerid, timeFrame, (atrSmooth == "EMA" ? ta.ema(ta.tr, atrLen) : atrSmooth == "RMA" ? ta.rma(ta.tr, atrLen) : atrSmooth == "SMA" ? ta.sma(ta.tr, atrLen) : ta.wma(ta.tr, atrLen)), lookahead = barmerge.lookahead_on)
daily_range_table = request.security(syminfo.tickerid, "D", high - low, lookahead = barmerge.lookahead_on)
dtrpct = avg_atr > 0 ? math.round((daily_range_table / avg_atr) * 100) : 0

//== RVOL CALCULATION ==
// PACE      -> per-bar relative volume.
//              Each bar is compared to the N-session EWMA of volume at that SAME
//              bar slot (same position from session open).  No elapsed-time division,
//              so the open does not blow up.  Answers: "is THIS bar hot or cold?"
//
// CUMULATIVE -> all-day volume (pre + regular + post) / N-day avg full-day total.
//              Keeps building after 16:00; no feed-unit mismatch.

bool rv_in_session = not na(time(timeframe.period, sessionTime, timeZone))
bool rv_sess_start = rv_in_session and not rv_in_session[1]
int  rv_date       = year(time, timeZone) * 10000 + month(time, timeZone) * 100 + dayofmonth(time, timeZone)

var int          rv_last_date = 0
var int          rv_bar_idx   = 0         // 0-based bar slot within current session
var float        rv_cum_day   = 0.0       // all-bar daily accumulator (Cumulative)
var array<float> rv_hist_day  = array.new_float()
var array<float> rv_bar_ema   = array.new_float(1000, na)  // per-slot EWMA (Pace)
float rv_ema_alpha = 2.0 / float(vol_len + 1)

// All-day accumulator (Cumulative mode)
if rv_date != rv_last_date
    if rv_last_date != 0
        array.push(rv_hist_day, rv_cum_day)
        if array.size(rv_hist_day) > vol_len
            array.shift(rv_hist_day)
    rv_cum_day   := volume
    rv_last_date := rv_date
else
    rv_cum_day += volume

// Session bar-position counter (Pace mode)
if rv_sess_start
    rv_bar_idx := 0
else if rv_in_session
    rv_bar_idx += 1

// Read historical EWMA for this slot BEFORE updating (pure historical denominator)
float rv_slot_expected = (rv_in_session and rv_bar_idx < 1000) ? array.get(rv_bar_ema, rv_bar_idx) : na

// Update EWMA only when bar is confirmed (prevents re-evaluation distortion on live bar)
if barstate.isconfirmed and rv_in_session and rv_bar_idx < 1000
    float old_ema = array.get(rv_bar_ema, rv_bar_idx)
    array.set(rv_bar_ema, rv_bar_idx, na(old_ema) ? volume : old_ema * (1.0 - rv_ema_alpha) + volume * rv_ema_alpha)

float rv_avg_day = array.size(rv_hist_day) > 0 ? array.avg(rv_hist_day) : na

float raw_pace = not na(rv_slot_expected) and rv_slot_expected > 0.0 ? volume / rv_slot_expected : 0.0
float raw_cum  = not na(rv_avg_day)       and rv_avg_day       > 0.0 ? rv_cum_day / rv_avg_day  : 0.0
volpct = rvolMode == "Pace" ? math.round(raw_pace * 100) : math.round(raw_cum * 100)

//== TABLE DISPLAY ==
if barstate.islast
    final_text = "DTR: " + str.tostring(daily_range_table, "#.##") + " vs ATR: " + str.tostring(avg_atr, "#.##") + "  =>  " + str.tostring(dtrpct) + "%"
    rvol_arrow = volpct > 100 ? "▲ " : volpct < 100 ? "▼ " : "► "
    rvol_text  = rvol_arrow + str.tostring(volpct) + "%"
    colour_atr = dtrpct <= 70 ? color.new(color.green, 0) : dtrpct >= 90 ? color.rgb(215, 133, 133) : color.new(#ffd500, 5)
    if show_header
        table.cell(dtrDisplay, 0, 0, "DTR vs ATR", bgcolor=header_color, text_color=color.white, text_size=txt_size)
        table.cell(dtrDisplay, 1, 0, "RVol",       bgcolor=header_color, text_color=color.white, text_size=txt_size)
        table.cell(dtrDisplay, 0, 1, final_text,   bgcolor=colour_atr,   text_size=txt_size)
        table.cell(dtrDisplay, 1, 1, rvol_text,    bgcolor=colour_atr,   text_size=txt_size)
    else
        table.cell(dtrDisplay, 0, 0, final_text, bgcolor=colour_atr, text_size=txt_size)
        table.cell(dtrDisplay, 1, 0, rvol_text,  bgcolor=colour_atr, text_size=txt_size)

//== EFFICIENT PLOTTING CONSTANTS ==
label_size_const = f_get_label_size(labelSizeInput)
label_style_const = f_get_label_style(labelStyleInput)

//== ATR LINE & ZONE PLOTTING ==
// State management variables
var line upperAtrLine = na
var line lowerAtrLine = na
var box Range100ZoneBox = na
var label upperAtrLabel = na
var label lowerAtrLabel = na

var line upperAtrLine150 = na
var line lowerAtrLine150 = na
var label upperAtrLabel150 = na
var label lowerAtrLabel150 = na
var box upperZoneBox150 = na
var box lowerZoneBox150 = na

var line upperAtrLine200 = na
var line lowerAtrLine200 = na
var label upperAtrLabel200 = na
var label lowerAtrLabel200 = na
var box upperZoneBox200 = na
var box lowerZoneBox200 = na

var line upperAtrLine250 = na
var line lowerAtrLine250 = na
var label upperAtrLabel250 = na
var label lowerAtrLabel250 = na
var box upperZoneBox250 = na
var box lowerZoneBox250 = na

var line upperAtrLine300 = na
var line lowerAtrLine300 = na
var label upperAtrLabel300 = na
var label lowerAtrLabel300 = na
var box upperZoneBox300 = na
var box lowerZoneBox300 = na

var bool levelsLocked = false
var float lockedUpperLevel = na
var float lockedLowerLevel = na
var int dayHighTimestamp = na
var int dayLowTimestamp = na
var float sessionHigh = na
var float sessionLow = na

inSession = not na(time(timeframe.period, sessionTime, timeZone))
isFirstBarOfSession = inSession and not inSession[1]
bool shouldPlotLines = showLines100 or showLines150 or showLines200 or showLines250 or showLines300

if isFirstBarOfSession
    levelsLocked := false
    lockedUpperLevel := na
    lockedLowerLevel := na
    sessionHigh := high
    sessionLow := low
    dayHighTimestamp := time
    dayLowTimestamp := time

if (shouldPlotLines or showZones) and timeframe.isintraday and inSession
    if not isFirstBarOfSession
        if high > sessionHigh
            sessionHigh := high
            dayHighTimestamp := time
        if low < sessionLow
            sessionLow := low
            dayLowTimestamp := time

    dtr = sessionHigh - sessionLow
    difference = math.max(0, avg_atr - dtr)
    dynamicUpperLevel = sessionHigh + difference
    dynamicLowerLevel = sessionLow - difference

    if not levelsLocked and dtr >= avg_atr
        levelsLocked := true
        if dayHighTimestamp > dayLowTimestamp
            lockedUpperLevel := sessionLow + avg_atr
            lockedLowerLevel := sessionLow
        else
            lockedUpperLevel := sessionHigh
            lockedLowerLevel := sessionHigh - avg_atr

    finalUpperLevel = levelsLocked ? lockedUpperLevel : dynamicUpperLevel
    finalLowerLevel = levelsLocked ? lockedLowerLevel : dynamicLowerLevel

    if isFirstBarOfSession
        // Delete previous session's objects
        if not na(upperAtrLine[1])
            line.delete(upperAtrLine[1])
            line.delete(lowerAtrLine[1])
            label.delete(upperAtrLabel[1])
            label.delete(lowerAtrLabel[1])
            line.delete(upperAtrLine150[1])
            line.delete(lowerAtrLine150[1])
            label.delete(upperAtrLabel150[1])
            label.delete(lowerAtrLabel150[1])
            line.delete(upperAtrLine200[1])
            line.delete(lowerAtrLine200[1])
            label.delete(upperAtrLabel200[1])
            label.delete(lowerAtrLabel200[1])
            line.delete(upperAtrLine250[1])
            line.delete(lowerAtrLine250[1])
            label.delete(upperAtrLabel250[1])
            label.delete(lowerAtrLabel250[1])
            line.delete(upperAtrLine300[1])
            line.delete(lowerAtrLine300[1])
            label.delete(upperAtrLabel300[1])
            label.delete(lowerAtrLabel300[1])
            box.delete(Range100ZoneBox[1])
            box.delete(upperZoneBox150[1])
            box.delete(lowerZoneBox150[1])
            box.delete(upperZoneBox200[1])
            box.delete(lowerZoneBox200[1])
            box.delete(upperZoneBox250[1])
            box.delete(lowerZoneBox250[1])
            box.delete(upperZoneBox300[1])
            box.delete(lowerZoneBox300[1])

        str_split = str.split(sessionTime, "-")
        closeHour = str.tonumber(str.substring(str_split.get(1), 0, 2))
        closeMinute = str.tonumber(str.substring(str_split.get(1), 2, 4))
        sessionCloseTime = timestamp(timeZone, year, month, dayofmonth, int(closeHour), int(closeMinute), 0)

        if showLines100
            style100 = f_get_line_style(lineStyleInput100)
            upperAtrLine := line.new(time, finalUpperLevel, sessionCloseTime, finalUpperLevel, xloc=xloc.bar_time, color=uppercolour100, width=lineWidth100, style=style100)
            lowerAtrLine := line.new(time, finalLowerLevel, sessionCloseTime, finalLowerLevel, xloc=xloc.bar_time, color=lowercolour100, width=lineWidth100, style=style100)
            if showLabels100
                // MOD: Use helper function for label text
                upperAtrLabel := label.new(sessionCloseTime, finalUpperLevel, f_get_label_text("100% ATR", finalUpperLevel, showPriceOnLabel), xloc=xloc.bar_time, color=labelBgColour, style=label_style_const, textcolor=labelTxtColour, size=label_size_const)
                lowerAtrLabel := label.new(sessionCloseTime, finalLowerLevel, f_get_label_text("100% ATR", finalLowerLevel, showPriceOnLabel), xloc=xloc.bar_time, color=labelBgColour, style=label_style_const, textcolor=labelTxtColour, size=label_size_const)

        if showLines150
            style150 = f_get_line_style(lineStyleInput150)
            upperAtrLine150 := line.new(time, finalUpperLevel + avg_atr * 0.5, sessionCloseTime, finalUpperLevel + avg_atr * 0.5, xloc=xloc.bar_time, color=uppercolour150, width=lineWidth150, style=style150)
            lowerAtrLine150 := line.new(time, finalLowerLevel - avg_atr * 0.5, sessionCloseTime, finalLowerLevel - avg_atr * 0.5, xloc=xloc.bar_time, color=lowercolour150, width=lineWidth150, style=style150)
            if showLabels150
                // MOD: Use helper function for label text
                upperAtrLabel150 := label.new(sessionCloseTime, finalUpperLevel + avg_atr * 0.5, f_get_label_text("150% ATR", finalUpperLevel + avg_atr * 0.5, showPriceOnLabel), xloc=xloc.bar_time, color=labelBgColour, style=label_style_const, textcolor=labelTxtColour, size=label_size_const)
                lowerAtrLabel150 := label.new(sessionCloseTime, finalLowerLevel - avg_atr * 0.5, f_get_label_text("150% ATR", finalLowerLevel - avg_atr * 0.5, showPriceOnLabel), xloc=xloc.bar_time, color=labelBgColour, style=label_style_const, textcolor=labelTxtColour, size=label_size_const)

        if showLines200
            style200 = f_get_line_style(lineStyleInput200)
            upperAtrLine200 := line.new(time, finalUpperLevel + avg_atr, sessionCloseTime, finalUpperLevel + avg_atr, xloc=xloc.bar_time, color=uppercolour200, width=lineWidth200, style=style200)
            lowerAtrLine200 := line.new(time, finalLowerLevel - avg_atr, sessionCloseTime, finalLowerLevel - avg_atr, xloc=xloc.bar_time, color=lowercolour200, width=lineWidth200, style=style200)
            if showLabels200
                // MOD: Use helper function for label text
                upperAtrLabel200 := label.new(sessionCloseTime, finalUpperLevel + avg_atr, f_get_label_text("200% ATR", finalUpperLevel + avg_atr, showPriceOnLabel), xloc=xloc.bar_time, color=labelBgColour, style=label_style_const, textcolor=labelTxtColour, size=label_size_const)
                lowerAtrLabel200 := label.new(sessionCloseTime, finalLowerLevel - avg_atr, f_get_label_text("200% ATR", finalLowerLevel - avg_atr, showPriceOnLabel), xloc=xloc.bar_time, color=labelBgColour, style=label_style_const, textcolor=labelTxtColour, size=label_size_const)

        if showLines250
            style250 = f_get_line_style(lineStyleInput250)
            upperAtrLine250 := line.new(time, finalUpperLevel + avg_atr * 1.5, sessionCloseTime, finalUpperLevel + avg_atr * 1.5, xloc=xloc.bar_time, color=uppercolour250, width=lineWidth250, style=style250)
            lowerAtrLine250 := line.new(time, finalLowerLevel - avg_atr * 1.5, sessionCloseTime, finalLowerLevel - avg_atr * 1.5, xloc=xloc.bar_time, color=lowercolour250, width=lineWidth250, style=style250)
            if showLabels250
                // MOD: Use helper function for label text
                upperAtrLabel250 := label.new(sessionCloseTime, finalUpperLevel + avg_atr * 1.5, f_get_label_text("250% ATR", finalUpperLevel + avg_atr * 1.5, showPriceOnLabel), xloc=xloc.bar_time, color=labelBgColour, style=label_style_const, textcolor=labelTxtColour, size=label_size_const)
                lowerAtrLabel250 := label.new(sessionCloseTime, finalLowerLevel - avg_atr * 1.5, f_get_label_text("250% ATR", finalLowerLevel - avg_atr * 1.5, showPriceOnLabel), xloc=xloc.bar_time, color=labelBgColour, style=label_style_const, textcolor=labelTxtColour, size=label_size_const)

        if showLines300
            style300 = f_get_line_style(lineStyleInput300)
            upperAtrLine300 := line.new(time, finalUpperLevel + avg_atr * 2.0, sessionCloseTime, finalUpperLevel + avg_atr * 2.0, xloc=xloc.bar_time, color=uppercolour300, width=lineWidth300, style=style300)
            lowerAtrLine300 := line.new(time, finalLowerLevel - avg_atr * 2.0, sessionCloseTime, finalLowerLevel - avg_atr * 2.0, xloc=xloc.bar_time, color=lowercolour300, width=lineWidth300, style=style300)
            if showLabels300
                // MOD: Use helper function for label text
                upperAtrLabel300 := label.new(sessionCloseTime, finalUpperLevel + avg_atr * 2.0, f_get_label_text("300% ATR", finalUpperLevel + avg_atr * 2.0, showPriceOnLabel), xloc=xloc.bar_time, color=labelBgColour, style=label_style_const, textcolor=labelTxtColour, size=label_size_const)
                lowerAtrLabel300 := label.new(sessionCloseTime, finalLowerLevel - avg_atr * 2.0, f_get_label_text("300% ATR", finalLowerLevel - avg_atr * 2.0, showPriceOnLabel), xloc=xloc.bar_time, color=labelBgColour, style=label_style_const, textcolor=labelTxtColour, size=label_size_const)

        if showZones
            Range100ZoneBox := box.new(time, finalUpperLevel, sessionCloseTime, finalLowerLevel, xloc=xloc.bar_time, bgcolor=boxcolourRange100, border_color=na)
            upperZoneBox150 := box.new(time, finalUpperLevel + avg_atr * 0.5, sessionCloseTime, finalUpperLevel, xloc=xloc.bar_time, bgcolor=boxcolour150RangeUp, border_color=na)
            lowerZoneBox150 := box.new(time, finalLowerLevel, sessionCloseTime, finalLowerLevel - avg_atr * 0.5, xloc=xloc.bar_time, bgcolor=boxcolour150RangeDown, border_color=na)
            upperZoneBox200 := box.new(time, finalUpperLevel + avg_atr, sessionCloseTime, finalUpperLevel + avg_atr * 0.5, xloc=xloc.bar_time, bgcolor=boxcolour200RangeUp, border_color=na)
            lowerZoneBox200 := box.new(time, finalLowerLevel - avg_atr * 0.5, sessionCloseTime, finalLowerLevel - avg_atr, xloc=xloc.bar_time, bgcolor=boxcolour200RangeDown, border_color=na)
            upperZoneBox250 := box.new(time, finalUpperLevel + avg_atr * 1.5, sessionCloseTime, finalUpperLevel + avg_atr, xloc=xloc.bar_time, bgcolor=boxcolour250RangeUp, border_color=na)
            lowerZoneBox250 := box.new(time, finalLowerLevel - avg_atr, sessionCloseTime, finalLowerLevel - avg_atr * 1.5, xloc=xloc.bar_time, bgcolor=boxcolour250RangeDown, border_color=na)
            upperZoneBox300 := box.new(time, finalUpperLevel + avg_atr * 2.0, sessionCloseTime, finalUpperLevel + avg_atr * 1.5, xloc=xloc.bar_time, bgcolor=boxcolour300RangeUp, border_color=na)
            lowerZoneBox300 := box.new(time, finalLowerLevel - avg_atr * 1.5, sessionCloseTime, finalLowerLevel - avg_atr * 2.0, xloc=xloc.bar_time, bgcolor=boxcolour300RangeDown, border_color=na)

    else // For subsequent bars in the session, update the levels
        if showLines100
            line.set_y1(upperAtrLine, finalUpperLevel)
            line.set_y2(upperAtrLine, finalUpperLevel)
            line.set_y1(lowerAtrLine, finalLowerLevel)
            line.set_y2(lowerAtrLine, finalLowerLevel)
            if showLabels100
                label.set_y(upperAtrLabel, finalUpperLevel)
                label.set_y(lowerAtrLabel, finalLowerLevel)
                // MOD: Update label text if price is shown
                if showPriceOnLabel
                    label.set_text(upperAtrLabel, f_get_label_text("100% ATR", finalUpperLevel, true))
                    label.set_text(lowerAtrLabel, f_get_label_text("100% ATR", finalLowerLevel, true))

        if showLines150
            line.set_y1(upperAtrLine150, finalUpperLevel + avg_atr * 0.5)
            line.set_y2(upperAtrLine150, finalUpperLevel + avg_atr * 0.5)
            line.set_y1(lowerAtrLine150, finalLowerLevel - avg_atr * 0.5)
            line.set_y2(lowerAtrLine150, finalLowerLevel - avg_atr * 0.5)
            if showLabels150
                label.set_y(upperAtrLabel150, finalUpperLevel + avg_atr * 0.5)
                label.set_y(lowerAtrLabel150, finalLowerLevel - avg_atr * 0.5)
                // MOD: Update label text if price is shown
                if showPriceOnLabel
                    label.set_text(upperAtrLabel150, f_get_label_text("150% ATR", finalUpperLevel + avg_atr * 0.5, true))
                    label.set_text(lowerAtrLabel150, f_get_label_text("150% ATR", finalLowerLevel - avg_atr * 0.5, true))

        if showLines200
            line.set_y1(upperAtrLine200, finalUpperLevel + avg_atr)
            line.set_y2(upperAtrLine200, finalUpperLevel + avg_atr)
            line.set_y1(lowerAtrLine200, finalLowerLevel - avg_atr)
            line.set_y2(lowerAtrLine200, finalLowerLevel - avg_atr)
            if showLabels200
                label.set_y(upperAtrLabel200, finalUpperLevel + avg_atr)
                label.set_y(lowerAtrLabel200, finalLowerLevel - avg_atr)
                // MOD: Update label text if price is shown
                if showPriceOnLabel
                    label.set_text(upperAtrLabel200, f_get_label_text("200% ATR", finalUpperLevel + avg_atr, true))
                    label.set_text(lowerAtrLabel200, f_get_label_text("200% ATR", finalLowerLevel - avg_atr, true))

        if showLines250
            line.set_y1(upperAtrLine250, finalUpperLevel + avg_atr * 1.5)
            line.set_y2(upperAtrLine250, finalUpperLevel + avg_atr * 1.5)
            line.set_y1(lowerAtrLine250, finalLowerLevel - avg_atr * 1.5)
            line.set_y2(lowerAtrLine250, finalLowerLevel - avg_atr * 1.5)
            if showLabels250
                label.set_y(upperAtrLabel250, finalUpperLevel + avg_atr * 1.5)
                label.set_y(lowerAtrLabel250, finalLowerLevel - avg_atr * 1.5)
                // MOD: Update label text if price is shown
                if showPriceOnLabel
                    label.set_text(upperAtrLabel250, f_get_label_text("250% ATR", finalUpperLevel + avg_atr * 1.5, true))
                    label.set_text(lowerAtrLabel250, f_get_label_text("250% ATR", finalLowerLevel - avg_atr * 1.5, true))

        if showLines300
            line.set_y1(upperAtrLine300, finalUpperLevel + avg_atr * 2.0)
            line.set_y2(upperAtrLine300, finalUpperLevel + avg_atr * 2.0)
            line.set_y1(lowerAtrLine300, finalLowerLevel - avg_atr * 2.0)
            line.set_y2(lowerAtrLine300, finalLowerLevel - avg_atr * 2.0)
            if showLabels300
                label.set_y(upperAtrLabel300, finalUpperLevel + avg_atr * 2.0)
                label.set_y(lowerAtrLabel300, finalLowerLevel - avg_atr * 2.0)
                // MOD: Update label text if price is shown
                if showPriceOnLabel
                    label.set_text(upperAtrLabel300, f_get_label_text("300% ATR", finalUpperLevel + avg_atr * 2.0, true))
                    label.set_text(lowerAtrLabel300, f_get_label_text("300% ATR", finalLowerLevel - avg_atr * 2.0, true))

        if showZones
            box.set_top(Range100ZoneBox, finalUpperLevel)
            box.set_bottom(Range100ZoneBox, finalLowerLevel)
            box.set_top(upperZoneBox150, finalUpperLevel + avg_atr * 0.5)
            box.set_bottom(upperZoneBox150, finalUpperLevel)
            box.set_top(lowerZoneBox150, finalLowerLevel)
            box.set_bottom(lowerZoneBox150, finalLowerLevel - avg_atr * 0.5)
            box.set_top(upperZoneBox200, finalUpperLevel + avg_atr)
            box.set_bottom(upperZoneBox200, finalUpperLevel + avg_atr * 0.5)
            box.set_top(lowerZoneBox200, finalLowerLevel - avg_atr * 0.5)
            box.set_bottom(lowerZoneBox200, finalLowerLevel - avg_atr)
            box.set_top(upperZoneBox250, finalUpperLevel + avg_atr * 1.5)
            box.set_bottom(upperZoneBox250, finalUpperLevel + avg_atr)
            box.set_top(lowerZoneBox250, finalLowerLevel - avg_atr)
            box.set_bottom(lowerZoneBox250, finalLowerLevel - avg_atr * 1.5)
            box.set_top(upperZoneBox300, finalUpperLevel + avg_atr * 2.0)
            box.set_bottom(upperZoneBox300, finalUpperLevel + avg_atr * 1.5)
            box.set_top(lowerZoneBox300, finalLowerLevel - avg_atr * 1.5)
            box.set_bottom(lowerZoneBox300, finalLowerLevel - avg_atr * 2.0)
````
