# ICT FVG_IFVG Engine  3m Optimised

- url: https://www.tradingview.com/script/lvBgSY9G-ICT-FVG-IFVG-Engine-3m-Optimised/
- type: indicator
- pine_id: PUB;76aaaf85b7a84dfa8f024293b230c5d1
- version: 1.0

## Description

This indicator detects and tracks **Fair Value Gaps (FVGs)** and **Inversion Fair Value Gaps (IFVGs)** based on the Inner Circle Trader (ICT) methodology. It is built specifically around the **AM session (9:30–12:00 NY)** and **Silver Bullet windows (10:00–11:00 and 14:00–15:00 NY)**, firing real-time alerts when price returns to key entry levels.

The core signal is the **Consequent Encroachment (CE) tap** — price reaching the 50% midpoint (mean threshold) of a Fair Value Gap — which ICT teaches as the precision entry point within the gap. When this level is touched, the indicator fires a full alert with entry price, stop loss, take profit, R:R ratio, session tag, and quality tier.

---

## ICT Concepts Applied

**Fair Value Gap (FVG)**
A 3-candle price imbalance where the current bar's low is above the 2-bars-prior high (bullish) or the current bar's high is below the 2-bars-prior low (bearish). An optional ATR displacement filter ensures only gaps formed by real displacement candles are tracked.

**Consequent Encroachment (CE)**
The 50% midpoint of the FVG — also called the mean threshold. ICT teaches this as the primary entry reference within the gap, offering better risk-to-reward than entering at the gap edge.

**Inversion Fair Value Gap (IFVG)**
When price closes through the far edge of an FVG (a **body close**, not just a wick), the gap inverts its role — a bullish FVG becomes resistance, a bearish FVG becomes support. The next retest of the inverted zone is a trade in the new direction.

**First-Presented FVG (FPFVG)**
The first qualifying FVG of each session. ICT methodology emphasises this as the highest-quality setup of the session.

**Silver Bullet**
A specific ICT time window (10:00–11:00 AM and 2:00–3:00 PM New York time) within which the first FVG and its CE are considered premium setups.

**Liquidity Sweep (optional)**
A prerequisite where price raids a prior swing high or low (taking out resting orders) and then closes back inside the range before the displacement that creates the FVG. This forms the full ICT sequence: sweep → displacement → FVG → CE entry.

---

## Features

### Detection
- 3-candle FVG detection with configurable ATR displacement filter
- Optional liquidity sweep prerequisite (raid + rejection of prior swing)
- Tracks gaps until mitigated (full entry) or inverted (IFVG)
- Inversion confirmed by **candle body close** through the far edge — not a wick

### Session & Scope
- Configurable AM (default 9:30–12:00) and PM (1:30–4:00) session windows
- Silver Bullet windows: AM (10:00–11:00) and PM (2:00–3:00)
- Optional London Silver Bullet (3:00–4:00 AM NY)
- Three scope modes: All gaps | Session gaps only | First-presented + Silver Bullet

### Time-of-Day Quality Filter
Gaps are colour-coded by formation time based on historical win-rate data:

| Tier | Window | Visual |
|------|--------|--------|
| HIGH | 9:30–10:00 AM | Bright boxes |
| MED | 10:00–11:00 AM | Normal boxes (Silver Bullet) |
| LOW | 11:00 AM–12:00 PM | Dimmed boxes |

LOW-quality alerts and R:R zones are suppressed by default to reduce noise.

### Two-Tier Alert System
Every CE tap fires a rich alert message containing:
- Priority tier (`*** PRIORITY` for first-presented/SB, `SETUP` for others)
- Quality tier (`HIGH`, `MED`, or `LOW`)
- Ticker and timeframe
- Trade direction (`LONG` or `SHORT`)
- Exact CE entry level
- Stop loss level
- Take profit level
- R:R ratio
- Session tag (e.g. `1st AM`, `SB-AM`, `AM`)
- Current price

**Example alert message:**
```
*** PRIORITY [HIGH] | NQ 3 | LONG | CE 21245.00 | SL 21235.00 | TP 21275.00 | 1:3.0 | [1st AM] | px 21246.25
```

### R:R Zones
When a CE tap occurs, the indicator automatically draws:
- **Yellow dashed line** — Entry at CE
- **Red solid line** — Stop loss level with label
- **Green solid line** — Take profit level with label
- **Green fill zone** — CE to TP visual
- **Red fill zone** — CE to SL visual

