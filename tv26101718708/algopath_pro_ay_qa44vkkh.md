# AlgoPath Pro [AY]

- url: https://www.tradingview.com/script/QA44VkKh/
- type: indicator
- pine_id: PUB;bc4bbde4bcd74d10968af9f9920a1d2d
- version: 1.0

## Description

AlgoPath Pro⁺ [AY¹] is a comprehensive intraday reference-level suite designed for traders who work with New York session structure, institutional price levels, and volatility-based candle detection. All features are built around New York time (UTC−4) and are fully customizable via the settings panel.

🔷 FEATURES OVERVIEW
📅 NY Levels — Previous Day High / Low / EQ
Automatically plots the previous day's High (PDH), Low (PDL), and their midpoint (EQ) at the start of each new New York day. Lines extend 24 hours forward and reset daily. Optional labels can be toggled on/off independently.
🕐 Opening Price Levels
Four key intraday reference prices are captured and plotted automatically:

mdO — Midnight Open (00:00 NY)
QTO — Quarter To Open (07:30 NY)
nyO — New York Open (09:30 NY)
rthC — Regular Trading Hours Close (16:00 NY)

Each level draws a horizontal line extending 24 hours from its trigger bar. Labels appear at the right end of each line for a clean, uncluttered chart.
📦 NY Session Range Box
Plots the previous day's RTH range (nyO → rthC) as a shaded zone on the current day's chart. Includes an optional midpoint line. Both box and midpoint are independently togglable. Default: hidden.
⚡ Opening Gap Detection
Identifies and visualizes the gap between the previous day's rthC and the current day's nyO — the true overnight gap on 24-hour continuous charts (futures, indices, crypto). Bullish gaps are shaded green, bearish gaps red. An optional label displays the gap size in points. Default: visible.
🐋 Whale Candle Detector (Balina)
Detects abnormally large candles using an ATR-based threshold. Qualifies candles by body size or full wick range. Bullish and bearish whales are highlighted with bar coloring. Optional features include a midpoint line projection (dashed gray by default) and a time label showing when the candle occurred.

⚙️ SETTINGS SUMMARY
GroupKey OptionsGlobal SettingsTimezone offset (default UTC−4), Label sizeNY LevelsPDH/PDL/EQ label toggle, New Day backgroundOpening TimesAutomatic — no user input requiredNY Session RangeShow/hide box, box color, show/hide midpoint, midpoint colorOpening GapShow/hide gap box, show/hide gap label, bull/bear colorsBalinaShow/hide whales, bar coloring, ATR period & multiplier, midpoint line, time labels

📐 RECOMMENDED TIMEFRAMES
Works best on intraday charts: 1m, 2m, 3m, 5m, 15m, 30m
Designed primarily for NQ, ES, MNQ, MES, SPX, indices and futures.

📌 NOTES

All session times are based on New York time (UTC−4). The timezone offset input allows adjustment if needed.
Opening Gap logic treats the rthC→nyO move as the standard overnight gap definition used in 24-hour markets.
This indicator does not repaint. All levels are derived from confirmed prior-bar and prior-session data.
No signals, no alerts, no entries. This is a pure price structure and reference level tool.

## Source Code

````pine
//@version=5
indicator("AlgoPath Pro⁺[AY¹]", overlay=true, max_lines_count=500, max_labels_count=500)

//=============================================================================
// GLOBAL SETTINGS
//=============================================================================
global_timezone_offset = input.int(-4, "Global Timezone Offset (UTC)", minval=-12, maxval=12, group="Global Settings", tooltip="All times will use this timezone. Default: -4 (NY Time)")
global_timezone = "GMT" + str.tostring(global_timezone_offset)

lbl_size_opt = input.string("Normal", "Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Global Settings")
lbl_size = lbl_size_opt == "Tiny" ? size.tiny : lbl_size_opt == "Small" ? size.small : lbl_size_opt == "Large" ? size.large : lbl_size_opt == "Huge" ? size.huge : size.normal

//=============================================================================
// NY LEVELS
//=============================================================================
show_new_day_bg  = input.bool(true,  "Show New Day Background", group="NY Levels")
show_pdh_pdl_eq  = input.bool(false, "Show PDH / PDL / EQ Labels", group="NY Levels")

new_ny_day = ta.change(dayofmonth(time, global_timezone)) != 0

var float prev_high  = na
var float prev_low   = na
var float prev_eq    = na
var float daily_high = high
var float daily_low  = low

daily_high := math.max(daily_high, high)
daily_low  := math.min(daily_low,  low)

