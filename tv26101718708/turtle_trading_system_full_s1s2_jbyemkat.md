# Turtle Trading System - Full (S1+S2)

- url: https://www.tradingview.com/script/jbyeMkat/
- type: indicator
- pine_id: PUB;1f4795e85de241de84a35b7b7fff8075
- version: 2.0

## Description

Turtle Trading System - Full (System 1 + System 2)

A complete implementation of the original Turtle Trading rules (Richard Dennis, 1983), 
built for Daily timeframe use. Pine Script v6.

FEATURES:
- System 1: 20-day breakout entry / 10-day breakout exit
- System 2: 55-day breakout entry / 20-day breakout exit (failsafe, never filtered)
- Last-Trade Filter: skips a System 1 signal if the prior System 1 trade was a winner, 
  reducing false breakouts in ranging markets. Falls through to System 2 when filtered.
- ATR-based (N) position sizing reference and 2N initial stop
- Pyramiding: adds units every 0.5N in the favorable direction, up to 4 units max
- Trailing stop that only tightens in the trade's favor, never loosens
- No-repaint option: signals confirm only on closed bars (barstate.isconfirmed)
- Live status table: current position, units held, active system, current N, filter state

NOTES:
- Calibrated for Daily charts, consistent with the original system's historical backtesting. 
  Using it on lower timeframes changes what the lookback lengths represent and has not been 
  validated here.
- The Last-Trade Filter only tracks trades entered via System 1. Trades triggered by the 
  System 2 failsafe do not update the filter, per the original rule set.
- This is a signal/reference tool, not an auto-trading strategy. Verify signals in replay 
  mode before trading live.  Be claude IA

## Source Code

````pine
//@version=6
indicator('Turtle Trading System - Full (S1+S2)', shorttitle = 'Turtle-Full', overlay = true)

// ── Inputs ──────────────────────────────────────────────
s1Entry = input.int(20, 'System 1 Entry Length', minval = 1, group = 'System 1')
s1Exit = input.int(10, 'System 1 Exit Length', minval = 1, group = 'System 1')
useS1Filter = input.bool(true, 'Apply Last-Trade Filter (skip S1 if prior S1 trade won)', group = 'System 1')

useS2 = input.bool(true, 'Enable System 2 Failsafe (55/20)', group = 'System 2')
s2Entry = input.int(55, 'System 2 Entry Length', minval = 1, group = 'System 2')
s2Exit = input.int(20, 'System 2 Exit Length', minval = 1, group = 'System 2')

atrLen = input.int(20, 'N (ATR) Length', minval = 1, group = 'Risk')
stopMult = input.float(2.0, 'Initial Stop (N multiple)', minval = 0.1, group = 'Risk')
unitAdd = input.float(0.5, 'Pyramid Add-On Spacing (N multiple)', minval = 0.1, group = 'Risk')
maxUnits = input.int(4, 'Max Units', minval = 1, maxval = 6, group = 'Risk')

confirmOnly = input.bool(true, 'Confirmed bars only (no repaint)', group = 'Engine')

showExitLevels = input.bool(true, 'Show Exit Channel Lines', group = 'Display')

// ── Core channels ───────────────────────────────────────
N = ta.atr(atrLen)
canSignal = confirmOnly ? barstate.isconfirmed : true

s1Upper = ta.highest(high, s1Entry)[1]
s1Lower = ta.lowest(low, s1Entry)[1]
s1ExitL = ta.lowest(low, s1Exit)[1]
s1ExitS = ta.highest(high, s1Exit)[1]

s2Upper = ta.highest(high, s2Entry)[1]
s2Lower = ta.lowest(low, s2Entry)[1]
s2ExitL = ta.lowest(low, s2Exit)[1]
s2ExitS = ta.highest(high, s2Exit)[1]

// ── State ───────────────────────────────────────────────
var int position = 0 // 1 long, -1 short, 0 flat
var int units = 0
var float entryPrice = na
var float stopLevel = na
var float lastAddPrice = na
var string activeSystem = ''

var bool lastS1WasWin = false
var float s1TradeEntryPrice = na

