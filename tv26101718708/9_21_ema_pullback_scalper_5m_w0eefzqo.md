# 9 / 21 EMA Pullback Scalper  |  5m

- url: https://www.tradingview.com/script/W0EEFzqO-9-21-EMA-Pullback-Scalper-5m/
- type: indicator
- pine_id: PUB;fbf3c88fac9c42329a03ba0f6660ce9b
- version: 2.0

## Description

Easy scalping method off the 9/21 EMA. Uses the 5 min TF. Best if only done from 9:45-15:00 time zone. 

Use 9 EMA + 21 EMA on the 5m chart
Enter when price pulls back to the 9 EMA in a trending move
Only trade when 9 EMA is above 21 EMA (long) or below (short)
Simple, visual, easy to execute fast with alerts.


[*]Element:	         Description
[*]9 EMA line:	         Bold, colored green in bull trend / red in bear trend
[*]21 EMA line:	Same color, slightly faded
[*]Shaded fill:    	Between the two EMAs — instantly shows trend strength and direction
[*]BUY / SELL: 	Arrow labels at signal bars. Hover for RSI, EMA values, gap %
[*]Stop-Loss dashed line:	Drawn at the lowest low (long) or highest high (short) of the last 3 bars
[*]Info table:	         Bottom-right corner — live trend, 9 EMA, 21 EMA, RSI, gap %
[/list]

[*]RSI Filter	Blocks longs above 70, shorts below 30	
[*]EMA Gap Filter	Requires minimum 0.05% spread between EMAs — kills signals in sideways chop	
[*]Cooldown	Minimum 5 bars between same-direction signals — stops cluster spam

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0
// © patrickmcdonald
//
// ─── STRATEGY RULES ──────────────────────────────────────────────────────────
//  LONG  : 9 EMA is above 21 EMA  (bull trend)
//          Previous bar's low touched or dipped to/below the 9 EMA (pullback)
//          Current bar closes back above the 9 EMA (resumption)
//
//  SHORT : 9 EMA is below 21 EMA  (bear trend)
//          Previous bar's high touched or rose to/above the 9 EMA (pullback)
//          Current bar closes back below the 9 EMA (resumption)
//
//  OPTIONAL FILTERS (each independently toggleable):
//    · RSI      – avoids longs when overbought, shorts when oversold
//    · EMA gap  – only signals when the two EMAs are far enough apart
//    · Cooldown – minimum bars between consecutive same-direction signals
//    · Session  – restrict signals to Asia, London, and/or USA market hours
// ─────────────────────────────────────────────────────────────────────────────
indicator("9 / 21 EMA Pullback Scalper  |  5m",
          overlay          = true,
          max_labels_count = 500,
          max_lines_count  = 100)

// ════════════════════════════════════════════════════════════════════════════
// INPUT GROUPS
// ════════════════════════════════════════════════════════════════════════════
var string G_EMA  = "EMA Settings"
var string G_SIG  = "Signal Settings"
var string G_FILT = "Filters"
var string G_SESS = "Session Filter"
var string G_VIZ  = "Visuals"

// ── EMA ──────────────────────────────────────────────────────────────────────
fastLen   = input.int(9,        "Fast EMA  (default 9)",   group = G_EMA, minval = 1)
slowLen   = input.int(21,       "Slow EMA  (default 21)",  group = G_EMA, minval = 2)
emaSource = input.source(close, "EMA Source",              group = G_EMA)

// ── Signals ───────────────────────────────────────────────────────────────────
showBuy      = input.bool(true, "Show BUY  Signals",       group = G_SIG)
showSell     = input.bool(true, "Show SELL Signals",       group = G_SIG)
showSL       = input.bool(true, "Show Stop-Loss Line",     group = G_SIG,
               tooltip = "Draws a short horizontal line at the suggested stop level for each signal.")
slLookback   = input.int(3,    "SL Swing Lookback (bars)", group = G_SIG,
               minval = 1, maxval = 20,
               tooltip = "Stop for longs = lowest low of this many bars. Stop for shorts = highest high.")

// ── Filters ───────────────────────────────────────────────────────────────────
useRSI       = input.bool(true,  "RSI Filter",             group = G_FILT,
               tooltip = "Blocks longs when RSI is overbought and shorts when oversold.")
rsiLen       = input.int(14,     "RSI Length",             group = G_FILT, minval = 2)
rsiOB        = input.int(70,     "RSI Overbought",         group = G_FILT, minval = 50, maxval = 100)
rsiOS        = input.int(30,     "RSI Oversold",           group = G_FILT, minval = 0,  maxval = 50)
useGap       = input.bool(true,  "EMA Gap Filter",         group = G_FILT,
               tooltip = "Only signals when the EMA spread is wide enough — filters choppy/flat markets.")
