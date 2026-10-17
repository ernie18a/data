# Simple Moving Average X Risk

- url: https://www.tradingview.com/script/EEKp6H0J-Simple-Moving-Average-X-Risk/
- type: indicator
- pine_id: PUB;79040be7ab884b19b14c65bea94d984f
- version: 1.0

## Description

ZIZO ⬡ Risk SMA
 
The 200-day SMA, painted with the ZIZO risk engine. Trend and valuation in a single line — no second pane required.
 
Hard money. Don't trust. Verify.
 
──────────────────────────────
 
WHAT IT DOES
 
A moving average tells you where the trend is. It says nothing about whether that trend is cheap or expensive. This overlay adds the missing half.
 
It plots a standard SMA (200 by default) directly on your price chart, then colours that line by the same risk model that drives the ZIZO Risk pane. Cold blue means low risk — the baseline is sitting deep in the value band. Hot red means high risk — it's stretched toward the top. You read the trend and its risk in one glance, without opening a separate oscillator.
 
The colour engine is the ZIZO Risk v3.9 engine, verbatim. Same bounds, same colormap, same numbers. If the risk pane says 42, this line paints the 0.4 band. Parity is the whole point — verify it side by side.
 
──────────────────────────────
 
HOW THE RISK IS MEASURED
 
Risk here is a position, not a probability. It answers one question: where does the price sit between a lower bound and an upper bound, measured in log space?
 
• 0 means price is resting on the lower bound.
• 100 means price is pressed against the upper bound.
• 50 means it's halfway between, on a log scale.
 
The bounds are built from the SMA baseline and a time-scaling factor. The factor lets the bands drift as the series ages — a deliberate model assumption that fair-value ranges compress over a long history rather than staying fixed forever. You control that drift with the Decay and Sensitivity inputs. If you reject the assumption, flatten them.
 
Because the metric lives in log space, it behaves the way a log price chart does. That is intentional and consistent across the whole ZIZO suite.
 
──────────────────────────────
 
TWO COLOUR SOURCES
 
The line drawn is always the SMA. What you colour it by is your choice:
 
• Smoothed Risk (default) — the risk of the SMA itself. Calmer. This is the line that matches the smoothed track in the risk pane.
• Relative Risk — the risk of spot price. Jumpier, more reactive. Use it when you want the SMA to carry the live temperature of price rather than its own.
 
The info table shows both readings at once, each on its own colour swatch, so you never have to guess which is which. Table text auto-contrasts — black on bright swatches, white on dark — so it stays legible in every band.
 
──────────────────────────────
 
MULTI-TIMEFRAME
 
Set the risk timeframe to Daily, Weekly, Monthly, or follow the chart. The SMA and its risk are computed on that timeframe and pulled onto your chart, so you can run a true daily-risk SMA while viewing any resolution.
 
──────────────────────────────
 
ALERT
 
One alert: band change. It fires when the coloured line crosses from one risk band into the next — a regime shift of one decile. Quiet when nothing has changed, loud when the temperature moves.
 
──────────────────────────────
 
INPUTS WORTH KNOWING
 
• SMA length and line width.
• Colour source — Smoothed or Relative.
• Risk engine controls — Time offset, Decay, Sensitivity, Baseline control, Upper/Lower bound.
• Lowerbound is dynamic — leave this off (recommended). The lower bound holds steadier that way.
• Timeframe, info table position and size.
 
──────────────────────────────
 
HONEST NOTES
 
This is not a new model. It is the ZIZO Risk engine wearing a different coat. Every value it prints should match the risk pane to the decimal — if it ever doesn't, trust neither until you find out why.
 
The bounds ship calibrated for BTC. Point it at another asset and the numbers become meaningless until you recalibrate. Do the work, or don't trust the colour.
 
Risk is a position between two bounds, not a forecast. A reading of 80 does not mean an 80% chance of anything. It means the baseline is high in its band — nothing more, nothing less.
 
Nothing here is financial advice. It is a lens, not a signal.
 
Hard money. Don't trust. Verify.
 
— PseudoNakamoto21

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════
// Zone in, Zone out ⬡ Risk SMA  ·  PseudoNakamoto21
// 200 SMA coloured by the v3.9 risk engine (parity with ZIZO Risk).
// Hard money. Don't trust. Verify.
// ══════════════════════════════════════════════════════════════════
indicator("Simple Moving Average X Risk", shorttitle="Simple Moving Average X Risk", overlay=true)