Default levels are set to the backtest-optimised values for the 3-minute NQ chart (10-point stop / 30-point target). These are fully configurable.

### Dashboard (top-right table)
- Live session status for AM, PM, Silver Bullet AM/PM/London
- Time-quality tier indicator with win-rate reference per bucket
- Daily CE signal counter vs cap
- Current R:R settings reminder

---

## How to Use

**Step 1 — Add to chart**
Paste into Pine Editor, Save, then click *Add to chart*. The indicator works as an overlay on any symbol and timeframe.

**Step 2 — Choose your scope**
In *Settings → Scope*, select:
- **"In configured sessions only"** to track all AM/PM FVGs (more signals)
- **"First-presented + Silver Bullet"** for highest-quality only (fewer signals)

**Step 3 — Set your R:R levels**
In *Settings → R:R Levels*, enter your stop loss and take profit in points. Defaults are 10pt stop / 30pt TP — calibrated for the 3-minute NQ futures chart.

**Step 4 — Create alerts**
1. Right-click the chart → *Add alert*
2. Condition = this indicator → select one of:
   - **"*** PRIORITY CE tap"** — First-presented and Silver Bullet gaps only
   - **"SETUP CE tap"** — All other session gaps
   - **"Any CE tap"** — Catch-all for both tiers
   - **"Any ICT signal"** — Includes inversions and IFVG retests
3. Set trigger to *Once Per Bar Close* to match closed-bar detection and avoid repaint

**Step 5 — Read the chart**
- **Bright boxes** = HIGH quality (9:30–10:00 AM) — best setups
- **Normal boxes** = MED quality (Silver Bullet window)
- **Dimmed boxes** = LOW quality (11:00 AM+) — alerts suppressed by default
- **Yellow border** = First-presented FVG of the session
- **Orange box** = FVG has inverted → now an IFVG — trade the opposite direction
- **Green/Red zones** = R:R levels drawn at moment of CE tap

---

## Settings Reference

| Group | Setting | Description |
|-------|---------|-------------|
| Detection | ATR filter | Minimum gap size relative to ATR14 — filters out small gaps |
| Detection | Closed bars only | Prevents repainting — recommended ON |
| Liquidity Sweep | Require sweep | Makes the full ICT sequence mandatory before a gap qualifies |
| Scope | Which gaps to track | Controls how many gaps are tracked and drawn |
| Sessions | AM / PM / SB times | All configurable in NY time. DST is handled automatically |
| Quality Filter | Enable quality tiers | Colour-codes gaps by time-of-day win rate |
| Quality Filter | Suppress LOW alerts | Prevents alerts after 11:00 AM when win rates drop |
| Alerts | PRIORITY / SETUP | Toggle each alert tier independently |
| Alerts | Max CE per day | Daily signal cap — default 4, matching recommended session limit |
| R:R Levels | Stop / TP points | Draws SL and TP lines and fill zones on every CE tap |

---

## Alert Setup for Mobile Notifications

To receive push notifications to the TradingView mobile app:
1. Create the alert as above
2. Under *Notifications*, enable **App notification**
3. Set trigger to *Once Per Bar Close*

For webhook/automation, the alert message is structured for easy parsing:
- Fields are `|`-separated
- Entry, SL, and TP are explicit price levels (not offsets)

---

## Notes & Disclaimers

- **Timeframe:** The indicator works on all timeframes. Default settings (10pt SL / 30pt TP) are calibrated for the **3-minute NQ futures chart** based on internal backtesting over 60 days of data. Adjust stop and target values to match your instrument's volatility and your preferred timeframe.

- **Repaint:** With *"Detect on closed bars only"* enabled (default), all signals are based on confirmed closed candles. Disabling this option allows earlier intrabar detection but will repaint before the bar closes.

- **Inversion logic:** Inversion is confirmed by a candle **body close** through the far edge of the gap, per ICT teaching. A wick alone does not qualify.

- **No financial advice:** This indicator is a technical analysis tool. All signals are for informational purposes only. Past performance of any pattern or level does not guarantee future results. Always use appropriate risk management and conduct your own analysis before entering any trade.

- **ICT methodology:** Fair Value Gaps, Silver Bullet, Consequent Encroachment, and related terminology are concepts taught by the Inner Circle Trader (ICT). This indicator is an independent technical implementation and is not affiliated with, endorsed by, or produced by ICT.

---

*Built with Pine Script v6.*

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © srt298

