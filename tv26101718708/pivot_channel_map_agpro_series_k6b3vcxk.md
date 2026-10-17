# Pivot Channel Map [AGPro Series]

- url: https://www.tradingview.com/script/k6b3vcXK-Pivot-Channel-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;fb828c244195402f94cf699ee78b5311
- version: 3.0

## Description

Pivot Channel Map [AGPro Series]

🔹 OVERVIEW

Pivot Channel Map is a structural channel engine that automatically detects and classifies market structure channels from confirmed swing pivots. It organises every qualified channel into a clear 8-family taxonomy (Major / Minor × External / Internal × Up / Down) and renders them as a living map of trend, range and reversal context. The script works on all instruments and timeframes, with a focus on intraday and swing analysis.

Instead of plotting a single trendline or band, the engine maintains a continuously updated structural map: active channels, their midlines, interaction pockets around the rails, preserved broken channels, and post-break retest / reclaim signals. A compact right-corner panel summarises live channel counts, qualification state, nearest channel distance in ATR units, and the prevailing Major tilt.

The goal is to give discretionary traders a moderation-safe, clutter-controlled view of where price is inside the broader structure — not to predict future prices.

[image]https://www.tradingview.com/x/zfRcB9ga/[/image]

[image]https://www.tradingview.com/x/Garw2G9v/[/image]

[image]https://www.tradingview.com/x/VnUQNbW4/[/image]

🔸 UNIQUE EDGE

Most channel indicators draw one or two parallel lines and call it a day. Pivot Channel Map adds structural classification, qualification, memory and post-event follow-through on top of the channel geometry:

- Eight channel families instead of a single pair of rails
- ATR-normalised qualification engine (Off / Balanced / Strict) to filter structurally weak channels
- Broken Channel Memory that preserves invalidated structure as faded historical context
- Interaction Zones (right-edge ATR pockets) around active channel rails
- Post-Break Retest / Reclaim tracker that tags the first valid touch after a confirmed break
- Break and React event markers on Major channels
- ATR-based distance tagging in the info panel (Near / Mid / Wide / Far)

The result is a richer structural read than a standard channel script, while still staying visually clean through emphasis, opacity and clutter controls.


🔹 METHODOLOGY

1. Pivot detection. A configurable Pivot Period drives ta.pivothigh and ta.pivotlow to produce confirmed swing pivots. The script then classifies each pivot into H / HH / LH / HL / LL / L roles and promotes / demotes them between Major (M*) and Minor (m*) status based on close breaks versus the current Major range.

2. Channel construction. From the classified pivot stream, eight channel families are built:
   - Major External Up / Down
   - Major Internal Up / Down
   - Minor External Up / Down
   - Minor Internal Up / Down
   External channels trace structural HH/LL extremes, Internal channels trace LH/HL interior swings.

3. Qualification. Each candidate channel is width-measured against ATR and span-measured in bars. The Qualification Engine (Off / Balanced / Strict) filters out structurally weak channels before they are drawn.

4. Life-cycle management. Active channels are redrawn and extended forward each bar until an origin-rail or channel-rail break is confirmed. On break, the previous structure can be preserved by Broken Channel Memory (Off / Major Only / All) with its own style and opacity.

5. Event detection. Confirmed origin-rail breaks produce BREAK events; wick-through-then-close-back moves produce REACT events on Major channels. A cooldown and an ATR-based price-distance filter prevent label clusters when price oscillates around the same rail.

6. Post-break follow-through. After a confirmed break, the script tracks the first valid touch inside a configurable window and tags it as RETEST (channel-rail break) or RECLAIM (origin-rail break).


🔸 SIGNALS & ALERTS

On-chart events:
- BREAK — confirmed close-based break of a Major channel rail
- REACT — wick through the Major rail with a close back inside, filtered by bar cooldown and ATR distance
- RETEST / RECLAIM — first valid touch of the broken rail inside the post-break window
- Interaction Zone contact — visual ATR pocket around active channel rails
- Channel Quick Tags (MEX / MIN / mEX / mIN, Up / Dn) — compact family labels on active channels

Alert conditions (all 16 toggleable, Major alerts On by default, Minor Off by default):
- Break: Major External Up / Down
- React: Major External Up / Down
- Break: Major Internal Up / Down
- React: Major Internal Up / Down
- Break: Minor External Up / Down
- React: Minor External Up / Down
- Break: Minor Internal Up / Down
- React: Minor Internal Up / Down

Message frequency is configurable (All / Once Per Bar / Once Per Bar Close). Alerts include symbol, timeframe, time zone and event description.


🔹 KEY INPUTS

- Pivot Engine: Pivot Period (default 5)
- Per-family Visibility: 8 Show / Delete-Previous / Color / Style / Extend / Width groups
- Channel Qualification: Mode (Off / Balanced / Strict), Apply To (All / Major Only / Minor Only), ATR Length
- Broken Channel Memory: Scope (Off / Major Only / All), Keep (Last 1 / Last 2), Style
- Channel Midline: Show, Apply To, Scope, Style, Width, Opacity
- Active Map Clarity: Line Emphasis, Base-Line Focus, Event Markers, React Cooldown, React Min Price Distance, Quick Tags, Tag Scope, Tag Size, Event / Quick Tag Vertical Offsets
- Interaction Zones: Scope, Rails, Zone Width ATR, Extend Bars, Opacity, Zone Text
- Post-Break Retest / Reclaim: Scope, Window Bars, Label Offset ATR
- Panel: Show, Position, Font Size
- Alerts: 16 per-family Break / React toggles, Alert Name, Frequency, Time Zone


🔸 HOW TO USE

Getting started:
1. Apply the indicator on any symbol and timeframe.
2. Start with default settings: Qualification Off so the full structural map is visible.
3. If the chart feels busy on lower timeframes, switch Qualification to Balanced or Strict.

Reading the panel:
- Major Live / Minor Live — active channels per class
- Nearest Channel — closest active channel, with ATR distance and Near / Mid / Wide / Far tag
- Qualification — current filter mode and scope
- Interaction — interaction zone scope and rails
- Post-Break — tracker scope, window and prevailing Major tilt

Common workflows:
- Trend continuation: wait for price to hold an Active Major channel and look for a REACT at the rail inside the channel direction.
- Break-and-retest: after a BREAK event, watch for the RETEST / RECLAIM label inside the Post-Break window.
- Confluence: use Interaction Zones to spot where Major and Minor rails meet at the right edge of the chart.
- Higher-timeframe context: open a higher timeframe tab with the same script to map macro structure around your execution timeframe.

Suggested defaults:
- Intraday traders: 15m–1H base TF, Balanced qualification
- Swing traders: 4H–1D base TF, Balanced or Off qualification
- Higher-timeframe context: 1D–1W with Qualification Off


🔹 LIMITATIONS & TRANSPARENCY

- Pivot-based. Pivots require the configured number of bars to confirm, so the most recent swing always lags by Pivot Period bars. This is a structural property of confirmed pivots, not a bug.
- Redraw behaviour. Active channels are extended forward each bar until a break is confirmed on close. Channel end-points can therefore adjust as new pivots qualify.
- Alerts fire on confirmed conditions. Break and React alerts require barstate.isconfirmed, so intra-bar touches do not trigger alerts.
- Timeframe behaviour. On very high timeframes with limited history (e.g. weekly / monthly on newer instruments), the total pivot count can be small. Keep Qualification at Off on higher timeframes to avoid over-filtering.
- This is a visualisation / structure tool. It is not a trading strategy, it does not manage risk, and it does not generate buy / sell recommendations. All entries and exits are the trader’s responsibility.


🔸 RISK DISCLOSURE

This script is a technical analysis tool intended for educational and analytical purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any asset. Past chart behaviour does not guarantee future results. Trading involves significant risk and can result in the loss of capital. Always do your own research, use proper risk management, and consider consulting a licensed financial advisor before making trading decisions.

## Source Code

````pine
// -------------------------------------------------
// Pivot Channel Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.2
//
// Pivot-based channel mapping engine that auto-detects Major / Minor and
// External / Internal structural channels from swing pivots, qualifies
// them with ATR-normalized span and width filters, and visualizes the
// active map with midlines, interaction pockets, broken channel memory,
// post-break retest / reclaim signals, and break / react event markers.
// A break follow-rate layer reports how often confirmed major channel
// breaks on this chart actually extended in the break direction before
// price reclaimed the broken rail. Built for discretionary market
// structure readers who want a clean, moderation-safe technical overlay
// for trend, range and reversal reads.
// -------------------------------------------------
//@version=6
indicator('Pivot Channel Map [AGPro Series]',
     shorttitle = 'AG Pro PCM',
     overlay = true,
     max_bars_back = 5000,
     max_boxes_count = 500,
     max_labels_count = 500,
     max_lines_count = 500)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
agp_HeaderBg      = color.rgb(37, 99, 235)      // #2563EB
agp_HeaderText    = color.rgb(245, 247, 250)    // #F5F7FA
agp_PanelBg       = color.rgb(15, 23, 42)       // #0F172A
agp_PanelBorder   = color.rgb(51, 65, 85)       // #334155
agp_PanelLabelCol = color.rgb(148, 163, 184)    // #94A3B8
agp_PanelValueCol = color.rgb(226, 232, 240)    // #E2E8F0
agp_BullColor     = color.rgb(34, 197, 166)     // #22C5A6
agp_BearColor     = color.rgb(244, 114, 182)    // #F472B6
agp_NeutralColor  = color.rgb(245, 189, 92)     // #F5BD5C
agp_AccentColor   = color.rgb(129, 140, 248)    // #818CF8

