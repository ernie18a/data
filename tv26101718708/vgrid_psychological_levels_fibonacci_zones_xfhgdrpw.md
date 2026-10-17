# Vgrid - Psychological Levels, Fibonacci Zones

- url: https://www.tradingview.com/script/xFhgdRPW-Vgrid-Psychological-Levels-Fibonacci-Zones/
- type: indicator
- pine_id: PUB;36bb82c7f213405a832dbac3dc483f05
- version: 1.0

## Description

Vgrid plots a dynamic price grid anchored to psychological round numbers with Fibonacci retracement levels drawn inside each zone automatically.

Features:

Auto grid sizing for 14 instruments (Gold, Forex pairs, Bitcoin, Silver) — no manual setup needed
Fibonacci levels (0.236 / 0.382 / 0.5 / 0.618 / 0.786) drawn within every grid zone
Toggle grid lines, grid labels, fib lines, and fib labels independently
Solid or dashed line style for grid and fibs separately
Labels stay anchored to current price — no drift during bar replay or timeframe switching
Full color control for grid lines, fib lines, and label text separately
Works on all timeframes and all instruments
Best used for:
Identifying key reaction zones where psychological price levels and Fibonacci confluence align — a common area for reversals, entries, and targets.

## Source Code

````pine
//@version=5
indicator("Vgrid", overlay=true, max_lines_count=500, max_labels_count=500)

// ─── GRID SETTINGS ─────────────────────────────────────────────────────────────
gridInput   = input.float(500, "Grid Step (Points)",
              options=[10000, 5000, 2500, 1000, 500, 250, 100, 50, 25, 10, 5, 2.5, 1, 0.5, 0.25, 0.1, 0.05, 0.025, 0.01, 0.005],
              group="Grid Settings")
useManual   = input.bool(true, "Override Auto Grid", group="Grid Settings", display=display.all - display.status_line)
levelsAbove = input.int(15, "Levels Above Price", minval=1, maxval=100, group="Grid Settings", display=display.all - display.status_line)
levelsBelow = input.int(15, "Levels Below Price", minval=1, maxval=100, group="Grid Settings", display=display.all - display.status_line)

// ─── AUTO GRID ─────────────────────────────────────────────────────────────────
autoGrid =
     syminfo.ticker == "XAUUSD" ? 250 :
     syminfo.ticker == "EURUSD" ? 0.025 :
     syminfo.ticker == "XAGUSD" ? 25 :
     syminfo.ticker == "BTCUSD" ? 5000 :
     syminfo.ticker == "GBPUSD" ? 0.025 :
     syminfo.ticker == "USDJPY" ? 2.5 :
     syminfo.ticker == "AUDUSD" ? 0.01 :
     syminfo.ticker == "GBPJPY" ? 2.5 :
     syminfo.ticker == "NZDUSD" ? 0.025 :
     syminfo.ticker == "EURJPY" ? 2.5 :
     syminfo.ticker == "EURNZD" ? 0.05 :
     syminfo.ticker == "USDCHF" ? 0.025 :
     syminfo.ticker == "USDCAD" ? 0.025 :
     syminfo.ticker == "EURGBP" ? 0.01 :
     gridInput

gridSize = useManual ? gridInput : autoGrid

// ─── GRID LINE SETTINGS (Psychological Numbers) ────────────────────────────────
showGridLines  = input.bool(true,    "Show Grid Lines",  group="Grid Lines (Psychological)", display=display.all - display.status_line)
showGridLabels = input.bool(true,    "Show Grid Labels", group="Grid Lines (Psychological)", display=display.all - display.status_line)
gridLineStyle  = input.string("solid", "Line Style", options=["solid", "dashed"], group="Grid Lines (Psychological)", display=display.all - display.status_line)
lineColor      = input.color(color.new(color.purple, 30), "Line Color",       group="Grid Lines (Psychological)", display=display.all - display.status_line)
labelTxtClr    = input.color(color.purple,                "Label Text Color", group="Grid Lines (Psychological)", display=display.all - display.status_line)

