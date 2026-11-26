# Xces' (key levels)

- url: https://www.tradingview.com/script/phCLCifJ-Xces-key-levels/
- type: indicator
- pine_id: PUB;b560844d5c62466bb6c3afe6ee59dff9
- version: 10.0

## Description

Inspired by spaceman's version i made my own version.

[b]Detected levels:[/b]
[list]
[*]Asia, London, and NY session highs/lows.
[*]Current week highs/lows (CWH/CWL) and current month highs/lows (CMH/CML).
  These move with the current period extreme and are not marked swept by the sweep scanner.
[*]Previous day/week/month highs/lows (PDH/PDL, PWH/PWL, PMH/PML).
  These are marked swept when the current corresponding period crosses them, even if the chart history loaded after the actual sweep.
[*]Monday high/low after Monday completes.
[*]TDO, NDOG, and NWOG.
[/list]

[b]Sweep and drawing rules:[/b]
[list]
[*]A level is swept when a chart candle's wick range crosses it with mintick tolerance.
[*]Unswept levels draw in the active-level color.
[*]Swept levels from the current trading week remain visible in the swept-level color.
[*]Swept PWH/PWL/PMH/PML also remain visible in the swept-level color.
[*]Other older swept levels are hidden.
[*]Overlapping visible levels are clustered into one label.
[/list]

Full source code included, have fun.

## Source Code

````pine
//@version=6
indicator("Xces' key level indicator", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=50)

// ============================================================
// Key-level overlay
// ------------------------------------------------------------
// Detected levels:
//   - Asia, London, and NY session highs/lows.
//   - Current week highs/lows (CWH/CWL) and current month highs/lows
//     (CMH/CML). These move with the current period extreme and are not
//     marked swept by the sweep scanner.
//   - Previous day/week/month highs/lows (PDH/PDL, PWH/PWL, PMH/PML).
//     These are marked swept when the current corresponding period crosses
//     them, even if the chart history loaded after the actual sweep.
//   - Monday high/low after Monday completes.
//   - TDO, yearly open (YO), NY 10am open.
//   - NDOG / NWOG as ICT gap boxes (prev close → 17:00 NY open) with CE
//     midpoint lines. Anchored to the ETH session in keyTimezone.
//
// Fixes vs original:
//   1. Monday detection uses exchange dayofweek(time) so MonH/MonL match
//      chart candles (important on UTC crypto like Binance BTCUSDT.P).
//   2. Session/Monday eventTime is the bar that formed the high or low.
//   3. Sweep detection runs only on confirmed bars.
//   4. NY 10am line is drawn every bar (not just barstate.islast).
//   5. NDOG/NWOG use 17:00 NY ETH gap boxes with CE; ETH day id locks them.
//   6. CWH/CWL and PWH/PWL use ETH week (Sunday 17:00); PDH/PDL use NY day.
//   7. Session accumulators reset on session entry only (Asia-safe at midnight).
//   8. f_render_key_levels() runs every bar, not only barstate.islast.
//   9. Cluster label price uses the average of member prices.
//  10. switch cases are one per line (Pine v6 syntax).
//  11. Clustered labels show exact prices when grouped levels differ.
//  12. TDO locks on NY midnight (no na-seed / na!=0 footguns).
//  13. f_set_key_level only moves ray starts when the level price changes.
//  14. Key-level lines ray from the pivot/event bar to the right edge.
//  15. Yearly Open (YO) is the open of the first exchange-calendar daily
//      candle of the year (request.security "D").
// ============================================================

// ------------------------------------------------------------
// Inputs
// ------------------------------------------------------------
keyGroup = "Key Levels settings:"
keyEnableSessionLevels  = input.bool(true,  "Session H/L",   group=keyGroup, tooltip="Show Asia, London, and NY session highs/lows after each session completes.")
keyEnablePriorPeriods   = input.bool(true,  "Prior D/W/M",   group=keyGroup, tooltip="Show PDH/PDL (NY calendar day), PWH/PWL + CWH/CWL (ETH week from Sunday 17:00), and PMH/PML + CMH/CML (exchange month).")
keyEnableMondayLevels   = input.bool(true,  "Monday H/L",    group=keyGroup, tooltip="Show Monday high and low after Monday completes. Monday is the exchange-timezone calendar Monday so levels match chart candles.")
keyEnableGaps           = input.bool(true,  "NWOG/NDOG",     group=keyGroup, tooltip="Show New Week / New Day Opening Gap shaded zones (prev close → 17:00 open in the key-level timezone) with CE midpoint lines.")
keyEnableTdo            = input.bool(true,  "TDO",           group=keyGroup, tooltip="Show the True Day Open (first bar of the NY calendar day). Falls back to exchange daily open if NY midnight is not in loaded history.")
keyEnableYearlyOpen     = input.bool(true,  "Yearly open",   group=keyGroup, tooltip="Show the Yearly Open: open of the first daily candle of the exchange calendar year.")
keyEnableNy10Open       = input.bool(true,  "NY 10am open",  group=keyGroup, tooltip="Show a line from the NY 10:00 candle open through the current bar for the remainder of the NY session.")
keyActiveLevelColor     = input.color(color.new(color.yellow, 15), "Active level color",  group=keyGroup, tooltip="Color used for active, unswept levels, NY 10am open, and gap CE lines.")
keySweptLevelColor      = input.color(color.new(color.gray,   65), "Swept level color",   group=keyGroup, tooltip="Color used for swept levels that remain visible.")
keyGapFillColor         = input.color(color.new(color.yellow, 85), "Gap fill color",     group=keyGroup, tooltip="Fill color for NDOG/NWOG gap boxes. NWOG uses a slightly more transparent fill.")
keyLineWidth            = input.int(1, "Line width", minval=1, maxval=4, group=keyGroup, tooltip="Thickness of key-level, NY 10am, and gap CE lines.")
keyLabelSizeInput       = input.string("normal", "Label size", options=["tiny", "small", "normal", "large", "huge"], group=keyGroup, tooltip="Text size used for key-level, NY 10am, and gap CE labels.")
keyShowPrices           = input.bool(true, "Show prices on labels", group=keyGroup, tooltip="When off, labels show level names only for a cleaner chart.")
keyRightOffsetBars      = input.int(5, "Right edge offset bars", minval=0, maxval=500, group=keyGroup, tooltip="How many bars beyond the visible right edge clustered key levels, labels, and gap boxes are projected.")
keyTimezone             = input.string("America/New_York", "Key-level timezone", group=keyGroup, tooltip="Timezone used to evaluate session windows, ETH 17:00 gap anchors, and day/date labels.")
keyAsiaSession          = input.session("2000-0000", "Asia session",   group=keyGroup, tooltip="Session window used for Asia high/low tracking. Default is the ICT Asian range 20:00-00:00 in the key-level timezone.")
keyLondonSession        = input.session("0200-0500", "London session", group=keyGroup, tooltip="Session window used for London high/low tracking. Default is the ICT London killzone 02:00-05:00 in the key-level timezone.")
keyNySession            = input.session("0930-1600", "NY session",     group=keyGroup, tooltip="Session window used for NY high/low tracking.")

