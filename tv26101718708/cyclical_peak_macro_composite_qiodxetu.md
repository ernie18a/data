# Cyclical Peak Macro Composite

- url: https://www.tradingview.com/script/QIoDXeTU-Cyclical-Peak-Macro-Composite/
- type: indicator
- pine_id: PUB;bcbb641e83e44933aad4b360ebaf0dbf
- version: 1.0

## Description

█ [b]OVERVIEW[/b]

[b]Cyclical Peak Macro Composite[/b] is a macro and valuation signal panel that tracks a set of independent conditions historically associated with late-cycle equity market peaks and reports the share of them that are currently active. It plots in a separate pane as a single column series, [i]% Triggered[/i], the percent of counting signals that meet their trigger condition, alongside a status table that summarizes each individual signal.

In one sentence: when a majority of independent macro, credit, and valuation conditions seen near prior market peaks are simultaneously active, the late-cycle environment is more elevated than when few of them are.


█ [b]HISTORY / BACKGROUND[/b]

The practice of monitoring a fixed panel of macro, valuation, credit, and sentiment signposts for equity market peaks comes from sell-side equity strategy research, which publishes periodic checklists scoring how many of a set of conditions are active relative to prior peaks. This script implements only the subset of such a checklist whose inputs exist as data on TradingView, substitutes documented proxies where the original series are proprietary, and omits the signals that have no public feed and no faithful proxy rather than approximating them with unrelated data.

The component methods have established lineage:

 • [b]Term spread.[/b] The difference between a long and a short Treasury yield is a standard cycle reference. A negative 10Y minus 2Y spread, an inverted curve, has been present ahead of prior downturns.
 • [b]Rule of 20.[/b] A long standing market heuristic that sums the trailing price to earnings ratio and the year over year inflation rate, treating a value near 20 as a fair value reference and higher readings as richer valuation.
 • [b]High yield option adjusted spread.[/b] The ICE BofA US High Yield index OAS, distributed through FRED, is a widely used gauge of credit risk pricing. Unusually tight spreads are read here as complacency, not stress.
 • [b]Senior Loan Officer Opinion Survey (SLOOS).[/b] The Federal Reserve survey of bank lending standards. A positive net reading indicates tightening credit availability.
 • [b]Consumer sentiment.[/b] The University of Michigan survey, used as an optional proxy for a different consumer confidence series in the original checklist.

The conceptual basis is that these conditions tend to cluster near cyclical peaks, so counting how many are active gives a coarse read on where the cycle sits. The specific composite arrangement is third party research; this script is an independent reconstruction of its available subset.


█ [b]HOW IT WORKS[/b]

The script reads external macro series through [i]request.security[/i] and does not use the chart symbol's price in any calculation, so its output is identical on any chart and depends only on the chart timeframe. Every lookback is specified in months and converted to a bar count for the active resolution by round(months times seconds per month divided by seconds per bar), clamped between 1 and 5000 bars, so each window holds its intended calendar duration across resolutions.

It evaluates up to six signals:

 • [b]Yield curve inversion.[/b] Requests the 10Y and 2Y yield symbols at the chart timeframe and takes their spread. Active if the spread was below zero at any point within the latch window, tested with a rolling maximum of the inverted condition.
 • [b]Credit complacency.[/b] Requests the high yield OAS series. Active if the spread was below the tight spread threshold at any point within the latch window. The direction is deliberate: a low spread is the peak signal.
 • [b]Rule of 20.[/b] Computes the year over year change of monthly CPI and adds it to a trailing P/E value, which is a manual input by default or a symbol sourced value if enabled. It then takes a rolling z-score of that sum over the z-score lookback and is active when the z-score exceeds its trigger.
 • [b]Value versus growth.[/b] Requests a value proxy and a growth proxy at the chart timeframe and computes the difference of their returns over the return window, in percentage points. Active when the value proxy trails the growth proxy by more than the underperformance trigger.
 • [b]SLOOS net tightening.[/b] Requests the SLOOS series at a quarterly resolution. Active when the net reading is above zero. Counts only when included and when its data resolves.
 • [b]Consumer sentiment (optional).[/b] Takes a rolling z-score of the sentiment series over the z-score lookback and is active when it exceeds the sentiment trigger. Counts only when enabled and when its data resolves.

The denominator is dynamic. Four core signals always count, plus SLOOS when active, plus sentiment when active. [i]% Triggered[/i] is 100 times the number of active triggers divided by the number of counting signals. Any series whose data does not resolve returns na and is excluded from both numerator and denominator rather than scored as off.


