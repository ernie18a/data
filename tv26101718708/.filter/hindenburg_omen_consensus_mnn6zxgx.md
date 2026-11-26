# Hindenburg Omen [Consensus]

- url: https://www.tradingview.com/script/mNn6ZXgX-Hindenburg-Omen-Consensus/
- type: indicator
- pine_id: PUB;7375011ea0cb42c48e96de08ccfc0df2
- version: 1.0

## Description

[b]Hindenburg Omen [Miekka Method] - Multi-Universe Consensus[/b]

This indicator runs Jim Miekka's two-phase Hindenburg Omen methodology independently across multiple market universes (NYSE, S&P 500, and optionally NASDAQ) and only signals when two or more universes agree. Cross-universe consensus filters out noise specific to any single exchange, producing fewer but higher-conviction warnings of genuine broad-market fracturing.

This is the third in a series of Hindenburg Omen indicators built on Miekka's original specification. The first corrects the widely misimplemented NYSE version. The second adapts it to the S&P 500 to avoid ETF noise. This version combines both (and optionally NASDAQ) into a consensus framework.


═══════════════════════════════════════════════════════════════════


[b]WHY CONSENSUS[/b]

Every single-universe breadth indicator has blind spots:

    • [b]NYSE[/b] is polluted by ETFs, closed-end funds, preferred shares, and structured products that inflate the new highs and new lows counts with cross-asset noise. A bond ETF hitting a new low while equities rally is not the breadth divergence Miekka intended to detect.

    • [b]S&P 500[/b] is curated and clean (no ETFs, no structured products), but it only covers ~503 large-cap names. It misses mid-cap and small-cap weakness, and its small universe means a handful of stocks can push the percentages around.

    • [b]NASDAQ[/b] skews heavily toward technology and growth. Breadth divergence on NASDAQ alone may reflect sector rotation rather than broad-market stress.

When two or more of these universes independently show breadth divergence during an uptrend, the signal is far more likely to represent genuine market-wide fracturing rather than an artifact of one exchange's composition. This is also philosophically consistent with Miekka's own emphasis on cluster confirmation as a stronger warning than a single signal.


═══════════════════════════════════════════════════════════════════


[b]HOW IT WORKS[/b]

The indicator applies Miekka's two-phase methodology independently to each enabled universe:

[b]Phase 1: Trigger (per universe)[/b]
Two conditions must fire on the same bar to open a 30-trading-day signal window for that universe:
    • [b]Breadth divergence:[/b] Both new 52-week highs and new 52-week lows must each exceed a threshold percentage of the universe's issue count.
    • [b]Uptrend:[/b] The universe's benchmark index must be at or above its value from 50 trading days ago.

