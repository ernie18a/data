# Daily Opening Range For Scalping

- url: https://www.tradingview.com/script/Lw8wOc2o-Daily-Opening-Range-For-Scalping/
- type: indicator
- pine_id: PUB;8ad2393ded6f421ab5c73cd01fde02cd
- version: 1.0

## Description

[image]https://www.tradingview.com/x/4VotS55W/[/image]

# Daily Scalping Key Levels — PDH/PDL, DBYH/DBYL, PMH/PML, ORH/ORL & Daily ATR

## Overview

This indicator is designed for **intraday traders and scalpers** who want important market reference levels automatically plotted on their chart.

Instead of manually marking previous highs/lows, pre-market levels, the opening range, and daily ATR targets, the indicator calculates and displays these levels for the current trading session.

The goal is to provide a clean intraday map showing areas where price may encounter **support, resistance, liquidity, breakouts, rejection, or increased trading activity**.

The indicator includes:

- 🔵 **PDH / PDL — Previous Day High & Low**
- 🩷 **DBYH / DBYL — Day Before Yesterday High & Low**
- 🟠 **PMH / PML — Pre-Market High & Low**
- 🟢 **ORH / ORL — Opening Range High & Low**
- 🟣 **Open + ATR / Open − ATR — Daily ATR Extension Levels**

---

## 🔵 PDH / PDL — Previous Day High & Low

**PDH = Previous Day High**  
**PDL = Previous Day Low**

These blue lines represent the highest and lowest prices reached during the **previous completed regular trading session (RTH)**.

The indicator uses the regular New York session:

**9:30 AM – 4:00 PM ET**

These are important intraday reference levels because the previous day's extremes are often watched by day traders.

### Common ways traders monitor PDH/PDL

Price approaching these levels may produce:

**Breakout:**  
Price moves through PDH or PDL and continues in that direction.

**Rejection:**  
Price tests the level but fails to hold beyond it and reverses.

**Support/Resistance:**  
A previous high may act as resistance, while a previous low may act as support.

**Liquidity Area:**  
Previous session highs and lows can attract trading activity because stops and breakout orders may be clustered around these areas.

PDH/PDL should generally be treated as **areas of interest rather than automatic entry signals**.

---

## 🩷 DBYH / DBYL — Day Before Yesterday High & Low

**DBYH = Day Before Yesterday High**  
**DBYL = Day Before Yesterday Low**

The pink lines represent the regular-session high and low from **two completed trading sessions ago**.

For example:

If today is Tuesday:

**PDH/PDL = Monday's RTH High/Low**  
**DBYH/DBYL = Friday's RTH High/Low**

The indicator tracks completed trading sessions rather than simply subtracting calendar days, making these levels more useful around weekends.

### Why keep the second previous session?

Sometimes the prior day's range is relatively narrow or price quickly moves outside it. The high and low from two sessions ago can remain relevant as another historical reference area.

DBYH/DBYL can be useful for identifying:

- Older support/resistance
- Potential breakout areas
- Liquidity around prior swing extremes
- Rejection zones
- Price targets when PDH/PDL have already been broken

When PDH/PDL and DBYH/DBYL are located close together, the area may be worth additional attention because multiple historical levels are clustered nearby.

---

## 🟠 PMH / PML — Pre-Market High & Low

**PMH = Pre-Market High**  
**PML = Pre-Market Low**

These orange lines track the highest and lowest prices during the pre-market session:

**4:00 AM – 9:30 AM ET**

The levels update during pre-market trading and are then available as reference points for the regular session.

### Why pre-market levels matter

The pre-market range shows where price traded before the regular market opened.

After 9:30 AM, traders can watch whether price:

- Breaks above PMH
- Breaks below PML
- Rejects one of the levels
- Retests a broken level
- Remains inside the pre-market range

A break followed by acceptance outside the pre-market range can provide useful information about intraday momentum, while repeated rejection may suggest that the level is acting as resistance or support.

---

## 🟢 ORH / ORL — Opening Range High & Low

**ORH = Opening Range High**  
**ORL = Opening Range Low**

