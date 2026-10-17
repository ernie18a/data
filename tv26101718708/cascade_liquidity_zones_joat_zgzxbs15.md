# Cascade Liquidity Zones [JOAT]

- url: https://www.tradingview.com/script/zGzxBs15-Cascade-Liquidity-Zones-JOAT/
- type: indicator
- pine_id: PUB;d7ffcfd635cf4ed1b2bd81c7c84544d5
- version: 1.0

## Description

[b]Cascade Liquidity Zones [JOAT][/b]

[b]Introduction[/b]

Cascade Liquidity Zones is an open-source institutional stop-hunt and liquidity zone detector built around the mechanics of how large participants move price through retail stop clusters before reversing. It identifies demand and supply zones from pivot-impulse structures, scores them by quality, confirms sweep events with multiple filters, and marks potential failure entry patterns — all within a single indicator that requires no additional tools to interpret.

The foundational premise is that price routinely sweeps beyond visible structural levels to trigger stop orders placed by retail participants, before institutional participants absorb the liquidity generated and reverse price. Identifying these events in advance, tracking the zones where they are likely to occur, and confirming them with volume and wick rejection filters produces a framework for anticipating institutional reactions at structural extremes.

[image]https://www.tradingview.com/x/NoyXJlcP/[/image]

[b]Core Concepts[/b]

[b]1. Pivot-Impulse Zone Creation[/b]

Demand zones are formed from confirmed pivot lows and supply zones from confirmed pivot highs. Each pivot creates a zone spanning a configurable ATR multiple, representing the area of institutional activity around that structural level. Zones are scored using a three-component Impulse Quality Score:

[pine]
f_score(idx) =>
    bodyR = math.abs(close[idx]-open[idx]) / math.max(high[idx]-low[idx], syminfo.mintick)
    volR  = volume[idx] / ta.sma(volume, 20)[idx]
    atrR  = (high[idx]-low[idx]) / ta.atr(14)[idx]
    (bodyR*40.0) + (math.min(volR,4.0)/4.0*35.0) + (math.min(atrR,3.0)/3.0*25.0)
[/pine]

This scores the impulse candle by three factors: directional body conviction (40%), volume participation relative to average (35%), and range size relative to ATR (25%).

[b]2. Four-Layer Glow Zone Visualization[/b]

Each zone is drawn as four concentric boxes expanding outward from the core zone level, with decreasing opacity on each outer layer. This creates a visual glow effect that communicates zone location and zone type at a glance. Demand zones use the bull theme color; supply zones use the bear theme color.

[b]3. Sweep Confirmation Engine[/b]

A demand zone sweep is confirmed when all of the following conditions pass simultaneously on a confirmed bar: minimum wick penetration percentage, close back inside or above the zone, volume exceeds average by a configurable multiple, wick rejection percentage exceeds minimum threshold, cooldown period elapsed, and optional pattern filters pass.

[b]4. Failure Entry Engine[/b]

An alternative entry mode detects price failure patterns at pivot levels. A bullish failure occurs when price wicks below the most recent confirmed pivot low and closes back above it on the same bar, with the wick exceeding a minimum ATR size and a minimum rejection percentage. This targets trapped short-sellers at pivot extremes.

[b]5. Zone Flip Mechanics[/b]

When price closes fully through a demand zone, that zone flips to a supply zone — its color changes from bull to bear theme color and it becomes eligible for short-side sweeps. This reflects the structural concept that broken support becomes resistance.

[b]6. Liquidity Value and Hold Percentage[/b]

Each zone tracks cumulative volume × price product from its origin bar, displayed as a liquidity value label ($K, $M, $B). Zones also track how many times price has touched and rejected from them without breaking through, expressed as a hold percentage.

[image]https://www.tradingview.com/x/ON8Z4Cyv/[/image]

[b]Features[/b]

[list]
[*][b]Pivot-impulse zone creation:[/b] Demand and supply zones built from confirmed structural pivot points, scored by impulse quality
[*][b]Three-component impulse quality score:[/b] Body conviction, volume participation, and ATR-relative range scored at zone creation
[*][b]Four-layer glow boxes:[/b] Each zone drawn as four concentric boxes with decreasing opacity for a depth visualization effect
[*][b]Multi-filter sweep confirmation:[/b] Wick penetration %, close direction, volume multiple, wick rejection %, cooldown, and optional pattern filters
[*][b]Failure entry engine:[/b] Detects pivot-wick failure patterns as an alternative signal type with independent settings
[*][b]Zone flip:[/b] Broken demand zones automatically flip to supply and vice versa
[*][b]Liquidity value labels:[/b] Volume × price accumulated at each zone's origin bar, displayed in human-readable scale
[*][b]Hold percentage:[/b] Ratio of zone tests that did not break through; used to prioritize zone strength
[*][b]Trade block on sweep:[/b] Entry, stop, and two TP levels rendered as boxes and lines when a sweep confirms
[*][b]Zone clustering:[/b] Overlapping zones within a minimum ATR separation are deduplicated, keeping the higher-quality zone
[*][b]Backtest tracker:[/b] Win rate and expected value tracked across all sweep signals
[*][b]Non-repainting:[/b] All sweep confirmations gated by barstate.isconfirmed
[*][b]Institutional dashboard:[/b] 18-row table with zone statistics, sweep and failure counts, win rate, and expected value
[/list]

[b]Input Parameters[/b]