// ------------------------------------------------------------
// Storage
// ------------------------------------------------------------
var array<line>   keyLevelLines   = array.new<line>()
var array<label>  keyLevelLabels  = array.new<label>()
var array<string> keyLevelNames   = array.new<string>()
var array<float>  keyLevelPrices  = array.new<float>()
var array<bool>   keyLevelEnabled = array.new<bool>()
var array<bool>   keyLevelActive  = array.new<bool>()
var array<bool>   keyLevelSwept   = array.new<bool>()
var array<int>    keyLevelTimes   = array.new<int>()
var line          keyNy10OpenLine  = na
var label         keyNy10OpenLabel = na
var box           keyNdogBox       = na
var line          keyNdogCeLine    = na
var label         keyNdogCeLabel   = na
var box           keyNwogBox       = na
var line          keyNwogCeLine    = na
var label         keyNwogCeLabel   = na

// ------------------------------------------------------------
// Helpers
// ------------------------------------------------------------
f_key_label_size() =>
    switch keyLabelSizeInput
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        "huge"   => size.huge
        =>         size.normal

f_key_level_index(string name) =>
    int found = -1
    if array.size(keyLevelNames) > 0
        for i = 0 to array.size(keyLevelNames) - 1
            if found == -1 and array.get(keyLevelNames, i) == name
                found := i
    found

f_price_equal(float a, float b) =>
    not na(a) and not na(b) and math.abs(a - b) <= syminfo.mintick / 2

f_clear_key_level_drawing_at(int i) =>
    line  keyLine  = array.get(keyLevelLines, i)
    label keyLabel = array.get(keyLevelLabels, i)
    if not na(keyLine)
        line.delete(keyLine)
        array.set(keyLevelLines, i, na)
    if not na(keyLabel)
        label.delete(keyLabel)
        array.set(keyLevelLabels, i, na)

f_set_key_level(string name, float price, bool enabled, int eventTime) =>
    if not na(price)
        int idx = f_key_level_index(name)
        if idx == -1
            array.push(keyLevelLines,   na)
            array.push(keyLevelLabels,  na)
            array.push(keyLevelNames,   name)
            array.push(keyLevelPrices,  price)
            array.push(keyLevelEnabled, enabled)
            array.push(keyLevelActive,  enabled)
            array.push(keyLevelSwept,   false)
            array.push(keyLevelTimes,   eventTime)
        else
            float oldPrice = array.get(keyLevelPrices, idx)
            bool  changed  = not f_price_equal(oldPrice, price)
            array.set(keyLevelPrices,  idx, price)
            array.set(keyLevelEnabled, idx, enabled)
            array.set(keyLevelActive,  idx, enabled)
            // Only move the ray start when the level price itself changes —
            // rewriting eventTime every bar made PDH/PWL/etc drift to the right.
            if changed and not na(eventTime)
                array.set(keyLevelTimes, idx, eventTime)
                array.set(keyLevelSwept, idx, false)
            if not enabled
                f_clear_key_level_drawing_at(idx)

f_key_levels_close_for_display(float a, float b) =>
    float denom = math.max(math.abs(a), math.abs(b))
    denom > 0 and math.abs(a - b) / denom <= 0.0001

// ETH day id = most recent 17:00 in keyTimezone (ICT day boundary).
f_key_eth_day_id() =>
    int today1700 = timestamp(keyTimezone,
         year(time, keyTimezone), month(time, keyTimezone),
         dayofmonth(time, keyTimezone), 17, 0)
    if time >= today1700
        today1700
    else
        int prevRef = time - 12 * 60 * 60 * 1000
        timestamp(keyTimezone,
             year(prevRef, keyTimezone), month(prevRef, keyTimezone),
             dayofmonth(prevRef, keyTimezone), 17, 0)

// ETH week starts at Sunday 17:00 in keyTimezone (NWOG open).
f_key_eth_week_start() =>
    int ethId = f_key_eth_day_id()
    int daysBack = dayofweek(ethId, keyTimezone) - dayofweek.sunday
    int approx = ethId - daysBack * 86400000
    timestamp(keyTimezone,
         year(approx, keyTimezone), month(approx, keyTimezone),
         dayofmonth(approx, keyTimezone), 17, 0)

f_key_level_from_current_trading_week(int i) =>
    int levelTime = array.get(keyLevelTimes, i)
    // ETH week (Sunday 17:00 keyTimezone), not exchange timeframe.change("W").
    int weekStart = f_key_eth_week_start()
    not na(levelTime) and not na(weekStart) and levelTime >= weekStart