The green lines represent the high and low created during the first **30 minutes of the regular trading session**:

**9:30 AM – 10:00 AM ET**

The opening range is widely monitored because the first part of the session often establishes important intraday boundaries.

### Common interpretations

**Above ORH:**  
Can indicate strengthening bullish intraday momentum when supported by price action and other confirmation.

**Below ORL:**  
Can indicate strengthening bearish intraday momentum when supported by confirmation.

**Inside ORH/ORL:**  
Price may be consolidating or trading without a clear directional break.

Traders may also watch for a breakout followed by a **retest of ORH or ORL** rather than immediately entering on the initial break.

---

## 🟣 Open + ATR / Open − ATR — Daily ATR Levels

These purple levels use the **Daily Average True Range (ATR)** to estimate potential price extensions from the regular-session opening price.

The default calculation uses:

**14-Day Daily ATR**

The levels are calculated as:

**Upper ATR Level = 9:30 AM Open + Daily ATR × Multiplier**

**Lower ATR Level = 9:30 AM Open − Daily ATR × Multiplier**

The default multiplier is **1.0**, but it can be changed in the indicator settings.

### Example

Suppose SPX opens at:

**6,700**

and its 14-day Daily ATR is:

**80 points**

The indicator would plot:

**Open + ATR = 6,780**

**Open − ATR = 6,620**

These levels provide context for how far price has traveled relative to its recent average daily movement.

Reaching an ATR level does **not** mean price must reverse. Strong trend days can exceed normal ATR ranges.

Instead, the levels can help traders evaluate whether price is relatively extended compared with recent daily volatility.

---

# How I Use the Levels for Intraday Scalping

The indicator is primarily a **market-map tool**, not a standalone buy/sell system.

I look for price interaction with these levels and then use additional confirmation before considering a trade.

Examples of confirmation can include:

**Price Action**
- Rejection candles
- Engulfing candles
- Break-and-retest setups
- Higher highs/higher lows
- Lower highs/lower lows

**Trend & Momentum**
- VWAP
- 9 EMA
- 21 EMA
- MACD
- RSI

**Participation**
- Volume expansion
- Increasing momentum
- Strong candle closes through a level

For example, price breaking PDH alone does not automatically create a long trade. A trader might instead wait to see whether price can **close above PDH, hold the level, and confirm momentum**.

---

# Level Confluence

One of the most useful features of plotting all these levels together is identifying **confluence**.

For example, suppose:

**PDH = 6,750**  
**PMH = 6,752**  
**ORH = 6,754**

Instead of treating these as three completely separate lines, the **6,750–6,754 area** can be viewed as a cluster of important reference levels.

The reaction around a cluster may be more informative than focusing on a single exact price.

---

# Quick Color Guide

🔵 **Blue — PDH / PDL**  
Previous regular-session high and low.

🩷 **Pink — DBYH / DBYL**  
Regular-session high and low from two completed trading sessions ago.

🟠 **Orange — PMH / PML**  
Pre-market high and low from 4:00 AM–9:30 AM ET.

🟢 **Green — ORH / ORL**  
Opening Range high and low from 9:30 AM–10:00 AM ET.

🟣 **Purple — Open ± ATR**  
Potential daily volatility-extension levels calculated from the 9:30 AM opening price and Daily ATR.

---

## Intended Use

This indicator is designed primarily for **intraday trading, day trading, and scalping**.

It can help answer four important questions:

**Where are the important historical levels?**  
→ PDH/PDL and DBYH/DBYL

**What levels did the market establish before today's open?**  
→ PMH/PML

**What range did the market establish after the opening bell?**  
→ ORH/ORL

**How extended is today's move relative to recent volatility?**  
→ Open ± ATR

The levels are intended to provide **context and structure**, not automatic trade signals.

---

## Disclaimer

This indicator is provided for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any security. Historical support, resistance, ATR, and session levels do not guarantee future price behavior. Traders should use their own analysis, confirmation, and risk-management rules.

## Source Code

````pine
//@version=6
indicator("OpeningRange For Scalping", overlay = true, max_lines_count = 50, max_labels_count = 50)