if new_ny_day and not na(daily_high[1]) and not na(daily_low[1])
    prev_high := daily_high[1]
    prev_low  := daily_low[1]
    prev_eq   := (prev_high + prev_low) / 2
    line_end_time = time + 86400000

    line.new(x1=time, y1=prev_high, x2=line_end_time, y2=prev_high, color=color.blue, width=2, style=line.style_solid, xloc=xloc.bar_time, extend=extend.none)
    line.new(x1=time, y1=prev_low,  x2=line_end_time, y2=prev_low,  color=color.red,  width=2, style=line.style_solid, xloc=xloc.bar_time, extend=extend.none)
    line.new(x1=time, y1=prev_eq,   x2=line_end_time, y2=prev_eq,   color=color.blue, width=1, style=line.style_dashed, xloc=xloc.bar_time, extend=extend.none)

    if show_pdh_pdl_eq
        label.new(x=line_end_time, y=prev_high, text="PDH", style=label.style_none, textcolor=color.blue, size=lbl_size, xloc=xloc.bar_time)
        label.new(x=line_end_time, y=prev_low,  text="PDL", style=label.style_none, textcolor=color.red,  size=lbl_size, xloc=xloc.bar_time)
        label.new(x=line_end_time, y=prev_eq,   text="EQ",  style=label.style_none, textcolor=color.blue, size=lbl_size, xloc=xloc.bar_time)

    daily_high := high
    daily_low  := low

bgcolor(show_new_day_bg and new_ny_day ? color.new(color.gray, 90) : na, title="New Day Background")

//=============================================================================
// OPENING TIMES
//=============================================================================
mdo_session  = "0000-0001:1234567"
qto_session  = "0730-0731:1234567"
nyo_session  = "0930-0931:1234567"
rthc_session = "1600-1601:1234567"

mdo_time  = time("1", mdo_session,  global_timezone)
qto_time  = time("1", qto_session,  global_timezone)
nyo_time  = time("1", nyo_session,  global_timezone)
rthc_time = time("1", rthc_session, global_timezone)

var float mdo_price  = na
var float qto_price  = na
var float nyo_price  = na
var float rthc_price = na

if not na(mdo_time) and na(mdo_time[1])
    mdo_price := open
    mdo_end = time + 86400000
    line.new(x1=time, y1=mdo_price, x2=mdo_end, y2=mdo_price, color=color.purple, width=1, style=line.style_solid, xloc=xloc.bar_time, extend=extend.none)
    label.new(x=mdo_end, y=mdo_price, text="mdO", style=label.style_none, textcolor=color.purple, size=lbl_size, xloc=xloc.bar_time)

