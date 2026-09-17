<!-- tradingview-pine-id: PUB;a583c07c2da94d148f367707ec5c6529 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MGC Precision Scalper (3-Min)

Source: https://www.tradingview.com/script/HS1hPk9f-MGC-Precision-Scalper-3-Min/

## Description

Gold Scout is a confluence-based scalping tool built and tested specifically

for Micro Gold Futures (MGC) on the 3-minute chart. It does not repaint:

every signal is evaluated only on barstate.isconfirmed, so what you see in

history is exactly what would have printed live.

HOW IT WORKS

Trend structure

The script plots a moving-average stack: SMA 9, SMA 20, EMA 65, EMA 86, and

SMA 200, plus a session VWAP with standard-deviation bands. A trend ribbon

fills the gap between SMA 20 and EMA 86, tinted green when the full bullish

stack is aligned (SMA20 > EMA65 > EMA86 with price above SMA200), red for

the mirrored bearish stack, and neutral gray otherwise.

Trigger

A Buy is triggered the same bar RSI(14) crosses above a configurable level

(default 60); a Sell triggers on RSI crossing below a configurable level

(default 40). Each side is "armed" only after RSI has first retreated

through the 50 midline, and a configurable cooldown (default 6 bars)

blocks re-firing immediately after a signal — this prevents rapid-fire

duplicate signals during choppy RSI oscillation around the trigger level.

Signal quality grading (this is the core idea of the script)

Every signal is scored, not just fired blind:

- Premium: full MA stack alignment + price beyond SMA200 + strong RSI

  momentum (>55 / <45 past the neutral line).

- Good: partial MA stack alignment + price on the correct side of SMA200.

- Basic: RSI cross valid, but weak or no moving-average confluence.

A "Minimum quality to show" input lets you hide Basic (and optionally

Good) signals so the chart only displays the setups you actually trade.

Noise filters

Two guards suppress low-quality environments before a signal can even

qualify:

- Chop filter: blocks signals when the SMA20-to-EMA86 gap is too small

  relative to ATR(14), i.e. the MAs are tangled together.

- Extension filter: blocks entries when price is already stretched too

  far from SMA20 relative to ATR — avoids chasing an exhausted move.

- RSI exhaustion filter: suppresses Buy when RSI is already deep

  overbought (default 82) and Sell when deep oversold (default 18).

Session and volume

An optional session window (default 09:30–16:00 America/New_York, both

configurable) restricts signals to a chosen window, and an optional volume

filter requires above-average volume before a signal counts. Because gold

futures trade nearly around the clock, adjust the session input to match

the hours you actually trade (e.g. COMEX floor hours, or London/NY overlap)

or disable "Only signal inside session" if you want 24-hour coverage.

Dashboard

A top-right table summarizes live state: session status, trend bias, VWAP

position, RSI value, ribbon/chop status, and the current quality grade for

both sides, so you can read market context at a glance instead of

reverse-engineering it from the chart.

Alerts

Six alert conditions are included, split by side and quality grade

(Premium / Good / Basic), so you can build alert workflows that only

notify you for the grade of setup you care about.

HOW TO USE IT

This is a discretionary confluence tool, not a mechanical buy/sell system,

tuned for MGC on the 3-minute timeframe. Treat a Premium signal as

"multiple independent conditions agree," Good as "partial agreement," and

Basic as "RSI trigger only — verify manually before acting." Combine it

with your own risk management, market context, and a higher-timeframe view.

Backtest and forward-test on a simulated account before using it with real

capital.

Note: This script and its outputs are for informational and educational purposes

only. Nothing here is financial advice, and past signal behavior on

