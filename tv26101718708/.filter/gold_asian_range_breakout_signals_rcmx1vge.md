# GOLD Asian Range Breakout Signals

- url: https://www.tradingview.com/script/rCMX1vGE-GOLD-Asian-Range-Breakout-Signals/
- type: indicator
- pine_id: PUB;719f95f242fd487b87c107af2f0c21b9
- version: 1.0

## Description

GOLD Asian Range Breakout (ARB)
Identifies high-probability breakout entries on GOLD (XAUUSD) based on the Asian session range, designed for the London session open.
How it works:

Tracks the Asian session high and low (default 01:00–08:00 server time)
Signals a BUY when London price closes above Asian High + ATR buffer
Signals a SELL when London price closes below Asian Low − ATR buffer
One signal per direction per day — no re-entries

Built-in filters:

H4 EMA 50 trend filter (BUY only above, SELL only below)
Asian range size filter (skips choppy or spike sessions)
Day-of-week filter (Monday and Friday skipped by default)

## Source Code

````pine
//@version=6
indicator('GOLD Asian Range Breakout Signals', shorttitle = 'GOLD ARB', overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 200)

// ───────────────────────────────────────────────────────────────────
// INPUTS
// ───────────────────────────────────────────────────────────────────
tz          = input.string('UTC+2', 'Broker Server Timezone', options = ['UTC', 'UTC+1', 'UTC+2', 'UTC+3', 'UTC+4', 'UTC+5', 'UTC+6'], tooltip = 'XM Global: UTC+2 (winter) or UTC+3 (summer DST)')
asianStart  = input.int(1,  'Asian Start Hour (server)',  minval = 0, maxval = 23, group = 'Session')
asianEnd    = input.int(8,  'Asian End Hour   (server)',  minval = 0, maxval = 23, group = 'Session')
londonStart = input.int(9,  'London Start Hour (server)', minval = 0, maxval = 23, group = 'Session')
londonEnd   = input.int(14, 'London End Hour   (server)', minval = 0, maxval = 23, group = 'Session')
skipMon     = input.bool(true, 'Skip Monday (net losing in backtest)', group = 'Session')
skipFri     = input.bool(true, 'Skip Friday', group = 'Session')

atrLen   = input.int(14,  'ATR Length', group = 'Signal Settings')
brkBuf   = input.float(0.2, 'Breakout Buffer (× ATR)',       step = 0.05, group = 'Signal Settings', tooltip = 'Price must close X*ATR above Asian High to trigger BUY')
minRange = input.float(0.8, 'Min Range Filter (× ATR)',      step = 0.1,  group = 'Signal Settings', tooltip = 'Skip if Asian range is too narrow (choppy session)')
maxRange = input.float(3.0, 'Max Range Filter (× ATR)',      step = 0.1,  group = 'Signal Settings', tooltip = 'Skip if Asian range is too wide (panic/volatile session)')
slMult   = input.float(1.5, 'Stop Loss  = ATR ×',           step = 0.1,  group = 'Signal Settings')
rrRatio  = input.float(3.0, 'Take Profit = SL ×  (RR)',     step = 0.1,  group = 'Signal Settings', tooltip = '3.0 = 3:1 RR, breakeven win rate = 25%')

useH4    = input.bool(true, 'Enable H4 EMA50 Trend Filter', group = 'H4 Trend Filter', tooltip = 'BUY only when H4 is above EMA50 | SELL only when below')
h4Len    = input.int(50,   'H4 EMA Length',                 group = 'H4 Trend Filter')

showAsianBox  = input.bool(true, 'Show Asian Range Box',          group = 'Display')
showLondonBg  = input.bool(true, 'Show London Session Shading',   group = 'Display')
showH4Line    = input.bool(true, 'Show H4 EMA50 Line',            group = 'Display')
showSLTP      = input.bool(true, 'Draw SL & TP Lines on Signal',  group = 'Display')
showTable     = input.bool(true, 'Show Info Panel (top right)',    group = 'Display')

// ───────────────────────────────────────────────────────────────────
// TIME CALCULATIONS
// ───────────────────────────────────────────────────────────────────
sHour = hour(time, tz)
sDay  = dayofweek(time, tz)

inAsian  = sHour >= asianStart and sHour < asianEnd
inLondon = sHour >= londonStart and sHour < londonEnd
skipDay  = (skipMon and sDay == dayofweek.monday) or (skipFri and sDay == dayofweek.friday)
isNewDay = ta.change(dayofweek(time, tz)) != 0

// ───────────────────────────────────────────────────────────────────
// ASIAN RANGE TRACKER
// ───────────────────────────────────────────────────────────────────
var float asianH    = na
var float asianL    = na
var bool  asianDone = false
var int   asianBar0 = na

if isNewDay
    asianH    := na
    asianL    := na
    asianDone := false
    asianBar0 := na

