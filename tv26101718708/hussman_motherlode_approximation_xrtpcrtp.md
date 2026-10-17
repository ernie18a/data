# Hussman Motherlode Approximation

- url: https://www.tradingview.com/script/xRtpCRTp-Hussman-Motherlode-Approximation/
- type: indicator
- pine_id: PUB;10dbeddeabc5441abbaa571bd9bb7c3a
- version: 2.0

## Description

█ [b]OVERVIEW[/b]

This indicator approximates John Hussman's "Motherlode" composite, which flags conditions historically present at intermediate market peaks: overextended price action coinciding with deteriorating internal breadth. The composite draws red vertical lines when multiple breadth-divergence signals fire within a configurable lookback window.

The core composite requires joint occurrence of a confirmed Hindenburg Omen (Miekka two-phase method) and a Titanic Syndrome within 20 trading sessions. An optional Phase Transition proxy can be toggled on for a stricter three-signal requirement.


█ [b]SIGNALS[/b]

[b]Hindenburg Omen (Miekka Two-Phase)[/b]
Implements Jim Miekka's original two-phase methodology using NYSE breadth data:
 • [i]Phase 1 (Trigger):[/i] Both NYSE new 52-week highs and new 52-week lows exceed a threshold
   percentage of total issues (advancing + declining), while the index is trading at or above its
   level from N bars ago (uptrend filter). Both conditions must be true on the same bar.
 • [i]Phase 2 (Activation):[/i] Once triggered, a signal window opens for 30 bars. Within that window,
   the omen is ACTIVE when the McClellan Oscillator (computed via the Ratio-Adjusted Net Advances
   method from NYSE breadth) is negative, and INACTIVE when the MCO turns positive.

This two-phase approach reduces false signals relative to single-bar implementations by requiring
sustained breadth deterioration after the initial divergence.

[b]Titanic Syndrome[/b]
Fires when NYSE new 52-week lows exceed NYSE new 52-week highs within 7 trading days of the chart
instrument making a 52-week high. This captures the specific condition of declining breadth beneath
a surface of index-level strength, often driven by narrow leadership.

[b]Phase Transition Proxy (Optional)[/b]
Hussman's Phase Transition condition combines overvaluation, overbought price action, overbullish
sentiment, and rising yields. Since TradingView lacks direct feeds for valuation metrics and
Investors Intelligence sentiment data, this indicator approximates the condition using RSI
(overbought threshold) combined with an elevated 10-period smoothed NYSE advances ratio.

This proxy will overfire relative to Hussman's actual model. It is disabled in the composite by
default and should be treated as a rough filter, not a faithful reproduction. Enable it via the
"Require Phase Transition proxy" toggle in the Composite input group.


█ [b]WHAT IS NOT INCLUDED[/b]

Hussman's full Motherlode composite also requires at least one instance of his proprietary
Syndrome 63 or Syndrome 74 within the lookback window. These syndromes are referenced in his
weekly commentaries but their exact formulas have never been published. This indicator does not
attempt to fabricate them. The info table on the chart displays "Not Available" for this component
as a permanent reminder.

This means the indicator will produce more signals than Hussman's published charts. Treat it as a
superset: every Hussman signal would appear here, but not every signal here would appear in
Hussman's version.


█ [b]HOW TO USE[/b]

1 — Apply the indicator to a daily chart. It is designed for the S&P 500 ([symbol="SP:SPX"]SP:SPX[/symbol])
  but will function on any instrument since breadth data is pulled independently via
  `request.security()`. The uptrend filter and 52-week high detection use the chart instrument's
  own price data.

2 — Red vertical lines mark bars where the composite condition is active. The first bar of each
  new cluster draws a full-opacity line; sustained signal bars draw thinner, partially transparent
  lines so you can distinguish onset from continuation.

3 — Use the info table (top-right corner) to see which components are currently active and their
  raw values: McClellan Oscillator level, new highs/lows percentages, and Hindenburg Omen window
  status.

