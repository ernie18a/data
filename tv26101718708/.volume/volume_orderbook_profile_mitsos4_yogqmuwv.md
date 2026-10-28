# Volume Orderbook Profile (Mitsos4)

- url: https://www.tradingview.com/script/yOGqmuWV-Volume-Orderbook-Profile-Mitsos4/
- type: indicator
- pine_id: PUB;30b8f6a5c0784584b99e097463457d0f
- version: 1.0

## Description

Volume Orderbook (Mitsos4) — Multi-Timeframe Presets

A customised version of the original Volume Orderbook by Zeiierman, with additional configuration options designed to make the indicator easier to use across multiple timeframes.

This version focuses on timeframe-specific customisation, flexible orderbook sizing and improved preset control, allowing traders to tailor the orderbook display to their individual charting and trading styles.

Key Features

1. Automatic Timeframe Presets

Automatically applies your configured settings when switching chart timeframes.
Individual presets for 1m, 2m, 3m, 5m, 15m, 1H, 2H, 3H, 4H, 6H, 8H, 10H, 12H, 1D, 2D, 3D and 1W.
Enable or disable each timeframe independently.
Each preset has its own row count and width multiplier.

2. Independent Rows & Width Settings

Adjust the number of orderbook rows for each timeframe.
Control the width of the orderbook display independently for each timeframe.
Customise lower-timeframe views for faster trading while maintaining wider displays on higher timeframes.
Avoid relying on one universal set of settings for every chart timeframe.

3. Additional 2-Minute Timeframe

Adds a dedicated 2-minute preset with its own row and width settings, providing more flexibility for short-term analysis and scalping.

4. Manual Configuration Mode

Disable Timeframe Presets to use the original-style manual Rows and Width settings.
Retain control over the orderbook configuration without using automatic presets.

5. Customisable Visual Display

Adjustable red and green transparency.
Configurable volume text alignment: Left, Centre or Right.
Optional POC extension.
Optional grid lines and table display.
Selectable price source.
Designed for Multi-Timeframe Analysis

This modification is intended for traders who regularly switch between timeframes and want their orderbook to remain appropriately sized for each view.

Use shorter timeframes for more detailed intraday observation and higher timeframes to examine broader price areas. The independent presets make it easier to maintain a consistent chart layout without continually changing the settings manually.

Important Notes
This is a community modification of the original Zeiierman Volume Orderbook, with additional timeframe presets and configuration changes.
The indicator visualises volume distribution using its underlying calculation logic; it is not a live exchange order book displaying actual resting bid and ask liquidity.
The indicator does not provide guaranteed support/resistance levels or trading signals. Use it alongside your own analysis and risk management.

Credits: Original concept and underlying script by Zeiierman. Custom modifications and timeframe preset configuration by Mitsos4.

Please refer to the original script's licence and attribution requirements when using or redistributing this modified version.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// © Mitsos4

//@version=6

indicator('Volume Orderbook (Mitsos4)', overlay = true, max_boxes_count = 500, max_lines_count = 500)

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Inputs
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

src = input.source(close, 'Source')

// Original manual settings.
// These are used when Timeframe Presets are disabled,
// or when a timeframe preset is disabled.
manualRows = input.int(10, 'Rows', 0, 50, inline = 'rows')
manualWidth = input.float(.5, 'Width', .1, 10, step = .05, inline = 'rows')
poc = input.bool(false, 'POC', inline = 'rows')

tbl = input.bool(false, 'Table', inline = 'table')
left = input.int(5, 'Left', -100, 50, 5, inline = 'table')
tbli = input.bool(false, 'Grid', inline = 'table')

redTransparency = input.int(80, 'Red Transparency', minval = 0, maxval = 100, step = 5)
greenTransparency = input.int(80, 'Green Transparency', minval = 0, maxval = 100, step = 5)

textPosition = input.string('Center', 'Text Position', options = ['Left', 'Center', 'Right'])

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Timeframe Presets
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

presetGroup = 'Timeframe Presets'

usePresets = input.bool(true, 'Use Timeframe Presets', group = presetGroup)

//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// Minutes
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

group1m = '1 Minute'
enable1m = input.bool(true, 'Enable', group = group1m, inline = '1m')
rows1m = input.int(20, 'Rows', 0, 50, group = group1m, inline = '1m')
width1m = input.float(1.40, 'Width', .1, 10, step = .05, group = group1m, inline = '1m')

group2m = '2 Minutes'
enable2m = input.bool(true, 'Enable', group = group2m, inline = '2m')
rows2m = input.int(25, 'Rows', 0, 50, group = group2m, inline = '2m')
width2m = input.float(2.85, 'Width', .1, 10, step = .05, group = group2m, inline = '2m')

group3m = '3 Minutes'
enable3m = input.bool(true, 'Enable', group = group3m, inline = '3m')
rows3m = input.int(20, 'Rows', 0, 50, group = group3m, inline = '3m')
width3m = input.float(.55, 'Width', .1, 10, step = .05, group = group3m, inline = '3m')