//@version=6
// ============================================================================
//  ICT FVG / IFVG Engine  v4  —  3m-Optimised + Time-Quality Filter
//
//  BACKTEST-VALIDATED DEFAULTS (NQ, 3m, 60 days):
//    All AM FVGs  |  10pt SL / 30pt TP (1:3)  |  3 contracts
//    → 100% Monte Carlo hit rate on $9k / 10-day target
//    → $17,100 median 10-day P&L  |  Max DD 95th pct: $3,600
//
//  TIME-OF-DAY QUALITY TIERS  (win rate by bucket):
//    HIGH  9:30–10:00  →  59–67% WR  (bright teal/red boxes)
//    MED   10:00–11:00 →  47–71% WR  (normal colour, Silver Bullet window)
//    LOW   11:00–12:00 →  0–33%  WR  (dimmed, optional suppress)
//
//  TWO-TIER ALERTS:
//    PRIORITY — First-presented / Silver Bullet gaps
//    SETUP    — All other session gaps
//    Both include: SL, TP, R:R, quality tier, session tag
// ============================================================================
indicator("ICT FVG / IFVG Engine — 3m Optimised", shorttitle="ICT CE v4",
          overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ======================= INPUTS =============================================
gD = "1 · Detection"
useDisp     = input.bool(true,  "Require displacement (ATR filter)", group=gD)
dispMult    = input.float(0.25, "Min gap size (× ATR14)", minval=0.0, step=0.05, group=gD)
confirmOnly = input.bool(true,  "Detect on closed bars only", group=gD)
maxKeep     = input.int(60,     "Max gaps to track", minval=5, maxval=300, group=gD)

gSweep = "1b · Liquidity Sweep"
useSweep    = input.bool(false, "Require liquidity sweep before FVG", group=gSweep)
pivLen      = input.int(5,      "Swing pivot length", minval=1, group=gSweep)
sweepWindow = input.int(8,      "Sweep within N bars", minval=1, group=gSweep)
markSweep   = input.bool(true,  "Mark swept level", group=gSweep)

gScope = "2 · Scope"
scopeMode = input.string("In configured sessions only", "Which gaps to track",
              options=["All gaps","In configured sessions only","First-presented + Silver Bullet"],
              group=gScope,
              tooltip="'In configured sessions only' = ALL FVGs in AM/PM/SB windows. Backtest shows this is the highest-probability mode.")
tz = input.string("America/New_York", "Timezone", group=gScope)

gSess = "3 · Sessions (NY time)"
amSess  = input.session("0930-1200", "AM session",           group=gSess)
pmSess  = input.session("1330-1600", "PM session",           group=gSess)
sbAm    = input.session("1000-1100", "Silver Bullet — AM",   group=gSess)
sbPm    = input.session("1400-1500", "Silver Bullet — PM",   group=gSess)
useLnSB = input.bool(false,          "London Silver Bullet", group=gSess)
sbLn    = input.session("0300-0400", "Silver Bullet — LN",   group=gSess)

gQual = "4 · Time-of-Day Quality Filter"
useQualFilter   = input.bool(true,  "Enable quality tiers", group=gQual,
                    tooltip="Colours gaps by time-of-day win rate. HIGH (9:30-10am) = brightest. MED (10-11am) = normal. LOW (11am+) = dimmed.")
highEnd         = input.int(600,    "HIGH tier ends  (NY min, default 10:00 = 600)", minval=570, maxval=720, group=gQual)
medEnd          = input.int(660,    "MED tier ends   (NY min, default 11:00 = 660)", minval=570, maxval=720, group=gQual,
                    tooltip="Gaps after this time are LOW quality. Default 660 = 11:00 AM.")
suppressLow     = input.bool(true,  "Suppress CE alerts on LOW quality gaps", group=gQual,
                    tooltip="ON = no alert fires for gaps formed after 11am. Keeps signal quality high.")
suppressRRlow   = input.bool(true,  "Skip R:R zones on LOW quality gaps", group=gQual)

gAlert = "5 · Alerts"
alertCEpriority = input.bool(true,  "PRIORITY alert: CE on 1st-presented / SB gaps", group=gAlert)
alertCEall      = input.bool(true,  "SETUP alert: CE on all other session gaps",      group=gAlert)
alertRetest     = input.bool(false, "Alert: FVG retest",                              group=gAlert)
alertInv        = input.bool(true,  "Alert: FVG inversion (IFVG forms)",              group=gAlert)
alertInvRetest  = input.bool(true,  "Alert: IFVG retest",                             group=gAlert)
maxDailyAlerts  = input.int(4,      "Max CE alerts per day (0 = unlimited)", minval=0, maxval=20, group=gAlert)

gRR = "5b · R:R Levels  [3m optimal: 10pt SL / 30pt TP]"
showRR        = input.bool(true,   "Draw SL / TP zones on CE tap",              group=gRR)
rrStopPts     = input.float(10.0,  "Stop loss (points)",  minval=1.0, step=1.0, group=gRR,
                  tooltip="Backtest optimal for 3m: 10pt. For 1m: 12pt. For 5m: 15pt.")
rrTpPts       = input.float(30.0,  "Take profit (points)", minval=1.0, step=1.0, group=gRR,
                  tooltip="Backtest optimal for 3m: 30pt (1:3 R:R = 100% Monte Carlo hit rate).")
rrPriorityOnly = input.bool(false, "Only on PRIORITY / MED+ quality gaps",      group=gRR)
rrExtend      = input.int(50,      "Extend N bars", minval=5, maxval=200,        group=gRR)
colSL         = input.color(color.new(color.red,   0), "SL",    group=gRR, inline="rr")
colTP         = input.color(color.new(color.lime,  0), "TP",    group=gRR, inline="rr")
colEntry      = input.color(color.new(color.yellow,0), "Entry", group=gRR, inline="rr")

gStyle = "6 · Style"
showBoxes   = input.bool(true, "Draw gap boxes",     group=gStyle)
showCE      = input.bool(true, "Draw CE (50%) line", group=gStyle)
showLabels  = input.bool(true, "Draw markers",       group=gStyle)
markerShape = input.string("Triangle", "Marker shape",
                options=["Triangle","Arrow","Circle","Diamond","Label (box)","None"], group=gStyle)
markerSize  = input.string("Tiny", "Marker size", options=["Tiny","Small","Normal"], group=gStyle)
markerText  = input.string("None (hover tooltip)", "Marker text",
                options=["Full","Compact","None (hover tooltip)"], group=gStyle)
labelScope  = input.string("All tracked", "Which gaps get a marker",
                options=["All tracked","First-presented only"], group=gStyle)
showTable   = input.bool(true, "Show dashboard", group=gStyle)
// Quality colours
colHigh   = input.color(color.new(color.teal,   65), "HIGH quality box",   group=gStyle, inline="q")
colMed    = input.color(color.new(color.teal,   80), "MED quality box",    group=gStyle, inline="q")
colLow    = input.color(color.new(color.teal,   92), "LOW quality box",    group=gStyle, inline="q")
colHighB  = input.color(color.new(color.red,    65), "HIGH bear box",      group=gStyle, inline="q2")
colMedB   = input.color(color.new(color.red,    80), "MED bear box",       group=gStyle, inline="q2")
colLowB   = input.color(color.new(color.red,    92), "LOW bear box",       group=gStyle, inline="q2")
colInv    = input.color(color.new(color.orange, 75), "IFVG",               group=gStyle, inline="q3")
colFirst  = input.color(color.yellow,               "1st-presented border",group=gStyle, inline="q3")

// ======================= TYPE ===============================================
type FVG
    float  top
    float  bottom
    float  ce
    int    dir          // 1=bull -1=bear (original)
    int    startBar
    int    invBar
    bool   inverted
    bool   isFirst
    string tag
    int    quality      // 3=HIGH 2=MED 1=LOW
    bool   retestDone
    bool   ceDone
    bool   invDone
    bool   invRetestDone
    bool   mitigated
    box    bx
    line   ceLn
    label  lb

// ======================= STATE ==============================================
var array<FVG> fvgs = array.new<FVG>()
var bool amFirst  = false
var bool pmFirst  = false
var bool sbaFirst = false
var bool sbpFirst = false
var bool sblFirst = false

var int dailyCEcount = 0
var int dailyCEday   = 0

atr = ta.atr(14)

// ---- liquidity sweep ----
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low,  pivLen, pivLen)
var float lastSH = na
var float lastSL = na
if not na(ph)
    lastSH := ph
