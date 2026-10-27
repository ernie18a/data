# AlgoStorm Institutional Key Levels (IKL)

- url: https://www.tradingview.com/script/lX8Efl8C-AlgoStorm-Institutional-Key-Levels-IKL/
- type: indicator
- pine_id: PUB;57bda19a676a4570bd9124ed72cdc3f9
- version: 4.0

## Description

[b]AlgoStorm Institutional Key Levels (IKL)[/b]

[quote]For US Index Futures and DAX.[/quote]

[i]An institutional-grade structural mapping tool built on actual Auction Market Theory (AMT) to track the true liquidity and volume nodes across centralized futures markets.[/i]

The retail trading industry has heavily distorted the word "institutional," convincing traders that algorithms are hunting their stop-losses at random pivot highs. The reality is far more objective. Real institutions, hedge funds, and market makers rely on definitive, centralized exchange volume, liquidity depth, and execution algorithms (VWAP/TWAP) to scale into positions without causing market impact. 

The AlgoStorm Institutional Key Levels (IKL) indicator maps the precise mathematical benchmarks that dictate this capital flow. Designed for markets with centralized volume (CME, Eurex), it plots highly accurate session opens, Opening Ranges, Initial Balances, and Value Areas, stripping away retail noise to provide a professional framework for your intraday bias.

[b]Technical Specifications & Architecture[/b]
[list]
[*] [b]Supported Markets:[/b] Universal application for centralized futures markets including US Indices (ES, NQ, YM, RTY) and European Indices (DAX/FDAX, FDXM). 
[*] [b]Supported Timeframes:[/b] Designed specifically for [b]2-minute through 30-minute charts[/b]. (Note: Due to the historical buffers required for multi-session mapping, Pine Script will reject timeframes below 2-minutes).
[*] [b]Timezone Mastery:[/b] Flawlessly handles Daylight Saving Time (DST) transitions natively. US Futures are bound strictly to [i]America/New_York[/i], while DAX/Eurex Futures are strictly bound to [i]Europe/Berlin[/i].
[*] [b]Fixed-Pool Drawing Engine:[/b] Most level indicators suffer from memory bloat and chart lag due to constant object creation and garbage collection limits. The IKL utilizes a highly optimized "fixed-pool" architecture. Lines and labels are generated only once on the first bar and recycled dynamically.
[*] [b]Smart Label Stagger:[/b] Features a forward-pass algorithm that detects and pushes overlapping labels apart (user-adjustable separation), ensuring your chart remains pristine regardless of price compression.
[/list]

[b]US Futures Mapping (ES / NQ / YM / RTY)[/b]
[i]All inputs trigger based on standard America/New_York session times.[/i]
[list]
[*] [b]Globex Structure:[/b] Previous Day High/Low (Full 18:00–17:00 session) and Overnight High/Low (18:00 to 09:30 ET).
[*] [b]RTH Anchors:[/b] Previous Day Close (PDC) locked exactly at the 16:00 ET cash close, and the RTH Open (09:30 ET) held all day.
[*] [b]Gap Fill Zone:[/b] Automatically draws an asynchronous highlight box between the PDC and current RTH open if an unfilled gap of more than 2 ticks exists.
[*] [b]Auction Metrics:[/b] 15-minute Opening Range (09:30–09:45 ET) and the standard Initial Balance (09:30–10:30 ET) with optional 100%, 150%, and 200% IB extension bands.
[/list]

[b]Eurex / DAX Futures Mapping (FDAX / FDXM)[/b]
[i]A complete, standalone module built for the complex, multi-open nature of European futures. Based on Europe/Berlin time.[/i]
[list]
[*] [b]Asian / Pre-London Phase:[/b] Tracks Eurex overnight high/low from 01:00 CET until Frankfurt liquidity arrives at 08:00 CET.
[*] [b]Euro / Frankfurt Session:[/b] Plots the 08:00 CET Open and the 30-minute Euro Opening Range (08:00–08:30 CET).
[*] [b]Xetra Cash Session:[/b] Plots the definitive Xetra Open (09:00 CET), Xetra OPR (09:00–09:30 CET), and the Previous Xetra Close (17:30 CET) which acts as the DAX equivalent to the US PDC.
[*] [b]US Open Impact:[/b] Captures the 15:30 CET open and 30-minute OPR, marking the massive liquidity injection when US equity markets open.
[/list]

[b]Execution & Volume Mechanics[/b]
[list]
[*] [b]Algorithmic VWAPs:[/b] Plots the exact Daily and Session VWAP bands used by institutional execution desks to grade their fills. Features a full Globex Daily VWAP (resets 18:00 ET), a localized NY VWAP (resets 09:30 ET), and a dedicated Xetra VWAP (resets 09:00 CET).
[*] [b]Custom Value Area Engine:[/b] Features a built-in, manual array-based Volume Profile engine. It calculates the Point of Control (POC) and Value Area High/Low (VAH/VAL) for both RTH and Xetra sessions independently, bypassing standard Pine Script volume limitations. Users can customize the Value Area % and price-row tick size.
[/list]

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © AlgoStorm