group5m = '5 Minutes'
enable5m = input.bool(true, 'Enable', group = group5m, inline = '5m')
rows5m = input.int(20, 'Rows', 0, 50, group = group5m, inline = '5m')
width5m = input.float(.55, 'Width', .1, 10, step = .05, group = group5m, inline = '5m')

group15m = '15 Minutes'
enable15m = input.bool(true, 'Enable', group = group15m, inline = '15m')
rows15m = input.int(20, 'Rows', 0, 50, group = group15m, inline = '15m')
width15m = input.float(.15, 'Width', .1, 10, step = .05, group = group15m, inline = '15m')

//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// Hours
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

group1h = '1 Hour'
enable1h = input.bool(true, 'Enable', group = group1h, inline = '1h')
rows1h = input.int(20, 'Rows', 0, 50, group = group1h, inline = '1h')
width1h = input.float(.75, 'Width', .1, 10, step = .05, group = group1h, inline = '1h')

group2h = '2 Hours'
enable2h = input.bool(true, 'Enable', group = group2h, inline = '2h')
rows2h = input.int(20, 'Rows', 0, 50, group = group2h, inline = '2h')
width2h = input.float(1.00, 'Width', .1, 10, step = .05, group = group2h, inline = '2h')

group3h = '3 Hours'
enable3h = input.bool(true, 'Enable', group = group3h, inline = '3h')
rows3h = input.int(20, 'Rows', 0, 50, group = group3h, inline = '3h')
width3h = input.float(4.50, 'Width', .1, 10, step = .05, group = group3h, inline = '3h')

group4h = '4 Hours'
enable4h = input.bool(true, 'Enable', group = group4h, inline = '4h')
rows4h = input.int(20, 'Rows', 0, 50, group = group4h, inline = '4h')
width4h = input.float(4.80, 'Width', .1, 10, step = .05, group = group4h, inline = '4h')

group6h = '6 Hours'
enable6h = input.bool(true, 'Enable', group = group6h, inline = '6h')
rows6h = input.int(20, 'Rows', 0, 50, group = group6h, inline = '6h')
width6h = input.float(1.80, 'Width', .1, 10, step = .05, group = group6h, inline = '6h')

group8h = '8 Hours'
enable8h = input.bool(true, 'Enable', group = group8h, inline = '8h')
rows8h = input.int(20, 'Rows', 0, 50, group = group8h, inline = '8h')
width8h = input.float(2.00, 'Width', .1, 10, step = .05, group = group8h, inline = '8h')

group10h = '10 Hours'
enable10h = input.bool(false, 'Enable', group = group10h, inline = '10h')
rows10h = input.int(0, 'Rows', 0, 50, group = group10h, inline = '10h')
width10h = input.float(.10, 'Width', .1, 10, step = .05, group = group10h, inline = '10h')

group12h = '12 Hours'
enable12h = input.bool(true, 'Enable', group = group12h, inline = '12h')
rows12h = input.int(15, 'Rows', 0, 50, group = group12h, inline = '12h')
width12h = input.float(1.25, 'Width', .1, 10, step = .05, group = group12h, inline = '12h')

//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// Days
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

group1d = '1 Day'
enable1d = input.bool(true, 'Enable', group = group1d, inline = '1d')
rows1d = input.int(20, 'Rows', 0, 50, group = group1d, inline = '1d')
width1d = input.float(4.65, 'Width', .1, 10, step = .05, group = group1d, inline = '1d')

group2d = '2 Days'
enable2d = input.bool(true, 'Enable', group = group2d, inline = '2d')
rows2d = input.int(20, 'Rows', 0, 50, group = group2d, inline = '2d')
width2d = input.float(4.65, 'Width', .1, 10, step = .05, group = group2d, inline = '2d')

group3d = '3 Days'
enable3d = input.bool(true, 'Enable', group = group3d, inline = '3d')
rows3d = input.int(25, 'Rows', 0, 50, group = group3d, inline = '3d')
width3d = input.float(1.70, 'Width', .1, 10, step = .05, group = group3d, inline = '3d')

//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// Weekly
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

group1w = '1 Week'
enable1w = input.bool(false, 'Enable', group = group1w, inline = '1w')
rows1w = input.int(0, 'Rows', 0, 50, group = group1w, inline = '1w')
width1w = input.float(.10, 'Width', .1, 10, step = .05, group = group1w, inline = '1w')

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Select Rows and Width BEFORE creating the original Mitsos4 arrays
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int rows = manualRows
float mult = manualWidth

