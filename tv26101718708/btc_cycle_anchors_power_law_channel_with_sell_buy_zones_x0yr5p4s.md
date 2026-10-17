#  BTC Cycle Anchors  Power Law Channel with SELL & BUY Zones

- url: https://www.tradingview.com/script/x0Yr5p4S-BTC-Cycle-Anchors-Power-Law-Channel-with-SELL-BUY-Zones/
- type: indicator
- pine_id: PUB;c10ab60f5a874c61be2efc10d3aafd39
- version: 1.0

## Description

A clean, decisive Bitcoin power-law channel that draws a SELL zone through every cycle top (Dec 2013, Dec 2017, Nov 2021, Oct 2025) and a BUY zone through every cycle bottom (Jan 2015, Dec 2018, Nov 2022). No fuzzy "maybe" zones — when price enters the red, take profits. When it enters the green, accumulate.

═══════════════════════════════════════
HOW IT WORKS
═══════════════════════════════════════

Unlike traditional log-regression bands that use hardcoded coefficients (and go stale within 1–2 cycles), this indicator uses USER-EDITABLE ANCHOR POINTS. You tell it where the historical cycle tops and bottoms occurred, and the script fits two power-law lines (log10(price) vs log10(days)) directly through those points.

The red zone = power-law line through the cycle peaks with 3 gradient sub-bands.
The green zone = power-law line through the cycle bottoms with 3 gradient sub-bands.
The middle = intentionally empty so price action is fully readable.

═══════════════════════════════════════
DEFAULT ANCHOR POINTS
═══════════════════════════════════════

 CYCLE TOPS
• Dec 2013 — $1,163
• Dec 2017 — $19,783
• Nov 2021 — $69,000
• Oct 2025 — $125,000

 CYCLE BOTTOMS
• Jan 2015 — $172
• Dec 2018 — $3,122
• Nov 2022 — $15,479
• (BOT 4 placeholder ready for next cycle bottom — enable in settings when it prints)

═══════════════════════════════════════
HOW TO USE
═══════════════════════════════════════

SETUP
• Symbol: INDEX:BTCUSD (full history back to 2010)
• Timeframe: Weekly (1W) or Monthly (1M)
• Price axis: Right-click → Logarithmic (REQUIRED — power-law curves only render correctly on log scale)

 SIGNAL ZONES (from top to bottom of chart):
• EXTREME SELL — Price above red ceiling (historical bubble territory)
•  STRONG SELL — Price in deeper red zone (distribution / take profits)
•  SELL ZONE — Price at red inner edge (start reducing exposure)
• NEUTRAL — Price in empty middle (hold, no action)
•  BUY ZONE — Price at green inner edge (start accumulating)
•  STRONG BUY — Price in deeper green zone (capitulation / aggressive buy)
•  EXTREME BUY — Price below green floor (generational opportunity)

A status label on the right edge of the chart shows your exact zone, current price, and distance to SELL/BUY edges.

═══════════════════════════════════════
WHEN A NEW CYCLE TOP/BOTTOM PRINTS
═══════════════════════════════════════

Open settings → update the relevant anchor's date and price. The entire channel recalibrates instantly. No need to wait for an update from the author. For the next cycle bottom (expected late 2026 / early 2027), enable "BOT 4" in settings once it prints.

═══════════════════════════════════════
TUNING
═══════════════════════════════════════

• Zone depth — How thick the SELL/BUY zones are (default 35% of channel)
• Anchor dots — Toggle the visual markers at each historical cycle extreme
• Custom colors and line widths

═══════════════════════════════════════
NOT FINANCIAL ADVICE
═══════════════════════════════════════

This is a visualization tool grounded in Bitcoin's empirical power-law behavior (Santostasi, 2024). Past cycles do not guarantee future cycles. Adoption curve, macro conditions, and regulation can break historical patterns. Use as one input among many, not as a standalone trading signal.

Built with Pine Script v6.

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// BTC CYCLE ANCHORS — Power Law Channel with SELL/BUY Zones · Pine Script v6
// Red zone at top (cycle peaks = SELL), green zone at bottom (cycle troughs = BUY),
// empty space in the middle for clean price action visibility.
// REQUIRED: INDEX:BTCUSD, weekly (1W) or monthly (1M), LOG SCALE.
// ══════════════════════════════════════════════════════════════════════════════
//@version=6
indicator("BTC Cycle Anchors", overlay=true, max_bars_back=5000)

// ── Cycle TOP anchors (date, price) ───────────────────────────────────────────
top1_date = input.time(timestamp("2013-12-01"), "TOP 1 date", group="Cycle Tops")
top1_px   = input.float(1163,    "TOP 1 price",   group="Cycle Tops")
top2_date = input.time(timestamp("2017-12-18"), "TOP 2 date", group="Cycle Tops")
top2_px   = input.float(19783,   "TOP 2 price",   group="Cycle Tops")
top3_date = input.time(timestamp("2021-11-08"), "TOP 3 date", group="Cycle Tops")
top3_px   = input.float(69000,   "TOP 3 price",   group="Cycle Tops")
top4_date = input.time(timestamp("2025-10-06"), "TOP 4 date", group="Cycle Tops")
top4_px   = input.float(125000,  "TOP 4 price",   group="Cycle Tops")

