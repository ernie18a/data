<!-- tradingview-pine-id: PUB;cf126c9c74a8487b9b2d299c8c2354bf -->
<!-- tradingviewscripts-format: 1 -->
# LDO-Magnet [1.2]

Source: https://www.tradingview.com/script/wZmCpeTF-LDO-Magnet-1-1/

## Description

LDO-Magnet — Naked POCs, Value Areas & Vector Candle Zones

WHAT IT DOES

Plots the two kinds of unfinished business that pull price back like a magnet, and tells you when they stack on top of each other.

NAKED POINTS OF CONTROL (NPOCs). Each UTC day, week and month gets a volume profile built from lower-timeframe data. The price with the most traded volume is that period's POC. Once the period closes, an untouched POC is "naked" — a magnet that price tends to return to. Levels are removed the moment price finally trades through them. Previous Value Areas (VAH/VAL — the range holding 70% of the period's volume) are also drawn.

VECTOR CANDLE ZONES. Candles with unusually high volume — 200%+ of the recent average (red/green vectors) or 150%+ (violet/blue vectors) — mark where market makers left a footprint. The candle body becomes a zone that stays on the chart until price trades fully back through it.

CONFLUENCE ★. When a Naked POC sits inside an active vector zone, two independent reasons for price to react coincide at one level. The NPOC's label gains a star and its line brightens: ★ — the NPOC is anywhere inside the zone ★★ — the NPOC is near the zone's 50% midpoint (strong confluence) Stars appear and disappear live as zones are created and cleared.

READING THE CHART

Levels are labelled on the right edge: dNPOC / wNPOC / mNPOC are daily, weekly and monthly Naked POCs (dotted, dashed and solid lines); pdVAH, pwVAL etc. are the previous period's Value Area edges. A star in front of any NPOC means it currently sits inside a vector zone. When two NPOCs from different timeframes nearly overlap, only the higher-timeframe one is drawn — the hidden one is still tracked and still fires alerts.

SETTINGS

Timeframes — which profile periods to plot. Daily and weekly are on by default; monthly suits higher-timeframe charts.

Levels — toggle Naked POCs, previous Value Areas and developing (live, still-forming) profiles, and cap how many levels of each timeframe stay on the chart. "Keep Touched Levels" leaves a faded line where a level was hit instead of deleting it.

Vector Zones — toggle the zones, colour them with one colour or by vector type, and set their transparency. "Highlight NPOC + zone confluence" controls the stars; the "Strong confluence band" sets how close to the zone's 50% level an NPOC must be to earn ★★ (default 15% of the zone's height).

Display — labels, prices, text size, and the overlap distance below which lower-timeframe levels are hidden.

Alerts — enables the dynamic alerts and sets the approach distance.

Appearance — colours and transparency per level family. Transparency runs 0–100: LOWER is brighter, higher is fainter. If a label seems hard to read, check you are adjusting the slider for that family (Naked POC, Value Area or developing profile) — each has its own.

ALERTS

Add an alert on the indicator and choose a condition: approach/touch per NPOC timeframe, previous VAH/VAL crosses, Value Area entries, vector zone approach/entry, and Approaching/Touching Confluence. Or select "Any alert() function call" to receive everything as detailed messages, e.g.:

ZECUSDT.P | STRONG CONFLUENCE touch | Daily NPOC 466.60 inside vector zone | current 466.85

HOW TO USE THE CONFLUENCE

The stars mark where a reaction is likely — they do not predict its direction. In practice:

Treat ★★ levels as the highest-priority magnets on the chart. Price reaching one usually does something: a rejection back the way it came, or a decisive push straight through.
Read direction from the approach. Into confluence against the prevailing trend, favour the reversal; with the trend and on strong volume, a clean break often accelerates.
First touches are the most reliable. Once a level has been tested the magnet is spent — the script removes filled NPOCs automatically.
Higher timeframe beats lower: a starred wNPOC or mNPOC outranks a starred dNPOC.
Set the Approaching Confluence alert and let the chart come to you.
NOTES

Levels are computed from lower-timeframe volume distributed across price, with UTC period boundaries, so they will not exactly match profiles drawn in your chart's local timezone. Use standard candles. Works on any symbol and timeframe with volume data.

Vector zone logic is adapted from the open-source Vector Candle Zones code by infernix and peshocore (MPL 2.0) via the public Traders_Reality_Lib library — credit to them for the PVSRA methodology. The volume-profile engine, UTC framework, overlap suppression, confluence detection and alert system are original to this script.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// © 2026
//
// LDO-Magnet — UTC Volume Profile Levels + Vector Candle Zones
//
// Two families of unfinished business, one script. Naked POCs and previous
// Value Areas come from UTC volume profiles (Chart Champions methodology).
// Vector candle zones mark the bodies of unusually high-volume candles —
// market-maker footprints that price tends to revisit (PVSRA methodology).
//
// Vector zone logic: adapted from the open-source Vector Candle Zones code by
// infernix and peshocore (MPL 2.0), via the public Traders_Reality_Lib import.
// This script is an independent derivative and is not affiliated with, or named
// in reference to, that project.
//
// Confluence (1.1): a Naked POC sitting inside an active vector zone is marked
// with a star (★, or ★★ when near the zone's 50% midpoint) and gets its own
// approach/touch alerts. Two independent reasons for price to react at one
// level — the highest-signal condition this script can flag.
//
// Alert latching (1.2): every alert fires once per item. An NPOC alerts at
// most once approaching and once on the touch that retires it; Value Area
// crosses and entries fire once per period per side; each vector zone fires
// its approach and entry alerts once in its lifetime.
//
// Volume profile methodology
// --------------------------
// TradingView candles do not expose the true volume traded at every price. This
// script requests lower-timeframe OHLCV candles and allocates each candle's
// volume across every overlapped price row in proportion to price-range overlap.
// A zero-range candle is assigned to the row containing its close. The allocated
// amount is reconciled back to the candle's source volume to prevent volume loss
// through floating-point rounding.
//
// Automatic rows begin at a mintick-aligned size and merge adjacent rows whenever
// expansion would exceed the hard row limit. Merging preserves accumulated volume;
// historical candles are never replayed and completed levels never move.
//
// All profile boundaries are UTC calendar boundaries. Use standard candles/bars.

//@version=6
// Version is carried in the title so it shows in the chart legend.
// No shorttitle on purpose: the editor caps it at 10 characters, and with no
// shorttitle the legend falls back to the full title, version included.
indicator("LDO-Magnet [1.2]", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 5000, dynamic_requests = true)

import TradersReality/Traders_Reality_Lib/1 as trLib

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
string G_TF   = "Timeframes"
string G_LVL  = "Levels"
string G_VEC  = "Vector Zones"
string G_DISP = "Display"
string G_ALT  = "Alerts"
string G_APP  = "Appearance"

bool showDaily   = input.bool(true,  "Show Daily",   group = G_TF, inline = "tf")
bool showWeekly  = input.bool(true,  "Show Weekly",  group = G_TF, inline = "tf")
bool showMonthly = input.bool(false, "Show Monthly", group = G_TF, inline = "tf")