if not na(pl)
    lastSL := pl
var int   lastBuySweepBar  = na
var int   lastSellSweepBar = na
var float lastBuySweepLvl  = na
var float lastSellSweepLvl = na
bool sellSweep = not na(lastSL) and low  < lastSL and close > lastSL
bool buySweep  = not na(lastSH) and high > lastSH and close < lastSH
if sellSweep
    lastSellSweepBar := bar_index
    lastSellSweepLvl := lastSL
if buySweep
    lastBuySweepBar  := bar_index
    lastBuySweepLvl  := lastSH

// ---- sessions ----
f_in(simple string s) => not na(time(timeframe.period, s, tz))
inAM     = f_in(amSess)
inPM     = f_in(pmSess)
inSBa    = f_in(sbAm)
inSBp    = f_in(sbPm)
inSBl    = useLnSB and f_in(sbLn)
inAnyCfg = inAM or inPM or inSBa or inSBp or inSBl

if inAM  and not inAM[1]
    amFirst  := false
if inPM  and not inPM[1]
    pmFirst  := false
if inSBa and not inSBa[1]
    sbaFirst := false
if inSBp and not inSBp[1]
    sbpFirst := false
if inSBl and not inSBl[1]
    sblFirst := false

// daily CE counter reset
curDay = dayofmonth(time("D","0000-0000",tz))
if curDay != dailyCEday
    dailyCEday   := curDay
    dailyCEcount := 0