// ── Cycle BOTTOM anchors (date, price) ────────────────────────────────────────
bot1_date = input.time(timestamp("2015-01-14"), "BOT 1 date", group="Cycle Bottoms")
bot1_px   = input.float(172,    "BOT 1 price",   group="Cycle Bottoms")
bot2_date = input.time(timestamp("2018-12-15"), "BOT 2 date", group="Cycle Bottoms")
bot2_px   = input.float(3122,   "BOT 2 price",   group="Cycle Bottoms")
bot3_date = input.time(timestamp("2022-11-21"), "BOT 3 date", group="Cycle Bottoms")
bot3_px   = input.float(15479,  "BOT 3 price",   group="Cycle Bottoms")

// ── Zone Configuration ────────────────────────────────────────────────────────
zone_depth = input.float(0.35, "Zone depth (% of channel)", minval=0.10, maxval=0.50, step=0.05, group="Zones", tooltip="How thick the SELL/BUY zones are. 0.35 = each zone covers 35% of the channel, leaving 30% empty in the middle.")
show_dots  = input.bool(true,  "Show anchor dots", group="Display")
show_label = input.bool(true,  "Show status label", group="Display")
line_w     = input.int(2, "Outer line width", minval=1, maxval=5, group="Display")

top_col    = input.color(color.red,   "Top zone color", group="Display")
bot_col    = input.color(color.green, "Bottom zone color", group="Display")

// ── BTC Genesis ───────────────────────────────────────────────────────────────
genesis_ms = 1230940800000.0
ms_per_day = 86400000.0

// ── Build log-log anchor arrays ───────────────────────────────────────────────
top_x = array.from(math.log10((top1_date - genesis_ms) / ms_per_day), math.log10((top2_date - genesis_ms) / ms_per_day), math.log10((top3_date - genesis_ms) / ms_per_day), math.log10((top4_date - genesis_ms) / ms_per_day))
top_y = array.from(math.log10(top1_px), math.log10(top2_px), math.log10(top3_px), math.log10(top4_px))
bot_x = array.from(math.log10((bot1_date - genesis_ms) / ms_per_day), math.log10((bot2_date - genesis_ms) / ms_per_day), math.log10((bot3_date - genesis_ms) / ms_per_day))
bot_y = array.from(math.log10(bot1_px), math.log10(bot2_px), math.log10(bot3_px))

// ── Regression through tops ───────────────────────────────────────────────────
n_t   = array.size(top_x)
sx_t  = array.sum(top_x)
sy_t  = array.sum(top_y)
sxx_t = 0.0
sxy_t = 0.0
for i = 0 to n_t - 1
    xi = array.get(top_x, i)
    yi = array.get(top_y, i)
    sxx_t += xi * xi
    sxy_t += xi * yi
top_slope = (n_t * sxy_t - sx_t * sy_t) / (n_t * sxx_t - sx_t * sx_t)
top_b     = (sy_t - top_slope * sx_t) / n_t

// ── Regression through bottoms ────────────────────────────────────────────────
n_b   = array.size(bot_x)
sx_b  = array.sum(bot_x)
sy_b  = array.sum(bot_y)
sxx_b = 0.0
sxy_b = 0.0
for i = 0 to n_b - 1
    xi = array.get(bot_x, i)
    yi = array.get(bot_y, i)
    sxx_b += xi * xi
    sxy_b += xi * yi
bot_slope = (n_b * sxy_b - sx_b * sy_b) / (n_b * sxx_b - sx_b * sx_b)
bot_b     = (sy_b - bot_slope * sx_b) / n_b

// ── Compute log-space values at current bar ───────────────────────────────────
days     = (time - genesis_ms) / ms_per_day
x        = days > 0 ? math.log10(days) : na
log_top  = not na(x) ? top_slope * x + top_b : na
log_bot  = not na(x) ? bot_slope * x + bot_b : na

// ── Build sub-band offsets ────────────────────────────────────────────────────
top_inner = not na(log_top) and not na(log_bot) ? log_bot + (log_top - log_bot) * (1.0 - zone_depth)          : na
top_mid   = not na(log_top) and not na(log_bot) ? log_bot + (log_top - log_bot) * (1.0 - zone_depth * 0.66)  : na
top_outer = not na(log_top) and not na(log_bot) ? log_bot + (log_top - log_bot) * (1.0 - zone_depth * 0.33)  : na
top_max   = log_top

bot_inner = not na(log_top) and not na(log_bot) ? log_bot + (log_top - log_bot) * zone_depth                  : na
bot_mid   = not na(log_top) and not na(log_bot) ? log_bot + (log_top - log_bot) * (zone_depth * 0.66)        : na
bot_outer = not na(log_top) and not na(log_bot) ? log_bot + (log_top - log_bot) * (zone_depth * 0.33)        : na
bot_min   = log_bot

