# Torque Momentum Oscillator [JOAT]

- url: https://www.tradingview.com/script/t6JwjbJn-Torque-Momentum-Oscillator-JOAT/
- type: indicator
- pine_id: PUB;88a6bffe1d8148c2a71cedab729a4f28
- version: 1.0

## Description

Torque Momentum Oscillator [JOAT]

[b]Introduction[/b]

The Torque Momentum Oscillator is a sub-chart composite momentum engine that synthesizes four independent momentum perspectives into a single normalized 0–100 oscillator. Rather than relying on any one momentum calculation, it blends a stochastic-range oscillator, two RSI variants at different cycle lengths, and a Bollinger Band position reading into a weighted composite score — then colors the histogram on a gradient that instantly communicates whether momentum is building or exhausting.

The philosophy behind TMO is that any single momentum indicator can be fooled by choppy markets or unusual price action. When four different momentum frameworks all agree, the composite reading carries genuine conviction. When they diverge, the composite score gravitates toward the midline — a built-in disagreement signal that keeps you from over-committing to a directional bias.

[image]https://www.tradingview.com/x/Vqmgf8dD/[/image]

[b]Core Concepts[/b]

[b]Component 1 — RSV (Raw Stochastic Value)[/b]

The RSV is a stochastic-style reading of where close sits within the highest high and lowest low range over the lookback period, smoothed with an SMA to reduce noise:

[pine]
float hiRange = ta.highest(high, rsvPeriod)
float loRange = ta.lowest(low,  rsvPeriod)
float rsvRaw  = safeDiv(close - loRange, hiRange - loRange, 0.5) * 100.0
float rsvLine = ta.sma(rsvRaw, rsvSmooth)
[/pine]

The RSV line is also plotted independently as a fast overlay on the oscillator, giving it a secondary use as a crossover signal generator. When RSV crosses above 20, an [b]Opportunity[/b] label fires. When it crosses back below 80, a [b]Risk[/b] label fires.

[b]Component 2 — RSI Fast[/b]

The standard Wilder RSI at the fast period (default 14) captures short-cycle momentum velocity. It contributes a responsive directional reading without being so short that it becomes noise.

[b]Component 3 — RSI Slow (Blackcat-Style)[/b]

The slow RSI uses a blackcat-inspired manual construction: SMA of gains divided by SMA of absolute changes, rather than the standard Wilder smoothing:

[pine]
float rsiSlowVal = safeDiv(
    nz(ta.sma(math.max(close - prevClose, 0.0), rsiSlow), 50.0),
    nz(ta.sma(math.abs(close - prevClose), rsiSlow), 1.0),
    0.5) * 100.0
[/pine]

This produces a longer-cycle momentum trend bias that is less sensitive to individual candle extremes, creating a smoother counterpart to the fast RSI.

[b]Component 4 — Normalized BB Position[/b]

Bollinger Band position tells you where price sits in its statistical envelope:

[pine]
[bbBasis, bbUpper, bbLower] = ta.bb(close, bbLen, bbMult)
float bbPos = math.max(0.0, math.min(100.0,
    safeDiv(close - bbLower, bbUpper - bbLower, 0.5) * 100.0))
[/pine]

At 100 price is at the upper band. At 0 it is at the lower band. At 50 it is exactly at the basis. This adds a volatility-relative momentum reading to the composite.

[b]Weighted Composite Score[/b]

All four components are blended using user-configurable weights that are automatically normalized to sum to 1.0:

[pine]
float wSum     = wRsv + wRsiF + wRsiS + wBB
float composite = (rsvLine   * (wRsv  / wSum) +
                   rsiFastVal * (wRsiF / wSum) +
                   rsiSlowVal * (wRsiS / wSum) +
                   bbPos      * (wBB   / wSum))
[/pine]

Default weights: RSV 35%, RSI Fast 25%, RSI Slow 25%, BB Position 15%.

[b]Gradient Histogram Coloring[/b]

