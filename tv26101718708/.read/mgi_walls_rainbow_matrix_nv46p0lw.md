# MGI Walls | Rainbow Matrix

- url: https://www.tradingview.com/script/nv46P0LW-MGI-Walls-Rainbow-Matrix/
- type: indicator
- pine_id: PUB;c0d6b9afb56e4e649bc8686e88090117
- version: 2.0

## Description

GENERAL OVERVIEW
The MGI Walls is a multi-timeframe institutional liquidity radar that extracts and renders the price zones where institutional capital concentrates: Volume Profile blocks (Point of Control, Value Area High, Value Area Low), Anchored VWAPs, and Parabolic SAR levels. Instead of showing these levels for a single chart timeframe, the indicator scans up to five macro timeframes simultaneously and merges overlapping zones into a single intensified block whenever multiple timeframes agree on the same price area.

The main goal of this indicator is to give traders a clean, automatic read on where the structural barriers in the market are — without having to manually flip between timeframes, mark POCs by hand, or guess which level the next reaction will respect. Every line, box, and confluence zone you see on the chart was extracted from real volume distribution data, not drawn manually.

It plots up to four level types per timeframe (POC, VAH, VAL, VWAP, SAR), each weighted by the structural significance of its timeframe — a Weekly POC carries five times the gravitational weight of a 15-minute POC. The Wall Fusion Engine then detects when levels from different timeframes fall within a configurable percentage threshold and consolidates them into a single block. The Nearest Wall HUD panel and the institutional collision alerts complete the toolkit.

This indicator was developed for traders who already understand Volume Profile and VWAP concepts and want to see them across multiple timeframes in a single visual, with automatic confluence detection.

[image]https://www.tradingview.com/x/xOxOJvjF/[/image]

WHAT IS THE THEORY BEHIND THIS INDICATOR?
Most Volume Profile indicators on TradingView — including the standard built-in profiles, Fixed Range Volume Profile, and the various session/visible-range derivatives — share a common architectural choice: they operate on a single timeframe. They show you the POC and Value Area for the current chart only. This treats each timeframe as an isolated decision space.

The problem: institutional flow is not isolated to one timeframe. The market makers operating on the daily horizon see different value areas than those operating on the weekly or 4-hour horizon. Their orders sit at their own POCs and Value Area boundaries. When price approaches a level that only one institutional horizon defends, the reaction is often modest. When price approaches a level that multiple horizons defend simultaneously, the reaction is structurally stronger — that confluence is where the largest pools of resting liquidity accumulate.

This indicator addresses that by performing the extraction across five user-configured timeframes simultaneously via `request.security()`, weighting each level by the gravitational significance of its parent timeframe, and then fusing levels from different timeframes that fall within a configurable margin. The math is standard Volume Profile (POC at the volume-weighted mode, VAH/VAL at the ±2.51σ boundary that approximates the 70% Value Area) — what makes it useful is doing it across five timeframes at once, with hierarchical weighting and confluence merging.

Why traders use it: each block represents an institutional decision zone. A standalone POC line from the 15-minute timeframe is a local reaction point. A POC line that simultaneously aligns with the 4-hour VAH and the daily VWAP is a multi-horizon barrier — a zone defended by three independent pools of institutional capital at once. The fusion engine makes these confluences immediately visible as thicker, more opaque blocks; the polarity of each block reflects the accumulated weight balance of the levels that compose it, not the polarity of the last level to be merged.

The three rendered components — Volume Profile zones, Anchored VWAPs, and Parabolic SAR levels — are not independent layers stacked on the same chart. They map three different aspects of institutional positioning at the same set of timeframes: where past volume concentrated (Volume Profile), where the live volume-weighted consensus price currently sits (VWAPs), and which directional trend regime each timeframe is in (SARs). The Wall Fusion Engine operates across all three layers indiscriminately — a POC from the 4-hour timeframe and a VWAP from the daily timeframe at the same price are fused into a single block, because from the perspective of institutional defense they represent the same structural barrier reinforced by two independent mechanisms. This integration is the reason the three components exist in a single script rather than as three separate indicators: the cross-layer fusion is what surfaces multi-mechanism confluence, which a separate-script approach cannot do.

MGI WALLS FEATURES

The indicator includes 6 main features:
Multi-Timeframe Volume Profile Engine
Anchored MTF VWAPs
Parabolic SAR Levels (MTF)
Wall Fusion Engine with Polarity-Balance Coloring
Nearest Wall HUD Panel
Institutional Collision Alerts

Multilingual interface and full customization across all visual layers.

MULTI-TIMEFRAME VOLUME PROFILE ENGINE
🔹 What It Does
The core of the indicator. For each of the five configured radar timeframes, the engine performs three operations:
◇ Locates the price level that received the highest traded volume in the lookback window — the Point of Control (POC).
◇ Computes the volume-weighted standard deviation of price around that POC.
◇ Builds the Value Area High (VAH) and Value Area Low (VAL) at a calibrated multiplier (±2.51σ) of that deviation, approximating the price range that contained 70% of the total volume.

The result is three institutional reference levels per timeframe — POC, VAH, VAL — extracted natively at the granularity of each timeframe rather than approximated from the current chart's data.

🔹 Method
The extraction runs via `request.security()` with `lookahead=barmerge.lookahead_off` to prevent repainting. The POC is identified as the volume-weighted mode within the lookback window. The Value Area boundaries are derived statistically from the volume-weighted variance of price around the POC, using a calibration factor (vp_k = 2.51) tuned to approximate the conventional 70% Value Area definition. Each level is plotted on the chart as a line or box at its native price location, color-coded by whether it sits above (resistance) or below (support) the current price, and weighted by the timeframe it originated from.

🔹 Hierarchical Weighting
The five timeframes are weighted by structural significance:
◇ TF1 (Micro, default 15m): weight 1 — local reaction point.
◇ TF2 (Intraday, default 1h): weight 1 — session-scale level.
◇ TF3 (Macro 1, default 4h): weight 2 — multi-session level.
◇ TF4 (Macro 2, default Daily): weight 3 — multi-day level.
◇ TF5 (Global, default Weekly): weight 5 — multi-week structural barrier.