f_key_level_retained_after_sweep(int i) =>
    string name = array.get(keyLevelNames, i)
    f_key_level_from_current_trading_week(i) or name == "PWH" or name == "PWL" or name == "PMH" or name == "PML"

f_key_level_can_sweep(string name) =>
    name != "CWH" and name != "CWL" and name != "CMH" and name != "CML" and name != "YO"

f_key_level_visible_for_display(int i) =>
    bool swept = array.get(keyLevelSwept, i)
    array.get(keyLevelEnabled, i) and array.get(keyLevelActive, i) and (not swept or f_key_level_retained_after_sweep(i))

f_key_level_is_session_level(string name) =>
    name == "AsiaH" or name == "AsiaL" or name == "AsiaO" or
     name == "LondonH" or name == "LondonL" or name == "LondonO" or
     name == "NYH" or name == "NYL" or name == "NYO"

f_key_level_base_display_name(string name) =>
    switch name
        "AsiaH"   => "Asia high"
        "AsiaL"   => "Asia low"
        "AsiaO"   => "Asia open"
        "LondonH" => "London high"
        "LondonL" => "London low"
        "LondonO" => "London open"
        "NYH"     => "NY high"
        "NYL"     => "NY low"
        "NYO"     => "NY open"
        "CWH"     => "CWH"
        "CWL"     => "CWL"
        "CMH"     => "CMH"
        "CML"     => "CML"
        "YO"      => "YO"
        =>           name

f_month_name(int monthValue) =>
    switch monthValue
        1  => "jan"
        2  => "feb"
        3  => "mar"
        4  => "apr"
        5  => "may"
        6  => "jun"
        7  => "jul"
        8  => "aug"
        9  => "sep"
        10 => "oct"
        11 => "nov"
        12 => "dec"
        =>    ""

f_ordinal_suffix(int dayNumber) =>
    int rem100 = dayNumber % 100
    int rem10  = dayNumber % 10
    rem100 >= 11 and rem100 <= 13 ? "th" :
     rem10 == 1 ? "st" : rem10 == 2 ? "nd" : rem10 == 3 ? "rd" : "th"

f_key_level_older_than_today(int levelTime) =>
    int todayStart    = timestamp(keyTimezone,
         year(time, keyTimezone), month(time, keyTimezone),
         dayofmonth(time, keyTimezone), 0, 0)
    int levelDayStart = timestamp(keyTimezone,
         year(levelTime, keyTimezone), month(levelTime, keyTimezone),
         dayofmonth(levelTime, keyTimezone), 0, 0)
    levelDayStart < todayStart

f_key_level_display_name_at(int i) =>
    string name      = array.get(keyLevelNames, i)
    int    levelTime = array.get(keyLevelTimes, i)
    if f_key_level_is_session_level(name) and not na(levelTime) and f_key_level_older_than_today(levelTime)
        int dayNumber = dayofmonth(levelTime, keyTimezone)
        f_key_level_base_display_name(name) + " (" +
         str.tostring(dayNumber) + f_ordinal_suffix(dayNumber) +
         " " + f_month_name(month(levelTime, keyTimezone)) + ")"
    else
        f_key_level_base_display_name(name)

f_key_level_cluster_text(array<int> members, float displayPrice) =>
    string nameText = ""
    float  firstPrice = displayPrice
    bool   samePrice = true
    int    sz       = array.size(members)
    if sz > 0
        int firstIdx = array.get(members, 0)
        firstPrice := array.get(keyLevelPrices, firstIdx)
        for m = 0 to sz - 1
            int    idx  = array.get(members, m)
            string part = f_key_level_display_name_at(idx)
            nameText  := nameText == "" ? part : nameText + " / " + part
            samePrice := samePrice and f_price_equal(firstPrice, array.get(keyLevelPrices, idx))
    if not keyShowPrices
        nameText
    else if samePrice
        nameText + " @ " + str.tostring(firstPrice, format.mintick)
    else
        string exactText = ""
        for m = 0 to sz - 1
            int idx = array.get(members, m)
            string part = f_key_level_display_name_at(idx) + " @ " + str.tostring(array.get(keyLevelPrices, idx), format.mintick)
            exactText := exactText == "" ? part : exactText + " / " + part
        exactText

