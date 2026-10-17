# ORDER FLOW DASHBOARD [DOM, Tape, Big Contracts] Percentage Based

- url: https://www.tradingview.com/script/8827q9XS-ORDER-FLOW-DASHBOARD-DOM-Tape-Big-Contracts-Percentage-Based/
- type: indicator
- pine_id: PUB;8f27748c5f4b49ab9fefa72d28767049
- version: 3.0

## Description

[image]https://www.tradingview.com/x/kJZoX4e1/[/image]

A compact, non-intrusive percentile order flow dashboard for futures scalping and intraday trading on /NQ, /MNQ, /ES, /MES and other CME instruments. Three panels, one glance.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHAT IS IT

Most order flow tools require expensive data feeds or dedicated platforms like Bookmap or Sierra Chart. This dashboard brings the core concepts of DOM pressure, tape reading and big contract detection directly onto your TradingView chart using bar structure and volume as proxies. It is designed to sit quietly in the corner of your chart, update in real time, and give you directional context without cluttering your price action.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

THE THREE PANELS

DOM Panel
Estimates bid vs ask pressure by splitting each bar's volume based on where price closed within the bar's range. A bar closing near its high suggests buying pressure — near the low suggests selling. Displays Buyers %, Sellers % and a Net Delta over your chosen lookback period. The dominant side lights up automatically.

Tape Panel
Estimates aggressive vs passive order flow. Bars closing in the upper half of their range are classified as aggressive buyers (market orders lifting the offer). Lower half = aggressive sellers (hitting the bid). Shows aggressive buy %, aggressive sell % and passive %. The leading side highlights.

Big Contracts Panel
Flags bars where total volume exceeds your threshold — a proxy for institutional or block trade activity. Each entry shows price, volume, direction (BID or ASK) and a New York exchange-time timestamp for chart cross-reference. Supports a lower detection timeframe — use 1 min detection on a 2 min chart for more granular results.

Confluence Signal
Combines DOM and Tape into a single directional read at the bottom of the Tape panel.
▲ BUYERS LEAD — both DOM and Tape show buyers in control. Strongest bullish signal.
▼ SELLERS LEAD — both DOM and Tape show sellers in control. Strongest bearish signal.
 ? DOM BULL / TAPE BEAR — conflicting signals. Potential absorption or reversal brewing.
 ? DOM BEAR / TAPE BULL — conflicting signals. Same as above but reversed.
 BALANCED — neither side clearly dominant on either panel.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DISPLAY MODES

Minimalistic Mode — strips all row background colors from DOM and Tape panels. Only text colors remain. Blends cleanly into any chart style or theme. Big Contracts panel keeps its colors for easy scanning.

Color Blind Friendly Mode — replaces red/green color scheme with blue/orange throughout the entire dashboard. One toggle in settings. Works alongside minimalistic mode.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ IMPORTANT — NOT REAL ORDER BOOK DATA

Pine Script does not have access to real Level 2 DOM data, true bid/ask volume splits or individual order sizes. Everything this dashboard shows is a bar structure approximation, not real order book data.

DOM proxy: buyVol = volume × (close − low) / (high − low)
Tape proxy: close position in range = aggressor classification
Big Contracts proxy: total bar volume spike — NOT individual order size

Use this dashboard as a confirming tool alongside price action. For true order flow data use Bookmap, Sierra Chart, Quantower or NinjaTrader with a proper CME data feed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HOW TO USE IT

Watch for confluence — when DOM and Tape both agree on a direction that is your strongest signal. A single panel reading alone is less reliable.

Use the Big Contracts panel to identify when institutional-sized volume hits. A cluster of big BID bars at a support level, combined with DOM buyers leading and tape aggressive buy dominant, is a classic accumulation pattern. The timestamp on each entry makes it easy to find the bar on your chart.

Watch the Net Delta — a rising price with falling net delta can signal a weakening move or absorption. A falling price with rising net delta may indicate buyers stepping in.

[image]https://www.tradingview.com/x/LMgPfZ7E/[/image]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RECOMMENDED SETTINGS BY TIMEFRAME

1 min  — DOM: 8-10 bars | Tape: 5-8 bars | NQ: 1500-2000 | ES: 300-500
2 min  — DOM: 5-8 bars  | Tape: 4-6 bars | NQ: 2000-3000 | ES: 500-800
3 min  — DOM: 5-6 bars  | Tape: 4-5 bars | NQ: 2500-3500 | ES: 600-1000
5 min  — DOM: 4-6 bars  | Tape: 3-5 bars | NQ: 3000-5000 | ES: 800-1500
15 min — DOM: 3-5 bars  | Tape: 3-4 bars | NQ: 5000-8000 | ES: 1500-3000

MNQ and MES: divide NQ/ES thresholds by 10.
Tip: set Big Contracts detection timeframe to 1 min when charting on 2 min.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CUSTOMISATION

Every color, background, transparency and threshold is adjustable from settings.

General — show/hide dashboard, DOM + Tape panels, Big Contracts panel, confluence row, minimalistic mode, color blind mode, dashboard position, text size, background transparency, chart background tint, session filter.

DOM — lookback period, alert threshold, full color and background customization per row.

Tape — lookback period, alert threshold, full color and background customization per row.

Cumulative Delta — optional full-width row at bottom of dashboard, display as number only, bar chart only or both, daily reset time.

Big Contracts — volume threshold, extra large threshold, detection timeframe, max entries to display, daily reset time, full color customization.

Alerts — 8 individually toggleable alert conditions covering big contracts, DOM dominance, tape dominance and confluence signals.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DESIGNED FOR

Futures scalpers and intraday traders who want order flow context without cluttering their chart or paying for a separate platform. Works on any instrument with volume data — optimized for CME futures.