//@version=6
indicator(title="AlgoStorm Institutional Key Levels (IKL)", shorttitle="IKL • [AlgoStorm]", overlay=true, max_lines_count=50, max_labels_count=50, max_boxes_count=5)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  NOTES
//  • Designed for US Index Futures and FDAX/DAX futures.
//  • All DAX inputs are off by default — enable only the group that matches your instrument.
//
//  ── ES / US FUTURES ───────────────────────────────────────────────────────
//  • PDH/PDL         : full globex session high/low via "1D".
//  • PDC             : RTH close at 16:00 ET — close[1] at rthEnd.
//  • RTH Open        : open of first RTH bar at 09:30 ET, held all day.
//  • 15-min OPR H/L  : high/low of 09:30–09:45 ET, locked at 09:45 ET.
//  • Initial Balance : high/low of 09:30–10:30 ET, locked at 10:30 ET.
//  • IB Extensions   : 100/150/200% of IB range above IBH and below IBL.
//  • Gap Fill Zone   : box between PDC and RTH Open. Skipped when gap < 2 ticks.
//  • RTH Value Area  : manual VP bucketed by hlc3 during RTH. Cleared each rthEnd.
//                      VAH = top edge hi bucket | VAL = bot edge lo bucket
//                      POC = centre of max-volume bucket
//  • Daily VWAP      : resets at globex open (18:00 ET).
//                      High/Low = envelope | Mid (hlc3) = optional centre line.
//  • NY VWAP         : single hlc3 line. Resets at 09:30 ET. na outside RTH.
//
//  ── DAX / FDAX FUTURES (Europe/Berlin, DST-aware) ────────────────────────
//  • Asian / Pre-London H/L : Eurex open (01:00 CET) → Euro open (08:00 CET).
//                             Locked when Frankfurt liquidity arrives at 08:00.
//  • Euro / Frankfurt Open  : open of first bar at 08:00 CET, held all day.
//  • Euro OPR H/L           : high/low 08:00–08:30 CET, locked at 08:30 CET.
//  • Xetra Open             : open of first Xetra bar at 09:00 CET, held all day.
//  • Xetra OPR H/L          : high/low 09:00–09:30 CET, locked at 09:30 CET.
//  • Prev Xetra Close       : Xetra close at 17:30 CET — analogous to PDC.
//  • US Open Level          : open of first bar at 15:30 CET (NYSE/NASDAQ open).
//                             Biggest intraday catalyst for FDAX.
//  • US OPR H/L             : high/low 15:30–16:00 CET, locked at 16:00 CET.
//  • Xetra Value Area H/L   : manual VP bucketed by hlc3 during 09:00–17:30 CET.
//                             Uses the same VA% and Row Size as the RTH VA.
//  • Xetra VWAP             : resets at 09:00 CET. Shown during Xetra hours only.
//
//  • vpRow note             : For DAX (0.5pt min tick), try Row Size = 0.5 or 1.0.
//  • Label stagger          : levels sorted by price; forward pass pushes
//                             overlapping labels upward. Lines always at true price.
//  • All sessions           : America/New_York and Europe/Berlin are both DST-aware.
//  • All lines              : solid style throughout.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ─── Historical buffer ────────────────────────────────────────────────────────
//  request.security() with "1D" uses the built-in `time` series internally to
//  align daily bars with base-chart bars.
max_bars_back(time, 1000)

// ─── Timeframe guard ──────────────────────────────────────────────────────────
//  Minimum supported timeframe is 2-min.  Below that, the "1D" security call
//  requires more time-series history than Pine buffers by default, and the
//  indicator refuses to run rather than crash with a cryptic runtime error.
bool tfOk = timeframe.in_seconds() >= 120

// ─── Inputs — Display ─────────────────────────────────────────────────────────
int   lblOff = input.int(8,   "Label Offset (bars)",          minval=1,    maxval=50,  group="Display",
               tooltip="Shifts all labels rightward into the chart margin.")
float minSep = input.float(3.0, "Min Label Separation (pts)", minval=0.25, step=0.25,  group="Display",
               tooltip="Minimum price gap enforced between adjacent labels. Increase if labels still stack.")

// ─── Inputs — Levels (ES / US Futures) ────────────────────────────────────────
bool showPD    = input.bool(true,  "Previous Day H/L",              group="Levels")
bool showPDC   = input.bool(false, "Previous Day Close (PDC)",      group="Levels")
bool showON    = input.bool(true,  "Overnight H/L",                 group="Levels")
bool showOpen  = input.bool(true,  "RTH Open",                      group="Levels")
bool showVA    = input.bool(true,  "PD RTH Value Area H/L",         group="Levels")
bool showPOC   = input.bool(true,  "PD RTH POC",                    group="Levels")
bool showOPR   = input.bool(true,  "15-min Opening Range",          group="Levels")
bool showIB    = input.bool(false, "Initial Balance H/L",           group="Levels")
bool showIBExt = input.bool(false, "IB Extensions (100/150/200%)",  group="Levels")
bool showGap   = input.bool(false, "Gap Fill Zone",                 group="Levels")

// ─── Inputs — DAX / FDAX Levels ───────────────────────────────────────────────
bool showAsian     = input.bool(false, "Asian / Pre-London H/L  (01:00-08:00 CET)", group="DAX Levels",
                     tooltip="Eurex overnight high/low, running from 01:00 CET to the Euro/Frankfurt open at 08:00 CET. Analogous to ONH/ONL for ES.")
