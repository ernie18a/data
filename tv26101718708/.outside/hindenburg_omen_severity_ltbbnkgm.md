# Hindenburg Omen [Severity]

- url: https://www.tradingview.com/script/LTBBnkGM-Hindenburg-Omen-Severity/
- type: indicator
- pine_id: PUB;39416eb913624d4a9717abe3ef30e397
- version: 1.0

## Description

[b]Hindenburg Omen [Miekka Method] - Severity Weighted[/b]

Most Hindenburg Omen implementations give you a binary answer: the omen fired or it didn't. This version tells you [b]how alarmed to be[/b]. It replaces the binary trigger with a continuous divergence intensity score that measures how far above the threshold both new highs and new lows have pushed, while preserving Miekka's original two-phase methodology in every other respect.

A bar where 8% of stocks are hitting new highs and 6% are hitting new lows is a fundamentally more alarming signal than one barely crossing 2.8% on both sides. This indicator makes that distinction visible.

This is the fourth in a series of Hindenburg Omen indicators built on Miekka's original specification. The first corrects the widely misimplemented NYSE version. The second adapts it to the S&P 500 to avoid ETF noise. The third combines multiple universes into a consensus framework. This version adds severity grading to the base NYSE indicator.


═══════════════════════════════════════════════════════════════════


[b]DIVERGENCE INTENSITY SCORE[/b]

The core addition is a single number:

[b]Divergence Intensity = min(new_highs_%, new_lows_%) / threshold[/b]

    • [b]1.0x[/b] means the weaker side is exactly at the threshold. Barely qualifying.
    • [b]1.5x[/b] means the weaker side is 50% above the threshold. Notable.
    • [b]2.0x[/b] means the weaker side is double the threshold. Severe.
    • [b]2.5x+[/b] is historically rare and indicates extreme breadth divergence.

The formula uses the [b]lesser[/b] of the two percentages (new highs % and new lows %) because the omen requires BOTH to exceed the threshold. The weaker side is the binding constraint. If new highs are at 8% but new lows are at 3%, the intensity is 3% / 2.8% = 1.07x. The extreme highs reading does not compensate for a barely qualifying lows reading.


═══════════════════════════════════════════════════════════════════


[b]HOW IT WORKS[/b]

The indicator preserves Miekka's two-phase structure exactly. Severity grading is layered on top without changing the underlying methodology.

[b]Phase 1: Trigger[/b]
A trigger fires when divergence intensity reaches 1.0x or higher (both new highs % and new lows % exceed the threshold) AND the NYSE Composite is in an uptrend (at or above its value from 50 trading days ago). This opens a 30-trading-day signal window, identical to the base indicator.

[b]Phase 2: Activation[/b]
Within the signal window, the omen is active when the McClellan Oscillator is negative and deactivated when it turns positive. The MCO is computed from NYSE advances and declines and acts as a sentiment gate, not a co-equal trigger condition.

[b]Severity Layer[/b]
The trigger is classified into tiers based on intensity at the moment it fires:
    • [b]TRIGGER[/b] (1.0x to 1.5x) — Threshold met. Standard Hindenburg signal.
    • [b]ELEVATED[/b] (1.5x to 2.0x) — Meaningfully above threshold on both sides.
    • [b]SEVERE[/b] (2.0x+) — Double the threshold or more. Historically uncommon.

The indicator also tracks the [b]peak intensity[/b] seen during each 30-day signal window. A window opened by a barely qualifying trigger that later sees a second, stronger trigger within the same window will reflect the higher reading. This matters because Miekka emphasized that clusters of signals within a window are stronger warnings than single occurrences.


═══════════════════════════════════════════════════════════════════


[b]HOW TO READ THE CHART[/b]

[b]Trigger Markers[/b]
    • [b]Yellow triangle "TRIGGER"[/b] — Intensity 1.0x to 1.5x. Standard threshold crossing.
    • [b]Orange triangle "ELEVATED"[/b] — Intensity 1.5x to 2.0x. Both sides meaningfully above threshold.
    • [b]Red triangle "SEVERE"[/b] — Intensity 2.0x or higher. Extreme breadth divergence.