## Source Code

````pine
// ============================================================
// ORDER FLOW DASHBOARD v5.7.1
// For Futures Trading: /NQ, /MNQ, /ES, /MES and more
// ============================================================
//
// WHAT THIS INDICATOR DOES:
// A compact, non-intrusive order flow dashboard for futures
// scalping and intraday trading. Three panels, one glance —
// no extra subscriptions or separate platforms required.
//
//   1. DOM Panel — Estimates bid vs ask pressure using volume
//      delta proxy. Shows Buyers %, Sellers % and Net Delta.
//      buyVol = volume * (close-low) / (high-low)
//
//   2. Tape Panel — Estimates aggressive (market orders) vs
//      passive (limit orders) activity. Close in upper half
//      of range = aggressive buyers. Lower half = aggressive
//      sellers. Shows who is winning the tape right now.
//
//   3. Big Contracts Panel — Flags volume spike bars above
//      your threshold. Shows price, volume, direction and
//      NY exchange timestamp for chart cross-reference.
//      Supports lower timeframe detection (e.g. 1 min on
//      a 2 min chart) for more granular spike identification.
//
//   4. Confluence Signal — Combines DOM and Tape into a
//      single directional read at the bottom of the Tape
//      panel. Lights up when both panels agree on direction.
//      ▲ BUYERS LEAD — both DOM and Tape bullish
//      ▼ SELLERS LEAD — both DOM and Tape bearish
//      ? CONFLICT     — panels disagree, potential reversal
//      BALANCED       — neither side clearly dominant
//
//   Display Modes:
//      Minimalistic — strips all row backgrounds, text only,
//      blends into any chart style or theme
//      Colour Blind — replaces red/green with blue/orange
//
// ⚠️ IMPORTANT LIMITATIONS:
//   Pine Script does NOT have access to real Level 2 DOM,
//   true bid/ask volume splits, or individual order sizes.
//   All panels use BAR STRUCTURE and VOLUME as proxies only.
//   This is NOT real order book data.
//
//   For true order flow data use: Bookmap, Sierra Chart,
//   Quantower or NinjaTrader with a proper CME data feed.
//
// RECOMMENDED SETTINGS BY TIMEFRAME:
//   1 min  — DOM: 8-10, Tape: 5-8,  NQ: 1500-2000, ES: 300-500
//   2 min  — DOM: 5-8,  Tape: 4-6,  NQ: 2000-3000, ES: 500-800
//   3 min  — DOM: 5-6,  Tape: 4-5,  NQ: 2500-3500, ES: 600-1000
//   5 min  — DOM: 4-6,  Tape: 3-5,  NQ: 3000-5000, ES: 800-1500
//   15 min — DOM: 3-5,  Tape: 3-4,  NQ: 5000-8000, ES: 1500-3000
//   MNQ/MES = divide NQ/ES thresholds by 10
//   Tip: set Big Contracts TF to 1 min when charting 2 min
//
// VERSION HISTORY:
//   v1.0 — Initial release
//   v1.9 — Single cell centered titles, Pine v6 upgrade
//   v2.0 — Removed empty rows, tightened layout
//   v2.1 — Removed DOM status row, compact layout
//   v2.2 — Full colour and transparency customisation
//   v2.3 — Background tint toggle, better defaults
//   v2.4 — Publication version, full description added
//   v2.5 — Chart tint colours and transparency customisable
//   v3.0 — Session filter, alert thresholds, delta divergence,
//           bar colouring, cumulative delta, reset time,
//           dashboard toggle added
//   v3.1 — Fixed divergence labels, cumulative delta moved
//           to dashboard table, removed overlay plot lines
//   v3.2 — Cumulative delta spans full table bottom row
//   v3.3 — Fixed empty gap when cumulative delta enabled
//   v3.4 — Fixed middle column gap caused by unset cells
//   v3.5 — Removed empty rows at bottom, clean layout
//   v3.6 — Cumulative delta display style selector added
//   v4.0 — Separate tape alert threshold, colour blind mode,
//           divergence label cleanup, improved tooltips
//   v4.1 — Watermark changed to settings hint
//   v4.2 — Confluence signal combining DOM and Tape
//   v4.3 — Confluence tooltip, AGGR rows light up like DOM
//   v4.4 — Confluence info moved to general settings
//   v4.5 — Removed divergence signals, renamed DELTA
//   v4.6 — Timestamp column added to big contracts panel
//   v4.7 — Removed bar colouring to avoid indicator conflicts
//   v4.8 — Individual panel show/hide toggles added
//   v4.9 — Panel toggles simplified, settings layout cleaned
//   v5.0 — Publication ready: settings consolidated, title
//           cleaned, max_bars_back added, alert descriptions
//           improved
//   v5.1 — Confluence explanation merged into toggle tooltip,
//           dummy tickbox removed, colour blind repositioned
//   v5.2 — Colour blind moved under confluence toggle,
//           timestamp fixed to use exchange time (New York)
//   v5.3 — Alert toggles added, big contracts lower timeframe
//           selector added for more granular spike detection
//   v5.4 — Fixed max big contracts to show — table rows now
//           dynamic so all entries display correctly
//   v5.5 — Minimalistic mode added
//   v5.6 — Fixed empty rows at bottom of big contracts panel
//           and gap between tape and confluence row
//   v5.7 — Fixed lower timeframe detection using
//           request.security_lower_tf so every lower TF bar
//           is checked individually — no more missed spikes
//   v5.7.1 — Updated preview chart image
// ============================================================

//@version=6
indicator(title = 'Order Flow Dashboard', shorttitle = 'OFD', overlay = true, max_labels_count = 500)

