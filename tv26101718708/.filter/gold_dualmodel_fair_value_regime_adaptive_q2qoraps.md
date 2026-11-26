# Gold Dual-Model Fair Value [Regime Adaptive]

- url: https://www.tradingview.com/script/Q2QorApS-Gold-Dual-Model-Fair-Value-Regime-Adaptive/
- type: indicator
- pine_id: PUB;912a147217b0485794e7e3213cae87f8
- version: 1.0

## Description

█ [b]OVERVIEW[/b]

Gold Dual-Model Fair Value [Regime Adaptive] is a chart overlay that plots two competing fair value estimates for gold, one regressed on the 10 year real yield and one regressed on a global M2 money supply composite, then combines them into a single fair value line by continuously measuring which model currently fits better. The thesis: gold's dominant macro driver is not constant, so a useful fair value model must detect the driver in force rather than assume it.


█ [b]HISTORY / BACKGROUND[/b]

The inverse relationship between gold and real interest rates is one of the most widely documented regularities in the asset's modern history and is treated in academic work such as Erb and Harvey's "The Golden Dilemma" (2013). That relationship visibly weakened after 2022, when gold rose while real yields climbed to multi year highs, a divergence commonly attributed to price insensitive official sector buying. Macro strategists, notably Jurrien Timmer, have illustrated this as a regime change in which a real yield model stops explaining gold and a global liquidity model takes over.

The weakness of that illustration is that the regime break is declared after the fact, by inspection. This script's contribution is to make the regime decision endogenous: both models are estimated continuously, and the model in force is chosen by trailing out of sample fit, with no hardcoded break date. The regime change around 2022, if present in the data, emerges from the computation rather than being asserted.


█ [b]HOW IT WORKS[/b]

All computation runs on the chart timeframe. The script requests the following series with request.security at the chart resolution, with no lookahead: FRED:DFII10 (10 year TIPS real yield), five M2 series (ECONOMICS:USM2, CNM2, EUM2, JPM2, GBM2) and four conversion rates (FX_IDC:CNYUSD, EURUSD, JPYUSD, GBPUSD).

Step 1. Global M2 composite. Each enabled non US component is converted to US dollars and the enabled components are summed. Two aggregation modes exist. Spot FX converts at the current exchange rate, replicating the standard global liquidity composite. Constant FX converts every bar at the rate captured on the first bar at or after a user defined anchor date, which freezes the currency translation effect and isolates changes in underlying money stocks. The composite is na until every enabled component has data, so its membership never changes mid history and no artificial level jumps are introduced.

Step 2. Two rolling regressions. Over a rolling fit window the script estimates ordinary least squares coefficients from running moments (beta equals covariance over variance, alpha equals mean of y minus beta times mean of x):

 • Model A regresses the natural log of the chart close on the level of the 10 year real yield.
 • Model B regresses the natural log of the chart close on the natural log of the M2 composite.

Each model produces a log fair value each bar from its current alpha, beta and regressor value.

Step 3. Fit measurement. Each model's residual (log price minus log fair value) is squared and averaged over a shorter trailing evaluation window; the square root is that model's rolling RMSE.

Step 4. Regime and combination. Two output modes:

 • Blend (default): the combined log fair value is a weighted average of the two model fair values with weights proportional to inverse RMSE, so the better fitting model dominates smoothly.
 • Hard switch: the combined fair value is the fair value of the incumbent model, and the incumbent only changes when the challenger's RMSE beats it by a user set hysteresis margin, which prevents rapid flip flopping when the models fit similarly.

Independently of the mode, the hard switch state machine always runs and its current state is reported in the table and as the background tint, so blend users can still see the discrete regime call.

Step 5. Deviation statistics. The deviation is log price minus combined log fair value. Its rolling standard deviation over the evaluation window defines a z score, and bands are drawn at the fair value times e to the plus and minus (band multiple times sigma). The z score's percent rank over a user defined lookback gives a deviation percentile.

If one model's inputs are unavailable (for example the M2 composite before all enabled components exist), the combined fair value falls back to the available model alone.


█ [b]HOW TO USE[/b]

