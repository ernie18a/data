# Hindenburg Omen [Miekka Method]

- url: https://www.tradingview.com/script/BaSOru9I-Hindenburg-Omen-Miekka-Method/
- type: indicator
- pine_id: PUB;845676798a4e4ba5a2c3854fb924e350
- version: 2.0

## Description

[b]Hindenburg Omen [Miekka Method][/b]

This indicator implements Jim Miekka's original Hindenburg Omen methodology, correcting several errors found in most public implementations. It is a rewrite of QuantNomad's v4 Hindenburg Omen indicator, updated to Pine Script v6 with structural corrections to match Miekka's published specification.


═══════════════════════════════════════════════════════════════════


[b]WHAT THE HINDENBURG OMEN IS[/b]

The Hindenburg Omen is a market breadth indicator that flags periods of elevated crash risk. It detects a specific divergence condition: when an unusually large percentage of NYSE-listed stocks are simultaneously hitting 52-week highs AND 52-week lows. Under normal conditions, the market moves with some degree of uniformity. When both extremes spike at once during an uptrend, it suggests internal fracturing that has historically preceded significant drawdowns.

The indicator was developed by James R. Miekka in 1995 as a modified and restricted version of work originally published by Martin Zweig and later tweaked by Gerald Appel. It also draws on Norman G. Fosback's High Low Logic Index. Miekka was a high-school physics teacher who lost his eyesight after a laboratory explosion and complications from subsequent surgery. While recovering, he began studying the markets by listening to financial broadcasts. Because he could not see, he worked almost entirely with formulas rather than charts. He published the indicator through his newsletter, the [i]Sudbury Bull and Bear Report[/i].

The name was suggested by Kennedy Gammage, publisher of [i]The Richland Report[/i], who had a background in advertising and knew the value of a strong brand. Gammage was also familiar with Bill Ohama's "Titanic Syndrome," another indicator based on new highs and new lows data.

[b]Note:[/b] Claims that the Hindenburg Omen "predicted the crash of 1987" are retroactive backtests. Miekka did not develop the indicator until 1995.


═══════════════════════════════════════════════════════════════════


[b]HOW THIS IMPLEMENTATION DIFFERS FROM MOST[/b]

Most publicly available versions of the Hindenburg Omen contain errors that have been copied from source to source for years. This version corrects four material deviations from Miekka's specification:

[b]1. Threshold[/b]
Miekka specified [b]2.8%[/b] as the minimum percentage of NYSE issues that must be hitting new 52-week highs and lows simultaneously. Most implementations incorrectly use 2.2%. This script defaults to 2.8% but remains configurable.

[b]2. Denominator[/b]
Miekka defined the threshold as a percentage of [b]advances plus declines[/b] on the same day. Most implementations incorrectly use total issues traded (advances + declines + unchanged). An older version of the indicator used 2.5% of total issues, which may be the source of this confusion. This script uses advances + declines per Miekka's final specification.

[b]3. McClellan Oscillator role[/b]
This is the most significant correction. Most implementations treat a negative McClellan Oscillator as one of several conditions that must all fire on the same bar. Miekka's actual design is a [b]two-phase system[/b]:
    • [i]Phase 1 (Trigger):[/i] Breadth divergence and an uptrend must fire on the same bar, opening a 30-trading-day signal window.
    • [i]Phase 2 (Activation):[/i] Within that window, the omen is activated when the MCO is negative and deactivated when it turns positive.
The MCO is a gate, not a co-equal trigger.

[b]4. High/Low ratio filter[/b]
Many implementations include a condition requiring that new highs cannot exceed twice the number of new lows. This does not appear in Miekka's published methodology and has been removed.


═══════════════════════════════════════════════════════════════════


[b]HOW TO READ THE CHART[/b]

    • [b]Red triangle[/b] above a bar: A trigger has fired (breadth divergence + uptrend confirmed on that bar). This opens a 30-trading-day signal window.

    • [b]Dark maroon background:[/b] The omen is [b]active[/b]. You are inside a signal window and the McClellan Oscillator is negative. Per Miekka, this is the state where traders should consider going short or exiting long positions.

    • [b]Light orange background:[/b] A signal window is open but the MCO has turned positive, [b]temporarily deactivating[/b] the omen. The window has not expired, so if the MCO dips negative again before the 30 days are up, the omen reactivates and the background returns to maroon.

    • [b]No background:[/b] Either no trigger has fired recently or the 30-day window has expired.

A floating label on the last bar shows the current state of all conditions, the MCO value, and how many bars remain in any active window.

[b]Cluster interpretation:[/b] A single trigger in isolation is weaker than multiple triggers firing within a short timeframe. If you see repeated triggers clustering within a few weeks, that is historically a stronger warning than a single occurrence.