// -------------------------------------------------
// Inputs : Major External Up
// -------------------------------------------------
agp_Show_MjExUp       = input.bool(true, 'Show: Major Ext Up', group = 'AGP: Major External Up', tooltip = 'Toggles the Major External Up channel built from structural Lower Lows inside a confirmed bullish leg.')
agp_Delete_Pre_MjExUp = input.bool(true, 'Delete Previous',    group = 'AGP: Major External Up', tooltip = 'When enabled, only the most recent Major External Up channel is kept on chart.')
agp_Color_MjExUp      = input.color(#22C5A6, 'Color',          group = 'AGP: Major External Up')
agp_Style_MjExUp      = input.string(line.style_solid, 'Style', [line.style_solid, line.style_dashed, line.style_dotted], group = 'AGP: Major External Up')
agp_Extend_MjExUp     = input.string(extend.none, 'Extend',    [extend.none, extend.both, extend.right, extend.left], group = 'AGP: Major External Up')
agp_Width_MjExUp      = input.int(3, 'Width', minval = 1, maxval = 5, group = 'AGP: Major External Up')

// -------------------------------------------------
// Inputs : Major External Down
// -------------------------------------------------
agp_Show_MjExDown       = input.bool(true, 'Show: Major Ext Down', group = 'AGP: Major External Down', tooltip = 'Toggles the Major External Down channel built from structural Higher Highs inside a confirmed bearish leg.')
agp_Delete_Pre_MjExDown = input.bool(true, 'Delete Previous',      group = 'AGP: Major External Down')
agp_Color_MjExDown      = input.color(#F472B6, 'Color',            group = 'AGP: Major External Down')
agp_Style_MjExDown      = input.string(line.style_solid, 'Style',  [line.style_solid, line.style_dashed, line.style_dotted], group = 'AGP: Major External Down')
agp_Extend_MjExDown     = input.string(extend.none, 'Extend',      [extend.none, extend.both, extend.right, extend.left], group = 'AGP: Major External Down')
agp_Width_MjExDown      = input.int(3, 'Width', minval = 1, maxval = 5, group = 'AGP: Major External Down')

// -------------------------------------------------
// Inputs : Major Internal Up
// -------------------------------------------------
agp_Show_MjInUp       = input.bool(true, 'Show: Major Int Up', group = 'AGP: Major Internal Up', tooltip = 'Toggles the Major Internal Up channel built from Higher Lows that sit inside a broader bullish Major structure.')
agp_Delete_Pre_MjInUp = input.bool(true, 'Delete Previous',    group = 'AGP: Major Internal Up')
agp_Color_MjInUp      = input.color(#22C5A6, 'Color',          group = 'AGP: Major Internal Up')
agp_Style_MjInUp      = input.string(line.style_solid, 'Style', [line.style_solid, line.style_dashed, line.style_dotted], group = 'AGP: Major Internal Up')
agp_Extend_MjInUp     = input.string(extend.none, 'Extend',    [extend.none, extend.both, extend.right, extend.left], group = 'AGP: Major Internal Up')
agp_Width_MjInUp      = input.int(2, 'Width', minval = 1, maxval = 5, group = 'AGP: Major Internal Up')

// -------------------------------------------------
// Inputs : Major Internal Down
// -------------------------------------------------
agp_Show_MjInDown       = input.bool(true, 'Show: Major Int Down', group = 'AGP: Major Internal Down', tooltip = 'Toggles the Major Internal Down channel built from Lower Highs that sit inside a broader bearish Major structure.')
agp_Delete_Pre_MjInDown = input.bool(true, 'Delete Previous',      group = 'AGP: Major Internal Down')
agp_Color_MjInDown      = input.color(#F472B6, 'Color',            group = 'AGP: Major Internal Down')
agp_Style_MjInDown      = input.string(line.style_solid, 'Style',  [line.style_solid, line.style_dashed, line.style_dotted], group = 'AGP: Major Internal Down')
agp_Extend_MjInDown     = input.string(extend.none, 'Extend',      [extend.none, extend.both, extend.right, extend.left], group = 'AGP: Major Internal Down')
agp_Width_MjInDown      = input.int(2, 'Width', minval = 1, maxval = 5, group = 'AGP: Major Internal Down')

// -------------------------------------------------
// Inputs : Minor External Up
// -------------------------------------------------
agp_Show_MnExUp       = input.bool(true, 'Show: Minor Ext Up', group = 'AGP: Minor External Up', tooltip = 'Toggles the Minor External Up channel formed by local Lower Lows inside short-term bullish legs.')
agp_Delete_Pre_MnExUp = input.bool(true, 'Delete Previous',    group = 'AGP: Minor External Up')
agp_Color_MnExUp      = input.color(#22C5A659, 'Color',        group = 'AGP: Minor External Up')
agp_Style_MnExUp      = input.string(line.style_dashed, 'Style', [line.style_solid, line.style_dashed, line.style_dotted], group = 'AGP: Minor External Up')
agp_Extend_MnExUp     = input.string(extend.none, 'Extend',    [extend.none, extend.both, extend.right, extend.left], group = 'AGP: Minor External Up')
agp_Width_MnExUp      = input.int(1, 'Width', minval = 1, maxval = 5, group = 'AGP: Minor External Up')

// -------------------------------------------------
// Inputs : Minor External Down
// -------------------------------------------------
agp_Show_MnExDown       = input.bool(true, 'Show: Minor Ext Down', group = 'AGP: Minor External Down', tooltip = 'Toggles the Minor External Down channel formed by local Higher Highs inside short-term bearish legs.')
agp_Delete_Pre_MnExDown = input.bool(true, 'Delete Previous',      group = 'AGP: Minor External Down')
agp_Color_MnExDown      = input.color(#F472B659, 'Color',          group = 'AGP: Minor External Down')
agp_Style_MnExDown      = input.string(line.style_dashed, 'Style', [line.style_solid, line.style_dashed, line.style_dotted], group = 'AGP: Minor External Down')
agp_Extend_MnExDown     = input.string(extend.none, 'Extend',      [extend.none, extend.both, extend.right, extend.left], group = 'AGP: Minor External Down')
agp_Width_MnExDown      = input.int(1, 'Width', minval = 1, maxval = 5, group = 'AGP: Minor External Down')

// -------------------------------------------------
// Inputs : Minor Internal Up
// -------------------------------------------------
agp_Show_MnInUp       = input.bool(true, 'Show: Minor Int Up', group = 'AGP: Minor Internal Up', tooltip = 'Toggles the Minor Internal Up channel formed by local Higher Lows inside a short-term bullish micro structure.')
agp_Delete_Pre_MnInUp = input.bool(true, 'Delete Previous',    group = 'AGP: Minor Internal Up')
agp_Color_MnInUp      = input.color(#22C5A659, 'Color',        group = 'AGP: Minor Internal Up')
agp_Style_MnInUp      = input.string(line.style_dotted, 'Style', [line.style_solid, line.style_dashed, line.style_dotted], group = 'AGP: Minor Internal Up')
agp_Extend_MnInUp     = input.string(extend.none, 'Extend',    [extend.none, extend.both, extend.right, extend.left], group = 'AGP: Minor Internal Up')
agp_Width_MnInUp      = input.int(1, 'Width', minval = 1, maxval = 5, group = 'AGP: Minor Internal Up')

// -------------------------------------------------
// Inputs : Minor Internal Down
// -------------------------------------------------
agp_Show_MnInDown       = input.bool(true, 'Show: Minor Int Down', group = 'AGP: Minor Internal Down', tooltip = 'Toggles the Minor Internal Down channel formed by local Lower Highs inside a short-term bearish micro structure.')
agp_Delete_Pre_MnInDown = input.bool(true, 'Delete Previous',      group = 'AGP: Minor Internal Down')
agp_Color_MnInDown      = input.color(#F472B659, 'Color',          group = 'AGP: Minor Internal Down')
agp_Style_MnInDown      = input.string(line.style_dotted, 'Style', [line.style_solid, line.style_dashed, line.style_dotted], group = 'AGP: Minor Internal Down')
agp_Extend_MnInDown     = input.string(extend.none, 'Extend',      [extend.none, extend.both, extend.right, extend.left], group = 'AGP: Minor Internal Down')
agp_Width_MnInDown      = input.int(1, 'Width', minval = 1, maxval = 5, group = 'AGP: Minor Internal Down')

// -------------------------------------------------
// Inputs : Pivot Engine
// -------------------------------------------------
agp_PivotPeriod = input.int(5, 'Pivot Period', minval = 2, maxval = 50, group = 'AGP: Pivot Engine', tooltip = 'Number of bars on each side used to confirm a pivot high or low. Higher values produce fewer, more structural pivots.')

// -------------------------------------------------
// Inputs : Channel Qualification Engine
// -------------------------------------------------
agp_QualMode    = input.string('Off', 'Mode', ['Off', 'Balanced', 'Strict'], group = 'AGP: Channel Qualification', tooltip = 'Filters structurally weaker channels before they are drawn. Off (default): no filtering, shows every valid structural channel across all timeframes. Balanced: keeps healthy channels, good for filtering noise on intraday charts. Strict: only allows wide and persistent structures. Tip: enable Balanced or Strict if the chart feels too busy, especially on lower timeframes.')
agp_QualApplyTo = input.string('All', 'Apply To', ['All', 'Major Only', 'Minor Only'], group = 'AGP: Channel Qualification', tooltip = 'Limits qualification to Major or Minor channels, or applies it to both families.')
agp_QualAtrLen  = input.int(14, 'ATR Length', minval = 1, maxval = 200, group = 'AGP: Channel Qualification', tooltip = 'ATR length used to normalize channel width during qualification.')

// -------------------------------------------------
// Inputs : Broken Channel Memory
// -------------------------------------------------
agp_BrokenMemoryScope = input.string('Major Only', 'Scope', ['Off', 'Major Only', 'All'], group = 'AGP: Broken Channel Memory', tooltip = 'Preserves recently invalidated channels as faded historical context when a new channel replaces them.')
agp_BrokenMemoryKeep  = input.string('Last 1', 'Keep', ['Last 1', 'Last 2'], group = 'AGP: Broken Channel Memory', tooltip = 'Number of broken channels to preserve for each channel family.')
agp_BrokenMemoryStyle = input.string(line.style_dashed, 'Style', [line.style_dashed, line.style_dotted], group = 'AGP: Broken Channel Memory', tooltip = 'Visual style used for preserved broken channels.')

// -------------------------------------------------
// Inputs : Channel Midline
// -------------------------------------------------
agp_ShowMidline     = input.bool(true, 'Show Midline', group = 'AGP: Channel Midline', tooltip = 'Displays a centerline inside qualified channels to show the internal balance path.')
agp_MidlineApplyTo  = input.string('Active Only', 'Apply To', ['Active Only', 'All Visible'], group = 'AGP: Channel Midline', tooltip = 'Active Only shows midlines for active channels. All Visible also keeps midlines on preserved broken channels.')
agp_MidlineScope    = input.string('Major Only', 'Scope', ['All', 'Major Only', 'Minor Only'], group = 'AGP: Channel Midline', tooltip = 'Limits midline display to Major channels, Minor channels, or both. Default Major Only keeps the chart lighter.')
agp_MidlineStyle    = input.string(line.style_dotted, 'Style', [line.style_dotted, line.style_dashed], group = 'AGP: Channel Midline')
agp_MidlineWidth    = input.int(1, 'Width', minval = 1, maxval = 2, group = 'AGP: Channel Midline')
agp_MidlineOpacity  = input.int(40, 'Opacity', minval = 0, maxval = 100, group = 'AGP: Channel Midline', tooltip = 'Higher values make the midline more transparent.')

// -------------------------------------------------
// Inputs : Active Map Clarity
// -------------------------------------------------
agp_EmphasisMode        = input.string('Balanced', 'Line Emphasis', ['Off', 'Balanced', 'Strong'], group = 'AGP: Active Map Clarity', tooltip = 'Balances line contrast so active channels read more clearly without changing channel logic.')
agp_FocusBaseLine       = input.bool(true, 'Base-Line Focus', group = 'AGP: Active Map Clarity', tooltip = 'Keeps the structural base line slightly more prominent than the opposite channel rail.')
agp_ShowEventMarkers    = input.bool(true, 'Event Markers Lite', group = 'AGP: Active Map Clarity', tooltip = 'Shows compact markers on confirmed major break and reaction events.')
agp_ReactCooldownBars   = input.int(20, 'React Cooldown Bars', minval = 0, maxval = 100, group = 'AGP: Active Map Clarity', tooltip = 'Minimum bar spacing between two React markers inside the same channel family. Prevents overlapping reaction tags when price oscillates around the same rail. Higher values give a cleaner chart with fewer reaction labels.')
agp_ReactMinPriceAtr    = input.float(0.75, 'React Min Price Distance ATR', minval = 0.00, maxval = 5.00, step = 0.05, group = 'AGP: Active Map Clarity', tooltip = 'Secondary filter: if the price level of the last React marker is within this ATR distance, the new React is suppressed. Set to 0 to disable price-based suppression.')
agp_ShowMajorQuickTags  = input.bool(true, 'Channel Quick Tags', group = 'AGP: Active Map Clarity', tooltip = 'Adds compact family labels on active channels based on the selected tag scope.')
agp_QuickTagScope       = input.string('All Major', 'Tag Scope', ['Active Major Only', 'All Major', 'All Visible'], group = 'AGP: Active Map Clarity', tooltip = 'Controls whether quick tags are shown only on the active major channel, on all major channels, or on all visible channels including minor structures.')
agp_TagOffsetBars       = input.int(3, 'Tag Offset Bars', minval = 1, maxval = 20, group = 'AGP: Active Map Clarity', tooltip = 'Horizontal offset used for quick tags and event tags.')
agp_TagSizeInput        = input.string('Normal', 'Tag Size', ['Tiny', 'Small', 'Normal'], group = 'AGP: Active Map Clarity', tooltip = 'Shared tag size used by quick tags and BREAK / REACT event tags.')
agp_EventTagVerticalOffset = input.float(0.30, 'Event Tag Vertical Offset ATR', minval = 0.10, maxval = 1.00, step = 0.01, group = 'AGP: Active Map Clarity', tooltip = 'ATR-based vertical spacing used by BREAK / REACT event tags so they do not sit too close to candles.')
agp_QuickTagVerticalOffset = input.float(0.35, 'Quick Tag Vertical Offset ATR', minval = 0.10, maxval = 1.00, step = 0.01, group = 'AGP: Active Map Clarity', tooltip = 'ATR-based vertical spacing used by channel quick tags so they stay clear of candles.')

// -------------------------------------------------
// Inputs : Interaction Zones
// -------------------------------------------------
agp_ShowInteractionZones = input.bool(true, 'Show Interaction Zones', group = 'AGP: Interaction Zones', tooltip = 'Draws right-edge interaction pockets around active channel rails so current channel touch areas read faster on the chart.')
agp_InteractionScope     = input.string('Major Only', 'Scope', ['Major Only', 'All'], group = 'AGP: Interaction Zones')
agp_InteractionRails     = input.string('Both', 'Rails', ['Origin Only', 'Channel Only', 'Both'], group = 'AGP: Interaction Zones')
agp_InteractionWidthAtr  = input.float(0.18, 'Zone Width ATR', minval = 0.05, maxval = 1.50, step = 0.01, group = 'AGP: Interaction Zones')
agp_InteractionExtendBars = input.int(25, 'Extend Bars', minval = 5, maxval = 150, group = 'AGP: Interaction Zones', tooltip = 'How far right the interaction pockets project. Minimum of 25 bars keeps the forward context readable.')
agp_InteractionOpacity   = input.int(80, 'Zone Opacity', minval = 0, maxval = 100, group = 'AGP: Interaction Zones')
agp_ShowInteractionText  = input.bool(false, 'Show Zone Text', group = 'AGP: Interaction Zones')

// -------------------------------------------------
// Inputs : Post-Break Retest / Reclaim
// -------------------------------------------------
agp_ShowPostBreakSignals = input.bool(true, 'Show Post-Break Signals', group = 'AGP: Post-Break Retest / Reclaim', tooltip = 'Tracks the first valid retest or reclaim after a confirmed major or minor break event without changing the alert engine.')
agp_PostBreakScope       = input.string('Major Only', 'Scope', ['Major Only', 'All'], group = 'AGP: Post-Break Retest / Reclaim')
agp_PostBreakWindow      = input.int(20, 'Window Bars', minval = 3, maxval = 150, group = 'AGP: Post-Break Retest / Reclaim')
agp_PostBreakOffsetAtr   = input.float(0.38, 'Label Offset ATR', minval = 0.05, maxval = 1.50, step = 0.01, group = 'AGP: Post-Break Retest / Reclaim', tooltip = 'Vertical ATR offset for RECLAIM / RETEST labels. Higher values keep labels further from candles to prevent overlap with wicks on lower timeframes.')

// -------------------------------------------------
// Inputs : Panel
// -------------------------------------------------
agp_ShowPanel          = input.bool(true, 'Show Panel', group = 'AGP: Panel')
agp_PanelPosition      = input.string('Top Right', 'Panel Position', ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'], group = 'AGP: Panel')
agp_PanelTextSizeInput = input.string('Normal', 'Panel Font Size', ['Small', 'Normal'], group = 'AGP: Panel')

// -------------------------------------------------
// Inputs : Alerts
// -------------------------------------------------
agp_AlertName      = input.string('Pivot Channel Map [AGPro] Alerts', 'Alert Name', group = 'AGP: Alerts')
agp_AlertFrequency = input.string('Once Per Bar', 'Message Frequency', ['All', 'Once Per Bar', 'Per Bar Close'], 'Default is "Once Per Bar".', group = 'AGP: Alerts')
agp_AlertTimezone  = input.string('UTC', 'Alert Time Zone', group = 'AGP: Alerts', tooltip = 'Timezone used inside alert messages.')
agp_Alert_MjExUp_B   = input.string('On', 'Break Alert: Major Ext Up',   ['On', 'Off'], group = 'AGP: Alerts')
agp_Alert_MjExUp_R   = input.string('On', 'React Alert: Major Ext Up',   ['On', 'Off'], group = 'AGP: Alerts')
agp_Alert_MjExDown_B = input.string('On', 'Break Alert: Major Ext Down', ['On', 'Off'], group = 'AGP: Alerts')
agp_Alert_MjExDown_R = input.string('On', 'React Alert: Major Ext Down', ['On', 'Off'], group = 'AGP: Alerts')
agp_Alert_MjInUp_B   = input.string('On', 'Break Alert: Major Int Up',   ['On', 'Off'], group = 'AGP: Alerts')
agp_Alert_MjInUp_R   = input.string('On', 'React Alert: Major Int Up',   ['On', 'Off'], group = 'AGP: Alerts')
agp_Alert_MjInDown_B = input.string('On', 'Break Alert: Major Int Down', ['On', 'Off'], group = 'AGP: Alerts')
agp_Alert_MjInDown_R = input.string('On', 'React Alert: Major Int Down', ['On', 'Off'], group = 'AGP: Alerts')
agp_Alert_MnExUp_B   = input.string('Off', 'Break Alert: Minor Ext Up',   ['On', 'Off'], group = 'AGP: Alerts')
agp_Alert_MnExUp_R   = input.string('Off', 'React Alert: Minor Ext Up',   ['On', 'Off'], group = 'AGP: Alerts')
agp_Alert_MnExDown_B = input.string('Off', 'Break Alert: Minor Ext Down', ['On', 'Off'], group = 'AGP: Alerts')
agp_Alert_MnExDown_R = input.string('Off', 'React Alert: Minor Ext Down', ['On', 'Off'], group = 'AGP: Alerts')
agp_Alert_MnInUp_B   = input.string('Off', 'Break Alert: Minor Int Up',   ['On', 'Off'], group = 'AGP: Alerts')
agp_Alert_MnInUp_R   = input.string('Off', 'React Alert: Minor Int Up',   ['On', 'Off'], group = 'AGP: Alerts')
agp_Alert_MnInDown_B = input.string('Off', 'Break Alert: Minor Int Down', ['On', 'Off'], group = 'AGP: Alerts')
agp_Alert_MnInDown_R = input.string('Off', 'React Alert: Minor Int Down', ['On', 'Off'], group = 'AGP: Alerts')

// -------------------------------------------------
// State containers
// -------------------------------------------------
var int    agp_x    = 0
var float  agp_y    = 0.0
var string agp_type = ''

var agp_QuickTagStore    = array.new_label(8, na)
var agp_EventBreakStore  = array.new_label(8, na)
var agp_EventReactStore  = array.new_label(8, na)
var agp_PostBreakStore   = array.new_label(8, na)

var agp_ZoneOriginStore  = array.new_box(8, na)
var agp_ZoneChannelStore = array.new_box(8, na)

var agp_ActiveOriginNow   = array.new_float(8, na)
var agp_ActiveChannelNow  = array.new_float(8, na)
var agp_ActiveIsLive      = array.new_bool(8, false)
var agp_ChannelTypeStore  = array.new_string(8, '')
var agp_ChannelClassStore = array.new_string(8, '')
var agp_ChannelLabelStore = array.new_string(8, '')
var agp_ChannelColorStore = array.new_color(8, na)

var agp_BreakLevelStore    = array.new_float(8, na)
var agp_BreakBarStore      = array.new_int(8, na)
var agp_BreakModeStore     = array.new_string(8, '')
var agp_PostBreakDoneStore = array.new_bool(8, false)

var agp_LastReactBarStore  = array.new_int(8, na)
var agp_LastReactPriceStore = array.new_float(8, na)

var table agp_InfoPanel     = table.new(position.top_right, 2, 8, border_width = 1, border_color = agp_PanelBorder)

// -------------------------------------------------
// Helper functions
// -------------------------------------------------
agp_isQualificationEnabled(channelClass) =>
    agp_QualMode != 'Off' and (agp_QualApplyTo == 'All' or (agp_QualApplyTo == 'Major Only' and channelClass == 'Major') or (agp_QualApplyTo == 'Minor Only' and channelClass == 'Minor'))

agp_getMinSpan(channelClass) =>
    int agp_MinSpan = 0
    if agp_QualMode == 'Balanced'
        agp_MinSpan := channelClass == 'Major' ? 8 : 5
    else if agp_QualMode == 'Strict'
        agp_MinSpan := channelClass == 'Major' ? 16 : 10
    agp_MinSpan

agp_getMinWidthAtr(channelClass) =>
    float agp_MinWidthAtr = 0.0
    if agp_QualMode == 'Balanced'
        agp_MinWidthAtr := channelClass == 'Major' ? 0.20 : 0.12
    else if agp_QualMode == 'Strict'
        agp_MinWidthAtr := channelClass == 'Major' ? 0.60 : 0.40
    agp_MinWidthAtr

agp_isChannelQualified(x0, y0, x1, y1, channelClass, channelWidth) =>
    bool agp_Qualified = true
    if agp_isQualificationEnabled(channelClass)
        int   agp_SpanBars = int(math.abs(x1 - x0))
        float agp_Atr      = ta.atr(agp_QualAtrLen)
        float agp_WidthAbs = math.abs(channelWidth)
        float agp_WidthAtr = agp_Atr > 0 ? agp_WidthAbs / agp_Atr : 0.0
        agp_Qualified := agp_SpanBars >= agp_getMinSpan(channelClass) and agp_WidthAtr >= agp_getMinWidthAtr(channelClass)
    agp_Qualified

agp_isBrokenMemoryEnabled(channelClass) =>
    agp_BrokenMemoryScope != 'Off' and (agp_BrokenMemoryScope == 'All' or (agp_BrokenMemoryScope == 'Major Only' and channelClass == 'Major'))

agp_isMidlineEnabled(channelClass) =>
    agp_ShowMidline and (agp_MidlineScope == 'All' or (agp_MidlineScope == 'Major Only' and channelClass == 'Major') or (agp_MidlineScope == 'Minor Only' and channelClass == 'Minor'))

agp_getMidlineColor(baseColor, isMemory) =>
    color.new(baseColor, int(math.min(95, agp_MidlineOpacity + (isMemory ? 20 : 0))))

agp_getTagSize() =>
    agp_TagSizeInput == 'Normal' ? size.normal : agp_TagSizeInput == 'Small' ? size.small : size.tiny

agp_getChannelSlot(channelLabel) =>
    switch channelLabel
        'Maj Ext Up'    => 0
        'Maj Ext Down'  => 1
        'Maj Int Up'    => 2
        'Maj Int Down'  => 3
        'Min Ext Up'    => 4
        'Min Ext Down'  => 5
        'Min Int Up'    => 6
        'Min Int Down'  => 7
        => 0

agp_getQuickTagText(channelLabel) =>
    switch channelLabel
        'Maj Ext Up'    => 'MEX UP'
        'Maj Ext Down'  => 'MEX DN'
        'Maj Int Up'    => 'MIN UP'
        'Maj Int Down'  => 'MIN DN'
        'Min Ext Up'    => 'mEX UP'
        'Min Ext Down'  => 'mEX DN'
        'Min Int Up'    => 'mIN UP'
        'Min Int Down'  => 'mIN DN'
        => channelLabel

agp_isQuickTagEnabled(channelClass) =>
    agp_ShowMajorQuickTags and (agp_QuickTagScope == 'All Visible' or (agp_QuickTagScope == 'All Major' and channelClass == 'Major') or (agp_QuickTagScope == 'Active Major Only' and channelClass == 'Major'))

agp_getEmphasisColor(baseColor, channelClass, isBaseLine) =>
    int agp_Opacity = 0
    if agp_EmphasisMode == 'Balanced'
        agp_Opacity := channelClass == 'Major' ? (isBaseLine and agp_FocusBaseLine ? 0 : 18) : (isBaseLine and agp_FocusBaseLine ? 32 : 45)
    else if agp_EmphasisMode == 'Strong'
        agp_Opacity := channelClass == 'Major' ? (isBaseLine and agp_FocusBaseLine ? 0 : 28) : (isBaseLine and agp_FocusBaseLine ? 42 : 62)
    color.new(baseColor, agp_Opacity)

agp_getEmphasisWidth(baseWidth, channelClass, isBaseLine) =>
    int agp_Width = baseWidth
    if agp_EmphasisMode == 'Balanced' and channelClass == 'Major' and isBaseLine and agp_FocusBaseLine
        agp_Width := baseWidth
    else if agp_EmphasisMode == 'Strong' and channelClass == 'Major' and isBaseLine and agp_FocusBaseLine
        agp_Width := baseWidth + 1
    else if channelClass == 'Minor' and not isBaseLine
        agp_Width := math.max(1, baseWidth - 0)
    agp_Width

agp_getFillColor(baseColor, channelClass) =>
    int agp_FillOpacity = agp_EmphasisMode == 'Strong' ? (channelClass == 'Major' ? 94 : 97) : (channelClass == 'Major' ? 96 : 98)
    color.new(baseColor, agp_FillOpacity)

agp_getLabelPrice(anchorPrice, useDownStyle, multiplier) =>
    float agp_Atr    = ta.atr(14)
    float agp_Offset = nz(agp_Atr, 0.0) * multiplier
    useDownStyle ? anchorPrice + agp_Offset : anchorPrice - agp_Offset

agp_isInteractionScopeEnabled(channelClass) =>
    agp_InteractionScope == 'All' or (agp_InteractionScope == 'Major Only' and channelClass == 'Major')

agp_isPostBreakScopeEnabled(channelClass) =>
    agp_PostBreakScope == 'All' or (agp_PostBreakScope == 'Major Only' and channelClass == 'Major')

agp_getPanelPosition() =>
    switch agp_PanelPosition
        'Top Left'      => position.top_left
        'Bottom Right'  => position.bottom_right
        'Bottom Left'   => position.bottom_left
        => position.top_right

agp_getPanelTextSize() =>
    agp_PanelTextSizeInput == 'Normal' ? size.normal : size.small

agp_getShortLabel(channelLabel) =>
    switch channelLabel
        'Maj Ext Up'    => 'M.Ext Up'
        'Maj Ext Down'  => 'M.Ext Down'
        'Maj Int Up'    => 'M.Int Up'
        'Maj Int Down'  => 'M.Int Down'
        'Min Ext Up'    => 'm.Ext Up'
        'Min Ext Down'  => 'm.Ext Down'
        'Min Int Up'    => 'm.Int Up'
        'Min Int Down'  => 'm.Int Down'
        => channelLabel

// -------------------------------------------------
// Interaction Zone renderer
// -------------------------------------------------
agp_renderInteractionZone(slot, railName, level, zoneColor, channelClass) =>
    box  agp_ZoneRef = railName == 'Origin' ? array.get(agp_ZoneOriginStore, slot) : array.get(agp_ZoneChannelStore, slot)
    bool agp_ShouldShow = agp_ShowInteractionZones and agp_isInteractionScopeEnabled(channelClass) and not na(level) and (agp_InteractionRails == 'Both' or (agp_InteractionRails == 'Origin Only' and railName == 'Origin') or (agp_InteractionRails == 'Channel Only' and railName == 'Channel'))
    if agp_ShouldShow
        float agp_Atr      = ta.atr(14)
        float agp_ZoneHalf = nz(agp_Atr, 0.0) * agp_InteractionWidthAtr
        int   agp_Left     = bar_index
        int   agp_Right    = bar_index + agp_InteractionExtendBars
        string agp_BoxText = agp_ShowInteractionText ? (railName == 'Origin' ? 'ORIGIN POCKET' : 'CHANNEL POCKET') : ''
        if na(agp_ZoneRef)
            agp_ZoneRef := box.new(agp_Left, level + agp_ZoneHalf, agp_Right, level - agp_ZoneHalf, border_color = color.new(zoneColor, 55), bgcolor = color.new(zoneColor, agp_InteractionOpacity), text = agp_BoxText, text_color = color.white, text_size = size.small, text_halign = text.align_right)
        else
            box.set_left(agp_ZoneRef, agp_Left)
            box.set_right(agp_ZoneRef, agp_Right)
            box.set_top(agp_ZoneRef, level + agp_ZoneHalf)
            box.set_bottom(agp_ZoneRef, level - agp_ZoneHalf)
            box.set_bgcolor(agp_ZoneRef, color.new(zoneColor, agp_InteractionOpacity))
            box.set_border_color(agp_ZoneRef, color.new(zoneColor, 55))
            box.set_text(agp_ZoneRef, agp_BoxText)
            box.set_text_color(agp_ZoneRef, color.white)
        if railName == 'Origin'
            array.set(agp_ZoneOriginStore, slot, agp_ZoneRef)
        else
            array.set(agp_ZoneChannelStore, slot, agp_ZoneRef)
    else
        if not na(agp_ZoneRef)
            box.delete(agp_ZoneRef)
            agp_ZoneRef := na
        if railName == 'Origin'
            array.set(agp_ZoneOriginStore, slot, agp_ZoneRef)
        else
            array.set(agp_ZoneChannelStore, slot, agp_ZoneRef)

// -------------------------------------------------
// Post-Break Retest / Reclaim tracker
// -------------------------------------------------
agp_updatePostBreakSignals() =>
    for agp_i = 0 to 7
        string agp_Class    = array.get(agp_ChannelClassStore, agp_i)
        string agp_Type     = array.get(agp_ChannelTypeStore, agp_i)
        color  agp_Color    = array.get(agp_ChannelColorStore, agp_i)
        float  agp_Level    = array.get(agp_BreakLevelStore, agp_i)
        int    agp_BreakBar = array.get(agp_BreakBarStore, agp_i)
        string agp_Mode     = array.get(agp_BreakModeStore, agp_i)
        bool   agp_Done     = array.get(agp_PostBreakDoneStore, agp_i)
        label  agp_PostLabel = array.get(agp_PostBreakStore, agp_i)
        bool   agp_Enabled  = agp_ShowPostBreakSignals and agp_isPostBreakScopeEnabled(agp_Class)
        if not agp_Enabled
            if not na(agp_PostLabel)
                label.delete(agp_PostLabel)
                agp_PostLabel := na
            array.set(agp_PostBreakStore, agp_i, agp_PostLabel)
        else
            bool agp_WithinWindow = not na(agp_BreakBar) and bar_index > agp_BreakBar and bar_index - agp_BreakBar <= agp_PostBreakWindow
            bool agp_ValidTouch   = not na(agp_Level) and (agp_Type == 'Up' ? low <= agp_Level and close > agp_Level : high >= agp_Level and close < agp_Level)
            if not agp_Done and agp_WithinWindow and agp_ValidTouch
                string agp_SignalText    = agp_Mode == 'OriginBreak' ? 'RECLAIM' : 'RETEST'
                bool   agp_UseDownStyle  = agp_Type == 'Down'
                agp_PostLabel := label.new(bar_index + agp_TagOffsetBars, agp_getLabelPrice(agp_Level, agp_UseDownStyle, agp_PostBreakOffsetAtr), agp_SignalText, style = agp_UseDownStyle ? label.style_label_down : label.style_label_up, color = color.new(agp_Color, 0), textcolor = color.white, size = agp_getTagSize())
                array.set(agp_PostBreakStore, agp_i, agp_PostLabel)
                array.set(agp_PostBreakDoneStore, agp_i, true)
            if not na(agp_BreakBar) and bar_index - agp_BreakBar > agp_PostBreakWindow
                array.set(agp_BreakBarStore, agp_i, na)
                array.set(agp_BreakLevelStore, agp_i, na)
                array.set(agp_BreakModeStore, agp_i, '')
                if not na(agp_PostLabel)
                    label.delete(agp_PostLabel)
                    agp_PostLabel := na
                array.set(agp_PostBreakStore, agp_i, agp_PostLabel)

// -------------------------------------------------
// Info Panel renderer
// -------------------------------------------------
agp_renderPanel(int breakFollowN, float breakFollowRate, bool breakFollowReady) =>
    if agp_ShowPanel
        int agp_MajorUp   = 0
        int agp_MajorDown = 0
        int agp_MinorUp   = 0
        int agp_MinorDown = 0
        float  agp_NearestDist = na
        string agp_NearestText = 'None'
        for agp_i = 0 to 7
            bool   agp_IsLive = array.get(agp_ActiveIsLive, agp_i)
            string agp_Class  = array.get(agp_ChannelClassStore, agp_i)
            string agp_Type   = array.get(agp_ChannelTypeStore, agp_i)
            float  agp_Level  = array.get(agp_ActiveOriginNow, agp_i)
            string agp_Label  = array.get(agp_ChannelLabelStore, agp_i)
            if agp_IsLive
                if agp_Class == 'Major' and agp_Type == 'Up'
                    agp_MajorUp += 1
                if agp_Class == 'Major' and agp_Type == 'Down'
                    agp_MajorDown += 1
                if agp_Class == 'Minor' and agp_Type == 'Up'
                    agp_MinorUp += 1
                if agp_Class == 'Minor' and agp_Type == 'Down'
                    agp_MinorDown += 1
                if not na(agp_Level)
                    float agp_Dist = math.abs(close - agp_Level)
                    if na(agp_NearestDist) or agp_Dist < agp_NearestDist
                        agp_NearestDist := agp_Dist
                        agp_NearestText := agp_getShortLabel(agp_Label)
        float agp_Atr     = ta.atr(14)
        float agp_DistAtr = not na(agp_NearestDist) and agp_Atr > 0 ? agp_NearestDist / agp_Atr : na
        string agp_DistanceTag   = na(agp_DistAtr) ? '' : (agp_DistAtr <= 1.0 ? 'Near' : agp_DistAtr <= 3.0 ? 'Mid' : agp_DistAtr <= 5.0 ? 'Wide' : 'Far')
        string agp_NearestLine   = not na(agp_DistAtr) ? agp_NearestText + ' | ' + str.tostring(agp_DistAtr, '#.##') + ' ATR | ' + agp_DistanceTag : 'None'
        string agp_ZoneLine      = agp_ShowInteractionZones ? agp_InteractionScope + ' | ' + agp_InteractionRails : 'Off'
        string agp_PostBreakLine = agp_ShowPostBreakSignals ? agp_PostBreakScope + ' | ' + str.tostring(agp_PostBreakWindow) + ' bars' : 'Off'
        string agp_QualLine      = agp_QualMode + ' | ' + agp_QualApplyTo
        string agp_BiasLine      = agp_MajorUp > agp_MajorDown ? 'Bullish Major Tilt' : agp_MajorDown > agp_MajorUp ? 'Bearish Major Tilt' : 'Balanced Major Tilt'

        table.clear(agp_InfoPanel, 0, 0, 1, 7)
        table.set_position(agp_InfoPanel, agp_getPanelPosition())

        table.cell(agp_InfoPanel, 0, 0, 'AG Pro Pivot Channel Map', text_color = agp_HeaderText, text_size = agp_getPanelTextSize(), bgcolor = agp_HeaderBg)
        table.cell(agp_InfoPanel, 1, 0, '', text_color = agp_HeaderText, text_size = agp_getPanelTextSize(), bgcolor = agp_HeaderBg)
        table.merge_cells(agp_InfoPanel, 0, 0, 1, 0)

        table.cell(agp_InfoPanel, 0, 1, 'Major Live',      text_color = agp_PanelLabelCol, text_size = agp_getPanelTextSize(), bgcolor = agp_PanelBg)
        table.cell(agp_InfoPanel, 1, 1, str.tostring(agp_MajorUp) + ' Up | ' + str.tostring(agp_MajorDown) + ' Down', text_color = agp_PanelValueCol, text_size = agp_getPanelTextSize(), bgcolor = agp_PanelBg)
        table.cell(agp_InfoPanel, 0, 2, 'Minor Live',      text_color = agp_PanelLabelCol, text_size = agp_getPanelTextSize(), bgcolor = agp_PanelBg)
        table.cell(agp_InfoPanel, 1, 2, str.tostring(agp_MinorUp) + ' Up | ' + str.tostring(agp_MinorDown) + ' Down', text_color = agp_PanelValueCol, text_size = agp_getPanelTextSize(), bgcolor = agp_PanelBg)
        table.cell(agp_InfoPanel, 0, 3, 'Nearest Channel', text_color = agp_PanelLabelCol, text_size = agp_getPanelTextSize(), bgcolor = agp_PanelBg)
        table.cell(agp_InfoPanel, 1, 3, agp_NearestLine,   text_color = agp_PanelValueCol, text_size = agp_getPanelTextSize(), bgcolor = agp_PanelBg)
        table.cell(agp_InfoPanel, 0, 4, 'Qualification',   text_color = agp_PanelLabelCol, text_size = agp_getPanelTextSize(), bgcolor = agp_PanelBg)
        table.cell(agp_InfoPanel, 1, 4, agp_QualLine,      text_color = agp_PanelValueCol, text_size = agp_getPanelTextSize(), bgcolor = agp_PanelBg)
        table.cell(agp_InfoPanel, 0, 5, 'Interaction',     text_color = agp_PanelLabelCol, text_size = agp_getPanelTextSize(), bgcolor = agp_PanelBg)
        table.cell(agp_InfoPanel, 1, 5, agp_ZoneLine,      text_color = agp_PanelValueCol, text_size = agp_getPanelTextSize(), bgcolor = agp_PanelBg)
        string agp_BreakFollowText = breakFollowN == 0 ? '-' : str.tostring(int(math.round(breakFollowRate))) + '%  n=' + str.tostring(breakFollowN)
        color  agp_BreakFollowColor = breakFollowReady ? (breakFollowRate >= 55.0 ? agp_BullColor : breakFollowRate >= 40.0 ? agp_NeutralColor : agp_BearColor) : agp_PanelLabelCol
        table.cell(agp_InfoPanel, 0, 6, 'Break Follow',    text_color = agp_PanelLabelCol, text_size = agp_getPanelTextSize(), bgcolor = agp_PanelBg)
        table.cell(agp_InfoPanel, 1, 6, agp_BreakFollowText, text_color = agp_BreakFollowColor, text_size = agp_getPanelTextSize(), bgcolor = agp_PanelBg)
        table.cell(agp_InfoPanel, 0, 7, 'Post-Break',      text_color = agp_PanelLabelCol, text_size = agp_getPanelTextSize(), bgcolor = agp_PanelBg)
        table.cell(agp_InfoPanel, 1, 7, agp_PostBreakLine + ' | ' + agp_BiasLine, text_color = agp_PanelValueCol, text_size = agp_getPanelTextSize(), bgcolor = agp_PanelBg)
    else
        table.clear(agp_InfoPanel, 0, 0, 1, 7)

// -------------------------------------------------
// Pivot / structural calculation (preserved from v3 core)
// -------------------------------------------------
agp_calculatePivots(pivotPeriod) =>
    Open      = open
    High      = high
    Low       = low
    Close     = close
    Bar_Index = bar_index
    var agp_ArrayType     = array.new_string()
    var agp_ArrayValue    = array.new_float()
    var agp_ArrayIndex    = array.new_int()
    var agp_ArrayTypeAdv  = array.new_string()
    var agp_ArrayValueAdv = array.new_float()
    var agp_ArrayIndexAdv = array.new_int()
    agp_Pass       = 0
    agp_HighPivot  = ta.pivothigh(pivotPeriod, pivotPeriod)
    agp_LowPivot   = ta.pivotlow(pivotPeriod, pivotPeriod)
    agp_HighValue  = ta.valuewhen(bool(agp_HighPivot), High[pivotPeriod],  0)
    agp_LowValue   = ta.valuewhen(bool(agp_LowPivot),  Low[pivotPeriod],   0)
    agp_HighIndex  = ta.valuewhen(bool(agp_HighPivot), Bar_Index[pivotPeriod], 0)
    agp_LowIndex   = ta.valuewhen(bool(agp_LowPivot),  Bar_Index[pivotPeriod], 0)
    agp_Correct_HighPivot = 0.0
    agp_Correct_LowPivot  = 0.0

    if bool(agp_HighPivot) and bool(agp_LowPivot)
        if agp_ArrayType.size() == 0
            agp_Pass := 1
            agp_Pass
        else if agp_ArrayType.size() >= 1
            if agp_ArrayType.get(agp_ArrayType.size() - 1) == 'L' or agp_ArrayType.get(agp_ArrayType.size() - 1) == 'LL'
                if agp_LowPivot < agp_ArrayValue.get(agp_ArrayType.size() - 1)
                    array.remove(agp_ArrayType,  agp_ArrayType.size()  - 1)
                    array.remove(agp_ArrayValue, agp_ArrayValue.size() - 1)
                    array.remove(agp_ArrayIndex, agp_ArrayIndex.size() - 1)
                    array.push(agp_ArrayType,  agp_ArrayType.size() > 2 ? agp_ArrayValue.get(agp_ArrayType.size() - 2) < agp_LowValue ? 'HL' : 'LL' : 'L')
                    array.push(agp_ArrayValue, agp_LowValue)
                    array.push(agp_ArrayIndex, agp_LowIndex)
                    agp_Correct_LowPivot := agp_LowValue
                    agp_Correct_LowPivot
                else
                    array.push(agp_ArrayType,  agp_ArrayType.size() > 2 ? agp_ArrayValue.get(agp_ArrayType.size() - 2) < agp_HighValue ? 'HH' : 'LH' : 'H')
                    array.push(agp_ArrayValue, agp_HighValue)
                    array.push(agp_ArrayIndex, agp_HighIndex)
                agp_Correct_HighPivot := agp_HighValue
                agp_Correct_HighPivot
            else if agp_ArrayType.get(agp_ArrayType.size() - 1) == 'H' or agp_ArrayType.get(agp_ArrayType.size() - 1) == 'HH'
                if agp_HighPivot > agp_ArrayValue.get(agp_ArrayType.size() - 1)
                    array.remove(agp_ArrayType,  agp_ArrayType.size()  - 1)
                    array.remove(agp_ArrayValue, agp_ArrayValue.size() - 1)
                    array.remove(agp_ArrayIndex, agp_ArrayIndex.size() - 1)
                    array.push(agp_ArrayType,  agp_ArrayType.size() > 2 ? agp_ArrayValue.get(agp_ArrayType.size() - 2) < agp_HighValue ? 'HH' : 'LH' : 'H')
                    array.push(agp_ArrayValue, agp_HighValue)
                    array.push(agp_ArrayIndex, agp_HighIndex)
                    agp_Correct_HighPivot := agp_HighValue
                    agp_Correct_HighPivot
                else
                    array.push(agp_ArrayType,  agp_ArrayType.size() > 2 ? agp_ArrayValue.get(agp_ArrayType.size() - 2) < agp_LowValue ? 'HL' : 'LL' : 'L')
                    array.push(agp_ArrayValue, agp_LowValue)
                    array.push(agp_ArrayIndex, agp_LowIndex)
                agp_Correct_LowPivot := agp_LowValue
                agp_Correct_LowPivot
            else if agp_ArrayType.get(agp_ArrayType.size() - 1) == 'LH'
                if agp_HighPivot < agp_ArrayValue.get(agp_ArrayType.size() - 1)
                    array.push(agp_ArrayType,  agp_ArrayType.size() > 2 ? agp_ArrayValue.get(agp_ArrayType.size() - 2) < agp_LowValue ? 'HL' : 'LL' : 'L')
                    array.push(agp_ArrayValue, agp_LowValue)
                    array.push(agp_ArrayIndex, agp_LowIndex)
                    agp_Correct_LowPivot := agp_LowValue
                    agp_Correct_LowPivot
                else if agp_HighPivot > agp_ArrayValue.get(agp_ArrayType.size() - 1)
                    if close < agp_ArrayValue.get(agp_ArrayType.size() - 1)
                        array.remove(agp_ArrayType,  agp_ArrayType.size()  - 1)
                        array.remove(agp_ArrayValue, agp_ArrayValue.size() - 1)
                        array.remove(agp_ArrayIndex, agp_ArrayIndex.size() - 1)
                        array.push(agp_ArrayType,  agp_ArrayType.size() > 2 ? agp_ArrayValue.get(agp_ArrayType.size() - 2) < agp_HighValue ? 'HH' : 'LH' : 'H')
                        array.push(agp_ArrayValue, agp_HighValue)
                        array.push(agp_ArrayIndex, agp_HighIndex)
                        agp_Correct_HighPivot := agp_HighValue
                        agp_Correct_HighPivot
                    else if close > agp_ArrayValue.get(agp_ArrayType.size() - 1)
                        array.push(agp_ArrayType,  agp_ArrayType.size() > 2 ? agp_ArrayValue.get(agp_ArrayType.size() - 2) < agp_LowValue ? 'HL' : 'LL' : 'L')
                        array.push(agp_ArrayValue, agp_LowValue)
                        array.push(agp_ArrayIndex, agp_LowIndex)
                        agp_Correct_LowPivot := agp_LowValue
                        agp_Correct_LowPivot
            else if agp_ArrayType.get(agp_ArrayType.size() - 1) == 'HL'
                if agp_LowPivot > agp_ArrayValue.get(agp_ArrayType.size() - 1)
                    array.push(agp_ArrayType,  agp_ArrayType.size() > 2 ? agp_ArrayValue.get(agp_ArrayType.size() - 2) < agp_HighValue ? 'HH' : 'LH' : 'H')
                    array.push(agp_ArrayValue, agp_HighValue)
                    array.push(agp_ArrayIndex, agp_HighIndex)
                    agp_Correct_HighPivot := agp_HighValue
                    agp_Correct_HighPivot
                else if agp_LowPivot < agp_ArrayValue.get(agp_ArrayType.size() - 1)
                    if close > agp_ArrayValue.get(agp_ArrayType.size() - 1)
                        array.remove(agp_ArrayType,  agp_ArrayType.size()  - 1)
                        array.remove(agp_ArrayValue, agp_ArrayValue.size() - 1)
                        array.remove(agp_ArrayIndex, agp_ArrayIndex.size() - 1)
                        array.push(agp_ArrayType,  agp_ArrayType.size() > 2 ? agp_ArrayValue.get(agp_ArrayType.size() - 2) < agp_LowValue ? 'HL' : 'LL' : 'L')
                        array.push(agp_ArrayValue, agp_LowValue)
                        array.push(agp_ArrayIndex, agp_LowIndex)
                        agp_Correct_LowPivot := agp_LowValue
                        agp_Correct_LowPivot
                    else if close < agp_ArrayValue.get(agp_ArrayType.size() - 1)
                        array.push(agp_ArrayType,  agp_ArrayType.size() > 2 ? agp_ArrayValue.get(agp_ArrayType.size() - 2) < agp_HighValue ? 'HH' : 'LH' : 'H')
                        array.push(agp_ArrayValue, agp_HighValue)
                        array.push(agp_ArrayIndex, agp_HighIndex)
                        agp_Correct_HighPivot := agp_HighValue
                        agp_Correct_HighPivot
    else if bool(agp_HighPivot)
        if agp_ArrayType.size() == 0
            array.insert(agp_ArrayType,  0, 'H')
            array.insert(agp_ArrayValue, 0, agp_HighValue)
            array.insert(agp_ArrayIndex, 0, agp_HighIndex)
            agp_Correct_HighPivot := agp_HighValue
            agp_Correct_HighPivot
        else if agp_ArrayType.size() >= 1
            if agp_ArrayType.get(agp_ArrayType.size() - 1) == 'L' or agp_ArrayType.get(agp_ArrayType.size() - 1) == 'HL' or agp_ArrayType.get(agp_ArrayType.size() - 1) == 'LL'
                if agp_HighPivot > agp_ArrayValue.get(agp_ArrayType.size() - 1)
                    array.push(agp_ArrayType,  agp_ArrayType.size() > 2 ? agp_ArrayValue.get(agp_ArrayType.size() - 2) < agp_HighValue ? 'HH' : 'LH' : 'H')
                    array.push(agp_ArrayValue, agp_HighValue)
                    array.push(agp_ArrayIndex, agp_HighIndex)
                    agp_Correct_HighPivot := agp_HighValue
                    agp_Correct_HighPivot
                else if agp_HighPivot < agp_ArrayValue.get(agp_ArrayType.size() - 1)
                    array.remove(agp_ArrayType,  agp_ArrayType.size()  - 1)
                    array.remove(agp_ArrayValue, agp_ArrayValue.size() - 1)
                    array.remove(agp_ArrayIndex, agp_ArrayIndex.size() - 1)
                    array.push(agp_ArrayType,  agp_ArrayType.size() > 2 ? agp_ArrayValue.get(agp_ArrayType.size() - 2) < agp_LowValue ? 'HL' : 'LL' : 'L')
                    array.push(agp_ArrayValue, agp_LowValue)
                    array.push(agp_ArrayIndex, agp_LowIndex)
                    agp_Correct_LowPivot := agp_LowValue
                    agp_Correct_LowPivot
            else if agp_ArrayType.get(agp_ArrayType.size() - 1) == 'H' or agp_ArrayType.get(agp_ArrayType.size() - 1) == 'HH' or agp_ArrayType.get(agp_ArrayType.size() - 1) == 'LH'
                if agp_ArrayValue.get(agp_ArrayValue.size() - 1) < agp_HighValue
                    array.remove(agp_ArrayType,  agp_ArrayType.size()  - 1)
                    array.remove(agp_ArrayValue, agp_ArrayValue.size() - 1)
                    array.remove(agp_ArrayIndex, agp_ArrayIndex.size() - 1)
                    array.push(agp_ArrayType,  agp_ArrayType.size() > 2 ? agp_ArrayValue.get(agp_ArrayType.size() - 2) < agp_HighValue ? 'HH' : 'LH' : 'H')
                    array.push(agp_ArrayValue, agp_HighValue)
                    array.push(agp_ArrayIndex, agp_HighIndex)
                    agp_Correct_HighPivot := agp_HighValue
                    agp_Correct_HighPivot
    else if bool(agp_LowPivot)
        if agp_ArrayType.size() == 0
            array.insert(agp_ArrayType,  0, 'L')
            array.insert(agp_ArrayValue, 0, agp_LowValue)
            array.insert(agp_ArrayIndex, 0, agp_LowIndex)
            agp_Correct_LowPivot := agp_LowValue
            agp_Correct_LowPivot
        else if agp_ArrayType.size() >= 1
            if agp_ArrayType.get(agp_ArrayType.size() - 1) == 'H' or agp_ArrayType.get(agp_ArrayType.size() - 1) == 'HH' or agp_ArrayType.get(agp_ArrayType.size() - 1) == 'LH'
                if agp_LowPivot < agp_ArrayValue.get(agp_ArrayType.size() - 1)
                    array.push(agp_ArrayType,  agp_ArrayType.size() > 2 ? agp_ArrayValue.get(agp_ArrayType.size() - 2) < agp_LowValue ? 'HL' : 'LL' : 'L')
                    array.push(agp_ArrayValue, agp_LowValue)
                    array.push(agp_ArrayIndex, agp_LowIndex)
                    agp_Correct_LowPivot := agp_LowValue
                    agp_Correct_LowPivot
                else if agp_LowPivot > agp_ArrayValue.get(agp_ArrayType.size() - 1)
                    array.remove(agp_ArrayType,  agp_ArrayType.size()  - 1)
                    array.remove(agp_ArrayValue, agp_ArrayValue.size() - 1)
                    array.remove(agp_ArrayIndex, agp_ArrayIndex.size() - 1)
                    array.push(agp_ArrayType,  agp_ArrayType.size() > 2 ? agp_ArrayValue.get(agp_ArrayType.size() - 2) < agp_HighValue ? 'HH' : 'LH' : 'H')
                    array.push(agp_ArrayValue, agp_HighValue)
                    array.push(agp_ArrayIndex, agp_HighIndex)
                    agp_Correct_HighPivot := agp_HighValue
                    agp_Correct_HighPivot
            else if agp_ArrayType.get(agp_ArrayType.size() - 1) == 'L' or agp_ArrayType.get(agp_ArrayType.size() - 1) == 'HL' or agp_ArrayType.get(agp_ArrayType.size() - 1) == 'LL'
                if agp_ArrayValue.get(agp_ArrayValue.size() - 1) > agp_LowValue
                    array.remove(agp_ArrayType,  agp_ArrayType.size()  - 1)
                    array.remove(agp_ArrayValue, agp_ArrayValue.size() - 1)
                    array.remove(agp_ArrayIndex, agp_ArrayIndex.size() - 1)
                    array.push(agp_ArrayType,  agp_ArrayType.size() > 2 ? agp_ArrayValue.get(agp_ArrayType.size() - 2) < agp_LowValue ? 'HL' : 'LL' : 'L')
                    array.push(agp_ArrayValue, agp_LowValue)
                    array.push(agp_ArrayIndex, agp_LowIndex)
                    agp_Correct_LowPivot := agp_LowValue
                    agp_Correct_LowPivot

    var float  agp_Major_HighLevel = na
    var float  agp_Major_LowLevel  = na
    var int    agp_Major_HighIndex = na
    var int    agp_Major_LowIndex  = na
    var string agp_Major_HighType  = na
    var string agp_Major_LowType   = na

    // Initial Major detection: trigger on the first time we have at least 2 pivots
    // and Major levels have not been seeded yet. Previous version used size == 2 which
    // silently skipped initialization on higher timeframes where pivots accumulate past 2
    // before this block ever observes size == 2 on a confirmed bar.
    if agp_ArrayType.size() >= 2 and na(agp_Major_HighLevel) and na(agp_Major_LowLevel)
        int agp_LastIdx = agp_ArrayType.size() - 1
        int agp_PrevIdx = agp_ArrayType.size() - 2
        string agp_LastT = agp_ArrayType.get(agp_LastIdx)
        string agp_PrevT = agp_ArrayType.get(agp_PrevIdx)
        // Use last two pivots: the newer one defines one rail, the older one defines the other
        bool agp_LastIsHigh = agp_LastT == 'H' or agp_LastT == 'HH' or agp_LastT == 'LH'
        bool agp_PrevIsHigh = agp_PrevT == 'H' or agp_PrevT == 'HH' or agp_PrevT == 'LH'
        if agp_LastIsHigh and not agp_PrevIsHigh
            agp_Major_HighLevel := agp_ArrayValue.get(agp_LastIdx)
            agp_Major_LowLevel  := agp_ArrayValue.get(agp_PrevIdx)
            agp_Major_HighIndex := agp_ArrayIndex.get(agp_LastIdx)
            agp_Major_LowIndex  := agp_ArrayIndex.get(agp_PrevIdx)
            agp_Major_HighType  := agp_LastT
            agp_Major_LowType   := agp_PrevT
            agp_Major_LowType
        else if not agp_LastIsHigh and agp_PrevIsHigh
            agp_Major_HighLevel := agp_ArrayValue.get(agp_PrevIdx)
            agp_Major_LowLevel  := agp_ArrayValue.get(agp_LastIdx)
            agp_Major_HighIndex := agp_ArrayIndex.get(agp_PrevIdx)
            agp_Major_LowIndex  := agp_ArrayIndex.get(agp_LastIdx)
            agp_Major_HighType  := agp_PrevT
            agp_Major_LowType   := agp_LastT
            agp_Major_LowType

    var bool agp_Lock0 = true
    var bool agp_Lock1 = true

    // Seed advanced pivot array with the first pivot once size reaches 1 or more
    if agp_ArrayValue.size() >= 1
        if agp_Lock0
            array.insert(agp_ArrayTypeAdv,  0, 'M' + agp_ArrayType.get(0))
            array.insert(agp_ArrayValueAdv, 0, agp_ArrayValue.get(0))
            array.insert(agp_ArrayIndexAdv, 0, agp_ArrayIndex.get(0))
            agp_Lock0 := false
            agp_Lock0

    // Seed the second pivot once size reaches 2 or more
    if agp_ArrayValue.size() >= 2
        if agp_Lock1
            array.insert(agp_ArrayTypeAdv,  1, 'M' + agp_ArrayType.get(1))
            array.insert(agp_ArrayValueAdv, 1, agp_ArrayValue.get(1))
            array.insert(agp_ArrayIndexAdv, 1, agp_ArrayIndex.get(1))
            agp_Lock1 := false
            agp_Lock1

    if agp_ArrayValue.size() > 1
        if agp_ArrayValue.get(agp_ArrayValue.size() - 1)[1] != agp_ArrayValue.get(agp_ArrayValue.size() - 1)
            if str.substring(agp_ArrayType.get(agp_ArrayType.size() - 1)[1], str.length(agp_ArrayType.get(agp_ArrayType.size() - 1)) - 1) != str.substring(agp_ArrayType.get(agp_ArrayType.size() - 1), str.length(agp_ArrayType.get(agp_ArrayType.size() - 1)) - 1)
                array.push(agp_ArrayTypeAdv,  'm' + agp_ArrayType.get(agp_ArrayType.size() - 1))
                array.push(agp_ArrayValueAdv, agp_ArrayValue.get(agp_ArrayValue.size() - 1))
                array.push(agp_ArrayIndexAdv, agp_ArrayIndex.get(agp_ArrayIndex.size() - 1))
            else if str.substring(agp_ArrayType.get(agp_ArrayType.size() - 1)[1], str.length(agp_ArrayType.get(agp_ArrayType.size() - 1)) - 1) == str.substring(agp_ArrayType.get(agp_ArrayType.size() - 1), str.length(agp_ArrayType.get(agp_ArrayType.size() - 1)) - 1)
                array.remove(agp_ArrayValueAdv, agp_ArrayValueAdv.size() - 1)
                array.remove(agp_ArrayIndexAdv, agp_ArrayIndexAdv.size() - 1)
                array.push(agp_ArrayValueAdv, agp_ArrayValue.get(agp_ArrayValue.size() - 1))
                array.push(agp_ArrayIndexAdv, agp_ArrayIndex.get(agp_ArrayIndex.size() - 1))

    if agp_ArrayValueAdv.size() > 1
        if not na(agp_Major_HighLevel) and close > agp_Major_HighLevel
            if agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'mL'
                agp_ArrayTypeAdv.remove(agp_ArrayTypeAdv.size() - 1)
                agp_ArrayTypeAdv.push('ML')
                agp_Major_LowLevel := agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 1)
                agp_Major_LowIndex := agp_ArrayIndexAdv.get(agp_ArrayIndexAdv.size() - 1)
                agp_Major_LowType  := agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1)
                agp_Major_LowType
            else if agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'mHL'
                agp_ArrayTypeAdv.remove(agp_ArrayTypeAdv.size() - 1)
                agp_ArrayTypeAdv.push('M' + agp_ArrayType.get(agp_ArrayType.size() - 1))
                agp_Major_LowLevel := agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 1)
                agp_Major_LowIndex := agp_ArrayIndexAdv.get(agp_ArrayIndexAdv.size() - 1)
                agp_Major_LowType  := agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1)
                agp_Major_LowType
            else if agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'mLL'
                agp_ArrayTypeAdv.remove(agp_ArrayTypeAdv.size() - 1)
                agp_ArrayTypeAdv.push('M' + agp_ArrayType.get(agp_ArrayType.size() - 1))
                agp_Major_LowLevel := agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 1)
                agp_Major_LowIndex := agp_ArrayIndexAdv.get(agp_ArrayIndexAdv.size() - 1)
                agp_Major_LowType  := agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1)
                agp_Major_LowType
            else if agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'mLH' or agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'mHH' or agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'MLH' or agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'MHH'
                if agp_ArrayTypeAdv.size() > 1 and agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 2) == 'mHL'
                    agp_ArrayTypeAdv.remove(agp_ArrayTypeAdv.size() - 2)
                    agp_ArrayTypeAdv.insert(agp_ArrayValueAdv.size() - 2, 'M' + agp_ArrayType.get(agp_ArrayType.size() - 2))
                    agp_Major_LowLevel := agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 2)
                    agp_Major_LowIndex := agp_ArrayIndexAdv.get(agp_ArrayIndexAdv.size() - 2)
                    agp_Major_LowType  := agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 2)
                    agp_Major_LowType
                else if agp_ArrayTypeAdv.size() > 1 and agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 2) == 'mLL'
                    agp_ArrayTypeAdv.remove(agp_ArrayTypeAdv.size() - 2)
                    agp_ArrayTypeAdv.insert(agp_ArrayValueAdv.size() - 2, 'M' + agp_ArrayType.get(agp_ArrayType.size() - 2))
                    agp_Major_LowLevel := agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 2)
                    agp_Major_LowIndex := agp_ArrayIndexAdv.get(agp_ArrayIndexAdv.size() - 2)
                    agp_Major_LowType  := agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 2)
                    agp_Major_LowType

        if not na(agp_Major_HighLevel) and agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 1) > agp_Major_HighLevel
            if agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'mH'
                agp_ArrayTypeAdv.remove(agp_ArrayTypeAdv.size() - 1)
                agp_ArrayTypeAdv.push('MH')
                agp_Major_HighLevel := agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 1)
                agp_Major_HighIndex := agp_ArrayIndexAdv.get(agp_ArrayIndexAdv.size() - 1)
                agp_Major_HighType  := agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1)
                agp_Major_HighType
            else if agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'mLH'
                agp_ArrayTypeAdv.remove(agp_ArrayTypeAdv.size() - 1)
                agp_ArrayTypeAdv.push('M' + agp_ArrayType.get(agp_ArrayType.size() - 1))
                agp_Major_HighLevel := agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 1)
                agp_Major_HighIndex := agp_ArrayIndexAdv.get(agp_ArrayIndexAdv.size() - 1)
                agp_Major_HighType  := agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1)
                agp_Major_HighType
            else if agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'mHH' or agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'MHH'
                agp_ArrayTypeAdv.remove(agp_ArrayTypeAdv.size() - 1)
                agp_ArrayTypeAdv.push('M' + agp_ArrayType.get(agp_ArrayType.size() - 1))
                agp_Major_HighLevel := agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 1)
                agp_Major_HighIndex := agp_ArrayIndexAdv.get(agp_ArrayIndexAdv.size() - 1)
                agp_Major_HighType  := agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1)
                agp_Major_HighType

        if not na(agp_Major_LowLevel) and close < agp_Major_LowLevel
            if agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'mH'
                agp_ArrayTypeAdv.remove(agp_ArrayTypeAdv.size() - 1)
                agp_ArrayTypeAdv.push('MH')
                agp_Major_HighLevel := agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 1)
                agp_Major_HighIndex := agp_ArrayIndexAdv.get(agp_ArrayIndexAdv.size() - 1)
                agp_Major_HighType  := agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1)
                agp_Major_HighType
            else if agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'mLH'
                agp_ArrayTypeAdv.remove(agp_ArrayTypeAdv.size() - 1)
                agp_ArrayTypeAdv.push('M' + agp_ArrayType.get(agp_ArrayType.size() - 1))
                agp_Major_HighLevel := agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 1)
                agp_Major_HighIndex := agp_ArrayIndexAdv.get(agp_ArrayIndexAdv.size() - 1)
                agp_Major_HighType  := agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1)
                agp_Major_HighType
            else if agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'mHH'
                agp_ArrayTypeAdv.remove(agp_ArrayTypeAdv.size() - 1)
                agp_ArrayTypeAdv.push('M' + agp_ArrayType.get(agp_ArrayType.size() - 1))
                agp_Major_HighLevel := agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 1)
                agp_Major_HighIndex := agp_ArrayIndexAdv.get(agp_ArrayIndexAdv.size() - 1)
                agp_Major_HighType  := agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1)
                agp_Major_HighType
            else if agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'mHL' or agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'mLL' or agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'MHL' or agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'MLL'
                if agp_ArrayTypeAdv.size() > 1 and agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 2) == 'mLH'
                    agp_ArrayTypeAdv.remove(agp_ArrayTypeAdv.size() - 2)
                    agp_ArrayTypeAdv.insert(agp_ArrayValueAdv.size() - 2, 'M' + agp_ArrayType.get(agp_ArrayType.size() - 2))
                    agp_Major_HighLevel := agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 2)
                    agp_Major_HighIndex := agp_ArrayIndexAdv.get(agp_ArrayIndexAdv.size() - 2)
                    agp_Major_HighType  := agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 2)
                    agp_Major_HighType
                else if agp_ArrayTypeAdv.size() > 1 and agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 2) == 'mHH'
                    agp_ArrayTypeAdv.remove(agp_ArrayTypeAdv.size() - 2)
                    agp_ArrayTypeAdv.insert(agp_ArrayValueAdv.size() - 2, 'M' + agp_ArrayType.get(agp_ArrayType.size() - 2))
                    agp_Major_HighLevel := agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 2)
                    agp_Major_HighIndex := agp_ArrayIndexAdv.get(agp_ArrayIndexAdv.size() - 2)
                    agp_Major_HighType  := agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 2)
                    agp_Major_HighType

        if not na(agp_Major_LowLevel) and agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 1) < agp_Major_LowLevel
            if agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'mL'
                agp_ArrayTypeAdv.remove(agp_ArrayTypeAdv.size() - 1)
                agp_ArrayTypeAdv.push('ML')
                agp_Major_LowLevel := agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 1)
                agp_Major_LowIndex := agp_ArrayIndexAdv.get(agp_ArrayIndexAdv.size() - 1)
                agp_Major_LowType  := agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1)
                agp_Major_LowType
            else if agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'mHL'
                agp_ArrayTypeAdv.remove(agp_ArrayTypeAdv.size() - 1)
                agp_ArrayTypeAdv.push('M' + agp_ArrayType.get(agp_ArrayType.size() - 1))
                agp_Major_LowLevel := agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 1)
                agp_Major_LowIndex := agp_ArrayIndexAdv.get(agp_ArrayIndexAdv.size() - 1)
                agp_Major_LowType  := agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1)
                agp_Major_LowType
            else if agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'mLL' or agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1) == 'MLL'
                agp_ArrayTypeAdv.remove(agp_ArrayTypeAdv.size() - 1)
                agp_ArrayTypeAdv.push('M' + agp_ArrayType.get(agp_ArrayType.size() - 1))
                agp_Major_LowLevel := agp_ArrayValueAdv.get(agp_ArrayValueAdv.size() - 1)
                agp_Major_LowIndex := agp_ArrayIndexAdv.get(agp_ArrayIndexAdv.size() - 1)
                agp_Major_LowType  := agp_ArrayTypeAdv.get(agp_ArrayTypeAdv.size() - 1)
                agp_Major_LowType
    [agp_ArrayTypeAdv, agp_ArrayValueAdv, agp_ArrayIndexAdv]

