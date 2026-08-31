<!-- tradingview-pine-id: PUB;00cc06998d4745d1a09d2366ef8bf11e -->
<!-- tradingviewscripts-format: 1 -->
# Pipstorm & Sessions

Source: https://www.tradingview.com/script/fUJBaOcX-Pipstorm-Sessions/

## Description

This indicator is designed to help traders identify the behavior of price during the major forex trading sessions: Asian, London, New York AM, and New York PM.
It automatically highlights each trading session on the chart, making it easy to analyze session ranges, volatility, and market structure.
Key Features
Automatically marks Asian, London, NY AM, and NY PM sessions.
Displays each session's trading range with colored boxes.
Helps identify session highs and lows.
Useful for spotting liquidity grabs, breakouts, and reversals.
Supports Smart Money Concepts (SMC), ICT, and price action trading strategies.
Clean and simple visual layout for better chart analysis.
How It Can Be Used
Trade London breakouts after the Asian session.
Identify New York reversals and continuation setups.
Monitor liquidity above session highs and below session lows.
Improve entry and exit timing using session-based market behavior.
Suitable for Gold (XAU/USD), Forex pairs, and major indices.
Best Timeframes
Works effectively on M5, M15, M30, and H1 charts.
Disclaimer
This indicator is an analytical tool and should be used alongside proper risk management and market confirmation. It does not guarantee profitable trades.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// © 

//@version=6
indicator(
     title = "Pipstorm & Sessions",
     shorttitle = "Pipstorm KillZones & Sessions",
     overlay = true,
     max_boxes_count = 500,
     max_lines_count = 200,
     max_labels_count = 100,
     max_bars_back = 5000
)

bgcolor(na)

// ============================================================================
// GLOBAL SETTINGS
// ============================================================================