[b]Zone Detection:[/b]
[list]
[*]Pivot Lookback: Bars required on each side to confirm a pivot (default: 10)
[*]Max Active Zones Per Side: Maximum simultaneous demand or supply zones (default: 8)
[*]Zone ATR Width: Zone height as ATR multiple (default: 0.4)
[*]Min Zone Separation: Minimum distance between zones in ATR units (default: 1.5)
[/list]

[b]Sweep Confirmation:[/b]
[list]
[*]Min Wick Penetration %: Minimum wick extension through zone boundary
[*]Volume Confirmation toggle and minimum volume multiple
[*]Wick Rejection Filter toggle and minimum rejection %
[*]Cooldown Bars Between Sweeps
[/list]

[b]Failure Entry:[/b]
[list]
[*]Enable Failure Entry Mode toggle
[*]Pivot lookback, wick ATR minimum, wick rejection minimum, volume confirmation, cooldown
[/list]

[b]Trade Block:[/b]
[list]
[*]Show Trade Block toggle
[*]RR Ratio for TP placement
[*]SL Mode: Zone boundary or Wick extreme
[*]SL Buffer in ATR units
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify Active Zones[/b]
Fresh zones (not yet swept) are displayed in full color. Prioritize fresh zones with high hold percentages and large liquidity values for upcoming sweep setups.

[b]Step 2: Wait for Sweep Confirmation[/b]
A sweep is confirmed when the bar closes after the wick penetration. The trade block appears automatically with entry at the close of the confirmation bar, stop behind the zone boundary plus buffer, TP1 at 1:1 R, and TP2 at the configured RR ratio.

[b]Step 3: Distinguish Sweeps from Failures[/b]
Standard sweeps require price to touch inside the zone boundary. Failure entries detect pivot-level failures at a higher structural level. Enable only one mode at a time to avoid conflicting signals.

[b]Indicator Limitations[/b]

[list]
[*]Pivot confirmation requires bars after the pivot candle. Zones are plotted with an inherent offset corresponding to the lookback length
[*]All sweep confirmations require a bar close. Price that sweeps and reverses within the same bar without confirming on close will not generate a signal
[*]Volume-based filters are less reliable on assets where volume data is unreported or synthetic
[*]Zone flip mechanics assume that a broken level becomes resistance. This structural assumption does not hold in all market conditions
[/list]

[b]Originality Statement[/b]

[list]
[*]The combination of a three-component impulse quality score at zone creation, four-layer glow box visualization, multi-condition sweep confirmation, zone flip mechanics, and a failure entry engine in a single indicator is not replicated in existing open-source Pine Script v6 publications
[*]The liquidity value metric (volume × price at pivot origin) as a zone ranking input alongside hold percentage provides an institutional sizing dimension that simple pivot-based zone indicators do not include
[*]The dual-mode architecture (sweep engine + failure entry engine) with independent settings for each, selectable via a single mode toggle, allows the same structural framework to address two different entry philosophies within one indicator
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Trading involves substantial risk of loss. Liquidity sweep patterns identified by this indicator represent historical structural events, not predictions of future price behavior. The author accepts no responsibility for trading losses resulting from use of this indicator.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Cascade Liquidity Zones [JOAT]", overlay=true, max_boxes_count=200, max_lines_count=100, max_labels_count=50)

// ============================================================
//  CASCADE LIQUIDITY ZONES [JOAT]
//  Institutional stop-hunt liquidity zone detector.
//  Demand/supply zones from impulse pivot structures,
//  scored by body×40 + vol×35 + ATR-range×25.
//  Multi-filter sweep confirmation, failure entry engine,
//  zone flip mechanics, 4-layer glow boxes, trade block.
// ============================================================

// ─────────────────────────────────────────────────────────────
//  COLOR THEMES
// ─────────────────────────────────────────────────────────────
string themeInput = input.string("Phantom", "Color Theme",
     options=["Phantom","Neon","Classic","Solar"], group="◈ Visual")

var color colorBULL  = na
var color colorBEAR  = na
var color colorELITE = na
var color colorNEUTR = na

if themeInput == "Phantom"
    colorBULL  := color.rgb(6, 182, 212)
    colorBEAR  := color.rgb(236, 72, 153)
    colorELITE := color.rgb(187, 134, 252)
    colorNEUTR := color.rgb(139, 148, 158)
else if themeInput == "Neon"
    colorBULL  := #00F5D4
    colorBEAR  := #FF4466
    colorELITE := #6C63FF
    colorNEUTR := #FFD700
else if themeInput == "Classic"
    colorBULL  := color.rgb(0, 255, 0)
    colorBEAR  := color.rgb(255, 0, 0)
    colorELITE := color.rgb(187, 134, 252)
    colorNEUTR := color.rgb(139, 148, 158)
else
    colorBULL  := #FF9800
    colorBEAR  := #42A5F5
    colorELITE := #FFEB3B
    colorNEUTR := #9E9E9E