The weight controls visual prominence (opacity, border thickness) and, when fusion occurs, the contribution of each level to the polarity balance of the resulting block.

ANCHORED MTF VWAPS
🔹 What It Does
For each of the five radar timeframes, an Anchored VWAP is extracted and rendered as a separate level. The Global VWAP — the average of all five — is also plotted, marked with a globe emoji to distinguish it from the per-timeframe VWAPs.

🔹 Method
The per-timeframe VWAP is computed via a volume-weighted moving average of hlc3 on the native bars of each timeframe, then reported back to the current chart through `request.security()`. The Global VWAP is the unweighted average of the five timeframe VWAPs that are currently available (NA values are skipped).

🔹 Why It Matters
The Volume Profile blocks tell you where past volume concentrated. The VWAPs tell you what the volume-weighted consensus price is for each horizon, updated bar by bar. Together they give a complete read on every bar: where the past institutional reference zones are (the blocks) and where the live volume-weighted average for each horizon currently sits (the VWAPs).

PARABOLIC SAR LEVELS (MTF)
🔹 What It Does
The Parabolic SAR for each of the five radar timeframes is extracted and rendered as an institutional trend-direction anchor. SAR levels are toggleable independently of the Volume Profile and VWAP layers.

🔹 Why It Matters
The SAR provides a directional trend reference per timeframe — when the Weekly SAR sits above price and the Daily SAR sits below, the structure is in conflict and the resolution of that conflict often drives the next swing. When multiple SARs align on the same side, the directional bias is structurally agreed across horizons.

WALL FUSION ENGINE WITH POLARITY-BALANCE COLORING
🔹 What It Does
When two or more levels from different timeframes fall within a configurable percentage threshold (default 0.30%), the engine fuses them into a single block. The fused block inherits the combined weight of all its components — visually thicker, more opaque, more visible than a standalone level. The label of the fused block accumulates the directional triangles of each contributing level (▲ for support, ▼ for resistance).

🔹 Polarity-Balance Coloring
The color of a fused block reflects the accumulated weight balance of its constituent levels — not the polarity of the last level to be merged. A block containing four resistance levels (▼▼▼▼) and two support levels (▲▲) will render red, because the resistance weight dominates. A block where support and resistance weights are equal uses a tiebreaker: the position of the current price relative to the block's midpoint. Price above midpoint resolves to support (green); price below resolves to resistance (red). This produces a coloring scheme that is internally consistent with the triangle labels and with the price's current location.

🔹 Customization
The Wall Merge Margin (%) input controls how aggressively levels are fused. Lower values produce many separate precise lines. Higher values produce massive consolidated institutional blocks. The default of 0.30% is calibrated for liquid instruments on intraday timeframes; for higher-volatility assets or higher timeframes, larger margins (0.50–1.00%) may produce more readable charts.

NEAREST WALL HUD PANEL
🔹 What It Shows
A compact corner panel reports four live values:
◇ RESISTANCE — the price of the nearest wall above the current price
◇ DIST. — the percentage distance from current price to that resistance
◇ SUPPORT — the price of the nearest wall below the current price
◇ DIST. — the percentage distance from current price to that support

The distances are computed against the midpoint of each fused block, so the values reflect the consolidated wall, not any single contributing level.

🔹 Why It Helps
The HUD removes the need to visually measure distances to the walls on every bar. It tells you in plain numerical form how far the nearest barriers are in each direction. Useful for stop placement, target placement, and live decision-making where the visual chart is busy with multiple levels.

🔹 Customization
The HUD can be positioned in any of the four chart corners and rendered in any of five font sizes. The display language is controlled by the System Language input.

snapshot

INSTITUTIONAL COLLISION ALERTS
🔹 What Triggers
Two alert types are available:
◇ VWAP Collision — fires when price crosses or touches the daily, weekly, or monthly VWAP within a 0.15% proximity band.
◇ Volume Profile Wall Hit — fires when price crosses or touches the Global POC, VAH, or VAL within the same proximity band.

🔹 How They Fire
Alerts are gated by `barstate.isconfirmed`, which means they only trigger on the close of the bar that touched the level — not intra-bar. This prevents false signals from wicks that get rejected before the bar closes. Each alert uses `alert.freq_once_per_bar`, ensuring no duplicate firings on the same candle.

🔹 alertcondition() Mode
For users who prefer the TradingView alert UI rather than the `alert()` function call, two `alertcondition` blocks are also exposed: "VWAP Collision" and "Volume Profile Wall Hit". A third dummy `alertcondition` titled "HOW TO SETUP ALERTS (READ)" provides setup guidance in the alert condition menu.

MULTILINGUAL INTERFACE
The indicator supports five languages for the HUD display and alert messages: English (default), Português, Español, Русский, and 中文 (Chinese). Code, comments, and configuration tooltips remain in English regardless of the selected language.

For reference, the English text of all multilingual UI strings used in the HUD and alerts:
◇ (SUPPORT) / (RESISTANCE) — appended to wall labels indicating polarity
◇ RESISTANCE: / SUPPORT: — HUD row labels for nearest walls
◇ DIST.: — HUD row label for distance percentage
◇ VWAP Collision Alert: "🛡️ [WALL] Price collided with Institutional VWAP. Defense zone active."
◇ Volume Profile Wall Alert: "🧱 [WALL] Price hit Macro Volume Profile zone (POC/VAH/VAL). Institutional decision imminent."

HOW TO USE
This indicator is not a signal generator. It is a structural map: it tells you where the institutional barriers are, how strong each one is (by weight and fusion), and how far the nearest one is in each direction.

🔹 Reading the Walls
◇ Each line or block on the chart marks an institutional decision zone.
◇ The triangles in the label (▲ or ▼) and their count indicate the polarity and weight of the level.
◇ Walls with multiple triangles in the same direction are stronger reaction points than single-triangle walls.
◇ A block with mixed triangles is a fused confluence — the color shows which side dominates by weight.