// -------------------------------------------------
// Channel point finder
// -------------------------------------------------
agp_findChannelPoints(x, y, type_str, pivotType) =>
    var int   agp_X0 = 0,   var int   agp_X1 = 0
    var float agp_Y0 = 0.0, var float agp_Y1 = 0.0
    if type_str != type_str[1]
        if type_str == pivotType
            if agp_X0 == 0
                agp_X0 := x
                agp_Y0 := y
                agp_Y0
            else
                if agp_X1 == 0
                    agp_X1 := x
                    agp_Y1 := y
                    agp_Y1
                else
                    agp_X0 := agp_X1
                    agp_Y0 := agp_Y1
                    agp_X1 := x
                    agp_Y1 := y
                    agp_Y1
    [agp_X0, agp_Y0, agp_X1, agp_Y1]

// -------------------------------------------------
// Draw and alert engine
// -------------------------------------------------
agp_drawAndAlert(x0, y0, x1, y1, channelType, channelClass, channelLabel, familySlot, showLine, deletePrevious, lineColor, lineStyle, lineExtend, lineWidth) =>
    var line     agp_Line_Origin    = na
    var line     agp_Line_Sub       = na
    var line     agp_Line_Channel   = na
    var line     agp_Line_Midline   = na
    var linefill agp_Channel_Above  = na
    var linefill agp_Channel_Below  = na
    var line     agp_Memory_Origin_1  = na
    var line     agp_Memory_Channel_1 = na
    var line     agp_Memory_Midline_1 = na
    var line     agp_Memory_Origin_2  = na
    var line     agp_Memory_Channel_2 = na
    var line     agp_Memory_Midline_2 = na

    label agp_EventLabel_Break = array.get(agp_EventBreakStore, familySlot)
    label agp_EventLabel_React = array.get(agp_EventReactStore, familySlot)
    label agp_QuickTag         = array.get(agp_QuickTagStore,   familySlot)

    var bool  agp_Permit      = true
    var bool  agp_Permit_set  = true
    var bool  agp_Alert_Break = false
    var bool  agp_Alert_React = false
    var float agp_Diff        = 0.0

    if (x0 != 0 and x1 != 0) and (x0 != x0[1])
        if channelType == 'Up' ? (y1 > y0) : (y1 < y0)
            agp_Line_Sub := line.new(x0, y0, x1, y1, color = na)
        for i = 1 to (bar_index - x0)
            agp_Permit := channelType == 'Up' ? close[bar_index - x0 - i] > line.get_price(agp_Line_Sub, (x0 + i)) and agp_Permit ? true : false : close[bar_index - x0 - i] < line.get_price(agp_Line_Sub, (x0 + i)) and agp_Permit ? true : false
            if agp_PivotPeriod < (bar_index - x0 - i) and agp_Permit
                if channelType == 'Up' ? high[bar_index - x0 - i] - line.get_price(agp_Line_Sub, (x0 + i)) > agp_Diff : low[bar_index - x0 - i] - line.get_price(agp_Line_Sub, (x0 + i)) < agp_Diff
                    agp_Diff := channelType == 'Up' ? high[bar_index - x0 - i] - line.get_price(agp_Line_Sub, (x0 + i)) : low[bar_index - x0 - i] - line.get_price(agp_Line_Sub, (x0 + i))

        bool agp_ChannelQualified = agp_isChannelQualified(x0, y0, x1, y1, channelClass, agp_Diff)
        if agp_Permit and agp_ChannelQualified
            bool  agp_ShowCurrentMidline = agp_isMidlineEnabled(channelClass)
            color agp_OriginColor        = agp_getEmphasisColor(lineColor, channelClass, true)
            color agp_ChannelColor       = agp_getEmphasisColor(lineColor, channelClass, false)
            int   agp_OriginWidth        = agp_getEmphasisWidth(lineWidth, channelClass, true)
            int   agp_ChannelWidth       = agp_getEmphasisWidth(lineWidth, channelClass, false)
            color agp_ActiveMidlineColor = agp_ShowCurrentMidline ? agp_getMidlineColor(lineColor, false) : color.new(lineColor, 100)
            if showLine
                agp_Line_Origin   := line.new(x0, y0, x1, y1, color = agp_OriginColor, style = lineStyle, extend = lineExtend, width = agp_OriginWidth)
                agp_Line_Channel  := line.new(x0, y0 + agp_Diff, x1, y1 + agp_Diff, color = agp_ChannelColor, style = lineStyle, extend = lineExtend, width = agp_ChannelWidth)
                agp_Line_Midline  := line.new(x0, y0 + agp_Diff / 2, x1, y1 + agp_Diff / 2, color = agp_ActiveMidlineColor, style = agp_MidlineStyle, extend = lineExtend, width = agp_ShowCurrentMidline ? agp_MidlineWidth : 1)
                agp_Channel_Above := linefill.new(agp_Line_Midline, agp_Line_Origin,  color = agp_getFillColor(lineColor, channelClass))
                agp_Channel_Below := linefill.new(agp_Line_Midline, agp_Line_Channel, color = agp_getFillColor(lineColor, channelClass))
            line.delete(agp_Line_Sub)
            if deletePrevious
                if agp_isBrokenMemoryEnabled(channelClass) and not agp_Permit_set[1] and not na(agp_Line_Origin[1]) and not na(agp_Line_Channel[1])
                    color agp_MemoryColor = color.new(lineColor, 86)
                    int   agp_MemoryWidth = math.max(1, lineWidth - 1)
                    if agp_BrokenMemoryKeep == 'Last 2'
                        line.delete(agp_Memory_Origin_2)
                        line.delete(agp_Memory_Channel_2)
                        line.delete(agp_Memory_Midline_2)
                        agp_Memory_Origin_2  := agp_Memory_Origin_1
                        agp_Memory_Channel_2 := agp_Memory_Channel_1
                        agp_Memory_Midline_2 := agp_Memory_Midline_1
                    else
                        line.delete(agp_Memory_Origin_1)
                        line.delete(agp_Memory_Channel_1)
                        line.delete(agp_Memory_Midline_1)
                    agp_Memory_Origin_1  := line.new(line.get_x1(agp_Line_Origin[1]),  line.get_y1(agp_Line_Origin[1]),  line.get_x2(agp_Line_Origin[1]),  line.get_y2(agp_Line_Origin[1]),  color = agp_MemoryColor, style = agp_BrokenMemoryStyle, extend = extend.none, width = agp_MemoryWidth)
                    agp_Memory_Channel_1 := line.new(line.get_x1(agp_Line_Channel[1]), line.get_y1(agp_Line_Channel[1]), line.get_x2(agp_Line_Channel[1]), line.get_y2(agp_Line_Channel[1]), color = agp_MemoryColor, style = agp_BrokenMemoryStyle, extend = extend.none, width = agp_MemoryWidth)
                    bool agp_ShowMemoryMidline = agp_MidlineApplyTo == 'All Visible' and agp_ShowCurrentMidline and not na(agp_Line_Midline[1])
                    if agp_ShowMemoryMidline
                        agp_Memory_Midline_1 := line.new(line.get_x1(agp_Line_Midline[1]), line.get_y1(agp_Line_Midline[1]), line.get_x2(agp_Line_Midline[1]), line.get_y2(agp_Line_Midline[1]), color = agp_getMidlineColor(lineColor, true), style = agp_MidlineStyle, extend = extend.none, width = agp_MemoryWidth)
                line.delete(agp_Line_Origin[1])
                line.delete(agp_Line_Channel[1])
                line.delete(agp_Line_Midline[1])
                linefill.delete(agp_Channel_Above[1])
                linefill.delete(agp_Channel_Below[1])
            agp_Permit_set := true
        else
            line.delete(agp_Line_Sub)
        if x0 != x0[1]
            agp_Permit := true
            agp_Diff   := 0.0

    float agp_OriginPriceNow  = not na(agp_Line_Origin)  ? line.get_price(agp_Line_Origin,  bar_index) : na
    float agp_ChannelPriceNow = not na(agp_Line_Channel) ? line.get_price(agp_Line_Channel, bar_index) : na

    bool agp_BrokeOrigin  = false
    bool agp_BrokeChannel = false
    if agp_Permit_set and not na(agp_Line_Origin) and not na(agp_Line_Channel) and not na(agp_Line_Midline)
        agp_BrokeOrigin  := channelType == 'Up' ? close <= agp_OriginPriceNow  : close >= agp_OriginPriceNow
        agp_BrokeChannel := channelType == 'Up' ? close >  agp_ChannelPriceNow : close <  agp_ChannelPriceNow
        if not agp_BrokeOrigin
            line.set_xy2(agp_Line_Origin,  bar_index + 1, line.get_price(agp_Line_Origin,  bar_index + 1))
            line.set_xy2(agp_Line_Channel, bar_index + 1, line.get_price(agp_Line_Channel, bar_index + 1))
            line.set_xy2(agp_Line_Midline, bar_index + 1, line.get_price(agp_Line_Midline, bar_index + 1))
        else
            agp_Permit_set := false

        if agp_BrokeChannel and agp_Permit_set
            agp_Permit_set := false

    agp_Alert_Break := not na(agp_OriginPriceNow) and barstate.isconfirmed and agp_Permit_set[1] and not agp_Permit_set ? true : false
    agp_Alert_React := not na(agp_OriginPriceNow) and channelType == 'Up' and (close > agp_OriginPriceNow and low < agp_OriginPriceNow or high > agp_OriginPriceNow and close < agp_OriginPriceNow) and barstate.isconfirmed and agp_Permit_set ? true : false or not na(agp_OriginPriceNow) and channelType == 'Down' and (close < agp_OriginPriceNow and high > agp_OriginPriceNow or low < agp_OriginPriceNow and high > agp_OriginPriceNow) and barstate.isconfirmed and agp_Permit_set ? true : false

    // React cooldown + ATR minimum price distance to prevent overlapping tags
    int   agp_LastReactBar    = array.get(agp_LastReactBarStore,   familySlot)
    float agp_LastReactPrice  = array.get(agp_LastReactPriceStore, familySlot)
    float agp_CurrentAtr      = ta.atr(14)
    bool  agp_ReactCooldownOk = na(agp_LastReactBar) or (bar_index - agp_LastReactBar) >= agp_ReactCooldownBars
    // Distance filter: if we have a prior React and a valid ATR and a valid origin, enforce minimum ATR-normalized price separation
    float agp_ReactCompareAnchor = not na(agp_OriginPriceNow) ? agp_OriginPriceNow : close
    bool  agp_ReactDistanceOk = true
    if agp_ReactMinPriceAtr > 0.0 and not na(agp_LastReactPrice) and not na(agp_CurrentAtr) and agp_CurrentAtr > 0
        agp_ReactDistanceOk := (math.abs(agp_ReactCompareAnchor - agp_LastReactPrice) / agp_CurrentAtr) >= agp_ReactMinPriceAtr

    if channelClass == 'Major' and agp_ShowEventMarkers
        if agp_Alert_Break and not na(agp_OriginPriceNow)
            label.delete(agp_EventLabel_Break)
            bool agp_BreakUseDownStyle = channelType == 'Up'
            agp_EventLabel_Break := label.new(bar_index + agp_TagOffsetBars, agp_getLabelPrice(agp_OriginPriceNow, agp_BreakUseDownStyle, agp_EventTagVerticalOffset), 'BREAK', style = agp_BreakUseDownStyle ? label.style_label_down : label.style_label_up, color = color.new(lineColor, 0), textcolor = color.white, size = agp_getTagSize())
        if agp_Alert_React and not na(agp_OriginPriceNow) and agp_ReactCooldownOk and agp_ReactDistanceOk
            label.delete(agp_EventLabel_React)
            bool agp_ReactUseDownStyle = channelType != 'Up'
            agp_EventLabel_React := label.new(bar_index + agp_TagOffsetBars, agp_getLabelPrice(agp_OriginPriceNow, agp_ReactUseDownStyle, math.max(0.12, agp_EventTagVerticalOffset * 0.9)), 'REACT', style = agp_ReactUseDownStyle ? label.style_label_down : label.style_label_up, color = color.new(lineColor, 12), textcolor = color.white, size = agp_getTagSize())
            array.set(agp_LastReactBarStore,   familySlot, bar_index)
            array.set(agp_LastReactPriceStore, familySlot, agp_OriginPriceNow)
    else
        label.delete(agp_EventLabel_Break)
        label.delete(agp_EventLabel_React)
        agp_EventLabel_Break := na
        agp_EventLabel_React := na

    if agp_isQuickTagEnabled(channelClass) and agp_Permit_set and not na(agp_Line_Origin)
        bool   agp_TagUseDownStyle   = channelType != 'Up'
        int    agp_LineEndX          = line.get_x2(agp_Line_Origin)
        int    agp_LineStartX        = line.get_x1(agp_Line_Origin)
        int    agp_TagXMin           = math.max(0, bar_index - 500)
        // Place tag slightly left of current bar for consistent visual placement next to candles
        int    agp_TagXPreferred     = bar_index - 2
        // But do not drift before line start or after line end
        int    agp_TagX              = math.max(agp_LineStartX, math.min(agp_LineEndX, math.max(agp_TagXMin, math.min(bar_index, agp_TagXPreferred))))
        bool   agp_TagWithinSafeWindow = agp_TagX >= agp_TagXMin and agp_TagX >= agp_LineStartX
        float  agp_TagAnchorPrice    = line.get_price(agp_Line_Origin, agp_TagX)
        float  agp_TagPrice          = agp_getLabelPrice(agp_TagAnchorPrice, agp_TagUseDownStyle, agp_QuickTagVerticalOffset)
        string agp_QuickTagText      = agp_getQuickTagText(channelLabel)
        if agp_TagWithinSafeWindow
            if na(agp_QuickTag)
                agp_QuickTag := label.new(agp_TagX, agp_TagPrice, agp_QuickTagText, style = agp_TagUseDownStyle ? label.style_label_down : label.style_label_up, color = color.new(lineColor, 10), textcolor = color.white, size = agp_getTagSize())
            else
                label.set_xy(agp_QuickTag, agp_TagX, agp_TagPrice)
                label.set_text(agp_QuickTag, agp_QuickTagText)
                label.set_style(agp_QuickTag, agp_TagUseDownStyle ? label.style_label_down : label.style_label_up)
                label.set_color(agp_QuickTag, color.new(lineColor, 10))
                label.set_textcolor(agp_QuickTag, color.white)
                label.set_size(agp_QuickTag, agp_getTagSize())
        else
            label.delete(agp_QuickTag)
            agp_QuickTag := na
    else
        label.delete(agp_QuickTag)
        agp_QuickTag := na

    array.set(agp_EventBreakStore, familySlot, agp_EventLabel_Break)
    array.set(agp_EventReactStore, familySlot, agp_EventLabel_React)
    array.set(agp_QuickTagStore,   familySlot, agp_QuickTag)

    array.set(agp_ActiveOriginNow,   familySlot, agp_Permit_set and not na(agp_OriginPriceNow)  ? agp_OriginPriceNow  : na)
    array.set(agp_ActiveChannelNow,  familySlot, agp_Permit_set and not na(agp_ChannelPriceNow) ? agp_ChannelPriceNow : na)
    array.set(agp_ActiveIsLive,      familySlot, agp_Permit_set and not na(agp_OriginPriceNow) and not na(agp_ChannelPriceNow))
    array.set(agp_ChannelTypeStore,  familySlot, channelType)
    array.set(agp_ChannelClassStore, familySlot, channelClass)
    array.set(agp_ChannelLabelStore, familySlot, channelLabel)
    array.set(agp_ChannelColorStore, familySlot, lineColor)

    if agp_Alert_Break
        float  agp_BreakLevel = agp_BrokeChannel ? agp_ChannelPriceNow : agp_OriginPriceNow
        string agp_BreakMode  = agp_BrokeChannel ? 'ChannelBreak' : 'OriginBreak'
        array.set(agp_BreakLevelStore,    familySlot, agp_BreakLevel)
        array.set(agp_BreakBarStore,      familySlot, bar_index)
        array.set(agp_BreakModeStore,     familySlot, agp_BreakMode)
        array.set(agp_PostBreakDoneStore, familySlot, false)
        label agp_OldPostLabel = array.get(agp_PostBreakStore, familySlot)
        if not na(agp_OldPostLabel)
            label.delete(agp_OldPostLabel)
            array.set(agp_PostBreakStore, familySlot, na)

    [agp_Alert_Break, agp_Alert_React]

