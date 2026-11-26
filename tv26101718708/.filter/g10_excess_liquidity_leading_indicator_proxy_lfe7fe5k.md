# G10 Excess Liquidity Leading Indicator (Proxy)

- url: https://www.tradingview.com/script/lFe7Fe5k-G10-Excess-Liquidity-Leading-Indicator-Proxy/
- type: indicator
- pine_id: PUB;37c0917c591b4f45a59beab115870333
- version: 1.0

## Description

█ OVERVIEW

This indicator plots a GDP-weighted composite of real money growth across ten G10 economies, measured as the deviation of each economy's annual real money growth from its own trailing trend, in a separate pane. The thesis it expresses is the excess-liquidity idea: when real money across the major economies is growing faster than its recent trend, the liquidity backdrop for risk assets is supportive, and when it is growing below trend the backdrop is restrictive. An optional [i]SPX YoY[/i] reference line is provided on a shared scale so the user can inspect the visual relationship between the two series.


═════════════════════════════════════════════════════════════

█ HISTORY / BACKGROUND

The term [i]excess liquidity[/i] comes from monetarist macro analysis, where the quantity of money in circulation is compared against the economy's transactional needs. The level analogue is the Marshallian K, the ratio of broad money to nominal output. The flow version used here treats the growth of real money relative to its own recent trend as a measure of surplus or deficit liquidity, on the reasoning that money created beyond what current activity absorbs tends to find its way into financial assets, while a deficit withdraws that support.

Aggregated, multi-country versions of this measure are produced by several research firms and data vendors as proprietary series, and are commonly charted against equity returns with a forward displacement to illustrate a hypothesized lead. Those vendor series are closed: their exact money aggregates, weighting, smoothing, and detrending are not published. This script is a transparent reconstruction of the concept from public data. It is not a copy of any vendor series, and its construction choices are the author's own, stated in full below.


═════════════════════════════════════════════════════════════

█ HOW IT WORKS

The script computes everything from external data requests and does not use the chart symbol's price, so its output is the same regardless of which symbol the chart shows. The pane location follows the chart; the values do not.

For each of ten economic units (United States, Euro area, Japan, United Kingdom, Canada, Switzerland, Australia, New Zealand, Sweden, Norway) the algorithm proceeds as follows.

1. It requests a money-supply series and a consumer price index from the [i]ECONOMICS[/i] provider at monthly resolution. Requests use no lookahead and forward-fill gaps, and invalid symbols are tolerated rather than throwing.

2. It forms real money as the money-supply level divided by the CPI index.

3. It computes annual real money growth as the twelve-month percentage change of that real money series.

4. It detrends that growth by subtracting its own simple moving average over the [i]Trend window[/i] length. The result is each economy's excess-liquidity reading in percentage points relative to its own trend.

The ten readings are then combined.

5. The composite is the GDP-weighted mean of the per-economy readings, using fixed nominal-GDP weights held as constants. Any economy whose data does not resolve returns na, is excluded from both the weighted sum and the weight total, and the remaining weights are renormalized automatically over the live subset.

6. The composite is optionally standardized by subtracting its moving average and dividing by its standard deviation over the [i]Z-score window[/i]. If the standard deviation is zero the standardized value is na.

7. The same twelve-month-change and optional standardization are applied to [symbol]SP:SPX[/symbol] to produce the reference line.

The plotted objects are: the composite, drawn with a forward bar offset and colored red when below zero and blue when at or above zero; the SPX reference line in black, shown only when its toggle is on; a dashed zero line; a status table in the top right listing each economic leg as OK or missing with a live-leg count; and a warning label that appears on the last bar only when the chart is not on a monthly resolution.


═════════════════════════════════════════════════════════════

█ HOW TO USE

Apply the script on a [b]monthly[/b] chart. The twelve-month change is computed as a twelve-bar change and the forward displacement is expressed in bars, so both only carry their intended meaning of twelve months and the configured number of months when one bar equals one month. On any other resolution the windows no longer correspond to those spans, and the script draws a label warning of this on the last bar.

Read the composite against the zero line. A blue reading means aggregate G10 real money growth is running above its own trailing trend; a red reading means it is running below trend. When standardization is enabled the vertical units are standard deviations from the windowed mean rather than raw percentage points.

