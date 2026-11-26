# Multi-Timeframe Liquidity Zones

- url: https://www.tradingview.com/script/KeDmItaR/
- type: indicator
- pine_id: PUB;f29788793a3440e184a1090c32808c7b
- version: 2.0

## Description

# Multi-Timeframe Liquidity Zones

Multi-Timeframe Liquidity Zones automatically identifies and displays significant support and resistance areas derived from pivot structures across multiple timeframes.

Instead of relying on a single timeframe, the indicator combines pivot highs and pivot lows from up to four user-defined timeframes, helping traders identify key reaction zones where price may experience support, resistance, rejection, or liquidity sweeps.

The indicator intelligently filters nearby levels to reduce chart clutter and highlights only the most relevant zones. Each zone is labeled with its originating timeframe, making it easy to identify higher-timeframe confluence areas.

### Features

• Multi-timeframe support and resistance detection
• Up to four customizable timeframes
• Automatic level clustering and duplicate filtering
• Dynamic support and resistance zone visualization
• Timeframe labels for quick level identification
• Adjustable zone width
• Configurable number of displayed levels
• Clean and lightweight chart presentation

### How It Works

The indicator scans pivot highs and pivot lows from selected timeframes and converts them into price zones. Nearby levels are merged to eliminate redundancy and improve readability.

Resistance zones are displayed above the current market price, while support zones are displayed below it. This allows traders to quickly identify potential reversal areas, breakout levels, and liquidity pools.

### Best Used For

• Support and resistance trading
• Breakout confirmation
• Liquidity sweep analysis
• Market structure analysis
• Confluence-based trading strategies
• Multi-timeframe technical analysis

### Disclaimer

This indicator is intended for educational and analytical purposes only. No indicator can predict future market movements with certainty. Always use proper risk management and combine multiple forms of analysis before making trading decisions.

TradingView Short Description:

Identify high-probability support and resistance zones using pivot structures from multiple timeframes. The indicator filters overlapping levels, highlights key liquidity areas, and displays clean multi-timeframe confluence zones directly on the chart.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Onuriano


//@version=6
indicator('Multi-Timeframe Liquidity Zones', overlay = true, max_boxes_count = 500, max_labels_count = 500)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
tf1 = input.timeframe('15', 'Timeframe 1')
tf2 = input.timeframe('30', 'Timeframe 2')
tf3 = input.timeframe('45', 'Timeframe 3')
tf4 = input.timeframe('90', 'Timeframe 4')

lookback = input.int(80, 'Lookback Period', minval = 3, maxval = 1000)
zoneSize = input.float(0.002, 'Zone Width (%)', minval = 0.001, maxval = 0.02, step = 0.001)
maxShow = input.int(10, 'Maximum Levels Displayed', minval = 1, maxval = 20)

showTF1 = input.bool(true, 'Show TF1 Levels')
showTF2 = input.bool(true, 'Show TF2 Levels')
showTF3 = input.bool(true, 'Show TF3 Levels')
showTF4 = input.bool(true, 'Show TF4 Levels')

labelOffset = input.int(10, 'Label Distance', minval = 0, maxval = 100)
resCol = input.color(color.new(color.red, 55), 'Resistance Color')
supCol = input.color(color.new(color.green, 55), 'Support Color')

// ─── PIVOT DATA ──────────────────────────────────────────────────────────────
[tf1h, tf1l] = request.security(syminfo.tickerid, tf1, [ta.pivothigh(high, lookback, lookback), ta.pivotlow(low, lookback, lookback)])

[tf2h, tf2l] = request.security(syminfo.tickerid, tf2, [ta.pivothigh(high, lookback, lookback), ta.pivotlow(low, lookback, lookback)])

[tf3h, tf3l] = request.security(syminfo.tickerid, tf3, [ta.pivothigh(high, lookback, lookback), ta.pivotlow(low, lookback, lookback)])

[tf4h, tf4l] = request.security(syminfo.tickerid, tf4, [ta.pivothigh(high, lookback, lookback), ta.pivotlow(low, lookback, lookback)])

// ─── TIMEFRAME LABEL FUNCTION ────────────────────────────────────────────────
tfLabel(tf) =>
    switch tf
        '1' => '1m'
        '3' => '3m'
        '5' => '5m'
        '15' => '15m'
        '30' => '30m'
        '45' => '45m'
        '60' => '1H'
        '120' => '2H'
        '180' => '3H'
        '240' => '4H'
        'D' => '1D'
        'W' => '1W'
        'M' => '1M'
        => tf

// ─── LEVEL ARRAYS ────────────────────────────────────────────────────────────
var array<float> allLevels = array.new_float()
var array<string> allTFs = array.new_string()

addIfNew(val, tfName) =>
    if not na(val)
        isNew = true
        sz = array.size(allLevels)
        if sz > 0
            for i = 0 to sz - 1 by 1
                existing = array.get(allLevels, i)
                if math.abs(existing - val) / val < zoneSize * 1.5
                    isNew := false
                    break
        if isNew
            array.push(allLevels, val)
            array.push(allTFs, tfName)

if showTF1
    addIfNew(tf1h, tfLabel(tf1))
    addIfNew(tf1l, tfLabel(tf1))

if showTF2
    addIfNew(tf2h, tfLabel(tf2))
    addIfNew(tf2l, tfLabel(tf2))

if showTF3
    addIfNew(tf3h, tfLabel(tf3))
    addIfNew(tf3l, tfLabel(tf3))

if showTF4
    addIfNew(tf4h, tfLabel(tf4))
    addIfNew(tf4l, tfLabel(tf4))

// ─── DRAWING (LAST BAR ONLY) ─────────────────────────────────────────────────
if barstate.islast
    total = array.size(allLevels)

    if total > 0
        startIdx = math.max(0, total - maxShow)

        for i = startIdx to total - 1 by 1
            lvl = array.get(allLevels, i)
            tfName = array.get(allTFs, i)

            half = lvl * zoneSize / 2
            top = lvl + half
            bot = lvl - half

            col = lvl > close ? resCol : supCol

            // Support / Resistance Zone
            box.new(left = bar_index - lookback * 3, top = top, right = bar_index + 50, bottom = bot, border_color = col, bgcolor = col, border_width = 1, extend = extend.right)

            // Right-side timeframe label
            label.new(x = bar_index + 2 + labelOffset, y = (top + bot) / 2, text = tfName, color = color.new(col, 20), textcolor = color.white, style = label.style_label_left, size = size.small)
````
