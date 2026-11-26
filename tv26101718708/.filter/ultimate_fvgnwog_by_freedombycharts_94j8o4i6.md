# Ultimate FVG/NWOG By FreedomByCharts

- url: https://www.tradingview.com/script/94J8o4i6-Ultimate-FVG-NWOG-By-FreedomByCharts/
- type: indicator
- pine_id: PUB;2dca89493b69418c9be58b560cc09c5a
- version: 5.0

## Description

Ultimate FVG/NWOG By FreedomByCharts
A clean, no-bloat FVG and NWOG indicator built around how I actually trade: chart timeframe + three independent higher timeframes + the New Week Opening Gap, all in one global colour scheme with sensible defaults and granular per-source control.
Why this one
Most FVG indicators on TV fall into one of two camps. Either they're stripped down to the bare chart-timeframe pattern with a single fill colour and a hardcoded mitigation rule, or they're bloated with theme presets, IPDA modes, half-finished features and ten settings groups you'll never use. This one is built the other way round: deep where it matters (mitigation logic, NWOG accuracy, display control), and stripped of everything that doesn't earn its place on the chart.
What's actually different:
Four mitigation modes, not one. Wick Filled (full), Body Filled (full), Wick 50%, Body 50%. Pick what matches your model — strict body close beyond the far side, or a partial wick into the midpoint, or anything between.
Independent box and line visibility per source. Box on, lines off. Lines on, box off. Top + bottom only, no middle. Mid line dotted, top and bottom solid. Whatever you want — five sources, each independent.
Mitigated FVGs become iFVGs. When an FVG gets mitigated its label flips from e.g. `1H` to `1H iFVG`, marking the zone as an inverted FVG — the same level can now act in the opposite direction. NWOG labels stay as `NWOG` since the inversion concept doesn't apply.
Mitigated zones can drop their lines automatically. Per-source toggle: keep the grey box for context, lose the line clutter. Active zones stay fully drawn.
Three HTFs at once, plus chart TF, plus NWOG. Run 1H, 4H, 1D simultaneously while the chart-TF FVGs print on whatever you're looking at. Each fully configurable. No request.security guesswork — the HTF tracking is explicit and aligned to the chart bars where each HTF period's high and low actually occurred.
NWOG done properly, including holiday weeks. The NWOG anchors to the close of the last 1H bar before the weekend (Friday on a normal week, Thursday on Easter / Good Friday week) and the open of Sunday's first 1H bar. No stale Friday-only state, no wrong-priced boxes anchored at the wrong bar after holiday closes.
Single global colour scheme. One bullish colour, one bearish colour, one mitigated grey. Applied uniformly across every source for a clean, professional look. NWOG can override its own bull/bear colours if you want it to stand out.
No display caps you have to work around. Set the unfilled count and mitigated count per source to whatever you actually want to see. Old zones get pruned automatically as new ones form.
What it draws
Chart FVGs — current timeframe, both bullish and bearish.
HTF1, HTF2, HTF3 — three configurable higher timeframes (defaults: 1H, 4H, 1D), all rendered on the current chart.
NWOG — the body gap between the close of the last 1H trading bar before the weekend and the open of Sunday's first 1H bar.
For each zone you get an optional coloured box (transparency adjustable), an optional top line, mid line, bot line (each with independent show/hide and Solid/Dashed/Dotted style), and an optional label showing the timeframe (auto-formatted as "1H", "4H", "1D", "NWOG", etc).
When a zone is mitigated, the box recolours to grey, the lines either go grey or hide entirely depending on the per-source toggle, and the label flips to show iFVG status (e.g. `1H` becomes `1H iFVG` — NWOGs keep their `NWOG` label). Mitigated zones stay visible for as many slots as you allow, then get pruned.
Mitigation methods explained
For a bullish FVG (zone below price), the chosen method tests whether price has come back down into the zone:
Wick Filled (full) — bar's low has reached the bottom of the zone. Default.
Body Filled (full) — bar's close has reached the bottom of the zone.
Wick 50% — bar's low has reached the midpoint.
Body 50% — bar's close has reached the midpoint.
Bearish zones (above price) test the opposite direction. Mitigation triggers an alert if you've enabled it for that source.
Alerts
Two alert flags per source: entry (price first touches the zone) and mitigation (price meets the mitigation criterion). Alert text identifies the source timeframe, direction (bull or bear) and the price.
Settings, top to bottom
Appearance — bull / bear / mitigated colours, box transparency, mitigated box transparency, line width, right-edge extension (default 0 = right edge sits at the current bar; raise it to extend further right), label text colour.
Mitigation — single global mitigation method dropdown.
Chart — enable, box / line visibility, line styles, unfilled and mitigated counts, mitigated-lines toggle, label settings, alerts.
HTF 1, HTF 2, HTF 3 — same controls as Chart plus a timeframe input.
NWOG — same controls as the others, plus optional NWOG-specific bull/bear colour overrides.
Notes on usage
For NWOG live detection use a 1H or smaller intraday chart. On 4H+ charts the bar boundaries don't land on the 18:00 NY moment cleanly so new NWOGs won't form.
HTF FVGs appear on the chart at the bar where their HTF period closed, anchored back to the chart bars where the relevant HTF candle highs and lows occurred — this gives a clean "stepped" visual at the zone's left edge that shows how it formed.
The right edge of every zone tracks the current bar in real time. Set "Extend right beyond current bar" higher if you prefer a fixed runway.
TradingView caps total drawn objects at 500 lines / 500 boxes / 500 labels. With three lines per zone enabled across many sources at high display caps, you can hit those limits — drop the mid line first (it's off by default for that reason) and you double your headroom.
Built specifically for the way I trade GC futures on the 1H. Sharing because I haven't seen another FVG indicator that handles all three of these together: holiday-week NWOGs, four mitigation modes, and independent box/line control per source. Feedback welcome.

## Source Code

````pine
// Ultimate FVG / NWOG By FreedomByCharts — v2.35
// ------------------------------------------------------------
// Simplified rewrite per Frankie's spec:
//   • 5 sources only: Chart + HTF1 + HTF2 + HTF3 + NWOG
//   • Single global colour scheme: one bull, one bear, one mitigated grey
//   • Independent box / top / mid / bot line visibility per source
//   • 4 mitigation modes: Wick Filled (full) / Body Filled (full) / Wick 50% / Body 50%
//   • User-set unfilled and mitigated display caps per source
//   • Default label colour black, customisable for dark themes
//   • NWOG anchored to 1H Friday close → 1H Sunday open in NY time
//   • Removed: IPDA, theme presets, NDOG, Daily VI, HTF4
//
// v2.35 — fix: switch HTF request.security calls from lookahead_off to
// lookahead_on with the existing [1]/[3] history offsets. Empirically
// verified via MinRepro/MinRepro3: the late-zone problem confirmed —
// lookahead_off + [1] returned the bar BEFORE the just-closed HTF bar,
// so the FVG triplet (A,B,C) detected on h_newBar excluded the just-
// closed bar entirely. With lookahead_on + [1] (TradingView's documented
// non-repainting pattern), the just-closed bar IS C, and detection
// fires on the first chart bar of the new HTF window — before any wick
// inside that window has happened, so mitigation can catch it.
//@version=6
indicator('Ultimate FVG/NWOG By FreedomByCharts', shorttitle = 'Ultimate FVG/NWOG By FreedomByCharts', overlay = true,
 max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500,
 max_bars_back = 5000)

// ════════════════════════════════════════════════════════════════════════════════════════════════════
//  GLOBAL APPEARANCE
// ════════════════════════════════════════════════════════════════════════════════════════════════════
g_app = '─── Appearance ───'
bullCol   = input.color(#4CAF50,     'Bullish colour',          group = g_app)
bearCol   = input.color(#F44336,     'Bearish colour',          group = g_app)
mitCol    = input.color(#9E9E9E,     'Mitigated colour (grey)', group = g_app)
boxTransp = input.int(90, 'Box transparency (0 = solid, 100 = invisible)', minval = 0, maxval = 100, group = g_app, tooltip = 'Higher = lighter / more washed out. 80 ≈ fadi-style fill.')
mitTransp = input.int(90, 'Mitigated box transparency',         minval = 0, maxval = 100, group = g_app)
lineWidth = input.int(1,  'Line width',                          minval = 1, maxval = 4,   group = g_app)
extendBars = input.int(5, 'Extend right beyond current bar',     minval = 0, maxval = 200, group = g_app, tooltip = 'Default 0 = right edge sits at the current bar and tracks forward as new bars print. Increase to push the right edge further into the future.')
lblCol    = input.color(#9E9E9E, 'Label text colour',        group = g_app, tooltip = 'Default black for light themes; switch to white/grey for dark backgrounds.')

// ════════════════════════════════════════════════════════════════════════════════════════════════════
//  MITIGATION
// ════════════════════════════════════════════════════════════════════════════════════════════════════
g_mit = '─── Mitigation ───'
mitMethod = input.string('Wick Filled (full)', 'Mitigation method',
 options = ['Wick Filled (full)', 'Body Filled (full)', 'Wick 50%', 'Body 50%'], group = g_mit,
 tooltip = '• Wick Filled (full) — wick reaches the far side of the zone (default)\n• Body Filled (full) — close reaches the far side\n• Wick 50% — wick reaches the midpoint\n• Body 50% — close reaches the midpoint')

// ════════════════════════════════════════════════════════════════════════════════════════════════════
//  CHART (current TF)
// ════════════════════════════════════════════════════════════════════════════════════════════════════
g_chart = '─── Chart (current TF) ───'
chart_on        = input.bool(false,  'Enable',                                              group = g_chart)
chart_showBox   = input.bool(true,  'Show box (fill)',                                     group = g_chart)
chart_showTop   = input.bool(true,  'Top',  inline = 'cl1', group = g_chart)
chart_showMid   = input.bool(true,  'Mid',  inline = 'cl1', group = g_chart)
chart_showBot   = input.bool(true,  'Bot',  inline = 'cl1', group = g_chart)
chart_topStyle  = input.string('Solid',  'Top style', options = ['Solid','Dashed','Dotted'], inline = 'cs', group = g_chart)
chart_midStyle  = input.string('Dotted', 'Mid style', options = ['Solid','Dashed','Dotted'], inline = 'cs', group = g_chart)
chart_botStyle  = input.string('Solid',  'Bot style', options = ['Solid','Dashed','Dotted'], inline = 'cs', group = g_chart)
chart_unmit     = input.int(5, 'Unfilled to show',  minval = 0, maxval = 50, group = g_chart)
chart_mitShowLines = input.bool(true, 'Show lines on mitigated', group = g_chart, tooltip = 'Off = mitigated zones drop the top/mid/bot lines and show only the grey box.')
chart_mit       = input.int(1, 'Mitigated to show', minval = 0, maxval = 50, group = g_chart)
chart_lblShow   = input.bool(true,  'Labels',    inline = 'cl2', group = g_chart)
chart_lblSize   = input.string('Small', 'Size',  options = ['Tiny','Small','Normal'], inline = 'cl2', group = g_chart)
chart_lblLoc    = input.string('Right (outside)', 'Label location', options = ['Right (inside)','Right (outside)','Left (inside)','Left (outside)','Center'], group = g_chart)
chart_lblOffset = input.int(2, 'Label bar offset', minval = 0, maxval = 50, group = g_chart)
chart_alertEntry = input.bool(false, 'Alert on entry',     inline = 'ca', group = g_chart)
chart_alertMit   = input.bool(false, 'Alert on mitigation', inline = 'ca', group = g_chart)

// ════════════════════════════════════════════════════════════════════════════════════════════════════
//  HTF 1
// ════════════════════════════════════════════════════════════════════════════════════════════════════
g_h1 = '─── HTF 1 ───'
h1_on        = input.bool(true,  'Enable',          group = g_h1)
h1_tf        = input.timeframe('240', 'Timeframe',  group = g_h1)
h1_showBox   = input.bool(true,  'Show box (fill)', group = g_h1)
h1_showTop   = input.bool(true,  'Top',  inline = 'h1l1', group = g_h1)
h1_showMid   = input.bool(true,  'Mid',  inline = 'h1l1', group = g_h1)
h1_showBot   = input.bool(true,  'Bot',  inline = 'h1l1', group = g_h1)
h1_topStyle  = input.string('Solid',  'Top style', options = ['Solid','Dashed','Dotted'], inline = 'h1s', group = g_h1)
h1_midStyle  = input.string('Dotted', 'Mid style', options = ['Solid','Dashed','Dotted'], inline = 'h1s', group = g_h1)
h1_botStyle  = input.string('Solid',  'Bot style', options = ['Solid','Dashed','Dotted'], inline = 'h1s', group = g_h1)
h1_unmit     = input.int(10, 'Unfilled to show',  minval = 0, maxval = 50, group = g_h1)
h1_mitShowLines = input.bool(false, 'Show lines on mitigated', group = g_h1)
h1_mit       = input.int(3, 'Mitigated to show', minval = 0, maxval = 50, group = g_h1)
h1_lblShow   = input.bool(true,  'Labels',     inline = 'h1l2', group = g_h1)
h1_lblSize   = input.string('Small', 'Size',   options = ['Tiny','Small','Normal'], inline = 'h1l2', group = g_h1)
h1_lblLoc    = input.string('Right (outside)', 'Label location', options = ['Right (inside)','Right (outside)','Left (inside)','Left (outside)','Center'], group = g_h1)
h1_lblOffset = input.int(2, 'Label bar offset',  minval = 0, maxval = 50, group = g_h1)
h1_alertEntry = input.bool(false, 'Alert on entry',     inline = 'h1a', group = g_h1)
h1_alertMit   = input.bool(false, 'Alert on mitigation', inline = 'h1a', group = g_h1)

// ════════════════════════════════════════════════════════════════════════════════════════════════════
//  HTF 2
// ════════════════════════════════════════════════════════════════════════════════════════════════════
g_h2 = '─── HTF 2 ───'
h2_on        = input.bool(false, 'Enable',          group = g_h2)
h2_tf        = input.timeframe('1D', 'Timeframe',  group = g_h2)
h2_showBox   = input.bool(true,  'Show box (fill)', group = g_h2)
h2_showTop   = input.bool(true,  'Top',  inline = 'h2l1', group = g_h2)
h2_showMid   = input.bool(false, 'Mid',  inline = 'h2l1', group = g_h2)
h2_showBot   = input.bool(true,  'Bot',  inline = 'h2l1', group = g_h2)
h2_topStyle  = input.string('Solid',  'Top style', options = ['Solid','Dashed','Dotted'], inline = 'h2s', group = g_h2)
h2_midStyle  = input.string('Dotted', 'Mid style', options = ['Solid','Dashed','Dotted'], inline = 'h2s', group = g_h2)
h2_botStyle  = input.string('Solid',  'Bot style', options = ['Solid','Dashed','Dotted'], inline = 'h2s', group = g_h2)
h2_unmit     = input.int(3, 'Unfilled to show',  minval = 0, maxval = 50, group = g_h2)
h2_mitShowLines = input.bool(false, 'Show lines on mitigated', group = g_h2)
h2_mit       = input.int(1, 'Mitigated to show', minval = 0, maxval = 50, group = g_h2)
h2_lblShow   = input.bool(true,  'Labels',     inline = 'h2l2', group = g_h2)
h2_lblSize   = input.string('Small', 'Size',   options = ['Tiny','Small','Normal'], inline = 'h2l2', group = g_h2)
h2_lblLoc    = input.string('Right (inside)', 'Label location', options = ['Right (inside)','Right (outside)','Left (inside)','Left (outside)','Center'], group = g_h2)
h2_lblOffset = input.int(2, 'Label bar offset',  minval = 0, maxval = 50, group = g_h2)
h2_alertEntry = input.bool(false, 'Alert on entry',     inline = 'h2a', group = g_h2)
h2_alertMit   = input.bool(false, 'Alert on mitigation', inline = 'h2a', group = g_h2)

// ════════════════════════════════════════════════════════════════════════════════════════════════════
//  HTF 3
// ════════════════════════════════════════════════════════════════════════════════════════════════════
g_h3 = '─── HTF 3 ───'
h3_on        = input.bool(false, 'Enable',          group = g_h3)
h3_tf        = input.timeframe('1W', 'Timeframe',   group = g_h3)
h3_showBox   = input.bool(true,  'Show box (fill)', group = g_h3)
h3_showTop   = input.bool(true,  'Top',  inline = 'h3l1', group = g_h3)
h3_showMid   = input.bool(false, 'Mid',  inline = 'h3l1', group = g_h3)
h3_showBot   = input.bool(true,  'Bot',  inline = 'h3l1', group = g_h3)
h3_topStyle  = input.string('Solid',  'Top style', options = ['Solid','Dashed','Dotted'], inline = 'h3s', group = g_h3)
h3_midStyle  = input.string('Dotted', 'Mid style', options = ['Solid','Dashed','Dotted'], inline = 'h3s', group = g_h3)
h3_botStyle  = input.string('Solid',  'Bot style', options = ['Solid','Dashed','Dotted'], inline = 'h3s', group = g_h3)
h3_unmit     = input.int(2, 'Unfilled to show',  minval = 0, maxval = 50, group = g_h3)
h3_mitShowLines = input.bool(true, 'Show lines on mitigated', group = g_h3)
h3_mit       = input.int(1, 'Mitigated to show', minval = 0, maxval = 50, group = g_h3)
h3_lblShow   = input.bool(true,  'Labels',     inline = 'h3l2', group = g_h3)
h3_lblSize   = input.string('Small', 'Size',   options = ['Tiny','Small','Normal'], inline = 'h3l2', group = g_h3)
h3_lblLoc    = input.string('Right (outside)', 'Label location', options = ['Right (inside)','Right (outside)','Left (inside)','Left (outside)','Center'], group = g_h3)
h3_lblOffset = input.int(2, 'Label bar offset',  minval = 0, maxval = 50, group = g_h3)
h3_alertEntry = input.bool(false, 'Alert on entry',     inline = 'h3a', group = g_h3)
h3_alertMit   = input.bool(false, 'Alert on mitigation', inline = 'h3a', group = g_h3)

// ════════════════════════════════════════════════════════════════════════════════════════════════════
//  NWOG  (Friday 1H 16:00 NY close → Sunday 1H 18:00 NY open)
// ════════════════════════════════════════════════════════════════════════════════════════════════════
g_nwog = '─── NWOG (New Week Opening Gap) ───'
nwog_on        = input.bool(true,  'Enable', group = g_nwog, tooltip = 'Anchored to 1H bars in NY time. Use a 1H or smaller intraday chart for live detection.')
nwog_showBox   = input.bool(true,  'Show box (fill)', group = g_nwog)
nwog_showTop   = input.bool(true,  'Top',  inline = 'nl1', group = g_nwog)
nwog_showMid   = input.bool(true,  'Mid',  inline = 'nl1', group = g_nwog)
nwog_showBot   = input.bool(true,  'Bot',  inline = 'nl1', group = g_nwog)
nwog_topStyle  = input.string('Solid',  'Top style', options = ['Solid','Dashed','Dotted'], inline = 'ns', group = g_nwog)
nwog_midStyle  = input.string('Dotted', 'Mid style', options = ['Solid','Dashed','Dotted'], inline = 'ns', group = g_nwog)
nwog_botStyle  = input.string('Solid',  'Bot style', options = ['Solid','Dashed','Dotted'], inline = 'ns', group = g_nwog)
nwog_unmit     = input.int(2, 'Unfilled to show',  minval = 0, maxval = 50, group = g_nwog)
nwog_mitShowLines = input.bool(false, 'Show lines on mitigated', group = g_nwog)
nwog_mit       = input.int(3, 'Mitigated to show', minval = 0, maxval = 50, group = g_nwog)
nwog_lblShow   = input.bool(true,  'Labels',     inline = 'nl2', group = g_nwog)
nwog_lblSize   = input.string('Small', 'Size',   options = ['Tiny','Small','Normal'], inline = 'nl2', group = g_nwog)
nwog_lblLoc    = input.string('Right (outside)', 'Label location', options = ['Right (inside)','Right (outside)','Left (inside)','Left (outside)','Center'], group = g_nwog)
nwog_lblOffset = input.int(2, 'Label bar offset',  minval = 0, maxval = 50, group = g_nwog)
nwog_bullCol   = input.color(#4CAF50, 'NWOG bull colour', inline = 'nwc', group = g_nwog, tooltip = 'Set both bull and bear to the same colour if you want NWOGs in one neutral colour.')
nwog_bearCol   = input.color(#F44336, 'NWOG bear colour', inline = 'nwc', group = g_nwog)
nwog_alertEntry = input.bool(false, 'Alert on entry',     inline = 'na', group = g_nwog)
nwog_alertMit   = input.bool(false, 'Alert on mitigation', inline = 'na', group = g_nwog)

// ════════════════════════════════════════════════════════════════════════════════════════════════════
//  TYPES
// ════════════════════════════════════════════════════════════════════════════════════════════════════
type SourceCfg
    string source
    string tfLabel
    bool   showBox
    bool   showTop
    bool   showMid
    bool   showBot
    string topStyle
    string midStyle
    string botStyle
    bool   lblShow
    string lblSize
    string lblLoc
    int    lblOffset
    color  bullCol
    color  bearCol
    bool   mitShowLines
    int    maxUnmit
    int    maxMit
    bool   alertEntry
    bool   alertMit

type FVGZone
    string source
    string tfLabel
    bool   isBull
    float  top
    float  bot
    float  mid
    int    leftBar
    bool   mitigated
    box    bx
    line   lnTop
    line   lnMid
    line   lnBot
    label  lbl
    string lblLoc
    int    lblOffset
    bool   showBox
    bool   showTop
    bool   showMid
    bool   showBot
    bool   alertedEntry
    bool   alertedMit

// ════════════════════════════════════════════════════════════════════════════════════════════════════
//  STATE
// ════════════════════════════════════════════════════════════════════════════════════════════════════
var array<FVGZone> chartZones = array.new<FVGZone>()
var array<FVGZone> h1Zones    = array.new<FVGZone>()
var array<FVGZone> h2Zones    = array.new<FVGZone>()
var array<FVGZone> h3Zones    = array.new<FVGZone>()
var array<FVGZone> nwogZones  = array.new<FVGZone>()

// Mutable state stored in parallel boolean arrays (UDT field mutation on array elements is
// unreliable in Pine v6; primitive bool arrays via array.set persist correctly).
var array<bool> chartMit = array.new<bool>()
var array<bool> h1Mit    = array.new<bool>()
var array<bool> h2Mit    = array.new<bool>()
var array<bool> h3Mit    = array.new<bool>()
var array<bool> nwogMit  = array.new<bool>()

var array<bool> chartAE = array.new<bool>()
var array<bool> h1AE    = array.new<bool>()
var array<bool> h2AE    = array.new<bool>()
var array<bool> h3AE    = array.new<bool>()
var array<bool> nwogAE  = array.new<bool>()

// HTF tracking — last detected zone time per source, to dedupe when chart bars span an HTF close
// (Currently unused after the rewrite to detect newBar via h_c_t != h_c_t[1]; kept here for future)

// (NWOG no longer needs persistent state — close[1] on the Sunday 18:00 NY bar is the
//  last 1H bar's close before the weekend, which is correct on normal weeks AND on holiday
//  weeks like Easter where Friday is closed.)

// ════════════════════════════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ════════════════════════════════════════════════════════════════════════════════════════════════════
toLineStyle(s) =>
    switch s
        'Dashed' => line.style_dashed
        'Dotted' => line.style_dotted
        => line.style_solid

toLabelSize(s) =>
    switch s
        'Tiny'   => size.tiny
        'Normal' => size.normal
        => size.small

// Convert a TF string ("60", "240", "5", "1D", "D", "1W", "W", "1M", "M") to a friendly label
// ("1H", "4H", "5m", "1D", "1W", "1M"). Robust against TV's mixed "1D" vs "D" conventions.
formatTfLabel(string tf) =>
    int secs = timeframe.in_seconds(tf)
    string result = tf
    if secs < 60
        result := str.tostring(secs) + 's'
    else if secs < 3600
        result := str.tostring(secs / 60) + 'm'
    else if secs < 86400
        result := str.tostring(secs / 3600) + 'H'
    else if secs < 604800
        result := str.tostring(secs / 86400) + 'D'
    else if secs < 2592000
        result := str.tostring(secs / 604800) + 'W'
    else
        result := str.tostring(secs / 2592000) + 'M'
    result

calcLabelBar(loc, leftBar, rightBar, offset) =>
    int    lblBar = rightBar
    string sty    = label.style_label_left
    switch loc
        'Right (outside)' =>
            lblBar := rightBar + offset
            sty    := label.style_label_left
        'Right (inside)'  =>
            lblBar := rightBar - offset
            sty    := label.style_label_right
        'Left (outside)'  =>
            lblBar := leftBar - offset
            sty    := label.style_label_right
        'Left (inside)'   =>
            lblBar := leftBar + offset
            sty    := label.style_label_left
        'Center'          =>
            lblBar := math.round((leftBar + rightBar) / 2)
            sty    := label.style_label_center
    [lblBar, sty]

isMitigatedZone(FVGZone z, float h, float l, float o, float c, string method) =>
    if z.isBull
        if method == 'Wick Filled (full)'
            l <= z.bot
        else if method == 'Body Filled (full)'
            math.min(o, c) <= z.bot
        else if method == 'Wick 50%'
            l <= z.mid
        else if method == 'Body 50%'
            math.min(o, c) <= z.mid
        else
            false
    else
        if method == 'Wick Filled (full)'
            h >= z.top
        else if method == 'Body Filled (full)'
            math.max(o, c) >= z.top
        else if method == 'Wick 50%'
            h >= z.mid
        else if method == 'Body 50%'
            math.max(o, c) >= z.mid
        else
            false

hasEnteredZone(FVGZone z, float h, float l) =>
    z.isBull ? l <= z.top : h >= z.bot

// ════════════════════════════════════════════════════════════════════════════════════════════════════
//  CREATE ZONE
// ════════════════════════════════════════════════════════════════════════════════════════════════════
createZone(SourceCfg cfg, bool isBull, float top, float bot, int topX1, int botX1) =>
    int   leftBar = math.min(topX1, botX1)
    int   rightBar = bar_index + extendBars
    float midPrc = (top + bot) / 2.0
    color base = isBull ? cfg.bullCol : cfg.bearCol

    // Box
    color boxC = cfg.showBox ? color.new(base, boxTransp) : color.new(base, 100)
    box bx = box.new(left = leftBar, top = top, right = rightBar, bottom = bot,
     bgcolor = boxC, border_color = color.new(base, 100), border_width = 0)

    // Lines — only create those enabled. x2 controls the right edge (no extend.right).
    line lnT = na
    line lnM = na
    line lnB = na
    if cfg.showTop
        lnT := line.new(topX1, top, rightBar, top, color = base, style = toLineStyle(cfg.topStyle), width = lineWidth)
    if cfg.showMid
        lnM := line.new(leftBar, midPrc, rightBar, midPrc, color = base, style = toLineStyle(cfg.midStyle), width = lineWidth)
    if cfg.showBot
        lnB := line.new(botX1, bot, rightBar, bot, color = base, style = toLineStyle(cfg.botStyle), width = lineWidth)

    // Label
    label lbl = na
    if cfg.lblShow
        [lblBar, lblStyle] = calcLabelBar(cfg.lblLoc, leftBar, rightBar, cfg.lblOffset)
        lbl := label.new(lblBar, midPrc, cfg.tfLabel, color = color.new(color.gray, 100),
         textcolor = lblCol, style = lblStyle, size = toLabelSize(cfg.lblSize))

    FVGZone.new(cfg.source, cfg.tfLabel, isBull, top, bot, midPrc, leftBar, false,
     bx, lnT, lnM, lnB, lbl, cfg.lblLoc, cfg.lblOffset,
     cfg.showBox, cfg.showTop, cfg.showMid, cfg.showBot, false, false)

// ════════════════════════════════════════════════════════════════════════════════════════════════════
//  UPDATE ZONES — mitigation, alerts, extending right edge, pruning to display caps
// ════════════════════════════════════════════════════════════════════════════════════════════════════
updateZones(array<FVGZone> zones, array<bool> mitArr, array<bool> aeArr, SourceCfg cfg) =>
    if zones.size() > 0
        int rb = bar_index + extendBars

        // Pass 1: mitigation, alerts, extend right edges
        for i = 0 to zones.size() - 1
            FVGZone z = zones.get(i)
            bool isMit = mitArr.get(i)
            bool ae    = aeArr.get(i)

            // Mitigation transition (only check unmitigated zones)
            if not isMit
                if cfg.alertEntry and not ae and hasEnteredZone(z, high, low)
                    alert(z.tfLabel + ' ' + (z.isBull ? 'Bull' : 'Bear') + ' entry @ ' + str.tostring(close), alert.freq_once_per_bar)
                    aeArr.set(i, true)
                if isMitigatedZone(z, high, low, open, close, mitMethod)
                    mitArr.set(i, true)
                    // Recolour to mitigated grey
                    color mitBoxC = z.showBox ? color.new(mitCol, mitTransp) : color.new(mitCol, 100)
                    z.bx.set_bgcolor(mitBoxC)
                    z.bx.set_border_color(color.new(mitCol, 100))
                    color mitLineC = cfg.mitShowLines ? mitCol : color.new(mitCol, 100)
                    if not na(z.lnTop)
                        z.lnTop.set_color(mitLineC)
                    if not na(z.lnMid)
                        z.lnMid.set_color(mitLineC)
                    if not na(z.lnBot)
                        z.lnBot.set_color(mitLineC)
                    // FVGs become iFVGs (inverted FVGs) when mitigated. NWOG keeps its label.
                    if z.source != 'NWOG' and not na(z.lbl)
                        z.lbl.set_text(z.tfLabel + ' iFVG')
                    if cfg.alertMit
                        alert(z.tfLabel + ' ' + (z.isBull ? 'Bull' : 'Bear') + ' mitigated @ ' + str.tostring(close), alert.freq_once_per_bar)

            // Extend right edges every bar
            z.bx.set_right(rb)
            if not na(z.lnTop)
                z.lnTop.set_x2(rb)
            if not na(z.lnMid)
                z.lnMid.set_x2(rb)
            if not na(z.lnBot)
                z.lnBot.set_x2(rb)
            if not na(z.lbl)
                [lblBar, _] = calcLabelBar(z.lblLoc, z.leftBar, rb, z.lblOffset)
                z.lbl.set_x(lblBar)

        // Pass 2: pruning. Walk newest -> oldest by counting up k, computing i = size-1-k.
        int unmitCount = 0
        int mitCount = 0
        int n = zones.size()
        for k = 0 to n - 1
            int i = n - 1 - k
            FVGZone z = zones.get(i)
            bool isMit = mitArr.get(i)
            bool drop = false
            if isMit
                mitCount += 1
                if mitCount > cfg.maxMit
                    drop := true
            else
                unmitCount += 1
                if unmitCount > cfg.maxUnmit
                    drop := true
            if drop
                z.bx.delete()
                if not na(z.lnTop)
                    z.lnTop.delete()
                if not na(z.lnMid)
                    z.lnMid.delete()
                if not na(z.lnBot)
                    z.lnBot.delete()
                if not na(z.lbl)
                    z.lbl.delete()
                zones.remove(i)
                mitArr.remove(i)
                aeArr.remove(i)

// ════════════════════════════════════════════════════════════════════════════════════════════════════
//  SOURCE CONFIGS  (one per source)
// ════════════════════════════════════════════════════════════════════════════════════════════════════
SourceCfg chartCfg = SourceCfg.new('Chart', formatTfLabel(timeframe.period),
 chart_showBox, chart_showTop, chart_showMid, chart_showBot,
 chart_topStyle, chart_midStyle, chart_botStyle,
 chart_lblShow, chart_lblSize, chart_lblLoc, chart_lblOffset,
 bullCol, bearCol, chart_mitShowLines,
 chart_unmit, chart_mit, chart_alertEntry, chart_alertMit)

SourceCfg h1Cfg = SourceCfg.new('HTF1', formatTfLabel(h1_tf),
 h1_showBox, h1_showTop, h1_showMid, h1_showBot,
 h1_topStyle, h1_midStyle, h1_botStyle,
 h1_lblShow, h1_lblSize, h1_lblLoc, h1_lblOffset,
 bullCol, bearCol, h1_mitShowLines,
 h1_unmit, h1_mit, h1_alertEntry, h1_alertMit)

SourceCfg h2Cfg = SourceCfg.new('HTF2', formatTfLabel(h2_tf),
 h2_showBox, h2_showTop, h2_showMid, h2_showBot,
 h2_topStyle, h2_midStyle, h2_botStyle,
 h2_lblShow, h2_lblSize, h2_lblLoc, h2_lblOffset,
 bullCol, bearCol, h2_mitShowLines,
 h2_unmit, h2_mit, h2_alertEntry, h2_alertMit)

SourceCfg h3Cfg = SourceCfg.new('HTF3', formatTfLabel(h3_tf),
 h3_showBox, h3_showTop, h3_showMid, h3_showBot,
 h3_topStyle, h3_midStyle, h3_botStyle,
 h3_lblShow, h3_lblSize, h3_lblLoc, h3_lblOffset,
 bullCol, bearCol, h3_mitShowLines,
 h3_unmit, h3_mit, h3_alertEntry, h3_alertMit)

SourceCfg nwogCfg = SourceCfg.new('NWOG', 'NWOG',
 nwog_showBox, nwog_showTop, nwog_showMid, nwog_showBot,
 nwog_topStyle, nwog_midStyle, nwog_botStyle,
 nwog_lblShow, nwog_lblSize, nwog_lblLoc, nwog_lblOffset,
 nwog_bullCol, nwog_bearCol, nwog_mitShowLines,
 nwog_unmit, nwog_mit, nwog_alertEntry, nwog_alertMit)

// ════════════════════════════════════════════════════════════════════════════════════════════════════
//  CHART FVG DETECTION
// ════════════════════════════════════════════════════════════════════════════════════════════════════
if chart_on and barstate.isconfirmed and bar_index >= 2
    float a_h = high[2]
    float a_l = low[2]
    float c_h = high
    float c_l = low
    // Bull FVG: A.high < C.low → top = C.low (at bar i), bot = A.high (at bar i-2)
    if a_h < c_l
        FVGZone z = createZone(chartCfg, true, c_l, a_h, bar_index, bar_index - 2)
        chartZones.push(z)
        chartMit.push(false)
        chartAE.push(false)
    // Bear FVG: A.low > C.high → top = A.low (at bar i-2), bot = C.high (at bar i)
    if a_l > c_h
        FVGZone z = createZone(chartCfg, false, a_l, c_h, bar_index - 2, bar_index)
        chartZones.push(z)
        chartMit.push(false)
        chartAE.push(false)

if chart_on
    updateZones(chartZones, chartMit, chartAE, chartCfg)

// ════════════════════════════════════════════════════════════════════════════════════════════════════
//  HTF TRACKING & FVG DETECTION
// ════════════════════════════════════════════════════════════════════════════════════════════════════
// Approach: top-level request.security() per HTF pulls each HTF bar's high/low/time. On each chart
// bar we get the current HTF bar's data. When the HTF time changes between consecutive chart bars,
// a new HTF bar has just confirmed — we then check the 3-bar FVG pattern using values 1, 2, 3 HTF
// bars back via the [N] history operator.
//
// To preserve the stepped-edge visual: when an FVG fires, walk back through chart bar history to
// find the chart bar where bar A (or C) had its high/low, anchored by HTF time + price match.
// The zone's top line starts at the chart bar where the gap-side level occurred, the bot line
// at the other side. Box left edge = earliest of the two anchors.
//
// Same FVG zones produced regardless of chart TF (provided chart TF ≤ HTF).

// Top-level request.security calls. Two calls per HTF: bars A (oldest of A/B/C) and C (newest).
// We index high[1]/low[1]/time[1] for C and high[3]/low[3]/time[3] for A, paired with
// lookahead = barmerge.lookahead_on. This is TradingView's documented non-repainting pattern:
// the [1] offset and lookahead_on are interdependent. Together they return — on every chart bar
// inside HTF window D — the value of HTF bar (D - 1), which is the most-recently-closed HTF bar.
// h_c_t therefore advances as soon as the new HTF bar starts on the chart, and h_newBar fires on
// the FIRST chart bar of the new HTF window — before any wick inside that window has happened.
//
// v2.34 used lookahead_off here, which (because lookahead_off already returns the most-recently-
// closed value) caused the [1] offset to over-shift by one HTF bar. The detected FVG triplet then
// excluded the just-closed HTF bar entirely, and any wick that should have mitigated the zone
// during the next HTF window had already happened by the time the zone was finally created.
[h1_a_h, h1_a_l, h1_a_t] = request.security(syminfo.tickerid, h1_tf, [high[3], low[3], time[3]], lookahead = barmerge.lookahead_on)
[h1_c_h, h1_c_l, h1_c_t] = request.security(syminfo.tickerid, h1_tf, [high[1], low[1], time[1]], lookahead = barmerge.lookahead_on)
[h2_a_h, h2_a_l, h2_a_t] = request.security(syminfo.tickerid, h2_tf, [high[3], low[3], time[3]], lookahead = barmerge.lookahead_on)
[h2_c_h, h2_c_l, h2_c_t] = request.security(syminfo.tickerid, h2_tf, [high[1], low[1], time[1]], lookahead = barmerge.lookahead_on)
[h3_a_h, h3_a_l, h3_a_t] = request.security(syminfo.tickerid, h3_tf, [high[3], low[3], time[3]], lookahead = barmerge.lookahead_on)
[h3_c_h, h3_c_l, h3_c_t] = request.security(syminfo.tickerid, h3_tf, [high[1], low[1], time[1]], lookahead = barmerge.lookahead_on)

// Detect new HTF bar: C's time changed from previous chart bar (a new HTF bar has just closed).
bool h1_newBar = not na(h1_c_t) and h1_c_t != h1_c_t[1]
bool h2_newBar = not na(h2_c_t) and h2_c_t != h2_c_t[1]
bool h3_newBar = not na(h3_c_t) and h3_c_t != h3_c_t[1]

// Top-level helper: walks back through chart bar history to find the bar where a target HTF bar
// (identified by its open time) had a target price level. Returns chart bar_index. Lookback is
// capped at 5000 chart bars to handle low chart TFs (e.g. 1m) with high HTFs (e.g. weekly) where
// anchors may be many thousands of chart bars back. If not found within that window, falls back
// to current bar so the zone still anchors somewhere visible.
findAnchorBar(int htfBarTime, int htfTfMs, float targetPrice, bool isHigh) =>
    int result = bar_index
    if not na(htfBarTime) and htfTfMs > 0
        int maxBack = math.min(5000, bar_index)
        int htfBarEnd = htfBarTime + htfTfMs
        float tol = syminfo.mintick / 2.0
        bool found = false
        bool stop = false
        int oldestBarReached = bar_index
        for i = 0 to maxBack
            if not found and not stop
                int bt = time[i]
                if na(bt)
                    stop := true
                else if bt < htfBarTime
                    // Walked past the target HTF window — anchor not in available history.
                    // Fall back to the oldest chart bar we did walk back to, so the zone at
                    // least stretches across most of the visible chart instead of rendering
                    // as a sliver at the right edge.
                    result := oldestBarReached
                    stop := true
                else
                    oldestBarReached := bar_index - i
                    if bt < htfBarEnd
                        float lvl = isHigh ? high[i] : low[i]
                        if not na(lvl) and math.abs(lvl - targetPrice) < tol
                            result := bar_index - i
                            found := true
        // If we exhausted the loop without finding or terminating, the lookback ran out
        // before reaching the HTF window — also fall back to oldest bar reached.
        if not found and not stop
            result := oldestBarReached
    result

// Per-HTF FVG check. Bull FVG: A.high < C.low. Bear FVG: A.low > C.high.
checkHtfFvg(SourceCfg cfg, array<FVGZone> zones, array<bool> mitArr, array<bool> aeArr, float a_h, float a_l, int a_t, float c_h, float c_l, int c_t, int tfMs) =>
    if not na(a_h) and not na(c_l) and a_h < c_l
        int topAnchor = findAnchorBar(c_t, tfMs, c_l, false)  // C's low
        int botAnchor = findAnchorBar(a_t, tfMs, a_h, true)   // A's high
        FVGZone z = createZone(cfg, true, c_l, a_h, topAnchor, botAnchor)
        zones.push(z)
        mitArr.push(false)
        aeArr.push(false)
    if not na(a_l) and not na(c_h) and a_l > c_h
        int topAnchor = findAnchorBar(a_t, tfMs, a_l, false)  // A's low
        int botAnchor = findAnchorBar(c_t, tfMs, c_h, true)   // C's high
        FVGZone z = createZone(cfg, false, a_l, c_h, topAnchor, botAnchor)
        zones.push(z)
        mitArr.push(false)
        aeArr.push(false)

// HTF 1
int h1_tfMs = timeframe.in_seconds(h1_tf) * 1000
if h1_on and h1_newBar
    checkHtfFvg(h1Cfg, h1Zones, h1Mit, h1AE, h1_a_h, h1_a_l, h1_a_t, h1_c_h, h1_c_l, h1_c_t, h1_tfMs)
if h1_on
    updateZones(h1Zones, h1Mit, h1AE, h1Cfg)

// HTF 2
int h2_tfMs = timeframe.in_seconds(h2_tf) * 1000
if h2_on and h2_newBar
    checkHtfFvg(h2Cfg, h2Zones, h2Mit, h2AE, h2_a_h, h2_a_l, h2_a_t, h2_c_h, h2_c_l, h2_c_t, h2_tfMs)
if h2_on
    updateZones(h2Zones, h2Mit, h2AE, h2Cfg)

// HTF 3
int h3_tfMs = timeframe.in_seconds(h3_tf) * 1000
if h3_on and h3_newBar
    checkHtfFvg(h3Cfg, h3Zones, h3Mit, h3AE, h3_a_h, h3_a_l, h3_a_t, h3_c_h, h3_c_l, h3_c_t, h3_tfMs)
if h3_on
    updateZones(h3Zones, h3Mit, h3AE, h3Cfg)

// ════════════════════════════════════════════════════════════════════════════════════════════════════
//  NWOG DETECTION  (close[1] approach — handles holiday weeks like Easter / Good Friday correctly)
//
//  On the Sunday 18:00 NY bar, the previous bar in the chart series is ALWAYS the last 1H
//  bar of the prior trading session — Friday on a normal week, Thursday on Good Friday week,
//  whatever the last open day was. Using close[1] means we pair with the actual last close
//  before the weekend regardless of which day it was.
//
//  Detection requires chart bars that land exactly at 18:00 NY. This works on 1m, 5m, 15m, 30m,
//  and 1H. On 2H+ charts, bars don't land at 18:00 NY cleanly — a runtime warning fires below
//  to alert the user instead of failing silently.
// ════════════════════════════════════════════════════════════════════════════════════════════════════
nyTz_   = 'America/New_York'
hr_NY   = hour(time, nyTz_)
mn_NY   = minute(time, nyTz_)
dow_NY  = dayofweek(time, nyTz_)
is18Sun = hr_NY == 18 and mn_NY == 0 and dow_NY == dayofweek.sunday

// ════════════════════════════════════════════════════════════════════════════════════════════════════
//  CONFIGURATION WARNINGS
//  Detect TF combinations that would cause silent failure or duplicate zones; show a single
//  warning label on the last bar so the user sees what's wrong instead of guessing.
// ════════════════════════════════════════════════════════════════════════════════════════════════════
if barstate.islast
    int chartSecs = timeframe.in_seconds()
    string warnings = ''

    // HTF < chart TF: most HTF FVGs missed silently
    if h1_on and timeframe.in_seconds(h1_tf) < chartSecs
        warnings := warnings + '⚠ HTF1 (' + h1_tf + ') is below chart TF — most zones missed\n'
    if h2_on and timeframe.in_seconds(h2_tf) < chartSecs
        warnings := warnings + '⚠ HTF2 (' + h2_tf + ') is below chart TF — most zones missed\n'
    if h3_on and timeframe.in_seconds(h3_tf) < chartSecs
        warnings := warnings + '⚠ HTF3 (' + h3_tf + ') is below chart TF — most zones missed\n'

    // HTF == chart TF AND Chart enabled: zones will duplicate
    if chart_on and h1_on and timeframe.in_seconds(h1_tf) == chartSecs
        warnings := warnings + '⚠ HTF1 matches chart TF — zones duplicate Chart FVGs\n'
    if chart_on and h2_on and timeframe.in_seconds(h2_tf) == chartSecs
        warnings := warnings + '⚠ HTF2 matches chart TF — zones duplicate Chart FVGs\n'
    if chart_on and h3_on and timeframe.in_seconds(h3_tf) == chartSecs
        warnings := warnings + '⚠ HTF3 matches chart TF — zones duplicate Chart FVGs\n'

    // NWOG: requires a chart bar that opens at exactly 18:00 NY. Safe TFs are anything that
    // divides 60 minutes cleanly (1m, 2m, 3m, 5m, 6m, 10m, 12m, 15m, 20m, 30m, 1H) plus 2H.
    // Anything else (3H, 4H, 6H, 8H, 12H, 1D, 1W, 1M, etc.) risks silent NWOG failure.
    bool nwogSafe = chartSecs == 60 or chartSecs == 120 or chartSecs == 180 or chartSecs == 300
     or chartSecs == 360 or chartSecs == 600 or chartSecs == 720 or chartSecs == 900
     or chartSecs == 1200 or chartSecs == 1800 or chartSecs == 3600 or chartSecs == 7200
    if nwog_on and not nwogSafe
        warnings := warnings + '⚠ NWOG: switch to 1H or smaller chart TF for detection\n'

    if warnings != ''
        var label cfgWarn = na
        if na(cfgWarn)
            cfgWarn := label.new(bar_index, high, warnings,
             color = color.new(color.orange, 20), textcolor = color.white,
             style = label.style_label_down, size = size.small)
        cfgWarn.set_x(bar_index)
        cfgWarn.set_y(high)
        cfgWarn.set_text(warnings)

if nwog_on and barstate.isconfirmed and is18Sun
    float prevClose = close[1]
    if not na(prevClose) and open != prevClose
        bool  isBull = open > prevClose
        float zTop   = math.max(open, prevClose)
        float zBot   = math.min(open, prevClose)
        int   topX1  = isBull ? bar_index     : bar_index - 1
        int   botX1  = isBull ? bar_index - 1 : bar_index
        FVGZone z = createZone(nwogCfg, isBull, zTop, zBot, topX1, botX1)
        nwogZones.push(z)
        nwogMit.push(false)
        nwogAE.push(false)

if nwog_on
    updateZones(nwogZones, nwogMit, nwogAE, nwogCfg)
````