█ [b]HOW TO USE[/b]

Add the script to any chart. The chart symbol is irrelevant because all inputs are requested macro series. Read the column height as the percent of counting signals currently triggered. The dashed line marks the composite alert threshold and the dotted line marks the 50 percent midline. The column is gray below 50, orange at or above 50, and red at or above the alert threshold.

The status table in the top right lists each signal with a state of ON, off, or n/a. ON is shown in red because in this context an active signal is a late-cycle condition rather than a healthy one, off is green, and n/a means the signal is disabled or its data did not resolve and it is not counting. The header cell repeats the current percent.

Recommended timeframe: the script is built for the daily resolution and higher, and is cleanest on monthly. CPI, SLOOS, and sentiment are requested at monthly or quarterly resolution and mapped onto the chart's bars, so on a monthly chart one bar corresponds to one source observation and the z-score statistics are exact. On intraday resolutions the month to bar conversion saturates at the 5000 bar clamp and the windows no longer span the intended number of months, so intraday use is not advised.

The diagnostic series, namely the spread, the OAS, the Rule of 20 level and z-score, the SLOOS reading, the value minus growth return, and the sentiment z-score, are not drawn on the pane. They are available in the Data Window for inspection.


█ [b]SETTINGS[/b]

[b]Yield Curve[/b]
 • 10Y yield symbol: long rate symbol for the term spread. Default US10Y.
 • 2Y yield symbol: short rate symbol. Default US02Y.

[b]Credit (HY OAS complacency)[/b]
 • HY OAS symbol: the high yield option adjusted spread series. Default FRED:BAMLH0A0HYM2.
 • Tight spread threshold (%): the level below which the spread is treated as complacent. Default 3.5.

[b]Rule of 20 (P/E + CPI YoY)[/b]
 • Trailing S&P 500 P/E: the manual trailing P/E used when the symbol feed is off. Default 22.
 • Feed P/E from a symbol: when on, sources the P/E from a symbol instead of the manual value. Default off.
 • P/E symbol (trailing): the symbol used when the feed is enabled. Default SP:SPX.
 • Z-score lookback (months): the window for the Rule of 20 and sentiment z-scores. Default 120, minimum 12.
 • Z-score trigger (>): the Rule of 20 z-score level that activates the signal. Default 1.

[b]Value / Growth (low-PE vs high-PE proxy)[/b]
 • Value proxy symbol: the value style proxy. Default AMEX:SPYV.
 • Growth proxy symbol: the growth style proxy. Default AMEX:SPYG.
 • Return window (months): lookback for the relative return. Default 6, minimum 1.
 • Underperformance trigger (pp): how far the value proxy must trail the growth proxy to activate. Default 2.5.

[b]SLOOS (bank lending)[/b]
 • Include SLOOS: whether the SLOOS signal counts. Default on.
 • SLOOS net tightening symbol: the lending standards series. Default FRED:DRTSCILM.

[b]Consumer sentiment (optional, low fidelity)[/b]
 • Include sentiment proxy: whether the sentiment signal counts. Default off.
 • Sentiment symbol: the sentiment series. Default FRED:UMCSENT.
 • Sentiment z-score trigger (>): the z-score level that activates the signal. Default 1.

[b]Composite[/b]
 • Latch window for prior signals (months): the lookback over which the yield curve and credit signals count as active if their condition occurred at any point inside it. Default 6, minimum 1.
 • Composite alert threshold (%): the percent at which the alert condition and red coloring engage. Default 70.


█ [b]WHAT MAKES IT ORIGINAL[/b]

This is not a wrapper around other indicators and reuses no third party signal code. It computes each condition directly from primary macro and valuation series and combines them with three specific design choices:

 • [b]Honest scope.[/b] It implements only the checklist signals that have real TradingView data, omits the proprietary and unavailable ones outright, and labels the two proxies it uses as proxies. The value and growth style spread stands in for a low P/E versus high P/E basket, and the optional University of Michigan z-score stands in for a different consumer confidence index. The percent reading is therefore not comparable to the source checklist's percent, which is computed over a larger set of signals.
 • [b]Deliberate credit direction.[/b] The credit signal fires on tight spreads, not wide ones, because the underlying idea is complacency near a peak rather than stress. This inverts the intuitive reading and is stated rather than hidden.
 • [b]Calendar anchored windows and graceful degradation.[/b] Every lookback is expressed in months and converted to bars for the current resolution, so latch and z-score windows keep their duration across timeframes, and any series that fails to resolve drops out of the denominator instead of being scored as off.


