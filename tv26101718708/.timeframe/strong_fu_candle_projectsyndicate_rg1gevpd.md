# Strong FU Candle | ProjectSyndicate

- url: https://www.tradingview.com/script/rg1geVPD-Strong-FU-Candle-ProjectSyndicate/
- type: indicator
- pine_id: PUB;b6adbd2a270840ee88001b9d1a4a7020
- version: 1.0

## Description

STRONG FU CANDLE

[b]Strong FU Candle marks the exact bars where the market sweeps liquidity and snaps back — the classic "follow-up" reversal candle that traps breakout traders and ignites the move the other way. It scans every bar for a liquidity grab beyond the prior candle's wick followed by an engulfing close back through it, grades each setup on candle anatomy, projects a full Entry / Stop / TP1-TP2-TP3 trade plan with live fill tracking, and stores the resulting liquidity zones so you can see — on the same chart — which FU types actually held and which failed.[/b]

🎯 0–10 QUALITY SCORE
Each FU candle earns a live grade from five sign-stable anatomy factors on the setup bar itself:body dominance — body-to-range ratio (a real FU closes near its extreme, not in the middle).Opposite wick — penalises any pullback from the close back into the body, since a clean FU has almost no opposite wick.Grab wick — rewards a meaningful sweep wick but punishes the oversized "all wick, no body" candle.Close position — how far into the bar's range the close lands (≥90% of range = full credit).Size & participation — bonus when the candle is normal-sized relative to ATR (not a micro-bar, not a freak spike) and volume is at or above its average.

🏷️ CALIBRATED TIERS — C / B / A / S
The raw 0–10 score maps to four tiers, calibrated on 8 H1 FX pairs (2024–2026) at 1:1 RR: C≈52%, B≈53%, A≈55%, S≈59% win rate (vs 54.6% unfiltered). Raise the minimum tier toward A/S for higher win rate and fewer signals; drop to C for maximum signal flow.

🕯️ FULL vs ATTEMPTED (ATT) FU
Full FU = close fully engulfs the prior candle's wick. Attempted FU = close engulfs the prior candle's body but not its wick — weaker, but often a valid early reversal. ATT can be toggled off entirely.

🧹 FILTERS
EMA filter (bull FUs only above EMA, bear FUs only below — keeps you trading with short-term momentum), rejection filter (drops candles where the opposite-side wick is larger than the body), fractal filter (requires the FU to actually sweep a recent swing high/low), and a configurable point-size system so every threshold — grab size, engulf depth, min/max body, min range — scales correctly across gold, FX, indices and crypto.

🧊 LIVE LIQUIDITY ZONES
Every qualifying FU is drawn as a zone anchored to the bar that created it, sourced from either the grab wick (default) or the full FU candle range, with an optional 50% midline. Zones never drift — they sit on the price action that formed them. A label above each zone shows timeframe, side, tier, score, BIW marker, and the live win rate of that side on this timeframe.

📜 HISTORIC ZONES & WINNER LEVELS
Old zones fade into a historic layer, colour-coded by outcome (green = TP1 hit, red = stopped out). Option to show winners only and clean the chart of losses. For the most recent N winners the indicator can re-draw the original Entry, Stop and TP1/TP2/TP3 lines on the historic zone, so you can visually audit exactly how the playbook performed in past conditions.

📐 PROJECTED TRADE PLAN — ENTRY / SL / TP1-TP2-TP3
Every new FU prints a complete trade plan on the chart: Entry (at 50% body, 50% wick, or FU close — your pick), Stop with adjustable buffer beyond the candle, and TP1 / TP2 / TP3 at user-defined R multiples. Reversal mode treats bullish FU as a BUY; Fade mode flips it.

🎛️ LIVE TRADE PANEL
A side panel tracks the latest setup in real time: direction, exact Entry / SL / TP1 / TP2 / TP3 prices, and a live status line — PENDING → FILLED → TP1 hit → TP2 hit → TP3 HIT, or STOPPED OUT, or NO FILL (missed) if price ran without filling.

📊 STATS DASHBOARD
A separate leaderboard tracks per-side performance on the current timeframe and current tier filter: Win Rate, Probability of Touch (fill rate), Expected Value in R, configured R:R, average bars to win, average bars to loss, and a W / L • n • avg-score line. BUY and SELL columns are tracked independently so you can see if one side is dominating.

🌐 MULTI-TIMEFRAME OVERLAY
Up to three higher timeframes can be overlaid as drawn-only zones (15m / 1H / 4H by default, any TF), so a 5m chart can show 1H FU zones still in play. Higher-TF zones are draw-only and excluded from current-TF stats to keep the dashboard honest.

🔔 NATIVE ALERTS
Dedicated alerts for a BUY setup formed, a SELL setup formed, any bullish/bearish FU on any active TF, price touching an FU zone (entry filled), and price approaching a zone within a user-set tick proximity.