bool showEuroOpen  = input.bool(false, "Euro / Frankfurt Open (08:00 CET)",          group="DAX Levels",
                     tooltip="Open price of the 08:00 CET bar — marks the start of meaningful Frankfurt pre-market liquidity. Held all day.")
bool showEuroOPR   = input.bool(false, "Euro Opening Range H/L (08:00-08:30 CET)",  group="DAX Levels",
                     tooltip="High/low of the first 30 minutes of the European pre-market session. Locked at 08:30 CET.")
bool showXetraOpen = input.bool(false, "Xetra Open (09:00 CET)",                    group="DAX Levels",
                     tooltip="Open price of the first Xetra cash-session bar at 09:00 CET. Equivalent to RTH Open for ES.")
bool showXetraOPR  = input.bool(false, "Xetra OPR H/L (09:00-09:30 CET)",          group="DAX Levels",
                     tooltip="High/low of the first 30 minutes of the Xetra cash session. Locked at 09:30 CET.")
bool showXClose    = input.bool(false, "Prev Xetra Close (17:30 CET)",               group="DAX Levels",
                     tooltip="Previous Xetra session closing price — analogous to PDC for ES traders.")
bool showUSOpen    = input.bool(false, "US Open Level (15:30 CET)",                  group="DAX Levels",
                     tooltip="Open price of the 15:30 CET bar when NYSE and NASDAQ open. The single biggest intraday catalyst for FDAX.")
bool showUSOPR     = input.bool(false, "US OPR H/L (15:30-16:00 CET)",              group="DAX Levels",
                     tooltip="High/low of the first 30 minutes after the US open. Locked at 16:00 CET.")
bool showXetraVA   = input.bool(false, "PD Xetra Value Area H/L",                   group="DAX Levels",
                     tooltip="Previous Xetra session value area (VAH/VAL). Uses the same VA% and Row Size as the RTH value area.")
bool showXetraPOC  = input.bool(false, "PD Xetra POC",                              group="DAX Levels",
                     tooltip="Previous Xetra session point of control (centre of the highest-volume price bucket).")

// ─── Inputs — VWAP (ES / US) ──────────────────────────────────────────────────
bool showDvwap    = input.bool(true, "Daily VWAP Wave (High / Low)", group="VWAP")
bool showDvwapMid = input.bool(true, "Daily VWAP Mid (HLC3)",        group="VWAP",
                    tooltip="Standard VWAP centre line. Visible only when Daily VWAP Wave is on.")
bool showNyVwap   = input.bool(true, "NY Session VWAP (HLC3)",       group="VWAP")

// ─── Inputs — VWAP (DAX / Xetra) ─────────────────────────────────────────────
bool showXVwap    = input.bool(false, "Xetra VWAP Wave (High / Low)", group="DAX VWAP",
                    tooltip="VWAP band (high/low anchors) that resets at the Xetra open (09:00 CET). Shown during Xetra hours only.")
bool showXVwapMid = input.bool(false, "Xetra VWAP Mid (HLC3)",        group="DAX VWAP",
                    tooltip="Xetra VWAP centre line (HLC3). Visible only when Xetra VWAP Wave is on.")

// ─── Inputs — Value Area (shared by RTH and Xetra VPs) ────────────────────────
int   vaPct = input.int(70,  "Value Area %",    minval=50,   maxval=100, group="Value Area",
              tooltip="Percentage of session volume enclosed by the value area. Standard: 70%. Applies to both RTH and Xetra VPs.")
float vpRow = input.float(1.0, "Row Size (pts)", minval=0.25, step=0.25,  group="Value Area",
              tooltip="Price-bucket width. ES default: 1.0pt (4 ticks). DAX (0.5pt tick): try 0.5 or 1.0.")

