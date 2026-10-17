# BTC ETH Cycle Top + N Months Bottom Anticipation Markers

- url: https://www.tradingview.com/script/zE8Di2WH-BTC-ETH-Cycle-Top-N-Months-Bottom-Anticipation-Markers/
- type: indicator
- pine_id: PUB;d0349cb806f54352b3285fb86c6de5bf
- version: 1.0

## Description

🎯 Cycle Top + N Months — Bottom Anticipation Markers

A research and timing tool that marks every historical cycle TOP and projects forward by N months (default 12) to anticipate where the next cycle BOTTOM is likely to form.

═══════════════════════════════════════
THE THESIS
═══════════════════════════════════════

Both BTC and ETH have shown a remarkably consistent ~12-month lag between cycle tops and the subsequent cycle bottoms:

🔴 BTC HISTORY
• Dec 2013 top ($1,163)  → Jan 2015 bottom ($172)        ≈ 13 months
• Dec 2017 top ($19,783) → Dec 2018 bottom ($3,122)      ≈ 12 months
• Nov 2021 top ($69,000) → Nov 2022 bottom ($15,479)     ≈ 12 months
• Oct 2025 top ($125,000) → projected late 2026

🔴 ETH HISTORY
• Jan 2018 top ($1,432) → Dec 2018 bottom ($83)          ≈ 11 months
• Nov 2021 top ($4,878) → Jun 2022 bottom ($880)         ≈ 7 months (early)
• Oct 2025 top ($4,955) → projected late 2026

This indicator visualizes that lag pattern with paired vertical markers so you can stop guessing where the next accumulation window will appear.

═══════════════════════════════════════
WHAT IT DRAWS
═══════════════════════════════════════

For each cycle top:
🔴 RED dashed vertical line — exact date of the cycle peak
🟡 YELLOW dashed vertical line — exact date of top + N months (your projection)
🏷️  Labels showing TOP # and price + "+12mo from TOP #" projection

The yellow line shows you exactly where to start watching for capitulation/accumulation.

═══════════════════════════════════════
ASSET PRESETS (built-in)
═══════════════════════════════════════

Select your asset from a dropdown:

⚡ BTC — Pre-loaded with 4 confirmed BTC cycle tops:
   • Dec 1, 2013
   • Dec 11, 2017
   • Nov 9, 2021
   • Oct 6, 2025

⚡ ETH — Pre-loaded with 3 confirmed ETH cycle tops:
   • Jan 13, 2018
   • Nov 10, 2021
   • Oct 3, 2025

⚡ CUSTOM — Enter your own up to 4 top dates and prices for any asset (S&P, gold, alts, individual stocks — any market with cyclical structure).

═══════════════════════════════════════
HOW TO USE
═══════════════════════════════════════

📊 SETUP
• Symbol: INDEX:BTCUSD or INDEX:ETHUSD (or any cyclical asset)
• Timeframe: Weekly (1W) recommended for cycle clarity
• Price axis: Logarithmic recommended for crypto

🎯 WORKFLOW
1. Load the indicator → select your asset preset
2. Note where the YELLOW lines fall in the past — they should land near the actual cycle bottoms (validation)
3. Look at the most recent YELLOW line in the future — that's your forecast window
4. Pair with any accumulation/buy-zone indicator to time entries inside that window

🔧 TUNABLE
• Months after top — default 12. Try 9, 14, or 18 to test different lag hypotheses
• Line style — solid / dashed / dotted
• Custom colors and labels

═══════════════════════════════════════
COMPANION INDICATOR
═══════════════════════════════════════

Pairs powerfully with my "BTC Cycle Anchors — Power Law Channel" or "ETH Accumulation Zone" indicators. The intersection of:
• 🟡 Yellow vertical timing marker
• 🟢 Green accumulation zone (from the other indicator)

…gives the highest-probability buy window of the entire cycle.

═══════════════════════════════════════
LIMITATIONS / HONEST DISCLAIMER
═══════════════════════════════════════