4 — For component-level debugging, enable the optional background shading toggles in the Display
  input group. These shade the chart background when individual signals are active:
 • Orange: Hindenburg Omen active (within window, MCO negative)
 • Purple: Titanic Syndrome firing
 • Blue: Phase Transition proxy firing


█ [b]INPUTS[/b]

[b]Hindenburg Omen (Miekka)[/b]
 • [i]NH/NL Threshold (%):[/i] Minimum percentage of total NYSE issues that both new highs and new
   lows must exceed. Default 2.8%.
 • [i]Uptrend Lookback (bars):[/i] The index must be at or above its close this many bars ago for the
   trigger to fire. Default 50 (roughly 10 weeks).
 • [i]Signal Window (bars):[/i] After a trigger, the MCO gate remains active for this many bars.
   Default 30.

[b]Titanic Syndrome[/b]
 • [i]Days from 52wk High:[/i] How recently the chart instrument must have made a 52-week high for the
   syndrome to be valid. Default 7.

[b]Phase Transition Proxy[/b]
 • [i]RSI Length / Overbought:[/i] Standard RSI parameters for the overbought condition. Defaults 14 / 70.
 • [i]Bull% Threshold:[/i] The 10-bar smoothed NYSE advances ratio must exceed this level. Default 55%.

[b]Composite[/b]
 • [i]Joint Signal Lookback:[/i] All required signals must have fired within this many bars. Default 20.
 • [i]Require Phase Transition proxy:[/i] Off by default. When enabled, the Phase Transition proxy must
   also fire within the lookback for the composite to activate.

[b]Display[/b]
 • Vertical line color and width.
 • Optional background shading for each individual component (all off by default).


█ [b]DATA FEEDS[/b]

The indicator pulls four NYSE breadth series via `request.security()`:
 • [symbol="INDEX:HIGN"]INDEX:HIGN[/symbol] — NYSE New 52-Week Highs
 • [symbol="INDEX:LOWN"]INDEX:LOWN[/symbol] — NYSE New 52-Week Lows
 • [symbol="INDEX:ADVN"]INDEX:ADVN[/symbol] — NYSE Advancing Issues
 • [symbol="INDEX:DECN"]INDEX:DECN[/symbol] — NYSE Declining Issues

These feeds require a TradingView plan that includes access to NYSE breadth indices. If they
resolve to `NaN`, the indicator will not produce signals.


█ [b]ALERTS[/b]

Four alert conditions are available:
 • [i]Motherlode Onset:[/i] Fires on the first bar of a new composite signal cluster.
 • [i]Hindenburg Trigger:[/i] Fires when Phase 1 trigger conditions are met.
 • [i]Hindenburg Active:[/i] Fires on every bar where the omen is active (within window, MCO negative).
 • [i]Titanic Syndrome:[/i] Fires when new lows exceed new highs near a 52-week high.


█ [b]LIMITATIONS[/b]

 • The Phase Transition proxy is a rough approximation. It lacks valuation data, Investors
   Intelligence survey data, and yield curve inputs that Hussman's actual model uses.
 • Syndromes 63 and 74 are not implemented. The composite will produce more signals than Hussman's
   published version.
 • The McClellan Oscillator is computed from NYSE breadth even when the chart instrument is not an
   NYSE-based index. This is by design (the MCO measures broad market internals) but worth noting.
 • The indicator draws `line` objects. TradingView limits these to 500 per indicator. On a daily
   chart with default settings this is unlikely to be a constraint, but very long histories or
   aggressive threshold settings could hit it.
 • Vertical lines render correctly on both arithmetic and logarithmic scale charts.