// ── INPUTS & ENUMS ───────────────────────────────────────────────────────────
enum TimeFramePeriod
    DAILY
    WEEKLY
    MONTHLY
    CHART

method asString(TimeFramePeriod p) =>
    switch p
        TimeFramePeriod.DAILY   => "D"
        TimeFramePeriod.WEEKLY  => "W"
        TimeFramePeriod.MONTHLY => "M"
        TimeFramePeriod.CHART   => "Chart"

// ── ① Moving Average ─────────────────────────────────────────────────────────
grpMA   = "① Moving Average"
smaLen  = input.int(200, "SMA length", minval=1, group=grpMA)
maWidth = input.int(1,   "Line width", minval=1, maxval=10, group=grpMA)
colourSourceIn = input.string("Smoothed Risk", "Colour source",
     options=["Smoothed Risk","Relative Risk"], group=grpMA,
     tooltip="Smoothed Risk = risk of the SMA itself (matches the smoothed line in the risk pane). Relative Risk = risk of price.")

// ── ② Risk Metric (v3.9 engine — must match PseudoNakamoto21 Risk) ──────────
grpRisk           = "② Risk Metric"
sfTimeOffset      = input.int  (defval = 126,    title = "Time offset",      group = grpRisk, inline = "UI_1", minval = 0, tooltip = "Centering offset for the exponential transformation relative to bar_index")
sfDecay           = input.float(defval = -0.85,  title = "Decay",            group = grpRisk, inline = "UI_2", tooltip = "Exponent multiplier controlling how quickly dynamic bounds change with bar_index")
sfSensitivity     = input.float(defval = 0.006,  title = "Sensitivity",      group = grpRisk, inline = "UI_2", tooltip = "Time-sensitivity of dynamic bound adjustments")
sfBaselineControl = input.float(defval = 1.024,  title = "Baseline control", group = grpRisk, inline = "1",    tooltip = "Additive offset for dynamic bounds — keeps them positive and non-trivial")
upperbound          = input.float(defval = 3.0,  title = "Upper bound",      group = grpRisk, inline = "2",    tooltip = "Headroom multiplier above the SMA baseline")
lowerbound          = input.float(defval = 0.35, title = "Lower bound",      group = grpRisk, inline = "2",    tooltip = "Log-scale compression multiplier below the SMA baseline")
lowerboundIsDynamic = input.bool (defval = false,title = "Lowerbound is dynamic", group = grpRisk, inline = "2", tooltip = "Recommended: false")
timeframeInput      = input.enum (defval = TimeFramePeriod.DAILY, title = "Timeframe", group = grpRisk, inline = "3")