// -------------------------------------------------
// Main execution
// -------------------------------------------------
[agp_TypeArr, agp_ValueArr, agp_IndexArr] = agp_calculatePivots(agp_PivotPeriod)

if agp_TypeArr.size() > 2
    agp_x    := agp_IndexArr.get(agp_TypeArr.size() - 1)
    agp_y    := agp_ValueArr.get(agp_TypeArr.size() - 1)
    agp_type := agp_TypeArr.get(agp_TypeArr.size() - 1)

[agp_MHL_x0, agp_MHL_y0, agp_MHL_x1, agp_MHL_y1] = agp_findChannelPoints(agp_x, agp_y, agp_type, 'MHL')
[agp_MLH_x0, agp_MLH_y0, agp_MLH_x1, agp_MLH_y1] = agp_findChannelPoints(agp_x, agp_y, agp_type, 'MLH')
[agp_MHH_x0, agp_MHH_y0, agp_MHH_x1, agp_MHH_y1] = agp_findChannelPoints(agp_x, agp_y, agp_type, 'MHH')
[agp_MLL_x0, agp_MLL_y0, agp_MLL_x1, agp_MLL_y1] = agp_findChannelPoints(agp_x, agp_y, agp_type, 'MLL')
[agp_mHL_x0, agp_mHL_y0, agp_mHL_x1, agp_mHL_y1] = agp_findChannelPoints(agp_x, agp_y, agp_type, 'mHL')
[agp_mLH_x0, agp_mLH_y0, agp_mLH_x1, agp_mLH_y1] = agp_findChannelPoints(agp_x, agp_y, agp_type, 'mLH')
[agp_mHH_x0, agp_mHH_y0, agp_mHH_x1, agp_mHH_y1] = agp_findChannelPoints(agp_x, agp_y, agp_type, 'mHH')
[agp_mLL_x0, agp_mLL_y0, agp_mLL_x1, agp_mLL_y1] = agp_findChannelPoints(agp_x, agp_y, agp_type, 'mLL')