// ─────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────
tzInput     = input.string("America/New_York", "Timezone")

rthSession  = input.session("0930-1600:23456", "Regular NY Session")
pmSession   = input.session("0400-0930:23456", "Pre-Market Session")
orSession   = input.session("0930-1000:23456", "Opening Range Session")

showPD      = input.bool(true, "Show Previous Regular Session High/Low")
showDBY     = input.bool(true, "Show Day Before Yesterday High/Low")
showPM      = input.bool(true, "Show Pre-Market High/Low")
showOR      = input.bool(true, "Show Opening Range High/Low")
showLabels  = input.bool(true, "Show Labels")

pdColor     = input.color(color.rgb(30, 144, 255), "Previous Day Color")
dbyColor    = input.color(color.rgb(255, 105, 180), "Day Before Yesterday Color")
pmColor     = input.color(color.rgb(255, 165, 0), "Pre-Market Color")
orColor     = input.color(color.rgb(50, 205, 50), "Opening Range Color")

// ── ATR inputs ────────────────────────────────
showATR     = input.bool(true, "Show Open ± Daily ATR", group = "Daily ATR Levels")
atrLength   = input.int(14, "Daily ATR Length", group = "Daily ATR Levels", minval = 1)
atrMult     = input.float(1.0, "ATR Multiplier", group = "Daily ATR Levels", minval = 0.1, step = 0.1)
atrColor    = input.color(color.rgb(220, 80, 220), "ATR Level Color", group = "Daily ATR Levels")

lineWidth   = input.int(2, "Line Width", minval = 1, maxval = 5)
lineStyleIn = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"])

lineStyle = lineStyleIn == "Dashed" ? line.style_dashed :
     lineStyleIn == "Dotted" ? line.style_dotted :
     line.style_solid

// ─────────────────────────────────────────────
// Daily ATR
// ─────────────────────────────────────────────
dailyAtr = request.security(
     syminfo.tickerid,
     "D",
     ta.atr(atrLength),
     lookahead = barmerge.lookahead_off)

// ─────────────────────────────────────────────
// NY timestamps
// ─────────────────────────────────────────────
nyYear  = year(time, tzInput)
nyMonth = month(time, tzInput)
nyDay   = dayofmonth(time, tzInput)

marketOpenTs  = timestamp(tzInput, nyYear, nyMonth, nyDay, 9, 30)
marketCloseTs = timestamp(tzInput, nyYear, nyMonth, nyDay, 16, 0)
marketMidTs   = timestamp(tzInput, nyYear, nyMonth, nyDay, 12, 45)

newNyDay = na(time[1]) or
     nyDay != dayofmonth(time[1], tzInput) or
     nyMonth != month(time[1], tzInput) or
     nyYear != year(time[1], tzInput)

// ─────────────────────────────────────────────
// Session detection
// ─────────────────────────────────────────────
inRTH = not na(time(timeframe.period, rthSession, tzInput))
inPM  = not na(time(timeframe.period, pmSession, tzInput))
inOR  = not na(time(timeframe.period, orSession, tzInput))

rthStart = inRTH and not inRTH[1]
rthEnd   = not inRTH and inRTH[1]

// ─────────────────────────────────────────────
// Track RTH High / Low
//
// prevRth = yesterday
// prev2Rth = day before yesterday
// ─────────────────────────────────────────────
var float currentRthHigh = na
var float currentRthLow  = na

var float prevRthHigh  = na
var float prevRthLow   = na

var float prev2RthHigh = na
var float prev2RthLow  = na

if rthStart
    currentRthHigh := high
    currentRthLow  := low
else if inRTH
    currentRthHigh := na(currentRthHigh) ? high : math.max(currentRthHigh, high)
    currentRthLow  := na(currentRthLow) ? low : math.min(currentRthLow, low)

// When RTH ends:
// Yesterday becomes Day Before Yesterday
// Today's completed session becomes Previous Day
if rthEnd
    prev2RthHigh := prevRthHigh
    prev2RthLow  := prevRthLow

    prevRthHigh := currentRthHigh
    prevRthLow  := currentRthLow