🔹 Reading the HUD
◇ The HUD reports the nearest resistance above and nearest support below the current price.
◇ The percentage distances help size stops and targets against the structural barriers rather than against arbitrary fixed values.

🔹 Tactical Reading
◇ Price approaching a heavy multi-triangle wall: zone of elevated structural significance, where multiple institutional horizons coincide.
◇ Price sitting between two close walls of opposite polarity: ranging structure, defined by two opposing barriers of comparable weight.
◇ Price breaking through a heavy wall on confirmed close: structural shift. The wall often inverts polarity on subsequent retests.
◇ VWAP collision alerts: useful as a contextual reference for mean-reversion or trend-continuation analysis.

🔹 Multi-Timeframe Reading
◇ On lower timeframes (1m, 5m, 15m), configure shorter radar timeframes to track intraday institutional flow.
◇ On higher timeframes (1h, 4h, daily), keep the default 15m/1h/4h/D/W configuration to read multi-day and multi-week structural zones.
◇ The Global VWAP and Global POC (marked with 🌎) represent the consensus across all five timeframes — the most structurally significant single reference.

INPUTS EXPLAINED
🔹 System Language
Display language for the HUD and alert messages. Options: English (default), Português, Español, Русский, 中文 (Chinese).

🔹 Radar Timeframes (TF1 to TF5)
Configure each of the five macro periods to scan. Defaults: 15m, 1h, 4h, Daily, Weekly. The shortest timeframe carries weight 1; the longest carries weight 5.

🔹 Show MTF VWAPs (Radar)
Toggle for the Volume-Weighted Average Price extracted from each radar timeframe.

🔹 Show POC Lines
Toggle for the Point of Control lines — the price level with the highest traded volume in each timeframe.

🔹 Show VA Boxes (VAH / VAL)
Toggle for the Value Area High and Value Area Low — the upper and lower boundaries of the 70% volume zone.

🔹 Show SAR Levels
Toggle for the Parabolic SAR levels from each timeframe.

🔹 Fuse Overlapping Walls
Toggle for the confluence merging engine. When enabled, levels from different timeframes that fall within the Wall Merge Margin are consolidated into a single intensified block.

🔹 Wall Merge Margin (%)
Distance threshold to fuse nearby walls. Range 0.01–3.00, default 0.30. Lower values produce separate precise lines; higher values produce consolidated institutional blocks.

🔹 Show Nearest Wall Panel
Toggle for the corner HUD reporting nearest resistance, nearest support, and the percentage distances.

🔹 Panel Position
Position of the HUD on the chart. Four corners available: Top Right (default), Top Left, Bottom Right, Bottom Left.

🔹 Font Size
HUD font size. Options: Tiny, Small (default), Normal, Large, Huge.

🔹 VWAP Collision Alert
Toggle for the alert that fires when price collides with the daily, weekly, or monthly VWAP.

🔹 Volume Profile Wall Alert (POC/VAH/VAL)
Toggle for the alert that fires when price touches the Global POC, VAH, or VAL.

IMPORTANT NOTES
The MGI Walls works on any timeframe. The default radar configuration (15m/1h/4h/D/W) is calibrated for intraday and swing trading on liquid instruments. For position trading or scalping, the radar timeframes can be reconfigured to scan longer or shorter horizons respectively.

The indicator works best on instruments with reliable volume data: crypto perpetual contracts, large-cap equities, futures, major forex pairs. On low-volume instruments, the Volume Profile component becomes less reliable, though the VWAP and SAR components continue to function correctly.

Alerts fire once per confirmed bar. Historical bars never repaint after they close. The live bar updates intra-bar as expected for a real-time indicator.

The Value Area calibration factor (vp_k = 2.51) is tuned to approximate the conventional 70% Value Area definition under volume-weighted standard deviation. It is a calibration constant derived from observation rather than an arbitrary choice.

Pine Script v6. Open-source under Mozilla Public License 2.0.

UNIQUENESS
The MGI Walls is unique in three ways. First, it performs the Volume Profile, VWAP, and SAR extraction across five timeframes simultaneously rather than on the current chart only, surfacing the institutional reference zones that multiple time horizons agree on rather than only those visible on the active timeframe. Second, it weights each level by the structural significance of its parent timeframe — a Weekly POC carries five times the gravitational weight of a 15-minute POC — and the Wall Fusion Engine consolidates levels from different timeframes that fall within a configurable margin into a single intensified block, making multi-horizon confluence zones immediately visible as visually thicker walls. Third, the fused-block coloring reflects the accumulated weight balance of all constituent levels rather than the polarity of the last level to be merged, producing a visual scheme that is internally consistent with the triangle labels (▲ for support, ▼ for resistance) and with the price's current position relative to the block. The combination of multi-timeframe simultaneous extraction, hierarchical weighting with automatic confluence fusion, and balance-driven block coloring produces a structural map that behaves differently from single-timeframe Volume Profile indicators, particularly at price zones where multiple institutional horizons converge and where the strongest reactions tend to occur.

PUBLICATION METADATA (handoff to operator — not part of description)

Title: MGI Walls | Rainbow Matrix
Visibility: Open-source / Public
Category suggestion: Volume-based (primary) — TradingView's category for Volume Profile / volume-driven indicators

Tag suggestions (TV allows up to 10; pick the 9 most relevant):
  - volume-profile
  - poc
  - value-area
  - vwap
  - multi-timeframe
  - mtf
  - confluence
  - institutional
  - support-resistance
  - parabolic-sar  (optional, swap for one above if SAR is a key selling point)

License declaration: Mozilla Public License 2.0 (already in script header)