[agp_Alert_Break_MjExUp,   agp_Alert_React_MjExUp]   = agp_drawAndAlert(agp_MLL_x0, agp_MLL_y0, agp_MLL_x1, agp_MLL_y1, 'Up',   'Major', 'Maj Ext Up',   agp_getChannelSlot('Maj Ext Up'),   agp_Show_MjExUp,   agp_Delete_Pre_MjExUp,   agp_Color_MjExUp,   agp_Style_MjExUp,   agp_Extend_MjExUp,   agp_Width_MjExUp)
[agp_Alert_Break_MjExDown, agp_Alert_React_MjExDown] = agp_drawAndAlert(agp_MHH_x0, agp_MHH_y0, agp_MHH_x1, agp_MHH_y1, 'Down', 'Major', 'Maj Ext Down', agp_getChannelSlot('Maj Ext Down'), agp_Show_MjExDown, agp_Delete_Pre_MjExDown, agp_Color_MjExDown, agp_Style_MjExDown, agp_Extend_MjExDown, agp_Width_MjExDown)
[agp_Alert_Break_MjInUp,   agp_Alert_React_MjInUp]   = agp_drawAndAlert(agp_MHL_x0, agp_MHL_y0, agp_MHL_x1, agp_MHL_y1, 'Up',   'Major', 'Maj Int Up',   agp_getChannelSlot('Maj Int Up'),   agp_Show_MjInUp,   agp_Delete_Pre_MjInUp,   agp_Color_MjInUp,   agp_Style_MjInUp,   agp_Extend_MjInUp,   agp_Width_MjInUp)
[agp_Alert_Break_MjInDown, agp_Alert_React_MjInDown] = agp_drawAndAlert(agp_MLH_x0, agp_MLH_y0, agp_MLH_x1, agp_MLH_y1, 'Down', 'Major', 'Maj Int Down', agp_getChannelSlot('Maj Int Down'), agp_Show_MjInDown, agp_Delete_Pre_MjInDown, agp_Color_MjInDown, agp_Style_MjInDown, agp_Extend_MjInDown, agp_Width_MjInDown)
[agp_Alert_Break_MnExUp,   agp_Alert_React_MnExUp]   = agp_drawAndAlert(agp_mLL_x0, agp_mLL_y0, agp_mLL_x1, agp_mLL_y1, 'Up',   'Minor', 'Min Ext Up',   agp_getChannelSlot('Min Ext Up'),   agp_Show_MnExUp,   agp_Delete_Pre_MnExUp,   agp_Color_MnExUp,   agp_Style_MnExUp,   agp_Extend_MnExUp,   agp_Width_MnExUp)
[agp_Alert_Break_MnExDown, agp_Alert_React_MnExDown] = agp_drawAndAlert(agp_mHH_x0, agp_mHH_y0, agp_mHH_x1, agp_mHH_y1, 'Down', 'Minor', 'Min Ext Down', agp_getChannelSlot('Min Ext Down'), agp_Show_MnExDown, agp_Delete_Pre_MnExDown, agp_Color_MnExDown, agp_Style_MnExDown, agp_Extend_MnExDown, agp_Width_MnExDown)
[agp_Alert_Break_MnInUp,   agp_Alert_React_MnInUp]   = agp_drawAndAlert(agp_mHL_x0, agp_mHL_y0, agp_mHL_x1, agp_mHL_y1, 'Up',   'Minor', 'Min Int Up',   agp_getChannelSlot('Min Int Up'),   agp_Show_MnInUp,   agp_Delete_Pre_MnInUp,   agp_Color_MnInUp,   agp_Style_MnInUp,   agp_Extend_MnInUp,   agp_Width_MnInUp)
[agp_Alert_Break_MnInDown, agp_Alert_React_MnInDown] = agp_drawAndAlert(agp_mLH_x0, agp_mLH_y0, agp_mLH_x1, agp_mLH_y1, 'Down', 'Minor', 'Min Int Down', agp_getChannelSlot('Min Int Down'), agp_Show_MnInDown, agp_Delete_Pre_MnInDown, agp_Color_MnInDown, agp_Style_MnInDown, agp_Extend_MnInDown, agp_Width_MnInDown)