// ─────────────────────────────────────────────
// Track Pre-Market + Opening Range
// ─────────────────────────────────────────────
var float pmHigh = na
var float pmLow  = na
var float orHigh = na
var float orLow  = na

if newNyDay
    pmHigh := na
    pmLow  := na
    orHigh := na
    orLow  := na

if inPM
    pmHigh := na(pmHigh) ? high : math.max(pmHigh, high)
    pmLow  := na(pmLow) ? low : math.min(pmLow, low)

if inOR
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow  := na(orLow) ? low : math.min(orLow, low)

// ─────────────────────────────────────────────
// Capture 9:30 Open + Freeze Daily ATR
// ─────────────────────────────────────────────
var float nyOpenPrice  = na
var float atrAtOpen    = na
var float openPlusAtr  = na
var float openMinusAtr = na

if newNyDay
    nyOpenPrice  := na
    atrAtOpen    := na
    openPlusAtr  := na
    openMinusAtr := na

if rthStart
    nyOpenPrice  := open
    atrAtOpen    := dailyAtr
    openPlusAtr  := nyOpenPrice + atrMult * atrAtOpen
    openMinusAtr := nyOpenPrice - atrMult * atrAtOpen

// ─────────────────────────────────────────────
// Drawing Objects
// ─────────────────────────────────────────────

// Previous Day
var line pdhLine = na
var line pdlLine = na

// Day Before Yesterday
var line dbyhLine = na
var line dbylLine = na

// PM / OR / ATR
var line pmhLine = na
var line pmlLine = na
var line orhLine = na
var line orlLine = na
var line opaLine = na
var line omaLine = na

// Labels
var label pdhLabel = na
var label pdlLabel = na

var label dbyhLabel = na
var label dbylLabel = na

var label pmhLabel = na
var label pmlLabel = na
var label orhLabel = na
var label orlLabel = na

var label opaLabel = na
var label omaLabel = na

var label opaMidLabel = na
var label omaMidLabel = na

// ─────────────────────────────────────────────
// Helper Functions
// ─────────────────────────────────────────────
f_deleteLine(line ln) =>
    if not na(ln)
        line.delete(ln)

f_deleteLabel(label lb) =>
    if not na(lb)
        label.delete(lb)

