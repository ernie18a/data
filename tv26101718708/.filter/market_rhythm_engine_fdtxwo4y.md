# Market Rhythm Engine

- url: https://www.tradingview.com/script/FDtxwo4y-Market-Rhythm-Engine/
- type: indicator
- pine_id: PUB;7589b0ad531e4fef80b8116c7186d44f
- version: 3.0

## Description

Market Rhythm Engine is a session and liquidity timing indicator designed to reveal when a coin historically tends to move the most.

Instead of analyzing individual candles, the indicator builds historical behavioral profiles based on:
• Hour of the day (24H rhythm)
• Day of the week (7-day rhythm)

This allows traders to quickly identify:
• Strong expansion hours
• Dead liquidity zones
• High participation sessions
• Historically weak periods
• Potential market rhythm cycles

The indicator compares current market behavior against historical averages using customizable ranges:
• Last Week
• Last Month
• Last 3 Months
• Last 6 Months
• Last Year
• Since Release / Loaded History
• Since Manual Pivot

Features:
• 24-hour historical pump profile
• 7-day historical behavior profile
• Volume-adjusted price expansion model
• Above-average / normal / under-average detection
• Session rhythm visualization
• Custom lookback engine
• Manual pivot regime analysis
• Optional live candle pressure plot

The goal is not to predict exact candles, but to identify when liquidity, volatility, and participation historically tend to appear.

Useful for:
• Scalping
• Session trading
• Crypto market timing
• Liquidity analysis
• Smart-money timing
• Avoiding dead hours
• Identifying historically explosive windows

Best used together with:
• Trendline systems
• VWAP
• Volume/CVD tools
• Liquidity maps
• Session-based strategies

The indicator works especially well on crypto markets where liquidity and volatility follow repeating intraday and weekly behavioral patterns.

## Source Code

````pine
//@version=6
// vTableForwardBias - background is plotted one candle ahead from the table bucket colour
indicator("Market Rhythm Engine - Table Colour Forward Bias", overlay=false, max_labels_count=500)

//──────────────────────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────────────────────
timeGroup = "Time Settings"

timeSource = input.string(
     "Manual timezone",
     "Time Source",
     options=["Manual timezone", "Exchange timezone"],
     group=timeGroup)

manualTz = input.string(
     "Etc/UTC",
     "Manual Timezone",
     options=[
         "Etc/UTC",
         "America/New_York",
         "America/Chicago",
         "America/Denver",
         "America/Los_Angeles",
         "America/Phoenix",
         "America/Toronto",
         "America/Vancouver",
         "America/Sao_Paulo",
         "Europe/London",
         "Europe/Paris",
         "Europe/Berlin",
         "Europe/Madrid",
         "Europe/Rome",
         "Europe/Bucharest",
         "Europe/Athens",
         "Europe/Moscow",
         "Asia/Dubai",
         "Asia/Singapore",
         "Asia/Hong_Kong",
         "Asia/Tokyo",
         "Asia/Shanghai",
         "Asia/Seoul",
         "Asia/Kolkata",
         "Australia/Sydney",
         "Australia/Melbourne",
         "Australia/Brisbane",
         "Australia/Perth",
         "Pacific/Auckland"
     ],
     group=timeGroup)

activeTz = timeSource == "Exchange timezone" ? syminfo.timezone : manualTz

profileMode = input.string(
     "Last Month",
     "Comparison Period",
     options=[
         "Last Week",
         "Last Month",
         "Last 3 Months",
         "Last 6 Months",
         "Last Year",
         "Since Release / All Loaded History",
         "Since Manual Pivot"
     ])

manualPivot = input.time(timestamp("2024-01-01T00:00:00"), "Manual Pivot Start")

viewMode = input.string(
     "Both",
     "Dashboard View",
     options=["24H Hours", "7 Days", "Both"])

volLen         = input.int(50, "Volume Average Length", minval=5)
minHourSamples = input.int(5, "Minimum Hour Samples", minval=1)
minDaySamples  = input.int(1, "Minimum Day Samples", minval=1)

strongMult = input.float(1.25, "Extreme Threshold", step=0.05)