// ---- current bar time-of-day in NY minutes ----
barNYmin = hour(time, tz) * 60 + minute(time, tz)

// ======================= HELPERS ============================================
f_del(FVG f) => box.delete(f.bx), line.delete(f.ceLn), label.delete(f.lb)

f_qualLabel(int q) =>
    q == 3 ? "HIGH" : q == 2 ? "MED" : "LOW"

f_qualColor(int q, bool bull) =>
    if bull
        q == 3 ? colHigh : q == 2 ? colMed : colLow
    else
        q == 3 ? colHighB : q == 2 ? colMedB : colLowB

// Full alert message with SL, TP, quality
f_ceMsg(string tier, FVG f) =>
    sl = f.dir == 1 ? f.ce - rrStopPts : f.ce + rrStopPts
    tp = f.dir == 1 ? f.ce + rrTpPts   : f.ce - rrTpPts
    tier
      + " [" + f_qualLabel(f.quality) + "]"
      + " | " + syminfo.ticker + " " + timeframe.period
      + " | " + (f.dir == 1 ? "LONG" : "SHORT")
      + " | CE "  + str.tostring(f.ce, format.mintick)
      + " | SL "  + str.tostring(sl,   format.mintick)
      + " | TP "  + str.tostring(tp,   format.mintick)
      + " | 1:"   + str.tostring(rrTpPts / rrStopPts, "#.#")
      + (f.tag != "" ? " [" + f.tag + "]" : "")
      + " | px "  + str.tostring(close, format.mintick)

f_msg(string kind, FVG f, int td, float lvl) =>
    kind + " | " + syminfo.ticker + " " + timeframe.period
      + " | " + (td == 1 ? "LONG" : "SHORT")
      + (f.inverted ? " (IFVG)" : " (FVG)")
      + " [" + f_qualLabel(f.quality) + "]"
      + (f.tag != "" ? " [" + f.tag + "]" : "")
      + " | " + str.tostring(lvl, format.mintick)
      + " | px " + str.tostring(close, format.mintick)

// marker helpers
f_mkSize() => markerSize == "Tiny" ? size.tiny : markerSize == "Small" ? size.small : size.normal

f_mkStyle(bool up) =>
    switch markerShape
        "Triangle"    => up ? label.style_triangleup  : label.style_triangledown
        "Arrow"       => up ? label.style_arrowup     : label.style_arrowdown
        "Circle"      => label.style_circle
        "Diamond"     => label.style_diamond
        "Label (box)" => up ? label.style_label_up    : label.style_label_down
        => label.style_none

f_mkText(string core, string tag, int q) =>
    qstr = useQualFilter ? " " + f_qualLabel(q) : ""
    switch markerText
        "Full"    => core + qstr + (tag != "" ? " " + tag : "")
        "Compact" => core + qstr
        => ""

// signal flags
bool sigCEpriority = false
bool sigCEsetup    = false
bool sigRetest     = false
bool sigInv        = false
bool sigInvRetest  = false

// ======================= DETECTION ==========================================
born = confirmOnly ? barstate.isconfirmed : true
bull = born and low  > high[2]
bear = born and high < low[2]