The histogram is colored on a gradient that transitions from full bear red near 0 to transparent near 50, then from transparent bull green near 50 to full bull green near 100. This produces an immediate visual sense of momentum intensity — a faint histogram near midline means indecision, a saturated histogram near the extremes means conviction.

[b]Features[/b]

[list]
[*] Four-component weighted composite oscillator: RSV + RSI Fast + RSI Slow + BB Position
[*] RSV component double duty: used in composite and plotted as independent fast line
[*] Gradient histogram — color intensity scales with momentum conviction
[*] Overbought (default 75) and oversold (default 25) zones with gradient fills
[*] RSV Opportunity label when RSV crosses above 20 — potential upswing signal
[*] RSV Risk label when RSV crosses below 80 — potential downswing signal
[*] Per-component weight controls — customize the blend to your trading style
[*] Midline reference at 50 and dashed OB/OS lines
[*] Dashboard showing composite, RSV, RSI Fast, RSI Slow, BB position, and last signal
[*] Auto dark/light theme detection
[*] Alerts for Opportunity, Risk, entering Overbought, and entering Oversold
[*] Webhook JSON alert format for automation
[*] Watermark
[/list]

[b]Input Parameters[/b]

[b]Oscillator Settings[/b]
[list]
[*] RSV Period — lookback for the stochastic range calculation (default 20)
[*] RSV Smoothing — SMA length applied to raw RSV before use (default 3)
[*] RSI Fast Period — short-cycle RSI length (default 14)
[*] RSI Slow Period — long-cycle blackcat-style RSI length (default 24)
[*] BB Period — Bollinger Band lookback (default 20)
[*] BB Multiplier — standard deviation multiplier for BB width (default 2.0)
[/list]

[b]Composite Weights[/b]
[list]
[*] RSV Weight — relative weight of the stochastic component (default 0.35)
[*] RSI Fast Weight — relative weight of the fast RSI (default 0.25)
[*] RSI Slow Weight — relative weight of the slow RSI (default 0.25)
[*] BB Position Weight — relative weight of the BB position reading (default 0.15)
[/list]

[b]Visual Settings[/b]
[list]
[*] Overbought Level — upper threshold for OB zone and gradient fill (default 75)
[*] Oversold Level — lower threshold for OS zone and gradient fill (default 25)
[*] Show RSV Signals — toggles Opportunity and Risk label markers
[*] Theme — Auto, Dark, or Light
[*] Show Dashboard — compact panel with live component readings
[*] Dashboard Position — four corner options
[*] Show Watermark
[/list]

[b]Colors[/b]
[list]
[*] Bull / Opportunity — color for bullish histogram bars and signal labels
[*] Bear / Risk — color for bearish histogram bars and signal labels
[*] RSV Line — color for the fast RSV overlay line
[*] RSI Fast — color for the RSI Fast overlay line
[/list]

[b]How to Use[/b]

[list]
[*] Add TMO to your chart below price as a separate sub-pane oscillator.
[*] Watch the composite histogram for directional bias: readings above 50 favor longs, below 50 favor shorts.
[*] Use the [b]OB zone[/b] (above 75) and [b]OS zone[/b] (below 25) as caution areas — not automatic reversal signals, but places where momentum is stretched and a mean reversion or consolidation becomes more likely.
[*] Use [b]Opportunity[/b] labels (RSV crossing above 20) as early warning that the stochastic component is turning up from deeply oversold — look for price confirmation before acting.
[*] Use [b]Risk[/b] labels (RSV crossing below 80) as early warning of a potential momentum rollover from overbought.
[*] Check the dashboard to see exactly which components are driving the composite reading. If RSV and RSI Fast are both high but BB Position is low, the composite may not tell the full story.
[*] Adjust the component weights in settings to emphasize the momentum style that best suits your market. For crypto, increasing RSV weight can be effective. For equities, RSI Slow weight can provide a smoother signal.
[/list]