bgGroup = "Chart Background Bias"
showBiasBackground = input.bool(true, "Show NEXT Candle Bias Background On 1H + 1D", group=bgGroup)
bgTransparency = input.int(88, "Background Transparency", minval=0, maxval=100, group=bgGroup)

showLiveHourPressure = input.bool(false, "Show Live 1H Net Pressure Plot")

//──────────────────────────────────────────────────────────────────────────────
// Lookback
//──────────────────────────────────────────────────────────────────────────────
periodMs =
     profileMode == "Last Week" ? 7 * 24 * 60 * 60 * 1000 :
     profileMode == "Last Month" ? 30 * 24 * 60 * 60 * 1000 :
     profileMode == "Last 3 Months" ? 90 * 24 * 60 * 60 * 1000 :
     profileMode == "Last 6 Months" ? 180 * 24 * 60 * 60 * 1000 :
     profileMode == "Last Year" ? 365 * 24 * 60 * 60 * 1000 :
     na

startTime =
     profileMode == "Since Manual Pivot" ? manualPivot :
     profileMode == "Since Release / All Loaded History" ? na :
     timenow - periodMs

//──────────────────────────────────────────────────────────────────────────────
// Core functions
//──────────────────────────────────────────────────────────────────────────────
f_use_time(_t) =>
    na(startTime) or _t >= startTime

f_ret_pct(_o, _c) =>
    _o != 0 ? ((_c - _o) / _o) * 100.0 : 0.0

f_vol_ratio(_vol, _volAvg) =>
    _volAvg > 0 ? _vol / _volAvg : 1.0

f_dow_index_from_time(_t) =>
    _d = dayofweek(_t, activeTz)
    _d == dayofweek.monday ? 0 :
     _d == dayofweek.tuesday ? 1 :
     _d == dayofweek.wednesday ? 2 :
     _d == dayofweek.thursday ? 3 :
     _d == dayofweek.friday ? 4 :
     _d == dayofweek.saturday ? 5 : 6

f_avg(_sum, _cnt, _minSamples) =>
    _cnt >= _minSamples ? _sum / _cnt : na