// -------------------------------------------------
// Break follow-rate layer
// Each confirmed MAJOR channel break is tracked once. The break
// direction comes from the stored break mode: on an Up channel a
// ChannelBreak points up and an OriginBreak points down; on a Down
// channel the mapping is mirrored. The break counts as followed when
// price extends 1.5 ATR in the break direction before closing back
// through the frozen break level, and as failed when the level is
// reclaimed first or the tracking window times out. Registration
// happens only on confirmed bars, so the statistic never repaints.
// Resolution runs before registration.
// -------------------------------------------------
agp_FollowAtr = ta.atr(14)
var bool  agp_BfTrkOn    = false
var int   agp_BfTrkDir   = 0
var float agp_BfTrkTgt   = na
var float agp_BfTrkInv   = na
var int   agp_BfTrkStart = na
var int   agp_BreakFollowW = 0
var int   agp_BreakFollowN = 0
agp_BfWindow = math.max(20, agp_PostBreakWindow * 2)
if agp_BfTrkOn
    bool agp_BfFollowed = agp_BfTrkDir == 1 ? high >= agp_BfTrkTgt : low <= agp_BfTrkTgt
    bool agp_BfFailed   = agp_BfTrkDir == 1 ? close < agp_BfTrkInv : close > agp_BfTrkInv
    bool agp_BfTimeout  = not na(agp_BfTrkStart) and bar_index - agp_BfTrkStart >= agp_BfWindow
    if agp_BfFailed or agp_BfTimeout
        agp_BreakFollowN += 1
        agp_BfTrkOn := false
    else if agp_BfFollowed
        agp_BreakFollowN += 1
        agp_BreakFollowW += 1
        agp_BfTrkOn := false
