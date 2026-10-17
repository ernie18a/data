# Respected MA Detector 

- url: https://www.tradingview.com/script/7ErIreay-Respected-MA-Detector/
- type: indicator
- pine_id: PUB;7f1c359d1ab34be18df51cfeb5a13255
- version: 1.0

## Description

RESPECTED MA DETECTOR

Most traders run a stack of moving averages and eyeball which one price is "respecting". This indicator does that job for you. An idea spawned from Qullamaggie lore, It works out which MA the current trend is actually riding, shows only that line, and walks the trail up or down the ladder as the trend strengthens or weakens.

HOW IT WORKS

You set up to four moving averages, fast to slow. Each can be EMA or SMA and can be switched off. The defaults are EMA 10 / 15 / 20 / 43. Separate to Qullamaggie who lists the 10 / 20 DEMA and the 50 DMA, I have added the 15 ema (which can be toggled off) and the 43 ema ( which I believe works better than the 50sma

An MA counts as "held" when both of these are true:
- Price closes at or above it, allowing a small dip below measured in ATR (Hold tolerance based on volatility of the stock).
- The MA itself is rising, meaning it is above its value from X bars ago (Slope lookback).

The trail then follows a simple ladder:
- Start: when no ride is active, the trail attaches to the fastest MA that is currently held.
- Tighten: if a faster MA has been held for a set number of consecutive bars (Bars to tighten), the trail steps up to it.
- Step down: if price closes below the current MA by more than the Break threshold (in ATR), the trail drops to the next slower MA that is still held.
- Out of play: if the break happens on the slowest enabled MA (the cut-off), or no slower MA is holding, the ride ends. The line stops, and a new ride begins as soon as any MA is held again.

Because the hold and break rules are scaled by ATR, the logic adapts to each instrument's volatility. It doesn't rely on fixed percentages.

WHAT YOU SEE

- Only the MA currently being ridden is plotted, coloured by which rung of the ladder it is on.
- A short connecting segment marks each step between MAs.
- There is a gap after an exit, so each new ride starts fresh.
- A label on the last bar shows the active MA, for example "EMA 20", or "Out of play".

HOW TO USE IT

- Trend health at a glance: riding the fastest MA means strong momentum. A step down to slower MAs means the trend is losing pace.
- Trailing stop reference: the plotted line is a ready-made, adaptive trail for managing open positions.
- Watchlist filter: "Out of play" quickly tells you a name has lost its trend structure.
- Untick any MA to remove it from the ladder. The slowest ticked MA automatically becomes the cut-off.
*Note: This is not financial advice and is merely a suggestion on how to use. Please do your research and find the solution that best fits your trading strategy.

ALERTS

- Stepped down: the trail moved to a slower MA.
- On the cut-off: the trail is on the slowest enabled MA, the last line of defence.
- Out of play: price closed below the cut-off by the ATR threshold.

NOTES

- All logic uses closing prices. Signals on the live bar can change until that bar closes.
- Works on any timeframe and market. Tune the MA lengths and ATR settings to match your holding period.

This script is a tool for reading trend structure, not a standalone trading system or financial advice. Always backtest and manage your risk.

## Source Code

````pine
//@version=6
indicator("Respected MA Detector ", shorttitle = "Respected MA", overlay=true, max_labels_count=100, max_lines_count=500)

// ===== Moving averages (fast → slow) =====
g1 = "Moving Averages"
e1 = input.bool(true, "", inline="m1", group=g1)
l1 = input.int(10, "MA1 length", minval=1, inline="m1", group=g1)
t1 = input.string("EMA", "", options=["EMA","SMA"], inline="m1", group=g1)
e2 = input.bool(true, "", inline="m2", group=g1)
l2 = input.int(15, "MA2 length", minval=1, inline="m2", group=g1)
t2 = input.string("EMA", "", options=["EMA","SMA"], inline="m2", group=g1)
e3 = input.bool(true, "", inline="m3", group=g1)
l3 = input.int(20, "MA3 length", minval=1, inline="m3", group=g1)
t3 = input.string("EMA", "", options=["EMA","SMA"], inline="m3", group=g1)
e4 = input.bool(true, "", inline="m4", group=g1)
l4 = input.int(43, "MA4 length", minval=1, inline="m4", group=g1, tooltip="Untick any MA to drop it from the ladder. The slowest ticked MA becomes the cut-off; the fastest ticked MA is where a ride can start highest.")
t4 = input.string("EMA", "", options=["EMA","SMA"], inline="m4", group=g1)

maf(len, typ) => typ == "EMA" ? ta.ema(close, len) : ta.sma(close, len)
ma1 = maf(l1, t1)
ma2 = maf(l2, t2)
ma3 = maf(l3, t3)
ma4 = maf(l4, t4)

// slowest enabled MA = cut-off
int lastIdx = e4 ? 3 : e3 ? 2 : e2 ? 1 : e1 ? 0 : -1

// ===== Detection =====
g2 = "Detection"
slopeLen    = input.int(5,    "Slope lookback", minval=1, group=g2, tooltip="MA must be above its value this many bars ago to count as rising")
atrLen      = input.int(14,   "ATR length", minval=1, group=g2)
touchZone   = input.float(0.25,"Hold tolerance (ATR)", minval=0.0, step=0.05, group=g2, tooltip="Price can dip this far below an MA and still count as holding it")
breakThr    = input.float(0.5, "Break threshold (ATR)", minval=0.0, step=0.05, group=g2, tooltip="Close this far below the current MA = decisively lost. On the cut-off MA this ends the ride.")
confirmBars = input.int(2,    "Bars to tighten", minval=1, group=g2, tooltip="Bars a faster MA must hold before the trail tightens up to it")

atr = ta.atr(atrLen)

// a disabled MA never counts as holding, so the ladder skips it
hold1 = e1 and close >= ma1 - touchZone*atr and ma1 > ma1[slopeLen]
hold2 = e2 and close >= ma2 - touchZone*atr and ma2 > ma2[slopeLen]
hold3 = e3 and close >= ma3 - touchZone*atr and ma3 > ma3[slopeLen]
hold4 = e4 and close >= ma4 - touchZone*atr and ma4 > ma4[slopeLen]

// consecutive bars each MA has been held
var int h1 = 0
var int h2 = 0
var int h3 = 0
var int h4 = 0
h1 := hold1 ? h1 + 1 : 0
h2 := hold2 ? h2 + 1 : 0
h3 := hold3 ? h3 + 1 : 0
h4 := hold4 ? h4 + 1 : 0

maAt(i)   => i==0 ? ma1   : i==1 ? ma2   : i==2 ? ma3   : i==3 ? ma4   : na
holdAt(i) => i==0 ? hold1 : i==1 ? hold2 : i==2 ? hold3 : i==3 ? hold4 : false
hAt(i)    => i==0 ? h1    : i==1 ? h2    : i==2 ? h3    : i==3 ? h4    : 0

int fastestHeld = hold1 ? 0 : hold2 ? 1 : hold3 ? 2 : hold4 ? 3 : -1

// ===== State machine: fastest enabled → ... → cut-off → out =====
var int curr = -1
bool brokeCur = curr == -1 ? true : close < maAt(curr) - breakThr*atr

if curr == -1
    curr := fastestHeld
else if brokeCur
    // step down to the next slower enabled MA that's still holding; none left = out of play
    int nxt = -1
    if curr < 3
        for j = curr + 1 to 3
            if holdAt(j)
                nxt := j
                break
    curr := nxt
else if curr > 0
    // tighten up to the fastest enabled MA that has held long enough
    int tgt = curr
    for j = 0 to curr - 1
        if holdAt(j) and hAt(j) >= confirmBars
            tgt := j
            break
    curr := tgt

// ===== Resolve the ridden MA =====
float  trail = curr == -1 ? na : maAt(curr)
int    trLen = curr==0 ? l1 : curr==1 ? l2 : curr==2 ? l3 : curr==3 ? l4 : na
string trTy  = curr==0 ? t1 : curr==1 ? t2 : curr==2 ? t3 : curr==3 ? t4 : ""

// ===== Transitions (alerts only) =====
exited   = curr == -1 and curr[1] != -1
loosened = curr != -1 and curr[1] != -1 and curr > curr[1]
toLast   = curr == lastIdx and curr[1] != lastIdx and curr[1] != -1

// ===== Plot =====
g3 = "Colours & widths"
c1 = input.color(color.white, "MA1", inline="c1", group=g3)
w1 = input.int(3, "Width", minval=1, maxval=10, inline="c1", group=g3)
c2 = input.color(#fbc02d,     "MA2", inline="c2", group=g3)
w2 = input.int(3, "Width", minval=1, maxval=10, inline="c2", group=g3)
c3 = input.color(#e65100,     "MA3", inline="c3", group=g3)
w3 = input.int(3, "Width", minval=1, maxval=10, inline="c3", group=g3)
c4 = input.color(#f23645,     "MA4", inline="c4", group=g3)
w4 = input.int(3, "Width", minval=1, maxval=10, inline="c4", group=g3)

trailCol = curr==3 ? c4 : curr==2 ? c3 : curr==1 ? c2 : c1
trailW   = curr==3 ? w4 : curr==2 ? w3 : curr==1 ? w2 : w1

// one plot per MA so each shows separately in the Style tab
plot(curr==0 ? ma1 : na, "Trail MA1", c1, w1, style=plot.style_linebr)
plot(curr==1 ? ma2 : na, "Trail MA2", c2, w2, style=plot.style_linebr)
plot(curr==2 ? ma3 : na, "Trail MA3", c3, w3, style=plot.style_linebr)
plot(curr==3 ? ma4 : na, "Trail MA4", c4, w4, style=plot.style_linebr)

// join the step between MAs; no join after the cut-off is lost, so the next ride starts fresh
float prevTrail = trail[1]
if curr != -1 and curr[1] != -1 and curr != curr[1]
    line.new(bar_index - 1, prevTrail, bar_index, trail, color=trailCol, width=trailW)

// ===== Label =====
var label lb = na
if barstate.islast
    label.delete(lb)
    string txt = curr == -1 ? "Out of play " : " " + trTy + " " + str.tostring(trLen) + "   "
    lb := label.new(bar_index + 1, curr==-1 ? high : trail, txt, style=label.style_label_left, color = curr==-1 ? color.gray : trailCol, textcolor = curr==-1 ? color.white : color.black, size=size.small)

// ===== Alerts =====
alertcondition(loosened, "Stepped down", "Trail stepped down to a slower MA")
alertcondition(toLast,   "On the cut-off", "Trail is on the slowest enabled MA — last line of defence")
alertcondition(exited,   "Out of play",  "Closed below the cut-off MA by the ATR threshold — out of play")
````