ShowMoreInfo  = input.bool(false, 'Show More Info', inline = 'More', group = 'Global Setting', display = display.none)
ColorMoreInfo = input.color(#0c3299, '', inline = 'More', group = 'Global Setting', display = display.none)

KillZoneOpacity = input.int(85, "Kill Zone Fill Opacity", minval = 0, maxval = 100, group = "Global Setting", display = display.none)
KillZoneBorderOpacity = input.int(50, "Kill Zone Border Opacity", minval = 0, maxval = 100, group = "Global Setting", display = display.none)

TimezoneDisplay = input.string(
     "India (IST) — GMT+05:30",
     "Timezone",
     options = [
         "Baker Island — GMT-12:00",
         "American Samoa / Niue — GMT-11:00",
         "Hawaii — GMT-10:00",
         "Marquesas Islands — GMT-09:30",
         "Alaska — GMT-09:00",
         "Pacific Time (US/Canada) — GMT-08:00",
         "Mountain Time (US/Canada) — GMT-07:00",
         "Central Time (US/Canada/Mexico) — GMT-06:00",
         "Eastern Time (US/Canada) — GMT-05:00",
         "Atlantic Time / Venezuela / Chile — GMT-04:00",
         "Newfoundland — GMT-03:30",
         "Argentina / Brazil — GMT-03:00",
         "South Georgia — GMT-02:00",
         "Azores / Cabo Verde — GMT-01:00",
         "London / Iceland — GMT+00:00",
         "Central Europe — GMT+01:00",
         "Eastern Europe / South Africa — GMT+02:00",
         "Moscow / Saudi Arabia — GMT+03:00",
         "Iran — GMT+03:30",
         "Dubai (GST) — GMT+04:00",
         "Afghanistan — GMT+04:30",
         "Pakistan — GMT+05:00",
         "India (IST) — GMT+05:30",
         "Nepal — GMT+05:45",
         "Bangladesh / Bhutan — GMT+06:00",
         "Myanmar — GMT+06:30",
         "Thailand / Vietnam — GMT+07:00",
         "Singapore / China — GMT+08:00",
         "Eucla — GMT+08:45",
         "Japan (JST) / Korea — GMT+09:00",
         "Australia Central — GMT+09:30",
         "Australia Eastern — GMT+10:00",
         "Lord Howe Island — GMT+10:30",
         "Solomon Islands — GMT+11:00",
         "New Zealand — GMT+12:00",
         "Chatham Islands — GMT+12:45",
         "Tonga / Samoa — GMT+13:00",
         "Line Islands — GMT+14:00"
     ],
     group = "Global Setting"
)

Timezone =
     TimezoneDisplay == "Baker Island — GMT-12:00" ? "GMT-1200" :
     TimezoneDisplay == "American Samoa / Niue — GMT-11:00" ? "GMT-1100" :
     TimezoneDisplay == "Hawaii — GMT-10:00" ? "GMT-1000" :
     TimezoneDisplay == "Marquesas Islands — GMT-09:30" ? "GMT-0930" :
     TimezoneDisplay == "Alaska — GMT-09:00" ? "GMT-0900" :
     TimezoneDisplay == "Pacific Time (US/Canada) — GMT-08:00" ? "GMT-0800" :
     TimezoneDisplay == "Mountain Time (US/Canada) — GMT-07:00" ? "GMT-0700" :
     TimezoneDisplay == "Central Time (US/Canada/Mexico) — GMT-06:00" ? "GMT-0600" :
     TimezoneDisplay == "Eastern Time (US/Canada) — GMT-05:00" ? "GMT-0500" :
     TimezoneDisplay == "Atlantic Time / Venezuela / Chile — GMT-04:00" ? "GMT-0400" :
     TimezoneDisplay == "Newfoundland — GMT-03:30" ? "GMT-0330" :
     TimezoneDisplay == "Argentina / Brazil — GMT-03:00" ? "GMT-0300" :
     TimezoneDisplay == "South Georgia — GMT-02:00" ? "GMT-0200" :
     TimezoneDisplay == "Azores / Cabo Verde — GMT-01:00" ? "GMT-0100" :
     TimezoneDisplay == "London / Iceland — GMT+00:00" ? "GMT+0000" :
     TimezoneDisplay == "Central Europe — GMT+01:00" ? "GMT+0100" :
     TimezoneDisplay == "Eastern Europe / South Africa — GMT+02:00" ? "GMT+0200" :
     TimezoneDisplay == "Moscow / Saudi Arabia — GMT+03:00" ? "GMT+0300" :
     TimezoneDisplay == "Iran — GMT+03:30" ? "GMT+0330" :
     TimezoneDisplay == "Dubai (GST) — GMT+04:00" ? "GMT+0400" :
     TimezoneDisplay == "Afghanistan — GMT+04:30" ? "GMT+0430" :
     TimezoneDisplay == "Pakistan — GMT+05:00" ? "GMT+0500" :
     TimezoneDisplay == "India (IST) — GMT+05:30" ? "GMT+0530" :
     TimezoneDisplay == "Nepal — GMT+05:45" ? "GMT+0545" :
     TimezoneDisplay == "Bangladesh / Bhutan — GMT+06:00" ? "GMT+0600" :
     TimezoneDisplay == "Myanmar — GMT+06:30" ? "GMT+0630" :
     TimezoneDisplay == "Thailand / Vietnam — GMT+07:00" ? "GMT+0700" :
     TimezoneDisplay == "Singapore / China — GMT+08:00" ? "GMT+0800" :
     TimezoneDisplay == "Eucla — GMT+08:45" ? "GMT+0845" :
     TimezoneDisplay == "Japan (JST) / Korea — GMT+09:00" ? "GMT+0900" :
     TimezoneDisplay == "Australia Central — GMT+09:30" ? "GMT+0930" :
     TimezoneDisplay == "Australia Eastern — GMT+10:00" ? "GMT+1000" :
     TimezoneDisplay == "Lord Howe Island — GMT+10:30" ? "GMT+1030" :
     TimezoneDisplay == "Solomon Islands — GMT+11:00" ? "GMT+1100" :
     TimezoneDisplay == "New Zealand — GMT+12:00" ? "GMT+1200" :
     TimezoneDisplay == "Chatham Islands — GMT+12:45" ? "GMT+1245" :
     TimezoneDisplay == "Tonga / Samoa — GMT+13:00" ? "GMT+1300" :
     TimezoneDisplay == "Line Islands — GMT+14:00" ? "GMT+1400" :
     "GMT+0530"

// ============================================================================
// SESSION DETECTOR
// ============================================================================

SessionDetector(
     string Session_Name,
     string Session_Time,
     string KillZone_Time,
     bool   Session_Show,
     bool   Kill_Show,
     bool   MoreInfo,
     color  Session_Color,
     color  Info_Color,
     int    DrawMinutes,
     string Timezone
) =>

    var int    SessionStartBar  = 0
    var int    SessionStartTime = 0

    var float  SessionHigh = 0.0
    var float  SessionLow  = 0.0

    var line   TopLine    = na
    var line   BottomLine = na

    var box    SessionBox = na
    var box    KillBox    = na

    var label  SessionLabel = na
    var label  InfoLabel    = na

    var line   FirstLine  = na
    var line   EndLine    = na
    var line   ArrowLine  = na

    var float  ATR = 0.0

    var int    BarInfo  = 0
    var int    TimeInfo = 0

    var float  Vol = 0.0

    var string Bar_Text  = ''
    var string Time_Text = ''
    var string Vol_Text  = ''

    var float  KillHigh    = 0.0
    var float  KillLow     = 0.0
    var int    KillStartBar = 0
    var bool   KillActive  = false
    var bool   KillDone    = false

    atr = ta.atr(50)

    // =========================================================================
    // SESSION DETECTION
    // =========================================================================

    SessTime = not na(time(timeframe.period, Session_Time,   Timezone)) ? 1 : 0
    KillTime = not na(time(timeframe.period, KillZone_Time,  Timezone)) ? 1 : 0

    // =========================================================================
    // SESSION START
    // =========================================================================

    if SessTime[1] == 0 and SessTime == 1

        ATR := atr

        SessionStartBar  := bar_index
        SessionStartTime := time

        SessionHigh := high
        SessionLow  := low

        BarInfo  := 0
        TimeInfo := 0
        Vol      := volume

        KillDone := false

        // SESSION BOX — only if Session_Show
        if Session_Show

            TopLine := line.new(
                 SessionStartBar, SessionHigh,
                 SessionStartBar, SessionHigh,
                 color = Session_Color,
                 style = line.style_dotted
            )

            BottomLine := line.new(
                 SessionStartBar, SessionLow,
                 SessionStartBar, SessionLow,
                 color = Session_Color,
                 style = line.style_dotted
            )

            SessionBox := box.new(
                 SessionStartBar, SessionHigh,
                 SessionStartBar, SessionLow,
                 bgcolor      = color.new(Session_Color, 90),
                 border_color = color.new(Session_Color, 100)
            )

            SessionLabel := label.new(
                 SessionStartBar, SessionHigh,
                 text      = Session_Name,
                 textcolor = Session_Color,
                 color     = color.new(color.white, 100),
                 size      = size.small
            )

            if MoreInfo

                FirstLine := line.new(
                     SessionStartBar, SessionLow,
                     SessionStartBar, SessionLow - ATR * 2,
                     color = Info_Color,
                     width = 2
                )

                EndLine := line.new(
                     SessionStartBar, SessionLow,
                     SessionStartBar, SessionLow - ATR * 2,
                     color = Info_Color,
                     width = 2
                )

                ArrowLine := line.new(
                     SessionStartBar, SessionLow - ATR,
                     SessionStartBar, SessionLow - ATR,
                     color = Info_Color,
                     style = line.style_arrow_right,
                     width = 2
                )

                InfoLabel := label.new(
                     SessionStartBar, SessionLow - ATR,
                     text  = "",
                     style = label.style_label_up,
                     color = color.new(color.white, 50),
                     size  = size.small
                )

    // =========================================================================
    // KILL ZONE START — independent of Session_Show
    // =========================================================================

    if KillTime == 1 and KillTime[1] == 0 and Kill_Show and not KillDone

        KillStartBar := bar_index
        KillHigh     := high
        KillLow      := low
        KillActive   := true

        KillBox := box.new(
             KillStartBar, KillHigh,
             KillStartBar, KillLow,
             bgcolor      = color.new(Session_Color, KillZoneOpacity),
             border_color = color.new(Session_Color, math.max(KillZoneOpacity - 20, 0)),
             border_width = 1
        )

    // =========================================================================
    // KILL ZONE ACTIVE — independent of Session_Show
    // =========================================================================

    if KillTime == 1 and KillActive and Kill_Show

        KillHigh := math.max(high, KillHigh)
        KillLow  := math.min(low,  KillLow)

        if not na(KillBox)
            KillBox.set_top(KillHigh)
            KillBox.set_bottom(KillLow)
            KillBox.set_right(bar_index)

    // =========================================================================
    // KILL ZONE END
    // =========================================================================

    if KillTime == 0 and KillTime[1] == 1 and KillActive
        KillActive := false
        KillDone   := true

    // =========================================================================
    // SESSION ACTIVE — only if Session_Show
    // =========================================================================

    if SessTime == 1 and Session_Show

        TimeInfo := int((time - SessionStartTime) / (60 * 1000))

        DrawLimitReached = TimeInfo >= DrawMinutes

        if not DrawLimitReached

            SessionHigh := math.max(high, SessionHigh)
            SessionLow  := math.min(low,  SessionLow)

            if not na(TopLine)
                TopLine.set_y1(SessionHigh)
                TopLine.set_y2(SessionHigh)
                TopLine.set_x2(bar_index)

            if not na(BottomLine)
                BottomLine.set_y1(SessionLow)
                BottomLine.set_y2(SessionLow)
                BottomLine.set_x2(bar_index)

            if not na(SessionBox)
                SessionBox.set_top(SessionHigh)
                SessionBox.set_bottom(SessionLow)
                SessionBox.set_right(bar_index)

        else

            if not na(TopLine)
                TopLine.set_x2(bar_index)

            if not na(BottomLine)
                BottomLine.set_x2(bar_index)

        if not na(SessionLabel)
            SessionLabel.set_xy(
                 math.round(math.avg(SessionStartBar, bar_index)),
                 SessionHigh
            )

        BarInfo := bar_index - SessionStartBar + 1
        Vol     := Vol + volume

        if BarInfo == 1
            Bar_Text := '1 bar, '
        else
            Bar_Text := str.tostring(BarInfo) + ' bars, '

        if TimeInfo < 60
            Time_Text := str.tostring(TimeInfo) + 'm'
        else
            if (TimeInfo % 60) == 0
                Time_Text := str.tostring(TimeInfo / 60) + 'h'
            else
                Time_Text := str.tostring(int(TimeInfo / 60)) + 'h ' + str.tostring(TimeInfo % 60) + 'm'

        if Vol <= 1000
            Vol_Text := '\nVol ' + str.tostring(Vol)
        else
            Vol_Text := '\nVol ' + str.tostring(Vol / 1000) + 'K'

        if MoreInfo

            if not na(FirstLine)
                FirstLine.set_y1(SessionLow)
                FirstLine.set_y2(SessionLow - ATR * 2)

            if not na(EndLine)
                EndLine.set_x1(bar_index)
                EndLine.set_x2(bar_index)
                EndLine.set_y1(SessionLow)
                EndLine.set_y2(SessionLow - ATR * 2)

            if not na(ArrowLine)
                ArrowLine.set_x2(bar_index)
                ArrowLine.set_y1(SessionLow - ATR)
                ArrowLine.set_y2(SessionLow - ATR)

            if not na(InfoLabel)
                InfoLabel.set_x(SessionStartBar + math.round(BarInfo / 2))
                InfoLabel.set_y(SessionLow - ATR)
                InfoLabel.set_text(Bar_Text + Time_Text + Vol_Text)

// ============================================================================
// SESSION INPUTS
// ============================================================================

// ASIA
show_AsiaSess = input.bool(true, 'Asia Session',     inline = 'asia',     group = 'Asia Session', display = display.none)
Asia_color    = input.color(#fa7b05, '',             inline = 'asia',     group = 'Asia Session', display = display.none)
Asia_SessTime = input.session('0430-1429', 'Session Time',                group = 'Asia Session', display = display.none) // 04:30 AM – 02:29 PM IST
show_AsiaKill = input.bool(true, 'Asia Kill Zone',   inline = 'asiakill', group = 'Asia Session', display = display.none)
Asia_KillTime = input.session('0430-1029', '',       inline = 'asiakill', group = 'Asia Session', display = display.none) // 04:30 AM – 10:29 AM IST

// LONDON
show_LondonSess = input.bool(true, 'London Session',     inline = 'london',     group = 'London Session', display = display.none)
London_color    = input.color(#118502, '',               inline = 'london',     group = 'London Session', display = display.none)
London_SessTime = input.session('1230-2050', 'Session Time',                    group = 'London Session', display = display.none) // 12:30 PM – 08:50 PM IST
show_LondonKill = input.bool(true, 'London Kill Zone',   inline = 'londonkill', group = 'London Session', display = display.none)
London_KillTime = input.session('1230-1430', '',         inline = 'londonkill', group = 'London Session', display = display.none) // 12:30 PM – 02:30 PM IST

// NY AM
show_amNewyorkSess = input.bool(true, 'NY AM Session',     inline = 'nyam',     group = 'NY AM Session', display = display.none)
amNewyork_color    = input.color(#b40f0f, '',              inline = 'nyam',     group = 'NY AM Session', display = display.none)
amNewyork_SessTime = input.session('1900-0054', 'Session Time',                 group = 'NY AM Session', display = display.none) // 08:00 PM – 12:54 AM IST
show_amNewyorkKill = input.bool(true, 'NY AM Kill Zone',   inline = 'nyamkill', group = 'NY AM Session', display = display.none)
amNewyork_KillTime = input.session('1900-2100', '',        inline = 'nyamkill', group = 'NY AM Session', display = display.none) // 08:00 PM – 10:00 PM IST

// NY PM
show_pmNewyorkSess = input.bool(true, 'NY PM Session',     inline = 'nypm',      group = 'NY PM Session', display = display.none)
pmNewyork_color    = input.color(#0c6dff, '',              inline = 'nypm',      group = 'NY PM Session', display = display.none)
pmNewyork_SessTime = input.session('0100-0424', 'Session Time',                  group = 'NY PM Session', display = display.none) // 01:00 AM – 04:24 AM IST
show_pmNewyorkKill = input.bool(true, 'NY PM Kill Zone',   inline = 'nypmpkill', group = 'NY PM Session', display = display.none)
pmNewyork_KillTime = input.session('0100-0200', '',        inline = 'nypmpkill', group = 'NY PM Session', display = display.none) // 01:00 AM – 02:00 AM IST

// ============================================================================
// DRAW SESSIONS
// ============================================================================

// Asia     0430-1429 = 10h 00m = 600 minutes
SessionDetector('Asia',   Asia_SessTime,      Asia_KillTime,      show_AsiaSess,      show_AsiaKill,      ShowMoreInfo, Asia_color,      ColorMoreInfo, 600, Timezone)

// London   1230-2050 = 8h 20m  = 500 minutes
SessionDetector('London', London_SessTime,    London_KillTime,    show_LondonSess,    show_LondonKill,    ShowMoreInfo, London_color,    ColorMoreInfo, 500, Timezone)

// NY AM    2000-0054 = 4h 54m  = 294 minutes
SessionDetector('NY AM',  amNewyork_SessTime, amNewyork_KillTime, show_amNewyorkSess, show_amNewyorkKill, ShowMoreInfo, amNewyork_color, ColorMoreInfo, 354, Timezone)

// NY PM    0100-0424 = 3h 24m  = 204 minutes
SessionDetector('NY PM',  pmNewyork_SessTime, pmNewyork_KillTime, show_pmNewyorkSess, show_pmNewyorkKill, ShowMoreInfo, pmNewyork_color, ColorMoreInfo, 204, Timezone)
````
