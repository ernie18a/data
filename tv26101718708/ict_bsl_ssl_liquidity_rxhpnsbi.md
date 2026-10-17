# ICT BSL / SSL Liquidity

- url: https://www.tradingview.com/script/RXHpnSBI-ICT-BSL-SSL-Liquidity/
- type: indicator
- pine_id: PUB;fa2339867917439f9d199e9f8b52a07f
- version: 1.0

## Description

ICT BSL / SSL Liquidity is a market-structure based liquidity detection indicator designed to identify Buy Side Liquidity (BSL), Sell Side Liquidity (SSL), and potential liquidity sweeps directly on the chart.

The indicator detects confirmed swing highs and swing lows and converts them into visual liquidity zones. It then monitors these zones for specific sweep conditions, helping traders visually identify situations where price takes liquidity and closes back through the corresponding zone.

BSL zones are created from confirmed swing highs, while SSL zones are created from confirmed swing lows. When a valid sweep occurs, the zone is highlighted and a corresponding bullish or bearish sweep signal is displayed on the chart.

The indicator is designed primarily as a liquidity-analysis tool and can be used alongside price action, market structure, support/resistance, order flow, or other ICT/SMC concepts.

SIGNALS LOGIC:

1. SELL SIDE LIQUIDITY (SSL) — BULLISH SWEEP

[list]
[*]SSL is created from a confirmed swing low.
[*]The indicator tracks the liquidity level and its associated zone.
[*]A bullish SSL sweep is detected when:
[/list]

[list]
[*]Price trades below the SSL level.
[*]The lookback-period low moves below the liquidity level.
[*]The candle closes above the zone body.
[*]The sweep candle closes bullish.
[/list]
  • Once triggered, the SSL zone is frozen and highlighted.
  • A bullish "B" signal is plotted below the candle.

2. BUY SIDE LIQUIDITY (BSL) — BEARISH SWEEP

[list]
[*]BSL is created from a confirmed swing high.
[*]The indicator tracks the liquidity level and its associated zone.
[*]A bearish BSL sweep is detected when:
[/list]

[list]
[*]Price trades above the BSL level.
[*]The lookback-period high moves above the liquidity level.
[*]The candle closes below the zone body.
[*]The sweep candle closes bearish.
[/list]
  • Once triggered, the BSL zone is frozen and highlighted.
  • A bearish "S" signal is plotted above the candle.

3. LIQUIDITY ZONE INVALIDATION

A liquidity zone can be removed from active tracking when price breaks the level in the opposite direction according to the script's invalidation logic.

4. CONFIRMED SWING DETECTION

Liquidity levels are generated using confirmed swing highs and swing lows based on the selected Swing Length. Increasing the Swing Length generally produces fewer but more significant liquidity levels.

USER INPUTS:

Indicator Settings

• Swing Length
Determines the number of bars used on each side of a pivot to identify swing highs and swing lows. Higher values generally produce fewer and more significant liquidity levels.

• Candles Lookback
Defines the lookback window used when checking whether price has wicked through a liquidity level and reclaimed it.

• Maximum Active BSL Zones
Controls the maximum number of Buy Side Liquidity zones that remain actively tracked.

• Maximum Active SSL Zones
Controls the maximum number of Sell Side Liquidity zones that remain actively tracked.

Visual Settings

• Zone Gradient Bands
Controls the number of gradient bands used to render each liquidity zone. More bands create a smoother visual effect.

• Glow On Swept Level
Adds a visual glow around a liquidity level when it is swept.

• Color The Sweep Candle
Highlights the candle responsible for the detected liquidity sweep.

Color Settings

• Palette Theme
Choose between:

* Neon
* Muted
* Native
* Custom

• BSL Color
Custom color for Buy Side Liquidity when the Custom palette is selected.

• SSL Color
Custom color for Sell Side Liquidity when the Custom palette is selected.

WHY IT IS UNIQUE:

• Separates Buy Side Liquidity and Sell Side Liquidity into dedicated active zones.
• Uses confirmed swing points rather than simply marking every recent high or low.
• Combines liquidity levels with zone-based visualization instead of displaying only horizontal lines.
• Automatically extends active liquidity zones until they are swept or invalidated.
• Clearly distinguishes bullish SSL sweeps from bearish BSL sweeps.
• Uses gradient zone rendering to make liquidity areas easier to identify visually.
• Provides an optional glow effect when liquidity is swept.
• Only the sweep candle is highlighted, keeping the rest of the chart visually clean.
• Includes configurable limits for active BSL and SSL zones to help manage chart clutter and drawing-object usage.
• Built-in alert conditions are available for both bullish SSL sweeps and bearish BSL sweeps.

