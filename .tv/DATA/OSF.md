<!-- tradingview-pine-id: PUB;1b3fe342ff0e41ccb8d1c5a753b68446 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# OSF

Source: https://www.tradingview.com/script/K4zaGkLy-OSF/

## Description

OSF — Fractal Sweep / CISD Model
Overview

OSF is an overlay indicator that tracks a four-candle higher-timeframe (HTF) sequence and reports its progress on a lower-timeframe (LTF) chart. It draws a compact HTF candle preview to the right of price, marks the point where an HTF candle sweeps the prior candle's extreme and closes back inside it, locates the LTF order-block open that price must reclaim (CISD), and then follows the setup through two further HTF candles to record whether it stayed intact or was invalidated.

Everything the script draws comes from one place: the relationship between consecutive HTF candles and the LTF bars that build them. Nothing is smoothed, averaged, or derived from a conventional oscillator.

What the model is

The script names four consecutive HTF candles:

C1 — the reference candle whose high and low become the levels to be swept.
C2 — the sweep candle. A bullish C2 trades below C1's low and closes back above it. A bearish C2 trades above C1's high and closes back below it. The C2 extreme (its low for bullish, its high for bearish) becomes the invalidation level for the whole setup.
C3 — the confirmation window. This is where price is expected to hold above (bullish) or below (bearish) the C2 extreme, and where the CISD reclaim is normally expected.
C4 — the outcome window. If price has still not breached the C2 extreme by the end of C4, the setup is recorded as "C4 intact."

A breach of the C2 extreme at any point kills the setup. The script distinguishes a breach that happens during C3 from one that happens during C4, because they are different failure modes, and labels the C2 marker XC2 accordingly (red before C4, orange after).

CISD

CISD (Change In State of Delivery) is calculated on the chart timeframe, not on the HTF. When the chart makes a new period low that also runs below the prior period's low, the script walks back up to ten bars to find the relevant swing open — the open of the last up-candle before the down-sequence that produced the low, adjusted upward if a later down-candle opens higher. That open price is the CISD level. The bearish case is the mirror image.

Two states are shown:

Early CISD — price closes back through the level before the HTF model has confirmed. Drawn as its own line and label so you can see the reclaim as it happens. Optional, and controlled separately from the alert for it.
Confirmed CISD — the same reclaim, but attached to a live C2 setup. Confirmed CISD is what "reveals" a setup: by default the C2 label, sweep line, and T-Spot zones are only drawn once CISD confirms, so the chart is not cluttered with unconfirmed sweeps.

If CISD only ever confirms after the model has already moved into C4, and C4 is then invalidated, the entire setup — including that CISD confirmation — is removed retroactively rather than left on the chart as a signal that never mattered.

Drawings
HTF candle preview — up to ten synthetic HTF candles rendered to the right of the last chart bar, with configurable body, border, and wick colors, an offset control, and a live-updating current candle.
HTF open line, period boundary lines, live high/low lines — optional reference lines tied to the HTF period.
Candle equilibrium — the 50% level of each HTF candle, plus the reference dash used by the T-Spot zone.
T-Spot box — the zone between the current HTF candle open and the previous HTF candle's equilibrium, drawn for C3 and again for C4. This is the area the model treats as the working range for the phase.
Candle 1 sweep lines — optional lines from the swept C1 extreme forward to confirmation, available separately on the HTF preview and on the chart timeframe, with a count limit and an s label.
Deviation projections — optional standard-deviation style extensions of the CISD-to-C2-extreme range, using either wicks or bodies as endpoints. Multipliers are entered as a comma-separated list (for example -1,-2,-3); invalid entries are ignored.

Line style, width, color, extension length, and label offset are exposed for every drawing type.

Timeframe pairing

The model needs an LTF/HTF pair. Preset pairs are 3m-15m, 1m-15m, 3m-30m, 5m-1H, 15m-4H, 1H-1D, 4H-1W, and 1D-1W. Custom lets you set both sides yourself. Auto selects the pair from the chart timeframe: 30s through 3m charts use 3m-15m, 5m uses 5m-1H, 15m uses 15m-4H, and anything else falls back to a monthly HTF.

The chart timeframe must be at or below the LTF side of the pair. When it is not, the dashboard shows a red warning row naming the timeframe you should switch to, and the HTF preview is suppressed. Model calculations still run, but the display is not meaningful in that state.

Note that HTF values are requested with lookahead enabled so the developing HTF candle can be drawn in real time. This is intentional for the preview, but it means historical HTF candle bodies on the chart reflect completed data — treat historical and realtime rendering as different, and do not read the preview as a backtest.

Dashboard

The table has three modes:

Live — the active setup only: direction, phase, CISD state, reclaim strength, rejection wick, age in bars.
Historical — adds the observed tally accumulated over the chart's loaded history: C4-intact rate, CISD confirmation rate, C4-intact rate split by whether CISD confirmed, and the two failure rates.
Full — adds sample counts, definitions, and interpretation notes.

Two measurements are worth defining explicitly:

Reclaim strength — where C2 closed inside C1's range, as a percentage of C1's range. A bullish C2 that swept the low and closed near C1's high scores high.
Rejection wick — the length of C2's rejection wick as a percentage of C2's own range.
About the reference figures

The dashboard can display a set of fixed reference percentages alongside the live tally. Those reference numbers are hard-coded constants taken from an external observational study of NQ/ES futures over 2019–2025 that counted per-event outcomes only. They are not calculated by this script, not derived from your chart, not a backtest, and not a P&L result — no position sizing, costs, slippage, or exit rules are involved anywhere in them. They are included purely as a static point of comparison, and they can be switched off entirely with the Study Benchmarks input.

The "Observed" column is calculated live by the script from whatever history your chart has loaded, so it will differ between symbols, timeframes, and account plans, and it will be small and noisy on short histories. Sample sizes (n=) are shown so you can judge that for yourself. Neither column predicts future outcomes.

Settings
General Settings — alerts master switch, separate Early CISD alert switch, history depth (number of retained setups; 0 keeps all), directional bias filter (Neutral / Bullish / Bearish), fractal pair, Early CISD display, custom LTF/HTF.
HTF Candles — candle count, hide toggle, offset, body/border/wick colors, HTF open line, period boundary lines, live high/low lines.
Model Style — label visibility and size, Early CISD styling, bullish and bearish CISD styling, candle equilibrium, T-Spot box colors.
Candle 1 Sweeps — HTF and LTF display toggles, count cap, sweep colors, extension, labels and label offset, style and width.
Line Extensions — bar-count extensions and label offsets for CISD and projection lines.
Deviations — enable, multiplier list, wick or body method, styling.
Dashboard — show/hide, mode, size, screen position, text and background colors, reference-figure toggle, live-setup toggle.
Alerts

Enable Alerts?, then create an alert on this indicator using "Any alert() function call." Events fire once per bar:

Bullish C2 formed
Bearish C2 formed
Bullish / Bearish Early CISD confirmed (requires Early CISD Alerts? as well)

Early CISD Alerts? controls only the alert events. Early CISD drawings are controlled by the separate Early CISD input.

How to use it
Set the fractal pair, or leave it on Auto, and make sure your chart timeframe is at or below the LTF side. The dashboard warns you if it is not.
Wait for a C2 to form — an HTF candle that sweeps the prior candle's extreme and closes back inside it.
Watch for the CISD reclaim on your chart timeframe. Confirmed CISD is what reveals the setup and what the model treats as the state change.
The C2 extreme is the invalidation reference. C3 is the window in which the setup should hold; C4 is where the outcome is recorded.
Use the T-Spot zone and the HTF equilibrium as context for where inside the phase price is working, and the deviation projections if you want measured extensions off the CISD range.
Use the bias filter to suppress counter-trend setups when you have a directional view.
Limitations and notes
This is an analysis and visualization tool. It generates no entries, exits, stops, targets, or position sizing, and it is not a strategy.
Drawing objects are capped by TradingView at 500 boxes, lines, and labels. High History, HTF Candles, Count, and deviation-multiplier settings all consume from those caps, and older drawings will be dropped when the cap is reached.
HTF data is requested with lookahead enabled to render the developing HTF candle. Realtime and historical rendering therefore differ; the preview is a display convenience, not a signal source.
The observed statistics depend entirely on how much history your chart has loaded and will change as you scroll, switch symbols, or change timeframes.
Repainting behavior on the current bar is inherent to any model that evaluates a developing candle. Levels and phase states are settled on bar close.
Nothing here is financial advice, and no result shown — observed or reference — is a prediction or a guarantee of future performance. Trading involves risk of loss.

---

## Source Code

