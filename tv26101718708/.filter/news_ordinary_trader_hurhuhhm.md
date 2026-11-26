# NEWS [Ordinary Trader]

- url: https://www.tradingview.com/script/hUrhUhHM-NEWS-Ordinary-Trader/
- type: indicator
- pine_id: PUB;f38564a797414a139e00c688e088f183
- version: 2.0

## Description

# NEWS [Ordinary Trader]

NEWS by Ordinary Trader marks high-impact USD economic news events on your chart — CPI, NFP, FOMC, PCE, GDP, and the rest of the red-folder calendar — both past and upcoming.

Part of the Ordinary Trader family alongside **EMAs**, **FVGs**, **KEY LEVELS**, **ZONES**, and **STRATEGY (LITE / PRO)**. The methodology calls for standing aside during high-impact news; this indicator makes those events impossible to miss.

## Visuals

Each event produces a **full-height vertical column** at the exact event time, plus a **small triangle marker** in a thin pane below the chart. Hover the marker for event name, day, date, and time in your selected timezone.

~3 months of historical events stay visible. ~1 week of upcoming events floats in the projected area to the right of your latest candle.

## Tiers + Filters

Events auto-classify into 4 tiers, each with its own colour:

- **Tier 1** — CPI, NFP, FOMC Rate Decision, PCE, GDP
- **Tier 2** — FOMC Minutes, Retail Sales, ISM PMI, PPI
- **Tier 3** — ADP, Consumer Confidence, Michigan, JOLTS, Initial Jobless Claims, Durable Goods
- **Uncategorised** — everything else (default OFF)

Hybrid filtering: tier master toggles + per-event toggles.

## Alerts (optional)

Pre-event TradingView alerts fire N minutes before each visible event (default 30). Same filters apply. One-time setup: enable in indicator settings + add a TradingView alert with condition `Any alert() function call`.

## Timezone

10 options (ET / CT / PT / UTC / UK / CET / Tokyo / HK / Singapore / Sydney) for tooltips and alerts. DST automatic.

## Notes

- USD events only; non-USD on the roadmap.
- Built on the Forex Factory data feed maintained by **@toodegrees** via Pine Seeds. The visual layer, tier classification, filter UI, and alerts are original work.
- License: Mozilla Public License 2.0. Free to use.

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// NEWS [Ordinary Trader] v1.2.1
// See CHANGELOG.md for full version history.
// ──────────────────────────────────────────────────────────────────────────────
// This Pine Script™ code is subject to the terms of the Mozilla Public License
// 2.0 at https://mozilla.org/MPL/2.0/
//
// © digitalpaul
//
// Based on "Live Economic Calendar by toodegrees" (© toodegrees, MPL 2.0):
// https://www.tradingview.com/script/JjgkjuMY-Live-Economic-Calendar-by-toodegrees/
// This indicator imports toodegrees' published libraries to access the Forex
// Factory news data feed they maintain via Pine Seeds. The visual layer below
// is original work.
// ══════════════════════════════════════════════════════════════════════════════

//@version=5
import toodegrees/forex_factory_utility/16 as ffUtil
import toodegrees/forex_factory_decoding/41 as ffDec

indicator("NEWS [Ordinary Trader] v1.2.1",
     shorttitle        = "NEWS [Ordinary Trader]",
     overlay           = false,
     scale             = scale.right,
     max_lines_count   = 500,
     max_labels_count  = 500)

// ─── TIMEFRAME LIMITS ─────────────────────────────────────────────────────────
// Inherited from toodegrees: data feed only meaningful at sub-Daily timeframes.
if timeframe.in_seconds(timeframe.period) > 86400
    runtime.error("Go to the Daily Timeframe or lower!")
else if timeframe.in_seconds(timeframe.period) < 30
    runtime.error("Go to the 30-Second Timeframe or higher!")

// Invisible anchor — overlay=false panes need at least one plot/hline.
// We plot a constant 0 with fully-transparent colour so nothing renders, but
// the pane is instantiated and our markers (also at y=0) appear inside it.
plot(0, "", color=color.new(color.gray, 100), display=display.none)

// ─── INPUTS ───────────────────────────────────────────────────────────────────

