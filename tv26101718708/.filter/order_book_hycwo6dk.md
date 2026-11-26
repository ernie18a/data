# ORDER BOOK

- url: https://www.tradingview.com/script/hyCWo6DK-ORDER-BOOK/
- type: indicator
- pine_id: PUB;de0d69adcb364ce6ade0d3c1818b52b1
- version: 1.0

## Description

order book vp

order book vp is a visual trading tool designed to read volume, buy pressure, sell pressure, and important price zones directly on the chart.

it combines a visual order book panel, a volume profile, an intrabar buy / sell engine, delta tracking, poc, value area, hvn / lvn zones, quantity labels on candles, and a compact dashboard.

the goal is simple: help the trader see where volume is building, where price is reacting, where buyers dominate, where sellers dominate, and which price zones can become important decision areas.

important: pine script does not have access to real level 2 order book data or resting limit orders. this tool does not display real exchange depth. it builds an order book style view from traded volume, volume-at-price, and intrabar analysis.

this gives a clean reading of traded flow, not a promise of real exchange order book depth.

---

main features

order book panel
shows a price ladder with levels around the current price. levels above price represent ask / sell pressure. levels below price represent bid / buy pressure.

fast order book effect
adds a fast reactive effect to the panel. the panel reacts to current buy / sell pressure, volume, candle body, and close position inside the candle.

volume profile
displays traded volume by price level. this helps identify where the market has exchanged the most volume.

poc
the point of control shows the price level with the highest volume inside the selected lookback window. it is often an equilibrium, reaction, or decision zone.

vah and val
vah is the upper boundary of the value area.
val is the lower boundary of the value area.
these levels help define the main area where the market built volume.

hvn and lvn
hvn means high volume node.
lvn means low volume node.
hvn zones can act as acceptance areas. lvn zones can act as rejection areas, acceleration zones, or liquidity gaps.

quantity labels
shows traded quantity on recent candles, with delta if enabled. green labels show buy dominance. red labels show sell dominance.

delta candle coloring
colors candles based on buy / sell delta dominance.

dashboard
summarizes important data: poc, vah, val, current candle buy / sell, delta, cvd, pressure, and intrabar source.

---

inputs guide

intrabar timeframe
lower timeframe used to estimate buy and sell volume. the lower the timeframe, the more detailed the reading. for example, on a 15 minute chart, using 1 minute gives a finer intrabar view.

lookback
number of candles used to build the volume profile. a higher value gives a broader view. a lower value makes the profile more reactive.

price levels
number of rows used in the volume profile. more rows give more precision, but also use more resources.

show order book panel
turns the order book panel on or off.

visible levels
number of price levels displayed inside the order book panel.

depth bar length
visual length of the depth bars inside the order book panel.

panel position
sets the position of the order book panel on the chart.

detect walls
enables detection of large volume levels.

wall multiplier
defines when a level is considered a wall compared to average level volume.

fast order book effect
turns on the fast reactive order book effect.

fast effect power
makes the order book effect more or less aggressive. higher values make the panel react faster.

fast level decay
controls how far the fast pressure effect spreads around the current price.

flash active levels
highlights active levels when buy or sell pressure is strong.

show volume profile
turns the volume profile on or off.

split buy / sell
splits the profile into buy volume and sell volume.

profile width
sets the visual width of the volume profile.

profile offset
sets the visual offset used for profile elements.

show poc
shows the point of control.

show value area
shows vah and val.

value area percent
sets the percentage used to calculate the value area.

mark hvn / lvn
shows high volume nodes and low volume nodes.

hvn multiplier
sets the threshold for high volume nodes.

lvn multiplier
sets the threshold for low volume nodes.

vp buy opacity
controls the opacity of the buy side of the volume profile.

vp sell opacity
controls the opacity of the sell side of the volume profile.

show quantity labels
turns quantity labels on or off.

on last n candles
defines how many recent candles display quantity labels.

show delta
shows buy minus sell delta inside the quantity labels.

quantity label spacing
increases or decreases the distance between candle labels and candles.

color candles by delta
colors candles based on delta dominance.

show dashboard
turns the small information panel on or off.

dashboard position
sets the position of the dashboard.

strong bar ratio
sets the threshold used for strong buy or strong sell alerts.

bid / buy
sets the buy side color.

ask / sell
sets the sell side color.

poc / accent
sets the poc and main accent color.

neutral
sets the neutral color.

---

how to use order book vp

start by choosing the asset and timeframe that match your trading style.

