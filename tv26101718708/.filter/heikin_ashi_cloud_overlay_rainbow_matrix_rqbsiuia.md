# Heikin Ashi Cloud Overlay | Rainbow Matrix

- url: https://www.tradingview.com/script/RQbsiuia-Heikin-Ashi-Cloud-Overlay-Rainbow-Matrix/
- type: indicator
- pine_id: PUB;0f9aac4f1d864d7ea41511533de65d35
- version: 2.0

## Description

GENERAL OVERVIEW
The Heikin Ashi Cloud Overlay renders a Heikin Ashi cloud directly on top of traditional candlesticks, giving traders both views in a single chart. HA candles smooth macro trend perception by filtering individual-bar noise, but they sacrifice entry-bar precision because each HA candle does not represent the actual price range traded on that bar. This script preserves both signals simultaneously: the HA cloud surfaces directional context, while the underlying real candles preserve precise execution-bar timing.

A compact corner HUD reports current HA direction, consecutive streak length, and body-size anomalies relative to a 20-bar rolling average — useful for monitoring momentum exhaustion and impulsive expansion in real time without analyzing the cloud manually.

The script adds a visual intelligence layer on top of the standard HA pattern: cloud fill opacity dynamically reflects body intensity (impulsive bars render densely opaque, normal bars render lightly), and small colored dots flag body anomalies (current body > 3× rolling average) directly on the chart.

[image]https://www.tradingview.com/x/BRKJsuNY/[/image]

WHAT IS THE THEORY BEHIND THIS INDICATOR?
Heikin Ashi candles are derived from traditional OHLC via a recursive smoothing formula introduced by Munehisa Homma in 18th-century Japanese rice trading and popularized in modern Western technical analysis through the work of Dan Valcu and others. The transformation produces candles that emphasize trend persistence over discrete price action: consecutive same-color HA candles indicate ongoing directional pressure, while doji-like HA candles or sudden color flips often signal pivots.

The trade-off is well-known: HA candles do not show real OHLC. The haOpen of each candle is the average of the previous haOpen and haClose, not the actual session open. This makes HA excellent for trend reading but unreliable for entry timing — orders need to reference the actual price range of the bar, not the smoothed projection.

The conventional solutions are either to switch back and forth between HA and regular candle views (cognitive overhead), or to use HA as the primary chart and lose precision on entries (execution cost). This indicator takes a third approach: render the HA candles as a transparent overlay envelope on top of the standard candlesticks. The trader sees both at once. The HA envelope communicates trend context; the underlying candles preserve real-bar precision.

The state machine layered on top — direction tracking, streak counting, and body-size anomaly detection against a rolling average — converts the visual cloud into a numerical readout, surfacing exhaustion and impulsive moves that might be missed at a glance.

HA CLOUD OVERLAY FEATURES

The indicator includes 5 main components:
Heikin Ashi Cloud Overlay
Body Intensity Modulation (dynamic opacity)
Body Anomaly Visual Markers
HA State HUD Panel
Three Optional Alerts

HEIKIN ASHI CLOUD OVERLAY
🔹 What It Does
For each bar on the chart, the indicator computes the four Heikin Ashi values (haOpen, haClose, haHigh, haLow) using Pine Script's canonical recursive formula. It then renders a thin envelope between haHigh and haLow with semi-transparent fill, plotted on top of the underlying traditional candles.

🔹 Method
The computation follows the standard HA definition:
◇ haClose = (open + high + low + close) / 4
◇ haOpen = average of the previous haOpen and the previous haClose (recursive)
◇ haHigh = max of (high, haOpen, haClose)
◇ haLow = min of (low, haOpen, haClose)

A `var float ha_open = na` seed pattern handles the first-bar initialization safely, avoiding NA propagation that would corrupt the recursive chain.

🔹 Visual Behavior
The envelope is rendered as a thin top-bottom band with translucent fill. The fill color reflects the HA direction: bullish (haClose ≥ haOpen) renders in the configured bull color (TradingView native teal by default); bearish (haClose < haOpen) renders in the bear color (TradingView native red by default). An optional midline (dotted) at the (haOpen + haClose) / 2 level can be toggled for traders who prefer an explicit midpoint reference.

BODY INTENSITY MODULATION
🔹 What It Does
The cloud fill transparency is dynamically modulated based on the current HA body size relative to the 20-bar rolling average. Bars with above-average body push the fill toward more opaque, surfacing impulsive expansion clusters visually without requiring HUD analysis.

🔹 Tier Logic
◇ Body < 1× average: standard transparency (user-configured slider value)
◇ Body 1-2× average: −10 transparency (notable bar — slightly more opaque)
◇ Body 2-3× average: −30 transparency (strong bar — clearly more opaque)
◇ Body ≥ 3× average: −50 transparency, floor 20 (anomaly — densely opaque)

The floor cap of 20 prevents the fill from becoming so opaque that the underlying candle wicks become unreadable, preserving the dual-view principle of the indicator.

🔹 Why It Helps
Body intensity modulation converts the cloud from a static color band into a momentum-aware visualization. During quiet conditions, the cloud whispers; during impulsive expansion or capitulation phases, the cloud intensifies visually. Traders monitoring multiple charts can identify regime changes peripherally without focusing on any single chart's HUD.

🔹 Toggle
The feature is enabled by default and can be disabled via the "Body Intensity Cloud Opacity" input in the HA CLOUD group, which restores fixed transparency from the slider.

BODY ANOMALY VISUAL MARKERS
🔹 What It Does
A small colored dot appears on the chart whenever the current HA body exceeds 3× the 20-bar rolling average. Bull anomalies render as a dot below the bar (location.belowbar); bear anomalies render as a dot above the bar (location.abovebar). Dot colors match the configured bull/bear palette.

🔹 Why It Helps
The markers convert the alert-only body anomaly detection into a persistent visual signal that remains visible on chart history. Traders reviewing past price action can identify impulsive expansion or capitulation events at a glance, without scrolling through alert history or replaying bars.

🔹 Independent of the Alert
The visual markers and the body anomaly alert are independently toggleable. Traders can show the markers without enabling the alert (visual-only mode) or enable the alert without showing the markers (sound/notification-only mode).

🔹 Toggle
Enabled by default via the "Show Body Anomaly Markers" input in the HA CLOUD group.

HA STATE HUD PANEL
🔹 What It Shows
A compact 4-row corner panel reports three live values:
◇ Direction — current HA candle direction (Bull / Bear), color-coded
◇ Streak — consecutive same-direction count (in current locale, e.g., "7 velas (candles)" in PT)
◇ Avg Body — the average HA body size over the last 20 bars, expressed as a percentage of price

🔹 Why It Helps
The HUD converts the cloud into a numerical readout. Instead of visually estimating streak length or body proportion, traders can read the exact values on each bar. This is particularly useful for traders monitoring multiple charts or running automated rules where consecutive-bar conditions need to be tracked precisely.