Screenshot slots in the description (5 "snapshot" placeholders):
  1. After GENERAL OVERVIEW — wide chart showing the indicator running on BTC or major instrument, with walls visible across multiple TFs
  2. After Multi-Timeframe Volume Profile Engine section — chart annotated with POC/VAH/VAL lines from different TFs
  3. After Wall Fusion Engine section — close-up of a fused confluence block with mixed triangles (▲▼) and the polarity-balance color clearly visible
  4. After Nearest Wall HUD Panel section — HUD close-up showing the 5-row layout with real values
  5. (Optional, swap into one of the above slots) — Black Swan-style touch event showing a collision alert firing

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rainbowmatrix
//
// ════════════════════════════════════════════════════════════════════════════════
// MGI WALLS — INSTITUTIONAL LIQUIDITY RADAR
//
// A multi-timeframe institutional wall detector that extracts and renders
// Volume Profile zones (POC / VAH / VAL), Anchored VWAPs and SAR levels from
// up to 5 macro timeframes simultaneously. Walls fuse and intensify when
// multiple timeframes converge on the same price zone — revealing the
// true gravitational barriers that institutions defend and attack.
//
// METHOD:
//   1. For each of 5 user-configured timeframes (default 15m, 1h, 4h, D, W),
//      the script extracts via request.security():
//        - POC (Point of Control): the price level with highest traded volume
//          in the lookback window of that timeframe.
//        - VAH / VAL (Value Area High / Low): the upper and lower boundaries
//          of the price range that contained 70% of the volume.
//        - Anchored VWAP for that timeframe.
//        - Parabolic SAR level for that timeframe.
//   2. Each level is plotted on the chart as a line or box at its native
//      price location, color-coded by whether it sits above (resistance) or
//      below (support) the current price.
//   3. The "Fuse Overlapping Walls" engine detects when levels from different
//      timeframes converge within a configurable margin (default 0.30%) and
//      merges them into a single intensified wall — a confluence zone with
//      higher gravitational weight than any individual level.
//   4. The Info Panel tracks the nearest resistance and nearest support walls
//      relative to the current price, with live distance percentages.
//
// ORIGINALITY:
//   Most volume-profile indicators on TradingView operate on a single
//   timeframe — they show you the POC and Value Area for the current chart
//   only. MGI Walls operates across 5 timeframes simultaneously, weighted by
//   structural significance: the weekly POC carries more gravitational
//   weight than the 15-minute POC. Combined with timeframe convergence
//   detection (the fusion engine), the indicator surfaces the price zones
//   that multiple institutional time horizons agree on — which tend to act
//   as the strongest support / resistance in actual price action.
//
// HOW TO USE:
//   - Lines and boxes mark institutional decision zones.
//   - Walls that span multiple timeframes (visually thicker after fusion)
//     are stronger reaction points than single-timeframe walls.
//   - The Info Panel shows the nearest wall above (resistance) and below
//     (support), with the percentage distance from current price.
//   - VWAP and Volume Profile alerts fire when price collides with the
//     respective wall types.
//
// INPUTS EXPLAINED:
//   - System Language: HUD/alert text language (EN/PT/ES/RU/ZH).
//   - 5 Radar Timeframes: configure each macro period to scan.
//   - Show toggles for VWAPs, POC, Value Area, SAR.
//   - Fuse Overlapping Walls: enables confluence merging.
//   - Wall Merge Margin: percentage threshold for fusion.
//   - Info Panel: nearest wall tracker (position, font size).
//   - Alerts: VWAP collision and Volume Profile zone touch.
// ════════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("MGI Walls | Rainbow Matrix", overlay=true, max_bars_back=500, max_labels_count=100, max_lines_count=100, max_boxes_count=100)

// ========================================================================================================
// COLOR PALETTE
// ========================================================================================================
// User-configurable colors for the dominant-polarity logic. c_neutral and c_black
// remain constants (used for HUD chrome — borders, frames, neutral labels).
g_colors = "COLORS"
c_sup = input.color(color.rgb(8, 153, 129), "Support / Below Price Color",
     group=g_colors,
     tooltip="Color for walls and HUD elements below the current price (acting as support). Default: TradingView native candle green.")
c_res = input.color(color.rgb(242, 54, 69), "Resistance / Above Price Color",
     group=g_colors,
     tooltip="Color for walls and HUD elements above the current price (acting as resistance). Default: TradingView native candle red.")
c_neutral = color.gray
c_black  = color.black

// ========================================================================================================
// SYSTEM LANGUAGE
// ========================================================================================================
g_lang = "GLOBAL SETTINGS"
language = input.string("English", "System Language",
     options=["English", "Português", "Español", "Русский", "中文 (Chinese)"],
     group=g_lang,
     tooltip="Select the display language for all on-screen labels and alerts.")
string _l = language == "Português" ? "PT" : language == "Español" ? "ES" : language == "Русский" ? "RU" : language == "中文 (Chinese)" ? "ZH" : "EN"

// ── Multilingual strings (per §3.11) ──
var string s_sup       = _l=="PT"?" (SUPORTE)"     :_l=="ES"?" (SOPORTE)"     :_l=="RU"?" (ПОДДЕРЖКА)"    :_l=="ZH"?" (支撑)"   :" (SUPPORT)"
var string s_res       = _l=="PT"?" (RESISTÊNCIA)"  :_l=="ES"?" (RESISTENCIA)"  :_l=="RU"?" (СОПРОТИВЛЕНИЕ)" :_l=="ZH"?" (阻力)"  :" (RESISTANCE)"
var string s_lbl_above = _l=="PT"?"RESISTÊNCIA:"   :_l=="ES"?"RESISTENCIA:"   :_l=="RU"?"СОПРОТИВЛЕНИЕ:" :_l=="ZH"?"阻力:"     :"RESISTANCE:"
var string s_lbl_below = _l=="PT"?"SUPORTE:"       :_l=="ES"?"SOPORTE:"       :_l=="RU"?"ПОДДЕРЖКА:"     :_l=="ZH"?"支撑:"     :"SUPPORT:"
var string s_lbl_dist  = _l=="PT"?"DIST.:"         :_l=="ES"?"DIST.:"         :_l=="RU"?"РАССТ.:"        :_l=="ZH"?"距离:"     :"DIST.:"
var string s_al_vwap   = _l=="PT"?"🛡️ [MURALHA] Preço colidiu com VWAP Institucional. Zona de defesa ativa." :_l=="ES"?"🛡️ [MURO] Precio chocó con VWAP Institucional. Zona de defensa activa." :_l=="RU"?"🛡️ [СТЕНА] Цена столкнулась с институциональным VWAP. Активная зона защиты." :_l=="ZH"?"🛡️ [墙壁] 价格与机构VWAP碰撞。防守区域激活。" :"🛡️ [WALL] Price collided with Institutional VWAP. Defense zone active."
var string s_al_vp     = _l=="PT"?"🧱 [MURALHA] Preço atingiu zona de Volume Profile Macro (POC/VAH/VAL). Decisão institucional iminente." :_l=="ES"?"🧱 [MURO] Precio alcanzó zona de Volume Profile Macro (POC/VAH/VAL). Decisión institucional inminente." :_l=="RU"?"🧱 [СТЕНА] Цена достигла зоны Макро Volume Profile (POC/VAH/VAL). Институциональное решение неизбежно." :_l=="ZH"?"🧱 [墙壁] 价格到达宏观成交量分布区域 (POC/VAH/VAL)。机构决策即将到来。" :"🧱 [WALL] Price hit Macro Volume Profile zone (POC/VAH/VAL). Institutional decision imminent."