for scalping, use 1 minute, 3 minutes, 5 minutes, or 15 minutes.
for intraday trading, use 15 minutes, 30 minutes, or 1 hour.
for swing trading, use 4 hours or daily.

turn on the volume profile and watch the poc.
when price stays around the poc, the market is often balanced.
when price moves far away from the poc, the market may be in a displacement phase.

watch vah and val.
between vah and val, price is inside the main value area.
above vah, the market may be in bullish expansion or excess.
below val, the market may be in bearish expansion or excess.

watch hvn zones.
an hvn is a zone where a lot of volume was traded. price can return to this area because it represents acceptance.

watch lvn zones.
an lvn is a zone where little volume was traded. price can move quickly through these areas because there is less acceptance.

watch the order book panel.
if buy levels become stronger below price, it can show buying pressure.
if sell levels become stronger above price, it can show selling pressure.

watch the candle quantity labels.
positive delta means more buy volume.
negative delta means more sell volume.
if price rises with positive delta, buyers are supporting the move.
if price rises while delta turns negative, it can show weakness or absorption.

watch cvd inside the dashboard.
rising cvd shows cumulative buy pressure.
falling cvd shows cumulative sell pressure.

---

simple beginner workflow

1. find the poc.
2. find vah and val.
3. check if price is inside or outside the value area.
4. check if the order book panel shows more buy pressure or sell pressure.
5. confirm with the quantity labels on candles.
6. look for reactions around poc, vah, val, hvn, or lvn.
7. always use a stop loss and risk management.

---

scalping example

on a lower timeframe, order book vp can help identify fast reaction zones.

example:
price comes into val.
the order book panel shows buy pressure.
candle labels show positive delta.
price rejects val.

this can become a long scalp observation zone if market structure confirms.

another example:
price comes into vah.
the order book panel shows sell pressure.
candle labels turn red.
price rejects vah.

this can become a short scalp observation zone if market structure confirms.

---

intraday example

on a medium timeframe, the tool helps identify important volume zones.

if price returns to the poc, it may react because this level is the center of traded volume.
if price breaks above vah with buy pressure, continuation can become possible.
if price breaks below val with sell pressure, bearish continuation can become possible.

---

swing trading example

on higher timeframes, the volume profile helps identify major acceptance and rejection zones.

hvn zones can act as return zones.
lvn zones can act as acceleration zones.
the poc can act as a major equilibrium level.

---

beginner settings

intrabar timeframe: 1
lookback: 300
price levels: 80
visible levels: 16
show order book panel: on
fast order book effect: on
show volume profile: on
split buy / sell: on
show poc: on
show value area: on
mark hvn / lvn: on
vp buy opacity: 25
vp sell opacity: 25
show quantity labels: on
show delta: on
color candles by delta: off
show dashboard: on

this setup keeps the chart complete while staying readable.

---

important notes

do not take a trade only because the panel turns green or red.

use the panel as pressure confirmation, not as a standalone signal.

the most important levels to watch are usually poc, vah, val, hvn, and lvn.

a clean reaction on a level with matching delta is more useful than an isolated signal.

the larger the volume window, the more important the level can become.