// ────────────────────────────────────────────────────────────
// MAX BARS BACK
// ────────────────────────────────────────────────────────────
max_bars_back(close,  500)
max_bars_back(high,   500)
max_bars_back(low,    500)
max_bars_back(volume, 500)

// ────────────────────────────────────────────────────────────
// INPUTS
// ────────────────────────────────────────────────────────────

grp_general = '── General ──'
i_showDash       = input.bool(true, 'show dashboard', group = grp_general,
     tooltip = 'Toggle the entire dashboard on or off without removing the indicator from your chart.')
i_showHint       = input.bool(true, 'show dashboard hint', group = grp_general,
     tooltip = 'Shows a small hint at the bottom of the dashboard reminding you that settings can be configured. Uncheck this once you are familiar with the indicator.')
i_showDomTape    = input.bool(true, 'show DOM and Tape panels', group = grp_general,
     tooltip = 'Show or hide both the DOM and Tape panels on the left side of the dashboard.')
i_showBig        = input.bool(true, 'show big contracts panel', group = grp_general,
     tooltip = 'Show or hide the Big Contracts panel on the right side of the dashboard.')
i_showConfluence = input.bool(true, 'show confluence signal row', group = grp_general,
     tooltip = 'Shows or hides the confluence signal row at the bottom of the Tape panel.\n\nThe confluence signal combines DOM and Tape readings into a single directional bias:\n\n▲ BUYERS LEAD — Both DOM and Tape show buyers in control. DOM buyers % is higher than sellers % AND aggressive tape buyers are dominating. Strongest bullish signal from this dashboard.\n\n▼ SELLERS LEAD — Both DOM and Tape show sellers in control. Strongest bearish signal.\n\n? DOM BULL / TAPE BEAR — DOM shows buying pressure but tape shows aggressive sellers. Could mean buyers are absorbing selling or a reversal is brewing. Treat as unclear direction.\n\n? DOM BEAR / TAPE BULL — DOM shows selling pressure but tape shows aggressive buyers. Same as above but reversed.\n\nBALANCED — Neither side is clearly dominant on either panel.')
i_colorBlind     = input.bool(false, 'colour blind friendly mode', group = grp_general,
     tooltip = 'Replaces red/green colour scheme with blue/orange which is easier to distinguish for most types of colour blindness.')
i_minimal        = input.bool(false, 'minimalistic mode', group = grp_general,
     tooltip = 'Strips all row background colours from the DOM and Tape panels. Only text colours remain, giving the dashboard a clean minimal look that blends into any chart style. Big contracts panel keeps its colours for easy scanning.')
i_tablePos       = input.string('Top Right', 'dashboard position', options = ['Top Right', 'Middle Right', 'Bottom Right'], group = grp_general,
     tooltip = 'Where on the chart the dashboard will appear.')
i_textSize       = input.string('Normal', 'text size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = grp_general,
     tooltip = 'Controls the font size of all text inside the dashboard.')
i_bgTransparency = input.int(12, 'background transparency (0=solid, 100=invisible)', minval = 0, maxval = 100, group = grp_general,
     tooltip = 'Sets how transparent the dashboard background is. 0 = fully solid, 100 = fully invisible.')
i_bgTint          = input.bool(false, 'show chart background tint', group = grp_general,
     tooltip = 'Tints the entire chart background when DOM buyers or sellers exceed the DOM alert threshold. Useful for quick directional bias at a glance. Off by default.')
i_bgTintBullColor = input.color(color.new(color.green, 95), 'tint bull color', group = grp_general,
     tooltip = 'Chart background colour when buyers are dominant.')
i_bgTintBearColor = input.color(color.new(color.red, 95),   'tint bear color', group = grp_general,
     tooltip = 'Chart background colour when sellers are dominant.')
i_sessionFilter   = input.bool(false, 'filter by session', group = grp_general,
     tooltip = 'When enabled, DOM and Tape calculations only include bars within your defined session window. Useful for filtering out overnight noise on futures.')
i_sessionStart    = input.string('0930-1600', 'session (exchange time)', group = grp_general,
     tooltip = 'Session window in exchange time format HHMM-HHMM. Default 0930-1600 covers CME regular trading hours. Adjust for your timezone or instrument.')

grp_dom = '── DOM / Bid-Ask % ──'
i_domLookback  = input.int(6, 'DOM lookback (bars)', minval = 1, maxval = 500, group = grp_dom,
     tooltip = 'How many bars back to sum estimated bid/ask volume. Lower = more reactive. Recommended: 5-8 bars for scalping, 14-20 for swing.')
i_domAlertThr  = input.int(60, 'DOM alert threshold (%)', minval = 51, maxval = 99, group = grp_dom,
     tooltip = 'DOM alerts and chart tint trigger when buyers or sellers exceed this percentage. Default 60% = at least 60% of volume on one side.')
i_domBullColor = input.color(color.new(color.lime, 0),   'buyers text color',        group = grp_dom,
     tooltip = 'Text colour for the buyers row.')
i_domBearColor = input.color(color.new(color.red, 0),    'sellers text color',       group = grp_dom,
     tooltip = 'Text colour for the sellers row.')
i_domBullBg    = input.color(color.new(color.green, 55), 'buyers background color',  group = grp_dom,
     tooltip = 'Background colour of buyers row when buyers are dominant (>50%). Ignored in minimalistic mode.')
i_domBearBg    = input.color(color.new(color.red, 55),   'sellers background color', group = grp_dom,
     tooltip = 'Background colour of sellers row when sellers are dominant (>50%). Ignored in minimalistic mode.')

grp_tape = '── Tape / Aggressive % ──'
i_tapeLookback  = input.int(5, 'tape lookback (bars)', minval = 1, maxval = 500, group = grp_tape,
     tooltip = 'How many bars back to sum estimated aggressive vs passive volume. Lower = more reactive. Recommended: 4-6 bars for scalping.')