// ── Raw breakout triggers ───────────────────────────────
s1LongTrig = canSignal and high > s1Upper
s1ShortTrig = canSignal and low < s1Lower
s2LongTrig = canSignal and high > s2Upper
s2ShortTrig = canSignal and low < s2Lower

s1LongAllowed = not(useS1Filter and lastS1WasWin)
s1ShortAllowed = not(useS1Filter and lastS1WasWin)

longEntry = position <= 0 and (s1LongTrig and s1LongAllowed or useS2 and s2LongTrig and (s1LongTrig and not s1LongAllowed or not s1LongTrig))
shortEntry = position >= 0 and (s1ShortTrig and s1ShortAllowed or useS2 and s2ShortTrig and (s1ShortTrig and not s1ShortAllowed or not s1ShortTrig))

longExit = canSignal and position == 1 and low < (activeSystem == 'S2' ? s2ExitL : s1ExitL)
shortExit = canSignal and position == -1 and high > (activeSystem == 'S2' ? s2ExitS : s1ExitS)

// ── Entrées ─────────────────────────────────────────────
if longEntry
    activeSystem := s1LongTrig and s1LongAllowed ? 'S1' : 'S2'
    position := 1
    units := 1
    entryPrice := close
    lastAddPrice := close
    stopLevel := close - stopMult * N
    if activeSystem == 'S1'
        s1TradeEntryPrice := close
        s1TradeEntryPrice

if shortEntry
    activeSystem := s1ShortTrig and s1ShortAllowed ? 'S1' : 'S2'
    position := -1
    units := 1
    entryPrice := close
    lastAddPrice := close
    stopLevel := close + stopMult * N
    if activeSystem == 'S1'
        s1TradeEntryPrice := close
        s1TradeEntryPrice

// ── Pyramidage ────────────────────────────────────────
addLong = position == 1 and units < maxUnits and canSignal and high > lastAddPrice + unitAdd * N
addShort = position == -1 and units < maxUnits and canSignal and low < lastAddPrice - unitAdd * N

if addLong
    units := units + 1
    lastAddPrice := close
    stopLevel := math.max(stopLevel, close - stopMult * N)
    stopLevel
if addShort
    units := units + 1
    lastAddPrice := close
    stopLevel := math.min(stopLevel, close + stopMult * N)
    stopLevel

// ── Trailing du stop ─────────────────────────────────
if position == 1
    stopLevel := math.max(stopLevel, close - stopMult * N)
    stopLevel
if position == -1
    stopLevel := math.min(stopLevel, close + stopMult * N)
    stopLevel

stopHitLong = position == 1 and low < stopLevel
stopHitShort = position == -1 and high > stopLevel

if (longExit or stopHitLong) and position == 1
    if activeSystem == 'S1'
        lastS1WasWin := close > s1TradeEntryPrice
        lastS1WasWin
    position := 0
    units := 0
    stopLevel := na
    activeSystem := ''
    activeSystem

if (shortExit or stopHitShort) and position == -1
    if activeSystem == 'S1'
        lastS1WasWin := close < s1TradeEntryPrice
        lastS1WasWin
    position := 0
    units := 0
    stopLevel := na
    activeSystem := ''
    activeSystem

// ── Exit channel level (affichage uniquement) ────────────
longExitLevel = position == 1 ? (activeSystem == 'S2' ? s2ExitL : s1ExitL) : na
shortExitLevel = position == -1 ? (activeSystem == 'S2' ? s2ExitS : s1ExitS) : na

// ── Plots ───────────────────────────────────────────────
// Canaux d'entrée : bleu = System 1 (20j), violet = System 2 (55j)
plot(s1Upper, 'S1 Upper', color = color.new(color.blue, 40))
plot(s1Lower, 'S1 Lower', color = color.new(color.blue, 40))
plot(useS2 ? s2Upper : na, 'S2 Upper', color = color.new(color.purple, 40), linewidth = 1)
plot(useS2 ? s2Lower : na, 'S2 Lower', color = color.new(color.purple, 40), linewidth = 1)

