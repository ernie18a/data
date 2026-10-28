# STDV | 15m + 5m + 1m Manipulation Legs

- url: https://www.tradingview.com/script/XV44UIsD-STDV-15m-5m-1m-Manipulation-Legs/
- type: indicator
- pine_id: PUB;0a0862b0e1c24c9e81822cb9b2364a2e
- version: 1.0

## Description

# STDV Manipulation Leg Engine

**STDV Manipulation Leg Engine** is a focused multi-timeframe tool designed to automatically identify meaningful manipulation legs and project Standard Deviation levels from them.

The concept is simple:

**Manipulation → Structure Shift → STDV Expansion**

Instead of projecting from arbitrary swings, the indicator attempts to isolate the price leg most closely connected to a meaningful reversal or structural transition.

## What It Does

The script independently analyzes:

- **15-minute structure**
- **5-minute structure**
- **1-minute structure**

Each timeframe runs its own STDV engine, allowing higher- and lower-timeframe structures to remain active at the same time.

This makes it possible to visualize nested manipulation sequences across multiple intraday timeframes without manually redrawing every projection.

## Automatic Leg Detection

The indicator looks for structurally relevant price movement such as:

- meaningful swing points;
- liquidity excursions beyond prior highs or lows;
- directional manipulation legs;
- subsequent structural confirmation;
- the most relevant anchor pair for the active sequence.

Once a leg is confirmed, its anchors are used to generate the corresponding STDV projection.

## STDV Levels

The script can display commonly used projected levels including:

- -1.0
- -1.5
- -2.0
- -2.25
- -2.5
- -3.5
- -4.0
- -4.75

These levels are intended as **objective reference zones for price expansion**, not automatic trade signals.

## Multi-Timeframe Confluence

One of the main advantages of the indicator is the ability to compare several independent STDV structures at once.

For example, a 15-minute projection may remain active while a new 5-minute or 1-minute manipulation leg develops inside it.

When projections from different timeframes begin clustering around a similar price area, traders can use that information as an additional point of context.

## Developing and Confirmed Structure

Developing legs may update as price continues to form.

Once the required structural confirmation occurs, the leg becomes confirmed and its anchors are intended to remain fixed.

This helps distinguish live developing information from confirmed historical structure.

## Designed to Stay Focused

This is intentionally not an all-in-one indicator.

It does not rely on:

- moving averages;
- VWAP;
- Bollinger Bands;
- RSI or MACD;
- order blocks;
- FVG signals;
- volume profile;
- automatic buy/sell signals.

The goal is to keep the chart clean and focus specifically on **manipulation-leg structure and STDV projection mapping**.

## Suggested Applications

The indicator can be used for:

- identifying potential expansion objectives;
- studying manipulation-to-expansion behavior;
- comparing 15m, 5m, and 1m structure;
- locating multi-timeframe projection overlap;
- adding objective STDV levels to discretionary price-action analysis.

It is designed primarily for intraday futures and index markets, although the underlying methodology may be applied to other sufficiently liquid markets.

## Important

STDV levels are not guaranteed support, resistance, entries, exits, or targets.

Market structure, volatility, session context, and risk management should always be considered separately.

This indicator is provided for educational and analytical purposes only and does not constitute financial advice.

## Source Code

````pine
//@version=6
indicator("STDV | 15m + 5m + 1m Manipulation Legs", "STDV M Legs r2", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 100, max_bars_back = 500, dynamic_requests = true)

// Source: Standard Deviation + Power of Three p11; mentorship pp1-3.
// Literal fib: A = 0, B = 1, price(r) = A + r * (B - A).
// Expansion magnitude 2 is fib -2. This is not statistical standard deviation.
// Numerical thresholds are transparent engineering choices, not source statistics.
// Revision 2: final-subleg selection, fresh-sweep ownership and expiry ordering.
// Display update: expansion 4.25 replaces 4.75; outer bound 4.5; black defaults.

const string GVIEW = "Display"
const string GLEVEL = "STDV levels | expansion numbers mean negative fib ratios"
const string GDETECT = "Detection and lifecycle"
const string G15 = "15m engine"
const string G5 = "5m engine"
const string G1 = "1m engine"

const string GSMT = "Optional SMT at STDV zones"
bool showSMT = input.bool(false, "Show SMT markers near reaction zones", tooltip = "Compare confirmed, same-bar native pivots only. Markers can appear after the reaction because pivot confirmation takes time. This does not change manipulation anchors or generate trade signals.", group = GSMT, display = display.none)
string smtPeerMode = input.string("Auto NQ/MNQ", "Comparison symbol", options = ["Auto NQ/MNQ", "Manual symbol"], group = GSMT, display = display.none)
string smtManualPeer = input.symbol("CME_MINI:ES1!", "Manual comparison symbol", tooltip = "Auto maps NQ to ES and MNQ to MES, preserving the contract suffix. Other chart symbols require Manual symbol.", group = GSMT, display = display.none)

bool show15 = input.bool(true, "Show 15m STDV", group = GVIEW, display = display.none)
bool show5 = input.bool(true, "Show 5m STDV", group = GVIEW, display = display.none)
bool show1 = input.bool(true, "Show 1m STDV", group = GVIEW, display = display.none)
bool showLeg = input.bool(true, "Show manipulation leg and exact anchors", group = GVIEW, display = display.none)
bool showLabels = input.bool(true, "Show labels", group = GVIEW, display = display.none)
bool showDeveloping = input.bool(true, "Show developing anchor bubbles (1m / 5m / 15m)", tooltip = "Show only the two anchor bubbles for pending legs. Hover a bubble for its timeframe and developing state. Bubbles may move or disappear; level lines appear only after confirmation. Requires Show manipulation leg and exact anchors.", group = GVIEW, display = display.none)
bool liveDeveloping = input.bool(true, "Preview the forming chart candle", tooltip = "Preview the current chart timeframe's open candle, including 5m candles on a 5m chart. Confirmed legs still require a closed native candle. Other engines use their completed native candles.", group = GVIEW, display = display.none)
bool showPrevious = input.bool(true, "Show previous legs", group = GVIEW, display = display.none)
bool showInvalidated = input.bool(false, "Show invalidated legs (faded history)", group = GVIEW, display = display.none)
string historyMode = input.string("Last 2 legs", "Leg history per timeframe", options = ["Current leg only", "Last 2 legs", "Last 3 legs", "Historical legs"], group = GVIEW, display = display.none)
int historyCap = input.int(8, "Historical legs per timeframe (bounded)", minval = 3, maxval = 8, group = GVIEW, display = display.none)
int projectionMinutes = input.int(30, "Active projection horizon (minutes)", minval = 5, maxval = 240, group = GVIEW, display = display.none)
bool signedLabels = input.bool(true, "Use literal signed fib labels", tooltip = "On: -2 means A + (-2)*(B-A). Off: E2 labels the identical expansion price. The measured endpoint stays '1 leg'.", group = GVIEW, display = display.none)
bool showPrimary = input.bool(true, "Show primary zone (-2 to -2.5)", group = GVIEW, display = display.none)
bool showMax = input.bool(true, "Show max expansion zone (-3.5 to -4.5)", group = GVIEW, display = display.none)
bool showContinuation = input.bool(false, "Show continuation zone (-1 to -1.5)", group = GVIEW, display = display.none)
bool showClusters = input.bool(false, "Show STDV clusters (current active legs only)", group = GVIEW, display = display.none)
int clusterTicks = input.int(4, "Cluster tolerance (ticks)", minval = 1, maxval = 100, group = GVIEW, display = display.none)
bool debugMode = input.bool(false, "Debug mode", group = GVIEW, display = display.none)