f_render_key_levels() =>
    if array.size(keyLevelNames) > 0
        array<bool> rendered    = array.new<bool>(array.size(keyLevelNames), false)
        int keyBarMillis        = math.max(int(timeframe.in_seconds(timeframe.period) * 1000), 1)
        int keyRightVisibleTime = na(chart.right_visible_bar_time) ? time : chart.right_visible_bar_time
        int keyLineEndTime      = keyRightVisibleTime + keyBarMillis * keyRightOffsetBars
        int keyLabelTime        = keyLineEndTime + keyBarMillis * 1
        string keyLblSize       = f_key_label_size()

        for i = 0 to array.size(keyLevelNames) - 1
            if not array.get(rendered, i)
                bool show = f_key_level_visible_for_display(i)
                if not show
                    f_clear_key_level_drawing_at(i)
                    array.set(rendered, i, true)
                else
                    float      basePrice    = array.get(keyLevelPrices, i)
                    bool       clusterSwept = array.get(keyLevelSwept, i)
                    array<int> members      = array.new<int>()
                    array.push(members, i)
                    array.set(rendered, i, true)

                    if i + 1 < array.size(keyLevelNames)
                        for j = i + 1 to array.size(keyLevelNames) - 1
                            if not array.get(rendered, j) and f_key_level_visible_for_display(j) and
                                 f_key_levels_close_for_display(basePrice, array.get(keyLevelPrices, j))
                                array.push(members, j)
                                array.set(rendered, j, true)
                                clusterSwept := clusterSwept or array.get(keyLevelSwept, j)

                    int keyLineStartTime = na
                    for m = 0 to array.size(members) - 1
                        int memberTime = array.get(keyLevelTimes, array.get(members, m))
                        if not na(memberTime) and (na(keyLineStartTime) or memberTime < keyLineStartTime)
                            keyLineStartTime := memberTime
                    if na(keyLineStartTime)
                        keyLineStartTime := time

                    color c        = clusterSwept ? keySweptLevelColor : keyActiveLevelColor
                    line  keyLine  = array.get(keyLevelLines, i)
                    label keyLabel = array.get(keyLevelLabels, i)

                    if na(keyLine)
                        keyLine := line.new(keyLineStartTime, basePrice, keyLineEndTime, basePrice,
                             xloc=xloc.bar_time, color=c, width=keyLineWidth, style=line.style_dotted)
                        array.set(keyLevelLines, i, keyLine)
                    else
                        line.set_xy1(keyLine,  keyLineStartTime, basePrice)
                        line.set_xy2(keyLine,  keyLineEndTime,   basePrice)
                        line.set_color(keyLine, c)
                        line.set_width(keyLine, keyLineWidth)
                        line.set_style(keyLine, line.style_dotted)

                    string labelText = f_key_level_cluster_text(members, basePrice)
                    if na(keyLabel)
                        keyLabel := label.new(keyLabelTime, basePrice, labelText,
                             xloc=xloc.bar_time, style=label.style_label_left,
                             color=color.new(color.black, 100), textcolor=c,
                             size=keyLblSize, textalign=text.align_left)
                        array.set(keyLevelLabels, i, keyLabel)
                    else
                        label.set_text(keyLabel,      labelText)
                        label.set_x(keyLabel,         keyLabelTime)
                        label.set_y(keyLabel,         basePrice)
                        label.set_style(keyLabel,     label.style_label_left)
                        label.set_textcolor(keyLabel,  c)
                        label.set_size(keyLabel,      keyLblSize)
                        label.set_textalign(keyLabel,  text.align_left)

                    if array.size(members) > 1
                        for m = 1 to array.size(members) - 1
                            f_clear_key_level_drawing_at(array.get(members, m))

f_mark_key_level_sweeps(float barHigh, float barLow) =>
    if array.size(keyLevelNames) > 0 and not na(barHigh) and not na(barLow)
        for i = 0 to array.size(keyLevelNames) - 1
            float  level   = array.get(keyLevelPrices, i)
            string name    = array.get(keyLevelNames, i)
            bool   crossed = barLow  <= level + syminfo.mintick / 2 and
                              barHigh >= level - syminfo.mintick / 2
            if f_key_level_can_sweep(name) and
                 array.get(keyLevelEnabled, i) and
                 array.get(keyLevelActive,  i) and
                 not array.get(keyLevelSwept, i) and crossed
                array.set(keyLevelSwept, i, true)

f_mark_key_level_swept_if(string name, bool sweptNow) =>
    if sweptNow
        int idx = f_key_level_index(name)
        if idx != -1 and array.get(keyLevelEnabled, idx) and
             array.get(keyLevelActive, idx) and not array.get(keyLevelSwept, idx)
            array.set(keyLevelSwept, idx, true)

f_gap_more_transparent(color baseFill) =>
    color.new(baseFill, math.min(color.t(baseFill) + 10, 95))

f_gap_has(int leftTime, float gapClose, float gapOpen) =>
    not na(leftTime) and not na(gapClose) and not na(gapOpen) and
         math.abs(gapClose - gapOpen) > syminfo.mintick / 2

f_render_gap_zone(box gapBox, line ceLine, label ceLabel, string name, int leftTime, float gapClose, float gapOpen, color fillColor, color borderColor) =>
    box   outBox   = gapBox
    line  outLine  = ceLine
    label outLabel = ceLabel
    if not f_gap_has(leftTime, gapClose, gapOpen)
        if not na(outBox)
            box.delete(outBox)
            outBox := na
        if not na(outLine)
            line.delete(outLine)
            outLine := na
        if not na(outLabel)
            label.delete(outLabel)
            outLabel := na
    else
        float gapTop   = math.max(gapClose, gapOpen)
        float gapBot   = math.min(gapClose, gapOpen)
        float cePrice  = (gapClose + gapOpen) / 2
        int keyBarMillis        = math.max(int(timeframe.in_seconds(timeframe.period) * 1000), 1)
        int keyRightVisibleTime = na(chart.right_visible_bar_time) ? time : chart.right_visible_bar_time
        int keyRightTime        = keyRightVisibleTime + keyBarMillis * keyRightOffsetBars
        int keyLabelTime        = keyRightTime + keyBarMillis * 1
        string keyLblSize       = f_key_label_size()
        string labelText        = keyShowPrices ?
             name + " @ " + str.tostring(cePrice, format.mintick) : name

        if na(outBox)
            outBox := box.new(leftTime, gapTop, keyRightTime, gapBot,
                 xloc=xloc.bar_time, bgcolor=fillColor, border_color=borderColor,
                 border_width=1, border_style=line.style_dotted)
        else
            box.set_lefttop(outBox, leftTime, gapTop)
            box.set_rightbottom(outBox, keyRightTime, gapBot)
            box.set_bgcolor(outBox, fillColor)
            box.set_border_color(outBox, borderColor)
            box.set_border_width(outBox, 1)
            box.set_border_style(outBox, line.style_dotted)

        if na(outLine)
            outLine := line.new(leftTime, cePrice, keyRightTime, cePrice,
                 xloc=xloc.bar_time, color=borderColor, width=keyLineWidth,
                 style=line.style_dotted)
        else
            line.set_xy1(outLine, leftTime, cePrice)
            line.set_xy2(outLine, keyRightTime, cePrice)
            line.set_color(outLine, borderColor)
            line.set_width(outLine, keyLineWidth)
            line.set_style(outLine, line.style_dotted)

        if na(outLabel)
            outLabel := label.new(keyLabelTime, cePrice, labelText,
                 xloc=xloc.bar_time, style=label.style_label_left,
                 color=color.new(color.black, 100), textcolor=borderColor,
                 size=keyLblSize, textalign=text.align_left)
        else
            label.set_text(outLabel,      labelText)
            label.set_x(outLabel,         keyLabelTime)
            label.set_y(outLabel,         cePrice)
            label.set_style(outLabel,     label.style_label_left)
            label.set_textcolor(outLabel, borderColor)
            label.set_size(outLabel,      keyLblSize)
            label.set_textalign(outLabel, text.align_left)
    [outBox, outLine, outLabel]