//──────────────────────────────────────────────────────────────────────────────
// Fixed 1H profile
// Pump = positive expansion × relative volume
// Dump = negative expansion × relative volume
// Net  = Pump - Dump, only used for optional live plot
//──────────────────────────────────────────────────────────────────────────────
f_hour_profile() =>
    var float[] pumpSums = array.new_float(24, 0.0)
    var float[] dumpSums = array.new_float(24, 0.0)
    var float[] netSums  = array.new_float(24, 0.0)
    var float[] cnts     = array.new_float(24, 0.0)

    _ret = f_ret_pct(open, close)
    _vr = f_vol_ratio(volume, ta.sma(volume, volLen))
    _pump = math.max(_ret, 0.0) * _vr
    _dump = math.max(-_ret, 0.0) * _vr
    _net = _pump - _dump
    _h = hour(time, activeTz)

    if barstate.isconfirmed and f_use_time(time)
        array.set(pumpSums, _h, array.get(pumpSums, _h) + _pump)
        array.set(dumpSums, _h, array.get(dumpSums, _h) + _dump)
        array.set(netSums, _h, array.get(netSums, _h) + _net)
        array.set(cnts, _h, array.get(cnts, _h) + 1.0)

    [
     f_avg(array.get(pumpSums, 0), array.get(cnts, 0), minHourSamples), f_avg(array.get(pumpSums, 1), array.get(cnts, 1), minHourSamples), f_avg(array.get(pumpSums, 2), array.get(cnts, 2), minHourSamples), f_avg(array.get(pumpSums, 3), array.get(cnts, 3), minHourSamples), f_avg(array.get(pumpSums, 4), array.get(cnts, 4), minHourSamples), f_avg(array.get(pumpSums, 5), array.get(cnts, 5), minHourSamples), f_avg(array.get(pumpSums, 6), array.get(cnts, 6), minHourSamples), f_avg(array.get(pumpSums, 7), array.get(cnts, 7), minHourSamples), f_avg(array.get(pumpSums, 8), array.get(cnts, 8), minHourSamples), f_avg(array.get(pumpSums, 9), array.get(cnts, 9), minHourSamples), f_avg(array.get(pumpSums, 10), array.get(cnts, 10), minHourSamples), f_avg(array.get(pumpSums, 11), array.get(cnts, 11), minHourSamples), f_avg(array.get(pumpSums, 12), array.get(cnts, 12), minHourSamples), f_avg(array.get(pumpSums, 13), array.get(cnts, 13), minHourSamples), f_avg(array.get(pumpSums, 14), array.get(cnts, 14), minHourSamples), f_avg(array.get(pumpSums, 15), array.get(cnts, 15), minHourSamples), f_avg(array.get(pumpSums, 16), array.get(cnts, 16), minHourSamples), f_avg(array.get(pumpSums, 17), array.get(cnts, 17), minHourSamples), f_avg(array.get(pumpSums, 18), array.get(cnts, 18), minHourSamples), f_avg(array.get(pumpSums, 19), array.get(cnts, 19), minHourSamples), f_avg(array.get(pumpSums, 20), array.get(cnts, 20), minHourSamples), f_avg(array.get(pumpSums, 21), array.get(cnts, 21), minHourSamples), f_avg(array.get(pumpSums, 22), array.get(cnts, 22), minHourSamples), f_avg(array.get(pumpSums, 23), array.get(cnts, 23), minHourSamples),
     f_avg(array.get(dumpSums, 0), array.get(cnts, 0), minHourSamples), f_avg(array.get(dumpSums, 1), array.get(cnts, 1), minHourSamples), f_avg(array.get(dumpSums, 2), array.get(cnts, 2), minHourSamples), f_avg(array.get(dumpSums, 3), array.get(cnts, 3), minHourSamples), f_avg(array.get(dumpSums, 4), array.get(cnts, 4), minHourSamples), f_avg(array.get(dumpSums, 5), array.get(cnts, 5), minHourSamples), f_avg(array.get(dumpSums, 6), array.get(cnts, 6), minHourSamples), f_avg(array.get(dumpSums, 7), array.get(cnts, 7), minHourSamples), f_avg(array.get(dumpSums, 8), array.get(cnts, 8), minHourSamples), f_avg(array.get(dumpSums, 9), array.get(cnts, 9), minHourSamples), f_avg(array.get(dumpSums, 10), array.get(cnts, 10), minHourSamples), f_avg(array.get(dumpSums, 11), array.get(cnts, 11), minHourSamples), f_avg(array.get(dumpSums, 12), array.get(cnts, 12), minHourSamples), f_avg(array.get(dumpSums, 13), array.get(cnts, 13), minHourSamples), f_avg(array.get(dumpSums, 14), array.get(cnts, 14), minHourSamples), f_avg(array.get(dumpSums, 15), array.get(cnts, 15), minHourSamples), f_avg(array.get(dumpSums, 16), array.get(cnts, 16), minHourSamples), f_avg(array.get(dumpSums, 17), array.get(cnts, 17), minHourSamples), f_avg(array.get(dumpSums, 18), array.get(cnts, 18), minHourSamples), f_avg(array.get(dumpSums, 19), array.get(cnts, 19), minHourSamples), f_avg(array.get(dumpSums, 20), array.get(cnts, 20), minHourSamples), f_avg(array.get(dumpSums, 21), array.get(cnts, 21), minHourSamples), f_avg(array.get(dumpSums, 22), array.get(cnts, 22), minHourSamples), f_avg(array.get(dumpSums, 23), array.get(cnts, 23), minHourSamples),
     f_avg(array.get(netSums, 0), array.get(cnts, 0), minHourSamples), f_avg(array.get(netSums, 1), array.get(cnts, 1), minHourSamples), f_avg(array.get(netSums, 2), array.get(cnts, 2), minHourSamples), f_avg(array.get(netSums, 3), array.get(cnts, 3), minHourSamples), f_avg(array.get(netSums, 4), array.get(cnts, 4), minHourSamples), f_avg(array.get(netSums, 5), array.get(cnts, 5), minHourSamples), f_avg(array.get(netSums, 6), array.get(cnts, 6), minHourSamples), f_avg(array.get(netSums, 7), array.get(cnts, 7), minHourSamples), f_avg(array.get(netSums, 8), array.get(cnts, 8), minHourSamples), f_avg(array.get(netSums, 9), array.get(cnts, 9), minHourSamples), f_avg(array.get(netSums, 10), array.get(cnts, 10), minHourSamples), f_avg(array.get(netSums, 11), array.get(cnts, 11), minHourSamples), f_avg(array.get(netSums, 12), array.get(cnts, 12), minHourSamples), f_avg(array.get(netSums, 13), array.get(cnts, 13), minHourSamples), f_avg(array.get(netSums, 14), array.get(cnts, 14), minHourSamples), f_avg(array.get(netSums, 15), array.get(cnts, 15), minHourSamples), f_avg(array.get(netSums, 16), array.get(cnts, 16), minHourSamples), f_avg(array.get(netSums, 17), array.get(cnts, 17), minHourSamples), f_avg(array.get(netSums, 18), array.get(cnts, 18), minHourSamples), f_avg(array.get(netSums, 19), array.get(cnts, 19), minHourSamples), f_avg(array.get(netSums, 20), array.get(cnts, 20), minHourSamples), f_avg(array.get(netSums, 21), array.get(cnts, 21), minHourSamples), f_avg(array.get(netSums, 22), array.get(cnts, 22), minHourSamples), f_avg(array.get(netSums, 23), array.get(cnts, 23), minHourSamples)]