Apply the indicator to a gold chart (spot, futures or a fund proxy) on the [b]weekly[/b] timeframe. Weekly is the design resolution for a structural reason: the M2 inputs are monthly series, so on lower resolutions the liquidity regressor is a long staircase while the real yield updates daily, which biases the fit comparison toward the real yield model for reasons unrelated to explanatory power. The default windows (156 and 52 bars) are calibrated as roughly three years and one year of weekly bars. An on chart warning label appears on intraday charts.

Visual elements:

 • Orange line: the combined fair value, the primary output.
 • Blue thin line: Model A fair value (real yields). Red thin line: Model B fair value (global liquidity). Comparing their paths shows where each model succeeded or failed.
 • Gray bands and fill: the plus and minus sigma envelope around the combined fair value. Price above the upper band is statistically rich against the currently fitting model mix, below the lower band statistically cheap, between the bands unremarkable.
 • Background tint: blue when the hard switch regime is the real yield model, red when it is the liquidity model.
 • Status table: hard switch regime, active mode, each model's RMSE, the real yield model's blend weight, the deviation z score (colored when beyond the band multiple), its percentile, and the M2 aggregation mode.

Interpretation cautions. The fair value is a rolling fit, so a deviation can close either by price moving toward the line or by the line re estimating toward price; a band touch is a valuation observation, not a mechanical entry signal. The regime readout tells you which catalyst matters: in the liquidity regime, a cheap reading resolves with money supply reacceleration rather than falling yields. Comparing Spot FX and Constant FX modes shows how much of the liquidity signal is currency translation rather than money creation; if a stretched reading shrinks materially under Constant FX, part of it was the US dollar itself.


█ [b]SETTINGS[/b]

Model group:

 • Regression fit window (bars), default 156: the rolling OLS estimation window for both models.
 • Fit evaluation window (bars), default 52: the trailing window for RMSE, regime detection and deviation sigma.
 • Regime mode, default Blend (inverse RMSE weights): selects between the blended fair value and the hard switch fair value.
 • Switch hysteresis (%), default 10: hard switch mode only, the margin by which the challenger RMSE must beat the incumbent before the regime flips.
 • Deviation band (sigma), default 2.0: the band multiple and the z score threshold for table coloring.
 • Deviation percentile lookback (bars), default 260: the window for the z score percent rank.

Global M2 composite group:

 • FX aggregation, default Spot FX: Spot FX or Constant FX (anchor date), as described above.
 • Constant FX anchor date, default 1 January 2018: the date whose exchange rates are frozen in Constant FX mode.
 • US M2, China M2, Eurozone M2, Japan M2, UK M2, all enabled by default: component toggles. Disabling a short history component lets the composite, and therefore Model B, begin earlier.

Display group:

 • Show individual model lines, default on.
 • Show deviation bands, default on.
 • Show status table, default on.
 • Regime background tint, default on.
 • Table position, default top right.


█ [b]WHAT MAKES IT ORIGINAL[/b]

Published global M2 composites plot the liquidity series itself, usually with a fixed time offset against an asset, and published regime indicators classify price behavior such as trending versus ranging. This script occupies a different intersection and does three things no script in either group does:

 • It converts both macro drivers into explicit fair value estimates via rolling least squares regression rather than displaying the raw series, so the drivers and the asset live on the same axis and disagreement between them is measurable in price terms.
 • It selects or weights the two models by trailing out of sample RMSE, so the widely discussed post 2022 handoff from real yields to liquidity is detected by the data instead of hardcoded, and any future handoff back requires no code change.
 • Its liquidity composite offers a Constant FX aggregation mode alongside the standard Spot FX mode. Spot converted composites embed the US dollar's own fluctuations, which are correlated with gold, into the liquidity measure. The Constant FX mode removes that translation effect, giving users a built in test of how much of the liquidity signal is monetary and how much is currency denomination. To this author's knowledge no published composite exposes this distinction.


