# Tiki Gamma (GEX)

- url: https://www.tradingview.com/script/2KmTiGIY-Tiki-Gamma-GEX/
- type: indicator
- pine_id: PUB;ee3961b03ef44d1e9446e9ace805b2db
- version: 1.0

## Description

Tiki Gamma maps the options dealer hedging levels that may influence intraday price action — directly on your chart.

Options dealers hedge trillions in exposure every session. They typically hedge by buying or selling the underlying to stay delta-neutral. Theoretical models suggest that at strikes where large open interest concentrates, this hedging may be large enough to influence price. These flows can be systematic and large, and are often watched by institutional desks as potential structural support and resistance reference points.

This indicator draws manually provided levels. It does not calculate levels from live options data. It is a visualization tool for external data.

[b]What It Draws[/b]

[b]Call Walls & Put Walls[/b] — Overhead zones where theoretical dealer selling is heaviest. Below-market zones where theoretical dealer buying provides structural support. Call walls may resist upward moves; put walls, if broken, may lead to accelerated moves. Line thickness scales with strength so the dominant level is immediately visible.

[b]Zero Gamma Flip[/b] — An important regime filter in modern markets. Above it, dealers may trade mean-reverting. Below it, they may trade amplifying.

[b]Expert Configuration[/b] (Signal-to-Noise Ratio) — Ships with optimized configuration for high-conviction trading. We recommend limiting Walls and Absolute Gamma to 3 levels each at 80%+ strength to filter out noise, while keeping Large Gamma at a 5-level, 50% strength threshold to catch secondary intraday pivots.

[b]Gamma Transition Band[/b] (Experimental) — The contested zone around the flip where dealer positioning is mixed. Price action inside this band is inherently noisier. These levels are currently in experimental beta.

[b]Key Gamma Strike & Large Gamma[/b] — Potential areas of interest. Price may gravitate toward them. In trending sessions, they can act as checkpoint S/R. Optional strength percentages and GEX magnitude labels show which levels carry real weight.

[b]Vanna Inflection[/b] — Where an IV expansion triggers forced delta rehedging independent of price movement. A level that is often monitored during gap opens and VIX events.

[b]Speed Trap[/b] — Where a move lower may theoretically create disproportionate dealer selling. A level that may turn a pullback into a flush.

[b]Max Pain[/b] — The settlement gravity point. The zone expands automatically near close as charm-driven delta unwinding theoretically strengthens into expiration — reflecting end-of-day pinning behavior.

[b]Expected / Implied Move Bands[/b] — 1-SD and 2-SD statistical envelopes. Inside the box: mean reversion is plausible. Outside it: respect the move.

[b]Visual Design[/b]

[list]
[*][b]Regime Background[/b] — Chart can be configured to tint teal above the gamma flip (stabilizing), magenta below (amplifying). Off by default to minimize clutter.
[*][b]Strength-Scaled Lines & Opacity[/b] — Dominant levels draw thicker and more opaque. Weaker levels fade. Hierarchy is visible without reading a single label.
[*][b]HUD Dashboard[/b] — Compact overlay showing current regime, distance to nearest walls in implied-move units (sigma), and futures basis shift.
[*][b]Proximity Highlighting[/b] — Zone opacity increases when price enters a level. The active level always stands out.
[*][b]Max Pain Expansion[/b] — The max pain zone grows as charm effects strengthen into the close, reflecting real-time gravitational pull.
[*][b]Price Axis Tags[/b] — Every level is tagged on the price axis for quick reference without chart clutter.
[*][b]Futures Basis Shift[/b] — SPX/NDX levels mapped accurately onto ES/NQ charts. When in Prior Bar mode, the indicator dynamically calculates the exact, real-time basis offset using prior close data to ensure perfect, stable alignment. If the ticker is unmapped or Session Open mode is selected, it automatically falls back to your initially pasted Basis Shift.
[/list]

[b]Settings & Configuration[/b]

The indicator features deep customisation via its settings panel, grouped for ease of use:

[list]
[*][b]Visibility[/b] — Toggle individual level types (Walls, GEX nodes, Vanna, Speed Trap, etc.), the HUD Dashboard, and Price Axis Labels. Choose between Level names, Prices, or both for on-chart labels.
[*][b]Style[/b] — Adjust base Line Width and enable Strength scaling for width/opacity. Toggle GEX Magnitude ($) and Vol Resilience (↑/↓) arrows in labels. Select Label Alignment (Left vs Last Bar) and Format (Full vs Abbreviated). Configure Display Timezone for timestamped levels.
[*][b]Level Filters[/b] — Fine-tune signal clarity by setting global and per-type "Min Strength %" thresholds. Use the "Max Total Levels" cap to limit the total number of lines drawn near price.
[*][b]Colors & Opacity[/b] — Customise the color for every level category. Global sliders control base opacity for lines and shaded influence zones.
[*][b]Visual Effects & Advanced[/b] — Configure Regime Background colors and opacity. Customise Advanced Max Pain settings, including the close-time target and the growth window for end-of-day expansion.
[/list]

[b]How It Works[/b]

Paste your formatted level data into the indicator's text input. Each level accepts optional metadata — strength, vol resilience, and GEX magnitude — so the indicator reflects the full depth of the pipeline output, not just price levels.

[b]Open Source[/b]

Full source is published openly. Read it, fork it, learn from it. Every level type is documented in the script header with the theoretical dealer mechanics that drive it. The display layer is transparent.

## Source Code

````pine
//@version=6        
//                                      
// ══════════════════════════════════════════════════════════════════════════════════════════════════════
// TIKI GAMMA - Open Source TradingView gamma levels indicator
// ══════════════════════════════════════════════════════════════════════════════════════════════════════
//
// Visualise options market structure directly on your TradingView chart.
// Since Pine Script cannot call external APIs to fetch options data,
// this script plots levels that are manually pasted into the 
// "Level Data" text area.
//
// ── WHAT IT DRAWS ────────────────────────────────────────────────
//
//  • Call Walls & Put Walls       — major dealer-hedging resistance/support
//  • Absolute & Key Gamma Strike  — highest net gamma concentration
//  • Large Gamma                  — ranked gamma strikes with optional
//                                   strength percentages
//  • Vanna Inflection             — price where vanna flips sign
//  • Speed Trap                   — momentum-acceleration zone
//  • Max Pain                     — maximum option-seller profit level
//  • Zero Gamma + Transition Zone — dealer flip point with shaded band
//  • Expected / Extreme / Implied Move bounds (1-SD and 2-SD)
//  • Underlying Price             — last known spot with update time
//
//  Levels at the same price are automatically merged into a single
//  line with a combined label (e.g. "Call Wall / Key Gamma Strike"),
//  keeping the chart clean regardless of how many data sources
//  overlap.
//
// ── CODE STRUCTURE ───────────────────────────────────────────────
//
//  1. Inputs & UI Configuration: Settings for colors, styles, and data.
//  2. Utility Functions: Parsing strings, formatting, and time conversion.
//  3. Drawing Logic: Functions for rendering lines, zones, and labels.
//  4. Main Execution: Parsing the pasted data and calculating proximities.
//  5. HUD Rendering: Drawing the on-chart dashboard.
//  6. Price Axis Plots: Invisible plots to show level prices on the axis.
//
// ── VISUAL FEATURES ──────────────────────────────────────────────
//
//  • Strength → Line Width        — line thickness scales with level
//                                   strength so dominant levels are
//                                   immediately visible
//  • Regime Background Tint       — teal above gamma flip (stabilising),
//                                   magenta below (amplifying)
//  • Proximity Highlighting       — zone opacity increases when price
//                                   is inside a level's zone
//  • HUD Dashboard                — compact overlay: current regime,
//                                   distance to nearest walls in σ,
//                                   basis shift; rows light up at level
//  • Max Pain Grows Near Close    — zone expands as charm effects
//                                   strengthen into expiration
//
// ── INPUT FORMAT ─────────────────────────────────────────────────
//
//  Multi-entry lists    →  "5800, 5850, 5900"
//                        or "5800:92, 5850:74, 5900:61"
//                        or "5800:92:18:380, 5850:74:-3:210"
//
//  Tuple fields         →  price:strength:volResilience:magnitude
//                            price         — strike price (required)
//                            strength      — 0–100; peer-relative within category
//                            volResilience — -100 to +100; positive = level
//                                           strengthens under IV expansion
//                            magnitude     — raw GEX in millions (integer);
//                                           drives $380M / $1.2B labels when
//                                           "GEX Magnitude in Labels" is on
//                          All fields after price are optional. Omit trailing
//                          fields to fall back to 100% strength, no
//                          volResilience encoding, no magnitude label).
//
//                          Strength is peer-relative within each category and
//                          uses the category's own ranking metric:
//                            Call Walls      → relative call GEX
//                            Put Walls       → relative put GEX
//                            Absolute Gamma  → relative total GEX (call + put)
//                            Large Gamma     → relative |net GEX|
//                          100 = strongest in the group; others are scaled
//                          proportionally. Single-value levels have no strength.
//
//  Single-price fields  →  "5775"
//
//  Underlying           →  price, optionally with UTC update time
//                          "661.43 @ 16:00"
//
// ── EXAMPLE COPY FORMAT ──────────────────────────────────────────
//
// Call Walls:              5800:92:18:380, 5850:74:-3:210
// Put Walls:               5700:95:-8:290, 5650:71:2:145
// Absolute Gamma:          5780:88:5:520, 5775:81:12:480
// Key Gamma Strike:        5775
// Large Gamma:             5795:85:-4:820, 5785:72:16:376, 5775:45:7:190
// Vanna Inflection:        5760
// Speed Trap:              5720
// Max Pain:                5770
// Zero Gamma:              5765
// Transition Lower:        5755
// Transition Upper:        5785
// Expected Move Upper:     5830
// Expected Move Lower:     5744
// Extreme Move Upper:      5874
// Extreme Move Lower:      5700
// Implied Move Upper:      5817
// Implied Move Lower:      5758
// Underlying:              661.43 @ 16:00
// Basis Shift:             82.02
//
// ════════════════════════════════════════════════════════════════════
// HOW THE LEVELS WORK
// ════════════════════════════════════════════════════════════════════
//
// Options dealers (market makers) hedge their books continuously.
// Theoretical models suggest that at strikes where large open interest
// concentrates, this hedging may be large enough to influence price.
//
// GEX (Gamma Exposure) estimates the dollar magnitude of that hedging
// per unit of price move. This script visualises strikes where GEX
// is theoretically significant, based on the data provided to it.
//
// CALL WALLS      Dealers are typically assumed to be net short calls.
//                 As price rallies toward a call wall, rising delta may
//                 lead them to sell the underlying, potentially
//                 acting as resistance.
//
// PUT WALLS       Dealers are typically assumed to be net short puts.
//                 Falling price may lead them to buy, potentially
//                 providing support. If a put wall breaks, unwinding
//                 hedges may potentially accelerate a drop.
//
// ZERO GAMMA      The theoretical price where net dealer gamma crosses
//                 zero. Above it: hedging may act as a stabiliser.
//                 Below it: hedging may amplify moves. Often watched
//                 as a potential regime filter.
//
// VANNA           Measures how a position's delta changes as implied
//                 volatility changes. The Vanna Inflection marks where
//                 this concentration is highest — often monitored on
//                 gap opens and VIX expansion days.
//
// SPEED TRAP      Where put/call GEX asymmetry is theoretically extreme
//                 on the downside. A move lower here may potentially
//                 trigger accelerated selling.
//
// MAX PAIN        The settlement strike that minimises total payout to
//                 option holders. Charm (time decay of delta) may
//                 create a gravitational pull toward this strike as
//                 expiration approaches.
//
// VANNA           The volResilience field on each level encodes whether
// RESILIENCE      the level theoretically strengthens (positive) or
//                 dissolves (negative) when IV expands.
//
// ════════════════════════════════════════════════════════════════════
// DATA SOURCE
// ════════════════════════════════════════════════════════════════════
//
// Paste your formatted level data into the "Level Data" input field.
//
// ════════════════════════════════════════════════════════════════════
// LICENSE
// ════════════════════════════════════════════════════════════════════
//
// MIT License — use, fork, and modify freely.
//
// ════════════════════════════════════════════════════════════════════

indicator("Tiki Gamma", shorttitle="Tiki Gamma", overlay=true,
     max_lines_count=200, max_labels_count=200, max_boxes_count=500)


