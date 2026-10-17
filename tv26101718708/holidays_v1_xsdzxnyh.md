# Holidays v1

- url: https://www.tradingview.com/script/XSDZXNyH-Holidays-v1/
- type: indicator
- pine_id: PUB;57b6de72f51e45f583af24d75be84f92
- version: 1.0

## Description

[image]https://www.tradingview.com/x/EeBPp5Qt/[/image]

[b]1. Overview[/b]
Holidays — marks trading halts at the world's major stock exchanges directly on the TradingView chart. For each configured holiday, a colored background block spans the full calendar day. At the bottom of the chart, auto-sizing labels display the holiday name and the flag emojis of all affected exchanges.
At a glance, you can see whether one or more markets are closed on any given day — critical information for assessing liquidity conditions, spread behavior, and correlation reliability across instruments.

[b]Key Features[/b]
[list]
[*]8 pre-configured exchanges with verified 2026 holiday data
[*]10 freely assignable custom slots for user-defined holidays or events
[*]Every holiday individually toggleable — enable only what you need
[*]Per-exchange color and configurable session duration (default: full 24h calendar day)
[*]Smart label merging: when multiple exchanges share the same holiday on the same day (e.g. New Year's Day), a single label shows the holiday name with all country flags combined
[*]Labels at chart bottom with automatic round-robin stacking across 4 rows — no overlap, no text truncation
[*]Info table showing active and upcoming holidays, color-coded by exchange, with flag and date columns
[*]Three independent visibility toggles: background blocks, labels, and info table can each be shown or hidden separately
[*]Works for past AND future dates (box.new with xloc.bar_time)
[*]Visible chart range detection: label positions recalculate automatically when scrolling or zooming
[/list]

[b]2. Smart Label Merging & Stacking[/b]
Many major holidays — such as New Year's Day, Good Friday, or Christmas — are observed simultaneously by multiple exchanges. Without merging, these would produce 5-8 overlapping labels on the same day.

[b]How Merging Works[/b]
The indicator groups all holidays by date AND name. When multiple exchanges have the same holiday on the same day, they are merged into a single label:
[list]
[*]Line 1: Holiday name (e.g. 'New Year's Day')
[*]Line 2: Combined flag emojis of all affected exchanges (e.g. '🇺🇸 🇬🇧 🇨🇦 🇩🇪 🇯🇵 🇨🇳 🇦🇺 🇰🇷')
[/list]
Different holidays on the same day (e.g. JP Greenery Day and KR Children's Day on May 4/5) remain as separate labels and are stacked vertically.

[b]Round-Robin Row Stacking[/b]
Labels are distributed across 4 rows at the bottom of the chart using a round-robin pattern: label 1 goes to row 1, label 2 to row 2, label 3 to row 3, label 4 to row 4, label 5 back to row 1, and so on. This guarantees that no two adjacent labels share the same vertical position, regardless of how closely spaced the holidays are in time.
The vertical spacing between rows scales automatically with the visible price range — when you zoom in, rows spread further apart; when you zoom out, they compress proportionally.

[b]3. Supported Exchanges[/b]
The indicator includes pre-filled and verified holiday data for eight exchanges. Each exchange group has its own color, a master enable toggle, and a configurable session duration (default: 24 hours = full calendar day).

Holidays (Configurable session duration)
Default: full calendar day (24h)

[b]🇺🇸[/b]
USA — NYSE / NASDAQ
Holidays: 9

[b]🇬🇧[/b]
London — LSE
Holidays: 8

[b]🇨🇦[/b]
Canada — TSX
Holidays: 8

[b]🇩🇪[/b]
Germany — Xetra
Holidays: 7

[b]🇯🇵[/b]
Japan — TSE
Holidays: 8

[b]🇨🇳[/b]
China — SSE
Holidays: 7

[b]🇦🇺[/b]
Australia — ASX
Holidays: 8

[b]🇰🇷[/b]
South Korea — KRX
Holidays: 7

[b]★[/b]
Custom (10 slots)
Freely configurable

[b]4. Settings[/b]
All settings are accessible via the gear icon next to the indicator name in the chart legend, or by right-clicking the indicator and selecting 'Settings'.

[b]4.1 Style Settings[/b]
Background Opacity
Transparency of the background blocks. 0 = fully opaque, 100 = invisible. Default: 85.

Border Color
Color of the outline drawn around each holiday block.

Border Style
Line style of the outline: Solid, Dashed, Dotted, or None.

Border Width (px)
Thickness of the outline in pixels (0–4).

Show Background Blocks
Toggle the full-height colored background blocks on/off. Can be disabled while keeping labels and/or table visible.

Show Block Labels
Toggle the holiday name labels at the bottom of the chart on/off.

Label Font Size
Font size for labels: Tiny, Small, Normal, Large.

Label Text Color
Text color of the bottom labels.

Label Background Transparency
Transparency of the label background. Uses the exchange color. 0 = opaque, 100 = invisible.

Show Info Table
Toggle the info table on/off. Works independently of blocks and labels.

Table Position
Corner of the chart: Top Right, Top Left, Bottom Right, Bottom Left.

Table: max upcoming rows
Maximum number of upcoming holidays in the table. Active holidays always shown additionally.

Table Font Size
Font size: Tiny, Small, Normal, Large.

Table Border Color
Grid line and frame color of the table.

Table Background Color
Background color of the table frame.

Table Upcoming Row Transparency
Transparency of upcoming (not yet active) holiday rows. Active rows always at 30%.

[b]4.2 Per-Exchange Settings[/b]
Each of the eight exchanges has its own settings group:
✓ Enable [Exchange] Group: Enable or disable all holidays for this exchange.
Color: Color used for background blocks, labels, and table rows.
Session hours: Duration of the holiday highlight (default: 24h = full calendar day). Can be reduced to show only the actual trading session if desired.
Below these, each individual holiday has a checkbox (enable/disable) and a date/time input.

[b]4.3 Custom Holidays[/b]
The '▼ Custom Holidays' group provides 10 free slots. Each slot has a checkbox, a name field, and a start timestamp. Custom slots share a common session duration setting.

[b]5. The Info Table[/b]
The info table displays active and upcoming holidays in a compact, color-coded format.

[b]Table Structure[/b]
[list]
[*]Column 1 (Flag): Country flag emoji or ★ for custom holidays
[*]Column 2 (Holiday): Holiday name with exchange prefix (e.g. 'GB Early May BH')
[*]Column 3 (Date): Date in UTC (format: MMM dd)
[/list]

[b]Display Logic[/b]
[list]
[*]Active holidays: strong exchange color, white text
[*]Upcoming holidays (within 90 days): dimmed exchange color at configurable transparency
[*]Maximum N upcoming entries shown (configurable), active holidays always additional
[*]Entries sorted chronologically by date
[/list]

[b]6. Three Independent Visibility Toggles[/b]

The indicator provides three separate toggles in the Style Settings, allowing you to show exactly what you need:

Toggle & What it controls:

Show Background Blocks
Full-height colored blocks spanning the entire price range. Provides an immediate visual cue that a holiday is in effect.

Show Block Labels
Auto-sizing labels at the chart bottom showing the holiday name and country flags. Labels use round-robin row stacking to prevent overlap.

Show Info Table
Compact table listing active and upcoming holidays. Can serve as the sole holiday indicator when blocks and labels are disabled.

Example combinations: table-only mode for a clean chart with minimal visual clutter; blocks-only for quick visual scanning without text; all three enabled for maximum information density.

[b]7. Technical Notes
[/b]
[b]7.1 Visible Range Detection
[/b]The indicator tracks the visible price range using chart.left_visible_bar_time, which triggers a recalculation whenever the user scrolls or zooms. The lowest and highest visible prices are computed incrementally using var float variables — no ta.lowest or ta.highest with series length, avoiding Pine's historical buffer allocation issues entirely.

[b]7.2 Past and Future Display
[/b]Holiday blocks use box.new() with xloc=xloc.bar_time, which is not limited to historical bars. Holidays are rendered correctly for future dates as soon as the corresponding time range is visible on the chart axis.

[b]7.3 Performance and Limits
[/b]Up to 500 boxes and 500 labels (configurable via indicator declaration)
All drawing objects redrawn only on barstate.islast — no performance impact on historical bars
Holiday data stored in global arrays to stay within Pine v6's 254-element-per-function limit
8.4 Holiday Data
All pre-filled dates refer to 2026 and have been verified against official exchange calendars from NYSE/ICE, LSE, TSX, Xetra/Deutsche Börse, JPX, SSE, ASX, and KRX. All timestamps are set to 00:00 UTC with a default duration of 24 hours, marking the full calendar day. For subsequent years, dates must be updated manually.

[b]8. Use Cases
[/b]Liquidity Analysis
On days when multiple exchanges are simultaneously closed — Good Friday affects NYSE, LSE, TSX, Xetra, and ASX — the merged label shows all five flags at once, and the overlapping background blocks create a visually darker zone. This signals exceptionally thin market liquidity.

[b]Forward Planning
[/b]The info table lists upcoming holidays chronologically. Traders can identify well in advance when reduced activity is expected — useful for position sizing, stop placement, and avoiding entries before liquidity gaps.

[b]Custom Event Marking
[/b]The 10 custom slots can mark FOMC meetings, ECB rate decisions, NFP releases, or any other scheduled events using the same visual system.

If you have questions just contact me or put your ideas or wishes in the comments.

## Source Code

````pine
//@version=6
// =============================================================================
//  Holidays — Multi Exchange  (v4.0)
//  Highlights -holiday sessions on the chart.
//  Exchanges: USA (NYSE), London (LSE), Canada (TSX), Germany (Xetra),
//             Japan (TSE), China (SSE), Australia (ASX), South Korea (KRX)
//             + 10 user-defined custom holidays.
//
//  Architecture: all holiday data is collected into arrays after inputs.
//  Functions receive only those arrays → stays within Pine v6 external-element limit.
// =============================================================================
indicator("Holidays — Multi Exchange", "Holidays",
     overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ── Visible range — tracked with var to avoid ta.lowest/highest buffer issues ─
// chart.left_visible_bar_time triggers script recalc from bar 0 on scroll/zoom
_isVis = time >= chart.left_visible_bar_time
var float _visLo = na
var float _visHi = na
if not _isVis
    _visLo := na
    _visHi := na
else
    if na(_visLo)
        _visLo := low
        _visHi := high
    else
        _visLo := math.min(_visLo, low)
        _visHi := math.max(_visHi, high)


g_style      = "▼ Style Settings"
opacity      = input.int(85, "Background Opacity (0=opaque, 100=invisible)",
                 minval=0, maxval=100, group=g_style)
borderClr    = input.color(color.gray, "Border Color", group=g_style)
borderS      = input.string("Solid", "Border Style",
                 options=["Solid","Dashed","Dotted","None"], group=g_style)
borderW      = input.int(1, "Border Width (px)", minval=0, maxval=4, group=g_style)
showBlocks   = input.bool(true, "Show Background Blocks", group=g_style)
showLabels   = input.bool(true, "Show Block Labels", group=g_style,
                 tooltip="Displays exchange flag and holiday name at the bottom of each block.")
labelSize    = input.string("Small", "Label Font Size",
                 options=["Tiny","Small","Normal","Large"], group=g_style)
labelTxtClr  = input.color(color.white, "Label Text Color", group=g_style)
labelBgTran  = input.int(20, "Label Background Transparency",
                 minval=0, maxval=100, group=g_style,
                 tooltip="0 = fully opaque, 100 = invisible. Uses the exchange color.")
showTbl      = input.bool(true, "Show Info Table", group=g_style)
tblPos       = input.string("Top Right", "Table Position",
                 options=["Top Right","Top Left","Bottom Right","Bottom Left"],
                 group=g_style)
tblMaxUp     = input.int(20, "Table: max upcoming rows", minval=1, maxval=50,
                 tooltip="Active holidays shown first, then next N upcoming.", group=g_style)
tblFontSize  = input.string("Small", "Table Font Size",
                 options=["Tiny","Small","Normal","Large"], group=g_style)
tblBorderClr = input.color(color.new(color.gray, 50), "Table Border Color", group=g_style)
tblBgClr     = input.color(color.new(color.black, 20), "Table Background Color", group=g_style)
tblBgTranUp  = input.int(75, "Table Upcoming Row Transparency",
                 minval=0, maxval=100, group=g_style,
                 tooltip="0 = fully opaque, 100 = invisible. Active rows always use 30%.")

bStyle    = switch borderS
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid
useBorder = borderS != "None"

tblFont   = switch tblFontSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    => size.small

lblFont   = switch labelSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    => size.small

MS_HOUR   = 60 * 60 * 1000

// =============================================================================
//  USA  (NYSE / NASDAQ)  — session 13:30–20:00 UTC (09:30–16:00 ET)
// =============================================================================
g1     = "▼ USA — NYSE / NASDAQ"
us_en  = input.bool(true,  "✓ Enable USA Group", group=g1)
us_clr = input.color(color.new(#B22222,0), "Color", group=g1)
us_dur = input.float(24.0, "Session hours", minval=0.5, maxval=24, step=0.5, group=g1)

us01_en = input.bool(true, "New Year's Day",          inline="us01", group=g1)
us01_ts = input.time(timestamp("2026-01-01 00:00"),   "", inline="us01", group=g1)
us02_en = input.bool(true, "MLK Jr. Day",             inline="us02", group=g1)
us02_ts = input.time(timestamp("2026-01-19 00:00"),   "", inline="us02", group=g1)
us03_en = input.bool(true, "Presidents' Day",         inline="us03", group=g1)
us03_ts = input.time(timestamp("2026-02-16 00:00"),   "", inline="us03", group=g1)
us04_en = input.bool(true, "Good Friday",             inline="us04", group=g1)
us04_ts = input.time(timestamp("2026-04-03 00:00"),   "", inline="us04", group=g1)
us05_en = input.bool(true, "Memorial Day",            inline="us05", group=g1)
us05_ts = input.time(timestamp("2026-05-25 00:00"),   "", inline="us05", group=g1)
us06_en = input.bool(true, "Juneteenth",              inline="us06", group=g1)
us06_ts = input.time(timestamp("2026-06-19 00:00"),   "", inline="us06", group=g1)
us07_en = input.bool(true, "Independence Day (obs.)", inline="us07", group=g1)
us07_ts = input.time(timestamp("2026-07-03 00:00"),   "", inline="us07", group=g1)
us08_en = input.bool(true, "Labor Day",               inline="us08", group=g1)
us08_ts = input.time(timestamp("2026-09-07 00:00"),   "", inline="us08", group=g1)
us09_en = input.bool(true, "Thanksgiving",            inline="us09", group=g1)
us09_ts = input.time(timestamp("2026-11-26 00:00"),   "", inline="us09", group=g1)

// =============================================================================
//  LONDON  (LSE)  — session 08:00–16:30 UTC (GMT) / 07:00–15:30 (BST)
// =============================================================================
g2     = "▼ London — LSE"
uk_en  = input.bool(true,  "✓ Enable UK Group", group=g2)
uk_clr = input.color(color.new(#003087,0), "Color", group=g2)
uk_dur = input.float(24.0, "Session hours", minval=0.5, maxval=24, step=0.5, group=g2)

uk01_en = input.bool(true, "New Year's Day",          inline="uk01", group=g2)
uk01_ts = input.time(timestamp("2026-01-01 00:00"),   "", inline="uk01", group=g2)
uk02_en = input.bool(true, "Good Friday",             inline="uk02", group=g2)
uk02_ts = input.time(timestamp("2026-04-03 00:00"),   "", inline="uk02", group=g2)
uk03_en = input.bool(true, "Easter Monday",           inline="uk03", group=g2)
uk03_ts = input.time(timestamp("2026-04-06 00:00"),   "", inline="uk03", group=g2)
uk04_en = input.bool(true, "Early May Bank Holiday",  inline="uk04", group=g2)
uk04_ts = input.time(timestamp("2026-05-04 00:00"),   "", inline="uk04", group=g2)
uk05_en = input.bool(true, "Spring Bank Holiday",     inline="uk05", group=g2)
uk05_ts = input.time(timestamp("2026-05-25 00:00"),   "", inline="uk05", group=g2)
uk06_en = input.bool(true, "Summer Bank Holiday",     inline="uk06", group=g2)
uk06_ts = input.time(timestamp("2026-08-31 00:00"),   "", inline="uk06", group=g2)
uk07_en = input.bool(true, "Christmas Day",           inline="uk07", group=g2)
uk07_ts = input.time(timestamp("2026-12-25 00:00"),   "", inline="uk07", group=g2)
uk08_en = input.bool(true, "Boxing Day (substitute)", inline="uk08", group=g2)
uk08_ts = input.time(timestamp("2026-12-28 00:00"),   "", inline="uk08", group=g2)

// =============================================================================
//  CANADA  (TSX)  — same session hours as NYSE
// =============================================================================
g3     = "▼ Canada — TSX"
ca_en  = input.bool(true,  "✓ Enable Canada Group", group=g3)
ca_clr = input.color(color.new(#CC0000,0), "Color", group=g3)
ca_dur = input.float(24.0, "Session hours", minval=0.5, maxval=24, step=0.5, group=g3)

ca01_en = input.bool(true, "New Year's Day",       inline="ca01", group=g3)
ca01_ts = input.time(timestamp("2026-01-01 00:00"), "", inline="ca01", group=g3)
ca02_en = input.bool(true, "Family Day",           inline="ca02", group=g3)
ca02_ts = input.time(timestamp("2026-02-16 00:00"), "", inline="ca02", group=g3)
ca03_en = input.bool(true, "Good Friday",          inline="ca03", group=g3)
ca03_ts = input.time(timestamp("2026-04-03 00:00"), "", inline="ca03", group=g3)
ca04_en = input.bool(true, "Victoria Day",         inline="ca04", group=g3)
ca04_ts = input.time(timestamp("2026-05-18 00:00"), "", inline="ca04", group=g3)
ca05_en = input.bool(true, "Canada Day",           inline="ca05", group=g3)
ca05_ts = input.time(timestamp("2026-07-01 00:00"), "", inline="ca05", group=g3)
ca06_en = input.bool(true, "Labour Day",           inline="ca06", group=g3)
ca06_ts = input.time(timestamp("2026-09-07 00:00"), "", inline="ca06", group=g3)
ca07_en = input.bool(true, "Thanksgiving (CA)",    inline="ca07", group=g3)
ca07_ts = input.time(timestamp("2026-10-12 00:00"), "", inline="ca07", group=g3)
ca08_en = input.bool(true, "Christmas Day",        inline="ca08", group=g3)
ca08_ts = input.time(timestamp("2026-12-25 00:00"), "", inline="ca08", group=g3)

// =============================================================================
//  GERMANY  (Xetra)  — session 08:00–17:30 UTC (CET) / 07:00–16:30 (CEST)
// =============================================================================
g4     = "▼ Germany — Xetra"
de_en  = input.bool(true,  "✓ Enable Germany Group", group=g4)
de_clr = input.color(color.new(#FFCC00,0), "Color", group=g4)
de_dur = input.float(24.0, "Session hours", minval=0.5, maxval=24, step=0.5, group=g4)

de01_en = input.bool(true, "New Year's Day",          inline="de01", group=g4)
de01_ts = input.time(timestamp("2026-01-01 00:00"),   "", inline="de01", group=g4)
de02_en = input.bool(true, "Good Friday",             inline="de02", group=g4)
de02_ts = input.time(timestamp("2026-04-03 00:00"),   "", inline="de02", group=g4)
de03_en = input.bool(true, "Easter Monday",           inline="de03", group=g4)
de03_ts = input.time(timestamp("2026-04-06 00:00"),   "", inline="de03", group=g4)
de04_en = input.bool(true, "Labour Day (May 1)",      inline="de04", group=g4)
de04_ts = input.time(timestamp("2026-05-01 00:00"),   "", inline="de04", group=g4)
de05_en = input.bool(true, "Christmas Eve (½ day)",   inline="de05", group=g4)
de05_ts = input.time(timestamp("2026-12-24 00:00"),   "", inline="de05", group=g4)
de06_en = input.bool(true, "Christmas Day",           inline="de06", group=g4)
de06_ts = input.time(timestamp("2026-12-25 00:00"),   "", inline="de06", group=g4)
de07_en = input.bool(true, "New Year's Eve (½ day)",  inline="de07", group=g4)
de07_ts = input.time(timestamp("2026-12-31 00:00"),   "", inline="de07", group=g4)

// =============================================================================
//  JAPAN  (TSE)  — session 00:00–06:30 UTC (09:00–15:30 JST)
// =============================================================================
g5     = "▼ Japan — TSE"
jp_en  = input.bool(true,  "✓ Enable Japan Group", group=g5)
jp_clr = input.color(color.new(#BC002D,0), "Color", group=g5)
jp_dur = input.float(24.0, "Session hours", minval=0.5, maxval=24, step=0.5, group=g5)

jp01_en = input.bool(true, "New Year's Day",          inline="jp01", group=g5)
jp01_ts = input.time(timestamp("2026-01-01 00:00"),   "", inline="jp01", group=g5)
jp02_en = input.bool(true, "Coming of Age Day",       inline="jp02", group=g5)
jp02_ts = input.time(timestamp("2026-01-12 00:00"),   "", inline="jp02", group=g5)
jp03_en = input.bool(true, "National Foundation Day", inline="jp03", group=g5)
jp03_ts = input.time(timestamp("2026-02-11 00:00"),   "", inline="jp03", group=g5)
jp04_en = input.bool(true, "Showa Day",               inline="jp04", group=g5)
jp04_ts = input.time(timestamp("2026-04-29 00:00"),   "", inline="jp04", group=g5)
jp05_en = input.bool(true, "Greenery Day",            inline="jp05", group=g5)
jp05_ts = input.time(timestamp("2026-05-04 00:00"),   "", inline="jp05", group=g5)
jp06_en = input.bool(true, "Children's Day (JP)",     inline="jp06", group=g5)
jp06_ts = input.time(timestamp("2026-05-05 00:00"),   "", inline="jp06", group=g5)
jp07_en = input.bool(true, "Mountain Day",            inline="jp07", group=g5)
jp07_ts = input.time(timestamp("2026-08-11 00:00"),   "", inline="jp07", group=g5)
jp08_en = input.bool(true, "Sports Day",              inline="jp08", group=g5)
jp08_ts = input.time(timestamp("2026-10-12 00:00"),   "", inline="jp08", group=g5)

// =============================================================================
//  CHINA  (SSE)  — session 01:30–07:00 UTC (09:30–15:00 CST)
// =============================================================================
g6     = "▼ China — SSE"
cn_en  = input.bool(true,  "✓ Enable China Group", group=g6)
cn_clr = input.color(color.new(#DE2910,0), "Color", group=g6)
cn_dur = input.float(24.0, "Session hours", minval=0.5, maxval=24, step=0.5, group=g6)

cn01_en = input.bool(true, "New Year's Day",         inline="cn01", group=g6)
cn01_ts = input.time(timestamp("2026-01-01 00:00"),  "", inline="cn01", group=g6)
cn02_en = input.bool(true, "Chinese New Year",       inline="cn02", group=g6)
cn02_ts = input.time(timestamp("2026-02-17 00:00"),  "", inline="cn02", group=g6)
cn03_en = input.bool(true, "Qingming Festival",      inline="cn03", group=g6)
cn03_ts = input.time(timestamp("2026-04-06 00:00"),  "", inline="cn03", group=g6)
cn04_en = input.bool(true, "Labour Day (CN)",        inline="cn04", group=g6)
cn04_ts = input.time(timestamp("2026-05-01 00:00"),  "", inline="cn04", group=g6)
cn05_en = input.bool(true, "Dragon Boat Festival",   inline="cn05", group=g6)
cn05_ts = input.time(timestamp("2026-06-19 00:00"),  "", inline="cn05", group=g6)
cn06_en = input.bool(true, "Mid-Autumn Festival",    inline="cn06", group=g6)
cn06_ts = input.time(timestamp("2026-09-25 00:00"),  "", inline="cn06", group=g6)
cn07_en = input.bool(true, "National Day",           inline="cn07", group=g6)
cn07_ts = input.time(timestamp("2026-10-01 00:00"),  "", inline="cn07", group=g6)

// =============================================================================
//  AUSTRALIA  (ASX)  — session 00:00–06:00 UTC (AEST) / 23:00–05:00 (AEDT)
// =============================================================================
g7     = "▼ Australia — ASX"
au_en  = input.bool(true,  "✓ Enable Australia Group", group=g7)
au_clr = input.color(color.new(#00843D,0), "Color", group=g7)
au_dur = input.float(24.0, "Session hours", minval=0.5, maxval=24, step=0.5, group=g7)

au01_en = input.bool(true, "New Year's Day",      inline="au01", group=g7)
au01_ts = input.time(timestamp("2025-12-31 00:00"), "", inline="au01", group=g7)
au02_en = input.bool(true, "Australia Day",       inline="au02", group=g7)
au02_ts = input.time(timestamp("2026-01-25 00:00"), "", inline="au02", group=g7)
au03_en = input.bool(true, "Good Friday",         inline="au03", group=g7)
au03_ts = input.time(timestamp("2026-04-02 00:00"), "", inline="au03", group=g7)
au04_en = input.bool(true, "Easter Monday",       inline="au04", group=g7)
au04_ts = input.time(timestamp("2026-04-05 00:00"), "", inline="au04", group=g7)
au05_en = input.bool(true, "ANZAC Day (obs.)",    inline="au05", group=g7)
au05_ts = input.time(timestamp("2026-04-26 00:00"), "", inline="au05", group=g7)
au06_en = input.bool(true, "King's Birthday",     inline="au06", group=g7)
au06_ts = input.time(timestamp("2026-06-08 00:00"), "", inline="au06", group=g7)
au07_en = input.bool(true, "Christmas Day",       inline="au07", group=g7)
au07_ts = input.time(timestamp("2026-12-25 00:00"), "", inline="au07", group=g7)
au08_en = input.bool(true, "Boxing Day (obs.)",   inline="au08", group=g7)
au08_ts = input.time(timestamp("2026-12-28 00:00"), "", inline="au08", group=g7)

// =============================================================================
//  SOUTH KOREA  (KRX)  — session 00:00–06:30 UTC (09:00–15:30 KST)
// =============================================================================
g8     = "▼ South Korea — KRX"
kr_en  = input.bool(true,  "✓ Enable Korea Group", group=g8)
kr_clr = input.color(color.new(#003478,0), "Color", group=g8)
kr_dur = input.float(24.0, "Session hours", minval=0.5, maxval=24, step=0.5, group=g8)

kr01_en = input.bool(true, "New Year's Day",              inline="kr01", group=g8)
kr01_ts = input.time(timestamp("2026-01-01 00:00"),       "", inline="kr01", group=g8)
kr02_en = input.bool(true, "Seollal (Lunar New Year)",    inline="kr02", group=g8)
kr02_ts = input.time(timestamp("2026-02-16 00:00"),       "", inline="kr02", group=g8)
kr03_en = input.bool(true, "Independence Movement Day",   inline="kr03", group=g8)
kr03_ts = input.time(timestamp("2026-03-02 00:00"),       "", inline="kr03", group=g8)
kr04_en = input.bool(true, "Children's Day (KR)",         inline="kr04", group=g8)
kr04_ts = input.time(timestamp("2026-05-05 00:00"),       "", inline="kr04", group=g8)
kr05_en = input.bool(true, "Memorial Day (KR)",           inline="kr05", group=g8)
kr05_ts = input.time(timestamp("2026-06-08 00:00"),       "", inline="kr05", group=g8)
kr06_en = input.bool(true, "Chuseok (Harvest Festival)",  inline="kr06", group=g8)
kr06_ts = input.time(timestamp("2026-09-24 00:00"),       "", inline="kr06", group=g8)
kr07_en = input.bool(true, "Hangeul Day",                 inline="kr07", group=g8)
kr07_ts = input.time(timestamp("2026-10-09 00:00"),       "", inline="kr07", group=g8)

// =============================================================================
//  CUSTOM HOLIDAYS  (10 slots)
// =============================================================================
g9     = "▼ Custom Holidays (User-Defined)"
cu_en  = input.bool(true,  "✓ Enable Custom Group", group=g9)
cu_clr = input.color(color.new(color.orange,0), "Color", group=g9)
cu_dur = input.float(24.0, "Session hours", minval=0.5, maxval=48, step=0.5, group=g9)

cu01_en = input.bool(false, "Slot 1",        inline="cu01a", group=g9)
cu01_nm = input.string("Custom 1", "Name",   inline="cu01a", group=g9)
cu01_ts = input.time(timestamp("2026-01-01 00:00"), "Slot 1: Start (UTC)", group=g9)
cu02_en = input.bool(false, "Slot 2",        inline="cu02a", group=g9)
cu02_nm = input.string("Custom 2", "Name",   inline="cu02a", group=g9)
cu02_ts = input.time(timestamp("2026-01-01 00:00"), "Slot 2: Start (UTC)", group=g9)
cu03_en = input.bool(false, "Slot 3",        inline="cu03a", group=g9)
cu03_nm = input.string("Custom 3", "Name",   inline="cu03a", group=g9)
cu03_ts = input.time(timestamp("2026-01-01 00:00"), "Slot 3: Start (UTC)", group=g9)
cu04_en = input.bool(false, "Slot 4",        inline="cu04a", group=g9)
cu04_nm = input.string("Custom 4", "Name",   inline="cu04a", group=g9)
cu04_ts = input.time(timestamp("2026-01-01 00:00"), "Slot 4: Start (UTC)", group=g9)
cu05_en = input.bool(false, "Slot 5",        inline="cu05a", group=g9)
cu05_nm = input.string("Custom 5", "Name",   inline="cu05a", group=g9)
cu05_ts = input.time(timestamp("2026-01-01 00:00"), "Slot 5: Start (UTC)", group=g9)
cu06_en = input.bool(false, "Slot 6",        inline="cu06a", group=g9)
cu06_nm = input.string("Custom 6", "Name",   inline="cu06a", group=g9)
cu06_ts = input.time(timestamp("2026-01-01 00:00"), "Slot 6: Start (UTC)", group=g9)
cu07_en = input.bool(false, "Slot 7",        inline="cu07a", group=g9)
cu07_nm = input.string("Custom 7", "Name",   inline="cu07a", group=g9)
cu07_ts = input.time(timestamp("2026-01-01 00:00"), "Slot 7: Start (UTC)", group=g9)
cu08_en = input.bool(false, "Slot 8",        inline="cu08a", group=g9)
cu08_nm = input.string("Custom 8", "Name",   inline="cu08a", group=g9)
cu08_ts = input.time(timestamp("2026-01-01 00:00"), "Slot 8: Start (UTC)", group=g9)
cu09_en = input.bool(false, "Slot 9",        inline="cu09a", group=g9)
cu09_nm = input.string("Custom 9", "Name",   inline="cu09a", group=g9)
cu09_ts = input.time(timestamp("2026-01-01 00:00"), "Slot 9: Start (UTC)", group=g9)
cu10_en = input.bool(false, "Slot 10",       inline="cu10a", group=g9)
cu10_nm = input.string("Custom 10", "Name",  inline="cu10a", group=g9)
cu10_ts = input.time(timestamp("2026-01-01 00:00"), "Slot 10: Start (UTC)", group=g9)

// =============================================================================
//  COLLECT ALL HOLIDAYS INTO ARRAYS
//  This is the key architectural fix: functions receive arrays, not 288 individual
//  variables. Pine v6 limit: 254 external elements per function.
// =============================================================================
var _en   = array.new<bool>()
var _ts   = array.new<int>()
var _durH = array.new<float>()
var _clr  = array.new<color>()
var _nm   = array.new<string>()
var _idx  = array.new<int>()    // exchange strip index: 0=USA 1=UK 2=CA 3=DE 4=JP 5=CN 6=AU 7=KR 8=Custom

// Build once (inputs are simple, so this executes correctly on bar 0 via var init)
// We use a one-time flag to fill arrays only once
var bool _built = false
if not _built
    _built := true
    // USA
    array.push(_en, us_en and us01_en)
    array.push(_ts, us01_ts)
    array.push(_durH, us_dur)
    array.push(_clr, us_clr)
    array.push(_nm, "🇺🇸 New Year's Day")
    array.push(_idx, 0)
    array.push(_en, us_en and us02_en)
    array.push(_ts, us02_ts)
    array.push(_durH, us_dur)
    array.push(_clr, us_clr)
    array.push(_nm, "🇺🇸 MLK Jr. Day")
    array.push(_idx, 0)
    array.push(_en, us_en and us03_en)
    array.push(_ts, us03_ts)
    array.push(_durH, us_dur)
    array.push(_clr, us_clr)
    array.push(_nm, "🇺🇸 Presidents' Day")
    array.push(_idx, 0)
    array.push(_en, us_en and us04_en)
    array.push(_ts, us04_ts)
    array.push(_durH, us_dur)
    array.push(_clr, us_clr)
    array.push(_nm, "🇺🇸 Good Friday")
    array.push(_idx, 0)
    array.push(_en, us_en and us05_en)
    array.push(_ts, us05_ts)
    array.push(_durH, us_dur)
    array.push(_clr, us_clr)
    array.push(_nm, "🇺🇸 Memorial Day")
    array.push(_idx, 0)
    array.push(_en, us_en and us06_en)
    array.push(_ts, us06_ts)
    array.push(_durH, us_dur)
    array.push(_clr, us_clr)
    array.push(_nm, "🇺🇸 Juneteenth")
    array.push(_idx, 0)
    array.push(_en, us_en and us07_en)
    array.push(_ts, us07_ts)
    array.push(_durH, us_dur)
    array.push(_clr, us_clr)
    array.push(_nm, "🇺🇸 Independence Day")
    array.push(_idx, 0)
    array.push(_en, us_en and us08_en)
    array.push(_ts, us08_ts)
    array.push(_durH, us_dur)
    array.push(_clr, us_clr)
    array.push(_nm, "🇺🇸 Labor Day")
    array.push(_idx, 0)
    array.push(_en, us_en and us09_en)
    array.push(_ts, us09_ts)
    array.push(_durH, us_dur)
    array.push(_clr, us_clr)
    array.push(_nm, "🇺🇸 Thanksgiving")
    array.push(_idx, 0)
    // UK
    array.push(_en, uk_en and uk01_en)
    array.push(_ts, uk01_ts)
    array.push(_durH, uk_dur)
    array.push(_clr, uk_clr)
    array.push(_nm, "🇬🇧 New Year's Day")
    array.push(_idx, 1)
    array.push(_en, uk_en and uk02_en)
    array.push(_ts, uk02_ts)
    array.push(_durH, uk_dur)
    array.push(_clr, uk_clr)
    array.push(_nm, "🇬🇧 Good Friday")
    array.push(_idx, 1)
    array.push(_en, uk_en and uk03_en)
    array.push(_ts, uk03_ts)
    array.push(_durH, uk_dur)
    array.push(_clr, uk_clr)
    array.push(_nm, "🇬🇧 Easter Monday")
    array.push(_idx, 1)
    array.push(_en, uk_en and uk04_en)
    array.push(_ts, uk04_ts)
    array.push(_durH, uk_dur)
    array.push(_clr, uk_clr)
    array.push(_nm, "🇬🇧 Early May BH")
    array.push(_idx, 1)
    array.push(_en, uk_en and uk05_en)
    array.push(_ts, uk05_ts)
    array.push(_durH, uk_dur)
    array.push(_clr, uk_clr)
    array.push(_nm, "🇬🇧 Spring BH")
    array.push(_idx, 1)
    array.push(_en, uk_en and uk06_en)
    array.push(_ts, uk06_ts)
    array.push(_durH, uk_dur)
    array.push(_clr, uk_clr)
    array.push(_nm, "🇬🇧 Summer BH")
    array.push(_idx, 1)
    array.push(_en, uk_en and uk07_en)
    array.push(_ts, uk07_ts)
    array.push(_durH, uk_dur)
    array.push(_clr, uk_clr)
    array.push(_nm, "🇬🇧 Christmas Day")
    array.push(_idx, 1)
    array.push(_en, uk_en and uk08_en)
    array.push(_ts, uk08_ts)
    array.push(_durH, uk_dur)
    array.push(_clr, uk_clr)
    array.push(_nm, "🇬🇧 Boxing Day")
    array.push(_idx, 1)
    // Canada
    array.push(_en, ca_en and ca01_en)
    array.push(_ts, ca01_ts)
    array.push(_durH, ca_dur)
    array.push(_clr, ca_clr)
    array.push(_nm, "🇨🇦 New Year's Day")
    array.push(_idx, 2)
    array.push(_en, ca_en and ca02_en)
    array.push(_ts, ca02_ts)
    array.push(_durH, ca_dur)
    array.push(_clr, ca_clr)
    array.push(_nm, "🇨🇦 Family Day")
    array.push(_idx, 2)
    array.push(_en, ca_en and ca03_en)
    array.push(_ts, ca03_ts)
    array.push(_durH, ca_dur)
    array.push(_clr, ca_clr)
    array.push(_nm, "🇨🇦 Good Friday")
    array.push(_idx, 2)
    array.push(_en, ca_en and ca04_en)
    array.push(_ts, ca04_ts)
    array.push(_durH, ca_dur)
    array.push(_clr, ca_clr)
    array.push(_nm, "🇨🇦 Victoria Day")
    array.push(_idx, 2)
    array.push(_en, ca_en and ca05_en)
    array.push(_ts, ca05_ts)
    array.push(_durH, ca_dur)
    array.push(_clr, ca_clr)
    array.push(_nm, "🇨🇦 Canada Day")
    array.push(_idx, 2)
    array.push(_en, ca_en and ca06_en)
    array.push(_ts, ca06_ts)
    array.push(_durH, ca_dur)
    array.push(_clr, ca_clr)
    array.push(_nm, "🇨🇦 Labour Day")
    array.push(_idx, 2)
    array.push(_en, ca_en and ca07_en)
    array.push(_ts, ca07_ts)
    array.push(_durH, ca_dur)
    array.push(_clr, ca_clr)
    array.push(_nm, "🇨🇦 Thanksgiving")
    array.push(_idx, 2)
    array.push(_en, ca_en and ca08_en)
    array.push(_ts, ca08_ts)
    array.push(_durH, ca_dur)
    array.push(_clr, ca_clr)
    array.push(_nm, "🇨🇦 Christmas Day")
    array.push(_idx, 2)
    // Germany
    array.push(_en, de_en and de01_en)
    array.push(_ts, de01_ts)
    array.push(_durH, de_dur)
    array.push(_clr, de_clr)
    array.push(_nm, "🇩🇪 New Year's Day")
    array.push(_idx, 3)
    array.push(_en, de_en and de02_en)
    array.push(_ts, de02_ts)
    array.push(_durH, de_dur)
    array.push(_clr, de_clr)
    array.push(_nm, "🇩🇪 Good Friday")
    array.push(_idx, 3)
    array.push(_en, de_en and de03_en)
    array.push(_ts, de03_ts)
    array.push(_durH, de_dur)
    array.push(_clr, de_clr)
    array.push(_nm, "🇩🇪 Easter Monday")
    array.push(_idx, 3)
    array.push(_en, de_en and de04_en)
    array.push(_ts, de04_ts)
    array.push(_durH, de_dur)
    array.push(_clr, de_clr)
    array.push(_nm, "🇩🇪 Labour Day")
    array.push(_idx, 3)
    array.push(_en, de_en and de05_en)
    array.push(_ts, de05_ts)
    array.push(_durH, de_dur)
    array.push(_clr, de_clr)
    array.push(_nm, "🇩🇪 Christmas Eve")
    array.push(_idx, 3)
    array.push(_en, de_en and de06_en)
    array.push(_ts, de06_ts)
    array.push(_durH, de_dur)
    array.push(_clr, de_clr)
    array.push(_nm, "🇩🇪 Christmas Day")
    array.push(_idx, 3)
    array.push(_en, de_en and de07_en)
    array.push(_ts, de07_ts)
    array.push(_durH, de_dur)
    array.push(_clr, de_clr)
    array.push(_nm, "🇩🇪 New Year's Eve")
    array.push(_idx, 3)
    // Japan
    array.push(_en, jp_en and jp01_en)
    array.push(_ts, jp01_ts)
    array.push(_durH, jp_dur)
    array.push(_clr, jp_clr)
    array.push(_nm, "🇯🇵 New Year's Day")
    array.push(_idx, 4)
    array.push(_en, jp_en and jp02_en)
    array.push(_ts, jp02_ts)
    array.push(_durH, jp_dur)
    array.push(_clr, jp_clr)
    array.push(_nm, "🇯🇵 Coming of Age Day")
    array.push(_idx, 4)
    array.push(_en, jp_en and jp03_en)
    array.push(_ts, jp03_ts)
    array.push(_durH, jp_dur)
    array.push(_clr, jp_clr)
    array.push(_nm, "🇯🇵 National Foundation Day")
    array.push(_idx, 4)
    array.push(_en, jp_en and jp04_en)
    array.push(_ts, jp04_ts)
    array.push(_durH, jp_dur)
    array.push(_clr, jp_clr)
    array.push(_nm, "🇯🇵 Showa Day")
    array.push(_idx, 4)
    array.push(_en, jp_en and jp05_en)
    array.push(_ts, jp05_ts)
    array.push(_durH, jp_dur)
    array.push(_clr, jp_clr)
    array.push(_nm, "🇯🇵 Greenery Day")
    array.push(_idx, 4)
    array.push(_en, jp_en and jp06_en)
    array.push(_ts, jp06_ts)
    array.push(_durH, jp_dur)
    array.push(_clr, jp_clr)
    array.push(_nm, "🇯🇵 Children's Day")
    array.push(_idx, 4)
    array.push(_en, jp_en and jp07_en)
    array.push(_ts, jp07_ts)
    array.push(_durH, jp_dur)
    array.push(_clr, jp_clr)
    array.push(_nm, "🇯🇵 Mountain Day")
    array.push(_idx, 4)
    array.push(_en, jp_en and jp08_en)
    array.push(_ts, jp08_ts)
    array.push(_durH, jp_dur)
    array.push(_clr, jp_clr)
    array.push(_nm, "🇯🇵 Sports Day")
    array.push(_idx, 4)
    // China
    array.push(_en, cn_en and cn01_en)
    array.push(_ts, cn01_ts)
    array.push(_durH, cn_dur)
    array.push(_clr, cn_clr)
    array.push(_nm, "🇨🇳 New Year's Day")
    array.push(_idx, 5)
    array.push(_en, cn_en and cn02_en)
    array.push(_ts, cn02_ts)
    array.push(_durH, cn_dur)
    array.push(_clr, cn_clr)
    array.push(_nm, "🇨🇳 Chinese New Year")
    array.push(_idx, 5)
    array.push(_en, cn_en and cn03_en)
    array.push(_ts, cn03_ts)
    array.push(_durH, cn_dur)
    array.push(_clr, cn_clr)
    array.push(_nm, "🇨🇳 Qingming Festival")
    array.push(_idx, 5)
    array.push(_en, cn_en and cn04_en)
    array.push(_ts, cn04_ts)
    array.push(_durH, cn_dur)
    array.push(_clr, cn_clr)
    array.push(_nm, "🇨🇳 Labour Day")
    array.push(_idx, 5)
    array.push(_en, cn_en and cn05_en)
    array.push(_ts, cn05_ts)
    array.push(_durH, cn_dur)
    array.push(_clr, cn_clr)
    array.push(_nm, "🇨🇳 Dragon Boat Festival")
    array.push(_idx, 5)
    array.push(_en, cn_en and cn06_en)
    array.push(_ts, cn06_ts)
    array.push(_durH, cn_dur)
    array.push(_clr, cn_clr)
    array.push(_nm, "🇨🇳 Mid-Autumn Festival")
    array.push(_idx, 5)
    array.push(_en, cn_en and cn07_en)
    array.push(_ts, cn07_ts)
    array.push(_durH, cn_dur)
    array.push(_clr, cn_clr)
    array.push(_nm, "🇨🇳 National Day")
    array.push(_idx, 5)
    // Australia
    array.push(_en, au_en and au01_en)
    array.push(_ts, au01_ts)
    array.push(_durH, au_dur)
    array.push(_clr, au_clr)
    array.push(_nm, "🇦🇺 New Year's Day")
    array.push(_idx, 6)
    array.push(_en, au_en and au02_en)
    array.push(_ts, au02_ts)
    array.push(_durH, au_dur)
    array.push(_clr, au_clr)
    array.push(_nm, "🇦🇺 Australia Day")
    array.push(_idx, 6)
    array.push(_en, au_en and au03_en)
    array.push(_ts, au03_ts)
    array.push(_durH, au_dur)
    array.push(_clr, au_clr)
    array.push(_nm, "🇦🇺 Good Friday")
    array.push(_idx, 6)
    array.push(_en, au_en and au04_en)
    array.push(_ts, au04_ts)
    array.push(_durH, au_dur)
    array.push(_clr, au_clr)
    array.push(_nm, "🇦🇺 Easter Monday")
    array.push(_idx, 6)
    array.push(_en, au_en and au05_en)
    array.push(_ts, au05_ts)
    array.push(_durH, au_dur)
    array.push(_clr, au_clr)
    array.push(_nm, "🇦🇺 ANZAC Day")
    array.push(_idx, 6)
    array.push(_en, au_en and au06_en)
    array.push(_ts, au06_ts)
    array.push(_durH, au_dur)
    array.push(_clr, au_clr)
    array.push(_nm, "🇦🇺 King's Birthday")
    array.push(_idx, 6)
    array.push(_en, au_en and au07_en)
    array.push(_ts, au07_ts)
    array.push(_durH, au_dur)
    array.push(_clr, au_clr)
    array.push(_nm, "🇦🇺 Christmas Day")
    array.push(_idx, 6)
    array.push(_en, au_en and au08_en)
    array.push(_ts, au08_ts)
    array.push(_durH, au_dur)
    array.push(_clr, au_clr)
    array.push(_nm, "🇦🇺 Boxing Day")
    array.push(_idx, 6)
    // South Korea
    array.push(_en, kr_en and kr01_en)
    array.push(_ts, kr01_ts)
    array.push(_durH, kr_dur)
    array.push(_clr, kr_clr)
    array.push(_nm, "🇰🇷 New Year's Day")
    array.push(_idx, 7)
    array.push(_en, kr_en and kr02_en)
    array.push(_ts, kr02_ts)
    array.push(_durH, kr_dur)
    array.push(_clr, kr_clr)
    array.push(_nm, "🇰🇷 Seollal")
    array.push(_idx, 7)
    array.push(_en, kr_en and kr03_en)
    array.push(_ts, kr03_ts)
    array.push(_durH, kr_dur)
    array.push(_clr, kr_clr)
    array.push(_nm, "🇰🇷 Independence Movement")
    array.push(_idx, 7)
    array.push(_en, kr_en and kr04_en)
    array.push(_ts, kr04_ts)
    array.push(_durH, kr_dur)
    array.push(_clr, kr_clr)
    array.push(_nm, "🇰🇷 Children's Day")
    array.push(_idx, 7)
    array.push(_en, kr_en and kr05_en)
    array.push(_ts, kr05_ts)
    array.push(_durH, kr_dur)
    array.push(_clr, kr_clr)
    array.push(_nm, "🇰🇷 Memorial Day")
    array.push(_idx, 7)
    array.push(_en, kr_en and kr06_en)
    array.push(_ts, kr06_ts)
    array.push(_durH, kr_dur)
    array.push(_clr, kr_clr)
    array.push(_nm, "🇰🇷 Chuseok")
    array.push(_idx, 7)
    array.push(_en, kr_en and kr07_en)
    array.push(_ts, kr07_ts)
    array.push(_durH, kr_dur)
    array.push(_clr, kr_clr)
    array.push(_nm, "🇰🇷 Hangeul Day")
    array.push(_idx, 7)
    // Custom
    array.push(_en, cu_en and cu01_en)
    array.push(_ts, cu01_ts)
    array.push(_durH, cu_dur)
    array.push(_clr, cu_clr)
    array.push(_nm, "★ " + cu01_nm)
    array.push(_idx, 8)
    array.push(_en, cu_en and cu02_en)
    array.push(_ts, cu02_ts)
    array.push(_durH, cu_dur)
    array.push(_clr, cu_clr)
    array.push(_nm, "★ " + cu02_nm)
    array.push(_idx, 8)
    array.push(_en, cu_en and cu03_en)
    array.push(_ts, cu03_ts)
    array.push(_durH, cu_dur)
    array.push(_clr, cu_clr)
    array.push(_nm, "★ " + cu03_nm)
    array.push(_idx, 8)
    array.push(_en, cu_en and cu04_en)
    array.push(_ts, cu04_ts)
    array.push(_durH, cu_dur)
    array.push(_clr, cu_clr)
    array.push(_nm, "★ " + cu04_nm)
    array.push(_idx, 8)
    array.push(_en, cu_en and cu05_en)
    array.push(_ts, cu05_ts)
    array.push(_durH, cu_dur)
    array.push(_clr, cu_clr)
    array.push(_nm, "★ " + cu05_nm)
    array.push(_idx, 8)
    array.push(_en, cu_en and cu06_en)
    array.push(_ts, cu06_ts)
    array.push(_durH, cu_dur)
    array.push(_clr, cu_clr)
    array.push(_nm, "★ " + cu06_nm)
    array.push(_idx, 8)
    array.push(_en, cu_en and cu07_en)
    array.push(_ts, cu07_ts)
    array.push(_durH, cu_dur)
    array.push(_clr, cu_clr)
    array.push(_nm, "★ " + cu07_nm)
    array.push(_idx, 8)
    array.push(_en, cu_en and cu08_en)
    array.push(_ts, cu08_ts)
    array.push(_durH, cu_dur)
    array.push(_clr, cu_clr)
    array.push(_nm, "★ " + cu08_nm)
    array.push(_idx, 8)
    array.push(_en, cu_en and cu09_en)
    array.push(_ts, cu09_ts)
    array.push(_durH, cu_dur)
    array.push(_clr, cu_clr)
    array.push(_nm, "★ " + cu09_nm)
    array.push(_idx, 8)
    array.push(_en, cu_en and cu10_en)
    array.push(_ts, cu10_ts)
    array.push(_durH, cu_dur)
    array.push(_clr, cu_clr)
    array.push(_nm, "★ " + cu10_nm)
    array.push(_idx, 8)

// =============================================================================
//  DRAWING STATE
// =============================================================================
var _boxes  = array.new<box>()
var _labels = array.new<label>()

tblPosition = tblPos == "Top Left"     ? position.top_left    :
              tblPos == "Bottom Right" ? position.bottom_right :
              tblPos == "Bottom Left"  ? position.bottom_left  :
              position.top_right

var table _tbl = table.new(tblPosition,
     columns=3, rows=55,
     bgcolor=tblBgClr,
     border_color=tblBorderClr, border_width=1,
     frame_color=tblBorderClr, frame_width=1)

// =============================================================================
//  FUNCTIONS  — receive only the global arrays, no individual holiday vars
// =============================================================================

// Extract holiday base name: strip leading flag emoji token
getName(nm) =>
    p  = str.split(nm, " ")
    fl = array.size(p) > 0 ? array.get(p, 0) : ""
    str.length(nm) > str.length(fl) + 1 ? str.substring(nm, str.length(fl) + 1, str.length(nm)) : nm

// Extract flag emoji: first token of stored name string
getFlag(nm) =>
    p = str.split(nm, " ")
    array.size(p) > 0 ? array.get(p, 0) : ""

renderAll() =>
    if not (barstate.islast or barstate.isrealtime)
        na
    else
        // Clear previous drawings
        for b in _boxes
            box.delete(b)
        array.clear(_boxes)
        for lb in _labels
            label.delete(lb)
        array.clear(_labels)

        // Visible price range — from global variables computed on every bar
        visSpan  = _visHi - _visLo
        safeSpan = visSpan > 0 ? visSpan : close * 0.01
        stripH   = safeSpan * 0.06
        // Anchor below the lowest visible candle
        anchorY  = _visLo - safeSpan * 0.03

        // Collect enabled holidays
        var sTs  = array.new<int>()
        var sEnd = array.new<int>()
        var sClr = array.new<color>()
        var sNm  = array.new<string>()
        var sEn  = array.new<bool>()
        array.clear(sTs)
        array.clear(sEnd)
        array.clear(sClr)
        array.clear(sNm)
        array.clear(sEn)

        n = array.size(_en)
        for i = 0 to n - 1
            durMs_i = math.round(array.get(_durH, i) * MS_HOUR)
            array.push(sEn,  array.get(_en,  i))
            array.push(sTs,  array.get(_ts,  i))
            array.push(sEnd, array.get(_ts,  i) + durMs_i)
            array.push(sClr, array.get(_clr, i))
            array.push(sNm,  array.get(_nm,  i))

        // Bubble sort by timestamp ascending
        sz = array.size(sTs)
        if sz > 1
            for i = 0 to sz - 2
                for j = 0 to sz - 2 - i
                    if array.get(sTs, j) > array.get(sTs, j + 1)
                        tT  = array.get(sTs,  j)
                        tE  = array.get(sEnd, j)
                        tC  = array.get(sClr, j)
                        tN  = array.get(sNm,  j)
                        tEn = array.get(sEn,  j)
                        array.set(sTs,  j, array.get(sTs,  j+1))
                        array.set(sEnd, j, array.get(sEnd, j+1))
                        array.set(sClr, j, array.get(sClr, j+1))
                        array.set(sNm,  j, array.get(sNm,  j+1))
                        array.set(sEn,  j, array.get(sEn,  j+1))
                        array.set(sTs,  j+1, tT)
                        array.set(sEnd, j+1, tE)
                        array.set(sClr, j+1, tC)
                        array.set(sNm,  j+1, tN)
                        array.set(sEn,  j+1, tEn)

        // ── Build merged label entries ─────────────────────────────────────
        // Same holiday name on same day → one label with all flags
        // Different holiday names on same day → stacked vertically
        var mTs    = array.new<int>()
        var mEnd   = array.new<int>()
        var mClr   = array.new<color>()
        var mTxt   = array.new<string>()
        var mStack = array.new<int>()
        array.clear(mTs)
        array.clear(mEnd)
        array.clear(mClr)
        array.clear(mTxt)
        array.clear(mStack)

        var dayTimes = array.new<int>()
        var dayNames = array.new<string>()
        var mergedTs = array.new<int>()
        var mergedNm = array.new<string>()
        array.clear(dayTimes)
        array.clear(dayNames)
        array.clear(mergedTs)
        array.clear(mergedNm)

        for i = 0 to sz - 1
            if array.get(sEn, i)
                ts_i   = array.get(sTs,  i)
                end_i  = array.get(sEnd, i)
                clr_i  = array.get(sClr, i)
                nm_i   = array.get(sNm,  i)
                name_i = getName(nm_i)
                flag_i = getFlag(nm_i)

                // Skip if already merged
                alreadyMerged = false
                msz = array.size(mergedTs)
                if msz > 0
                    for k = 0 to msz - 1
                        if array.get(mergedTs, k) == ts_i and array.get(mergedNm, k) == name_i
                            alreadyMerged := true

                if not alreadyMerged
                    // Collect all flags for same (ts, name)
                    allFlags = flag_i
                    if i + 1 <= sz - 1
                        for j = i + 1 to sz - 1
                            if array.get(sEn, j) and array.get(sTs, j) == ts_i
                                nm_j = array.get(sNm, j)
                                if getName(nm_j) == name_i
                                    allFlags := allFlags + " " + getFlag(nm_j)

                    array.push(mergedTs, ts_i)
                    array.push(mergedNm, name_i)

                    // Find stack slot: count distinct names already seen on this day
                    slot = 0
                    dsz = array.size(dayTimes)
                    if dsz > 0
                        for k = 0 to dsz - 1
                            if array.get(dayTimes, k) == ts_i
                                slot := slot + 1

                    array.push(dayTimes, ts_i)
                    array.push(dayNames, name_i)
                    array.push(mTs,    ts_i)
                    array.push(mEnd,   end_i)
                    array.push(mClr,   clr_i)
                    array.push(mTxt,   name_i + "\n" + allFlags)
                    array.push(mStack, slot)

        // ── Draw background boxes ──────────────────────────────────────────
        // Use visible range with generous padding (not 1e15 which distorts chart scale)
        bgTop = _visHi + visSpan * 5
        bgBot = _visLo - visSpan * 5
        if showBlocks
            for i = 0 to sz - 1
                if array.get(sEn, i)
                    bx = box.new(
                         left=array.get(sTs, i), top=bgTop,
                         right=array.get(sEnd, i), bottom=bgBot,
                         xloc=xloc.bar_time,
                         bgcolor=color.new(array.get(sClr, i), opacity),
                         border_color=useBorder ? borderClr : color.new(color.black, 100),
                         border_width=useBorder ? borderW : 0,
                         border_style=bStyle)
                    array.push(_boxes, bx)

        // ── Draw merged labels at chart bottom ─────────────────────────────
        // Labels auto-size to text width — no truncation on narrow timeframes
        // Round-robin across 4 rows so adjacent labels never overlap vertically
        if showLabels
            msz = array.size(mTs)
            if msz > 0
                for i = 0 to msz - 1
                    row    = i % 4
                    labelY = anchorY - stripH * row
                    lb = label.new(
                         x=array.get(mTs, i),
                         y=labelY,
                         text=array.get(mTxt, i),
                         xloc=xloc.bar_time,
                         yloc=yloc.price,
                         color=color.new(array.get(mClr, i), labelBgTran),
                         textcolor=labelTxtClr,
                         style=label.style_label_upper_right,
                         size=lblFont)
                    array.push(_labels, lb)

renderTable() =>
    // --- collect active and upcoming into sort arrays ---
    var sTs  = array.new<int>()
    var sNm  = array.new<string>()
    var sClr = array.new<color>()
    var sAct = array.new<bool>()
    array.clear(sTs)
    array.clear(sNm)
    array.clear(sClr)
    array.clear(sAct)

    n = array.size(_en)
    for i = 0 to n - 1
        if array.get(_en, i)
            ts_i  = array.get(_ts,   i)
            dur_i = math.round(array.get(_durH, i) * MS_HOUR)
            act   = timenow >= ts_i and timenow < ts_i + dur_i
            soon  = ts_i > timenow
            if act or soon
                array.push(sTs,  ts_i)
                array.push(sNm,  array.get(_nm,  i))
                array.push(sClr, array.get(_clr, i))
                array.push(sAct, act)

    // --- bubble sort by timestamp ---
    sz = array.size(sTs)
    if sz > 1
        for i = 0 to sz - 2
            for j = 0 to sz - 2 - i
                if array.get(sTs, j) > array.get(sTs, j + 1)
                    tT = array.get(sTs,  j)
                    tN = array.get(sNm,  j)
                    tC = array.get(sClr, j)
                    tA = array.get(sAct, j)
                    array.set(sTs,  j, array.get(sTs,  j+1))
                    array.set(sNm,  j, array.get(sNm,  j+1))
                    array.set(sClr, j, array.get(sClr, j+1))
                    array.set(sAct, j, array.get(sAct, j+1))
                    array.set(sTs,  j+1, tT)
                    array.set(sNm,  j+1, tN)
                    array.set(sClr, j+1, tC)
                    array.set(sAct, j+1, tA)

    // --- header ---
    hBg = color.new(color.black, 40)
    hTx = color.new(color.gray, 10)
    table.cell(_tbl, 0, 0, "Flag",     bgcolor=hBg, text_color=hTx, text_size=tblFont)
    table.cell(_tbl, 1, 0, "Holiday",  bgcolor=hBg, text_color=hTx,
         text_halign=text.align_left,  text_size=tblFont)
    table.cell(_tbl, 2, 0, "Date",     bgcolor=hBg, text_color=hTx,
         text_halign=text.align_right, text_size=tblFont)

    // --- fill rows ---
    upCnt = 0
    shown = 0
    for i = 0 to array.size(sTs) - 1
        act_i = array.get(sAct, i)
        if act_i or upCnt < tblMaxUp
            if not act_i
                upCnt += 1
            r      = shown + 1
            tc     = act_i ? color.white : color.new(color.white, 40)
            bg     = act_i ? color.new(array.get(sClr,i), 30) : color.new(array.get(sClr,i), tblBgTranUp)
            // Extract flag (first token of nm, e.g. "🇺🇸" or "★")
            nmParts = str.split(array.get(sNm, i), " ")
            flag_i  = array.size(nmParts) > 0 ? array.get(nmParts, 0) : "?"
            dt      = str.format_time(array.get(sTs, i), "MMM dd", "UTC")
            table.cell(_tbl, 0, r, flag_i,            text_color=tc, bgcolor=bg,
                 text_halign=text.align_center, text_size=tblFont)
            table.cell(_tbl, 1, r, getName(array.get(sNm, i)), text_color=tc, bgcolor=bg,
                 text_halign=text.align_left,  text_size=tblFont)
            table.cell(_tbl, 2, r, dt,                text_color=tc, bgcolor=bg,
                 text_halign=text.align_right, text_size=tblFont)
            shown += 1

// =============================================================================
//  MAIN — run on last / realtime bar only
// =============================================================================
renderAll()
if showTbl
    renderTable()
````