🔧 FULLY ADJUSTABLE
Detection thresholds in points (grab size, engulf depth, min range, min/max body); ATT FU on/off; EMA / rejection / fractal filter toggles and lengths; volume baseline length; minimum tier and minimum numeric score; direction logic (Reversal vs Fade); entry mode and stop buffer; TP1/TP2/TP3 multiples; zone source (grab wick vs full range), max active zones per side, historic cap, transparencies, midline on/off; full colour theme (bull, bear, win, loss, touched border); candle-colour toggle; label size; dashboard position and text size; up to three MTF channels; alert proximity.

🚀 Works on gold (XAUUSD), silver, forex, crypto and indices, on any timeframe.
────────────────────────

HOW TO TRADE IT — TWO APPROACHES

The tier chooses the playbook. High-tier FUs tend to reverse cleanly; low-tier FUs are coin flips that need extra confluence.
TRADE THE FU — reversal (A / S tier, score ≥ 6.5)
Use when a high-tier FU prints — calibrated to win ~55–59% at 1:1 with positive expectancy.
Wait for the FU to close and the trade plan to draw — Entry, SL, TP1/TP2/TP3.

Take the entry at your chosen level (50% body is the default — gives a pullback fill).

Stop just past the FU extreme with the buffer.

Scale at TP1, trail or hold for TP2 / TP3.

The trade panel tells you live whether you are PENDING, FILLED, in profit, or stopped.
FILTER & WAIT — selectivity (C / B tier)
Use C and B tier as context, not standalone signals — at the unfiltered ~54% baseline they need help.
Drop to C/B only when stacked with: a strong S/R level, an HTF FU in the same direction, an EMA reclaim/loss, or a fractal sweep.

Otherwise raise the minimum tier to A or S and accept fewer signals for a higher hit rate.

Use the live dashboard — if BUY WR on this TF is sitting at 45% over a decent n, that's a signal to either flip to Fade mode or sit out longs entirely on this instrument.
Rule of thumb: S/A tier → take the trade as drawn. B/C tier → needs confluence, or skip. Watch the live dashboard — let the actual win rate on this instrument tell you which side is paying.

────────────────────────

⚠️ This tool identifies high-probability liquidity-grab reversal candles and frames a full trade plan around each one. It is NOT a standalone buy/sell signal. Always combine it with your own strategy, price-action analysis and risk management to confirm setups. Past statistical behaviour does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Strong FU Candle", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

grpDet   = "Detection"
useATT       = input.bool(true,  "Detect Attempted FU (ATT)", tooltip="ATT FU = close engulfs the prior candle's BODY but not its wick.", group=grpDet)
ptInput      = input.float(0.0,  "Point Size (0 = auto / mintick)", minval=0.0, step=0.00001, tooltip="Price value of 1 'point' for the filters. 0 = instrument mintick. Adjust per asset/TF.", group=grpDet)
liqGrabPts   = input.float(20,   "Liq. Grab (points)", minval=0, group=grpDet)
engulfPts    = input.float(20,   "Engulfing (points)", minval=0, group=grpDet)
minSizePts   = input.float(20,   "Min. Size (points)", minval=0, group=grpDet)
minBodyPts   = input.float(20,   "Min. Body (points)", minval=0, group=grpDet)
maxBodyPts   = input.float(10000,"Max. Body (points)", minval=0, group=grpDet)

grpFil   = "Filters"
rejFilter    = input.bool(false, "Rejection Filter", tooltip="Drop FUs where the opposite-side wick is larger than the body.", group=grpFil)
emaFilter    = input.bool(true,  "EMA Filter", tooltip="Bull FU only above EMA, bear FU only below EMA.", group=grpFil)
emaLen       = input.int(7,      "EMA Length", minval=1, group=grpFil)
fracFilter   = input.bool(false, "Fractal Filter", group=grpFil)
fracLen      = input.int(10,     "Fractal Lookback", minval=2, group=grpFil)

grpStr   = "Quality / Tier Ranking"
volLen       = input.int(20,     "Volume Avg Length", minval=1, group=grpStr)
useBIW       = input.bool(true,  "Mark BIW source ('+')", tooltip="Body-Inside-Wick source candle, marked '+'. Informational only — NOT part of the quality score (BIW was found to be neutral-to-negative for win rate).", group=grpStr)
biwOnly      = input.bool(false, "BIW source only", group=grpStr)
minTier      = input.string("B", "Minimum Tier to show", options=["C","B","A","S"], tooltip="Filter setups by calibrated quality tier on the SETUP candle. S = strongest. Validated on 8x H1 FX pairs (2024-2026), 1:1 RR: C≈52%, B≈53%, A≈55%, S≈59% win rate (vs 54.6% unfiltered). Raise toward A/S for higher win rate, fewer signals.", group=grpStr)
minStrength  = input.float(0.0,  "Min. Quality Score (0-10)", minval=0.0, maxval=10.0, step=0.5, tooltip="Secondary numeric gate on the raw 0-10 quality score.", group=grpStr)