█ [b]NOTES / LIMITATIONS[/b]

 • [b]Symbol independent.[/b] The composite ignores the chart symbol entirely. Every input is requested through [i]request.security[/i], so changing the chart instrument does not change the output. Only the chart timeframe matters.
 • [b]Timeframe sensitivity.[/b] Built for daily and higher, best on monthly. On intraday resolutions the month to bar conversion is clamped at 5000 bars and the windows no longer span the intended months, so the latch and z-score logic are not valid intraday.
 • [b]Data availability.[/b] The macro series depend on TradingView's data catalog and on your data access. SLOOS is quarterly, heavily lagged, and may not resolve in the FRED catalog. The OAS, CPI, and sentiment series are likewise subject to availability. Unresolved series return na and are excluded. The value and growth proxy symbols use an exchange prefix that may need changing to match your data.
 • [b]Insufficient history.[/b] The z-scores require their full lookback of observations before they return a value. Until then the Rule of 20 and sentiment signals are na and do not count. The value versus growth signal requires history at least as long as its return window on both proxies, otherwise it returns na.
 • [b]Economic data revisions.[/b] CPI, SLOOS, and sentiment are released with a lag and can be revised, so the most recent readings may change as the source updates. No bar level lookahead is used. The requests run with default settings and the latch references only historical values.
 • [b]Static manual P/E.[/b] If the trailing P/E is left as a manual constant, the Rule of 20 z-score reduces to a z-score of inflation plus a constant, since the only varying term is CPI. Enabling a symbol sourced trailing P/E restores the intended behavior.
 • [b]Correlated signals.[/b] These macro and valuation conditions tend to move together late in a cycle, so the percent reading reflects fewer independent pieces of information than the raw signal count suggests.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// Cyclical Peak Macro Composite
// Macro/valuation subset of a market-peak signal checklist: yield-curve
// inversion, HY OAS complacency, a Rule-of-20 valuation z-score, a value/growth
// style spread, SLOOS bank tightening, and (optional, off by default) a
// consumer-sentiment z-score proxy.
// The remaining signals of the original methodology are OMITTED because their
// inputs (Conference Board confidence, the proprietary Sell Side Indicator,
// IBES long-term growth, and M&A counts) have no TradingView data feed and no
// faithful proxy. Two proxies below substitute related-but-not-identical series
// and are labelled as such: the value/growth spread stands in for a low-PE vs
// high-PE basket, and the optional UMich z-score stands in for Conference Board
// consumer confidence. This is a faithful macro fragment, not the full list.
// Author: BY_Tse
// ─────────────────────────────────────────────────────────────────────────────
indicator("Cyclical Peak Macro Composite", shorttitle="Peak Macro", overlay=false, precision=1)

// ── Inputs ───────────────────────────────────────────────────────────────────
grpYC   = "Yield Curve"
yc10sym = input.symbol("US10Y", "10Y yield symbol", group=grpYC)
yc02sym = input.symbol("US02Y", "2Y yield symbol",  group=grpYC)

grpCR   = "Credit (HY OAS complacency)"
oasSym  = input.symbol("FRED:BAMLH0A0HYM2", "HY OAS symbol", group=grpCR)
oasThr  = input.float(3.5, "Tight-spread threshold (%)", step=0.1, group=grpCR, tooltip="Faithful to the source: a LOW spread is the complacency / peak signal. The signpost fires when HY OAS is BELOW this level.")

grpVAL  = "Rule of 20 (P/E + CPI YoY)"
peManual= input.float(22.0, "Trailing S&P 500 P/E", step=0.5, group=grpVAL)
usePeSym= input.bool(false, "Feed P/E from a symbol", group=grpVAL)
peSym   = input.symbol("SP:SPX", "P/E symbol (trailing)", group=grpVAL, tooltip="Used only when 'Feed P/E from a symbol' is on. A static manual P/E collapses the z-score into a CPI-only z-score plus a constant; a symbol carrying trailing P/E restores fidelity.")
zLenM   = input.int(120, "Z-score lookback (months)", minval=12, group=grpVAL)
zThr    = input.float(1.0, "Z-score trigger (>)", step=0.1, group=grpVAL)