//──────────────────────────────────────────────────────────────────────────────
// Fixed 1D profile
//──────────────────────────────────────────────────────────────────────────────
f_day_profile() =>
    var float[] pumpSums = array.new_float(7, 0.0)
    var float[] dumpSums = array.new_float(7, 0.0)
    var float[] netSums  = array.new_float(7, 0.0)
    var float[] cnts     = array.new_float(7, 0.0)

    _ret = f_ret_pct(open, close)
    _vr = f_vol_ratio(volume, ta.sma(volume, volLen))
    _pump = math.max(_ret, 0.0) * _vr
    _dump = math.max(-_ret, 0.0) * _vr
    _net = _pump - _dump
    _d = f_dow_index_from_time(time)

    if barstate.isconfirmed and f_use_time(time)
        array.set(pumpSums, _d, array.get(pumpSums, _d) + _pump)
        array.set(dumpSums, _d, array.get(dumpSums, _d) + _dump)
        array.set(netSums, _d, array.get(netSums, _d) + _net)
        array.set(cnts, _d, array.get(cnts, _d) + 1.0)

    [
     f_avg(array.get(pumpSums, 0), array.get(cnts, 0), minDaySamples), f_avg(array.get(pumpSums, 1), array.get(cnts, 1), minDaySamples), f_avg(array.get(pumpSums, 2), array.get(cnts, 2), minDaySamples), f_avg(array.get(pumpSums, 3), array.get(cnts, 3), minDaySamples), f_avg(array.get(pumpSums, 4), array.get(cnts, 4), minDaySamples), f_avg(array.get(pumpSums, 5), array.get(cnts, 5), minDaySamples), f_avg(array.get(pumpSums, 6), array.get(cnts, 6), minDaySamples),
     f_avg(array.get(dumpSums, 0), array.get(cnts, 0), minDaySamples), f_avg(array.get(dumpSums, 1), array.get(cnts, 1), minDaySamples), f_avg(array.get(dumpSums, 2), array.get(cnts, 2), minDaySamples), f_avg(array.get(dumpSums, 3), array.get(cnts, 3), minDaySamples), f_avg(array.get(dumpSums, 4), array.get(cnts, 4), minDaySamples), f_avg(array.get(dumpSums, 5), array.get(cnts, 5), minDaySamples), f_avg(array.get(dumpSums, 6), array.get(cnts, 6), minDaySamples),
     f_avg(array.get(netSums, 0), array.get(cnts, 0), minDaySamples), f_avg(array.get(netSums, 1), array.get(cnts, 1), minDaySamples), f_avg(array.get(netSums, 2), array.get(cnts, 2), minDaySamples), f_avg(array.get(netSums, 3), array.get(cnts, 3), minDaySamples), f_avg(array.get(netSums, 4), array.get(cnts, 4), minDaySamples), f_avg(array.get(netSums, 5), array.get(cnts, 5), minDaySamples), f_avg(array.get(netSums, 6), array.get(cnts, 6), minDaySamples)]

