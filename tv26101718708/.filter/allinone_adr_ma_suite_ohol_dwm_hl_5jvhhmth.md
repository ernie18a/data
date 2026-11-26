# All-in-One: ADR% + MA Suite + OH/OL + DWM HL

- url: https://www.tradingview.com/script/5jVHHmtH-All-in-One-ADR-MA-Suite-OH-OL-DWM-HL/
- type: indicator
- pine_id: PUB;932139c87acf4c64946780a056892417
- version: 1.0

## Description

Script involves ATR, MAs, OH/OL, Daily/Weekly/Monthly Levels

## Source Code

````pine
//@version=6
indicator("All-in-One: ADR% + MA Suite + OH/OL + DWM HL", overlay=true, max_lines_count=500)

// ─────────────────────────────────────────────────────────────────────────────
// 1. ADR% / ATR / LoD dist. Table
// ─────────────────────────────────────────────────────────────────────────────
show_table     = input.bool(true,  "Show ADR% / ATR Table", group="📊 Table")
show_adrp      = input.bool(true,  "Show ADR%",             group="📊 Table")
show_atr       = input.bool(false, "Show ATR",              group="📊 Table")
show_lod_dist  = input.bool(true,  "Show LoD dist.",        group="📊 Table")
adrp_len       = input.int(20,     "ADR% Length",           group="📊 Table")
atr_len        = input.int(14,     "ATR Length",            group="📊 Table")
bg_col         = input.color(color.new(color.black, 100), "Table Background", group="📊 Table")
adrp_col       = input.color(color.white, "ADR% Text Color", group="📊 Table")
atr_col        = input.color(color.orange,"ATR Text Color",  group="📊 Table")
lod_dist_col   = input.color(color.orange,"LoD dist. Color", group="📊 Table")
show_empty_row = input.bool(false, "Add empty row above",   group="📊 Table")

adrp_val = request.security(syminfo.tickerid, "D", 100 * (ta.sma(high / low, adrp_len) - 1))
atr_val  = request.security(syminfo.tickerid, "D", ta.atr(atr_len))
lod_dist_val = request.security(syminfo.tickerid, "D", 100 * (close - low) / ta.atr(atr_len))

if barstate.islast and show_table and not (timeframe.period == "W" or timeframe.period == "M")
    var tbl = table.new(position.top_right, 2, 4, bgcolor=bg_col)
    if show_empty_row
        table.cell(tbl, 0, 0, "")
        table.cell(tbl, 1, 0, "")
    if show_adrp
        table.cell(tbl, 0, 1, "ADR%", text_color=adrp_col)
        table.cell(tbl, 1, 1, str.tostring(math.round(adrp_val, 2)) + "%", text_color=adrp_col)
    if show_atr
        table.cell(tbl, 0, 2, "ATR", text_color=atr_col)
        table.cell(tbl, 1, 2, str.tostring(math.round(atr_val, 2)), text_color=atr_col)
    if show_lod_dist
        table.cell(tbl, 0, 3, "LoD dist.", text_color=lod_dist_col)
        table.cell(tbl, 1, 3, str.tostring(math.round(lod_dist_val)) + "%", text_color=lod_dist_col)

// ─────────────────────────────────────────────────────────────────────────────
// 2. MA Suite (10 MAs + VWAP + Bollinger Bands) – opacity now functional
// ─────────────────────────────────────────────────────────────────────────────
ma(src, len, type) => type == "EMA" ? ta.ema(src, len) : ta.sma(src, len)

// MA 1
ma1_type  = input.string("EMA", "MA 1 Type", options=["EMA","SMA"], group="📈 MA 1", inline="ma1")
ma1_src   = input.source(close, "Source", group="📈 MA 1", inline="ma1")
ma1_len   = input.int(20, "Period", group="📈 MA 1", inline="ma1")
ma1_color = input.color(color.red, "Color", group="📈 MA 1", inline="ma1")
plot(ma(ma1_src, ma1_len, ma1_type), "MA1", ma1_color)

// MA 2
ma2_type  = input.string("SMA", "MA 2 Type", options=["EMA","SMA"], group="📈 MA 2", inline="ma2")
ma2_src   = input.source(close, "Source", group="📈 MA 2", inline="ma2")
ma2_len   = input.int(50, "Period", group="📈 MA 2", inline="ma2")
ma2_color = input.color(color.blue, "Color", group="📈 MA 2", inline="ma2")
plot(ma(ma2_src, ma2_len, ma2_type), "MA2", ma2_color)

