# Cost Basis Map [FEELS]

- url: https://www.tradingview.com/script/MYl1UFTz-Cost-Basis-Map-FEELS/
- type: indicator
- pine_id: PUB;190cbe5151fc4d67bcb726447579710f
- version: 1.0

## Description

Who is in profit at this level, and who is trapped? Cost Basis Map estimates the answer for any symbol and any timeframe from nothing but price and volume. On-chain analytics answers the same question for Bitcoin with realized price and supply in profit, but those metrics need blockchain data, so they stop at BTC. This script rebuilds that framework from OHLCV for everything else.

The headline number is the share of open positions that is underwater right now. Everything else on the chart is built from the same ledger.

[b]HOW THE LEDGER WORKS[/b]

The script maintains a ledger of open positions. Every bar adds its traded volume to the ledger at that bar's price, and the same volume closes a proportional share of the older positions. Old entries rotate out at a pace set by turnover rather than time: a few high-volume bars can replace a big part of the book, a quiet stretch barely touches it. The result is a bar-by-bar estimate of which positions are still open and what they paid. From it the script derives:

- Break-even line: the volume-weighted average entry of all open positions. This is the market's collective cost basis, the same construction on-chain research calls realized price.
- Underwater share: the % of open positions whose entry sits above the current price. It drives the headline, the fill color and the sentiment states (euphoria, healthy uptrend, mixed, majority trapped, extreme pain).
- Open-positions profile: the right-side histogram shows where the open positions were entered. Red rows above price are trapped positions waiting overhead, which tends to act as resistance and as squeeze fuel once price runs through it. Teal rows below are holders in profit, where support usually forms. The widest row is tagged as the heaviest entries.
- Capitulation marker: printed when an unusually large amount of volume (a z-score test) realizes losses below break-even. On everything I tested these cluster near major bottoms.
- Euphoria marker: printed when nearly every position is in profit and turnover is elevated, a condition typical of late trend.
- Recent entries line: the average entry of the newest cohort, the positions most likely to panic or chase first.

Positions are money-weighted by default (volume × price), with an option to weight by raw volume units instead.

https://www.tradingview.com/x/hBsXHxnn/

[b]HOW TO TRADE IT[/b]

1. Regime first. Price holding above a rising break-even line with a low underwater share is a healthy trend, and pullbacks into the line are buyable by ordinary trend rules. When price loses the break-even line the regime flips: the average holder is now at a loss, and rallies back into the line run into their exit orders.
2. Read the profile as a map of who needs what. Heavy red rows above price mark where trapped holders wait to break even, so expect supply there. Heavy teal rows below mark profitable entries that tend to get defended.
3. Extremes are mean-reversion territory. A capitulation marker on top of an extreme underwater share has marked the areas where selling exhausts. A euphoria marker with a single-digit underwater share is the same warning on the upside.

[b]HONESTY[/b]

This is an estimation model built from price and volume. Real per-account position data does not exist anywhere on any platform; on-chain analytics estimates it too, just from a different source. The model's assumptions are simple and disclosed: entries at the bar's typical price, proportional volume-driven rotation of old positions. A fixed marker cooldown keeps signal episodes readable. Markers print on bar close and do not repaint. The tool is most informative on volatile assets and intraday-to-daily timeframes; on slow index weeklies the market spends years in profit and the picture is honestly boring. Volume quality matters: prefer a real exchange feed (e.g. Bitstamp, Coinbase, a specific futures contract) over composite indices, because aggregated feeds smooth out the volume spikes the engine reads. On symbols with no volume data the script falls back to equal weighting.

https://www.tradingview.com/x/y1SYUSQW/

[b]ALERTS[/b]

Cost basis reclaimed · Cost basis lost · Majority underwater (60%+) · Nearly all in profit · Capitulation volume · Euphoria turnover.

[b]SETTINGS[/b]

Every input has a tooltip. The main ones: "Position memory" sets how long the ledger remembers (volume-weighted), "Ledger resolution" sets the price granularity, profile size/spacing and all colors are adjustable, "Text size" scales the captions for presentations.

https://www.tradingview.com/x/J8hu7I2a/

[b]ORIGINALITY[/b]

A volume profile shows where volume traded. This ledger goes one step further and estimates which of those positions are still open and what they paid, i.e. cost-basis analytics of the kind used in on-chain research, reconstructed from OHLCV for any market. The break-even line is not an MA or a VWAP band in disguise: it is computed from the position ledger, not from a lookback window. Engine and rendering are written from scratch.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FeelsStrategy

//@version=6
indicator("Cost Basis Map [FEELS]", "Cost Basis [FEELS]", overlay = true, max_boxes_count = 500, max_labels_count = 100, max_lines_count = 100)