grpTrade = "Trade Levels / Logic"
dirLogic  = input.string("Reversal — Bullish FU = BUY", "Direction Logic", options=["Reversal — Bullish FU = BUY", "Fade — Bullish FU = SELL"], tooltip="Reversal (default): bullish FU = BUY, bearish FU = SELL. Fade = opposite.", group=grpTrade)
entryType = input.string("50% Body", "Entry At", options=["50% Body", "50% Wick", "FU Close"], group=grpTrade)
slBufPts  = input.float(5,     "Stop Buffer (points)", minval=0, group=grpTrade)
tp1R      = input.float(1.0,   "TP1 (R)", minval=0.1, step=0.5, group=grpTrade)
tp2R      = input.float(2.0,   "TP2 (R)", minval=0.1, step=0.5, group=grpTrade)
tp3R      = input.float(3.0,   "TP3 (R)", minval=0.1, step=0.5, group=grpTrade)
showTrade = input.bool(true,   "Show Trade Lines (latest setup)", group=grpTrade)
rightOff  = input.int(40,      "Line Length (bars)", minval=1, group=grpTrade)
showPanel = input.bool(true,   "Show Trade Panel", group=grpTrade)

grpZone  = "Liquidity Zones"
showZones    = input.bool(true,  "Show Active Zones", group=grpZone)
showHist     = input.bool(true,  "Show Historic Zones (faded)", group=grpZone)
histWinOnly  = input.bool(true,  "Historic: winners only (hide losses)", group=grpZone)
showHistLvls = input.bool(true,  "Historic: draw winner Entry/SL/TP levels", group=grpZone)
maxHistTr    = input.int(5,      "Historic trades to mark with levels", minval=1, maxval=20, group=grpZone)
zoneSrc      = input.string("Grab Wick", "Zone Source", options=["Grab Wick", "FU Candle Range"], group=grpZone)
maxZones     = input.int(15,     "Max Active Zones / side", minval=1, maxval=50, group=grpZone)
histCap      = input.int(60,     "Max Historic Zones", minval=1, maxval=200, group=grpZone)
showMid      = input.bool(true,  "Show 50% Midline", group=grpZone)
zoneTransp   = input.int(82,     "Active Zone Transparency", minval=0, maxval=100, group=grpZone)
histTransp   = input.int(90,     "Historic Zone Transparency", minval=0, maxval=100, group=grpZone)