// ------------------------------------------------------------
// TDO  (True Day Open — first bar of the NY calendar day)
// Defined early so keyNewNyCalendarDay is available for session/PDH below.
// Do NOT use `ta.change(x) != 0` (na != 0 is true on bar 0) or seed with
// `or na(keyTdo)` (mid-load would lock the first chart bar as TDO).
// ------------------------------------------------------------
int  keyNyDayStart = timestamp(keyTimezone,
      year(time, keyTimezone), month(time, keyTimezone),
      dayofmonth(time, keyTimezone), 0, 0)
bool keyNewNyCalendarDay = not na(keyNyDayStart[1]) and keyNyDayStart != keyNyDayStart[1]

var float keyTdo     = na
var int   keyTdoTime = na

if keyNewNyCalendarDay
    keyTdo     := open
    keyTdoTime := time

// Exchange daily open only as fallback when NY midnight was not in history.
[keyExchDayOpen, keyExchDayOpenTime] = request.security(syminfo.tickerid, "D",
     [open, time],
     barmerge.gaps_off, barmerge.lookahead_on, calc_bars_count=5)
float keyTdoPrice = not na(keyTdo) ? keyTdo : keyExchDayOpen
int   keyTdoAnchor = not na(keyTdoTime) ? keyTdoTime : int(keyExchDayOpenTime)

f_set_key_level("TDO", keyTdoPrice, keyEnableTdo, na(keyTdoAnchor) ? time : keyTdoAnchor)

// ------------------------------------------------------------
// YO  (Yearly Open)
// Open of the first *daily* candle of the exchange calendar year.
// Always sourced from request.security("D") so weekly/monthly charts
// and keyTimezone session offsets cannot pick the wrong bar (e.g. NY
// midnight shifting Binance UTC daily Jan 1 onto a different open).
// ------------------------------------------------------------
f_yo_daily() =>
    var float yoOpen = na
    var int   yoYear = na
    var int   yoTime = na
    if not na(time[1]) and year(time) != year(time[1])
        yoOpen := open
        yoYear := year(time)
        yoTime := time
    [yoOpen, yoYear, yoTime]

[keyYoFromDaily, keyYoYearFromDaily, keyYoTimeFromDaily] =
     request.security(syminfo.tickerid, "D", f_yo_daily(),
         barmerge.gaps_off, barmerge.lookahead_on, calc_bars_count=400)

bool keyYoDailyOk = not na(keyYoFromDaily) and int(keyYoYearFromDaily) == year(time)

f_set_key_level("YO", keyYoDailyOk ? keyYoFromDaily : na, keyEnableYearlyOpen,
     keyYoDailyOk ? int(keyYoTimeFromDaily) : time)

// ------------------------------------------------------------
// Session tracking
// Reset only on session *entry* (was out, now in). Do not couple Asia to
// NY midnight — Asia 20:00-00:00 crosses midnight and a calendar-day reset
// would wipe the killzone mid-session.
// ------------------------------------------------------------
bool keyInAsia   = not na(time(timeframe.period, keyAsiaSession,   keyTimezone))
bool keyInLondon = not na(time(timeframe.period, keyLondonSession, keyTimezone))
bool keyInNy     = not na(time(timeframe.period, keyNySession,     keyTimezone))

var float keyAsiaHigh   = na
var float keyAsiaLow    = na
var float keyLondonHigh = na
var float keyLondonLow  = na
var float keyNyHigh     = na
var float keyNyLow      = na
var bool  keyWasInAsia   = false
var bool  keyWasInLondon = false
var bool  keyWasInNy     = false

var int keyAsiaHighTime   = na
var int keyAsiaLowTime    = na
var int keyLondonHighTime = na
var int keyLondonLowTime  = na
var int keyNyHighTime     = na
var int keyNyLowTime      = na

if keyEnableSessionLevels
    if keyInAsia
        bool keyStartAsia = not keyWasInAsia
        if keyStartAsia
            keyAsiaHigh     := high
            keyAsiaLow      := low
            keyAsiaHighTime := time
            keyAsiaLowTime  := time
        else
            if high > keyAsiaHigh
                keyAsiaHigh     := high
                keyAsiaHighTime := time
            if low < keyAsiaLow
                keyAsiaLow     := low
                keyAsiaLowTime := time
    else if keyWasInAsia
        f_set_key_level("AsiaH", keyAsiaHigh, true, keyAsiaHighTime)
        f_set_key_level("AsiaL", keyAsiaLow,  true, keyAsiaLowTime)

    if keyInLondon
        bool keyStartLondon = not keyWasInLondon
        if keyStartLondon
            keyLondonHigh     := high
            keyLondonLow      := low
            keyLondonHighTime := time
            keyLondonLowTime  := time
        else
            if high > keyLondonHigh
                keyLondonHigh     := high
                keyLondonHighTime := time
            if low < keyLondonLow
                keyLondonLow     := low
                keyLondonLowTime := time
    else if keyWasInLondon
        f_set_key_level("LondonH", keyLondonHigh, true, keyLondonHighTime)
        f_set_key_level("LondonL", keyLondonLow,  true, keyLondonLowTime)

    if keyInNy
        bool keyStartNy = not keyWasInNy
        if keyStartNy
            keyNyHigh     := high
            keyNyLow      := low
            keyNyHighTime := time
            keyNyLowTime  := time
        else
            if high > keyNyHigh
                keyNyHigh     := high
                keyNyHighTime := time
            if low < keyNyLow
                keyNyLow     := low
                keyNyLowTime := time
    else if keyWasInNy
        f_set_key_level("NYH", keyNyHigh, true, keyNyHighTime)
        f_set_key_level("NYL", keyNyLow,  true, keyNyLowTime)