// ========================================================================================================
// INPUTS
// ========================================================================================================
g_rd = "INSTITUTIONAL RADAR (MTF WALLS)"
rd_tf1 = input.string("15",  "Radar TF 1 — Micro",   group=g_rd, tooltip="Shortest timeframe. Identifies local institutional walls with lower weight.")
rd_tf2 = input.string("60",  "Radar TF 2 — Intraday", group=g_rd, tooltip="Intraday timeframe. Captures session-scale institutional positioning.")
rd_tf3 = input.string("240", "Radar TF 3 — Macro 1",  group=g_rd, tooltip="Mid-range macro timeframe. Captures multi-session institutional structure.")
rd_tf4 = input.string("D",   "Radar TF 4 — Macro 2",  group=g_rd, tooltip="Higher macro timeframe (typically Daily). Captures swing-level institutional decision zones.")
rd_tf5 = input.string("W",   "Radar TF 5 — Global",   group=g_rd, tooltip="Longest timeframe. Carries the highest gravitational weight (5x).")

g_vwma = "VWMA & ANCHORED VWAP REFERENCES"
show_vwma_rd   = input.bool(true, "Show MTF VWMAs (Radar)",           group=g_vwma, tooltip="Volume-Weighted Moving Average extracted from each radar timeframe. Acts as a dynamic rolling reference per timeframe.")
show_avwap_dwm = input.bool(true, "Show Anchored VWAPs (Daily/Weekly/Monthly)", group=g_vwma, tooltip="Anchored VWAPs that reset at session boundaries (D / W / M). True session-anchored references, distinct from the rolling VWMAs above.")

g_vis = "VISUALIZATION"
show_poc  = input.bool(true,  "Show POC Lines (Point of Control)",   group=g_vis, tooltip="The price level with the highest traded volume. The institutional 'Central Trench' — price has a strong tendency to return to this level.")
show_va   = input.bool(true,  "Show VA Boxes (VAH / VAL — 70% Area)", group=g_vis, tooltip="The Value Area where 70% of all capital was exchanged. VAH = upper boundary (resistance), VAL = lower boundary (support).")
show_sar  = input.bool(true,  "Show SAR Levels",                      group=g_vis, tooltip="Parabolic SAR levels from each timeframe — institutional trend direction anchors.")
show_dedup = input.bool(true, "Fuse Overlapping Walls",              group=g_vis, tooltip="When multiple timeframes agree on the same price zone, walls are merged and intensified — a confluence zone with higher gravitational weight.")
merge_margin = input.float(0.30, "Wall Merge Margin (%)", minval=0.01, maxval=3.0, step=0.05, group=g_vis, tooltip="Distance threshold to fuse nearby walls. Lower values = separate precise lines. Higher values = massive consolidated institutional blocks.")

g_info = "INFO PANEL"
show_panel = input.bool(true,   "Show Nearest Wall Panel", group=g_info, tooltip="Show the floating panel that tracks the nearest resistance above and the nearest support below the current price, with live distance percentages.")
panel_pos  = input.string("Top Right", "Panel Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=g_info,
     tooltip="Anchor corner for the Nearest Wall Panel — renders fixed in the chosen corner regardless of zoom or scroll.")