The composite is displaced forward by the [i]Forward push[/i] setting to align it visually with the period the excess-liquidity hypothesis associates it with. This displacement is a charting offset for inspection, not a forecast, and the displaced portion extending past the last bar carries no data claim.

The black SPX reference line is supplied only for visual comparison of timing on a common scale. The script does not combine the two series into a single signal.

Before interpreting the composite, check the status table. A reduced live-leg count changes which economies are present in the GDP weighting and therefore changes the composite. Because the standardization and trend windows require history, the composite is blank until enough monthly history has accumulated for the latest-starting live leg, so early chart history may show no line.


═════════════════════════════════════════════════════════════

█ SETTINGS

 • [i]Trend window (months)[/i]: length of the moving average subtracted from each economy's annual real money growth to form its excess reading. Default 36, minimum 12.

 • [i]Z-score window (months)[/i]: lookback used for the mean and standard deviation when standardizing both the composite and the SPX reference. Default 120, minimum 24.

 • [i]Z-score series for comparability[/i]: when enabled, the composite and the SPX line are standardized to a common unitless scale. When disabled, the composite is shown in percentage-point deviation units and the SPX line as a raw annual percentage change. Default enabled.

 • [i]Overlay SPX YoY[/i]: toggles the black SPX reference line. Default enabled.

 • [i]Forward push (months / bars)[/i]: number of bars by which the composite plot is shifted forward. Default 6, minimum 0, maximum 24.


═════════════════════════════════════════════════════════════

█ WHAT MAKES IT ORIGINAL

The script is a self-contained, fully on-chart reconstruction of the excess-liquidity concept rather than a wrapper around a published series. Its specific construction is: per-economy real money defined as a national money aggregate deflated by that country's CPI; annual growth of that real money detrended against its own moving average so each economy is measured relative to its own history; a GDP-weighted aggregation across ten G10 economies; and automatic renormalization of the weights over whatever data legs resolve at runtime, with a coverage table that makes the live universe and each economy's contribution status visible on the chart. A configurable forward displacement and an optional shared-scale SPX reference are included so the timing relationship can be inspected directly.

The money aggregates are each economy's most-available headline measure from the data provider and are therefore a mixed family across countries by design; each leg is internally consistent through time, which is what the annual-change and detrending steps require. The aggregate definition, the choice of detrending against a trailing trend, the weighting, and the windows are modeling choices made by the author and are exposed as inputs or as clearly marked constants, not hidden internals.


═════════════════════════════════════════════════════════════

█ NOTES / LIMITATIONS

 • [b]Monthly resolution only.[/b] The twelve-month change and the forward offset are bar-based. On non-monthly charts they no longer correspond to twelve months and the configured number of months. The script flags this with a label on the last bar.

 • [b]Forward displacement.[/b] The composite is shifted forward by the offset using the plot offset. The displaced segment extends beyond the last historical bar and moves as new bars arrive. It is a visual offset and not a prediction.

 • [b]Data dependence and coverage.[/b] The composite is built entirely from external money-supply and CPI series for ten economies plus the SPX series. Legs that fail to resolve return na, drop out of the aggregate, and shrink the effective universe. The status table reports the live count so the user can judge whether the composite is representative.

 • [b]History requirement.[/b] Each leg needs enough valid monthly history to fill the trend window and, when standardization is on, the z-score window before it contributes. The composite is na until those windows are satisfied for the live legs, so it begins only after sufficient history has accumulated.

 • [b]Revision behavior.[/b] Requests use no lookahead, so the script does not read future data. Economic series are published with a lag and are forward-filled between releases, and published values can be revised after the fact. The most recent readings can therefore change as data is updated, independently of any bar-level repainting.

 • [b]Symbol independence.[/b] The output does not depend on the chart symbol; it computes the same composite on any chart. Only the pane in which it is drawn follows the chart.

No claim is made regarding profitability, accuracy, or future returns. The indicator is a descriptive macro monitor.

## Source Code