else
    f_set_key_level("AsiaH",   keyAsiaHigh,   false, time)
    f_set_key_level("AsiaL",   keyAsiaLow,    false, time)
    f_set_key_level("LondonH", keyLondonHigh, false, time)
    f_set_key_level("LondonL", keyLondonLow,  false, time)
    f_set_key_level("NYH",     keyNyHigh,     false, time)
    f_set_key_level("NYL",     keyNyLow,      false, time)

keyWasInAsia   := keyInAsia
keyWasInLondon := keyInLondon
keyWasInNy     := keyInNy

// ------------------------------------------------------------
// Prior periods (D / W / M)
//
// PDH/PDL follow the same NY calendar day as TDO (not exchange "D" alone).
// CWH/CWL and PWH/PWL follow the ETH week (Sunday 17:00 keyTimezone).
// HTF request.security values are fallbacks when the prior period was not
// seen in loaded chart history. Month stays on exchange M.
// ------------------------------------------------------------
[keyPrevDayHighHtf, keyPrevDayLowHtf, keyPrevDayTimeHtf] =
     request.security(syminfo.tickerid, "D",
         [high[1], low[1], time[1]],
         barmerge.gaps_off, barmerge.lookahead_on, calc_bars_count=20)

[keyPrevWeekHighHtf, keyPrevWeekLowHtf, keyPrevWeekTimeHtf] =
     request.security(syminfo.tickerid, "W",
         [high[1], low[1], time[1]],
         barmerge.gaps_off, barmerge.lookahead_on, calc_bars_count=20)

[keyPrevMonthHigh, keyPrevMonthLow, keyPrevMonthTime] =
     request.security(syminfo.tickerid, "M",
         [high[1], low[1], time[1]],
         barmerge.gaps_off, barmerge.lookahead_on, calc_bars_count=20)

// --- NY calendar day (aligns with TDO) ---
var float keyCurrNyDayHigh     = na
var float keyCurrNyDayLow      = na
var int   keyCurrNyDayHighTime = na
var int   keyCurrNyDayLowTime  = na
var float keyPrevNyDayHigh     = na
var float keyPrevNyDayLow      = na
var int   keyPrevNyDayHighTime = na
var int   keyPrevNyDayLowTime  = na

if keyNewNyCalendarDay
    if not na(keyCurrNyDayHigh)
        keyPrevNyDayHigh     := keyCurrNyDayHigh
        keyPrevNyDayLow      := keyCurrNyDayLow
        keyPrevNyDayHighTime := keyCurrNyDayHighTime
        keyPrevNyDayLowTime  := keyCurrNyDayLowTime
    keyCurrNyDayHigh     := high
    keyCurrNyDayLow      := low
    keyCurrNyDayHighTime := time
    keyCurrNyDayLowTime  := time
else
    if na(keyCurrNyDayHigh) or high > keyCurrNyDayHigh
        keyCurrNyDayHigh     := high
        keyCurrNyDayHighTime := time
    if na(keyCurrNyDayLow) or low < keyCurrNyDayLow
        keyCurrNyDayLow     := low
        keyCurrNyDayLowTime := time

float keyPdhPrice = not na(keyPrevNyDayHigh) ? keyPrevNyDayHigh : keyPrevDayHighHtf
float keyPdlPrice = not na(keyPrevNyDayLow)  ? keyPrevNyDayLow  : keyPrevDayLowHtf
int   keyPdhTime  = not na(keyPrevNyDayHighTime) ? keyPrevNyDayHighTime : int(keyPrevDayTimeHtf)
int   keyPdlTime  = not na(keyPrevNyDayLowTime)  ? keyPrevNyDayLowTime  : int(keyPrevDayTimeHtf)

// --- ETH week (Sunday 17:00 → next Sunday 17:00) ---
int  keyEthWeekStart = f_key_eth_week_start()
bool keyNewEthWeek   = not na(keyEthWeekStart[1]) and keyEthWeekStart != keyEthWeekStart[1]

var float keyCurrWeekHigh      = na
var float keyCurrWeekLow       = na
var int   keyCurrWeekHighTime  = na
var int   keyCurrWeekLowTime   = na
var float keyPrevEthWeekHigh   = na
var float keyPrevEthWeekLow    = na
var int   keyPrevEthWeekHighTime = na
var int   keyPrevEthWeekLowTime  = na

if keyNewEthWeek
    if not na(keyCurrWeekHigh)
        keyPrevEthWeekHigh     := keyCurrWeekHigh
        keyPrevEthWeekLow      := keyCurrWeekLow
        keyPrevEthWeekHighTime := keyCurrWeekHighTime
        keyPrevEthWeekLowTime  := keyCurrWeekLowTime
    keyCurrWeekHigh     := high
    keyCurrWeekLow      := low
    keyCurrWeekHighTime := time
    keyCurrWeekLowTime  := time
else
    if na(keyCurrWeekHigh) or high > keyCurrWeekHigh
        keyCurrWeekHigh     := high
        keyCurrWeekHighTime := time
    if na(keyCurrWeekLow) or low < keyCurrWeekLow
        keyCurrWeekLow     := low
        keyCurrWeekLowTime := time

float keyPwhPrice = not na(keyPrevEthWeekHigh) ? keyPrevEthWeekHigh : keyPrevWeekHighHtf
float keyPwlPrice = not na(keyPrevEthWeekLow)  ? keyPrevEthWeekLow  : keyPrevWeekLowHtf
int   keyPwhTime  = not na(keyPrevEthWeekHighTime) ? keyPrevEthWeekHighTime : int(keyPrevWeekTimeHtf)
int   keyPwlTime  = not na(keyPrevEthWeekLowTime)  ? keyPrevEthWeekLowTime  : int(keyPrevWeekTimeHtf)