[b]Background Shading[/b]
    • [b]Graded maroon/red background:[/b] The omen is [b]active[/b] (signal window open, MCO negative). The background intensity varies by the peak divergence score recorded during the current window. A window opened by a severe trigger has a deeper, more visible background than one opened by a marginal trigger. Per Miekka, this is the state where traders should consider going short or exiting long positions.

    • [b]Light orange background:[/b] A signal window is open but the MCO has turned positive, [b]temporarily deactivating[/b] the omen. If the MCO dips negative again before the 30 days expire, the omen reactivates.

    • [b]No background:[/b] No active signal window.

[b]Info Label[/b]
The floating label on the last bar shows:
    • Current divergence intensity and its severity classification
    • Raw new highs and new lows percentages with issue counts
    • Uptrend condition status with index values
    • McClellan Oscillator reading and gate status
    • Signal window status with bars remaining
    • Peak intensity recorded during the current window


═══════════════════════════════════════════════════════════════════


[b]PRACTICAL INTERPRETATION[/b]

Not all Hindenburg Omen triggers are equal. Here is how to think about the severity tiers:

[b]TRIGGER (1.0x to 1.5x):[/b] The threshold has been crossed, but not by much. This is the most common case and has the highest false positive rate. Worth noting, not worth panicking over. Watch for follow-up triggers within the 30-day window (cluster confirmation).

[b]ELEVATED (1.5x to 2.0x):[/b] Both new highs and new lows are meaningfully above the threshold. The market is showing real internal disagreement. Pay closer attention. If this clusters with other signals in the same window, the warning carries significantly more weight.

[b]SEVERE (2.0x+):[/b] Both sides are at double the threshold or beyond. This is historically uncommon and indicates extreme breadth divergence. When this coincides with a negative MCO, treat it as a high-priority risk management signal.

The intensity score also helps with near-misses. A reading of 0.9x means the market nearly triggered but fell just short. That context is useful even without a formal trigger.


═══════════════════════════════════════════════════════════════════


[b]INPUTS[/b]

    • [b]New Highs/Lows Threshold %[/b] — The baseline threshold for new 52-week highs and lows as a percentage of NYSE advances + declines. Default 2.8% per Miekka. The intensity score is computed relative to this value.
    • [b]Positive Trend Lookback[/b] — Number of trading days used to confirm the NYSE Composite is in an uptrend. Default 50.
    • [b]Signal Window[/b] — Number of trading days the signal window remains open after a trigger. Default 30.


═══════════════════════════════════════════════════════════════════


[b]ALERTS[/b]

Four alert conditions are available, allowing different notification urgencies for different severity levels:
    • [b]Severe Trigger:[/b] Fires only when intensity reaches 2.0x or higher.
    • [b]Elevated Trigger:[/b] Fires when intensity is between 1.5x and 2.0x.
    • [b]Any Trigger:[/b] Fires on any trigger at 1.0x or above.
    • [b]Omen Active:[/b] Fires when the omen is active (signal window open, MCO negative), regardless of the severity tier that opened the window.


═══════════════════════════════════════════════════════════════════


[b]METHODOLOGY NOTES[/b]

This indicator preserves all corrections from the base Hindenburg Omen [Miekka Method] indicator:
    • [b]Threshold:[/b] Default 2.8% per Miekka's specification, not the widely misreported 2.2%.
    • [b]Denominator:[/b] Advances + declines, not total issues traded (which includes unchanged).
    • [b]MCO role:[/b] Two-phase gating mechanism within a 30-day signal window, not a co-equal trigger condition.
    • [b]NH/NL ratio filter:[/b] Removed. Not in Miekka's published methodology.

The severity grading is an analytical enhancement layered on top of Miekka's structure. It does not add, remove, or modify any of his conditions. It simply measures how far above the threshold the trigger has pushed, information that was always present in the data but discarded by binary implementations.


═══════════════════════════════════════════════════════════════════


[b]DATA FEEDS[/b]

    • `INDEX:MAHN` — NYSE new 52-week highs count
    • `INDEX:MALN` — NYSE new 52-week lows count
    • `USI:ADV` — NYSE advancing issues
    • `USI:DECL` — NYSE declining issues
    • `NYA` — NYSE Composite Index