🔹 Customization
The HUD can be positioned in any of the four chart corners and rendered in any of five font sizes. The Direction row uses contrasting colors (bull vs bear) for immediate parsing.

THREE OPTIONAL ALERTS
🔹 Alert Types
Each alert is independently toggleable in the indicator settings:

◇ HA Direction Change — fires on the close of a confirmed bar when the HA direction flips (bull→bear or bear→bull). Useful as a confirmation filter on top of other entry signals.

◇ HA Streak Exhaustion — fires when the absolute streak length crosses a user-configurable threshold (default 7). Long consecutive streaks often precede mean-reversion phases, especially in ranging markets.

◇ HA Body Anomaly — fires when the current HA body exceeds 3× the 20-bar rolling average. Anomalous body sizes typically signal impulsive expansion, capitulation, or news-driven moves worth investigating.

🔹 Firing Mechanism
All alerts are gated by `barstate.isconfirmed`, which means they only trigger on the close of the bar that satisfies the condition — never intra-bar. This prevents false signals from intrabar fluctuations that get rejected before close. Each alert uses `alert.freq_once_per_bar` to avoid duplicate firings on the same candle.

🔹 alertcondition() Mode
A dummy `alertcondition` titled "HOW TO SETUP ALERTS (READ)" is exposed at the bottom of the script. It provides setup guidance via its message field, instructing users to select "Any alert() function call" in the TradingView alert condition menu and filter individual alerts via the indicator settings.

MULTILINGUAL INTERFACE
The indicator supports five languages for the HUD display and alert messages: English (default), Português, Español, Русский, and 中文 (Chinese). Code, comments, and configuration tooltips remain in English regardless of the selected language.

For reference, examples of multilingual UI strings used in the HUD:
◇ Direction labels: "Direction:" / "Direção:" / "Dirección:" / "Направление:" / "方向:"
◇ Direction text: "🟢 BULL"/"🔴 BEAR" / "🟢 ALTA"/"🔴 BAIXA" / "🟢 ALCISTA"/"🔴 BAJISTA" / "🟢 БЫЧИЙ"/"🔴 МЕДВЕЖИЙ" / "🟢 多头"/"🔴 空头"
◇ Streak units use a bilingual pattern: "candles" stays in English as a universal technical term; native terms appear in parentheses where the local equivalent is well-established (e.g., "7 velas (candles)").

CUSTOM PALETTE TOGGLE
🔹 What It Does
By default, the indicator uses native TradingView teal/red colors for visual familiarity. A "Use Custom Cloud Colors" toggle in the settings switches to user-configurable bull/bear colors, useful for traders who want to align the cloud palette with their personal indicator stack or color preferences.

HOW TO USE
This indicator is a visualization tool, not a signal generator. It surfaces three categories of structural information: HA direction (smoothed trend context), streak length (momentum persistence), and body anomalies (impulsive moves).

🔹 Reading the Cloud
◇ Bull cloud (default teal) = current HA candle is bullish (haClose ≥ haOpen).
◇ Bear cloud (default red) = current HA candle is bearish (haClose < haOpen).
◇ A long sequence of same-color HA candles indicates strong directional pressure; mixed colors or doji-like HA candles indicate consolidation or pivot zones.
◇ Cloud density (opacity): denser fills mark bars with above-average body — pay attention to these zones, they often correspond to ignition or capitulation phases.
◇ Anomaly dots: when a dot appears below a bull bar or above a bear bar, the bar's body is 3× the recent average — exceptional impulse worth contextualizing against your other signals.

🔹 Reading the HUD
◇ Direction row: parse the current HA candle's directional state at a glance.
◇ Streak row: |streak| ≥ 7 → trend is mature, increasing probability of mean reversion or pullback. Streak just flipped sign → fresh direction.
◇ Avg Body row: current bar body > 3× this value → impulsive expansion or capitulation, worth investigating contextually.

🔹 Tactical Reading
◇ HA color flip + confirmation on the underlying candle: potential trend reversal or pullback entry.
◇ HA streak crosses the exhaustion threshold while price approaches a key level (from another indicator or manual S/R): increased probability of structural reaction.
◇ Body anomaly during otherwise quiet conditions: impulsive move (often news-driven or stop-cascade) — trade with reduced size or wait for retest.
◇ Cluster of dense-opacity bars: regime change or ongoing impulsive move — momentum is structurally elevated.

🔹 Multi-Indicator Workflow
The HA Cloud Overlay is designed to layer cleanly with other indicators. It does not add lines or boxes that compete visually with structural indicators (VWAP, Volume Profile, S/R). The cloud sits behind the candles, the markers are minimal dots, and the HUD sits in a corner — total chart footprint is minimal.

INPUTS EXPLAINED
🔹 System Language
Display language for the HUD and alert messages. Options: English (default), Português, Español, Русский, 中文.

🔹 Show Cloud Envelope
Master toggle for the HA top-bottom envelope and fill.

🔹 Cloud Fill Transparency
Base alpha of the cloud fill (60 = denser, 95 = barely visible). Floor of 60 keeps candle wicks readable. Default 80. When Body Intensity Modulation is ON, this value is the baseline; bars with above-average body intensity become progressively more opaque from this baseline.

🔹 Show HA Midline (dots)
Optional thin dotted line at (haOpen + haClose) / 2.

🔹 Use Custom Cloud Colors
OFF: native TradingView teal/red. ON: apply custom bull/bear colors below.

🔹 Custom Bull Color / Custom Bear Color
Used when "Use Custom Cloud Colors" is ON.

🔹 Body Intensity Cloud Opacity
When ON: cloud fill becomes progressively more opaque on bars with above-average body size. When OFF: cloud uses fixed transparency from the slider above. Recommended ON.

🔹 Show Body Anomaly Markers
When ON: small colored dots appear on bars whose body exceeds 3× the 20-period average. Independent of the body anomaly alert.

🔹 Show HA State HUD
Toggle for the corner HUD reporting Direction / Streak / Avg Body.

🔹 HUD Position
Top Right (default), Top Left, Bottom Right, Bottom Left.

🔹 Font Size
Tiny, Small (default), Normal, Large, Huge.

🔹 Streak Warning Threshold
Streak length at which the Streak Exhaustion alert fires. Range 3–30, default 7.

🔹 Alert: HA Direction Change / HA Streak Extreme / HA Body Anomaly
Independent toggles for each of the three alert types.

IMPORTANT NOTES
The Heikin Ashi Cloud Overlay works on any timeframe and any instrument. The HA computation is timeframe-agnostic — it transforms whatever OHLC data the chart provides.

Alerts fire once per confirmed bar. Historical bars never repaint after they close. The live bar updates intra-bar as expected for a real-time indicator, but alerts will only fire after the bar closes. Body anomaly visual markers can update intra-bar (preview behavior) and settle on close.