````pine
//@version=6
indicator("OSF", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

//#region [INPUTS]

grpModel   = 'General Settings'
showAlerts = input.bool(true, 'Alerts?', group = grpModel, inline = 'alerts', tooltip = "Master switch for C2, CISD, and enabled Early CISD alert() events. After enabling it, create an alert for this indicator using 'Any alert() function call'.")
showEarlyCisdAlerts = input.bool(false, 'Early CISD Alerts?', group = grpModel, inline = 'alerts', tooltip = "Allows alert() events when price first reclaims the CISD level. Requires Alerts? to be enabled; this does not control Early CISD drawings.")
showHistory = input.int(1, 'History', minval = 0, maxval = 40, group = grpModel, tooltip = 'Number of setup records retained and drawn. Set to 0 to retain all records; higher values use more drawing objects.')
biasFilter = input.string('Neutral', 'Bias', options = ['Neutral', 'Bullish', 'Bearish'], group = grpModel, tooltip = 'Filters model triggers by direction. Neutral allows both bullish and bearish setups; Bullish or Bearish allows only that direction.')
modelType  = input.string('Auto', 'Fractal', options = ['Custom', 'Auto', '3m-15m', '1m-15m', '3m-30m', '5m-1H', '15m-4H', '1H-1D', '4H-1W', '1D-1W'], group = grpModel, inline = 'fractal', tooltip = 'Select the lower/higher timeframe pair used by the fractal model. Auto prioritizes the 3m-15m pairing on 1m to 3m charts, the highest conditional return in the supplied study.')
showEarlyCisd = input.bool(true, 'Early CISD', group = grpModel, inline = 'fractal', tooltip = 'Show early CISD lines when price reclaims a detected CISD level before the full model confirmation.')
customLTF  = input.timeframe('5',  'Custom LTF                      ', group = grpModel, inline = 'custom', tooltip = 'Lower timeframe designation for the Custom fractal pair. The chart timeframe must be equal to or lower than this value for the model to be valid; set it below Custom HTF.', active = modelType == 'Custom')
customHTF  = input.timeframe('60', '', group = grpModel, inline = 'custom', tooltip = 'Higher timeframe used by the Custom fractal selection. It should be higher than Custom LTF.', active = modelType == 'Custom')

grpCandles     = 'HTF Candles'
htfCandleCount = input.int(4, 'HTF Candles', minval = 1, maxval = 10, group = grpCandles, inline = 'count', tooltip = 'Number of higher-timeframe candle previews displayed to the right of the chart.')
hideHtf        = input.bool(false, 'Hide?', group = grpCandles, inline = 'count', tooltip = 'Hide the higher-timeframe candle preview while keeping the model calculations active.')
candleOffsetIn = input.int(0, 'Offset', minval = 0, group = grpCandles, tooltip = 'Horizontal spacing, in chart bars, between the latest chart bar and the higher-timeframe candle preview.')

bullBody   = input.color(color.new(color.green, 0), 'Body', group = grpCandles, inline = 'body', tooltip = 'Fill color for bullish higher-timeframe candle bodies.')
bearBody   = input.color(color.new(#000000, 0), '', group = grpCandles, inline = 'body', tooltip = 'Fill color for bearish higher-timeframe candle bodies.')
borderBull = input.color(color.new(#000000, 0), 'Borders', group = grpCandles, inline = 'border', tooltip = 'Border color for bullish higher-timeframe candles.')
borderBear = input.color(color.new(#000000, 0), '', group = grpCandles, inline = 'border', tooltip = 'Border color for bearish higher-timeframe candles.')
wickBull   = input.color(color.new(#000000, 0), 'Wick', group = grpCandles, inline = 'wick', tooltip = 'Wick color for bullish higher-timeframe candles.')
wickBear   = input.color(color.new(#000000, 0), '', group = grpCandles, inline = 'wick', tooltip = 'Wick color for bearish higher-timeframe candles.')

showHtfOpen  = input.bool(true, 'HTF Open', group = grpCandles, inline = 'htfopen', tooltip = 'Show a horizontal line at the current higher-timeframe candle open.')
htfOpenColor = input.color(color.new(#1a1a1a, 30), '', group = grpCandles, inline = 'htfopen', tooltip = 'Color of the higher-timeframe open line.')
htfOpenStyle = input.string('Solid', '', options = ['Solid', 'Dashed', 'Dotted'], group = grpCandles, inline = 'htfopen', tooltip = 'Line style of the higher-timeframe open line.')
htfOpenWidth = input.int(1, '', minval = 1, group = grpCandles, inline = 'htfopen', tooltip = 'Line width of the higher-timeframe open line.')

showVlines = input.bool(true, 'O/C Time', group = grpCandles, inline = 'vline', tooltip = 'Show vertical lines at the start of each higher-timeframe period, marking its open/close boundary.')
lineColor  = input.color(color.new(color.gray, 60), '', group = grpCandles, inline = 'vline', tooltip = 'Color of the higher-timeframe period boundary lines.')
lineStyle  = input.string('Solid', '', options = ['Solid', 'Dashed', 'Dotted'], group = grpCandles, inline = 'vline', tooltip = 'Line style of the higher-timeframe period boundary lines.')
lineWidth  = input.int(1, '', minval = 1, group = grpCandles, inline = 'vline', tooltip = 'Line width of the higher-timeframe period boundary lines.')

showLH  = input.bool(false, 'L/H Lines', group = grpCandles, inline = 'lh', tooltip = 'Show live high and low lines for the current and retained higher-timeframe candles.')
lhColor = input.color(color.new(#1a1a1a, 30), '', group = grpCandles, inline = 'lh', tooltip = 'Color of the higher-timeframe high and low lines.')
lhStyle = input.string('Solid', '', options = ['Solid', 'Dashed', 'Dotted'], group = grpCandles, inline = 'lh', tooltip = 'Line style of the higher-timeframe high and low lines.')
lhWidth = input.int(1, '', minval = 1, group = grpCandles, inline = 'lh', tooltip = 'Line width of the higher-timeframe high and low lines.')

grpVisuals = 'Model Style'
showLabels = input.bool(true, 'Labels?', group = grpVisuals, inline = 'lbl', tooltip = 'Show C2, C4, CISD, invalidation, and projection labels where applicable.')
labelSize  = input.string('Small', '', group = grpVisuals, inline = 'lbl', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], tooltip = 'Text size for model and projection labels.', active = showLabels)
grpSweeps = 'Candle 1 Sweeps'
showHtfSweeps = input.bool(false, 'Show HTF', group = grpSweeps, inline = 'display', tooltip = 'Display Candle 1 sweep lines on the higher-timeframe candle preview.')
showLtfSweeps = input.bool(false, 'Show LTF', group = grpSweeps, inline = 'display', tooltip = 'Display Candle 1 sweep lines on the chart timeframe when a model sweep is confirmed.')
sweepCount = input.int(3, 'Count', minval = 0, maxval = 100, group = grpSweeps, tooltip = 'Maximum number of recent Candle 1 sweep lines to show on each selected timeframe. 0 keeps all available lines.')
sweepHighColor = input.color(color.new(color.red, 0), 'High Sweep', group = grpSweeps, inline = 'high', tooltip = 'Color for bearish high sweeps, where price runs above a prior high.')
sweepLowColor = input.color(color.new(color.green, 0), 'Low Sweep', group = grpSweeps, inline = 'low', tooltip = 'Color for bullish low sweeps, where price runs below a prior low.')
sweepExtension = input.int(3, 'Extension', minval = 0, maxval = 500, group = grpSweeps, tooltip = 'Number of chart bars to extend each sweep line beyond its confirmation endpoint on both selected timeframes.')
showSweepLabels = input.bool(true, 'Labels', group = grpSweeps, inline = 'labels', tooltip = 'Show a small s label at the end of each displayed Candle 1 sweep line.')
sweepLabelOffset = input.int(0, 'Offset', minval = 0, maxval = 250, group = grpSweeps, inline = 'labels', tooltip = 'Additional chart-bar offset between the end of a sweep line and its s label.')
sweepLabelSize = input.string('Small', 'Size', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = grpSweeps, tooltip = 'Text size of the s labels on HTF and LTF sweep lines.', active = showSweepLabels)

sweepStyle = input.string('Solid', 'Style', options = ['Solid', 'Dashed', 'Dotted'], group = grpSweeps, inline = 'style', tooltip = 'Line style applied to Candle 1 sweep lines on both the HTF preview and LTF chart.')
sweepWidth = input.int(1, 'Width', minval = 1, maxval = 5, group = grpSweeps, inline = 'style', tooltip = 'Line width applied to Candle 1 sweep lines on both the HTF preview and LTF chart.')

earlyCisdColor = input.color(color.new(color.blue, 0), 'Early CISD', group = grpVisuals, inline = 'earlycisd', tooltip = 'Color of early CISD lines and labels.', active = showEarlyCisd)
earlyCisdStyle = input.string('Dashed', '', options = ['Solid', 'Dashed', 'Dotted'], group = grpVisuals, inline = 'earlycisd', tooltip = 'Line style for early CISD levels.', active = showEarlyCisd)
earlyCisdWidth = input.int(1, '', minval = 1, group = grpVisuals, inline = 'earlycisd', tooltip = 'Line width for early CISD levels.', active = showEarlyCisd)

showBullCisd  = input.bool(true, 'Bullish CISD', group = grpVisuals, inline = 'bullcisd', tooltip = 'Show confirmed bullish CISD levels and labels.')
cisdBullColor = input.color(color.new(color.blue, 0), '', group = grpVisuals, inline = 'bullcisd', tooltip = 'Color of confirmed bullish CISD levels and labels.')
cisdBullStyle = input.string('Solid', '', options = ['Solid', 'Dashed', 'Dotted'], group = grpVisuals, inline = 'bullcisd', tooltip = 'Line style for confirmed bullish CISD levels.', active = showBullCisd)
cisdBullWidth = input.int(1, '', minval = 1, group = grpVisuals, inline = 'bullcisd', tooltip = 'Line width for confirmed bullish CISD levels.', active = showBullCisd)

showBearCisd  = input.bool(true, 'Bearish CISD', group = grpVisuals, inline = 'bearcisd', tooltip = 'Show confirmed bearish CISD levels and labels.')
cisdBearColor = input.color(color.new(color.blue, 0), '', group = grpVisuals, inline = 'bearcisd', tooltip = 'Color of confirmed bearish CISD levels and labels.')
cisdBearStyle = input.string('Solid', '', options = ['Solid', 'Dashed', 'Dotted'], group = grpVisuals, inline = 'bearcisd', tooltip = 'Line style for confirmed bearish CISD levels.', active = showBearCisd)
cisdBearWidth = input.int(1, '', minval = 1, group = grpVisuals, inline = 'bearcisd', tooltip = 'Line width for confirmed bearish CISD levels.', active = showBearCisd)

grpLineSettings = 'Line Extensions'
cisdExtension = input.int(3, 'CISD Extension', minval = 0, maxval = 500, group = grpLineSettings, inline = 'cisdline', tooltip = 'Number of chart bars to extend Early and confirmed CISD lines beyond their confirmation bar.')
cisdLabelOffset = input.int(0, 'CISD Label Offset', minval = 0, maxval = 250, group = grpLineSettings, inline = 'cisdlabel', tooltip = 'Additional chart-bar offset between the end of a CISD line and its label.')
projectionExtension = input.int(3, 'Projection Extension', minval = 0, maxval = 500, group = grpLineSettings, inline = 'projline', tooltip = 'Number of chart bars to extend deviation projection lines beyond their confirmation bar.')
projectionLabelOffset = input.int(0, 'Projection Label Offset', minval = 0, maxval = 250, group = grpLineSettings, inline = 'projlabel', tooltip = 'Additional chart-bar offset between the end of a projection line and its deviation label.')

showEQ  = input.bool(true, 'Candle Equilibrium', group = grpVisuals, inline = 'eq', tooltip = 'Show the 50% equilibrium level of each higher-timeframe candle and the T-Spot reference dash.')
eqColor = input.color(color.new(#000000, 0), '', group = grpVisuals, inline = 'eq', tooltip = 'Color of equilibrium and T-Spot reference lines.')
eqStyle = input.string('Dotted', '', options = ['Solid', 'Dashed', 'Dotted'], group = grpVisuals, inline = 'eq', tooltip = 'Line style of equilibrium and T-Spot reference lines.')
eqWidth = input.int(1, '', minval = 1, group = grpVisuals, inline = 'eq', tooltip = 'Line width of equilibrium and T-Spot reference lines.')

showTSpot      = input.bool(true, 'T-Spot Box', group = grpVisuals, inline = 'tspot', tooltip = 'Show the bullish or bearish T-Spot zone between the candle open and the prior higher-timeframe equilibrium.')
tSpotBullColor = input.color(color.new(color.green, 80), '', group = grpVisuals, inline = 'tspot', tooltip = 'Fill color for bullish T-Spot zones.')
tSpotBearColor = input.color(color.new(color.gray, 80), '', group = grpVisuals, inline = 'tspot', tooltip = 'Fill color for bearish T-Spot zones.')

grpStdDev   = 'Deviations'
showStdDev  = input.bool(false, 'Enable Projections?', group = grpStdDev, inline = 'stdb', tooltip = 'Show deviation projection levels after a CISD confirmation.')
stdDevInput = input.string('-1,-2,-3', '', group = grpStdDev, inline = 'stdb', tooltip = 'Comma-separated deviation multipliers, for example -1,-2,-3. Invalid entries are ignored.', active = showStdDev)
stdDevCalc  = input.string('Wick', 'Method', options = ['Wick', 'Body'], group = grpStdDev, inline = 'stdb', tooltip = 'Choose whether deviation range endpoints use candle wicks or candle bodies.', active = showStdDev)
stdDevColor = input.color(color.new(#000000, 0), '', group = grpStdDev, inline = 'stdc', tooltip = 'Color of deviation projection levels and labels.', active = showStdDev)
stdDevStyle = input.string('Solid', '', options = ['Solid', 'Dashed', 'Dotted'], group = grpStdDev, inline = 'stdc', tooltip = 'Line style for deviation projection levels.', active = showStdDev)
stdDevWidth = input.int(1, '', minval = 1, group = grpStdDev, inline = 'stdc', tooltip = 'Line width for deviation projection levels.', active = showStdDev)

grpDash  = 'Dashboard'
boolTable = input.bool(true, 'Show Dashboard', group = grpDash, tooltip = 'Show the dashboard with the selected fractal timeframes and current model status.')
dashMode = input.string('Full', 'Dashboard Mode', options = ['Live', 'Historical', 'Full'], group = grpDash, tooltip = 'Live shows the setup section only. Historical shows Live plus the historical comparison. Full also includes definitions, methodology, and interpretation.')
dashSize = input.string('Small', 'Dashboard Size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = grpDash, tooltip = 'Controls the text size used by the dashboard.')
tableVert = input.string('Top', '', options = ['Top', 'Middle', 'Bottom'], inline = 'loc', group = grpDash, tooltip = 'Vertical position of the dashboard.')
tableHorz = input.string('Right', '', options = ['Left', 'Center', 'Right'], inline = 'loc', group = grpDash, tooltip = 'Horizontal position of the dashboard.')
dashTextColor = input.color(color.new(#131722, 0), 'Text', group = grpDash, inline = 'color', tooltip = 'Text color used in the dashboard.')
dashBgColor   = input.color(color.new(#ffffff, 0), 'Background', group = grpDash, inline = 'color', tooltip = 'Background color used in the dashboard.')
dashShowStudy = input.bool(true, 'Study Benchmarks', group = grpDash, tooltip = 'Show the supplied 2019-2025 study benchmarks beside the live, script-calculated historical results.')
dashShowLive = input.bool(true, 'Live Setup', group = grpDash, tooltip = 'Show the active setup, reclaim strength, rejection wick, CISD state, and live phase information.')

//#endregion

//#region [CONSTANTS AND STATE]

requireCisdToShow = true
candleSpacing = 3
noColor       = color.new(#000000, 100)

// --- Study benchmark indexes ---
STUDY_BASE_RATE       = 0
STUDY_CISD_RATE       = 1
STUDY_CISD_C4_RATE    = 2
STUDY_NO_CISD_C4_RATE = 3

// --- Runtime statistic indexes ---
STAT_TOTAL             = 0
STAT_C4_INTACT         = 1
STAT_FAIL_PRE_C4       = 2
STAT_FAIL_AFTER_C4     = 3
STAT_CISD              = 4
STAT_CISD_C4_INTACT    = 5
STAT_CISD_FAIL_PRE_C4  = 6
STAT_CISD_FAIL_AFTER_C4 = 7
STAT_NO_CISD_C4_INTACT = 8

var array<int> modelStats = array.new_int(9, 0)

type HtfCandle
    float o
    float h
    float l
    float c
    int   hBar
    int   lBar
    box   body
    line  wickUp
    line  wickDown
    line  eqLine
    int   midX
    line  sweepLine   = na
    label sweepLabel  = na
    bool  triggerBuy  = false
    bool  triggerSell = false

type PeriodState
    float prevOpen        = na
    float prevHigh        = na
    float prevLow         = na
    float prevClose       = na
    int   prevHighBar     = na
    int   prevLowBar      = na
    float prevPrevOpen    = na
    float prevPrevHigh    = na
    float prevPrevLow     = na
    float prevPrevClose   = na
    int   prevPrevHighBar = na
    int   prevPrevLowBar  = na
    bool  prevC2Buy       = false
    bool  prevC2Sell      = false

type StdDevData
    array<line>  lines
    array<label> labels

type C2Setup
    bool  isBull
    float extreme
    int   phase     = 1
    bool  dead      = false
    label c2Lbl     = na
    box   c3Box     = na
    line  c3Dash    = na
    float cisdLevel     = na
    int   cisdIndex     = na
    bool  cisdConfirmed = false
    line  cisdLine      = na
    label cisdLabel     = na
    StdDevData stdDevData = na
    box   c4Box     = na
    line  c4Dash    = na
    label c4Lbl     = na
    float c4Top     = na
    float c4Bottom  = na
    bool  c4Invalid = false
    // --- study measurements / outcome bookkeeping ---
    float reclaimStrength = na
    float rejectionWick   = na
    int   createdBar      = na
    bool  statsFinalized  = false
    // --- gating / deferred-draw bookkeeping ---
    bool  revealed          = false   // true once C2/C3/(C4) have actually been drawn
    int   c2Bar             = na
    float c2Price           = na
    float sweepFromPrice    = na
    int   sweepFromBar      = na
    int   c3StartBar        = na
    int   c4StartBar        = na
    float c3Top             = na
    float c3Bottom          = na
    bool  cisdConfirmedInC4 = false   // true if CISD confirmed while already in phase 2 (C4)

type SetupRecord
    C2Setup setup
    int     creationBar

type EarlyCisdRecord
    line  ln
    label lbl
    int   barIndex

var array<HtfCandle>        htfCandles           = array.new<HtfCandle>()
var array<line>             vLines               = array.new<line>()
var array<line>             hLines               = array.new<line>()
var array<line>             lLines               = array.new<line>()
var PeriodState              state                = PeriodState.new()
var C2Setup                  buySetup             = na
var C2Setup                  sellSetup            = na
var array<SetupRecord>       setupRecords         = array.new<SetupRecord>()
var array<EarlyCisdRecord>   bullEarlyCisdRecords = array.new<EarlyCisdRecord>()
var array<EarlyCisdRecord>   bearEarlyCisdRecords = array.new<EarlyCisdRecord>()
var array<line>              ltfSweepLines        = array.new<line>()
var array<label>             ltfSweepLabels       = array.new<label>()
var int                      htfOpenBar           = na
var line                     htfOpenLn            = na

allowBuy  = biasFilter != 'Bearish'
allowSell = biasFilter != 'Bullish'

//#endregion

//#region [FUNCTIONS]

tfLabel(string tf) =>
    switch tf
        '30S' => '30s'
        '1'   => '1m'
        '3'   => '3m'
        '5'   => '5m'
        '15'  => '15m'
        '60'  => '1h'
        '240' => '4h'
        '1D'  => '1D'
        'D'   => '1D'
        '1W'  => '1W'
        'W'   => '1W'
        '1M'  => '1M'
        'M'   => '1M'
        =>       tf + 'm'

tfMins(string tf) =>
    switch tf
        '1D' => 1440
        'D'  => 1440
        '1W' => 10080
        'W'  => 10080
        '1M' => 43200
        'M'  => 43200
        =>      int(str.tonumber(tf))

curTfCode() =>
    timeframe.isdaily ? '1D' : timeframe.isweekly ? '1W' : timeframe.ismonthly ? '1M' : timeframe.period

tablePosition(string vert, string horz) =>
    switch vert + '-' + horz
        'Top-Left'      => position.top_left
        'Top-Center'    => position.top_center
        'Top-Right'     => position.top_right
        'Middle-Left'   => position.middle_left
        'Middle-Center' => position.middle_center
        'Middle-Right'  => position.middle_right
        'Bottom-Left'   => position.bottom_left
        'Bottom-Center' => position.bottom_center
        'Bottom-Right'  => position.bottom_right
        =>                 position.top_right

lineStyleFromStr(string s) =>
    switch s
        'Solid'  => line.style_solid
        'Dashed' => line.style_dashed
        'Dotted' => line.style_dotted
        =>          line.style_dashed

futureBar(int baseBar, int offset) =>
    math.min(baseBar + offset, bar_index + 500)

textSize(string s) =>
    switch s
        'Tiny'   => size.tiny
        'Small'  => size.small
        'Normal' => size.normal
        'Large'  => size.large
        =>          size.huge

dashTextSize() =>
    switch dashSize
        'Tiny'   => size.tiny
        'Small'  => size.small
        'Normal' => size.normal
        =>          size.large

directionalLabel(int xBar, float yPrice, string txt, bool bullish) =>
    label.new(xBar, yPrice, text = txt, xloc = xloc.bar_index, yloc = yloc.price, style = bullish ? label.style_label_up : label.style_label_down, color = na, textcolor = color.gray, size = textSize(labelSize), text_font_family = font.family_monospace)

eqLineColor() => showEQ ? eqColor : noColor

drawSweepLine(bool isBull, int fromBar, float fromPrice, int confirmBar) =>
    line ln = na
    if showLtfSweeps
        sweepLineColor = isBull ? sweepLowColor : sweepHighColor
        sweepEndBar = futureBar(confirmBar, sweepExtension)
        ln := line.new(fromBar, fromPrice, sweepEndBar, fromPrice, xloc = xloc.bar_index, color = sweepLineColor, style = lineStyleFromStr(sweepStyle), width = sweepWidth)
        sweepLabel = showSweepLabels ? label.new(futureBar(sweepEndBar, sweepLabelOffset), fromPrice, 's', xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(color.white, 100), textcolor = sweepLineColor, size = textSize(sweepLabelSize), text_font_family = font.family_monospace) : na
        ltfSweepLines.unshift(ln)
        ltfSweepLabels.unshift(sweepLabel)
        while sweepCount > 0 and ltfSweepLines.size() > sweepCount
            line.delete(ltfSweepLines.pop())
            oldLabel = ltfSweepLabels.pop()
            if not na(oldLabel)
                label.delete(oldLabel)
    ln

newLHLine(float price) =>
    line.new(bar_index, price, bar_index, price, xloc.bar_index, extend.none, lhColor, lineStyleFromStr(lhStyle), lhWidth)

updateLHLine(line ln, float price) =>
    line.set_xy1(ln, line.get_x1(ln), price)
    line.set_xy2(ln, bar_index, price)
    line.set_color(ln, lhColor)
    line.set_style(ln, lineStyleFromStr(lhStyle))
    line.set_width(ln, lhWidth)

autoHTF() =>
    switch timeframe.in_seconds()
        30   => '15'
        60   => '15'
        120  => '15'
        180  => '15'
        300  => '60'
        900  => '240'
        =>      '1M'

autoLtf() =>
    switch timeframe.in_seconds()
        30   => '3'
        60   => '3'
        120  => '3'
        180  => '3'
        300  => '5'
        900  => '15'
        =>      curTfCode()

ltfCode() =>
    switch modelType
        '3m-15m' => '3'
        '1m-15m' => '1'
        '3m-30m' => '3'
        '5m-1H'  => '5'
        '15m-4H' => '15'
        '1H-1D'  => '60'
        '4H-1W'  => '240'
        '1D-1W'  => '1D'
        'Custom' => customLTF
        'Auto'   => autoLtf()
        =>          curTfCode()

isAutoValidTf(int seconds) => seconds == 30 or seconds == 60 or seconds == 120 or seconds == 180 or seconds == 300 or seconds == 900

studyBenchmark(string pair, int metric) =>
    switch pair
        '3m-15m' => metric == STUDY_BASE_RATE ? 65.2 : metric == STUDY_CISD_RATE ? 60.0 : metric == STUDY_CISD_C4_RATE ? 90.0 : metric == STUDY_NO_CISD_C4_RATE ? 28.0 : na
        '1m-15m' => metric == STUDY_BASE_RATE ? 65.2 : metric == STUDY_CISD_RATE ? 77.0 : metric == STUDY_CISD_C4_RATE ? 80.0 : metric == STUDY_NO_CISD_C4_RATE ? 14.0 : na
        '5m-1H'  => metric == STUDY_BASE_RATE ? 65.1 : metric == STUDY_CISD_RATE ? 73.0 : metric == STUDY_CISD_C4_RATE ? 82.0 : metric == STUDY_NO_CISD_C4_RATE ? 20.0 : na
        '15m-4H' => metric == STUDY_BASE_RATE ? 64.8 : na
        =>          na

studyReclaimRate(string pair, float strength) =>
    float result = na
    if not na(strength)
        result := switch pair
            '3m-15m' => strength <= 10 ? 43.0 : strength <= 25 ? 53.0 : strength <= 50 ? 66.0 : strength <= 75 ? 77.0 : strength <= 100 ? 83.0 : 90.0
            '1m-15m' => strength <= 10 ? 43.0 : strength <= 25 ? 53.0 : strength <= 50 ? 66.0 : strength <= 75 ? 77.0 : strength <= 100 ? 83.0 : 90.0
            '5m-1H'  => strength <= 10 ? 43.0 : strength <= 25 ? 53.0 : strength <= 50 ? 67.0 : strength <= 75 ? 77.0 : strength <= 100 ? 81.0 : 86.0
            '15m-4H' => strength <= 10 ? 46.0 : strength <= 25 ? 56.0 : strength <= 50 ? 60.0 : strength <= 75 ? 69.0 : strength <= 100 ? 72.0 : 85.0
            =>          na
    result

statCount(int index) =>
    array.get(modelStats, index)

statPct(int numerator, int denominator) =>
    denominator > 0 ? 100.0 * numerator / denominator : na

pctText(float value) =>
    na(value) ? 'n/a' : str.tostring(value, '0.0') + '%'

intText(int value) =>
    str.tostring(value)

method delete(HtfCandle c) =>
    box.delete(c.body)
    line.delete(c.wickUp)
    line.delete(c.wickDown)
    line.delete(c.eqLine)
    line.delete(c.sweepLine)
    label.delete(c.sweepLabel)

method update(HtfCandle c, float curH, float curL, float curC, int curBar) =>
    if curH > c.h
        c.h    := curH
        c.hBar := curBar
    if curL < c.l
        c.l    := curL
        c.lBar := curBar
    c.c := curC
    c

method draw(HtfCandle c, int leftBar) =>
    bool  isBull = c.c >= c.o
    int   midX   = leftBar + 1
    float eq     = (c.h + c.l) / 2
    box.set_left(c.body, leftBar)
    box.set_right(c.body, leftBar + 2)
    box.set_top(c.body, math.max(c.o, c.c))
    box.set_bottom(c.body, math.min(c.o, c.c))
    box.set_bgcolor(c.body, isBull ? bullBody : bearBody)
    box.set_border_color(c.body, isBull ? borderBull : borderBear)
    line.set_x1(c.wickUp, midX)
    line.set_x2(c.wickUp, midX)
    line.set_y1(c.wickUp, c.h)
    line.set_y2(c.wickUp, math.max(c.o, c.c))
    line.set_color(c.wickUp, isBull ? wickBull : wickBear)
    line.set_x1(c.wickDown, midX)
    line.set_x2(c.wickDown, midX)
    line.set_y1(c.wickDown, c.l)
    line.set_y2(c.wickDown, math.min(c.o, c.c))
    line.set_color(c.wickDown, isBull ? wickBull : wickBear)
    line.set_x1(c.eqLine, midX)
    line.set_x2(c.eqLine, midX)
    line.set_y1(c.eqLine, eq)
    line.set_y2(c.eqLine, eq)
    line.set_color(c.eqLine, eqLineColor())
    line.set_style(c.eqLine, lineStyleFromStr(eqStyle))
    line.set_width(c.eqLine, eqWidth)
    c.midX := midX

newHtfCandle() =>
    HtfCandle.new(open, high, low, close, bar_index, bar_index,
         box.new(bar_index, high, bar_index, low, border_color = borderBull, border_width = 1),
         line.new(bar_index, high, bar_index, high, color = wickBull),
         line.new(bar_index, low, bar_index, low, color = wickBull),
         line.new(bar_index, high, bar_index, high, color = noColor),
         na)

drawEarlyCisd(bool isBull, float level, int idx, int confirmBar) =>
    array<EarlyCisdRecord> target = isBull ? bullEarlyCisdRecords : bearEarlyCisdRecords
    if showEarlyCisd
        cisdEndBar = futureBar(confirmBar, cisdExtension)
        ln = line.new(idx, level, cisdEndBar, level, color = earlyCisdColor, style = lineStyleFromStr(earlyCisdStyle), width = earlyCisdWidth)
        label lbl = na
        if showLabels
            lbl := label.new(futureBar(cisdEndBar, cisdLabelOffset), level, isBull ? '+CISD' : '-CISD', xloc = xloc.bar_index, style = label.style_label_left, color = na, textcolor = earlyCisdColor, size = textSize(labelSize), text_font_family = font.family_monospace)
        target.push(EarlyCisdRecord.new(ln, lbl, confirmBar))
    if showAlerts and showEarlyCisdAlerts
        alert((isBull ? 'Bullish' : 'Bearish') + ' Early CISD confirmed on ' + syminfo.ticker, alert.freq_once_per_bar)

pruneEarlyCisd(array<EarlyCisdRecord> recs, int thresholdBar) =>
    if not na(thresholdBar)
        while recs.size() > 0 and recs.first().barIndex < thresholdBar
            evicted = recs.shift()
            line.delete(evicted.ln)
            if not na(evicted.lbl)
                label.delete(evicted.lbl)

consumeLastEarlyCisd(array<EarlyCisdRecord> recs) =>
    if recs.size() > 0
        evicted = recs.pop()
        line.delete(evicted.ln)
        if not na(evicted.lbl)
            label.delete(evicted.lbl)

parseFloats(string src) =>
    var out = array.new<float>()
    array.clear(out)
    for part in str.split(str.replace_all(src, ' ', ''), ',')
        v = str.tonumber(part)
        if not na(v)
            out.push(v)
    out

createStdDevProjections(C2Setup s, int confirmBar) =>
    if showStdDev
        devs = parseFloats(stdDevInput)
        if devs.size() > 0
            off     = bar_index - s.cisdIndex
            useWick = stdDevCalc == 'Wick'

            level0 = s.cisdLevel
            level1 = s.extreme
            if not useWick
                for j = 0 to 50
                    if s.isBull ? low[j] == s.extreme : high[j] == s.extreme
                        level1 := s.isBull ? math.min(open[j], close[j]) : math.max(open[j], close[j])
                        break

            leftBar = s.cisdIndex
            if s.cisdIndex < bar_index
                prevBetter = s.isBull
                     ? (useWick ? high[off + 1] > high[off] : math.max(open[off + 1], close[off + 1]) > math.max(open[off], close[off]))
                     : (useWick ? low[off + 1]  < low[off]  : math.min(open[off + 1], close[off + 1]) < math.min(open[off], close[off]))
                if prevBetter
                    leftBar := s.cisdIndex - 1

            rightBar   = futureBar(confirmBar, projectionExtension)
            labelBar   = futureBar(rightBar, projectionLabelOffset)
            priceRange = s.isBull ? level0 - level1 : level1 - level0
            lns        = array.new<line>()
            lbs        = array.new<label>()

            for dev in devs
                devPrice = s.isBull ? level0 - priceRange * dev : level0 + priceRange * dev
                lns.push(line.new(leftBar, devPrice, rightBar, devPrice, xloc = xloc.bar_index, color = stdDevColor, width = stdDevWidth, style = lineStyleFromStr(stdDevStyle)))
                if showLabels
                    lbs.push(label.new(labelBar, devPrice, str.tostring(dev), xloc = xloc.bar_index, style = label.style_label_left, color = na, textcolor = stdDevColor, size = textSize(labelSize), text_font_family = font.family_monospace))

            s.stdDevData := StdDevData.new(lns, lbs)

confirmCisd(C2Setup s, int confirmBar) =>
    if not s.cisdConfirmed
        s.cisdConfirmed := true
        array.set(modelStats, STAT_CISD, statCount(STAT_CISD) + 1)
    showLine = s.isBull ? showBullCisd : showBearCisd
    clr      = s.isBull ? cisdBullColor : cisdBearColor
    lnStyle  = s.isBull ? cisdBullStyle : cisdBearStyle
    lnWidth  = s.isBull ? cisdBullWidth : cisdBearWidth
    if showLine
        cisdEndBar = futureBar(confirmBar, cisdExtension)
        s.cisdLine := line.new(s.cisdIndex, s.cisdLevel, cisdEndBar, s.cisdLevel, color = clr, style = lineStyleFromStr(lnStyle), width = lnWidth)
        if showLabels
            s.cisdLabel := label.new(futureBar(cisdEndBar, cisdLabelOffset), s.cisdLevel, s.isBull ? '+CISD' : '-CISD', xloc = xloc.bar_index, style = label.style_label_left, color = na, textcolor = clr, size = textSize(labelSize), text_font_family = font.family_monospace)
    createStdDevProjections(s, confirmBar)

recordSetupOutcome(C2Setup s, int outcome) =>
    if not s.statsFinalized
        if outcome == 1
            array.set(modelStats, STAT_C4_INTACT, statCount(STAT_C4_INTACT) + 1)
        else if outcome == 2
            array.set(modelStats, STAT_FAIL_PRE_C4, statCount(STAT_FAIL_PRE_C4) + 1)
        else
            array.set(modelStats, STAT_FAIL_AFTER_C4, statCount(STAT_FAIL_AFTER_C4) + 1)
        if s.cisdConfirmed
            if outcome == 1
                array.set(modelStats, STAT_CISD_C4_INTACT, statCount(STAT_CISD_C4_INTACT) + 1)
            else if outcome == 2
                array.set(modelStats, STAT_CISD_FAIL_PRE_C4, statCount(STAT_CISD_FAIL_PRE_C4) + 1)
            else
                array.set(modelStats, STAT_CISD_FAIL_AFTER_C4, statCount(STAT_CISD_FAIL_AFTER_C4) + 1)
        else if outcome == 1
            array.set(modelStats, STAT_NO_CISD_C4_INTACT, statCount(STAT_NO_CISD_C4_INTACT) + 1)
        s.statsFinalized := true

deleteSetupVisuals(C2Setup s) =>
    if not na(s)
        if not na(s.c2Lbl)
            label.delete(s.c2Lbl)
        if not na(s.cisdLine)
            line.delete(s.cisdLine)
        if not na(s.cisdLabel)
            label.delete(s.cisdLabel)
        if not na(s.c3Box)
            box.delete(s.c3Box)
        if not na(s.c3Dash)
            line.delete(s.c3Dash)
        if not na(s.c4Box)
            box.delete(s.c4Box)
        if not na(s.c4Dash)
            line.delete(s.c4Dash)
        if not na(s.c4Lbl)
            label.delete(s.c4Lbl)
        if not na(s.stdDevData)
            if not na(s.stdDevData.lines)
                for ln in s.stdDevData.lines
                    line.delete(ln)
            if not na(s.stdDevData.labels)
                for lb in s.stdDevData.labels
                    label.delete(lb)

registerRecord(C2Setup s) =>
    setupRecords.push(SetupRecord.new(s, bar_index))
    while showHistory > 0 and setupRecords.size() > showHistory
        evicted = setupRecords.shift()
        deleteSetupVisuals(evicted.setup)
    earliestVisibleBar = setupRecords.size() > 0 ? setupRecords.first().creationBar : na
    pruneEarlyCisd(bullEarlyCisdRecords, earliestVisibleBar)
    pruneEarlyCisd(bearEarlyCisdRecords, earliestVisibleBar)

autoTf = switch modelType
    '3m-15m' => '15'
    '1m-15m' => '15'
    '3m-30m' => '30'
    '5m-1H'  => '60'
    '15m-4H' => '240'
    '1H-1D'  => '1D'
    '4H-1W'  => '1W'
    '1D-1W'  => '1W'
    'Custom' => customHTF
    =>          autoHTF()

validTf = modelType == 'Auto' ? isAutoValidTf(timeframe.in_seconds()) : tfMins(curTfCode()) <= tfMins(ltfCode())

[currentO, currentH, currentL, currentC, prevH1, prevL1] = request.security(syminfo.tickerid, autoTf, [open[0], high[0], low[0], close[0], high[1], low[1]], lookahead = barmerge.lookahead_on)

c2Buy         = currentL < prevL1 and currentC > prevL1
c2Sell        = currentH > prevH1 and currentC < prevH1
periodChanged = time(autoTf) != time(autoTf)[1]

// Computes the C3/C4 "T-Spot" top/bottom for the CURRENT bar (always runs,
// regardless of whether the setup is currently being drawn on the chart).
computeTopBot() =>
    mid = (state.prevHigh + state.prevLow) / 2
    top = math.max(open, mid)
    bot = math.min(open, mid)
    [top, bot]

// Actually draws the T-Spot box/dash/(C4 label) using an already-computed
// top/bot and a given left-edge bar (which may be in the past, i.e. a
// "backdated" / retroactive draw once CISD finally confirms).
drawPhaseVisual(bool isBull, bool isC4, int startBar, float top, float bot) =>
    yDash = isBull ? bot : top
    bxCol = isBull ? tSpotBullColor : tSpotBearColor
    box   bx   = showTSpot ? box.new(startBar, top, bar_index, bot, border_color = na, bgcolor = bxCol) : na
    line  dash = showEQ ? line.new(startBar, yDash, bar_index, yDash, color = eqColor, width = eqWidth, style = lineStyleFromStr(eqStyle)) : na
    label lbl  = na
    if isC4 and showTSpot and showLabels and validTf
        lbl := directionalLabel(bar_index + 2, isBull ? bot : top, 'C4', isBull)
    [bx, dash, lbl]

// Draws everything that has accumulated so far for a setup (C2 label, C3
// box/dash backdated to when C3 actually started, and — if already in C4 —
// the C4 box/dash/label backdated to when C4 actually started). Called the
// moment CISD confirms. No-ops if already revealed, or if the gate is off
// (in which case reveal happens immediately at C2, same as legacy behavior).
method reveal(C2Setup s) =>
    if not s.revealed
        s.revealed := true
        if validTf and showLabels and not na(s.c2Bar)
            s.c2Lbl := directionalLabel(s.c2Bar, s.c2Price, 'C2', s.isBull)
        if not na(s.sweepFromBar)
            drawSweepLine(s.isBull, s.sweepFromBar, s.sweepFromPrice, bar_index)
        [bx, dash, _] = drawPhaseVisual(s.isBull, false, s.c3StartBar, s.c3Top, s.c3Bottom)
        s.c3Box  := bx
        s.c3Dash := dash
        if s.phase == 2 and not na(s.c4StartBar)
            [bx4, dash4, lbl4] = drawPhaseVisual(s.isBull, true, s.c4StartBar, s.c4Top, s.c4Bottom)
            s.c4Box  := bx4
            s.c4Dash := dash4
            s.c4Lbl  := lbl4
    s

newSetup(bool isBull, float extreme, int extremeBar, float extremePrice, float sweepFromPrice, int sweepFromBar, float cisdLevel, int cisdIndex, bool cisdAlreadyConfirmed, int cisdConfirmBar) =>
    s = C2Setup.new(isBull, extreme, 1, false)
    s.c2Bar          := extremeBar
    s.c2Price        := extremePrice
    s.sweepFromPrice := sweepFromPrice
    s.sweepFromBar   := sweepFromBar
    s.createdBar     := bar_index
    s.c3StartBar     := bar_index
    c1Range = state.prevPrevHigh - state.prevPrevLow
    c2Range = state.prevHigh - state.prevLow
    s.reclaimStrength := c1Range > 0 ? (isBull ? (state.prevClose - state.prevPrevLow) / c1Range : (state.prevPrevHigh - state.prevClose) / c1Range) * 100.0 : na
    s.rejectionWick := c2Range > 0 ? (isBull ? (math.min(state.prevOpen, state.prevClose) - state.prevLow) / c2Range : (state.prevHigh - math.max(state.prevOpen, state.prevClose)) / c2Range) * 100.0 : na
    array.set(modelStats, STAT_TOTAL, statCount(STAT_TOTAL) + 1)
    [top, bot] = computeTopBot()
    s.c3Top      := top
    s.c3Bottom   := bot
    s.cisdLevel  := cisdLevel
    s.cisdIndex  := cisdIndex
    cisdReady = cisdAlreadyConfirmed and not na(cisdLevel) and not na(cisdIndex) and not na(cisdConfirmBar)
    if not requireCisdToShow
        // legacy behavior: always visible immediately
        s.reveal()
    if cisdReady
        if requireCisdToShow
            s.reveal()
        confirmCisd(s, cisdConfirmBar)
    registerRecord(s)
    s

method advanceToC4(C2Setup s) =>
    if not na(s.c3Box)
        box.set_right(s.c3Box, bar_index)
        line.set_x2(s.c3Dash, bar_index)
    s.c4StartBar := bar_index
    [top, bot] = computeTopBot()
    s.c4Top    := top
    s.c4Bottom := bot
    if s.revealed
        [bx, dash, lbl] = drawPhaseVisual(s.isBull, true, s.c4StartBar, top, bot)
        s.c4Box  := bx
        s.c4Dash := dash
        s.c4Lbl  := lbl
    s.phase     := 2
    s.c4Invalid := false
    s

method finish(C2Setup s) =>
    if not na(s.c4Box)
        box.set_right(s.c4Box, bar_index)
        line.set_x2(s.c4Dash, bar_index)
    recordSetupOutcome(s, 1)
    s.phase := 0
    s

method deleteStdDev(C2Setup s) =>
    if not na(s.stdDevData)
        if not na(s.stdDevData.lines)
            for ln in s.stdDevData.lines
                line.delete(ln)
        if not na(s.stdDevData.labels)
            for lb in s.stdDevData.labels
                label.delete(lb)
        s.stdDevData := na
    s

method extendAndCheck(C2Setup s) =>
    if not na(s) and not s.dead and s.phase != 0
        box  extBox  = s.phase == 1 ? s.c3Box : s.c4Box
        line extDash = s.phase == 1 ? s.c3Dash : s.c4Dash
        if not na(extBox)
            box.set_right(extBox, bar_index)
            line.set_x2(extDash, bar_index)

        c2Breach = s.isBull ? low < s.extreme : high > s.extreme
        if c2Breach
            recordSetupOutcome(s, s.phase == 2 ? 3 : 2)
            if not na(s.c2Lbl)
                label.set_text(s.c2Lbl, 'XC2')
                label.set_textcolor(s.c2Lbl, s.phase == 2 ? color.orange : color.red)
            if not na(s.c3Box)
                box.delete(s.c3Box)
                s.c3Box := na
            if not na(s.c3Dash)
                line.delete(s.c3Dash)
                s.c3Dash := na
            if not na(s.c4Box)
                box.delete(s.c4Box)
                s.c4Box := na
            if not na(s.c4Dash)
                line.delete(s.c4Dash)
                s.c4Dash := na
            if not na(s.c4Lbl)
                label.delete(s.c4Lbl)
                s.c4Lbl := na
            s.deleteStdDev()
            s.dead  := true
            s.phase := 0
    s

// If CISD only ever confirmed while in C4 (i.e. it was never valid back in
// C2/C3), and C4 subsequently gets invalidated, the whole setup — including
// the CISD confirmation itself — is discarded retroactively.
method checkC4Invalid(C2Setup s) =>
    if not na(s) and not s.dead and s.phase == 2 and not s.c4Invalid
        invalid = s.isBull ? close[1] < s.c4Bottom : close[1] > s.c4Top
        if invalid
            s.c4Invalid := true
            if requireCisdToShow and s.cisdConfirmedInC4
                deleteSetupVisuals(s)
                s.c2Lbl      := na
                s.c3Box      := na
                s.c3Dash     := na
                s.c4Box      := na
                s.c4Dash     := na
                s.c4Lbl      := na
                s.cisdLine   := na
                s.cisdLabel  := na
                s.stdDevData := na
                s.cisdConfirmed := false
                s.dead  := true
                s.phase := 0
            else
                if not na(s.c4Lbl)
                    label.set_text(s.c4Lbl, 'XC4')
                    label.set_textcolor(s.c4Lbl, color.red)
                if not na(s.c4Dash)
                    line.set_color(s.c4Dash, color.red)
                if not na(s.c4Box)
                    box.delete(s.c4Box)
                    s.c4Box := na
    s

method checkCisdConfirm(C2Setup s) =>
    if not na(s) and not s.dead and not s.cisdConfirmed and s.phase != 0 and not na(s.cisdLevel) and not na(s.cisdIndex)
        confirmed = s.isBull ? close > s.cisdLevel : close < s.cisdLevel
        if confirmed
            if s.phase == 2
                s.cisdConfirmedInC4 := true
            if requireCisdToShow
                s.reveal()
            confirmCisd(s, bar_index)
    s

processC2(bool trigger, bool allow, bool isBull, float extremePrice, int extremeBar, float sweepFromPrice, int sweepFromBar, float cisdLevel, int cisdIndex, bool cisdAlreadyConfirmed, int cisdConfirmBar, C2Setup existing) =>
    C2Setup result = existing
    if trigger and allow
        if not na(existing) and not existing.dead and existing.phase == 2
            recordSetupOutcome(existing, 1)
        result := newSetup(isBull, extremePrice, extremeBar, extremePrice, sweepFromPrice, sweepFromBar, cisdLevel, cisdIndex, cisdAlreadyConfirmed, cisdConfirmBar)
    else if periodChanged and not na(existing) and not existing.dead
        result := existing.phase == 1 ? existing.advanceToC4() : existing.phase == 2 ? existing.finish() : existing
    result

markTrigger(bool trigger, bool allow, int idx, bool isBuy) =>
    if trigger and allow and htfCandles.size() > idx
        c = htfCandles.get(idx)
        if isBuy
            c.triggerBuy := true
        else
            c.triggerSell := true

//#endregion

//#region [LOGIC]

var float o0 = open
var float h0 = high
var float l0 = low
var float o1 = open
var float h1 = high
var float l1 = low

if periodChanged
    o1 := o0[1]
    h1 := h0[1]
    l1 := l0[1]
    o0 := open
    h0 := high
    l0 := low

if high >= h0
    h0 := high
if low <= l0
    l0 := low

bool up = close > open
bool dw = close < open
bool eq = close == open

var float bullLevelFixed = na
var int   bullIndexFixed = na
var float bearLevelFixed = na
var int   bearIndexFixed = na

if low == l0 and low < l1
    if (dw[0] or eq[0]) and (up[1] or eq[1]) and not (eq[0] and eq[1])
        bullLevelFixed := open
        bullIndexFixed := bar_index
    else
        for i = 2 to 10
            if low[i] < low
                break
            if (up[i] or eq[i]) and dw[i - 1]
                b = i - 1
                bullLevelFixed := open[b]
                bullIndexFixed := bar_index - b
                for j = b to 0
                    if open[j] > bullLevelFixed and dw[j]
                        bullLevelFixed := open[j]
                        bullIndexFixed := bar_index - j
                if bullLevelFixed < open
                    bullLevelFixed := close > open ? high : open
                    bullIndexFixed := bar_index
                break

if high == h0 and high > h1
    if (up[0] or eq[0]) and (dw[1] or eq[1]) and not (eq[0] and eq[1])
        bearLevelFixed := open
        bearIndexFixed := bar_index
    else
        for i = 2 to 10
            if high[i] > high
                break
            if (dw[i] or eq[i]) and up[i - 1]
                yb = i - 1
                bearLevelFixed := open[yb]
                bearIndexFixed := bar_index - yb
                for j = yb to 0
                    if open[j] < bearLevelFixed and up[j]
                        bearLevelFixed := open[j]
                        bearIndexFixed := bar_index - j
                if bearLevelFixed > open
                    bearLevelFixed := close < open ? low : open
                    bearIndexFixed := bar_index
                break

var bool bullReclaimed  = false
var int  bullReclaimBar = na
var bool bearReclaimed  = false
var int  bearReclaimBar = na

bullPeriodSweep = l0 < l1
bearPeriodSweep = h0 > h1

newBullLevel = not na(bullIndexFixed) and (na(bullIndexFixed[1]) or bullIndexFixed != bullIndexFixed[1])
if newBullLevel
    bullReclaimed  := false
    bullReclaimBar := na
if not na(bullLevelFixed) and not bullReclaimed and close > bullLevelFixed
    bullReclaimed  := true
    bullReclaimBar := bar_index
    if bullPeriodSweep
        drawEarlyCisd(true, bullLevelFixed, bullIndexFixed, bar_index)

newBearLevel = not na(bearIndexFixed) and (na(bearIndexFixed[1]) or bearIndexFixed != bearIndexFixed[1])
if newBearLevel
    bearReclaimed  := false
    bearReclaimBar := na
if not na(bearLevelFixed) and not bearReclaimed and close < bearLevelFixed
    bearReclaimed  := true
    bearReclaimBar := bar_index
    if bearPeriodSweep
        drawEarlyCisd(false, bearLevelFixed, bearIndexFixed, bar_index)

candleOffset = candleOffsetIn + 10

if periodChanged
    if htfCandles.size() > 0
        newest             = htfCandles.first()
        state.prevOpen    := newest.o
        state.prevHigh    := newest.h
        state.prevLow     := newest.l
        state.prevClose   := newest.c
        state.prevHighBar := newest.hBar
        state.prevLowBar  := newest.lBar
    if htfCandles.size() > 1
        prior                  = htfCandles.get(1)
        state.prevPrevOpen    := prior.o
        state.prevPrevHigh    := prior.h
        state.prevPrevLow     := prior.l
        state.prevPrevClose   := prior.c
        state.prevPrevHighBar := prior.hBar
        state.prevPrevLowBar  := prior.lBar
    htfCandles.unshift(newHtfCandle())
    while htfCandles.size() > htfCandleCount
        htfCandles.pop().delete()
    htfOpenBar := bar_index
    if showLH
        if hLines.size() > 0
            line.set_x2(hLines.first(), bar_index)
            line.set_x2(lLines.first(), bar_index)
        hLines.unshift(newLHLine(high))
        lLines.unshift(newLHLine(low))
        while hLines.size() > htfCandleCount
            line.delete(hLines.pop())
        while lLines.size() > htfCandleCount
            line.delete(lLines.pop())
else if htfCandles.size() > 0
    htfCandles.set(0, htfCandles.first().update(high, low, close, bar_index))

if showLH and htfCandles.size() > 0 and hLines.size() > 0
    curCandle = htfCandles.first()
    updateLHLine(hLines.first(), curCandle.h)
    updateLHLine(lLines.first(), curCandle.l)

if periodChanged
    state.prevC2Buy  := c2Buy[1]
    state.prevC2Sell := c2Sell[1]

c2BuyTrigger  = periodChanged and state.prevC2Buy
c2SellTrigger = periodChanged and state.prevC2Sell

if c2BuyTrigger and allowBuy and bullReclaimed[1]
    consumeLastEarlyCisd(bullEarlyCisdRecords)

if c2SellTrigger and allowSell and bearReclaimed[1]
    consumeLastEarlyCisd(bearEarlyCisdRecords)

buySetup  := processC2(c2BuyTrigger, allowBuy, true, state.prevLow, state.prevLowBar, state.prevPrevLow, state.prevPrevLowBar, bullLevelFixed[1], bullIndexFixed[1], bullReclaimed[1], bullReclaimBar[1], buySetup)
sellSetup := processC2(c2SellTrigger, allowSell, false, state.prevHigh, state.prevHighBar, state.prevPrevHigh, state.prevPrevHighBar, bearLevelFixed[1], bearIndexFixed[1], bearReclaimed[1], bearReclaimBar[1], sellSetup)

markTrigger(c2BuyTrigger, allowBuy, 2, true)
markTrigger(c2SellTrigger, allowSell, 2, false)

buySetup  := buySetup.extendAndCheck()
sellSetup := sellSetup.extendAndCheck()

buySetup  := buySetup.checkC4Invalid()
sellSetup := sellSetup.checkC4Invalid()

buySetup  := buySetup.checkCisdConfirm()
sellSetup := sellSetup.checkCisdConfirm()

if showAlerts
    if c2BuyTrigger and allowBuy
        alert('Bullish C2 formed on ' + syminfo.ticker, alert.freq_once_per_bar)
    if c2SellTrigger and allowSell
        alert('Bearish C2 formed on ' + syminfo.ticker, alert.freq_once_per_bar)

if showVlines and periodChanged
    vLines.unshift(line.new(bar_index, low - ta.tr, bar_index, high + ta.tr, xloc.bar_index, extend.both, lineColor, lineStyleFromStr(lineStyle), lineWidth))
    while vLines.size() > htfCandleCount
        line.delete(vLines.pop())

//#endregion

//#region [PLOT]

if (barstate.islast or barstate.isrealtime) and validTf and htfCandles.size() > 0 and not hideHtf
    n = htfCandles.size()
    for i = n - 1 to 0
        htfCandles.get(i).draw(bar_index + candleOffset + candleSpacing * (n - 1 - i))
    if showHtfOpen and not na(htfOpenBar)
        curOpenX2 = box.get_right(htfCandles.first().body)
        if na(htfOpenLn)
            htfOpenLn := line.new(htfOpenBar, currentO, curOpenX2, currentO, xloc.bar_index, extend.none, htfOpenColor, lineStyleFromStr(htfOpenStyle), htfOpenWidth)
        else
            line.set_xy1(htfOpenLn, htfOpenBar, currentO)
            line.set_xy2(htfOpenLn, curOpenX2, currentO)
            line.set_color(htfOpenLn, htfOpenColor)
            line.set_style(htfOpenLn, lineStyleFromStr(htfOpenStyle))
            line.set_width(htfOpenLn, htfOpenWidth)
    int htfSweepShown = 0
    for i = 0 to n - 1
        c = htfCandles.get(i)
        if i > 0
            nextC = htfCandles.get(i - 1)
            line.set_x2(c.eqLine, nextC.midX)
        if showHtfSweeps and (c.triggerBuy or c.triggerSell) and i > 0 and (sweepCount == 0 or htfSweepShown < sweepCount)
            nextC = htfCandles.get(i - 1)
            price = c.triggerBuy ? c.l : c.h
            sweepLineColor = c.triggerBuy ? sweepLowColor : sweepHighColor
            sweepEndBar = futureBar(nextC.midX, sweepExtension)
            if na(c.sweepLine)
                c.sweepLine := line.new(c.midX, price, sweepEndBar, price, color = sweepLineColor, style = lineStyleFromStr(sweepStyle), width = sweepWidth)
            else
                line.set_xy1(c.sweepLine, c.midX, price)
                line.set_xy2(c.sweepLine, sweepEndBar, price)
                line.set_color(c.sweepLine, sweepLineColor)
                line.set_style(c.sweepLine, lineStyleFromStr(sweepStyle))
                line.set_width(c.sweepLine, sweepWidth)
            if showSweepLabels
                sweepLabelBar = futureBar(sweepEndBar, sweepLabelOffset)
                if na(c.sweepLabel)
                    c.sweepLabel := label.new(sweepLabelBar, price, 's', xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(color.white, 100), textcolor = sweepLineColor, size = textSize(sweepLabelSize), text_font_family = font.family_monospace)
                else
                    label.set_xy(c.sweepLabel, sweepLabelBar, price)
                    label.set_text(c.sweepLabel, 's')
                    label.set_color(c.sweepLabel, color.new(color.white, 100))
                    label.set_textcolor(c.sweepLabel, sweepLineColor)
                    label.set_size(c.sweepLabel, textSize(sweepLabelSize))
            else if not na(c.sweepLabel)
                label.delete(c.sweepLabel)
                c.sweepLabel := na
            htfSweepShown += 1

if barstate.islast and boolTable
    var table wm = table.new(tablePosition(tableVert, tableHorz), 4, 18,
         bgcolor      = color.new(#000000, 100),
         border_color = dashTextColor,
         border_width = 1,
         frame_color  = dashTextColor,
         frame_width  = 1)

    ltfDisp = tfLabel(ltfCode())
    htfDisp = tfLabel(autoTf)
    pairDisp = ltfDisp + '-' + htfDisp
    dateStr = str.format_time(time_close, 'dd MMM yyyy HH:mm', syminfo.timezone)

    resolvedCount = statCount(STAT_C4_INTACT) + statCount(STAT_FAIL_PRE_C4) + statCount(STAT_FAIL_AFTER_C4)
    liveCisdResolved = statCount(STAT_CISD_C4_INTACT) + statCount(STAT_CISD_FAIL_PRE_C4) + statCount(STAT_CISD_FAIL_AFTER_C4)
    liveNoCisdResolved = statCount(STAT_NO_CISD_C4_INTACT) + (statCount(STAT_FAIL_PRE_C4) - statCount(STAT_CISD_FAIL_PRE_C4)) + (statCount(STAT_FAIL_AFTER_C4) - statCount(STAT_CISD_FAIL_AFTER_C4))
    observedBase = statPct(statCount(STAT_C4_INTACT), resolvedCount)
    observedCisd = statPct(statCount(STAT_CISD), statCount(STAT_TOTAL))
    observedCisdC4 = statPct(statCount(STAT_CISD_C4_INTACT), liveCisdResolved)
    observedNoCisdC4 = statPct(statCount(STAT_NO_CISD_C4_INTACT), liveNoCisdResolved)

    C2Setup liveSetup = na
    if not na(buySetup) and (buySetup.phase != 0 or not buySetup.statsFinalized)
        liveSetup := buySetup
    if not na(sellSetup) and (sellSetup.phase != 0 or not sellSetup.statsFinalized)
        if na(liveSetup) or sellSetup.createdBar > liveSetup.createdBar
            liveSetup := sellSetup

    string liveDirection = 'None'
    string livePhase = 'No active setup'
    string liveCisdState = 'n/a'
    string liveReclaim = 'n/a'
    string liveWick = 'n/a'
    string liveAge = 'n/a'
    string liveEstimate = 'n/a'
    if not na(liveSetup)
        liveDirection := liveSetup.isBull ? 'Bullish low sweep' : 'Bearish high sweep'
        livePhase := liveSetup.phase == 1 ? 'C3: confirmation window' : liveSetup.phase == 2 ? 'C4: outcome window' : liveSetup.dead ? 'Invalidated' : 'Complete'
        liveCisdState := liveSetup.cisdConfirmed ? 'Confirmed' : na(liveSetup.cisdLevel) ? 'Not available' : 'Waiting'
        liveReclaim := pctText(liveSetup.reclaimStrength)
        liveWick := pctText(liveSetup.rejectionWick)
        liveAge := str.tostring(bar_index - liveSetup.createdBar) + ' chart bars'
        liveEstimate := pctText(studyReclaimRate(pairDisp, liveSetup.reclaimStrength))

    studyBase = studyBenchmark(pairDisp, STUDY_BASE_RATE)
    studyCisd = studyBenchmark(pairDisp, STUDY_CISD_RATE)
    studyCisdC4 = studyBenchmark(pairDisp, STUDY_CISD_C4_RATE)
    studyNoCisdC4 = studyBenchmark(pairDisp, STUDY_NO_CISD_C4_RATE)

    table.cell(wm, 0, 0, 'Fractal Model | Live vs Study', text_color = dashBgColor, bgcolor = dashTextColor, text_size = dashTextSize(), text_halign = text.align_center, text_font_family = font.family_default)
    table.cell(wm, 1, 0, pairDisp, text_color = dashBgColor, bgcolor = dashTextColor, text_size = dashTextSize(), text_halign = text.align_center, text_font_family = font.family_default)
    table.cell(wm, 2, 0, syminfo.ticker, text_color = dashBgColor, bgcolor = dashTextColor, text_size = dashTextSize(), text_halign = text.align_center, text_font_family = font.family_default)
    table.cell(wm, 3, 0, dateStr, text_color = dashBgColor, bgcolor = dashTextColor, text_size = dashTextSize(), text_halign = text.align_center, text_font_family = font.family_default)

    if dashMode != 'Live'
        table.cell(wm, 0, 1, 'Chart / model', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 1, 1, tfLabel(curTfCode()) + ' / ' + pairDisp, text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 2, 1, 'Bias', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 3, 1, biasFilter, text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())

        if not validTf
            table.cell(wm, 0, 2, 'WARNING', text_color = dashBgColor, bgcolor = color.new(#cc0000, 0), text_size = dashTextSize())
            table.cell(wm, 1, 2, 'Use ' + ltfDisp + ' or lower', text_color = dashBgColor, bgcolor = color.new(#cc0000, 0), text_size = dashTextSize())
            table.cell(wm, 2, 2, 'Current', text_color = dashBgColor, bgcolor = color.new(#cc0000, 0), text_size = dashTextSize())
            table.cell(wm, 3, 2, tfLabel(curTfCode()), text_color = dashBgColor, bgcolor = color.new(#cc0000, 0), text_size = dashTextSize())
        else
            table.cell(wm, 0, 2, 'STATUS', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
            table.cell(wm, 1, 2, 'Model active', text_color = color.new(#089981, 0), bgcolor = dashBgColor, text_size = dashTextSize())
            table.cell(wm, 2, 2, 'Detected', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
            table.cell(wm, 3, 2, intText(statCount(STAT_TOTAL)), text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())

    table.cell(wm, 0, 3, dashShowLive ? 'LIVE SETUP' : 'LIVE SETUP (off)', text_color = dashBgColor, bgcolor = color.new(#5b9cf6, 0), text_size = dashTextSize())
    table.cell(wm, 1, 3, dashShowLive ? liveDirection : 'hidden', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
    table.cell(wm, 2, 3, 'Phase', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
    table.cell(wm, 3, 3, dashShowLive ? livePhase : 'hidden', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
    table.cell(wm, 0, 4, 'Reclaim strength', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
    table.cell(wm, 1, 4, dashShowLive ? liveReclaim : 'hidden', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
    table.cell(wm, 2, 4, 'Rejection wick', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
    table.cell(wm, 3, 4, dashShowLive ? liveWick : 'hidden', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
    table.cell(wm, 0, 5, 'CISD', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
    table.cell(wm, 1, 5, dashShowLive ? liveCisdState : 'hidden', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
    table.cell(wm, 2, 5, 'Age / bucket est.', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
    table.cell(wm, 3, 5, dashShowLive ? liveAge + ' / ' + liveEstimate : 'hidden', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())

    baseDiff = na(observedBase) or na(studyBase) ? na : observedBase - studyBase
    cisdDiff = na(observedCisd) or na(studyCisd) ? na : observedCisd - studyCisd
    cisdC4Diff = na(observedCisdC4) or na(studyCisdC4) ? na : observedCisdC4 - studyCisdC4
    noCisdDiff = na(observedNoCisdC4) or na(studyNoCisdC4) ? na : observedNoCisdC4 - studyNoCisdC4

    if dashMode != 'Live'
        table.cell(wm, 0, 6, 'HISTORICAL RESULTS', text_color = dashBgColor, bgcolor = color.new(#5b9cf6, 0), text_size = dashTextSize())
        table.cell(wm, 1, 6, 'Observed', text_color = dashBgColor, bgcolor = color.new(#5b9cf6, 0), text_size = dashTextSize())
        table.cell(wm, 2, 6, 'Study', text_color = dashBgColor, bgcolor = color.new(#5b9cf6, 0), text_size = dashTextSize())
        table.cell(wm, 3, 6, 'Difference', text_color = dashBgColor, bgcolor = color.new(#5b9cf6, 0), text_size = dashTextSize())

        table.cell(wm, 0, 7, 'C4 intact / all resolved', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 1, 7, pctText(observedBase) + '  n=' + intText(resolvedCount), text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 2, 7, dashShowStudy ? pctText(studyBase) : 'hidden', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 3, 7, dashShowStudy ? pctText(baseDiff) + ' pp' : 'hidden', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())

        table.cell(wm, 0, 8, 'CISD confirmation rate', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 1, 8, pctText(observedCisd) + '  n=' + intText(statCount(STAT_TOTAL)), text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 2, 8, dashShowStudy ? pctText(studyCisd) : 'hidden', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 3, 8, dashShowStudy ? pctText(cisdDiff) + ' pp' : 'hidden', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())

        table.cell(wm, 0, 9, 'C4 intact | CISD confirmed', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 1, 9, pctText(observedCisdC4) + '  n=' + intText(liveCisdResolved), text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 2, 9, dashShowStudy ? pctText(studyCisdC4) : 'hidden', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 3, 9, dashShowStudy ? pctText(cisdC4Diff) + ' pp' : 'hidden', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())

        table.cell(wm, 0, 10, 'C4 intact | no CISD', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 1, 10, pctText(observedNoCisdC4) + '  n=' + intText(liveNoCisdResolved), text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 2, 10, dashShowStudy ? pctText(studyNoCisdC4) : 'hidden', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 3, 10, dashShowStudy ? pctText(noCisdDiff) + ' pp' : 'hidden', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())

        table.cell(wm, 0, 11, 'Failure before C4', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 1, 11, pctText(statPct(statCount(STAT_FAIL_PRE_C4), resolvedCount)), text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 2, 11, 'Study: not supplied', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 3, 11, '—', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())

        table.cell(wm, 0, 12, 'Failure after C4', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 1, 12, pctText(statPct(statCount(STAT_FAIL_AFTER_C4), resolvedCount)), text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 2, 12, 'Study: not supplied', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 3, 12, '—', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())

    if dashMode == 'Full'
        table.cell(wm, 0, 13, 'SAMPLE / DATA', text_color = dashBgColor, bgcolor = color.new(#5b9cf6, 0), text_size = dashTextSize())
        table.cell(wm, 1, 13, 'Resolved ' + intText(resolvedCount), text_color = dashBgColor, bgcolor = color.new(#5b9cf6, 0), text_size = dashTextSize())
        table.cell(wm, 2, 13, 'Open ' + intText(statCount(STAT_TOTAL) - resolvedCount), text_color = dashBgColor, bgcolor = color.new(#5b9cf6, 0), text_size = dashTextSize())
        table.cell(wm, 3, 13, 'Bias: ' + biasFilter, text_color = dashBgColor, bgcolor = color.new(#5b9cf6, 0), text_size = dashTextSize())

        table.cell(wm, 0, 14, 'Definitions', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 1, 14, 'C4 intact = no C2-low breach', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 2, 14, 'Reclaim = % of C1 range', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 3, 14, 'Wick = % of C2 range', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())

        table.cell(wm, 0, 15, 'Study source', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 1, 15, 'NQ / ES futures', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 2, 15, '2019-2025', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 3, 15, 'Per-event study, not P&L', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())

        table.cell(wm, 0, 16, 'Interpretation', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 1, 16, 'Stronger reclaim improves odds', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 2, 16, 'Slower LTF = fewer signals', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 3, 16, 'No CISD is a warning', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())

        table.cell(wm, 0, 17, 'Note', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 1, 17, 'Observed figures use loaded chart history', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 2, 17, 'Study values are fixed benchmarks', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())
        table.cell(wm, 3, 17, 'Past results are not guarantees', text_color = dashTextColor, bgcolor = dashBgColor, text_size = dashTextSize())

//#endregion
````