// --- Text settings ---
i_text_size = input.string("Small", "Font Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=g_info, tooltip="Font size for the HUD panel and on-chart wall labels.")
// Font size mapping
font_size = i_text_size == "Tiny" ? size.tiny : i_text_size == "Small" ? size.small : i_text_size == "Normal" ? size.normal : i_text_size == "Large" ? size.large : size.huge

g_al = "ALERTS"
al_vwap = input.bool(true, "VWAP Collision Alert", group=g_al, tooltip="Fires when price crosses or touches a Daily, Weekly, or Monthly Anchored VWAP — a structural institutional reference level.")
al_vp   = input.bool(true, "Volume Profile Wall Alert (POC/VAH/VAL)", group=g_al, tooltip="Fires when price hits the global Volume Profile zone (POC, VAH, or VAL) — a high-volume institutional decision point.")

// ========================================================================================================
// VOLUME PROFILE CONSTANT
// ========================================================================================================
float vp_k = 2.51  // Calibrated factor — defines the width of the Value Area (≈70% of volume)

// ========================================================================================================
// RADAR DATA EXTRACTION FUNCTION (PER TIMEFRAME)
// ========================================================================================================
// Extracts: VWAP, VAH, POC, VAL, SAR — from any timeframe via request.security()
f_calc_radar_data() =>
    _vwap      = ta.vwma(hlc3, 60)
    _max_vol = ta.highest(volume, 60)
    _poc       = ta.valuewhen(volume == _max_vol, hlc3, 0)
    _dev_sq    = volume * math.pow(hlc3 - _poc, 2)
    _var       = math.sum(_dev_sq, 60) / math.max(math.sum(volume, 60), 1)
    _std       = math.sqrt(_var)
    _vah       = _poc + (_std * vp_k)
    _val       = math.max(_poc - (_std * vp_k), 0.0000000001)  // Anti-abyss floor
    _sar       = ta.sar(0.02, 0.02, 0.2)
    [_vwap, _vah, _poc, _val, _sar]

// ── MTF extraction via request.security() ──
[rd_v_1, rd_vah_1, rd_poc_1, rd_val_1, rd_sar_1] = request.security(syminfo.tickerid, rd_tf1, f_calc_radar_data(), lookahead=barmerge.lookahead_off)
[rd_v_2, rd_vah_2, rd_poc_2, rd_val_2, rd_sar_2] = request.security(syminfo.tickerid, rd_tf2, f_calc_radar_data(), lookahead=barmerge.lookahead_off)
[rd_v_3, rd_vah_3, rd_poc_3, rd_val_3, rd_sar_3] = request.security(syminfo.tickerid, rd_tf3, f_calc_radar_data(), lookahead=barmerge.lookahead_off)
[rd_v_4, rd_vah_4, rd_poc_4, rd_val_4, rd_sar_4] = request.security(syminfo.tickerid, rd_tf4, f_calc_radar_data(), lookahead=barmerge.lookahead_off)
[rd_v_5, rd_vah_5, rd_poc_5, rd_val_5, rd_sar_5] = request.security(syminfo.tickerid, rd_tf5, f_calc_radar_data(), lookahead=barmerge.lookahead_off)

// ── Global averages (5-TF confluence) ──
f_avg5(v1, v2, v3, v4, v5) =>
    sum = (na(v1)?0.:v1) + (na(v2)?0.:v2) + (na(v3)?0.:v3) + (na(v4)?0.:v4) + (na(v5)?0.:v5)
    cnt = (na(v1)?0:1) + (na(v2)?0:1) + (na(v3)?0:1) + (na(v4)?0:1) + (na(v5)?0:1)
    cnt > 0 ? sum / cnt : na

rd_v_glb   = f_avg5(rd_v_1,   rd_v_2,   rd_v_3,   rd_v_4,   rd_v_5)
rd_poc_glb = f_avg5(rd_poc_1, rd_poc_2, rd_poc_3, rd_poc_4, rd_poc_5)
rd_vah_glb = f_avg5(rd_vah_1, rd_vah_2, rd_vah_3, rd_vah_4, rd_vah_5)
rd_val_glb = f_avg5(rd_val_1, rd_val_2, rd_val_3, rd_val_4, rd_val_5)

// ========================================================================================================
// HISTORICAL VWAPS (DAILY / WEEKLY / MONTHLY)
// ========================================================================================================
var float cum_vol_d = 0., var float cum_pv_d = 0.
var float cum_vol_w = 0., var float cum_pv_w = 0.
var float cum_vol_m = 0., var float cum_pv_m = 0.

if ta.change(time("D")) != 0
    cum_vol_d := 0., cum_pv_d := 0.
if ta.change(time("W")) != 0
    cum_vol_w := 0., cum_pv_w := 0.
if ta.change(time("M")) != 0
    cum_vol_m := 0., cum_pv_m := 0.

cum_vol_d += volume, cum_pv_d += hlc3 * volume
cum_vol_w += volume, cum_pv_w += hlc3 * volume
cum_vol_m += volume, cum_pv_m += hlc3 * volume

float vwap_d = cum_vol_d > 0 ? cum_pv_d / cum_vol_d : close
float vwap_w = cum_vol_w > 0 ? cum_pv_w / cum_vol_w : close
float vwap_m = cum_vol_m > 0 ? cum_pv_m / cum_vol_m : close

// ========================================================================================================
// RADAR CONTROL ARRAYS
// ========================================================================================================
var box[]   radar_boxes     = array.new_box()
var label[] radar_labels    = array.new_label()
var line[]  radar_mid_lines = array.new_line()
var float[] radar_tops      = array.new_float()
var float[] radar_bots      = array.new_float()
var int[]   radar_count     = array.new_int()
var int[]   radar_up_weight = array.new_int()
var int[]   radar_dn_weight = array.new_int()

// ========================================================================================================
// DRAWING AND DEDUPLICATION FUNCTIONS
// ========================================================================================================

// Checks whether 'val' already exists in an existing block (deduplication)
f_check_collision(val) =>
    int found = -1
    if not na(val) and array.size(radar_tops) > 0
        for i = 0 to array.size(radar_tops) - 1
            float t = array.get(radar_tops, i)
            float b = array.get(radar_bots, i)
            bool inside     = val <= t and val >= b
            bool near_top = math.abs(val - t) / math.max(val, 1e-10) * 100.0 <= merge_margin
            bool near_bot = math.abs(val - b) / math.max(val, 1e-10) * 100.0 <= merge_margin
            if inside or near_top or near_bot
                found := i
                break
    found

// Processes and draws an individual wall with weight and smart fusion
f_process_radar(tf_txt, val, line_type, is_global, int weight) =>
    if not na(val) and val > 0
        int idx = f_check_collision(val)
        bool is_sup    = close >= val
        color c_base   = is_sup ? c_sup : c_res
        string tag_sr  = is_sup ? s_sup : s_res
        string emojis  = ""
        if weight > 0
            for i = 1 to math.min(weight, 5)
                emojis += (is_sup ? "▲" : "▼")

        if idx == -1 or not show_dedup
            // New wall — higher weight = more opaque and visible
            int transp_bg = int(math.max(30, 97 - (weight * 7)))
            int transp_bd = int(math.max(15, 95 - (weight * 8)))
            int transp_ln = int(math.max(20, 95 - (weight * 7)))
            string prefix = is_global ? "🌟 " : ""
            string txt    = emojis + " " + prefix + line_type + " " + tf_txt + tag_sr

            b  = box.new(bar_index + 1, val, bar_index + 25, val,
                 border_color=color.new(c_base, transp_bd),
                 bgcolor=color.new(c_base, transp_bg),
                 border_width=1, force_overlay=true)
            lb = label.new(bar_index + 25, val, txt,
                 style=label.style_none, textcolor=color.new(c_base, 20),
                 size=font_size, textalign=text.align_left, force_overlay=true) // <--- The selector goes here
            l  = line.new(bar_index + 1, val, bar_index + 25, val,
                 color=color.new(c_base, transp_ln), style=line.style_dotted, force_overlay=true)

            array.push(radar_boxes, b), array.push(radar_labels, lb), array.push(radar_mid_lines, l)
            array.push(radar_tops, val), array.push(radar_bots, val), array.push(radar_count, weight)
            array.push(radar_up_weight, is_sup ? weight : 0)
            array.push(radar_dn_weight, is_sup ? 0 : weight)
        else
            // Existing wall — fusion and intensification
            box   b_target  = array.get(radar_boxes,     idx)
            label lb_target = array.get(radar_labels,    idx)
            line  l_target  = array.get(radar_mid_lines, idx)

            float t_current = array.get(radar_tops, idx)
            float b_current = array.get(radar_bots, idx)
            float new_top = math.max(t_current, val)
            float new_bot = math.min(b_current, val)
            float new_mid = (new_top + new_bot) / 2.0

            array.set(radar_tops, idx, new_top)
            array.set(radar_bots, idx, new_bot)
            box.set_top(b_target, new_top), box.set_bottom(b_target, new_bot)
            line.set_y1(l_target, new_mid), line.set_y2(l_target, new_mid)
            label.set_y(lb_target, new_mid)

            string current_txt  = label.get_text(lb_target)
            string clean_txt  = str.replace_all(str.replace_all(current_txt, s_sup, ""), s_res, "")
            label.set_text(lb_target, emojis + clean_txt + " + " + line_type + " " + tf_txt + tag_sr)

            int new_strength = array.get(radar_count, idx) + weight
            array.set(radar_count, idx, new_strength)

            // Polarity tally — accumulate weight by direction per block
            int up_w = array.get(radar_up_weight, idx) + (is_sup ? weight : 0)
            int dn_w = array.get(radar_dn_weight, idx) + (is_sup ? 0 : weight)
            array.set(radar_up_weight, idx, up_w)
            array.set(radar_dn_weight, idx, dn_w)

            // Dominant-polarity color for the fused block.
            // Tiebreaker: price position vs block mid
            //   (above mid → support, below mid → resistance).
            color c_fused = up_w > dn_w ? c_sup
                          : up_w < dn_w ? c_res
                          : (close >= new_mid ? c_sup : c_res)

            int t_bg = int(math.max(25, 97 - (new_strength * 7)))
            int t_bd = int(math.max(10, 95 - (new_strength * 8)))
            int t_ln = int(math.max(15, 95 - (new_strength * 7)))

            box.set_border_color(b_target, color.new(c_fused, t_bd))
            box.set_bgcolor(b_target,      color.new(c_fused, t_bg))
            line.set_color(l_target,       color.new(c_fused, t_ln))
            label.set_textcolor(lb_target, color.new(c_fused, 20))
            if new_strength >= 5
                box.set_border_width(b_target, 2)

// Helper: processes POC + VAH + VAL of a TF in one pass
f_draw_vp(tf_txt, v_vah, v_poc, v_val, is_global, int weight) =>
    if show_poc
        f_process_radar(tf_txt, v_poc, "POC", is_global, weight)
    if show_va
        f_process_radar(tf_txt, v_vah, "VAH", is_global, weight)
        f_process_radar(tf_txt, v_val, "VAL", is_global, weight)

// ========================================================================================================
// MAIN LOOP — Clears old objects and redraws everything on barstate.islast
// ========================================================================================================
if barstate.islast
    // 1. Clear old visual objects
    if array.size(radar_boxes) > 0
        for i = 0 to array.size(radar_boxes) - 1
            box.delete(array.get(radar_boxes, i))
            label.delete(array.get(radar_labels, i))
            line.delete(array.get(radar_mid_lines, i))

    array.clear(radar_boxes),  array.clear(radar_labels),  array.clear(radar_mid_lines)
    array.clear(radar_tops),   array.clear(radar_bots),    array.clear(radar_count)
    array.clear(radar_up_weight), array.clear(radar_dn_weight)

    // 3. Radar MTF VWMAs
    if show_vwma_rd
        f_process_radar("🌎",  rd_v_glb, "VWMA", true,  3)
        f_process_radar(rd_tf5, rd_v_5,  "VWMA", false, 5)
        f_process_radar(rd_tf4, rd_v_4,  "VWMA", false, 3)
        f_process_radar(rd_tf3, rd_v_3,  "VWMA", false, 2)
        f_process_radar(rd_tf2, rd_v_2,  "VWMA", false, 1)
        f_process_radar(rd_tf1, rd_v_1,  "VWMA", false, 1)

    // 3b. Anchored VWAPs (Daily / Weekly / Monthly) — true session-anchored levels
    if show_avwap_dwm
        f_process_radar("D", vwap_d, "AVWAP", false, 3)
        f_process_radar("W", vwap_w, "AVWAP", false, 5)
        f_process_radar("M", vwap_m, "AVWAP", false, 5)

    // 4. Volume Profile: POC, VAH, VAL per TF
    f_draw_vp("🌎",  rd_vah_glb, rd_poc_glb, rd_val_glb, true,  3)
    f_draw_vp(rd_tf5, rd_vah_5,  rd_poc_5,   rd_val_5,   false, 5)
    f_draw_vp(rd_tf4, rd_vah_4,  rd_poc_4,   rd_val_4,   false, 3)
    f_draw_vp(rd_tf3, rd_vah_3,  rd_poc_3,   rd_val_3,   false, 2)
    f_draw_vp(rd_tf2, rd_vah_2,  rd_poc_2,   rd_val_2,   false, 1)
    f_draw_vp(rd_tf1, rd_vah_1,  rd_poc_1,   rd_val_1,   false, 1)

    // 5. SAR (optional)
    if show_sar
        f_process_radar(rd_tf5, rd_sar_5, "SAR", false, 5)
        f_process_radar(rd_tf4, rd_sar_4, "SAR", false, 3)
        f_process_radar(rd_tf3, rd_sar_3, "SAR", false, 2)
        f_process_radar(rd_tf2, rd_sar_2, "SAR", false, 1)
        f_process_radar(rd_tf1, rd_sar_1, "SAR", false, 1)

// ========================================================================================================
// INFO PANEL — NEAREST WALL (ABOVE AND BELOW)
// ========================================================================================================
var float nearest_res = na  // Nearest resistance above
var float nearest_sup = na  // Nearest support below
var float dist_res = na  // distance %
var float dist_sup = na

if barstate.islast and array.size(radar_tops) > 0
    float best_res = 999999., float best_sup = 999999.
    nearest_res := na, nearest_sup := na

    for i = 0 to array.size(radar_tops) - 1
        float t = array.get(radar_tops, i)
        float b = array.get(radar_bots, i)
        float mid_wall = (t + b) / 2.0

        if mid_wall > close  // above → resistance
            d = mid_wall - close
            if d < best_res
                best_res := d, nearest_res := mid_wall
        else  // below → support
            d = close - mid_wall
            if d < best_sup
                best_sup := d, nearest_sup := mid_wall

    dist_res := not na(nearest_res) ? math.round((nearest_res - close) / close * 100, 2) : na
    dist_sup := not na(nearest_sup) ? math.round((close - nearest_sup) / close * 100, 2) : na

if show_panel and barstate.islast
    tbl_pos = panel_pos == "Top Right"    ? position.top_right    :
              panel_pos == "Top Left"     ? position.top_left     :
              panel_pos == "Bottom Right" ? position.bottom_right : position.bottom_left

    var table tbl = table.new(tbl_pos, 2, 5,
         border_width=1, border_color=color.new(c_neutral, 70),
         frame_width=2,  frame_color=color.new(c_black, 20))

    // Header
    table.cell(tbl, 0, 0, "🧱 MGI RADAR",      text_color=color.new(c_sup,   0), text_size=font_size, bgcolor=color.new(c_black, 10), text_halign=text.align_center)
    table.cell(tbl, 1, 0, "Institutional Walls Engine", text_color=color.new(c_neutral,30), text_size=font_size, bgcolor=color.new(c_black, 10), text_halign=text.align_center)

    // Resistance above
    res_txt   = not na(nearest_res) ? str.tostring(nearest_res, format.mintick) : "—"
    dist_r_txt= not na(dist_res) ? "+" + str.tostring(dist_res, "#.##") + "%" : "—"
    table.cell(tbl, 0, 1, s_lbl_above, text_color=color.new(c_res, 10),    text_size=font_size, bgcolor=color.new(c_black, 65), text_halign=text.align_left)
    table.cell(tbl, 1, 1, res_txt,     text_color=color.new(c_res, 0),     text_size=font_size, bgcolor=color.new(c_black, 65), text_halign=text.align_right)

    // Resistance distance
    table.cell(tbl, 0, 2, s_lbl_dist,  text_color=color.new(c_neutral, 20), text_size=font_size, bgcolor=color.new(c_black, 75), text_halign=text.align_left)
    table.cell(tbl, 1, 2, dist_r_txt,  text_color=color.new(c_res, 0),     text_size=font_size, bgcolor=color.new(c_black, 75), text_halign=text.align_right)

    // Support below
    sup_txt   = not na(nearest_sup) ? str.tostring(nearest_sup, format.mintick) : "—"
    dist_s_txt= not na(dist_sup) ? "-" + str.tostring(dist_sup, "#.##") + "%" : "—"
    table.cell(tbl, 0, 3, s_lbl_below, text_color=color.new(c_sup, 10),    text_size=font_size, bgcolor=color.new(c_black, 65), text_halign=text.align_left)
    table.cell(tbl, 1, 3, sup_txt,     text_color=color.new(c_sup, 0),     text_size=font_size, bgcolor=color.new(c_black, 65), text_halign=text.align_right)

    // Support distance
    table.cell(tbl, 0, 4, s_lbl_dist,  text_color=color.new(c_neutral, 20), text_size=font_size, bgcolor=color.new(c_black, 75), text_halign=text.align_left)
    table.cell(tbl, 1, 4, dist_s_txt,  text_color=color.new(c_sup, 0),     text_size=font_size, bgcolor=color.new(c_black, 75), text_halign=text.align_right)

// ========================================================================================================
// COLLISION ALERTS
// ========================================================================================================
// Detects collision with VWAP or Wall (corrected for stateless logic)
f_hit(val) =>
    // Pure math logic replaces ta.cross() to avoid the short-circuit error
    bool crossed = (close[1] <= val[1] and close > val) or (close[1] >= val[1] and close < val)
    not na(val) and val > 0 and (crossed or (math.abs(close - val) / close * 100 <= 0.15))

// Each f_hit() call uses [1] historical refs and must execute on every bar.
// Inline chaining with `or` risks short-circuit skipping calls (Pine CW10002).
// Pattern: assign each result to a variable first, then OR the bools.
hit_vwap_d = f_hit(vwap_d)
hit_vwap_w = f_hit(vwap_w)
hit_vwap_m = f_hit(vwap_m)
hit_vwap   = hit_vwap_d or hit_vwap_w or hit_vwap_m
hit_poc    = f_hit(rd_poc_glb)
hit_vah    = f_hit(rd_vah_glb)
hit_val    = f_hit(rd_val_glb)
hit_vp     = hit_poc or hit_vah or hit_val

bool al_vwap_fire = hit_vwap  and not hit_vwap[1]
bool al_vp_fire   = hit_vp    and not hit_vp[1]

if al_vwap and al_vwap_fire and barstate.isconfirmed
    alert(s_al_vwap, alert.freq_once_per_bar)

if al_vp and al_vp_fire and barstate.isconfirmed
    alert(s_al_vp, alert.freq_once_per_bar)

alertcondition(al_vwap_fire, "VWAP Collision",          "MGI Radar: Price hit an Institutional VWAP level.")
alertcondition(al_vp_fire,   "Volume Profile Wall Hit",  "MGI Radar: Price hit a POC / VAH / VAL zone.")
alertcondition(false, "HOW TO SETUP ALERTS (READ)", "Select 'Any alert() function call' in the condition menu.")
````