bool l0 = input.bool(true, "Show 0 (origin A)", group = GLEVEL, display = display.none)
bool l05 = input.bool(true, "Show 0.5 (measured midpoint)", group = GLEVEL, display = display.none)
bool l1 = input.bool(true, "Show 1 (measured endpoint B)", group = GLEVEL, display = display.none)
bool e1on = input.bool(true, "Show expansion 1 (fib -1)", group = GLEVEL, display = display.none)
bool l15 = input.bool(true, "Show expansion 1.5 (fib -1.5)", group = GLEVEL, display = display.none)
bool l2 = input.bool(true, "Show expansion 2 (fib -2)", group = GLEVEL, display = display.none)
bool l225 = input.bool(true, "Show expansion 2.25 (fib -2.25)", group = GLEVEL, display = display.none)
bool l25 = input.bool(true, "Show expansion 2.5 (fib -2.5)", group = GLEVEL, display = display.none)
bool l3 = input.bool(true, "Show expansion 3 (fib -3)", group = GLEVEL, display = display.none)
bool l35 = input.bool(true, "Show expansion 3.5 (fib -3.5)", group = GLEVEL, display = display.none)
bool l4 = input.bool(true, "Show expansion 4 (fib -4)", group = GLEVEL, display = display.none)
bool l425 = input.bool(true, "Show expansion 4.25 (fib -4.25)", group = GLEVEL, display = display.none)
bool l45 = input.bool(true, "Show expansion 4.5 (fib -4.5)", group = GLEVEL, display = display.none)
var array<float> ratios = array.from(0.0, 0.5, 1.0, -1.0, -1.5, -2.0, -2.25, -2.5, -3.0, -3.5, -4.0, -4.25, -4.5)
var array<bool> enabled = array.from(l0, l05, l1, e1on, l15, l2, l225, l25, l3, l35, l4, l425, l45)

bool useATR = input.bool(true, "Normalize minimum leg and displacement with ATR(14)", group = GDETECT, display = display.none)
int minLegTicks = input.int(8, "Minimum measured leg (ticks)", minval = 1, maxval = 200, group = GDETECT, display = display.none)
int sweepTicks = input.int(1, "Minimum sweep penetration (ticks)", minval = 1, maxval = 20, group = GDETECT, display = display.none)
int breakTicks = input.int(1, "MSS close buffer (ticks)", minval = 0, maxval = 20, group = GDETECT, display = display.none)
float bodyFraction = input.float(0.55, "Displacement body / candle range", minval = 0.1, maxval = 1.0, step = 0.05, group = GDETECT, display = display.none)
string mssModel = input.string("Origin swing", "MSS reference", options = ["Origin swing", "Latest internal swing"], tooltip = "Origin swing confirms through A. Internal swing can use a confirmed rebound pivot after B; it never becomes A unless price first makes a new extreme.", group = GDETECT, display = display.none)
string confirmMode = input.string("Displacement close", "MSS confirmation", options = ["Displacement close", "Two closes + displacement", "Close through only"], group = GDETECT, display = display.none)
string resetMode = input.string("Midnight + 09:30 + 18:00", "Context boundaries", options = ["Midnight + 09:30 + 18:00", "Midnight only", "4-hour blocks"], group = GDETECT, display = display.none)
string contextTimezone = input.string("America/New_York", "Context timezone (IANA)", group = GDETECT, display = display.none)
float completeAt = input.float(4.5, "Complete at expansion magnitude", options = [4.0, 4.25, 4.5], group = GDETECT, display = display.none)
int activeLife = input.int(180, "Maximum active projection age (source bars)", minval = 10, maxval = 1000, group = GDETECT, display = display.none)
string invalidationLevel = input.string("0.5", "Invalidate at measured level", options = ["0.5", "1"], tooltip = "A = 0; B = 1. 0.5 is the midpoint; 1 is the manipulation extreme. Check every later closed source candle, including older retained legs.", group = GDETECT, display = display.none)
string invalidationTrigger = input.string("Touch", "Invalidation trigger", options = ["Touch", "Close"], tooltip = "Touch uses the closed source candle's wick; Close requires its closing price at or beyond the level. The confirmation candle's earlier wick is excluded.", group = GDETECT, display = display.none)