//──────────────────────────────────────────────────────────────────────────────
// Fixed data requests
//──────────────────────────────────────────────────────────────────────────────
[hp0, hp1, hp2, hp3, hp4, hp5, hp6, hp7, hp8, hp9, hp10, hp11, hp12, hp13, hp14, hp15, hp16, hp17, hp18, hp19, hp20, hp21, hp22, hp23, hd0, hd1, hd2, hd3, hd4, hd5, hd6, hd7, hd8, hd9, hd10, hd11, hd12, hd13, hd14, hd15, hd16, hd17, hd18, hd19, hd20, hd21, hd22, hd23, hn0, hn1, hn2, hn3, hn4, hn5, hn6, hn7, hn8, hn9, hn10, hn11, hn12, hn13, hn14, hn15, hn16, hn17, hn18, hn19, hn20, hn21, hn22, hn23] =
     request.security(syminfo.tickerid, "60", f_hour_profile(), barmerge.gaps_off, barmerge.lookahead_off)

[dp0, dp1, dp2, dp3, dp4, dp5, dp6, dd0, dd1, dd2, dd3, dd4, dd5, dd6, dn0, dn1, dn2, dn3, dn4, dn5, dn6] =
     request.security(syminfo.tickerid, "D", f_day_profile(), barmerge.gaps_off, barmerge.lookahead_off)

liveNetPressure =
     request.security(syminfo.tickerid, "60", f_ret_pct(open, close) * f_vol_ratio(volume, ta.sma(volume, volLen)), barmerge.gaps_off, barmerge.lookahead_off)

//──────────────────────────────────────────────────────────────────────────────
// Current highlight
//──────────────────────────────────────────────────────────────────────────────
currentHour = hour(timenow, activeTz)
currentDay  = f_dow_index_from_time(timenow)

f_short_tz(_tz) =>
    _tz == "Etc/UTC" ? "UTC" :
     _tz == "America/New_York" ? "New York" :
     _tz == "America/Chicago" ? "Chicago" :
     _tz == "America/Denver" ? "Denver" :
     _tz == "America/Los_Angeles" ? "Los Angeles" :
     _tz == "America/Phoenix" ? "Phoenix" :
     _tz == "America/Toronto" ? "Toronto" :
     _tz == "America/Vancouver" ? "Vancouver" :
     _tz == "America/Sao_Paulo" ? "Sao Paulo" :
     _tz == "Europe/London" ? "London" :
     _tz == "Europe/Paris" ? "Paris" :
     _tz == "Europe/Berlin" ? "Berlin" :
     _tz == "Europe/Madrid" ? "Madrid" :
     _tz == "Europe/Rome" ? "Rome" :
     _tz == "Europe/Bucharest" ? "Bucharest" :
     _tz == "Europe/Athens" ? "Athens" :
     _tz == "Europe/Moscow" ? "Moscow" :
     _tz == "Asia/Dubai" ? "Dubai" :
     _tz == "Asia/Singapore" ? "Singapore" :
     _tz == "Asia/Hong_Kong" ? "Hong Kong" :
     _tz == "Asia/Tokyo" ? "Tokyo" :
     _tz == "Asia/Shanghai" ? "Shanghai" :
     _tz == "Asia/Seoul" ? "Seoul" :
     _tz == "Asia/Kolkata" ? "Kolkata" :
     _tz == "Australia/Sydney" ? "Sydney" :
     _tz == "Australia/Melbourne" ? "Melbourne" :
     _tz == "Australia/Brisbane" ? "Brisbane" :
     _tz == "Australia/Perth" ? "Perth" :
     _tz == "Pacific/Auckland" ? "Auckland" :
     _tz

tzLabel = timeSource == "Exchange timezone" ? "Exchange" : f_short_tz(manualTz)