minGapPct    = input.float(0.05, "Min EMA Gap  %",         group = G_FILT,
               minval = 0.01, step = 0.01,
               tooltip = "Gap between the two EMAs as a % of price. Raise to be more selective.")
useCooldown  = input.bool(true,  "Cooldown Filter",        group = G_FILT,
               tooltip = "Prevents back-to-back signals in the same direction.")
cooldownBars = input.int(5,      "Cooldown (bars)",        group = G_FILT,
               minval = 1, maxval = 50,
               tooltip = "Minimum bars that must pass before another same-direction signal fires.")

// ── Session Filter ────────────────────────────────────────────────────────────
//  When the master toggle is ON, BUY/SELL signals will only appear during the
//  sessions you enable below.  Turn all three on for 24-hour coverage with
//  highlighting, or mix and match to trade only your preferred window.
//
//  All times are New York (America/New_York) so the windows stay correct
//  regardless of which timezone your chart is set to.
//
//  Default windows:
//    Asia   20:00 – 04:00  (Tokyo / Sydney overlap)
//    London 03:00 – 12:00  (London open → NY morning)
//    USA    09:30 – 16:00  (NYSE regular hours)
// ─────────────────────────────────────────────────────────────────────────────
useSessionFilter = input.bool(false, "Enable Session Filter",
                  group   = G_SESS,
                  tooltip = "Master toggle. OFF = every bar is eligible (original behaviour). ON = signals only fire inside the sessions enabled below.")

useAsia      = input.bool(false, "Asia Session  (signals ON/OFF)",
               group   = G_SESS,
               tooltip = "When the master filter is ON, enable this to allow signals during the Asia window.")
asiaSess     = input.session("2000-0400", "  Asia Time Window",
               group   = G_SESS,
               tooltip = "New York time. Default 20:00–04:00. Crosses midnight — Pine handles this correctly.")

useLondon    = input.bool(false, "London Session  (signals ON/OFF)",
               group   = G_SESS,
               tooltip = "When the master filter is ON, enable this to allow signals during the London window.")
londonSess   = input.session("0300-1200", "  London Time Window",
               group   = G_SESS,
               tooltip = "New York time. Default 03:00–12:00.")

useUSA       = input.bool(false, "USA Session  (signals ON/OFF)",
               group   = G_SESS,
               tooltip = "When the master filter is ON, enable this to allow signals during the US session.")
usaSess      = input.session("0930-1600", "  USA Time Window",
               group   = G_SESS,
               tooltip = "New York time. Default 09:30–16:00 (NYSE regular hours).")

showSessionBG = input.bool(true, "Highlight Active Sessions on Chart",
                group   = G_SESS,
                tooltip = "Shades the chart background in each session's colour while that session is active, so you can see the windows at a glance.")
