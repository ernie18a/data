# Candle Timer

- url: https://www.tradingview.com/script/dlbGCJx2/
- type: indicator
- pine_id: PUB;987420eaceb345e4a8efd8e78dcaff23
- version: 1.0

## Description

Candle Timer+ is a multi-timeframe countdown dashboard that helps you keep track of candle closes and focus your attention as they approach.

The idea behind this indicator is simple: **I believe that watching a candle develop before it closes can make a meaningful difference in trading preparation.** Rather than checking only the finished candle, I prefer to observe how price behaves during its final stretch—whether it holds a level, rejects it, or changes direction before the close.

Candle Timer+ supports this routine by highlighting the relevant timer row when its remaining time reaches your chosen threshold.

Default highlight settings:

- 1-hour candles: 20 minutes before close.
- 4-hour candles: 90 minutes before close.
- Daily candles: 240 minutes before close.
- Other timeframes: 1 minute before close.

For example, a full 1-hour candle with a 20-minute threshold becomes highlighted 40 minutes after it opens. Each threshold is adjustable. Set it to zero to disable highlighting for that timeframe.

For example, a full 1-hour candle with a 10-minute threshold becomes highlighted 50 minutes after it opens. Each threshold is adjustable. Set it to zero to disable highlighting for that timeframe.

**Features**

- Up to six timeframe timer slots.
- Automatic timeframe mapping or manual selection.
- Customizable highlight color and transparency.
- Candle direction markers.
- Optional seconds, symbol, and chart timeframe display.
- Adjustable table position, text size, and colors.

These defaults reflect my preferred observation windows, rather than statistically proven optimal entry times. The highlight is a reminder to pay attention; it is not a buy or sell signal. A developing candle can still change before it closes.

Countdowns use the candle closing times supplied by TradingView and refresh when the script receives market updates.

My goal is to make candle observation a more deliberate part of trading: **notice the approaching close, watch price develop, and assess the completed candle within your own strategy.**

## Source Code

````pine
//@version=6