═══════════════════════════════════════════════════════════════════


[b]INPUTS[/b]

    • [b]New Highs/Lows Threshold %[/b] — Minimum percentage of NYSE advances + declines hitting new 52-week highs and lows. Default 2.8% per Miekka. Some analysts use 2.2%.
    • [b]Positive Trend Lookback[/b] — Number of trading days used to confirm the NYSE Composite is in an uptrend. Default 50.
    • [b]Signal Window[/b] — Number of trading days the signal window remains open after a trigger. Default 30.


═══════════════════════════════════════════════════════════════════


[b]ALERTS[/b]

Two alert conditions are available:
    • [b]Hindenburg Trigger:[/b] Fires when the breadth divergence and uptrend conditions are met on the same bar.
    • [b]Hindenburg Active:[/b] Fires when the omen is active (inside signal window with negative MCO).


═══════════════════════════════════════════════════════════════════


[b]LIMITATIONS[/b]

The Hindenburg Omen has a meaningful false positive rate. It fires more often than crashes actually occur. It should be used as one input in a broader risk assessment framework, not as a standalone trading signal. ETF proliferation on the NYSE has also introduced structural noise into the new highs/lows data, which can produce spurious triggers.


═══════════════════════════════════════════════════════════════════


[b]CREDITS[/b]

Originally based on QuantNomad's Hindenburg Omen v4 indicator. Rewritten for Pine Script v6 with structural corrections to align with Miekka's published methodology.

Primary sources:
    • Greg Morris, [i]The Complete Guide to Market Breadth Indicators[/i] (contains material written directly by Miekka)
    • Adaptiv Investments writeup documenting Miekka's formula
    • Tom McClellan's commentary at McClellan Financial Publications

## Source Code

````pine
// Hindenburg Omen [Miekka Method]
// Implements Jim Miekka's original two-phase methodology:
//   Phase 1 (Trigger): Conditions 1 & 2 must fire on the same bar to open a 30-trading-day signal window.
//   Phase 2 (Activation): Within that window, the omen is ACTIVE when the McClellan Oscillator is negative,
//                          and DEACTIVATED when the MCO turns positive.
//
// Corrections vs. common implementations:
//   - Threshold default is 2.8% per Miekka, not the widely misreported 2.2%
//   - Denominator is advances + declines (not total issues including unchanged)
//   - MCO is a gating mechanism within the signal window, not a co-equal trigger condition
//   - NH/NL ratio < 2 filter removed (not in Miekka's original specification)
//
// v2 changes:
//   - Replaced USI:ADV / USI:DECL with INDEX:ADVN / INDEX:DECN (NYSE advance/decline feeds,
//     consistent universe with INDEX:MAHN / INDEX:MALN). The USI feeds inherited from the
//     QuantNomad v4 base were the suspected cause of missing recent triggers.
//   - Added explicit na/data-integrity guard (data_ok) so stale or missing feeds surface
//     visibly in the label instead of silently suppressing triggers.
//   - Exposed newh_pct / newl_pct / MCO in the data window for empirical verification
//     against externally reported firing dates.

//@version=6
indicator("Hindenburg Omen [Miekka Method]", shorttitle = "HOmen [Miekka]", overlay = true, max_labels_count = 500)

////////////
// INPUTS //
////////////
float  new_low_high_threshold = input.float(2.8,  title = "New Highs/Lows Threshold %")
int    pos_trend_lookback     = input.int(50,      title = "Positive Trend Lookback (trading days)")
int    signal_window_days     = input.int(30,      title = "Signal Window (trading days)")

//////////////
// GET DATA //
//////////////
float nyse_adv       = request.security("INDEX:ADVN", "D", close)
float nyse_dec       = request.security("INDEX:DECN", "D", close)
float nyse_newh      = request.security("INDEX:MAHN", "D", close)
float nyse_newl      = request.security("INDEX:MALN", "D", close)
float nyse_comp_indx = request.security("NYA",        "D", close)

/////////////////////////
// DATA INTEGRITY GATE //
/////////////////////////
bool data_ok = not na(nyse_adv) and not na(nyse_dec) and not na(nyse_newh) and
     not na(nyse_newl) and not na(nyse_comp_indx)

///////////////////////////
// MCCLELLAN OSCILLATOR  //
///////////////////////////
float total_ad = nyse_adv + nyse_dec
float rana     = data_ok and total_ad > 0 ? 1000.0 * ((nyse_adv - nyse_dec) / total_ad) : na
float mcc_ema19 = ta.ema(rana, 19)
float mcc_ema39 = ta.ema(rana, 39)
float mcc       = mcc_ema19 - mcc_ema39