// ── ③ Info Table ─────────────────────────────────────────────────────────────
grpTbl    = "③ Info Table"
showTbl   = input.bool(true, "Show info table", group=grpTbl)
tblPosIn  = input.string("Bottom Left", "Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpTbl)
tblSizeIn = input.string("Small", "Text size",
     options=["Tiny","Small","Normal","Large"], group=grpTbl)

// ── ZIZO palette constants ───────────────────────────────────────────────────
colAccnt = #e6e64c
colSilvr = color.silver
hBG      = #0d0d1a
cBG      = #16213e

// ── VALIDATION & SETUP ───────────────────────────────────────────────────────
var int adjustedOffset = sfTimeOffset
if barstate.isfirst and adjustedOffset > last_bar_index
    adjustedOffset := last_bar_index

string timeframePreference = timeframeInput.asString()
string resolvedTimeframe   = timeframePreference == "Chart" ? "" : timeframePreference

// ── ENGINE (verbatim from PseudoNakamoto21 Risk v3.9) ────────────────────────
riskMetricFrom(float price, float upperBound, float lowerBound) =>
    float logUpperBound = math.log(upperBound)
    float logLowerBound = math.log(lowerBound)
    float logPrice      = math.log(price)
    (logPrice - logLowerBound) / (logUpperBound - logLowerBound)

// Colormap — identical keys, hex codes, and rounding behaviour to the risk pane
var map<string, color> riskMetricColorMap = map.new<string, color>()
if barstate.isfirst
    riskMetricColorMap.put("1.0", #e6392d)
    riskMetricColorMap.put("0.9", #ff6633)
    riskMetricColorMap.put("0.8", #ff9933)
    riskMetricColorMap.put("0.7", #ffcc33)
    riskMetricColorMap.put("0.6", #e6e64c)
    riskMetricColorMap.put("0.5", #a6d96e)
    riskMetricColorMap.put("0.4", #3ed9a6)
    riskMetricColorMap.put("0.3", #2eb8d9)
    riskMetricColorMap.put("0.2", #1e7cc2)
    riskMetricColorMap.put("0.1", #0a4d8c)
    riskMetricColorMap.put("0.0", #0a4d8c)   // guard: source map lacks this key; values rounding to 0.0 would return na

colorForRiskMetric(float metric) =>
    float clampedMetric = math.min(1.0, math.max(0.0, metric))
    string key = str.tostring(clampedMetric, "0.0")
    riskMetricColorMap.get(key)

// Auto-contrast text: black on light swatches, white on dark (luminance rule)
txtOn(color c) =>
    lum = 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
    lum > 140 ? color.black : color.white

// ── LOGIC & CALCS (identical order of operations to the risk pane) ───────────
float assetSMA           = request.security(syminfo.tickerid, resolvedTimeframe, expression = ta.sma(close, smaLen))
float scalingFactor      = math.pow(math.e, sfDecay * ((bar_index - adjustedOffset) * sfSensitivity)) + sfBaselineControl
float smoothedUpperbound = upperbound * assetSMA * scalingFactor
float smoothedLowerbound = lowerbound * assetSMA * (lowerboundIsDynamic ? scalingFactor : 1)

float riskMetric         = riskMetricFrom(close,    smoothedUpperbound, smoothedLowerbound)
float smoothedRiskMetric = riskMetricFrom(assetSMA, smoothedUpperbound, smoothedLowerbound)

float colourMetric = colourSourceIn == "Smoothed Risk" ? smoothedRiskMetric : riskMetric
color barCol       = na(colourMetric) ? color(na) : colorForRiskMetric(colourMetric)

// ── PLOT ─────────────────────────────────────────────────────────────────────
plot(assetSMA, "SMA (risk coloured)", color=barCol, linewidth=maWidth)

// ── INFO TABLE ───────────────────────────────────────────────────────────────
tblPos = tblPosIn == "Top Right"    ? position.top_right    :
     tblPosIn == "Top Left"     ? position.top_left     :
     tblPosIn == "Bottom Right" ? position.bottom_right : position.bottom_left

tblSize = tblSizeIn == "Tiny"   ? size.tiny   :
     tblSizeIn == "Small"  ? size.small  :
     tblSizeIn == "Normal" ? size.normal : size.large

var table t = table.new(tblPos, 2, 5, border_width=1, border_color=color.new(color.gray, 70))

if showTbl and barstate.islast and not na(smoothedRiskMetric)
    swatchS = colorForRiskMetric(smoothedRiskMetric)
    swatchR = colorForRiskMetric(riskMetric)
    table.cell(t, 0, 0, "ZIZO ⬡ RISK SMA", text_color=colAccnt, bgcolor=hBG, text_size=tblSize)
    table.cell(t, 1, 0, "",                                      bgcolor=hBG)
    table.cell(t, 0, 1, "Smoothed Risk",   text_color=colSilvr,  bgcolor=cBG, text_size=tblSize)
    table.cell(t, 1, 1, str.tostring(smoothedRiskMetric * 100, "0.00"), text_color=txtOn(swatchS), bgcolor=swatchS, text_size=tblSize)
    table.cell(t, 0, 2, "Relative Risk",   text_color=colSilvr,  bgcolor=cBG, text_size=tblSize)
    table.cell(t, 1, 2, str.tostring(riskMetric * 100, "0.00"), text_color=txtOn(swatchR), bgcolor=swatchR, text_size=tblSize)
    table.cell(t, 0, 3, "SMA " + str.tostring(smaLen), text_color=colSilvr, bgcolor=cBG, text_size=tblSize)
    table.cell(t, 1, 3, str.tostring(assetSMA, format.mintick), text_color=colSilvr, bgcolor=cBG, text_size=tblSize)
    table.cell(t, 0, 4, "Colour source",   text_color=colSilvr,  bgcolor=cBG, text_size=tblSize)
    table.cell(t, 1, 4, colourSourceIn,    text_color=colSilvr,  bgcolor=cBG, text_size=tblSize)

// ── ALERTS ───────────────────────────────────────────────────────────────────
alertcondition(barCol != barCol[1],
     "ZIZO Risk SMA: band change", "SMA risk colour crossed into a new band.")
````