// --- Exchange month (unchanged) ---
bool keyNewMonthP = timeframe.change("M")

var float keyCurrMonthHigh     = na
var float keyCurrMonthLow      = na
var int   keyCurrMonthHighTime = na
var int   keyCurrMonthLowTime  = na

if keyNewMonthP
    keyCurrMonthHigh     := high
    keyCurrMonthLow      := low
    keyCurrMonthHighTime := time
    keyCurrMonthLowTime  := time
else
    if na(keyCurrMonthHigh) or high > keyCurrMonthHigh
        keyCurrMonthHigh     := high
        keyCurrMonthHighTime := time
    if na(keyCurrMonthLow) or low < keyCurrMonthLow
        keyCurrMonthLow     := low
        keyCurrMonthLowTime := time

f_set_key_level("PDH", keyPdhPrice,       keyEnablePriorPeriods, na(keyPdhTime) ? time : keyPdhTime)
f_set_key_level("PDL", keyPdlPrice,       keyEnablePriorPeriods, na(keyPdlTime) ? time : keyPdlTime)
f_set_key_level("CWH", keyCurrWeekHigh,   keyEnablePriorPeriods, na(keyCurrWeekHighTime)  ? time : keyCurrWeekHighTime)
f_set_key_level("CWL", keyCurrWeekLow,    keyEnablePriorPeriods, na(keyCurrWeekLowTime)   ? time : keyCurrWeekLowTime)
f_set_key_level("PWH", keyPwhPrice,       keyEnablePriorPeriods, na(keyPwhTime) ? time : keyPwhTime)
f_set_key_level("PWL", keyPwlPrice,       keyEnablePriorPeriods, na(keyPwlTime) ? time : keyPwlTime)
f_set_key_level("CMH", keyCurrMonthHigh,  keyEnablePriorPeriods, na(keyCurrMonthHighTime) ? time : keyCurrMonthHighTime)
f_set_key_level("CML", keyCurrMonthLow,   keyEnablePriorPeriods, na(keyCurrMonthLowTime)  ? time : keyCurrMonthLowTime)
f_set_key_level("PMH", keyPrevMonthHigh,  keyEnablePriorPeriods, na(keyPrevMonthTime) ? time : keyPrevMonthTime)
f_set_key_level("PML", keyPrevMonthLow,   keyEnablePriorPeriods, na(keyPrevMonthTime) ? time : keyPrevMonthTime)

f_mark_key_level_swept_if("PDH", not na(keyCurrNyDayHigh) and not na(keyPdhPrice) and keyCurrNyDayHigh >= keyPdhPrice - syminfo.mintick / 2)
f_mark_key_level_swept_if("PDL", not na(keyCurrNyDayLow)  and not na(keyPdlPrice) and keyCurrNyDayLow  <= keyPdlPrice + syminfo.mintick / 2)
f_mark_key_level_swept_if("PWH", not na(keyCurrWeekHigh)  and not na(keyPwhPrice) and keyCurrWeekHigh  >= keyPwhPrice - syminfo.mintick / 2)
f_mark_key_level_swept_if("PWL", not na(keyCurrWeekLow)   and not na(keyPwlPrice) and keyCurrWeekLow   <= keyPwlPrice + syminfo.mintick / 2)
f_mark_key_level_swept_if("PMH", not na(keyCurrMonthHigh) and not na(keyPrevMonthHigh) and keyCurrMonthHigh >= keyPrevMonthHigh - syminfo.mintick / 2)
f_mark_key_level_swept_if("PML", not na(keyCurrMonthLow)  and not na(keyPrevMonthLow)  and keyCurrMonthLow  <= keyPrevMonthLow  + syminfo.mintick / 2)

// ------------------------------------------------------------
// Monday H/L
// Exchange-timezone Monday so MonH/MonL match chart candles on symbols
// like Binance BTCUSDT.P (UTC). Using keyTimezone (NY) here misses lows
// that print on exchange-Monday bars that are still Sunday in New York,
// which is why MonL could sit above a PWL that formed on a Monday candle.
// ------------------------------------------------------------
int  keyDow      = dayofweek(time)
bool keyIsMonday = keyDow == dayofweek.monday

var bool  keyWasMonday       = false
var float keyMondayHigh      = na
var float keyMondayLow       = na
var int   keyMondayHighTime  = na
var int   keyMondayLowTime   = na

if keyEnableMondayLevels
    if keyIsMonday
        if not keyWasMonday
            keyMondayHigh     := high
            keyMondayLow      := low
            keyMondayHighTime := time
            keyMondayLowTime  := time
        else
            if high > keyMondayHigh
                keyMondayHigh     := high
                keyMondayHighTime := time
            if low < keyMondayLow
                keyMondayLow     := low
                keyMondayLowTime := time
    else if keyWasMonday
        f_set_key_level("MonH", keyMondayHigh, true, keyMondayHighTime)
        f_set_key_level("MonL", keyMondayLow,  true, keyMondayLowTime)
else
    f_set_key_level("MonH", keyMondayHigh, false, time)
    f_set_key_level("MonL", keyMondayLow,  false, time)

keyWasMonday := keyIsMonday

// ------------------------------------------------------------
// NY 10am open
// FIX #4: draw on every bar inside the window, not only barstate.islast.
// ------------------------------------------------------------
bool keyInNy10Remainder         = not na(time(timeframe.period, "1000-1600", keyTimezone))
var bool  keyWasInNy10Remainder = false
var float keyNy10Open           = na
var int   keyNy10OpenBarIndex   = na

if keyInNy10Remainder and not keyWasInNy10Remainder
    keyNy10Open         := open
    keyNy10OpenBarIndex := bar_index

keyWasInNy10Remainder := keyInNy10Remainder