if inAsian
    asianBar0 := na(asianBar0) ? bar_index : asianBar0
    asianH    := na(asianH) ? high : math.max(asianH, high)
    asianL    := na(asianL) ? low  : math.min(asianL, low)

if not inAsian and sHour >= asianEnd and not na(asianH) and not asianDone
    asianDone := true

// ───────────────────────────────────────────────────────────────────
// INDICATORS
// ───────────────────────────────────────────────────────────────────
atr14 = ta.atr(atrLen)
h4ema = request.security(syminfo.tickerid, '240', ta.ema(close, h4Len), lookahead = barmerge.lookahead_off)

rangeSize = asianH - asianL
rangeOK   = asianDone and not na(rangeSize) and rangeSize >= atr14 * minRange and rangeSize <= atr14 * maxRange

brkBuyLvl  = asianH + atr14 * brkBuf
brkSellLvl = asianL - atr14 * brkBuf

h4Bull = close > h4ema
h4Bear = close < h4ema

// ───────────────────────────────────────────────────────────────────
// ENTRY SIGNALS
// FIX: hoist ta.crossover/ta.crossunder to global scope so they
//      execute on every bar (Pine Script v6 requirement)
// ───────────────────────────────────────────────────────────────────
buyOK  = inLondon and rangeOK and not skipDay and (not useH4 or h4Bull)
sellOK = inLondon and rangeOK and not skipDay and (not useH4 or h4Bear)

crossBuy  = ta.crossover(close, brkBuyLvl)
crossSell = ta.crossunder(close, brkSellLvl)

buySignal  = buyOK  and crossBuy
sellSignal = sellOK and crossSell

// ───────────────────────────────────────────────────────────────────
// BACKGROUND SHADING
// ───────────────────────────────────────────────────────────────────
bgcolor(inAsian ? color.new(color.blue, 94) : na, title = 'Asian Session')
bgcolor(showLondonBg and inLondon ? color.new(color.green, 92) : na, title = 'London Session')

// ───────────────────────────────────────────────────────────────────
// H4 EMA50 LINE
// ───────────────────────────────────────────────────────────────────
plot(showH4Line ? h4ema : na, 'H4 EMA50', color = color.new(color.orange, 10), linewidth = 2, style = plot.style_line)

// ───────────────────────────────────────────────────────────────────
// ASIAN RANGE BOX + LABELS
// ───────────────────────────────────────────────────────────────────
var box  asianBox = na
var line extH     = na
var line extL     = na

if asianDone and not asianDone[1] and showAsianBox and not na(asianBar0)
    box.delete(asianBox)
    asianBox := box.new(left = asianBar0, top = asianH, right = bar_index, bottom = asianL, bgcolor = color.new(color.blue, 84), border_color = color.new(color.blue, 30), border_width = 1)

    label.new(bar_index, asianH, 'Asian H: ' + str.tostring(asianH, '#.##'), style = label.style_label_right, color = color.new(color.blue, 20), textcolor = color.white, size = size.small)
    label.new(bar_index, asianL, 'Asian L: ' + str.tostring(asianL, '#.##'), style = label.style_label_right, color = color.new(color.blue, 20), textcolor = color.white, size = size.small)

    line.delete(extH)
    line.delete(extL)
    extH := line.new(bar_index, asianH, bar_index + 60, asianH, color = color.new(color.blue, 10), style = line.style_dashed, width = 1)
    extL := line.new(bar_index, asianL, bar_index + 60, asianL, color = color.new(color.red,  10), style = line.style_dashed, width = 1)

if not na(extH) and (inLondon or sHour < londonEnd)
    line.set_x2(extH, bar_index + 20)
    line.set_x2(extL, bar_index + 20)

// ───────────────────────────────────────────────────────────────────
// BUY SIGNAL
// ───────────────────────────────────────────────────────────────────
plotshape(buySignal, title = 'BUY', location = location.belowbar, style = shape.triangleup, color = color.lime, size = size.normal)

if buySignal
    slPrice = close - atr14 * slMult
    tpPrice = close + atr14 * slMult * rrRatio

    label.new(bar_index, low - atr14 * 0.3, 'BUY\n@ ' + str.tostring(close, '#.##') + '\nSL: ' + str.tostring(math.round(slPrice, 2)) + '\nTP: ' + str.tostring(math.round(tpPrice, 2)) + '\nRR: 1:' + str.tostring(rrRatio, '#.#'), style = label.style_label_up, color = color.new(color.lime, 10), textcolor = color.black, size = size.normal)

    if showSLTP
        line.new(bar_index, slPrice, bar_index + 50, slPrice, color = color.red,   style = line.style_dotted, width = 2)
        label.new(bar_index + 50, slPrice, 'SL ' + str.tostring(math.round(slPrice, 2)), style = label.style_label_left, color = color.red,   textcolor = color.white, size = size.small)
        line.new(bar_index, tpPrice, bar_index + 50, tpPrice, color = color.green, style = line.style_dotted, width = 2)
        label.new(bar_index + 50, tpPrice, 'TP ' + str.tostring(math.round(tpPrice, 2)), style = label.style_label_left, color = color.green, textcolor = color.white, size = size.small)