bool showNaked = input.bool(true, "Show Naked POCs", group = G_LVL)
bool showPrevVA = input.bool(true, "Show Previous Value Areas", group = G_LVL)
bool showDevD = input.bool(false, "Show Developing Daily Profile", group = G_LVL)
bool showDevW = input.bool(false, "Show Developing Weekly Profile", group = G_LVL)
bool showDevM = input.bool(false, "Show Developing Monthly Profile", group = G_LVL)
bool showDevVA = input.bool(false, "Show developing VAH and VAL", group = G_LVL,
     tooltip = "Also draw the developing Value Area High/Low alongside the developing POC.")
bool keepTouched = input.bool(false, "Keep Touched Levels", group = G_LVL,
     tooltip = "When price hits a Naked POC, keep a faded line where it was instead of removing it.")
int maxDaily = input.int(25, "Max Daily Naked POCs", minval = 1, maxval = 80, group = G_LVL,
     tooltip = "How many of the most recent untouched daily levels to keep on the chart.")
int maxWeekly = input.int(20, "Max Weekly Naked POCs", minval = 1, maxval = 60, group = G_LVL)
int maxMonthly = input.int(15, "Max Monthly Naked POCs", minval = 1, maxval = 40, group = G_LVL)

bool showVectors = input.bool(true, "Show Vector Zones", group = G_VEC,
     tooltip = "Shaded boxes marking the bodies of unusually high-volume candles — footprints that price tends to revisit. A zone is removed once price has traded fully back through it.")
string vecColorMode = input.string("Single colour", "Zone colouring", options = ["Single colour", "By vector type"], group = G_VEC,
     tooltip = "Single colour paints every zone with the colour below. By vector type matches the candle that made the zone: red/green for extreme volume (≥200% of the recent average), violet/blue for high volume (≥150%).")
color vecZoneColor = input.color(color.rgb(255, 230, 75), "Zone colour", group = G_VEC,
     tooltip = "Used in Single colour mode. Set brightness with the transparency slider below — the picker's own opacity slider is ignored.")
int vecTransparency = input.int(90, "Zone transparency", minval = 50, maxval = 99, group = G_VEC,
     tooltip = "How see-through the zones are. Lower is brighter: 50 gives a strong tint, 99 is barely there.")
color vecRed = input.color(color.red, "Red", group = G_VEC, inline = "vcol")
color vecGreen = input.color(color.lime, "Green", group = G_VEC, inline = "vcol")
color vecViolet = input.color(color.fuchsia, "Violet", group = G_VEC, inline = "vcol")
color vecBlue = input.color(color.blue, "Blue", group = G_VEC, inline = "vcol",
     tooltip = "Zone colours for By vector type mode. Red/green mark extreme-volume vectors, violet/blue high-volume vectors.")
bool showConfluence = input.bool(true, "Highlight NPOC + zone confluence", group = G_VEC,
     tooltip = "When a Naked POC sits inside a vector zone, its label gains a star and its line brightens: ★ anywhere in the zone, ★★ near the zone's 50% midpoint. Also enables the Approaching/Touching Confluence alerts.")
float confMidPct = input.float(15, "Strong confluence band around zone midpoint (%)", minval = 1, maxval = 50, step = 1,
     group = G_VEC,
     tooltip = "How close to the zone's 50% level an NPOC must sit to count as strong (★★), measured as a percentage of the zone's height.") / 100.0

