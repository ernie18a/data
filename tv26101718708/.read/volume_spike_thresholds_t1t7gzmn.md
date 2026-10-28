# Volume Spike Thresholds

- url: https://www.tradingview.com/script/t1t7gZMN-Volume-Spike-Thresholds/
- type: indicator
- pine_id: PUB;baa8d0d5c934440b9dd41b097d1a2a93
- version: 1.0

## Description

The script automatically displays a real-time table showing:
Baseline SMA   →  Current 20-bar average (updates every bar)
Spike 175%     →  Exact contract number needed for Real Spike
Climax 250%    →  Exact contract number needed for Climactic
Current Vol    →  Live volume of the forming bar
                  (turns red or orange when thresholds are hit)

What You'll See
ColorMeaningActionTeal/Red (dim)Normal volume — below 130%IgnoreYellowElevated — 130–175%Watch next barBright Red + label "SPIKE"Real spike — 175–250%Setup activatingOrange + label "CLIMAX"Climactic — 250%+Read candle close immediately

KEY SETTINGS TO ADJUST:
Baseline SMA Length:     20  (default — works well for NQ 5-min)
                         10  (more reactive, good for volatile sessions)
Real Spike Multiplier:   1.75 (standard)
Climactic Multiplier:    2.50 (standard)
[i][b]Exclude 9:30 Open Bar:   TRUE  (always leave on for NQ)[/b]
[b]RTH Session:             0930-1600 (ET — already set correctly)[/b][/i]

## Source Code

````pine
//@version=6
indicator("Volume Spike Threshold [RichVPA]", 
     shorttitle="Vol Spike", 
     overlay=false)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
maLength     = input.int(20,   "Baseline SMA Length",     minval=1)
spikeLevel   = input.float(1.75, "Real Spike Multiplier",  step=0.05)
climaxLevel  = input.float(2.50, "Climactic Multiplier",   step=0.05)
excludeOpen  = input.bool(true,  "Exclude 9:30 Open Bar from Baseline")
showLabels   = input.bool(true,  "Show Spike Labels on Bars")
sessionInput = input.session("0930-1600", "RTH Session (ET)")

// ─────────────────────────────────────────────
// SESSION & OPEN BAR LOGIC
// ─────────────────────────────────────────────
isRTH        = not na(time(timeframe.period, sessionInput))
isOpenBar    = isRTH and not isRTH[1]  // First bar of RTH session

// Volume used for baseline — exclude 9:30 open bar if toggled
baseVol      = (excludeOpen and isOpenBar) ? na : volume

// ─────────────────────────────────────────────
// BASELINE & THRESHOLDS
// ─────────────────────────────────────────────
volSMA       = ta.sma(baseVol, maLength)
threshold175 = volSMA * spikeLevel
threshold250 = volSMA * climaxLevel

// ─────────────────────────────────────────────
// SPIKE CLASSIFICATION
// ─────────────────────────────────────────────
isNoise      = volume <  volSMA * 1.30
isElevated   = volume >= volSMA * 1.30 and volume < threshold175
isRealSpike  = volume >= threshold175   and volume < threshold250
isClimax     = volume >= threshold250

// ─────────────────────────────────────────────
// BAR COLORS
// ─────────────────────────────────────────────
barCol = isClimax    ? color.new(#FF6B00, 0)  :  // Orange  — Climactic
         isRealSpike ? color.new(#FF3333, 0)  :  // Red     — Real Spike
         isElevated  ? color.new(#FFD700, 40) :  // Yellow  — Elevated
         close >= open ? color.new(#26A69A, 60): // Teal    — Normal Up
                         color.new(#EF5350, 60)  // Red     — Normal Down

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────
// Volume bars
plot(volume, "Volume", style=plot.style_columns, color=barCol)

// Baseline SMA
plot(volSMA, "Baseline (SMA)", 
     color=color.new(color.white, 20), 
     linewidth=1, style=plot.style_line)

// 175% Real Spike Line
plot(threshold175, "Real Spike 175%", 
     color=color.new(#FF3333, 0), 
     linewidth=2, style=plot.style_line)

// 250% Climactic Line
plot(threshold250, "Climactic 250%", 
     color=color.new(#FF6B00, 0), 
     linewidth=2, style=plot.style_line)

// ─────────────────────────────────────────────
// LABELS ON SPIKE BARS
// ─────────────────────────────────────────────
if showLabels and isRealSpike
    label.new(bar_index, volume, 
         text="SPIKE", 
         style=label.style_label_up, 
         color=color.new(#FF3333, 20), 
         textcolor=color.white, 
         size=size.small)

if showLabels and isClimax
    label.new(bar_index, volume, 
         text="CLIMAX", 
         style=label.style_label_up, 
         color=color.new(#FF6B00, 10), 
         textcolor=color.white, 
         size=size.normal)

// ─────────────────────────────────────────────
// BACKGROUND HIGHLIGHT — Spike bars
// ─────────────────────────────────────────────
bgcolor(isRealSpike ? color.new(#FF3333, 90) : na, title="Spike BG")
bgcolor(isClimax    ? color.new(#FF6B00, 85) : na, title="Climax BG")

// ─────────────────────────────────────────────
// INFO TABLE — Live Session Stats
// ─────────────────────────────────────────────
var table infoTable = table.new(position.top_right, 2, 5,
     bgcolor=color.new(color.black, 70),
     border_color=color.new(color.gray, 50),
     border_width=1)

if barstate.islast
    table.cell(infoTable, 0, 0, "METRIC",        text_color=color.gray,  text_size=size.small)
    table.cell(infoTable, 1, 0, "VALUE",          text_color=color.gray,  text_size=size.small)
    table.cell(infoTable, 0, 1, "Baseline SMA",   text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(math.round(volSMA)), 
         text_color=color.yellow, text_size=size.small)
    table.cell(infoTable, 0, 2, "Spike (175%)",   text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(math.round(threshold175)), 
         text_color=#FF3333,     text_size=size.small)
    table.cell(infoTable, 0, 3, "Climax (250%)",  text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(math.round(threshold250)), 
         text_color=#FF6B00,     text_size=size.small)
    table.cell(infoTable, 0, 4, "Current Vol",    text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 4, str.tostring(volume), 
         text_color=isClimax ? #FF6B00 : isRealSpike ? #FF3333 : color.white, 
         text_size=size.small)
````