grpVG   = "Value / Growth (low-PE vs high-PE proxy)"
valSym  = input.symbol("AMEX:SPYV", "Value proxy symbol", group=grpVG, tooltip="Style index, not a strict PE quintile. SPYV (S&P 500 Value) vs SPYG (S&P 500 Growth) approximates BofA's low-PE vs high-PE basket spread.")
groSym  = input.symbol("AMEX:SPYG", "Growth proxy symbol", group=grpVG)
vgM     = input.int(6, "Return window (months)", minval=1, group=grpVG)
vgThr   = input.float(2.5, "Underperformance trigger (pp)", step=0.5, group=grpVG, tooltip="Fires when the value proxy trails the growth proxy by more than this many percentage points over the return window.")

grpSL   = "SLOOS (bank lending)"
useSL   = input.bool(true, "Include SLOOS", group=grpSL)
slSym   = input.symbol("FRED:DRTSCILM", "SLOOS net-tightening symbol", group=grpSL, tooltip="Quarterly and lagged. May not resolve in TradingView's FRED catalog; if the symbol is invalid the signpost degrades to inactive (n/a) rather than erroring.")

grpUM   = "Consumer sentiment (optional, low fidelity)"
useUM   = input.bool(false, "Include sentiment proxy", group=grpUM, tooltip="OFF by default. UMich (UMCSENT) is NOT the Conference Board index from the source; the two diverge materially. This adds a sentiment axis at the cost of measuring a different series, so it is a proxy, not a replication.")
umSym   = input.symbol("FRED:UMCSENT", "Sentiment symbol", group=grpUM)
umThr   = input.float(1.0, "Sentiment z-score trigger (>)", step=0.1, group=grpUM, tooltip="High sentiment is the peak signal; the level threshold of the original (>110) is on a different scale, so a rolling z-score is used. Shares the Rule-of-20 lookback.")

grpGEN  = "Composite"
latchM  = input.int(6, "Latch window for 'prior 6m' signals (months)", minval=1, group=grpGEN)
alertPct= input.float(70.0, "Composite alert threshold (%)", step=5, group=grpGEN)

// ── Timeframe-robust months -> bars ──────────────────────────────────────────
// Keeps lookbacks anchored to real calendar months on any chart resolution.
monthSec = 2629800
m2b(int months) =>
    math.max(1, math.min(5000, math.round(months * monthSec / timeframe.in_seconds())))
bars6m = m2b(latchM)
barsZ  = m2b(zLenM)
barsVG = m2b(vgM)

// ── Data (optional feeds guarded with ignore_invalid_symbol) ─────────────────
y10    = request.security(yc10sym, timeframe.period, close)
y02    = request.security(yc02sym, timeframe.period, close)
spread = y10 - y02

oas    = request.security(oasSym, timeframe.period, close, ignore_invalid_symbol=true)

cpiYoY = request.security("FRED:CPIAUCSL", "1M", (close / close[12] - 1) * 100, ignore_invalid_symbol=true)
peSymV = request.security(peSym, "1M", close, ignore_invalid_symbol=true)
peVal  = usePeSym ? peSymV : peManual
r20    = peVal + cpiYoY
r20mu  = ta.sma(r20, barsZ)
r20sd  = ta.stdev(r20, barsZ)
r20z   = r20sd != 0 ? (r20 - r20mu) / r20sd : na

slRaw  = request.security(slSym, "3M", close, ignore_invalid_symbol=true)
slos   = useSL ? slRaw : na

vCl    = request.security(valSym, timeframe.period, close, ignore_invalid_symbol=true)
gCl    = request.security(groSym, timeframe.period, close, ignore_invalid_symbol=true)
vgRet  = not na(vCl) and not na(gCl) and not na(vCl[barsVG]) and not na(gCl[barsVG]) ? (vCl / vCl[barsVG] - gCl / gCl[barsVG]) * 100 : na

umRaw  = request.security(umSym, "1M", close, ignore_invalid_symbol=true)
umMu   = ta.sma(umRaw, barsZ)
umSd   = ta.stdev(umRaw, barsZ)
umZ    = umSd != 0 ? (umRaw - umMu) / umSd : na

// ── Signal logic ─────────────────────────────────────────────────────────────
ycCond = not na(spread) and spread < 0
crCond = not na(oas) and oas < oasThr