═══════════════════════════════════════════════════════════════════


[b]LIMITATIONS[/b]

    • [b]False positives:[/b] Even severe triggers can occur without subsequent declines. Severity grading reduces but does not eliminate false positives. Use as one input in a broader risk assessment framework.

    • [b]NYSE noise:[/b] This version runs against the full NYSE, which includes ETFs and structured products. For a cleaner universe, see the S&P 500 variant or the Multi-Universe Consensus variant in this series.

    • [b]Intensity is relative to threshold:[/b] Changing the threshold input changes all intensity readings. A 1.5x reading at a 2.8% threshold (4.2% actual) represents different market conditions than a 1.5x reading at a 2.2% threshold (3.3% actual). Be aware of this when comparing across different threshold settings.

    • [b]Data availability:[/b] The NYSE breadth feeds have limited historical depth on TradingView. The indicator will not produce signals prior to the start of these feeds (approximately 2015).

    • [b]Not investment advice:[/b] This indicator is a technical analysis tool. It does not constitute financial advice. Always conduct your own research and consult qualified professionals before making investment decisions.


═══════════════════════════════════════════════════════════════════


[b]BACKGROUND[/b]

The Hindenburg Omen was developed by James R. Miekka in 1995 as a modified and restricted version of work originally published by Martin Zweig and later tweaked by Gerald Appel. It also draws on Norman G. Fosback's High Low Logic Index. Miekka was a high-school physics teacher who lost his eyesight after a laboratory explosion and worked almost entirely with formulas rather than charts. He published the indicator through his newsletter, the [i]Sudbury Bull and Bear Report[/i]. The name was suggested by Kennedy Gammage, publisher of [i]The Richland Report[/i]. Miekka passed away in 2014.

Claims that the Hindenburg Omen "predicted the crash of 1987" are retroactive backtests. Miekka did not develop the indicator until 1995.


═══════════════════════════════════════════════════════════════════


[b]CREDITS[/b]

Part of the Hindenburg Omen [Miekka Method] series. Originally based on QuantNomad's Hindenburg Omen v4 indicator. Rewritten for Pine Script v6 with structural corrections to align with Miekka's published methodology.

Primary sources:
    • Greg Morris, [i]The Complete Guide to Market Breadth Indicators[/i] (contains material written directly by Miekka)
    • Adaptiv Investments writeup documenting Miekka's original formula
    • Tom McClellan's commentary at McClellan Financial Publications

## Source Code

````pine
// Hindenburg Omen [Miekka Method] - Severity Weighted
// Enhances Miekka's two-phase methodology with a continuous divergence intensity
// score rather than a binary trigger. Tells you not just WHETHER the omen fired,
// but HOW ALARMED to be.
//
// Divergence Intensity = min(newh_pct, newl_pct) / threshold
//   1.0 = barely qualifying trigger
//   2.0 = double the threshold on both sides
//   3.0+ = extreme divergence, historically rare
//
// The score uses the lesser of the two percentages because the omen requires
// BOTH highs and lows to exceed the threshold. The weaker side is the binding
// constraint and determines the true severity.
//
// Two-phase logic per Miekka:
//   Phase 1 (Trigger): Divergence intensity >= 1.0 AND uptrend opens a 30-day window.
//   Phase 2 (Activation): Within that window, omen is ON when MCO < 0, OFF when MCO >= 0.
//
// Corrections vs. common implementations:
//   - Threshold default is 2.8% per Miekka, not the widely misreported 2.2%
//   - Denominator is advances + declines (not total issues including unchanged)
//   - MCO is a gating mechanism within the signal window, not a co-equal trigger condition
//   - NH/NL ratio < 2 filter removed (not in Miekka's original specification)

//@version=6
indicator("Hindenburg Omen [Severity]", shorttitle = "HOmen [Severity]", overlay = true, max_labels_count = 500)