HOW USER CAN BENEFIT FROM IT:

This indicator can help traders:

• Identify areas where liquidity may be resting above swing highs or below swing lows.
• Spot potential liquidity sweeps and rejection behavior more easily.
• Visually track active liquidity zones as price develops.
• Separate bullish SSL sweep events from bearish BSL sweep events.
• Use liquidity sweeps as an additional confirmation within an existing trading strategy.
• Combine liquidity information with market structure, trend analysis, support/resistance, FVGs, order blocks, or other ICT/SMC concepts.
• Create TradingView alerts for detected liquidity sweep events.
• Reduce manual chart marking by automatically detecting and managing liquidity zones.

IMPORTANT:

This indicator identifies liquidity and sweep conditions based on the rules implemented in the script. A liquidity sweep signal should not automatically be treated as a guaranteed buy or sell signal. Traders should use proper risk management and combine the indicator with their own market analysis and trading methodology.

The script is provided for educational and informational purposes only and does not constitute financial, investment, or trading advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Shivam_Mandrai

//@version=6

indicator("ICT BSL / SSL Liquidity", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// _________________________________________________ User Inputs _____________________________________________ \\

// --------------------------------------- Liquidity Detection Settings --------------------------------------- \\
swing_length        = input.int(20, "Swing Length "           , group = "======= Indicator Settings ========", tooltip = "Bars on each side of a pivot. Higher = fewer but more significant liquidity levels.")
candles_lookback    = input.int(5, "Candles Lookback "        , group = "======= Indicator Settings ========", tooltip = "Window used to test whether a level was wicked through and reclaimed.")
max_active_bsl      = input.int(5, "Maximum Active BSL Zones ", group = "======= Indicator Settings ========", tooltip = "How many buy side zones stay live at once. Older zones freeze on the chart.")
max_active_ssl      = input.int(5, "Maximum Active SSL Zones ", group = "======= Indicator Settings ========", tooltip = "How many sell side zones stay live at once. Older zones freeze on the chart.")

// ------------------------------------------ Zone Rendering Settings ----------------------------------------- \\
zone_bands          = input.int(6, "Zone Gradient Bands "        , minval = 1, maxval = 10, group = "======== Visual Settings ==========", tooltip = "Sub boxes used to fade each zone. 1 draws a flat zone. Higher looks smoother but uses more of the 500 box budget.")
show_glow           = input.bool(true, "Glow On Swept Level "    , group = "======== Visual Settings ==========", tooltip = "Adds a soft halo to the liquidity line at the moment it is swept.")
color_bars          = input.bool(true, "Color The Sweep Candle " , group = "======== Visual Settings ==========", tooltip = "Paints only the sweep bar. Every other candle keeps the chart default.")

// ------------------------------------------ Palette And Zone Colors ----------------------------------------- \\
palette_preset      = input.string("Neon", "Palette Theme "      , options = ["Neon", "Muted", "Native", "Custom"], group = "========= Color Settings ============", tooltip = "Neon for dark charts, Muted for heavy zone coverage, Native to match TradingView chrome.")
bsl_input           = input.color(#FF2D75, "BSL Color "        , inline = "col", group = "========= Color Settings ============", tooltip = "Buy side liquidity. Used only when the palette is set to Custom.")
ssl_input           = input.color(#00E5FF, "SSL Color "        , inline = "col", group = "========= Color Settings ============", tooltip = "Sell side liquidity. Used only when the palette is set to Custom.")

// _________________________________________________ Color System ____________________________________________ \\

// ---------------------------------------- Preset Resolved Hero Colors --------------------------------------- \\
[bsl_col, ssl_col]  = switch palette_preset
    "Neon"   => [#FF2D75, #00E5FF]
    "Muted"  => [#BD2B2B, #29B453]
    "Native" => [#F23645, #089981]
    =>          [bsl_input, ssl_input]

// ------------------------------------------ Neutral And Text Colors ----------------------------------------- \\
neutral_col         = #7C8EA3
marker_txt          = #0E1117

// ------------------------------- Transparency Ladder Used By The Zone Gradient ------------------------------ \\
var alpha_ladder    = array.from(70, 75, 80, 83, 86, 89, 92, 95, 98, 99)

// _________________________________________________ Liquidity Zone Type _____________________________________ \\

// ------------------------- One Zone Is A Stack Of Gradient Bands Plus Its Level Line ------------------------ \\
type liq_zone
    float      level
    float      body
    int        left
    array<box> bands
    line       edge

// _________________________________________________ Drawing Functions _______________________________________ \\

// -------------------- Build The Gradient Bands - Opaque Edge Sits On The Liquidity Level -------------------- \\
build_bands(float top_price, float bot_price, int left_bar, bool from_top, color hero) =>
    bands           = array.new<box>()
    band_step       = (top_price - bot_price) / zone_bands
    for i = 0 to zone_bands - 1
        ix          = zone_bands == 1 ? 0 : int(math.round(i * 9.0 / (zone_bands - 1)))
        alp         = alpha_ladder.get(ix)
        b_top       = from_top ? top_price - band_step * i : bot_price + band_step * (i + 1)
        b_bot       = from_top ? top_price - band_step * (i + 1) : bot_price + band_step * i
        bands.push(box.new(left_bar, b_top, bar_index, b_bot, border_color = na, border_width = 0, bgcolor = color.new(hero, alp)))
    bands

// ---------------------------------- Stretch A Live Zone To The Current Bar ---------------------------------- \\
extend_zone(liq_zone z) =>
    for b in z.bands
        b.set_right(bar_index)
    z.edge.set_x2(bar_index)

// ---------------------------- Wash A Zone Out Once It Is Invalidated Or Aged Out ---------------------------- \\
retire_zone(liq_zone z) =>
    for b in z.bands
        b.set_bgcolor(color.new(neutral_col, 95))
    z.edge.set_color(color.new(neutral_col, 75))

// -------------------------------- Ignite The Level At The Moment It Is Swept -------------------------------- \\
ignite_zone(liq_zone z, color hero) =>
    z.edge.set_color(hero)
    z.edge.set_width(2)
    z.edge.set_style(line.style_solid)
    if show_glow
        line.new(z.left, z.level, bar_index, z.level, color = color.new(hero, 94), width = 4)
        line.new(z.left, z.level, bar_index, z.level, color = color.new(hero, 96), width = 10)
        line.new(z.left, z.level, bar_index, z.level, color = color.new(hero, 98), width = 20)

// _________________________________________________ Swing Pivot Detection ___________________________________ \\

// ----------------------------------------- Swing High And Swing Low ----------------------------------------- \\
swing_high          = ta.pivothigh(swing_length, swing_length)
swing_low           = ta.pivotlow(swing_length, swing_length)

// -------------------------------- Lookback Extremes Used For Sweep Detection -------------------------------- \\
highest_high        = ta.highest(high, candles_lookback)
lowest_low          = ta.lowest(low, candles_lookback)

// _________________________________________________ Liquidity Zone Storage __________________________________ \\

// ----------------------------------------- Buy Side Liquidity Levels ---------------------------------------- \\
var float bsl_high  = na
var float bsl_body  = na
var int bsl_left    = na
var line bsl_edge   = na

// ---------------------------------------- Sell Side Liquidity Levels ---------------------------------------- \\
var float ssl_low   = na
var float ssl_body  = na
var int ssl_left    = na
var line ssl_edge   = na

// -------------------------------------------- Active Zone Arrays -------------------------------------------- \\
var bsl_zone_array  = array.new<liq_zone>()
var ssl_zone_array  = array.new<liq_zone>()

// _________________________________________________ Buy Side Liquidity Creation _____________________________ \\

// -------------------------------- Draw BSL Zone From The Confirmed Swing High ------------------------------- \\
if not na(swing_high)
    bsl_high        := high[swing_length]
    bsl_body        := close[swing_length] > open[swing_length] ? close[swing_length] : open[swing_length]
    bsl_left        := bar_index[swing_length]
    bsl_edge        := line.new(bsl_left, bsl_high, bar_index, bsl_high, color = color.new(bsl_col, 20), width = 1, style = line.style_dotted)
    bsl_zone_array.push(liq_zone.new(bsl_high, bsl_body, bsl_left, build_bands(bsl_high, bsl_body, bsl_left, true, bsl_col), bsl_edge))
    // ----------------------------- Trim The Oldest Zone Once The Cap Is Reached ----------------------------- \\
    if bsl_zone_array.size() > max_active_bsl
        retire_zone(bsl_zone_array.get(0))
        bsl_zone_array.remove(0)

// _________________________________________________ Sell Side Liquidity Creation ____________________________ \\

// -------------------------------- Draw SSL Zone From The Confirmed Swing Low -------------------------------- \\
if not na(swing_low)
    ssl_low         := low[swing_length]
    ssl_body        := close[swing_length] > open[swing_length] ? open[swing_length] : close[swing_length]
    ssl_left        := bar_index[swing_length]
    ssl_edge        := line.new(ssl_left, ssl_low, bar_index, ssl_low, color = color.new(ssl_col, 20), width = 1, style = line.style_dotted)
    ssl_zone_array.push(liq_zone.new(ssl_low, ssl_body, ssl_left, build_bands(ssl_body, ssl_low, ssl_left, false, ssl_col), ssl_edge))
    // ----------------------------- Trim The Oldest Zone Once The Cap Is Reached ----------------------------- \\
    if ssl_zone_array.size() > max_active_ssl
        retire_zone(ssl_zone_array.get(0))
        ssl_zone_array.remove(0)

// _________________________________________________ Sell Side Liquidity Sweep _______________________________ \\

// ------------------------------------------------ Sweep Flag ------------------------------------------------ \\
ssl_sweep           = false

// ----------------------- Walk The Active SSL Zones Backwards So Removal Is Index Safe ----------------------- \\
if ssl_zone_array.size() > 0
    for i = ssl_zone_array.size() - 1 to 0
        ssl_zone    = ssl_zone_array.get(i)
        ssl_level   = ssl_zone.level
        ssl_swept   = close > ssl_zone.body and lowest_low < ssl_level and close > open
        ssl_broken  = close[candles_lookback] < ssl_level

        if ssl_swept
            // ----------------------- Signal Fires Once Then The Zone Is Frozen And Lit ---------------------- \\
            ssl_sweep := true
            extend_zone(ssl_zone)
            ignite_zone(ssl_zone, ssl_col)
            ssl_zone_array.remove(i)
        else if ssl_broken
            // ----------------------- Zone Invalidated - Wash It Out And Stop Tracking ----------------------- \\
            retire_zone(ssl_zone)
            ssl_zone_array.remove(i)
        else
            // ------------------------ Zone Still Live - Extend It To The Current Bar ------------------------ \\
            extend_zone(ssl_zone)

// _________________________________________________ Buy Side Liquidity Sweep ________________________________ \\

// ------------------------------------------------ Sweep Flag ------------------------------------------------ \\
bsl_sweep           = false

// ----------------------- Walk The Active BSL Zones Backwards So Removal Is Index Safe ----------------------- \\
if bsl_zone_array.size() > 0
    for j = bsl_zone_array.size() - 1 to 0
        bsl_zone    = bsl_zone_array.get(j)
        bsl_level   = bsl_zone.level
        bsl_swept   = close < bsl_zone.body and highest_high > bsl_level and close < open
        bsl_broken  = close[candles_lookback] > bsl_level

        if bsl_swept
            // ----------------------- Signal Fires Once Then The Zone Is Frozen And Lit ---------------------- \\
            bsl_sweep := true
            extend_zone(bsl_zone)
            ignite_zone(bsl_zone, bsl_col)
            bsl_zone_array.remove(j)
        else if bsl_broken
            // ----------------------- Zone Invalidated - Wash It Out And Stop Tracking ----------------------- \\
            retire_zone(bsl_zone)
            bsl_zone_array.remove(j)
        else
            // ------------------------ Zone Still Live - Extend It To The Current Bar ------------------------ \\
            extend_zone(bsl_zone)

// _________________________________________________ Plotting ________________________________________________ \\

// ----------------------------------------------- Sweep Signals ---------------------------------------------- \\
plotshape(ssl_sweep, "SSL Sweep - Bullish", shape.labelup  , location = location.belowbar, color = color.new(ssl_col, 10), textcolor = marker_txt, text = "B", force_overlay = true)
plotshape(bsl_sweep, "BSL Sweep - Bearish", shape.labeldown, location = location.abovebar, color = color.new(bsl_col, 10), textcolor = marker_txt, text = "S", force_overlay = true)

// ---------------------------------------- Paint Only The Sweep Candle --------------------------------------- \\
barcolor(color_bars and (ssl_sweep or bsl_sweep) ? (ssl_sweep ? ssl_col : bsl_col) : na)

// _________________________________________________ Alerts __________________________________________________ \\
alertcondition(ssl_sweep, "SSL Sweep - Bullish", "Sell side liquidity swept - bullish sweep !!")
alertcondition(bsl_sweep, "BSL Sweep - Bearish", "Buy side liquidity swept - bearish sweep !!")
````