if bull or bear
    float top    = bull ? low      : low[2]
    float bottom = bull ? high[2]  : high
    float gap    = top - bottom
    bool  pass   = (not useDisp) or (not na(atr) and gap >= atr * dispMult)

    bool sweptSellRecent = not na(lastSellSweepBar) and (bar_index - lastSellSweepBar) <= sweepWindow
    bool sweptBuyRecent  = not na(lastBuySweepBar)  and (bar_index - lastBuySweepBar)  <= sweepWindow
    bool hadSweep  = bull ? sweptSellRecent : sweptBuyRecent
    bool passSweep = (not useSweep) or hadSweep

    if pass and passSweep and gap > 0
        // first-presented tagging
        parts = array.new_string()
        if inAM  and not amFirst
            array.push(parts,"1st AM")
            amFirst  := true
        if inPM  and not pmFirst
            array.push(parts,"1st PM")
            pmFirst  := true
        if inSBa and not sbaFirst
            array.push(parts,"1st SB-AM")
            sbaFirst := true
        if inSBp and not sbpFirst
            array.push(parts,"1st SB-PM")
            sbpFirst := true
        if inSBl and not sblFirst
            array.push(parts,"1st SB-LN")
            sblFirst := true
        bool   isFirst = array.size(parts) > 0
        string fTag    = isFirst ? array.join(parts,"/")
                       : (inSBa?"SB-AM":inSBp?"SB-PM":inSBl?"SB-LN":inAM?"AM":inPM?"PM":"")
        if hadSweep
            fTag := fTag + (fTag != "" ? " " : "") + "swept"

        // quality tier from formation time
        int qual = useQualFilter
                   ? (barNYmin < highEnd ? 3 : barNYmin < medEnd ? 2 : 1)
                   : 2   // default MED when filter off

        // scope filter
        bool keep = switch scopeMode
            "All gaps"                        => true
            "In configured sessions only"     => inAnyCfg
            "First-presented + Silver Bullet" => isFirst or inSBa or inSBp or inSBl
            => true

        if keep
            int   d   = bull ? 1 : -1
            float ce  = (top + bottom) / 2.0
            color col = f_qualColor(qual, bull)
            int   bdrW = isFirst ? 2 : 1
            color bdr  = isFirst ? colFirst : color.new(col, 40)

            bx   = showBoxes ? box.new(bar_index-2, top, bar_index, bottom,
                                 border_color=bdr, border_width=bdrW, bgcolor=col) : na
            ceLn = showCE    ? line.new(bar_index-2, ce, bar_index, ce,
                                 color=color.new(color.gray,30), style=line.style_dashed) : na

            bool   drawLbl = showLabels and markerShape != "None" and
                             (labelScope == "All tracked" or isFirst)
            string ttip    = (bull?"Bull":"Bear") + " FVG | " + f_qualLabel(qual)
                           + (fTag != "" ? " | " + fTag : "")
                           + " | CE " + str.tostring(ce, format.mintick)
            lb = drawLbl ? label.new(bar_index-1, bull?bottom:top,
                             f_mkText("FVG", fTag, qual), style=f_mkStyle(bull),
                             color=col, textcolor=color.white,
                             size=f_mkSize(), tooltip=ttip) : na

            if markSweep and hadSweep
                float swLvl = bull ? lastSellSweepLvl : lastBuySweepLvl
                int   swBar = bull ? lastSellSweepBar  : lastBuySweepBar
                line.new(swBar, swLvl, bar_index, swLvl,
                         color=color.new(color.fuchsia,0), style=line.style_dotted)
                label.new(swBar, swLvl, "liq",
                          style=bull?label.style_label_down:label.style_label_up,
                          color=color.new(color.fuchsia,30),
                          textcolor=color.white, size=size.tiny)

            array.push(fvgs, FVG.new(top,bottom,ce,d,bar_index,na,false,isFirst,
                                     fTag,qual,false,false,false,false,false,bx,ceLn,lb))
            if array.size(fvgs) > maxKeep
                f_del(array.shift(fvgs))