agp_MajorBreakNow = barstate.isconfirmed and (agp_Alert_Break_MjExUp or agp_Alert_Break_MjExDown or agp_Alert_Break_MjInUp or agp_Alert_Break_MjInDown)
if agp_MajorBreakNow and not agp_BfTrkOn
    int agp_BfSlot = agp_Alert_Break_MjExUp ? 0 : agp_Alert_Break_MjExDown ? 1 : agp_Alert_Break_MjInUp ? 2 : 3
    string agp_BfType = array.get(agp_ChannelTypeStore, agp_BfSlot)
    string agp_BfMode = array.get(agp_BreakModeStore,   agp_BfSlot)
    float  agp_BfLevel = array.get(agp_BreakLevelStore, agp_BfSlot)
    if not na(agp_BfLevel) and not na(agp_FollowAtr) and agp_FollowAtr > 0
        int agp_BfDir = agp_BfType == 'Up' ? (agp_BfMode == 'ChannelBreak' ? 1 : -1) : (agp_BfMode == 'ChannelBreak' ? -1 : 1)
        agp_BfTrkOn    := true
        agp_BfTrkDir   := agp_BfDir
        agp_BfTrkTgt   := close + agp_BfDir * agp_FollowAtr * 1.5
        agp_BfTrkInv   := agp_BfLevel
        agp_BfTrkStart := bar_index