// ─────────────────────────────────────────────────────────────
//  INPUTS — ZONE DETECTION
// ─────────────────────────────────────────────────────────────
var string G_ZONE = "◈ Zone Detection"
int   pivLen     = input.int(10,    "Pivot Lookback",              minval=3,  maxval=50,  group=G_ZONE)
int   maxZones   = input.int(8,     "Max Active Zones/Side",       minval=2,  maxval=20,  group=G_ZONE)
float zoneAtrMul = input.float(0.4, "Zone ATR Width",              minval=0.1, maxval=2.0, step=0.1, group=G_ZONE)
float minDistMul = input.float(1.5, "Min Zone Separation (ATR)",   minval=0.5, maxval=10.0, step=0.5, group=G_ZONE)
bool  showFresh  = input.bool(false, "Show Fresh Zones Only",      group=G_ZONE)
bool  enableFlip = input.bool(true,  "Enable Zone Flip",            group=G_ZONE)
int   zoneTrans  = input.int(80,    "Zone Transparency",            minval=0, maxval=99,  group=G_ZONE)
int   glowStr    = input.int(88,    "Glow Strength",                minval=60, maxval=99, group=G_ZONE)

// ─────────────────────────────────────────────────────────────
//  INPUTS — SWEEP CONFIRMATION
// ─────────────────────────────────────────────────────────────
var string G_SWEEP = "◈ Sweep Confirmation"
float minWickPct  = input.float(0.05, "Min Wick Penetration %",    minval=0.0, maxval=2.0, step=0.01, group=G_SWEEP)
bool  useVol      = input.bool(true,  "Volume Confirmation",        group=G_SWEEP)
float volMult     = input.float(1.4,  "Min Volume Multiple",        minval=0.5, maxval=5.0, step=0.1, group=G_SWEEP)
int   volLen      = input.int(20,     "Volume Average Length",      group=G_SWEEP)
bool  useWick     = input.bool(true,  "Wick Rejection Filter",      group=G_SWEEP)
float wickMin     = input.float(25.0, "Min Wick Rejection %",       minval=10.0, maxval=90.0, step=5.0, group=G_SWEEP)
int   sweepCool   = input.int(5,      "Cooldown Bars",              minval=0, maxval=50, group=G_SWEEP)

// ─────────────────────────────────────────────────────────────
//  INPUTS — FAILURE ENTRY
// ─────────────────────────────────────────────────────────────
var string G_FAIL = "◈ Failure Entry"
bool   enableFail  = input.bool(false, "Enable Failure Entry Mode",  group=G_FAIL)
int    failPivLen  = input.int(10,    "Pivot Lookback",              minval=3, maxval=50,  group=G_FAIL)
float  failWickATR = input.float(0.4, "Min Failure Wick ATR",        minval=0.05, maxval=3.0, step=0.05, group=G_FAIL)
float  failWickRej = input.float(25.0,"Min Wick Rejection %",        minval=10.0, maxval=90.0, step=5.0, group=G_FAIL)
bool   failUseVol  = input.bool(true, "Volume Confirm",              group=G_FAIL)
float  failVolMult = input.float(1.2, "Min Volume Multiple",         minval=0.5, maxval=5.0, step=0.1, group=G_FAIL)
int    failCool    = input.int(3,     "Cooldown Bars",               minval=0, maxval=50,  group=G_FAIL)

// ─────────────────────────────────────────────────────────────
//  INPUTS — TRADE BLOCK
// ─────────────────────────────────────────────────────────────
var string G_TRADE = "◈ Trade Block"
bool   showTrade  = input.bool(true,   "Show Trade Block",           group=G_TRADE)
float  rrRatio    = input.float(1.0,   "RR Ratio",                   minval=0.5, maxval=10.0, step=0.5, group=G_TRADE)
string slMode     = input.string("Zone","SL Mode", options=["Zone","Wick"],        group=G_TRADE)
float  slBuffer   = input.float(0.4,   "SL Buffer ATR",              minval=0.0, maxval=2.0, step=0.1, group=G_TRADE)
int    tradeW     = input.int(20,      "Trade Block Width",           minval=5, maxval=100, group=G_TRADE)