grpVis   = "Appearance"
colBull      = input.color(#26a69a, "Bullish / Long", inline="c1", group=grpVis)
colBear      = input.color(#ef5350, "Bearish / Short", inline="c1", group=grpVis)
colWin       = input.color(#00c853, "Historic Win", inline="c2", group=grpVis)
colLoss      = input.color(#d50000, "Historic Loss", inline="c2", group=grpVis)
colTouch     = input.color(#ffb300, "Touched border", group=grpVis)
colorCandles = input.bool(true,  "Color FU Candles", group=grpVis)
showLabels   = input.bool(true,  "Show Zone Labels", group=grpVis)
labelSize    = input.string("Large", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpVis)

grpMtf   = "Multi-Timeframe (drawn only, not in stats)"
mtf1On       = input.bool(false, "TF 1", inline="m1", group=grpMtf)
mtf1         = input.timeframe("15", "", inline="m1", group=grpMtf)
mtf2On       = input.bool(false, "TF 2", inline="m2", group=grpMtf)
mtf2         = input.timeframe("60", "", inline="m2", group=grpMtf)
mtf3On       = input.bool(false, "TF 3", inline="m3", group=grpMtf)
mtf3         = input.timeframe("240", "", inline="m3", group=grpMtf)

grpDash  = "Stats Dashboard"
showDash     = input.bool(true,  "Show Stats Dashboard", group=grpDash)
dashPos      = input.string("Bottom Right", "Position", options=["Top Right","Bottom Right","Bottom Left"], group=grpDash)
dashSize     = input.string("Large", "Dashboard / Panel Text Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpDash)

grpAlert = "Alerts"
proxTicks    = input.int(20,     "Proximity (ticks)", minval=1, group=grpAlert)

pointSize = ptInput <= 0 ? syminfo.mintick : ptInput
lblSizeF  = labelSize == "Tiny" ? size.tiny : labelSize == "Small" ? size.small : labelSize == "Normal" ? size.normal : labelSize == "Huge" ? size.huge : size.large
dashSizeF = dashSize == "Tiny" ? size.tiny : dashSize == "Small" ? size.small : dashSize == "Normal" ? size.normal : dashSize == "Huge" ? size.huge : size.large
isReversal = dirLogic == "Reversal — Bullish FU = BUY"

tierOf(float sc)  => sc >= 8.0 ? 4 : sc >= 6.5 ? 3 : sc >= 5.0 ? 2 : 1
tierName(int t)   => t == 4 ? "S" : t == 3 ? "A" : t == 2 ? "B" : "C"
minTierV = minTier == "S" ? 4 : minTier == "A" ? 3 : minTier == "B" ? 2 : 1

detectFU() =>
    pH = high[1]
    pL = low[1]
    pO = open[1]
    pC = close[1]
    cH = high
    cL = low
    cO = open
    cC = close
    bodyTopPrev = math.max(pO, pC)
    bodyBotPrev = math.min(pO, pC)

    grab    = liqGrabPts * pointSize
    eng     = engulfPts  * pointSize
    minSz   = minSizePts * pointSize
    minBody = minBodyPts * pointSize
    maxBody = maxBodyPts * pointSize

    fuSize = cH - cL
    fuBody = math.abs(cC - cO)
    sizeOK = fuSize >= minSz and fuBody >= minBody and fuBody <= maxBody

    sweepDn = (pL - cL) >= grab
    sweepUp = (cH - pH) >= grab

    bullFull = sweepDn and cC > pH and cC > pO and (cC - pH) >= eng
    bullAtt  = useATT and not bullFull and sweepDn and cC > bodyTopPrev and cC <= pH and (cC - bodyTopPrev) >= eng
    bearFull = sweepUp and cC < pL and cC < pO and (pL - cC) >= eng
    bearAtt  = useATT and not bearFull and sweepUp and cC < bodyBotPrev and cC >= pL and (bodyBotPrev - cC) >= eng

    isBull = bullFull or bullAtt
    isBear = bearFull or bearAtt

    upWick = cH - math.max(cO, cC)
    dnWick = math.min(cO, cC) - cL
    rejOK  = not rejFilter or (isBull ? upWick <= fuBody : isBear ? dnWick <= fuBody : true)

    emaVal = ta.ema(close, emaLen)
    emaOK  = not emaFilter or (isBull ? cC > emaVal : isBear ? cC < emaVal : true)

    hh = ta.highest(high, fracLen)[1]
    ll = ta.lowest(low, fracLen)[1]
    fracOK = not fracFilter or (isBull ? cL < ll : isBear ? cH > hh : true)

    pRange = pH - pL
    pBody  = math.abs(pC - pO)
    pUp    = pH - bodyTopPrev
    pDn    = bodyBotPrev - pL
    biw    = useBIW and pRange > 0 and pBody <= 0.4 * pRange and pUp > 0 and pDn > 0
    biwOK  = not biwOnly or biw

    valid = sizeOK and rejOK and emaOK and fracOK and biwOK

    sig = 0
    if valid and bullFull
        sig := 2
    else if valid and bullAtt
        sig := 1
    else if valid and bearFull
        sig := -2
    else if valid and bearAtt
        sig := -1

    bull = sig > 0

    zTop = 0.0
    zBot = 0.0
    if sig != 0
        if zoneSrc == "Grab Wick"
            zTop := bull ? pL : cH
            zBot := bull ? cL : pH
        else
            zTop := cH
            zBot := cL

    avgVol = ta.sma(volume, volLen)
    volRat = avgVol > 0 ? volume / avgVol : 1.0
    atrV   = ta.atr(14)
    grabWk = bull ? dnWick : upWick
    oppWk  = bull ? upWick : dnWick
    bodyR  = fuSize > 0 ? fuBody / fuSize : 0.0
    oppR   = fuBody > 0 ? oppWk  / fuBody : 10.0
    grabR  = fuBody > 0 ? grabWk / fuBody : 10.0
    closeP = fuSize > 0 ? (bull ? (cC - cL) / fuSize : (cH - cC) / fuSize) : 0.0
    sizeA  = atrV   > 0 ? fuSize / atrV : 0.0
    qBody  = bodyR  >= 0.70 ? 3.0 : bodyR  >= 0.60 ? 2.5 : bodyR  >= 0.50 ? 2.0 : bodyR  >= 0.40 ? 1.0 : 0.5
    qOpp   = oppR   <= 0.20 ? 2.0 : oppR   <= 0.50 ? 1.5 : oppR   <= 1.00 ? 1.0 : 0.0
    qGrab  = grabR  <= 0.40 ? 2.0 : grabR  <= 0.60 ? 1.5 : grabR  <= 1.00 ? 1.0 : 0.0
    qClose = closeP >= 0.90 ? 2.0 : closeP >= 0.85 ? 1.5 : closeP >= 0.75 ? 1.0 : 0.0
    qMisc  = (sizeA >= 0.8 and sizeA <= 2.0 ? 0.5 : 0.0) + (volRat >= 1.0 ? 0.5 : 0.0)
    strength = sig == 0 ? 0.0 : math.min(10.0, qBody + qOpp + qGrab + qClose + qMisc)

    isBuy = isReversal ? (sig > 0) : (sig < 0)
    buf   = slBufPts * pointSize
    entry = entryType == "50% Body" ? (cO + cC) / 2 : entryType == "50% Wick" ? (cH + cL) / 2 : cC
    sl    = isBuy ? cL - buf : cH + buf
    risk  = math.abs(entry - sl)
    tp1   = isBuy ? entry + risk * tp1R : entry - risk * tp1R
    dirT  = sig == 0 ? 0 : (isBuy ? 1 : -1)

    [sig, zTop, zBot, strength, biw ? 1 : 0, dirT, entry, sl, tp1, risk]

type FUZone
    box    bx
    line   mid
    label  lb
    float  top
    float  bot
    int    dir
    int    barFormed
    int    btime
    float  strength
    float  entry
    float  sl
    float  tp1
    bool   touched
    bool   resolved
    bool   win
    bool   isCTF

var array<FUZone> activeZones = array.new<FUZone>()
var array<FUZone> histZones   = array.new<FUZone>()
var array<line>   histLines   = array.new<line>()

var int   bWins=0
var int   bLoss=0
var int   bTouch=0
var int   bTot=0
var float bWinBars=0.0
var float bLossBars=0.0
var float bStrSum=0.0
var int   sWins=0
var int   sLoss=0
var int   sTouch=0
var int   sTot=0
var float sWinBars=0.0
var float sLossBars=0.0
var float sStrSum=0.0

compute_stats(int w, int l, int t, int n, float wb, float lb) =>
    dec = w + l
    wr  = dec > 0 ? float(w) / float(dec) * 100.0 : na
    pt  = n   > 0 ? float(t) / float(n)   * 100.0 : na
    aw  = w   > 0 ? wb / float(w) : na
    al  = l   > 0 ? lb / float(l) : na
    wrf = na(wr) ? 0.0 : wr / 100.0
    ev  = wrf * tp1R - (1.0 - wrf) * 1.0
    [wr, pt, aw, al, ev]

[bWR, bPT, bAW, bAL, bEV] = compute_stats(bWins, bLoss, bTouch, bTot, bWinBars, bLossBars)
[sWR, sPT, sAW, sAL, sEV] = compute_stats(sWins, sLoss, sTouch, sTot, sWinBars, sLossBars)

zoneLabel(int dir, string tf, float strength, bool biw) =>
    long = dir > 0
    wr   = long ? bWR : sWR
    n    = long ? bTot : sTot
    wrTxt = na(wr) ? "n/a" : str.tostring(wr, "#") + "%"
    tf + " " + (long ? "BUY" : "SELL") + " • " + tierName(tierOf(strength)) + " " + (biw ? "+" : "") + str.tostring(strength, "#.#") + "/10 • WR " + wrTxt + " (n" + str.tostring(n) + ")"

fadeToHistoric(FUZone z) =>
    isWin = z.resolved and z.win
    keepBox = showHist and (not histWinOnly or isWin)
    if keepBox
        col = isWin ? colWin : (z.resolved ? colLoss : color.gray)
        z.bx.set_bgcolor(color.new(col, histTransp))
        z.bx.set_border_color(color.new(col, math.max(0, histTransp - 12)))
        z.bx.set_right(bar_index)
        z.bx.set_extend(extend.none)
        if not na(z.lb)
            z.lb.delete()
            z.lb := na
        if not na(z.mid)
            z.mid.delete()
            z.mid := na
        histZones.push(z)
        if histZones.size() > histCap
            old = histZones.shift()
            old.bx.delete()
    else
        z.bx.delete()
        if not na(z.lb)
            z.lb.delete()
        if not na(z.mid)
            z.mid.delete()
    if isWin and showHistLvls
        risk = math.abs(z.entry - z.sl)
        t2 = z.dir > 0 ? z.entry + risk * tp2R : z.entry - risk * tp2R
        t3 = z.dir > 0 ? z.entry + risk * tp3R : z.entry - risk * tp3R
        le = z.btime
        rt = time
        histLines.push(line.new(le, z.entry, rt, z.entry, xloc=xloc.bar_time, color=color.new(#2962ff, 10), width=1))
        histLines.push(line.new(le, z.sl,    rt, z.sl,    xloc=xloc.bar_time, color=color.new(colLoss, 25), width=1, style=line.style_dotted))
        histLines.push(line.new(le, z.tp1,   rt, z.tp1,   xloc=xloc.bar_time, color=color.new(colWin, 10), width=1))
        histLines.push(line.new(le, t2,      rt, t2,      xloc=xloc.bar_time, color=color.new(colWin, 30), width=1))
        histLines.push(line.new(le, t3,      rt, t3,      xloc=xloc.bar_time, color=color.new(colWin, 45), width=1))
        while histLines.size() > maxHistTr * 5
            line.delete(histLines.shift())

makeZone(int dir, float top, float bot, float strength, bool biw, string tf, float entry, float sl, float tp1, bool isCTF) =>
    if showZones and top > bot
        baseCol = dir > 0 ? colBull : colBear
        bx = box.new(bar_index, top, bar_index, bot, border_color=color.new(baseCol, 35), border_width=1, bgcolor=color.new(baseCol, zoneTransp))
        ln = showMid ? line.new(bar_index, (top + bot) / 2, bar_index, (top + bot) / 2, color=color.new(baseCol, 25), style=line.style_dashed) : na
        lb = showLabels ? label.new(bar_index, top, zoneLabel(dir, tf, strength, biw), style=dir > 0 ? label.style_label_down : label.style_label_up, color=color.new(baseCol, 20), textcolor=color.white, size=lblSizeF) : na
        z = FUZone.new(bx, ln, lb, top, bot, dir, bar_index, time, strength, entry, sl, tp1, false, false, false, isCTF)
        activeZones.push(z)
        if activeZones.size() > maxZones * 2
            fadeToHistoric(activeZones.shift())

[sigC, topC, botC, strC, biwC, dirC, entryC, slC, tp1C, riskC] = detectFU()

buySignal  = false
sellSignal = false

if barstate.isconfirmed and sigC != 0 and strC >= minStrength and tierOf(strC) >= minTierV
    makeZone(dirC, topC, botC, strC, biwC == 1, timeframe.period, entryC, slC, tp1C, true)
    if dirC > 0
        bTot += 1
        bStrSum += strC
    else
        sTot += 1
        sStrSum += strC
    buySignal  := dirC > 0
    sellSignal := dirC < 0

tierTransp = strC >= 8.0 ? 0 : strC >= 6.5 ? 25 : strC >= 5.0 ? 45 : 65
qualifies  = sigC != 0 and tierOf(strC) >= minTierV and strC >= minStrength
candleCol = colorCandles and qualifies ? (sigC > 0 ? color.new(colBull, tierTransp) : color.new(colBear, tierTransp)) : na
barcolor(candleCol)

mtfBull = false
mtfBear = false

handleMTF(bool on, string tf) =>
    [s_, tp_, bt_, st_, bw_, dr_, en_, sl_, t1_, rk_] = request.security(syminfo.tickerid, tf, detectFU(), lookahead=barmerge.lookahead_off)
    sChg = ta.change(s_)
    fired = false
    s = 0
    if on and s_ != 0 and sChg != 0 and st_ >= minStrength and tierOf(st_) >= minTierV
        makeZone(dr_, tp_, bt_, st_, bw_ == 1, tf, en_, sl_, t1_, false)
        fired := true
        s := s_
    [fired, s]

[f1, sg1] = handleMTF(mtf1On, mtf1)
[f2, sg2] = handleMTF(mtf2On, mtf2)
[f3, sg3] = handleMTF(mtf3On, mtf3)
mtfBull := (f1 and sg1 > 0) or (f2 and sg2 > 0) or (f3 and sg3 > 0)
mtfBear := (f1 and sg1 < 0) or (f2 and sg2 < 0) or (f3 and sg3 < 0)

bool touchEvent = false
bool proxEvent  = false
prox = proxTicks * syminfo.mintick

if activeZones.size() > 0
    for i = activeZones.size() - 1 to 0
        z = activeZones.get(i)
        z.bx.set_right(bar_index)
        if not na(z.mid)
            z.mid.set_x2(bar_index)
        if not na(z.lb)
            z.lb.set_x(bar_index)

        if not z.touched
            dist = z.dir > 0 ? z.entry - close : close - z.entry
            if dist > 0 and dist <= prox
                proxEvent := true

        if not z.touched and bar_index > z.barFormed
            hit = z.dir > 0 ? low <= z.entry : high >= z.entry
            if hit
                z.touched := true
                z.bx.set_border_color(colTouch)
                touchEvent := true
                if z.isCTF
                    if z.dir > 0
                        bTouch += 1
                    else
                        sTouch += 1

        if z.touched and not z.resolved
            if z.dir > 0
                if low <= z.sl
                    z.resolved := true
                    z.win := false
                else if high >= z.tp1
                    z.resolved := true
                    z.win := true
            else
                if high >= z.sl
                    z.resolved := true
                    z.win := false
                else if low <= z.tp1
                    z.resolved := true
                    z.win := true
            if z.resolved
                bars = bar_index - z.barFormed
                if z.isCTF
                    if z.dir > 0
                        if z.win
                            bWins += 1
                            bWinBars += bars
                        else
                            bLoss += 1
                            bLossBars += bars
                    else
                        if z.win
                            sWins += 1
                            sWinBars += bars
                        else
                            sLoss += 1
                            sLossBars += bars
                fadeToHistoric(z)
                activeZones.remove(i)

var line  lnE=na
var line  lnS=na
var line  lnT1=na
var line  lnT2=na
var line  lnT3=na
var label lbE=na
var label lbS=na
var label lbT1=na
var label lbT2=na
var label lbT3=na
var int    tDir=0
var float  tEntry=na
var float  tSL=na
var float  tT1=na
var float  tT2=na
var float  tT3=na
var bool   tActive=false
var bool   tFilled=false
var int    tBar=na
var string tStatus="—"

if showTrade and barstate.isconfirmed and sigC != 0 and strC >= minStrength and tierOf(strC) >= minTierV
    t2 = dirC > 0 ? entryC + riskC * tp2R : entryC - riskC * tp2R
    t3 = dirC > 0 ? entryC + riskC * tp3R : entryC - riskC * tp3R
    if not na(lnE)
        lnE.delete()
        lnS.delete()
        lnT1.delete()
        lnT2.delete()
        lnT3.delete()
        lbE.delete()
        lbS.delete()
        lbT1.delete()
        lbT2.delete()
        lbT3.delete()
    re = bar_index + rightOff
    dw = dirC > 0 ? "BUY" : "SELL"
    lnE  := line.new(bar_index, entryC, re, entryC, color=color.new(#2962ff,0), width=2)
    lnS  := line.new(bar_index, slC,    re, slC,    color=color.new(colLoss,0), width=2, style=line.style_dashed)
    lnT1 := line.new(bar_index, tp1C,   re, tp1C,   color=color.new(colWin,0),  width=1)
    lnT2 := line.new(bar_index, t2,     re, t2,     color=color.new(colWin,0),  width=1)
    lnT3 := line.new(bar_index, t3,     re, t3,     color=color.new(colWin,0),  width=1)
    lbE  := label.new(re, entryC, dw + " @ " + str.tostring(entryC, format.mintick), style=label.style_label_left, color=dirC>0?colBull:colBear, textcolor=color.white, size=lblSizeF)
    lbS  := label.new(re, slC,  "SL @ " + str.tostring(slC, format.mintick), style=label.style_label_left, color=colLoss, textcolor=color.white, size=lblSizeF)
    lbT1 := label.new(re, tp1C, "TP1 (" + str.tostring(tp1R,"#.#") + "R) @ " + str.tostring(tp1C, format.mintick), style=label.style_label_left, color=colWin, textcolor=color.white, size=lblSizeF)
    lbT2 := label.new(re, t2,   "TP2 (" + str.tostring(tp2R,"#.#") + "R) @ " + str.tostring(t2, format.mintick), style=label.style_label_left, color=colWin, textcolor=color.white, size=lblSizeF)
    lbT3 := label.new(re, t3,   "TP3 (" + str.tostring(tp3R,"#.#") + "R) @ " + str.tostring(t3, format.mintick), style=label.style_label_left, color=colWin, textcolor=color.white, size=lblSizeF)
    tDir:=dirC
    tEntry:=entryC
    tSL:=slC
    tT1:=tp1C
    tT2:=t2
    tT3:=t3
    tActive:=true
    tFilled:=false
    tBar:=bar_index
    tStatus:="PENDING — limit not filled yet"

if tActive and not na(tBar) and bar_index > tBar
    re2 = bar_index + rightOff
    if not na(lnE)
        lnE.set_x2(re2)
        lnS.set_x2(re2)
        lnT1.set_x2(re2)
        lnT2.set_x2(re2)
        lnT3.set_x2(re2)
        lbE.set_x(re2)
        lbS.set_x(re2)
        lbT1.set_x(re2)
        lbT2.set_x(re2)
        lbT3.set_x(re2)
    if not tFilled
        fillHit = tDir > 0 ? low <= tEntry : high >= tEntry
        if fillHit
            tFilled := true
            tStatus := "FILLED — in trade"
        else
            missed = tDir > 0 ? high >= tT3 : low <= tT3
            if missed
                tStatus := "NO FILL — missed (price ran)"
                tActive := false
    if tFilled and tActive
        if tDir > 0
            if low <= tSL
                tStatus := "STOPPED OUT  ✗"
                tActive := false
            else if high >= tT3
                tStatus := "TP3 HIT  ✓✓✓"
                tActive := false
            else if high >= tT2
                tStatus := "TP2 hit  ✓✓"
            else if high >= tT1
                tStatus := "TP1 hit  ✓"
        else
            if high >= tSL
                tStatus := "STOPPED OUT  ✗"
                tActive := false
            else if low <= tT3
                tStatus := "TP3 HIT  ✓✓✓"
                tActive := false
            else if low <= tT2
                tStatus := "TP2 hit  ✓✓"
            else if low <= tT1
                tStatus := "TP1 hit  ✓"

fmtP(v) => na(v) ? "—" : str.tostring(v, format.mintick)

var table tpnl = table.new(position.top_right, 2, 7, frame_color=color.new(color.gray,40), frame_width=1, border_color=color.new(color.gray,60), border_width=1)
if showPanel and barstate.islast
    dirTxt = tDir>0?"BUY":tDir<0?"SELL":"—"
    dirCol = tDir>0?colBull:tDir<0?colBear:color.gray
    hb = color.new(color.black,10)
    rb = color.new(color.black,30)
    table.cell(tpnl,0,0,"FU SIGNAL",text_color=color.white,bgcolor=hb,text_size=dashSizeF)
    table.cell(tpnl,1,0,dirTxt,text_color=color.white,bgcolor=dirCol,text_size=dashSizeF)
    table.cell(tpnl,0,1,"Entry",text_color=color.white,bgcolor=rb,text_size=dashSizeF)
    table.cell(tpnl,1,1,fmtP(tEntry),text_color=color.white,bgcolor=rb,text_size=dashSizeF)
    table.cell(tpnl,0,2,"Stop",text_color=color.white,bgcolor=rb,text_size=dashSizeF)
    table.cell(tpnl,1,2,fmtP(tSL),text_color=#ff8a80,bgcolor=rb,text_size=dashSizeF)
    table.cell(tpnl,0,3,"TP1",text_color=color.white,bgcolor=rb,text_size=dashSizeF)
    table.cell(tpnl,1,3,fmtP(tT1),text_color=#b9f6ca,bgcolor=rb,text_size=dashSizeF)
    table.cell(tpnl,0,4,"TP2",text_color=color.white,bgcolor=rb,text_size=dashSizeF)
    table.cell(tpnl,1,4,fmtP(tT2),text_color=#b9f6ca,bgcolor=rb,text_size=dashSizeF)
    table.cell(tpnl,0,5,"TP3",text_color=color.white,bgcolor=rb,text_size=dashSizeF)
    table.cell(tpnl,1,5,fmtP(tT3),text_color=#b9f6ca,bgcolor=rb,text_size=dashSizeF)
    table.cell(tpnl,0,6,"Status",text_color=color.white,bgcolor=hb,text_size=dashSizeF)
    table.cell(tpnl,1,6,tStatus,text_color=color.white,bgcolor=hb,text_size=dashSizeF)

dashPosV = dashPos == "Top Right" ? position.top_right : dashPos == "Bottom Left" ? position.bottom_left : position.bottom_right
var table ds = table.new(dashPosV, 3, 9, frame_color=color.new(color.gray,40), frame_width=1, border_color=color.new(color.gray,70), border_width=1)

pctTxt(v) => na(v) ? "n/a" : str.tostring(v, "#.#") + "%"
barTxt(v) => na(v) ? "n/a" : str.tostring(v, "#.#")
evTxt(v)  => (v>=0?"+":"") + str.tostring(v,"#.##") + "R"

if showDash and barstate.islast
    hb = color.new(color.gray,15)
    rb = color.new(color.black,25)
    table.cell(ds,0,0,"FU STATS (this TF) • Tier≥"+minTier,text_color=color.white,bgcolor=hb,text_size=dashSizeF,text_halign=text.align_center)
    table.merge_cells(ds,0,0,2,0)
    table.cell(ds,0,1,"Metric",text_color=color.white,bgcolor=color.new(color.gray,40),text_size=dashSizeF)
    table.cell(ds,1,1,"BUY", text_color=color.white,bgcolor=color.new(colBull,40),text_size=dashSizeF,text_halign=text.align_center)
    table.cell(ds,2,1,"SELL",text_color=color.white,bgcolor=color.new(colBear,40),text_size=dashSizeF,text_halign=text.align_center)
    bAvgStr = bTot>0 ? bStrSum/bTot : na
    sAvgStr = sTot>0 ? sStrSum/sTot : na
    rows  = array.from("Win Rate","P(Touch)","Exp.Value","R : R","Avg Win","Avg Loss","W/L • n • Score")
    bvals = array.from(pctTxt(bWR), pctTxt(bPT), evTxt(bEV), "1:"+str.tostring(tp1R,"#.#"), barTxt(bAW)+"b", barTxt(bAL)+"b", str.tostring(bWins)+"/"+str.tostring(bLoss)+" • "+str.tostring(bTot)+" • "+barTxt(bAvgStr))
    svals = array.from(pctTxt(sWR), pctTxt(sPT), evTxt(sEV), "1:"+str.tostring(tp1R,"#.#"), barTxt(sAW)+"b", barTxt(sAL)+"b", str.tostring(sWins)+"/"+str.tostring(sLoss)+" • "+str.tostring(sTot)+" • "+barTxt(sAvgStr))
    for r = 0 to 6
        table.cell(ds,0,r+2,array.get(rows,r),text_color=color.white,bgcolor=rb,text_size=dashSizeF)
        table.cell(ds,1,r+2,array.get(bvals,r),text_color=color.new(colBull,0),bgcolor=rb,text_size=dashSizeF,text_halign=text.align_center)
        table.cell(ds,2,r+2,array.get(svals,r),text_color=color.new(colBear,0),bgcolor=rb,text_size=dashSizeF,text_halign=text.align_center)

anyBull = buySignal or mtfBull
anyBear = sellSignal or mtfBear
alertcondition(buySignal,  "BUY Setup",  "FU BUY setup formed")
alertcondition(sellSignal, "SELL Setup", "FU SELL setup formed")
alertcondition(anyBull,    "Bullish FU (any TF)", "Bullish FU detected")
alertcondition(anyBear,    "Bearish FU (any TF)", "Bearish FU detected")
alertcondition(touchEvent, "Zone Touch", "Price touched an FU zone (entry filled)")
alertcondition(proxEvent,  "Zone Proximity", "Price approaching an FU zone")
````