The body anomaly threshold (3× rolling average) and streak warning threshold (default 7) are derived from empirical observation across common timeframes and instruments. Both are user-configurable and should be tuned to the trader's instrument and timeframe — high-volatility crypto on 1m may warrant a higher anomaly multiplier than large-cap equities on Daily.

The 20-bar body rolling average uses `ta.sma` of the percentage-based body size. The first 20 bars after script start will show partial values; once enough history is available, the value stabilizes.

The body intensity modulation tier floors (50, 30, 20) are calibrated to preserve candle wick readability even on extreme anomaly bars — the floor 20 ensures the cloud never becomes fully opaque.

Pine Script v6. Open-source under Mozilla Public License 2.0.

UNIQUENESS
The Heikin Ashi Cloud Overlay differs from the standard TradingView Heikin Ashi chart type and from other HA-based indicators in four structural ways.

First, it preserves both views simultaneously rather than replacing one with the other. Standard HA chart mode hides the real candles entirely; this overlay keeps the underlying candles visible at all times, giving traders smoothed trend context (the cloud) and precise entry-bar timing (the underlying candles) in the same visual without context-switching cost.

Second, the cloud fill opacity is dynamically modulated by body intensity relative to a 20-bar rolling average. Standard HA cloud indicators render fills with a single static transparency; this script renders impulsive bars (≥1×, ≥2×, ≥3× average body) with progressively more opaque fills, transforming the cloud from a static visualization into a momentum-aware density map. Capitulation, ignition, and impulsive expansion phases become visually identifiable peripheral signals.

Third, it adds an explicit state machine layer over the raw HA visualization. Direction tracking, consecutive streak counting, 20-bar rolling body-size anomaly detection, and on-chart visual anomaly markers convert the visual cloud into a numerical readout reported live on a corner HUD. This converts subjective visual estimation (is this a long streak? is this body unusually large?) into deterministic measurements with configurable thresholds and a persistent visual record on the chart history.

Fourth, it exposes three independently-toggleable alerts (direction change, streak exhaustion, body anomaly) gated by bar confirmation, making the indicator usable as a confirmation filter or trigger source in automated workflows. Most HA-based indicators are visualization-only or expose a single direction-flip alert; the multi-condition alert set here is designed for traders building structured rules around HA state rather than just observing it.

The combination of dual-view preservation, body-intensity opacity modulation, state machine readout, visual anomaly markers, and multilingual UI produces a single overlay that combines the readability of Heikin Ashi smoothing with the precision of real candles, the rigor of a deterministic state readout, and the visual intuition of a density-aware momentum map.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rainbowmatrix
//
// ════════════════════════════════════════════════════════════════════════════════
// HEIKIN ASHI CLOUD OVERLAY
//
// An overlay that renders a Heikin Ashi cloud directly on traditional candlesticks,
// giving traders both views in a single chart: HA smooths macro trend perception,
// while traditional candles preserve precise entry-bar timing. A compact HUD reports
// current HA direction, streak length, and body-size anomalies relative to a 20-bar
// average, surfacing momentum exhaustion and impulsive expansion in real time.
//
// METHOD:
//   1. Computes Heikin Ashi OHLC iteratively from traditional OHLC, preserving Pine
//      Script's standard formula.
//   2. Renders a thin envelope (haOpen/haClose top-bottom) with transparent fill,
//      avoiding visual conflict with the underlying candles.
//   3. Maintains a state machine tracking direction (bull/bear), consecutive streak,
//      and 20-bar body-size average for anomaly detection.
//   4. Surfaces three optional alerts: direction flip, streak exhaustion (configurable
//      threshold), and body anomaly (current body > 3× the rolling average).
//
// PALETTE:
//   Native TradingView teal/red by default for visual familiarity. A custom-colors
//   toggle exposes a canonical 4-tier rainbow palette (purple→red→orange→yellow
//   for bull exhaustion ladder; mirrored on the bear side) for traders preferring
//   intensity-coded direction states.
//
// ════════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Heikin Ashi Cloud Overlay | Rainbow Matrix", overlay = true)

// ========================================================================================================
// COLOR PALETTE (Rainbow Matrix canonical — see context §3.4)
// ========================================================================================================
c_up_4 = color.purple     // Black Swan High (extreme bull exhaustion)
c_up_3 = color.red        // Z-Exhaustion High (saturated bull)
c_up_2 = color.orange     // Z-Alert High (mid bull)
c_up_1 = color.yellow     // Z-Breathing High (light bull)
c_dn_1 = color.green      // Z-Breathing Low (light bear)
c_dn_2 = color.teal       // Z-Alert Low (mid bear)
c_dn_3 = color.blue       // Z-Exhaustion Low (saturated bear)
c_dn_4 = color.aqua       // Black Swan Low (extreme bear exhaustion)
c_neutral = color.gray
c_black   = color.black

// ========================================================================================================
// TV-NATIVE HEIKIN ASHI PALETTE (per §9.4 — operator-decided exception to §4 rule #1
//    for visual familiarity with TradingView's stock HA chart. Users may override via
//    `use_custom_colors=true` to apply their own colors below.)
// ========================================================================================================
ha_bull_default = color.rgb(8, 153, 129)    // #089981 — TradingView native teal
ha_bear_default = color.rgb(242, 54, 69)    // #F23645 — TradingView native red

