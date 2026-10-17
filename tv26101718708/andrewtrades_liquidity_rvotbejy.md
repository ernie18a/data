# AndrewTrades Liquidity

- url: https://www.tradingview.com/script/rvOtBEjy-AndrewTrades-Liquidity/
- type: indicator
- pine_id: PUB;9dff0c4e02f042328dc8370e8cde41a6
- version: 1.0

## Description

[b]AndrewTrades Liquidity[/b] identifies key buyside and sellside liquidity levels by detecting pivot highs and lows on your chart. Each confirmed pivot is marked with a horizontal line that extends to the right until the level is swept.

Settings:
[list]
[*]Pivot Strength — controls how significant a high/low must be before it's marked (higher = fewer, stronger levels)
[*]Line Style & Width — customize the appearance of each level
[*]Auto-Delete — remove levels that price never reaches after a set number of bars
[/list]

Best used on higher timeframes (15m and above) to identify meaningful liquidity pools that institutional players may target.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AndrewTradesNQ

//@version=6
indicator("AndrewTrades Liquidity", overlay = true, max_lines_count = 500)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────
grp_col = "Colors"
grp_ln  = "Lines"
grp_str = "Detection"
grp_del = "Cleanup"

bsl_color = input.color(color.teal, "Buy-Side (Highs)", group = grp_col, inline = "col")
ssl_color = input.color(color.red,  "Sell-Side (Lows)", group = grp_col, inline = "col")

line_style = input.string("Solid", "Line Style",
              options = ["Solid", "Dashed", "Dotted"], group = grp_ln, inline = "ln")
line_width = input.int(1, "", minval = 1, maxval = 4,  group = grp_ln, inline = "ln")

ps = input.int(25, "Pivot Strength", minval = 1, maxval = 100, group = grp_str,
      tooltip = "Number of bars left and right required to confirm a pivot high/low")

del_old   = input.bool(true, "Auto-Delete Untouched After (bars)", group = grp_del, inline = "del")
del_after = input.int(1000,  "", minval = 1,                        group = grp_del, inline = "del")

// ─────────────────────────────────────────────
//  DERIVED
// ─────────────────────────────────────────────
lstyle = switch line_style
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    =>           line.style_solid

// ─────────────────────────────────────────────
//  TYPE DEFINITION
// ─────────────────────────────────────────────
type LiqPool
    array<float> price
    array<int>   idx
    array<line>  hrz

// ─────────────────────────────────────────────
//  PERSISTENT STATE
// ─────────────────────────────────────────────
var BSL = LiqPool.new(array.new_float(), array.new_int(), array.new_line())
var SSL = LiqPool.new(array.new_float(), array.new_int(), array.new_line())

// ─────────────────────────────────────────────
//  METHODS
// ─────────────────────────────────────────────

method add_liq(LiqPool L, float P, int I, bool bull) =>
    col = bull ? bsl_color : ssl_color
    L.price.unshift(P)
    L.idx.unshift(I)
    L.hrz.unshift(line.new(I, P, bar_index, P,
      color = col, style = lstyle, width = line_width))

method del_liq(LiqPool L, int i, bool stale) =>
    L.price.remove(i)
    L.idx.remove(i)
    h = L.hrz.remove(i)
    if del_old and stale
        h.delete()

method update_liq(LiqPool L, bool bull) =>
    if L.price.size() > 0
        for i = L.price.size() - 1 to 0
            L.hrz.get(i).set_x2(bar_index)
            P     = L.price.get(i)
            I     = L.idx.get(i)
            stale = bar_index - I >= del_after
            swept = bull ? high > P : low < P
            if stale or swept
                L.del_liq(i, stale)

// ─────────────────────────────────────────────
//  PIVOT DETECTION
// ─────────────────────────────────────────────
piv_hi = not na(ta.pivothigh(ps, ps))
piv_lo = not na(ta.pivotlow (ps, ps))

if piv_hi
    BSL.add_liq(high[ps], bar_index[ps], true)
if piv_lo
    SSL.add_liq(low[ps],  bar_index[ps], false)

// ─────────────────────────────────────────────
//  UPDATE EVERY BAR
// ─────────────────────────────────────────────
BSL.update_liq(true)
SSL.update_liq(false)
````