//--- inputs · engine
grpE = "Engine"
procDepth = input.int(4000, "Engine window (bars)", minval = 500, maxval = 9000, step = 500, group = grpE, tooltip = "How many recent bars feed the position ledger. Larger = deeper market memory, heavier to compute.")
memLen    = input.int(150, "Position memory (bars)", minval = 20, maxval = 1000, step = 10, group = grpE, tooltip = "How long the ledger remembers positions. Volume-weighted: high-volume bars churn positions faster than quiet ones. Longer memory = heavier break-even line and deeper underwater zones.")
binPct    = input.float(0.2, "Ledger resolution (%)", minval = 0.05, maxval = 1.0, step = 0.05, group = grpE, tooltip = "Price bin width of the open-position ledger, as a % of price. Smaller = finer cost-basis profile.")
recAge    = input.int(20, "Recent entries window", minval = 5, maxval = 100, group = grpE, tooltip = "Cohort line: volume-weighted average entry of the last N bars — the newest participants, the first to panic or chase.")
capZ      = input.float(2.0, "Capitulation sensitivity", minval = 1.0, maxval = 4.0, step = 0.25, group = grpE, tooltip = "Z-score of loss-realizing volume needed to print a capitulation marker. Lower = more markers.")
unitS     = input.string("Quote (money)", "Position units", options = ["Quote (money)", "Base (coins/shares)"], group = grpE, tooltip = "How position size is weighted in the ledger. Quote = volume × price (money-weighted, recommended). Base = raw volume units — on assets that grew 100x it lets ancient cheap entries dominate the ledger.")

//--- inputs · display
grpV = "Display"
showCB   = input.bool(true, "Cost basis line", group = grpV, tooltip = "Volume-weighted average entry of ALL open positions in the ledger — the market's collective break-even.")
showRec  = input.bool(true, "Recent entries line", group = grpV, tooltip = "Average entry of the newest cohort (Recent entries window).")
showFill = input.bool(true, "Underwater / cushion fill", group = grpV, tooltip = "The space between price and cost basis: red when the average open position is losing, teal when it is in profit.")
showProf = input.bool(true, "Open-positions profile", group = grpV, tooltip = "Right-side histogram of WHERE the open positions were entered. Red rows above price = trapped volume overhead (resistance), teal rows below = profitable holders (support).")
profRows = input.int(30, "Profile rows", minval = 10, maxval = 60, group = grpV)
profWide = input.int(30, "Profile width (bars)", minval = 10, maxval = 60, group = grpV)
profScaleS = input.string("Linear", "Profile spacing", options = ["Linear", "Log"], group = grpV, tooltip = "Row spacing of the profile. Switch to Log when your chart is on log scale or covers a very wide price range, so the rows look even.")
showMark = input.bool(true, "Capitulation / euphoria markers", group = grpV, tooltip = "Capitulation: unusual volume realizing losses below cost basis — historically clusters near bottoms. Euphoria: nearly every position in profit on elevated turnover — late-trend condition.")
markCd   = input.int(25, "Marker cooldown (bars)", minval = 5, maxval = 100, group = grpV, tooltip = "One marker per episode: repeats within this many bars stay silent. Raise it on lower timeframes if markers cluster.")
showHead = input.bool(true, "Headline", group = grpV, tooltip = "The one number this tool is about: the share of open positions currently underwater.")
showBG   = input.bool(false, "Extreme sentiment tint", group = grpV, tooltip = "Very light background tint at true extremes only: 80%+ underwater (pain) or 97%+ in profit (euphoria).")
lblSzS   = input.string("Normal", "Text size", options = ["Small", "Normal", "Large", "Huge"], group = grpV, tooltip = "Size of the headline and profile captions. Bump it up for screenshots.")