This is a HISTORICAL PATTERN visualizer, not a prediction. The ~12-month lag held across three crypto cycles but:

• Sample size is small (3-4 cycles)
• Macroeconomic regime shifts can break the pattern
• ETH's 2021→2022 lag was only 7 months — patterns mutate
• Diminishing-returns cycles (especially ETH) may compress timing
• Adoption maturity changes cycle dynamics

Use as ONE input among many. Pair with on-chain data, macro context, and price-zone confirmation. Not financial advice.

═══════════════════════════════════════
CREDITS
═══════════════════════════════════════

Built in Pine Script v6. Free to use, modify, and remix.

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// CYCLE TOP + N MONTHS — Anticipation Markers · Pine Script v6
// For each historical cycle top, drops a vertical dashed line at top + N months.
// Use to anticipate where the next cycle bottom may form (typically 12 months
// after the top in BTC/ETH cycles).
// Works on both BTC and ETH (or any asset — just edit the top dates).
// ══════════════════════════════════════════════════════════════════════════════
//@version=6
indicator("Cycle Top + N Months Markers", overlay=true, max_bars_back=5000)

// ── Asset selection: BTC or ETH ───────────────────────────────────────────────
asset = input.string("BTC", "Asset preset", options=["ETH", "BTC", "Custom"], group="Asset", tooltip="ETH = uses 3 known ETH cycle tops. BTC = uses 4 known BTC cycle tops. Custom = use the dates below.")

// ── Months after top to mark ──────────────────────────────────────────────────
months_after = input.int(12, "Months after cycle top", minval=1, maxval=48, step=1, group="Marker", tooltip="Number of months from cycle top to draw the vertical marker. Default 12 = one year (historical lag between cycle top and cycle bottom).")

// ── Cycle TOP dates (used when asset = Custom) ────────────────────────────────
top1_date = input.time(timestamp("2018-01-13"), "Custom TOP 1 date", group="Custom Asset Tops")
top1_px   = input.float(1432, "Custom TOP 1 price (for label)", group="Custom Asset Tops")
top2_date = input.time(timestamp("2021-11-10"), "Custom TOP 2 date", group="Custom Asset Tops")
top2_px   = input.float(4878, "Custom TOP 2 price (for label)", group="Custom Asset Tops")
top3_date = input.time(timestamp("2025-10-03"), "Custom TOP 3 date", group="Custom Asset Tops")
top3_px   = input.float(4955, "Custom TOP 3 price (for label)", group="Custom Asset Tops")
top4_date = input.time(timestamp("2029-10-01"), "Custom TOP 4 date (optional)", group="Custom Asset Tops")
top4_px   = input.float(0,    "Custom TOP 4 price (0 = disabled)", group="Custom Asset Tops")

// ── Display ───────────────────────────────────────────────────────────────────
top_col    = input.color(color.red,    "Cycle top marker color", group="Display")
proj_col   = input.color(color.yellow, "Top + N months marker color", group="Display")
line_style = input.string("dashed", "Marker line style", options=["solid", "dashed", "dotted"], group="Display")
line_w     = input.int(2, "Line width", minval=1, maxval=5, group="Display")
show_top_labels  = input.bool(true, "Show cycle top labels", group="Display")
show_proj_labels = input.bool(true, "Show + N month labels", group="Display")

// ── Style helper ──────────────────────────────────────────────────────────────
style_val = line_style == "dashed" ? line.style_dashed : line_style == "dotted" ? line.style_dotted : line.style_solid

// ── BTC cycle tops (corrected dates) ──────────────────────────────────────────
btc_t1 = timestamp("2013-12-01")
btc_t2 = timestamp("2017-12-11")
btc_t3 = timestamp("2021-11-09")
btc_t4 = timestamp("2025-10-06")
btc_p1 = 1163.0
btc_p2 = 19783.0
btc_p3 = 69000.0
btc_p4 = 125000.0

