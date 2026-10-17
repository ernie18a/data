# CQ_(-)_Current Candle Highlight

- url: https://www.tradingview.com/script/xJ8qMeq9-CQ-Current-Candle-Highlight/
- type: indicator
- pine_id: PUB;438bbea7906d4f22a6a343ff74aa43c5
- version: 1.0

## Description

CQ_(-)_Current Candle Highlight
Author: CQuevedo345
User Manual

================================================================
OVERVIEW
================================================================
This indicator highlights the current (in-progress / last) candle
on the chart with a customizable glow, colored body, wick, and a
"NOW" label so it stands out from historical price action at a
glance. It also includes an optional highlight for the candle
immediately before the current one, using its own independent
teal/red (or custom) bullish/bearish colors.

Nothing about price, signals, or trend direction is calculated;
this is a pure visual aid for locating the active candle and the
one that just closed.

================================================================
FEATURE LIST
================================================================

1) CURRENT CANDLE HIGHLIGHT
   - Recolors the live/last candle's body, wick, and border.
   - Adds a soft multi-layer "glow halo" box around the candle.
   - Adds a small "NOW" label above the candle's high.
   - Colors are drawn from one of five built-in palettes (see
     below); direction (bullish/bearish) automatically selects
     the correct color from the chosen palette.

2) PREVIOUS CANDLE HIGHLIGHT
   - Independently highlights the candle that comes right before
     the current one (the last fully closed candle before "NOW").
   - Colors are fully user-selectable, defaulting to:
       Bullish -> Teal
       Bearish -> Red
   - Can optionally recolor that candle's wick/border to match, or
     leave the wick/border unchanged (body color only).
   - Automatically follows the chart forward: as new bars form,
     the highlight always tracks the candle just before the newest
     one - no manual adjustment needed.
   - Can be toggled on/off independently of the current-candle
     highlight.

3) FIVE COLOR PALETTES (for the current-candle highlight)
   - Inferno       - blazing orange/red volcanic tones
   - Neon City      - cyberpunk electric cyan/magenta
   - Arctic Storm   - icy blue/white high-contrast
   - Toxic Green    - radioactive lime/chartreuse (default)
   - Ultraviolet    - deep purple to violet spectrum
   Each palette defines a distinct bullish and bearish color for
   the body, border/wick, and glow.

================================================================
INPUT SETTINGS
================================================================

--- Settings ---
Show Highlight
   Master on/off switch for the current-candle highlight (glow,
   body, wick, border, and NOW label).

Color Palette
   Choose which of the five palettes is used for the current
   candle's colors.

Body Fill Opacity (0-100)
   Controls how solid/transparent the current candle's body fill
   is. Higher values = more opaque.

Color Wicks & Border
   When on, the current candle's wick and border are colored to
   match the palette. When off, only the body fill is colored.

Glow Halo Boxes
   Toggles the soft glow effect drawn behind/around the current
   candle.

Glow Layers (1-5)
   Number of concentric glow layers drawn. More layers = a
   thicker, more gradual glow falloff.

Glow Alpha per Layer (1-30)
   Controls how visible/intense each glow layer is. Higher values
   = stronger glow.

Show 'NOW' Label
   Toggles the small "NOW" text label shown above the current
   candle.

--- Previous Candle Highlight ---
Highlight Previous Candle
   Master on/off switch for highlighting the candle immediately
   before the current one.

Bullish Color / Bearish Color
   User-selectable colors applied to the previous candle depending
   on whether it closed bullish (close >= open) or bearish
   (close < open). Default: Teal (bullish) / Red (bearish).

Color Previous Wick & Border
   When on, the previous candle's wick and border are also colored
   to match its bullish/bearish color. When off, only the body is
   colored.

================================================================
HOW IT WORKS (BEHIND THE SCENES)
================================================================
- The current-candle highlight (glow, body box, wick line, and
  label) is only drawn while the script is evaluating the actual
  last bar on the chart (barstate.islast). These drawn objects are
  deleted and redrawn each time a new bar closes, so the highlight
  always follows the live candle.
- The previous-candle highlight uses the candle's own bar index
  compared against the chart's last bar index, so it automatically
  "moves forward" one candle at a time as new bars are added,
  without needing to track or delete old drawings.
- Both highlights use plotcandle() overrides, so they recolor the
  actual candles on the chart rather than drawing separate shapes
  on top of them.

================================================================
TIPS
================================================================
- If you only want the previous-candle highlight (e.g., to clearly
  mark the last fully closed candle) and not the current one, turn
  off "Show Highlight" and leave "Highlight Previous Candle" on.
- If the glow feels too strong or distracting, lower "Glow Alpha
  per Layer" or reduce "Glow Layers" rather than disabling it
  outright.
- Pick a palette (or previous-candle colors) with enough contrast
  against your chart background/candle theme for the highlight to
  remain visible.

