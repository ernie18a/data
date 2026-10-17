# RSI Signals with Sessions

- url: https://www.tradingview.com/script/UR7l1TFQ-RSI-Signals-with-Sessions/
- type: indicator
- pine_id: PUB;b722ca113beb4c39bd5af6d346c93e8f
- version: 1.0

## Description

RSI Signals with Sessions 
[url=https://www.tradingview.com/u/Michael_Fx_Trader/]https://www.tradingview.com/u/Michael_Fx_Trader/[/url]

What This Indicator Is

RSI Signals with Sessions combines a four level colored RSI with a live Buy and Sell signal engine and a set of four automatically drawn trading session boxes, all in one tool. It works on any timeframe and any symbol, but it has been tuned by default for fast, short term signals on the one minute and five minute charts. The RSI panel tells you exactly when momentum has reached an extreme or a key zone, the signal engine turns specific RSI conditions into labeled Buy and Sell markers with a stop and target already measured out in pips, and the four session boxes drawn directly on the candles show you exactly when the Asia, London, New York, and London Close trading windows happened on the chart, each with its own color and its own high to low range for that session.
[image]https://www.tradingview.com/x/t8Ff7lyk/[/image]

Why It Was Built

Reading raw RSI and deciding whether a reading is extreme enough to act on is subjective, and it gets harder on fast charts where a lot of small, low quality signals can appear. This indicator removes that guesswork by defining four fixed levels up front, Over Buy, Resistance, Support, and Over Sold, and applying two clear, repeatable rules on top of them: a pure RSI extreme rule for the strongest, highest confidence reversals, and a level plus candle confirmation rule for less extreme readings that still show real rejection at a key zone. On top of that, most short term traders also care about which part of the trading day they are in, since Gold and other instruments behave very differently during the Asian session compared to London or New York, so the four session boxes were added to make that context visible on the chart itself rather than something you have to track separately.
[image]https://www.tradingview.com/x/0s34pUOp/[/image]

How It Works

The RSI line itself changes color depending on which of the four zones it is currently sitting in, so the current market condition is visible at a glance without reading the exact number. A Sell signal only ever comes from one of two places: RSI reaching the Over Buy level on its own, which fires immediately at a fixed eighty percent strength, or RSI sitting inside the Resistance zone together with a strong bearish candle closing at the same time, which fires at a fixed seventy percent strength. A Buy signal is the mirror image, coming only from RSI reaching the Over Sold level on its own at eighty percent strength, or RSI sitting inside the Support zone together with a strong bullish candle at seventy percent strength. A candle only counts as strong when its body is a chosen multiple of the average candle body size over a recent lookback period, which stops the indicator from reacting to small, indecisive candles. Each zone can only fire once per visit, meaning once RSI leaves a zone and later comes back into it, a fresh signal becomes possible again, which keeps the chart from spamming repeated signals while RSI simply sits inside the same zone for a long stretch.

Separately from the RSI logic, four independent session trackers run in the background, each watching its own defined time window in the timezone you choose. The moment the chart enters one of those windows, that session starts recording its own running highest high and lowest low, updating live bar by bar. The instant the window closes, a box is drawn directly on the price candles spanning that exact time range at that session's high to low, in that session's own color, with its name labeled above the box, and a short rolling history of these boxes is kept for each session so you can compare recent sessions against each other without the chart becoming cluttered with every session since the beginning of the chart's history.
[image]https://www.tradingview.com/x/nA3hfSsl/[/image]

How To Read The Chart

A red downward triangle marks a Sell signal and a green upward triangle marks a Buy signal, both appearing directly on the candle that triggered it and at the matching point on the RSI line underneath, so the same event is visible from either view. A percentage label next to each signal states its fixed confidence, eighty percent for the pure RSI extreme signals or seventy percent for the zone plus candle signals. When a signal fires, a white dashed entry line, a red dashed stop line, and a green dashed target line extend a short distance to the right, each carrying its own price tag, giving you a ready made trade plan at the moment the signal appears. The four session boxes sit directly on the candles in their own colors, Asia in cyan, London in orange, New York in purple, and London Close in gray by default, each with its name labeled just above it, so you can see at a glance which part of the trading day produced which part of the move.
[image]https://www.tradingview.com/x/OkPA034i/[/image]

How To Use It For Analysis

Use the RSI panel's colored zones to judge the underlying momentum before a signal even fires, since a reading sitting right at the edge of the Resistance or Support zone is worth watching closely for the strong candle that would complete that signal. Once a signal does fire, check which session box it fell inside, since a signal forming during London or New York, when liquidity is typically higher, generally deserves more weight than one forming during a quiet stretch between sessions. Comparing the height and shape of recent session boxes against each other is also a quick way to judge whether a particular session has been unusually active or unusually quiet lately on the instrument you are watching. As always, this indicator encodes a specific, transparent rule set, it does not replace your own trend reading, other confluence, or your own risk management before acting on any signal it shows you.
[image]https://www.tradingview.com/x/xpjfssit/[/image]

What The RSI Panel Shows

The RSI panel itself only shows the RSI line, colored by zone, and its four level lines, Over Buy, Resistance, Support, and Over Sold, along with a faint midline for reference. Small triangle markers appear on the RSI line at the exact value where a Buy or Sell signal fired, giving you a second, independent view of every signal alongside the main chart. Nothing else is drawn in this panel, keeping it focused purely on momentum; the signal labels, the entry/stop/target lines, and the four session boxes all appear directly on the price candles instead.
[image]https://www.tradingview.com/x/KqlVoUrJ/[/image]

Settings Worth Knowing Before Use

The RSI length and source, whether signals wait for candle close, all four RSI levels, the two fixed strength percentages, the strong candle lookback and multiplier, the pip size, stop and target pip distances, and the entry/stop/target line length can all be adjusted from the indicator's settings panel, along with every RSI and signal color. On the session side, the timezone used for all four windows, how many recent boxes are kept per session, each session's own time window and color, and the fill opacity of the boxes can all be changed as well, so the tool can be matched to a different broker's session times or a different trading style.

Disclaimer

This indicator is a technical analysis tool and does not constitute financial advice. The Strength % values are fixed confidence labels describing which internal rule produced a given signal, not a statistical win rate or a guarantee of outcome, and the session boxes describe where price actually traded during a defined time window, not a prediction of future behavior in that same window. All trading involves risk, and past performance of any signal, pattern, or session does not guarantee future results. Always use proper risk management and combine this tool with your own analysis before entering any trade.

Original Script Declaration

Script Name: RSI Signals with Sessions
Author: Michael_Fx_Trader
Publisher: Michael_Fx_Trader
Rights: Copyright Michael_Fx_Trader. All rights reserved.

Originality Statement: This is an original work, designed and coded from scratch by Michael_Fx_Trader. The four level colored RSI zone engine, the zone entry armed and fired signal state machine so that Buy signals only ever come from the Support and Over Sold conditions and Sell signals only ever come from the Resistance and Over Buy conditions, the fixed confidence Strength % labeling system, the dual chart and RSI pane signal display, the pip based Entry, Stop Loss and Take Profit level drawing engine, and the four session colored box drawing engine that tracks each session's own high and low range live and finalizes the box the instant the session ends were all independently conceived and implemented for this publication. No proprietary source code, private scripts, or copyrighted material belonging to any other author has been copied, mashed up, or reused in any part of this script.

Author Verification and Declaration: I, Michael_Fx_Trader, am the sole author and publisher of this script. I hold full authorship rights over its source code, its underlying logic, and its visual presentation. The Relative Strength Index itself is a well known, generic public domain technical indicator, and marking trading sessions on a chart is a well known, generic concept; neither is owned by any individual author. Only the specific zone, signal, and labeling logic, and the specific session box tracking and drawing logic built around them here, is original to this script, and nothing in it was copied or adapted from another author's published work.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════════════════
//  INDICATOR NAME   : RSI Signals with Sessions
//  SHORT TITLE      : RSI Signals + Sessions
//  PINE SCRIPT      : Version 6
// ═══════════════════════════════════════════════════════════════════════════════════════
//
//  AUTHOR           : Michael_Fx_Trader
//  CREATOR          : Michael_Fx_Trader
//  PUBLISHER        : Michael_Fx_Trader
//  TRADINGVIEW PROFILE : Michael_Fx-Trader
//
// ───────────────────────────────────────────────────────────────────────────────────────
//  VERIFICATION & ORIGINALITY DECLARATION
// ───────────────────────────────────────────────────────────────────────────────────────
//  I, Michael_Fx_Trader, hereby declare and verify that:
//
//   1. This indicator ("RSI Signals with Sessions") is my own ORIGINAL work. The idea,
//      the signal logic, the session-box engine and the complete Pine Script v6 source
//      code were designed and implemented by me personally.
//
//   2. No part of this script has been copied, cloned, re-published, re-packaged or
//      derived from any other author's closed-source or open-source script, whether on
//      TradingView or anywhere else.
//
//   3. The only external component used is the TradingView built-in function library
//      (ta.rsi, ta.sma, ta.highest, ta.lowest, time(), box.*, label.*, line.*, plot*,
//      hline, fill, alertcondition), which is provided by Pine Script itself.
//
//   4. The implementation (RSI zone logic + strong-candle confirmation + trading
//      session boxes + signal labels + entry/target helper lines) was independently
//      coded and verified by the author. The author takes full responsibility for the
//      originality of this publication.
//
//   5. This script is published for EDUCATIONAL and ANALYTICAL purposes only.
//
// ───────────────────────────────────────────────────────────────────────────────────────
//  DESCRIPTION
// ───────────────────────────────────────────────────────────────────────────────────────
//  "RSI Signals with Sessions" combines a colourful RSI oscillator (lower pane) with
//  BUY / SELL signals printed directly on the price chart (main pane) and four
//  trading-session boxes drawn on the candles (Asia, London, New York, London Close).
//
//  It works on every timeframe, but it is designed and tuned mainly for the
//  5-minute and 1-minute charts (for example XAUUSD / Gold, Forex pairs, indices).
//  Session boxes are drawn on intraday timeframes only.
//
//  RSI LEVELS (all four are drawn as horizontal lines in the RSI pane)
//    • Over Bought : 80
//    • Resistance  : 68
//    • Support     : 35
//    • Over Sold   : 20
//
//  SIGNAL LOGIC
//    1) SELL "80%" : RSI touches / crosses up through the Over Bought level (80).
//                    A red SELL label is printed on the candle chart and a red triangle
//                    is printed on the RSI line at the same bar.
//    2) SELL "70%" : RSI is at the Resistance level (68) or above (within the zone
//                    lookback) AND a strong bearish candle closes on the same bar.
//    3) BUY  "80%" : RSI touches / crosses down through the Over Sold level (20).
//                    A green BUY label is printed on the chart and a green triangle on
//                    the RSI line at the same bar.
//    4) BUY  "70%" : RSI is at the Support level (35) or below (within the zone
//                    lookback) AND a strong bullish candle closes on the same bar.
//
//    Optional helper lines show the entry price and a target of 80 pips (extreme
//    signals) or 70 pips (resistance / support signals). Pip size is automatic
//    (syminfo.mintick * 10) and can be overridden in the settings.
//
//  TRADING SESSIONS (default timezone GMT-4)
//    • Asia         : 08:00 PM – 12:00 AM   (20:00 – 00:00)
//    • London       : 02:00 AM – 05:00 AM
//    • New York     : 07:00 AM – 10:00 AM
//    • London Close : 10:00 AM – 12:00 PM
//    Each session is a coloured box that follows the session high / low, with the
//    session name written above the box.
//
//  ALERTS
//    Alert conditions are provided for Sell, Buy, and for each individual signal type.
//
//  DISCLAIMER
//    This indicator is a technical analysis tool, NOT financial advice. Trading
//    leveraged products such as Forex, Gold and CFDs involves a high level of risk.
//    Past performance does not guarantee future results. Always use proper risk
//    management and test on a demo account first.
//
//  VERSION HISTORY
//    v1.0 : Initial release - RSI with 4 levels, 4 signal types, 4 session boxes,
//           alerts, entry / target helper lines.
//
//  © Michael_Fx_Trader - All rights reserved.
// ═══════════════════════════════════════════════════════════════════════════════════════

indicator(
     title            = "RSI Signals with Sessions",
     shorttitle       = "RSI Signals + Sessions",
     overlay          = false,
     max_labels_count = 500,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     precision        = 2)

// ═══════════════════════════════════════════════════════════════════════════════════════
//  USER DEFINED TYPES
// ═══════════════════════════════════════════════════════════════════════════════════════
// Holds the live state of one session box (so each session keeps its own high / low).
type SessionState
    box   bx
    label lb
    float hi
    float lo
    int   t0

// ═══════════════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════════════════════════════
// ── Group names ──
const string G_RSI  = "RSI Settings"
const string G_SIG  = "Signal Settings"
const string G_TP   = "Entry / Target Lines"
const string G_COL  = "RSI Colors"
const string G_SESS = "Session Settings (General)"
const string G_ASIA = "Asia Session"
const string G_LON  = "London Session"
const string G_NY   = "New York Session"
const string G_LCL  = "London Close Session"

// ── RSI settings ──
rsiLen   = input.int(14, "RSI Length", minval = 1, group = G_RSI)
rsiSrc   = input.source(close, "RSI Source", group = G_RSI)
obLevel  = input.float(80.0, "Over Bought Level", minval = 50.0, maxval = 100.0, step = 0.5, group = G_RSI)
resLevel = input.float(68.0, "Resistance Level",  minval = 30.0, maxval = 100.0, step = 0.5, group = G_RSI)
supLevel = input.float(35.0, "Support Level",     minval = 0.0,  maxval = 70.0,  step = 0.5, group = G_RSI)
osLevel  = input.float(20.0, "Over Sold Level",   minval = 0.0,  maxval = 50.0,  step = 0.5, group = G_RSI)

// ── Signal settings ──
showSignals  = input.bool(true, "Show Buy / Sell Signals", group = G_SIG)
confirmClose = input.bool(true, "Confirm Signals on Bar Close (no repaint)", group = G_SIG,
     tooltip = "ON: the signal appears when the candle closes (does not repaint).\nOFF: the signal fires instantly the moment RSI touches the level (can disappear if RSI moves back before the candle closes).")
zoneLookback = input.int(2, "RSI Zone Lookback (bars)", minval = 1, maxval = 10, group = G_SIG,
     tooltip = "RSI must have touched the Resistance / Support zone within this many bars (including the current bar) for the candle-confirmation signal.")
avgBodyLen   = input.int(14, "Average Candle Body Length", minval = 2, group = G_SIG)
bodyMult     = input.float(1.2, "Strong Candle: Body vs Average (x)", minval = 0.5, step = 0.1, group = G_SIG,
     tooltip = "A candle is 'strong' when its body is at least this multiple of the average body.")
bodyPct      = input.float(60.0, "Strong Candle: Min Body % of Range", minval = 10.0, maxval = 100.0, step = 5.0, group = G_SIG,
     tooltip = "Minimum body size as a percentage of the full candle range (high - low).")
cooldownBars = input.int(3, "Min Bars Between Same-Direction Signals", minval = 0, maxval = 100, group = G_SIG)

// ── Entry / target helper lines ──
showTP    = input.bool(true, "Show Entry / Target Lines", group = G_TP)
tpExtreme = input.float(80.0, "Target Pips - 80% Signals (Over Bought / Over Sold)", minval = 1.0, group = G_TP)
tpZone    = input.float(70.0, "Target Pips - 70% Signals (Resistance / Support)", minval = 1.0, group = G_TP)
pipInput  = input.float(0.0, "Pip Size in Price Units (0 = Auto)", minval = 0.0, step = 0.0001, group = G_TP,
     tooltip = "0 = automatic (syminfo.mintick * 10). Example: Gold 0.10, EURUSD 0.0001, USDJPY 0.01.")
tpLen     = input.int(20, "Line Length (bars)", minval = 2, maxval = 200, group = G_TP)

// ── Colors ──
colSell = input.color(#F23645, "Sell Signal Color", group = G_COL)
colBuy  = input.color(#00C853, "Buy Signal Color",  group = G_COL)
colOB   = input.color(#F23645, "Over Bought Zone / Line", group = G_COL)
colRes  = input.color(#FF9800, "Resistance Zone / Line", group = G_COL)
colMid  = input.color(#787B86, "RSI Neutral Line", group = G_COL)
colSup  = input.color(#2962FF, "Support Zone / Line", group = G_COL)
colOS   = input.color(#00C853, "Over Sold Zone / Line", group = G_COL)

// ── Session general ──
showSessions = input.bool(true, "Show Session Boxes", group = G_SESS)
tzInput      = input.string("GMT-4", "Timezone", group = G_SESS,
     options = ["GMT-12", "GMT-11", "GMT-10", "GMT-9", "GMT-8", "GMT-7", "GMT-6", "GMT-5", "GMT-4", "GMT-3", "GMT-2", "GMT-1",
                "GMT+0", "GMT+1", "GMT+2", "GMT+3", "GMT+4", "GMT+5", "GMT+6", "GMT+7", "GMT+8", "GMT+9", "GMT+10", "GMT+11", "GMT+12", "GMT+13", "GMT+14"],
     tooltip = "All session times below are interpreted in this timezone. Default GMT-4.")
histMax      = input.int(100, "History (sessions kept per session)", minval = 1, maxval = 120, group = G_SESS)
boxTransp    = input.int(80, "Box Fill Transparency", minval = 0, maxval = 100, group = G_SESS)
boxBorder    = input.int(1, "Box Border Width", minval = 1, maxval = 4, group = G_SESS)

// ── Asia ──
asiaOn   = input.bool(true, "Show Asia Session", group = G_ASIA)
asiaTime = input.session("2000-0000", "Asia Session (08:00 PM - 12:00 AM)", group = G_ASIA)
asiaCol  = input.color(#00BCD4, "Box Color", group = G_ASIA)
asiaTxt  = input.color(#00BCD4, "Name Color", group = G_ASIA)

// ── London ──
lonOn   = input.bool(true, "Show London Session", group = G_LON)
lonTime = input.session("0200-0500", "London Session (02:00 AM - 05:00 AM)", group = G_LON)
lonCol  = input.color(#FF9800, "Box Color", group = G_LON)
lonTxt  = input.color(#FF9800, "Name Color", group = G_LON)

// ── New York ──
nyOn   = input.bool(true, "Show New York Session", group = G_NY)
nyTime = input.session("0700-1000", "New York Session (07:00 AM - 10:00 AM)", group = G_NY)
nyCol  = input.color(#673AB7, "Box Color", group = G_NY)
nyTxt  = input.color(#673AB7, "Name Color", group = G_NY)

// ── London Close ──
lclOn   = input.bool(true, "Show London Close Session", group = G_LCL)
lclTime = input.session("1000-1200", "London Close Session (10:00 AM - 12:00 PM)", group = G_LCL)
lclCol  = input.color(#787B86, "Box Color", group = G_LCL)
lclTxt  = input.color(#434651, "Name Color", group = G_LCL)

// ═══════════════════════════════════════════════════════════════════════════════════════
//  RSI CALCULATION
// ═══════════════════════════════════════════════════════════════════════════════════════
float rsi = ta.rsi(rsiSrc, rsiLen)

// Colorful RSI line: red = over bought, orange = resistance, blue = support, green = over sold
color rsiColor = rsi >= obLevel ? colOB : rsi >= resLevel ? colRes : rsi <= osLevel ? colOS : rsi <= supLevel ? colSup : colMid

// ═══════════════════════════════════════════════════════════════════════════════════════
//  CANDLE STRENGTH
// ═══════════════════════════════════════════════════════════════════════════════════════
float body    = math.abs(close - open)
float rng     = high - low
float avgBody = ta.sma(body, avgBodyLen)

bool strongBear = close < open and rng > 0 and body >= avgBody * bodyMult and (body / rng * 100.0) >= bodyPct
bool strongBull = close > open and rng > 0 and body >= avgBody * bodyMult and (body / rng * 100.0) >= bodyPct

// ═══════════════════════════════════════════════════════════════════════════════════════
//  SIGNAL LOGIC
// ═══════════════════════════════════════════════════════════════════════════════════════
float zoneHigh = ta.highest(rsi, zoneLookback)
float zoneLow  = ta.lowest(rsi, zoneLookback)

// 80% signals - RSI touches the extreme level
bool touchOB = rsi >= obLevel and rsi[1] < obLevel
bool touchOS = rsi <= osLevel and rsi[1] > osLevel

// 70% signals - RSI at resistance / support zone + strong candle close
bool resSell = zoneHigh >= resLevel and strongBear and not touchOB
bool supBuy  = zoneLow  <= supLevel and strongBull and not touchOS

bool canFire = showSignals and (not confirmClose or barstate.isconfirmed)

bool rawSell = touchOB or resSell
bool rawBuy  = touchOS or supBuy

var int lastSellBar = na
var int lastBuyBar  = na

bool sellOK = canFire and rawSell and (na(lastSellBar) or bar_index - lastSellBar > cooldownBars)
bool buyOK  = canFire and rawBuy  and (na(lastBuyBar)  or bar_index - lastBuyBar  > cooldownBars)

if sellOK
    lastSellBar := bar_index
if buyOK
    lastBuyBar := bar_index

int sellStrength = touchOB ? 80 : 70
int buyStrength  = touchOS ? 80 : 70

// ═══════════════════════════════════════════════════════════════════════════════════════
//  SIGNALS ON THE CANDLE CHART (force_overlay = true draws on the main price panel)
// ═══════════════════════════════════════════════════════════════════════════════════════
float pip = pipInput > 0 ? pipInput : syminfo.mintick * 10

if sellOK
    label.new(x = bar_index, y = high, text = "Sell",
         xloc = xloc.bar_index, yloc = yloc.price, color = colSell,
         style = label.style_label_down, textcolor = color.white, size = size.small,
         force_overlay = true)
    if showTP
        float tpDist = (touchOB ? tpExtreme : tpZone) * pip
        line.new(x1 = bar_index, y1 = close, x2 = bar_index + tpLen, y2 = close,
             color = color.gray, style = line.style_dashed, width = 1, force_overlay = true)
        line.new(x1 = bar_index, y1 = close - tpDist, x2 = bar_index + tpLen, y2 = close - tpDist,
             color = colSell, style = line.style_dashed, width = 1, force_overlay = true)

if buyOK
    label.new(x = bar_index, y = low, text = "Buy",
         xloc = xloc.bar_index, yloc = yloc.price, color = colBuy,
         style = label.style_label_up, textcolor = color.white, size = size.small,
         force_overlay = true)
    if showTP
        float tpDistB = (touchOS ? tpExtreme : tpZone) * pip
        line.new(x1 = bar_index, y1 = close, x2 = bar_index + tpLen, y2 = close,
             color = color.gray, style = line.style_dashed, width = 1, force_overlay = true)
        line.new(x1 = bar_index, y1 = close + tpDistB, x2 = bar_index + tpLen, y2 = close + tpDistB,
             color = colBuy, style = line.style_dashed, width = 1, force_overlay = true)

// ═══════════════════════════════════════════════════════════════════════════════════════
//  RSI PANE: LEVEL LINES, ZONES, LINE AND SIGNAL MARKERS
// ═══════════════════════════════════════════════════════════════════════════════════════
hTop = hline(100, "Top",  color = color.new(color.gray, 100))
hBot = hline(0,   "Bottom", color = color.new(color.gray, 100))
hOB  = hline(obLevel,  "Over Bought", color = colOB,  linestyle = hline.style_solid,  linewidth = 1)
hRes = hline(resLevel, "Resistance",  color = colRes, linestyle = hline.style_dashed, linewidth = 1)
hSup = hline(supLevel, "Support",     color = colSup, linestyle = hline.style_dashed, linewidth = 1)
hOS  = hline(osLevel,  "Over Sold",   color = colOS,  linestyle = hline.style_solid,  linewidth = 1)

fill(hOB, hTop, color = color.new(colOB, 88), title = "Over Bought Zone")
fill(hBot, hOS, color = color.new(colOS, 88), title = "Over Sold Zone")

plot(rsi, title = "RSI", color = rsiColor, linewidth = 2)

// Signal markers on the RSI line (same bar as the chart signal)
plotshape(sellOK ? rsi : na, title = "Sell Signal (RSI)", style = shape.triangledown,
     location = location.absolute, color = colSell, size = size.small)
plotshape(buyOK ? rsi : na, title = "Buy Signal (RSI)", style = shape.triangleup,
     location = location.absolute, color = colBuy, size = size.small)

// ═══════════════════════════════════════════════════════════════════════════════════════
//  SESSION BOXES (drawn on the candle chart)
// ═══════════════════════════════════════════════════════════════════════════════════════
var SessionState asiaS = SessionState.new()
var SessionState lonS  = SessionState.new()
var SessionState nyS   = SessionState.new()
var SessionState lclS  = SessionState.new()

var array<box>   asiaBoxes = array.new<box>()
var array<label> asiaLbls  = array.new<label>()
var array<box>   lonBoxes  = array.new<box>()
var array<label> lonLbls   = array.new<label>()
var array<box>   nyBoxes   = array.new<box>()
var array<label> nyLbls    = array.new<label>()
var array<box>   lclBoxes  = array.new<box>()
var array<label> lclLbls   = array.new<label>()

// Creates a box when a session starts, grows it (high / low) while the session is active.
f_session(SessionState s, array<box> boxes, array<label> lbls, bool enabled, bool inSess, bool wasIn,
     string nm, color fillCol, color lineCol, color txtCol, int maxHist, int bw) =>
    if enabled and timeframe.isintraday
        if inSess and not wasIn
            s.hi := high
            s.lo := low
            s.t0 := time
            s.bx := box.new(left = time, top = high, right = nz(time_close, time), bottom = low,
                 border_color = lineCol, border_width = bw, xloc = xloc.bar_time,
                 bgcolor = fillCol, force_overlay = true)
            s.lb := label.new(x = time, y = high, text = nm, xloc = xloc.bar_time, yloc = yloc.price,
                 color = color.new(color.white, 100), style = label.style_label_down,
                 textcolor = txtCol, size = size.normal, force_overlay = true)
            boxes.push(s.bx)
            lbls.push(s.lb)
            if boxes.size() > maxHist
                box.delete(boxes.shift())
                label.delete(lbls.shift())
        else if inSess and not na(s.bx)
            s.hi := math.max(s.hi, high)
            s.lo := math.min(s.lo, low)
            box.set_top(s.bx, s.hi)
            box.set_bottom(s.bx, s.lo)
            box.set_right(s.bx, nz(time_close, time))
            int midT = int(math.round((s.t0 + time) / 2.0))
            label.set_xy(s.lb, midT, s.hi)
    true

// Session detection (timezone aware)
bool inAsia = not na(time(timeframe.period, asiaTime, tzInput))
bool inLon  = not na(time(timeframe.period, lonTime,  tzInput))
bool inNY   = not na(time(timeframe.period, nyTime,   tzInput))
bool inLcl  = not na(time(timeframe.period, lclTime,  tzInput))

f_session(asiaS, asiaBoxes, asiaLbls, asiaOn and showSessions, inAsia, inAsia[1], "ASIA",
     color.new(asiaCol, boxTransp), asiaCol, asiaTxt, histMax, boxBorder)
f_session(lonS, lonBoxes, lonLbls, lonOn and showSessions, inLon, inLon[1], "LONDON",
     color.new(lonCol, boxTransp), lonCol, lonTxt, histMax, boxBorder)
f_session(nyS, nyBoxes, nyLbls, nyOn and showSessions, inNY, inNY[1], "NEW YORK",
     color.new(nyCol, boxTransp), nyCol, nyTxt, histMax, boxBorder)
f_session(lclS, lclBoxes, lclLbls, lclOn and showSessions, inLcl, inLcl[1], "LONDON CLOSE",
     color.new(lclCol, boxTransp), lclCol, lclTxt, histMax, boxBorder)

// ═══════════════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════════════════
alertcondition(sellOK, "SELL Signal (any)", "RSI Signals with Sessions: SELL on {{ticker}} | Price {{close}} | TF {{interval}}")
alertcondition(buyOK,  "BUY Signal (any)",  "RSI Signals with Sessions: BUY on {{ticker}} | Price {{close}} | TF {{interval}}")
alertcondition(sellOK and touchOB, "SELL 80% - Over Bought touch", "RSI Signals with Sessions: SELL 80% (Over Bought) on {{ticker}} | Price {{close}} | TF {{interval}}")
alertcondition(sellOK and resSell, "SELL 70% - Resistance + Bearish candle", "RSI Signals with Sessions: SELL 70% (Resistance) on {{ticker}} | Price {{close}} | TF {{interval}}")
alertcondition(buyOK and touchOS,  "BUY 80% - Over Sold touch", "RSI Signals with Sessions: BUY 80% (Over Sold) on {{ticker}} | Price {{close}} | TF {{interval}}")
alertcondition(buyOK and supBuy,   "BUY 70% - Support + Bullish candle", "RSI Signals with Sessions: BUY 70% (Support) on {{ticker}} | Price {{close}} | TF {{interval}}")
````