// ─────────────────────────────────────────────
// Re-create Objects Each NY Day
// ─────────────────────────────────────────────
if newNyDay or na(pdhLine)

    // Delete old lines
    f_deleteLine(pdhLine)
    f_deleteLine(pdlLine)

    f_deleteLine(dbyhLine)
    f_deleteLine(dbylLine)

    f_deleteLine(pmhLine)
    f_deleteLine(pmlLine)
    f_deleteLine(orhLine)
    f_deleteLine(orlLine)

    f_deleteLine(opaLine)
    f_deleteLine(omaLine)

    // Delete old labels
    f_deleteLabel(pdhLabel)
    f_deleteLabel(pdlLabel)

    f_deleteLabel(dbyhLabel)
    f_deleteLabel(dbylLabel)

    f_deleteLabel(pmhLabel)
    f_deleteLabel(pmlLabel)
    f_deleteLabel(orhLabel)
    f_deleteLabel(orlLabel)

    f_deleteLabel(opaLabel)
    f_deleteLabel(omaLabel)

    f_deleteLabel(opaMidLabel)
    f_deleteLabel(omaMidLabel)

    // ── Create Previous Day Lines ──
    pdhLine := line.new(
         marketOpenTs, close,
         marketCloseTs, close,
         xloc = xloc.bar_time,
         color = color.new(pdColor, 100),
         width = lineWidth,
         style = lineStyle)

    pdlLine := line.new(
         marketOpenTs, close,
         marketCloseTs, close,
         xloc = xloc.bar_time,
         color = color.new(pdColor, 100),
         width = lineWidth,
         style = lineStyle)

    // ── Create Day Before Yesterday Lines ──
    dbyhLine := line.new(
         marketOpenTs, close,
         marketCloseTs, close,
         xloc = xloc.bar_time,
         color = color.new(dbyColor, 100),
         width = lineWidth,
         style = lineStyle)

    dbylLine := line.new(
         marketOpenTs, close,
         marketCloseTs, close,
         xloc = xloc.bar_time,
         color = color.new(dbyColor, 100),
         width = lineWidth,
         style = lineStyle)

    // ── PM Lines ──
    pmhLine := line.new(
         marketOpenTs, close,
         marketCloseTs, close,
         xloc = xloc.bar_time,
         color = color.new(pmColor, 100),
         width = lineWidth,
         style = lineStyle)

    pmlLine := line.new(
         marketOpenTs, close,
         marketCloseTs, close,
         xloc = xloc.bar_time,
         color = color.new(pmColor, 100),
         width = lineWidth,
         style = lineStyle)

    // ── Opening Range Lines ──
    orhLine := line.new(
         marketOpenTs, close,
         marketCloseTs, close,
         xloc = xloc.bar_time,
         color = color.new(orColor, 100),
         width = lineWidth,
         style = lineStyle)

    orlLine := line.new(
         marketOpenTs, close,
         marketCloseTs, close,
         xloc = xloc.bar_time,
         color = color.new(orColor, 100),
         width = lineWidth,
         style = lineStyle)

    // ── ATR Lines ──
    opaLine := line.new(
         marketOpenTs, close,
         marketCloseTs, close,
         xloc = xloc.bar_time,
         color = color.new(atrColor, 100),
         width = lineWidth,
         style = lineStyle)

    omaLine := line.new(
         marketOpenTs, close,
         marketCloseTs, close,
         xloc = xloc.bar_time,
         color = color.new(atrColor, 100),
         width = lineWidth,
         style = lineStyle)

    // ── Previous Day Labels ──
    pdhLabel := label.new(
         marketCloseTs, close, "",
         xloc = xloc.bar_time,
         yloc = yloc.price,
         style = label.style_label_left,
         color = color.new(color.black, 100),
         textcolor = pdColor,
         size = size.small)

    pdlLabel := label.new(
         marketCloseTs, close, "",
         xloc = xloc.bar_time,
         yloc = yloc.price,
         style = label.style_label_left,
         color = color.new(color.black, 100),
         textcolor = pdColor,
         size = size.small)

    // ── Day Before Yesterday Labels ──
    dbyhLabel := label.new(
         marketCloseTs, close, "",
         xloc = xloc.bar_time,
         yloc = yloc.price,
         style = label.style_label_left,
         color = color.new(color.black, 100),
         textcolor = dbyColor,
         size = size.small)

    dbylLabel := label.new(
         marketCloseTs, close, "",
         xloc = xloc.bar_time,
         yloc = yloc.price,
         style = label.style_label_left,
         color = color.new(color.black, 100),
         textcolor = dbyColor,
         size = size.small)

    // ── PM Labels ──
    pmhLabel := label.new(
         marketCloseTs, close, "",
         xloc = xloc.bar_time,
         yloc = yloc.price,
         style = label.style_label_left,
         color = color.new(color.black, 100),
         textcolor = pmColor,
         size = size.small)

    pmlLabel := label.new(
         marketCloseTs, close, "",
         xloc = xloc.bar_time,
         yloc = yloc.price,
         style = label.style_label_left,
         color = color.new(color.black, 100),
         textcolor = pmColor,
         size = size.small)

    // ── OR Labels ──
    orhLabel := label.new(
         marketCloseTs, close, "",
         xloc = xloc.bar_time,
         yloc = yloc.price,
         style = label.style_label_left,
         color = color.new(color.black, 100),
         textcolor = orColor,
         size = size.small)

    orlLabel := label.new(
         marketCloseTs, close, "",
         xloc = xloc.bar_time,
         yloc = yloc.price,
         style = label.style_label_left,
         color = color.new(color.black, 100),
         textcolor = orColor,
         size = size.small)

    // ── ATR Right Labels ──
    opaLabel := label.new(
         marketCloseTs, close, "",
         xloc = xloc.bar_time,
         yloc = yloc.price,
         style = label.style_label_left,
         color = color.new(color.black, 100),
         textcolor = atrColor,
         size = size.small)

    omaLabel := label.new(
         marketCloseTs, close, "",
         xloc = xloc.bar_time,
         yloc = yloc.price,
         style = label.style_label_left,
         color = color.new(color.black, 100),
         textcolor = atrColor,
         size = size.small)

    // ── ATR Mid Labels ──
    opaMidLabel := label.new(
         marketMidTs, close, "",
         xloc = xloc.bar_time,
         yloc = yloc.price,
         style = label.style_label_center,
         color = color.new(atrColor, 15),
         textcolor = color.white,
         size = size.normal)

    omaMidLabel := label.new(
         marketMidTs, close, "",
         xloc = xloc.bar_time,
         yloc = yloc.price,
         style = label.style_label_center,
         color = color.new(atrColor, 15),
         textcolor = color.white,
         size = size.normal)