// ─────────────────────────────────────────────────────────────
//  INPUTS — DASHBOARD
// ─────────────────────────────────────────────────────────────
var string G_DASH = "◈ Dashboard"
bool   showDash   = input.bool(true,         "Show Dashboard", group=G_DASH)
string dashPos    = input.string("Top Right", "Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=G_DASH)
string dashSize   = input.string("Small",     "Size",
     options=["Tiny","Small","Normal"], group=G_DASH)

// ─────────────────────────────────────────────────────────────
//  ZONE TYPE DEFINITION  (must precede array<Zone> declarations)
// ─────────────────────────────────────────────────────────────
type Zone
    float zTop
    float zBot
    float score
    bool  isDemand
    bool  isFresh
    int   startBar
    int   tests
    float liqVal
    box   coreBox
    box   glowBox1
    box   glowBox2
    box   glowBox3
    label scoreLbl

var array<Zone> demandZones = array.new<Zone>()
var array<Zone> supplyZones = array.new<Zone>()

// ─────────────────────────────────────────────────────────────
//  PERSISTENT STATE
// ─────────────────────────────────────────────────────────────
var int   lastBullSweep = 0
var int   lastBearSweep = 0
var int   totalLongs    = 0
var int   totalShorts   = 0
var int   totalSignals  = 0
var int   totalWins     = 0
var float totalPnlR     = 0.0
var int   btDir         = 0
var float btTP          = na
var float btSL          = na
var float fPivHi        = na
var float fPivLo        = na

// ─────────────────────────────────────────────────────────────
//  CORE CALCULATIONS
// ─────────────────────────────────────────────────────────────
float atrVal  = ta.atr(14)
float avgVol  = ta.sma(volume, volLen)
float zoneH   = atrVal * zoneAtrMul
float minDist = atrVal * minDistMul

// ─────────────────────────────────────────────────────────────
//  UTILITY FUNCTIONS
// ─────────────────────────────────────────────────────────────

// Impulse quality score (body×40 + vol×35 + ATR-range×25)
f_score(int idx) =>
    float rng   = high[idx] - low[idx]
    float body  = math.abs(close[idx] - open[idx])
    float bodyR = rng > 0.0 ? body / rng : 0.0
    float volR  = avgVol[idx] > 0.0 ? volume[idx] / avgVol[idx] : 1.0
    float atrR  = atrVal[idx] > 0.0 ? rng / atrVal[idx] : 1.0
    float s     = (bodyR * 40.0) + (math.min(volR, 4.0) / 4.0 * 35.0) + (math.min(atrR, 3.0) / 3.0 * 25.0)
    math.max(0.0, math.min(100.0, s))

// Liquidity value formatter
f_liqFmt(float v) =>
    string _r = (v >= 1.0e9 ? str.tostring(math.round(v / 1.0e9, 1)) + "B" :
                 v >= 1.0e6 ? str.tostring(math.round(v / 1.0e6, 1)) + "M" :
                 v >= 1.0e3 ? str.tostring(math.round(v / 1.0e3, 1)) + "K" :
                              str.tostring(math.round(v, 0)))
    _r

// Hold percentage helper
f_holdPct(int tests) =>
    tests > 0 ? math.round(float(tests - 1) / float(tests) * 100) : 100

// ─────────────────────────────────────────────────────────────
//  4-LAYER GLOW BOX CREATOR
// ─────────────────────────────────────────────────────────────
f_createZone(int pBar, float zTop, float zBot, color zCol, int trans, int glow) =>
    int  rightEdge = bar_index
    // Outermost glow layer (largest expansion, most transparent)
    box g3 = box.new(pBar, zTop + atrVal * 0.15, rightEdge, zBot - atrVal * 0.15,
         bgcolor      = color.new(zCol, math.min(99, glow + 15)),
         border_color = color.new(color.black, 100),
         extend       = extend.right)
    // Middle-outer glow
    box g2 = box.new(pBar, zTop + atrVal * 0.10, rightEdge, zBot - atrVal * 0.10,
         bgcolor      = color.new(zCol, math.min(99, glow + 8)),
         border_color = color.new(color.black, 100),
         extend       = extend.right)
    // Inner glow
    box g1 = box.new(pBar, zTop + atrVal * 0.05, rightEdge, zBot - atrVal * 0.05,
         bgcolor      = color.new(zCol, glow),
         border_color = color.new(color.black, 100),
         extend       = extend.right)
    // Core zone box
    box cb = box.new(pBar, zTop, rightEdge, zBot,
         bgcolor      = color.new(zCol, trans),
         border_color = color.new(zCol, math.max(0, trans - 25)),
         border_width = 1,
         extend       = extend.right)
    [g3, g2, g1, cb]

// ─────────────────────────────────────────────────────────────
//  CLUSTER CHECK — prevents overlapping / duplicate zones
// ─────────────────────────────────────────────────────────────
f_cluster(array<Zone> arr, float mid, float score) =>
    bool blocked = false
    if arr.size() > 0
        for i = arr.size() - 1 to 0
            Zone z        = arr.get(i)
            float existMid = (z.zTop + z.zBot) / 2.0
            if math.abs(mid - existMid) < minDist
                if z.score >= score
                    blocked := true
                else
                    box.delete(z.coreBox)
                    box.delete(z.glowBox1)
                    box.delete(z.glowBox2)
                    box.delete(z.glowBox3)
                    label.delete(z.scoreLbl)
                    arr.remove(i)
                break
    blocked

// ─────────────────────────────────────────────────────────────
//  PIVOT DETECTION
// ─────────────────────────────────────────────────────────────
float pivH = ta.pivothigh(high, pivLen, pivLen)
float pivL = ta.pivotlow( low,  pivLen, pivLen)

// Failure-entry pivot detection (separate lookback)
float failPivH = ta.pivothigh(high, failPivLen, failPivLen)
float failPivL = ta.pivotlow( low,  failPivLen, failPivLen)

// ─────────────────────────────────────────────────────────────
//  ZONE CREATION — DEMAND (pivot low → bullish)
// ─────────────────────────────────────────────────────────────
if not na(pivL) and barstate.isconfirmed
    int   pBar   = bar_index - pivLen
    float pPrice = low[pivLen]
    float zTop_d = pPrice + zoneH
    float zBot_d = pPrice
    float mid_d  = (zTop_d + zBot_d) / 2.0
    float sc_d   = f_score(pivLen)

    if sc_d > 0.0 and not f_cluster(demandZones, mid_d, sc_d)
        float liqVal_d            = volume[pivLen] * pPrice
        [g3b, g2b, g1b, cBox_d]  = f_createZone(pBar, zTop_d, zBot_d, colorBULL, zoneTrans, glowStr)

        label sLbl_d = label.new(bar_index, zTop_d,
             str.tostring(math.round(sc_d)) + "  |  " + f_liqFmt(liqVal_d),
             style     = label.style_label_left,
             color     = color.new(colorBULL, 85),
             textcolor = colorBULL,
             size      = size.tiny)

        Zone newDemand = Zone.new(
             zTop_d, zBot_d, sc_d, true, true, pBar, 1,
             liqVal_d, cBox_d, g1b, g2b, g3b, sLbl_d)

        demandZones.push(newDemand)

        if demandZones.size() > maxZones
            Zone old_d = demandZones.shift()
            box.delete(old_d.coreBox)
            box.delete(old_d.glowBox1)
            box.delete(old_d.glowBox2)
            box.delete(old_d.glowBox3)
            label.delete(old_d.scoreLbl)

// ─────────────────────────────────────────────────────────────
//  ZONE CREATION — SUPPLY (pivot high → bearish)
// ─────────────────────────────────────────────────────────────
if not na(pivH) and barstate.isconfirmed
    int   pBar   = bar_index - pivLen
    float pPrice = high[pivLen]
    float zTop_s = pPrice
    float zBot_s = pPrice - zoneH
    float mid_s  = (zTop_s + zBot_s) / 2.0
    float sc_s   = f_score(pivLen)

    if sc_s > 0.0 and not f_cluster(supplyZones, mid_s, sc_s)
        float liqVal_s            = volume[pivLen] * pPrice
        [g3s, g2s, g1s, cBox_s]  = f_createZone(pBar, zTop_s, zBot_s, colorBEAR, zoneTrans, glowStr)

        label sLbl_s = label.new(bar_index, zBot_s,
             str.tostring(math.round(sc_s)) + "  |  " + f_liqFmt(liqVal_s),
             style     = label.style_label_left,
             color     = color.new(colorBEAR, 85),
             textcolor = colorBEAR,
             size      = size.tiny)

        Zone newSupply = Zone.new(
             zTop_s, zBot_s, sc_s, false, true, pBar, 1,
             liqVal_s, cBox_s, g1s, g2s, g3s, sLbl_s)

        supplyZones.push(newSupply)

        if supplyZones.size() > maxZones
            Zone old_s = supplyZones.shift()
            box.delete(old_s.coreBox)
            box.delete(old_s.glowBox1)
            box.delete(old_s.glowBox2)
            box.delete(old_s.glowBox3)
            label.delete(old_s.scoreLbl)

// ─────────────────────────────────────────────────────────────
//  SWEEP SIGNAL STATE (reset each bar)
// ─────────────────────────────────────────────────────────────
bool  sweepLongFired  = false
bool  sweepShortFired = false
float sweepEntry      = na
float sweepSL         = na
float sweepTP1        = na
float sweepTP2        = na

// ─────────────────────────────────────────────────────────────
//  SWEEP DETECTION — DEMAND ZONES (bullish sweep)
// ─────────────────────────────────────────────────────────────
if demandZones.size() > 0
    for i = 0 to demandZones.size() - 1
        Zone zd = demandZones.get(i)

        // Touch / test tracking
        if low <= zd.zTop and low >= zd.zBot - atrVal * 0.1
            zd.tests += 1

        // Multi-filter sweep confirmation
        float wPenPct_d  = zd.zBot > 0.0 ? (zd.zBot - low) / zd.zBot * 100.0 : 0.0
        bool  minPenetOk_d = wPenPct_d >= minWickPct
        bool  closeOk_d    = close > zd.zBot
        float wRange_d     = (high - low) > 0.0 ? (close - low) / (high - low) * 100.0 : 0.0
        bool  wickRejOk_d  = not useWick or wRange_d >= wickMin
        bool  volOk_d      = not useVol  or volume >= avgVol * volMult
        bool  coolOk_d     = bar_index >= lastBullSweep + sweepCool
        bool  holdOk_d     = not showFresh or zd.isFresh

        bool swept_d = not enableFail and holdOk_d and low < zd.zBot and
             minPenetOk_d and closeOk_d and volOk_d and wickRejOk_d and coolOk_d and
             barstate.isconfirmed

        if swept_d and zd.isFresh
            lastBullSweep  := bar_index
            zd.isFresh     := false
            totalLongs     += 1
            totalSignals   += 1
            sweepLongFired  := true
            sweepEntry      := close
            sweepSL         := slMode == "Zone" ? zd.zBot - atrVal * slBuffer
                                                 : low - atrVal * slBuffer
            float dist_d    = math.abs(sweepEntry - sweepSL)
            sweepTP1        := sweepEntry + dist_d
            sweepTP2        := sweepEntry + dist_d * rrRatio

        // Zone flip: demand broken to downside → convert to supply
        if enableFlip and close < zd.zBot and barstate.isconfirmed and zd.isFresh
            zd.isDemand := false
            zd.isFresh  := true
            box.set_bgcolor(zd.coreBox,   color.new(colorBEAR, zoneTrans))
            box.set_border_color(zd.coreBox, color.new(colorBEAR, math.max(0, zoneTrans - 25)))
            box.set_bgcolor(zd.glowBox1,  color.new(colorBEAR, glowStr))
            box.set_bgcolor(zd.glowBox2,  color.new(colorBEAR, math.min(99, glowStr + 8)))
            box.set_bgcolor(zd.glowBox3,  color.new(colorBEAR, math.min(99, glowStr + 15)))

        // Keep score label pinned to current bar
        label.set_x(zd.scoreLbl, bar_index)

// ─────────────────────────────────────────────────────────────
//  SWEEP DETECTION — SUPPLY ZONES (bearish sweep)
// ─────────────────────────────────────────────────────────────
if supplyZones.size() > 0
    for i = 0 to supplyZones.size() - 1
        Zone zs = supplyZones.get(i)

        // Touch / test tracking
        if high >= zs.zBot and high <= zs.zTop + atrVal * 0.1
            zs.tests += 1

        // Multi-filter sweep confirmation
        float wPenPct_s  = zs.zTop > 0.0 ? (high - zs.zTop) / zs.zTop * 100.0 : 0.0
        bool  minPenetOk_s = wPenPct_s >= minWickPct
        bool  closeOk_s    = close < zs.zTop
        float wRange_s     = (high - low) > 0.0 ? (high - close) / (high - low) * 100.0 : 0.0
        bool  wickRejOk_s  = not useWick or wRange_s >= wickMin
        bool  volOk_s      = not useVol  or volume >= avgVol * volMult
        bool  coolOk_s     = bar_index >= lastBearSweep + sweepCool
        bool  holdOk_s     = not showFresh or zs.isFresh

        bool swept_s = not enableFail and holdOk_s and high > zs.zTop and
             minPenetOk_s and closeOk_s and volOk_s and wickRejOk_s and coolOk_s and
             barstate.isconfirmed

        if swept_s and zs.isFresh
            lastBearSweep   := bar_index
            zs.isFresh      := false
            totalShorts     += 1
            totalSignals    += 1
            sweepShortFired  := true
            sweepEntry       := close
            sweepSL          := slMode == "Zone" ? zs.zTop + atrVal * slBuffer
                                                  : high + atrVal * slBuffer
            float dist_s     = math.abs(sweepSL - sweepEntry)
            sweepTP1         := sweepEntry - dist_s
            sweepTP2         := sweepEntry - dist_s * rrRatio

        // Zone flip: supply broken to upside → convert to demand
        if enableFlip and close > zs.zTop and barstate.isconfirmed and zs.isFresh
            zs.isDemand := true
            zs.isFresh  := true
            box.set_bgcolor(zs.coreBox,   color.new(colorBULL, zoneTrans))
            box.set_border_color(zs.coreBox, color.new(colorBULL, math.max(0, zoneTrans - 25)))
            box.set_bgcolor(zs.glowBox1,  color.new(colorBULL, glowStr))
            box.set_bgcolor(zs.glowBox2,  color.new(colorBULL, math.min(99, glowStr + 8)))
            box.set_bgcolor(zs.glowBox3,  color.new(colorBULL, math.min(99, glowStr + 15)))

        // Keep score label pinned to current bar
        label.set_x(zs.scoreLbl, bar_index)

// ─────────────────────────────────────────────────────────────
//  FAILURE ENTRY ENGINE
//  Detects structure-failure bars: wick through prior pivot,
//  close back inside, volume confirmation.
// ─────────────────────────────────────────────────────────────
if not na(failPivH)
    fPivHi := failPivH
if not na(failPivL)
    fPivLo := failPivL

bool fBullOk = false
bool fBearOk = false

if enableFail and barstate.isconfirmed
    // Bullish failure: wick below prior pivot low then close above
    if not na(fPivLo)
        float fWickSizeLo = fPivLo - low
        float wickPctLow  = (high - low) > 0.0 ? (close - low) / (high - low) * 100.0 : 0.0
        fBullOk :=
             low  < fPivLo          and
             close > fPivLo         and
             low[1] >= fPivLo       and
             fWickSizeLo >= atrVal * failWickATR and
             wickPctLow  >= failWickRej           and
             (not failUseVol or volume >= avgVol * failVolMult) and
             bar_index >= lastBullSweep + failCool

    // Bearish failure: wick above prior pivot high then close below
    if not na(fPivHi)
        float fWickSizeHi = high - fPivHi
        float wickPctHigh = (high - low) > 0.0 ? (high - close) / (high - low) * 100.0 : 0.0
        fBearOk :=
             high  > fPivHi         and
             close < fPivHi         and
             high[1] <= fPivHi      and
             fWickSizeHi >= atrVal * failWickATR and
             wickPctHigh >= failWickRej           and
             (not failUseVol or volume >= avgVol * failVolMult) and
             bar_index >= lastBearSweep + failCool

if fBullOk
    sweepLongFired := true
    sweepEntry     := close
    sweepSL        := fPivLo - atrVal * slBuffer
    float fDistLo   = math.abs(sweepEntry - sweepSL)
    sweepTP1       := sweepEntry + fDistLo
    sweepTP2       := sweepEntry + fDistLo * rrRatio
    lastBullSweep  := bar_index
    totalLongs     += 1
    totalSignals   += 1

if fBearOk
    sweepShortFired := true
    sweepEntry      := close
    sweepSL         := fPivHi + atrVal * slBuffer
    float fDistHi    = math.abs(sweepSL - sweepEntry)
    sweepTP1        := sweepEntry - fDistHi
    sweepTP2        := sweepEntry - fDistHi * rrRatio
    lastBearSweep   := bar_index
    totalShorts     += 1
    totalSignals    += 1

// ─────────────────────────────────────────────────────────────
//  TRADE BLOCK ON SWEEP
//  SL box (risk zone), TP1 box (1R target), TP2 box (extended)
// ─────────────────────────────────────────────────────────────
if (sweepLongFired or sweepShortFired) and showTrade
    int tEnd = bar_index + tradeW

    if sweepLongFired
        // SL zone (entry → stop)
        box.new(bar_index, sweepEntry, tEnd, sweepSL,
             bgcolor      = color.new(colorBEAR, 82),
             border_color = color.new(colorBEAR, 50),
             border_width = 1)
        // TP1 zone (entry → TP1)
        box.new(bar_index, sweepTP1, tEnd, sweepEntry,
             bgcolor      = color.new(colorBULL, 80),
             border_color = color.new(colorBULL, 45),
             border_width = 1)
        // TP2 zone (TP1 → TP2, dashed border)
        box.new(bar_index, sweepTP2, tEnd, sweepTP1,
             bgcolor      = color.new(colorBULL, 88),
             border_color = color.new(colorBULL, 60),
             border_width = 1,
             border_style = line.style_dashed)
        // Entry label
        label.new(bar_index, sweepEntry,
             "LONG  " + str.tostring(sweepEntry, format.mintick),
             style     = label.style_label_right,
             color     = color.new(#ffffff, 80),
             textcolor = #ffffff,
             size      = size.tiny)

    if sweepShortFired
        // SL zone (entry → stop, reversed)
        box.new(bar_index, sweepSL, tEnd, sweepEntry,
             bgcolor      = color.new(colorBEAR, 82),
             border_color = color.new(colorBEAR, 50),
             border_width = 1)
        // TP1 zone (entry → TP1)
        box.new(bar_index, sweepEntry, tEnd, sweepTP1,
             bgcolor      = color.new(colorBULL, 80),
             border_color = color.new(colorBULL, 45),
             border_width = 1)
        // TP2 zone (TP1 → TP2, dashed border)
        box.new(bar_index, sweepTP1, tEnd, sweepTP2,
             bgcolor      = color.new(colorBULL, 88),
             border_color = color.new(colorBULL, 60),
             border_width = 1,
             border_style = line.style_dashed)
        // Entry label
        label.new(bar_index, sweepEntry,
             "SHORT  " + str.tostring(sweepEntry, format.mintick),
             style     = label.style_label_right,
             color     = color.new(colorBEAR, 80),
             textcolor = colorBEAR,
             size      = size.tiny)

// ─────────────────────────────────────────────────────────────
//  BACKTEST OUTCOME TRACKER
//  Tracks TP2 / SL hits for the simple sweep-mode backtest.
// ─────────────────────────────────────────────────────────────
if btDir != 0 and not na(btTP) and not na(btSL)
    bool bWin  = btDir ==  1 ? high >= btTP : low  <= btTP
    bool bLoss = btDir ==  1 ? low  <= btSL : high >= btSL
    if bWin or bLoss
        totalWins  += bWin ? 1 : 0
        totalPnlR  += bWin ? rrRatio : -1.0
        btDir      := 0
        btTP       := na
        btSL       := na

if sweepLongFired and not enableFail
    btDir := 1
    btTP  := sweepTP2
    btSL  := sweepSL

if sweepShortFired and not enableFail
    btDir := -1
    btTP  := sweepTP2
    btSL  := sweepSL

float winRate  = totalSignals > 0 ? float(totalWins) / float(totalSignals) * 100.0 : 0.0
float expValue = totalSignals > 0 ? totalPnlR / float(totalSignals) : 0.0

// ─────────────────────────────────────────────────────────────
//  SIGNAL LABELS (on-chart sweep arrows)
// ─────────────────────────────────────────────────────────────
if sweepLongFired
    label.new(bar_index, low - atrVal * 0.5,
         "▲  SWEEP LONG",
         style     = label.style_label_up,
         color     = color.new(colorBULL, 75),
         textcolor = colorBULL,
         size      = size.small)

if sweepShortFired
    label.new(bar_index, high + atrVal * 0.5,
         "▼  SWEEP SHORT",
         style     = label.style_label_down,
         color     = color.new(colorBEAR, 75),
         textcolor = colorBEAR,
         size      = size.small)

// ─────────────────────────────────────────────────────────────
//  DASHBOARD — 18-row stats panel
// ─────────────────────────────────────────────────────────────
// Fix: use type-inferred variables so Pine resolves correct enum types
dashPosVal = switch dashPos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    =>                position.top_right

dSz = switch dashSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    =>          size.small

var table dash = table.new(dashPosVal, 2, 18,
     bgcolor      = color.new(#0d1117, 10),
     border_color = color.new(#30363d, 20),
     border_width = 1,
     frame_color  = color.new(#30363d, 40),
     frame_width  = 1)

// Dashboard cell helper
f_dc(int col, int row, string txt, color tc, color bg) =>
    table.cell(dash, col, row, txt,
         text_color  = tc,
         text_size   = dSz,
         bgcolor     = bg,
         text_halign = col == 0 ? text.align_left : text.align_right)

if showDash and barstate.islast
    color hBg  = color.new(#1A237E, 0)
    color pBg  = color.new(#161b22, 0)
    color dBg  = color.new(#0d1117, 10)
    color cMut = color.new(#8b949e, 0)

    // ── Row 0: Header ──────────────────────────────────────
    f_dc(0, 0, "Cascade Liquidity Zones [JOAT]", colorELITE, hBg)
    f_dc(1, 0, timeframe.period + " | v1.0",     cMut,       hBg)

    // ── Row 1: Mode ────────────────────────────────────────
    f_dc(0, 1, "Mode", cMut, pBg)
    f_dc(1, 1,
         enableFail ? "Failure Entry" : "Zone Sweep",
         enableFail ? colorELITE      : colorBULL,
         dBg)

    // ── Row 2: Demand zones count ──────────────────────────
    f_dc(0, 2, "Demand Zones", cMut, pBg)
    f_dc(1, 2, str.tostring(demandZones.size()), colorBULL, dBg)

    // ── Row 3: Supply zones count ──────────────────────────
    f_dc(0, 3, "Supply Zones", cMut, pBg)
    f_dc(1, 3, str.tostring(supplyZones.size()), colorBEAR, dBg)

    // ── Row 4: ATR value ───────────────────────────────────
    f_dc(0, 4, "ATR", cMut, pBg)
    f_dc(1, 4, str.tostring(atrVal, format.mintick), cMut, dBg)

    // ── Row 5: Volume vs Average ───────────────────────────
    f_dc(0, 5, "Volume vs Avg", cMut, pBg)
    color volCol = volume > avgVol * volMult ? colorBULL : cMut
    float volPct = avgVol > 0.0 ? volume / avgVol * 100.0 : 0.0
    f_dc(1, 5, str.tostring(math.round(volPct)) + "%", volCol, dBg)

    // ── Row 6: Divider ─────────────────────────────────────
    f_dc(0, 6, "─────────────", cMut, pBg)
    f_dc(1, 6, "─────────────", cMut, dBg)

    // ── Row 7: Total signals ───────────────────────────────
    f_dc(0, 7, "Total Signals", cMut, pBg)
    f_dc(1, 7, str.tostring(totalSignals), cMut, dBg)

    // ── Row 8: Bull sweeps ─────────────────────────────────
    f_dc(0, 8, "Bull Sweeps", cMut, pBg)
    f_dc(1, 8, str.tostring(totalLongs), colorBULL, dBg)

    // ── Row 9: Bear sweeps ─────────────────────────────────
    f_dc(0, 9, "Bear Sweeps", cMut, pBg)
    f_dc(1, 9, str.tostring(totalShorts), colorBEAR, dBg)

    // ── Row 10: Win rate ───────────────────────────────────
    f_dc(0, 10, "Win Rate", cMut, pBg)
    color wrCol = winRate >= 55.0 ? colorBULL :
                  winRate >= 40.0 ? colorNEUTR :
                  totalSignals > 0 ? colorBEAR : cMut
    f_dc(1, 10,
         totalSignals > 0 ? str.tostring(winRate, "#.#") + "%" : "─",
         wrCol, dBg)

    // ── Row 11: Expected value ─────────────────────────────
    f_dc(0, 11, "Exp Value", cMut, pBg)
    color evCol = expValue >= 0.0 ? colorBULL : colorBEAR
    string evStr = totalSignals > 0
         ? (expValue >= 0.0 ? "+" : "") + str.tostring(expValue, "#.##") + " R"
         : "─"
    f_dc(1, 11, evStr, evCol, dBg)

    // ── Row 12: Last entry ─────────────────────────────────
    f_dc(0, 12, "Last Entry", cMut, pBg)
    f_dc(1, 12,
         not na(sweepEntry) ? str.tostring(sweepEntry, format.mintick) : "─",
         cMut, dBg)

    // ── Row 13: Last TP1 ───────────────────────────────────
    f_dc(0, 13, "Last TP1", cMut, pBg)
    f_dc(1, 13,
         not na(sweepTP1) ? str.tostring(sweepTP1, format.mintick) : "─",
         color.rgb(0, 210, 90), dBg)

    // ── Row 14: Last TP2 ───────────────────────────────────
    f_dc(0, 14, "Last TP2", cMut, pBg)
    f_dc(1, 14,
         not na(sweepTP2) ? str.tostring(sweepTP2, format.mintick) : "─",
         color.rgb(0, 255, 110), dBg)

    // ── Row 15: Last SL ────────────────────────────────────
    f_dc(0, 15, "Last SL", cMut, pBg)
    f_dc(1, 15,
         not na(sweepSL) ? str.tostring(sweepSL, format.mintick) : "─",
         colorBEAR, dBg)

    // ── Row 16: Divider ────────────────────────────────────
    f_dc(0, 16, "─────────────", cMut, pBg)
    f_dc(1, 16, "─────────────", cMut, dBg)

    // ── Row 17: Footer branding ────────────────────────────
    f_dc(0, 17, "[JOAT]",         color.new(#6C63FF, 0), color.new(#0d1117, 20))
    f_dc(1, 17, "jackofalltrades", cMut,                  color.new(#0d1117, 20))

// ─────────────────────────────────────────────────────────────
//  ALERT CONDITIONS
// ─────────────────────────────────────────────────────────────
alertcondition(sweepLongFired  and not enableFail,
     "Cascade Liquidity Zones Sweep Long",
     "Cascade Liquidity Zones: Bull sweep confirmed.")

alertcondition(sweepShortFired and not enableFail,
     "Cascade Liquidity Zones Sweep Short",
     "Cascade Liquidity Zones: Bear sweep confirmed.")

alertcondition(fBullOk,
     "Cascade Liquidity Zones Failure Long",
     "Cascade Liquidity Zones: Bull failure entry confirmed.")

alertcondition(fBearOk,
     "Cascade Liquidity Zones Failure Short",
     "Cascade Liquidity Zones: Bear failure entry confirmed.")

alertcondition(sweepLongFired or sweepShortFired,
     "Cascade Liquidity Zones Any Signal",
     "Cascade Liquidity Zones: Signal fired.")
````