if not na(qto_time) and na(qto_time[1])
    qto_price := open
    qto_end = time + 86400000
    line.new(x1=time, y1=qto_price, x2=qto_end, y2=qto_price, color=#b7ab49, width=1, style=line.style_solid, xloc=xloc.bar_time, extend=extend.none)
    label.new(x=qto_end, y=qto_price, text="QTO", style=label.style_none, textcolor=#b7ab49, size=lbl_size, xloc=xloc.bar_time)

if not na(nyo_time) and na(nyo_time[1])
    nyo_price := open
    nyo_end = time + 86400000
    line.new(x1=time, y1=nyo_price, x2=nyo_end, y2=nyo_price, color=color.orange, width=1, style=line.style_solid, xloc=xloc.bar_time, extend=extend.none)
    label.new(x=nyo_end, y=nyo_price, text="nyO", style=label.style_none, textcolor=color.orange, size=lbl_size, xloc=xloc.bar_time)

if not na(rthc_time) and na(rthc_time[1])
    rthc_price := open
    rthc_end = time + 86400000
    line.new(x1=time, y1=rthc_price, x2=rthc_end, y2=rthc_price, color=color.green, width=1, style=line.style_solid, xloc=xloc.bar_time, extend=extend.none)
    label.new(x=rthc_end, y=rthc_price, text="rthC", style=label.style_none, textcolor=color.green, size=lbl_size, xloc=xloc.bar_time)

//=============================================================================
// NY SESSION RANGE
//=============================================================================
ny_range_show     = input.bool(false, "Show NY Session Range", group="NY Session Range")
ny_range_color    = input.color(color.new(color.gray, 85), "NY Range Box Color", group="NY Session Range")
ny_mid_show       = input.bool(false, "Show NY Midpoint Line", group="NY Session Range")
ny_mid_color      = input.color(color.new(color.gray, 30), "NY Midpoint Line Color", group="NY Session Range")

var float prev_nyo  = na
var float prev_rthc = na
var float ny_mid    = na

if new_ny_day
    prev_nyo  := nyo_price[1]
    prev_rthc := rthc_price[1]

    if not na(prev_nyo) and not na(prev_rthc)
        ny_mid     := (prev_nyo + prev_rthc) / 2
        box_top    = math.max(prev_nyo, prev_rthc)
        box_bottom = math.min(prev_nyo, prev_rthc)
        ny_box_end = time + 86400000

        if ny_range_show
            box.new(left=time, top=box_top, right=ny_box_end, bottom=box_bottom, bgcolor=ny_range_color, border_color=color.new(color.gray, 100), border_width=0, xloc=xloc.bar_time)

        if ny_mid_show
            line.new(x1=time, y1=ny_mid, x2=ny_box_end, y2=ny_mid, color=ny_mid_color, width=1, style=line.style_dashed, xloc=xloc.bar_time, extend=extend.none)

//=============================================================================
// OPENING GAP (prev rthC → current nyO)
//=============================================================================
gap_show       = input.bool(true,  "Show Opening Gap",    group="Opening Gap")
gap_label_show = input.bool(true,  "Show Gap Size Label", group="Opening Gap")
gap_bull_color = input.color(color.new(#a8d5b5, 75), "Bullish Gap Color", group="Opening Gap")
gap_bear_color = input.color(color.new(#e8a0a0, 75), "Bearish Gap Color", group="Opening Gap")

var float gap_rthc_price = na
var float gap_nyo_price  = na

if not na(rthc_time) and na(rthc_time[1])
    gap_rthc_price := open

if not na(nyo_time) and na(nyo_time[1])
    gap_nyo_price := open

    if gap_show and not na(gap_rthc_price) and not na(gap_nyo_price)
        gap_top    = math.max(gap_rthc_price, gap_nyo_price)
        gap_bottom = math.min(gap_rthc_price, gap_nyo_price)
        gap_size   = gap_nyo_price - gap_rthc_price
        is_bull    = gap_size > 0
        gap_color  = is_bull ? gap_bull_color : gap_bear_color
        gap_end    = time + 86400000

        box.new(left=time, top=gap_top, right=gap_end, bottom=gap_bottom, bgcolor=gap_color, border_color=color.new(color.gray, 100), border_width=0, xloc=xloc.bar_time)

        if gap_label_show and math.abs(gap_size) > 0
            gap_text = (is_bull ? "▲ Gap +" : "▼ Gap ") + str.tostring(math.round(math.abs(gap_size), 2))
            label.new(x=gap_end, y=(gap_top + gap_bottom) / 2, text=gap_text, style=label.style_none, textcolor=is_bull ? color.new(#2e7d52, 0) : color.new(#b03030, 0), size=lbl_size, xloc=xloc.bar_time)

//=============================================================================
// BALİNA / WHALE CANDLE DETECTOR
//=============================================================================
whale_show           = input.bool(true,  "Show Whale Candles", group="Balina")
whale_show_bar_color = input.bool(true,  "Color Whale Bars",   group="Balina")
whale_Use_Wicks      = input.bool(false, "Use Wicks to Calculate Length", group="Balina")
whale_Periods        = input.int(14,     "ATR Periods", minval=1, group="Balina")
whale_Multi          = input.float(1,    "ATR Multi",   minval=0.1, step=0.1, group="Balina")

whale_bull_color     = input.color(color.blue, "Bullish Color", group="Balina")
whale_bear_color     = input.color(color.red,  "Bearish Color", group="Balina")

whale_show_mid_line  = input.bool(false, "Show Midpoint Line", group="Balina")
whale_mid_color      = input.color(color.new(color.gray, 0), "Midpoint Line Color", group="Balina")
whale_line_style_opt = input.string("Dashed", "Midpoint Line Style", options=["Solid", "Dotted", "Dashed"], group="Balina")
whale_line_width     = input.int(1, "Midpoint Line Width", minval=1, maxval=5, group="Balina")
whale_show_time_lbl  = input.bool(true, "Show Time Labels", group="Balina")

whale_line_style = whale_line_style_opt == "Dotted" ? line.style_dotted : whale_line_style_opt == "Dashed" ? line.style_dashed : line.style_solid

whale_Wick = high - low
whale_Body = math.abs(close - open)
whale_Sum  = whale_Use_Wicks ? whale_Wick : whale_Body
whale_ATR  = ta.atr(whale_Periods) * whale_Multi

whale_is_bullish = whale_show and whale_Sum > whale_ATR and close > open
whale_is_bearish = whale_show and whale_Sum > whale_ATR and close < open

barcolor(whale_show_bar_color ? (whale_is_bullish ? color.new(whale_bull_color, 10) : whale_is_bearish ? color.new(whale_bear_color, 10) : na) : na)

whale_mid = (high + low) / 2
whale_candle_size = whale_Use_Wicks ? whale_Wick : whale_Body
whale_line_length = whale_candle_size < whale_ATR ? 50 : whale_candle_size < 2 * whale_ATR ? 100 : whale_candle_size < 3 * whale_ATR ? 150 : 200

if whale_is_bullish and whale_show_mid_line
    line.new(bar_index, whale_mid, bar_index + whale_line_length, whale_mid, color=whale_mid_color, width=whale_line_width, style=whale_line_style)

if whale_is_bearish and whale_show_mid_line
    line.new(bar_index, whale_mid, bar_index + whale_line_length, whale_mid, color=whale_mid_color, width=whale_line_width, style=whale_line_style)

whale_saat      = hour(time, global_timezone)
whale_dakika    = minute(time, global_timezone)
whale_time_text = str.tostring(whale_saat) + ":" + (whale_dakika < 10 ? "0" + str.tostring(whale_dakika) : str.tostring(whale_dakika))

if whale_is_bullish and whale_show_time_lbl
    label.new(bar_index, high, text=whale_time_text, color=color.new(color.white, 100), textcolor=color.black, style=label.style_label_down, size=size.normal)

if whale_is_bearish and whale_show_time_lbl
    label.new(bar_index, low, text=whale_time_text, color=color.new(color.white, 100), textcolor=color.black, style=label.style_label_up, size=size.normal)
````