s_yc   = ta.highest(ycCond ? 1 : 0, bars6m) > 0   // inverted within latch window
s_cr   = ta.highest(crCond ? 1 : 0, bars6m) > 0   // spreads tight within latch window
s_val  = not na(r20z) and r20z > zThr             // current reading
s_vg   = not na(vgRet) and vgRet < -vgThr         // value underperforms growth, current reading
slAct  = useSL and not na(slos)
s_sl   = slAct and slos > 0                       // current reading
umAct  = useUM and not na(umZ)
s_um   = umAct and umZ > umThr                    // current reading

total  = 4 + (slAct ? 1 : 0) + (umAct ? 1 : 0)
hits   = (s_yc ? 1 : 0) + (s_cr ? 1 : 0) + (s_val ? 1 : 0) + (s_vg ? 1 : 0) + (s_sl ? 1 : 0) + (s_um ? 1 : 0)
pct    = total > 0 ? 100.0 * hits / total : na

// ── Plot ─────────────────────────────────────────────────────────────────────
pctCol = pct >= alertPct ? color.new(color.red, 0) : pct >= 50 ? color.new(color.orange, 0) : color.new(color.gray, 0)
plot(pct, title="% Triggered", style=plot.style_columns, color=pctCol)
hline(alertPct, "Alert threshold", color=color.new(color.red, 50), linestyle=hline.style_dashed)
hline(50, "Midline", color=color.new(color.gray, 60), linestyle=hline.style_dotted)

// Diagnostics (data window only, no clutter)
plot(spread, title="10Y-2Y spread (pp)",  color=color.new(color.blue, 0),    display=display.data_window)
plot(oas,    title="HY OAS (%)",           color=color.new(color.teal, 0),    display=display.data_window)
plot(r20,    title="Rule of 20 (PE+CPI)",  color=color.new(color.purple, 0),  display=display.data_window)
plot(r20z,   title="Rule of 20 z-score",   color=color.new(color.fuchsia, 0), display=display.data_window)
plot(slos,   title="SLOOS net tightening", color=color.new(color.maroon, 0),  display=display.data_window)
plot(vgRet,  title="Value-Growth 6m (pp)", color=color.new(color.olive, 0),   display=display.data_window)
plot(umZ,    title="Sentiment z-score",    color=color.new(color.navy, 0),    display=display.data_window)

// ── Status table ─────────────────────────────────────────────────────────────
var table t = table.new(position.top_right, 2, 8, border_width=1)
f_row(int r, string label, bool on, bool active) =>
    txt = not active ? "n/a" : on ? "ON" : "off"
    col = not active ? color.new(color.gray, 0) : on ? color.new(color.red, 0) : color.new(color.green, 0)
    table.cell(t, 0, r, label, text_size=size.small, text_halign=text.align_left, text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(t, 1, r, txt, text_size=size.small, text_color=color.white, bgcolor=col)

if barstate.islast
    table.cell(t, 0, 0, "Peak Macro Composite", text_size=size.small, text_halign=text.align_left, text_color=color.white, bgcolor=color.new(color.black, 40))
    table.cell(t, 1, 0, str.tostring(pct, "#.#") + "%", text_size=size.small, text_color=color.white, bgcolor=color.new(color.black, 40))
    f_row(1, "Yield curve inverted (latch)", s_yc, true)
    f_row(2, "HY OAS tight / complacent (latch)", s_cr, true)
    f_row(3, "Rule of 20 z > " + str.tostring(zThr), s_val, true)
    f_row(4, "Value trails growth > " + str.tostring(vgThr) + "pp", s_vg, true)
    f_row(5, "SLOOS net tightening", s_sl, slAct)
    f_row(6, "Sentiment z > " + str.tostring(umThr), s_um, umAct)

// ── Alerts (compile-time constant messages) ──────────────────────────────────
alertcondition(s_yc,  "Yield curve inverted (latch)",  "Yield curve inverted within the latch window")
alertcondition(s_cr,  "HY OAS complacency (latch)",    "HY OAS below the tight-spread threshold within the latch window")
alertcondition(s_val, "Rule of 20 z-score trigger",    "Rule of 20 (P/E + CPI YoY) z-score above trigger")
alertcondition(s_vg,  "Value underperforms growth",    "Value proxy trails growth proxy beyond the threshold over the return window")
alertcondition(s_sl,  "SLOOS net tightening",          "SLOOS shows net tightening of credit conditions")
alertcondition(s_um,  "Consumer sentiment elevated",   "Consumer sentiment z-score above trigger")
alertcondition(pct >= alertPct, "Composite alert threshold", "Macro signpost composite at or above alert threshold")
````