agp_BreakFollowRate = agp_BreakFollowN > 0 ? 100.0 * agp_BreakFollowW / agp_BreakFollowN : na
agp_BreakFollowReady = agp_BreakFollowN >= 8

for agp_slot = 0 to 7
    string agp_ClassSlot   = array.get(agp_ChannelClassStore, agp_slot)
    color  agp_ColorSlot   = array.get(agp_ChannelColorStore, agp_slot)
    float  agp_OriginSlot  = array.get(agp_ActiveOriginNow,   agp_slot)
    float  agp_ChannelSlot = array.get(agp_ActiveChannelNow,  agp_slot)
    agp_renderInteractionZone(agp_slot, 'Origin',  agp_OriginSlot,  agp_ColorSlot, agp_ClassSlot)
    agp_renderInteractionZone(agp_slot, 'Channel', agp_ChannelSlot, agp_ColorSlot, agp_ClassSlot)

agp_updatePostBreakSignals()
agp_renderPanel(agp_BreakFollowN, agp_BreakFollowRate, agp_BreakFollowReady)

// -------------------------------------------------
// Alert dispatcher
// -------------------------------------------------
agp_AlertSender(bool Condition, string Alert, string AlertName, string AlertType, string DetectionType, string SetupData, string Frequncy, string UTC, string MoreInfo, string Message, float o, float h, float l, float c, float Entry, float TP, float SL, float Distal, float Proximal) =>
    bool   agp_condition     = Condition
    string agp_alert_switch  = Alert
    string agp_alertname     = AlertName
    string agp_message       = Message
    string agp_alerttype     = AlertType
    string agp_frequency     = Frequncy
    string agp_detectiontype = DetectionType
    string agp_moreinfo      = MoreInfo
    float  agp_O = o
    float  agp_H = h
    float  agp_L = l
    float  agp_C = c
    float  agp_entry = Entry
    float  agp_tp    = TP
    float  agp_sl    = SL
    string agp_Time  = str.format_time(time, "    yy-MM-dd \n    HH:mm:ss", UTC)

    string agp_Type = if agp_detectiontype == 'Signal' or agp_detectiontype == 'Order Block Signal' or agp_detectiontype == 'Setup'
        if agp_alerttype == 'Bullish'
            'Long ' + agp_detectiontype
        else if agp_alerttype == 'Bearish'
            'Short ' + agp_detectiontype
    else
        agp_alerttype + ' ' + agp_detectiontype

    string agp_tf = timeframe.period
    string agp_tfcalculator = if str.contains(agp_tf, 'S')
        if agp_tf == 'S'
            ' 1 Second'
        else
            str.substring(agp_tf, 0, str.length(agp_tf) - 1) + ' Seconds'
    else if str.contains(agp_tf, 'D')
        if agp_tf == 'D'
            ' Daily'
        else
            str.substring(agp_tf, 0, str.length(agp_tf) - 1) + ' Days'
    else if str.contains(agp_tf, 'W')
        if agp_tf == 'W'
            ' Weekly'
        else
            str.substring(agp_tf, 0, str.length(agp_tf) - 1) + ' Weeks'
    else if str.contains(agp_tf, 'M')
        if agp_tf == 'M'
            ' Monthly'
        else
            str.substring(agp_tf, 0, str.length(agp_tf) - 1) + ' Months'
    else if str.contains(agp_tf, '')
        if str.tonumber(agp_tf) < 60
            if agp_tf == '1'
                '1 Minute'
            else
                agp_tf + ' Minutes'
        else if str.tonumber(agp_tf) >= 60
            if agp_tf == '60'
                ' 1 Hour'
            else
                str.tostring(str.tonumber(agp_tf) / 60) + ' Hours'

    string agp_messagetext = if agp_moreinfo == 'Off'
        'Alert Name: ' + agp_alertname + '\nAlert Type: ' + agp_Type + '\nSymbol: ' + syminfo.ticker + '\nTime Frame: ' + agp_tfcalculator + '\nMessage: ' + agp_message
    else if agp_moreinfo == 'On'
        if agp_detectiontype == 'Order Block Signal'
            'Alert Name: ' + agp_alertname + '\nAlert Type: ' + agp_Type + '\nSymbol: ' + syminfo.ticker + '\nTime Frame: ' + agp_tfcalculator + '\nTime:' + '\n' + agp_Time + '\nZone Price =>' + '\n     Distal:' + str.tostring(Distal) + '\n     Proximal:' + str.tostring(Proximal) + '\nMessage: ' + agp_message
        else if agp_detectiontype == 'Signal'
            'Alert Name: ' + agp_alertname + '\nAlert Type: ' + agp_Type + '\nSymbol: ' + syminfo.ticker + '\nTime Frame: ' + agp_tfcalculator + '\nTime:' + '\n' + agp_Time + '\nMarket Price =>' + '\n     Open:' + str.tostring(agp_O) + '\n     High:' + str.tostring(agp_H) + '\n     Low:' + str.tostring(agp_L) + '\n     Close:' + str.tostring(agp_C) + '\nMessage: ' + agp_message
        else if agp_detectiontype == 'Setup'
            if SetupData == 'Full'
                'Alert Name: ' + agp_alertname + '\nAlert Type: ' + agp_Type + '\nSymbol: ' + syminfo.ticker + '\nTime Frame: ' + agp_tfcalculator + '\nTime:' + '\n' + agp_Time + '\nSetup Price Data =>' + '\n     Entry:' + str.tostring(agp_entry) + '\n     Stop Loss:' + str.tostring(agp_sl) + '\n     Take Profit:' + str.tostring(agp_tp) + '\nMessage: ' + agp_message
            else if SetupData == 'Basic'
                'Alert Name: ' + agp_alertname + '\nAlert Type: ' + agp_Type + '\nSymbol: ' + syminfo.ticker + '\nTime Frame: ' + agp_tfcalculator + '\nTime:' + '\n' + agp_Time + '\nSetup Price Data =>' + '\n     Entry:' + str.tostring(agp_O) + '\nMessage: ' + agp_message
        else if agp_detectiontype == 'Analysis'
            'Alert Name: ' + agp_alertname + '\nAlert Type: ' + agp_Type + '\nSymbol: ' + syminfo.ticker + '\nTime Frame: ' + agp_tfcalculator + '\nMessage: ' + agp_message
        else
            'Alert Name: ' + agp_alertname + '\nAlert Type: ' + agp_Type + '\nSymbol: ' + syminfo.ticker + '\nTime Frame: ' + agp_tfcalculator + '\nTime:' + '\n' + agp_Time + '\nMessage: ' + agp_message

    if agp_alert_switch == 'On'
        if agp_condition
            if agp_frequency == 'All'
                alert(agp_messagetext, alert.freq_all)
            if agp_frequency == 'Once Per Bar'
                alert(agp_messagetext, alert.freq_once_per_bar)
            if agp_frequency == 'Once Per Bar Close'
                alert(agp_messagetext, alert.freq_once_per_bar_close)

// -------------------------------------------------
// Alert firing
// -------------------------------------------------
agp_AlertSender(agp_Alert_Break_MjExUp,   agp_Alert_MjExUp_B,   agp_AlertName, 'Analysis', '', 'Basic', agp_AlertFrequency, agp_AlertTimezone, 'On', 'Break Major External Up Channel',   open, high, low, close, 0, 0, 0, 0, 0)
agp_AlertSender(agp_Alert_React_MjExUp,   agp_Alert_MjExUp_R,   agp_AlertName, 'Analysis', '', 'Basic', agp_AlertFrequency, agp_AlertTimezone, 'On', 'React Major External Up Channel',   open, high, low, close, 0, 0, 0, 0, 0)
agp_AlertSender(agp_Alert_Break_MjExDown, agp_Alert_MjExDown_B, agp_AlertName, 'Analysis', '', 'Basic', agp_AlertFrequency, agp_AlertTimezone, 'On', 'Break Major External Down Channel', open, high, low, close, 0, 0, 0, 0, 0)
agp_AlertSender(agp_Alert_React_MjExDown, agp_Alert_MjExDown_R, agp_AlertName, 'Analysis', '', 'Basic', agp_AlertFrequency, agp_AlertTimezone, 'On', 'React Major External Down Channel', open, high, low, close, 0, 0, 0, 0, 0)
agp_AlertSender(agp_Alert_Break_MjInUp,   agp_Alert_MjInUp_B,   agp_AlertName, 'Analysis', '', 'Basic', agp_AlertFrequency, agp_AlertTimezone, 'On', 'Break Major Internal Up Channel',   open, high, low, close, 0, 0, 0, 0, 0)
agp_AlertSender(agp_Alert_React_MjInUp,   agp_Alert_MjInUp_R,   agp_AlertName, 'Analysis', '', 'Basic', agp_AlertFrequency, agp_AlertTimezone, 'On', 'React Major Internal Up Channel',   open, high, low, close, 0, 0, 0, 0, 0)
agp_AlertSender(agp_Alert_Break_MjInDown, agp_Alert_MjInDown_B, agp_AlertName, 'Analysis', '', 'Basic', agp_AlertFrequency, agp_AlertTimezone, 'On', 'Break Major Internal Down Channel', open, high, low, close, 0, 0, 0, 0, 0)
agp_AlertSender(agp_Alert_React_MjInDown, agp_Alert_MjInDown_R, agp_AlertName, 'Analysis', '', 'Basic', agp_AlertFrequency, agp_AlertTimezone, 'On', 'React Major Internal Down Channel', open, high, low, close, 0, 0, 0, 0, 0)
agp_AlertSender(agp_Alert_Break_MnExUp,   agp_Alert_MnExUp_B,   agp_AlertName, 'Analysis', '', 'Basic', agp_AlertFrequency, agp_AlertTimezone, 'On', 'Break Minor External Up Channel',   open, high, low, close, 0, 0, 0, 0, 0)
agp_AlertSender(agp_Alert_React_MnExUp,   agp_Alert_MnExUp_R,   agp_AlertName, 'Analysis', '', 'Basic', agp_AlertFrequency, agp_AlertTimezone, 'On', 'React Minor External Up Channel',   open, high, low, close, 0, 0, 0, 0, 0)
agp_AlertSender(agp_Alert_Break_MnExDown, agp_Alert_MnExDown_B, agp_AlertName, 'Analysis', '', 'Basic', agp_AlertFrequency, agp_AlertTimezone, 'On', 'Break Minor External Down Channel', open, high, low, close, 0, 0, 0, 0, 0)
agp_AlertSender(agp_Alert_React_MnExDown, agp_Alert_MnExDown_R, agp_AlertName, 'Analysis', '', 'Basic', agp_AlertFrequency, agp_AlertTimezone, 'On', 'React Minor External Down Channel', open, high, low, close, 0, 0, 0, 0, 0)
agp_AlertSender(agp_Alert_Break_MnInUp,   agp_Alert_MnInUp_B,   agp_AlertName, 'Analysis', '', 'Basic', agp_AlertFrequency, agp_AlertTimezone, 'On', 'Break Minor Internal Up Channel',   open, high, low, close, 0, 0, 0, 0, 0)
agp_AlertSender(agp_Alert_React_MnInUp,   agp_Alert_MnInUp_R,   agp_AlertName, 'Analysis', '', 'Basic', agp_AlertFrequency, agp_AlertTimezone, 'On', 'React Minor Internal Up Channel',   open, high, low, close, 0, 0, 0, 0, 0)
agp_AlertSender(agp_Alert_Break_MnInDown, agp_Alert_MnInDown_B, agp_AlertName, 'Analysis', '', 'Basic', agp_AlertFrequency, agp_AlertTimezone, 'On', 'Break Minor Internal Down Channel', open, high, low, close, 0, 0, 0, 0, 0)
agp_AlertSender(agp_Alert_React_MnInDown, agp_Alert_MnInDown_R, agp_AlertName, 'Analysis', '', 'Basic', agp_AlertFrequency, agp_AlertTimezone, 'On', 'React Minor Internal Down Channel', open, high, low, close, 0, 0, 0, 0, 0)
````