historical bars is not a guarantee of future results.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("MGC Precision Scalper (3-Min)", shorttitle="Gold Scout", overlay=true, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════
//  INPUT GROUPS
// ═══════════════════════════════════════════════════════════════════
grpT = "Trend & Levels"
grpR = "RSI Trigger"
grpQ = "Signal Quality"
grpS = "Session"
grpC = "Colors"
grpD = "Display"

// ── Trend & Levels ─────────────────────────────────────────────────
showSma9      = input.bool(true,  "Show SMA 9",        group=grpT)
showSma20     = input.bool(true,  "Show SMA 20",       group=grpT)
showEma65     = input.bool(true,  "Show EMA 65",       group=grpT)
showEma86     = input.bool(true,  "Show EMA 86",       group=grpT)
showSma200    = input.bool(true,  "Show SMA 200",      group=grpT)
showVwap      = input.bool(true,  "Show Session VWAP", group=grpT)
showVwapBands = input.bool(true,  "Show VWAP Bands",   group=grpT)
vwapBandMult  = input.float(1.0,  "VWAP band std-dev multiplier", minval=0.5, maxval=3.0, step=0.25, group=grpT)

// ── RSI Trigger ────────────────────────────────────────────────────
rsiLen      = input.int(14,   "RSI length",                    minval=2,   maxval=50,  group=grpR)
rsiBuyLvl   = input.float(60.0,"Buy  — RSI crosses above",    minval=50.0,maxval=80.0,step=0.5, group=grpR, tooltip="Buy fires on the SAME candle RSI closes above this level.")
rsiSellLvl  = input.float(40.0,"Sell — RSI crosses below",    minval=20.0,maxval=50.0,step=0.5, group=grpR, tooltip="Sell fires on the SAME candle RSI closes below this level.")

// ── Signal Quality ─────────────────────────────────────────────────
minQuality  = input.int(1, "Minimum quality to show (1=all  2=good+  3=premium)", minval=1, maxval=3, group=grpQ,
     tooltip="1 = show all signals   2 = suppress basic, show Good + Premium only   3 = show Premium only.\nPremium = full EMA stack + SMA200 + strong RSI momentum.\nGood    = partial stack + RSI cross valid.\nBasic   = RSI cross only, weak confluence.")

chopATR     = input.float(0.10,"Chop block: min ribbon gap (x ATR14)", minval=0.0, maxval=1.0, step=0.01, group=grpQ,
     tooltip="SMA20 to EMA86 gap must exceed this x ATR14. Blocks signals when MAs are intertwined. Set 0 to disable.")
extATR      = input.float(3.00,"Chop block: max extension from SMA20 (x ATR14)", minval=0.5, maxval=8.0, step=0.1, group=grpQ,
     tooltip="Blocks entries when price is already stretched this far from SMA20 — avoids late exhaustion entries.")
rsiExhBull  = input.float(82.0,"Exhaustion block — overbought above", minval=70.0, maxval=95.0, step=1.0, group=grpQ,
     tooltip="Suppresses Buy when RSI is already extreme overbought.")
rsiExhBear  = input.float(18.0,"Exhaustion block — oversold below",   minval=5.0,  maxval=30.0, step=1.0, group=grpQ,
     tooltip="Suppresses Sell when RSI is already extreme oversold.")
cooldown    = input.int(6,     "Cooldown bars per side", minval=0, maxval=100, group=grpQ)
useVolGate  = input.bool(false,"Require above-average volume", group=grpQ)
volLen      = input.int(20,    "Volume MA length", minval=5, group=grpQ)
volMult     = input.float(1.10,"Volume multiplier", minval=0.5, maxval=3.0, step=0.05, group=grpQ)

// ── Session ────────────────────────────────────────────────────────
sess    = input.session("0930-1600",       "Trading session", group=grpS)
tz      = input.string("America/New_York", "Timezone",        group=grpS)
sessReq = input.bool(true, "Only signal inside session",      group=grpS)

// ── Colors ─────────────────────────────────────────────────────────
cPremium  = input.color(#00E5FF, "Premium signal (neon cyan)",  group=grpC)
cGood     = input.color(#39FF14, "Good signal (neon green)",    group=grpC)
cBasic    = input.color(#FF9800, "Basic signal (amber)",        group=grpC)
cSell     = input.color(#FF1744, "Sell signal (neon red)",      group=grpC)
cSellGood = input.color(#FF6D00, "Sell good (neon orange)",     group=grpC)
cSellBasic= input.color(#FF9800, "Sell basic (amber)",          group=grpC)
cSma9     = input.color(#00E5FF, "SMA 9 (neon cyan)",          group=grpC)
cSma20    = input.color(#FF1744, "SMA 20 (neon red)",           group=grpC)
cEma65    = input.color(#5D3A1A, "EMA 65 (dark brown)",         group=grpC)
cEma86    = input.color(#1CADA8, "EMA 86 (sky teal)",           group=grpC)
cSma200   = input.color(#E879A8, "SMA 200 (pink)",              group=grpC)
cVwap     = input.color(#22B8CF, "Session VWAP",               group=grpC)
cVwapBand = input.color(#22B8CF, "VWAP Bands",                 group=grpC)

// ── Display ────────────────────────────────────────────────────────
showSignals   = input.bool(true,  "Show Buy/Sell labels",      group=grpD)
showDash      = input.bool(true,  "Show dashboard",            group=grpD)
showRibbon    = input.bool(true,  "Show trend ribbon fill",    group=grpD)
showSessShade = input.bool(false, "Shade trading session",     group=grpD)
dashTrans     = input.int(60, "Dashboard transparency", minval=0, maxval=90, group=grpD)

// ═══════════════════════════════════════════════════════════════════
//  CORE SERIES
// ═══════════════════════════════════════════════════════════════════
sma9v   = ta.sma(close, 9)
sma20v  = ta.sma(close, 20)
ema65v  = ta.ema(close, 65)
ema86v  = ta.ema(close, 86)
sma200v = ta.sma(close, 200)
atr14v  = ta.atr(14)
rsiv    = ta.rsi(close, rsiLen)
volSmav = ta.sma(volume, volLen)
highVol = volume > volSmav * volMult

// ── Session VWAP + Std-Dev Bands ──────────────────────────────────
inSess  = not na(time(timeframe.period, sess, tz))
sessNew = inSess and not inSess[1]

var float cumPV  = 0.0
var float cumV   = 0.0
var float cumPV2 = 0.0
if sessNew
    cumPV  := hlc3 * nz(volume)
    cumV   := nz(volume)
    cumPV2 := hlc3 * hlc3 * nz(volume)
else if inSess
    cumPV  += hlc3 * nz(volume)
    cumV   += nz(volume)
    cumPV2 += hlc3 * hlc3 * nz(volume)

vwapv      = cumV > 0 ? cumPV / cumV : na
vwapVar    = cumV > 0 ? math.max(cumPV2 / cumV - vwapv * vwapv, 0.0) : na
vwapSD     = not na(vwapVar) ? math.sqrt(vwapVar) : na
vwapUpper  = not na(vwapv) and not na(vwapSD) ? vwapv + vwapBandMult * vwapSD : na
vwapLower  = not na(vwapv) and not na(vwapSD) ? vwapv - vwapBandMult * vwapSD : na

// ═══════════════════════════════════════════════════════════════════
//  SIGNAL QUALITY SCORING
// ═══════════════════════════════════════════════════════════════════
bullFullStack  = sma20v > ema65v and ema65v > ema86v and close > sma200v
bullPartStack  = sma20v > ema65v or sma20v > ema86v
sma200abv      = close > sma200v
rsiBullMom     = rsiv > 55.0

bearFullStack  = sma20v < ema65v and ema65v < ema86v and close < sma200v
bearPartStack  = sma20v < ema65v or sma20v < ema86v
sma200blw      = close < sma200v
rsiBearMom     = rsiv < 45.0

buyQuality  = bullFullStack and rsiBullMom ? 3 : bullPartStack and sma200abv ? 2 : 1
sellQuality = bearFullStack and rsiBearMom ? 3 : bearPartStack and sma200blw  ? 2 : 1

// ═══════════════════════════════════════════════════════════════════
//  CHOP / EXHAUSTION GUARDS
// ═══════════════════════════════════════════════════════════════════
ribbonGap  = math.abs(sma20v - ema86v)
notChop    = chopATR <= 0.0 or ribbonGap >= chopATR * atr14v

extDist    = math.abs(close - sma20v)
notExtBull = extDist < extATR * atr14v or close <= sma20v
notExtBear = extDist < extATR * atr14v or close >= sma20v

notExhBull = rsiv < rsiExhBull
notExhBear = rsiv > rsiExhBear

volOk   = not useVolGate or highVol
sessOk  = not sessReq or inSess

// ═══════════════════════════════════════════════════════════════════
//  RSI CROSS TRIGGERS — SAME CANDLE FIRE
// ═══════════════════════════════════════════════════════════════════
rsiBuyCross  = ta.crossover(rsiv,  rsiBuyLvl)
rsiSellCross = ta.crossunder(rsiv, rsiSellLvl)

var bool armBuy  = true
var bool armSell = true
if ta.crossunder(rsiv, 50.0)
    armBuy := true
if ta.crossover(rsiv, 50.0)
    armSell := true

var int lastBuyBar  = na
var int lastSellBar = na
coolOkBuy  = na(lastBuyBar)  or (bar_index - lastBuyBar  >= cooldown)
coolOkSell = na(lastSellBar) or (bar_index - lastSellBar >= cooldown)

buyValid  = barstate.isconfirmed and sessOk and rsiBuyCross  and notChop and notExtBull and notExhBull and armBuy  and coolOkBuy  and volOk
sellValid = barstate.isconfirmed and sessOk and rsiSellCross and notChop and notExtBear and notExhBear and armSell and coolOkSell and volOk

buyShow  = buyValid  and buyQuality  >= minQuality
sellShow = sellValid and sellQuality >= minQuality

if buyShow
    armBuy     := false
    lastBuyBar := bar_index
if sellShow
    armSell     := false
    lastSellBar := bar_index

// ═══════════════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════════════
pS20  = plot(showSma20  ? sma20v  : na, "SMA 20",  color=cSma20,                linewidth=2)
pE86  = plot(showEma86  ? ema86v  : na, "EMA 86",  color=cEma86,                linewidth=2)
pE65  = plot(showEma65  ? ema65v  : na, "EMA 65",  color=cEma65,                linewidth=2)
pS9   = plot(showSma9   ? sma9v   : na, "SMA 9",   color=color.new(cSma9, 10),  linewidth=1)
pS200 = plot(showSma200 ? sma200v : na, "SMA 200", color=color.new(cSma200, 5), linewidth=3)
pVwap = plot(showVwap   ? vwapv   : na, "VWAP",    color=cVwap,                 linewidth=2, style=plot.style_circles)
pVwapU = plot(showVwapBands ? vwapUpper : na, "VWAP Upper", color=color.new(cVwapBand, 45), linewidth=1)
pVwapL = plot(showVwapBands ? vwapLower : na, "VWAP Lower", color=color.new(cVwapBand, 45), linewidth=1)

fill(pVwapU, pVwapL, showVwapBands ? color.new(cVwapBand, 92) : na, title="VWAP band fill")

ribbonFill = bullFullStack ? color.new(cGood, 88) : bearFullStack ? color.new(cSell, 90) : color.new(#8B95A5, 95)
fill(pS20, pE86, showRibbon ? ribbonFill : na, title="Trend ribbon")

bgcolor(showSessShade and inSess ? color.new(#5B9CF6, 97) : na, title="Session shade")

// ═══════════════════════════════════════════════════════════════════
//  SIGNAL LABELS
// ═══════════════════════════════════════════════════════════════════
buyColor  = buyQuality  == 3 ? cPremium  : buyQuality  == 2 ? cGood   : cBasic
sellColor = sellQuality == 3 ? cSell     : sellQuality == 2 ? cSellGood : cSellBasic

plotshape(showSignals and buyShow,
     title="Buy",  style=shape.labelup,   location=location.belowbar,
     color=buyColor,  textcolor=color.white, text="Buy",  size=size.small)

plotshape(showSignals and sellShow,
     title="Sell", style=shape.labeldown,  location=location.abovebar,
     color=sellColor, textcolor=color.white, text="Sell", size=size.small)

// ═══════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════════
var table dash = table.new(
     position.top_right, 2, 8,
     bgcolor      = color.new(#0D1117, dashTrans),
     frame_color  = color.new(#30363D, 30),
     frame_width  = 1,
     border_color = color.new(#30363D, 50),
     border_width = 1)

cHdr  = color.new(#1C6EF2, 70)
cMute = color.new(#8B949E, 0)
dbg   = color.new(#0D1117, dashTrans)

biasText  = bullFullStack ? "Bullish" : bearFullStack ? "Bearish" : bullPartStack ? "Mild bull" : bearPartStack ? "Mild bear" : "Neutral"
biasCol   = bullFullStack ? cGood     : bearFullStack ? cSell      : bullPartStack ? color.new(cGood,40) : bearPartStack ? color.new(cSell,40) : cMute
vwapText  = na(vwapv) ? "n/a"   : close > vwapv ? "Above"  : "Below"
vwapCol   = na(vwapv) ? cMute   : close > vwapv ? cGood    : cSell
rsiStr    = str.tostring(rsiv, "#.1")
rsiCol    = rsiv >= 60 ? cPremium : rsiv <= 40 ? cSell : rsiv >= 50 ? cGood : cMute
chopStr   = notChop    ? "Clear"  : "Chop"
chopCol   = notChop    ? cGood    : cBasic
bqStr     = buyQuality  == 3 ? "Premium" : buyQuality  == 2 ? "Good" : "Basic"
sqStr     = sellQuality == 3 ? "Premium" : sellQuality == 2 ? "Good" : "Basic"
sigText   = buyShow    ? "Buy (" + bqStr + ")"  : sellShow ? "Sell (" + sqStr + ")" : "Waiting"
sigCol    = buyShow    ? buyColor : sellShow ? sellColor : cMute
minQStr   = minQuality == 3 ? "Premium only" : minQuality == 2 ? "Good+" : "All"

if barstate.islast and showDash
    table.cell(dash, 0, 0, "Gold Scout", text_color=color.white,  text_size=size.small, bgcolor=cHdr)
    table.cell(dash, 1, 0, inSess ? "RTH" : "Off-hrs", text_color=inSess ? cGood : cMute, text_size=size.small, bgcolor=cHdr)
    table.cell(dash, 0, 1, "Bias",       text_color=cMute, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 1, biasText,     text_color=biasCol, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 0, 2, "VWAP",       text_color=cMute, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 2, vwapText,     text_color=vwapCol, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 0, 3, "RSI",        text_color=cMute, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 3, rsiStr,       text_color=rsiCol, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 0, 4, "Ribbon",     text_color=cMute, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 4, chopStr,      text_color=chopCol, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 0, 5, "Buy quality",  text_color=cMute, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 5, bqStr,          text_color=buyQuality==3?cPremium:buyQuality==2?cGood:cBasic, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 0, 6, "Sell quality", text_color=cMute, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 6, sqStr,          text_color=sellQuality==3?cSell:sellQuality==2?cSellGood:cSellBasic, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 0, 7, "Filter",      text_color=cMute, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 7, minQStr,       text_color=cMute, text_size=size.small, bgcolor=dbg)
else if barstate.islast
    table.clear(dash, 0, 0, 1, 7)

// ═══════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════
alertcondition(buyShow  and buyQuality  == 3, title="Buy  — Premium", message="Gold Scout PREMIUM BUY on {{ticker}} {{interval}}: RSI x above 60, full stack confirmed.")
alertcondition(buyShow  and buyQuality  == 2, title="Buy  — Good",    message="Gold Scout GOOD BUY on {{ticker}} {{interval}}: RSI x above 60, partial stack.")
alertcondition(buyShow  and buyQuality  == 1, title="Buy  — Basic",   message="Gold Scout BASIC BUY on {{ticker}} {{interval}}: RSI x above 60, weak confluence.")
alertcondition(sellShow and sellQuality == 3, title="Sell — Premium", message="Gold Scout PREMIUM SELL on {{ticker}} {{interval}}: RSI x below 40, full stack confirmed.")
alertcondition(sellShow and sellQuality == 2, title="Sell — Good",    message="Gold Scout GOOD SELL on {{ticker}} {{interval}}: RSI x below 40, partial stack.")
alertcondition(sellShow and sellQuality == 1, title="Sell — Basic",   message="Gold Scout BASIC SELL on {{ticker}} {{interval}}: RSI x below 40, weak confluence.")
````