// ─── FIBONACCI SETTINGS ────────────────────────────────────────────────────────
showFibs      = input.bool(true, "Show Fib Levels", group="Fibonacci Levels", display=display.all - display.status_line)
showFibLabels = input.bool(true, "Show Fib Labels",  group="Fibonacci Levels", display=display.all - display.status_line)
fibLineStyle  = input.string("solid", "Line Style", options=["solid", "dashed"], group="Fibonacci Levels", display=display.all - display.status_line)
fibWidth      = input.int(1, "Fib Line Width", minval=1, maxval=4, group="Fibonacci Levels", display=display.all - display.status_line)
fibColor      = input.color(color.new(#D3D3D3, 40), "Fib Line Color",       group="Fibonacci Levels", display=display.all - display.status_line)
fibLabelTxt   = input.color(#D3D3D3,               "Fib Label Text Color", group="Fibonacci Levels", display=display.all - display.status_line)

// ─── STORAGE ───────────────────────────────────────────────────────────────────
var line[]  lines     = array.new_line()
var label[] labels    = array.new_label()
var line[]  fibLines  = array.new_line()
var label[] fibLabels = array.new_label()
var float   lastBase  = na

// ─── CURRENT BASE ──────────────────────────────────────────────────────────────
base = math.floor(close / gridSize) * gridSize

// ─── KEEP LABELS ANCHORED TO CURRENT BAR (runs every bar) ─────────────────────
if array.size(labels) > 0
    for i = 0 to array.size(labels) - 1
        label.set_x(array.get(labels, i), bar_index + 50)

if array.size(fibLabels) > 0
    for i = 0 to array.size(fibLabels) - 1
        label.set_x(array.get(fibLabels, i), bar_index + 50)

// ─── REDRAW ON GRID SHIFT ──────────────────────────────────────────────────────
if na(lastBase) or base != lastBase

    // Clear grid lines + labels
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            line.delete(array.get(lines, i))
    if array.size(labels) > 0
        for i = 0 to array.size(labels) - 1
            label.delete(array.get(labels, i))
    array.clear(lines)
    array.clear(labels)

    // Clear fib lines + labels
    if array.size(fibLines) > 0
        for i = 0 to array.size(fibLines) - 1
            line.delete(array.get(fibLines, i))
    if array.size(fibLabels) > 0
        for i = 0 to array.size(fibLabels) - 1
            label.delete(array.get(fibLabels, i))
    array.clear(fibLines)
    array.clear(fibLabels)

    resolvedGridStyle = gridLineStyle == "dashed" ? line.style_dashed : line.style_solid
    resolvedFibStyle  = fibLineStyle  == "dashed" ? line.style_dashed : line.style_solid

    // Draw grid lines (psychological numbers)
    for i = -levelsBelow to levelsAbove
        level = base + (i * gridSize)
        txt   = str.tostring(level, format.mintick)

        if showGridLines
            ln = line.new(bar_index, level, bar_index + 1, level,
                 xloc=xloc.bar_index, extend=extend.both,
                 color=lineColor, style=resolvedGridStyle, width=1)
            array.push(lines, ln)

        if showGridLabels
            lb = label.new(bar_index + 50, level, txt,
                 style=label.style_label_left,
                 color=color.new(lineColor, 85),
                 textcolor=labelTxtClr, size=size.tiny)
            array.push(labels, lb)

    // Draw fibonacci levels within each grid zone
    if showFibs
        fibRatios = array.from(0.236, 0.382, 0.500, 0.618, 0.786)
        fibTxts   = array.from("0.236", "0.382", "0.5", "0.618", "0.786")

        for i = -levelsBelow to levelsAbove - 1
            zoneLow  = base + (i       * gridSize)
            zoneHigh = base + ((i + 1) * gridSize)

            for j = 0 to 4
                fLevel = zoneLow + array.get(fibRatios, j) * (zoneHigh - zoneLow)

                fl = line.new(bar_index, fLevel, bar_index + 1, fLevel,
                     xloc=xloc.bar_index, extend=extend.both,
                     color=fibColor, style=resolvedFibStyle, width=fibWidth)
                array.push(fibLines, fl)

                if showFibLabels
                    flb = label.new(bar_index + 50, fLevel, array.get(fibTxts, j),
                          style=label.style_label_left,
                          color=color.new(fibColor, 90),
                          textcolor=fibLabelTxt, size=size.tiny)
                    array.push(fibLabels, flb)

    lastBase := base
````