================================================================
VERSION NOTES
================================================================
- Added: user-selectable Previous Candle Highlight (independent
  teal/red bullish/bearish colors, optional wick/border coloring,
  and its own on/off toggle).

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © CQuevedo345 / UkutaLabs

//@version=6
indicator("CQ_(-)_Current Candle Highlight", overlay = true, max_boxes_count = 10, max_lines_count = 10, max_labels_count = 10)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────
grp_main = "⚙️ Settings"
i_show        = input.bool(true,  "Show Highlight",                        group = grp_main)
i_palette     = input.string("🌿 Toxic Green",
     options  = ["🔥 Inferno", "⚡ Neon City", "🌊 Arctic Storm", "🌿 Toxic Green", "💜 Ultraviolet"],
     title    = "Color Palette",                                            group = grp_main)
i_bodyAlpha   = input.int(15,  "Body Fill Opacity (0–100)",  minval=0, maxval=100, group = grp_main)
i_borderWick  = input.bool(true, "Color Wicks & Border",                   group = grp_main)
i_glowEnable  = input.bool(true, "Glow Halo Boxes",                        group = grp_main)
i_glowLayers  = input.int(5, "Glow Layers (1–5)", minval=1, maxval=5,      group = grp_main)
i_glowAlpha   = input.int(12, "Glow Alpha per Layer (1–30)", minval=1, maxval=30,  group = grp_main)
i_labelEnable = input.bool(true, "Show 'NOW' Label",                       group = grp_main)

// ─────────────────────────────────────────────
//  PALETTE DEFINITIONS
// ─────────────────────────────────────────────

// 🔥 Inferno  — blazing orange/red volcanic tones
color INF_BULL_BODY   = color.rgb(98, 255, 229)
color INF_BEAR_BODY   = color.rgb(255, 98, 150)
color INF_BULL_BDR    = color.rgb(98, 255, 229)
color INF_BEAR_BDR    = color.rgb(255, 98, 150)
color INF_BULL_GLOW   = color.rgb(98, 255, 229)
color INF_BEAR_GLOW   = color.rgb(255, 98, 150)

// ⚡ Neon City — cyberpunk electric palette
color NEO_BULL_BODY   = color.rgb(98, 245, 255)
color NEO_BEAR_BODY   = color.rgb(255, 98, 255)
color NEO_BULL_BDR    = color.rgb(98, 245, 255)
color NEO_BEAR_BDR    = color.rgb(255, 98, 255)
color NEO_BULL_GLOW   = color.rgb(98, 245, 255)
color NEO_BEAR_GLOW   = color.rgb(255, 98, 255)

// 🌊 Arctic Storm — icy blue/white high-contrast
color ARC_BULL_BODY   = color.rgb(128, 216, 255)
color ARC_BEAR_BODY   = color.rgb(255, 121, 112)
color ARC_BULL_BDR    = color.rgb(128, 216, 255)
color ARC_BEAR_BDR    = color.rgb(255, 121, 112)
color ARC_BULL_GLOW   = color.rgb(128, 216, 255)
color ARC_BEAR_GLOW   = color.rgb(255, 121, 255)

// 🌿 Toxic Green — radioactive lime/chartreuse
color TOX_BULL_BODY   = color.rgb(230, 255, 3)
color TOX_BEAR_BODY   = color.rgb(255, 0, 221)
color TOX_BULL_BDR    = color.rgb(208, 255, 80)
color TOX_BEAR_BDR    = color.rgb(255, 0, 211)
color TOX_BULL_GLOW   = color.rgb(187, 255, 0)
color TOX_BEAR_GLOW   = color.rgb(255, 0, 211)

// 💜 Ultraviolet — deep purple to violet spectrum
color ULT_BULL_BODY   = color.rgb(240, 156, 255)
color ULT_BEAR_BODY   = color.rgb(146, 107, 255)
color ULT_BULL_BDR    = color.rgb(240, 156, 255)
color ULT_BEAR_BDR    = color.rgb(146, 107, 255)
color ULT_BULL_GLOW   = color.rgb(240, 156, 255)
color ULT_BEAR_GLOW   = color.rgb(146, 107, 255)

// ─────────────────────────────────────────────
//  PALETTE SELECTOR
// ─────────────────────────────────────────────
bool isBull = close >= open