string preset15 = input.string("Balanced", "Strictness", options = ["Sensitive", "Balanced", "Major Only"], group = G15, display = display.none)
int left15 = input.int(3, "Base pivot left bars", minval = 1, maxval = 10, group = G15, display = display.none)
int right15 = input.int(3, "Base pivot right bars", minval = 1, maxval = 10, group = G15, display = display.none)
float size15 = input.float(1.40, "Base minimum leg / ATR", minval = 0.1, step = 0.05, group = G15, display = display.none)
float body15 = input.float(0.55, "Base displacement body / ATR", minval = 0.05, step = 0.05, group = G15, display = display.none)
int span15 = input.int(12, "Maximum origin-to-extreme bars", minval = 3, maxval = 100, group = G15, display = display.none)
int wait15 = input.int(8, "Maximum sweep-to-confirmation bars", minval = 2, maxval = 100, group = G15, display = display.none)
color c15 = input.color(#000000, "Color", group = G15, display = display.none)
int w15 = input.int(2, "Line width", minval = 1, maxval = 4, group = G15, display = display.none)
int tr15 = input.int(0, "Line transparency", minval = 0, maxval = 90, group = G15, display = display.none)

string preset5 = input.string("Balanced", "Strictness", options = ["Sensitive", "Balanced", "Major Only"], group = G5, display = display.none)
int left5 = input.int(3, "Base pivot left bars", minval = 1, maxval = 10, group = G5, display = display.none)
int right5 = input.int(2, "Base pivot right bars", minval = 1, maxval = 10, group = G5, display = display.none)
float size5 = input.float(1.20, "Base minimum leg / ATR", minval = 0.1, step = 0.05, group = G5, display = display.none)
float body5 = input.float(0.50, "Base displacement body / ATR", minval = 0.05, step = 0.05, group = G5, display = display.none)
int span5 = input.int(18, "Maximum origin-to-extreme bars", minval = 3, maxval = 100, group = G5, display = display.none)
int wait5 = input.int(10, "Maximum sweep-to-confirmation bars", minval = 2, maxval = 100, group = G5, display = display.none)
color c5 = input.color(#000000, "Color", group = G5, display = display.none)
int w5 = input.int(1, "Line width", minval = 1, maxval = 4, group = G5, display = display.none)
int tr5 = input.int(0, "Line transparency", minval = 0, maxval = 90, group = G5, display = display.none)

string preset1 = input.string("Balanced", "Strictness", options = ["Sensitive", "Balanced", "Major Only"], group = G1, display = display.none)
int left1 = input.int(2, "Base pivot left bars", minval = 1, maxval = 10, group = G1, display = display.none)
int right1 = input.int(2, "Base pivot right bars", minval = 1, maxval = 10, group = G1, display = display.none)
float size1 = input.float(1.00, "Base minimum leg / ATR", minval = 0.1, step = 0.05, group = G1, display = display.none)
float body1 = input.float(0.45, "Base displacement body / ATR", minval = 0.05, step = 0.05, group = G1, display = display.none)
int span1 = input.int(20, "Maximum origin-to-extreme bars", minval = 3, maxval = 100, group = G1, display = display.none)
int wait1 = input.int(12, "Maximum sweep-to-confirmation bars", minval = 2, maxval = 100, group = G1, display = display.none)
color c1 = input.color(#000000, "Color", group = G1, display = display.none)
int w1 = input.int(1, "Line width", minval = 1, maxval = 4, group = G1, display = display.none)
int tr1 = input.int(0, "Line transparency", minval = 0, maxval = 90, group = G1, display = display.none)

type Config
    int leftBars
    int rightBars
    float minAtr
    float bodyAtr
    int maxLeg
    int maxWait
    bool twoCloses

type Feed
    int t
    int tc
    int n
    int ctx
    float o
    float h
    float l
    float c
    float atr
    float ph
    float pl
    int pivotTime
    int pivotIndex
    int windowTime
    float tick = na

type Candidate
    int dir = 0
    float a = na
    float b = na
    int at = na
    int bt = na
    int ai = na
    int bi = na
    float sweep = na
    float mss = na
    int sweepT = na
    int mssT = na
    int startIndex = na
    float norm = na
    int closes = 0
    bool strong = false
    string phase = "IDLE"

type Leg
    float a
    float b
    int at
    int bt
    int confirmed
    int stopT
    int confirmIndex
    int dir
    float sweep
    float mss
    string status = "ACTIVE"
    int sweptAt = na
    int sweepEvent = na
    int invalidatedAt = na
    float invalidationPrice = na
    int smt2At = na
    int smt2Pivot = na
    float smt2Price = na
    float smt2Magnitude = na
    string smt2Evidence = ""
    int smt4At = na
    int smt4Pivot = na
    float smt4Price = na
    float smt4Magnitude = na
    string smt4Evidence = ""

type Engine
    int lastT = na
    int lastClose = na
    int ctx = na
    int lastIndex = na
    int segmentStart = na
    float lastAtr = na
    float lastPrice = na
    float hi = na
    float lo = na
    int hiT = na
    int loT = na
    int hiI = na
    int loI = na
    bool usedHi = false
    bool usedLo = false
    Candidate bull
    Candidate bear
    array<Leg> legs
    string reason = "Warming up / no source data yet"

f_config(string preset, int leftBase, int rightBase, float sizeBase, float bodyBase, int span, int waitBars) =>
    int shift = preset == "Sensitive" ? -1 : preset == "Major Only" ? 1 : 0
    float scale = preset == "Sensitive" ? 0.75 : preset == "Major Only" ? 1.35 : 1.0
    float bodyScale = preset == "Sensitive" ? 0.80 : preset == "Major Only" ? 1.25 : 1.0
    Config.new(math.max(1, leftBase + shift), math.max(1, rightBase + shift), sizeBase * scale, bodyBase * bodyScale, span, waitBars, preset == "Major Only" or confirmMode == "Two closes + displacement")

f_engine() =>
    Engine.new(bull = Candidate.new(), bear = Candidate.new(), legs = array.new<Leg>())

f_context() =>
    int hr = hour(time, contextTimezone)
    int mn = minute(time, contextTimezone)
    int minutesNow = hr * 60 + mn
    int boundary = resetMode == "4-hour blocks" ? int(math.floor(hr / 4)) * 240 : resetMode == "Midnight only" ? 0 : minutesNow >= 1080 ? 1080 : minutesNow >= 570 ? 570 : 0
    timestamp(contextTimezone, year(time, contextTimezone), month(time, contextTimezone), dayofmonth(time, contextTimezone), int(math.floor(boundary / 60)), boundary % 60)

// Called on every native bar. A NEW scalar-only object prevents history aliasing.
f_feed(int leftBars, int rightBars) =>
    int contextKey = f_context()
    float ph = ta.pivothigh(high, leftBars, rightBars)
    float pl = ta.pivotlow(low, leftBars, rightBars)
    float nativeAtr = ta.atr(14)
    bool coherent = not na(contextKey[leftBars + rightBars]) and contextKey == contextKey[leftBars + rightBars]
    Feed.new(time, time_close, bar_index, contextKey, open, high, low, close, nativeAtr, coherent ? ph : na, coherent ? pl : na, time[rightBars], bar_index - rightBars, time[leftBars + rightBars], syminfo.mintick)

f_closedFeed(int leftBars, int rightBars) =>
    Feed snapshot = f_feed(leftBars, rightBars)
    snapshot[1]

f_minRange(float norm, Config cfg) =>
    math.max(minLegTicks * syminfo.mintick, useATR ? norm * cfg.minAtr : 0.0)

f_newCandidate(int dir, float a, int at, int ai, float b, int bt, int bi, float swept, int sweptTime, float norm) =>
    Candidate.new(dir = dir, a = a, b = b, at = at, bt = bt, ai = ai, bi = bi, sweep = swept, mss = a, sweepT = sweptTime, mssT = at, startIndex = bi, norm = norm, phase = "CANDIDATE")

method retire(Engine e, string why, int endTime) =>
    if array.size(e.legs) > 0
        Leg last = array.get(e.legs, array.size(e.legs) - 1)
        if last.status == "ACTIVE"
            last.status := why
            last.stopT := endTime

method resetSequence(Engine e, string why, int endTime) =>
    e.retire(why, endTime)
    e.hi := na
    e.lo := na
    e.hiT := na
    e.loT := na
    e.hiI := na
    e.loI := na
    e.usedHi := false
    e.usedLo := false
    e.bull := Candidate.new()
    e.bear := Candidate.new()
    e.reason := why
    e.segmentStart := endTime

method checkInvalidation(Leg leg, Feed b, float ratio, bool touch) =>
    // Confirmation is known only at its source close. Earlier wicks cannot
    // invalidate a projection that did not yet exist.
    if na(leg.invalidatedAt) and b.t >= leg.confirmed
        float threshold = leg.a + ratio * (leg.b - leg.a)
        float observed = touch ? (leg.dir == 1 ? b.l : b.h) : b.c
        if leg.dir * (observed - threshold) <= 0
            leg.invalidatedAt := b.tc
            leg.invalidationPrice := threshold

method manageProjection(Engine e, Feed b) =>
    // Continue checking retained history after replacement/completion. Keep
    // its original retirement time and frozen anchors, but hide invalidated legs.
    for leg in e.legs
        leg.checkInvalidation(b, invalidationLevel == "0.5" ? 0.5 : 1.0, invalidationTrigger == "Touch")
        if leg.status == "ACTIVE"
            float terminal = leg.a - completeAt * (leg.b - leg.a)
            bool complete = leg.dir == 1 ? b.h >= terminal : b.l <= terminal
            if not na(leg.invalidatedAt)
                leg.status := complete ? "INVALIDATED / TERMINAL ALSO TOUCHED" : "INVALIDATED"
                leg.stopT := b.tc
            else if complete
                leg.status := "COMPLETED"
                leg.stopT := b.tc
            else if b.n - leg.confirmIndex > activeLife
                leg.status := "EXPIRED"
                leg.stopT := b.tc

method expireCandidate(Candidate c, Engine e, Feed b, Config cfg) =>
    if c.dir != 0 and b.n - c.startIndex > cfg.maxWait
        e.reason := c.dir == 1 ? "Bull candidate expired before MSS" : "Bear candidate expired before MSS"
        c.dir := 0
        c.phase := "EXPIRED"

// A and B are mutable here only. Never pass a frozen Leg as a Candidate.
method advance(Candidate c, Engine e, Feed b, Config cfg) =>
    bool confirmed = false
    if c.dir != 0
        bool timedOut = b.n - c.startIndex > cfg.maxWait
        if timedOut
            e.reason := c.dir == 1 ? "Bull candidate expired before MSS" : "Bear candidate expired before MSS"
            c.dir := 0
            c.phase := "EXPIRED"
        else
            bool newExtreme = c.dir == 1 ? b.l < c.b : b.h > c.b
            if newExtreme
                c.b := c.dir == 1 ? b.l : b.h
                c.bt := b.t
                c.bi := b.n
                c.closes := 0
                c.strong := false
                c.mss := c.a
                c.mssT := c.at
            float recentA = c.dir == 1 ? e.hi : e.lo
            int recentT = c.dir == 1 ? e.hiT : e.loT
            int recentI = c.dir == 1 ? e.hiI : e.loI
            // Last-move preference, including a pivot recognized after B formed.
            // The pivot's actual timestamp must remain strictly BEFORE B.
            bool newerOrigin = not na(recentI) and recentI > c.ai and recentI < c.bi
            bool correctSide = c.dir == 1 ? recentA > c.b : recentA < c.b
            // Select structure FIRST. A small final sub-leg must not silently
            // fall back to an older, wider leg merely to pass the size filter.
            if newerOrigin and correctSide and c.bi - recentI <= cfg.maxLeg
                c.a := recentA
                c.at := recentT
                c.ai := recentI
                c.mss := recentA
                c.mssT := recentT
                c.closes := 0
                c.strong := false
            if c.bi - c.ai > cfg.maxLeg
                e.reason := "Candidate rejected: origin too distant from extreme"
                c.dir := 0
                c.phase := "REJECTED"
            else
                if mssModel == "Latest internal swing" and not na(recentI) and recentI > c.bi and recentT > c.mssT
                    c.mss := recentA
                    c.mssT := recentT
                    c.closes := 0
                    c.strong := false
                float measured = math.abs(c.a - c.b)
                bool sizeOK = measured >= f_minRange(c.norm, cfg)
                bool sweepInLeg = c.dir * (c.a - c.sweep) > 0 and c.dir * (c.sweep - c.b) >= sweepTicks * syminfo.mintick
                c.phase := not sweepInLeg ? "SWEEP NO LONGER IN LEG" : sizeOK ? "MSS PENDING" : "DEVELOPING / TOO SMALL"
                bool reclaimed = c.dir == 1 ? b.c > c.sweep : b.c < c.sweep
                bool broken = c.dir == 1 ? b.c > c.mss + breakTicks * syminfo.mintick : b.c < c.mss - breakTicks * syminfo.mintick
                bool laterBar = b.t > c.bt
                float signedBody = c.dir * (b.c - b.o)
                float minBody = useATR ? c.norm * cfg.bodyAtr : syminfo.mintick
                bool displaced = signedBody >= minBody and math.abs(b.c - b.o) / math.max(b.h - b.l, syminfo.mintick) >= bodyFraction
                bool eligible = sizeOK and sweepInLeg and reclaimed and broken and laterBar
                c.closes := eligible ? c.closes + 1 : 0
                c.strong := eligible ? c.strong or displaced : false
                bool confirmationOK = cfg.twoCloses ? c.closes >= 2 and c.strong : confirmMode == "Close through only" ? true : displaced
                confirmed := eligible and confirmationOK
    confirmed

method confirmLeg(Engine e, Candidate c, Feed b) =>
    e.retire("REPLACED", b.tc)
    // Copy scalar coordinates. No Candidate/Leg alias, no later anchor rewriting.
    Leg frozen = Leg.new(c.a, c.b, c.at, c.bt, b.tc, na, b.n, c.dir, c.sweep, c.mss, "ACTIVE")
    frozen.sweptAt := c.sweepT
    frozen.sweepEvent := c.bt
    float terminal = c.a - completeAt * (c.b - c.a)
    if c.dir * (b.c - terminal) >= 0
        frozen.status := "COMPLETED AT CONFIRMATION"
        frozen.stopT := b.tc
    array.push(e.legs, frozen)
    if array.size(e.legs) > historyCap
        array.shift(e.legs)
    e.reason := c.dir == 1 ? "Bull M confirmed; anchors frozen" : "Bear M confirmed; anchors frozen"
    e.bull := Candidate.new()
    e.bear := Candidate.new()
    // This candle's earlier wick is not a post-confirmation target touch.

method consume(Engine e, Feed b, Config cfg, bool allowConfirmation = true) =>
    if not na(b)
        // A delayed old-context snapshot cannot resurrect a retired sequence.
        if (na(e.lastT) or b.t > e.lastT) and (na(e.ctx) or b.ctx >= e.ctx)
            bool contextChanged = not na(e.ctx) and b.ctx != e.ctx
            bool gap = not na(e.lastClose) and b.t > e.lastClose
            if contextChanged or gap
                e.resetSequence(contextChanged ? "CONTEXT ENDED" : "GAP RESET", b.t)
            if na(e.segmentStart)
                e.segmentStart := b.t
            e.ctx := b.ctx
            // Pivots only become known on this Feed's closed confirmation bar.
            if b.windowTime >= e.segmentStart and not na(b.ph) and (na(e.hiT) or b.pivotTime > e.hiT)
                e.hi := b.ph
                e.hiT := b.pivotTime
                e.hiI := b.pivotIndex
                e.usedHi := false
            if b.windowTime >= e.segmentStart and not na(b.pl) and (na(e.loT) or b.pivotTime > e.loT)
                e.lo := b.pl
                e.loT := b.pivotTime
                e.loI := b.pivotIndex
                e.usedLo := false
            e.manageProjection(b)
            // Retire stale candidates BEFORE a fresh sweep can consume its pool.
            e.bull.expireCandidate(e, b, cfg)
            e.bear.expireCandidate(e, b, cfg)
            bool downSweep = not na(e.lo) and not e.usedLo and b.l <= e.lo - sweepTicks * syminfo.mintick
            bool upSweep = not na(e.hi) and not e.usedHi and b.h >= e.hi + sweepTicks * syminfo.mintick
            if downSweep
                e.usedLo := true
            if upSweep
                e.usedHi := true
            if downSweep and upSweep
                e.reason := "Dual-sided sweep: new candidates rejected (unknown wick order)"
            else if not na(b.atr)
                if downSweep
                    bool originOK = not na(e.hiI) and e.hiI < b.n and b.n - e.hiI <= cfg.maxLeg and e.hi > e.lo
                    bool newerSequence = e.bull.dir == 0 or e.hiI > e.bull.ai
                    if originOK and newerSequence
                        e.bull := f_newCandidate(1, e.hi, e.hiT, e.hiI, b.l, b.t, b.n, e.lo, e.loT, b.atr)
                        e.reason := "Downside sweep; bullish candidate developing"
                    else if e.bull.dir != 0 and b.l <= e.bull.b
                        // This bar itself sweeps the new pool and reaches B.
                        // Never attach a later sweep to an earlier, deeper B.
                        e.bull.sweep := e.lo
                        e.bull.sweepT := e.loT
                        e.bull.b := b.l
                        e.bull.bt := b.t
                        e.bull.bi := b.n
                        e.bull.mss := e.bull.a
                        e.bull.mssT := e.bull.at
                        e.bull.closes := 0
                        e.bull.strong := false
                    else if not originOK
                        e.reason := "Down-sweep rejected: no recent confirmed origin high"
                if upSweep
                    bool originOK = not na(e.loI) and e.loI < b.n and b.n - e.loI <= cfg.maxLeg and e.lo < e.hi
                    bool newerSequence = e.bear.dir == 0 or e.loI > e.bear.ai
                    if originOK and newerSequence
                        e.bear := f_newCandidate(-1, e.lo, e.loT, e.loI, b.h, b.t, b.n, e.hi, e.hiT, b.atr)
                        e.reason := "Upside sweep; bearish candidate developing"
                    else if e.bear.dir != 0 and b.h >= e.bear.b
                        e.bear.sweep := e.hi
                        e.bear.sweepT := e.hiT
                        e.bear.b := b.h
                        e.bear.bt := b.t
                        e.bear.bi := b.n
                        e.bear.mss := e.bear.a
                        e.bear.mssT := e.bear.at
                        e.bear.closes := 0
                        e.bear.strong := false
                    else if not originOK
                        e.reason := "Up-sweep rejected: no recent confirmed origin low"
            bool bullishConfirmed = e.bull.advance(e, b, cfg)
            bool bearishConfirmed = e.bear.advance(e, b, cfg)
            if bullishConfirmed and bearishConfirmed
                e.reason := "Conflicting MSS: both candidates rejected"
                e.bull := Candidate.new()
                e.bear := Candidate.new()
            else if bullishConfirmed
                if allowConfirmation
                    e.confirmLeg(e.bull, b)
                else
                    e.bull.phase := "MSS FORMING / CLOSE REQUIRED"
            else if bearishConfirmed
                if allowConfirmation
                    e.confirmLeg(e.bear, b)
                else
                    e.bear.phase := "MSS FORMING / CLOSE REQUIRED"
            e.lastT := b.t
            e.lastClose := b.tc
            e.lastIndex := b.n
            e.lastAtr := b.atr
            e.lastPrice := b.c

// Disposable display state only. Nested Candidate references must be copied;
// frozen legs are deliberately excluded so preview lifecycle checks touch none.
f_preview(Engine e, Feed liveFeed, Config cfg) =>
    Engine preview = e.copy()
    preview.bull := e.bull.copy()
    preview.bear := e.bear.copy()
    preview.legs := array.new<Leg>()
    if not na(liveFeed)
        Feed forming = liveFeed.copy()
        // A pivot reported by an open confirmation candle is not confirmed yet.
        forming.ph := na
        forming.pl := na
        preview.consume(forming, cfg, false)
    preview

type SmtState
    int lastT = na
    int lastClose = na
    int ctx = na
    int segmentStart = na
    float hi = na
    float peerHi = na
    int hiT = na
    int hiI = na
    float lo = na
    float peerLo = na
    int loT = na
    int loI = na
    string reason = "Waiting for paired source bars"

f_smtState() =>
    SmtState.new()

f_smtAutoPeer(string chartRoot, string chartTicker, string exchangePrefix) =>
    string mapped = ""
    bool supported = chartRoot == "MNQ" or chartRoot == "NQ"
    if supported and str.startswith(chartTicker, chartRoot) and str.length(chartTicker) > str.length(chartRoot)
        string suffix = str.substring(chartTicker, str.length(chartRoot))
        mapped := exchangePrefix + ":" + (chartRoot == "MNQ" ? "MES" : "ES") + suffix
    mapped

f_smtZone(Leg leg, float price, float tick) =>
    float measured = math.abs(leg.a - leg.b)
    int zone = 0
    if measured > 0 and tick > 0
        float magnitude = (price - leg.a) / (leg.a - leg.b)
        float tolerance = 4.0 * tick / measured
        // The whole first band is eligible; reaching -2.25 is NOT required.
        if magnitude >= 2.0 - tolerance and magnitude <= 2.5 + tolerance
            zone := 1
        else if magnitude >= 3.5 - tolerance and magnitude <= 4.5 + tolerance
            zone := 2
    zone

method clearSmtPairs(SmtState s, int fromTime, string why) =>
    s.hi := na
    s.peerHi := na
    s.hiT := na
    s.hiI := na
    s.lo := na
    s.peerLo := na
    s.loT := na
    s.loI := na
    s.segmentStart := fromTime
    s.reason := why

f_smtOpposite(float mainChange, float peerChange, float mainTick, float peerTick) =>
    // Small tolerance only absorbs floating-point tick representation.
    float mainMinimum = mainTick * (1.0 - 1e-9)
    float peerMinimum = peerTick * (1.0 - 1e-9)
    mainTick > 0 and peerTick > 0 and ((mainChange >= mainMinimum and peerChange <= -peerMinimum) or (mainChange <= -mainMinimum and peerChange >= peerMinimum))

method recordSmt(Leg leg, Feed b, float price, float oldMain, float oldPeer, float newPeer, int oldPivot, bool highs) =>
    int zone = f_smtZone(leg, price, b.tick)
    bool unused = zone == 1 ? na(leg.smt2At) : zone == 2 ? na(leg.smt4At) : false
    if unused
        float magnitude = (price - leg.a) / (leg.a - leg.b)
        string side = highs ? "highs" : "lows"
        string detail = "Chart " + side + ": " + str.tostring(oldMain, "#.########") + " -> " + str.tostring(price, "#.########")
        detail += "\nPeer " + side + ": " + str.tostring(oldPeer, "#.########") + " -> " + str.tostring(newPeer, "#.########")
        detail += "\nPrevious paired pivot: " + str.format_time(oldPivot, "yyyy-MM-dd HH:mm:ss", contextTimezone)
        if zone == 1
            leg.smt2At := b.tc
            leg.smt2Pivot := b.pivotTime
            leg.smt2Price := price
            leg.smt2Magnitude := magnitude
            leg.smt2Evidence := detail
        else
            leg.smt4At := b.tc
            leg.smt4Pivot := b.pivotTime
            leg.smt4Price := price
            leg.smt4Magnitude := magnitude
            leg.smt4Evidence := detail
    unused

method consumeSMT(SmtState s, Engine e, Feed b, Feed peer, Config cfg) =>
    // lastT advances only after a successful pair. A delayed peer can retry the
    // same primary HTF snapshot; main Engine.consume() has its own watermark.
    if not na(b) and (na(s.lastT) or b.t > s.lastT)
        bool staleContext = not na(s.ctx) and b.ctx < s.ctx
        if not staleContext
            bool aligned = not na(peer)
            if aligned
                aligned := b.t == peer.t and b.tc == peer.tc and b.ctx == peer.ctx and b.tick > 0 and peer.tick > 0
            if not aligned
                s.reason := "Peer data unavailable / waiting for matching closed bar"
            else
                bool contextChanged = not na(s.ctx) and b.ctx != s.ctx
                bool gap = not na(s.lastClose) and b.t != s.lastClose
                if contextChanged or gap or na(s.segmentStart)
                    s.clearSmtPairs(b.t, contextChanged ? "Context reset" : gap ? "Paired data gap reset" : "Warming paired pivots")
                else
                    s.reason := "Aligned closed source bars"
                s.ctx := b.ctx
                bool windowOK = b.windowTime >= s.segmentStart and peer.windowTime >= s.segmentStart
                bool samePivot = windowOK and b.pivotTime == peer.pivotTime
                bool highPair = samePivot and not na(b.ph) and not na(peer.ph)
                bool lowPair = samePivot and not na(b.pl) and not na(peer.pl)
                Leg current = array.size(e.legs) > 0 ? array.get(e.legs, array.size(e.legs) - 1) : na
                bool legOK = false
                if not na(current)
                    bool statusOK = current.status == "ACTIVE" or current.status == "COMPLETED" or current.status == "COMPLETED AT CONFIRMATION"
                    legOK := statusOK and na(current.invalidatedAt) and e.ctx == b.ctx and current.at >= b.ctx and current.bt >= b.ctx and b.pivotTime >= current.confirmed
                if highPair and (na(s.hiT) or b.pivotTime > s.hiT)
                    if legOK and current.dir == 1 and not na(s.hiT) and s.hiT > current.bt and b.pivotIndex - s.hiI <= cfg.maxLeg
                        if f_smtOpposite(b.ph - s.hi, peer.ph - s.peerHi, b.tick, peer.tick)
                            bool recorded = current.recordSmt(b, b.ph, s.hi, s.peerHi, peer.ph, s.hiT, true)
                            if recorded
                                s.reason := "Bearish SMT at bullish leg's expansion zone"
                    s.hi := b.ph
                    s.peerHi := peer.ph
                    s.hiT := b.pivotTime
                    s.hiI := b.pivotIndex
                else if windowOK and (not na(b.ph) or not na(peer.ph)) and not highPair
                    // Do not bridge an intervening unpaired swing with stale structure.
                    s.hi := na
                    s.peerHi := na
                    s.hiT := na
                    s.hiI := na
                    s.reason := "Unmatched high pivot skipped"
                if lowPair and (na(s.loT) or b.pivotTime > s.loT)
                    if legOK and current.dir == -1 and not na(s.loT) and s.loT > current.bt and b.pivotIndex - s.loI <= cfg.maxLeg
                        if f_smtOpposite(b.pl - s.lo, peer.pl - s.peerLo, b.tick, peer.tick)
                            bool recorded = current.recordSmt(b, b.pl, s.lo, s.peerLo, peer.pl, s.loT, false)
                            if recorded
                                s.reason := "Bullish SMT at bearish leg's expansion zone"
                    s.lo := b.pl
                    s.peerLo := peer.pl
                    s.loT := b.pivotTime
                    s.loI := b.pivotIndex
                else if windowOK and (not na(b.pl) or not na(peer.pl)) and not lowPair
                    s.lo := na
                    s.peerLo := na
                    s.loT := na
                    s.loI := na
                    s.reason := "Unmatched low pivot skipped"
                s.lastT := b.t
                s.lastClose := b.tc
    0

f_step(Engine e, SmtState s, Feed b, Feed peer, Config cfg, bool smtEnabled) =>
    e.consume(b, cfg)
    if smtEnabled
        s.consumeSMT(e, b, peer, cfg)
    0

f_smtPacket(Engine e, SmtState s, array<Feed> mainBars, array<Feed> peerBars, Config cfg, bool smtEnabled) =>
    int peerIndex = 0
    int peerCount = na(peerBars) ? 0 : array.size(peerBars)
    for nativeBar in mainBars
        if not barstate.isrealtime or nativeBar.tc <= timenow
            Feed matchingPeer = na
            while peerIndex < peerCount
                Feed candidatePeer = array.get(peerBars, peerIndex)
                if na(candidatePeer) or candidatePeer.t < nativeBar.t
                    peerIndex += 1
                else
                    if candidatePeer.t == nativeBar.t and candidatePeer.tc == nativeBar.tc
                        matchingPeer := candidatePeer
                    break
            f_step(e, s, nativeBar, matchingPeer, cfg, smtEnabled)
    0

var Config cfg15 = f_config(preset15, left15, right15, size15, body15, span15, wait15)
var Config cfg5 = f_config(preset5, left5, right5, size5, body5, span5, wait5)
var Config cfg1 = f_config(preset1, left1, right1, size1, body1, span1, wait1)
var Engine e15 = f_engine()
var Engine e5 = f_engine()
var Engine e1 = f_engine()

var SmtState smt15 = f_smtState()
var SmtState smt5 = f_smtState()
var SmtState smt1 = f_smtState()
string smtPeerStandard = smtPeerMode == "Auto NQ/MNQ" ? f_smtAutoPeer(syminfo.root, syminfo.ticker, syminfo.prefix) : smtManualPeer
bool smtCanRequest = showSMT and str.length(smtPeerStandard) > 0 and smtPeerStandard != ticker.standard(syminfo.tickerid)
string smtPeerTicker = smtCanRequest ? ticker.inherit(syminfo.tickerid, smtPeerStandard) : syminfo.tickerid
if showSMT and not smtCanRequest
    for smtState in array.from(smt15, smt5, smt1)
        smtState.reason := "Select a different manual comparison symbol for this chart"

int chartSeconds = timeframe.in_seconds()
if barstate.isfirst and (not chart.is_standard or not (chartSeconds == 60 or chartSeconds == 300 or chartSeconds == 900))
    runtime.error("Use standard time-based 1-minute, 5-minute or 15-minute candles. Other chart periods and synthetic candles are not supported by this version.")

// Only the chart-native feed can supply an open-candle preview. The ordinary
// chronological routes below still commit exclusively closed native candles.
Feed formingChart = na

// Primary detection is unchanged. Optional peer snapshots use their own native
// pivots/tick size. Exact timestamps reject stale repeated HTF prices.
// Request expressions run on every bar of the selected native route. When SMT
// is disabled, smtPeerTicker falls back to the chart symbol; f_step skips SMT.
if chartSeconds < 900
    Feed feed15 = request.security(syminfo.tickerid, "15", f_closedFeed(cfg15.leftBars, cfg15.rightBars), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, calc_bars_count = 100000)
    Feed peer15 = request.security(smtPeerTicker, "15", f_closedFeed(cfg15.leftBars, cfg15.rightBars), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true, calc_bars_count = 100000)
    f_step(e15, smt15, feed15, peer15, cfg15, smtCanRequest)
else
    Feed feed15 = f_feed(cfg15.leftBars, cfg15.rightBars)
    formingChart := feed15
    Feed peer15 = request.security(smtPeerTicker, "15", f_feed(cfg15.leftBars, cfg15.rightBars), gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true, calc_bars_count = 100000)
    if barstate.isconfirmed
        f_step(e15, smt15, feed15, peer15, cfg15, smtCanRequest)

if chartSeconds < 300
    Feed feed5 = request.security(syminfo.tickerid, "5", f_closedFeed(cfg5.leftBars, cfg5.rightBars), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, calc_bars_count = 100000)
    Feed peer5 = request.security(smtPeerTicker, "5", f_closedFeed(cfg5.leftBars, cfg5.rightBars), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true, calc_bars_count = 100000)
    f_step(e5, smt5, feed5, peer5, cfg5, smtCanRequest)
else if chartSeconds == 300
    Feed feed5 = f_feed(cfg5.leftBars, cfg5.rightBars)
    formingChart := feed5
    Feed peer5 = request.security(smtPeerTicker, "5", f_feed(cfg5.leftBars, cfg5.rightBars), gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true, calc_bars_count = 100000)
    if barstate.isconfirmed
        f_step(e5, smt5, feed5, peer5, cfg5, smtCanRequest)
else
    array<Feed> feeds5 = request.security_lower_tf(syminfo.tickerid, "5", f_feed(cfg5.leftBars, cfg5.rightBars), calc_bars_count = 100000)
    array<Feed> peers5 = request.security_lower_tf(smtPeerTicker, "5", f_feed(cfg5.leftBars, cfg5.rightBars), ignore_invalid_symbol = true, calc_bars_count = 100000)
    f_smtPacket(e5, smt5, feeds5, peers5, cfg5, smtCanRequest)

if chartSeconds == 60
    Feed feed1 = f_feed(cfg1.leftBars, cfg1.rightBars)
    formingChart := feed1
    Feed peer1 = request.security(smtPeerTicker, "1", f_feed(cfg1.leftBars, cfg1.rightBars), gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true, calc_bars_count = 100000)
    if barstate.isconfirmed
        f_step(e1, smt1, feed1, peer1, cfg1, smtCanRequest)
else
    array<Feed> feeds1 = request.security_lower_tf(syminfo.tickerid, "1", f_feed(cfg1.leftBars, cfg1.rightBars), calc_bars_count = 100000)
    array<Feed> peers1 = request.security_lower_tf(smtPeerTicker, "1", f_feed(cfg1.leftBars, cfg1.rightBars), ignore_invalid_symbol = true, calc_bars_count = 100000)
    f_smtPacket(e1, smt1, feeds1, peers1, cfg1, smtCanRequest)

// Opening boundaries are known at chart-bar OPEN; retire old contexts without
// waiting for an unclosed 15m candle. No unconfirmed price is consumed here.
int chartContext = f_context()
for engineState in array.from(e15, e5, e1)
    if not na(engineState.ctx) and chartContext > engineState.ctx
        engineState.resetSequence("CONTEXT ENDED", chartContext)
        engineState.ctx := chartContext

for smtState in array.from(smt15, smt5, smt1)
    if not na(smtState.ctx) and chartContext > smtState.ctx
        smtState.clearSmtPairs(chartContext, "Context ended")
        smtState.ctx := chartContext

// Rendering only. Integrate after the engine types, inputs and ratio arrays.
// Engine.legs is ordered oldest to newest. Drawing storage is bounded and
// rebuilt only on the last chart bar; confirmed coordinates are never edited.
var array<line> drawingLines = array.new<line>()
var array<label> drawingLabels = array.new<label>()
var array<box> drawingBoxes = array.new<box>()
var table renderDebugTable = table.new(position.top_right, 4, 3, border_width = 1)

f_clearDrawings() =>
    while array.size(drawingLines) > 0
        line.delete(array.pop(drawingLines))
    while array.size(drawingLabels) > 0
        label.delete(array.pop(drawingLabels))
    while array.size(drawingBoxes) > 0
        box.delete(array.pop(drawingBoxes))
    0

f_r_price(float a, float b, float ratio) =>
    a + ratio * (b - a)

f_r_enabled(int index) =>
    index >= 0 and index < array.size(enabled) ? array.get(enabled, index) : false

f_r_time(int stamp) =>
    na(stamp) ? "n/a" : str.format_time(stamp, "yyyy-MM-dd HH:mm:ss", syminfo.timezone)

f_r_ratioText(float ratio) =>
    ratio == 1.0 ? "1 leg" : ratio < 0 and not signedLabels ? "E" + str.tostring(math.abs(ratio), "0.##") : str.tostring(ratio, "0.##")

f_r_right(Engine e) =>
    int chartClose = na(time_close) ? time : time_close
    math.max(chartClose, nz(e.lastClose, chartClose)) + projectionMinutes * 60000

f_r_line(int x1, float y1, int x2, float y2, color col, int width, string lineStyle) =>
    line object = line.new(x1, y1, x2, y2, xloc = xloc.bar_time, extend = extend.none, color = col, style = lineStyle, width = width, force_overlay = true)
    array.push(drawingLines, object)
    0

f_r_label(int x, float y, string labelText, color fill, color ink, string labelStyle, string tip) =>
    label object = label.new(x, y, labelText, xloc = xloc.bar_time, yloc = yloc.price, color = fill, style = labelStyle, textcolor = ink, size = size.tiny, tooltip = tip, force_overlay = true)
    array.push(drawingLabels, object)
    0

f_r_band(int left, int right, float p1, float p2, color col, int opacity) =>
    box object = box.new(left, math.max(p1, p2), right, math.min(p1, p2), xloc = xloc.bar_time, border_width = 0, bgcolor = color.new(col, opacity), force_overlay = true)
    array.push(drawingBoxes, object)
    0

f_r_legTip(Leg leg, string tag) =>
    string tip = tag + " manipulation; " + (leg.dir == 1 ? "bullish expansion" : "bearish expansion")
    tip += "\nA / fib 0: " + str.tostring(leg.a, format.mintick) + " @ " + f_r_time(leg.at)
    tip += "\nB / fib 1: " + str.tostring(leg.b, format.mintick) + " @ " + f_r_time(leg.bt)
    tip += "\nConfirmed at source close: " + f_r_time(leg.confirmed)
    tip += "\nSwept price: " + str.tostring(leg.sweep, format.mintick) + "; MSS: " + str.tostring(leg.mss, format.mintick)
    tip += "\nSwept pivot: " + f_r_time(leg.sweptAt) + "; manipulation extreme: " + f_r_time(leg.sweepEvent)
    tip += "\nStatus: " + leg.status
    if not na(leg.invalidatedAt)
        tip += "\nINVALIDATED at source close: " + f_r_time(leg.invalidatedAt)
        tip += "\nInvalidation level " + invalidationLevel + " = " + str.tostring(leg.invalidationPrice, format.mintick) + " (" + invalidationTrigger + ")"
    if not na(leg.stopT)
        tip += "\nEnded at source close: " + f_r_time(leg.stopT)
    tip += "\nTimes: " + syminfo.timezone + ". A/B use source candle OPEN times."
    tip += "\nProjection lines begin at confirmation, after A and B were known."
    tip

f_r_candidate(Candidate candidate, Engine e, string tag, color col, int transp, bool live = false) =>
    bool valid = candidate.dir != 0 and not na(candidate.a) and not na(candidate.b) and not na(candidate.at) and not na(candidate.bt)
    if valid
        color pendingColor = color.new(col, math.max(transp, 25))
        int asOf = live ? math.max(time, math.min(timenow, time_close)) : nz(e.lastClose, candidate.bt)
        string tip = tag + " DEVELOPING: " + candidate.phase + ". Anchor bubbles may move or disappear; levels appear after confirmation."
        tip += "\nA / fib 0: " + str.tostring(candidate.a, format.mintick) + " @ " + f_r_time(candidate.at)
        tip += "\nB / fib 1: " + str.tostring(candidate.b, format.mintick) + " @ " + f_r_time(candidate.bt)
        tip += (live ? "\nLive preview as of: " : "\nAs of source close: ") + f_r_time(asOf) + " (" + syminfo.timezone + ")"
        if live
            tip += "\nSource candle is still open. No confirmation, SMT or invalidation is committed from this preview."
        tip += "\nSwept: " + str.tostring(candidate.sweep, format.mintick) + "; MSS: " + str.tostring(candidate.mss, format.mintick)
        if showLeg
            f_r_label(candidate.at, candidate.a, "", pendingColor, pendingColor, label.style_circle, tip)
            f_r_label(candidate.bt, candidate.b, "", pendingColor, pendingColor, label.style_circle, tip)
    0

f_r_smt(Leg leg, string tag, color col) =>
    if showSMT and na(leg.invalidatedAt)
        string direction = leg.dir == 1 ? "Bearish" : "Bullish"
        string style = leg.dir == 1 ? label.style_label_down : label.style_label_up
        if not na(leg.smt2At)
            string tip = tag + " " + direction + " SMT near primary zone; comparison " + smtPeerStandard
            tip += "\nObserved at source close: " + f_r_time(leg.smt2At)
            tip += "\nPaired pivot: " + f_r_time(leg.smt2Pivot) + "; expansion magnitude " + str.tostring(leg.smt2Magnitude, "0.###")
            tip += "\n" + leg.smt2Evidence + "\nReference-pivot time above uses " + contextTimezone + "."
            tip += "\nStrict same-bar confirmed pivots; marker is placed when known. No reversal is guaranteed."
            f_r_label(leg.smt2At, leg.smt2Price, tag + " SMT", color.new(col, 90), col, style, tip)
        if not na(leg.smt4At)
            string tip = tag + " " + direction + " SMT near extended zone; comparison " + smtPeerStandard
            tip += "\nObserved at source close: " + f_r_time(leg.smt4At)
            tip += "\nPaired pivot: " + f_r_time(leg.smt4Pivot) + "; expansion magnitude " + str.tostring(leg.smt4Magnitude, "0.###")
            tip += "\n" + leg.smt4Evidence + "\nReference-pivot time above uses " + contextTimezone + "."
            tip += "\nStrict same-bar confirmed pivots; marker is placed when known. No reversal is guaranteed."
            f_r_label(leg.smt4At, leg.smt4Price, tag + " SMT", color.new(col, 90), col, style, tip)
    0

f_render(Engine e, string tag, color col, int width, int transp, Engine developingEngine, bool livePreview) =>
    int count = array.size(e.legs)
    int requested = historyMode == "Current leg only" ? 1 : historyMode == "Last 2 legs" ? 2 : historyMode == "Last 3 legs" ? 3 : historyCap
    // 24 retained drawings * 19 labels + 6 pending pairs * 2 bubbles +
    // 6 clusters = 474 labels, below Pine's 500-label ceiling.
    int keep = showPrevious ? math.min(requested, historyCap) : 1
    if count > 0
        int first = math.max(0, count - keep)
        for index = first to count - 1
            Leg leg = array.get(e.legs, index)
            if showInvalidated or na(leg.invalidatedAt)
                bool faded = index < count - 1 or leg.status != "ACTIVE"
                int alpha = faded ? math.max(transp, 83) : transp
                color lineColor = color.new(col, alpha)
                int right = na(leg.stopT) ? f_r_right(e) : math.max(leg.confirmed, leg.stopT)
                string tip = f_r_legTip(leg, tag)
                f_r_smt(leg, tag, lineColor)
                if showContinuation
                    f_r_band(leg.confirmed, right, f_r_price(leg.a, leg.b, -1.0), f_r_price(leg.a, leg.b, -1.5), col, faded ? 97 : math.max(91, transp))
                if showPrimary
                    f_r_band(leg.confirmed, right, f_r_price(leg.a, leg.b, -2.0), f_r_price(leg.a, leg.b, -2.5), col, faded ? 96 : math.max(86, transp))
                if showMax
                    f_r_band(leg.confirmed, right, f_r_price(leg.a, leg.b, -3.5), f_r_price(leg.a, leg.b, -4.5), col, faded ? 98 : math.max(93, transp))
                if showLeg
                    f_r_line(leg.at, leg.a, leg.bt, leg.b, lineColor, width, line.style_solid)
                    f_r_label(leg.at, leg.a, "", lineColor, lineColor, label.style_circle, tip)
                    f_r_label(leg.bt, leg.b, "", lineColor, lineColor, label.style_circle, tip)
                    if showLabels
                        int midTime = leg.at + int((leg.bt - leg.at) / 2)
                        f_r_label(midTime, (leg.a + leg.b) / 2.0, tag + " M", color.new(col, 100), lineColor, label.style_label_center, tip)
                // The confirmation dot survives the text-label and anchor-line toggles.
                // It records when the retrospectively located A/B became actionable data.
                f_r_label(leg.confirmed, leg.mss, "", lineColor, lineColor, label.style_diamond, tip)
                int levelCount = array.size(ratios)
                if levelCount > 0
                    for levelIndex = 0 to levelCount - 1
                        if f_r_enabled(levelIndex)
                            float ratio = array.get(ratios, levelIndex)
                            float price = f_r_price(leg.a, leg.b, ratio)
                            string levelStyle = ratio >= 0 ? line.style_dotted : line.style_solid
                            f_r_line(leg.confirmed, price, right, price, lineColor, ratio >= 0 ? 1 : width, levelStyle)
                            if showLabels
                                string levelTip = tag + " literal fib " + str.tostring(ratio, "0.##") + " = " + str.tostring(price, format.mintick)
                                levelTip += "\nP(r) = A + r * (B - A)\n" + tip
                                f_r_label(right, price, tag + " " + f_r_ratioText(ratio), color.new(col, 100), lineColor, label.style_label_left, levelTip)
    if showDeveloping
        f_r_candidate(developingEngine.bull, developingEngine, tag, col, transp, livePreview)
        f_r_candidate(developingEngine.bear, developingEngine, tag, col, transp, livePreview)
    0

f_r_collect(Engine e, string tag, int tfId, array<float> prices, array<int> frames, array<string> descriptions) =>
    int count = array.size(e.legs)
    if count > 0
        Leg leg = array.get(e.legs, count - 1)
        if leg.status == "ACTIVE" and na(leg.invalidatedAt)
            int levelCount = array.size(ratios)
            if levelCount > 0
                for index = 0 to levelCount - 1
                    float ratio = array.get(ratios, index)
                    if ratio < 0 and f_r_enabled(index)
                        float price = f_r_price(leg.a, leg.b, ratio)
                        array.push(prices, price)
                        array.push(frames, tfId)
                        array.push(descriptions, tag + " " + f_r_ratioText(ratio) + ": " + str.tostring(price, format.mintick))
    0

f_clusters(Engine engine15, Engine engine5, Engine engine1, bool visible15, bool visible5, bool visible1) =>
    if showClusters
        array<float> prices = array.new<float>()
        array<int> frames = array.new<int>()
        array<string> descriptions = array.new<string>()
        if visible15
            f_r_collect(engine15, "15m", 15, prices, frames, descriptions)
        if visible5
            f_r_collect(engine5, "5m", 5, prices, frames, descriptions)
        if visible1
            f_r_collect(engine1, "1m", 1, prices, frames, descriptions)
        int count = array.size(prices)
        if count > 1
            array<int> sorted = array.sort_indices(prices, order.ascending)
            float tolerance = clusterTicks * syminfo.mintick
            int cursor = 0
            int groups = 0
            int right = math.max(f_r_right(engine15), math.max(f_r_right(engine5), f_r_right(engine1)))
            while cursor < count and groups < 6
                int baseIndex = array.get(sorted, cursor)
                float lowPrice = array.get(prices, baseIndex)
                int firstFrame = array.get(frames, baseIndex)
                int endCursor = cursor + 1
                float sum = lowPrice
                bool multipleFrames = false
                string detail = array.get(descriptions, baseIndex)
                // Compare each member with the lowest price: max-min <= tolerance.
                // This avoids transitive chains spanning more than the input limit.
                while endCursor < count
                    int nextIndex = array.get(sorted, endCursor)
                    float nextPrice = array.get(prices, nextIndex)
                    if nextPrice - lowPrice > tolerance
                        break
                    sum += nextPrice
                    multipleFrames := multipleFrames or array.get(frames, nextIndex) != firstFrame
                    detail += "\n" + array.get(descriptions, nextIndex)
                    endCursor += 1
                if multipleFrames
                    float center = sum / (endCursor - cursor)
                    string tip = "Current active projections from different timeframes."
                    tip += "\nFull price span <= " + str.tostring(clusterTicks) + " ticks.\n" + detail
                    f_r_label(right, center, "STDV CLUSTER", color.new(color.yellow, 18), color.black, label.style_label_left, tip)
                    groups += 1
                    cursor := endCursor
                else
                    cursor += 1
    0

f_r_debugStructure(Candidate candidate, Engine e, color col) =>
    if candidate.dir != 0 and not na(candidate.mss)
        int left = na(candidate.mssT) ? candidate.bt : candidate.mssT
        int right = nz(e.lastClose, left)
        if not na(left) and not na(right)
            f_r_line(left, candidate.mss, right, candidate.mss, color.new(col, 35), 1, line.style_dotted)
    0

f_r_debugRow(Engine e, SmtState smtState, string tag, int row, color col, bool shown) =>
    string phases = "Bull: " + e.bull.phase + "\nBear: " + e.bear.phase
    string levels = "MSS B: " + (e.bull.dir == 0 ? "-" : str.tostring(e.bull.mss, format.mintick))
    levels += "\nMSS S: " + (e.bear.dir == 0 ? "-" : str.tostring(e.bear.mss, format.mintick))
    color bg = color.new(color.black, 15)
    table.cell(renderDebugTable, 0, row, tag + (shown ? "" : " hidden"), text_color = col, bgcolor = bg, text_size = size.tiny)
    table.cell(renderDebugTable, 1, row, phases, text_color = color.white, bgcolor = bg, text_size = size.tiny)
    table.cell(renderDebugTable, 2, row, levels, text_color = color.white, bgcolor = bg, text_size = size.tiny)
    table.cell(renderDebugTable, 3, row, e.reason + (showSMT ? "\nSMT: " + smtState.reason : ""), text_color = color.silver, bgcolor = bg, text_size = size.tiny)
    if shown
        f_r_debugStructure(e.bull, e, col)
        f_r_debugStructure(e.bear, e, col)
    0

f_debug(Engine engine15, Engine engine5, Engine engine1) =>
    if debugMode
        f_r_debugRow(engine15, smt15, "15m", 0, c15, show15)
        f_r_debugRow(engine5, smt5, "5m", 1, c5, show5)
        f_r_debugRow(engine1, smt1, "1m", 2, c1, show1)
    else
        table.clear(renderDebugTable, 0, 0, 3, 2)
    0

if barstate.islast
    f_clearDrawings()
    bool previewOpenBar = showDeveloping and liveDeveloping and barstate.isrealtime and not barstate.isconfirmed and not na(formingChart)
    bool live15 = previewOpenBar and chartSeconds == 900
    bool live5 = previewOpenBar and chartSeconds == 300
    bool live1 = previewOpenBar and chartSeconds == 60
    Engine developing15 = live15 ? f_preview(e15, formingChart, cfg15) : e15
    Engine developing5 = live5 ? f_preview(e5, formingChart, cfg5) : e5
    Engine developing1 = live1 ? f_preview(e1, formingChart, cfg1) : e1
    if show15
        f_render(e15, "15m", c15, w15, tr15, developing15, live15)
    if show5
        f_render(e5, "5m", c5, w5, tr5, developing5, live5)
    if show1
        f_render(e1, "1m", c1, w1, tr1, developing1, live1)
    f_clusters(e15, e5, e1, show15, show5, show1)
    f_debug(e15, e5, e1)

// Optional audit module. Append after all feed processing and context fences.
// These values belong to the latest confirmed leg, including a retired leg.
// They are Data Window/export fields only and never draw on the price chart.
bool auditOutputs = input.bool(false, "Expose audit values in Data Window / CSV", group = GVIEW, display = display.none)

f_a_latest(Engine e) =>
    Leg latest = na
    if array.size(e.legs) > 0
        latest := array.get(e.legs, array.size(e.legs) - 1)
    latest

f_a_status(string status) =>
    switch status
        "ACTIVE" => 1
        "COMPLETED" => 2
        "COMPLETED AT CONFIRMATION" => 3
        "INVALIDATED" => 4
        "INVALIDATED / TERMINAL ALSO TOUCHED" => 5
        "REPLACED" => 6
        "CONTEXT ENDED" => 7
        "GAP RESET" => 8
        "EXPIRED" => 9
        => 99

Leg audit15 = f_a_latest(e15)
Leg audit5 = f_a_latest(e5)
Leg audit1 = f_a_latest(e1)

plot(auditOutputs and not na(audit15) ? audit15.a : na, "Audit 15m A", display = display.data_window)
plot(auditOutputs and not na(audit15) ? audit15.b : na, "Audit 15m B", display = display.data_window)
plot(auditOutputs and not na(audit15) ? audit15.at : na, "Audit 15m A time ms", display = display.data_window)
plot(auditOutputs and not na(audit15) ? audit15.bt : na, "Audit 15m B time ms", display = display.data_window)
plot(auditOutputs and not na(audit15) ? audit15.confirmed : na, "Audit 15m confirmation ms", display = display.data_window)
plot(auditOutputs ? e15.lastClose : na, "Audit 15m source close ms", display = display.data_window)
plot(auditOutputs ? e15.ctx : na, "Audit 15m context ms", display = display.data_window)
plot(auditOutputs ? (na(audit15) ? 0 : not na(audit15.invalidatedAt) ? 4 : f_a_status(audit15.status)) : na, "Audit 15m status", display = display.data_window)

plot(auditOutputs and not na(audit5) ? audit5.a : na, "Audit 5m A", display = display.data_window)
plot(auditOutputs and not na(audit5) ? audit5.b : na, "Audit 5m B", display = display.data_window)
plot(auditOutputs and not na(audit5) ? audit5.at : na, "Audit 5m A time ms", display = display.data_window)
plot(auditOutputs and not na(audit5) ? audit5.bt : na, "Audit 5m B time ms", display = display.data_window)
plot(auditOutputs and not na(audit5) ? audit5.confirmed : na, "Audit 5m confirmation ms", display = display.data_window)
plot(auditOutputs ? e5.lastClose : na, "Audit 5m source close ms", display = display.data_window)
plot(auditOutputs ? e5.ctx : na, "Audit 5m context ms", display = display.data_window)
plot(auditOutputs ? (na(audit5) ? 0 : not na(audit5.invalidatedAt) ? 4 : f_a_status(audit5.status)) : na, "Audit 5m status", display = display.data_window)

plot(auditOutputs and not na(audit1) ? audit1.a : na, "Audit 1m A", display = display.data_window)
plot(auditOutputs and not na(audit1) ? audit1.b : na, "Audit 1m B", display = display.data_window)
plot(auditOutputs and not na(audit1) ? audit1.at : na, "Audit 1m A time ms", display = display.data_window)
plot(auditOutputs and not na(audit1) ? audit1.bt : na, "Audit 1m B time ms", display = display.data_window)
plot(auditOutputs and not na(audit1) ? audit1.confirmed : na, "Audit 1m confirmation ms", display = display.data_window)
plot(auditOutputs ? e1.lastClose : na, "Audit 1m source close ms", display = display.data_window)
plot(auditOutputs ? e1.ctx : na, "Audit 1m context ms", display = display.data_window)
plot(auditOutputs ? (na(audit1) ? 0 : not na(audit1.invalidatedAt) ? 4 : f_a_status(audit1.status)) : na, "Audit 1m status", display = display.data_window)
````