// Stop trailing : orange, ligne pleine
plot(position != 0 ? stopLevel : na, 'Stop (2N trailing)', color = color.orange, style = plot.style_linebr, linewidth = 2)

// Lignes de sortie de canal : vert = niveau de sortie long, rouge = niveau de sortie short
// (couleur cohérente avec le sens de la position : vert=long, rouge=short, orange=stop)
plot(showExitLevels ? longExitLevel : na, 'Long Exit Level', color = color.new(color.green, 30), style = plot.style_circles, linewidth = 2)
plot(showExitLevels ? shortExitLevel : na, 'Short Exit Level', color = color.new(color.red, 30), style = plot.style_circles, linewidth = 2)

plotshape(longEntry, title = 'Long Entry', location = location.belowbar, style = shape.labelup, color = color.green, text = 'L', textcolor = color.white, size = size.tiny)
plotshape(shortEntry, title = 'Short Entry', location = location.abovebar, style = shape.labeldown, color = color.red, text = 'S', textcolor = color.white, size = size.tiny)
plotshape(addLong, title = 'Add Unit Long', location = location.belowbar, style = shape.triangleup, color = color.new(color.green, 30), size = size.tiny)
plotshape(addShort, title = 'Add Unit Short', location = location.abovebar, style = shape.triangledown, color = color.new(color.red, 30), size = size.tiny)
plotshape((longExit or stopHitLong) and position == 1, title = 'Long Exit', location = location.abovebar, style = shape.xcross, color = color.blue, size = size.tiny)
plotshape((shortExit or stopHitShort) and position == -1, title = 'Short Exit', location = location.belowbar, style = shape.xcross, color = color.blue, size = size.tiny)

// ── Alertes (symétriques long/short) ───────────────────────
alertcondition(longEntry, title = 'Long Entry (L)', message = 'Turtle: nouvelle entrée LONG sur {{ticker}} à {{close}}')
alertcondition(shortEntry, title = 'Short Entry (S)', message = 'Turtle: nouvelle entrée SHORT sur {{ticker}} à {{close}}')

alertcondition(addLong, title = 'Long Pyramid Add', message = 'Turtle: unité ajoutée à la position LONG sur {{ticker}} à {{close}}')
alertcondition(addShort, title = 'Short Pyramid Add', message = 'Turtle: unité ajoutée à la position SHORT sur {{ticker}} à {{close}}')

alertcondition((longExit or stopHitLong) and position == 1, title = 'Long Exit', message = 'Turtle: sortie de position LONG sur {{ticker}} à {{close}}')
alertcondition((shortExit or stopHitShort) and position == -1, title = 'Short Exit', message = 'Turtle: sortie de position SHORT sur {{ticker}} à {{close}}')

// ── Table d'état ────────────────────────────────────────
var table info = table.new(position.top_right, 2, 5, border_width = 1)
if barstate.islast
    table.cell(info, 0, 0, 'Position', bgcolor = color.gray, text_color = color.white)
    table.cell(info, 1, 0, position == 1 ? 'LONG' : position == -1 ? 'SHORT' : 'FLAT', bgcolor = color.gray, text_color = color.white)
    table.cell(info, 0, 1, 'Units', bgcolor = color.gray, text_color = color.white)
    table.cell(info, 1, 1, str.tostring(units), bgcolor = color.gray, text_color = color.white)
    table.cell(info, 0, 2, 'System', bgcolor = color.gray, text_color = color.white)
    table.cell(info, 1, 2, activeSystem, bgcolor = color.gray, text_color = color.white)
    table.cell(info, 0, 3, 'N (ATR)', bgcolor = color.gray, text_color = color.white)
    table.cell(info, 1, 3, str.tostring(math.round(N, 3)), bgcolor = color.gray, text_color = color.white)
    table.cell(info, 0, 4, 'S1 Filter', bgcolor = color.gray, text_color = color.white)
    table.cell(info, 1, 4, lastS1WasWin ? 'SKIP next S1' : 'S1 active', bgcolor = color.gray, text_color = color.white)
````