if usePresets

    switch timeframe.period

        '1' =>
            if enable1m
                rows := rows1m
                mult := width1m

        '2' =>
            if enable2m
                rows := rows2m
                mult := width2m

        '3' =>
            if enable3m
                rows := rows3m
                mult := width3m

        '5' =>
            if enable5m
                rows := rows5m
                mult := width5m

        '15' =>
            if enable15m
                rows := rows15m
                mult := width15m

        '60' =>
            if enable1h
                rows := rows1h
                mult := width1h

        '120' =>
            if enable2h
                rows := rows2h
                mult := width2h

        '180' =>
            if enable3h
                rows := rows3h
                mult := width3h

        '240' =>
            if enable4h
                rows := rows4h
                mult := width4h

        '360' =>
            if enable6h
                rows := rows6h
                mult := width6h

        '480' =>
            if enable8h
                rows := rows8h
                mult := width8h

        '600' =>
            if enable10h
                rows := rows10h
                mult := width10h

        '720' =>
            if enable12h
                rows := rows12h
                mult := width12h

        '1D' =>
            if enable1d
                rows := rows1d
                mult := width1d

        '2D' =>
            if enable2d
                rows := rows2d
                mult := width2d

        '3D' =>
            if enable3d
                rows := rows3d
                mult := width3d

        '1W' =>
            if enable1w
                rows := rows1w
                mult := width1w

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Variables & Array's
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

b = bar_index

var step = 0.0

type Table
    array<box> boxes
    array<line> lines
    array<label> lab

var levels = array.new<float>()
var volumes = array.new<float>()

// IMPORTANT:
// These are the original Mitsos4 array definitions.
// They use the selected Rows value before the first bar executes.
var vols = array.new<float>(rows * 2 + 1)

var tab = Table.new(
     array.new<box>(rows * 2 + 2),
     array.new<line>(rows * 2 + 1),
     array.new<label>(rows * 2 + 1))

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Code
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// Save first candle size
if barstate.isfirst
    step := (high - low) * mult
    step

// Stores each candle volume in levels
if levels.size() <= 0

    levels.push(src + step)
    levels.push(src - step)
    volumes.push(volume)

else

    found = false

    for i = 0 to levels.size() - 2 by 1

        lvl1 = levels.get(i)
        lvl2 = levels.get(i + 1)

        if src < lvl1 and src > lvl2

            volumes.set(i, volumes.get(i) + volume)
            found := true
            break

    if not found

        if src > levels.get(0)

            lvl = levels.get(0)

            while src > lvl

                levels.unshift(lvl + step)
                volumes.unshift(0)

                lvl := lvl + step
                lvl

            levels.unshift(lvl + step)
            volumes.unshift(volume)

        else if src < levels.get(levels.size() - 1)

            lvl = levels.get(levels.size() - 1)

            while src < lvl

                levels.push(lvl - step)
                volumes.push(0)

                lvl := lvl - step
                lvl

            levels.push(lvl - step)
            volumes.push(volume)

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Plots the orderbook
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if barstate.islast

    for i = 0 to levels.size() - 2 by 1

        if src < levels.get(i) and src > levels.get(i + 1)

            for x = 0 to math.min(volumes.size() - 1, rows * 2) by 1

                if i - rows + x < volumes.size() - 1

                    vols.set(x, volumes.get(math.max(0, i - rows + x)))

                else

                    vols.set(x, 0.0)

            vol = vols.copy()

            vols.sort()

            log.error(str.tostring(vols))

            for x = 0 to rows * 2 by 1

                if i - rows + x < levels.size() - 1

                    tab.boxes.get(x).delete()

                    col = x < rows ? color.red : x > rows ? color.lime : color.gray

                    transparency = x < rows ? redTransparency : greenTransparency

                    colgrade = color.from_gradient(
                         vols.indexof(vol.get(x)),
                         0,
                         vols.size(),
                         color.new(col, transparency),
                         color.new(col, transparency))

                    tab.boxes.set(
                         x,
                         box.new(
                             b + left + rows * 2 - vols.indexof(vol.get(x)),
                             levels.get(math.max(0, i - rows + x)),
                             b + left + rows * 2 + vols.indexof(vol.get(x)),
                             levels.get(math.max(1, i - rows + x + 1)),
                             colgrade,
                             bgcolor = colgrade,
                             border_style = line.style_dotted,
                             text = str.tostring(vol.get(x), format.volume),
                             text_color = chart.fg_color,
                             text_halign = textPosition == 'Left' ? text.align_left : textPosition == 'Right' ? text.align_right : text.align_center,
                             extend = poc and vols.indexof(vol.get(x)) == rows * 2 ? extend.left : extend.none))

                    if tbli and i - rows + x >= 0

                        tab.lines.get(x).delete()

                        tab.lines.set(
                             x,
                             line.new(
                                 b + left,
                                 levels.get(i - rows + x),
                                 math.min(b + left + rows * 2 + vols.size() - 1, b + 500),
                                 levels.get(i - rows + x),
                                 color = color.gray))

            if tbl

                tab.boxes.get(rows * 2 + 1).delete()

                tab.boxes.set(
                     rows * 2 + 1,
                     box.new(
                         b + left,
                         box.get_top(tab.boxes.get(0)),
                         b + left + rows * 2 + vols.size() - 1,
                         box.get_bottom(tab.boxes.get(rows * 2)),
                         color.gray,
                         border_width = 2,
                         bgcolor = color(na)))
````