// ── Level Data ────────────────────────────────────────────────────
// Primary input — paste fresh levels here each session.

var string GRP_DATA = "Level Data"
in_data = input.text_area(
    defval  = "Call Walls:\nPut Walls:\nAbsolute Gamma:\nKey Gamma Strike:\nLarge Gamma:\nVanna Inflection:\nSpeed Trap:\nMax Pain:\nZero Gamma:\nTransition Lower:\nTransition Upper:\nExpected Move Upper:\nExpected Move Lower:\nExtreme Move Upper:\nExtreme Move Lower:\nImplied Move Upper:\nImplied Move Lower:\nImplied Move 2SD Upper:\nImplied Move 2SD Lower:\nUnderlying:\nOpen Price:\nBasis Shift:",
    title   = "Paste Levels Here",
    group   = GRP_DATA,
    tooltip = "Paste your level data — one per line.\n\nExamples:\n  Call Walls: 5800, 5850\n  Large Gamma: 5795:85, 5785:72\n  Underlying: 661.43 @ 16:00")


// ── Visibility ────────────────────────────────────────────────────

var string GRP_VIS = "Visibility"
show_walls         = input.bool(true,  "Walls (Call / Put)",         group=GRP_VIS,
     tooltip="Call Walls may act as resistance; Put Walls may act as support based on theoretical dealer hedging — see header comments for details.")
show_key_gamma     = input.bool(true,  "Key Gamma / Absolute Gamma", group=GRP_VIS,
     tooltip="Key Gamma Strike is the single highest net-gamma strike. Absolute Gamma shows the top total-GEX strikes (call + put combined).")
show_large_gamma   = input.bool(true,  "Large Gamma",                group=GRP_VIS,
     tooltip="Ranked gamma strikes with significant but not dominant exposure. Useful for identifying secondary support/resistance clusters.")
show_vanna         = input.bool(true,  "Vanna Inflection",           group=GRP_VIS,
     tooltip="The strike where vanna (sensitivity of delta to IV) is most concentrated. Most relevant on gap opens and VIX expansion days when dealers must rehedge without price moving.")
show_speed_trap    = input.bool(true,  "Speed Trap",                 group=GRP_VIS,
     tooltip="Where put/call GEX asymmetry is theoretically extreme on the downside. A move lower here may potentially trigger accelerated selling.")
show_max_pain      = input.bool(true,  "Max Pain",                   group=GRP_VIS,
     tooltip="The settlement strike that minimises total payout to option holders. Charm (time decay of delta) may create a gravitational pull here as expiration approaches.")
show_zero_gamma    = input.bool(true,  "Zero Gamma",                 group=GRP_VIS,
     tooltip="The theoretical price where net dealer gamma crosses zero. Above: hedging may stabilise price. Below: hedging may amplify moves. Often watched as a potential regime filter.")
show_transition    = input.bool(false, "Transition Zone (Experimental)",            group=GRP_VIS,
     tooltip="[EXPERIMENTAL] The price band around Zero Gamma where regime behaviour transitions. Off by default; enable for a visual buffer around the flip point.")
show_exp_move      = input.bool(true,  "Expected Move",              group=GRP_VIS,
     tooltip="The ±1-standard-deviation price range implied by at-the-money options (roughly 68% probability band).")
show_ext_move      = input.bool(true,  "Extreme Move",               group=GRP_VIS,
     tooltip="The ±2-standard-deviation price range implied by options (roughly 95% probability band). Moves beyond this are statistically rare.")
show_imp_move      = input.bool(true,  "Implied Move",               group=GRP_VIS,
     tooltip="IV-derived single-day move estimate — the market's priced-in range for the current session.")
show_imp_2sd       = input.bool(false, "Implied Move 2SD",           group=GRP_VIS,
     tooltip="The 2-standard-deviation extension of the Implied Move. Off by default; enable when tracking tail-risk or wide-range sessions.")
show_underlying    = input.bool(false,  "Underlying Price",           group=GRP_VIS,
     tooltip="Plots the last known spot price from the pasted data, with the update timestamp if provided.")
show_open          = input.bool(true,  "Open Price",                 group=GRP_VIS,
     tooltip="Plots the open price from the pasted data, with the open time if provided.")
show_price_axis    = input.bool(true,  "Price Axis Labels",          group=GRP_VIS,
     tooltip="Show level prices on the right price axis. Uses invisible plot lines to display colored price tags. NOTE: Pine Script limits indicators to 64 plots total; Tiki Gamma uses 57 slots to provide first-class axis status to all major levels.")
show_labels        = input.string("Level", "Labels",                  group=GRP_VIS,
     options=["Level", "Price", "Level & Price", "Off"],
     tooltip="What to show in level labels.\n\nLevel: name only (e.g. 'Call Wall 1').\nPrice: price only (e.g. '5800').\nLevel & Price: both (e.g. 'Call Wall 1 (5800)').\nOff: hide all labels.")
in_basis_shift_mode = input.string("Session Open", "Apply Basis Shift", options=["Prior Bar", "Session Open", "Off"], group=GRP_VIS,
     tooltip="When Prior Bar, the indicator will dynamically calculate the real-time exact shift using the prior close for ES/MES and NQ/MNQ. When Session Open, it strictly uses the 'Basis Shift' from your pasted payload (representing the snapshot start-of-session basis). Select 'Off' to plot raw levels.")
apply_basis_shift = switch in_basis_shift_mode
    "Session Open"  => syminfo.type == "futures"
    "Prior Bar"     => syminfo.type == "futures"
    => false
show_regime_bg     = input.bool(false, "Regime Background Tint",     group=GRP_VIS,
     tooltip="Tints the chart teal when price is above the gamma flip (mean-reverting regime) and magenta when below (amplifying). Off by default to keep the chart clean; enable for a session-wide visual filter.")
show_hud           = input.bool(true,  "HUD Dashboard",              group=GRP_VIS,
     tooltip="Compact overlay showing current regime, distance to nearest walls, and basis shift. Rows highlight automatically when price enters a level's zone.")
hud_dist_mode      = input.string("Points", "HUD Distance Mode",     group=GRP_VIS, options=["Points", "Sigma"],
     tooltip="Points: distance in price units (e.g. +45.2 pts). Sigma: distance in standard deviations (e.g. +1.2σ).")