//──────────────────────────────────────────────────────────────────────────────
// Getters
//──────────────────────────────────────────────────────────────────────────────
f_hour_pump(_i) => _i == 0 ? hp0 : _i == 1 ? hp1 : _i == 2 ? hp2 : _i == 3 ? hp3 : _i == 4 ? hp4 : _i == 5 ? hp5 : _i == 6 ? hp6 : _i == 7 ? hp7 : _i == 8 ? hp8 : _i == 9 ? hp9 : _i == 10 ? hp10 : _i == 11 ? hp11 : _i == 12 ? hp12 : _i == 13 ? hp13 : _i == 14 ? hp14 : _i == 15 ? hp15 : _i == 16 ? hp16 : _i == 17 ? hp17 : _i == 18 ? hp18 : _i == 19 ? hp19 : _i == 20 ? hp20 : _i == 21 ? hp21 : _i == 22 ? hp22 : hp23
f_hour_dump(_i) => _i == 0 ? hd0 : _i == 1 ? hd1 : _i == 2 ? hd2 : _i == 3 ? hd3 : _i == 4 ? hd4 : _i == 5 ? hd5 : _i == 6 ? hd6 : _i == 7 ? hd7 : _i == 8 ? hd8 : _i == 9 ? hd9 : _i == 10 ? hd10 : _i == 11 ? hd11 : _i == 12 ? hd12 : _i == 13 ? hd13 : _i == 14 ? hd14 : _i == 15 ? hd15 : _i == 16 ? hd16 : _i == 17 ? hd17 : _i == 18 ? hd18 : _i == 19 ? hd19 : _i == 20 ? hd20 : _i == 21 ? hd21 : _i == 22 ? hd22 : hd23
f_hour_net(_i)  => _i == 0 ? hn0 : _i == 1 ? hn1 : _i == 2 ? hn2 : _i == 3 ? hn3 : _i == 4 ? hn4 : _i == 5 ? hn5 : _i == 6 ? hn6 : _i == 7 ? hn7 : _i == 8 ? hn8 : _i == 9 ? hn9 : _i == 10 ? hn10 : _i == 11 ? hn11 : _i == 12 ? hn12 : _i == 13 ? hn13 : _i == 14 ? hn14 : _i == 15 ? hn15 : _i == 16 ? hn16 : _i == 17 ? hn17 : _i == 18 ? hn18 : _i == 19 ? hn19 : _i == 20 ? hn20 : _i == 21 ? hn21 : _i == 22 ? hn22 : hn23

f_day_pump(_i) => _i == 0 ? dp0 : _i == 1 ? dp1 : _i == 2 ? dp2 : _i == 3 ? dp3 : _i == 4 ? dp4 : _i == 5 ? dp5 : dp6
f_day_dump(_i) => _i == 0 ? dd0 : _i == 1 ? dd1 : _i == 2 ? dd2 : _i == 3 ? dd3 : _i == 4 ? dd4 : _i == 5 ? dd5 : dd6
f_day_net(_i)  => _i == 0 ? dn0 : _i == 1 ? dn1 : _i == 2 ? dn2 : _i == 3 ? dn3 : _i == 4 ? dn4 : _i == 5 ? dn5 : dn6

//──────────────────────────────────────────────────────────────────────────────
// Norm helpers
//──────────────────────────────────────────────────────────────────────────────
f_avg_abs_24(_mode) =>
    float _s = 0.0
    float _c = 0.0
    for i = 0 to 23
        _v = _mode == "pump" ? f_hour_pump(i) : _mode == "dump" ? f_hour_dump(i) : f_hour_net(i)
        if not na(_v)
            _s += math.abs(_v)
            _c += 1.0
    _c > 0 ? _s / _c : na

f_avg_abs_7(_mode) =>
    float _s = 0.0
    float _c = 0.0
    for i = 0 to 6
        _v = _mode == "pump" ? f_day_pump(i) : _mode == "dump" ? f_day_dump(i) : f_day_net(i)
        if not na(_v)
            _s += math.abs(_v)
            _c += 1.0
    _c > 0 ? _s / _c : na

hourPumpNorm = f_avg_abs_24("pump")
hourDumpNorm = f_avg_abs_24("dump")

dayPumpNorm = f_avg_abs_7("pump")
dayDumpNorm = f_avg_abs_7("dump")

//──────────────────────────────────────────────────────────────────────────────
// Colours
//──────────────────────────────────────────────────────────────────────────────
f_text(_v) =>
    na(_v) ? "n/a" : str.tostring(_v, "#.##")

f_color_positive(_v, _norm, _mainColor) =>
    na(_v) or na(_norm) ? color.new(color.gray, 75) :
     _v > _norm * strongMult ? _mainColor :
     color.new(color.orange, 0)