i_tapeAlertThr  = input.int(65, 'tape alert threshold (%)', minval = 51, maxval = 99, group = grp_tape,
     tooltip = 'Tape alerts trigger when aggressive buyers or sellers exceed this share of total aggressive volume. Independent from DOM threshold.')
i_aggrBullColor = input.color(color.new(color.aqua, 0),    'aggressive buyers text color',  group = grp_tape,
     tooltip = 'Text colour for the aggressive buyers row.')
i_aggrBearColor = input.color(color.new(color.orange, 0),  'aggressive sellers text color', group = grp_tape,
     tooltip = 'Text colour for the aggressive sellers row.')
i_tapeBullBg    = input.color(color.new(#00FFAA, 65),      'buyers lead background color',  group = grp_tape,
     tooltip = 'Background colour of the confluence row when both DOM and Tape agree buyers are leading. Ignored in minimalistic mode.')
i_tapeBearBg    = input.color(color.new(color.orange, 65), 'sellers lead background color', group = grp_tape,
     tooltip = 'Background colour of the confluence row when both DOM and Tape agree sellers are leading. Ignored in minimalistic mode.')

grp_delta = '── Cumulative Delta ──'
i_showCumDelta   = input.bool(false, 'show cumulative delta', group = grp_delta,
     tooltip = 'Adds a cumulative delta row at the bottom of the dashboard showing the running total of estimated buy minus sell volume. Resets daily at the time configured below.')
i_cumDeltaStyle  = input.string('Bar + Number', 'display style', options = ['Number only', 'Bar only', 'Bar + Number'], group = grp_delta,
     tooltip = 'Number only: raw delta value with direction triangle.\nBar only: horizontal filled bar — blocks grow right for positive delta, left for negative.\nBar + Number: both together.')
i_cumDeltaReset  = input.string('0930', 'reset time (exchange time HHMM)', group = grp_delta,
     tooltip = 'Resets cumulative delta to zero at this time each day. Default 0930 = CME RTH open.')
i_cumDeltaBull   = input.color(color.new(color.lime, 0),   'bull text color',       group = grp_delta,
     tooltip = 'Text colour when cumulative delta is positive.')
i_cumDeltaBear   = input.color(color.new(color.red, 0),    'bear text color',       group = grp_delta,
     tooltip = 'Text colour when cumulative delta is negative.')
i_cumDeltaBullBg = input.color(color.new(color.green, 65), 'bull background color', group = grp_delta,
     tooltip = 'Background colour when cumulative delta is positive.')
i_cumDeltaBearBg = input.color(color.new(color.red, 65),   'bear background color', group = grp_delta,
     tooltip = 'Background colour when cumulative delta is negative.')

grp_big = '── Big Contracts ──'
i_bigThreshold = input.int(2500, 'big contract threshold (volume)', minval = 1, group = grp_big,
     tooltip = 'Flags bars where total bar volume exceeds this value.\nRecommended:\n  NQ  = 2000-3000\n  ES  = 500-1000\n  MNQ = 200-300\n  MES = 100-200\nNote: total bar volume only — NOT individual order size.')
i_bigTF        = input.string('Chart', 'detection timeframe', options = ['Chart', '1', '2', '3', '5'], group = grp_big,
     tooltip = 'Timeframe used to detect big contract volume spikes.\nChart = uses your current chart timeframe (no lower TF lookup).\n1, 2, 3, 5 = checks every bar on that timeframe independently.\nFor scalping on 2 min chart, setting this to 1 min catches spikes that would otherwise be hidden inside a 2 min bar.\nNote: lower timeframe option uses request.security_lower_tf for accurate per-bar detection.')
i_bigMaxRows   = input.int(8, 'max big contracts to show', minval = 1, maxval = 15, group = grp_big,
     tooltip = 'Maximum recent big contract bars to display. Older entries are removed as new ones come in.')
i_bigResetTime = input.string('0930', 'reset list at (exchange time HHMM)', group = grp_big,
     tooltip = 'Clears the big contracts list at this time each day. Default 0930 = CME RTH open.')
i_bigAlertThr  = input.int(3000, 'extra large contract threshold', minval = 1, group = grp_big,
     tooltip = 'Second higher threshold for exceptionally large volume bars. Fires a separate alert distinct from the standard big contract alert.')
i_bigBullColor = input.color(color.new(color.lime, 0),   'big buy text color',        group = grp_big,
     tooltip = 'Text colour for bullish big contract entries.')
i_bigBearColor = input.color(color.new(color.red, 0),    'big sell text color',       group = grp_big,
     tooltip = 'Text colour for bearish big contract entries.')
i_bigBullBg    = input.color(color.new(color.green, 55), 'big buy background color',  group = grp_big,
     tooltip = 'Background colour for bullish big contract entries.')
i_bigBearBg    = input.color(color.new(color.red, 55),   'big sell background color', group = grp_big,
     tooltip = 'Background colour for bearish big contract entries.')

grp_alerts = '── Alerts ──'
i_alertBig      = input.bool(true,  'alert: big contract detected',           group = grp_alerts,
     tooltip = 'Fires when a bar volume exceeds your big contract threshold.')
i_alertExtraBig = input.bool(true,  'alert: extra large contract detected',   group = grp_alerts,
     tooltip = 'Fires when a bar volume exceeds your extra large contract threshold.')
i_alertDomBull  = input.bool(false, 'alert: DOM buyers dominant',             group = grp_alerts,
     tooltip = 'Fires when DOM buyers % exceeds your DOM alert threshold.')
i_alertDomBear  = input.bool(false, 'alert: DOM sellers dominant',            group = grp_alerts,
     tooltip = 'Fires when DOM sellers % exceeds your DOM alert threshold.')
i_alertTapeBull = input.bool(false, 'alert: tape aggressive buyers dominant', group = grp_alerts,
     tooltip = 'Fires when aggressive buyers exceed your tape alert threshold.')
i_alertTapeBear = input.bool(false, 'alert: tape aggressive sellers dominant',group = grp_alerts,
     tooltip = 'Fires when aggressive sellers exceed your tape alert threshold.')
i_alertConfBull = input.bool(false, 'alert: confluence buyers lead',          group = grp_alerts,
     tooltip = 'Fires when both DOM and Tape show buyers leading simultaneously.')
i_alertConfBear = input.bool(false, 'alert: confluence sellers lead',         group = grp_alerts,
     tooltip = 'Fires when both DOM and Tape show sellers leading simultaneously.')

// ────────────────────────────────────────────────────────────
// COLOUR BLIND MODE
// ────────────────────────────────────────────────────────────
cbBull   = color.new(#2196F3, 0)
cbBear   = color.new(#FF9800, 0)
cbBullBg = color.new(#2196F3, 55)
cbBearBg = color.new(#FF9800, 55)

domBullTxt  = i_colorBlind ? cbBull   : i_domBullColor
domBearTxt  = i_colorBlind ? cbBear   : i_domBearColor
domBullBg_  = i_colorBlind ? cbBullBg : i_domBullBg
domBearBg_  = i_colorBlind ? cbBearBg : i_domBearBg
aggrBullTxt = i_colorBlind ? cbBull   : i_aggrBullColor
aggrBearTxt = i_colorBlind ? cbBear   : i_aggrBearColor
bigBullTxt  = i_colorBlind ? cbBull   : i_bigBullColor
bigBearTxt  = i_colorBlind ? cbBear   : i_bigBearColor
bigBullBg_  = i_colorBlind ? cbBullBg : i_bigBullBg
bigBearBg_  = i_colorBlind ? cbBearBg : i_bigBearBg

// ────────────────────────────────────────────────────────────
// HELPERS
// ────────────────────────────────────────────────────────────
f_tablePos(s) =>
    switch s
        'Top Right'    => position.top_right
        'Middle Right' => position.middle_right
        =>                position.bottom_right

f_textSize(s) =>
    switch s
        'Tiny'  => size.tiny
        'Small' => size.small
        'Large' => size.large
        =>         size.normal

f_pad(n) =>
    n < 10 ? '0' + str.tostring(n) : str.tostring(n)

var TABLE_POS = f_tablePos(i_tablePos)
var TEXT_SIZE = f_textSize(i_textSize)

inSession = not i_sessionFilter or not na(time(timeframe.period, i_sessionStart))

nyHour   = hour(time, 'America/New_York')
nyMinute = minute(time, 'America/New_York')

resetHour   = math.floor(str.tonumber(i_bigResetTime) / 100)
resetMinute = str.tonumber(i_bigResetTime) - resetHour * 100
isResetBar  = nyHour == resetHour and nyMinute == resetMinute and second < 30

deltaResetHour   = math.floor(str.tonumber(i_cumDeltaReset) / 100)
deltaResetMinute = str.tonumber(i_cumDeltaReset) - deltaResetHour * 100
isDeltaResetBar  = nyHour == deltaResetHour and nyMinute == deltaResetMinute and second < 30

// ────────────────────────────────────────────────────────────
// BIG CONTRACTS: Lower timeframe detection
// When Chart is selected we use bar data directly.
// When a lower TF is selected we use
// request.security_lower_tf which returns an array of every
// lower TF bar within the current chart bar — this ensures
// no spikes are missed between chart bar closes.
// ────────────────────────────────────────────────────────────
useChartTF = i_bigTF == 'Chart'
bigTF      = useChartTF ? timeframe.period : i_bigTF

// Lower TF arrays — one value per lower TF bar inside chart bar
ltfVolumes = useChartTF ? array.new_float(0) :
     request.security_lower_tf(syminfo.tickerid, bigTF, volume)
ltfCloses  = useChartTF ? array.new_float(0) :
     request.security_lower_tf(syminfo.tickerid, bigTF, close)
ltfOpens   = useChartTF ? array.new_float(0) :
     request.security_lower_tf(syminfo.tickerid, bigTF, open)
ltfHours   = useChartTF ? array.new_int(0) :
     request.security_lower_tf(syminfo.tickerid, bigTF, hour(time, 'America/New_York'))
ltfMinutes = useChartTF ? array.new_int(0) :
     request.security_lower_tf(syminfo.tickerid, bigTF, minute(time, 'America/New_York'))

// ────────────────────────────────────────────────────────────
// CALCULATIONS
// ────────────────────────────────────────────────────────────

f_buyVol(v, h, l, c)  => h - l > 0 ? v * (c - l) / (h - l) : v * 0.5
f_sellVol(v, h, l, c) => h - l > 0 ? v * (h - c) / (h - l) : v * 0.5

rawBuy  = f_buyVol(volume, high, low, close)
rawSell = f_sellVol(volume, high, low, close)

barBuy  = inSession ? rawBuy  : 0.0
barSell = inSession ? rawSell : 0.0

domBuySum   = math.sum(barBuy,  i_domLookback)
domSellSum  = math.sum(barSell, i_domLookback)
domTotal    = domBuySum + domSellSum
domBuyPct   = domTotal > 0 ? domBuySum / domTotal * 100 : 50.0
domSellPct  = 100 - domBuyPct
domNetDelta = math.sum(barBuy - barSell, i_domLookback)

closeRatio  = high - low > 0 ? (close - low) / (high - low) : 0.5
aggrBuyVol  = inSession ? volume * math.max(closeRatio - 0.5, 0) * 2 : 0.0
aggrSellVol = inSession ? volume * math.max(0.5 - closeRatio, 0) * 2 : 0.0
passiveVol  = inSession ? volume - aggrBuyVol - aggrSellVol : 0.0

tapeAggrBuySum  = math.sum(aggrBuyVol,  i_tapeLookback)
tapeAggrSellSum = math.sum(aggrSellVol, i_tapeLookback)
tapePassiveSum  = math.sum(passiveVol,  i_tapeLookback)
tapeTotal       = tapeAggrBuySum + tapeAggrSellSum + tapePassiveSum

tapeAggrBuyPct  = tapeTotal > 0 ? tapeAggrBuySum  / tapeTotal * 100 : 33.3
tapeAggrSellPct = tapeTotal > 0 ? tapeAggrSellSum / tapeTotal * 100 : 33.3
tapePassivePct  = 100 - tapeAggrBuyPct - tapeAggrSellPct

tapeAggrBuyShare  = tapeAggrBuyPct + tapeAggrSellPct > 0 ? tapeAggrBuyPct / (tapeAggrBuyPct + tapeAggrSellPct) * 100 : 50.0
tapeAggrSellShare = 100 - tapeAggrBuyShare

// Confluence
domBullish  = domBuyPct > domSellPct
domBearish  = domSellPct > domBuyPct
tapeBullish = tapeAggrBuyShare > tapeAggrSellShare
tapeBearish = tapeAggrSellShare > tapeAggrBuyShare

confluenceSignal =
     domBullish and tapeBullish ? '▲ BUYERS LEAD' :
     domBearish and tapeBearish ? '▼ SELLERS LEAD' :
     domBullish and tapeBearish ? '? DOM BULL / TAPE BEAR' :
     domBearish and tapeBullish ? '? DOM BEAR / TAPE BULL' :
     'BALANCED'

confluenceColor =
     domBullish and tapeBullish ? aggrBullTxt :
     domBearish and tapeBearish ? aggrBearTxt :
     color.gray

confluenceBg =
     i_minimal                  ? color.new(color.black, 100) :
     domBullish and tapeBullish ? i_tapeBullBg :
     domBearish and tapeBearish ? i_tapeBearBg :
     color.new(color.gray, 75)

// Cumulative Delta
var float cumDelta    = 0.0
var float cumDeltaMax = 1.0

if isDeltaResetBar
    cumDelta    := 0.0
    cumDeltaMax := 1.0
else
    cumDelta    += barBuy - barSell
    cumDeltaMax := math.max(cumDeltaMax, math.abs(cumDelta))

f_deltaBar(delta, maxVal) =>
    totalBlocks = 20
    half        = totalBlocks / 2
    filled      = maxVal > 0 ? math.round(math.abs(delta) / maxVal * half) : 0
    filled      := math.min(filled, half)
    emptyChar   = '░'
    fullChar    = '█'
    bar         = ''
    if delta >= 0
        for i = 0 to half - 1
            bar += emptyChar
        for i = 0 to half - 1
            bar += i < filled ? fullChar : emptyChar
    else
        for i = 0 to half - 1
            bar += (half - 1 - i) < filled ? fullChar : emptyChar
        for i = 0 to half - 1
            bar += emptyChar
    bar

// ────────────────────────────────────────────────────────────
// BIG CONTRACTS — array tracking
// ────────────────────────────────────────────────────────────
var bigPrices  = array.new_float(0)
var bigVolumes = array.new_float(0)
var bigDirs    = array.new_string(0)
var bigTimes   = array.new_string(0)

// Chart TF values (used when detection TF = Chart)
chartIsBig      = volume >= i_bigThreshold
chartIsExtraBig = volume >= i_bigAlertThr
chartDir        = close > open ? 'BUY' : close < open ? 'SELL' : 'NEUTRAL'
chartTime       = f_pad(nyHour) + ':' + f_pad(nyMinute)

if isResetBar and barstate.isconfirmed
    array.clear(bigPrices)
    array.clear(bigVolumes)
    array.clear(bigDirs)
    array.clear(bigTimes)

if barstate.isconfirmed
    if useChartTF
        // ── Chart TF mode — same as before ──
        if chartIsBig
            array.unshift(bigPrices,  close)
            array.unshift(bigVolumes, volume)
            array.unshift(bigDirs,    chartDir)
            array.unshift(bigTimes,   chartTime)
            if array.size(bigPrices) > i_bigMaxRows
                array.pop(bigPrices)
                array.pop(bigVolumes)
                array.pop(bigDirs)
                array.pop(bigTimes)
    else
        // ── Lower TF mode — check every bar in the array ──
        n = array.size(ltfVolumes)
        if n > 0
            for i = 0 to n - 1
                ltfVol = array.get(ltfVolumes, i)
                if ltfVol >= i_bigThreshold
                    ltfC   = array.get(ltfCloses,  i)
                    ltfO   = array.get(ltfOpens,   i)
                    ltfH   = array.get(ltfHours,   i)
                    ltfM   = array.get(ltfMinutes, i)
                    ltfDir = ltfC > ltfO ? 'BUY' : ltfC < ltfO ? 'SELL' : 'NEUTRAL'
                    ltfTim = f_pad(ltfH) + ':' + f_pad(ltfM)
                    array.unshift(bigPrices,  ltfC)
                    array.unshift(bigVolumes, ltfVol)
                    array.unshift(bigDirs,    ltfDir)
                    array.unshift(bigTimes,   ltfTim)
                    if array.size(bigPrices) > i_bigMaxRows
                        array.pop(bigPrices)
                        array.pop(bigVolumes)
                        array.pop(bigDirs)
                        array.pop(bigTimes)

// Alert triggers — based on most recent confirmed bar
isBigBar      = useChartTF ? chartIsBig      : array.size(ltfVolumes) > 0 and array.max(ltfVolumes) >= i_bigThreshold
isExtraBigBar = useChartTF ? chartIsExtraBig : array.size(ltfVolumes) > 0 and array.max(ltfVolumes) >= i_bigAlertThr

// ────────────────────────────────────────────────────────────
// TABLE
// ────────────────────────────────────────────────────────────
bgColor     = color.new(color.black, i_bgTransparency)
borderColor = color.new(color.gray, 40)
totalRows   = math.max(9, i_bigMaxRows + 1) + 3

var table dash = table.new(position = TABLE_POS, columns = 5, rows = totalRows, bgcolor = bgColor, border_color = borderColor, border_width = 1, frame_color = color.new(#b2b5be, 85), frame_width = 2)

if barstate.islast and i_showDash

    // ── DOM PANEL ──────────────────────────────────────────
    if i_showDomTape
        table.cell(dash, 0, 0, 'DOM', text_color = color.white, bgcolor = color.new(#2195f3, 100), text_size = TEXT_SIZE, text_halign = text.align_center)
        table.merge_cells(dash, 0, 0, 1, 0)

        domBuyBg = (not i_minimal and domBuyPct > 50) ? domBullBg_ : bgColor
        table.cell(dash, 0, 1, '▲ BUYERS', text_color = domBullTxt, bgcolor = domBuyBg, text_size = TEXT_SIZE)
        table.cell(dash, 1, 1, str.tostring(math.round(domBuyPct, 1)) + '%', text_color = domBullTxt, bgcolor = domBuyBg, text_size = TEXT_SIZE)

        domSellBg = (not i_minimal and domSellPct > 50) ? domBearBg_ : bgColor
        table.cell(dash, 0, 2, '▼ SELLERS', text_color = domBearTxt, bgcolor = domSellBg, text_size = TEXT_SIZE)
        table.cell(dash, 1, 2, str.tostring(math.round(domSellPct, 1)) + '%', text_color = domBearTxt, bgcolor = domSellBg, text_size = TEXT_SIZE)

        netTxtCol = domNetDelta >= 0 ? domBullTxt : domBearTxt
        netLabel  = domNetDelta >= 0 ? 'NET △' : 'NET ▽'
        table.cell(dash, 0, 3, netLabel, text_color = netTxtCol, bgcolor = bgColor, text_size = TEXT_SIZE)
        table.cell(dash, 1, 3, (domNetDelta >= 0 ? '+' : '') + str.tostring(math.round(domNetDelta)), text_color = netTxtCol, bgcolor = bgColor, text_size = TEXT_SIZE)

    // ── TAPE PANEL ─────────────────────────────────────────
    if i_showDomTape
        table.cell(dash, 0, 4, 'TAPE', text_color = color.white, bgcolor = color.new(#9b27b0, 100), text_size = TEXT_SIZE, text_halign = text.align_center)
        table.merge_cells(dash, 0, 4, 1, 4)

        aggrBuyBg = (not i_minimal and tapeAggrBuyShare > tapeAggrSellShare) ? (i_colorBlind ? cbBullBg : color.new(color.aqua, 70)) : bgColor
        table.cell(dash, 0, 5, '▲ AGGR BUY', text_color = aggrBullTxt, bgcolor = aggrBuyBg, text_size = TEXT_SIZE)
        table.cell(dash, 1, 5, str.tostring(math.round(tapeAggrBuyPct, 1)) + '%', text_color = aggrBullTxt, bgcolor = aggrBuyBg, text_size = TEXT_SIZE)

        aggrSellBg = (not i_minimal and tapeAggrSellShare > tapeAggrBuyShare) ? (i_colorBlind ? cbBearBg : color.new(color.orange, 70)) : bgColor
        table.cell(dash, 0, 6, '▼ AGGR SELL', text_color = aggrBearTxt, bgcolor = aggrSellBg, text_size = TEXT_SIZE)
        table.cell(dash, 1, 6, str.tostring(math.round(tapeAggrSellPct, 1)) + '%', text_color = aggrBearTxt, bgcolor = aggrSellBg, text_size = TEXT_SIZE)

        table.cell(dash, 0, 7, '≈ PASSIVE', text_color = color.gray, text_size = TEXT_SIZE)
        table.cell(dash, 1, 7, str.tostring(math.round(tapePassivePct, 1)) + '%', text_color = color.gray, text_size = TEXT_SIZE)

        if i_showConfluence
            table.cell(dash, 0, 8, confluenceSignal, text_color = confluenceColor, bgcolor = confluenceBg, text_size = TEXT_SIZE, text_halign = text.align_center)
            table.merge_cells(dash, 0, 8, 1, 8)

    // ── BIG CONTRACTS PANEL ────────────────────────────────
    if i_showBig
        table.cell(dash, 2, 0, 'PRICE',     text_color = color.silver, bgcolor = bgColor, text_size = size.tiny, text_halign = text.align_center)
        table.cell(dash, 3, 0, 'VOL / DIR', text_color = color.silver, bgcolor = bgColor, text_size = size.tiny, text_halign = text.align_center)
        table.cell(dash, 4, 0, 'TIME',      text_color = color.silver, bgcolor = bgColor, text_size = size.tiny, text_halign = text.align_center)

        n = array.size(bigPrices)
        if n == 0
            table.cell(dash, 2, 1, 'no big orders yet', text_color = color.gray, bgcolor = bgColor, text_size = size.tiny, text_halign = text.align_center)
            table.merge_cells(dash, 2, 1, 4, 1)
            for r = 2 to i_bigMaxRows
                table.cell(dash, 2, r, '', bgcolor = bgColor)
                table.cell(dash, 3, r, '', bgcolor = bgColor)
                table.cell(dash, 4, r, '', bgcolor = bgColor)
        else
            maxR = math.min(n, i_bigMaxRows)
            for i = 0 to maxR - 1
                r   = i + 1
                prc = array.get(bigPrices,  i)
                vol = array.get(bigVolumes, i)
                dir = array.get(bigDirs,    i)
                tim = array.get(bigTimes,   i)

                dirSymbol = dir == 'BUY' ? '▲ BID' : dir == 'SELL' ? '▼ ASK' : '◆'
                txtCol    = dir == 'BUY' ? bigBullTxt : dir == 'SELL' ? bigBearTxt : color.yellow
                cellBg    = dir == 'BUY' ? bigBullBg_ : dir == 'SELL' ? bigBearBg_ : color.new(color.yellow, 80)

                table.cell(dash, 2, r, str.tostring(prc, format.mintick), text_color = txtCol, bgcolor = cellBg, text_size = TEXT_SIZE, text_halign = text.align_center)
                table.cell(dash, 3, r, str.tostring(math.round(vol)) + ' ' + dirSymbol, text_color = txtCol, bgcolor = cellBg, text_size = TEXT_SIZE, text_halign = text.align_center)
                table.cell(dash, 4, r, tim, text_color = color.new(color.silver, 30), bgcolor = cellBg, text_size = size.tiny, text_halign = text.align_center)

            if maxR < i_bigMaxRows
                for r = maxR + 1 to i_bigMaxRows
                    table.cell(dash, 2, r, '', bgcolor = bgColor)
                    table.cell(dash, 3, r, '', bgcolor = bgColor)
                    table.cell(dash, 4, r, '', bgcolor = bgColor)

    // ── Cumulative Delta ────────────────────────────────────
    if i_showCumDelta
        cumDeltaCol = cumDelta >= 0 ? i_cumDeltaBull   : i_cumDeltaBear
        cumDeltaBg  = cumDelta >= 0 ? i_cumDeltaBullBg : i_cumDeltaBearBg
        cumValStr   = (cumDelta >= 0 ? '+' : '') + str.tostring(math.round(cumDelta))
        deltaBar    = f_deltaBar(cumDelta, cumDeltaMax)

        cumDeltaLbl = switch i_cumDeltaStyle
            'Number only' => 'CUMULATIVE DELTA  ' + (cumDelta >= 0 ? '△' : '▽') + '  ' + cumValStr
            'Bar only'    => deltaBar
            =>               deltaBar + '  ' + cumValStr

        cumRow = math.max(9, i_bigMaxRows + 1)
        table.cell(dash, 0, cumRow, cumDeltaLbl, text_color = cumDeltaCol, bgcolor = cumDeltaBg, text_size = TEXT_SIZE, text_halign = text.align_center)
        table.merge_cells(dash, 0, cumRow, 4, cumRow)

    // ── Settings hint ───────────────────────────────────────
    if i_showHint
        hintRow = math.max(10, i_bigMaxRows + 2)
        table.cell(dash, 0, hintRow, '⚙  configure this dashboard in settings', text_color = color.new(color.gray, 40), bgcolor = bgColor, text_size = size.tiny, text_halign = text.align_center)
        table.merge_cells(dash, 0, hintRow, 4, hintRow)

// ────────────────────────────────────────────────────────────
// BACKGROUND TINT
// ────────────────────────────────────────────────────────────
bgcolor(i_bgTint ? (domBuyPct > float(i_domAlertThr) ? i_bgTintBullColor : domSellPct > float(i_domAlertThr) ? i_bgTintBearColor : na) : na)

// ────────────────────────────────────────────────────────────
// ALERTS
// ────────────────────────────────────────────────────────────
alertcondition(i_alertBig and isBigBar,
     title   = 'Big Contract Detected',
     message = 'Order Flow Dashboard: Big volume spike detected on {{ticker}} at {{close}}')
alertcondition(i_alertExtraBig and isExtraBigBar,
     title   = 'Extra Large Contract Detected',
     message = 'Order Flow Dashboard: Extra large volume spike detected on {{ticker}} at {{close}}')
alertcondition(i_alertDomBull and domBuyPct > float(i_domAlertThr),
     title   = 'DOM — Buyers Dominant',
     message = 'Order Flow Dashboard: DOM buyers dominant on {{ticker}} — buyers exceeding threshold')
alertcondition(i_alertDomBear and domSellPct > float(i_domAlertThr),
     title   = 'DOM — Sellers Dominant',
     message = 'Order Flow Dashboard: DOM sellers dominant on {{ticker}} — sellers exceeding threshold')
alertcondition(i_alertTapeBull and tapeAggrBuyShare > float(i_tapeAlertThr),
     title   = 'Tape — Aggressive Buyers Dominant',
     message = 'Order Flow Dashboard: Aggressive buyers dominating tape on {{ticker}}')
alertcondition(i_alertTapeBear and tapeAggrSellShare > float(i_tapeAlertThr),
     title   = 'Tape — Aggressive Sellers Dominant',
     message = 'Order Flow Dashboard: Aggressive sellers dominating tape on {{ticker}}')
alertcondition(i_alertConfBull and domBullish and tapeBullish,
     title   = 'Confluence — Buyers Lead',
     message = 'Order Flow Dashboard: Full confluence — both DOM and Tape show buyers leading on {{ticker}}')
alertcondition(i_alertConfBear and domBearish and tapeBearish,
     title   = 'Confluence — Sellers Lead',
     message = 'Order Flow Dashboard: Full confluence — both DOM and Tape show sellers leading on {{ticker}}')

// ============================================================
// END OF SCRIPT
// ============================================================
````
