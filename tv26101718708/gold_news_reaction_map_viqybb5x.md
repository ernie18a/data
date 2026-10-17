# Gold News Reaction Map

- url: https://www.tradingview.com/script/ViQyBB5X-Gold-News-Reaction-Map/
- type: indicator
- pine_id: PUB;23f625da103846c0936ac8cc0a8bdf73
- version: 1.0

## Description

WHAT THIS SCRIPT DOES

This indicator measures how price actually reacted to scheduled US economic releases: how far it moved in the first minutes after each release, whether that first move held or reversed, and how much wider the window was than the same clock window on a normal day.

It does not predict the next release. It shows what the previous ones did, and how many of them there were, so you can judge whether a sample is large enough to mean anything.

It was built for gold (XAU/USD), where US data drives much of the intraday volatility, but the measurements are generic and can be applied to any instrument that trades through the US morning session.

THE EVENTS

Ten release types are tracked, each with its own switch:

FOMC rate decision (2:00 PM New York)
FOMC minutes (2:00 PM)
CPI (8:30 AM)
PCE / Personal Income and Outlays (8:30 AM)
PPI (8:30 AM)
Employment Situation / NFP (8:30 AM)
Retail sales (8:30 AM)
ISM Manufacturing (10:00 AM)
ISM Services (10:00 AM)
Weekly jobless claims (8:30 AM)

Release dates are stored in the script rather than guessed from rules such as "the first Friday of the month". They come from the official calendars of the Federal Reserve, the Bureau of Labor Statistics, the Bureau of Economic Analysis, the Census Bureau and ISM, including the delayed and cancelled releases of the 2025 government shutdown. Times are New York times, so daylight saving is handled automatically.

HOW EACH RELEASE IS MEASURED

For every release, the script takes the price at the open of the release bar and measures:

First move: where price stands at the end of the first window (15 minutes by default), as a percentage of the pre-release price.

Follow-through: where price stands at the end of the second window (60 minutes by default).

Held or reversed: if the first move and the end of the window are on opposite sides of the pre-release price, the release is marked as reversed.

Range ratio: the high-to-low range of the window, divided by the average range of the same clock window on recent days that had no listed release at that time. A value of x2.0 means the window was twice as wide as a normal day at that hour. Comparing with the same clock time on normal days is fairer than comparing with the quiet hour before the release, because the US open is volatile on its own.

Each release is labelled on the chart with its name, both moves, the held or reversed status and the range ratio, and the measured window is shaded.

RELEASES THAT SHARE A MINUTE

CPI sometimes lands with retail sales, and NFP with retail sales. Releases published at the same minute are measured once, as one reaction. A setting decides whether that reaction is counted in the row of each release involved, or only releases that came out alone are counted, which is cleaner but gives a smaller sample. Weekly jobless claims are always counted only in weeks when no other listed release came out at the same minute; otherwise the reaction belongs to the bigger release.

READING THE PANEL

The summary panel lists every release type that is switched on, with:

n: the number of releases measured in the loaded history. Rows below the minimum sample (10 by default) are greyed and marked with an asterisk.
First move and follow-through: the average size of each move. Moves are averaged in percent, because gold's price has changed a lot over the sample, then converted to points at today's price.
Reversed: the share of releases where the first move did not hold.
Range: the average range ratio against normal days.

A second box shows the next listed release, a countdown to it, and what the previous releases of the same kind did.

SETTINGS

Events: a switch for each release type, and whether to count releases that shared their minute.
Measurement: the two windows, the number of normal days in the baseline, the minimum sample, and a start date for counting, so two settings can be compared over exactly the same period.
Display: labels, shaded windows, the panel, its text size and its position.

LIMITATIONS - PLEASE READ

It runs on minute charts whose timeframe divides 30 minutes (1, 2, 3, 5, 10, 15 or 30). The windows are rounded up to whole bars, so on a 30-minute chart a 15-minute first window becomes 30 minutes.

The sample is limited by the history your chart loads. Lower timeframes give more precise windows but fewer releases. A 30-minute chart covers more releases than a 15-minute one.

The release calendar is stored in the script. It currently runs to the end of 2027 for the main releases; dates that agencies had not yet published when this version was released will be added in later updates. If an agency moves a release, the script will measure the old time until it is updated.

Only the ten listed releases are known to the script. If an unlisted report, such as GDP, comes out at the same minute, its effect is included in the listed release's reaction.

It measures the reaction, not the surprise. It does not know the forecast, the actual figure or the revision, so it cannot tell a big miss from a small one.

Bars are evaluated only after they close, so nothing repaints. A release is skipped if the chart has no bar starting at the release time, for example on a holiday or inside a data gap.

The moves are measured from the open of the release bar. On some feeds the first tick of a release can arrive a moment before or after the bar opens.

ON PERFORMANCE CLAIMS

This publication makes no claim about trading results. It does not generate entries, exits or signals. It reports how price behaved around past releases, with the sample size beside every figure, so you can decide for yourself how much weight to give it. Past reactions do not guarantee future reactions.

ORIGINALITY

Economic-calendar overlays usually stop at marking the time of a release. The original work here is in the measurement: a stored calendar of official release times instead of rule-based guesses, a reaction measured in two windows with an explicit held-or-reversed test, a range ratio against the same clock window on release-free days rather than against the preceding hour, handling of releases that share the same minute, and a sample-size check on every row. The code is published open-source so every date and every rule can be inspected.

## Source Code