// MA 3
ma3_type  = input.string("EMA", "MA 3 Type", options=["EMA","SMA"], group="📈 MA 3", inline="ma3")
ma3_src   = input.source(close, "Source", group="📈 MA 3", inline="ma3")
ma3_len   = input.int(100, "Period", group="📈 MA 3", inline="ma3")
ma3_color = input.color(color.green, "Color", group="📈 MA 3", inline="ma3")
plot(ma(ma3_src, ma3_len, ma3_type), "MA3", ma3_color)

// MA 4
ma4_type  = input.string("SMA", "MA 4 Type", options=["EMA","SMA"], group="📈 MA 4", inline="ma4")
ma4_src   = input.source(close, "Source", group="📈 MA 4", inline="ma4")
ma4_len   = input.int(150, "Period", group="📈 MA 4", inline="ma4")
ma4_color = input.color(color.orange, "Color", group="📈 MA 4", inline="ma4")
plot(ma(ma4_src, ma4_len, ma4_type), "MA4", ma4_color)

// MA 5
ma5_type  = input.string("EMA", "MA 5 Type", options=["EMA","SMA"], group="📈 MA 5", inline="ma5")
ma5_src   = input.source(close, "Source", group="📈 MA 5", inline="ma5")
ma5_len   = input.int(200, "Period", group="📈 MA 5", inline="ma5")
ma5_color = input.color(color.purple, "Color", group="📈 MA 5", inline="ma5")
plot(ma(ma5_src, ma5_len, ma5_type), "MA5", ma5_color)

// MA 6
ma6_type  = input.string("SMA", "MA 6 Type", options=["EMA","SMA"], group="📈 MA 6", inline="ma6")
ma6_src   = input.source(high, "Source", group="📈 MA 6", inline="ma6")
ma6_len   = input.int(250, "Period", group="📈 MA 6", inline="ma6")
ma6_color = input.color(color.teal, "Color", group="📈 MA 6", inline="ma6")
plot(ma(ma6_src, ma6_len, ma6_type), "MA6", ma6_color)

// MA 7
ma7_type  = input.string("EMA", "MA 7 Type", options=["EMA","SMA"], group="📈 MA 7", inline="ma7")
ma7_src   = input.source(low, "Source", group="📈 MA 7", inline="ma7")
ma7_len   = input.int(300, "Period", group="📈 MA 7", inline="ma7")
ma7_color = input.color(color.olive, "Color", group="📈 MA 7", inline="ma7")
plot(ma(ma7_src, ma7_len, ma7_type), "MA7", ma7_color)

// MA 8
ma8_type  = input.string("SMA", "MA 8 Type", options=["EMA","SMA"], group="📈 MA 8", inline="ma8")
ma8_src   = input.source(hl2, "Source", group="📈 MA 8", inline="ma8")
ma8_len   = input.int(350, "Period", group="📈 MA 8", inline="ma8")
ma8_color = input.color(color.navy, "Color", group="📈 MA 8", inline="ma8")
plot(ma(ma8_src, ma8_len, ma8_type), "MA8", ma8_color)

// MA 9
ma9_type  = input.string("EMA", "MA 9 Type", options=["EMA","SMA"], group="📈 MA 9", inline="ma9")
ma9_src   = input.source(hlc3, "Source", group="📈 MA 9", inline="ma9")
ma9_len   = input.int(400, "Period", group="📈 MA 9", inline="ma9")
ma9_color = input.color(color.maroon, "Color", group="📈 MA 9", inline="ma9")
plot(ma(ma9_src, ma9_len, ma9_type), "MA9", ma9_color)

// MA 10
ma10_type  = input.string("SMA", "MA 10 Type", options=["EMA","SMA"], group="📈 MA 10", inline="ma10")
ma10_src   = input.source(ohlc4, "Source", group="📈 MA 10", inline="ma10")
ma10_len   = input.int(500, "Period", group="📈 MA 10", inline="ma10")
ma10_color = input.color(color.fuchsia, "Color", group="📈 MA 10", inline="ma10")
plot(ma(ma10_src, ma10_len, ma10_type), "MA10", ma10_color)

// VWAP (Session)
vwap_color = input.color(color.purple, "VWAP Color", group="📈 VWAP")
var float cumPV = na, var float cumV = na
newSession = timeframe.change("D")
typical    = (high + low + close) / 3
if newSession
    cumPV := 0.0
    cumV  := 0.0
cumPV := cumPV + typical * volume
cumV  := cumV + volume
vwap   = cumPV / cumV
plot(vwap, "VWAP", vwap_color, 2)