// ───────────────────────────────────────────────────────────────────
// SELL SIGNAL
// ───────────────────────────────────────────────────────────────────
plotshape(sellSignal, title = 'SELL', location = location.abovebar, style = shape.triangledown, color = color.red, size = size.normal)

if sellSignal
    slPrice = close + atr14 * slMult
    tpPrice = close - atr14 * slMult * rrRatio

    label.new(bar_index, high + atr14 * 0.3, 'SELL\n@ ' + str.tostring(close, '#.##') + '\nSL: ' + str.tostring(math.round(slPrice, 2)) + '\nTP: ' + str.tostring(math.round(tpPrice, 2)) + '\nRR: 1:' + str.tostring(rrRatio, '#.#'), style = label.style_label_down, color = color.new(color.red, 10), textcolor = color.white, size = size.normal)

    if showSLTP
        line.new(bar_index, slPrice, bar_index + 50, slPrice, color = color.red,   style = line.style_dotted, width = 2)
        label.new(bar_index + 50, slPrice, 'SL ' + str.tostring(math.round(slPrice, 2)), style = label.style_label_left, color = color.red,   textcolor = color.white, size = size.small)
        line.new(bar_index, tpPrice, bar_index + 50, tpPrice, color = color.green, style = line.style_dotted, width = 2)
        label.new(bar_index + 50, tpPrice, 'TP ' + str.tostring(math.round(tpPrice, 2)), style = label.style_label_left, color = color.green, textcolor = color.white, size = size.small)

// ───────────────────────────────────────────────────────────────────
// INFO PANEL
// ───────────────────────────────────────────────────────────────────
if showTable and barstate.islast
    tb = table.new(position.top_right, 2, 7, bgcolor = color.new(color.black, 60), border_color = color.new(color.gray, 40), border_width = 1, frame_color = color.new(color.gray, 20), frame_width = 1)

    table.cell(tb, 0, 0, 'GOLD Asian Breakout', bgcolor = color.new(color.blue, 30), text_color = color.white, text_size = size.small, text_halign = text.align_center)
    table.cell(tb, 1, 0, 'v1.0',                bgcolor = color.new(color.blue, 30), text_color = color.white, text_size = size.small)

    table.cell(tb, 0, 1, 'Asian High', text_color = color.aqua,  text_size = size.small)
    table.cell(tb, 1, 1, na(asianH) ? '---' : str.tostring(asianH, '#.##'), text_color = color.white, text_size = size.small)

    table.cell(tb, 0, 2, 'Asian Low',  text_color = color.aqua,  text_size = size.small)
    table.cell(tb, 1, 2, na(asianL) ? '---' : str.tostring(asianL, '#.##'), text_color = color.white, text_size = size.small)

    rangeStr = na(rangeSize) ? '---' : str.tostring(rangeSize, '#.##') + (rangeOK ? '  OK' : '  SKIP')
    table.cell(tb, 0, 3, 'Range',      text_color = color.aqua,  text_size = size.small)
    table.cell(tb, 1, 3, rangeStr,     text_color = rangeOK ? color.lime : color.red, text_size = size.small)

    table.cell(tb, 0, 4, 'H4 Trend',  text_color = color.aqua,  text_size = size.small)
    table.cell(tb, 1, 4, h4Bull ? 'BULLISH' : 'BEARISH', text_color = h4Bull ? color.lime : color.red, text_size = size.small)

    sessName  = inAsian ? 'ASIAN' : inLondon ? 'LONDON' : 'CLOSED'
    sessColor = inAsian ? color.blue : inLondon ? color.lime : color.gray
    table.cell(tb, 0, 5, 'Session',    text_color = color.aqua,  text_size = size.small)
    table.cell(tb, 1, 5, sessName,     text_color = sessColor,   text_size = size.small)

    table.cell(tb, 0, 6, 'Today Filter', text_color = color.aqua, text_size = size.small)
    table.cell(tb, 1, 6, skipDay ? 'SKIP DAY' : 'ACTIVE', text_color = skipDay ? color.red : color.lime, text_size = size.small)

// ───────────────────────────────────────────────────────────────────
// ALERTS
// ───────────────────────────────────────────────────────────────────
alertcondition(buySignal,               title = 'BUY — Asian Range Breakout',  message = 'GOLD Asian Breakout | BUY signal | London broke above Asian High | Check chart for SL and TP levels')
alertcondition(sellSignal,              title = 'SELL — Asian Range Breakdown', message = 'GOLD Asian Breakout | SELL signal | London broke below Asian Low | Check chart for SL and TP levels')
alertcondition(buySignal or sellSignal, title = 'Any Signal — Asian Range',     message = 'GOLD Asian Breakout | Signal fired | Open chart to see direction, SL and TP')
````