█ [b]NOTES / LIMITATIONS[/b]

 • The M2 inputs are monthly economic series requested at the chart resolution. They hold their value between releases, so the liquidity fair value moves in steps between prints, and releases arrive with publication lag.
 • Economic series are subject to vendor revisions. A revised M2 or real yield history changes the regression inputs, so the historical fair value shown today can differ from what the script displayed in real time. This is a property of the data, not lookahead: the script uses no lookahead and requests no timeframe above the chart's.
 • Model B is na until every enabled M2 component and its conversion rate have history, and each regression additionally needs the full fit window plus evaluation window of bars before its output and RMSE are defined. On deep weekly gold history the real yield model also cannot begin before the real yield series itself starts in 2003. Expect a substantial warm up period at the left edge of the chart, during which the script falls back to whichever single model is available, or plots nothing.
 • The logic is designed for the weekly timeframe. On daily and lower resolutions the mixed update frequencies of the regressors distort the fit comparison, the default windows lose their intended calendar meaning, and an on chart label warns on intraday charts.
 • The script uses the chart symbol's close as the dependent variable. Its economic reasoning applies to gold denominated symbols; applied to unrelated symbols it will still compute, but the output has no stated meaning.
 • The fair value lines are descriptive regression fits over past data. They quantify the historical relationship between gold and each driver and say nothing about future prices.

## Source Code

````pine
//@version=6
// Gold Dual-Model Fair Value [Regime Adaptive]
// Two competing fair-value models for gold, selected/blended by rolling out-of-sample fit:
//   Model A: rolling OLS of log(gold) on 10Y TIPS real yield (FRED:DFII10)
//   Model B: rolling OLS of log(gold) on log(global M2 composite, USD)
// Regime is detected endogenously via trailing RMSE comparison with hysteresis,
// rather than hardcoding a break date. M2 aggregation offers Spot FX vs Constant FX
// modes to expose how much of the "liquidity" signal is a USD valuation artifact.
// Designed for the weekly timeframe on gold symbols (XAUUSD, GC, GLD proxies).
indicator("Gold Dual-Model Fair Value [Regime Adaptive]", "Gold FV Regime", overlay = true)

// ── Inputs ──────────────────────────────────────────────────────────────────
grpM   = "Model"
fitLen  = input.int(156, "Regression fit window (bars)",  minval = 20,  group = grpM,
     tooltip = "Rolling OLS estimation window. Default 156 = ~3 years on weekly bars.")
evalLen = input.int(52,  "Fit evaluation window (bars)",  minval = 10,  group = grpM,
     tooltip = "Trailing window for per-model RMSE used in regime detection and blending. Default 52 = ~1 year on weekly bars.")
modeStr = input.string("Blend (inverse RMSE weights)", "Regime mode",
     options = ["Blend (inverse RMSE weights)", "Hard switch (hysteresis)"], group = grpM)
hystPct = input.float(10.0, "Switch hysteresis (%)", minval = 0, maxval = 50, step = 1, group = grpM,
     tooltip = "Hard-switch mode only: challenger model RMSE must beat the incumbent by this margin before the regime flips.")
zBand   = input.float(2.0, "Deviation band (sigma)", minval = 0.5, step = 0.25, group = grpM)
pctLen  = input.int(260, "Deviation percentile lookback (bars)", minval = 50, group = grpM)

grpL   = "Global M2 composite"
aggStr  = input.string("Spot FX", "FX aggregation", options = ["Spot FX", "Constant FX (anchor date)"], group = grpL,
     tooltip = "Spot FX replicates the standard USD-aggregated composite. Constant FX freezes conversion rates at the anchor date, removing the USD valuation effect from the liquidity series.")
anchorT = input.time(timestamp("2018-01-01T00:00:00"), "Constant FX anchor date", group = grpL)
useUS   = input.bool(true, "US M2",        group = grpL, inline = "c1")
useCN   = input.bool(true, "China M2",     group = grpL, inline = "c1")
useEU   = input.bool(true, "Eurozone M2",  group = grpL, inline = "c2")
useJP   = input.bool(true, "Japan M2",     group = grpL, inline = "c2")
useGB   = input.bool(true, "UK M2",        group = grpL, inline = "c3")

grpD   = "Display"
showModels = input.bool(true,  "Show individual model lines", group = grpD)
showBands  = input.bool(true,  "Show deviation bands",        group = grpD)
showTable  = input.bool(true,  "Show status table",           group = grpD)
showBg     = input.bool(true,  "Regime background tint",      group = grpD)
tblPosStr  = input.string("Top right", "Table position",
     options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = grpD)