indicator("Candle Timer+", shorttitle="Candle Timer+", overlay=true, dynamic_requests=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 01. Display

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupDisplay = "01. Display"

displayMode = input.string(

     "Compact",

     "Display mode",

     options=["Compact", "Detailed"],

     group=groupDisplay)

showHeader     = input.bool(true,  "Show header", group=groupDisplay)

showInstrument = input.bool(true,  "Show symbol", group=groupDisplay)

showChartTf    = input.bool(true,  "Show chart timeframe", group=groupDisplay)

showDirection  = input.bool(true,  "Show candle direction", group=groupDisplay)

showSeconds    = input.bool(true,  "Show seconds", group=groupDisplay)

positionInput = input.string(

     "Top right",

     "Table position",

     options=["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"],

     group=groupDisplay)

textSizeInput = input.string(

     "Small",

     "Text size",

     options=["Tiny", "Small", "Normal", "Large"],

     group=groupDisplay)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 02. Timeframe mode

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupTfMode = "02. Timeframe mode"

tfMode = input.string(

     "Auto",

     "Timeframe mode",

     options=["Auto", "Manual"],

     group=groupTfMode)

autoProfile = input.string(

     "Standard",

     "Automatic timeframe mapping",

     options=["Standard", "Extended"],

     tooltip=

         "Standard:\n" +

         "1m → 5m / 15m / 1H / 4H / 1D\n" +

         "2m → 5m / 15m / 1H / 4H / 1D\n" +

         "3m → 15m / 1H / 4H / 1D\n" +

         "5m → 15m / 1H / 4H / 1D\n" +

         "15m·30m → 1H / 4H / 1D / 1W\n" +

         "1H → 4H / 1D / 1W\n\n" +

         "Extended: adds a weekly or monthly timeframe where supported.",

     group=groupTfMode)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 03. Manual timeframes

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupManual = "03. Timer slots / Manual timeframes"

m1On = input.bool(true,  "Show", inline="M1", tooltip="Controls this timer slot in both Auto and Manual modes.", group=groupManual)

m1Tf = input.timeframe("5",   "1", inline="M1", group=groupManual)

m2On = input.bool(true,  "Show", inline="M2", tooltip="Controls this timer slot in both Auto and Manual modes.", group=groupManual)

m2Tf = input.timeframe("15",  "2", inline="M2", group=groupManual)

m3On = input.bool(true,  "Show", inline="M3", tooltip="Controls this timer slot in both Auto and Manual modes.", group=groupManual)

m3Tf = input.timeframe("60",  "3", inline="M3", group=groupManual)

m4On = input.bool(true,  "Show", inline="M4", tooltip="Controls this timer slot in both Auto and Manual modes.", group=groupManual)

m4Tf = input.timeframe("240", "4", inline="M4", group=groupManual)

m5On = input.bool(true,  "Show", inline="M5", tooltip="Controls this timer slot in both Auto and Manual modes.", group=groupManual)

m5Tf = input.timeframe("D",   "5", inline="M5", group=groupManual)

m6On = input.bool(false, "Show", inline="M6", tooltip="Controls this timer slot in both Auto and Manual modes.", group=groupManual)

m6Tf = input.timeframe("W",   "6", inline="M6", group=groupManual)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 04. Highlight before candle close

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupWarn = "04. Highlight before candle close"

warnOn = input.bool(true, "Highlight the timer row before close", group=groupWarn)
warn1hMin = input.int(20, "1-hour candle: minutes before close", minval=0, maxval=60, tooltip="20 = highlight when 20 minutes or less remain (40 minutes after a full 1-hour candle opens). Set to 0 to disable highlighting for this timeframe.", group=groupWarn)
warn4hMin = input.int(90, "4-hour candle: minutes before close", minval=0, maxval=240, tooltip="Default: 90 minutes before close. Set to 60 for one hour before close. Set to 0 to disable highlighting for this timeframe.", group=groupWarn)
warnDayMin = input.int(240, "Daily candle: minutes before close", minval=0, maxval=1440, tooltip="240 minutes = 4 hours before close. Uses the symbol's actual daily candle closing time. Set to 0 to disable highlighting for this timeframe.", group=groupWarn)
warnOtherMin = input.int(1, "Other timeframes: minutes before close", minval=0, maxval=44640, tooltip="Applies to timers other than 1-hour, 4-hour and daily candles. Set to 0 to disable highlighting for other timeframes.", group=groupWarn)
warnBgColor = input.color(color.rgb(255, 193, 7), "Highlight background color", group=groupWarn)
warnBgTransparency = input.int(85, "Highlight transparency (0=solid, 100=invisible)", minval=0, maxval=100, group=groupWarn)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 05. Style

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupStyle = "05. Style"

headerBg   = input.color(color.rgb(238, 238, 238), "Header background", group=groupStyle)

panelBg    = input.color(color.new(color.white, 4), "Table background", group=groupStyle)

textColor  = input.color(color.rgb(20, 20, 20), "Text color", group=groupStyle)

timeColor  = input.color(color.rgb(20, 20, 20), "Timer text color", group=groupStyle)

bullColor  = input.color(color.rgb(179, 73, 214), "Bullish direction color", group=groupStyle)

bearColor  = input.color(color.rgb(179, 73, 214), "Bearish direction color", group=groupStyle)

dojiColor  = input.color(color.rgb(125, 125, 125), "Neutral direction color", group=groupStyle)




borderCol  = input.color(color.rgb(70, 70, 70), "Border color", group=groupStyle)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Utilities

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_position(string p) =>

    switch p

        "Top left"       => position.top_left

        "Top center"     => position.top_center

        "Top right"     => position.top_right

        "Middle left"   => position.middle_left

        "Middle right" => position.middle_right

        "Bottom left"     => position.bottom_left

        "Bottom center"   => position.bottom_center

        => position.bottom_right

f_textSize(string s) =>

    switch s

        "Tiny" => size.tiny

        "Small"      => size.small

        "Normal"      => size.normal

        => size.large

f_tfLabel(string tf) =>

    switch tf

        "1"   => "M1"

        "2"   => "M2"

        "3"   => "M3"

        "5"   => "M5"

        "10"  => "M10"

        "15"  => "M15"

        "20"  => "M20"

        "30"  => "M30"

        "45"  => "M45"

        "60"  => "H1"

        "120" => "H2"

        "180" => "H3"

        "240" => "H4"

        "360" => "H6"

        "480" => "H8"

        "720" => "H12"

        "D"   => "D"

        "1D"  => "D"

        "W"   => "W"

        "1W"  => "W"

        "M"   => "M"

        "1M"  => "M"

        => tf

f_chartTfLabel() =>

    f_tfLabel(timeframe.period)

f_remainingSec(int closeTime) =>

    na(closeTime) ? 0 : int(math.max(math.ceil((closeTime - timenow) / 1000.0), 0))

f_remainingText(int closeTime) =>

    if na(closeTime)

        "—"

    else

        int remainMs = math.max(closeTime - timenow, 0)

        int totalSec = int(math.ceil(remainMs / 1000.0))

        int days     = int(math.floor(totalSec / 86400))

        int remDay   = totalSec - days * 86400

        int hours    = int(math.floor(remDay / 3600))

        int remHour  = remDay - hours * 3600

        int minutes  = int(math.floor(remHour / 60))

        int seconds  = remHour - minutes * 60

        string hh = str.tostring(hours, "00")

        string mm = str.tostring(minutes, "00")

        string ss = str.tostring(seconds, "00")

        if days > 0

            showSeconds

                 ? str.tostring(days) + "d " + hh + ":" + mm + ":" + ss

                 : str.tostring(days) + "d " + hh + ":" + mm

        else if hours > 0

            showSeconds

                 ? str.tostring(hours) + ":" + mm + ":" + ss

                 : str.tostring(hours) + ":" + mm

        else

            showSeconds ? mm + ":" + ss : mm

f_dir(float o, float c) =>

    na(o) or na(c) ? 0 : c > o ? 1 : c < o ? -1 : 0

f_arrow(int d) =>

    d > 0 ? "▲" : d < 0 ? "▼" : "•"

f_dirColor(int d) =>

    d > 0 ? bullColor : d < 0 ? bearColor : dojiColor

// Select the threshold by the actual timer timeframe, not the slot number.
f_warnMinutes(string tf) =>
    switch tf
        "60" => warn1hMin
        "240" => warn4hMin
        "D" => warnDayMin
        "1D" => warnDayMin
        => warnOtherMin

f_timerBg(string tf, int closeTime) =>
    int thresholdMin = f_warnMinutes(tf)
    bool highlight = false
    if warnOn and thresholdMin > 0 and not na(closeTime)
        int remainingMs = closeTime - timenow
        highlight := remainingMs > 0 and remainingMs <= thresholdMin * 60000
    highlight ? color.new(warnBgColor, warnBgTransparency) : panelBg

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Automatic timeframe mapping

// Return "" for unused slots.

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_autoTf(int slot) =>

    string ctf = timeframe.period

    bool wide = autoProfile == "Extended"

    string out = ""

    if ctf == "1"

        out := switch slot

            1 => "5"

            2 => "15"

            3 => "60"

            4 => "240"

            5 => "D"

            6 => wide ? "W" : ""

            => ""

    else if ctf == "2"

        out := switch slot

            1 => "5"

            2 => "15"

            3 => "60"

            4 => "240"

            5 => "D"

            6 => wide ? "W" : ""

            => ""

    else if ctf == "3"

        out := switch slot

            1 => "15"

            2 => "60"

            3 => "240"

            4 => "D"

            5 => wide ? "W" : ""

            => ""

    else if ctf == "5"

        out := switch slot

            1 => "15"

            2 => "60"

            3 => "240"

            4 => "D"

            5 => wide ? "W" : ""

            => ""

    else if ctf == "15" or ctf == "30"

        out := switch slot

            1 => "60"

            2 => "240"

            3 => "D"

            4 => "W"

            5 => wide ? "M" : ""

            => ""

    else if ctf == "60"

        out := switch slot

            1 => "240"

            2 => "D"

            3 => "W"

            4 => wide ? "M" : ""

            => ""

    else if ctf == "240"

        out := switch slot

            1 => "D"

            2 => "W"

            3 => "M"

            => ""

    else if ctf == "D" or ctf == "1D"

        out := switch slot

            1 => "W"

            2 => "M"

            => ""

    else

        // Use manual inputs for chart timeframes without a preset mapping.

        out := switch slot

            1 => m1Tf

            2 => m2Tf

            3 => m3Tf

            4 => m4Tf

            5 => m5Tf

            6 => m6Tf

            => ""

    out

f_manualTf(int slot) =>

    switch slot

        1 => m1Tf

        2 => m2Tf

        3 => m3Tf

        4 => m4Tf

        5 => m5Tf

        6 => m6Tf

        => ""

f_manualOn(int slot) =>

    switch slot

        1 => m1On

        2 => m2On

        3 => m3On

        4 => m4On

        5 => m5On

        6 => m6On

        => false

f_activeTf(int slot) =>

    tfMode == "Auto" ? f_autoTf(slot) : f_manualTf(slot)

f_activeOn(int slot) =>

    // Slot visibility checkboxes apply in both Auto and Manual modes.

    f_manualOn(slot) and f_activeTf(slot) != ""

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Active timeframes

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tf1 = f_activeTf(1)

tf2 = f_activeTf(2)

tf3 = f_activeTf(3)

tf4 = f_activeTf(4)

tf5 = f_activeTf(5)

tf6 = f_activeTf(6)

on1 = f_activeOn(1)

on2 = f_activeOn(2)

on3 = f_activeOn(3)

on4 = f_activeOn(4)

on5 = f_activeOn(5)

on6 = f_activeOn(6)

// Use a safe fallback timeframe for empty slots.

safeTf1 = tf1 == "" ? timeframe.period : tf1

safeTf2 = tf2 == "" ? timeframe.period : tf2

safeTf3 = tf3 == "" ? timeframe.period : tf3

safeTf4 = tf4 == "" ? timeframe.period : tf4

safeTf5 = tf5 == "" ? timeframe.period : tf5

safeTf6 = tf6 == "" ? timeframe.period : tf6

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Current candle data for each timeframe

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tf1CloseTime = request.security(syminfo.tickerid, safeTf1, time_close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf1Open      = request.security(syminfo.tickerid, safeTf1, open,       gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf1Close     = request.security(syminfo.tickerid, safeTf1, close,      gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf2CloseTime = request.security(syminfo.tickerid, safeTf2, time_close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf2Open      = request.security(syminfo.tickerid, safeTf2, open,       gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf2Close     = request.security(syminfo.tickerid, safeTf2, close,      gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf3CloseTime = request.security(syminfo.tickerid, safeTf3, time_close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf3Open      = request.security(syminfo.tickerid, safeTf3, open,       gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf3Close     = request.security(syminfo.tickerid, safeTf3, close,      gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf4CloseTime = request.security(syminfo.tickerid, safeTf4, time_close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf4Open      = request.security(syminfo.tickerid, safeTf4, open,       gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf4Close     = request.security(syminfo.tickerid, safeTf4, close,      gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf5CloseTime = request.security(syminfo.tickerid, safeTf5, time_close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf5Open      = request.security(syminfo.tickerid, safeTf5, open,       gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf5Close     = request.security(syminfo.tickerid, safeTf5, close,      gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf6CloseTime = request.security(syminfo.tickerid, safeTf6, time_close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf6Open      = request.security(syminfo.tickerid, safeTf6, open,       gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

tf6Close     = request.security(syminfo.tickerid, safeTf6, close,      gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Table

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table timerTable = table.new(

     f_position(positionInput),

     3, 10,

     bgcolor=panelBg,

     frame_color=borderCol,

     frame_width=1,

     border_color=color.new(borderCol, 45),

     border_width=1)

f_putTimerRow(int row, string tf, int closeTime, float o, float c) =>

    int d = f_dir(o, c)

    color rowBg = f_timerBg(tf, closeTime)

    string leftText = displayMode == "Compact"

         ? f_tfLabel(tf) + " CLOSES IN"

         : f_tfLabel(tf) + " Time to close"

    table.cell(timerTable, 0, row, leftText,

         bgcolor=rowBg,

         text_color=textColor,

         text_size=f_textSize(textSizeInput),

         text_halign=text.align_left)

    table.cell(timerTable, 1, row, f_remainingText(closeTime),

         bgcolor=rowBg,

         text_color=timeColor,

         text_size=f_textSize(textSizeInput),

         text_halign=text.align_right)

    table.cell(timerTable, 2, row, showDirection ? f_arrow(d) : "",

         bgcolor=rowBg,

         text_color=f_dirColor(d),

         text_size=f_textSize(textSizeInput),

         text_halign=text.align_center)

if barstate.islast

    table.clear(timerTable, 0, 0, 2, 9)

    int row = 0

    if showHeader

        table.cell(timerTable, 0, row, displayMode == "Compact" ? "CANDLE TIMER+" : "Candle Timer+",

             bgcolor=headerBg,

             text_color=textColor,

             text_size=f_textSize(textSizeInput),

             text_halign=text.align_left)

        table.cell(timerTable, 1, row, "", bgcolor=headerBg)

        table.cell(timerTable, 2, row, "", bgcolor=headerBg)

        row += 1

    if showInstrument

        table.cell(timerTable, 0, row, displayMode == "Compact" ? "INSTRUMENT" : "Symbol",

             bgcolor=panelBg,

             text_color=textColor,

             text_size=f_textSize(textSizeInput),

             text_halign=text.align_left)

        table.cell(timerTable, 1, row, syminfo.ticker,

             bgcolor=panelBg,

             text_color=textColor,

             text_size=f_textSize(textSizeInput),

             text_halign=text.align_right)

        table.cell(timerTable, 2, row, "", bgcolor=panelBg)

        row += 1

    if showChartTf

        table.cell(timerTable, 0, row, displayMode == "Compact" ? "TIMEFRAME" : "Chart timeframe",

             bgcolor=panelBg,

             text_color=textColor,

             text_size=f_textSize(textSizeInput),

             text_halign=text.align_left)

        table.cell(timerTable, 1, row, f_chartTfLabel(),

             bgcolor=panelBg,

             text_color=textColor,

             text_size=f_textSize(textSizeInput),

             text_halign=text.align_right)

        table.cell(timerTable, 2, row, "", bgcolor=panelBg)

        row += 1

    if on1 and row < 10

        f_putTimerRow(row, tf1, tf1CloseTime, tf1Open, tf1Close)

        row += 1

    if on2 and row < 10

        f_putTimerRow(row, tf2, tf2CloseTime, tf2Open, tf2Close)

        row += 1

    if on3 and row < 10

        f_putTimerRow(row, tf3, tf3CloseTime, tf3Open, tf3Close)

        row += 1

    if on4 and row < 10

        f_putTimerRow(row, tf4, tf4CloseTime, tf4Open, tf4Close)

        row += 1

    if on5 and row < 10

        f_putTimerRow(row, tf5, tf5CloseTime, tf5Open, tf5Close)

        row += 1

    if on6 and row < 10

        f_putTimerRow(row, tf6, tf6CloseTime, tf6Open, tf6Close)
````