bool keyShowNy10Open = keyEnableNy10Open and keyInNy10Remainder and
     not na(keyNy10Open) and not na(keyNy10OpenBarIndex)

if keyShowNy10Open
    int    keyNy10LabelBarIndex = bar_index + 1
    string keyNy10LabelText     = keyShowPrices ?
         "NY 10am @ " + str.tostring(keyNy10Open, format.mintick) : "NY 10am"
    string keyNy10LblSize       = f_key_label_size()
    if na(keyNy10OpenLine)
        keyNy10OpenLine := line.new(keyNy10OpenBarIndex, keyNy10Open,
             bar_index, keyNy10Open,
             xloc=xloc.bar_index, color=keyActiveLevelColor, width=keyLineWidth, style=line.style_solid)
    else
        line.set_xy1(keyNy10OpenLine,   keyNy10OpenBarIndex, keyNy10Open)
        line.set_xy2(keyNy10OpenLine,   bar_index,           keyNy10Open)
        line.set_color(keyNy10OpenLine, keyActiveLevelColor)
        line.set_width(keyNy10OpenLine, keyLineWidth)
        line.set_style(keyNy10OpenLine, line.style_solid)
    if na(keyNy10OpenLabel)
        keyNy10OpenLabel := label.new(keyNy10LabelBarIndex, keyNy10Open, keyNy10LabelText,
             xloc=xloc.bar_index, style=label.style_label_left,
             color=color.new(color.black, 100), textcolor=keyActiveLevelColor,
             size=keyNy10LblSize, textalign=text.align_left)
    else
        label.set_text(keyNy10OpenLabel,      keyNy10LabelText)
        label.set_x(keyNy10OpenLabel,         keyNy10LabelBarIndex)
        label.set_y(keyNy10OpenLabel,         keyNy10Open)
        label.set_style(keyNy10OpenLabel,     label.style_label_left)
        label.set_textcolor(keyNy10OpenLabel, keyActiveLevelColor)
        label.set_size(keyNy10OpenLabel,      keyNy10LblSize)
        label.set_textalign(keyNy10OpenLabel, text.align_left)
else
    if not na(keyNy10OpenLine)
        line.delete(keyNy10OpenLine)
        keyNy10OpenLine := na
    if not na(keyNy10OpenLabel)
        label.delete(keyNy10OpenLabel)
        keyNy10OpenLabel := na

// ------------------------------------------------------------
// NDOG / NWOG — ICT gap boxes + CE
// ETH day opens at 17:00 in keyTimezone (f_key_eth_day_id). Levels lock
// for that whole ETH day and only recompute when the ETH day id changes.
// NWOG opens on Sunday 17:00 (or Monday when Friday was the prior ETH day
// for symbols that skip Sunday).
// ------------------------------------------------------------
int  keyEthDayId   = f_key_eth_day_id()
bool keyNewEthDay  = not na(keyEthDayId[1]) and keyEthDayId != keyEthDayId[1]
int  keyEthOpenDow = dayofweek(keyEthDayId, keyTimezone)
int  keyEthPrevDow = dayofweek(keyEthDayId[1], keyTimezone)
bool keyIsNwogOpen = keyNewEthDay and (
     keyEthOpenDow == dayofweek.sunday or
     (keyEthOpenDow == dayofweek.monday and keyEthPrevDow == dayofweek.friday))

var float keyNdogClose    = na
var float keyNdogOpen     = na
var int   keyNdogLeftTime = na
var float keyNwogClose    = na
var float keyNwogOpen     = na
var int   keyNwogLeftTime = na

if keyNewEthDay
    keyNdogClose    := close[1]
    keyNdogOpen     := open
    keyNdogLeftTime := time[1]
    if keyIsNwogOpen
        keyNwogClose    := close[1]
        keyNwogOpen     := open
        keyNwogLeftTime := time[1]

if keyEnableGaps
    [keyNdogBoxOut, keyNdogLineOut, keyNdogLabelOut] = f_render_gap_zone(keyNdogBox, keyNdogCeLine, keyNdogCeLabel,
         "NDOG CE", keyNdogLeftTime, keyNdogClose, keyNdogOpen,
         keyGapFillColor, keyActiveLevelColor)
    keyNdogBox     := keyNdogBoxOut
    keyNdogCeLine  := keyNdogLineOut
    keyNdogCeLabel := keyNdogLabelOut

    [keyNwogBoxOut, keyNwogLineOut, keyNwogLabelOut] = f_render_gap_zone(keyNwogBox, keyNwogCeLine, keyNwogCeLabel,
         "NWOG CE", keyNwogLeftTime, keyNwogClose, keyNwogOpen,
         f_gap_more_transparent(keyGapFillColor),
         color.new(keyActiveLevelColor, 25))
    keyNwogBox     := keyNwogBoxOut
    keyNwogCeLine  := keyNwogLineOut
    keyNwogCeLabel := keyNwogLabelOut
else
    if not na(keyNdogBox)
        box.delete(keyNdogBox)
        keyNdogBox := na
    if not na(keyNdogCeLine)
        line.delete(keyNdogCeLine)
        keyNdogCeLine := na
    if not na(keyNdogCeLabel)
        label.delete(keyNdogCeLabel)
        keyNdogCeLabel := na
    if not na(keyNwogBox)
        box.delete(keyNwogBox)
        keyNwogBox := na
    if not na(keyNwogCeLine)
        line.delete(keyNwogCeLine)
        keyNwogCeLine := na
    if not na(keyNwogCeLabel)
        label.delete(keyNwogCeLabel)
        keyNwogCeLabel := na

// ------------------------------------------------------------
// Sweep detection — confirmed bars only (FIX #3)
// ------------------------------------------------------------
if barstate.isconfirmed
    f_mark_key_level_sweeps(high, low)

// ------------------------------------------------------------
// Rendering — every bar (FIX #8)
// ------------------------------------------------------------
f_render_key_levels()
````
