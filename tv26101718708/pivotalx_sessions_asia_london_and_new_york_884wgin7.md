# PivotalX Sessions - Asia, London and New York

- url: https://www.tradingview.com/script/884WGIN7-PivotalX-Sessions-Asia-London-and-New-York/
- type: indicator
- pine_id: PUB;e68739c2fdaf45c8bd9fd25dd19cf246
- version: 1.0

## Description

A clean sessions indicator built around the three sessions that matter most: Asia, London, and New York.

Most session indicators try to display everything - Sydney, Tokyo, Shanghai, Frankfurt, NYSE - until the chart becomes unreadable. This one keeps it to the golden three, drawn as clear high/low range boxes with the levels traders actually reference.

[b]WHAT IT DRAWS[/b]

[list]
[*]A range box for each session, expanding in real time as new highs and lows print
[*]Solid session high and low lines in the session color so the key levels stand out
[*]Optional 50% midline (off by default) for traders who reference the session midpoint
[*]A clean info table showing each session's open and close time, live Open/Closed status, and the active timezone
[/list]
[b]
LEVELS THAT KEEP WORKING AFTER THE CLOSE[/b]
Choose how each finished session's high and low project forward:

[list]
[*]None: levels end with the session
[*]Until next session (default): levels extend as reference until that session runs again - for example, the completed Asia high and low stay on the chart through London
[*]Until broken: each level extends until price trades through it, then freezes at the break
[/list]
[b]
BUILT-IN ALERTS[/b]
Nine alert conditions, available from the standard alert dialog:
[list]
[*]
[*]Session opened (Asia / London / New York)
[*]Session high broken (Asia / London / New York)
[*]Session low broken (Asia / London / New York)
[/list]

Break alerts arm only when a session completes, so they fire when price takes out a finished session's high or low - not on every new high inside a live session. Each level fires once, then retires when that session next opens.

[b]DST-SAFE BY DESIGN[/b]

Each session is anchored to its home city timezone (Tokyo, London, New York), so daylight saving is handled automatically. The boxes never drift an hour when clocks change and you never need to adjust the settings twice a year. Japan has no DST, so the Asia session is stable year-round.

[b]YOUR TIMEZONE, YOUR CLOCK[/b]

Pick your timezone in the settings and the info table converts all session times to your local clock - Sydney, Singapore, Dubai, London, New York and more. Changing the table timezone never moves the boxes; they are anchored to each city and always sit in the correct place on the chart.

[b]KEPT CLEAN ON PURPOSE[/b]

[list]
[*]Show last N days control (default 15) so old sessions do not pile up
[*]Session inputs hidden from the chart status line for a tidy header
[*]A clear on-chart notice if the indicator is added to a Daily or higher timeframe, since sessions can only be drawn on intraday charts
[/list]

## Source Code

````pine
// This Pine Script(TM) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) PivotalX - DST-safe sessions (Asia / London / New York): high/low/mid levels, forward extension, break alerts
//@version=6