Each universe has its own threshold and denominator:
    • [b]NYSE:[/b] 2.8% of advances + declines (per Miekka's original specification)
    • [b]S&P 500:[/b] 4.7% of ~503 fixed constituent count
    • [b]NASDAQ:[/b] 2.8% of ~3,300 estimated composite count

[b]Phase 2: Activation (global)[/b]
The indicator counts how many universes currently have open signal windows. When that count meets or exceeds the minimum consensus threshold (default: 2) AND the McClellan Oscillator is negative, the omen is active.

The MCO is computed from NYSE breadth data globally, as TradingView does not provide per-universe advance/decline feeds for the S&P 500 or NASDAQ. It acts as a sentiment gate within the consensus window, not a co-equal trigger condition.


═══════════════════════════════════════════════════════════════════


[b]HOW TO READ THE CHART[/b]

    • [b]Red "CONSENSUS" triangle[/b] above a bar: Multiple universes triggered on the same bar, meeting the consensus threshold. This is the strongest single-bar signal.

    • [b]Gray dot[/b] above a bar: A single universe triggered but consensus was not reached. Provides context on which universes are showing stress even when the full consensus signal has not fired.

    • [b]Dark maroon background:[/b] The omen is [b]active[/b]. Enough universes have overlapping open signal windows and the McClellan Oscillator is negative. Per Miekka, this is the state where traders should consider going short or exiting long positions.

    • [b]Light orange background:[/b] Enough universes have overlapping windows (consensus reached) but the MCO has turned positive, [b]temporarily deactivating[/b] the omen. If the MCO dips negative again before the windows expire, the omen reactivates.

    • [b]No background:[/b] Either not enough universes have open windows or all windows have expired.

The floating label on the last bar shows the full status of each universe: whether its window is open, its current new highs/lows percentages versus its threshold, the MCO reading, and the consensus score.

[b]Important:[/b] Consensus is scored at the [b]window level[/b], not the trigger level. The indicator asks "how many universes currently have an open 30-day signal window?" rather than "how many triggered on this exact bar?" Triggers across universes will not necessarily land on the same day, but overlapping windows indicate the same underlying stress.


═══════════════════════════════════════════════════════════════════


[b]INPUTS[/b]

[b]General[/b]
    • [b]Positive Trend Lookback[/b] — Trading days used to confirm the uptrend condition for each universe. Default 50.
    • [b]Signal Window[/b] — Trading days each universe's signal window remains open after a trigger. Default 30.
    • [b]Minimum Universes for Consensus[/b] — How many universes must have overlapping open windows before the consensus signal fires. Default 2. Range 1-3. Set to 1 to see individual universe signals without consensus filtering.

[b]NYSE[/b]
    • [b]Enable NYSE[/b] — Toggle this universe on or off. Default on.
    • [b]NYSE Threshold %[/b] — Minimum percentage of advances + declines hitting new 52-week highs and lows. Default 2.8% per Miekka.

[b]S&P 500[/b]
    • [b]Enable S&P 500[/b] — Toggle this universe on or off. Default on.
    • [b]S&P 500 Threshold %[/b] — Minimum percentage of S&P 500 constituents hitting new 52-week highs and lows. Default 4.7%.
    • [b]S&P 500 Constituent Count[/b] — Denominator for percentage calculation. Default 503.

[b]NASDAQ (Unverified Symbols)[/b]
    • [b]Enable NASDAQ[/b] — Toggle this universe on or off. [b]Default off.[/b] The data symbols `INDEX:MAHQ` and `INDEX:MALQ` are unverified on TradingView. Enable this only after confirming these symbols return valid data on your TradingView plan. If they return no data, the NASDAQ universe will not contribute to consensus.
    • [b]NASDAQ Threshold %[/b] — Minimum percentage of NASDAQ composite issues. Default 2.8%.


═══════════════════════════════════════════════════════════════════


[b]ALERTS[/b]

Two alert conditions are available:
    • [b]Consensus Trigger:[/b] Fires when enough universes trigger on the same bar to meet the consensus threshold.
    • [b]Consensus Active:[/b] Fires when the consensus omen is active (enough overlapping windows + negative MCO).


═══════════════════════════════════════════════════════════════════


[b]DATA FEEDS[/b]

[b]NYSE[/b]
    • `INDEX:MAHN` — NYSE new 52-week highs count
    • `INDEX:MALN` — NYSE new 52-week lows count
    • `USI:ADV` — NYSE advancing issues (also used for global MCO)
    • `USI:DECL` — NYSE declining issues (also used for global MCO)
    • `NYA` — NYSE Composite Index

[b]S&P 500[/b]
    • `INDEX:MAHP` — S&P 500 new 52-week highs count
    • `INDEX:MALP` — S&P 500 new 52-week lows count
    • `SP:SPX` — S&P 500 Index

[b]NASDAQ[/b]
    • `INDEX:MAHQ` — NASDAQ new 52-week highs count [i](unverified)[/i]
    • `INDEX:MALQ` — NASDAQ new 52-week lows count [i](unverified)[/i]
    • `NASDAQ:IXIC` — NASDAQ Composite Index


═══════════════════════════════════════════════════════════════════


[b]LIMITATIONS[/b]

    • [b]False positives:[/b] Even with consensus filtering, the Hindenburg Omen can fire without a subsequent decline. It should be used as one input in a broader risk assessment framework, not as a standalone trading signal.

    • [b]Hybrid MCO:[/b] The McClellan Oscillator is computed from NYSE breadth data and applied globally across all universes. No per-universe MCO is available on TradingView.

    • [b]NASDAQ symbols unverified:[/b] The `INDEX:MAHQ` and `INDEX:MALQ` symbols follow the observed naming convention but have not been confirmed to return valid data. NASDAQ is disabled by default for this reason.

    • [b]Thresholds not backtested:[/b] The default thresholds (2.8% NYSE, 4.7% S&P 500, 2.8% NASDAQ) are starting points. The NYSE value is Miekka's original. The S&P 500 value is empirically chosen for the smaller, curated universe. Users should evaluate signal quality and adjust.

    • [b]Data availability:[/b] The breadth data feeds have limited historical depth on TradingView. The indicator will not produce signals prior to the start of these feeds (approximately 2015 for most).

    • [b]Not investment advice:[/b] This indicator is a technical analysis tool. It does not constitute financial advice. Always conduct your own research and consult qualified professionals before making investment decisions.


═══════════════════════════════════════════════════════════════════


[b]BACKGROUND[/b]

The Hindenburg Omen was developed by James R. Miekka in 1995 as a modified and restricted version of work originally published by Martin Zweig and later tweaked by Gerald Appel. It also draws on Norman G. Fosback's High Low Logic Index. Miekka was a high-school physics teacher who lost his eyesight after a laboratory explosion and worked almost entirely with formulas rather than charts. He published the indicator through his newsletter, the [i]Sudbury Bull and Bear Report[/i]. The name was suggested by Kennedy Gammage, publisher of [i]The Richland Report[/i]. Miekka passed away in 2014.

Claims that the Hindenburg Omen "predicted the crash of 1987" are retroactive backtests. Miekka did not develop the indicator until 1995.


═══════════════════════════════════════════════════════════════════


[b]CREDITS[/b]

Part of the Hindenburg Omen [Miekka Method] series. The NYSE version corrects structural errors in most public implementations. The S&P 500 version addresses ETF noise. This consensus version combines multiple universes to reduce false positives.

Originally based on QuantNomad's Hindenburg Omen v4 indicator. Rewritten for Pine Script v6.

Primary sources:
    • Greg Morris, [i]The Complete Guide to Market Breadth Indicators[/i] (contains material written directly by Miekka)
    • Adaptiv Investments writeup documenting Miekka's original formula
    • Tom McClellan's commentary at McClellan Financial Publications

## Source Code

````pine
// Hindenburg Omen [Miekka Method] - Multi-Universe Consensus
// Runs Miekka's two-phase methodology independently across up to three universes
// (NYSE, S&P 500, NASDAQ) and only signals when multiple universes agree.
//
// Cross-universe agreement filters out noise specific to any single exchange.
// NYSE is susceptible to ETF/CEF pollution. S&P 500 is curated but small.
// NASDAQ skews toward tech/growth. Agreement across universes indicates
// genuine broad-market fracturing rather than exchange-specific artifacts.
//
// NASDAQ symbols (INDEX:MAHQ / INDEX:MALQ) are unverified on TradingView.
// NASDAQ universe is disabled by default. Enable in settings after confirming
// the symbols return valid data on your TradingView plan.
//
// Two-phase logic per Miekka (applied independently per universe):
//   Phase 1 (Trigger): Breadth divergence + uptrend opens a 30-day signal window.
//   Phase 2 (Activation): Within that window, omen is ON when MCO < 0, OFF when MCO >= 0.
// MCO is computed from NYSE breadth globally (no per-universe MCO available).

//@version=6
indicator("Hindenburg Omen [Consensus]", shorttitle = "HOmen [Consensus]", overlay = true, max_labels_count = 500)

//////////////
// INPUTS   //
//////////////
string GRP_GENERAL = "General"
int    pos_trend_lookback = input.int(50,    title = "Positive Trend Lookback (trading days)", group = GRP_GENERAL)
int    signal_window_days = input.int(30,    title = "Signal Window (trading days)",           group = GRP_GENERAL)
int    min_consensus      = input.int(2,     title = "Minimum Universes for Consensus",        group = GRP_GENERAL, minval = 1, maxval = 3)

string GRP_NYSE = "NYSE"
bool   use_nyse           = input.bool(true, title = "Enable NYSE",                   group = GRP_NYSE)
float  nyse_threshold     = input.float(2.8, title = "NYSE Threshold %",              group = GRP_NYSE)

string GRP_SP500 = "S&P 500"
bool   use_sp500          = input.bool(true, title = "Enable S&P 500",                group = GRP_SP500)
float  sp500_threshold    = input.float(4.7, title = "S&P 500 Threshold %",           group = GRP_SP500)
int    sp500_count        = input.int(503,   title = "S&P 500 Constituent Count",     group = GRP_SP500)

string GRP_NASDAQ = "NASDAQ (Unverified Symbols)"
bool   use_nasdaq          = input.bool(false, title = "Enable NASDAQ",               group = GRP_NASDAQ)
float  nasdaq_threshold    = input.float(2.8,  title = "NASDAQ Threshold %",          group = GRP_NASDAQ)

//////////////
// GET DATA //
//////////////
// NYSE
float nyse_adv  = request.security("USI:ADV",      "D", close)
float nyse_dec  = request.security("USI:DECL",     "D", close)
float nyse_newh = request.security("INDEX:MAHN",   "D", close)
float nyse_newl = request.security("INDEX:MALN",   "D", close)
float nyse_idx  = request.security("NYA",          "D", close)

// S&P 500
float sp_newh   = request.security("INDEX:MAHP",   "D", close)
float sp_newl   = request.security("INDEX:MALP",   "D", close)
float sp_idx    = request.security("SP:SPX",       "D", close)

// NASDAQ (symbols unverified - may need adjustment)
float nq_newh   = request.security("INDEX:MAHQ",   "D", close)
float nq_newl   = request.security("INDEX:MALQ",   "D", close)
float nq_idx    = request.security("NASDAQ:IXIC",  "D", close)

///////////////////////////
// MCCLELLAN OSCILLATOR  //
///////////////////////////
// Global MCO from NYSE breadth (no per-universe MCO available)
float total_ad  = nyse_adv + nyse_dec
float rana      = total_ad != 0 ? 1000.0 * ((nyse_adv - nyse_dec) / total_ad) : 0.0
float mcc_ema19 = ta.ema(rana, 19)
float mcc_ema39 = ta.ema(rana, 39)
float mcc       = mcc_ema19 - mcc_ema39
bool  mco_neg   = mcc < 0

///////////////////////////////////////
// UNIVERSE TRIGGER LOGIC            //
///////////////////////////////////////
// NYSE: denominator = advances + declines per Miekka
float nyse_newh_pct = total_ad != 0 ? (nyse_newh / total_ad) * 100.0 : 0.0
float nyse_newl_pct = total_ad != 0 ? (nyse_newl / total_ad) * 100.0 : 0.0
bool  nyse_cond1    = nyse_newh_pct >= nyse_threshold and nyse_newl_pct >= nyse_threshold
bool  nyse_cond2    = nyse_idx >= nyse_idx[pos_trend_lookback]
bool  nyse_trigger  = use_nyse and nyse_cond1 and nyse_cond2

int   nyse_bst      = ta.barssince(nyse_trigger)
int   nyse_safe     = na(nyse_bst) ? signal_window_days + 1 : nyse_bst
bool  nyse_window   = use_nyse and nyse_safe <= signal_window_days

// S&P 500: denominator = fixed constituent count
float sp_newh_pct   = sp500_count != 0 ? (sp_newh / sp500_count) * 100.0 : 0.0
float sp_newl_pct   = sp500_count != 0 ? (sp_newl / sp500_count) * 100.0 : 0.0
bool  sp_cond1      = sp_newh_pct >= sp500_threshold and sp_newl_pct >= sp500_threshold
bool  sp_cond2      = sp_idx >= sp_idx[pos_trend_lookback]
bool  sp_trigger    = use_sp500 and sp_cond1 and sp_cond2

int   sp_bst        = ta.barssince(sp_trigger)
int   sp_safe       = na(sp_bst) ? signal_window_days + 1 : sp_bst
bool  sp_window     = use_sp500 and sp_safe <= signal_window_days

// NASDAQ: denominator = approximate composite count (~3300)
// This is a rough estimate; NASDAQ composite has ~3000-3500 listed securities
int   nasdaq_count  = 3300
float nq_newh_pct   = nasdaq_count != 0 ? (nq_newh / nasdaq_count) * 100.0 : 0.0
float nq_newl_pct   = nasdaq_count != 0 ? (nq_newl / nasdaq_count) * 100.0 : 0.0
bool  nq_cond1      = nq_newh_pct >= nasdaq_threshold and nq_newl_pct >= nasdaq_threshold
bool  nq_cond2      = nq_idx >= nq_idx[pos_trend_lookback]
bool  nq_trigger    = use_nasdaq and nq_cond1 and nq_cond2

int   nq_bst        = ta.barssince(nq_trigger)
int   nq_safe       = na(nq_bst) ? signal_window_days + 1 : nq_bst
bool  nq_window     = use_nasdaq and nq_safe <= signal_window_days

///////////////////////////////////////
// CONSENSUS SCORING                 //
///////////////////////////////////////
int active_universes  = (use_nyse ? 1 : 0) + (use_sp500 ? 1 : 0) + (use_nasdaq ? 1 : 0)
int trigger_count     = (nyse_trigger ? 1 : 0) + (sp_trigger ? 1 : 0) + (nq_trigger ? 1 : 0)
int window_count      = (nyse_window ? 1 : 0) + (sp_window ? 1 : 0) + (nq_window ? 1 : 0)

// Consensus trigger: enough universes triggered on this bar
bool consensus_trigger = trigger_count >= min_consensus

// Consensus window: enough universes have open windows simultaneously
bool consensus_window  = window_count >= min_consensus

// Omen active: consensus window open AND MCO negative
bool omen_active       = consensus_window and mco_neg

///////////
// PLOTS //
///////////
// Consensus trigger marker
plotshape(consensus_trigger, style = shape.triangledown, location = location.abovebar,
     color = color.red, text = "CONSENSUS", textcolor = color.red, size = size.small)

// Individual universe triggers (smaller markers for context)
plotshape(nyse_trigger and not consensus_trigger, style = shape.circle, location = location.abovebar,
     color = color.gray, size = size.tiny)
plotshape(sp_trigger and not consensus_trigger, style = shape.circle, location = location.abovebar,
     color = color.gray, size = size.tiny)
plotshape(nq_trigger and not consensus_trigger, style = shape.circle, location = location.abovebar,
     color = color.gray, size = size.tiny)

// Background: omen active (consensus + MCO negative)
bgcolor(omen_active ? color.new(color.maroon, 80) : na)

// Background: consensus window open but MCO positive
bgcolor(consensus_window and not mco_neg ? color.new(color.orange, 90) : na)

/////////////////////
// INFO LABEL      //
/////////////////////
string sep = "-----------------------------\n"

string status_str = omen_active ? "ACTIVE (" + str.tostring(window_count) + "/" + str.tostring(active_universes) + " universes)" :
     consensus_window ? "WINDOW OPEN (MCO positive)" : "INACTIVE"

string nyse_status = use_nyse ?
     "NYSE: " + (nyse_window ? "WINDOW" : "---") + (nyse_trigger ? " [TRIGGER]" : "") +
     "\n   H: " + str.tostring(nyse_newh_pct, "#.#") + "%, L: " + str.tostring(nyse_newl_pct, "#.#") +
     "% (thr: " + str.tostring(nyse_threshold, "#.#") + "%)\n" :
     "NYSE: disabled\n"

string sp_status = use_sp500 ?
     "S&P 500: " + (sp_window ? "WINDOW" : "---") + (sp_trigger ? " [TRIGGER]" : "") +
     "\n   H: " + str.tostring(sp_newh_pct, "#.#") + "%, L: " + str.tostring(sp_newl_pct, "#.#") +
     "% (thr: " + str.tostring(sp500_threshold, "#.#") + "%)\n" :
     "S&P 500: disabled\n"

string nq_status = use_nasdaq ?
     "NASDAQ: " + (nq_window ? "WINDOW" : "---") + (nq_trigger ? " [TRIGGER]" : "") +
     "\n   H: " + str.tostring(nq_newh_pct, "#.#") + "%, L: " + str.tostring(nq_newl_pct, "#.#") +
     "% (thr: " + str.tostring(nasdaq_threshold, "#.#") + "%)\n" :
     "NASDAQ: disabled\n"

string mco_str = "MCO (NYSE): " + str.tostring(mcc, "#.##") +
     (mco_neg ? " (negative, gate OPEN)" : " (positive, gate CLOSED)") + "\n"

string consensus_str = "Consensus: " + str.tostring(window_count) + "/" +
     str.tostring(active_universes) + " (need " + str.tostring(min_consensus) + ")\n"

string label_text = "HINDENBURG CONSENSUS: " + status_str + "\n" +
     sep + consensus_str + sep + nyse_status + sep + sp_status + sep + nq_status + sep + mco_str

if barstate.islast
    label.new(bar_index + 3, close, label_text,
         xloc = xloc.bar_index, yloc = yloc.price,
         color = omen_active ? color.red : color.blue,
         textcolor = color.white, style = label.style_label_left,
         size = size.normal)

/////////////
// ALERTS  //
/////////////
alertcondition(consensus_trigger, title = "Consensus Trigger",  message = "Hindenburg Omen: Consensus trigger fired across multiple universes.")
alertcondition(omen_active,       title = "Consensus Active",   message = "Hindenburg Omen: Consensus active (multiple universes + MCO negative).")
````