// ─────────────────────────────────────────────
// Generic Level Update
// ─────────────────────────────────────────────
f_updateLevel(line ln, label lb, float price, string txt, color col, bool visible) =>
    if visible and not na(price)
        line.set_xy1(ln, marketOpenTs, price)
        line.set_xy2(ln, marketCloseTs, price)
        line.set_color(ln, col)
        line.set_width(ln, lineWidth)
        line.set_style(ln, lineStyle)

        label.set_x(lb, marketCloseTs)
        label.set_y(lb, price)
        label.set_text(lb, showLabels ? txt : "")
        label.set_textcolor(lb, col)
        label.set_color(lb, color.new(color.black, 100))
    else
        line.set_color(ln, color.new(col, 100))
        label.set_text(lb, "")

// ─────────────────────────────────────────────
// ATR Mid Label
// ─────────────────────────────────────────────
f_updateMidLabel(label lb, float price, string prefix, bool visible) =>
    if visible and not na(price)

        decimals = math.round(
             math.log(1 / syminfo.mintick) /
             math.log(10))

        priceStr = str.tostring(
             math.round(price, decimals))

        labelTxt = prefix + "\n" + priceStr

        label.set_x(lb, marketMidTs)
        label.set_y(lb, price)
        label.set_text(lb, labelTxt)
        label.set_color(lb, color.new(atrColor, 15))
        label.set_textcolor(lb, color.white)

    else
        label.set_text(lb, "")
        label.set_color(lb, color.new(atrColor, 100))

// ─────────────────────────────────────────────
// Apply Updates
// ─────────────────────────────────────────────

// Previous Day
f_updateLevel(
     pdhLine, pdhLabel,
     prevRthHigh,
     "PDH",
     pdColor,
     showPD)

f_updateLevel(
     pdlLine, pdlLabel,
     prevRthLow,
     "PDL",
     pdColor,
     showPD)

// Day Before Yesterday — PINK
f_updateLevel(
     dbyhLine, dbyhLabel,
     prev2RthHigh,
     "DBYH",
     dbyColor,
     showDBY)

f_updateLevel(
     dbylLine, dbylLabel,
     prev2RthLow,
     "DBYL",
     dbyColor,
     showDBY)

// Pre-Market
f_updateLevel(
     pmhLine, pmhLabel,
     pmHigh,
     "PMH",
     pmColor,
     showPM)

f_updateLevel(
     pmlLine, pmlLabel,
     pmLow,
     "PML",
     pmColor,
     showPM)

// Opening Range
f_updateLevel(
     orhLine, orhLabel,
     orHigh,
     "ORH",
     orColor,
     showOR)

f_updateLevel(
     orlLine, orlLabel,
     orLow,
     "ORL",
     orColor,
     showOR)

// ATR
f_updateLevel(
     opaLine, opaLabel,
     openPlusAtr,
     "Open+ATR",
     atrColor,
     showATR)

f_updateLevel(
     omaLine, omaLabel,
     openMinusAtr,
     "Open-ATR",
     atrColor,
     showATR)

f_updateMidLabel(
     opaMidLabel,
     openPlusAtr,
     "Open+ATR",
     showATR)

f_updateMidLabel(
     omaMidLabel,
     openMinusAtr,
     "Open-ATR",
     showATR)
````