/////////////////////////////////////
// PHASE 1: TRIGGER CONDITIONS     //
/////////////////////////////////////
float newh_pct = data_ok and total_ad > 0 ? (nyse_newh / total_ad) * 100.0 : na
float newl_pct = data_ok and total_ad > 0 ? (nyse_newl / total_ad) * 100.0 : na

// Condition 1: Both new 52W highs AND new 52W lows exceed threshold % of advances + declines
bool cond1 = data_ok and not na(newh_pct) and not na(newl_pct) and
     newh_pct >= new_low_high_threshold and newl_pct >= new_low_high_threshold

// Condition 2: NYSE Composite is at or above its value from [lookback] trading days ago
bool cond2 = data_ok and not na(nyse_comp_indx[pos_trend_lookback]) and
     nyse_comp_indx >= nyse_comp_indx[pos_trend_lookback]

// Trigger fires when both conditions are met on the same bar
bool trigger = cond1 and cond2

////////////////////////////////////////
// PHASE 2: SIGNAL WINDOW & MCO GATE  //
////////////////////////////////////////
// Track bars since last trigger. If no trigger has ever occurred, set to a large number.
int bars_since_trigger = ta.barssince(trigger)
int safe_bars_since    = na(bars_since_trigger) ? signal_window_days + 1 : bars_since_trigger

// We are inside the signal window if a trigger occurred within the last N trading days
bool in_signal_window = safe_bars_since <= signal_window_days

// MCO gate: omen is active only when MCO is negative within the window
bool mco_negative = mcc < 0
bool omen_active  = in_signal_window and mco_negative

///////////
// PLOTS //
///////////
// Mark the bar where a new trigger fires (Phase 1)
plotshape(trigger, style = shape.triangledown, location = location.abovebar,
     color = color.red, text = "TRIGGER", textcolor = color.red, size = size.small)

// Background: signal window with MCO negative (omen active)
bgcolor(omen_active ? color.new(color.maroon, 80) : na)

// Background: signal window with MCO positive (omen deactivated, lighter shade for awareness)
bgcolor(in_signal_window and not mco_negative ? color.new(color.orange, 90) : na)

// Data-window diagnostics (not drawn on chart)
plot(newh_pct, title = "New Highs % of A+D", display = display.data_window)
plot(newl_pct, title = "New Lows % of A+D",  display = display.data_window)
plot(mcc,      title = "McClellan Oscillator", display = display.data_window)
plot(total_ad, title = "Advances + Declines",  display = display.data_window)

/////////////////////
// INFO LABEL      //
/////////////////////
string sep = "-----------------------------\n"

string status_str = not data_ok ? "DATA UNAVAILABLE" :
     omen_active ? "ACTIVE" :
     in_signal_window ? "WINDOW OPEN (MCO positive)" : "INACTIVE"

string data_str = data_ok ? "" : "WARNING: one or more breadth feeds returning na on this bar\n" + sep

string trigger_str = "Trigger: " + (trigger ? "FIRED" : str.tostring(safe_bars_since) + " bars ago") + "\n"

string cond1_str = "1) 52W H/L > " + str.tostring(new_low_high_threshold, "#.#") + "%: " +
     (cond1 ? "YES" : "NO") + "\n" +
     "   Highs: " + str.tostring(newh_pct, "#.#") + "%, Lows: " + str.tostring(newl_pct, "#.#") + "%\n"

string cond2_str = "2) Uptrend (idx >= idx[" + str.tostring(pos_trend_lookback) + "]): " +
     (cond2 ? "YES" : "NO") + "\n" +
     "   Now: " + str.tostring(nyse_comp_indx, "#.##") +
     ", Then: " + str.tostring(nyse_comp_indx[pos_trend_lookback], "#.##") + "\n"

string mco_str = "MCO Gate: " + str.tostring(mcc, "#.##") +
     (mco_negative ? " (negative, omen ON)" : " (positive, omen OFF)") + "\n"

string window_str = in_signal_window ?
     "Signal window: " + str.tostring(signal_window_days - safe_bars_since) + " bars remaining\n" :
     "No active signal window\n"

string label_text = "HINDENBURG OMEN: " + status_str + "\n" +
     sep + data_str + trigger_str + sep + cond1_str + sep + cond2_str + sep + mco_str + sep + window_str

if barstate.islast
    label.new(bar_index + 3, close, label_text,
         xloc = xloc.bar_index, yloc = yloc.price,
         color = not data_ok ? color.gray : omen_active ? color.red : color.blue,
         textcolor = color.white, style = label.style_label_left,
         size = size.normal)

/////////////
// ALERTS  //
/////////////
alertcondition(trigger,      title = "Hindenburg Trigger",   message = "Hindenburg Omen: Trigger conditions (breadth divergence + uptrend) fired.")
alertcondition(omen_active,  title = "Hindenburg Active",    message = "Hindenburg Omen: Active (within signal window, MCO negative).")
````