//──────────────────────────────────────────────────────────────────────────────
// Candle-chart background TABLE-COLOUR FORWARD bias
// Only active on 1H and 1D charts.
//
// IMPORTANT:
// The background colour now uses the exact same table-cell colour logic:
//     f_color_positive(value, norm, mainColour)
//
// No separate red/green background calculation is used.
//──────────────────────────────────────────────────────────────────────────────
isOneHourTf = timeframe.isminutes and timeframe.multiplier == 60
isOneDayTf = timeframe.isdaily and timeframe.multiplier == 1

//──────────────────────────────────────────────────────────────────────────────
// Forward bucket indexes using SAME timezone logic as table
//──────────────────────────────────────────────────────────────────────────────
currentHourIndex = hour(time, activeTz)
currentDayIndex  = f_dow_index_from_time(time)

// Move ONE bucket ahead using the MANUAL timezone-adjusted bucket
nextHourIndex = (currentHourIndex + 1) % 24
nextDayIndex  = (currentDayIndex + 1) % 7

nextHourPump = f_hour_pump(nextHourIndex)
nextHourDump = f_hour_dump(nextHourIndex)
nextDayPump  = f_day_pump(nextDayIndex)
nextDayDump  = f_day_dump(nextDayIndex)

// Exact same colours used by the table cells.
nextHourPumpTableColor = f_color_positive(nextHourPump, hourPumpNorm, color.new(color.lime, 0))
nextHourDumpTableColor = f_color_positive(nextHourDump, hourDumpNorm, color.new(color.red, 0))
nextDayPumpTableColor  = f_color_positive(nextDayPump, dayPumpNorm, color.new(color.lime, 0))
nextDayDumpTableColor  = f_color_positive(nextDayDump, dayDumpNorm, color.new(color.red, 0))

// Same table-cell extreme checks.
// If both Pump and Dump are extreme in the table for the same bucket,
// use the stronger value, but the colour itself is taken from the table colour.
nextHourPumpIsTableGreen = not na(nextHourPump) and not na(hourPumpNorm) and nextHourPump > hourPumpNorm * strongMult
nextHourDumpIsTableRed   = not na(nextHourDump) and not na(hourDumpNorm) and nextHourDump > hourDumpNorm * strongMult

nextDayPumpIsTableGreen = not na(nextDayPump) and not na(dayPumpNorm) and nextDayPump > dayPumpNorm * strongMult
nextDayDumpIsTableRed   = not na(nextDayDump) and not na(dayDumpNorm) and nextDayDump > dayDumpNorm * strongMult

nextHourUsePumpColor = nextHourPumpIsTableGreen and (not nextHourDumpIsTableRed or nextHourPump >= nextHourDump)
nextHourUseDumpColor = nextHourDumpIsTableRed and (not nextHourPumpIsTableGreen or nextHourDump > nextHourPump)

nextDayUsePumpColor = nextDayPumpIsTableGreen and (not nextDayDumpIsTableRed or nextDayPump >= nextDayDump)
nextDayUseDumpColor = nextDayDumpIsTableRed and (not nextDayPumpIsTableGreen or nextDayDump > nextDayPump)

rawForwardBg =
     isOneHourTf and nextHourUsePumpColor ? nextHourPumpTableColor :
     isOneHourTf and nextHourUseDumpColor ? nextHourDumpTableColor :
     isOneDayTf and nextDayUsePumpColor   ? nextDayPumpTableColor :
     isOneDayTf and nextDayUseDumpColor   ? nextDayDumpTableColor :
     na

forwardBg = na(rawForwardBg) ? na : color.new(rawForwardBg, bgTransparency)

// offset=1 keeps the hint one candle ahead.
bgcolor(color=showBiasBackground ? forwardBg : na, title="Table Colour Forward Bias", offset=1, force_overlay=true)

//──────────────────────────────────────────────────────────────────────────────
// Dashboard
//──────────────────────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 25, 7, border_width=1)