indicator("Sessions - Asia, London, New York (DST-safe)", "PivotalX Sessions", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// ---------- Display ----------
grp_disp    = 'Display'
disp_tz_opt = input.string('Australia/Sydney', 'Table timezone', options = ['Exchange / chart', 'UTC', 'Pacific/Auckland', 'Australia/Sydney', 'Asia/Tokyo', 'Asia/Singapore', 'Asia/Hong_Kong', 'Asia/Dubai', 'Europe/London', 'Europe/Berlin', 'America/New_York', 'America/Chicago', 'America/Los_Angeles'], group = grp_disp, tooltip = 'Open/Close in the table are shown in this timezone. The session BOXES are anchored to each city and do NOT move when you change this.', display = display.none)
disp_tz     = disp_tz_opt == 'Exchange / chart' ? syminfo.timezone : disp_tz_opt
lookback_d  = input.int(15, 'Show last N days', minval = 1, maxval = 60, group = grp_disp, tooltip = 'Sessions older than this are not drawn. Keeps the chart clean and fast.', display = display.none)
extend_mode = input.string('Until next session', 'Extend high/low after close', options = ['None', 'Until next session', 'Until broken'], group = grp_disp, tooltip = 'Projects the finished session high/low forward as reference levels. Until broken: each line stops extending once price trades through it. The midline (if shown) always extends until the next session.', display = display.none)
show_mid    = input.bool(false, 'Show session midline (50%)', group = grp_disp)

// ---------- Session inputs - hours are in each city's LOCAL time; DST handled automatically ----------
show_sesasia  = input.bool(true, 'Asia Session', group = 'Asia Session', tooltip = 'Tokyo local time. Japan has no DST, so this is stable year-round.')
sesasia_ses   = input.session('0800-1500', '', inline = 'sesasia', group = 'Asia Session', display = display.none)
sesasia_tz    = 'Asia/Tokyo'
sesasia_color = input.color(color.rgb(214, 184, 144), 'Color', inline = 'sesasia', group = 'Asia Session')
sesasia_text  = 'Asia'

show_seslondon  = input.bool(true, 'London Session', group = 'London Session', tooltip = 'London local time. Auto-adjusts for British Summer Time.')
seslondon_ses   = input.session('0800-1630', '', inline = 'seslondon', group = 'London Session', display = display.none)
seslondon_tz    = 'Europe/London'
seslondon_color = input.color(color.rgb(132, 221, 228), 'Color', inline = 'seslondon', group = 'London Session')
seslondon_text  = 'London'

show_sesNewyork  = input.bool(true, 'New York Session', group = 'New York Session', tooltip = 'New York local time. Auto-adjusts for US daylight saving.')
sesNewyork_ses   = input.session('0800-1700', '', inline = 'sesNewyork', group = 'New York Session', display = display.none)
sesNewyork_tz    = 'America/New_York'
sesNewyork_color = input.color(#a174df, 'Color', inline = 'sesNewyork', group = 'New York Session')
sesNewyork_text  = 'New York'

show_Info_Table = input.bool(true, 'Info Table', group = 'Table')

// ---------- Session state (in / out) using each city's own timezone ----------
On_sesasia    = math.sign(nz(time(timeframe.period, sesasia_ses,    sesasia_tz)))
On_seslondon  = math.sign(nz(time(timeframe.period, seslondon_ses,  seslondon_tz)))
On_sesNewyork = math.sign(nz(time(timeframe.period, sesNewyork_ses, sesNewyork_tz)))

isIntraday = timeframe.isintraday
inLookback = time >= timenow - lookback_d * 86400000
extendOn   = extend_mode != 'None'

// ---------- Per-session engine: box, label, high/low/mid lines, extension, break detection ----------
f_session(showSes, On_Session, Color_Session, Text_Session) =>
    var int   Bar     = 0
    var float High    = 0.0
    var float Low     = 0.0
    var box   BoX     = na
    var label LabeL   = na
    var line  HiLine  = na
    var line  LoLine  = na
    var line  MidLine = na
    var float finHi   = na
    var float finLo   = na
    var bool  hiDone  = true
    var bool  loDone  = true

    sesStart = On_Session[1] == 0 and On_Session == 1
    sesEnd   = On_Session[1] == 1 and On_Session == 0
    sesLive  = On_Session == 1 and On_Session[1] == 1
    draw     = showSes and isIntraday and inLookback

    // Arm the completed session's levels for extension and break alerts
    if sesEnd
        finHi  := High
        finLo  := Low
        hiDone := false
        loDone := false

    // A new session of the same type retires the old levels
    if sesStart
        hiDone := true
        loDone := true

    // Track the running session range
    if sesStart
        Bar  := bar_index
        High := high
        Low  := low
    else if sesLive
        High := math.max(high, High)
        Low  := math.min(low, Low)
    else if On_Session == 0
        High := 0.0
        Low  := 0.0
        Bar  := 0

    // Break detection on the most recently completed session's levels
    brokeHi = not hiDone and not na(finHi) and high > finHi
    brokeLo = not loDone and not na(finLo) and low < finLo
    if brokeHi
        hiDone := true
    if brokeLo
        loDone := true

    // Create drawings at session open
    if sesStart
        if draw
            BoX     := box.new(bar_index, High, bar_index, Low, bgcolor = color.new(Color_Session, 85), border_color = Color_Session, border_style = line.style_dotted)
            LabeL   := label.new(Bar, High, text = Text_Session, xloc = xloc.bar_index, yloc = yloc.price, size = size.small, style = Text_Session == 'Asia' ? label.style_label_down : label.style_label_lower_left, textcolor = Color_Session, color = color.rgb(255, 255, 255, 100))
            HiLine  := line.new(Bar, High, bar_index, High, xloc = xloc.bar_index, color = Color_Session, width = 2)
            LoLine  := line.new(Bar, Low,  bar_index, Low,  xloc = xloc.bar_index, color = Color_Session, width = 2)
            MidLine := na
            if show_mid
                MidLine := line.new(Bar, math.avg(High, Low), bar_index, math.avg(High, Low), xloc = xloc.bar_index, color = color.new(Color_Session, 30), width = 1, style = line.style_dashed)
        else
            BoX     := na
            LabeL   := na
            HiLine  := na
            LoLine  := na
            MidLine := na

    // Update drawings while the session is live
    if sesLive and not na(BoX)
        box.set_top(BoX, High)
        box.set_bottom(BoX, Low)
        box.set_right(BoX, bar_index)
        label.set_x(LabeL, math.round(math.avg(Bar, bar_index)))
        label.set_y(LabeL, High)
        line.set_y1(HiLine, High)
        line.set_y2(HiLine, High)
        line.set_x2(HiLine, bar_index)
        line.set_y1(LoLine, Low)
        line.set_y2(LoLine, Low)
        line.set_x2(LoLine, bar_index)
        if not na(MidLine)
            mid = math.avg(High, Low)
            line.set_y1(MidLine, mid)
            line.set_y2(MidLine, mid)
            line.set_x2(MidLine, bar_index)

    // Extend the finished session's levels forward
    if On_Session == 0 and extendOn
        if not na(HiLine) and (extend_mode == 'Until next session' or not hiDone or brokeHi)
            line.set_x2(HiLine, bar_index)
        if not na(LoLine) and (extend_mode == 'Until next session' or not loDone or brokeLo)
            line.set_x2(LoLine, bar_index)
        if not na(MidLine)
            line.set_x2(MidLine, bar_index)

    [sesStart and showSes, brokeHi and showSes, brokeLo and showSes]

[asiaOpened, asiaHiBroke, asiaLoBroke] = f_session(show_sesasia,    On_sesasia,    sesasia_color,    sesasia_text)
[lonOpened, lonHiBroke, lonLoBroke]    = f_session(show_seslondon,  On_seslondon,  seslondon_color,  seslondon_text)
[nyOpened, nyHiBroke, nyLoBroke]       = f_session(show_sesNewyork, On_sesNewyork, sesNewyork_color, sesNewyork_text)

// ---------- Alerts (create them via the Alert dialog with this indicator as the condition) ----------
alertcondition(asiaOpened,  'Asia session opened',         'Asia session has opened')
alertcondition(asiaHiBroke, 'Asia session high broken',    'Price broke the completed Asia session high')
alertcondition(asiaLoBroke, 'Asia session low broken',     'Price broke the completed Asia session low')
alertcondition(lonOpened,   'London session opened',       'London session has opened')
alertcondition(lonHiBroke,  'London session high broken',  'Price broke the completed London session high')
alertcondition(lonLoBroke,  'London session low broken',   'Price broke the completed London session low')
alertcondition(nyOpened,    'New York session opened',     'New York session has opened')
alertcondition(nyHiBroke,   'New York session high broken','Price broke the completed New York session high')
alertcondition(nyLoBroke,   'New York session low broken', 'Price broke the completed New York session low')

// ---------- Timeframe guard ----------
if not isIntraday and barstate.islast
    var table TF_Warn = table.new(position.top_center, 1, 1, bgcolor = #db504a, border_width = 1, frame_color = #373a46)
    table.cell(TF_Warn, 0, 0, 'PivotalX Sessions: switch to an intraday timeframe - sessions cannot be drawn on Daily or higher', text_color = color.white, text_size = size.small)

// ---------- Convert a session's open/close into the chosen display timezone (DST-aware) ----------
f_sessTime(string ses, string srcTZ, string dispTZ, bool isClose) =>
    hh = int(str.tonumber(str.substring(ses, isClose ? 5 : 0, isClose ? 7 : 2)))
    mm = int(str.tonumber(str.substring(ses, isClose ? 7 : 2, isClose ? 9 : 4)))
    ts = timestamp(srcTZ, year(time, srcTZ), month(time, srcTZ), dayofmonth(time, srcTZ), hh, mm)
    str.format_time(ts, 'HH:mm', dispTZ)

var Info_Table = table.new(position.top_right, 4, 5, bgcolor = #283c74, border_color = #53609bcb, border_width = 1, frame_color = #373a46, frame_width = 1)

if show_Info_Table and barstate.islast and isIntraday
    table.cell(Info_Table, 0, 0, 'Sessions: ' + disp_tz, text_color = color.white, text_size = size.small)
    table.merge_cells(Info_Table, 0, 0, 3, 0)
    table.cell(Info_Table, 0, 1, 'Session', text_color = color.white, text_size = size.small)
    table.cell(Info_Table, 1, 1, 'Status',  text_color = color.white, text_size = size.small)
    table.cell(Info_Table, 2, 1, 'Open',    text_color = color.white, text_size = size.small)
    table.cell(Info_Table, 3, 1, 'Close',   text_color = color.white, text_size = size.small)

    table.cell(Info_Table, 0, 2, sesasia_text,    text_color = sesasia_color,    text_size = size.small)
    table.cell(Info_Table, 0, 3, seslondon_text,  text_color = seslondon_color,  text_size = size.small)
    table.cell(Info_Table, 0, 4, sesNewyork_text, text_color = sesNewyork_color, text_size = size.small)

    table.cell(Info_Table, 1, 2, On_sesasia    != 0 ? 'Open' : 'Closed', bgcolor = On_sesasia    != 0 ? #56a3a6 : #db504a, text_color = color.black, text_size = size.small)
    table.cell(Info_Table, 1, 3, On_seslondon  != 0 ? 'Open' : 'Closed', bgcolor = On_seslondon  != 0 ? #56a3a6 : #db504a, text_color = color.black, text_size = size.small)
    table.cell(Info_Table, 1, 4, On_sesNewyork != 0 ? 'Open' : 'Closed', bgcolor = On_sesNewyork != 0 ? #56a3a6 : #db504a, text_color = color.black, text_size = size.small)

    table.cell(Info_Table, 2, 2, f_sessTime(sesasia_ses,    sesasia_tz,    disp_tz, false), text_color = color.white, text_size = size.small)
    table.cell(Info_Table, 2, 3, f_sessTime(seslondon_ses,  seslondon_tz,  disp_tz, false), text_color = color.white, text_size = size.small)
    table.cell(Info_Table, 2, 4, f_sessTime(sesNewyork_ses, sesNewyork_tz, disp_tz, false), text_color = color.white, text_size = size.small)

    table.cell(Info_Table, 3, 2, f_sessTime(sesasia_ses,    sesasia_tz,    disp_tz, true), text_color = color.white, text_size = size.small)
    table.cell(Info_Table, 3, 3, f_sessTime(seslondon_ses,  seslondon_tz,  disp_tz, true), text_color = color.white, text_size = size.small)
    table.cell(Info_Table, 3, 4, f_sessTime(sesNewyork_ses, sesNewyork_tz, disp_tz, true), text_color = color.white, text_size = size.small)
````