bool showLabels   = input.bool(true, "Show Labels", group = G_DISP, inline = "labels")
bool showPrices   = input.bool(true, "Show Prices in Labels", group = G_DISP, inline = "labels")
int labelOffset   = input.int(13, "Right-side label offset (bars)", minval = 1, maxval = 100, group = G_DISP)
string labelSizeMode = input.string("Normal", "Label text size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_DISP)
float overlapPct = input.float(0.15, "Hide overlapping levels within (%)", minval = 0.0, maxval = 2.0, step = 0.01,
     group = G_DISP,
     tooltip = "When two Naked POCs sit closer together than this, only the higher-timeframe one is drawn: monthly beats weekly beats daily. The hidden level is still tracked and still fires its alerts. Set to 0 to draw every level.") / 100.0

bool enableAlerts = input.bool(true, "Enable dynamic alert() calls", group = G_ALT,
     tooltip = "Sends pop-up/app alerts for Naked POC touches and approaches, Value Area events and vector zone events when an alert is set on this indicator.")
float approachPct = input.float(0.10, "Approach alert distance (%)", minval = 0.001, step = 0.01, group = G_ALT,
     tooltip = "Fires the approach alert when price closes within this percentage of a Naked POC or vector zone edge.") / 100.0

color dailyBase = input.color(color.rgb(0, 175, 190), "Daily", group = G_APP, inline = "col")
color weeklyBase = input.color(color.rgb(200, 200, 205), "Weekly", group = G_APP, inline = "col")
color monthlyBase = input.color(color.rgb(170, 50, 170), "Monthly", group = G_APP, inline = "col")
int lineWidth = input.int(1, "Line width", options = [1, 2], group = G_APP)
bool useVAFill = input.bool(false, "Subtle previous Value Area fill", group = G_APP)
color vaFillColor = input.color(color.rgb(0, 188, 212), "Value Area fill colour", group = G_APP,
     tooltip = "Colour of the shaded band between the previous VAH and VAL. Set brightness with the slider below — the picker's own opacity slider is ignored.")
int vaFillTransparency = input.int(89, "Value Area fill transparency", minval = 60, maxval = 99, group = G_APP,
     tooltip = "How see-through the fill is. Lower is brighter: 60 gives a clearly visible tint, 99 is barely there.")
int dailyTransparency = input.int(29, "Daily Naked POC transparency", minval = 0, maxval = 95, group = G_APP)
int weeklyTransparency = input.int(40, "Weekly Naked POC transparency", minval = 0, maxval = 95, group = G_APP)
int monthlyTransparency = input.int(20, "Monthly Naked POC transparency", minval = 0, maxval = 95, group = G_APP)
int vaTransparency = input.int(55, "Previous Value Area transparency", minval = 0, maxval = 95, group = G_APP)
int devTransparency = input.int(55, "Developing profile transparency", minval = 0, maxval = 95, group = G_APP)

// Fixed engine settings — deliberately not exposed as inputs. Changing these
// changes where the levels sit; the automatic values are correct for any symbol.
int TARGET_ROWS = 100
int MAX_ROWS = 180
int MAX_TOUCHED_HISTORY = 40

// Fixed vector-zone settings (upstream defaults). Zones span the candle body;
// a zone is cleared when a later candle's full range trades back through it.
int VEC_MAX_ZONES = 500
string VEC_ZONE_TYPE = "Body only"
string VEC_CLEAR_TYPE = "Body with wicks"
int VEC_BORDER_WIDTH = 0

// Internal PVSRA classification colours. Constant on purpose: classification
// must never depend on the user's display colours, which may collide.
color C_VEC_RED = #ff0000
color C_VEC_GREEN = #00ff00
color C_VEC_VIOLET = #ff00ff
color C_VEC_BLUE = #0000ff
color C_REG_UP = #999999
color C_REG_DOWN = #4d4d4d

string labelTextSize = switch labelSizeMode
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large
    "Huge" => size.huge
    => size.tiny

// Confluence needs both families of levels visible to mean anything.
bool confEnabled = showConfluence and showVectors and showNaked

// ─────────────────────────────────────────────────────────────────────────────
// Data structures
// ─────────────────────────────────────────────────────────────────────────────
type Profile
    int periodStart
    float base
    float step
    float profileHigh
    float profileLow
    float totalVolume
    float weightedPriceVolume
    bool completeFromStart
    array<float> bins

type NakedLevel
    float price
    int originStart
    int eligibleFrom
    int creationBar
    bool approached
    line levelLine
    label levelLabel

type ValueAreaDisplay
    float poc
    float vah
    float val
    int originStart
    line vahLine
    line valLine
    label vahLabel
    label valLabel
    linefill areaFill
    bool vahAlerted
    bool valAlerted
    bool entryAlerted

type DevelopingDisplay
    line pocLine
    line vahLine
    line valLine
    label pocLabel
    label vahLabel
    label valLabel

var Profile dProfile = Profile.new(na, na, na, na, na, 0.0, 0.0, false, array.new_float())
var Profile wProfile = Profile.new(na, na, na, na, na, 0.0, 0.0, false, array.new_float())
var Profile mProfile = Profile.new(na, na, na, na, na, 0.0, 0.0, false, array.new_float())

var array<NakedLevel> dNaked = array.new<NakedLevel>()
var array<NakedLevel> wNaked = array.new<NakedLevel>()
var array<NakedLevel> mNaked = array.new<NakedLevel>()
var array<line> touchedLines = array.new_line()

var ValueAreaDisplay dVA = ValueAreaDisplay.new(na, na, na, na, na, na, na, na, na, false, false, false)
var ValueAreaDisplay wVA = ValueAreaDisplay.new(na, na, na, na, na, na, na, na, na, false, false, false)
var ValueAreaDisplay mVA = ValueAreaDisplay.new(na, na, na, na, na, na, na, na, na, false, false, false)

var DevelopingDisplay dDev = DevelopingDisplay.new(na, na, na, na, na, na)
var DevelopingDisplay wDev = DevelopingDisplay.new(na, na, na, na, na, na)
var DevelopingDisplay mDev = DevelopingDisplay.new(na, na, na, na, na, na)

// Declared here (not in the vector-zone section) so the confluence helpers,
// which are defined with the other drawing helpers, can reference them.
var array<box> vecZonesBelow = array.new<box>()
var array<box> vecZonesAbove = array.new<box>()

// ─────────────────────────────────────────────────────────────────────────────
// UTC calendar periods
// ─────────────────────────────────────────────────────────────────────────────
f_dayStart(int t) =>
    timestamp("UTC", year(t, "UTC"), month(t, "UTC"), dayofmonth(t, "UTC"), 0, 0)

f_weekStart(int t) =>
    int ds = (dayofweek(t, "UTC") + 5) % 7
    f_dayStart(t) - ds * 86400000

f_monthStart(int t) =>
    timestamp("UTC", year(t, "UTC"), month(t, "UTC"), 1, 0, 0)

// ─────────────────────────────────────────────────────────────────────────────
// Styling helpers
// ─────────────────────────────────────────────────────────────────────────────
f_baseColor(string tf) =>
    tf == "D" ? dailyBase : tf == "W" ? weeklyBase : monthlyBase

f_nakedColor(string tf) =>
    int tr = tf == "D" ? dailyTransparency : tf == "W" ? weeklyTransparency : monthlyTransparency
    color.new(f_baseColor(tf), tr)

f_vaColor(string tf) => color.new(f_baseColor(tf), vaTransparency)
f_devColor(string tf) => color.new(f_baseColor(tf), devTransparency)

f_nakedStyle(string tf) =>
    tf == "D" ? line.style_dotted : tf == "W" ? line.style_dashed : line.style_solid

f_prefix(string tf) => tf == "D" ? "d" : tf == "W" ? "w" : "m"
f_prevPrefix(string tf) => tf == "D" ? "pd" : tf == "W" ? "pw" : "pm"

f_text(string name, float price) =>
    showPrices ? name + " " + str.tostring(price, format.mintick) : name

// ─────────────────────────────────────────────────────────────────────────────
// Profile engine
// ─────────────────────────────────────────────────────────────────────────────
f_initialStep(float candleLow, float candleHigh) =>
    float tick = syminfo.mintick
    float raw = math.max((candleHigh - candleLow) / TARGET_ROWS, tick)
    math.max(tick, math.ceil(raw / tick) * tick)

f_mergeRows(Profile p) =>
    array<float> merged = array.new_float()
    int oldSize = array.size(p.bins)
    if oldSize > 0
        for i = 0 to oldSize - 1 by 2
            float v = array.get(p.bins, i)
            if i + 1 < oldSize
                v += array.get(p.bins, i + 1)
            array.push(merged, v)
        p.bins := merged
        p.step *= 2.0

f_requiredBelow(Profile p, float lo) =>
    lo < p.base ? int(math.ceil((p.base - lo) / p.step)) : 0

f_requiredAbove(Profile p, float hi) =>
    int topIndex = int(math.floor((hi - p.base) / p.step))
    math.max(0, topIndex - array.size(p.bins) + 1)

f_ensureRange(Profile p, float lo, float hi) =>
    int below = f_requiredBelow(p, lo)
    int above = f_requiredAbove(p, hi)
    while array.size(p.bins) + below + above > MAX_ROWS
        f_mergeRows(p)
        below := f_requiredBelow(p, lo)
        above := f_requiredAbove(p, hi)
    if below > 0
        for i = 0 to below - 1
            array.unshift(p.bins, 0.0)
        p.base -= below * p.step
    if above > 0
        for i = 0 to above - 1
            array.push(p.bins, 0.0)

f_resetProfile(Profile p, int periodId, int sourceTime, float candleLow, float candleHigh, bool trustworthy) =>
    array.clear(p.bins)
    p.periodStart := periodId
    p.step := f_initialStep(candleLow, candleHigh)
    p.base := math.floor(candleLow / p.step) * p.step
    p.profileHigh := candleHigh
    p.profileLow := candleLow
    p.totalVolume := 0.0
    p.weightedPriceVolume := 0.0
    p.completeFromStart := trustworthy or sourceTime == periodId
    array.push(p.bins, 0.0)
    f_ensureRange(p, candleLow, candleHigh)

f_addCandle(Profile p, float candleHigh, float candleLow, float candleClose, float candleVolume) =>
    float hi = math.max(candleHigh, candleLow)
    float lo = math.min(candleHigh, candleLow)
    float vol = na(candleVolume) or candleVolume < 0.0 ? 0.0 : candleVolume
    f_ensureRange(p, lo, hi)
    int sz = array.size(p.bins)
    int closeIndex = math.max(0, math.min(sz - 1, int(math.floor((candleClose - p.base) / p.step))))
    float allocated = 0.0
    float weightedAllocated = 0.0
    if vol > 0.0
        if hi <= lo
            array.set(p.bins, closeIndex, array.get(p.bins, closeIndex) + vol)
            allocated := vol
            weightedAllocated := vol * (p.base + (closeIndex + 0.5) * p.step)
        else
            int first = math.max(0, int(math.floor((lo - p.base) / p.step)))
            int last = math.min(sz - 1, int(math.floor((hi - p.base) / p.step)))
            float candleRange = hi - lo
            if last >= first
                for i = first to last
                    float binLow = p.base + i * p.step
                    float binHigh = binLow + p.step
                    float overlap = math.max(0.0, math.min(hi, binHigh) - math.max(lo, binLow))
                    float share = vol * overlap / candleRange
                    if share > 0.0
                        array.set(p.bins, i, array.get(p.bins, i) + share)
                        allocated += share
                        weightedAllocated += share * (p.base + (i + 0.5) * p.step)
            float residual = vol - allocated
            if math.abs(residual) > vol * 1e-10
                array.set(p.bins, closeIndex, array.get(p.bins, closeIndex) + residual)
                allocated += residual
                weightedAllocated += residual * (p.base + (closeIndex + 0.5) * p.step)
    p.totalVolume += allocated
    p.weightedPriceVolume += weightedAllocated
    p.profileHigh := math.max(p.profileHigh, hi)
    p.profileLow := math.min(p.profileLow, lo)

f_profileLevels(Profile p) =>
    float poc = na
    float vah = na
    float val = na
    int sz = array.size(p.bins)
    if sz > 0 and p.totalVolume > 0.0
        float meanPrice = p.weightedPriceVolume / p.totalVolume
        float maxVol = -1.0
        int pocIndex = 0
        for i = 0 to sz - 1
            float v = array.get(p.bins, i)
            float center = p.base + (i + 0.5) * p.step
            float chosenCenter = p.base + (pocIndex + 0.5) * p.step
            float eps = math.max(1e-10, math.abs(maxVol) * 1e-10)
            bool larger = v > maxVol + eps
            bool tied = math.abs(v - maxVol) <= eps
            bool closer = math.abs(center - meanPrice) < math.abs(chosenCenter - meanPrice) - syminfo.mintick * 1e-6
            bool sameDistanceLower = math.abs(math.abs(center - meanPrice) - math.abs(chosenCenter - meanPrice)) <= syminfo.mintick * 1e-6 and center < chosenCenter
            if larger or (tied and (closer or sameDistanceLower))
                maxVol := v
                pocIndex := i
        int lowIndex = pocIndex
        int highIndex = pocIndex
        float included = array.get(p.bins, pocIndex)
        float target = p.totalVolume * 0.70
        while included < target and (lowIndex > 0 or highIndex < sz - 1)
            bool hasBelow = lowIndex > 0
            bool hasAbove = highIndex < sz - 1
            float belowVol = hasBelow ? array.get(p.bins, lowIndex - 1) : -1.0
            float aboveVol = hasAbove ? array.get(p.bins, highIndex + 1) : -1.0
            if hasBelow and hasAbove and math.abs(aboveVol - belowVol) <= math.max(1e-10, math.max(aboveVol, belowVol) * 1e-10)
                lowIndex -= 1
                highIndex += 1
                included += belowVol + aboveVol
            else if hasAbove and (not hasBelow or aboveVol > belowVol)
                highIndex += 1
                included += aboveVol
            else
                lowIndex -= 1
                included += belowVol
        poc := p.base + (pocIndex + 0.5) * p.step
        val := p.base + lowIndex * p.step
        vah := p.base + (highIndex + 1) * p.step
        val := math.min(val, poc)
        vah := math.max(vah, poc)
    [poc, vah, val]

// ─────────────────────────────────────────────────────────────────────────────
// Drawing and lifecycle helpers
// ─────────────────────────────────────────────────────────────────────────────
f_deleteLabel(label id) =>
    if not na(id)
        label.delete(id)

f_deleteLine(line id) =>
    if not na(id)
        line.delete(id)

f_registerNaked(array<NakedLevel> levels, string tf, float price, int origin, int eligible, int limit) =>
    if showNaked and not na(price)
        color c = f_nakedColor(tf)
        line ln = line.new(eligible, price, eligible + 60000, price, xloc = xloc.bar_time,
             extend = extend.right, color = c, style = f_nakedStyle(tf), width = lineWidth)
        label lb = showLabels ? label.new(bar_index + labelOffset, price, f_text(f_prefix(tf) + "NPOC", price),
             xloc = xloc.bar_index, style = label.style_none, textcolor = c, size = labelTextSize) : na
        array.push(levels, NakedLevel.new(price, origin, eligible, bar_index, false, ln, lb))
        while array.size(levels) > limit
            NakedLevel oldest = array.shift(levels)
            f_deleteLine(oldest.levelLine)
            f_deleteLabel(oldest.levelLabel)

f_setPreviousVA(ValueAreaDisplay display, string tf, int origin, int eligible, float poc, float vah, float val) =>
    f_deleteLine(display.vahLine)
    f_deleteLine(display.valLine)
    f_deleteLabel(display.vahLabel)
    f_deleteLabel(display.valLabel)
    if not na(display.areaFill)
        linefill.delete(display.areaFill)
    display.poc := poc
    display.vah := vah
    display.val := val
    display.originStart := origin
    display.vahLine := na
    display.valLine := na
    display.vahLabel := na
    display.valLabel := na
    display.areaFill := na
    // A new period re-arms this timeframe's Value Area alerts.
    display.vahAlerted := false
    display.valAlerted := false
    display.entryAlerted := false
    bool enabledTf = tf == "D" ? showDaily : tf == "W" ? showWeekly : showMonthly
    if showPrevVA and enabledTf and not na(vah) and not na(val)
        color c = f_vaColor(tf)
        display.vahLine := line.new(eligible, vah, eligible + 60000, vah, xloc = xloc.bar_time,
             extend = extend.right, color = c, style = line.style_dotted, width = 1)
        display.valLine := line.new(eligible, val, eligible + 60000, val, xloc = xloc.bar_time,
             extend = extend.right, color = c, style = line.style_dotted, width = 1)
        if showLabels
            display.vahLabel := label.new(bar_index + labelOffset, vah, f_text(f_prevPrefix(tf) + "VAH", vah),
                 xloc = xloc.bar_index, style = label.style_none, textcolor = c, size = labelTextSize)
            display.valLabel := label.new(bar_index + labelOffset, val, f_text(f_prevPrefix(tf) + "VAL", val),
                 xloc = xloc.bar_index, style = label.style_none, textcolor = c, size = labelTextSize)
        if useVAFill
            display.areaFill := linefill.new(display.vahLine, display.valLine, color.new(vaFillColor, vaFillTransparency))

// True when price sits within tol of a level already claimed by a higher timeframe.
f_clashes(array<float> shown, float price, float tol) =>
    bool hit = false
    int n = array.size(shown)
    if n > 0 and tol > 0.0
        for i = 0 to n - 1
            if math.abs(array.get(shown, i) - price) <= tol
                hit := true
    hit

// Whether a price sits inside any zone in one array, and whether it is close
// enough to that zone's 50% midpoint to count as strong confluence.
f_confluenceInArr(array<box> zones, float price) =>
    bool found = false
    bool strong = false
    int n = array.size(zones)
    if n > 0 and not na(price)
        for i = 0 to n - 1
            box b = array.get(zones, i)
            if not na(b)
                float zTop = box.get_top(b)
                float zBot = box.get_bottom(b)
                if price >= zBot and price <= zTop
                    found := true
                    if math.abs(price - (zTop + zBot) / 2.0) <= (zTop - zBot) * confMidPct
                        strong := true
    [found, strong]

// Confluence status of a price against all active vector zones.
f_confluenceAt(float price) =>
    [foundB, strongB] = f_confluenceInArr(vecZonesBelow, price)
    [foundA, strongA] = f_confluenceInArr(vecZonesAbove, price)
    [foundB or foundA, strongB or strongA]

// Brightened variant of the naked colour for confluent levels.
f_confNakedColor(string tf) =>
    int tr = tf == "D" ? dailyTransparency : tf == "W" ? weeklyTransparency : monthlyTransparency
    color.new(f_baseColor(tf), math.max(0, tr - 25))

// Lays out one timeframe's Naked POCs, suppressing any that collide with a
// level already drawn by a higher timeframe. Call monthly first, then weekly,
// then daily, passing the same `shown` array through all three.
f_layoutNaked(array<NakedLevel> levels, string tf, array<float> shown, float tol) =>
    int sz = array.size(levels)
    if sz > 0
        for i = 0 to sz - 1
            NakedLevel rec = array.get(levels, i)
            bool hidden = f_clashes(shown, rec.price, tol)
            [confHere, confStrong] = f_confluenceAt(rec.price)
            bool markConf = confEnabled and confHere
            color levelColor = markConf ? f_confNakedColor(tf) : f_nakedColor(tf)
            string star = markConf ? (confStrong ? "★★" : "★") : ""
            line.set_color(rec.levelLine, hidden ? color.new(color.black, 100) : levelColor)
            line.set_width(rec.levelLine, markConf and confStrong ? 2 : lineWidth)
            if hidden or not showLabels
                f_deleteLabel(rec.levelLabel)
                rec.levelLabel := na
                array.set(levels, i, rec)
            else
                string labelText = f_text(star + f_prefix(tf) + "NPOC", rec.price)
                if na(rec.levelLabel)
                    rec.levelLabel := label.new(bar_index + labelOffset, rec.price, labelText,
                         xloc = xloc.bar_index, style = label.style_none, textcolor = levelColor, size = labelTextSize)
                    array.set(levels, i, rec)
                else
                    label.set_x(rec.levelLabel, bar_index + labelOffset)
                    label.set_text(rec.levelLabel, labelText)
                    label.set_textcolor(rec.levelLabel, levelColor)
            if not hidden
                array.push(shown, rec.price)

f_updateVALabels(ValueAreaDisplay display) =>
    if showLabels
        if not na(display.vahLabel)
            label.set_x(display.vahLabel, bar_index + labelOffset)
        if not na(display.valLabel)
            label.set_x(display.valLabel, bar_index + labelOffset)

f_trimTouched() =>
    while array.size(touchedLines) > MAX_TOUCHED_HISTORY
        line oldLine = array.shift(touchedLines)
        f_deleteLine(oldLine)

f_touchAndApproach(array<NakedLevel> levels, string tf, int sourceTime, float sourceHigh, float sourceLow,
     float sourceClose, float distance) =>
    bool touchedEvent = false
    float touchedPrice = na
    bool approachEvent = false
    float approachPrice = na
    int i = array.size(levels) - 1
    while i >= 0
        NakedLevel rec = array.get(levels, i)
        bool eligible = sourceTime >= rec.eligibleFrom
        bool touched = eligible and sourceLow <= rec.price and sourceHigh >= rec.price
        if touched
            touchedEvent := true
            touchedPrice := rec.price
            if keepTouched
                line.set_x2(rec.levelLine, sourceTime)
                line.set_extend(rec.levelLine, extend.none)
                line.set_color(rec.levelLine, color.new(f_baseColor(tf), 90))
                f_deleteLabel(rec.levelLabel)
                array.push(touchedLines, rec.levelLine)
            else
                f_deleteLine(rec.levelLine)
                f_deleteLabel(rec.levelLabel)
            array.remove(levels, i)
        else
            // `approached` never resets: each level announces its approach once
            // in its lifetime, then stays quiet until the touch retires it.
            bool near = eligible and math.abs(sourceClose - rec.price) <= distance
            if near and not rec.approached
                approachEvent := true
                approachPrice := rec.price
                rec.approached := true
                array.set(levels, i, rec)
        i -= 1
    [touchedEvent, touchedPrice, approachEvent, approachPrice]

f_updateDeveloping(DevelopingDisplay display, Profile p, string tf, bool enabled) =>
    [poc, vah, val] = f_profileLevels(p)
    bool valid = enabled and not na(poc)
    color c = f_devColor(tf)
    if valid
        if na(display.pocLine)
            display.pocLine := line.new(p.periodStart, poc, time_close, poc, xloc = xloc.bar_time, color = c, style = line.style_dotted, width = 1)
        else
            line.set_xy1(display.pocLine, p.periodStart, poc)
            line.set_xy2(display.pocLine, time_close, poc)
        if showDevVA
            if na(display.vahLine)
                display.vahLine := line.new(p.periodStart, vah, time_close, vah, xloc = xloc.bar_time, color = c, style = line.style_dotted, width = 1)
                display.valLine := line.new(p.periodStart, val, time_close, val, xloc = xloc.bar_time, color = c, style = line.style_dotted, width = 1)
            else
                line.set_xy1(display.vahLine, p.periodStart, vah)
                line.set_xy2(display.vahLine, time_close, vah)
                line.set_xy1(display.valLine, p.periodStart, val)
                line.set_xy2(display.valLine, time_close, val)
        else
            f_deleteLine(display.vahLine)
            f_deleteLine(display.valLine)
            display.vahLine := na
            display.valLine := na
        if showLabels
            if na(display.pocLabel)
                display.pocLabel := label.new(bar_index + labelOffset, poc, f_text(f_prefix(tf) + "POC", poc), xloc = xloc.bar_index,
                     style = label.style_none, textcolor = c, size = labelTextSize)
            else
                label.set_xy(display.pocLabel, bar_index + labelOffset, poc)
                label.set_text(display.pocLabel, f_text(f_prefix(tf) + "POC", poc))
            if showDevVA
                if na(display.vahLabel)
                    display.vahLabel := label.new(bar_index + labelOffset, vah, "", xloc = xloc.bar_index,
                         style = label.style_none, textcolor = c, size = labelTextSize)
                if na(display.valLabel)
                    display.valLabel := label.new(bar_index + labelOffset, val, "", xloc = xloc.bar_index,
                         style = label.style_none, textcolor = c, size = labelTextSize)
                label.set_xy(display.vahLabel, bar_index + labelOffset, vah)
                label.set_text(display.vahLabel, f_text(f_prefix(tf) + "VAH", vah))
                label.set_xy(display.valLabel, bar_index + labelOffset, val)
                label.set_text(display.valLabel, f_text(f_prefix(tf) + "VAL", val))
        else
            f_deleteLabel(display.pocLabel)
            f_deleteLabel(display.vahLabel)
            f_deleteLabel(display.valLabel)
            display.pocLabel := na
            display.vahLabel := na
            display.valLabel := na
    else
        f_deleteLine(display.pocLine)
        f_deleteLine(display.vahLine)
        f_deleteLine(display.valLine)
        f_deleteLabel(display.pocLabel)
        f_deleteLabel(display.vahLabel)
        f_deleteLabel(display.valLabel)
        display.pocLine := na
        display.vahLine := na
        display.valLine := na
        display.pocLabel := na
        display.vahLabel := na
        display.valLabel := na
    valid

// ─────────────────────────────────────────────────────────────────────────────
// Lower-timeframe selection and processing
// ─────────────────────────────────────────────────────────────────────────────
float chartSeconds = timeframe.in_seconds()
string automaticLower = chartSeconds <= 900 ? "1" : chartSeconds <= 3600 ? "3" : chartSeconds <= 14400 ? "5" : "15"
string lowerTf = timeframe.in_seconds(automaticLower) <= chartSeconds ? automaticLower : timeframe.period

[ltTimes, ltHighs, ltLows, ltCloses, ltVolumes] = request.security_lower_tf(syminfo.tickerid, lowerTf,
     [time, high, low, close, volume], ignore_invalid_timeframe = true)

float alertDistance = close * approachPct

bool touchD = false
bool touchW = false
bool touchM = false
bool approachD = false
bool approachW = false
bool approachM = false
float touchDPrice = na
float touchWPrice = na
float touchMPrice = na
float approachDPrice = na
float approachWPrice = na
float approachMPrice = na

f_processSource(int t, float h, float l, float c, float v) =>
    int dId = f_dayStart(t)
    int wId = f_weekStart(t)
    int mId = f_monthStart(t)

    if na(dProfile.periodStart)
        f_resetProfile(dProfile, dId, t, l, h, false)
    else if dId != dProfile.periodStart
        [poc, vah, val] = f_profileLevels(dProfile)
        if dProfile.completeFromStart and dProfile.totalVolume > 0.0
            if showDaily
                f_registerNaked(dNaked, "D", poc, dProfile.periodStart, dId, maxDaily)
            f_setPreviousVA(dVA, "D", dProfile.periodStart, dId, poc, vah, val)
        f_resetProfile(dProfile, dId, t, l, h, true)

    if na(wProfile.periodStart)
        f_resetProfile(wProfile, wId, t, l, h, false)
    else if wId != wProfile.periodStart
        [poc, vah, val] = f_profileLevels(wProfile)
        if wProfile.completeFromStart and wProfile.totalVolume > 0.0
            if showWeekly
                f_registerNaked(wNaked, "W", poc, wProfile.periodStart, wId, maxWeekly)
            f_setPreviousVA(wVA, "W", wProfile.periodStart, wId, poc, vah, val)
        f_resetProfile(wProfile, wId, t, l, h, true)

    if na(mProfile.periodStart)
        f_resetProfile(mProfile, mId, t, l, h, false)
    else if mId != mProfile.periodStart
        [poc, vah, val] = f_profileLevels(mProfile)
        if mProfile.completeFromStart and mProfile.totalVolume > 0.0
            if showMonthly
                f_registerNaked(mNaked, "M", poc, mProfile.periodStart, mId, maxMonthly)
            f_setPreviousVA(mVA, "M", mProfile.periodStart, mId, poc, vah, val)
        f_resetProfile(mProfile, mId, t, l, h, true)

    [td, tdp, ad, adp] = f_touchAndApproach(dNaked, "D", t, h, l, c, alertDistance)
    [tw, twp, aw, awp] = f_touchAndApproach(wNaked, "W", t, h, l, c, alertDistance)
    [tm, tmp, am, amp] = f_touchAndApproach(mNaked, "M", t, h, l, c, alertDistance)

    f_addCandle(dProfile, h, l, c, v)
    f_addCandle(wProfile, h, l, c, v)
    f_addCandle(mProfile, h, l, c, v)
    [td, tdp, ad, adp, tw, twp, aw, awp, tm, tmp, am, amp]

int intrabars = array.size(ltTimes)
if intrabars > 0
    for i = 0 to intrabars - 1
        [td, tdp, ad, adp, tw, twp, aw, awp, tm, tmp, am, amp] = f_processSource(
             array.get(ltTimes, i), array.get(ltHighs, i), array.get(ltLows, i), array.get(ltCloses, i), array.get(ltVolumes, i))
        touchD := touchD or td
        touchW := touchW or tw
        touchM := touchM or tm
        approachD := approachD or ad
        approachW := approachW or aw
        approachM := approachM or am
        touchDPrice := td ? tdp : touchDPrice
        touchWPrice := tw ? twp : touchWPrice
        touchMPrice := tm ? tmp : touchMPrice
        approachDPrice := ad ? adp : approachDPrice
        approachWPrice := aw ? awp : approachWPrice
        approachMPrice := am ? amp : approachMPrice
else
    [td, tdp, ad, adp, tw, twp, aw, awp, tm, tmp, am, amp] = f_processSource(time, high, low, close, volume)
    touchD := td
    touchW := tw
    touchM := tm
    approachD := ad
    approachW := aw
    approachM := am
    touchDPrice := tdp
    touchWPrice := twp
    touchMPrice := tmp
    approachDPrice := adp
    approachWPrice := awp
    approachMPrice := amp

f_trimTouched()

// ─────────────────────────────────────────────────────────────────────────────
// Confluence events
// ─────────────────────────────────────────────────────────────────────────────
// Piggybacks on the NPOC touch/approach events above, tested against the zones
// as they stood at the start of this bar (the zone update runs below), so a
// touch that clears the level or the zone in the same bar still counts.
[confTouchInD, confTouchStrongD] = f_confluenceAt(touchDPrice)
[confTouchInW, confTouchStrongW] = f_confluenceAt(touchWPrice)
[confTouchInM, confTouchStrongM] = f_confluenceAt(touchMPrice)
[confNearInD, confNearStrongD] = f_confluenceAt(approachDPrice)
[confNearInW, confNearStrongW] = f_confluenceAt(approachWPrice)
[confNearInM, confNearStrongM] = f_confluenceAt(approachMPrice)

bool confTouchD = confEnabled and touchD and confTouchInD
bool confTouchW = confEnabled and touchW and confTouchInW
bool confTouchM = confEnabled and touchM and confTouchInM
bool touchConfluence = confTouchD or confTouchW or confTouchM
bool touchConfluenceStrong = (confTouchD and confTouchStrongD) or (confTouchW and confTouchStrongW) or (confTouchM and confTouchStrongM)
float touchConfluencePrice = confTouchM ? touchMPrice : confTouchW ? touchWPrice : touchDPrice
string touchConfluenceTf = confTouchM ? "Monthly" : confTouchW ? "Weekly" : "Daily"

bool confNearD = confEnabled and approachD and confNearInD
bool confNearW = confEnabled and approachW and confNearInW
bool confNearM = confEnabled and approachM and confNearInM
bool approachConfluence = confNearD or confNearW or confNearM
bool approachConfluenceStrong = (confNearD and confNearStrongD) or (confNearW and confNearStrongW) or (confNearM and confNearStrongM)
float approachConfluencePrice = confNearM ? approachMPrice : confNearW ? approachWPrice : approachDPrice
string approachConfluenceTf = confNearM ? "Monthly" : confNearW ? "Weekly" : "Daily"

// ─────────────────────────────────────────────────────────────────────────────
// Vector candle zones
// ─────────────────────────────────────────────────────────────────────────────
// Classification runs unconditionally so the library's rolling averages stay
// consistent on every bar; only the drawing is gated by the toggle.
[pvsraColor, _vecAlertFlag, _vecAvgVol, _vecVolSpread, _vecHighestSpread] =
     trLib.calcPvsra(volume, high, low, close, open,
     C_VEC_RED, C_VEC_GREEN, C_VEC_VIOLET, C_VEC_BLUE, C_REG_DOWN, C_REG_UP)
pvsraFlag = trLib.getPvsraFlagByColor(pvsraColor, C_VEC_RED, C_VEC_GREEN, C_VEC_VIOLET, C_VEC_BLUE, C_REG_UP)

// Reports the first zone the bar overlaps, plus the nearest non-touched zone
// edge, from one side's zone array.
f_scanZones(array<box> zones, float hi, float lo, float cl) =>
    bool touching = false
    float touchTop = na
    float touchBottom = na
    float nearDist = na
    float nearTop = na
    float nearBottom = na
    int n = array.size(zones)
    if n > 0
        for i = 0 to n - 1
            box b = array.get(zones, i)
            if not na(b)
                float zTop = box.get_top(b)
                float zBottom = box.get_bottom(b)
                if hi >= zBottom and lo <= zTop
                    if not touching
                        touching := true
                        touchTop := zTop
                        touchBottom := zBottom
                else
                    float d = cl > zTop ? cl - zTop : math.max(0.0, zBottom - cl)
                    if na(nearDist) or d < nearDist
                        nearDist := d
                        nearTop := zTop
                        nearBottom := zBottom
    [touching, touchTop, touchBottom, nearDist, nearTop, nearBottom]

// Scan against the zones as they stood at the end of the previous bar, so a
// candle that both enters and clears a zone still registers the touch.
[vTouchB, vTouchTopB, vTouchBotB, vDistB, vNearTopB, vNearBotB] = f_scanZones(vecZonesBelow, high, low, close)
[vTouchA, vTouchTopA, vTouchBotA, vDistA, vNearTopA, vNearBotA] = f_scanZones(vecZonesAbove, high, low, close)

bool inVecZone = showVectors and (vTouchB or vTouchA)
float vecTouchTop = vTouchB ? vTouchTopB : vTouchTopA
float vecTouchBottom = vTouchB ? vTouchBotB : vTouchBotA
bool nearerIsBelow = na(vDistA) or (not na(vDistB) and vDistB <= vDistA)
float vecNearDist = nearerIsBelow ? vDistB : vDistA
float vecNearTop = nearerIsBelow ? vNearTopB : vNearTopA
float vecNearBottom = nearerIsBelow ? vNearBotB : vNearBotA

// Once-per-zone alert latches. A zone's top/bottom never move after creation,
// so the pair identifies it. Entry and approach latch independently.
var array<float> entryAlertedTops = array.new_float()
var array<float> entryAlertedBots = array.new_float()
var array<float> nearAlertedTops = array.new_float()
var array<float> nearAlertedBots = array.new_float()

f_zoneSeen(array<float> tops, array<float> bots, float zTop, float zBot) =>
    bool hit = false
    int n = array.size(tops)
    if n > 0 and not na(zTop)
        for i = 0 to n - 1
            if math.abs(array.get(tops, i) - zTop) <= syminfo.mintick * 0.5 and math.abs(array.get(bots, i) - zBot) <= syminfo.mintick * 0.5
                hit := true
    hit

f_zoneMark(array<float> tops, array<float> bots, float zTop, float zBot) =>
    array.push(tops, zTop)
    array.push(bots, zBot)
    // Bounded history: far larger than the number of zones ever on screen.
    while array.size(tops) > 600
        array.shift(tops)
        array.shift(bots)

bool enteredVecZone = inVecZone and not inVecZone[1] and not f_zoneSeen(entryAlertedTops, entryAlertedBots, vecTouchTop, vecTouchBottom)
if enteredVecZone
    f_zoneMark(entryAlertedTops, entryAlertedBots, vecTouchTop, vecTouchBottom)
bool nearVecZone = showVectors and not inVecZone and not na(vecNearDist) and vecNearDist <= alertDistance
bool approachVecZone = nearVecZone and not nearVecZone[1] and not enteredVecZone and not f_zoneSeen(nearAlertedTops, nearAlertedBots, vecNearTop, vecNearBottom)
if approachVecZone
    f_zoneMark(nearAlertedTops, nearAlertedBots, vecNearTop, vecNearBottom)

if showVectors
    color vecOverrideColor = color.new(vecZoneColor, vecTransparency)
    bool useSingleColour = vecColorMode == "Single colour"
    trLib.updateZones(pvsraFlag, 0, vecZonesBelow, VEC_MAX_ZONES, high, low, open, close,
         vecTransparency, VEC_CLEAR_TYPE, vecOverrideColor, VEC_ZONE_TYPE, VEC_BORDER_WIDTH,
         useSingleColour, vecRed, vecGreen, vecViolet, vecBlue)
    trLib.updateZones(pvsraFlag, 1, vecZonesAbove, VEC_MAX_ZONES, high, low, open, close,
         vecTransparency, VEC_CLEAR_TYPE, vecOverrideColor, VEC_ZONE_TYPE, VEC_BORDER_WIDTH,
         useSingleColour, vecRed, vecGreen, vecViolet, vecBlue)
    trLib.cleanarr(vecZonesBelow)
    trLib.cleanarr(vecZonesAbove)

// ─────────────────────────────────────────────────────────────────────────────
// Display maintenance
// ─────────────────────────────────────────────────────────────────────────────
if barstate.islast
    // Highest timeframe first — it claims its price, and anything closer than
    // the overlap tolerance below it is suppressed.
    float clashTol = close * overlapPct
    array<float> shownPrices = array.new_float()
    f_layoutNaked(mNaked, "M", shownPrices, clashTol)
    f_layoutNaked(wNaked, "W", shownPrices, clashTol)
    f_layoutNaked(dNaked, "D", shownPrices, clashTol)
    f_updateVALabels(dVA)
    f_updateVALabels(wVA)
    f_updateVALabels(mVA)

f_updateDeveloping(dDev, dProfile, "D", showDaily and showDevD)
f_updateDeveloping(wDev, wProfile, "W", showWeekly and showDevW)
f_updateDeveloping(mDev, mProfile, "M", showMonthly and showDevM)

// Small, conditional warnings only. No panel or background alteration.
var label warningLabel = na
if barstate.islast
    f_deleteLabel(warningLabel)
    string warning = not chart.is_standard ? "Standard candles recommended" : ""
    warningLabel := str.length(warning) > 0 ? label.new(bar_index, low, warning, xloc = xloc.bar_index,
         style = label.style_none, textcolor = color.new(color.silver, 65), size = labelTextSize) : na

// ─────────────────────────────────────────────────────────────────────────────
// Previous Value Area events
// ─────────────────────────────────────────────────────────────────────────────
bool dVahCrossRaw = ta.cross(close, dVA.vah)
bool wVahCrossRaw = ta.cross(close, wVA.vah)
bool mVahCrossRaw = ta.cross(close, mVA.vah)
bool dValCrossRaw = ta.cross(close, dVA.val)
bool wValCrossRaw = ta.cross(close, wVA.val)
bool mValCrossRaw = ta.cross(close, mVA.val)
// Each Value Area event fires once per period per side; the latches reset
// when the timeframe rolls into a new period (f_setPreviousVA).
bool dVahCross = showDaily and showPrevVA and not na(dVA.vah) and dVahCrossRaw and not dVA.vahAlerted
bool wVahCross = showWeekly and showPrevVA and not na(wVA.vah) and wVahCrossRaw and not wVA.vahAlerted
bool mVahCross = showMonthly and showPrevVA and not na(mVA.vah) and mVahCrossRaw and not mVA.vahAlerted
bool dValCross = showDaily and showPrevVA and not na(dVA.val) and dValCrossRaw and not dVA.valAlerted
bool wValCross = showWeekly and showPrevVA and not na(wVA.val) and wValCrossRaw and not wVA.valAlerted
bool mValCross = showMonthly and showPrevVA and not na(mVA.val) and mValCrossRaw and not mVA.valAlerted
if dVahCross
    dVA.vahAlerted := true
if wVahCross
    wVA.vahAlerted := true
if mVahCross
    mVA.vahAlerted := true
if dValCross
    dVA.valAlerted := true
if wValCross
    wVA.valAlerted := true
if mValCross
    mVA.valAlerted := true
bool crossVAH = dVahCross or wVahCross or mVahCross
bool crossVAL = dValCross or wValCross or mValCross

bool inDVA = showDaily and showPrevVA and not na(dVA.vah) and close <= dVA.vah and close >= dVA.val
bool inWVA = showWeekly and showPrevVA and not na(wVA.vah) and close <= wVA.vah and close >= wVA.val
bool inMVA = showMonthly and showPrevVA and not na(mVA.vah) and close <= mVA.vah and close >= mVA.val
bool dEnterVA = inDVA and not inDVA[1] and not dVA.entryAlerted
bool wEnterVA = inWVA and not inWVA[1] and not wVA.entryAlerted
bool mEnterVA = inMVA and not inMVA[1] and not mVA.entryAlerted
if dEnterVA
    dVA.entryAlerted := true
if wEnterVA
    wVA.entryAlerted := true
if mEnterVA
    mVA.entryAlerted := true
bool enteredVA = dEnterVA or wEnterVA or mEnterVA

// Selectable alert conditions.
alertcondition(approachD, "Approaching Daily Naked POC", "{{ticker}} approaching a Daily Naked POC. Current price: {{close}}")
alertcondition(approachW, "Approaching Weekly Naked POC", "{{ticker}} approaching a Weekly Naked POC. Current price: {{close}}")
alertcondition(approachM, "Approaching Monthly Naked POC", "{{ticker}} approaching a Monthly Naked POC. Current price: {{close}}")
alertcondition(touchD, "Touching Daily Naked POC", "{{ticker}} touched a Daily Naked POC. Current price: {{close}}")
alertcondition(touchW, "Touching Weekly Naked POC", "{{ticker}} touched a Weekly Naked POC. Current price: {{close}}")
alertcondition(touchM, "Touching Monthly Naked POC", "{{ticker}} touched a Monthly Naked POC. Current price: {{close}}")
alertcondition(crossVAH, "Crossing Previous VAH", "{{ticker}} crossed a previous Value Area High. Current price: {{close}}")
alertcondition(crossVAL, "Crossing Previous VAL", "{{ticker}} crossed a previous Value Area Low. Current price: {{close}}")
alertcondition(enteredVA, "Entering Previous Value Area", "{{ticker}} entered a previous Value Area. Current price: {{close}}")
alertcondition(enteredVecZone, "Touching Vector Zone", "{{ticker}} entered a vector zone. Current price: {{close}}")
alertcondition(approachVecZone, "Approaching Vector Zone", "{{ticker}} approaching a vector zone. Current price: {{close}}")
alertcondition(touchConfluence, "Touching Confluence", "{{ticker}} touched a Naked POC inside a vector zone. Current price: {{close}}")
alertcondition(approachConfluence, "Approaching Confluence", "{{ticker}} approaching a Naked POC inside a vector zone. Current price: {{close}}")

f_alertMessage(string tf, string eventName, float levelPrice) =>
    syminfo.ticker + " | " + tf + " " + eventName + " | level " + str.tostring(levelPrice, format.mintick) +
         " | current " + str.tostring(close, format.mintick)

if enableAlerts and barstate.isrealtime
    if approachD
        alert(f_alertMessage("Daily", "Naked POC approach", approachDPrice), alert.freq_once_per_bar)
    if approachW
        alert(f_alertMessage("Weekly", "Naked POC approach", approachWPrice), alert.freq_once_per_bar)
    if approachM
        alert(f_alertMessage("Monthly", "Naked POC approach", approachMPrice), alert.freq_once_per_bar)
    if touchD
        alert(f_alertMessage("Daily", "Naked POC touch", touchDPrice), alert.freq_once_per_bar)
    if touchW
        alert(f_alertMessage("Weekly", "Naked POC touch", touchWPrice), alert.freq_once_per_bar)
    if touchM
        alert(f_alertMessage("Monthly", "Naked POC touch", touchMPrice), alert.freq_once_per_bar)
    if dVahCross
        alert(f_alertMessage("Daily", "previous VAH cross", dVA.vah), alert.freq_once_per_bar)
    if wVahCross
        alert(f_alertMessage("Weekly", "previous VAH cross", wVA.vah), alert.freq_once_per_bar)
    if mVahCross
        alert(f_alertMessage("Monthly", "previous VAH cross", mVA.vah), alert.freq_once_per_bar)
    if dValCross
        alert(f_alertMessage("Daily", "previous VAL cross", dVA.val), alert.freq_once_per_bar)
    if wValCross
        alert(f_alertMessage("Weekly", "previous VAL cross", wVA.val), alert.freq_once_per_bar)
    if mValCross
        alert(f_alertMessage("Monthly", "previous VAL cross", mVA.val), alert.freq_once_per_bar)
    if dEnterVA
        alert(syminfo.ticker + " | Daily previous Value Area entry | " + str.tostring(dVA.val, format.mintick) +
             "–" + str.tostring(dVA.vah, format.mintick) + " | current " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
    if wEnterVA
        alert(syminfo.ticker + " | Weekly previous Value Area entry | " + str.tostring(wVA.val, format.mintick) +
             "–" + str.tostring(wVA.vah, format.mintick) + " | current " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
    if mEnterVA
        alert(syminfo.ticker + " | Monthly previous Value Area entry | " + str.tostring(mVA.val, format.mintick) +
             "–" + str.tostring(mVA.vah, format.mintick) + " | current " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
    if enteredVecZone
        alert(syminfo.ticker + " | Vector zone touch | zone " + str.tostring(vecTouchBottom, format.mintick) +
             "–" + str.tostring(vecTouchTop, format.mintick) + " | current " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
    if approachVecZone
        alert(syminfo.ticker + " | Vector zone approach | zone " + str.tostring(vecNearBottom, format.mintick) +
             "–" + str.tostring(vecNearTop, format.mintick) + " | current " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
    if touchConfluence
        alert(syminfo.ticker + " | " + (touchConfluenceStrong ? "STRONG CONFLUENCE touch" : "Confluence touch") +
             " | " + touchConfluenceTf + " NPOC " + str.tostring(touchConfluencePrice, format.mintick) +
             " inside vector zone | current " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
    if approachConfluence
        alert(syminfo.ticker + " | " + (approachConfluenceStrong ? "STRONG CONFLUENCE approach" : "Confluence approach") +
             " | " + approachConfluenceTf + " NPOC " + str.tostring(approachConfluencePrice, format.mintick) +
             " inside vector zone | current " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
````