blendMode = modeStr == "Blend (inverse RMSE weights)"
spotFx    = aggStr  == "Spot FX"
hyst      = hystPct / 100.0

// ── Data ────────────────────────────────────────────────────────────────────
f_sec(simple string sym) =>
    request.security(sym, timeframe.period, close)

dfii = f_sec("FRED:DFII10")

m2us = f_sec("ECONOMICS:USM2")
m2cn = f_sec("ECONOMICS:CNM2")
m2eu = f_sec("ECONOMICS:EUM2")
m2jp = f_sec("ECONOMICS:JPM2")
m2gb = f_sec("ECONOMICS:GBM2")

fxcn = f_sec("FX_IDC:CNYUSD")
fxeu = f_sec("FX_IDC:EURUSD")
fxjp = f_sec("FX_IDC:JPYUSD")
fxgb = f_sec("FX_IDC:GBPUSD")

// Constant-FX: capture the first available rate at/after the anchor date.
f_anchor(float fx) =>
    var float a = na
    if na(a) and time >= anchorT and not na(fx)
        a := fx
    a

acn = f_anchor(fxcn)
aeu = f_anchor(fxeu)
ajp = f_anchor(fxjp)
agb = f_anchor(fxgb)
rcn = spotFx ? fxcn : acn
reu = spotFx ? fxeu : aeu
rjp = spotFx ? fxjp : ajp
rgb = spotFx ? fxgb : agb

// Composite is na until every ENABLED component has data, so its member set
// never changes mid-history (a silent membership change would create level jumps).
float m2comp = 0.0
bool  compOk = true
if useUS
    compOk := compOk and not na(m2us)
    m2comp += nz(m2us)
if useCN
    compOk := compOk and not na(m2cn) and not na(rcn)
    m2comp += nz(m2cn) * nz(rcn)
if useEU
    compOk := compOk and not na(m2eu) and not na(reu)
    m2comp += nz(m2eu) * nz(reu)
if useJP
    compOk := compOk and not na(m2jp) and not na(rjp)
    m2comp += nz(m2jp) * nz(rjp)
if useGB
    compOk := compOk and not na(m2gb) and not na(rgb)
    m2comp += nz(m2gb) * nz(rgb)
anyComp = useUS or useCN or useEU or useJP or useGB
m2comp := compOk and anyComp and m2comp > 0 ? m2comp : na

logGold = math.log(close)
logM2   = math.log(m2comp)

// ── Rolling OLS ─────────────────────────────────────────────────────────────
// beta = cov(x,y)/var(x) via rolling moments; alpha = mean(y) - beta*mean(x).
f_ols(float y, float x, simple int len) =>
    mx  = ta.sma(x, len)
    my  = ta.sma(y, len)
    mxy = ta.sma(x * y, len)
    mx2 = ta.sma(x * x, len)
    vX  = mx2 - mx * mx
    b   = vX > 1e-12 ? (mxy - mx * my) / vX : na
    a   = my - b * mx
    [a, b]

[aA, bA] = f_ols(logGold, dfii,  fitLen)
[aB, bB] = f_ols(logGold, logM2, fitLen)

logFvA = aA + bA * dfii
logFvB = aB + bB * logM2

// ── Fit quality and regime ──────────────────────────────────────────────────
resA  = logGold - logFvA
resB  = logGold - logFvB
rmseA = math.sqrt(ta.sma(resA * resA, evalLen))
rmseB = math.sqrt(ta.sma(resB * resB, evalLen))

okA = not na(rmseA)
okB = not na(rmseB)

// Hard-switch regime state with hysteresis. 1 = real yields, 2 = liquidity.
var int regime = 0
if regime == 0
    regime := okA and okB ? (rmseA <= rmseB ? 1 : 2) : okA ? 1 : okB ? 2 : 0
else
    if regime == 1 and okB and (not okA or rmseB < rmseA * (1 - hyst))
        regime := 2
    if regime == 2 and okA and (not okB or rmseA < rmseB * (1 - hyst))
        regime := 1