// ========================================================================================================
// GLOBAL SETTINGS
// ========================================================================================================
g_global = "GLOBAL SETTINGS"
font_size = input.string("Small", "Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = g_global, tooltip = "Font size for the H.Ashi State HUD. Default Small keeps the HUD compact — larger sizes block chart space (see §9.8 rule 4).")

// ========================================================================================================
// HA CLOUD
// ========================================================================================================
g_cloud = "H.Ashi CLOUD"
show_cloud        = input.bool(true, "Show Cloud Envelope", group = g_cloud, tooltip = "Master toggle for the Heikin Ashi cloud overlay (high/low envelope + colored fill).")
fill_transparency = input.int(90, "Cloud Fill Transparency", minval = 60, maxval = 95, step = 1, group = g_cloud, tooltip = "Alpha of the cloud fill. 60 = denser cloud, 95 = barely visible. Floor is 60 (see §9.8 rule 1) to keep candle wicks readable underneath. Default 90 (cloud whispers, lets price action lead).")
show_centerline   = input.bool(false, "Show H.Ashi Midline (dots)", group = g_cloud, tooltip = "Optional thin dotted line at (ha_open + ha_close) / 2 showing the H.Ashi candle midpoint. Off by default to keep chart clean.")
use_custom_colors = input.bool(false, "Use Custom Cloud Colors", group = g_cloud, tooltip = "OFF (default): TradingView native H.Ashi palette (teal #089981 / red #F23645) for visual familiarity. ON: apply your custom Bull / Bear colors below.")
custom_bull_color = input.color(color.rgb(8, 153, 129), "Custom Bull Color", group = g_cloud, inline = "custom_cloud", tooltip = "Applied only when 'Use Custom Cloud Colors' is ON.")
custom_bear_color = input.color(color.rgb(242, 54, 69), "Custom Bear Color", group = g_cloud, inline = "custom_cloud", tooltip = "Applied only when 'Use Custom Cloud Colors' is ON.")
show_intensity_modulation = input.bool(true, "Body Intensity Cloud Opacity", group = g_cloud, tooltip = "When ON: cloud fill becomes progressively more opaque on bars with above-average body size, surfacing impulsive expansion phases visually. When OFF: cloud uses fixed transparency from the slider above. Recommended ON.")
show_anomaly_marker       = input.bool(true, "Show Body Anomaly Markers",    group = g_cloud, tooltip = "When ON: a small colored dot appears below bull / above bear bars whose body exceeds 3× the 20-period average — visual signal of impulsive expansion or capitulation. Independent of the Body Anomaly alert (which can be ON or OFF separately).")

// ========================================================================================================
// HA STATE HUD
// ========================================================================================================
g_hud = "H.Ashi STATE HUD"
show_hud                 = input.bool(true, "Show H.Ashi State HUD", group = g_hud, tooltip = "Show the corner HUD reporting Direction, Streak length, and average body size.")
hud_position             = input.string("Top Right", "HUD Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = g_hud, tooltip = "Position of the H.Ashi State HUD on the chart. Four corners available.")
streak_warning_threshold = input.int(12, "Streak Exhaustion Threshold", minval = 5, maxval = 50, step = 1, group = g_hud, tooltip = "When |streak| crosses this value, the HUD streak cell turns purple/aqua (extreme exhaustion). Also feeds the 'Streak Exhaustion' alert below.")

// ========================================================================================================
// ALERTS
// ========================================================================================================
g_alerts = "ALERTS"
alert_direction_change = input.bool(true,  "Alert on H.Ashi Direction Flip",        group = g_alerts, tooltip = "Fires once per bar on confirmed close when the H.Ashi candle flips direction (bull→bear or bear→bull).")
alert_streak_extreme   = input.bool(true,  "Alert on Streak Exhaustion",        group = g_alerts, tooltip = "Fires once when |streak| crosses above the Streak Exhaustion Threshold (see HUD group).")
alert_body_anomaly     = input.bool(false, "Alert on Body Anomaly (3× avg)",    group = g_alerts, tooltip = "Fires when the current H.Ashi body is more than 3× the 20-period average — flags a volatility spike. OFF by default (can be noisy on choppy assets).")

// ========================================================================================================
// HTF CLOUD (Higher Timeframe HA Cloud overlay)
// ========================================================================================================
g_htf = "HTF CLOUD"
show_htf_cloud   = input.bool(false, "Show HTF H.Ashi Cloud", group = g_htf, tooltip = "Render a second H.Ashi cloud from a higher timeframe behind the local cloud. Useful for trend alignment context — when HTF and local cloud share direction, the trade is with the macro trend; when they diverge, it's a counter-trend setup. OFF by default to keep the chart clean for users who don't need MTF context.")
htf_timeframe    = input.timeframe("D", "Higher Timeframe", group = g_htf, tooltip = "The higher timeframe to read H.Ashi data from. Default Daily covers most intraday charts (5m through 1h). For 1h+ charts consider Weekly; for daily charts consider Monthly. Anti-repaint: HTF values lock in only when the HTF bar closes.")
htf_linewidth    = input.int(2, "HTF Line Width", minval = 1, maxval = 4, step = 1, group = g_htf, tooltip = "Thickness of the HTF cloud outline. Default 2 (thicker than local cloud's 1) creates visual hierarchy — HTF is the background layer, local is the foreground.")
htf_transparency = input.int(95, "HTF Cloud Fill Transparency", minval = 70, maxval = 95, step = 1, group = g_htf, tooltip = "Alpha of the HTF cloud fill. Default 95 (very faint — 'ghost cloud', barely visible). Floor 70 prevents HTF from overwhelming the local cloud visually. When HTF and local align, the ghost cloud reinforces the direction; when they conflict, it serves as a quiet warning. Maintains visual hierarchy: local cloud always more visible than HTF.")

// ========================================================================================================
// PROBABILITY SCORE (Reversal Probability Score)
// ========================================================================================================
g_score = "PROBABILITY SCORE"
show_score        = input.bool(true, "Show Score in HUD", group = g_score, tooltip = "Add a 'Rev. Prob.' row to the H.Ashi State HUD reporting the Reversal Probability Score (0-100). The score is a weighted composite of streak length (40%), body intensity (35%), and recent anomaly density (25%). HIGHER = MORE probability of trend reversal on the next bar (so 75/100 indicates more reversal probability than 20/100). Color tiers: 0-30 GREEN (trend strong, low reversal probability), 30-70 GRAY (neutral / transition zone), 70-100 RED (exhaustion signals high, reversal probable — a ⚠️ emoji appends to the value at this tier for visual reinforcement). Useful as an analytical readout, NOT a signal generator — pair with the Score ≥ 80 alert below for edge-triggered notifications.")
alert_high_score  = input.bool(false, "Alert on Score ≥ 80", group = g_score, tooltip = "Fires once when the Reversal Probability Score crosses 80 from below. OFF by default to avoid duplicate signals with Streak Exhaustion alert — enable selectively when the score's broader composite (streak + body + anomalies) better matches your trading rules than streak alone.")

// ========================================================================================================
// LANGUAGE
// ========================================================================================================
g_lang = "LANGUAGE"
language = input.string("English", "System Language",
     options = ["English", "Português", "Español", "Русский", "中文"],
     tooltip = "Language for HUD labels and alert messages. Affects only the on-chart UI text; code, comments, and configuration tooltips remain in English.",
     group = g_lang)

_l = language == "Português" ? "PT" :
     language == "Español"   ? "ES" :
     language == "Русский"   ? "RU" :
     language == "中文"        ? "ZH" : "EN"

// ========================================================================================================
// MULTILINGUAL UI STRINGS (EN/PT/ES/RU/ZH)
// ========================================================================================================
// HUD static labels
var string s_hud_title    = _l=="PT" ? "Sobreposição H.Ashi Cloud" : _l=="ES" ? "Superposición H.Ashi Cloud" : _l=="RU" ? "Наложение H.Ashi Cloud"     : _l=="ZH" ? "H.Ashi 云叠加" : "H.Ashi Cloud Overlay"
var string s_lbl_dir      = _l=="PT" ? "Direção:"                : _l=="ES" ? "Dirección:"               : _l=="RU" ? "Направление:"              : _l=="ZH" ? "方向："       : "Direction:"
var string s_lbl_streak   = _l=="PT" ? "Sequência:"              : _l=="ES" ? "Racha:"                   : _l=="RU" ? "Серия:"                    : _l=="ZH" ? "连续："       : "Streak:"
var string s_lbl_body     = _l=="PT" ? "Corpo Médio:"            : _l=="ES" ? "Cuerpo Med.:"             : _l=="RU" ? "Ср. тело:"                 : _l=="ZH" ? "平均实体："   : "Avg Body:"

// HUD dynamic direction text
var string s_dir_bull     = _l=="PT" ? "🟢 ALTA"                 : _l=="ES" ? "🟢 ALCISTA"               : _l=="RU" ? "🟢 БЫЧИЙ"                  : _l=="ZH" ? "🟢 多头"      : "🟢 BULL"
var string s_dir_bear     = _l=="PT" ? "🔴 BAIXA"                : _l=="ES" ? "🔴 BAJISTA"               : _l=="RU" ? "🔴 МЕДВЕЖИЙ"               : _l=="ZH" ? "🔴 空头"      : "🔴 BEAR"

// HUD streak suffix
var string s_sfx_candles  = _l=="PT" ? " velas (candles)"        : _l=="ES" ? " velas (candles)"         : _l=="RU" ? " свечей (candles)"         : _l=="ZH" ? " 根 (candles)" : " candles"

// Alert message prefixes
var string s_al_dir_pre    = _l=="PT" ? "🌊 H.Ashi Mudança de Direção: agora "    : _l=="ES" ? "🌊 H.Ashi Cambio de Dirección: ahora "    : _l=="RU" ? "🌊 H.Ashi Смена направления: сейчас "    : _l=="ZH" ? "🌊 H.Ashi 方向变化：当前 "  : "🌊 H.Ashi Direction Change: now "
var string s_al_streak_pre = _l=="PT" ? "⚠️ H.Ashi Exaustão de Sequência: "        : _l=="ES" ? "⚠️ H.Ashi Agotamiento de Racha: "         : _l=="RU" ? "⚠️ H.Ashi Истощение серии: "             : _l=="ZH" ? "⚠️ H.Ashi 连续耗尽："       : "⚠️ H.Ashi Streak Exhaustion: "
var string s_al_body_pre   = _l=="PT" ? "💥 H.Ashi Anomalia de Corpo: "            : _l=="ES" ? "💥 H.Ashi Anomalía de Cuerpo: "           : _l=="RU" ? "💥 H.Ashi Аномалия тела: "                : _l=="ZH" ? "💥 H.Ashi 实体异常："       : "💥 H.Ashi Body Anomaly: "

// Alert message connectors
var string s_al_streak_mid = _l=="PT" ? " velas (candles) consecutivas — "          : _l=="ES" ? " velas (candles) consecutivas — "          : _l=="RU" ? " свечей (candles) подряд — "                 : _l=="ZH" ? " 根 (candles) 连续 — "         : " consecutive candles — "
var string s_al_body_mid   = _l=="PT" ? "% vs média "                                : _l=="ES" ? "% vs prom. "                                : _l=="RU" ? "% против ср. "                              : _l=="ZH" ? "% 对比均值 "                  : "% vs avg "
var string s_al_on         = _l=="PT" ? " em "                                       : _l=="ES" ? " en "                                       : _l=="RU" ? " на "                                         : _l=="ZH" ? " 在 "                          : " on "

// Alert trend phrases (for streak exhaustion)
var string s_al_up_ext     = _l=="PT" ? "tendência de alta sobreestendida"           : _l=="ES" ? "tendencia alcista sobreextendida"           : _l=="RU" ? "восходящий тренд перерастянут"                : _l=="ZH" ? "上升趋势超延伸"                : "uptrend overextended"
var string s_al_dn_ext     = _l=="PT" ? "tendência de baixa sobreestendida"          : _l=="ES" ? "tendencia bajista sobreextendida"           : _l=="RU" ? "нисходящий тренд перерастянут"               : _l=="ZH" ? "下降趋势超延伸"                : "downtrend overextended"

// Reversal Probability Score (v1.6)
var string s_lbl_score     = _l=="PT" ? "🔄 Prob. Rev.:"         : _l=="ES" ? "🔄 Prob. Rev.:"         : _l=="RU" ? "🔄 Вер. Рев.:"             : _l=="ZH" ? "🔄 反转概率：" : "🔄 Rev. Prob.:"
var string s_al_score_pre  = _l=="PT" ? "📊 H.Ashi Probabilidade de Reversão: "    : _l=="ES" ? "📊 H.Ashi Probabilidad de Reversión: "    : _l=="RU" ? "📊 H.Ashi Вероятность разворота: "       : _l=="ZH" ? "📊 H.Ashi 反转概率："      : "📊 H.Ashi Reversal Probability: "
var string s_al_score_mid  = _l=="PT" ? " — alta probabilidade de reversão"         : _l=="ES" ? " — alta probabilidad de reversión"          : _l=="RU" ? " — высокая вероятность разворота"        : _l=="ZH" ? " — 反转概率高"               : " — high reversal probability"

// MTF Sync row (v1.7) — multilingual labels for the new HUD row
var string s_lbl_sync      = _l=="PT" ? "Sinc.:"                : _l=="ES" ? "Sinc.:"                : _l=="RU" ? "Синх.:"               : _l=="ZH" ? "同步："         : "Sync:"
var string s_lbl_htf_tf    = _l=="ZH" ? "HTF TF："                                                                                                                                : "HTF TF:"
var string s_sync_aligned  = _l=="PT" ? "ALINHADO"              : _l=="ES" ? "ALINEADO"              : _l=="RU" ? "СОВПАДАЕТ"           : _l=="ZH" ? "对齐"           : "ALIGNED"
var string s_sync_divergent = _l=="PT" ? "DIVERGENTE"            : _l=="ES" ? "DIVERGENTE"            : _l=="RU" ? "РАСХОЖДЕНИЕ"         : _l=="ZH" ? "分歧"           : "DIVERGENT"
var string s_sync_na       = "N/A"
var string s_sync_htf_off  = _l=="PT" ? "HTF desligado"         : _l=="ES" ? "HTF apagado"           : _l=="RU" ? "HTF выкл."           : _l=="ZH" ? "HTF 关闭"        : "HTF off"

// ========================================================================================================
// HELPER FUNCTIONS
// ========================================================================================================
f_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_position(s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

// Map streak (signed) to Rainbow Palette color via zone semantics:
//   |streak| ≤ 3      → c_neutral        (early, weak — no signal)
//   |streak| 4..6     → c_up_2 / c_dn_2  (mid — Z-Alert tier)
//   |streak| 7..thr-1 → c_up_3 / c_dn_1  (strong — Z-Exhaustion tier)
//   |streak| ≥ thr    → c_up_4 / c_dn_4  (extreme — Black Swan tier)
// Bull streaks shade hot (warning of bull exhaustion). Bear streaks shade cool.
f_streak_color(int streak_val, int threshold) =>
    int abs_s = math.abs(streak_val)
    color c   = c_neutral
    if abs_s >= threshold
        c := streak_val > 0 ? c_up_4 : c_dn_4
    else if abs_s >= 7
        c := streak_val > 0 ? c_up_3 : c_dn_3
    else if abs_s >= 4
        c := streak_val > 0 ? c_up_2 : c_dn_2
    c

// Map Reversal Probability Score (0-100) to a 3-tier color:
//   0-30  → c_dn_1 (green/cool — low reversal risk, trend may continue)
//   30-70 → c_neutral (gray — undecided / building up)
//   70-100 → c_up_3 (red/hot — high reversal risk, watch for flip)
f_score_color(float score) =>
    score >= 70.0 ? c_up_3 :
     score >= 30.0 ? c_neutral :
     c_dn_1

sz = f_size(font_size)

// ========================================================================================================
// HEIKIN ASHI CORE MATH (§9.3.1)
// CRITICAL: the `var float ha_open = na` + seed pattern is mandatory. Scripts that skip
// it produce wrong values on the first 50-100 bars. The recursion needs a seed on bar 0;
// thereafter ha_open[1] is non-na so the recursive formula takes over.
// ========================================================================================================
ha_close = (open + high + low + close) / 4.0
var float ha_open = na
ha_open := na(ha_open[1]) ? (open + close) / 2.0 : (ha_open[1] + ha_close[1]) / 2.0
ha_high  = math.max(high, math.max(ha_open, ha_close))
ha_low   = math.min(low,  math.min(ha_open, ha_close))

// ========================================================================================================
// DIRECTION + STREAK (§9.3.2)
// streak is signed: positive = consecutive bull HA candles, negative = consecutive bear.
// Resets to ±1 on direction flip.
// Pine v6 safety (§3.8): `ha_is_bull[1]` is `series bool`, and `na()` does not accept
// that type (CE10123). Also, `na` propagates through `and` / ternary, which would
// poison the recursive streak counter on bar 0. We solve both by using `var bool`
// snapshots updated at the end of the script — they hold the previous bar's value
// throughout the current bar, with a safe initial `false` on bar 0.
// ========================================================================================================
bool ha_is_bull = ha_close >= ha_open
bool ha_is_bear = ha_close <  ha_open

var bool was_bull = false
var bool was_bear = false

var int ha_streak = 0
ha_streak := ha_is_bull and was_bull ? ha_streak + 1 :
     ha_is_bear and was_bear ? ha_streak - 1 :
     ha_is_bull ? 1 : -1

// ========================================================================================================
// BODY SIZE METRIC (§9.3.3) — % of price, smoothed over 20 bars for the anomaly alert
// ========================================================================================================
float ha_body_pct = ha_open > 0 ? (math.abs(ha_close - ha_open) / ha_open) * 100.0 : 0.0
float ha_body_avg = ta.sma(ha_body_pct, 20)

// Body anomaly visual flag — declared here (early, right after the body metrics
// it depends on) so the v1.6 Reversal Probability Score (next section) can use it.
// Also used by v1.5 anomaly_bull / anomaly_bear in the ALERTS section below.
// NOT gated by barstate.isconfirmed — visual markers can preview intra-bar;
// final state settles on close.
bool body_anomaly_visual = not na(ha_body_avg) and ha_body_avg > 0.0 and ha_body_pct > 3.0 * ha_body_avg

// ========================================================================================================
// HTF DATA FETCH (v1.6 — Higher Timeframe HA Cloud)
//   The wrapper function ha_compute() is evaluated inside request.security() in the
//   HTF context, so it re-computes the HA recursion using the HTF's own OHLC.
//   lookahead=barmerge.lookahead_off is mandatory (anti-repaint): values lock in
//   only when the HTF bar closes; historical bars never repaint.
// ========================================================================================================
ha_compute() =>
    float _hc = (open + high + low + close) / 4.0
    var float _ho = na
    _ho := na(_ho[1]) ? (open + close) / 2.0 : (_ho[1] + _hc[1]) / 2.0
    float _hh = math.max(high, math.max(_ho, _hc))
    float _hl = math.min(low,  math.min(_ho, _hc))
    bool  _hb = _hc >= _ho
    [_hh, _hl, _hb]

[htf_ha_high, htf_ha_low, htf_is_bull] = request.security(syminfo.tickerid, htf_timeframe, ha_compute(), lookahead = barmerge.lookahead_off)

// ========================================================================================================
// REVERSAL PROBABILITY SCORE (v1.6)
//   A 0-100 composite score blending three orthogonal signals into a single readout:
//
//     streak_norm  = min(|streak|/threshold, 1.0) × 100         (weight 40%)
//     body_norm    = min(body_pct/body_avg, 3.0) / 3.0 × 100    (weight 35%)
//     anomaly_norm = min(anomaly_rate_20bar / 0.15, 1.0) × 100  (weight 25%)
//
//     reversal_score = 0.40 × streak_norm + 0.35 × body_norm + 0.25 × anomaly_norm
//
//   Streak component dominates because streak length is the most robust exhaustion
//   signal in HA. Body component adds "quality" — extended streaks with large bodies
//   are more likely to reverse than streaks with shrinking bodies. Anomaly component
//   adds recent context — clusters of impulse bars (>3× avg body) suggest exhaustion
//   regardless of the current bar's body.
//
//   At anomaly_rate ≥ 0.15 (3+ anomalies in 20 bars), anomaly_norm saturates at 100.
//
//   Higher score → higher probability of reversal on the next bar.
//   This is an analytical readout, NOT an entry signal generator.
// ========================================================================================================
int   anomaly_int          = body_anomaly_visual ? 1 : 0
float anomaly_rate_20bar   = ta.sma(anomaly_int, 20)

float streak_norm   = math.min(math.abs(ha_streak) / float(streak_warning_threshold), 1.0) * 100.0
float body_norm     = na(ha_body_avg) or ha_body_avg <= 0.0 ? 0.0 : math.min(ha_body_pct / ha_body_avg, 3.0) / 3.0 * 100.0
float anomaly_norm  = math.min(anomaly_rate_20bar / 0.15, 1.0) * 100.0

float reversal_score = 0.40 * streak_norm + 0.35 * body_norm + 0.25 * anomaly_norm

// ========================================================================================================
// MTF SYNCHRONY (v1.7)
//   Classifies the relationship between the local HA candle direction and the HTF
//   HA candle direction into 4 states. Used by the HUD Sync row (Row 5).
//
//   States:
//     - sync_aligned    → local + HTF share direction (both bull OR both bear)
//     - sync_divergent  → local and HTF disagree (counter-trend setup or pivot zone)
//     - sync_na         → HTF data warming up (htf_ready is false — first ~N bars)
//     - sync_off        → show_htf_cloud is OFF (user disabled HTF feature)
//
//   Booleans are mutually exclusive (one and only one is true at any bar).
//   Cleared during warmup via the order of checks (off > na > aligned/divergent).
// ========================================================================================================
bool htf_ready      = not na(htf_ha_high)  // Pine v6: na() needs series float, not series bool from request.security tuple (avoids CE10123)
bool sync_off       = not show_htf_cloud
bool sync_na        = show_htf_cloud and not htf_ready
bool sync_aligned   = show_htf_cloud and htf_ready and (ha_is_bull == htf_is_bull)
bool sync_divergent = show_htf_cloud and htf_ready and (ha_is_bull != htf_is_bull)

// ========================================================================================================
// CLOUD COLOR SELECTION (§9.4 + §9.6 custom override)
// ========================================================================================================
color ha_bull_color  = use_custom_colors ? custom_bull_color : ha_bull_default
color ha_bear_color  = use_custom_colors ? custom_bear_color : ha_bear_default
color ha_cloud_color = ha_is_bull ? ha_bull_color : ha_bear_color

// ========================================================================================================
// BODY INTENSITY MODULATION (§9.4.2)
//   Modulates the fill transparency dynamically based on current HA body size vs the
//   20-bar rolling average. Bars with above-average body push the fill toward more
//   opaque, surfacing impulsive expansion clusters visually. Capped at floor 20 to
//   keep candle wicks readable underneath even on anomaly bars.
// ========================================================================================================
float ha_body_intensity = na(ha_body_avg) or ha_body_avg <= 0.0 ? 1.0 : ha_body_pct / ha_body_avg

int ha_fill_transp = not show_intensity_modulation ? fill_transparency :
     ha_body_intensity >= 3.0 ? math.max(20, fill_transparency - 50) :
     ha_body_intensity >= 2.0 ? math.max(30, fill_transparency - 30) :
     ha_body_intensity >= 1.0 ? math.max(50, fill_transparency - 10) :
     fill_transparency

// ========================================================================================================
// CLOUD RENDERING — model C+A hybrid (§9.4)
//   - Lines: ha_high / ha_low as thin outlines (envelope)
//   - Fill:  semi-transparent area between them, colored by direction
//   - Default fill_transparency = 80 (§9.8 rule 1 — never below 60, candle wicks must
//     remain readable underneath)
//   - Linewidth = 1 (§9.8 rule 2 — heavier lines compete with candle outlines)
// ========================================================================================================
p_ha_high = plot(show_cloud ? ha_high : na, "H.Ashi High",
     color = color.new(ha_cloud_color, 60), linewidth = 1, force_overlay = true)
p_ha_low  = plot(show_cloud ? ha_low  : na, "H.Ashi Low",
     color = color.new(ha_cloud_color, 60), linewidth = 1, force_overlay = true)

fill(p_ha_high, p_ha_low,
     color = show_cloud ? color.new(ha_cloud_color, ha_fill_transp) : na,
     title = "H.Ashi Cloud Fill")

// ========================================================================================================
// HTF HA CLOUD RENDERING (v1.6)
//   Ghost cloud: same color palette as local but transparency forced high to keep
//   the local cloud as the visual primary. Thicker outline (linewidth=2 default vs
//   local's 1) creates clear visual hierarchy.
//   When show_htf_cloud is OFF, the plots return na (no rendering, no chart space
//   consumed, no performance cost beyond the request.security call above which Pine
//   evaluates always).
// ========================================================================================================
color htf_cloud_color = htf_is_bull ? ha_bull_color : ha_bear_color

p_htf_high = plot(show_htf_cloud ? htf_ha_high : na, "HTF H.Ashi High",
     color = color.new(htf_cloud_color, 70), linewidth = htf_linewidth, force_overlay = true)
p_htf_low  = plot(show_htf_cloud ? htf_ha_low  : na, "HTF H.Ashi Low",
     color = color.new(htf_cloud_color, 70), linewidth = htf_linewidth, force_overlay = true)

fill(p_htf_high, p_htf_low,
     color = show_htf_cloud ? color.new(htf_cloud_color, htf_transparency) : na,
     title = "HTF H.Ashi Cloud Fill")

// ========================================================================================================
// OPTIONAL CENTERLINE (§9.4.1) — plot.style_circles is mandatory per §9.8 rule 3
//    (dots are visually subordinate; solid line would compete with the candle outlines)
// ========================================================================================================
ha_mid = (ha_open + ha_close) / 2.0
plot(show_centerline ? ha_mid : na, "H.Ashi Midline",
     color = color.new(ha_cloud_color, 30), linewidth = 1,
     style = plot.style_circles, force_overlay = true)

// ========================================================================================================
// HA STATE HUD (§9.5) — 2 cols × 4 rows
// Layout:
//   Row 0: HA Cloud Overlay (merged, full-width header)
//   Row 1: Direction:               | 🟢 BULL / 🔴 BEAR          (colored bg)
//   Row 2: Streak:                  | N candles                  (color by exhaustion tier)
//   Row 3: Avg Body:                | 0.00%
// ========================================================================================================
var table hud = table.new(f_position(hud_position), 2, 7,
     border_width = 1, border_color = color.new(c_neutral, 70),
     frame_width = 2, frame_color = color.new(c_black, 20))

if barstate.islast and show_hud
    // Direction cell colors (§9.5.2)
    color  dir_text_color = ha_is_bull ? c_dn_2  : c_up_3
    color  dir_bg_color   = ha_is_bull ? color.new(c_dn_1, 70) : color.new(c_up_3, 70)
    string dir_txt        = ha_is_bull ? s_dir_bull : s_dir_bear

    // Streak cell color (§9.5.2 zone-tiered)
    color streak_text_color = f_streak_color(ha_streak, streak_warning_threshold)
    string streak_txt       = str.tostring(math.abs(ha_streak)) + s_sfx_candles

    // Body cell — plain text, 2 decimals + %
    string body_txt = str.tostring(ha_body_pct, "#.##") + "%"

    // Row 0 — Header
    table.merge_cells(hud, 0, 0, 1, 0)
    table.cell(hud, 0, 0, s_hud_title,
         text_color = color.new(c_dn_4, 0), text_size = sz,
         bgcolor = color.new(c_black, 10), text_halign = text.align_center)

    // Row 1 — Direction
    table.cell(hud, 0, 1, s_lbl_dir,
         text_color = color.new(c_neutral, 20), text_size = sz,
         bgcolor = color.new(c_black, 65), text_halign = text.align_left)
    table.cell(hud, 1, 1, dir_txt,
         text_color = dir_text_color, text_size = sz,
         bgcolor = dir_bg_color, text_halign = text.align_right)

    // Row 2 — Streak
    table.cell(hud, 0, 2, s_lbl_streak,
         text_color = color.new(c_neutral, 20), text_size = sz,
         bgcolor = color.new(c_black, 70), text_halign = text.align_left)
    table.cell(hud, 1, 2, streak_txt,
         text_color = streak_text_color, text_size = sz,
         bgcolor = color.new(c_black, 70), text_halign = text.align_right)

    // Row 3 — Reversal Probability Score (v1.6)
    if show_score
        color score_text_color = f_score_color(reversal_score)
        string score_txt = str.tostring(reversal_score, "#") + "/100" + (reversal_score >= 70.0 ? " ⚠️" : "")
        table.cell(hud, 0, 3, s_lbl_score,
             text_color = color.new(c_neutral, 20), text_size = sz,
             bgcolor = color.new(c_black, 70), text_halign = text.align_left)
        table.cell(hud, 1, 3, score_txt,
             text_color = score_text_color, text_size = sz,
             bgcolor = color.new(c_black, 70), text_halign = text.align_right)

    // Row 4 — Avg Body (was row 3 in v1.5)
    table.cell(hud, 0, 4, s_lbl_body,
         text_color = color.new(c_neutral, 20), text_size = sz,
         bgcolor = color.new(c_black, 65), text_halign = text.align_left)
    table.cell(hud, 1, 4, body_txt,
         text_color = color.new(c_neutral, 10), text_size = sz,
         bgcolor = color.new(c_black, 65), text_halign = text.align_right)

    // Row 5 — MTF Sync (v1.7)
    //   Always rendered. Reports local vs HTF direction alignment.
    string sync_txt   = sync_aligned   ? s_sync_aligned :
                         sync_divergent ? s_sync_divergent :
                         sync_na        ? s_sync_na :
                         s_sync_htf_off
    color  sync_color = sync_aligned   ? c_dn_1 :       // green — positive consensus
                         sync_divergent ? c_up_2 :       // orange — warning, divergence
                         color.new(c_neutral, 0)         // gray — na or off
    table.cell(hud, 0, 5, s_lbl_sync,
         text_color = color.new(c_neutral, 20), text_size = sz,
         bgcolor = color.new(c_black, 70), text_halign = text.align_left)
    table.cell(hud, 1, 5, sync_txt,
         text_color = sync_color, text_size = sz,
         bgcolor = color.new(c_black, 70), text_halign = text.align_right)

    // Row 6 — HTF Timeframe disclosure (v1.7.2)
    //   Always rendered (informational regardless of show_htf_cloud state).
    //   When htf_timeframe is "" (chart-following), shows the chart's actual TF
    //   via timeframe.period so the disclosure remains accurate.
    string htf_tf_display = htf_timeframe == "" ? timeframe.period : htf_timeframe
    table.cell(hud, 0, 6, s_lbl_htf_tf,
         text_color = color.new(c_neutral, 20), text_size = sz,
         bgcolor = color.new(c_black, 65), text_halign = text.align_left)
    table.cell(hud, 1, 6, htf_tf_display,
         text_color = color.new(c_neutral, 10), text_size = sz,
         bgcolor = color.new(c_black, 65), text_halign = text.align_right)


// ========================================================================================================
// ALERTS (§9.7) — all gated by barstate.isconfirmed (§4 rule #7)
// ========================================================================================================
// Direction flip: bull→bear or bear→bull on this confirmed bar
// (uses `was_bull` / `was_bear` from above — `var bool` snapshots, no na propagation)
bool dir_change_event = barstate.isconfirmed and ((ha_is_bull and was_bear) or (ha_is_bear and was_bull))

// Streak exhaustion: |streak| just crossed the user threshold
bool streak_event = barstate.isconfirmed and math.abs(ha_streak) >= streak_warning_threshold and math.abs(nz(ha_streak[1], 0)) < streak_warning_threshold

// Body anomaly: current body > 3× the 20-bar average (and avg is valid + positive)
bool body_anomaly_event = barstate.isconfirmed and not na(ha_body_avg) and ha_body_avg > 0.0 and ha_body_pct > 3.0 * ha_body_avg

// Anomaly bull/bear visual triggers — body_anomaly_visual is declared earlier
// (right after BODY SIZE METRIC) so it can be used by the v1.6 Reversal Score formula
bool anomaly_bull = show_anomaly_marker and body_anomaly_visual and ha_is_bull
bool anomaly_bear = show_anomaly_marker and body_anomaly_visual and ha_is_bear

// ========================================================================================================
// BODY ANOMALY VISUAL MARKERS (§9.4.3)
//   Small dots appear when current HA body > 3× the 20-bar average — flags impulsive
//   expansion or capitulation. Bull anomaly: dot below the bar. Bear: dot above.
//   Independent of the alert (which has its own toggle in g_alerts group).
// ========================================================================================================
plotshape(anomaly_bull,
     title    = "Bull Body Anomaly Marker",
     location = location.belowbar,
     style    = shape.circle,
     color    = color.new(ha_bull_color, 30),
     size     = size.tiny,
     force_overlay = true)

plotshape(anomaly_bear,
     title    = "Bear Body Anomaly Marker",
     location = location.abovebar,
     style    = shape.circle,
     color    = color.new(ha_bear_color, 30),
     size     = size.tiny,
     force_overlay = true)

if dir_change_event and alert_direction_change
    string dir_now = ha_is_bull ? s_dir_bull : s_dir_bear
    alert(s_al_dir_pre + dir_now + s_al_on + syminfo.ticker, alert.freq_once_per_bar)

if streak_event and alert_streak_extreme
    string trend_phrase = ha_is_bull ? s_al_up_ext : s_al_dn_ext
    alert(s_al_streak_pre + str.tostring(math.abs(ha_streak)) + s_al_streak_mid + trend_phrase + s_al_on + syminfo.ticker, alert.freq_once_per_bar)

if body_anomaly_event and alert_body_anomaly
    alert(s_al_body_pre + str.tostring(ha_body_pct, "#.##") + s_al_body_mid + str.tostring(ha_body_avg, "#.##") + "%" + s_al_on + syminfo.ticker, alert.freq_once_per_bar)

// Reversal Probability Score alert — fires once when score crosses ≥80 from below (v1.6)
bool score_high_event = barstate.isconfirmed and reversal_score >= 80.0 and nz(reversal_score[1], 0.0) < 80.0
if score_high_event and alert_high_score
    alert(s_al_score_pre + str.tostring(reversal_score, "#") + "/100" + s_al_score_mid + s_al_on + syminfo.ticker, alert.freq_once_per_bar)

// Billboard alertcondition (UX hint — see context §3.9)
alertcondition(false, title = "HOW TO SETUP ALERTS (READ)", message = "Please select 'Any alert() function call' in the condition menu. You can filter which alerts you receive inside the Indicator Settings (Gear Icon).")

// ========================================================================================================
// STATE SNAPSHOT FOR NEXT BAR
// MUST come AFTER all uses of `was_bull` / `was_bear` (i.e., after the alerts section)
// so the current bar's reads see the previous bar's value. After these assignments,
// the variables hold THIS bar's direction, which becomes the "previous" on the next bar.
// ========================================================================================================
was_bull := ha_is_bull
was_bear := ha_is_bear
````