[b]Indicator Limitations[/b]

[list]
[*] The composite is a weighted average and can only be as accurate as the components that feed it. In strongly trending markets with low volatility, RSV and BB Position can both hover near extremes for extended periods — the composite will look overbought even when trend continuation is the correct read.
[*] RSV Opportunity and Risk signals are generated by a single component (RSV) and should not be used in isolation as trade entries. They are high-probability turning-point flags that require price action confirmation.
[*] Warmup bars are required before the oscillator becomes reliable. The indicator suppresses output until sufficient history is available.
[*] This is a momentum indicator, not a trend direction indicator. It works best in liquid, active markets and may generate false signals during low-volume chop.
[/list]

[b]Originality Statement[/b]

The Torque Momentum Oscillator is an original Pine Script v6 publication. The architecture of combining RSV (stochastic-range), dual RSI cycles at different periodicities, and normalized Bollinger Band position into a single dynamically-weighted composite is an original design. The blackcat-style SMA-based RSI slow construction is an adapted technique included for its distinct noise characteristics, with full attribution. The gradient histogram coloring, RSV crossover signal system, and dashboard layout are original implementations built specifically for this publication.

[b]Disclaimer[/b]

This indicator is for educational and informational purposes only. It does not constitute financial advice. Momentum readings are not predictions of future price direction. Always use proper risk management and never risk more than you can afford to lose.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(
    title            = "Torque Momentum Oscillator [JOAT]",
    shorttitle       = "TMO [JOAT]",
    overlay          = false,
    max_labels_count = 500)

// ─── Groups ───────────────────────────────────────────────────────────────────
G_CORE  = "Oscillator Settings"
G_COMP  = "Composite Weights"
G_VIS   = "Visual Settings"
G_DASH  = "Dashboard"
G_ALERT = "Alerts"
G_COL   = "Colors"

INDICATOR_VERSION = "v1.0.0"

// ─── Inputs ───────────────────────────────────────────────────────────────────
rsvPeriod    = input.int(20,   "RSV Period",          minval=5,  maxval=100, group=G_CORE,
    tooltip="Lookback for RSV: (close - lowest_low) / (highest_high - lowest_low) × 100")
rsvSmooth    = input.int(3,    "RSV Smoothing",       minval=1,  maxval=20,  group=G_CORE)
rsiFast      = input.int(14,   "RSI Fast Period",     minval=2,  maxval=50,  group=G_CORE)
rsiSlow      = input.int(24,   "RSI Slow Period",     minval=10, maxval=100, group=G_CORE)
bbLen        = input.int(20,   "BB Period",           minval=5,  maxval=100, group=G_CORE)
bbMult       = input.float(2.0,"BB Multiplier",       minval=0.5,maxval=4.0, step=0.1, group=G_CORE)
wRsv         = input.float(0.35,"RSV Weight",         minval=0.0,maxval=1.0, step=0.05, group=G_COMP)
wRsiF        = input.float(0.25,"RSI Fast Weight",    minval=0.0,maxval=1.0, step=0.05, group=G_COMP)
wRsiS        = input.float(0.25,"RSI Slow Weight",    minval=0.0,maxval=1.0, step=0.05, group=G_COMP)
wBB          = input.float(0.15,"BB Position Weight", minval=0.0,maxval=1.0, step=0.05, group=G_COMP)
obLevel      = input.float(75.0,"Overbought Level",   minval=60.0,maxval=90.0,step=1.0, group=G_VIS)
osLevel      = input.float(25.0,"Oversold Level",     minval=10.0,maxval=40.0,step=1.0, group=G_VIS)
showSigs     = input.bool(true, "Show RSV Signals",   group=G_VIS,
    tooltip="Signal when RSV crosses above 20 (Opportunity) or below 80 (Risk)")
themeStr     = input.string("Auto","Theme",options=["Auto","Dark","Light"], group=G_VIS)
showDash     = input.bool(true, "Show Dashboard",     group=G_DASH)
dashPosStr   = input.string("Top Right","Position",
    options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=G_DASH)