// Bollinger Bands – with separate opacity control for bands
bb_len   = input.int(20, "BB Length", group="📊 Bollinger Bands")
bb_mult  = input.float(2.0, "BB StdDev", group="📊 Bollinger Bands")
bb_src   = input.source(close, "BB Source", group="📊 Bollinger Bands")
bb_basis_color = input.color(#00FF00, "Basis Color", group="📊 Bollinger Bands", inline="bb_col")
bb_band_color  = input.color(#00FF00, "Bands Color", group="📊 Bollinger Bands", inline="bb_col")
bb_band_opacity = input.int(50, "Band Opacity %", minval=0, maxval=100, group="📊 Bollinger Bands")

basis = ta.sma(bb_src, bb_len)
dev   = ta.stdev(bb_src, bb_len)
upper = basis + dev * bb_mult
lower = basis - dev * bb_mult
plot(basis, "BB Basis", bb_basis_color)
plot(upper, "BB Upper", color.new(bb_band_color, bb_band_opacity))
plot(lower, "BB Lower", color.new(bb_band_color, bb_band_opacity))

// ─────────────────────────────────────────────────────────────────────────────
// 3. Open = High / Open = Low markers – opacity already functional
// ─────────────────────────────────────────────────────────────────────────────
show_oh = input.bool(true, "Show Open=High", group="🔵 OH/OL Markers")
oh_text_color = input.color(color.white, "OH Text Color", group="🔵 OH/OL Markers", inline="oh")
oh_marker_color = input.color(color.red, "OH Marker", group="🔵 OH/OL Markers", inline="oh")

show_ol = input.bool(true, "Show Open=Low", group="🔵 OH/OL Markers")
ol_text_color = input.color(color.white, "OL Text Color", group="🔵 OH/OL Markers", inline="ol")
ol_marker_color = input.color(color.green, "OL Marker", group="🔵 OH/OL Markers", inline="ol")

oh = open == high
ol = open == low

plotshape(series=show_oh and oh, title="OH", location=location.abovebar,
          color=oh_marker_color, style=shape.circle, text="OH", textcolor=oh_text_color)
plotshape(series=show_ol and ol, title="OL", location=location.belowbar,
          color=ol_marker_color, style=shape.circle, text="OL", textcolor=ol_text_color)

// ─────────────────────────────────────────────────────────────────────────────
// 4. Daily / Weekly / Monthly Highs & Lows – opacity already functional
// ─────────────────────────────────────────────────────────────────────────────
i_isDailyEnabled   = input.bool(true,          "Daily",                        inline="Daily",     group="📅 DWM Highs & Lows")
i_dailyColor       = input.color(color.green,  "",                             inline="Daily",     group="📅 DWM Highs & Lows")
i_dailyLookback    = input.int(2,              "", 1,                          inline="Daily",     group="📅 DWM Highs & Lows")
i_isWeeklyEnabled  = input.bool(true,          "Weekly",                       inline="Weekly",    group="📅 DWM Highs & Lows")
i_weeklyColor      = input.color(color.orange, "",                             inline="Weekly",    group="📅 DWM Highs & Lows")
i_weeklyLookback   = input.int(1,              "", 1,                          inline="Weekly",    group="📅 DWM Highs & Lows")
i_isMonthlyEnabled = input.bool(true,          "Monthly",                      inline="Monthly",   group="📅 DWM Highs & Lows")
i_monthlyColor     = input.color(color.red,    "",                             inline="Monthly",   group="📅 DWM Highs & Lows")
i_monthlyLookback  = input.int(1,              "", 1,                          inline="Monthly",   group="📅 DWM Highs & Lows")
i_areHeadsEnabled  = input.bool(false,         "Show Projections",             inline="Head",      group="📅 DWM Highs & Lows")
i_rightOffset      = input.int(20,             "", 1,                          inline="Head",      group="📅 DWM Highs & Lows")
i_hasGradient      = input.bool(true,          "Show Gradient",                                    group="📅 DWM Highs & Lows")

DAILY_LINE_STYLE   = line.style_dashed
DAILY_LINE_WIDTH   = 1
WEEKLY_LINE_STYLE  = line.style_dashed
WEEKLY_LINE_WIDTH  = 1
MONTHLY_LINE_STYLE = line.style_dashed
MONTHLY_LINE_WIDTH = 1

[dailyTime, dailyHigh, dailyLow, isLastDaily]     = request.security(syminfo.tickerid, 'D', [time, high, low, barstate.islast], lookahead=barmerge.lookahead_on)
[weeklyTime, weeklyHigh, weeklyLow, isLastWeekly] = request.security(syminfo.tickerid, 'W', [time, high, low, barstate.islast], lookahead=barmerge.lookahead_on)
[monthlyTime, monthlyHigh, monthlyLow, isLastMonthly] = request.security(syminfo.tickerid, 'M', [time, high, low, barstate.islast], lookahead=barmerge.lookahead_on)

hasDailyTimeChanged   = dailyTime != dailyTime[1]
hasWeeklyTimeChanged  = weeklyTime != weeklyTime[1]
hasMonthlyTimeChanged = monthlyTime != monthlyTime[1]

canShowDaily   = i_isDailyEnabled and timeframe.isintraday
canShowWeekly  = i_isWeeklyEnabled and (timeframe.isintraday or timeframe.isdaily)
canShowMonthly = i_isMonthlyEnabled and not timeframe.ismonthly

var a_lastHighs = array.new_float(3)
var a_lastLows  = array.new_float(3)

if canShowDaily and hasDailyTimeChanged and not isLastDaily
    array.set(a_lastHighs, 0, dailyHigh)
    array.set(a_lastLows, 0, dailyLow)

if canShowWeekly and hasWeeklyTimeChanged and not isLastWeekly
    array.set(a_lastHighs, 1, weeklyHigh)
    array.set(a_lastLows, 1, weeklyLow)

if canShowMonthly and hasMonthlyTimeChanged and not isLastMonthly
    array.set(a_lastHighs, 2, monthlyHigh)
    array.set(a_lastLows, 2, monthlyLow)

f_getRightBarIndex() => bar_index + i_rightOffset

f_draw(bool _isNew, float _h, float _l, int _lookback, color _color, string _style, int _width) =>
    var line _high  = na
    var line _low   = na
    var _highs      = array.new_line()
    var _lows       = array.new_line()
    _end            = i_areHeadsEnabled ? f_getRightBarIndex() : bar_index
    
    if _isNew
        line.set_x2(_high, _end)
        line.set_x2(_low, _end)

        if i_hasGradient
            _size = array.size(_highs)
            if _size > 1
                for i = 0 to _size - 1
                    _c = color.from_gradient(i, 0, _size - 1, color.new(_color, 100), color.new(_color, 0))
                    line.set_color(array.get(_highs, i), _c)
                    line.set_color(array.get(_lows, i), _c)

        _high := line.new(bar_index, _h, bar_index, _h, color=_color, style=_style, width=_width)
        _low  := line.new(bar_index, _l, bar_index, _l, color=_color, style=_style, width=_width)
        array.push(_highs, _high)
        array.push(_lows, _low)

        if array.size(_highs) > _lookback + 1
            line.delete(array.shift(_highs))
            line.delete(array.shift(_lows))

    if i_areHeadsEnabled and barstate.islast and array.size(_highs) > 1
        for i = 0 to array.size(_highs) - 2
            line.set_x2(array.get(_highs, i), f_getRightBarIndex())
            line.set_x2(array.get(_lows, i), f_getRightBarIndex())

if canShowMonthly
    f_draw(hasMonthlyTimeChanged, monthlyHigh, monthlyLow, i_monthlyLookback, i_monthlyColor, MONTHLY_LINE_STYLE, MONTHLY_LINE_WIDTH)

if canShowWeekly
    f_draw(hasWeeklyTimeChanged, weeklyHigh, weeklyLow, i_weeklyLookback, i_weeklyColor, WEEKLY_LINE_STYLE, WEEKLY_LINE_WIDTH)

if canShowDaily
    f_draw(hasDailyTimeChanged, dailyHigh, dailyLow, i_dailyLookback, i_dailyColor, DAILY_LINE_STYLE, DAILY_LINE_WIDTH)

plot(array.get(a_lastHighs, 0), "DH", color.new(i_dailyColor, 100),   editable=false)
plot(array.get(a_lastLows, 0),  "DL", color.new(i_dailyColor, 100),   editable=false)
plot(array.get(a_lastHighs, 1), "WH", color.new(i_weeklyColor, 100),  editable=false)
plot(array.get(a_lastLows, 1),  "WL", color.new(i_weeklyColor, 100),  editable=false)
plot(array.get(a_lastHighs, 2), "MH", color.new(i_monthlyColor, 100), editable=false)
plot(array.get(a_lastLows, 2),  "ML", color.new(i_monthlyColor, 100), editable=false)
````