////////////
// INPUTS //
////////////
float  threshold          = input.float(2.8,  title = "New Highs/Lows Threshold %")
int    pos_trend_lookback = input.int(50,      title = "Positive Trend Lookback (trading days)")
int    signal_window_days = input.int(30,      title = "Signal Window (trading days)")

//////////////
// GET DATA //
//////////////
float nyse_adv  = request.security("USI:ADV",      "D", close)
float nyse_dec  = request.security("USI:DECL",     "D", close)
float nyse_newh = request.security("INDEX:MAHN",   "D", close)
float nyse_newl = request.security("INDEX:MALN",   "D", close)
float nyse_idx  = request.security("NYA",          "D", close)

///////////////////////////
// MCCLELLAN OSCILLATOR  //
///////////////////////////
float total_ad  = nyse_adv + nyse_dec
float rana      = total_ad != 0 ? 1000.0 * ((nyse_adv - nyse_dec) / total_ad) : 0.0
float mcc_ema19 = ta.ema(rana, 19)
float mcc_ema39 = ta.ema(rana, 39)
float mcc       = mcc_ema19 - mcc_ema39

/////////////////////////////////////
// DIVERGENCE INTENSITY            //
/////////////////////////////////////
float newh_pct = total_ad != 0 ? (nyse_newh / total_ad) * 100.0 : 0.0
float newl_pct = total_ad != 0 ? (nyse_newl / total_ad) * 100.0 : 0.0

// Intensity is the binding constraint (weaker side) normalized to the threshold
// 1.0 = exactly at threshold, 2.0 = double, etc.
// Below 1.0 means threshold not met (no trigger)
float divergence_intensity = threshold != 0 ? math.min(newh_pct, newl_pct) / threshold : 0.0

// Uptrend condition
bool cond_uptrend = nyse_idx >= nyse_idx[pos_trend_lookback]

// Trigger fires when intensity >= 1.0 AND uptrend confirmed
bool trigger = divergence_intensity >= 1.0 and cond_uptrend

// Capture the intensity at trigger for use during the window
var float trigger_intensity = 0.0
if trigger
    trigger_intensity := divergence_intensity

/////////////////////////////////////
// PHASE 2: SIGNAL WINDOW & MCO   //
/////////////////////////////////////
int bars_since_trigger = ta.barssince(trigger)
int safe_bars_since    = na(bars_since_trigger) ? signal_window_days + 1 : bars_since_trigger

bool in_signal_window = safe_bars_since <= signal_window_days
bool mco_neg          = mcc < 0
bool omen_active      = in_signal_window and mco_neg

/////////////////////////////////////
// PEAK TRACKING                   //
/////////////////////////////////////
// Track highest intensity seen within the current signal window
var float window_peak_intensity = 0.0
if trigger
    window_peak_intensity := divergence_intensity
else if in_signal_window and divergence_intensity >= 1.0
    window_peak_intensity := math.max(window_peak_intensity, divergence_intensity)
else if not in_signal_window
    window_peak_intensity := 0.0

///////////
// PLOTS //
///////////
// Trigger markers color-graded by intensity
color trigger_color = trigger ?
     divergence_intensity >= 2.5 ? color.new(color.red, 0) :
     divergence_intensity >= 2.0 ? color.new(color.red, 20) :
     divergence_intensity >= 1.5 ? color.new(color.orange, 10) :
     color.new(color.yellow, 10) :
     na

plotshape(trigger and divergence_intensity >= 2.0, style = shape.triangledown, location = location.abovebar,
     color = trigger_color, text = "SEVERE", textcolor = color.red, size = size.small)
plotshape(trigger and divergence_intensity >= 1.5 and divergence_intensity < 2.0, style = shape.triangledown, location = location.abovebar,
     color = trigger_color, text = "ELEVATED", textcolor = color.orange, size = size.small)
plotshape(trigger and divergence_intensity >= 1.0 and divergence_intensity < 1.5, style = shape.triangledown, location = location.abovebar,
     color = trigger_color, text = "TRIGGER", textcolor = color.yellow, size = size.small)