asiaCol       = input.color(color.new(#7b68ee, 93), "  Asia Highlight Color",   group = G_SESS)
londonCol     = input.color(color.new(#ffd700, 93), "  London Highlight Color", group = G_SESS)
usaCol        = input.color(color.new(#00bcd4, 93), "  USA Highlight Color",    group = G_SESS)

// ── Visuals ───────────────────────────────────────────────────────────────────
bullCol      = input.color(#26a69a,                "Bull Color  (trend up)",   group = G_VIZ)
bearCol      = input.color(#ef5350,                "Bear Color  (trend down)", group = G_VIZ)
neutCol      = input.color(color.new(#90a4ae, 0),  "Neutral Color  (flat)",    group = G_VIZ)
fillTransp   = input.int(88, "EMA Fill Transparency", group = G_VIZ,
               minval = 0, maxval = 100)
buyCol       = input.color(#00e676,                "BUY  Label Color",         group = G_VIZ)
sellCol      = input.color(#ff1744,                "SELL Label Color",         group = G_VIZ)
slCol        = input.color(color.new(#ff9800, 20), "Stop-Loss Line Color",     group = G_VIZ)
colorCandles = input.bool(false, "Color Candles by Trend", group = G_VIZ,
               tooltip = "Paints each candle green (bull trend) or red (bear trend).")

// ════════════════════════════════════════════════════════════════════════════
// EMA CALCULATION
// ════════════════════════════════════════════════════════════════════════════
float ema9  = ta.ema(emaSource, fastLen)
float ema21 = ta.ema(emaSource, slowLen)
bool  bullTrend = ema9 > ema21
bool  bearTrend = ema9 < ema21
float emaPct    = math.abs(ema9 - ema21) / ema21 * 100

// ════════════════════════════════════════════════════════════════════════════
// FILTER VALUES
// ════════════════════════════════════════════════════════════════════════════
float rsiVal    = ta.rsi(emaSource, rsiLen)
bool rsiOkLong  = not useRSI or rsiVal < rsiOB
bool rsiOkShort = not useRSI or rsiVal > rsiOS
bool gapOk      = not useGap or emaPct >= minGapPct

// ════════════════════════════════════════════════════════════════════════════
// SESSION FILTER
//
//  time() returns na when the current bar falls outside the session string,
//  so  not na(time(...))  is the standard Pine idiom for "bar is in session".
//  The timezone argument pins the window to New York time on every instrument.
//
//  sessionOk is true when:
//    · The master filter is OFF (pass-all, original behaviour), OR
//    · The master filter is ON and the bar is inside at least one enabled session
// ════════════════════════════════════════════════════════════════════════════
string TZ     = "America/New_York"
bool inAsia   = useAsia   and not na(time(timeframe.period, asiaSess,   TZ))
bool inLondon = useLondon and not na(time(timeframe.period, londonSess, TZ))
bool inUSA    = useUSA    and not na(time(timeframe.period, usaSess,    TZ))
bool sessionOk = not useSessionFilter or (inAsia or inLondon or inUSA)

// ── Session background highlight ──────────────────────────────────────────────
bgcolor(showSessionBG and useSessionFilter and useAsia   and inAsia   ? asiaCol   : na, title = "Asia Session BG")
bgcolor(showSessionBG and useSessionFilter and useLondon and inLondon ? londonCol : na, title = "London Session BG")
bgcolor(showSessionBG and useSessionFilter and useUSA    and inUSA    ? usaCol    : na, title = "USA Session BG")

// ════════════════════════════════════════════════════════════════════════════
// PULLBACK DETECTION
// ════════════════════════════════════════════════════════════════════════════
bool rawLong  = bullTrend and low[1]  <= ema9[1] and close > ema9
bool rawShort = bearTrend and high[1] >= ema9[1] and close < ema9

// ── Cooldown tracking ─────────────────────────────────────────────────────────
var int lastLongBar  = -999
var int lastShortBar = -999
bool coolLong  = not useCooldown or (bar_index - lastLongBar)  > cooldownBars
bool coolShort = not useCooldown or (bar_index - lastShortBar) > cooldownBars

// ── Final signals — all filters + session gate applied here ───────────────────
bool longSig  = rawLong  and rsiOkLong  and gapOk and coolLong  and sessionOk
bool shortSig = rawShort and rsiOkShort and gapOk and coolShort and sessionOk

if longSig
    lastLongBar  := bar_index
if shortSig
    lastShortBar := bar_index

// ════════════════════════════════════════════════════════════════════════════
// VISUALS — EMA LINES & FILL
// ════════════════════════════════════════════════════════════════════════════
color trendCol = bullTrend ? bullCol : bearTrend ? bearCol : neutCol
plot(ema9,  "9 EMA",  color = trendCol,               linewidth = 2)
plot(ema21, "21 EMA", color = color.new(trendCol, 40), linewidth = 2)

ema9Plot  = plot(ema9,  display = display.none)
ema21Plot = plot(ema21, display = display.none)
fill(ema9Plot, ema21Plot,
     color = color.new(bullTrend ? bullCol : bearTrend ? bearCol : neutCol, fillTransp),
     title = "EMA Fill")

barcolor(colorCandles ? (bullTrend ? color.new(bullCol, 60) : bearTrend ? color.new(bearCol, 60) : na) : na,
         title = "Candle Color")

// ════════════════════════════════════════════════════════════════════════════
// VISUALS — BUY / SELL SIGNAL LABELS
// ════════════════════════════════════════════════════════════════════════════
string rsiStr = "  RSI: " + str.tostring(math.round(rsiVal, 1))

if longSig and showBuy
    label.new(bar_index, low,
              "BUY",
              style     = label.style_label_up,
              color     = buyCol,
              textcolor = color.white,
              size      = size.normal,
              tooltip   = "Long Pullback Signal" + rsiStr +
                          "\n9 EMA:  " + str.tostring(math.round(ema9,  2)) +
                          "\n21 EMA: " + str.tostring(math.round(ema21, 2)) +
                          "\nEMA Gap: " + str.tostring(math.round(emaPct, 3)) + "%")

if shortSig and showSell
    label.new(bar_index, high,
              "SELL",
              style     = label.style_label_down,
              color     = sellCol,
              textcolor = color.white,
              size      = size.normal,
              tooltip   = "Short Pullback Signal" + rsiStr +
                          "\n9 EMA:  " + str.tostring(math.round(ema9,  2)) +
                          "\n21 EMA: " + str.tostring(math.round(ema21, 2)) +
                          "\nEMA Gap: " + str.tostring(math.round(emaPct, 3)) + "%")

// ════════════════════════════════════════════════════════════════════════════
// VISUALS — STOP-LOSS LINE
// ════════════════════════════════════════════════════════════════════════════
if showSL
    if longSig
        float slLevel = ta.lowest(low, slLookback)
        line.new(bar_index - slLookback, slLevel, bar_index + 6, slLevel,
                 color = slCol, width = 2, style = line.style_dashed)
        label.new(bar_index + 6, slLevel, "SL",
                  style     = label.style_label_left,
                  color     = color(na),
                  textcolor = slCol,
                  size      = size.tiny)
    if shortSig
        float slLevel = ta.highest(high, slLookback)
        line.new(bar_index - slLookback, slLevel, bar_index + 6, slLevel,
                 color = slCol, width = 2, style = line.style_dashed)
        label.new(bar_index + 6, slLevel, "SL",
                  style     = label.style_label_left,
                  color     = color(na),
                  textcolor = slCol,
                  size      = size.tiny)

// ════════════════════════════════════════════════════════════════════════════
// INFO TABLE  (bottom-right corner)
// ════════════════════════════════════════════════════════════════════════════
var table infoTbl = table.new(position.bottom_right, 2, 6,
                              bgcolor      = color.new(#1a1a2e, 10),
                              border_color = color.new(#ffffff, 80),
                              border_width = 1,
                              frame_color  = color.new(#ffffff, 80),
                              frame_width  = 1)

f_cell(int col, int row, string txt, color tc) =>
    table.cell(infoTbl, col, row, txt,
               text_color = tc, text_size = size.small,
               bgcolor    = color(na))

if barstate.islast
    string trendTxt = bullTrend ? "▲  BULL" : bearTrend ? "▼  BEAR" : "─  FLAT"
    color  trendTc  = bullTrend ? bullCol   : bearTrend ? bearCol   : neutCol

    f_cell(0, 0, "Trend",   color.new(#ffffff, 30))
    f_cell(1, 0, trendTxt,  trendTc)
    f_cell(0, 1, "9  EMA",  color.new(#ffffff, 30))
    f_cell(1, 1, str.tostring(math.round(ema9,  2)),  trendCol)
    f_cell(0, 2, "21 EMA",  color.new(#ffffff, 30))
    f_cell(1, 2, str.tostring(math.round(ema21, 2)),  trendCol)
    f_cell(0, 3, "RSI",     color.new(#ffffff, 30))
    f_cell(1, 3, str.tostring(math.round(rsiVal, 1)), rsiVal > rsiOB ? bearCol : rsiVal < rsiOS ? bullCol : color.new(#ffffff, 20))
    f_cell(0, 4, "EMA Gap", color.new(#ffffff, 30))
    f_cell(1, 4, str.tostring(math.round(emaPct, 3)) + "%", gapOk ? bullCol : color.new(#607d8b, 0))

    string sessTxt = not useSessionFilter ? "OFF" : inUSA ? "USA" : inLondon ? "London" : inAsia ? "Asia" : "— none —"
    color  sessTc  = not useSessionFilter ? color.new(#ffffff, 50) : inUSA ? color.new(#00bcd4, 0) : inLondon ? color.new(#ffd700, 0) : inAsia ? color.new(#7b68ee, 0) : color.new(#ffffff, 60)
    f_cell(0, 5, "Session", color.new(#ffffff, 30))
    f_cell(1, 5, sessTxt,   sessTc)

// ════════════════════════════════════════════════════════════════════════════
// ALERT CONDITIONS
// Create Alert → Condition: this indicator → choose one below.
// Recommended trigger: "Once Per Bar Close"
// ════════════════════════════════════════════════════════════════════════════
alertcondition(longSig,            "BUY  – EMA Pullback", "{{ticker}} 5m BUY  — 9/21 EMA Pullback")
alertcondition(shortSig,           "SELL – EMA Pullback", "{{ticker}} 5m SELL — 9/21 EMA Pullback")
alertcondition(longSig or shortSig,"Any  – EMA Pullback", "{{ticker}} 5m EMA Pullback Signal")
````