````pine
//@version=6
//
// G10 Excess Liquidity Leading Indicator (Proxy)
// ----------------------------------------------------------------------------
// Methodology (trend-deviation definition):
//   1. Per economy, real money = nominal money aggregate / CPI.
//   2. YoY real money growth (12 monthly bars).
//   3. Excess = YoY growth minus its own trailing trend (SMA over trendLen).
//   4. Aggregate = GDP-weighted mean of per-economy excess, dropping any leg
//      whose FRED series does not resolve (na) and renormalizing weights.
//   5. Optional z-score for scale comparability with SPX YoY.
//   6. Aggregate is plotted with a forward offset to mirror the source chart's
//      "pushed forward N months" construction.
//
// IMPORTANT NOTES:
//   - Run this on a MONTHLY chart. YoY uses [12] bars and the forward offset is
//     in bars, so both only mean "12 / N months" when one bar equals one month.
//   - This reproduces the METHODOLOGY, not any proprietary Bloomberg/CrossBorder
//     series. Aggregate definition, money aggregate, smoothing and weights are
//     modeling choices, not the original's unstated internals.
//   - The 6-month lead is almost certainly an in-sample fit. Treat as a monitor,
//     validate the lead length out-of-sample before trusting the forward push.
//
// DATA RISK (the binding constraint): every international leg is an OECD-sourced
// FRED ticker. FRED carrying a series does not mean the TradingView symbol
// resolves on your plan. The coverage table (top-right) shows which legs are
// live. Verify there, swap or comment out dead legs, and the GDP weights
// renormalize automatically over whatever subset resolves.
//
// Money aggregate: ECONOMICS provider, each country's most-available headline
// measure (M2/M3/M4 mixed by design). Each leg is internally consistent over
// time, which is all the YoY and trend-deviation transforms require.
// ----------------------------------------------------------------------------

indicator("G10 Excess Liquidity Leading Indicator (Proxy)", "G10 EL Proxy", overlay = false, precision = 2)

// ============================== INPUTS ======================================
trendLen  = input.int(36,  "Trend window (months)",   minval = 12)
zWin      = input.int(120, "Z-score window (months)", minval = 24)
useZ      = input.bool(true,  "Z-score series for comparability")
showSPX   = input.bool(true,  "Overlay SPX YoY (z-scored)")
fwdOffset = input.int(6,   "Forward push (months / bars)", minval = 0, maxval = 24)

string TF = "1M"

// ============================== TICKERS =====================================
// Provider: ECONOMICS (TradingView macro feed). FRED's OECD international
// series do not resolve on this plan, confirmed 0/10. All flagged UNVERIFIED;
// edit any that read "missing" in the coverage table.
//
// Money aggregate is each country's most-available headline measure, so the
// family is mixed by design (M2 / M3 / M4). Each leg is internally consistent
// over time, which is what the YoY and trend-deviation require. Likeliest
// "missing" legs are NZ, NO, SE money supply; dropping them costs ~1.5% weight.

// Money supply
m_us = "ECONOMICS:USM2"
m_ea = "ECONOMICS:EUM3"
m_jp = "ECONOMICS:JPM2"
m_uk = "ECONOMICS:GBM3"
m_ca = "ECONOMICS:CAM2"
m_ch = "ECONOMICS:CHM2"
m_au = "ECONOMICS:AUM3"
m_nz = "ECONOMICS:NZM3"
m_se = "ECONOMICS:SEM3"
m_no = "ECONOMICS:NOM2"

// CPI (index)
c_us = "ECONOMICS:USCPI"
c_ea = "ECONOMICS:EUCPI"
c_jp = "ECONOMICS:JPCPI"
c_uk = "ECONOMICS:GBCPI"
c_ca = "ECONOMICS:CACPI"
c_ch = "ECONOMICS:CHCPI"
c_au = "ECONOMICS:AUCPI"
c_nz = "ECONOMICS:NZCPI"
c_se = "ECONOMICS:SECPI"
c_no = "ECONOMICS:NOCPI"

// ====================== NOMINAL GDP WEIGHTS (USD bn) ========================
// Approximate, editable. Renormalized automatically over resolved legs.
w_us = 28000.0, w_ea = 15500.0, w_jp = 4200.0, w_uk = 3400.0, w_ca = 2200.0
w_ch =   900.0, w_au =  1700.0, w_nz =  250.0, w_se =  600.0, w_no =  500.0