// Background graded by severity during active omen
color active_bg = omen_active ?
     window_peak_intensity >= 2.5 ? color.new(color.red, 70) :
     window_peak_intensity >= 2.0 ? color.new(color.maroon, 75) :
     window_peak_intensity >= 1.5 ? color.new(color.maroon, 80) :
     color.new(color.maroon, 85) :
     na

bgcolor(active_bg)

// Window open but MCO positive
bgcolor(in_signal_window and not mco_neg ? color.new(color.orange, 90) : na)

/////////////////////////////////////
// DIVERGENCE INTENSITY PLOT       //
/////////////////////////////////////
// Separate pane showing the continuous intensity score
// Visible via TradingView's "Move to new pane" option
var line threshold_line = na

/////////////////////
// INFO LABEL      //
/////////////////////
string sep = "-----------------------------\n"

string severity_label = divergence_intensity >= 2.5 ? "EXTREME" :
     divergence_intensity >= 2.0 ? "SEVERE" :
     divergence_intensity >= 1.5 ? "ELEVATED" :
     divergence_intensity >= 1.0 ? "THRESHOLD MET" :
     divergence_intensity >= 0.7 ? "APPROACHING" :
     "LOW"

string status_str = omen_active ? "ACTIVE (" + severity_label + ")" :
     in_signal_window ? "WINDOW OPEN (MCO positive)" : "INACTIVE"

string intensity_str = "Divergence Intensity: " + str.tostring(divergence_intensity, "#.##") +
     "x (" + severity_label + ")\n"

string breadth_str = "New Highs: " + str.tostring(newh_pct, "#.#") + "% (" +
     str.tostring(nyse_newh, "#") + " issues)\n" +
     "New Lows: " + str.tostring(newl_pct, "#.#") + "% (" +
     str.tostring(nyse_newl, "#") + " issues)\n" +
     "Threshold: " + str.tostring(threshold, "#.#") + "%\n"

string uptrend_str = "Uptrend (idx >= idx[" + str.tostring(pos_trend_lookback) + "]): " +
     (cond_uptrend ? "YES" : "NO") + "\n" +
     "   Now: " + str.tostring(nyse_idx, "#.##") +
     ", Then: " + str.tostring(nyse_idx[pos_trend_lookback], "#.##") + "\n"

string mco_str = "MCO: " + str.tostring(mcc, "#.##") +
     (mco_neg ? " (negative, gate OPEN)" : " (positive, gate CLOSED)") + "\n"

string window_str = in_signal_window ?
     "Signal window: " + str.tostring(signal_window_days - safe_bars_since) + " bars remaining\n" +
     "Peak intensity this window: " + str.tostring(window_peak_intensity, "#.##") + "x\n" :
     "No active signal window\n"

string trigger_str = trigger ? "TRIGGER FIRED this bar\n" :
     in_signal_window ? "Last trigger: " + str.tostring(safe_bars_since) + " bars ago\n" :
     "No recent trigger\n"

string label_text = "HINDENBURG SEVERITY: " + status_str + "\n" +
     sep + intensity_str + sep + breadth_str + sep + uptrend_str +
     sep + mco_str + sep + window_str + sep + trigger_str

if barstate.islast
    label.new(bar_index + 3, close, label_text,
         xloc = xloc.bar_index, yloc = yloc.price,
         color = omen_active ?
              (window_peak_intensity >= 2.0 ? color.red : color.maroon) :
              color.blue,
         textcolor = color.white, style = label.style_label_left,
         size = size.normal)

/////////////
// ALERTS  //
/////////////
alertcondition(trigger and divergence_intensity >= 2.0,
     title = "Severe Trigger",
     message = "Hindenburg Omen: SEVERE trigger fired (intensity >= 2.0x threshold).")
alertcondition(trigger and divergence_intensity >= 1.5 and divergence_intensity < 2.0,
     title = "Elevated Trigger",
     message = "Hindenburg Omen: ELEVATED trigger fired (intensity 1.5-2.0x threshold).")
alertcondition(trigger,
     title = "Any Trigger",
     message = "Hindenburg Omen: Trigger fired (intensity >= 1.0x threshold).")
alertcondition(omen_active,
     title = "Omen Active",
     message = "Hindenburg Omen: Active (signal window open, MCO negative).")
````