order book vp is built to give a clear view of traded flow, volume by price, and buy / sell pressure, so the chart becomes a decision map instead of a random price display.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("ORDER BOOK", shorttitle="ORDERBOOK", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ════════════════════════════════════════════════════════════════════════════
gE = "═══ FLOW ENGINE ═══"
ltf     = input.timeframe("1", "Intrabar Timeframe", group=gE, tooltip="Lower timeframe used to estimate buy/sell volume. Must be lower than the chart TF; if not, falls back to whole-bar classification.")
vpLen   = input.int(300, "Lookback (bars)",  minval=20, maxval=1000, group=gE)
nLevels = input.int(80,  "Price Levels (rows)", minval=6, maxval=200, group=gE)

gDom = "═══ DOM PANEL (Binance style) ═══"
showDOM   = input.bool(true, "Show Order Book Panel", group=gDom)
domLevels = input.int(16, "Visible Levels (even)", minval=4, maxval=40, group=gDom)
barChars  = input.int(12, "Depth Bar Length",      minval=4, maxval=30, group=gDom)
domPos    = input.string("Bottom Right", "Panel Position", options=["Right","Left","Top Right","Top Left","Bottom Right","Bottom Left"], group=gDom)
showWalls = input.bool(true, "Detect Walls",        group=gDom)
wallMult  = input.float(2.0, "Wall = × avg level vol", minval=1.1, step=0.1, group=gDom)
fastDOM   = input.bool(true, "Fast Order Book Effect", group=gDom, tooltip="Adds a fast reactive DOM effect based on current intrabar buy/sell pressure. This is still traded volume-at-price, not real level-2 resting orders.")
fastPower = input.float(2.2, "Fast Effect Power", minval=0.1, maxval=8.0, step=0.1, group=gDom, tooltip="Higher values make the displayed order book react more aggressively to current buy/sell pressure.")
fastDecay = input.float(0.72, "Fast Level Decay", minval=0.10, maxval=0.98, step=0.01, group=gDom, tooltip="Controls how far the fast pulse spreads away from the current price level. Lower = tighter. Higher = wider.")
flashDOM  = input.bool(true, "Flash Active Levels", group=gDom, tooltip="Highlights active levels when fast buy/sell pressure expands the DOM rows.")

gVp = "═══ VOLUME PROFILE ═══"
showVP    = input.bool(true, "Show Volume Profile", group=gVp)
splitDelta= input.bool(true, "Split Buy / Sell (delta profile)", group=gVp)
vpWidth   = input.int(60, "Profile Width (bars)", minval=10, maxval=200, group=gVp)
vpOffset  = input.int(8,  "Profile Offset (bars)", minval=0, maxval=100, group=gVp)
vpBuyOpacity  = input.int(25, "VP Buy Opacity %", minval=0, maxval=100, group=gVp)
vpSellOpacity = input.int(25, "VP Sell Opacity %", minval=0, maxval=100, group=gVp)
showPOC   = input.bool(true, "Show POC", group=gVp)
showVA    = input.bool(true, "Show Value Area (VAH/VAL)", group=gVp)
vaPct     = input.float(70, "Value Area %", minval=30, maxval=95, group=gVp)
showNodes = input.bool(true, "Mark HVN / LVN", group=gVp)
hvnMult   = input.float(1.5, "HVN ≥ × avg", minval=1.0, step=0.1, group=gVp)
lvnMult   = input.float(0.4, "LVN ≤ × avg", minval=0.05, step=0.05, group=gVp)
maxNodes  = input.int(4, "Max HVN / LVN Per Type", minval=1, maxval=20, group=gVp)

gQty = "═══ QUANTITY ON CANDLES ═══"
showQty    = input.bool(true,  "Show Quantity Labels", group=gQty)
qtyBars    = input.int(30, "On last N candles", minval=1, maxval=200, group=gQty)
qtyDelta   = input.bool(true,  "Show Delta (buy-sell)", group=gQty)
colorBars  = input.bool(false, "Color Candles by Delta", group=gQty)
qtySpacing = input.float(0.35, "Quantity Label Spacing (× ATR)", minval=0.0, maxval=5.0, step=0.05, group=gQty)

gUi = "═══ DISPLAY ═══"
showDash = input.bool(true, "Show Dashboard", group=gUi)
dashPos  = input.string("Top Right", "Dashboard Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=gUi)
strongR  = input.float(2.0, "Strong Bar ratio (alerts)", minval=1.1, step=0.1, group=gUi)

gC = "═══ AESTHETICS ═══"
colBid = input.color(#00FFD1, "Bid / Buy",  group=gC)
colAsk = input.color(#FF3B5C, "Ask / Sell", group=gC)
colPoc = input.color(#FFD23F, "POC / Accent", group=gC)
colNeu = input.color(#9AB0C7, "Neutral", group=gC)
panelGrey = #8A929D
panelTitle = #C7CDD6

// ════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ════════════════════════════════════════════════════════════════════════════
f2s(float x) => na(x) ? "—" : str.tostring(x, format.mintick)
fmtVol(float v) =>
    a = math.abs(v)
    a >= 1e9 ? str.tostring(v / 1e9, "0.00") + "B" : a >= 1e6 ? str.tostring(v / 1e6, "0.00") + "M" : a >= 1e3 ? str.tostring(v / 1e3, "0.0") + "K" : str.tostring(v, "0.#")
depthBar(float v, float mx, int maxc) =>
    n = mx > 0 ? int(math.round(v / mx * maxc)) : 0
    v > 0 and n < 1 ? "▏" : str.repeat("█", math.max(0, n))
clamp(float x, float lo, float hi) => math.max(lo, math.min(nz(x, 0.0), hi))

clearBoxes(array<box> a) =>
    for x in a
        box.delete(x)
    array.clear(a)
clearLines(array<line> a) =>
    for x in a
        line.delete(x)
    array.clear(a)
clearLabels(array<label> a) =>
    for x in a
        label.delete(x)
    array.clear(a)

// ════════════════════════════════════════════════════════════════════════════
//  BUY / SELL ENGINE (intrabar via request.security_lower_tf)
// ════════════════════════════════════════════════════════════════════════════
aClose = request.security_lower_tf(syminfo.tickerid, ltf, close)
aOpen  = request.security_lower_tf(syminfo.tickerid, ltf, open)
aVol   = request.security_lower_tf(syminfo.tickerid, ltf, volume)

bV = 0.0
sV = 0.0
nlt = array.size(aVol)
if nlt > 0
    for i = 0 to nlt - 1
        vv = array.get(aVol, i)
        if not na(vv)
            if array.get(aClose, i) >= array.get(aOpen, i)
                bV += vv
            else
                sV += vv
else
    if close >= open
        bV := nz(volume)
    else
        sV := nz(volume)

var float cvd = 0.0
cvd += bV - sV

var array<float> sHi  = array.new<float>()
var array<float> sLo  = array.new<float>()
var array<float> sVol = array.new<float>()
var array<float> sBuy = array.new<float>()
var array<float> sSell= array.new<float>()

array.push(sHi, high)
array.push(sLo, low)
array.push(sVol, nz(volume))
array.push(sBuy, bV)
array.push(sSell, sV)
if array.size(sHi) > vpLen
    array.shift(sHi)
    array.shift(sLo)
    array.shift(sVol)
    array.shift(sBuy)
    array.shift(sSell)

barcolor(colorBars ? (bV >= sV ? colBid : colAsk) : na)
qtyGap = ta.atr(14) * qtySpacing

// ════════════════════════════════════════════════════════════════════════════
//  DRAW COLLECTIONS + SHARED STATE
// ════════════════════════════════════════════════════════════════════════════
var array<box>   glBoxes  = array.new<box>()
var array<line>  glLines  = array.new<line>()
var array<label> glLabels = array.new<label>()

var float pocPrice = na
var float vahPrice = na
var float valPrice = na
var float totBuyW  = na
var float totSellW = na

domSel = domPos == "Left" ? position.middle_left : domPos == "Top Right" ? position.top_right : domPos == "Top Left" ? position.top_left : domPos == "Bottom Right" ? position.bottom_right : domPos == "Bottom Left" ? position.bottom_left : position.middle_right
var table dom = table.new(domSel, 3, domLevels + 4, bgcolor=color.new(#0A0E14, 4), frame_color=color.new(panelGrey, 0), frame_width=1, border_color=color.new(panelGrey, 55), border_width=1)
dcell(int c, int r, string t, color tc, color bg) => table.cell(dom, c, r, t, width=c == 0 ? 6 : c == 1 ? 6 : 8, text_color=tc, bgcolor=bg, text_size=size.small, text_halign=text.align_left)

// ════════════════════════════════════════════════════════════════════════════
//  BUILD
// ════════════════════════════════════════════════════════════════════════════
if barstate.islast and array.size(sVol) > 2
    clearBoxes(glBoxes)
    clearLines(glLines)
    clearLabels(glLabels)

    pHi = array.max(sHi)
    pLo = array.min(sLo)
    rng = pHi - pLo
    if rng > 0
        step = rng / nLevels
        bVol = array.new<float>(nLevels, 0.0)
        bBuy = array.new<float>(nLevels, 0.0)
        bSell= array.new<float>(nLevels, 0.0)

        ns = array.size(sVol)
        for idx = 0 to ns - 1
            bh = array.get(sHi, idx)
            bl = array.get(sLo, idx)
            bv = array.get(sVol, idx)
            bb = array.get(sBuy, idx)
            bs = array.get(sSell, idx)
            loB = math.max(0, math.min(nLevels - 1, int(math.floor((bl - pLo) / step))))
            hiB = math.max(0, math.min(nLevels - 1, int(math.floor((bh - pLo) / step))))
            span = math.max(1, hiB - loB + 1)
            vPer = bv / span
            bPer = bb / span
            sPer = bs / span
            for k = loB to hiB
                array.set(bVol, k, array.get(bVol, k) + vPer)
                array.set(bBuy, k, array.get(bBuy, k) + bPer)
                array.set(bSell, k, array.get(bSell, k) + sPer)

        pocIdx = 0
        maxVol = 0.0
        totVol = 0.0
        totB = 0.0
        totS = 0.0
        for k = 0 to nLevels - 1
            vk = array.get(bVol, k)
            totVol += vk
            totB += array.get(bBuy, k)
            totS += array.get(bSell, k)
            if vk > maxVol
                maxVol := vk
                pocIdx := k
        avgVol = totVol / nLevels
        pocPrice := pLo + (pocIdx + 0.5) * step
        totBuyW := totB
        totSellW := totS

        vaTarget = totVol * vaPct / 100.0
        acc = array.get(bVol, pocIdx)
        loVA = pocIdx
        hiVA = pocIdx
        guard = 0
        while acc < vaTarget and guard < nLevels * 2
            guard += 1
            upV = hiVA < nLevels - 1 ? array.get(bVol, hiVA + 1) : -1.0
            dnV = loVA > 0 ? array.get(bVol, loVA - 1) : -1.0
            if upV < 0 and dnV < 0
                break
            if upV >= dnV
                hiVA += 1
                acc += upV
            else
                loVA -= 1
                acc += dnV
        vahPrice := pLo + (hiVA + 1) * step
        valPrice := pLo + loVA * step

        barMsNow = int(math.max(1, nz(time - time[1], 60000)))
        visibleLeftT = int(chart.left_visible_bar_time)
        visibleRightT = int(chart.right_visible_bar_time)
        visibleSpanT = math.max(barMsNow * 20, visibleRightT - visibleLeftT)
        vpMaxSpanT = int(math.round(float(visibleSpanT) * 0.38))
        vpSpanT = math.max(barMsNow * 4, math.min(vpWidth * barMsNow, vpMaxSpanT))
        vpAnchorT = visibleLeftT
        vpEndT = vpAnchorT + vpSpanT
        vpOtherLabelT = math.max(int(time + 2 * barMsNow), vpEndT + barMsNow)
        vpPocLabelT = vpOtherLabelT + 6 * barMsNow
        vpOtherLineEndT = vpOtherLabelT
        vpPocLineEndT = vpPocLabelT
        vpBuyBaseTr = 100 - vpBuyOpacity
        vpSellBaseTr = 100 - vpSellOpacity
        vpBuyPocTr = math.max(0, vpBuyBaseTr - 20)
        vpSellPocTr = math.max(0, vpSellBaseTr - 20)
        hvnScore = array.new<float>()
        hvnIdx = array.new<int>()
        lvnScore = array.new<float>()
        lvnIdx = array.new<int>()
        if showNodes
            for nk = 0 to nLevels - 1
                nv = array.get(bVol, nk)
                lv = nk > 0 ? array.get(bVol, nk - 1) : nv
                rv = nk < nLevels - 1 ? array.get(bVol, nk + 1) : nv
                isHvn = nv >= avgVol * hvnMult and nv >= lv and nv >= rv and (nv > lv or nv > rv)
                isLvn = nv <= avgVol * lvnMult and nv > 0 and nv <= lv and nv <= rv and (nv < lv or nv < rv)
                if isHvn
                    array.push(hvnScore, nv)
                    array.push(hvnIdx, nk)
                if isLvn
                    array.push(lvnScore, avgVol * lvnMult - nv)
                    array.push(lvnIdx, nk)

        if showVP
            for k = 0 to nLevels - 1
                vk = array.get(bVol, k)
                if vk > 0
                    top = pLo + (k + 1) * step
                    bot = pLo + k * step
                    bk = array.get(bBuy, k)
                    sk = array.get(bSell, k)
                    if splitDelta
                        buyLenT = int(math.round(maxVol > 0 ? bk / maxVol * vpSpanT : 0.0))
                        sellLenT = int(math.round(maxVol > 0 ? sk / maxVol * vpSpanT : 0.0))
                        if sellLenT > 0
                            array.push(glBoxes, box.new(vpAnchorT, top, vpAnchorT + sellLenT, bot, xloc=xloc.bar_time, border_color=color.new(colAsk, 100), bgcolor=color.new(colAsk, k == pocIdx ? vpSellPocTr : vpSellBaseTr)))
                        if buyLenT > 0
                            array.push(glBoxes, box.new(vpAnchorT + sellLenT, top, vpAnchorT + sellLenT + buyLenT, bot, xloc=xloc.bar_time, border_color=color.new(colBid, 100), bgcolor=color.new(colBid, k == pocIdx ? vpBuyPocTr : vpBuyBaseTr)))
                    else
                        totLenT = int(math.round(maxVol > 0 ? vk / maxVol * vpSpanT : 0.0))
                        cc = bk >= sk ? colBid : colAsk
                        if totLenT > 0
                            array.push(glBoxes, box.new(vpAnchorT, top, vpAnchorT + totLenT, bot, xloc=xloc.bar_time, border_color=color.new(cc, 100), bgcolor=color.new(cc, k == pocIdx ? (bk >= sk ? vpBuyPocTr : vpSellPocTr) : (bk >= sk ? vpBuyBaseTr : vpSellBaseTr))))

            hvnDrawn = 0
            while hvnDrawn < maxNodes and array.size(hvnScore) > 0
                bestI = -1
                bestSc = -1.0
                for ni = 0 to array.size(hvnScore) - 1
                    sc = array.get(hvnScore, ni)
                    if sc > bestSc
                        bestSc := sc
                        bestI := ni
                if bestI < 0 or bestSc < 0
                    break
                array.set(hvnScore, bestI, -1.0)
                nk = array.get(hvnIdx, bestI)
                nodePrice = pLo + (nk + 0.5) * step
                array.push(glLines, line.new(vpEndT, nodePrice, vpOtherLineEndT, nodePrice, xloc=xloc.bar_time, color=color.new(colPoc, 45), width=1, style=line.style_dotted))
                array.push(glLabels, label.new(vpOtherLabelT, nodePrice, "HVN " + f2s(nodePrice), xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(colPoc, 80), textcolor=colPoc, size=size.tiny))
                hvnDrawn += 1
            lvnDrawn = 0
            while lvnDrawn < maxNodes and array.size(lvnScore) > 0
                bestI = -1
                bestSc = -1.0
                for ni = 0 to array.size(lvnScore) - 1
                    sc = array.get(lvnScore, ni)
                    if sc > bestSc
                        bestSc := sc
                        bestI := ni
                if bestI < 0 or bestSc < 0
                    break
                array.set(lvnScore, bestI, -1.0)
                nk = array.get(lvnIdx, bestI)
                nodePrice = pLo + (nk + 0.5) * step
                array.push(glLines, line.new(vpEndT, nodePrice, vpOtherLineEndT, nodePrice, xloc=xloc.bar_time, color=color.new(colNeu, 55), width=1, style=line.style_dotted))
                array.push(glLabels, label.new(vpOtherLabelT, nodePrice, "LVN " + f2s(nodePrice), xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(colNeu, 85), textcolor=colNeu, size=size.tiny))
                lvnDrawn += 1

        if showPOC
            array.push(glLines, line.new(vpEndT, pocPrice, vpPocLineEndT, pocPrice, xloc=xloc.bar_time, color=color.new(colPoc, 0), width=2, style=line.style_dashed))
            array.push(glLabels, label.new(vpPocLabelT, pocPrice, "POC " + f2s(pocPrice), xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(colPoc, 75), textcolor=colPoc, size=size.tiny))
        if showVA
            array.push(glLines, line.new(vpEndT, vahPrice, vpOtherLineEndT, vahPrice, xloc=xloc.bar_time, color=color.new(colNeu, 30), width=1, style=line.style_dashed))
            array.push(glLines, line.new(vpEndT, valPrice, vpOtherLineEndT, valPrice, xloc=xloc.bar_time, color=color.new(colNeu, 30), width=1, style=line.style_dashed))
            array.push(glLabels, label.new(vpOtherLabelT, vahPrice, "VAH " + f2s(vahPrice), xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(colNeu, 82), textcolor=colNeu, size=size.tiny))
            array.push(glLabels, label.new(vpOtherLabelT, valPrice, "VAL " + f2s(valPrice), xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(colNeu, 82), textcolor=colNeu, size=size.tiny))

        if showQty
            startI = math.max(0, ns - qtyBars)
            for idx = startI to ns - 1
                bx = bar_index - (ns - 1 - idx)
                vv = array.get(sVol, idx)
                bb = array.get(sBuy, idx)
                sk = array.get(sSell, idx)
                dlt = bb - sk
                cc = dlt >= 0 ? colBid : colAsk
                txt = fmtVol(vv) + (qtyDelta ? "\nΔ" + fmtVol(dlt) : "")
                qy = dlt >= 0 ? array.get(sLo, idx) - qtyGap : array.get(sHi, idx) + qtyGap
                qstyle = dlt >= 0 ? label.style_label_up : label.style_label_down
                array.push(glLabels, label.new(bx, qy, txt, xloc=xloc.bar_index, yloc=yloc.price, style=qstyle, color=color.new(cc, 80), textcolor=cc, size=size.tiny))

        if showDOM
            half = int(domLevels / 2)
            lastB = math.max(0, math.min(nLevels - 1, int(math.floor((close - pLo) / step))))
            curTot = math.max(bV + sV, 1.0)
            barRng = math.max(high - low, syminfo.mintick)
            volPress = (bV - sV) / curTot
            closePress = ((close - low) / barRng - 0.5) * 2.0
            bodyPress = (close - open) / barRng
            domPress = clamp((volPress * 0.62 + closePress * 0.23 + bodyPress * 0.15) * fastPower, -1.0, 1.0)
            buyPulse = fastDOM ? math.max(domPress, 0.0) * curTot : 0.0
            sellPulse = fastDOM ? math.max(-domPress, 0.0) * curTot : 0.0

            maxDisp = 0.0
            for r = 0 to half - 1
                ai = lastB + half - r
                if ai >= 0 and ai < nLevels
                    distA = math.abs(ai - lastB)
                    pulseA = sellPulse * math.pow(fastDecay, distA)
                    maxDisp := math.max(maxDisp, array.get(bVol, ai) + pulseA)
                bi = lastB - 1 - r
                if bi >= 0 and bi < nLevels
                    distB = math.abs(bi - lastB)
                    pulseB = buyPulse * math.pow(fastDecay, distB)
                    maxDisp := math.max(maxDisp, array.get(bVol, bi) + pulseB)
            maxDisp := math.max(maxDisp, 1.0)

            dcell(0, 0, "ORDER BOOK", panelTitle, color.new(#0A0E14, 0))
            dcell(1, 0, fastDOM ? "FAST VAP" : "VAP", panelTitle, color.new(#0A0E14, 0))
            dcell(2, 0, ltf, panelTitle, color.new(#0A0E14, 0))
            dcell(0, 1, "PRICE", colNeu, color.new(#16202E, 30))
            dcell(1, 1, "SIZE", colNeu, color.new(#16202E, 30))
            dcell(2, 1, "DEPTH", colNeu, color.new(#16202E, 30))

            for r = 0 to half - 1
                rowI = 2 + r
                ai = lastB + half - r
                if ai >= 0 and ai < nLevels
                    pr = pLo + (ai + 0.5) * step
                    baseV = array.get(bVol, ai)
                    distA = math.abs(ai - lastB)
                    pulseA = sellPulse * math.pow(fastDecay, distA)
                    vk = baseV + pulseA
                    active = fastDOM and flashDOM and pulseA > curTot * 0.04
                    wall = showWalls and vk > avgVol * wallMult
                    bgAsk = active ? color.new(colAsk, 82) : color.new(#1A1015, 20)
                    dcell(0, rowI, f2s(pr), colAsk, bgAsk)
                    dcell(1, rowI, fmtVol(vk) + (wall ? " ◄" : ""), active or wall ? color.new(colAsk, 0) : colAsk, bgAsk)
                    dcell(2, rowI, depthBar(vk, maxDisp, barChars), color.new(colAsk, active or wall ? 0 : 20), bgAsk)
                else
                    dcell(0, rowI, "", colAsk, color.new(#1A1015, 40))
                    dcell(1, rowI, "", colAsk, color.new(#1A1015, 40))
                    dcell(2, rowI, "", colAsk, color.new(#1A1015, 40))

            midR = 2 + half
            bestAsk = pLo + (math.min(nLevels - 1, lastB + 1) + 0.5) * step
            bestBid = pLo + (math.max(0, lastB - 1) + 0.5) * step
            midBg = domPress > 0.15 ? color.new(colBid, 0) : domPress < -0.15 ? color.new(colAsk, 0) : color.new(colPoc, 0)
            dcell(0, midR, f2s(close), color.new(#0A0E14, 0), midBg)
            dcell(1, midR, domPress > 0.15 ? "BUY HIT" : domPress < -0.15 ? "SELL HIT" : "LAST", color.new(#0A0E14, 0), midBg)
            dcell(2, midR, "spr " + f2s(bestAsk - bestBid), color.new(#0A0E14, 0), midBg)

            for r = 0 to half - 1
                rowI = midR + 1 + r
                bi = lastB - 1 - r
                if bi >= 0 and bi < nLevels
                    pr = pLo + (bi + 0.5) * step
                    baseV = array.get(bVol, bi)
                    distB = math.abs(bi - lastB)
                    pulseB = buyPulse * math.pow(fastDecay, distB)
                    vk = baseV + pulseB
                    active = fastDOM and flashDOM and pulseB > curTot * 0.04
                    wall = showWalls and vk > avgVol * wallMult
                    bgBid = active ? color.new(colBid, 82) : color.new(#0A1A17, 20)
                    dcell(0, rowI, f2s(pr), colBid, bgBid)
                    dcell(1, rowI, fmtVol(vk) + (wall ? " ◄" : ""), active or wall ? color.new(colBid, 0) : colBid, bgBid)
                    dcell(2, rowI, depthBar(vk, maxDisp, barChars), color.new(colBid, active or wall ? 0 : 20), bgBid)
                else
                    dcell(0, rowI, "", colBid, color.new(#0A1A17, 40))
                    dcell(1, rowI, "", colBid, color.new(#0A1A17, 40))
                    dcell(2, rowI, "", colBid, color.new(#0A1A17, 40))

            footR = domLevels + 3
            tot = totB + totS
            buyPct = fastDOM ? bV / curTot * 100.0 : tot > 0 ? totB / tot * 100.0 : 50.0
            dcell(0, footR, "▲ " + str.tostring(buyPct, "0") + "%", colBid, color.new(#16202E, 20))
            dcell(1, footR, depthBar(fastDOM ? bV : totB, math.max(fastDOM ? bV : totB, fastDOM ? sV : totS), barChars), colBid, color.new(#16202E, 20))
            dcell(2, footR, "▼ " + str.tostring(100 - buyPct, "0") + "%", colAsk, color.new(#16202E, 20))

// ════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════
strongBuy  = bV > sV * strongR
strongSell = sV > bV * strongR
pocCrossRaw = ta.cross(close, pocPrice)
atPOC = not na(pocPrice) and pocCrossRaw
alertcondition(strongBuy,  "Strong Buy Bar",  "ORDER BOOK — strong buy volume bar")
alertcondition(strongSell, "Strong Sell Bar", "ORDER BOOK — strong sell volume bar")
alertcondition(atPOC,      "Price at POC",    "ORDER BOOK — price reached the POC")

// ════════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ════════════════════════════════════════════════════════════════════════════
posSel = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.middle_right
var table dash = table.new(posSel, 2, 8, bgcolor=color.new(#0A0E14, 6), frame_color=color.new(panelGrey, 0), frame_width=1, border_color=color.new(panelGrey, 55), border_width=1)
dashCell(int c, int r, string t, color tc, color bg) => table.cell(dash, c, r, t, text_color=tc, bgcolor=bg, text_size=size.small, text_halign=text.align_left)

if showDash and barstate.islast
    tw = nz(totBuyW) + nz(totSellW)
    bpct = tw > 0 ? nz(totBuyW) / tw * 100.0 : na
    dashCell(0, 0, "📊 ORDER BOOK", panelTitle, color.new(#0A0E14, 0))
    dashCell(1, 0, "🧙 WIZARD", panelTitle, color.new(#0A0E14, 0))
    dashCell(0, 1, "📍 POC", colPoc, color.new(#101722, 20))
    dashCell(1, 1, f2s(pocPrice), colPoc, color.new(#101722, 20))
    dashCell(0, 2, "📐 VAH / VAL", colNeu, color.new(#0D131C, 20))
    dashCell(1, 2, f2s(vahPrice) + " / " + f2s(valPrice), #C7D3E0, color.new(#0D131C, 20))
    dashCell(0, 3, "⚖️ Bar Buy/Sell", colNeu, color.new(#101722, 20))
    dashCell(1, 3, fmtVol(bV) + " / " + fmtVol(sV), bV >= sV ? colBid : colAsk, color.new(#101722, 20))
    dashCell(0, 4, "⚡ Bar Delta", colNeu, color.new(#0D131C, 20))
    dashCell(1, 4, fmtVol(bV - sV), bV - sV >= 0 ? colBid : colAsk, color.new(#0D131C, 20))
    dashCell(0, 5, "📈 CVD", colNeu, color.new(#101722, 20))
    dashCell(1, 5, fmtVol(cvd), cvd >= 0 ? colBid : colAsk, color.new(#101722, 20))
    dashCell(0, 6, "🔥 Pressure", colNeu, color.new(#0D131C, 20))
    dashCell(1, 6, na(bpct) ? "—" : "▲" + str.tostring(bpct, "0") + "%  ▼" + str.tostring(100 - bpct, "0") + "%", #C7D3E0, color.new(#0D131C, 20))
    dashCell(0, 7, "🔎 Source", colNeu, color.new(#101722, 20))
    dashCell(1, 7, nlt > 0 ? "intrabar " + ltf : "whole-bar", nlt > 0 ? colBid : colNeu, color.new(#101722, 20))
````