var string GRP_GEN = "General"
i_width = input.int(3, "News Column Width", minval=1, maxval=10, group=GRP_GEN, tooltip="Width of each column in pixels.\n\nThe column always looks the same width on every timeframe — it's measured in screen pixels, not chart time.")
var string TZ_TT = "Timezone shown in the tooltip on each event marker.\n\nDaylight Saving Time is handled automatically."
i_tz = input.string("ET", "Tooltip timezone", options=["ET", "CT", "PT", "UTC", "UK", "CET", "Tokyo", "HK", "Singapore", "Sydney"], group=GRP_GEN, tooltip=TZ_TT)
var string ALERT_TT = "Fires a TradingView alert N minutes before each visible event.\n\nRequires creating a TradingView alert on this indicator with condition 'Any alert() function call' — right-click the indicator name → Add alert → choose condition 'Any alert() function call'."
i_alerts_on  = input.bool(false, "Enable alerts", group=GRP_GEN, tooltip=ALERT_TT)
i_alert_lead = input.int(30, "Alert lead time (minutes)", minval=1, maxval=1440, group=GRP_GEN, tooltip="How many minutes before each event the alert fires. Default 30.\n\nThe same lead time applies to every event that passes your tier and per-event filters.")

var string GRP_T1 = "Tier 1 — Highest impact"
i_t1_on    = input.bool(true,                            "Show Tier 1",         group=GRP_T1, inline="t1head")
i_t1_color = input.color(color.new(#e07a5f, 0),          "",                    group=GRP_T1, inline="t1head")
i_t1_cpi   = input.bool(true,                            "CPI",                 group=GRP_T1)
i_t1_nfp   = input.bool(true,                            "Non-Farm Payrolls",   group=GRP_T1)
i_t1_fomc  = input.bool(true,                            "FOMC Rate Decision",  group=GRP_T1)
i_t1_pce   = input.bool(true,                            "PCE",                 group=GRP_T1)
i_t1_gdp   = input.bool(true,                            "GDP",                 group=GRP_T1)

var string GRP_T2 = "Tier 2 — High impact"
i_t2_on        = input.bool(true,                          "Show Tier 2",            group=GRP_T2, inline="t2head")
i_t2_color     = input.color(color.new(#f2cc8f, 0),        "",                       group=GRP_T2, inline="t2head")
i_t2_minutes   = input.bool(true,                          "FOMC Meeting Minutes",   group=GRP_T2)
i_t2_retail    = input.bool(true,                          "Retail Sales",           group=GRP_T2)
i_t2_ism_mfg   = input.bool(true,                          "ISM Manufacturing PMI",  group=GRP_T2)
i_t2_ism_svc   = input.bool(true,                          "ISM Services PMI",       group=GRP_T2)
i_t2_ppi       = input.bool(true,                          "PPI",                    group=GRP_T2)

var string GRP_T3 = "Tier 3 — Medium impact"
i_t3_on         = input.bool(true,                          "Show Tier 3",                group=GRP_T3, inline="t3head")
i_t3_color      = input.color(color.new(#81b29a, 0),        "",                           group=GRP_T3, inline="t3head")
i_t3_adp        = input.bool(true,                          "ADP Non-Farm Employment",    group=GRP_T3)
i_t3_confidence = input.bool(true,                          "Consumer Confidence (CB)",   group=GRP_T3)
i_t3_michigan   = input.bool(true,                          "Michigan Sentiment",         group=GRP_T3)
i_t3_jolts      = input.bool(true,                          "JOLTS Job Openings",         group=GRP_T3)
i_t3_durable    = input.bool(true,                          "Durable Goods Orders",       group=GRP_T3)
i_t3_claims     = input.bool(true,                          "Initial Jobless Claims",     group=GRP_T3)

var string GRP_UNCAT = "Uncategorised"
i_uncat_on    = input.bool(false,                       "Show uncategorised events", group=GRP_UNCAT, inline="uchead")
i_uncat_color = input.color(color.new(#6d6875, 0),      "",                          group=GRP_UNCAT, inline="uchead", tooltip="Events from the Forex Factory feed that don't match Tier 1, 2, or 3.\n\nDefault OFF so unfamiliar events don't clutter the chart.")

// ─── DATA FETCH ───────────────────────────────────────────────────────────────
// Pull encoded news data from toodegrees' Pine Seeds feed (9 slots).
// Each slot is a "fake symbol" whose OHLCV values encode news events for the
// current week. ffDec.readNews decodes them back into a News[] array.

requestData() =>
    [request.seed("seed_toodegrees_toogit", "TOODEGREES_FOREX_FACTORY_SLOT_1", str.tostring(open) + "," + str.tostring(high) + "," + str.tostring(low) + "," + str.tostring(close) + "," + str.tostring(volume)),
     request.seed("seed_toodegrees_toogit", "TOODEGREES_FOREX_FACTORY_SLOT_2", str.tostring(open) + "," + str.tostring(high) + "," + str.tostring(low) + "," + str.tostring(close) + "," + str.tostring(volume)),
     request.seed("seed_toodegrees_toogit", "TOODEGREES_FOREX_FACTORY_SLOT_3", str.tostring(open) + "," + str.tostring(high) + "," + str.tostring(low) + "," + str.tostring(close) + "," + str.tostring(volume)),
     request.seed("seed_toodegrees_toogit", "TOODEGREES_FOREX_FACTORY_SLOT_4", str.tostring(open) + "," + str.tostring(high) + "," + str.tostring(low) + "," + str.tostring(close) + "," + str.tostring(volume)),
     request.seed("seed_toodegrees_toogit", "TOODEGREES_FOREX_FACTORY_SLOT_5", str.tostring(open) + "," + str.tostring(high) + "," + str.tostring(low) + "," + str.tostring(close) + "," + str.tostring(volume)),
     request.seed("seed_toodegrees_toogit", "TOODEGREES_FOREX_FACTORY_SLOT_6", str.tostring(open) + "," + str.tostring(high) + "," + str.tostring(low) + "," + str.tostring(close) + "," + str.tostring(volume)),
     request.seed("seed_toodegrees_toogit", "TOODEGREES_FOREX_FACTORY_SLOT_7", str.tostring(open) + "," + str.tostring(high) + "," + str.tostring(low) + "," + str.tostring(close) + "," + str.tostring(volume)),
     request.seed("seed_toodegrees_toogit", "TOODEGREES_FOREX_FACTORY_SLOT_8", str.tostring(open) + "," + str.tostring(high) + "," + str.tostring(low) + "," + str.tostring(close) + "," + str.tostring(volume)),
     request.seed("seed_toodegrees_toogit", "TOODEGREES_FOREX_FACTORY_SLOT_9", str.tostring(open) + "," + str.tostring(high) + "," + str.tostring(low) + "," + str.tostring(close) + "," + str.tostring(volume))]

method processData(ffUtil.News[] N, string S1, string S2, string S3, string S4, string S5, string S6, string S7, string S8, string S9) =>
    ffDec.readNews(N, S1), ffDec.readNews(N, S2), ffDec.readNews(N, S3)
    ffDec.readNews(N, S4), ffDec.readNews(N, S5), ffDec.readNews(N, S6)
    ffDec.readNews(N, S7), ffDec.readNews(N, S8), ffDec.readNews(N, S9)

// New-day / new-week detection (in New York EST, matching the news feed timezone).
var mdnCheck = false
if hour(time, "America/New_York") == 0 and hour(time[1], "America/New_York") != 0 and not mdnCheck
    mdnCheck := true
newDay = mdnCheck ? hour(time, "America/New_York") == 0 and hour(time[1], "America/New_York") != 0 : timeframe.change("D")

// Storage arrays for decoded news.
var currWeek = array.new<ffUtil.News>()
var nextWeek = array.new<ffUtil.News>()

// Fetch raw seed data every bar.
[slot1, slot2, slot3, slot4, slot5, slot6, slot7, slot8, slot9] = requestData()

// Decode into nextWeek every bar (nextWeek holds the upcoming-week's events).
nextWeek.processData(slot1, slot2, slot3, slot4, slot5, slot6, slot7, slot8, slot9)

// Filter constants — hardcoded for v1.
// curFilter signature: (AUTO, AUD, CAD, CHF, CNY, EUR, GBP, JPY, NZD, USD)
// impFilter signature: (holiday, low_impact, med_impact, high_impact)
var currency_filter = ffUtil.curFilter(false, false, false, false, false, false, false, false, false, true)
var impact_filter   = ffUtil.impFilter(false, false, false, true)

// At week rollover, promote nextWeek -> currWeek (after sorting and filtering).
if timeframe.change("W")
    nextWeek := ffUtil.bubbleSort_News(nextWeek)
    currWeek := nextWeek.copy()
    currWeek := ffUtil.weekNews(currWeek, currency_filter, impact_filter)
    nextWeek.clear()

// ─── HELPERS ──────────────────────────────────────────────────────────────────

// Map dropdown label to the IANA timezone string Pine Script uses for conversion.
tzZone(string lbl) =>
    switch lbl
        "ET"        => "America/New_York"
        "CT"        => "America/Chicago"
        "PT"        => "America/Los_Angeles"
        "UTC"       => "UTC"
        "UK"        => "Europe/London"
        "CET"       => "Europe/Berlin"
        "Tokyo"     => "Asia/Tokyo"
        "HK"        => "Asia/Hong_Kong"
        "Singapore" => "Asia/Singapore"
        "Sydney"    => "Australia/Sydney"
        => "America/New_York"

// Return the appropriate tier colour for a given tier identifier.
colourFor(string tier) =>
    switch tier
        "T1"    => i_t1_color
        "T2"    => i_t2_color
        "T3"    => i_t3_color
        "Uncat" => i_uncat_color
        => i_uncat_color

// Return whether the tier itself is enabled at the master level.
tierEnabled(string tier) =>
    switch tier
        "T1"    => i_t1_on
        "T2"    => i_t2_on
        "T3"    => i_t3_on
        "Uncat" => i_uncat_on
        => false

// Return whether an individual event is enabled given its decoded name and tier.
// For Tier 1/2/3, looks up the relevant per-event input.bool. For "Uncat" the
// master toggle alone decides (no per-event toggles for that bucket).
isEventEnabled(string name, string tier) =>
    n = str.lower(name)
    if tier == "T1"
        str.contains(n, "cpi") ? i_t1_cpi : str.contains(n, "non-farm employment") ? i_t1_nfp : str.contains(n, "unemployment rate") ? i_t1_nfp : (str.contains(n, "fomc statement") or str.contains(n, "fed funds rate")) ? i_t1_fomc : str.contains(n, "pce") ? i_t1_pce : str.contains(n, "gdp") ? i_t1_gdp : true
    else if tier == "T2"
        str.contains(n, "fomc meeting minutes") ? i_t2_minutes : str.contains(n, "retail sales") ? i_t2_retail : str.contains(n, "ism manufacturing") ? i_t2_ism_mfg : str.contains(n, "ism services") ? i_t2_ism_svc : str.contains(n, "ppi") ? i_t2_ppi : true
    else if tier == "T3"
        str.contains(n, "adp") ? i_t3_adp : str.contains(n, "consumer confidence") ? i_t3_confidence : str.contains(n, "michigan") ? i_t3_michigan : str.contains(n, "jolts") ? i_t3_jolts : str.contains(n, "durable goods") ? i_t3_durable : str.contains(n, "unemployment claims") ? i_t3_claims : true
    else
        true

// ─── CLASSIFICATION ───────────────────────────────────────────────────────────
// Classify a decoded event name into a tier by case-insensitive substring matching.
// Patterns are best-effort based on standard Forex Factory event naming; refine
// as edge cases are discovered in future weeks.

classifyEvent(string name) =>
    n = str.lower(name)
    isT1 = str.contains(n, "fomc statement") or str.contains(n, "fed funds rate") or str.contains(n, "cpi") or str.contains(n, "non-farm employment") or str.contains(n, "unemployment rate") or str.contains(n, "pce") or str.contains(n, "gdp")
    isT2 = str.contains(n, "fomc meeting minutes") or str.contains(n, "retail sales") or str.contains(n, "ism manufacturing") or str.contains(n, "ism services") or str.contains(n, "ppi")
    isT3 = str.contains(n, "adp") or str.contains(n, "consumer confidence") or str.contains(n, "michigan") or str.contains(n, "jolts") or str.contains(n, "durable goods") or str.contains(n, "unemployment claims")
    isT1 ? "T1" : isT2 ? "T2" : isT3 ? "T3" : "Uncat"

// ─── DRAW COLUMNS ─────────────────────────────────────────────────────────────
// Draw a vertical column at each event's timestamp, with tier-driven colour and
// per-event filtering. extend.both makes the line span the entire chart height
// regardless of price scale. xloc.bar_time positions future events in the
// projected area to the right of the latest bar.

// Track drawn lines so we can manage their lifecycle.
var array<line> eventLines = array.new<line>()

// Append this week's columns on week rollover. Previous weeks' columns are
// NOT deleted here — they remain until the 90-day prune below removes them,
// so the user can scroll back ~3 months and still see past event markers.
if timeframe.change("W") and currWeek.size() > 0
    // For each event, decode + classify + filter, then draw.
    for evt in currWeek
        tier = classifyEvent(evt.ttl)
        if tierEnabled(tier) and isEventEnabled(evt.ttl, tier)
            colour = colourFor(tier)
            newLn  = line.new(x1=evt.tmst, y1=0.0, x2=evt.tmst, y2=1.0, xloc=xloc.bar_time, extend=extend.both, color=colour, width=i_width, force_overlay=true)
            eventLines.push(newLn)

// Prune lines older than ~90 days to stay under the 500-line cap.
ninetyDaysMs = 90 * 24 * 60 * 60 * 1000
cutoff = time - ninetyDaysMs
i = 0
while i < eventLines.size()
    ln = eventLines.get(i)
    if line.get_x1(ln) < cutoff
        line.delete(ln)
        eventLines.remove(i)
    else
        i += 1

// ─── DRAW MARKERS ─────────────────────────────────────────────────────────────
// Each visible event gets a small dot label in this indicator's own pane.
// Because the indicator runs with overlay=false, y=0 anchors the marker to the
// bottom of its dedicated pane — no price-based calculation needed and the
// position is identical on every timeframe and zoom.
// The label is the tooltip carrier — Pine `line.new()` doesn't support tooltips.

// Tier label for the tooltip prefix.
tierLabel(string tier) =>
    switch tier
        "T1"    => "T1"
        "T2"    => "T2"
        "T3"    => "T3"
        "Uncat" => "Uncat"
        => "?"

// Track drawn marker labels.
var array<label> eventMarkers = array.new<label>()

// Append this week's markers on week rollover. Previous weeks' markers are
// NOT deleted here — they remain until the 90-day prune below removes them.
if timeframe.change("W") and currWeek.size() > 0
    // For each event passing the tier + per-event filter, place a marker.
    tzStr = tzZone(i_tz)
    for evt in currWeek
        tier = classifyEvent(evt.ttl)
        if tierEnabled(tier) and isEventEnabled(evt.ttl, tier)
            colour = colourFor(tier)
            hr   = hour(evt.tmst, tzStr)
            mn   = minute(evt.tmst, tzStr)
            hStr = (hr < 10 ? "0" : "") + str.tostring(hr)
            mStr = (mn < 10 ? "0" : "") + str.tostring(mn)
            tip   = "[" + tierLabel(tier) + "] " + evt.ttl + "\n" + evt.dow + " " + evt.dat + " · " + hStr + ":" + mStr + " " + i_tz
            newLb = label.new(x=evt.tmst, y=0, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_triangleup, color=colour, textcolor=color.new(color.white, 100), size=size.tiny, tooltip=tip)
            eventMarkers.push(newLb)

// Prune markers older than ~90 days to stay under the 500-label cap.
markerCutoffMs = 90 * 24 * 60 * 60 * 1000
markerCutoff   = time - markerCutoffMs
mi = 0
while mi < eventMarkers.size()
    lbl = eventMarkers.get(mi)
    if label.get_x(lbl) < markerCutoff
        label.delete(lbl)
        eventMarkers.remove(mi)
    else
        mi += 1

// ─── ALERTS ───────────────────────────────────────────────────────────────────
// Fire a TradingView alert() N minutes before each visible event.
// Inherits tier + per-event filters (same as columns and markers).
// Uses `timenow` (wall-clock) not `time` (bar open) so the lead-time window
// is accurate even on lower-volatility timeframes where bars are minutes apart.
// `barstate.isrealtime` gate prevents alert spam during chart-load historical replay.

var array<int> alertedEvents = array.new<int>()

// Prune past entries from alertedEvents every bar — keeps the array small and
// also avoids leaking memory if the script runs for weeks.
ai = 0
while ai < alertedEvents.size()
    if alertedEvents.get(ai) < timenow
        alertedEvents.remove(ai)
    else
        ai += 1

if i_alerts_on and barstate.isrealtime and currWeek.size() > 0
    leadMs    = i_alert_lead * 60 * 1000
    alertTzStr = tzZone(i_tz)
    for evt in currWeek
        // Skip if already alerted for this event.
        if alertedEvents.indexof(evt.tmst) == -1
            tier = classifyEvent(evt.ttl)
            // Inherit visual filters.
            if tierEnabled(tier) and isEventEnabled(evt.ttl, tier)
                timeToEvent = evt.tmst - timenow
                if timeToEvent > 0 and timeToEvent <= leadMs
                    ahr   = hour(evt.tmst, alertTzStr)
                    amn   = minute(evt.tmst, alertTzStr)
                    ahStr = (ahr < 10 ? "0" : "") + str.tostring(ahr)
                    amStr = (amn < 10 ? "0" : "") + str.tostring(amn)
                    msg   = "[" + tierLabel(tier) + "] " + evt.ttl + " in " + str.tostring(i_alert_lead) + " minutes (" + ahStr + ":" + amStr + " " + i_tz + ")"
                    alert(msg, alert.freq_once_per_bar_close)
                    alertedEvents.push(evt.tmst)
````