// ======================= MAINTENANCE ========================================
if array.size(fvgs) > 0
    for i = 0 to array.size(fvgs) - 1
        FVG f = array.get(fvgs, i)
        bool after      = bar_index > f.startBar
        bool overlap    = high >= f.bottom and low <= f.top
        bool isPriority = f.isFirst or str.contains(f.tag, "SB")
        bool isLow      = f.quality == 1

        // extend boxes
        if showBoxes and not na(f.bx) and not f.inverted
            box.set_right(f.bx, bar_index)
            if showCE and not na(f.ceLn)
                line.set_x2(f.ceLn, bar_index)

        if after
            // ---- INVERSION ----
            if not f.inverted
                bool inv = f.dir == 1 ? close < f.bottom : close > f.top
                if inv
                    f.inverted := true
                    f.invBar   := bar_index
                    if showBoxes and not na(f.bx)
                        box.set_bgcolor(f.bx, colInv)
                        box.set_border_color(f.bx, color.new(color.orange, 0))
                    if not na(f.lb)
                        label.set_text(f.lb, f_mkText("IFVG", f.tag, f.quality))
                        label.set_style(f.lb, f_mkStyle(f.dir == -1))
                        label.set_color(f.lb, color.new(color.orange, 10))
                    if alertInv and not (suppressLow and isLow)
                        sigInv := true
                        alert(f_msg("INVERSION", f, -f.dir, f.dir == 1 ? f.bottom : f.top), alert.freq_once_per_bar)

            // ---- FVG RETEST ----
            if not f.inverted and not f.retestDone and overlap
                f.retestDone := true
                if alertRetest and not (suppressLow and isLow)
                    sigRetest := true
                    alert(f_msg("FVG RETEST", f, f.dir, f.ce), alert.freq_once_per_bar)

            // ---- CE TAP ----
            if not f.inverted and not f.ceDone and low <= f.ce and high >= f.ce
                f.ceDone := true
                bool underCap  = maxDailyAlerts == 0 or dailyCEcount < maxDailyAlerts
                bool qualOK    = not suppressLow or not isLow

                if underCap and qualOK
                    if alertCEpriority and isPriority
                        sigCEpriority := true
                        alert(f_ceMsg("*** PRIORITY", f), alert.freq_once_per_bar)
                        dailyCEcount += 1
                    if alertCEall and not isPriority
                        sigCEsetup := true
                        alert(f_ceMsg("SETUP", f), alert.freq_once_per_bar)
                        dailyCEcount += 1

                // R:R zone
                bool rrDraw = showRR and not (suppressRRlow and isLow) and (not rrPriorityOnly or isPriority or f.quality >= 2)
                if rrDraw
                    float sl  = f.dir == 1 ? f.ce - rrStopPts : f.ce + rrStopPts
                    float tp  = f.dir == 1 ? f.ce + rrTpPts   : f.ce - rrTpPts
                    int   x2  = bar_index + rrExtend
                    string pfx = isPriority ? "* " : f.quality == 2 ? "" : "(low) "
                    // Entry
                    line.new(bar_index, f.ce, x2, f.ce, color=colEntry, style=line.style_dashed, width=1)
                    label.new(x2, f.ce, pfx + "CE " + str.tostring(f.ce, format.mintick),
                              style=label.style_label_left, color=color.new(colEntry,20),
                              textcolor=color.white, size=size.tiny)
                    // SL
                    line.new(bar_index, sl, x2, sl, color=colSL, style=line.style_solid, width=1)
                    label.new(x2, sl, "SL " + str.tostring(sl, format.mintick),
                              style=label.style_label_left, color=color.new(colSL,20),
                              textcolor=color.white, size=size.tiny)
                    // TP
                    line.new(bar_index, tp, x2, tp, color=colTP, style=line.style_solid, width=1)
                    label.new(x2, tp, "TP " + str.tostring(tp, format.mintick),
                              style=label.style_label_left, color=color.new(colTP,20),
                              textcolor=color.white, size=size.tiny)
                    // Fill zones
                    box.new(bar_index, tp,    x2, f.ce, border_color=color.new(colTP,60), bgcolor=color.new(colTP,92))
                    box.new(bar_index, f.ce,  x2, sl,   border_color=color.new(colSL,60), bgcolor=color.new(colSL,92))

            // ---- IFVG RETEST ----
            if f.inverted and not f.invRetestDone and bar_index > f.invBar and overlap
                f.invRetestDone := true
                int td = -f.dir
                if alertInvRetest and not (suppressLow and isLow)
                    sigInvRetest := true
                    alert(f_msg("IFVG RETEST", f, td, f.ce), alert.freq_once_per_bar)

        array.set(fvgs, i, f)

