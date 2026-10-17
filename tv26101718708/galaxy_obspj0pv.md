# Galaxy

- url: https://www.tradingview.com/script/Obspj0pV-Galaxy/
- type: indicator
- pine_id: PUB;6264dde681ac445ab45b99f228787daf
- version: 1.0

## Description

Galaxy Background — Twinkling Starfield

A purely cosmetic indicator that turns your chart into a starry night sky.
It doesn't calculate or signal anything; it just makes your chart look good.

HOW IT WORKS
Stars are drawn in a screen-fixed table, so they stay in place when you
scroll, zoom, or when new bars print. The layout is generated from a seed,
so the same seed always gives the same sky.

FEATURES
- Screen-fixed stars that never move with price or time
- Three brightness tiers: faint dust, bright stars, and rare "hero" stars
  with a soft glow halo
- Live twinkling: stars gently fade brighter and dimmer on each price tick
  (positions never change)
- Custom star characters: paste any symbols as a comma-separated list
  (e.g. ·,✧,✦). Earlier characters appear more often
- Adjustable density, brightness, glow strength, and color mix
  (white / pale blue / lavender)

SETUP
1. Set your chart background to black (Chart Settings → Canvas).
2. Add the indicator.
3. Tweak the seed until you like the layout, then adjust density and shine.

NOTES
- Twinkling needs live ticks, so the sky holds still when the market is
  closed.
- Stars draw on top of candles; raise transparency if they get in the way.
- Emoji characters keep their own colors and ignore the color settings.
- If the chart feels slow, lower "Stars per tick."

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  GALAXY — screen-fixed starry-sky background
//
//  CONFIRMED: the only drawing call in this script is table.new() / table.cell().
//  There is no label.new, line.new, box.new, plot, plotshape, or plotchar
//  anywhere below — nothing that is anchored to a bar index, bar time, or
//  price. A table's cells are positioned purely in pane-space (rows/columns
//  as a percentage of the pane), so the stars cannot drift when the chart is
//  scrolled, zoomed, or repainted, and they do not move as price changes.
// ════════════════════════════════════════════════════════════════════════════
indicator("Galaxy", overlay = true)

// ── Inputs ─────────────────────────────────────────────────────────────────
seedInput  = input.int(42,   "Random seed", minval = 0, tooltip = "Same seed = same sky. Change it to reshuffle the stars.")
density    = input.float(12.0, "Star density %", minval = 0.0, maxval = 100.0, step = 1.0, tooltip = "Roughly this percent of grid cells get a star.")
gridCols   = input.int(60, "Grid columns", minval = 5, maxval = 150)
gridRows   = input.int(35, "Grid rows",    minval = 5, maxval = 150)
brightness = input.int(50, "Brightness (base transparency)", minval = 20, maxval = 80, tooltip = "Each star gets a random offset around this value, clamped to 20-80.")
mixColors  = input.bool(true, "Color mix (white + pale blue + lavender)", tooltip = "Off = white stars only.")

// ── Palette ────────────────────────────────────────────────────────────────
C_WHITE    = color.rgb(255, 255, 255)
C_BLUE     = color.rgb(173, 205, 255)  // pale blue
C_LAVENDER = color.rgb(205, 185, 255)  // lavender

// ── Seed lanes ─────────────────────────────────────────────────────────────
// One offset per random attribute so cells never share a draw with their
// neighbours (e.g. every "star?" roll landing on the same value as the
// "which glyph?" roll for a different cell).
SEED_STAR   = 100000  // does this cell get a star at all?
SEED_GLYPH  = 200000  // which glyph
SEED_SIZE   = 300000  // text size
SEED_HALIGN = 400000  // horizontal alignment
SEED_VALIGN = 500000  // vertical alignment
SEED_COLOR  = 600000  // color pick
SEED_TRANSP = 700000  // transparency offset

// ── Table (the ONLY drawing object, created once) ───────────────────────────
// position.middle_center anchors the table to the pane itself, not to any
// bar. Cell widths/heights are percentages of the pane, so the 60x35 grid
// always covers exactly 100% of it. bgcolor = na / border_width = 0 /
// frame_width = 0 keep the grid itself fully invisible.
var table galaxyTable = table.new(position.middle_center, gridCols, gridRows, bgcolor = na, border_width = 0, frame_width = 0)

// ── Population guard ─────────────────────────────────────────────────────────
// The grid is filled exactly once (the first time a final bar is reached)
// and never touched again, so there is nothing to recompute or flicker on
// subsequent realtime ticks.
var bool populated = false

cellW = 100.0 / gridCols
cellH = 100.0 / gridRows

if barstate.islast and not populated
    for r = 0 to gridRows - 1
        for c = 0 to gridCols - 1
            cellIdx = r * gridCols + c

            // Decide whether this cell gets a star (~density% of cells).
            rStar = math.random(0, 1, seedInput + SEED_STAR + cellIdx)
            isStar = rStar < density / 100.0

            cellText  = ""
            cellColor = color.new(C_WHITE, 100)
            halign    = text.align_center
            valign    = text.align_center
            tsize     = size.tiny

            if isStar
                // Glyph: mostly "·", sometimes "•", rarely "✦".
                rGlyph = math.random(0, 1, seedInput + SEED_GLYPH + cellIdx)
                cellText := rGlyph < 0.65 ? "·" : rGlyph < 0.92 ? "•" : "✦"

                // Size: mostly tiny, sometimes small.
                rSize = math.random(0, 1, seedInput + SEED_SIZE + cellIdx)
                tsize := rSize < 0.70 ? size.tiny : size.small

                // Alignment jitter within the cell so the grid pattern
                // doesn't read as a rigid lattice.
                rH = math.random(0, 1, seedInput + SEED_HALIGN + cellIdx)
                halign := rH < 0.333 ? text.align_left : rH < 0.667 ? text.align_center : text.align_right
                rV = math.random(0, 1, seedInput + SEED_VALIGN + cellIdx)
                valign := rV < 0.333 ? text.align_top : rV < 0.667 ? text.align_center : text.align_bottom

                // Color: ~70% white, 20% pale blue, 10% lavender (white
                // only when the mix toggle is off).
                rColor = math.random(0, 1, seedInput + SEED_COLOR + cellIdx)
                col = not mixColors ? C_WHITE : rColor < 0.70 ? C_WHITE : rColor < 0.90 ? C_BLUE : C_LAVENDER

                // Transparency: random offset around the brightness input,
                // clamped to the 20-80 range.
                rTransp = math.random(-25, 25, seedInput + SEED_TRANSP + cellIdx)
                transp = int(math.max(20, math.min(80, math.round(brightness + rTransp))))
                cellColor := color.new(col, transp)

            table.cell(galaxyTable, c, r, text = cellText, width = cellW, height = cellH, text_color = cellColor, text_halign = halign, text_valign = valign, text_size = tsize, bgcolor = na)

    populated := true
````