█ [b]REFERENCES[/b]

 • Hussman, J. "The Motherlode." Weekly Market Comment, November 20, 2021.
   [url=https://www.hussmanfunds.com/comment/mc211120/]hussmanfunds.com[/url]
 • Hussman, J. "The Phase Transition." Weekly Market Comment, July 30, 2007.
   [url=https://www.hussmanfunds.com/wmc/wmc070730.htm]hussmanfunds.com[/url]
 • Miekka, J. The Hindenburg Omen. Documented in the Sudbury Bull & Bear Report.


█ [b]DISCLAIMER[/b]

This indicator is an independent approximation. It is not affiliated with, endorsed by, or derived
from proprietary code of Hussman Strategic Advisors. Published signal history will not match
Hussman's charts exactly due to the omission of Syndromes 63/74 and the use of a Phase Transition
proxy rather than his actual model. Use at your own discretion as one input among many. This is not
financial advice.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © Hussman Motherlode Approximation v4
// Hindenburg Omen uses Miekka two-phase method with NYSE breadth.
// Titanic Syndrome + Phase Transition proxy round out the composite.
// Phase Transition momentum gate is selectable: RSI (default) or MACD-V
// (Spiroglou volatility-normalized momentum). MACD-V is the stricter,
// lower-frequency variant; harness testing (1970s-2026) showed it filters
// ~3.4x more onsets but failed to fire ahead of the 2025 tariff decline,
// so RSI remains the default.
// Syndromes 63/74 are Hussman proprietary and not implemented.
// Use on S&P 500 (SPX) daily chart.

//@version=6
indicator("Hussman Motherlode Approximation", overlay=true, max_lines_count=500, max_labels_count=500)

// ─── INPUTS ─────────────────────────────────────────────────────────────────
grp_ho      = "Hindenburg Omen (Miekka)"
ho_pct      = input.float(2.8, "NH/NL Threshold (%)",    minval=0.5, maxval=15.0, step=0.1, group=grp_ho, tooltip="Both new 52W highs and lows must exceed this % of advancing + declining issues")
ho_trendLB  = input.int(50,    "Uptrend Lookback (bars)", minval=10,  maxval=100, group=grp_ho, tooltip="Index must be >= its value this many bars ago")
ho_window   = input.int(30,    "Signal Window (bars)",    minval=5,   maxval=60,  group=grp_ho, tooltip="Miekka Phase 2: MCO gate active for this many bars after trigger")

grp_ts      = "Titanic Syndrome"
ts_hiLoDays = input.int(7,     "Days from 52wk High",     minval=1,   maxval=20, group=grp_ts)

grp_pt      = "Phase Transition Proxy"
pt_gate     = input.string("RSI", "Momentum Gate", options=["RSI", "MACD-V"], group=grp_pt, tooltip="RSI: classic overbought threshold. MACD-V: Spiroglou volatility-normalized momentum; stricter, fires roughly 3x less often")
pt_rsiLen   = input.int(14,    "RSI Length",              minval=5,   maxval=50, group=grp_pt)
pt_rsiOB    = input.float(70,  "RSI Overbought",          minval=50,  maxval=95, group=grp_pt)
pt_vFast    = input.int(12,    "MACD-V Fast EMA",         minval=1,   group=grp_pt)
pt_vSlow    = input.int(26,    "MACD-V Slow EMA",         minval=1,   group=grp_pt)
pt_vAtrLen  = input.int(26,    "MACD-V ATR Length",       minval=1,   group=grp_pt, tooltip="Spiroglou: keep equal to Slow EMA length")
pt_vThresh  = input.float(150, "MACD-V Overbought",       minval=50,  maxval=300, step=5, group=grp_pt)
pt_bullPct  = input.float(55,  "Bull% Threshold",         minval=40,  maxval=80, group=grp_pt, tooltip="Advances ratio proxy for bullish sentiment")

grp_comp    = "Composite"
lookback    = input.int(20,    "Joint Signal Lookback",   minval=5,   maxval=60, group=grp_comp)
requirePT   = input.bool(false, "Require Phase Transition proxy", group=grp_comp, tooltip="Off: composite = Hindenburg + Titanic only. On: all three must fire.")

grp_viz     = "Display"
vlineColor  = input.color(color.new(color.red, 0), "Vertical Line Color", group=grp_viz)
vlineWidth  = input.int(2,     "Vertical Line Width",     minval=1,   maxval=6, group=grp_viz)
showHObg    = input.bool(false, "BG shade: Hindenburg Omen active", group=grp_viz)
showTSbg    = input.bool(false, "BG shade: Titanic Syndrome",       group=grp_viz)
showPTbg    = input.bool(false, "BG shade: Phase Transition proxy",  group=grp_viz)

// ─── DATA ───────────────────────────────────────────────────────────────────
// NYSE breadth
float newHighs = request.security("INDEX:HIGN", timeframe.period, close)  // NYSE New 52W Highs
float newLows  = request.security("INDEX:LOWN", timeframe.period, close)  // NYSE New 52W Lows
float advances = request.security("INDEX:ADVN", timeframe.period, close)  // NYSE Advancing Issues
float declines = request.security("INDEX:DECN", timeframe.period, close)  // NYSE Declining Issues

float totalIssues = advances + declines

// ─── MCCLELLAN OSCILLATOR (RANA method, NYSE) ───────────────────────────────
float rana      = totalIssues != 0 ? 1000.0 * ((advances - declines) / totalIssues) : 0.0
float mcc_ema19 = ta.ema(rana, 19)
float mcc_ema39 = ta.ema(rana, 39)
float mcOsc     = mcc_ema19 - mcc_ema39

// ─── HINDENBURG OMEN (Miekka two-phase) ────────────────────────────────────
// Phase 1: Trigger - breadth divergence + uptrend on same bar
float newh_pct = totalIssues > 0 ? (newHighs / totalIssues) * 100.0 : 0.0
float newl_pct = totalIssues > 0 ? (newLows  / totalIssues) * 100.0 : 0.0

bool ho_cond1   = newh_pct >= ho_pct and newl_pct >= ho_pct
bool ho_cond2   = close >= close[ho_trendLB]
bool ho_trigger = ho_cond1 and ho_cond2

// Phase 2: Signal window with MCO gate
int  bars_since_trigger = ta.barssince(ho_trigger)
int  safe_bars_since    = na(bars_since_trigger) ? ho_window + 1 : bars_since_trigger
bool in_ho_window       = safe_bars_since <= ho_window
bool ho_active          = in_ho_window and mcOsc < 0

// ─── TITANIC SYNDROME ───────────────────────────────────────────────────────
// NYSE new lows > new highs within N days of chart instrument making a 52-week high
float high52wk = ta.highest(high, 252)
bool  nearHigh = false
for i = 0 to ts_hiLoDays - 1
    if high[i] >= high52wk[i]
        nearHigh := true

bool titanicSyndrome = newLows > newHighs and nearHigh

// ─── PHASE TRANSITION PROXY ────────────────────────────────────────────────
// Momentum gate (selectable) + elevated advances ratio
// Hussman's actual version uses valuations, Investors Intelligence, and yields
// RSI: fixed-threshold bounded oscillator (classic)
// MACD-V: Spiroglou volatility-normalized MACD, (EMA12-EMA26)/ATR(26)*100
float rsiVal   = ta.rsi(close, pt_rsiLen)
float emaFast  = ta.ema(close, pt_vFast)
float emaSlow  = ta.ema(close, pt_vSlow)
float atrV     = ta.atr(pt_vAtrLen)
float macdV    = atrV != 0 ? ((emaFast - emaSlow) / atrV) * 100.0 : na

bool momGate = false
if pt_gate == "RSI"
    momGate := rsiVal > pt_rsiOB
else
    momGate := not na(macdV) and macdV > pt_vThresh

float advRatio       = totalIssues > 0 ? (advances / totalIssues) * 100 : 50
float advRatioSmooth = ta.sma(advRatio, 10)
bool  phaseTransition = momGate and advRatioSmooth > pt_bullPct

// ─── COMPOSITE: MOTHERLODE APPROXIMATION ────────────────────────────────────
bool ho_recent = false
bool ts_recent = false
bool pt_recent = false

for i = 0 to lookback - 1
    if ho_active[i]
        ho_recent := true
    if titanicSyndrome[i]
        ts_recent := true
    if phaseTransition[i]
        pt_recent := true

bool motherlode = ho_recent and ts_recent and (not requirePT or pt_recent)

// ─── VISUALIZATION: VERTICAL LINES ─────────────────────────────────────────
bool ml_onset = motherlode and not motherlode[1]

if ml_onset
    line.new(bar_index, close, bar_index, close * 1.001, 
         xloc=xloc.bar_index, extend=extend.both, 
         color=vlineColor, width=vlineWidth, style=line.style_solid)

if motherlode and not ml_onset
    line.new(bar_index, close, bar_index, close * 1.001, 
         xloc=xloc.bar_index, extend=extend.both, 
         color=color.new(vlineColor, 60), width=math.max(1, vlineWidth - 1), style=line.style_solid)

// ─── OPTIONAL COMPONENT BG SHADING ─────────────────────────────────────────
bgcolor(showHObg and ho_active       ? color.new(color.orange, 88) : na, title="Hindenburg Active")
bgcolor(showTSbg and titanicSyndrome ? color.new(color.purple, 88) : na, title="Titanic Syndrome")
bgcolor(showPTbg and phaseTransition ? color.new(color.blue, 88)   : na, title="Phase Transition Proxy")

// ─── INFO TABLE ─────────────────────────────────────────────────────────────
var table infoTbl = table.new(position.top_right, 2, 9, 
     bgcolor=color.new(color.black, 80), border_width=1)

if barstate.islast
    table.cell(infoTbl, 0, 0, "Motherlode Approx.", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 0, motherlode ? "ACTIVE" : "Inactive", 
         text_color=motherlode ? color.red : color.green, text_size=size.small)

    table.cell(infoTbl, 0, 1, "Hindenburg (Miekka)", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 1, ho_active ? "Active" : in_ho_window ? "Window (MCO+)" : "No", 
         text_color=ho_active ? color.orange : color.gray, text_size=size.small)

    table.cell(infoTbl, 0, 2, "Titanic Syndrome", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 2, ts_recent ? "Yes" : "No", 
         text_color=ts_recent ? color.purple : color.gray, text_size=size.small)

    table.cell(infoTbl, 0, 3, "Phase Trans Proxy", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 3, pt_recent ? "Yes" : "No", 
         text_color=pt_recent ? color.blue : color.gray, text_size=size.small)

    table.cell(infoTbl, 0, 4, "PT Gate (" + pt_gate + ")", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 4, pt_gate == "RSI" ? str.tostring(rsiVal, "#.#") + " / " + str.tostring(pt_rsiOB, "#") : str.tostring(macdV, "#.#") + " / " + str.tostring(pt_vThresh, "#"), 
         text_color=momGate ? color.blue : color.gray, text_size=size.small)

    table.cell(infoTbl, 0, 5, "McClellan Osc", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 5, str.tostring(mcOsc, "#.##"), 
         text_color=mcOsc < 0 ? color.red : color.green, text_size=size.small)

    table.cell(infoTbl, 0, 6, "NH% / NL%", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 6, str.tostring(newh_pct, "#.#") + " / " + str.tostring(newl_pct, "#.#"), 
         text_color=color.white, text_size=size.small)

    table.cell(infoTbl, 0, 7, "HO Window", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 7, in_ho_window ? str.tostring(ho_window - safe_bars_since) + " bars left" : "Closed", 
         text_color=in_ho_window ? color.yellow : color.gray, text_size=size.small)

    table.cell(infoTbl, 0, 8, "Syndromes 63/74", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 8, "Not Available", text_color=color.gray, text_size=size.small)

// ─── ALERTS ─────────────────────────────────────────────────────────────────
alertcondition(ml_onset,        title="Motherlode Onset",         message="Hussman Motherlode approximation: composite signal fired.")
alertcondition(ho_trigger,      title="Hindenburg Trigger",       message="Hindenburg Omen (Miekka): trigger conditions met.")
alertcondition(ho_active,       title="Hindenburg Active",        message="Hindenburg Omen (Miekka): active (MCO negative in window).")
alertcondition(titanicSyndrome, title="Titanic Syndrome",         message="Titanic Syndrome: new lows > new highs near 52-week high.")
````