````pine
//@version=6
// Gold News Reaction Map — Consultya
// Measures how price actually reacted to scheduled US releases: how far
// it moved in the first minutes, whether that first move held or
// reversed, and how much wider the hour was than a normal hour at the
// same clock time. It does not predict the next release. It shows what
// the previous ones did, and how many of them there were.
// Release dates run to the end of 2027 (CPI, PPI, NFP and FOMC from the
// official 2027 calendars); retail sales and the first PCE releases of 2027
// will be added when their agencies publish them.
indicator("Gold News Reaction Map", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ══════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════
i_fomc = input.bool(true, "FOMC rate decision", group="Events", tooltip="2:00 PM New York time. Statement days from federalreserve.gov. The follow-through window includes the press conference at 2:30.")
i_min  = input.bool(true, "FOMC minutes", group="Events", tooltip="2:00 PM New York time, three weeks after each meeting. Past dates from federalreserve.gov; upcoming ones follow the Fed's three-week rule.")
i_cpi  = input.bool(true, "CPI", group="Events", tooltip="8:30 AM New York time. Dates from the bls.gov archive, including the delayed and cancelled releases of the 2025 shutdown.")
i_pce  = input.bool(true, "PCE (personal income and outlays)", group="Events", tooltip="8:30 AM New York time - the Fed's preferred inflation gauge. Dates and times from the BEA schedule; two post-shutdown catch-up releases came out at 10:00 and are placed there.")
i_ppi  = input.bool(true, "PPI", group="Events", tooltip="8:30 AM New York time. Dates from the bls.gov archive.")
i_nfp  = input.bool(true, "Employment Situation (NFP)", group="Events", tooltip="8:30 AM New York time. Exact dates from the bls.gov archive - not assumed to be the first Friday.")
i_ret  = input.bool(true, "Retail sales", group="Events", tooltip="8:30 AM New York time. Census release dates; annual-revision days are excluded.")
i_ismM = input.bool(true, "ISM Manufacturing", group="Events", tooltip="10:00 AM New York time, first business day of the month. 2026 dates from ismworld.org; other years from ISM's published business-day rule.")
i_ismS = input.bool(true, "ISM Services", group="Events", tooltip="10:00 AM New York time, third business day of the month. 2026 dates from ismworld.org; other years from ISM's published business-day rule.")
i_clm  = input.bool(true, "Weekly jobless claims", group="Events", tooltip="8:30 AM New York time. Counted only in weeks when no other listed release came out at the same minute - otherwise the reaction belongs to the bigger release. Release days from the Labor Department via ALFRED, holiday shifts included.")
i_shared = input.bool(true, "Count releases that shared their minute", group="Events", tooltip="CPI sometimes lands with retail sales, PCE with GDP, NFP with retail sales. ON counts that reaction in each release's row. OFF keeps only releases that came out alone - cleaner, but a smaller sample. Jobless claims are always counted only when alone.")

i_w1    = input.int(15, "First move window (minutes)", minval=1, maxval=60, group="Measurement", tooltip="Where price stands this many minutes after the release, compared with the price just before it. Rounded up to whole chart bars - on a 30-minute chart, 15 becomes 30.")
i_w2    = input.int(60, "Follow-through window (minutes)", minval=2, maxval=90, group="Measurement", tooltip="Where price stands this many minutes after the release, and the full range covered in between. Capped at 90 so an 8:30 window never runs into a 10:00 release. Rounded up to whole chart bars, and always at least one bar longer than the first window.")
i_baseN = input.int(20, "Normal-day baseline (days)", minval=5, maxval=60, group="Measurement", tooltip="Each event window is compared with the average range of the same clock window on this many previous days that had no listed release at that time.")
i_minN  = input.int(10, "Minimum sample to trust", minval=3, maxval=50, group="Measurement", tooltip="Rows with fewer events than this are marked with an asterisk. A handful of releases is an anecdote, not a statistic.")
i_from  = input.time(1704067200000, "Count events from", group="Measurement", tooltip="Events before this moment are ignored. Pin it to compare two settings over exactly the same period.")

i_lbl    = input.bool(true, "Label each event", group="Display")
i_lblClm = input.bool(false, "Also label jobless claims", group="Display", tooltip="Off by default - a weekly release would crowd the chart. Claims are still counted in the table.")
i_box    = input.bool(true, "Draw the reaction window", group="Display")
i_panel  = input.bool(true, "Show summary panel", group="Display")
i_txt    = input.string("Normal", "Panel text size", options=["Small", "Normal", "Large", "Huge"], group="Display")
i_pos    = input.string("Top center", "Summary panel position", options=["Top center", "Bottom center", "Bottom left", "Top left", "Top right", "Bottom right"], group="Display", tooltip="Kept away from the corners used by the Gold M15 panels. The next-release box sits at the top center, or at the bottom center if the summary is up there.")

// ══════════════════════════════════════════════════════════
// EVENT TABLE
// Dates are stored as yyyymmdd and turned into New York times, so
// daylight saving is handled by TradingView. evD0/evD1/evD2 keep every
// listed release day for the 8:30, 10:00 and 2:00 PM windows, switched
// on or not, so a normal-day baseline never includes a release.
// ══════════════════════════════════════════════════════════
var array<int> evT  = array.new<int>()
var array<int> evK  = array.new<int>()
var array<int> evD0 = array.new<int>()
var array<int> evD1 = array.new<int>()
var array<int> evD2 = array.new<int>()
var array<string> NAMES = array.from("FOMC", "CPI", "NFP", "PPI", "PCE", "Retail", "ISM Mfg", "ISM Srv", "Claims", "Minutes")
var array<int> ORDER = array.from(0, 9, 1, 4, 3, 2, 5, 6, 7, 8)
CLAIMS_K = 8

addDays(array<int> days, int h, int mi, int k, bool isOn) =>
    hm = h * 60 + mi
    for d in days
        if hm == 510
            array.push(evD0, d)
        else if hm == 600
            array.push(evD1, d)
        else
            array.push(evD2, d)
        if isOn
            array.push(evT, timestamp("America/New_York", math.floor(d / 10000), math.floor(d / 100) % 100, d % 100, h, mi))
            array.push(evK, k)

isOnK(int k) =>
    k == 0 ? i_fomc : k == 1 ? i_cpi : k == 2 ? i_nfp : k == 3 ? i_ppi : k == 4 ? i_pce : k == 5 ? i_ret : k == 6 ? i_ismM : k == 7 ? i_ismS : k == 8 ? i_clm : i_min

if barstate.isfirst
    // FOMC rate decision — federalreserve.gov, statement day, 2:00 PM
    addDays(array.from(20240131, 20240320, 20240501, 20240612, 20240731, 20240918), 14, 0, 0, i_fomc)
    addDays(array.from(20241107, 20241218), 14, 0, 0, i_fomc)
    addDays(array.from(20250129, 20250319, 20250507, 20250618, 20250730, 20250917), 14, 0, 0, i_fomc)
    addDays(array.from(20251029, 20251210), 14, 0, 0, i_fomc)
    addDays(array.from(20260128, 20260318, 20260429, 20260617, 20260729, 20260916), 14, 0, 0, i_fomc)
    addDays(array.from(20261028, 20261209), 14, 0, 0, i_fomc)
    addDays(array.from(20270127, 20270317, 20270428, 20270609, 20270728, 20270915), 14, 0, 0, i_fomc)
    addDays(array.from(20271027, 20271208), 14, 0, 0, i_fomc)
    // FOMC minutes — federalreserve.gov, 2:00 PM (Oct/Nov 2026 scheduled)
    addDays(array.from(20240103, 20240221, 20240410, 20240522, 20240703, 20240821), 14, 0, 9, i_min)
    addDays(array.from(20241009, 20241126), 14, 0, 9, i_min)
    addDays(array.from(20250108, 20250219, 20250409, 20250528, 20250709, 20250820), 14, 0, 9, i_min)
    addDays(array.from(20251008, 20251119, 20251230), 14, 0, 9, i_min)
    addDays(array.from(20260218, 20260408, 20260520, 20260708, 20260819, 20261007), 14, 0, 9, i_min)
    addDays(array.from(20261118), 14, 0, 9, i_min)
    // Dec 2026 and 2027 minutes: three weeks after each decision (Fed rule; confirm on federalreserve.gov)
    addDays(array.from(20261230), 14, 0, 9, i_min)
    addDays(array.from(20270217, 20270407, 20270519, 20270630, 20270818, 20271006), 14, 0, 9, i_min)
    addDays(array.from(20271117, 20271229), 14, 0, 9, i_min)
    // CPI — bls.gov release archive, 8:30
    addDays(array.from(20240111, 20240213, 20240312, 20240410, 20240515, 20240612), 8, 30, 1, i_cpi)
    addDays(array.from(20240711, 20240814, 20240911, 20241010, 20241113, 20241211), 8, 30, 1, i_cpi)
    addDays(array.from(20250115, 20250212, 20250312, 20250410, 20250513, 20250611), 8, 30, 1, i_cpi)
    addDays(array.from(20250715, 20250812, 20250911, 20251024, 20251218), 8, 30, 1, i_cpi)
    addDays(array.from(20260113, 20260213, 20260311, 20260410, 20260512, 20260610), 8, 30, 1, i_cpi)
    addDays(array.from(20260714, 20260812, 20260911, 20261014, 20261110, 20261210), 8, 30, 1, i_cpi)
    addDays(array.from(20270113, 20270211, 20270310, 20270413, 20270512, 20270610), 8, 30, 1, i_cpi)
    addDays(array.from(20270714, 20270811, 20270914, 20271014, 20271110, 20271210), 8, 30, 1, i_cpi)
    // PCE (Personal Income and Outlays) — BEA schedule, 8:30
    addDays(array.from(20240126, 20240229, 20240329, 20240426, 20240531, 20240628), 8, 30, 4, i_pce)
    addDays(array.from(20240726, 20240830, 20240927, 20241031, 20241127, 20241220), 8, 30, 4, i_pce)
    addDays(array.from(20250131, 20250228, 20250328, 20250430, 20250530, 20250627), 8, 30, 4, i_pce)
    addDays(array.from(20250731, 20250829, 20250926), 8, 30, 4, i_pce)
    addDays(array.from(20260220, 20260313, 20260409, 20260430, 20260528, 20260625), 8, 30, 4, i_pce)
    addDays(array.from(20260730, 20260826, 20260930, 20261029, 20261125, 20261223), 8, 30, 4, i_pce)
    addDays(array.from(20270331, 20270429, 20270527, 20270625, 20270729, 20270825), 8, 30, 4, i_pce)
    addDays(array.from(20270930, 20271028, 20271124), 8, 30, 4, i_pce)
    // PCE post-shutdown catch-up releases — BEA, published at 10:00
    addDays(array.from(20251205), 10, 0, 4, i_pce)
    addDays(array.from(20260122), 10, 0, 4, i_pce)
    // PPI — bls.gov release archive, 8:30
    addDays(array.from(20240112, 20240216, 20240314, 20240411, 20240514, 20240613), 8, 30, 3, i_ppi)
    addDays(array.from(20240712, 20240813, 20240912, 20241011, 20241114, 20241212), 8, 30, 3, i_ppi)
    addDays(array.from(20250114, 20250213, 20250313, 20250411, 20250515, 20250612), 8, 30, 3, i_ppi)
    addDays(array.from(20250716, 20250814, 20250910, 20251125), 8, 30, 3, i_ppi)
    addDays(array.from(20260114, 20260130, 20260227, 20260318, 20260414, 20260513), 8, 30, 3, i_ppi)
    addDays(array.from(20260611, 20260715, 20260813, 20260910, 20261015, 20261113), 8, 30, 3, i_ppi)
    addDays(array.from(20261215), 8, 30, 3, i_ppi)
    addDays(array.from(20270114, 20270212, 20270312, 20270414, 20270513, 20270611), 8, 30, 3, i_ppi)
    addDays(array.from(20270715, 20270810, 20270910, 20271015, 20271112, 20271215), 8, 30, 3, i_ppi)
    // Employment Situation — bls.gov release archive, 8:30
    addDays(array.from(20240105, 20240202, 20240308, 20240405, 20240503, 20240607), 8, 30, 2, i_nfp)
    addDays(array.from(20240705, 20240802, 20240906, 20241004, 20241101, 20241206), 8, 30, 2, i_nfp)
    addDays(array.from(20250110, 20250207, 20250307, 20250404, 20250502, 20250606), 8, 30, 2, i_nfp)
    addDays(array.from(20250703, 20250801, 20250905, 20251120, 20251216), 8, 30, 2, i_nfp)
    addDays(array.from(20260109, 20260211, 20260306, 20260403, 20260508, 20260605), 8, 30, 2, i_nfp)
    addDays(array.from(20260702, 20260807, 20260904, 20261002, 20261106, 20261204), 8, 30, 2, i_nfp)
    addDays(array.from(20270108, 20270205, 20270305, 20270402, 20270507, 20270604), 8, 30, 2, i_nfp)
    addDays(array.from(20270702, 20270806, 20270903, 20271008, 20271105, 20271203), 8, 30, 2, i_nfp)
    // Retail sales — Census via ALFRED release dates, 8:30 (annual-revision days excluded)
    addDays(array.from(20240117, 20240215, 20240314, 20240415, 20240515, 20240618), 8, 30, 5, i_ret)
    addDays(array.from(20240716, 20240815, 20240917, 20241017, 20241115, 20241217), 8, 30, 5, i_ret)
    addDays(array.from(20250116, 20250214, 20250317, 20250416, 20250515, 20250617), 8, 30, 5, i_ret)
    addDays(array.from(20250717, 20250815, 20250916, 20251125, 20251216), 8, 30, 5, i_ret)
    addDays(array.from(20260114, 20260210, 20260306, 20260401, 20260421, 20260514), 8, 30, 5, i_ret)
    addDays(array.from(20260617, 20260716, 20260814, 20260916, 20261015, 20261117), 8, 30, 5, i_ret)
    addDays(array.from(20261216), 8, 30, 5, i_ret)
    // ISM Manufacturing — ismworld.org calendar / 1st business day rule, 10:00
    addDays(array.from(20240103, 20240201, 20240301, 20240401, 20240501, 20240603), 10, 0, 6, i_ismM)
    addDays(array.from(20240701, 20240801, 20240903, 20241001, 20241101, 20241202), 10, 0, 6, i_ismM)
    addDays(array.from(20250103, 20250203, 20250303, 20250401, 20250501, 20250602), 10, 0, 6, i_ismM)
    addDays(array.from(20250701, 20250801, 20250902, 20251001, 20251103, 20251201), 10, 0, 6, i_ismM)
    addDays(array.from(20260105, 20260202, 20260302, 20260401, 20260501, 20260601), 10, 0, 6, i_ismM)
    addDays(array.from(20260701, 20260803, 20260901, 20261001, 20261102, 20261201), 10, 0, 6, i_ismM)
    addDays(array.from(20270104, 20270201, 20270301, 20270401, 20270503, 20270601), 10, 0, 6, i_ismM)
    addDays(array.from(20270701, 20270802, 20270901, 20271001, 20271101, 20271201), 10, 0, 6, i_ismM)
    // ISM Services — ismworld.org calendar / 3rd business day rule, 10:00
    addDays(array.from(20240105, 20240205, 20240305, 20240403, 20240503, 20240605), 10, 0, 7, i_ismS)
    addDays(array.from(20240703, 20240805, 20240905, 20241003, 20241105, 20241204), 10, 0, 7, i_ismS)
    addDays(array.from(20250107, 20250205, 20250305, 20250403, 20250505, 20250604), 10, 0, 7, i_ismS)
    addDays(array.from(20250703, 20250805, 20250904, 20251003, 20251105, 20251203), 10, 0, 7, i_ismS)
    addDays(array.from(20260107, 20260204, 20260304, 20260406, 20260505, 20260603), 10, 0, 7, i_ismS)
    addDays(array.from(20260706, 20260805, 20260903, 20261005, 20261104, 20261203), 10, 0, 7, i_ismS)
    addDays(array.from(20270106, 20270203, 20270303, 20270405, 20270505, 20270603), 10, 0, 7, i_ismS)
    addDays(array.from(20270706, 20270804, 20270903, 20271005, 20271103, 20271203), 10, 0, 7, i_ismS)
    // Jobless claims — Labor Department release days via ALFRED, 8:30
    addDays(array.from(20240104, 20240111, 20240118, 20240125, 20240201, 20240208), 8, 30, 8, i_clm)
    addDays(array.from(20240215, 20240222, 20240229, 20240307, 20240314, 20240321), 8, 30, 8, i_clm)
    addDays(array.from(20240328, 20240404, 20240411, 20240418, 20240425, 20240502), 8, 30, 8, i_clm)
    addDays(array.from(20240509, 20240516, 20240523, 20240530, 20240606, 20240613), 8, 30, 8, i_clm)
    addDays(array.from(20240620, 20240627, 20240703, 20240711, 20240718, 20240725), 8, 30, 8, i_clm)
    addDays(array.from(20240801, 20240808, 20240815, 20240822, 20240829, 20240905), 8, 30, 8, i_clm)
    addDays(array.from(20240912, 20240919, 20240926, 20241003, 20241010, 20241017), 8, 30, 8, i_clm)
    addDays(array.from(20241024, 20241031, 20241107, 20241114, 20241121, 20241127), 8, 30, 8, i_clm)
    addDays(array.from(20241205, 20241212, 20241219, 20241226), 8, 30, 8, i_clm)
    addDays(array.from(20250102, 20250108, 20250116, 20250123, 20250130, 20250206), 8, 30, 8, i_clm)
    addDays(array.from(20250213, 20250220, 20250227, 20250306, 20250313, 20250320), 8, 30, 8, i_clm)
    addDays(array.from(20250327, 20250403, 20250410, 20250417, 20250424, 20250501), 8, 30, 8, i_clm)
    addDays(array.from(20250508, 20250515, 20250522, 20250529, 20250605, 20250612), 8, 30, 8, i_clm)
    addDays(array.from(20250618, 20250626, 20250703, 20250710, 20250717, 20250724), 8, 30, 8, i_clm)
    addDays(array.from(20250731, 20250807, 20250814, 20250821, 20250828, 20250904), 8, 30, 8, i_clm)
    addDays(array.from(20250911, 20250918, 20250925, 20251120, 20251126, 20251204), 8, 30, 8, i_clm)
    addDays(array.from(20251211, 20251218, 20251224, 20251231), 8, 30, 8, i_clm)
    addDays(array.from(20260108, 20260115, 20260122, 20260129, 20260205, 20260212), 8, 30, 8, i_clm)
    addDays(array.from(20260219, 20260226, 20260305, 20260312, 20260319, 20260326), 8, 30, 8, i_clm)
    addDays(array.from(20260402, 20260409, 20260416, 20260423, 20260430, 20260507), 8, 30, 8, i_clm)
    addDays(array.from(20260514, 20260521, 20260528, 20260604, 20260611, 20260618), 8, 30, 8, i_clm)
    addDays(array.from(20260625, 20260702, 20260709, 20260716, 20260723, 20260730), 8, 30, 8, i_clm)
    addDays(array.from(20260806, 20260813, 20260820, 20260827, 20260903, 20260910), 8, 30, 8, i_clm)
    addDays(array.from(20260917, 20260924, 20261001, 20261008, 20261015, 20261022), 8, 30, 8, i_clm)
    addDays(array.from(20261029, 20261105, 20261112, 20261119, 20261125, 20261203), 8, 30, 8, i_clm)
    addDays(array.from(20261210, 20261217), 8, 30, 8, i_clm)
    // Late Dec 2026 and 2027: every Thursday, Thanksgiving week on Wednesday (DOL rule; check holiday weeks)
    addDays(array.from(20261224, 20261231, 20270107, 20270114, 20270121, 20270128), 8, 30, 8, i_clm)
    addDays(array.from(20270204, 20270211, 20270218, 20270225, 20270304, 20270311), 8, 30, 8, i_clm)
    addDays(array.from(20270318, 20270325, 20270401, 20270408, 20270415, 20270422), 8, 30, 8, i_clm)
    addDays(array.from(20270429, 20270506, 20270513, 20270520, 20270527, 20270603), 8, 30, 8, i_clm)
    addDays(array.from(20270610, 20270617, 20270624, 20270701, 20270708, 20270715), 8, 30, 8, i_clm)
    addDays(array.from(20270722, 20270729, 20270805, 20270812, 20270819, 20270826), 8, 30, 8, i_clm)
    addDays(array.from(20270902, 20270909, 20270916, 20270923, 20270930, 20271007), 8, 30, 8, i_clm)
    addDays(array.from(20271014, 20271021, 20271028, 20271104, 20271111, 20271118), 8, 30, 8, i_clm)
    addDays(array.from(20271124, 20271202, 20271209, 20271216, 20271223, 20271230), 8, 30, 8, i_clm)
    idx = array.sort_indices(evT, order.ascending)
    sT = array.new<int>()
    sK = array.new<int>()
    if array.size(idx) > 0
        for j = 0 to array.size(idx) - 1
            array.push(sT, array.get(evT, array.get(idx, j)))
            array.push(sK, array.get(evK, array.get(idx, j)))
        evT := sT
        evK := sK

// ══════════════════════════════════════════════════════════
// TIMEFRAME GUARD
// Releases land on :00 and :30, so the chart timeframe must divide
// 30 minutes, and both windows must be whole numbers of bars.
// ══════════════════════════════════════════════════════════
tf   = timeframe.multiplier
// Windows are rounded up to whole chart bars, so the defaults also work on
// 30-minute charts: a 15-minute first window becomes one 30-minute bar.
w1   = timeframe.isminutes ? math.ceil(math.max(i_w1, tf) / float(tf)) * tf : i_w1
w2   = timeframe.isminutes ? math.ceil(math.max(i_w2, w1 + tf) / float(tf)) * tf : i_w2
okTF = timeframe.isminutes and 30 % tf == 0 and w2 <= 90

var label warn = na
if not okTF and barstate.islast
    label.delete(warn)
    warn := label.new(bar_index, high, "Gold News Reaction Map needs a minute chart whose timeframe divides 30 (1, 2, 3, 5, 10, 15 or 30 minutes).", color=color.yellow, textcolor=color.black, style=label.style_label_down, size=size.normal)

NY    = "America/New_York"
nyMin = hour(time, NY) * 60 + minute(time, NY)
nyDay = year(time, NY) * 10000 + month(time, NY) * 100 + dayofmonth(time, NY)

// ══════════════════════════════════════════════════════════
// NORMAL-DAY BASELINE
// Every day, the range of the 8:30, 10:00 and 2:00 PM windows is
// recorded as a percentage of price - unless a listed release fell in
// that window on that day. An event's range is compared with the average
// of the previous normal days at the same clock time, which is fairer
// than comparing it with the quiet hour just before the release.
// ══════════════════════════════════════════════════════════
var array<float> base0 = array.new<float>()
var int   s0Day = 0
var bool  s0Ok  = false
var float s0Op  = na
var float s0Hi  = na
var float s0Lo  = na
var array<float> base1 = array.new<float>()
var int   s1Day = 0
var bool  s1Ok  = false
var float s1Op  = na
var float s1Hi  = na
var float s1Lo  = na
var array<float> base2 = array.new<float>()
var int   s2Day = 0
var bool  s2Ok  = false
var float s2Op  = na
var float s2Hi  = na
var float s2Lo  = na

// ══════════════════════════════════════════════════════════
// EVENT STATE AND TOTALS
// Totals are indexed by event: 0 FOMC, 1 CPI, 2 NFP, 3 PPI, 4 PCE,
// 5 Retail, 6 ISM Mfg, 7 ISM Srv, 8 Claims, 9 Minutes.
// ══════════════════════════════════════════════════════════
var int   ptr   = 0
var bool  aOn   = false
var int   aT0   = 0
var int   aBar0 = 0
var int   aSlot = -1
var float aP0   = na
var float aHi   = na
var float aLo   = na
var float aC1   = na
var array<int> aTyp = array.new<int>()

var array<float> cN   = array.new<float>(10, 0.0)
var array<float> cSp  = array.new<float>(10, 0.0)
var array<float> cMv  = array.new<float>(10, 0.0)
var array<float> cRev = array.new<float>(10, 0.0)
var array<float> cEx  = array.new<float>(10, 0.0)
var array<float> cExN = array.new<float>(10, 0.0)

fmtMove(float d, float pct) =>
    (d > 0 ? "▲ " : d < 0 ? "▼ " : "• ") + str.tostring(pct, "0.00") + "%"

// Everything is evaluated on closed bars only, so nothing repaints.
if okTF and barstate.isconfirmed
    // ── baseline: 8:30 window ─────────────────────────
    if nyMin >= 510 and nyMin < 510 + w2
        if s0Day != nyDay
            s0Day := nyDay
            s0Ok  := nyMin == 510
            s0Op  := open
            s0Hi  := high
            s0Lo  := low
        else
            s0Hi := math.max(s0Hi, high)
            s0Lo := math.min(s0Lo, low)
        if nyMin + tf >= 510 + w2
            if s0Ok and s0Op > 0 and not array.includes(evD0, nyDay)
                array.push(base0, (s0Hi - s0Lo) / s0Op * 100)
                if array.size(base0) > i_baseN
                    array.shift(base0)
            s0Ok := false

    // ── baseline: 10:00 window ─────────────────────────
    if nyMin >= 600 and nyMin < 600 + w2
        if s1Day != nyDay
            s1Day := nyDay
            s1Ok  := nyMin == 600
            s1Op  := open
            s1Hi  := high
            s1Lo  := low
        else
            s1Hi := math.max(s1Hi, high)
            s1Lo := math.min(s1Lo, low)
        if nyMin + tf >= 600 + w2
            if s1Ok and s1Op > 0 and not array.includes(evD1, nyDay)
                array.push(base1, (s1Hi - s1Lo) / s1Op * 100)
                if array.size(base1) > i_baseN
                    array.shift(base1)
            s1Ok := false

    // ── baseline: 2:00 PM window ─────────────────────────
    if nyMin >= 840 and nyMin < 840 + w2
        if s2Day != nyDay
            s2Day := nyDay
            s2Ok  := nyMin == 840
            s2Op  := open
            s2Hi  := high
            s2Lo  := low
        else
            s2Hi := math.max(s2Hi, high)
            s2Lo := math.min(s2Lo, low)
        if nyMin + tf >= 840 + w2
            if s2Ok and s2Op > 0 and not array.includes(evD2, nyDay)
                array.push(base2, (s2Hi - s2Lo) / s2Op * 100)
                if array.size(base2) > i_baseN
                    array.shift(base2)
            s2Ok := false

    // ── start of an event ────────────────────────────────
    // Releases that fell before the loaded history, or inside a data
    // gap, are skipped rather than measured from the wrong bar. Releases
    // published at the same minute are measured once, as one reaction.
    while ptr < array.size(evT) and array.get(evT, ptr) < time
        ptr += 1
    if not aOn and ptr < array.size(evT) and array.get(evT, ptr) == time
        array.clear(aTyp)
        while ptr < array.size(evT) and array.get(evT, ptr) == time
            array.push(aTyp, array.get(evK, ptr))
            ptr += 1
        if time >= i_from
            aOn   := true
            aT0   := time
            aBar0 := bar_index
            aSlot := nyMin == 510 ? 0 : nyMin == 600 ? 1 : nyMin == 840 ? 2 : -1
            aP0   := open
            aHi   := high
            aLo   := low
            aC1   := na
    else if aOn
        aHi := math.max(aHi, high)
        aLo := math.min(aLo, low)

    // ── measure ──────────────────────────────────────────
    if aOn
        if na(aC1) and time_close >= aT0 + w1 * 60000
            aC1 := close
        if time_close >= aT0 + w2 * 60000
            d1  = aC1 - aP0
            d2  = close - aP0
            sp  = math.abs(d1) / aP0 * 100
            mv  = math.abs(d2) / aP0 * 100
            rev = d1 != 0 and d2 != 0 and math.sign(d1) != math.sign(d2)
            rng = (aHi - aLo) / aP0 * 100
            bArr = aSlot == 2 ? base2 : aSlot == 1 ? base1 : base0
            float ex = na
            if aSlot >= 0 and array.size(bArr) >= 5
                bAvg = array.avg(bArr)
                if bAvg > 0
                    ex := rng / bAvg

            nT = array.size(aTyp)
            nm = ""
            onlyClaims = nT == 1 and array.get(aTyp, 0) == CLAIMS_K
            for k in aTyp
                nm := nm + (nm == "" ? "" : " + ") + array.get(NAMES, k)
                countIt = k == CLAIMS_K ? nT == 1 : (nT == 1 or i_shared)
                if countIt
                    array.set(cN,  k, array.get(cN,  k) + 1)
                    array.set(cSp, k, array.get(cSp, k) + sp)
                    array.set(cMv, k, array.get(cMv, k) + mv)
                    if rev
                        array.set(cRev, k, array.get(cRev, k) + 1)
                    if not na(ex)
                        array.set(cEx,  k, array.get(cEx,  k) + ex)
                        array.set(cExN, k, array.get(cExN, k) + 1)

            drawIt = not onlyClaims or i_lblClm
            stTxt = rev ? "REVERSED" : (d1 == 0 or d2 == 0) ? "FLAT" : "HELD"
            colW  = rev ? #F0A040 : (d1 == 0 or d2 == 0) ? #8899AA : #8AB4FF
            if i_box and drawIt
                box.new(aBar0, aHi, bar_index, aLo, border_color=color.new(colW, 50), bgcolor=color.new(colW, 90))
                line.new(aBar0, aP0, bar_index, aP0, color=color.new(#9AAABB, 20), style=line.style_dotted, width=1)
            if i_lbl and drawIt
                exTxt = na(ex) ? "" : "  ·  range x" + str.tostring(ex, "0.0")
                txt = nm + "\n" + str.tostring(w1) + "m " + fmtMove(d1, sp) + "   " + str.tostring(w2) + "m " + fmtMove(d2, mv) + "\n" + stTxt + exTxt
                label.new(aBar0, aHi, txt, color=color.new(colW, 10), textcolor=#0D1117, style=label.style_label_down, size=size.small)
            aOn := false

// ══════════════════════════════════════════════════════════
// NEXT RELEASE
// All releases due at the same minute are shown together; the stats
// line uses the one listed first in the table.
// ══════════════════════════════════════════════════════════
nextT   = 0
nextNm  = ""
nextK   = -1
if barstate.islast and array.size(evT) > 0
    for i = 0 to array.size(evT) - 1
        t = array.get(evT, i)
        if t > timenow and (nextT == 0 or t == nextT)
            k = array.get(evK, i)
            nextT  := t
            nextNm := nextNm + (nextNm == "" ? "" : " + ") + array.get(NAMES, k)
            if nextK < 0 or array.indexof(ORDER, k) < array.indexof(ORDER, nextK)
                nextK := k
        else if nextT != 0 and t != nextT
            break

// ══════════════════════════════════════════════════════════
// PANELS
// Moves are averaged in percent, because gold's price has changed a
// lot over the sample, then converted to points at today's price.
// ══════════════════════════════════════════════════════════
pnlPos = i_pos == "Top left" ? position.top_left : i_pos == "Top center" ? position.top_center : i_pos == "Bottom center" ? position.bottom_center : i_pos == "Top right" ? position.top_right : i_pos == "Bottom right" ? position.bottom_right : position.bottom_left
nxtPos = i_pos == "Top center" ? position.bottom_center : position.top_center
var table pnl = table.new(pnlPos, 6, 12, bgcolor=#0D1117, border_width=1, border_color=#2A2D4A, frame_width=2, frame_color=#2A2D4A)
var table nxt = table.new(nxtPos, 1, 3, bgcolor=#0D1117, border_width=1, border_color=#2A2D4A, frame_width=2, frame_color=#2A2D4A)

szMid = i_txt == "Small" ? size.small : i_txt == "Normal" ? size.normal : i_txt == "Large" ? size.large : size.huge
szSml = i_txt == "Small" ? size.tiny : i_txt == "Normal" ? size.small : i_txt == "Large" ? size.normal : size.large

hdrBg = #1A1E3A
rowBg = #0D1117

if i_panel and okTF and barstate.islast
    px = close
    table.clear(pnl, 0, 0, 5, 11)
    table.cell(pnl, 0, 0, "NEWS REACTION", text_color=#8AB4FF, text_size=szMid, bgcolor=hdrBg, text_halign=text.align_left)
    for c = 1 to 5
        table.cell(pnl, c, 0, "", bgcolor=hdrBg)
    table.cell(pnl, 0, 1, "Event", text_color=#8899AA, text_size=szSml, bgcolor=rowBg, text_halign=text.align_left)
    table.cell(pnl, 1, 1, "n", text_color=#8899AA, text_size=szSml, bgcolor=rowBg)
    table.cell(pnl, 2, 1, str.tostring(w1) + "m move", text_color=#8899AA, text_size=szSml, bgcolor=rowBg)
    table.cell(pnl, 3, 1, str.tostring(w2) + "m move", text_color=#8899AA, text_size=szSml, bgcolor=rowBg)
    table.cell(pnl, 4, 1, "Reversed", text_color=#8899AA, text_size=szSml, bgcolor=rowBg)
    table.cell(pnl, 5, 1, "Range", text_color=#8899AA, text_size=szSml, bgcolor=rowBg)

    r = 2
    for k in ORDER
        if isOnK(k)
            n     = array.get(cN, k)
            small = n < i_minN
            nmCol = n == 0 ? #5E6B7A : small ? #9AAABB : color.white
            vCol  = n == 0 ? #5E6B7A : small ? #9AAABB : #E6EDF3
            table.cell(pnl, 0, r, array.get(NAMES, k), text_color=nmCol, text_size=szSml, bgcolor=rowBg, text_halign=text.align_left)
            if n == 0
                table.cell(pnl, 1, r, "0", text_color=vCol, text_size=szSml, bgcolor=rowBg)
                for c = 2 to 5
                    table.cell(pnl, c, r, "-", text_color=vCol, text_size=szSml, bgcolor=rowBg)
            else
                spP  = array.get(cSp, k) / n
                mvP  = array.get(cMv, k) / n
                revP = array.get(cRev, k) / n * 100
                exN  = array.get(cExN, k)
                exA  = exN > 0 ? array.get(cEx, k) / exN : na
                table.cell(pnl, 1, r, str.tostring(n, "#") + (small ? "*" : ""), text_color=vCol, text_size=szSml, bgcolor=rowBg)
                table.cell(pnl, 2, r, str.tostring(spP * px / 100, "#.0"), text_color=vCol, text_size=szSml, bgcolor=rowBg, tooltip="Average size of the first move: " + str.tostring(spP, "0.00") + "% of price")
                table.cell(pnl, 3, r, str.tostring(mvP * px / 100, "#.0"), text_color=vCol, text_size=szSml, bgcolor=rowBg, tooltip="Average distance from the pre-release price at the end of the window: " + str.tostring(mvP, "0.00") + "% of price")
                table.cell(pnl, 4, r, str.tostring(revP, "#") + "%", text_color=revP >= 50 ? #F0A040 : vCol, text_size=szSml, bgcolor=rowBg, tooltip="Share of releases where the first move was on one side of the pre-release price and the end of the window on the other")
                table.cell(pnl, 5, r, na(exA) ? "-" : "x" + str.tostring(exA, "0.0"), text_color=vCol, text_size=szSml, bgcolor=rowBg, tooltip="Range of the window compared with the same clock window on normal days")
            r += 1

    // next release, and what the previous ones of the same kind did
    nTxt = "No upcoming release listed"
    sTxt = ""
    if nextK >= 0
        diff = nextT - timenow
        dd = math.floor(diff / 86400000)
        hh = math.floor(diff % 86400000 / 3600000)
        mm = math.floor(diff % 3600000 / 60000)
        cd = dd > 0 ? str.tostring(dd) + "d " + str.tostring(hh) + "h" : str.tostring(hh) + "h " + str.tostring(mm) + "m"
        nTxt := "NEXT: " + nextNm + " in " + cd
        nn = array.get(cN, nextK)
        if nn > 0
            sTxt := array.get(NAMES, nextK) + ", previous " + str.tostring(nn, "#") + ": " + str.tostring(w2) + "m move ~" + str.tostring(array.get(cMv, nextK) / nn * px / 100, "#.0") + " pts, reversed " + str.tostring(array.get(cRev, nextK) / nn * 100, "#") + "%"
        else
            sTxt := "No previous " + array.get(NAMES, nextK) + " release in the loaded history"
    table.cell(nxt, 0, 0, nTxt, text_color=#F0C040, text_size=szSml, bgcolor=hdrBg, text_halign=text.align_left)
    table.cell(nxt, 0, 1, sTxt, text_color=#E6EDF3, text_size=szSml, bgcolor=rowBg, text_halign=text.align_left)
    table.cell(nxt, 0, 2, "Points at today's price.  * fewer than " + str.tostring(i_minN) + " events.  Claims: weeks released alone.", text_color=#5E6B7A, text_size=szSml, bgcolor=rowBg, text_halign=text.align_left)
````