grpC = "Colors"
cProfit = input.color(#089981, "In profit", group = grpC)
cLoss   = input.color(#F23645, "Underwater", group = grpC)
cCB     = input.color(#2F3B4A, "Cost basis", group = grpC)
cRec    = input.color(#3B82F6, "Recent entries", group = grpC)

lblSz = lblSzS == "Huge" ? size.huge : lblSzS == "Large" ? size.large : lblSzS == "Small" ? size.small : size.normal

//--- position ledger
// model: every bar deposits its volume at its typical price; the same volume
// closes existing positions pro-rata (turnover), so the ledger always holds an
// estimate of the OPEN positions and their entry prices. lazy multiplier M
// keeps the pro-rata decay O(1) per bar. this is an estimation from price and
// volume — no exchange position data exists on any platform.
var array<float> binK = array.new<float>()   // sorted bin keys
var array<float> binV = array.new<float>()   // stored volume, lazy-scaled
var float M = 1.0
var float S = 0.0                            // stored (unscaled) total

lnStep = math.log(1 + binPct / 100)
f_key(float p) =>
    math.floor(math.log(p) / lnStep) * 1.0

active = last_bar_index - bar_index <= procDepth
float volRaw = nz(volume) <= 0 ? 1.0 : volume
float vol = unitS == "Quote (money)" ? volRaw * hlc3 : volRaw
volMaL = ta.sma(vol, 100)

var float uwPct = na
var float cb = na
float realizedLoss = 0.0

if active and barstate.isconfirmed
    totalEff = S * M
    // volume-weighted forgetting: the ledger remembers ~memLen bars, and
    // high-volume bars churn positions faster than quiet ones
    f = totalEff > 0 and volMaL > 0 ? math.max(1 - vol / (volMaL * memLen), 0.0) : 1.0
    // positions closed this bar, weighted by how much of the ledger was
    // underwater = loss-realization proxy
    realizedLoss := totalEff > 0 and not na(uwPct) ? totalEff * (1 - f) * uwPct / 100 : 0.0
    M := M * f
    if M < 1e-8
        if array.size(binV) > 0
            for i = 0 to array.size(binV) - 1
                array.set(binV, i, array.get(binV, i) * M)
        S := S * M
        M := 1.0
    k = f_key(hlc3)
    idx = array.binary_search_leftmost(binK, k)
    add = vol / M
    if idx < array.size(binK) and array.get(binK, idx) == k
        array.set(binV, idx, array.get(binV, idx) + add)
    else
        array.insert(binK, idx, k)
        array.insert(binV, idx, add)
    S := S + add
    // prune dust bins so the ledger stays light
    if bar_index % 500 == 0 and array.size(binV) > 50
        thr = S * 1e-5
        i = 0
        while i < array.size(binV)
            if array.get(binV, i) < thr
                S := S - array.get(binV, i)
                array.remove(binV, i)
                array.remove(binK, i)
            else
                i += 1
    // aggregates: collective break-even + share of positions underwater
    n = array.size(binK)
    if n > 0 and S > 0
        float pv = 0.0
        float uw = 0.0
        for i = 0 to n - 1
            p = math.exp((array.get(binK, i) + 0.5) * lnStep)
            v = array.get(binV, i)
            pv += p * v
            if p > close
                uw += v
        cb := pv / S
        uwPct := 100 * uw / S

//--- cohort line: average entry of the newest participants
rec = math.sum(hlc3 * vol, recAge) / math.sum(vol, recAge)

//--- capitulation / euphoria detection
rlMean = ta.sma(realizedLoss, 100)
rlStd  = ta.stdev(realizedLoss, 100)
volMa  = ta.sma(vol, 50)
capRaw   = active and barstate.isconfirmed and rlStd > 0 and realizedLoss > rlMean + capZ * rlStd and close < nz(cb, close)
euphoRaw = active and not na(uwPct) and uwPct <= 5 and vol > volMa * 1.5
// one marker per episode: repeats inside the cooldown window stay silent
var int lastCapB = -500
var int lastEuB  = -500
capMark = capRaw and bar_index - lastCapB >= markCd
if capMark
    lastCapB := bar_index
euphMark = euphoRaw and bar_index - lastEuB >= markCd
if euphMark
    lastEuB := bar_index

//--- render
pClose = plot(close, "Price anchor", display = display.none, editable = false)
pCB    = plot(showCB and active ? cb : na, "Cost basis", color = cCB, linewidth = 3)
pRec   = plot(showRec and active ? rec : na, "Recent entries", color = color.new(cRec, 20), linewidth = 2)

fillCol = close < cb ? color.new(cLoss, 78) : color.new(cProfit, 84)
fill(pClose, pCB, showFill and active ? fillCol : na, title = "Underwater / cushion")

bgcolor(showBG and active and not na(uwPct) ? (uwPct >= 80 ? color.new(cLoss, 94) : uwPct <= 3 ? color.new(cProfit, 95) : na) : na, title = "Extreme sentiment tint")

plotshape(showMark and capMark, "Capitulation", style = shape.triangleup, location = location.belowbar, color = color.new(cLoss, 0), size = size.small, text = "cap", textcolor = color.new(cLoss, 20))
plotshape(showMark and euphMark, "Euphoria", style = shape.triangledown, location = location.abovebar, color = color.new(cProfit, 0), size = size.small, text = "euph", textcolor = color.new(cProfit, 20))

//--- open-positions profile + headline (last bar)
var array<box> profBoxes = array.new<box>()
var array<label> hlLabels = array.new<label>()
var int drawnAt = -1

if barstate.islast and bar_index != drawnAt
    drawnAt := bar_index
    if array.size(profBoxes) > 0
        for bx in profBoxes
            box.delete(bx)
        array.clear(profBoxes)
    if array.size(hlLabels) > 0
        for lb in hlLabels
            label.delete(lb)
        array.clear(hlLabels)
    n = array.size(binK)
    if n > 0 and S > 0
        // trim the display range to the middle 98% of position mass, so ancient
        // dust cannot stretch the profile into a thin thread
        float pLo = na
        float pHi = na
        float cum = 0.0
        for i = 0 to n - 1
            cum += array.get(binV, i)
            if na(pLo) and cum >= S * 0.01
                pLo := math.exp(array.get(binK, i) * lnStep)
            if cum >= S * 0.99
                pHi := math.exp((array.get(binK, i) + 1) * lnStep)
                break
        if na(pHi)
            pHi := math.exp((array.get(binK, n - 1) + 1) * lnStep)
        if showProf and pHi > pLo
            useLogRows = profScaleS == "Log"
            lnLo = math.log(pLo)
            lnHi = math.log(pHi)
            rowH  = (pHi - pLo) / profRows
            rowHL = (lnHi - lnLo) / profRows
            rowV = array.new<float>(profRows, 0.0)
            for i = 0 to n - 1
                p = math.exp((array.get(binK, i) + 0.5) * lnStep)
                if p >= pLo and p <= pHi
                    rF = useLogRows ? (math.log(p) - lnLo) / rowHL : (p - pLo) / rowH
                    r = math.min(profRows - 1, math.max(0, math.floor(rF)))
                    array.set(rowV, r, array.get(rowV, r) + array.get(binV, i))
            maxV = array.max(rowV)
            int pocRow = array.indexof(rowV, maxV)
            if maxV > 0
                for r = 0 to profRows - 1
                    v = array.get(rowV, r)
                    if v >= maxV * 0.05
                        y1 = useLogRows ? math.exp(lnLo + r * rowHL) : pLo + r * rowH
                        y2 = useLogRows ? math.exp(lnLo + (r + 0.9) * rowHL) : y1 + rowH * 0.9
                        w = math.max(1, math.round(profWide * v / maxV))
                        mid = useLogRows ? math.exp(lnLo + (r + 0.5) * rowHL) : y1 + rowH / 2
                        col = mid > close ? cLoss : cProfit
                        array.push(profBoxes, box.new(bar_index + 3, y2, bar_index + 3 + w, y1, border_color = na, bgcolor = color.new(col, r == pocRow ? 35 : 65)))
                if pocRow >= 0
                    pocMid = useLogRows ? math.exp(lnLo + (pocRow + 0.5) * rowHL) : pLo + pocRow * rowH + rowH / 2
                    array.push(hlLabels, label.new(bar_index + 4 + profWide, pocMid, "heaviest entries", style = label.style_label_left, color = color.new(cCB, 100), textcolor = color.new(cCB, 25), size = size.small))
        if showHead and not na(uwPct)
            string state = uwPct >= 75 ? "extreme pain" : uwPct >= 55 ? "majority trapped" : uwPct <= 5 ? "euphoria" : uwPct <= 25 ? "healthy uptrend" : "mixed"
            color hCol = uwPct >= 55 ? cLoss : uwPct <= 25 ? cProfit : cCB
            txt = str.tostring(uwPct, "#") + "% underwater\n" + state + "\nbreak-even " + str.tostring(cb, format.mintick)
            array.push(hlLabels, label.new(bar_index + 3, pHi, txt, style = label.style_label_lower_left, color = color.new(hCol, 15), textcolor = color.white, size = lblSz))

//--- alerts
uwHigh = not na(uwPct) and uwPct >= 60
uwLow  = not na(uwPct) and uwPct <= 10
reclaim = ta.crossover(close, cb)
losecb  = ta.crossunder(close, cb)

alertcondition(uwHigh and not uwHigh[1], "Majority underwater (60%+)", "Cost Basis: 60%+ of open positions are now underwater — pain zone")
alertcondition(uwLow and not uwLow[1], "Nearly all in profit (90%+)", "Cost Basis: 90%+ of open positions are in profit — late-trend condition")
alertcondition(reclaim, "Cost basis reclaimed", "Cost Basis: price crossed above the market's collective break-even")
alertcondition(losecb, "Cost basis lost", "Cost Basis: price crossed below the market's collective break-even")
alertcondition(capMark, "Capitulation volume", "Cost Basis: unusual volume is realizing losses below break-even")
alertcondition(euphMark, "Euphoria turnover", "Cost Basis: nearly every position is in profit on elevated turnover")
````