hud_pos            = input.string("Top Right", "HUD Position",       group=GRP_VIS,
     options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"])
hud_color          = input.color(color.new(#AAAAAA, 0), "HUD Color",  group=GRP_VIS,
     tooltip="Text and label color for non-highlighted HUD rows.")
hud_size           = input.string(size.normal, "HUD Font Size",      group=GRP_VIS,
    options=[size.tiny, size.small, size.normal, size.large, size.huge],
    tooltip="Font size used by the HUD dashboard rows.")
show_proximity     = input.bool(true,  "Proximity Highlighting",     group=GRP_VIS,
     tooltip="Increases zone opacity when price is inside a level's zone, making the active level visually stand out.")


// ── Style ─────────────────────────────────────────────────────────

var string GRP_STYLE = "Style"
line_wid_min         = input.int(1,          "Min Line Width",               group=GRP_STYLE, minval=1, maxval=5, tooltip="Line width for the weakest ranked levels (when scaled).")
line_wid_max         = input.int(5,          "Max Line Width",               group=GRP_STYLE, minval=1, maxval=10, tooltip="Line width for the strongest ranked levels (when scaled).")
line_wid_def         = input.int(1,          "Default Line Width",           group=GRP_STYLE, minval=1, maxval=10, tooltip="Line width for structural/unranked levels (e.g. Expected Move, Open Price, Zero Gamma).")
strength_line_width  = input.bool(true,      "Strength → Line Width",        group=GRP_STYLE,
     tooltip="Scales line width by level strength. Strongest levels draw at Max Line Width; weaker levels draw thinner down to Min Line Width.\n\nStrength is peer-relative within each category: Call/Put Walls compare by their respective directional GEX; Absolute Gamma by total GEX (call + put); Large Gamma by absolute net GEX. A wall at 75% means its GEX is 75% of the strongest wall in that same group.")
use_strength_opacity = input.bool(true,      "Strength → Opacity",           group=GRP_STYLE,
     tooltip="Scales line and zone opacity by level strength. Weaker levels appear more transparent. Works in conjunction with the base Level Opacity setting.")
show_gex_magnitude   = input.bool(true,     "GEX Magnitude in Labels",      group=GRP_STYLE,
     tooltip="Adds the raw GEX dollar amount to ranked level labels — e.g. 'Call Wall 1 (92%) $380M'. On by default.\n\nGEX magnitude is product-specific: $380M is significant for QQQ but unremarkable for SPX. Compare within the same symbol, not across symbols.")
show_vol_resilience  = input.bool(false,     "Vol Resilience in Labels",     group=GRP_STYLE,
     tooltip="Appends ↑ or ↓ to ranked level labels based on the volResilience field in the paste data.\n\n↑ = level strengthens under IV expansion (dealers hedge harder into it).\n↓ = level dissolves when VIX spikes.\n\nOnly annotates when |volResilience| > 10% — levels below this threshold are vol-neutral and treated as normal S/R. Seeing no arrows at all is common and means all displayed levels behave similarly under a vol spike (low-signal environment).\n\nRequires the 4-tuple paste format: price:strength:volResilience:magnitude.")
show_zones           = input.bool(true,      "Level Zones",                  group=GRP_STYLE,
     tooltip="Draws a shaded band above and below each level line to visualise its influence zone. Zone height is controlled by 'Zone Height (ticks)'.")
zone_pts             = input.float(1.00,      "Zone Height (pts)",            group=GRP_STYLE, minval=0.01, maxval=50.0, step=0.01,
     tooltip="Half-height of each level's zone band, in points. Total band height is 2× this value. Proximity highlighting activates when price enters this band.")
lbl_align            = input.string("Left", "Label Alignment",            group=GRP_STYLE,
     options=["Last Bar", "Left"], tooltip="Last Bar: anchored to the last bar + offset. Left: anchored to the left chart edge (follows scroll).")
lbl_format           = input.string("Full", "Label Format",                  group=GRP_STYLE,
     options=["Full", "Short", "Abbrev"], tooltip="Label brevity. Full: 'Call Wall' | Short: 'C Wall' | Abbrev: 'CW'")
lbl_size             = input.string(size.normal, "Label Size",               group=GRP_STYLE,
     options=[size.tiny, size.small, size.normal, size.large, size.huge])
lbl_pos              = input.string("Below", "Label Vertical Position",      group=GRP_STYLE,
     options=["Above", "Below"])
lbl_offset           = input.int(2,          "Label Offset (bars)",          group=GRP_STYLE, minval=-100, maxval=500,
     tooltip="Left: bars inward from left edge. Last Bar: bars to the right of the last bar.")
line_style_walls     = input.string("Solid", "Walls Line Style",             group=GRP_STYLE, options=["Solid", "Dashed", "Dotted"])
line_style_gamma     = input.string("Solid", "Gamma Line Style",             group=GRP_STYLE, options=["Solid", "Dashed", "Dotted"])
line_style_zero      = input.string("Dashed","Zero Gamma Line Style",        group=GRP_STYLE, options=["Solid", "Dashed", "Dotted"])
line_style_moves     = input.string("Dotted","Move/Sigma Line Style",        group=GRP_STYLE, options=["Solid", "Dashed", "Dotted"])
display_tz           = input.string("America/New_York", "Display Timezone", group=GRP_STYLE, options=["America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles", "Europe/London", "UTC", "Exchange"],
     tooltip="Timezone for the timestamp shown in the Underlying and Open labels. Select a valid IANA timezone ID to automatically handle daylight savings, or use 'Exchange' to use the symbol's exchange timezone (syminfo.timezone), which may differ from your chart's display timezone.")
display_tz_label     = display_tz == "America/New_York" ? "NY" : display_tz == "Exchange" ? "Exch" : display_tz


// ── Level Filters ─────────────────────────────────────────────────
// Control how many levels are drawn and how weak a level must be
// before it is hidden.  Strength is peer-relative within each
// category: 100 = strongest in the group, others scaled proportionally.

var string GRP_FILTERS = "Level Filters"
min_strength           = input.int(30, "Global Min Strength %",         group=GRP_FILTERS, minval=0, maxval=100,
     tooltip="Master filter: hide ANY multi-entry level below this strength, regardless of its type-specific threshold.")
max_total_levels       = input.int(20, "Max Total Levels",              group=GRP_FILTERS, minval=1, maxval=50,
     tooltip="Master cap: limit the total number of strike levels drawn on the chart to the N levels closest to price.")
min_call_wall_strength = input.int(85, "Call Wall Min Strength %",      group=GRP_FILTERS, minval=25, maxval=100,
     tooltip="Hide Call Walls whose strength falls below this threshold. 85 = only the top ~15% of walls are drawn. Lower to show weaker levels.")
max_call_wall_levels   = input.int(3,  "Call Wall Max Levels",          group=GRP_FILTERS, minval=1, maxval=10,
     tooltip="Maximum number of Call Wall lines to draw, taken from the strongest down. Acts as a hard cap after the strength filter.")
min_put_wall_strength  = input.int(85, "Put Wall Min Strength %",       group=GRP_FILTERS, minval=25, maxval=100,
     tooltip="Hide Put Walls whose strength falls below this threshold.")
max_put_wall_levels    = input.int(3,  "Put Wall Max Levels",           group=GRP_FILTERS, minval=1, maxval=10,
     tooltip="Maximum number of Put Wall lines to draw.")
min_abs_gamma_strength = input.int(80, "Absolute Gamma Min Strength %", group=GRP_FILTERS, minval=25, maxval=100,
     tooltip="Hide Absolute Gamma strikes below this strength.")
max_abs_gamma_levels   = input.int(3,  "Absolute Gamma Max Levels",     group=GRP_FILTERS, minval=1, maxval=10,
     tooltip="Maximum number of Absolute Gamma lines to draw.")
min_lgamma_strength    = input.int(50, "Large Gamma Min Strength %",    group=GRP_FILTERS, minval=10, maxval=100,
     tooltip="Hide Large Gamma strikes below this strength.")
max_lgamma_levels      = input.int(5,  "Large Gamma Max Levels",        group=GRP_FILTERS, minval=1, maxval=10,
     tooltip="Maximum number of Large Gamma lines to draw.")


// ── Colors ────────────────────────────────────────────────────────

var string GRP_COL = "Colors"
col_resist  = input.color(color.new(#E81E72, 0),  "Resistance (Call Walls)",  group=GRP_COL)
col_support = input.color(color.new(#00ACBA, 0),  "Support (Put Walls)",      group=GRP_COL)
col_lgamma  = input.color(color.new(#00ACBA, 0),  "Large Gamma",              group=GRP_COL)
col_zgamma  = input.color(color.new(#FFDD33, 0),  "Zero Gamma / Transition",  group=GRP_COL)
col_maxpain = input.color(color.new(#CCCCCC, 0),  "Max Pain",                 group=GRP_COL)
col_strap   = input.color(color.new(#999999, 0),  "Speed Trap",               group=GRP_COL)
col_vanna   = input.color(color.new(#CC29C4, 0),  "Vanna Inflection",         group=GRP_COL)
col_exp     = input.color(color.new(#FEB000, 0),  "Expected Move",            group=GRP_COL)
col_ext     = input.color(color.new(#FF7900, 0),  "Extreme Move",             group=GRP_COL)
col_imp     = input.color(color.new(#FF9200, 0),  "Implied Move",             group=GRP_COL)
col_imp2sd  = input.color(color.new(#EA5752, 0),  "Implied Move 2SD",         group=GRP_COL)
col_under   = input.color(color.new(#777777, 0),  "Underlying Price",         group=GRP_COL)
col_open    = input.color(color.new(#FF9200, 0),  "Open Price",               group=GRP_COL)
line_opac_min= input.int(40,                      "Min Line Opacity",         group=GRP_COL, minval=0, maxval=100, tooltip="Opacity for the weakest ranked levels (when scaled). 100 = fully opaque.")
line_opac_max= input.int(100,                     "Max Line Opacity",         group=GRP_COL, minval=0, maxval=100, tooltip="Opacity for the strongest ranked levels.")
line_opac_def= input.int(100,                     "Default Line Opacity",     group=GRP_COL, minval=0, maxval=100, tooltip="Opacity for structural/unranked levels (e.g. Expected Move).")
zone_opac_min= input.int(5,                       "Min Zone Opacity",         group=GRP_COL, minval=0, maxval=100, tooltip="Zone opacity for the weakest ranked levels (when scaled).")
zone_opac_max= input.int(25,                      "Max/Default Zone Opacity", group=GRP_COL, minval=0, maxval=100, tooltip="Zone opacity for strongly ranked or structural levels.")


// ── Visual Effects ──────────────────────────────────────────────────

var string GRP_VFX = "Visual Effects"
regime_bg_opac       = input.int(10,                      "Regime Background Opacity",  group=GRP_VFX, minval=0, maxval=50,
     tooltip="Opacity of the regime background tint. Lower values are more subtle.")
regime_bull_col      = input.color(color.new(#00ACBA, 0), "Regime Bullish Color",       group=GRP_VFX,
     tooltip="Background tint color when price is above the gamma flip (stabilising regime).")
regime_bear_col      = input.color(color.new(#E81E72, 0), "Regime Bearish Color",       group=GRP_VFX,
     tooltip="Background tint color when price is below the gamma flip (amplifying regime).")
proximity_zone_opac  = input.int(70,                      "Proximity Zone Opacity",     group=GRP_VFX, minval=0, maxval=100,
     tooltip="Zone opacity when price is within the zone (proximity highlighting).")


// ── Advanced Max Pain ───────────────────────────────────────────────

var string GRP_MP = "Advanced Max Pain"
max_pain_grow        = input.bool(true,    "Max Pain Grows Near Close",  group=GRP_MP,
     tooltip="Expand the Max Pain zone width as market close approaches, reflecting increasing charm/pin pressure.")
max_pain_close_time  = input.string("16:00", "Max Pain Close Time (HH:MM)", group=GRP_MP,
     tooltip="Market close time in HH:MM format (UTC-adjusted). Zone growth is calculated relative to this time.")
max_pain_grow_window = input.int(90,       "Growth Window (minutes)",    group=GRP_MP, minval=10, maxval=240,
     tooltip="How many minutes before close the zone begins expanding.")
max_pain_grow_max    = input.float(5.0,    "Max Growth Multiplier",      group=GRP_MP, minval=1.0, maxval=5.0, step=0.5,
     tooltip="Maximum zone width multiplier at close. 5.0 = zone can grow up to 5× its base width.")




// ════════════════════════════════════════════════════════════════════
// TIME UTILITIES
// ════════════════════════════════════════════════════════════════════

// Parse a UTC time string into a unix timestamp.
// Supported formats:
//   "HH:MM"                    (backward-compatible, assumes today UTC)
//   "YYYY-MM-DD HH:MMZ"        (preferred)
//   "YYYY-MM-DDTHH:MMZ"        (also accepted)
// Returns [timestamp_ms, has_full_date].
parse_utc_timestamp(time_str) =>
    ts = int(na)
    has_full_date = false
    t = str.trim(time_str)

    if str.length(t) > 0
        norm = str.replace_all(t, "T", " ")
        norm := str.replace_all(norm, "Z", "")

        // Full datetime path: YYYY-MM-DD HH:MM
        if str.contains(norm, "-") and str.contains(norm, " ") and str.contains(norm, ":")
            dt_parts = str.split(norm, " ")
            if array.size(dt_parts) >= 2
                d_part = str.trim(array.get(dt_parts, 0))
                t_part = str.trim(array.get(dt_parts, 1))
                d_arr  = str.split(d_part, "-")
                hm_arr = str.split(t_part, ":")
                if array.size(d_arr) == 3 and array.size(hm_arr) == 2
                    yy = str.tonumber(str.trim(array.get(d_arr, 0)))
                    mo = str.tonumber(str.trim(array.get(d_arr, 1)))
                    dd = str.tonumber(str.trim(array.get(d_arr, 2)))
                    hh = str.tonumber(str.trim(array.get(hm_arr, 0)))
                    mm = str.tonumber(str.trim(array.get(hm_arr, 1)))
                    if not na(yy) and not na(mo) and not na(dd) and not na(hh) and not na(mm)
                        ts := timestamp("UTC", int(yy), int(mo), int(dd), int(hh), int(mm), 0)
                        has_full_date := true

        // Legacy path: HH:MM (assume today's UTC date)
        else if str.contains(norm, ":")
            hm_arr = str.split(norm, ":")
            if array.size(hm_arr) == 2
                hh = str.tonumber(str.trim(array.get(hm_arr, 0)))
                mm = str.tonumber(str.trim(array.get(hm_arr, 1)))
                if not na(hh) and not na(mm)
                    now = timenow
                    ts := timestamp("UTC",
                         year(now, "UTC"), month(now, "UTC"), dayofmonth(now, "UTC"),
                         int(hh), int(mm), 0)

    [ts, has_full_date]

// Convert a "HH:MM" UTC string to a local time string using the specified
// timezone string (IANA ID or "Exchange"). Uses str.format_time so leap-seconds
// and daylight savings formatting are governed by Pine. Returns the original
// string unchanged on any parse failure.
utc_to_local(time_str, tz_string) =>
    result = time_str
    [ts, has_full_date] = parse_utc_timestamp(time_str)
    if not na(ts)
        // Use the provided timezone, falling back to Exchange timezone if requested
        _tz = tz_string == "Exchange" ? syminfo.timezone : tz_string
        _fmt = has_full_date ? "yyyy-MM-dd HH:mm" : "HH:mm"
        result := str.format_time(ts, _fmt, _tz)
    result


// ════════════════════════════════════════════════════════════════════
// PARSING
// ════════════════════════════════════════════════════════════════════

// Extract the value for a given key from a parsed line array.
// Splits only on the FIRST colon so "Large Gamma: 5795:0.85" works correctly —
// the key is parts[0], the value is parts[1:] rejoined with ":".
get_value(lines, target) =>
    val = ""
    tgt = str.lower(str.trim(target))
    n = array.size(lines)
    if n > 0
        for i = 0 to n - 1
            ln = str.trim(array.get(lines, i))
            if str.length(ln) > 0 and str.contains(ln, ":")
                parts = str.split(ln, ":")
                if array.size(parts) > 0
                    k = str.lower(str.trim(array.get(parts, 0)))
                    if k == tgt
                        rest = array.new<string>()
                        if array.size(parts) > 1
                            for j = 1 to array.size(parts) - 1
                                array.push(rest, array.get(parts, j))
                        val := str.trim(array.join(rest, ":"))
    val

// Resolve a field from two parsed-line arrays: user value wins if non-empty,
// otherwise returns empty.
resolve_value(user_lines, default_lines, target) =>
    v = get_value(user_lines, target)
    str.length(v) > 0 ? v : get_value(default_lines, target)

// Trim and parse a single price string; returns na if empty/invalid.
// Handles both plain "6600" and ranked "6600:100:2:315" formats (takes first field).
pnum(s) =>
    t = str.trim(s)
    if str.length(t) == 0
        float(na)
    else
        _parts = str.split(t, ":")
        str.tonumber(str.trim(array.get(_parts, 0)))

// Format an integer GEX magnitude (millions) as "$380M" or "$1.2B".
format_magnitude(m) =>
    m >= 1000 ? "$" + str.tostring(m / 1000.0, "#.#") + "B" : "$" + str.tostring(m) + "M"

// Parse a multi-entry list where each item is one of:
//   "price"
//   "price:strength"
//   "price:strength:volResilience"
//   "price:strength:volResilience:magnitude"
// Strength (0–100) is optional; omitting means full strength (100).
// volResilience (-100 to +100) is optional; stored as a float in [-1, 1].
// magnitude (integer millions) is optional; appended to labels when show_gex_magnitude is on.
// Applies a minimum strength threshold and a max count cap before building labels.
// Returns [prices, labels, strengths, vol_resiliences] arrays.
parse_ranked_levels(s, base_label, min_strength_pct, max_levels) =>
    prices         = array.new<float>()
    labels         = array.new<string>()
    strengths      = array.new<float>()
    vol_resiliences = array.new<float>()
    if str.length(str.trim(s)) > 0
        pairs = str.split(s, ",")
        vp  = array.new<float>()
        vs  = array.new<float>()
        vvr = array.new<float>()
        vmag = array.new<float>()
        if array.size(pairs) > 0
            for i = 0 to array.size(pairs) - 1
                pair  = str.trim(array.get(pairs, i))
                parts = str.split(pair, ":")
                p     = pnum(array.get(parts, 0))
                if not na(p)
                    raw_strength = array.size(parts) > 1 ? pnum(array.get(parts, 1)) : na
                    strength = na(raw_strength) ? 1.0 : math.max(0.0, math.min(1.0, raw_strength / 100.0))
                    if strength >= min_strength_pct / 100.0
                        raw_vr  = array.size(parts) > 2 ? pnum(array.get(parts, 2)) : na
                        raw_mag = array.size(parts) > 3 ? pnum(array.get(parts, 3)) : na
                        array.push(vp,   p)
                        array.push(vs,   strength)
                        array.push(vvr,  na(raw_vr) ? float(na) : raw_vr / 100.0)
                        array.push(vmag, na(raw_mag) ? float(na) : raw_mag)

        if array.size(vp) > max_levels
            trimmed_prices    = array.new<float>()
            trimmed_strengths = array.new<float>()
            trimmed_vr        = array.new<float>()
            trimmed_mag       = array.new<float>()
            for i = 0 to max_levels - 1
                array.push(trimmed_prices,    array.get(vp,   i))
                array.push(trimmed_strengths, array.get(vs,   i))
                array.push(trimmed_vr,        array.get(vvr,  i))
                array.push(trimmed_mag,       array.get(vmag, i))
            vp   := trimmed_prices
            vs   := trimmed_strengths
            vvr  := trimmed_vr
            vmag := trimmed_mag

        n = array.size(vp)
        if n > 0
            for i = 0 to n - 1
                p    = array.get(vp,   i)
                sval = array.get(vs,   i)
                vr   = array.get(vvr,  i)
                mag  = array.get(vmag, i)
                array.push(prices,          p)
                array.push(strengths,       sval)
                array.push(vol_resiliences, vr)
                lbl  = n > 1 ? base_label + " " + str.tostring(i + 1) : base_label
                if sval > 0.0 and sval < 1.0
                    lbl := lbl + " (" + str.tostring(math.round(sval * 100)) + "%)"
                if show_gex_magnitude and not na(mag)
                    lbl := lbl + " " + format_magnitude(math.round(mag))
                if show_vol_resilience and not na(vr) and math.abs(vr) > 0.1
                    lbl := lbl + (vr > 0 ? " ↑" : " ↓")
                array.push(labels, lbl)
    [prices, labels, strengths, vol_resiliences]

// Parse underlying: "661.43" or "661.43 @ 16:00"
// Returns [price, time_string].
parse_underlying(s) =>
    u_price = float(na)
    u_time  = ""
    t = str.trim(s)
    if str.length(t) > 0
        if str.contains(t, "@")
            parts   = str.split(t, "@")
            u_price := pnum(array.get(parts, 0))
            u_time  := str.trim(array.get(parts, 1))
        else
            u_price := pnum(t)
    [u_price, u_time]


// ════════════════════════════════════════════════════════════════════
// DYNAMIC AUTO BASIS
// Evaluated globally to provide dynamic basis shift for ES/NQ.
// ════════════════════════════════════════════════════════════════════

_spx_close = request.security("SP:SPX", timeframe.period, close[1])
_ndx_close = request.security("NASDAQ:NDX", timeframe.period, close[1])

_is_es = syminfo.root == "ES" or syminfo.root == "MES"
_is_nq = syminfo.root == "NQ" or syminfo.root == "MNQ"

_dynamic_basis = float(na)
if _is_es and not na(_spx_close)
    _dynamic_basis := close[1] - _spx_close
else if _is_nq and not na(_ndx_close)
    _dynamic_basis := close[1] - _ndx_close


// ════════════════════════════════════════════════════════════════════
// REGIME LEVEL CACHE
// Parsed once on the first bar so the per-bar bgcolor can use it
// without re-running the full parse every bar.
// ════════════════════════════════════════════════════════════════════

var float _cached_regime_lv = na
var float _rc_zg = na
var float _rc_bs = na

if barstate.isfirst
    _rc_u   = str.split(in_data, "\n")
    _rc_d   = array.new<string>()
    _rc_zg_raw  = str.trim(resolve_value(_rc_u, _rc_d, "Zero Gamma"))
    _rc_zg_clean = str.length(_rc_zg_raw) > 0 and str.substring(_rc_zg_raw, str.length(_rc_zg_raw) - 1, str.length(_rc_zg_raw)) == "?" ? str.substring(_rc_zg_raw, 0, str.length(_rc_zg_raw) - 1) : _rc_zg_raw
    _rc_zg  := pnum(_rc_zg_clean)
    _rc_bs  := pnum(resolve_value(_rc_u, _rc_d, "Basis Shift"))

_rc_sh = 0.0
if in_basis_shift_mode == "Prior Bar"
    if not na(_dynamic_basis)
        _rc_sh := _dynamic_basis
    else if apply_basis_shift and not na(_rc_bs)
        _rc_sh := _rc_bs
else if apply_basis_shift
    _rc_sh := not na(_rc_bs) ? _rc_bs : 0.0

_cached_regime_lv := not na(_rc_zg) ? _rc_zg + _rc_sh : float(na)

// Per-bar regime background tint
bgcolor(
     show_regime_bg and not na(_cached_regime_lv) ?
         (close > _cached_regime_lv ? color.new(regime_bull_col, 100 - regime_bg_opac) : color.new(regime_bear_col, 100 - regime_bg_opac)) :
         na,
     title="Regime Background")


// ════════════════════════════════════════════════════════════════════
// DRAWING
// ════════════════════════════════════════════════════════════════════

// Draw a horizontal line + optional floating label + optional zone box.
// eff_wid:         computed line width (strength-scaled or fixed)
// eff_line_opac:   line opacity 0–100
// eff_zone_opac:   zone fill opacity 0–100 (proximity-boosted or normal)
// eff_zone_pts:  zone half-height in points (max-pain-scaled or normal)
// Returns [line, label, box] — label/box may be na if disabled.
draw_hlevel(price, col, lbl, lstyle, eff_wid, eff_line_opac, eff_zone_opac, eff_zone_pts) =>
    _line_col = color.new(col, 100 - eff_line_opac)
    ln = line.new(bar_index, price, bar_index + 1, price,
         extend=extend.both, color=_line_col, width=eff_wid, style=lstyle)
    label lb = na
    box   bx = na
    if show_labels != "Off" and str.length(lbl) > 0
        txt   = show_labels == "Price" ? str.tostring(price) :
             show_labels == "Level & Price" ? lbl + " (" + str.tostring(price) + ")" :
             lbl
        
        _x_pos = int(bar_index + lbl_offset)
        _xloc  = xloc.bar_index
        _style = label.style_label_left
        _align = text.align_left
        _y_pos = price
        _txt   = txt
        
        _bar_ms = int(time - nz(time[1], time - 60000))

        if lbl_align == "Left"
            // Anchor at left edge + offset; text extends rightward
            _x_pos := int(chart.left_visible_bar_time) + int(lbl_offset * _bar_ms)
            _xloc  := xloc.bar_time
            _style := label.style_label_left
            _align := text.align_left
            _txt   := lbl_pos == "Below" ? "\n" + txt : txt + "\n"
        else
            // Anchor at last bar + offset; text extends rightward
            _x_pos := int(bar_index + lbl_offset)
            _style := label.style_label_left
            _align := text.align_left
            _txt   := lbl_pos == "Below" ? "\n" + txt : txt + "\n"

        lb := label.new(
            _x_pos, _y_pos,
            text      = _txt,
            xloc      = _xloc,
            yloc      = yloc.price,
            color     = color.new(color.black, 100),
            textcolor = col,
            style     = _style,
            textalign = _align,
            size      = lbl_size
            )
    if show_zones
        bx := box.new(bar_index, price + eff_zone_pts, bar_index + 1, price - eff_zone_pts,
             border_color = color.new(col, 100),
             bgcolor      = color.new(col, 100 - eff_zone_opac),
             extend       = extend.both)
    [ln, lb, bx]

// Add line, label, and box to their respective tracking arrays.
add_level(ln, lb, bx, lns, lbs, bxs) =>
    array.push(lns, ln)
    if not na(lb)
        array.push(lbs, lb)
    if not na(bx)
        array.push(bxs, bx)

// Find index of a price in the collected levels; returns -1 if not found.
find_lv_idx(prices, target) =>
    result = -1
    n = array.size(prices)
    if n > 0
        for i = 0 to n - 1
            if array.get(prices, i) == target
                result := i
    result

// Collect a level into parallel arrays, merging label if price already exists.
// Color and style of the first entry at a given price take precedence.
// strength:   0.0–1.0 relative strength (used for line width scaling)
// is_maxpain: marks the level for max-pain zone height expansion near close
push_level(prices, labels, colors, styles, strengths, is_maxpains,
           p, lbl, col, lstyle, strength, is_maxpain) =>
    idx = find_lv_idx(prices, p)
    if idx < 0
        array.push(prices,     p)
        array.push(labels,     lbl)
        array.push(colors,     col)
        array.push(styles,     lstyle)
        array.push(strengths,  strength)
        array.push(is_maxpains, is_maxpain)
    else
        cur = array.get(labels, idx)
        if not str.contains(cur, lbl)
            array.set(labels, idx, cur + " / " + lbl)

// Map HUD position string to Pine table position constant.
hud_table_pos(s) =>
    s == "Top Left"    ? position.top_left  :
     s == "Top Right"   ? position.top_right :
     s == "Bottom Left" ? position.bottom_left :
     position.bottom_right

// Map string style to Pine line style
get_style(s) =>
    s == "Dashed" ? line.style_dashed :
     s == "Dotted" ? line.style_dotted :
     line.style_solid

// Format name based on brevity preference
format_name(nm, fmt) =>
    result = nm
    if fmt == "Abbrev"
        result := nm == "Call Wall" ? "CW" : nm == "Put Wall" ? "PW" : nm == "Absolute Gamma" ? "AG" : nm == "Key Gamma Strike" ? "KGS" : nm == "Large Gamma" ? "LG" : nm == "Vanna Inflection" ? "VI" : nm == "Speed Trap" ? "ST" : nm == "Max Pain" ? "MP" : nm == "Zero Gamma" ? "ZG" : nm == "Gamma Transition Lower" ? "TL" : nm == "Gamma Transition Upper" ? "TU" : nm == "Expected Move Upper" ? "EMU" : nm == "Expected Move Lower" ? "EML" : nm == "Extreme Move Upper" ? "XMU" : nm == "Extreme Move Lower" ? "XML" : nm == "Implied Move Upper" ? "IMU" : nm == "Implied Move Lower" ? "IML" : nm == "Implied Move 2SD Upper" ? "IM2U" : nm == "Implied Move 2SD Lower" ? "IM2L" : nm == "Underlying" ? "Spot" : nm == "Open Price" ? "Open" : nm
    else if fmt == "Short"
        result := nm == "Call Wall" ? "C Wall" : nm == "Put Wall" ? "P Wall" : nm == "Absolute Gamma" ? "Abs G" : nm == "Key Gamma Strike" ? "Key G" : nm == "Large Gamma" ? "Lrg G" : nm == "Vanna Inflection" ? "Vanna" : nm == "Speed Trap" ? "Trap" : nm == "Max Pain" ? "Pain" : nm == "Zero Gamma" ? "Zero G" : nm == "Gamma Transition Lower" ? "Trans Lo" : nm == "Gamma Transition Upper" ? "Trans Hi" : nm == "Expected Move Upper" ? "Exp Hi" : nm == "Expected Move Lower" ? "Exp Lo" : nm == "Extreme Move Upper" ? "Ext Hi" : nm == "Extreme Move Lower" ? "Ext Lo" : nm == "Implied Move Upper" ? "Imp Hi" : nm == "Implied Move Lower" ? "Imp Lo" : nm == "Implied Move 2SD Upper" ? "Imp 2SD Hi" : nm == "Implied Move 2SD Lower" ? "Imp 2SD Lo" : nm == "Underlying" ? "Spot" : nm == "Open Price" ? "Open" : nm
    result


// ════════════════════════════════════════════════════════════════════
// MAIN — redraws on every last-bar update
// ════════════════════════════════════════════════════════════════════

var all_lines  = array.new<line>()
var all_labels = array.new<label>()
var all_boxes  = array.new<box>()
var table hud_table = na

// — Price-axis plot values (var persists across bars; set inside barstate.islast) —
var float _pa_call_wall_1  = na
var float _pa_call_wall_2  = na
var float _pa_call_wall_3  = na
var float _pa_call_wall_4  = na
var float _pa_call_wall_5  = na
var float _pa_call_wall_6  = na
var float _pa_call_wall_7  = na
var float _pa_call_wall_8  = na
var float _pa_call_wall_9  = na
var float _pa_call_wall_10 = na

var float _pa_put_wall_1   = na
var float _pa_put_wall_2   = na
var float _pa_put_wall_3   = na
var float _pa_put_wall_4   = na
var float _pa_put_wall_5   = na
var float _pa_put_wall_6   = na
var float _pa_put_wall_7   = na
var float _pa_put_wall_8   = na
var float _pa_put_wall_9   = na
var float _pa_put_wall_10  = na

var float _pa_abs_gamma_1  = na
var float _pa_abs_gamma_2  = na
var float _pa_abs_gamma_3  = na
var float _pa_abs_gamma_4  = na
var float _pa_abs_gamma_5  = na
var float _pa_abs_gamma_6  = na
var float _pa_abs_gamma_7  = na
var float _pa_abs_gamma_8  = na
var float _pa_abs_gamma_9  = na
var float _pa_abs_gamma_10 = na

var float _pa_large_gamma_1  = na
var float _pa_large_gamma_2  = na
var float _pa_large_gamma_3  = na
var float _pa_large_gamma_4  = na
var float _pa_large_gamma_5  = na
var float _pa_large_gamma_6  = na
var float _pa_large_gamma_7  = na
var float _pa_large_gamma_8  = na
var float _pa_large_gamma_9  = na
var float _pa_large_gamma_10 = na

var float _pa_key_gamma    = na
var float _pa_vanna         = na
var float _pa_speed_trap    = na
var float _pa_max_pain      = na
var float _pa_zero_gamma    = na
var float _pa_trans_lower   = na
var float _pa_trans_upper   = na
var float _pa_exp_upper     = na
var float _pa_exp_lower     = na
var float _pa_ext_upper     = na
var float _pa_ext_lower     = na
var float _pa_imp_upper     = na
var float _pa_imp_lower     = na
var float _pa_imp2sd_upper  = na
var float _pa_imp2sd_lower  = na
var float _pa_underlying    = na
var float _pa_open          = na

if barstate.islast

    // — Resolve data source —
    user_parsed    = str.split(in_data, "\n")
    default_parsed = array.new<string>()

    // — Parse data into named values —
    in_call_walls   = resolve_value(user_parsed, default_parsed, "Call Walls")
    in_put_walls    = resolve_value(user_parsed, default_parsed, "Put Walls")
    in_abs_gamma    = resolve_value(user_parsed, default_parsed, "Absolute Gamma")
    in_key_gamma    = resolve_value(user_parsed, default_parsed, "Key Gamma Strike")
    in_large_gamma  = resolve_value(user_parsed, default_parsed, "Large Gamma")
    in_vanna        = resolve_value(user_parsed, default_parsed, "Vanna Inflection")
    in_speed_trap   = resolve_value(user_parsed, default_parsed, "Speed Trap")
    in_max_pain     = resolve_value(user_parsed, default_parsed, "Max Pain")
    in_zero_gamma   = resolve_value(user_parsed, default_parsed, "Zero Gamma")
    in_trans_lower  = resolve_value(user_parsed, default_parsed, "Transition Lower")
    in_trans_upper  = resolve_value(user_parsed, default_parsed, "Transition Upper")
    in_exp_upper    = resolve_value(user_parsed, default_parsed, "Expected Move Upper")
    in_exp_lower    = resolve_value(user_parsed, default_parsed, "Expected Move Lower")
    in_ext_upper    = resolve_value(user_parsed, default_parsed, "Extreme Move Upper")
    in_ext_lower    = resolve_value(user_parsed, default_parsed, "Extreme Move Lower")
    in_imp_upper    = resolve_value(user_parsed, default_parsed, "Implied Move Upper")
    in_imp_lower    = resolve_value(user_parsed, default_parsed, "Implied Move Lower")
    in_imp2sd_upper = resolve_value(user_parsed, default_parsed, "Implied Move 2SD Upper")
    in_imp2sd_lower = resolve_value(user_parsed, default_parsed, "Implied Move 2SD Lower")
    in_underlying   = resolve_value(user_parsed, default_parsed, "Underlying")
    in_open         = resolve_value(user_parsed, default_parsed, "Open Price")
    in_basis_shift  = resolve_value(user_parsed, default_parsed, "Basis Shift")

    // Default template has keys but empty values. Detect whether the user has
    // provided any actual level payload so HUD can show onboarding text.
    has_level_input =
         str.length(str.trim(in_call_walls))   > 0 or
         str.length(str.trim(in_put_walls))    > 0 or
         str.length(str.trim(in_abs_gamma))    > 0 or
         str.length(str.trim(in_key_gamma))    > 0 or
         str.length(str.trim(in_large_gamma))  > 0 or
         str.length(str.trim(in_vanna))        > 0 or
         str.length(str.trim(in_speed_trap))   > 0 or
         str.length(str.trim(in_max_pain))     > 0 or
         str.length(str.trim(in_zero_gamma))   > 0 or
         str.length(str.trim(in_trans_lower))  > 0 or
         str.length(str.trim(in_trans_upper))  > 0 or
         str.length(str.trim(in_exp_upper))    > 0 or
         str.length(str.trim(in_exp_lower))    > 0 or
         str.length(str.trim(in_ext_upper))    > 0 or
         str.length(str.trim(in_ext_lower))    > 0 or
         str.length(str.trim(in_imp_upper))    > 0 or
         str.length(str.trim(in_imp_lower))    > 0 or
         str.length(str.trim(in_imp2sd_upper)) > 0 or
         str.length(str.trim(in_imp2sd_lower)) > 0 or
         str.length(str.trim(in_underlying))   > 0 or
         str.length(str.trim(in_open))         > 0 or
         str.length(str.trim(in_basis_shift))  > 0

    // Stale-data detection (> 24h) from full UTC datetimes in Underlying/Open.
    [u_raw_price, u_raw_time] = parse_underlying(in_underlying)
    [o_raw_price, o_raw_time] = parse_underlying(in_open)
    [u_raw_ts, u_has_date]    = parse_utc_timestamp(u_raw_time)
    [o_raw_ts, o_has_date]    = parse_utc_timestamp(o_raw_time)

    _stale_cutoff_ms = 24.0 * 60.0 * 60.0 * 1000.0
    _u_is_stale = u_has_date and not na(u_raw_ts) and timenow > u_raw_ts and (timenow - u_raw_ts) > _stale_cutoff_ms
    _o_is_stale = o_has_date and not na(o_raw_ts) and timenow > o_raw_ts and (timenow - o_raw_ts) > _stale_cutoff_ms
    _show_stale_warning = _u_is_stale or _o_is_stale

    // — Resolve basis shift: spot → futures offset —
    raw_shift   = pnum(in_basis_shift)
    
    basis_shift = 0.0
    if in_basis_shift_mode == "Prior Bar"
        if not na(_dynamic_basis)
            basis_shift := _dynamic_basis
        else if apply_basis_shift and not na(raw_shift)
            basis_shift := raw_shift
    else if apply_basis_shift
        basis_shift := not na(raw_shift) ? raw_shift : 0.0

    // — Parse Zero Gamma: strip trailing "?" which signals a candidate flip
    //   (no confirmed zero-crossing; pipeline reports the least-negative strike) —
    _zg_trimmed      = str.trim(in_zero_gamma)
    _zg_is_candidate = str.length(_zg_trimmed) > 0 and str.substring(_zg_trimmed, str.length(_zg_trimmed) - 1, str.length(_zg_trimmed)) == "?"
    _zg_clean        = _zg_is_candidate ? str.substring(_zg_trimmed, 0, str.length(_zg_trimmed) - 1) : _zg_trimmed

    // — Keep regime cache in sync with the full parse —
    _zg_parsed        = pnum(_zg_clean)
    _cached_regime_lv := not na(_zg_parsed) ? _zg_parsed + basis_shift : float(na)

    // — Max Pain zone multiplier: expands linearly in the final N minutes before close —
    mp_mult = 1.0
    if max_pain_grow and show_max_pain
        _mp_parts    = str.split(max_pain_close_time, ":")
        _mp_h        = array.size(_mp_parts) >= 1 ? math.round(nz(str.tonumber(array.get(_mp_parts, 0)), 21.0)) : 21
        _mp_m        = array.size(_mp_parts) >= 2 ? math.round(nz(str.tonumber(array.get(_mp_parts, 1)),  0.0)) :  0
        _now_ts      = timenow
        _close_ts    = timestamp("UTC",
             year(_now_ts, "UTC"), month(_now_ts, "UTC"), dayofmonth(_now_ts, "UTC"),
             _mp_h, _mp_m, 0)
        _mins_left   = (_close_ts - _now_ts) / 60000.0
        if _mins_left >= 0 and _mins_left <= max_pain_grow_window
            _progress = 1.0 - (_mins_left / max_pain_grow_window)
            mp_mult  := 1.0 + _progress * (max_pain_grow_max - 1.0)

    // — 1-sigma for HUD distance display (range is shift-independent) —
    _exp_u    = pnum(in_exp_upper)
    _exp_l    = pnum(in_exp_lower)
    one_sigma = not na(_exp_u) and not na(_exp_l) ? (_exp_u - _exp_l) / 2.0 : float(na)

    // — Clear previous drawings —
    for ln in all_lines
        line.delete(ln)
    for lb in all_labels
        label.delete(lb)
    for bx in all_boxes
        box.delete(bx)
    array.clear(all_lines)
    array.clear(all_labels)
    array.clear(all_boxes)

    // — Gamma Transition Zone (shaded background band) —
    // [EXPERIMENTAL] This zone represents the 'churn' area where net gamma is mixed.
    // The calculation is currently in beta and should be used as a secondary visual buffer.
    t_lo = pnum(in_trans_lower)
    t_hi = pnum(in_trans_upper)
    if show_transition and not na(t_lo) and not na(t_hi)
        lo = math.min(t_lo, t_hi)
        hi = math.max(t_lo, t_hi)
        bx = box.new(bar_index, hi, bar_index + 1, lo,
             border_color = color.new(col_zgamma, 100),
             bgcolor      = color.new(col_zgamma, 100 - zone_opac_max),
             extend       = extend.both)
        array.push(all_boxes, bx)

    // — Parallel level arrays (price, label, color, style, strength, is_maxpain) —
    lv_prices    = array.new<float>()
    lv_labels    = array.new<string>()
    lv_colors    = array.new<color>()
    lv_styles    = array.new<string>()
    lv_strengths = array.new<float>()
    lv_is_mp     = array.new<bool>()

    // HUD: capture call/put wall prices (with basis shift already applied)
    hud_call_walls = array.new<float>()
    hud_put_walls  = array.new<float>()

    // — Call Walls —
    if show_walls
        [cw_prices, cw_labels, cw_strengths, _cw_vr] = parse_ranked_levels(in_call_walls, format_name("Call Wall", lbl_format), math.max(min_strength, min_call_wall_strength), max_call_wall_levels)
        n = array.size(cw_prices)
        if n > 0
            for i = 0 to n - 1
                p   = array.get(cw_prices, i)
                lbl = array.get(cw_labels, i)
                str_v = array.get(cw_strengths, i)
                push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                     p, lbl, col_resist, get_style(line_style_walls), str_v, false)
                array.push(hud_call_walls, p + basis_shift)

    // — Put Walls —
    if show_walls
        [pw_prices, pw_labels, pw_strengths, _pw_vr] = parse_ranked_levels(in_put_walls, format_name("Put Wall", lbl_format), math.max(min_strength, min_put_wall_strength), max_put_wall_levels)
        n = array.size(pw_prices)
        if n > 0
            for i = 0 to n - 1
                p   = array.get(pw_prices, i)
                lbl = array.get(pw_labels, i)
                str_v = array.get(pw_strengths, i)
                push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                     p, lbl, col_support, get_style(line_style_walls), str_v, false)
                array.push(hud_put_walls, p + basis_shift)

    // — Absolute Gamma —
    if show_key_gamma
        [ag_prices, ag_labels, ag_strengths, _ag_vr] = parse_ranked_levels(in_abs_gamma, format_name("Absolute Gamma", lbl_format), math.max(min_strength, min_abs_gamma_strength), max_abs_gamma_levels)
        if array.size(ag_prices) > 0
            for i = 0 to array.size(ag_prices) - 1
                push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                     array.get(ag_prices, i), array.get(ag_labels, i), col_resist, get_style(line_style_gamma),
                     array.get(ag_strengths, i), false)

    // — Key Gamma Strike —
    if show_key_gamma
        p = pnum(in_key_gamma)
        if not na(p)
            push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                 p, format_name("Key Gamma Strike", lbl_format), col_resist, get_style(line_style_gamma), 1.0, false)

    // — Large Gamma (ranked, with optional strength %) —
    if show_large_gamma
        [lg_prices, lg_labels, lg_strengths, _lg_vr] = parse_ranked_levels(in_large_gamma, format_name("Large Gamma", lbl_format), math.max(min_strength, min_lgamma_strength), max_lgamma_levels)
        if array.size(lg_prices) > 0
            for i = 0 to array.size(lg_prices) - 1
                push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                     array.get(lg_prices, i), array.get(lg_labels, i), col_lgamma, get_style(line_style_gamma),
                     array.get(lg_strengths, i), false)

    // — Vanna Inflection —
    if show_vanna
        p = pnum(in_vanna)
        if not na(p)
            push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                 p, format_name("Vanna Inflection", lbl_format), col_vanna, line.style_dashed, -1.0, false)

    // — Speed Trap —
    if show_speed_trap
        p = pnum(in_speed_trap)
        if not na(p)
            push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                 p, format_name("Speed Trap", lbl_format), col_strap, line.style_dashed, -1.0, false)

    // — Max Pain —
    if show_max_pain
        p = pnum(in_max_pain)
        if not na(p)
            push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                 p, format_name("Max Pain", lbl_format), col_maxpain, line.style_dashed, -1.0, true)

    // — Zero Gamma —
    if show_zero_gamma
        p = pnum(_zg_clean)
        if not na(p)
            _zg_lbl   = _zg_is_candidate ? "Flip Candidate" : format_name("Zero Gamma", lbl_format)
            _zg_style = _zg_is_candidate ? line.style_dotted : get_style(line_style_zero)
            push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                 p, _zg_lbl, col_zgamma, _zg_style, -1.0, false)

    // — Transition Bounds —
    if show_transition
        if not na(t_lo)
            push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                 t_lo, format_name("Gamma Transition Lower", lbl_format), col_zgamma, get_style(line_style_zero), -1.0, false)
        if not na(t_hi)
            push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                 t_hi, format_name("Gamma Transition Upper", lbl_format), col_zgamma, get_style(line_style_zero), -1.0, false)

    // — Max Total Levels Cap: Sort strike levels by proximity to current price and trim —
    n_strikes = array.size(lv_prices)
    if n_strikes > max_total_levels
        // Simple bubble sort by distance (efficient enough for small N like 20-50)
        for i = 0 to n_strikes - 2
            for j = 0 to n_strikes - i - 2
                d1 = math.abs(close - array.get(lv_prices, j))
                d2 = math.abs(close - array.get(lv_prices, j + 1))
                if d1 > d2
                    // Swap all parallel arrays
                    array.set(lv_prices,    j, array.get(lv_prices,    j + 1)), array.set(lv_prices,    j + 1, array.get(lv_prices,    j))
                    array.set(lv_labels,    j, array.get(lv_labels,    j + 1)), array.set(lv_labels,    j + 1, array.get(lv_labels,    j))
                    array.set(lv_colors,    j, array.get(lv_colors,    j + 1)), array.set(lv_colors,    j + 1, array.get(lv_colors,    j))
                    array.set(lv_styles,    j, array.get(lv_styles,    j + 1)), array.set(lv_styles,    j + 1, array.get(lv_styles,    j))
                    array.set(lv_strengths, j, array.get(lv_strengths, j + 1)), array.set(lv_strengths, j + 1, array.get(lv_strengths, j))
                    array.set(lv_is_mp,     j, array.get(lv_is_mp,     j + 1)), array.set(lv_is_mp,     j + 1, array.get(lv_is_mp,     j))
        
        // Trim arrays to max_total_levels
        while array.size(lv_prices) > max_total_levels
            array.pop(lv_prices),    array.pop(lv_labels)
            array.pop(lv_colors),    array.pop(lv_styles)
            array.pop(lv_strengths), array.pop(lv_is_mp)

    // — Expected Move —
    if show_exp_move
        p = pnum(in_exp_upper)
        if not na(p)
            push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                 p, format_name("Expected Move Upper", lbl_format), col_exp, get_style(line_style_moves), -1.0, false)
        p := pnum(in_exp_lower)
        if not na(p)
            push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                 p, format_name("Expected Move Lower", lbl_format), col_exp, get_style(line_style_moves), -1.0, false)

    // — Extreme Move —
    if show_ext_move
        p = pnum(in_ext_upper)
        if not na(p)
            push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                 p, format_name("Extreme Move Upper", lbl_format), col_ext, get_style(line_style_moves), -1.0, false)
        p := pnum(in_ext_lower)
        if not na(p)
            push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                 p, format_name("Extreme Move Lower", lbl_format), col_ext, get_style(line_style_moves), -1.0, false)

    // — Implied Move —
    if show_imp_move
        p = pnum(in_imp_upper)
        if not na(p)
            push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                 p, format_name("Implied Move Upper", lbl_format), col_imp, get_style(line_style_moves), -1.0, false)
        p := pnum(in_imp_lower)
        if not na(p)
            push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                 p, format_name("Implied Move Lower", lbl_format), col_imp, get_style(line_style_moves), -1.0, false)

    // — Implied Move 2SD —
    if show_imp_2sd
        p = pnum(in_imp2sd_upper)
        if not na(p)
            push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                 p, format_name("Implied Move 2SD Upper", lbl_format), col_imp2sd, get_style(line_style_moves), -1.0, false)
        p := pnum(in_imp2sd_lower)
        if not na(p)
            push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                 p, format_name("Implied Move 2SD Lower", lbl_format), col_imp2sd, get_style(line_style_moves), -1.0, false)

    // — Underlying Price —
    if show_underlying
        [u_price, u_time] = parse_underlying(in_underlying)
        if not na(u_price)
            u_time_local = utc_to_local(u_time, display_tz)
            u_base       = format_name("Underlying", lbl_format)
            u_lbl = str.length(u_time) > 0
                 ? "Updated at " + u_time_local + " (" + display_tz_label + ") — " + str.tostring(u_price)
                 : u_base + " (" + str.tostring(u_price) + ")"
            push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                 u_price, u_lbl, col_under, line.style_dashed, -1.0, false)

    // — Open Price —
    if show_open
        [o_price, o_time] = parse_underlying(in_open)
        if not na(o_price)
            o_time_local = utc_to_local(o_time, display_tz)
            o_base       = format_name("Open Price", lbl_format)
            o_lbl = str.length(o_time) > 0
                 ? "Open at " + o_time_local + " (" + display_tz_label + ") — " + str.tostring(o_price)
                 : o_base + " (" + str.tostring(o_price) + ")"
            push_level(lv_prices, lv_labels, lv_colors, lv_styles, lv_strengths, lv_is_mp,
                 o_price, o_lbl, col_open, line.style_dashed, -1.0, false)

    // — Apply basis shift: add offset to every collected price —
    if basis_shift != 0.0
        n_shift = array.size(lv_prices)
        if n_shift > 0
            for i = 0 to n_shift - 1
                array.set(lv_prices, i, array.get(lv_prices, i) + basis_shift)
        // Shift the gamma transition zone box too
        if show_transition and not na(t_lo) and not na(t_hi)
            lo_s = math.min(t_lo, t_hi) + basis_shift
            hi_s = math.max(t_lo, t_hi) + basis_shift
            if array.size(all_boxes) > 0
                box.delete(array.pop(all_boxes))
            bx_s = box.new(bar_index, hi_s, bar_index + 1, lo_s,
                 border_color = color.new(col_zgamma, 100),
                 bgcolor      = color.new(col_zgamma, 100 - zone_opac_max),
                 extend       = extend.both)
            array.push(all_boxes, bx_s)

    // — Price-axis plot values: set shifted prices for invisible plot() calls —
    if show_price_axis
        // Reset all to na first
        _pa_call_wall_1 := na, _pa_call_wall_2 := na, _pa_call_wall_3 := na, _pa_call_wall_4 := na, _pa_call_wall_5 := na
        _pa_call_wall_6 := na, _pa_call_wall_7 := na, _pa_call_wall_8 := na, _pa_call_wall_9 := na, _pa_call_wall_10 := na
        _pa_put_wall_1 := na,  _pa_put_wall_2 := na,  _pa_put_wall_3 := na,  _pa_put_wall_4 := na,  _pa_put_wall_5 := na
        _pa_put_wall_6 := na,  _pa_put_wall_7 := na,  _pa_put_wall_8 := na,  _pa_put_wall_9 := na,  _pa_put_wall_10 := na
        _pa_abs_gamma_1 := na, _pa_abs_gamma_2 := na, _pa_abs_gamma_3 := na, _pa_abs_gamma_4 := na, _pa_abs_gamma_5 := na
        _pa_abs_gamma_6 := na, _pa_abs_gamma_7 := na, _pa_abs_gamma_8 := na, _pa_abs_gamma_9 := na, _pa_abs_gamma_10 := na
        _pa_large_gamma_1 := na, _pa_large_gamma_2 := na, _pa_large_gamma_3 := na, _pa_large_gamma_4 := na, _pa_large_gamma_5 := na
        _pa_large_gamma_6 := na, _pa_large_gamma_7 := na, _pa_large_gamma_8 := na, _pa_large_gamma_9 := na, _pa_large_gamma_10 := na
        _pa_key_gamma := na, _pa_vanna := na, _pa_speed_trap := na, _pa_max_pain := na, _pa_zero_gamma := na
        _pa_trans_lower := na, _pa_trans_upper := na, _pa_exp_upper := na, _pa_exp_lower := na, _pa_ext_upper := na
        _pa_ext_lower := na, _pa_imp_upper := na, _pa_imp_lower := na, _pa_imp2sd_upper := na, _pa_imp2sd_lower := na
        _pa_underlying := na, _pa_open := na

        // Call Walls (up to 10)
        if show_walls
            [_pa_cw_p, _ign1, _ign2, _ign3] = parse_ranked_levels(in_call_walls, "CW", min_call_wall_strength, max_call_wall_levels)
            _n_cw = array.size(_pa_cw_p)
            if _n_cw > 0
                _pa_call_wall_1  := array.get(_pa_cw_p, 0) + basis_shift
                if _n_cw > 1
                    _pa_call_wall_2  := array.get(_pa_cw_p, 1) + basis_shift
                if _n_cw > 2
                    _pa_call_wall_3  := array.get(_pa_cw_p, 2) + basis_shift
                if _n_cw > 3
                    _pa_call_wall_4  := array.get(_pa_cw_p, 3) + basis_shift
                if _n_cw > 4
                    _pa_call_wall_5  := array.get(_pa_cw_p, 4) + basis_shift
                if _n_cw > 5
                    _pa_call_wall_6  := array.get(_pa_cw_p, 5) + basis_shift
                if _n_cw > 6
                    _pa_call_wall_7  := array.get(_pa_cw_p, 6) + basis_shift
                if _n_cw > 7
                    _pa_call_wall_8  := array.get(_pa_cw_p, 7) + basis_shift
                if _n_cw > 8
                    _pa_call_wall_9  := array.get(_pa_cw_p, 8) + basis_shift
                if _n_cw > 9
                    _pa_call_wall_10 := array.get(_pa_cw_p, 9) + basis_shift

        // Put Walls (up to 10)
        if show_walls
            [_pa_pw_p, _ign4, _ign5, _ign6] = parse_ranked_levels(in_put_walls, "PW", min_put_wall_strength, max_put_wall_levels)
            _n_pw = array.size(_pa_pw_p)
            if _n_pw > 0
                _pa_put_wall_1  := array.get(_pa_pw_p, 0) + basis_shift
                if _n_pw > 1
                    _pa_put_wall_2  := array.get(_pa_pw_p, 1) + basis_shift
                if _n_pw > 2
                    _pa_put_wall_3  := array.get(_pa_pw_p, 2) + basis_shift
                if _n_pw > 3
                    _pa_put_wall_4  := array.get(_pa_pw_p, 3) + basis_shift
                if _n_pw > 4
                    _pa_put_wall_5  := array.get(_pa_pw_p, 4) + basis_shift
                if _n_pw > 5
                    _pa_put_wall_6  := array.get(_pa_pw_p, 5) + basis_shift
                if _n_pw > 6
                    _pa_put_wall_7  := array.get(_pa_pw_p, 6) + basis_shift
                if _n_pw > 7
                    _pa_put_wall_8  := array.get(_pa_pw_p, 7) + basis_shift
                if _n_pw > 8
                    _pa_put_wall_9  := array.get(_pa_pw_p, 8) + basis_shift
                if _n_pw > 9
                    _pa_put_wall_10 := array.get(_pa_pw_p, 9) + basis_shift

        // Absolute Gamma (up to 10)
        if show_key_gamma
            [_pa_ag_p, _ign7, _ign8, _ign9] = parse_ranked_levels(in_abs_gamma, "AG", min_abs_gamma_strength, max_abs_gamma_levels)
            _n_ag = array.size(_pa_ag_p)
            if _n_ag > 0
                _pa_abs_gamma_1  := array.get(_pa_ag_p, 0) + basis_shift
                if _n_ag > 1
                    _pa_abs_gamma_2  := array.get(_pa_ag_p, 1) + basis_shift
                if _n_ag > 2
                    _pa_abs_gamma_3  := array.get(_pa_ag_p, 2) + basis_shift
                if _n_ag > 3
                    _pa_abs_gamma_4  := array.get(_pa_ag_p, 3) + basis_shift
                if _n_ag > 4
                    _pa_abs_gamma_5  := array.get(_pa_ag_p, 4) + basis_shift
                if _n_ag > 5
                    _pa_abs_gamma_6  := array.get(_pa_ag_p, 5) + basis_shift
                if _n_ag > 6
                    _pa_abs_gamma_7  := array.get(_pa_ag_p, 6) + basis_shift
                if _n_ag > 7
                    _pa_abs_gamma_8  := array.get(_pa_ag_p, 7) + basis_shift
                if _n_ag > 8
                    _pa_abs_gamma_9  := array.get(_pa_ag_p, 8) + basis_shift
                if _n_ag > 9
                    _pa_abs_gamma_10 := array.get(_pa_ag_p, 9) + basis_shift

        // Large Gamma (up to 10)
        if show_large_gamma
            [_pa_lg_p, _ign10, _ign11, _ign12] = parse_ranked_levels(in_large_gamma, "LG", min_lgamma_strength, max_lgamma_levels)
            _n_lg = array.size(_pa_lg_p)
            if _n_lg > 0
                _pa_large_gamma_1  := array.get(_pa_lg_p, 0) + basis_shift
                if _n_lg > 1
                    _pa_large_gamma_2  := array.get(_pa_lg_p, 1) + basis_shift
                if _n_lg > 2
                    _pa_large_gamma_3  := array.get(_pa_lg_p, 2) + basis_shift
                if _n_lg > 3
                    _pa_large_gamma_4  := array.get(_pa_lg_p, 3) + basis_shift
                if _n_lg > 4
                    _pa_large_gamma_5  := array.get(_pa_lg_p, 4) + basis_shift
                if _n_lg > 5
                    _pa_large_gamma_6  := array.get(_pa_lg_p, 5) + basis_shift
                if _n_lg > 6
                    _pa_large_gamma_7  := array.get(_pa_lg_p, 6) + basis_shift
                if _n_lg > 7
                    _pa_large_gamma_8  := array.get(_pa_lg_p, 7) + basis_shift
                if _n_lg > 8
                    _pa_large_gamma_9  := array.get(_pa_lg_p, 8) + basis_shift
                if _n_lg > 9
                    _pa_large_gamma_10 := array.get(_pa_lg_p, 9) + basis_shift

        // Key Gamma Strike
        if show_key_gamma
            _pa_kg = pnum(in_key_gamma)
            if not na(_pa_kg)
                _pa_key_gamma := _pa_kg + basis_shift

        // Vanna Inflection
        if show_vanna
            _pa_vi = pnum(in_vanna)
            if not na(_pa_vi)
                _pa_vanna := _pa_vi + basis_shift

        // Speed Trap
        if show_speed_trap
            _pa_st = pnum(in_speed_trap)
            if not na(_pa_st)
                _pa_speed_trap := _pa_st + basis_shift

        // Max Pain
        if show_max_pain
            _pa_mp = pnum(in_max_pain)
            if not na(_pa_mp)
                _pa_max_pain := _pa_mp + basis_shift

        // Zero Gamma
        if show_zero_gamma
            _pa_zg = pnum(_zg_clean)
            if not na(_pa_zg)
                _pa_zero_gamma := _pa_zg + basis_shift

        // Transition Bounds
        if show_transition
            if not na(t_lo)
                _pa_trans_lower := t_lo + basis_shift
            if not na(t_hi)
                _pa_trans_upper := t_hi + basis_shift

        // Expected Move
        if show_exp_move
            _pa_eu = pnum(in_exp_upper)
            _pa_el = pnum(in_exp_lower)
            if not na(_pa_eu)
                _pa_exp_upper := _pa_eu + basis_shift
            if not na(_pa_el)
                _pa_exp_lower := _pa_el + basis_shift

        // Extreme Move
        if show_ext_move
            _pa_xu = pnum(in_ext_upper)
            _pa_xl = pnum(in_ext_lower)
            if not na(_pa_xu)
                _pa_ext_upper := _pa_xu + basis_shift
            if not na(_pa_xl)
                _pa_ext_lower := _pa_xl + basis_shift

        // Implied Move
        if show_imp_move
            _pa_iu = pnum(in_imp_upper)
            _pa_il = pnum(in_imp_lower)
            if not na(_pa_iu)
                _pa_imp_upper := _pa_iu + basis_shift
            if not na(_pa_il)
                _pa_imp_lower := _pa_il + basis_shift

        // Implied Move 2SD
        if show_imp_2sd
            _pa_i2u = pnum(in_imp2sd_upper)
            _pa_i2l = pnum(in_imp2sd_lower)
            if not na(_pa_i2u)
                _pa_imp2sd_upper := _pa_i2u + basis_shift
            if not na(_pa_i2l)
                _pa_imp2sd_lower := _pa_i2l + basis_shift

        // Underlying
        if show_underlying
            [_pa_up, _pa_ut] = parse_underlying(in_underlying)
            if not na(_pa_up)
                _pa_underlying := _pa_up + basis_shift

        // Open Price
        if show_open
            [_pa_op, _pa_ot] = parse_underlying(in_open)
            if not na(_pa_op)
                _pa_open := _pa_op + basis_shift
    else
        // Price axis disabled — clear all
        _pa_call_wall_1 := na
        _pa_call_wall_2 := na
        _pa_call_wall_3 := na
        _pa_put_wall_1  := na
        _pa_put_wall_2  := na
        _pa_put_wall_3  := na
        _pa_abs_gamma_1 := na, _pa_abs_gamma_2 := na, _pa_abs_gamma_3 := na, _pa_abs_gamma_4 := na, _pa_abs_gamma_5 := na
        _pa_abs_gamma_6 := na, _pa_abs_gamma_7 := na, _pa_abs_gamma_8 := na, _pa_abs_gamma_9 := na, _pa_abs_gamma_10 := na
        _pa_large_gamma_1 := na, _pa_large_gamma_2 := na, _pa_large_gamma_3 := na, _pa_large_gamma_4 := na, _pa_large_gamma_5 := na
        _pa_large_gamma_6 := na, _pa_large_gamma_7 := na, _pa_large_gamma_8 := na, _pa_large_gamma_9 := na, _pa_large_gamma_10 := na
        _pa_key_gamma   := na
        _pa_vanna        := na
        _pa_speed_trap   := na
        _pa_max_pain     := na
        _pa_zero_gamma   := na
        _pa_trans_lower  := na
        _pa_trans_upper  := na
        _pa_exp_upper    := na
        _pa_exp_lower    := na
        _pa_ext_upper    := na
        _pa_ext_lower    := na
        _pa_imp_upper    := na
        _pa_imp_lower    := na
        _pa_imp2sd_upper := na
        _pa_imp2sd_lower := na
        _pa_underlying   := na
        _pa_open         := na

    // — Proximity flags: which levels are inside their own zone at current price —
    n_lv    = array.size(lv_prices)
    lv_near = array.new<bool>(n_lv, false)
    if show_proximity and n_lv > 0
        for i = 0 to n_lv - 1
            if math.abs(close - array.get(lv_prices, i)) <= zone_pts
                array.set(lv_near, i, true)

    // — HUD: nearest walls for distance display (post-shift prices) —
    nearest_cw = float(na)
    if array.size(hud_call_walls) > 0
        for i = 0 to array.size(hud_call_walls) - 1
            _p = array.get(hud_call_walls, i)
            if _p > close
                nearest_cw := na(nearest_cw) or _p < nearest_cw ? _p : nearest_cw

    nearest_pw = float(na)
    if array.size(hud_put_walls) > 0
        for i = 0 to array.size(hud_put_walls) - 1
            _p = array.get(hud_put_walls, i)
            if _p < close
                nearest_pw := na(nearest_pw) or _p > nearest_pw ? _p : nearest_pw

    // Proximity flags for HUD row highlighting
    cw_at_level = not na(nearest_cw) and math.abs(close - nearest_cw) <= zone_pts
    pw_at_level = not na(nearest_pw) and math.abs(close - nearest_pw) <= zone_pts

    // — Draw all merged levels — one line/label/box per unique price —
    if n_lv > 0
        for i = 0 to n_lv - 1
            p       = array.get(lv_prices,    i)
            lbl     = array.get(lv_labels,    i)
            col     = array.get(lv_colors,    i)
            sty     = array.get(lv_styles,    i)
            str_val = array.get(lv_strengths, i)
            is_mp   = array.get(lv_is_mp,     i)
            is_near = array.get(lv_near,      i)

            // Effective line width: strength-proportional or fixed
            eff_w = line_wid_def
            if str_val >= 0.0
                eff_w := strength_line_width ?
                     math.max(1, math.round(float(line_wid_min) + str_val * float(line_wid_max - line_wid_min))) :
                     line_wid_max

            // Effective line opacity: strength-scaled or fixed
            eff_lo = line_opac_def
            if str_val >= 0.0
                eff_lo := use_strength_opacity ?
                     math.max(0, math.round(float(line_opac_min) + str_val * float(line_opac_max - line_opac_min))) :
                     line_opac_max

            // Effective zone opacity: strength-scaled or fixed
            base_zone_opac = zone_opac_max
            if str_val >= 0.0
                base_zone_opac := use_strength_opacity ?
                     math.max(0, math.round(float(zone_opac_min) + str_val * float(zone_opac_max - zone_opac_min))) :
                     zone_opac_max

            eff_opac = show_proximity and is_near ? proximity_zone_opac : base_zone_opac

            // Effective zone height: max pain expands near close
            eff_z_pts = is_mp ? zone_pts * mp_mult : zone_pts

            [ln, lb, bx] = draw_hlevel(p, col, lbl, sty, eff_w, eff_lo, eff_opac, eff_z_pts)
            add_level(ln, lb, bx, all_lines, all_labels, all_boxes)

    // — HUD Dashboard —
    if not na(hud_table)
        table.delete(hud_table)

    // Keep HUD row-visibility flags in this scope so they can be reused
    // in the subsequent rendering block.
    _show_cw_row    = not na(nearest_cw)
    _show_pw_row    = not na(nearest_pw)
    _show_basis_row = basis_shift != 0.0
    _show_flip_row  = not na(_cached_regime_lv)
    _show_onboarding = n_lv == 0 or not has_level_input

    if show_hud or _show_onboarding
        // Count rows: regime always present; walls and basis only if available
        _n_rows = _show_onboarding ? 2 : (_show_stale_warning ? 2 : 0) + 1 + (_show_flip_row ? 1 : 0) + (show_walls and _show_cw_row ? 1 : 0) + (show_walls and _show_pw_row ? 1 : 0) + (_show_basis_row ? 1 : 0)

        hud_table := table.new(
               hud_table_pos(hud_pos), 2, _n_rows,
             bgcolor      = color.new(color.black, 60),
             border_color = color.new(color.gray,  50),
             border_width = 1,
             frame_color  = color.new(color.gray,  30),
             frame_width  = 1)

    if _show_onboarding
        if not na(hud_table)
            table.cell(hud_table, 0, 0, "NO LEVELS FOUND", text_color=color.white, text_size=hud_size, bgcolor=color.new(col_resist, 20), text_halign=text.align_center)
            table.merge_cells(hud_table, 0, 0, 1, 0)
            table.cell(hud_table, 0, 1, "Please provide level data in settings", text_color=hud_color, text_size=hud_size, bgcolor=color.new(color.black, 60), text_halign=text.align_center)
            table.merge_cells(hud_table, 0, 1, 1, 1)
    else if show_hud
        _row = 0

        // Stale levels warning rows (only when full date is provided and age > 24h).
        if _show_stale_warning
            table.cell(hud_table, 0, _row, "LEVELS OUTDATED (>24H)", text_color=color.white, text_size=hud_size, bgcolor=color.new(col_resist, 20), text_halign=text.align_center)
            table.merge_cells(hud_table, 0, _row, 1, _row)
            _row := _row + 1
            table.cell(hud_table, 0, _row, "Please provide fresh levels", text_color=hud_color, text_size=hud_size, bgcolor=color.new(color.black, 60), text_halign=text.align_center)
            table.merge_cells(hud_table, 0, _row, 1, _row)
            _row := _row + 1

        // Regime row
        _has_flip    = not na(_cached_regime_lv)
        _above_flip  = _has_flip and close > _cached_regime_lv
        _regime_col  = _has_flip ? (_above_flip ? color.new(regime_bull_col, 40) : color.new(regime_bear_col, 40)) : color.new(color.gray, 40)
        _regime_text = _has_flip ? (_above_flip ? (_zg_is_candidate ? "Above Flip?" : "Above Flip") : (_zg_is_candidate ? "Below Flip?" : "Below Flip")) : "No Flip"

        table.cell(hud_table, 0, _row, "REGIME",     text_color=hud_color, text_size=hud_size, bgcolor=_regime_col, text_halign=text.align_left)
        table.cell(hud_table, 1, _row, _regime_text,  text_color=hud_color, text_size=hud_size, bgcolor=_regime_col, text_halign=text.align_right)
        _row := _row + 1

        // Flip price row (only when zero gamma is present)
        if _show_flip_row
            _flip_text = (_zg_is_candidate ? "~" : "") + str.tostring(math.round(_cached_regime_lv, 2))
            table.cell(hud_table, 0, _row, "FLIP",      text_color=hud_color, text_size=hud_size, bgcolor=color.new(color.black, 60), text_halign=text.align_left)
            table.cell(hud_table, 1, _row, _flip_text,  text_color=col_zgamma, text_size=hud_size, bgcolor=color.new(color.black, 60), text_halign=text.align_right)
            _row := _row + 1

        // Call wall row
        if show_walls and _show_cw_row
            _cw_dist   = nearest_cw - close
            _cw_sigma  = not na(one_sigma) and one_sigma > 0 ? _cw_dist / one_sigma : na
            
            _cw_text = hud_dist_mode == "Sigma" and not na(_cw_sigma) ?
                 "+" + str.tostring(math.round(_cw_sigma, 2)) + "σ" :
                 "+" + str.tostring(math.round(_cw_dist, 1)) + " pts"
            
            // Color intensity based on sigma
            _cw_bg = cw_at_level ? color.new(col_resist, 30) : 
                     (not na(_cw_sigma) and _cw_sigma < 1.0 ? color.new(col_resist, 80) : color.new(color.black, 60))
            
            table.cell(hud_table, 0, _row, "CALL WALL", text_color=hud_color,     text_size=hud_size, bgcolor=_cw_bg, text_halign=text.align_left)
            table.cell(hud_table, 1, _row, _cw_text,    text_color=col_resist,    text_size=hud_size, bgcolor=_cw_bg, text_halign=text.align_right)
            _row := _row + 1

        // Put wall row
        if show_walls and _show_pw_row
            _pw_dist   = close - nearest_pw
            _pw_sigma  = not na(one_sigma) and one_sigma > 0 ? _pw_dist / one_sigma : na
            
            _pw_text = hud_dist_mode == "Sigma" and not na(_pw_sigma) ?
                 "-" + str.tostring(math.round(_pw_sigma, 2)) + "σ" :
                 "-" + str.tostring(math.round(_pw_dist, 1)) + " pts"
            
            // Color intensity based on sigma
            _pw_bg = pw_at_level ? color.new(col_support, 30) : 
                     (not na(_pw_sigma) and _pw_sigma < 1.0 ? color.new(col_support, 80) : color.new(color.black, 60))
            
            table.cell(hud_table, 0, _row, "PUT WALL",  text_color=hud_color,     text_size=hud_size, bgcolor=_pw_bg, text_halign=text.align_left)
            table.cell(hud_table, 1, _row, _pw_text,    text_color=col_support,   text_size=hud_size, bgcolor=_pw_bg, text_halign=text.align_right)
            _row := _row + 1

        // Basis row
        if _show_basis_row
            _bs_text = (basis_shift > 0 ? "+" : "") + str.tostring(math.round(basis_shift, 1)) + " pts"
            table.cell(hud_table, 0, _row, "BASIS",   text_color=hud_color, text_size=hud_size, bgcolor=color.new(color.black, 60), text_halign=text.align_left)
            table.cell(hud_table, 1, _row, _bs_text,  text_color=hud_color, text_size=hud_size, bgcolor=color.new(color.black, 60), text_halign=text.align_right)


// ════════════════════════════════════════════════════════════════════
// PRICE-AXIS LABELS — invisible plots that show level prices on the
// right price scale.  plot() must be top-level (not inside if), so
// var float values are set inside barstate.islast above and persist.
// display=display.price_scale renders only the axis tag, no chart line.
//
// NOTE: Literal hex colors are used instead of input.color() refs to
// keep each plot() at 1 plot-count (non-series color).  Using input
// colors would double every call (value + color series) and bust the
// 64-plot limit.  The actual chart lines/labels still honour the
// user-customisable input colors via draw_hlevel().
// ════════════════════════════════════════════════════════════════════

plot(_pa_call_wall_1,  "Call Wall 1",             #E81E72, display=display.price_scale)
plot(_pa_call_wall_2,  "Call Wall 2",             #E81E72, display=display.price_scale)
plot(_pa_call_wall_3,  "Call Wall 3",             #E81E72, display=display.price_scale)
plot(_pa_call_wall_4,  "Call Wall 4",             #E81E72, display=display.price_scale)
plot(_pa_call_wall_5,  "Call Wall 5",             #E81E72, display=display.price_scale)
plot(_pa_call_wall_6,  "Call Wall 6",             #E81E72, display=display.price_scale)
plot(_pa_call_wall_7,  "Call Wall 7",             #E81E72, display=display.price_scale)
plot(_pa_call_wall_8,  "Call Wall 8",             #E81E72, display=display.price_scale)
plot(_pa_call_wall_9,  "Call Wall 9",             #E81E72, display=display.price_scale)
plot(_pa_call_wall_10, "Call Wall 10",            #E81E72, display=display.price_scale)

plot(_pa_put_wall_1,   "Put Wall 1",              #00ACBA, display=display.price_scale)
plot(_pa_put_wall_2,   "Put Wall 2",              #00ACBA, display=display.price_scale)
plot(_pa_put_wall_3,   "Put Wall 3",              #00ACBA, display=display.price_scale)
plot(_pa_put_wall_4,   "Put Wall 4",              #00ACBA, display=display.price_scale)
plot(_pa_put_wall_5,   "Put Wall 5",              #00ACBA, display=display.price_scale)
plot(_pa_put_wall_6,   "Put Wall 6",              #00ACBA, display=display.price_scale)
plot(_pa_put_wall_7,   "Put Wall 7",              #00ACBA, display=display.price_scale)
plot(_pa_put_wall_8,   "Put Wall 8",              #00ACBA, display=display.price_scale)
plot(_pa_put_wall_9,   "Put Wall 9",              #00ACBA, display=display.price_scale)
plot(_pa_put_wall_10,  "Put Wall 10",             #00ACBA, display=display.price_scale)

plot(_pa_abs_gamma_1,  "Absolute Gamma 1",        #E81E72, display=display.price_scale)
plot(_pa_abs_gamma_2,  "Absolute Gamma 2",        #E81E72, display=display.price_scale)
plot(_pa_abs_gamma_3,  "Absolute Gamma 3",        #E81E72, display=display.price_scale)
plot(_pa_abs_gamma_4,  "Absolute Gamma 4",        #E81E72, display=display.price_scale)
plot(_pa_abs_gamma_5,  "Absolute Gamma 5",        #E81E72, display=display.price_scale)
plot(_pa_abs_gamma_6,  "Absolute Gamma 6",        #E81E72, display=display.price_scale)
plot(_pa_abs_gamma_7,  "Absolute Gamma 7",        #E81E72, display=display.price_scale)
plot(_pa_abs_gamma_8,  "Absolute Gamma 8",        #E81E72, display=display.price_scale)
plot(_pa_abs_gamma_9,  "Absolute Gamma 9",        #E81E72, display=display.price_scale)
plot(_pa_abs_gamma_10, "Absolute Gamma 10",       #E81E72, display=display.price_scale)

plot(_pa_large_gamma_1,  "Large Gamma 1",         #00ACBA, display=display.price_scale)
plot(_pa_large_gamma_2,  "Large Gamma 2",         #00ACBA, display=display.price_scale)
plot(_pa_large_gamma_3,  "Large Gamma 3",         #00ACBA, display=display.price_scale)
plot(_pa_large_gamma_4,  "Large Gamma 4",         #00ACBA, display=display.price_scale)
plot(_pa_large_gamma_5,  "Large Gamma 5",         #00ACBA, display=display.price_scale)
plot(_pa_large_gamma_6,  "Large Gamma 6",         #00ACBA, display=display.price_scale)
plot(_pa_large_gamma_7,  "Large Gamma 7",         #00ACBA, display=display.price_scale)
plot(_pa_large_gamma_8,  "Large Gamma 8",         #00ACBA, display=display.price_scale)
plot(_pa_large_gamma_9,  "Large Gamma 9",         #00ACBA, display=display.price_scale)
plot(_pa_large_gamma_10, "Large Gamma 10",        #00ACBA, display=display.price_scale)

plot(_pa_key_gamma,    "Key Gamma Strike",        #E81E72, display=display.price_scale)
plot(_pa_vanna,        "Vanna Inflection",        #CC29C4, display=display.price_scale)
plot(_pa_speed_trap,   "Speed Trap",              #999999, display=display.price_scale)
plot(_pa_max_pain,     "Max Pain",                #CCCCCC, display=display.price_scale)
plot(_pa_zero_gamma,   "Zero Gamma",              #FFDD33, display=display.price_scale)
plot(_pa_trans_lower,  "Gamma Transition Lower",  #FFDD33, display=display.price_scale)
plot(_pa_trans_upper,  "Gamma Transition Upper",  #FFDD33, display=display.price_scale)
plot(_pa_exp_upper,    "Expected Move Upper",     #FEB000, display=display.price_scale)
plot(_pa_exp_lower,    "Expected Move Lower",     #FEB000, display=display.price_scale)
plot(_pa_ext_upper,    "Extreme Move Upper",      #FF7900, display=display.price_scale)
plot(_pa_ext_lower,    "Extreme Move Lower",      #FF7900, display=display.price_scale)
plot(_pa_imp_upper,    "Implied Move Upper",      #FF9200, display=display.price_scale)
plot(_pa_imp_lower,    "Implied Move Lower",      #FF9200, display=display.price_scale)
plot(_pa_imp2sd_upper, "Implied Move 2SD Upper",  #EA5752, display=display.price_scale)
plot(_pa_imp2sd_lower, "Implied Move 2SD Lower",  #EA5752, display=display.price_scale)
plot(_pa_underlying,   "Underlying Price",        #777777, display=display.price_scale)
plot(_pa_open,         "Open Price",              #FF9200, display=display.price_scale)
````