// Inverse-RMSE blend weights.
float wA = na
if okA and okB
    invA = 1.0 / math.max(rmseA, 1e-10)
    invB = 1.0 / math.max(rmseB, 1e-10)
    wA := invA / (invA + invB)
else
    wA := okA ? 1.0 : okB ? 0.0 : na

float logFv = na
if blendMode
    logFv := okA and okB ? wA * logFvA + (1 - wA) * logFvB : okA ? logFvA : okB ? logFvB : na
else
    logFv := regime == 1 ? logFvA : regime == 2 ? logFvB : na

// ── Deviation ───────────────────────────────────────────────────────────────
dev    = logGold - logFv
sigma  = ta.stdev(dev, evalLen)
zDev   = sigma > 0 ? dev / sigma : na
zPct   = ta.percentrank(zDev, pctLen)

fv    = math.exp(logFv)
fvUp  = math.exp(logFv + zBand * sigma)
fvDn  = math.exp(logFv - zBand * sigma)

// ── Plots ───────────────────────────────────────────────────────────────────
colA     = color.new(#2962ff, 30)
colB     = color.new(#f23645, 30)
colFv    = color.new(#ff9800, 0)
colBand  = color.new(#787b86, 60)

plot(showModels ? math.exp(logFvA) : na, "FV: real yields",     colA, 1)
plot(showModels ? math.exp(logFvB) : na, "FV: global liquidity", colB, 1)
plot(fv, "Fair value", colFv, 2)
pU = plot(showBands ? fvUp : na, "Upper band", colBand, 1)
pD = plot(showBands ? fvDn : na, "Lower band", colBand, 1)
fill(pU, pD, color = color.new(#787b86, 92), title = "Band fill")

bgcolor(showBg and regime == 1 ? color.new(#2962ff, 94) :
     showBg and regime == 2 ? color.new(#f23645, 94) : na, title = "Regime tint")

// ── Status table ────────────────────────────────────────────────────────────
tblPos = tblPosStr == "Top right" ? position.top_right :
     tblPosStr == "Top left" ? position.top_left :
     tblPosStr == "Bottom right" ? position.bottom_right : position.bottom_left

f_row(table t, int r, string k, string v, color vc) =>
    table.cell(t, 0, r, k, text_color = color.new(#b2b5be, 0), text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, r, v, text_color = vc, text_size = size.small, text_halign = text.align_right)

if showTable and barstate.islast
    var table t = table.new(tblPos, 2, 8, border_width = 1,
         bgcolor = color.new(color.black, 20), border_color = color.new(#787b86, 70))
    regStr = regime == 1 ? "REAL YIELDS" : regime == 2 ? "LIQUIDITY" : "WARMING UP"
    regCol = regime == 1 ? #2962ff : regime == 2 ? #f23645 : color.gray
    zCol   = na(zDev) ? color.gray : zDev >= zBand ? #f23645 : zDev <= -zBand ? #4caf50 : color.white
    f_row(t, 0, "Regime (hard switch)", regStr, regCol)
    f_row(t, 1, "Mode", blendMode ? "Blend" : "Hard switch", color.white)
    f_row(t, 2, "RMSE real yields",  okA ? str.tostring(rmseA, "#.####") : "na", color.white)
    f_row(t, 3, "RMSE liquidity",    okB ? str.tostring(rmseB, "#.####") : "na", color.white)
    f_row(t, 4, "Weight real yields", na(wA) ? "na" : str.tostring(wA * 100, "#.#") + " %", color.white)
    f_row(t, 5, "Deviation (z)", na(zDev) ? "na" : str.tostring(zDev, "#.##"), zCol)
    f_row(t, 6, "Deviation percentile", na(zPct) ? "na" : str.tostring(zPct, "#.#") + " %", color.white)
    f_row(t, 7, "M2 aggregation", spotFx ? "Spot FX" : "Constant FX", color.white)

if barstate.islast and timeframe.isintraday
    var label warn = na
    label.delete(warn)
    warn := label.new(bar_index, high, "Designed for the weekly timeframe.\nMonthly macro inputs step on lower resolutions.",
         style = label.style_label_down, color = color.new(color.orange, 20), textcolor = color.black, size = size.small)
````
