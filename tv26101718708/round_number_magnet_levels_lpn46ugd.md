# Round Number Magnet Levels

- url: https://www.tradingview.com/script/LPN46ugD-Round-Number-Magnet-Levels/
- type: indicator
- pine_id: PUB;1d738a4c8a7d483e903c3efe099bc410
- version: 1.0

## Description

═══════════════════════════════════════════
ROUND NUMBER MAGNET LEVELS
═══════════════════════════════════════════

OVERVIEW
Round Number Magnet Levels automatically plots the nearest psychological round-number price levels around the current price. Round numbers act as natural support and resistance because traders cluster their orders, stop-losses, and targets at these "round" prices. This tool is built specifically for Indian indices — Nifty, BankNifty, and Sensex — and keeps your chart clean by showing only the most relevant levels near price instead of cluttering it with every level.

───────────────────────────────────────────
DESIGNED FOR NIFTY, BANKNIFTY & SENSEX
───────────────────────────────────────────
The indicator auto-detects the instrument and applies the correct interval:
- Nifty   → 100-point levels
- BankNifty → 500-point levels
- Sensex  → 500-point levels
No manual setup needed — switch between the three indices and the levels adjust on their own. A manual interval option is also available for any other instrument.

───────────────────────────────────────────
HOW IT WORKS
───────────────────────────────────────────
The script draws a fixed number of round levels above and below the current price, split into two visual tiers:

- MAJOR levels (every Nth interval) — drawn as thicker, highlighted lines. These are the strongest psychological magnets (e.g. Nifty 24000, 24500).
- MINOR levels — drawn as thinner lines for secondary reference.

As price moves, the levels rebuild around the latest price, so the nearest zones are always in view. Clean labels show each level as a round number with no decimal clutter.

───────────────────────────────────────────
HOW TO USE
───────────────────────────────────────────
- Watch for price reactions (rejection or acceptance) at major levels for potential support/resistance.
- Use the levels as logical reference points for targets and stop placement.
- Combine with your own price-action or confirmation method — round levels mark where reactions are likely, not guaranteed.
- Works best on intraday timeframes (15m, 1H) for Nifty, BankNifty, and Sensex.

───────────────────────────────────────────
SETTINGS
───────────────────────────────────────────
- Auto-detect interval — picks the right round-number step per instrument; can be turned off for a manual interval.
- Major level frequency — defines how often a level is treated as "major."
- Levels above & below — controls how many levels are shown on each side of price.
- Visual controls — separate colors, line widths, and label settings for major and minor levels.

───────────────────────────────────────────
NOTES
───────────────────────────────────────────
This is a discretionary support/resistance tool, not a buy/sell signal generator. It does not repaint — levels are derived purely from current price and the chosen interval. Always do your own analysis and manage risk; past behavior at a level does not guarantee future reactions.

## Source Code

````pine
// © darshakssc
//@version=6
indicator("Round Number Magnet Levels 🐘 by @darshakssc", overlay = true, max_lines_count = 20, max_labels_count = 20)

// ═══════════════════════════════════════════════════════════════════
//                          USER INPUTS
// ═══════════════════════════════════════════════════════════════════

grpInt = "Interval"
autoMode   = input.bool(true, "Auto-detect interval (Nifty/BankNifty/Sensex)", group = grpInt, tooltip = "Nifty -> 100, BankNifty & Sensex -> 500. Turn off to set manually.")
manualStep = input.float(100, "Manual Interval", minval = 1, group = grpInt, tooltip = "Used only when Auto is OFF")
majorMult  = input.int(5, "Major Level Every N intervals", minval = 2, group = grpInt, tooltip = "e.g. 5 means every 5th line is a 'major' magnet (Nifty 500s)")

grpCount = "Levels Shown"
levelsEachSide = input.int(3, "Levels Above & Below", minval = 1, maxval = 10, group = grpCount, tooltip = "How many round levels above and below current price")

grpVis = "Visual"
minorClr   = input.color(color.new(color.gray, 40), "Minor Level", group = grpVis)
majorClr   = input.color(color.new(color.orange, 10), "Major Level", group = grpVis)
minorWidth = input.int(1, "Minor Line Width", minval = 1, maxval = 4, group = grpVis)
majorWidth = input.int(3, "Major Line Width", minval = 1, maxval = 5, group = grpVis)
showLabels = input.bool(true, "Show Price Labels", group = grpVis)

// ═══════════════════════════════════════════════════════════════════
//                  INTERVAL AUTO-DETECTION (by symbol name)
// ═══════════════════════════════════════════════════════════════════

sym = str.upper(syminfo.ticker)
isNifty     = str.contains(sym, "NIFTY") and not str.contains(sym, "BANK")
isBankNifty = str.contains(sym, "BANKNIFTY") or (str.contains(sym, "NIFTY") and str.contains(sym, "BANK"))
isSensex    = str.contains(sym, "SENSEX")

// Nifty -> 100 ; BankNifty & Sensex -> 500
autoStep = isNifty ? 100 : (isBankNifty or isSensex) ? 500 : (close >= 30000 ? 500 : 100)
step = autoMode ? autoStep : manualStep

// ═══════════════════════════════════════════════════════════════════
//                  COMPUTE NEAREST LEVELS (3 up + 3 down)
// ═══════════════════════════════════════════════════════════════════

var line[]  lvlLines  = array.new<line>()
var label[] lvlLabels = array.new<label>()

f_clearAll() =>
    if array.size(lvlLines) > 0
        for i = 0 to array.size(lvlLines) - 1
            line.delete(array.get(lvlLines, i))
        array.clear(lvlLines)
    if array.size(lvlLabels) > 0
        for i = 0 to array.size(lvlLabels) - 1
            label.delete(array.get(lvlLabels, i))
        array.clear(lvlLabels)

if barstate.islast
    f_clearAll()

    // nearest round level at or below current price
    baseLevel = math.floor(close / step) * step

    // build levels: levelsEachSide below, baseLevel, and levelsEachSide above
    startLvl = baseLevel - step * (levelsEachSide - 1)
    endLvl   = baseLevel + step * (levelsEachSide + 1)

    lvl = startLvl
    while lvl <= endLvl
        isMajor = math.round(lvl / step) % majorMult == 0
        lclr = isMajor ? majorClr : minorClr
        lw   = isMajor ? majorWidth : minorWidth

        ln = line.new(bar_index - 1, lvl, bar_index, lvl, color = lclr, width = lw, extend = extend.both)
        array.push(lvlLines, ln)

        if showLabels
            lblTxtClr = color.white
            lblBgClr  = isMajor ? color.new(color.orange, 10) : color.new(#363a45, 0)
            lb = label.new(bar_index + 2, lvl, str.tostring(math.round(lvl)), style = label.style_label_left, color = lblBgClr, textcolor = lblTxtClr, size = size.normal)
            array.push(lvlLabels, lb)

        lvl := lvl + step

// ═══════════════════════════════════════════════════════════════════
//                  INFO TABLE
// ═══════════════════════════════════════════════════════════════════

var table info = table.new(position.bottom_right, 1, 2, border_width = 1, border_color = color.new(color.gray, 60))
if barstate.islast
    table.cell(info, 0, 0, "Round Magnet 🐘", bgcolor = color.new(#1e222d, 0), text_color = color.white, text_size = size.small)
    table.cell(info, 0, 1, "Interval: " + str.tostring(step), bgcolor = color.new(#2a2e39, 0), text_color = color.white, text_size = size.small)
````
