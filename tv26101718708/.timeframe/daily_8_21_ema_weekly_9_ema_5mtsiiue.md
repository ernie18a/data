# Daily 8 & 21 EMA + Weekly 9 EMA

- url: https://www.tradingview.com/script/5MTsIiuE-Daily-8-21-EMA-Weekly-9-EMA/
- type: indicator
- pine_id: PUB;ad94ea78a6334322b5715174494c2b42
- version: 1.0

## Description

Indicator to check the levels of 8, 21, and 9 W Ema on 15 min chart. Alerts included

## Source Code

````pine
//@version=6
indicator("Daily 8 & 21 EMA + Weekly 9 EMA", overlay=true, max_lines_count=10, max_labels_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
show8EMA        = input.bool(true,  "Show Daily 8 EMA")
show21EMA       = input.bool(true,  "Show Daily 21 EMA")
show9WEMA       = input.bool(true,  "Show Weekly 9 EMA")
color8          = input.color(color.new(#00E5FF, 0),  "8 EMA Color")
color21         = input.color(color.new(#FF6D00, 0),  "21 EMA Color")
color9W         = input.color(color.new(#FF1744, 0),  "9W EMA Color")
lineWidth       = input.int(2, "Line Width", minval=1, maxval=4)
showLabels      = input.bool(true, "Show Price Labels")
showFill        = input.bool(true, "Fill Between EMAs")
fillTransp      = input.int(88, "Fill Transparency", minval=50, maxval=99)

// Hide EMAs when price is too extended (prevents chart scale distortion)
hideExtended     = input.bool(true,  "Hide EMAs when extended from price", group="Extended Filter")
extendedPct21    = input.float(15.0, "Max % from price — 21D EMA",  minval=1.0, maxval=100.0, step=0.5, group="Extended Filter")
extendedPct9W    = input.float(25.0, "Max % from price — 9W EMA",   minval=1.0, maxval=100.0, step=0.5, group="Extended Filter")

// Undercut & Rally (bar-close trigger, RDR-style; confirmed by next candle)
showUndercutRally   = input.bool(true,  "Show Undercut & Rally", group="Undercut & Rally")
alertUndercutRally  = input.bool(true,  "Enable Undercut & Rally Alertconditions", group="Undercut & Rally")
sessionFilter      = input.bool(false, "Restrict to session 0930–1600", group="Undercut & Rally")
undercutBars       = input.int(3, "Lookback bars for undercut", minval=1, maxval=10, group="Undercut & Rally")
confirmGreen       = input.bool(true,  "Confirm with next candle: green (close > open)", group="Undercut & Rally")

// ─── FETCH DAILY EMAs ─────────────────────────────────────────────────────────
// request.security pulls the DAILY timeframe values regardless of chart TF
// lookahead_on ensures the current (forming) daily bar's EMA updates in real-time
// across all intraday bars rather than only at the daily close
ema8_daily  = request.security(syminfo.tickerid, "1D", ta.ema(close, 8),  lookahead=barmerge.lookahead_on)
ema21_daily = request.security(syminfo.tickerid, "1D", ta.ema(close, 21), lookahead=barmerge.lookahead_on)
ema9_weekly = request.security(syminfo.tickerid, "1W", ta.ema(close, 9),  lookahead=barmerge.lookahead_on)

// Session gate (optional, like RDR)
t       = time(timeframe.period, "0930-1600")
isOpen  = not na(t)
sessionOk = not sessionFilter or isOpen

// ─── PLOT AS SMOOTH CURVING LINES ─────────────────────────────────────────────
pct21 = math.abs(close - ema21_daily) / ema21_daily * 100
pct9W = math.abs(close - ema9_weekly) / ema9_weekly * 100

show21_plot = show21EMA and (not hideExtended or pct21 <= extendedPct21)
show9W_plot = show9WEMA and (not hideExtended or pct9W <= extendedPct9W)

p8  = plot(show8EMA      ? ema8_daily  : na, "Daily 8 EMA",
     color=color8,  linewidth=lineWidth, style=plot.style_line)

p21 = plot(show21_plot   ? ema21_daily : na, "Daily 21 EMA",
     color=color21, linewidth=lineWidth, style=plot.style_line)

p9W = plot(show9W_plot   ? ema9_weekly : na, "Weekly 9 EMA",
     color=color9W, linewidth=lineWidth + 1, style=plot.style_line)

// ─── FILL BETWEEN EMAs ────────────────────────────────────────────────────────
bullishFill = ema8_daily >= ema21_daily
fillColor   = showFill
             ? (bullishFill
                 ? color.new(color.green, fillTransp)
                 : color.new(color.red,   fillTransp))
             : na

fill(p8, p21, color=fillColor, title="EMA Fill")

// ─── UNDERCUT & RALLY DETECTION (bar-close trigger, RDR-style) ─────────────────
// Price dipped below an EMA in the lookback window, then closed back above (bought back up)
f_had_undercut(ema_series, lookback) =>
    had = false
    for i = 0 to lookback - 1
        if low[i] < ema_series[i]
            had := true
    had

undercut_then_rally_8  = sessionOk and f_had_undercut(ema8_daily, undercutBars)  and close > ema8_daily
undercut_then_rally_21 = sessionOk and f_had_undercut(ema21_daily, undercutBars) and close > ema21_daily
undercut_then_rally_9W = sessionOk and f_had_undercut(ema9_weekly, undercutBars) and close > ema9_weekly

// Rising edge: first bar where the undercut condition becomes true (episode start)
episodeStart_8  = undercut_then_rally_8  and not undercut_then_rally_8[1]
episodeStart_21 = undercut_then_rally_21 and not undercut_then_rally_21[1]
episodeStart_9W = undercut_then_rally_9W and not undercut_then_rally_9W[1]

// Confirmation window: allow any green bar above EMA within N bars of the episode start
// (old logic only allowed exactly 1 bar, missing cases where bounce took 2-3 bars to turn green)
confirmWindow = input.int(5, "Confirmation window (bars after undercut)", minval=1, maxval=15, group="Undercut & Rally")

f_episode_active(ser, window) =>
    active = false
    for i = 1 to window
        if ser[i]
            active := true
    active

activeEpisode_8  = f_episode_active(episodeStart_8,  confirmWindow)
activeEpisode_21 = f_episode_active(episodeStart_21, confirmWindow)
activeEpisode_9W = f_episode_active(episodeStart_9W, confirmWindow)

nextCandleGreen = close > open

dailyOpen      = request.security(syminfo.tickerid, "1D", open, lookahead=barmerge.lookahead_on)
belowDailyOpen = close < dailyOpen
undercutRallySignal_8  = showUndercutRally and activeEpisode_8  and (not confirmGreen or nextCandleGreen) and (close > ema8_daily)  and belowDailyOpen
undercutRallySignal_21 = showUndercutRally and activeEpisode_21 and (not confirmGreen or nextCandleGreen) and (close > ema21_daily) and belowDailyOpen
undercutRallySignal_9W = showUndercutRally and activeEpisode_9W and (not confirmGreen or nextCandleGreen) and (close > ema9_weekly)

// Once per day per EMA: each EMA tracks independently so 9W is never blocked by 8/21 firing first
dayId = time("1D")
var float lastFiredDay_8  = na
var float lastFiredDay_21 = na
var float lastFiredDay_9W = na
canFireToday_8  = na(lastFiredDay_8)  or (dayId != lastFiredDay_8)
canFireToday_21 = na(lastFiredDay_21) or (dayId != lastFiredDay_21)
canFireToday_9W = na(lastFiredDay_9W) or (dayId != lastFiredDay_9W)
oncePerDay_8  = undercutRallySignal_8  and canFireToday_8
oncePerDay_21 = undercutRallySignal_21 and canFireToday_21
oncePerDay_9W = undercutRallySignal_9W and canFireToday_9W
if oncePerDay_8
    lastFiredDay_8 := dayId
if oncePerDay_21
    lastFiredDay_21 := dayId
if oncePerDay_9W
    lastFiredDay_9W := dayId

// Labels on confirmation bar (the green candle above the undercut line)
if oncePerDay_8
    label.new(bar_index, low, "Undercut 8",  style=label.style_label_up, color=color8,  textcolor=color.white, size=size.small)
if oncePerDay_21
    label.new(bar_index, low, "Undercut 21", style=label.style_label_up, color=color21, textcolor=color.white, size=size.small)
if oncePerDay_9W
    label.new(bar_index, low, "Undercut 9W", style=label.style_label_up, color=color9W, textcolor=color.white, size=size.small)

// ─── PRICE LABELS (right side) ────────────────────────────────────────────────
// Only one set of labels: delete previous ones before creating new (avoids clutter on repaint/scroll)
var label id8   = na
var label id21  = na
var label id9W  = na
if barstate.islast and showLabels
    label.delete(id8)
    label.delete(id21)
    label.delete(id9W)
    if show8EMA
        id8 := label.new(
             bar_index + 2, ema8_daily,
             text  = "8D EMA\n" + str.tostring(ema8_daily, format.mintick),
             color = color8,
             textcolor = color.white,
             style = label.style_label_left,
             size  = size.small)
    if show21_plot
        id21 := label.new(
             bar_index + 2, ema21_daily,
             text  = "21D EMA\n" + str.tostring(ema21_daily, format.mintick),
             color = color21,
             textcolor = color.white,
             style = label.style_label_left,
             size  = size.small)
    if show9W_plot
        id9W := label.new(
             bar_index + 2, ema9_weekly,
             text  = "9W EMA\n" + str.tostring(ema9_weekly, format.mintick),
             color = color9W,
             textcolor = color.white,
             style = label.style_label_left,
             size  = size.small)

// ─── SECTOR STRENGTH TABLE ────────────────────────────────────────────────────
showSectorBox = input.bool(true, "Show Sector Box", group="Sector Strength")

_sec         = syminfo.sector
_stock_open  = request.security(syminfo.tickerid, "1D", open,  lookahead=barmerge.lookahead_on)
_stock_close = request.security(syminfo.tickerid, "1D", close, lookahead=barmerge.lookahead_on)
_stock_pct   = (_stock_close - _stock_open) / _stock_open * 100

_sec_bg = _stock_pct >= 0 ? color.new(color.green, 20) : color.new(color.red, 20)

var table _secTbl = table.new(position.bottom_right, 1, 2,
     border_width=1, border_color=color.new(color.gray, 50))
if barstate.islast and showSectorBox
    _pct_str = (_stock_pct >= 0 ? "+" : "") + str.tostring(_stock_pct, "#.##") + "%"
    table.cell(_secTbl, 0, 0,
         _sec == "" ? "Unknown Sector" : _sec,
         text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.small)
    table.cell(_secTbl, 0, 1,
         _pct_str,
         text_color=color.white, bgcolor=_sec_bg, text_size=size.normal)

// ─── ALERTS ───────────────────────────────────────────────────────────────────
alertcondition(ta.cross(close, ema8_daily),  "Price crossed Daily 8 EMA",  "Price crossed the Daily 8 EMA")
alertcondition(ta.cross(close, ema21_daily), "Price crossed Daily 21 EMA", "Price crossed the Daily 21 EMA")
alertcondition(ta.cross(close, ema9_weekly), "Price crossed Weekly 9 EMA", "Price crossed the Weekly 9 EMA")
alertcondition(ta.cross(ema8_daily, ema21_daily), "Daily 8/21 EMA Cross", "Daily 8 EMA crossed the Daily 21 EMA")

anyUndercut = oncePerDay_8 or oncePerDay_21 or oncePerDay_9W
alertcondition(alertUndercutRally and anyUndercut, title="Undercut & Rally (Any EMA)", message="Undercut & Rally {{ticker}} ({{interval}})")
````