// ── ETH cycle tops ────────────────────────────────────────────────────────────
eth_t1 = timestamp("2018-01-13")
eth_t2 = timestamp("2021-11-10")
eth_t3 = timestamp("2025-10-03")
eth_p1 = 1432.0
eth_p2 = 4878.0
eth_p3 = 4955.0

var array<int>   top_dates  = array.new<int>()
var array<float> top_prices = array.new<float>()

if barstate.isfirst
    array.clear(top_dates)
    array.clear(top_prices)
    if asset == "BTC"
        array.push(top_dates, btc_t1)
        array.push(top_dates, btc_t2)
        array.push(top_dates, btc_t3)
        array.push(top_dates, btc_t4)
        array.push(top_prices, btc_p1)
        array.push(top_prices, btc_p2)
        array.push(top_prices, btc_p3)
        array.push(top_prices, btc_p4)
    else if asset == "ETH"
        array.push(top_dates, eth_t1)
        array.push(top_dates, eth_t2)
        array.push(top_dates, eth_t3)
        array.push(top_prices, eth_p1)
        array.push(top_prices, eth_p2)
        array.push(top_prices, eth_p3)
    else
        array.push(top_dates, top1_date)
        array.push(top_dates, top2_date)
        array.push(top_dates, top3_date)
        array.push(top_prices, top1_px)
        array.push(top_prices, top2_px)
        array.push(top_prices, top3_px)
        if top4_px > 0
            array.push(top_dates, top4_date)
            array.push(top_prices, top4_px)

var array<line>  top_lines  = array.new<line>()
var array<line>  proj_lines = array.new<line>()
var array<label> top_lbls   = array.new<label>()
var array<label> proj_lbls  = array.new<label>()

ms_per_month = 30.44 * 86400000.0

if barstate.islast
    if array.size(top_lines) > 0
        for i = 0 to array.size(top_lines) - 1
            line.delete(array.get(top_lines, i))
    array.clear(top_lines)

    if array.size(proj_lines) > 0
        for i = 0 to array.size(proj_lines) - 1
            line.delete(array.get(proj_lines, i))
    array.clear(proj_lines)

    if array.size(top_lbls) > 0
        for i = 0 to array.size(top_lbls) - 1
            label.delete(array.get(top_lbls, i))
    array.clear(top_lbls)

    if array.size(proj_lbls) > 0
        for i = 0 to array.size(proj_lbls) - 1
            label.delete(array.get(proj_lbls, i))
    array.clear(proj_lbls)

    n_tops = array.size(top_dates)
    if n_tops > 0
        for i = 0 to n_tops - 1
            t_top  = array.get(top_dates, i)
            p_top  = array.get(top_prices, i)
            t_proj = t_top + int(months_after * ms_per_month)

            new_top_line = line.new(x1=t_top, y1=0.0, x2=t_top, y2=10000000.0, xloc=xloc.bar_time, extend=extend.both, color=color.new(top_col, 0), style=style_val, width=line_w)
            array.push(top_lines, new_top_line)

            new_proj_line = line.new(x1=t_proj, y1=0.0, x2=t_proj, y2=10000000.0, xloc=xloc.bar_time, extend=extend.both, color=color.new(proj_col, 0), style=style_val, width=line_w)
            array.push(proj_lines, new_proj_line)

            if show_top_labels
                top_text = "TOP " + str.tostring(i + 1) + "\n$" + str.tostring(p_top, "#,###")
                new_top_lbl = label.new(x=t_top, y=p_top, text=top_text, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down, color=color.new(top_col, 20), textcolor=color.white, size=size.small)
                array.push(top_lbls, new_top_lbl)

            if show_proj_labels
                proj_text = "+" + str.tostring(months_after) + "mo\nfrom TOP " + str.tostring(i + 1)
                new_proj_lbl = label.new(x=t_proj, y=p_top, text=proj_text, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down, color=color.new(proj_col, 20), textcolor=color.black, size=size.small)
                array.push(proj_lbls, new_proj_lbl)
````