// ─── Inputs — Colors (ES / US) ────────────────────────────────────────────────
color cPD     = input.color(color.new(#FF6B6B, 0),  "Prev Day H/L",         group="Colors")
color cPDC    = input.color(color.new(#FF9F43, 0),  "Prev Day Close",       group="Colors")
color cON     = input.color(color.new(#74B9FF, 0),  "Overnight H/L",        group="Colors")
color cOpen   = input.color(color.new(#00CEC9, 0),  "RTH Open",             group="Colors")
color cVA     = input.color(color.new(#FDCB6E, 0),  "PD RTH Value Area",    group="Colors")
color cPOC    = input.color(color.new(#A29BFE, 0),  "PD RTH POC",           group="Colors")
color cOPR    = input.color(color.new(#ffffff, 0),  "15-min Opening Range", group="Colors")
color cIB     = input.color(color.new(#55EFC4, 0),  "Initial Balance",      group="Colors")
color cIBExt  = input.color(color.new(#55EFC4, 55), "IB Extensions",        group="Colors")
color cGap    = input.color(color.new(#FFEAA7, 85), "Gap Fill Zone",        group="Colors")
color cDvwap  = input.color(color.new(#6C5CE7, 0),  "Daily VWAP",           group="Colors")
color cNyVwap = input.color(color.new(#FD79A8, 0),  "NY VWAP",              group="Colors")

// ─── Inputs — Colors (DAX / Xetra) ───────────────────────────────────────────
color cAsian     = input.color(color.new(#B2BEC3, 0),  "Asian / Pre-London H/L", group="DAX Colors")
color cEuroOpen  = input.color(color.new(#00B894, 0),  "Euro / Frankfurt Open",  group="DAX Colors")
color cEuroOPR   = input.color(color.new(#81ECEC, 0),  "Euro Opening Range",     group="DAX Colors")
color cXetraOpen = input.color(color.new(#55EFC4, 0),  "Xetra Open",             group="DAX Colors")
color cXetraOPR  = input.color(color.new(#74B9FF, 0),  "Xetra OPR",              group="DAX Colors")
color cXClose    = input.color(color.new(#FF9F43, 0),  "Prev Xetra Close",       group="DAX Colors")
color cUSOpen    = input.color(color.new(#FD79A8, 0),  "US Open",                group="DAX Colors")
color cUSOPR     = input.color(color.new(#E17055, 0),  "US OPR",                 group="DAX Colors")
color cXetraVA   = input.color(color.new(#FDCB6E, 0),  "Xetra Value Area",       group="DAX Colors")
color cXetraPOC  = input.color(color.new(#A29BFE, 0),  "Xetra POC",              group="DAX Colors")
color cXVwap     = input.color(color.new(#00B894, 0),  "Xetra VWAP",             group="DAX Colors")

// ─── Session Flags (ES / US — America/New_York) ───────────────────────────────
bool isRTH     = not na(time("", "0930-1600", "America/New_York"))
bool isON      = not na(time("", "1800-0930", "America/New_York"))
bool isOPRtime = not na(time("", "0930-0945", "America/New_York"))
bool isIBtime  = not na(time("", "0930-1030", "America/New_York"))

bool rthStart = isRTH        and not isRTH[1]
bool rthEnd   = isRTH[1]     and not isRTH
bool oprEnd   = isOPRtime[1] and not isOPRtime
bool ibEnd    = isIBtime[1]  and not isIBtime
bool onStart  = isON         and not isON[1]

// ─── Session Flags (DAX / FDAX — Europe/Berlin, DST-aware) ────────────────────
bool isXetra     = not na(time("", "0900-1730", "Europe/Berlin"))
bool isEuroHours = not na(time("", "0800-1730", "Europe/Berlin"))
bool isEuroOPR_  = not na(time("", "0800-0830", "Europe/Berlin"))
bool isXetraOPR_ = not na(time("", "0900-0930", "Europe/Berlin"))
bool isUSOpenH_  = not na(time("", "1530-1730", "Europe/Berlin"))
bool isUSOPR_    = not na(time("", "1530-1600", "Europe/Berlin"))
bool isAsian_    = not na(time("", "0100-0800", "Europe/Berlin"))

bool xetraStart   = isXetra     and not isXetra[1]
bool xetraEnd     = isXetra[1]  and not isXetra
bool euroStart    = isEuroHours  and not isEuroHours[1]
bool euroOprEnd_  = isEuroOPR_[1]   and not isEuroOPR_
bool xetraOprEnd_ = isXetraOPR_[1]  and not isXetraOPR_
bool usStart_     = isUSOpenH_   and not isUSOpenH_[1]
bool usOPREnd_    = isUSOPR_[1]  and not isUSOPR_
bool asianStart_  = isAsian_     and not isAsian_[1]

// ─── Previous Day High / Low ──────────────────────────────────────────────────
var float pdh = na
var float pdl = na
if tfOk
    pdh := request.security(syminfo.tickerid, "1D", high[1], lookahead=barmerge.lookahead_on)
    pdl := request.security(syminfo.tickerid, "1D", low[1],  lookahead=barmerge.lookahead_on)

// ─── Previous Day Close (RTH 16:00 ET) ───────────────────────────────────────
var float prevPDC = na
if rthEnd
    prevPDC := close[1]

// ─── RTH Open + bar index (gap fill zone anchor) ─────────────────────────────
var float rthOpenPrice = na
var int   rthStartBar  = na
if rthStart
    rthOpenPrice := open
    rthStartBar  := bar_index

// ─── Overnight High / Low (18:00 → 09:30 ET) ─────────────────────────────────
var float _onH = na,  var float _onL = na
var float  onH = na,  var float  onL = na

if onStart
    _onH := high
    _onL := low
else if isON
    _onH := math.max(nz(_onH, high), high)
    _onL := math.min(nz(_onL, low),  low)

if rthStart
    onH  := _onH
    onL  := _onL
    _onH := na
    _onL := na

// ─── 15-min Opening Range (09:30 → 09:45 ET, locked at 09:45 ET) ────────────
var float _oprH = na,  var float _oprL = na
var float  oprH = na,  var float  oprL = na

if rthStart
    oprH  := na
    oprL  := na
    _oprH := high
    _oprL := low
else if isOPRtime
    _oprH := math.max(nz(_oprH, high), high)
    _oprL := math.min(nz(_oprL, low),  low)

if oprEnd
    oprH  := _oprH
    oprL  := _oprL
    _oprH := na
    _oprL := na

// ─── Initial Balance + Extensions (09:30 → 10:30 ET, locked at 10:30 ET) ────
var float _ibH = na,  var float _ibL = na
var float  ibH = na,  var float  ibL = na

var float ibExt1U  = na
var float ibExt15U = na
var float ibExt2U  = na
var float ibExt1D  = na
var float ibExt15D = na
var float ibExt2D  = na

if rthStart
    ibH      := na
    ibL      := na
    _ibH     := high
    _ibL     := low
    ibExt1U  := na
    ibExt15U := na
    ibExt2U  := na
    ibExt1D  := na
    ibExt15D := na
    ibExt2D  := na
else if isIBtime
    _ibH := math.max(nz(_ibH, high), high)
    _ibL := math.min(nz(_ibL, low),  low)

if ibEnd
    ibH  := _ibH
    ibL  := _ibL
    _ibH := na
    _ibL := na
    float rng = ibH - ibL
    ibExt1U  := ibH + 1.0 * rng
    ibExt15U := ibH + 1.5 * rng
    ibExt2U  := ibH + 2.0 * rng
    ibExt1D  := ibL - 1.0 * rng
    ibExt15D := ibL - 1.5 * rng
    ibExt2D  := ibL - 2.0 * rng

// ─── RTH Value Area — Manual Volume Profile ───────────────────────────────────
var map<int, float> _vp = map.new<int, float>()
var float prevVAH = na,  var float prevVAL = na,  var float prevPOC = na

if isRTH
    int bkt = math.round(hlc3 / vpRow)
    map.put(_vp, bkt, nz(map.get(_vp, bkt)) + volume)

if rthEnd and map.size(_vp) > 1
    array<int>   keys = map.keys(_vp)
    array<float> vols = array.new<float>()
    for k in keys
        array.push(vols, nz(map.get(_vp, k)))
    int n = array.size(keys)

    for i = 1 to n - 1
        int   ki = array.get(keys, i)
        float vi = array.get(vols, i)
        int   j  = i - 1
        while j >= 0 and array.get(keys, j) > ki
            array.set(keys, j + 1, array.get(keys, j))
            array.set(vols, j + 1, array.get(vols, j))
            j -= 1
        array.set(keys, j + 1, ki)
        array.set(vols, j + 1, vi)

    int   pocI = 0
    float pocV = 0.0
    for i = 0 to n - 1
        float v = array.get(vols, i)
        if v > pocV
            pocV := v
            pocI := i

    float tgt = array.sum(vols) * vaPct / 100.0
    float acc = pocV
    int   lo  = pocI,  int hi = pocI

    while acc < tgt
        float addUp   = hi < n - 1 ? array.get(vols, hi + 1) : -1.0
        float addDown = lo > 0      ? array.get(vols, lo - 1) : -1.0
        if addUp < 0.0 and addDown < 0.0
            break
        if addUp >= addDown
            hi  += 1
            acc += addUp
        else
            lo  -= 1
            acc += addDown

    prevVAH := array.get(keys, hi)   * vpRow + vpRow
    prevVAL := array.get(keys, lo)   * vpRow
    prevPOC := array.get(keys, pocI) * vpRow + vpRow * 0.5
    map.clear(_vp)

// ─── Daily VWAP Wave (resets at globex open 18:00 ET) ─────────────────────────
var float _dvCumHV = 0.0,  var float _dvCumLV = 0.0
var float _dvCumMV = 0.0,  var float _dvCumV  = 0.0

if onStart
    _dvCumHV := high * volume
    _dvCumLV := low  * volume
    _dvCumMV := hlc3 * volume
    _dvCumV  := volume
else
    _dvCumHV += high * volume
    _dvCumLV += low  * volume
    _dvCumMV += hlc3 * volume
    _dvCumV  += volume

float dvwapH = _dvCumV > 0 ? _dvCumHV / _dvCumV : na
float dvwapL = _dvCumV > 0 ? _dvCumLV / _dvCumV : na
float dvwapM = _dvCumV > 0 ? _dvCumMV / _dvCumV : na

// ─── NY Session VWAP (resets at 09:30 ET, shown during RTH only) ─────────────
var float _nyTPV = 0.0,  var float _nyVol = 0.0

if rthStart
    _nyTPV := hlc3 * volume
    _nyVol := volume
else if isRTH
    _nyTPV += hlc3 * volume
    _nyVol += volume

float nyVwap = isRTH and _nyVol > 0 ? _nyTPV / _nyVol : na

// ─── DAX: Asian / Pre-London H/L (01:00–08:00 CET) ───────────────────────────
//  Accumulates from Eurex open at 01:00 CET; locked when Frankfurt liquidity
//  arrives at the Euro open (08:00 CET). Analogous to ES ONH/ONL.
var float _asH = na,  var float _asL = na
var float  asH = na,  var float  asL = na

if asianStart_
    _asH := high
    _asL := low
else if isAsian_
    _asH := math.max(nz(_asH, high), high)
    _asL := math.min(nz(_asL, low),  low)

if euroStart               // lock at 08:00 CET
    asH  := _asH
    asL  := _asL
    _asH := na
    _asL := na

// ─── DAX: Euro / Frankfurt Open (08:00 CET) ───────────────────────────────────
var float euroOpenPrice = na
if euroStart
    euroOpenPrice := open

// ─── DAX: Euro Opening Range (08:00–08:30 CET, locked at 08:30 CET) ─────────
var float _eOprH = na,  var float _eOprL = na
var float  eOprH = na,  var float  eOprL = na

if euroStart
    _eOprH := high
    _eOprL := low
else if isEuroOPR_
    _eOprH := math.max(nz(_eOprH, high), high)
    _eOprL := math.min(nz(_eOprL, low),  low)

if euroOprEnd_
    eOprH  := _eOprH
    eOprL  := _eOprL
    _eOprH := na
    _eOprL := na

// ─── DAX: Xetra Open (09:00 CET) ──────────────────────────────────────────────
var float xetraOpenPrice = na
if xetraStart
    xetraOpenPrice := open

// ─── DAX: Xetra Opening Range (09:00–09:30 CET, locked at 09:30 CET) ────────
var float _xOprH = na,  var float _xOprL = na
var float  xOprH = na,  var float  xOprL = na

if xetraStart
    xOprH  := na
    xOprL  := na
    _xOprH := high
    _xOprL := low
else if isXetraOPR_
    _xOprH := math.max(nz(_xOprH, high), high)
    _xOprL := math.min(nz(_xOprL, low),  low)

if xetraOprEnd_
    xOprH  := _xOprH
    xOprL  := _xOprL
    _xOprH := na
    _xOprL := na

// ─── DAX: Previous Xetra Close (17:30 CET) ────────────────────────────────────
var float prevXClose = na
if xetraEnd
    prevXClose := close[1]

// ─── DAX: US Open Level (15:30 CET) ───────────────────────────────────────────
var float usOpenPrice = na
if usStart_
    usOpenPrice := open

// ─── DAX: US Opening Range (15:30–16:00 CET, locked at 16:00 CET) ────────────
var float _usOprH = na,  var float _usOprL = na
var float  usOprH = na,  var float  usOprL = na

if usStart_
    _usOprH := high
    _usOprL := low
else if isUSOPR_
    _usOprH := math.max(nz(_usOprH, high), high)
    _usOprL := math.min(nz(_usOprL, low),  low)

if usOPREnd_
    usOprH  := _usOprH
    usOprL  := _usOprL
    _usOprH := na
    _usOprL := na

// ─── DAX: Xetra Value Area — Manual Volume Profile (09:00–17:30 CET) ─────────
//  Identical algorithm to RTH VA; uses a separate map and triggers on xetraEnd.
var map<int, float> _xVp = map.new<int, float>()
var float prevXVAH = na,  var float prevXVAL = na,  var float prevXPOC = na

if isXetra
    int xBkt = math.round(hlc3 / vpRow)
    map.put(_xVp, xBkt, nz(map.get(_xVp, xBkt)) + volume)

if xetraEnd and map.size(_xVp) > 1
    array<int>   xKeys = map.keys(_xVp)
    array<float> xVols = array.new<float>()
    for k in xKeys
        array.push(xVols, nz(map.get(_xVp, k)))
    int xN = array.size(xKeys)

    for i = 1 to xN - 1
        int   ki = array.get(xKeys, i)
        float vi = array.get(xVols, i)
        int   j  = i - 1
        while j >= 0 and array.get(xKeys, j) > ki
            array.set(xKeys, j + 1, array.get(xKeys, j))
            array.set(xVols, j + 1, array.get(xVols, j))
            j -= 1
        array.set(xKeys, j + 1, ki)
        array.set(xVols, j + 1, vi)

    int   xPocI = 0
    float xPocV = 0.0
    for i = 0 to xN - 1
        float v = array.get(xVols, i)
        if v > xPocV
            xPocV := v
            xPocI := i

    float xTgt = array.sum(xVols) * vaPct / 100.0
    float xAcc = xPocV
    int   xLo  = xPocI,  int xHi = xPocI

    while xAcc < xTgt
        float addUp   = xHi < xN - 1 ? array.get(xVols, xHi + 1) : -1.0
        float addDown = xLo > 0       ? array.get(xVols, xLo - 1) : -1.0
        if addUp < 0.0 and addDown < 0.0
            break
        if addUp >= addDown
            xHi  += 1
            xAcc += addUp
        else
            xLo  -= 1
            xAcc += addDown

    prevXVAH := array.get(xKeys, xHi)   * vpRow + vpRow
    prevXVAL := array.get(xKeys, xLo)   * vpRow
    prevXPOC := array.get(xKeys, xPocI) * vpRow + vpRow * 0.5
    map.clear(_xVp)

// ─── DAX: Xetra VWAP (resets at Xetra open 09:00 CET) ────────────────────────
var float _xVwapCumHV = 0.0,  var float _xVwapCumLV = 0.0
var float _xVwapCumMV = 0.0,  var float _xVwapCumV  = 0.0

if xetraStart
    _xVwapCumHV := high * volume
    _xVwapCumLV := low  * volume
    _xVwapCumMV := hlc3 * volume
    _xVwapCumV  := volume
else if isXetra
    _xVwapCumHV += high * volume
    _xVwapCumLV += low  * volume
    _xVwapCumMV += hlc3 * volume
    _xVwapCumV  += volume

float xVwapH = isXetra and _xVwapCumV > 0 ? _xVwapCumHV / _xVwapCumV : na
float xVwapL = isXetra and _xVwapCumV > 0 ? _xVwapCumLV / _xVwapCumV : na
float xVwapM = isXetra and _xVwapCumV > 0 ? _xVwapCumMV / _xVwapCumV : na

// ─── Level collection helper ──────────────────────────────────────────────────
//  Appends a level to the three parallel arrays only when price is not na.
f_collect(array<float> ps, array<string> ts, array<color> cs,
          float price, string txt, color clr) =>
    if not na(price)
        array.push(ps, price)
        array.push(ts, txt)
        array.push(cs, clr)

// ─── Drawing pool ─────────────────────────────────────────────────────────────
//  Objects are created ONCE on barstate.isfirst and reused forever.
//  No line/label is ever created or deleted after initialisation, so the
//  object count is fixed at MAX_LEVELS and the GC double-count bug cannot occur.
//
//  MAX_LEVELS must be ≥ the maximum number of non-na levels at any one time.
//  ES (21) + DAX (15) = 36 active maximum → 40 gives 4 spare slots.
//  If you add new levels, increment MAX_LEVELS accordingly.
var int MAX_LEVELS = 40

var array<line>  poolLines  = array.new<line>()
var array<label> poolLabels = array.new<label>()
var box          gapBox     = na

// ─── Unsupported timeframe — native error, no visual banner ──────────────────
if not tfOk
    runtime.error('This indicator requires a 2-min timeframe or higher.')

if tfOk and barstate.isfirst
    for i = 0 to MAX_LEVELS - 1
        array.push(poolLines,
             line.new(x1=na, y1=na, x2=na, y2=na,
                      xloc=xloc.bar_index,
                      color=color.new(color.white, 100),
                      style=line.style_solid, width=1,
                      extend=extend.left))
        array.push(poolLabels,
             label.new(x=na, y=na, text="",
                       xloc=xloc.bar_index,
                       color=color.new(color.white, 100),
                       textcolor=color.new(color.white, 100),
                       style=label.style_label_left,
                       size=size.small))

if tfOk and barstate.islast

    // ── Collect all active levels ────────────────────────────────────────────
    array<float>  lvlP = array.new<float>()
    array<string> lvlT = array.new<string>()
    array<color>  lvlC = array.new<color>()

    // ── ES / US levels ────────────────────────────────────────────────────────
    if showPD
        f_collect(lvlP, lvlT, lvlC, pdh,          "PDH",         cPD)
        f_collect(lvlP, lvlT, lvlC, pdl,          "PDL",         cPD)
    if showPDC
        f_collect(lvlP, lvlT, lvlC, prevPDC,      "PDC",         cPDC)
    if showON
        f_collect(lvlP, lvlT, lvlC, onH,          "ONH",         cON)
        f_collect(lvlP, lvlT, lvlC, onL,          "ONL",         cON)
    if showOpen
        f_collect(lvlP, lvlT, lvlC, rthOpenPrice, "RTH OPEN",    cOpen)
    if showVA
        f_collect(lvlP, lvlT, lvlC, prevVAH,      "PD RTH VAH",  cVA)
        f_collect(lvlP, lvlT, lvlC, prevVAL,      "PD RTH VAL",  cVA)
    if showPOC
        f_collect(lvlP, lvlT, lvlC, prevPOC,      "PD RTH POC",  cPOC)
    if showOPR
        f_collect(lvlP, lvlT, lvlC, oprH,         "15-min OPR",  cOPR)
        f_collect(lvlP, lvlT, lvlC, oprL,         "15-min OPR",  cOPR)
    if showIB
        f_collect(lvlP, lvlT, lvlC, ibH,          "IBH",         cIB)
        f_collect(lvlP, lvlT, lvlC, ibL,          "IBL",         cIB)
    if showIBExt
        f_collect(lvlP, lvlT, lvlC, ibExt1U,      "IB +100%",    cIBExt)
        f_collect(lvlP, lvlT, lvlC, ibExt15U,     "IB +150%",    cIBExt)
        f_collect(lvlP, lvlT, lvlC, ibExt2U,      "IB +200%",    cIBExt)
        f_collect(lvlP, lvlT, lvlC, ibExt1D,      "IB -100%",    cIBExt)
        f_collect(lvlP, lvlT, lvlC, ibExt15D,     "IB -150%",    cIBExt)
        f_collect(lvlP, lvlT, lvlC, ibExt2D,      "IB -200%",    cIBExt)

    // ── DAX / FDAX levels ─────────────────────────────────────────────────────
    if showAsian
        f_collect(lvlP, lvlT, lvlC, asH,           "Asian H",      cAsian)
        f_collect(lvlP, lvlT, lvlC, asL,           "Asian L",      cAsian)
    if showEuroOpen
        f_collect(lvlP, lvlT, lvlC, euroOpenPrice, "Euro Open",    cEuroOpen)
    if showEuroOPR
        f_collect(lvlP, lvlT, lvlC, eOprH,         "Euro OPR H",   cEuroOPR)
        f_collect(lvlP, lvlT, lvlC, eOprL,         "Euro OPR L",   cEuroOPR)
    if showXetraOpen
        f_collect(lvlP, lvlT, lvlC, xetraOpenPrice,"Xetra Open",   cXetraOpen)
    if showXetraOPR
        f_collect(lvlP, lvlT, lvlC, xOprH,         "Xetra OPR H",  cXetraOPR)
        f_collect(lvlP, lvlT, lvlC, xOprL,         "Xetra OPR L",  cXetraOPR)
    if showXClose
        f_collect(lvlP, lvlT, lvlC, prevXClose,    "Xetra Close",  cXClose)
    if showUSOpen
        f_collect(lvlP, lvlT, lvlC, usOpenPrice,   "US Open",      cUSOpen)
    if showUSOPR
        f_collect(lvlP, lvlT, lvlC, usOprH,        "US OPR H",     cUSOPR)
        f_collect(lvlP, lvlT, lvlC, usOprL,        "US OPR L",     cUSOPR)
    if showXetraVA
        f_collect(lvlP, lvlT, lvlC, prevXVAH,      "Xetra VAH",    cXetraVA)
        f_collect(lvlP, lvlT, lvlC, prevXVAL,      "Xetra VAL",    cXetraVA)
    if showXetraPOC
        f_collect(lvlP, lvlT, lvlC, prevXPOC,      "Xetra POC",    cXetraPOC)

    int nLvl = array.size(lvlP)

    // ── Sort ascending by price ──────────────────────────────────────────────
    array<float>  sPrice = array.new<float>()
    array<string> sTxt   = array.new<string>()
    array<color>  sClr   = array.new<color>()
    array<float>  lblY   = array.new<float>()

    if nLvl > 0
        array<int> idx = array.sort_indices(lvlP, order.ascending)
        for i = 0 to nLvl - 1
            int si = array.get(idx, i)
            array.push(sPrice, array.get(lvlP, si))
            array.push(sTxt,   array.get(lvlT, si))
            array.push(sClr,   array.get(lvlC, si))

        // ── Label stagger pass ───────────────────────────────────────────────
        lblY := array.copy(sPrice)
        if nLvl > 1
            for i = 1 to nLvl - 1
                float prevY = array.get(lblY, i - 1)
                float curY  = array.get(lblY, i)
                if curY - prevY < minSep
                    array.set(lblY, i, prevY + minSep)

    // ── Single pass: update visible slots, hide unused ones ──────────────────
    //  No line/label is ever created or destroyed here — only properties change.
    for i = 0 to MAX_LEVELS - 1
        line  ln = array.get(poolLines,  i)
        label lb = array.get(poolLabels, i)

        if i < nLvl
            float  p = array.get(sPrice, i)
            float  y = array.get(lblY,   i)
            string t = array.get(sTxt,   i)
            color  c = array.get(sClr,   i)

            line.set_xy1(ln, bar_index, p)
            line.set_xy2(ln, bar_index + lblOff, p)
            line.set_color(ln, c)

            label.set_x(lb, bar_index + lblOff)
            label.set_y(lb, y)
            label.set_text(lb, t + "  " + str.tostring(p, "#.##"))
            label.set_color(lb, color.new(c, 85))
            label.set_textcolor(lb, c)
        else
            // Clear coordinates to prevent auto-scale squeeze, and make fully transparent
            line.set_xy1(ln, na, na)
            line.set_xy2(ln, na, na)
            line.set_color(ln,  color.new(color.white, 100))
            label.set_x(lb, na)
            label.set_y(lb, na)
            label.set_color(lb, color.new(color.white, 100))
            label.set_textcolor(lb, color.new(color.white, 100))

    // ── Gap Fill Zone (box — outside the level system) ───────────────────────
    box.delete(gapBox)
    gapBox := na
    if showGap and not na(prevPDC) and not na(rthOpenPrice) and not na(rthStartBar)
        float gapTop = math.max(prevPDC, rthOpenPrice)
        float gapBot = math.min(prevPDC, rthOpenPrice)
        if gapTop - gapBot > syminfo.mintick * 2
            gapBox := box.new(rthStartBar, gapTop, bar_index + 1, gapBot,
                              border_color=color.new(cGap, 60),
                              border_width=1, bgcolor=cGap,
                              extend=extend.right)

// ─── ES / US VWAP Plots (root scope) ─────────────────────────────────────────
pDvH = plot(showDvwap ? dvwapH : na,
            title="Daily VWAP High", color=cDvwap, linewidth=1)
pDvL = plot(showDvwap ? dvwapL : na,
            title="Daily VWAP Low",  color=cDvwap, linewidth=1)

plot(showDvwap and showDvwapMid ? dvwapM : na,
     title="Daily VWAP Mid", color=color.new(cDvwap, 40), linewidth=1)

fill(pDvH, pDvL,
     color=color.new(cDvwap, 88),
     title="Daily VWAP Band")

plot(showNyVwap ? nyVwap : na,
     title="NY VWAP", color=cNyVwap, linewidth=2,
     style=plot.style_linebr)

// ─── DAX / Xetra VWAP Plots (root scope) ─────────────────────────────────────
pXvH = plot(showXVwap ? xVwapH : na,
            title="Xetra VWAP High", color=cXVwap, linewidth=1)
pXvL = plot(showXVwap ? xVwapL : na,
            title="Xetra VWAP Low",  color=cXVwap, linewidth=1)

plot(showXVwap and showXVwapMid ? xVwapM : na,
     title="Xetra VWAP Mid", color=color.new(cXVwap, 40), linewidth=1)

fill(pXvH, pXvL,
     color=color.new(cXVwap, 88),
     title="Xetra VWAP Band")
````