f_paletteColor(string slot) =>
    color out = na
    if i_palette == "🔥 Inferno"
        out := slot == "bull_body"  ? INF_BULL_BODY  :
               slot == "bear_body"  ? INF_BEAR_BODY  :
               slot == "bull_bdr"   ? INF_BULL_BDR   :
               slot == "bear_bdr"   ? INF_BEAR_BDR   :
               slot == "bull_glow"  ? INF_BULL_GLOW  : INF_BEAR_GLOW
    else if i_palette == "⚡ Neon City"
        out := slot == "bull_body"  ? NEO_BULL_BODY  :
               slot == "bear_body"  ? NEO_BEAR_BODY  :
               slot == "bull_bdr"   ? NEO_BULL_BDR   :
               slot == "bear_bdr"   ? NEO_BEAR_BDR   :
               slot == "bull_glow"  ? NEO_BULL_GLOW  : NEO_BEAR_GLOW
    else if i_palette == "🌊 Arctic Storm"
        out := slot == "bull_body"  ? ARC_BULL_BODY  :
               slot == "bear_body"  ? ARC_BEAR_BODY  :
               slot == "bull_bdr"   ? ARC_BULL_BDR   :
               slot == "bear_bdr"   ? ARC_BEAR_BDR   :
               slot == "bull_glow"  ? ARC_BULL_GLOW  : ARC_BEAR_GLOW
    else if i_palette == "🌿 Toxic Green"
        out := slot == "bull_body"  ? TOX_BULL_BODY  :
               slot == "bear_body"  ? TOX_BEAR_BODY  :
               slot == "bull_bdr"   ? TOX_BULL_BDR   :
               slot == "bear_bdr"   ? TOX_BEAR_BDR   :
               slot == "bull_glow"  ? TOX_BULL_GLOW  : TOX_BEAR_GLOW
    else
        out := slot == "bull_body"  ? ULT_BULL_BODY  :
               slot == "bear_body"  ? ULT_BEAR_BODY  :
               slot == "bull_bdr"   ? ULT_BULL_BDR   :
               slot == "bear_bdr"   ? ULT_BEAR_BDR   :
               slot == "bull_glow"  ? ULT_BULL_GLOW  : ULT_BEAR_GLOW
    out

// ─────────────────────────────────────────────
//  DERIVED COLORS
// ─────────────────────────────────────────────
color bodyColor   = isBull ? f_paletteColor("bull_body") : f_paletteColor("bear_body")
color borderColor = isBull ? f_paletteColor("bull_bdr")  : f_paletteColor("bear_bdr")
color glowColor   = isBull ? f_paletteColor("bull_glow") : f_paletteColor("bear_glow")
color bodyFill    = color.new(bodyColor, 100 - i_bodyAlpha)

// ─────────────────────────────────────────────
//  PERSISTENT OBJECTS  (deleted & redrawn each bar)
// ─────────────────────────────────────────────
var box[]   glowBoxes = array.new<box>()
var box     bodyBox   = na
var line    wickLine  = na
var label   nowLabel  = na

// Helper: delete all tracked glow boxes
f_clearGlow() =>
    if array.size(glowBoxes) > 0
        for b in glowBoxes
            box.delete(b)
        array.clear(glowBoxes)

// ─────────────────────────────────────────────
//  DRAW ON LAST (CURRENT) BAR ONLY
// ─────────────────────────────────────────────
if barstate.islast and i_show
    // --- Clean up previous objects ---
    f_clearGlow()
    box.delete(bodyBox)
    line.delete(wickLine)
    label.delete(nowLabel)

    float bodyTop    = math.max(open, close)
    float bodyBot    = math.min(open, close)
    float wickTop    = high
    float wickBot    = low
    int   barLeft    = bar_index
    int   barRight   = bar_index

    // --- Glow halo layers (outermost first, most transparent) ---
    if i_glowEnable
        for i = i_glowLayers to 1
            float expand = i * 0.0003 * (wickTop - wickBot + 1e-10)
            box newGlow  = box.new(
                 left         = barLeft,
                 top          = wickTop  + expand,
                 right        = barRight,
                 bottom       = wickBot  - expand,
                 border_color = color.new(glowColor, 100 - i_glowAlpha),
                 border_width = i + 1,
                 bgcolor      = color.new(glowColor, 100 - math.round(i_glowAlpha * 0.5)))
            array.push(glowBoxes, newGlow)

    // --- Wick (vertical line through full range) ---
    if i_borderWick
        wickLine := line.new(
             x1    = barLeft,
             y1    = wickTop,
             x2    = barLeft,
             y2    = wickBot,
             color = borderColor,
             width = 1)

    // --- Body box ---
    bodyBox := box.new(
         left         = barLeft,
         top          = bodyTop,
         right        = barRight,
         bottom       = bodyBot,
         border_color = i_borderWick ? borderColor : color.new(borderColor, 100),
         border_width = 2,
         bgcolor      = bodyFill)

    // --- "NOW" label above wick ---
    if i_labelEnable
        nowLabel := label.new(
             x         = barLeft,
             y         = wickTop,
             text      = "NOW",
             style     = label.style_label_down,
             color     = color.new(borderColor, 50),
             textcolor = borderColor,
             size      = size.tiny,
             yloc      = yloc.abovebar)

// ─────────────────────────────────────────────
//  CANDLE COLORING  (all bars — current bar override)
// ─────────────────────────────────────────────
color candleColor = barstate.islast and i_show ? bodyColor : na
plotcandle(open, high, low, close,
     color       = candleColor,
     wickcolor   = (barstate.islast and i_show and i_borderWick) ? borderColor : na,
     bordercolor = (barstate.islast and i_show and i_borderWick) ? borderColor : na)

//EOF
````