showWM       = input.bool(true, "Show Watermark",     group=G_VIS)
webhookFmt   = input.bool(false,"Webhook JSON",       group=G_ALERT)
cBull        = input.color(#00C853, "Bull / Opportunity", inline="c1", group=G_COL)
cBear        = input.color(#D50000, "Bear / Risk",        inline="c1", group=G_COL)
cRsv         = input.color(#FFD600, "RSV Line",           inline="c2", group=G_COL)
cRsiF        = input.color(#00BCD4, "RSI Fast",           inline="c2", group=G_COL)

// ─── Theme ────────────────────────────────────────────────────────────────────
isDark  = switch themeStr
    "Dark"  => true
    "Light" => false
    =>         color.r(chart.bg_color) < 128

TXT     = isDark ? #E0E0E0 : #1A1A1A
TXT_M   = isDark ? color.new(#9E9E9E, 0) : color.new(#757575, 0)
TBL_BG  = isDark ? color.new(#0D1117, 5) : color.new(#FFFFFF, 5)
TBL_BD  = isDark ? color.new(#21262D, 0) : color.new(#D0D0D0, 0)
TBL_ALT = isDark ? color.new(#161B22, 0) : color.new(#F6F8FA, 0)
HDR_BG  = color.new(#1565C0, 0)
WM_C    = isDark ? color.new(#FFFFFF, 85) : color.new(#000000, 85)

safeDiv(float n, float d, float fb = 0.0) =>
    d != 0.0 and not na(n) and not na(d) ? n / d : fb

getDashPos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        =>               position.top_right

// ─── Warmup ───────────────────────────────────────────────────────────────────
int  WARMUP = math.max(math.max(rsvPeriod, rsiSlow * 2), math.max(bbLen, 50))
bool warmed = bar_index >= WARMUP

// ─── Core Component Calculations ─────────────────────────────────────────────

// 1. RSV (Raw Stochastic Value) — where is close within the high/low range?
//    Smoothed with SMA to reduce noise. Same concept as the blackcat L2 RSI source.
float hiRange = ta.highest(high, rsvPeriod)
float loRange = ta.lowest( low,  rsvPeriod)
float rsvRaw  = safeDiv(close - loRange, hiRange - loRange, 0.5) * 100.0
float rsvLine = ta.sma(rsvRaw, rsvSmooth)

// 2. RSI Fast — short-cycle momentum velocity
float rsiFastVal = ta.rsi(close, rsiFast)

// 3. RSI Slow — blackcat-style manual RSI using SMA of gains/abs-changes
//    sma(max(close-prev,0), n) / sma(abs(close-prev), n) × 100
float prevClose   = close[1]
float rsiSlowVal  = safeDiv(
    nz(ta.sma(math.max(close - prevClose, 0.0), rsiSlow), 50.0),
    nz(ta.sma(math.abs(close - prevClose), rsiSlow), 1.0),
    0.5) * 100.0

// 4. Normalized BB Position — where is price in the Bollinger envelope?
[bbBasis, bbUpper, bbLower] = ta.bb(close, bbLen, bbMult)
float bbPos = math.max(0.0, math.min(100.0,
    safeDiv(close - bbLower, bbUpper - bbLower, 0.5) * 100.0))

// ─── Weighted Composite Score (0–100) ─────────────────────────────────────────
// Normalize weights to sum to 1.0 regardless of input values
float wSum    = wRsv + wRsiF + wRsiS + wBB
float wSumSafe = math.max(wSum, 1e-6)
float composite = (rsvLine   * safeDiv(wRsv,  wSumSafe) +
                   rsiFastVal * safeDiv(wRsiF, wSumSafe) +
                   rsiSlowVal * safeDiv(wRsiS, wSumSafe) +
                   bbPos      * safeDiv(wBB,   wSumSafe))

// ─── State Classification ─────────────────────────────────────────────────────
bool isOB    = composite >= obLevel
bool isOS    = composite <= osLevel
bool isBull  = composite > 50.0 and not isOB
bool isBear  = composite < 50.0 and not isOS

string stateStr = isOB   ? "Overbought" :
                  isOS   ? "Oversold"   :
                  isBull ? "Bullish"    :
                  isBear ? "Bearish"    : "Neutral"

color stateClr = isOB  ? #FF6F00 :
                 isOS  ? #1565C0 :
                 isBull ? cBull  :
                 isBear ? cBear  : color.gray

// ─── RSV Signal Logic (Opportunity / Risk) ────────────────────────────────────
// Opportunity: RSV line crosses above oversold (20) = potential upswing
// Risk:        RSV line crosses below overbought (80) = potential downswing
bool rsvOpportunity = ta.crossover( rsvLine, 20.0) and warmed and barstate.isconfirmed
bool rsvRisk        = ta.crossunder(rsvLine, 80.0) and warmed and barstate.isconfirmed

// Track last signal
var string lastRsvSig = "—"
var int    rsvBarsSince = 0
rsvBarsSince := rsvBarsSince + 1
if rsvOpportunity
    lastRsvSig   := "Opportunity"
    rsvBarsSince := 0
if rsvRisk
    lastRsvSig   := "Risk"
    rsvBarsSince := 0

// ─── Histogram Color Gradient ─────────────────────────────────────────────────
// Below 50 = gradient toward bear color; above 50 = gradient toward bull color
color histClr = composite < 50.0 ? color.from_gradient(composite, 0.0, 50.0, cBear, color.new(cBear, 70)) : color.from_gradient(composite, 50.0, 100.0, color.new(cBull, 70), cBull)

// ─── Plots ────────────────────────────────────────────────────────────────────
// Composite histogram — the primary read
plot(warmed ? composite  : na, "Composite", color=histClr, style=plot.style_histogram, linewidth=3)

// Reference lines
hline(obLevel, "Overbought", color=color.new(#FF6F00, 40), linestyle=hline.style_dashed)
hline(50.0,    "Midline",    color=color.new(color.gray, 50), linestyle=hline.style_dotted)
hline(osLevel, "Oversold",   color=color.new(#1565C0, 40), linestyle=hline.style_dashed)

// RSV line — fast, responsive stochastic-style reading
plot(warmed ? rsvLine : na,     "RSV",      color=color.new(cRsv,  0), linewidth=1)

// RSI Fast — velocity overlay
plot(warmed ? rsiFastVal : na,  "RSI Fast", color=color.new(cRsiF, 30), linewidth=1)

// Overbought fill (above obLevel)
p_ob_val = plot(warmed ? obLevel : na, "OB Level", color=na, display=display.none)
p_comp   = plot(warmed ? composite : na, "Comp Ref", color=na, display=display.none)
fill(p_ob_val, p_comp, obLevel, 100.0,
    color.new(#FF6F00, 88), color.new(#FF6F00, 70), "Overbought Zone")

// Oversold fill (below osLevel)
p_os_val = plot(warmed ? osLevel : na, "OS Level", color=na, display=display.none)
fill(p_comp, p_os_val, 0.0, osLevel,
    color.new(#1565C0, 70), color.new(#1565C0, 88), "Oversold Zone")

// ─── Signal Labels ────────────────────────────────────────────────────────────
if showSigs and warmed
    if rsvOpportunity
        label.new(bar_index, rsvLine, "OPP",
            style=label.style_label_up, color=cBull, textcolor=#FFFFFF, size=size.small)
    if rsvRisk
        label.new(bar_index, rsvLine, "RISK",
            style=label.style_label_down, color=cBear, textcolor=#FFFFFF, size=size.small)

// ─── Dashboard ────────────────────────────────────────────────────────────────
if showDash and barstate.islast
    var tbl = table.new(getDashPos(dashPosStr), 2, 10, TBL_BG, TBL_BD, 1, TBL_BD, 1)

    table.cell(tbl, 0, 0, "JOAT  |  Torque Momentum",
        text_color=#FFFFFF, bgcolor=HDR_BG, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 0, 1, 0)

    table.cell(tbl, 0, 1, "State",      text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 1, stateStr, text_color=stateClr, text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 2, "Composite",  text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 2, str.tostring(composite, "#.1"),
        text_color=histClr, text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 3, "RSV",        text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 3, str.tostring(rsvLine, "#.1"),
        text_color=rsvLine >= 60 ? cBull : rsvLine <= 40 ? cBear : TXT,
        text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 4, "RSI Fast",   text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 4, str.tostring(rsiFastVal, "#.1"),
        text_color=rsiFastVal >= 60 ? cBull : rsiFastVal <= 40 ? cBear : TXT,
        text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 5, "RSI Slow",   text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 5, str.tostring(rsiSlowVal, "#.1"),
        text_color=rsiSlowVal >= 60 ? cBull : rsiSlowVal <= 40 ? cBear : TXT,
        text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 6, "BB Pos",     text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 6, str.tostring(bbPos, "#.1") + "%",
        text_color=bbPos >= 70 ? cBull : bbPos <= 30 ? cBear : TXT,
        text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 7, "RSV Signal", text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 7, lastRsvSig + (rsvBarsSince > 0 ? " (" + str.tostring(rsvBarsSince) + ")" : ""),
        text_color=lastRsvSig == "Opportunity" ? cBull : lastRsvSig == "Risk" ? cBear : TXT_M,
        text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 8, "Timeframe",  text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 8, timeframe.period, text_color=TXT, text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 9, "Version",    text_color=TXT_M, text_size=size.tiny,  bgcolor=TBL_BG)
    table.cell(tbl, 1, 9, INDICATOR_VERSION, text_color=TXT_M, text_size=size.tiny, bgcolor=TBL_BG)

// ─── Watermark ────────────────────────────────────────────────────────────────
if showWM and barstate.islast
    var wmT = table.new(position.bottom_center, 1, 1,
        bgcolor=color.new(color.black, 100), border_color=color.new(color.black, 100), border_width=0)
    table.cell(wmT, 0, 0, "JackOfAllTrades",
        text_color=WM_C, text_size=size.normal, text_halign=text.align_center,
        bgcolor=color.new(color.black, 100))

// ─── Alerts ───────────────────────────────────────────────────────────────────
string tkr  = syminfo.tickerid
string tf   = timeframe.period
string pxS  = str.tostring(close, format.mintick)
string cmpS = str.tostring(composite, "#.1")

string oppTxt  = "TMO Opportunity | Composite: " + cmpS + " | " + tkr + " | TF: " + tf
string rskTxt  = "TMO Risk Signal | Composite: " + cmpS + " | " + tkr + " | TF: " + tf
string oppJson = '{"event":"opportunity","composite":' + cmpS + ',"ticker":"' + tkr + '","tf":"' + tf + '"}'
string rskJson = '{"event":"risk","composite":' + cmpS + ',"ticker":"' + tkr + '","tf":"' + tf + '"}'

if rsvOpportunity
    alert(webhookFmt ? oppJson : oppTxt, alert.freq_once_per_bar_close)
if rsvRisk
    alert(webhookFmt ? rskJson : rskTxt, alert.freq_once_per_bar_close)

alertcondition(rsvOpportunity, "TMO Opportunity",  "Torque: RSV crossed above oversold — opportunity signal")
alertcondition(rsvRisk,        "TMO Risk",         "Torque: RSV crossed below overbought — risk signal")
alertcondition(composite >= obLevel and warmed, "TMO Overbought", "Torque: Composite entering overbought zone")
alertcondition(composite <= osLevel and warmed, "TMO Oversold",   "Torque: Composite entering oversold zone")
````