// ============================== FETCH =======================================
f_get(string sym) =>
    request.security(sym, TF, close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

// money
mu = f_get(m_us), me = f_get(m_ea), mj = f_get(m_jp), mk = f_get(m_uk), mc = f_get(m_ca)
ms = f_get(m_ch), ma = f_get(m_au), mn = f_get(m_nz), mw = f_get(m_se), mo = f_get(m_no)
// cpi
pu = f_get(c_us), pe = f_get(c_ea), pj = f_get(c_jp), pk = f_get(c_uk), pc = f_get(c_ca)
ps = f_get(c_ch), pa = f_get(c_au), pn = f_get(c_nz), pw = f_get(c_se), po = f_get(c_no)

// ============================== TRANSFORM ===================================
f_excess(float money, float cpi, int tl) =>
    real = money / cpi
    yoy  = (real / real[12] - 1.0) * 100.0
    yoy - ta.sma(yoy, tl)

x_us = f_excess(mu, pu, trendLen), x_ea = f_excess(me, pe, trendLen)
x_jp = f_excess(mj, pj, trendLen), x_uk = f_excess(mk, pk, trendLen)
x_ca = f_excess(mc, pc, trendLen), x_ch = f_excess(ms, ps, trendLen)
x_au = f_excess(ma, pa, trendLen), x_nz = f_excess(mn, pn, trendLen)
x_se = f_excess(mw, pw, trendLen), x_no = f_excess(mo, po, trendLen)

// ====================== GDP-WEIGHTED AGGREGATE ==============================
num = 0.0
den = 0.0
if not na(x_us)
    num += x_us * w_us, den += w_us
if not na(x_ea)
    num += x_ea * w_ea, den += w_ea
if not na(x_jp)
    num += x_jp * w_jp, den += w_jp
if not na(x_uk)
    num += x_uk * w_uk, den += w_uk
if not na(x_ca)
    num += x_ca * w_ca, den += w_ca
if not na(x_ch)
    num += x_ch * w_ch, den += w_ch
if not na(x_au)
    num += x_au * w_au, den += w_au
if not na(x_nz)
    num += x_nz * w_nz, den += w_nz
if not na(x_se)
    num += x_se * w_se, den += w_se
if not na(x_no)
    num += x_no * w_no, den += w_no
agg = den > 0 ? num / den : na

// ============================== Z-SCORE / SPX ===============================
f_z(float s, int w) =>
    sd = ta.stdev(s, w)
    sd > 0 ? (s - ta.sma(s, w)) / sd : na

aggOut = useZ ? f_z(agg, zWin) : agg

spx    = f_get("SP:SPX")
spxYoY = (spx / spx[12] - 1.0) * 100.0
spxOut = useZ ? f_z(spxYoY, zWin) : spxYoY

// ============================== PLOTS =======================================
elColor = aggOut < 0 ? color.new(color.red, 0) : color.new(color.blue, 0)
plot(showSPX ? spxOut : na, "SPX YoY", color = color.black, linewidth = 2)
plot(aggOut, "G10 EL (pushed fwd)", color = elColor, linewidth = 2, offset = fwdOffset)
hline(0, "Zero", color = color.new(color.gray, 50), linestyle = hline.style_dashed)

// ============================== DIAGNOSTICS =================================
if barstate.islast
    if not timeframe.ismonthly
        label.new(bar_index, 0, "Apply on a MONTHLY chart. YoY and forward offset assume one bar = one month.", style = label.style_label_down, color = color.new(color.orange, 0), textcolor = color.white, size = size.small)
    names = array.from("US", "Euro area", "Japan", "UK", "Canada", "Switzerland", "Australia", "New Zealand", "Sweden", "Norway")
    vals  = array.from(x_us, x_ea, x_jp, x_uk, x_ca, x_ch, x_au, x_nz, x_se, x_no)
    t = table.new(position.top_right, 2, 12, border_width = 1, frame_width = 1, frame_color = color.gray)
    table.cell(t, 0, 0, "G10 leg",  text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = size.small)
    table.cell(t, 1, 0, "status",   text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = size.small)
    live = 0
    for i = 0 to 9
        ok = not na(array.get(vals, i))
        live += ok ? 1 : 0
        table.cell(t, 0, i + 1, array.get(names, i), text_color = color.gray, text_size = size.small)
        table.cell(t, 1, i + 1, ok ? "OK" : "missing", text_color = color.white, bgcolor = ok ? color.new(color.green, 70) : color.new(color.red, 60), text_size = size.small)
    table.cell(t, 0, 11, "legs live", text_color = color.white, text_size = size.small)
    table.cell(t, 1, 11, str.tostring(live) + "/10", text_color = color.white, text_size = size.small)
````