top_v_max   = not na(top_max)   ? math.pow(10, top_max)   : na
top_v_outer = not na(top_outer) ? math.pow(10, top_outer) : na
top_v_mid   = not na(top_mid)   ? math.pow(10, top_mid)   : na
top_v_inner = not na(top_inner) ? math.pow(10, top_inner) : na

bot_v_inner = not na(bot_inner) ? math.pow(10, bot_inner) : na
bot_v_mid   = not na(bot_mid)   ? math.pow(10, bot_mid)   : na
bot_v_outer = not na(bot_outer) ? math.pow(10, bot_outer) : na
bot_v_min   = not na(bot_min)   ? math.pow(10, bot_min)   : na

// ── Plots ─────────────────────────────────────────────────────────────────────
p_top_max   = plot(top_v_max,   "SELL Ceiling", color=color.new(top_col, 0),   linewidth=line_w)
p_top_outer = plot(top_v_outer, "Sell Strong",  color=color.new(top_col, 50),  linewidth=1)
p_top_mid   = plot(top_v_mid,   "Sell Medium",  color=color.new(top_col, 70),  linewidth=1)
p_top_inner = plot(top_v_inner, "Sell Light",   color=color.new(top_col, 85),  linewidth=1)

p_bot_inner = plot(bot_v_inner, "Buy Light",    color=color.new(bot_col, 85),  linewidth=1)
p_bot_mid   = plot(bot_v_mid,   "Buy Medium",   color=color.new(bot_col, 70),  linewidth=1)
p_bot_outer = plot(bot_v_outer, "Buy Strong",   color=color.new(bot_col, 50),  linewidth=1)
p_bot_min   = plot(bot_v_min,   "BUY Floor",    color=color.new(bot_col, 0),   linewidth=line_w)

fill(p_top_max,   p_top_outer, color=color.new(top_col, 70), title="Sell Zone (strongest)")
fill(p_top_outer, p_top_mid,   color=color.new(top_col, 80), title="Sell Zone (strong)")
fill(p_top_mid,   p_top_inner, color=color.new(top_col, 90), title="Sell Zone (light)")

// MIDDLE = empty (no plot, no fill — clean space for price action)

fill(p_bot_inner, p_bot_mid,   color=color.new(bot_col, 90), title="Buy Zone (light)")
fill(p_bot_mid,   p_bot_outer, color=color.new(bot_col, 80), title="Buy Zone (strong)")
fill(p_bot_outer, p_bot_min,   color=color.new(bot_col, 70), title="Buy Zone (strongest)")

plotshape(show_dots and time == top1_date ? top1_px : na, style=shape.circle, location=location.absolute, color=top_col, size=size.normal)
plotshape(show_dots and time == top2_date ? top2_px : na, style=shape.circle, location=location.absolute, color=top_col, size=size.normal)
plotshape(show_dots and time == top3_date ? top3_px : na, style=shape.circle, location=location.absolute, color=top_col, size=size.normal)
plotshape(show_dots and time == top4_date ? top4_px : na, style=shape.circle, location=location.absolute, color=top_col, size=size.normal)
plotshape(show_dots and time == bot1_date ? bot1_px : na, style=shape.circle, location=location.absolute, color=bot_col, size=size.normal)
plotshape(show_dots and time == bot2_date ? bot2_px : na, style=shape.circle, location=location.absolute, color=bot_col, size=size.normal)
plotshape(show_dots and time == bot3_date ? bot3_px : na, style=shape.circle, location=location.absolute, color=bot_col, size=size.normal)

var label stats_lbl = na

if show_label and barstate.islast and not na(top_v_max) and not na(bot_v_min)
    label.delete(stats_lbl)

    zone = close >= top_v_max   ? "EXTREME SELL - Above Ceiling"   : close >= top_v_outer ? "STRONG SELL - Distribution"      : close >= top_v_inner ? "SELL ZONE - Take Profits"       : close <= bot_v_min   ? "EXTREME BUY - Below Floor"      : close <= bot_v_outer ? "STRONG BUY - Capitulation"     : close <= bot_v_inner ? "BUY ZONE - Accumulate"          : "NEUTRAL - Middle Range"

    up   = (top_v_max - close) / close * 100
    down = (close - bot_v_min) / close * 100

    txt = "BTC Cycle Anchors\nZONE: " + zone + "\n\nSELL ceiling: $" + str.tostring(top_v_max,   "#,###") + "\nSell enter:   $" + str.tostring(top_v_inner, "#,###") + "\nBuy enter:    $" + str.tostring(bot_v_inner, "#,###") + "\nBUY floor:    $" + str.tostring(bot_v_min,   "#,###") + "\n\nCurrent:      $" + str.tostring(close,     "#,###") + "\nUpside:       +" + str.tostring(up,   "#.#") + "%\nDownside:     -" + str.tostring(down, "#.#") + "%"

    stats_lbl := label.new(bar_index, math.pow(10, (log_top + log_bot) / 2), text=txt, style=label.style_label_left, color=color.new(color.black, 15), textcolor=color.white, size=size.small)
````