if barstate.islast
    table.clear(dash, 0, 0, 24, 6)

    int row = 0

    table.cell(dash, 0, row, "Market Rhythm", text_color=color.white, bgcolor=color.new(color.blue, 0))
    table.cell(dash, 1, row, profileMode, text_color=color.white, bgcolor=color.new(color.blue, 0))
    table.cell(dash, 2, row, "TZ: " + tzLabel, text_color=color.white, bgcolor=color.new(color.blue, 0))

    row += 1

    if viewMode == "24H Hours" or viewMode == "Both"
        table.cell(dash, 0, row, "Hour", text_color=color.white, bgcolor=color.new(color.black, 0))
        for displayHour = 1 to 24
            _hourIndex = displayHour == 24 ? 0 : displayHour
            _headerBg = _hourIndex == currentHour ? color.new(color.blue, 0) : color.new(color.black, 0)
            table.cell(dash, displayHour, row, _hourIndex == currentHour ? "▶ " + str.tostring(displayHour) : str.tostring(displayHour), text_color=color.white, bgcolor=_headerBg)

        row += 1
        table.cell(dash, 0, row, "Pump 1H", text_color=color.white, bgcolor=color.new(color.black, 0))
        for displayHour = 1 to 24
            _hourIndex = displayHour == 24 ? 0 : displayHour
            _v = f_hour_pump(_hourIndex)
            table.cell(dash, displayHour, row, f_text(_v), text_color=color.white, bgcolor=f_color_positive(_v, hourPumpNorm, color.new(color.lime, 0)))

        row += 1
        table.cell(dash, 0, row, "Dump 1H", text_color=color.white, bgcolor=color.new(color.black, 0))
        for displayHour = 1 to 24
            _hourIndex = displayHour == 24 ? 0 : displayHour
            _v = f_hour_dump(_hourIndex)
            table.cell(dash, displayHour, row, f_text(_v), text_color=color.white, bgcolor=f_color_positive(_v, hourDumpNorm, color.new(color.red, 0)))

        row += 1

    if viewMode == "7 Days" or viewMode == "Both"
        table.cell(dash, 0, row, "Day", text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(dash, 1, row, currentDay == 0 ? "▶ Mon" : "Mon", text_color=color.white, bgcolor=currentDay == 0 ? color.new(color.blue, 0) : color.new(color.black, 0))
        table.cell(dash, 2, row, currentDay == 1 ? "▶ Tue" : "Tue", text_color=color.white, bgcolor=currentDay == 1 ? color.new(color.blue, 0) : color.new(color.black, 0))
        table.cell(dash, 3, row, currentDay == 2 ? "▶ Wed" : "Wed", text_color=color.white, bgcolor=currentDay == 2 ? color.new(color.blue, 0) : color.new(color.black, 0))
        table.cell(dash, 4, row, currentDay == 3 ? "▶ Thu" : "Thu", text_color=color.white, bgcolor=currentDay == 3 ? color.new(color.blue, 0) : color.new(color.black, 0))
        table.cell(dash, 5, row, currentDay == 4 ? "▶ Fri" : "Fri", text_color=color.white, bgcolor=currentDay == 4 ? color.new(color.blue, 0) : color.new(color.black, 0))
        table.cell(dash, 6, row, currentDay == 5 ? "▶ Sat" : "Sat", text_color=color.white, bgcolor=currentDay == 5 ? color.new(color.blue, 0) : color.new(color.black, 0))
        table.cell(dash, 7, row, currentDay == 6 ? "▶ Sun" : "Sun", text_color=color.white, bgcolor=currentDay == 6 ? color.new(color.blue, 0) : color.new(color.black, 0))

        row += 1
        table.cell(dash, 0, row, "Pump 1D", text_color=color.white, bgcolor=color.new(color.black, 0))
        for i = 0 to 6
            _v = f_day_pump(i)
            table.cell(dash, i + 1, row, f_text(_v), text_color=color.white, bgcolor=f_color_positive(_v, dayPumpNorm, color.new(color.lime, 0)))

        row += 1
        table.cell(dash, 0, row, "Dump 1D", text_color=color.white, bgcolor=color.new(color.black, 0))
        for i = 0 to 6
            _v = f_day_dump(i)
            table.cell(dash, i + 1, row, f_text(_v), text_color=color.white, bgcolor=f_color_positive(_v, dayDumpNorm, color.new(color.red, 0)))

plot(showLiveHourPressure ? liveNetPressure : na, "Live 1H Net Pressure", style=plot.style_columns)
````