// ======================= ALERTCONDITIONS ====================================
alertcondition(sigCEpriority, "*** PRIORITY CE tap",  "PRIORITY CE — 1st FVG or Silver Bullet")
alertcondition(sigCEsetup,    "SETUP CE tap",          "SETUP CE — qualifying session FVG")
alertcondition(sigCEpriority or sigCEsetup, "Any CE tap",  "CE tap signal fired")
alertcondition(sigRetest,     "FVG retest",            "FVG retest entry zone")
alertcondition(sigInv,        "FVG inversion (IFVG)",  "FVG inverted — IFVG formed")
alertcondition(sigInvRetest,  "IFVG retest",           "IFVG retest — flipped entry")
alertcondition(sigCEpriority or sigCEsetup or sigInv or sigInvRetest, "Any ICT signal", "ICT signal")

// ======================= DASHBOARD ==========================================
var table dash = table.new(position.top_right, 3, 11, border_width=1,
                            frame_color=color.new(color.gray,50), frame_width=1)

f_drow(int r, string k, string v, color vc) =>
    table.cell(dash, 0, r, k,  text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray,80))
    table.cell(dash, 1, r, v,  text_color=vc,          text_size=size.small, bgcolor=color.new(color.gray,85))

f_qrow(int r, string k, string v, color vc, string q, color qc) =>
    table.cell(dash, 0, r, k,  text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray,80))
    table.cell(dash, 1, r, v,  text_color=vc,          text_size=size.small, bgcolor=color.new(color.gray,85))
    table.cell(dash, 2, r, q,  text_color=qc,          text_size=size.small, bgcolor=color.new(color.gray,85))

if showTable and barstate.islast
    // Header
    table.cell(dash, 0, 0, "ICT CE v4",    text_color=color.yellow, text_size=size.small, bgcolor=color.new(color.black,30))
    table.cell(dash, 1, 0, "Status",       text_color=color.yellow, text_size=size.small, bgcolor=color.new(color.black,30))
    table.cell(dash, 2, 0, "Quality",      text_color=color.yellow, text_size=size.small, bgcolor=color.new(color.black,30))

    // Current time quality
    curQ    = useQualFilter ? (barNYmin < highEnd ? 3 : barNYmin < medEnd ? 2 : 1) : 2
    curQlbl = curQ == 3 ? "HIGH" : curQ == 2 ? "MED" : "LOW"
    curQcol = curQ == 3 ? color.lime : curQ == 2 ? color.yellow : color.red

    // Sessions
    f_qrow(1, "AM", inAM ? "LIVE" : amFirst ? "1st FVG found" : "—",
           inAM ? color.lime : amFirst ? color.teal : color.silver,
           inAM ? curQlbl : "—", inAM ? curQcol : color.silver)
    f_qrow(2, "PM", inPM ? "LIVE" : pmFirst ? "1st FVG found" : "—",
           inPM ? color.lime : pmFirst ? color.teal : color.silver,
           inPM ? curQlbl : "—", inPM ? curQcol : color.silver)
    f_qrow(3, "SB AM", inSBa ? "LIVE" : sbaFirst ? "1st found" : "—",
           inSBa ? color.lime : sbaFirst ? color.teal : color.silver,
           inSBa ? "MED" : "—", color.yellow)
    f_qrow(4, "SB PM", inSBp ? "LIVE" : sbpFirst ? "1st found" : "—",
           inSBp ? color.lime : sbpFirst ? color.teal : color.silver,
           inSBp ? "MED" : "—", color.yellow)
    f_qrow(5, "SB LN", inSBl ? "LIVE" : sblFirst ? "1st found" : "—",
           inSBl ? color.lime : sblFirst ? color.teal : color.silver,
           inSBl ? "MED" : "—", color.yellow)

    // Quality legend
    f_drow(6, "9:30-10:00", "HIGH  59-67% WR", color.lime)
    f_drow(7, "10:00-11:00","MED   47-71% WR", color.yellow)
    f_drow(8, "11:00-12:00","LOW   0-33%  WR", color.red)

    // CE counter
    capStr  = maxDailyAlerts > 0 ? "/" + str.tostring(maxDailyAlerts) : " (no cap)"
    ceColor = dailyCEcount >= maxDailyAlerts and maxDailyAlerts > 0 ? color.red
             : dailyCEcount > 0 ? color.lime : color.silver
    f_drow(9, "CE today", str.tostring(dailyCEcount) + capStr, ceColor)

    // R:R reminder
    f_drow(10, "R:R", str.tostring(rrStopPts,"#") + "pt SL / " + str.tostring(rrTpPts,"#") + "pt TP  (1:" + str.tostring(rrTpPts/rrStopPts,"#.#") + ")", color.yellow)
````
