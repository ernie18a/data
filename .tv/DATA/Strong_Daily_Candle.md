<!-- tradingview-pine-id: PUB;61a44db7bc214f12b96af21240a065d6 -->
<!-- tradingviewscripts-format: 1 -->
# Strong Daily Candle

Source: https://www.tradingview.com/script/XtaGKK2y-Strong-Daily-Candle-ProjectSyndicate/

## Description

Strong Daily Candle

Strong Daily Candle grades the one candle that every institution, fund and algo actually settles on — the daily close — and refuses to trade until that candle proves it was a day of real conviction. Every daily bar is scored 0–10 on its raw power: how much of its range is decisive body, how hard it closed toward the extreme, how far it expanded beyond its own average range, how little it got rejected against its direction, and whether volume showed up to back it. Only when a day earns a high enough score does the tool project a full trade from it — entry, stop and three targets — and then honestly track how that setup resolved. It is built to run on the Daily (1D) chart, where a "strong candle" means a strong day.

Most candle tools just slap a name on a shape — "engulfing", "marubozu", "pin bar" — and leave you to guess whether it mattered. This one measures the day's conviction on a graded scale, gates every setup behind a strength threshold you control, turns the qualifying candle into a structured trade, and keeps an honest on-chart tally of how those setups played out. No pattern-spotting. A number, a tier, and a plan.

📊 The 0–10 Daily Strength Engine — the core. Every daily candle is scored on five institutional tells and summed to a 0–10 ceiling: BODY DOMINANCE (how much of the range is real body vs wick), CLOSE POSITION (how tightly it closed into the extreme in its own direction), RANGE EXPANSION (today's range measured against ATR — an expansion day vs a nothing day), OPPOSITE-WICK SMALLNESS (a strong bull with no upper rejection, a strong bear with no lower rejection), and VOLUME EXPANSION (did participation confirm the move). A clean, decisive trend day scores high; a wide-wicked, indecisive doti-day scores low — automatically, on every bar.

🎯 One Gate, You Set It. The whole point: nothing plots, colours or counts unless the day clears your strength gate — default 6.0/10. Raise it to 7 or 8 for only the most violent, one-sided days; drop it to see more. This is the filter that turns "every candle" into "only the days worth trading".

🏅 Tiered Quality (C → B → A → S). On top of the raw score, every qualifying day is stamped with a tier — S (≥ 8.0), A (≥ 6.5), B (≥ 5.0), C (below) — so you can read conviction at a glance and gate by tier as well as by number. S-tier days are the cleanest expressions of one-directional intent the market prints.

🧭 Momentum or Fade — you choose the thesis. MOMENTUM (default): a strong bull day = BUY, a strong bear day = SELL — you trade with the day's proven force, entering on the pullback. FADE: the logic inverts — a strong bull day = SELL — for traders who want to counter an over-extended, exhausted move back toward value. One toggle, two completely different playbooks off the same engine.

🧱 Auto Trade Levels — the qualifying day becomes a plan. The instant a day closes strong enough, the tool projects: an ENTRY (50% of the body, 50% of the range, or the candle close — your pick), a STRUCTURAL STOP just beyond the day's low (BUY) or high (SELL) with an adjustable buffer, and TP1 / TP2 / TP3 at your chosen R multiples (default 1R / 2R / 3R). The latest setup is drawn live on the chart with entry, stop and all three targets labelled.

🟩 Direction-Coloured Setup Zones. Each qualifying day drops a demand/supply zone — built from the candle body or full range — with a 50% midline. BUY zones are always teal, SELL zones are always red, active or closed, so a bullish setup never masquerades as a red box. When a zone closes it keeps its direction colour and gets a clean ✓ / ✗ outcome tag; every winning setup also draws its full Entry / SL / TP ladder into history so you can see exactly how it ran.

🧾 Live DAILY SIGNAL Panel. A fixed panel prints the current plan — direction, Entry, Stop, TP1/2/3 — and a live STATUS that walks the trade in real time: PENDING (waiting for the pullback fill) → FILLED → TP1 hit → TP2 hit → TP3 HIT, or STOPPED OUT. You always know where the latest setup stands without measuring anything.

📈 Honest Win-Rate Dashboard — separated BUY vs SELL. The dashboard tallies how the gated setups actually resolved on your chart: WIN RATE, P(TOUCH) (how often price even reached the entry), EXPECTANCY in R, R:R, average WIN and LOSS duration in days, and a running W/L · sample size · average score. Every closed setup is counted — winners and losers alike — and when a single day could hit both stop and target, it is booked pessimistically as a loss. The numbers are never flattered.

🌗 This-Candle Live Read. At the top of the dashboard, the still-forming day shows its live score, tier and direction, plus a banner that tells you plainly: ✓ a strong setup is forming, ✗ it's below the gate (and by how much), it's a flat/doji day with no direction, or you're not on a Daily chart. You see the day building toward — or failing — the gate in real time.

🎨 Fully Themed & Configurable. Strength gate and minimum tier, momentum/fade logic, entry model, stop buffer and R targets, optional filters (rejection-wick filter, EMA trend filter, minimum range × ATR), zone source (body or range), active/historic colours and transparencies, historic colour mode (by direction or by win/loss), outcome tags, midline, label and dashboard sizing, zone caps, dashboard position, and full alertconditions for BUY, SELL, zone touch and zone proximity.

🔒 Honest, Non-Repaint Core. The "this candle" read updates intrabar as the day forms — inherent to showing a live daily candle, not a defect. But every committed output — the setup zone, the entry/stop/targets, and the statistics — is locked to the CONFIRMED daily close and never redraws afterward to flatter the chart. The 0–10 scores are descriptive ranking frameworks for directing attention, and the dashboard is an on-chart simulation of the fixed-R model over your history — not a guarantee of future results.

🚀 Built for the Daily chart, any market. Forex, indices, metals, crypto, equities — anywhere a daily candle carries meaning. The Daily-timeframe guard is on by default so the engine only runs where it's designed to; advanced users can disable it to score any chart's candles.

🎯 How To Trade It — Trade The Day That Proved Itself

⏱️ Load the indicator on a Daily (1D) chart — the whole model is a read on the daily candle. Set your gate (start at 6.0) and your logic (Momentum by default).

Everything hinges on one read: the day just closed with graded, measurable conviction — trade the pullback expecting that force to continue, or, in Fade mode, trade the snap-back when the day over-extended.

◾ 1) Strong-day continuation (the core thesis — Momentum mode)

Use when a daily candle closes strong enough to clear your gate.

▪️ A strong BULL day scores ≥ gate → a teal BUY zone drops on the candle with entry, stop and targets projected. ▪️ Wait for price to rotate back into the zone — ideally to the 50% body / midline — rather than chasing the close. ▪️ Entry: long on the reaction inside the buy zone; the higher the score and tier (A/S), the more the day insisted on that direction. ▪️ Stop: below the day's low (auto-placed) — if price accepts beneath it, the day's control failed; stand aside. ▪️ Targets: TP1 (1R) to bank, then TP2 / TP3 as the continuation extends.

The mirror applies to a strong BEAR day → red SELL zone up top: fade rallies into it, stop above the day's high, targets down.

◾ 2) Let the tier size the trade

▪️ S / A-tier days are the cleanest one-directional intent — press these with confidence. ▪️ B-tier days clear a lower bar — demand extra confluence or trade them smaller. ▪️ Want fewer, higher-quality setups? Raise the gate to 7–8 and the minimum tier to A. The engine simply shows you less, and better.

◾ 3) Fade mode — trade exhaustion, not continuation

▪️ After an over-stretched big day slams into a higher-timeframe level, switch to Fade: a strong bull day becomes a counter-trend SELL back toward value. ▪️ Best used with context — a spent extreme, a prior swing, a session's end — not blindly against every strong close.

◾ 4) Stand down — the map says wait

▪️ Doji / flat day → no direction → no setup drew → no edge this day. ▪️ Below-gate day → the move lacked body, expansion or conviction → the banner reads ✗. ▪️ Price already accepted through the zone → the level is spent. Let the next daily close reset the map.

Rule of thumb: ⭐ A high-score, high-tier daily candle + price rotating back into its graded zone + your gate respected → trade the continuation with the day's force. ⭐ A weak, wicky, below-gate or already-consumed day → stand down until the next close sets a new map.

⚠️ IMPORTANT NOTICE: Strong Daily Candle is a structure- and conviction-mapping tool for the Daily timeframe. The 0–10 strength score is a descriptive ranking of a candle's geometry and volume — a model of behaviour, NOT exchange order-flow data, NOT a backtested signal, and NOT a standalone trade trigger. The on-chart statistics are a simulation of the fixed-R setup logic over your chart's own history under pessimistic (stop-first) assumptions; they describe the past, not the future. Trading strong-candle continuations and fades still carries real risk of failed levels and stop-outs. Always combine it with your own strategy, price-action analysis, higher-timeframe context and risk management. Past behaviour does not guarantee future results.

---

## Source Code

````pine
//@version=6
indicator("Strong Daily Candle", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

grpDet   = "Detection"
reqDaily     = input.bool(true,  "Require Daily (1D) chart", tooltip="ON = only detect/plot when the chart timeframe is Daily. OFF = score whatever candle the current chart shows (advanced).", group=grpDet)
ptInput      = input.float(0.0,  "Point Size (0 = auto / mintick)", minval=0.0, step=0.00001, tooltip="Price value of 1 'point' for buffers. 0 = instrument mintick.", group=grpDet)
minRangeATR  = input.float(0.0,  "Min Range (x ATR, 0 = off)", minval=0.0, step=0.1, tooltip="Require the daily range to be at least this multiple of ATR before a candle can qualify.", group=grpDet)
atrLen       = input.int(14,     "ATR Length", minval=1, group=grpDet)
volLen       = input.int(20,     "Volume Avg Length", minval=1, group=grpDet)

grpFil   = "Filters"
rejFilter    = input.bool(false, "Rejection Filter", tooltip="Drop candles where the wick against the candle's direction is larger than the body.", group=grpFil)
emaFilter    = input.bool(false, "EMA Trend Filter", tooltip="Bull candle only above EMA, bear candle only below EMA.", group=grpFil)
emaLen       = input.int(20,     "EMA Length", minval=1, group=grpFil)

grpStr   = "Quality / Tier Ranking"
minStrength  = input.float(6.0,  "Min. Daily Strength (0-10)", minval=0.0, maxval=10.0, step=0.5, tooltip="PRIMARY GATE. Only candles scoring at least this are traded/plotted. Default 6.0 as requested.", group=grpStr)
minTier      = input.string("B", "Minimum Tier to show", options=["C","B","A","S"], tooltip="Secondary tier gate on the 0-10 score. S>=8.0, A>=6.5, B>=5.0, C otherwise.", group=grpStr)

grpTrade = "Trade Levels / Logic"
dirLogic  = input.string("Momentum - Bull candle = BUY", "Direction Logic", options=["Momentum - Bull candle = BUY", "Fade - Bull candle = SELL"], tooltip="Momentum (default): strong bull day = BUY, strong bear day = SELL. Fade = opposite.", group=grpTrade)
entryType = input.string("50% Body", "Entry At", options=["50% Body", "50% Range", "Candle Close"], group=grpTrade)
slBufPts  = input.float(5,      "Stop Buffer (points)", minval=0, group=grpTrade)
tp1R      = input.float(1.0,    "TP1 (R)", minval=0.1, step=0.5, group=grpTrade)
tp2R      = input.float(2.0,    "TP2 (R)", minval=0.1, step=0.5, group=grpTrade)
tp3R      = input.float(3.0,    "TP3 (R)", minval=0.1, step=0.5, group=grpTrade)
showTrade = input.bool(true,    "Show Trade Lines (latest setup)", group=grpTrade)
rightOff  = input.int(40,       "Line Length (bars)", minval=1, group=grpTrade)
showPanel = input.bool(true,    "Show Trade Panel", group=grpTrade)

grpZone  = "Liquidity Zones"
showZones    = input.bool(true,  "Show Active Zones", group=grpZone)
showHist     = input.bool(true,  "Show Historic Zones (faded)", group=grpZone)
histWinOnly  = input.bool(false, "Historic: winners only (hide losses)", tooltip="Visual only - losers are ALWAYS still counted in the stats.", group=grpZone)
showHistLvls = input.bool(true,  "Historic: draw winner Entry/SL/TP levels", group=grpZone)
maxHistTr    = input.int(5,      "Historic trades to mark with levels", minval=1, maxval=20, group=grpZone)
histColorMode= input.string("By Direction", "Historic Zone Colour", options=["By Direction","By Win/Loss"], tooltip="By Direction (default): a BUY zone stays teal and a SELL zone stays red even after it closes — win/loss is shown by a ✓/✗ tag instead. By Win/Loss: recolour the whole box green (win) / red (loss).", group=grpZone)
histTag      = input.bool(true,  "Historic: mark outcome (✓ / ✗)", tooltip="Stamp a ✓ WIN / ✗ LOSS tag on each closed zone. Losers are always kept and counted regardless.", group=grpZone)
zoneSrc      = input.string("Candle Range", "Zone Source", options=["Candle Body", "Candle Range"], group=grpZone)
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
colorCandles = input.bool(true,  "Color Strong Candles", group=grpVis)
showLabels   = input.bool(true,  "Show Zone Labels", group=grpVis)
labelSize    = input.string("Normal", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpVis)

grpDash  = "Stats Dashboard"
showDash     = input.bool(true,  "Show Stats Dashboard", group=grpDash)
dashPos      = input.string("Bottom Right", "Position", options=["Top Right","Bottom Right","Bottom Left"], group=grpDash)
dashSize     = input.string("Normal", "Dashboard / Panel Text Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpDash)

grpAlert = "Alerts"
proxTicks    = input.int(20,     "Proximity (ticks)", minval=1, group=grpAlert)

pointSize  = ptInput <= 0 ? syminfo.mintick : ptInput
lblSizeF   = labelSize == "Tiny" ? size.tiny : labelSize == "Small" ? size.small : labelSize == "Normal" ? size.normal : labelSize == "Huge" ? size.huge : size.large
dashSizeF  = dashSize == "Tiny" ? size.tiny : dashSize == "Small" ? size.small : dashSize == "Normal" ? size.normal : dashSize == "Huge" ? size.huge : size.large
isMomentum = dirLogic == "Momentum - Bull candle = BUY"
activeTF   = not reqDaily or timeframe.isdaily

tierOf(float sc)  => sc >= 8.0 ? 4 : sc >= 6.5 ? 3 : sc >= 5.0 ? 2 : 1
tierName(int t)   => t == 4 ? "S" : t == 3 ? "A" : t == 2 ? "B" : "C"
minTierV = minTier == "S" ? 4 : minTier == "A" ? 3 : minTier == "B" ? 2 : 1

// -----------------------------------------------------------------------------
// Daily-candle strength model (0-10) + directional trade levels
// -----------------------------------------------------------------------------
detectDaily() =>
    o = open
    h = high
    l = low
    c = close
    rng  = h - l
    body = math.abs(c - o)
    bull = c > o
    bear = c < o

    atrV   = ta.atr(atrLen)
    avgVol = ta.sma(volume, volLen)
    volRat = avgVol > 0 ? volume / avgVol : 1.0

    bodyRatio = rng > 0 ? body / rng : 0.0
    closePos  = rng > 0 ? (bull ? (c - l) / rng : bear ? (h - c) / rng : 0.0) : 0.0
    rangeATR  = atrV > 0 ? rng / atrV : 0.0
    upWick    = h - math.max(o, c)
    dnWick    = math.min(o, c) - l
    oppWick   = bull ? upWick : dnWick
    oppWickR  = body > 0 ? oppWick / body : 10.0

    // component scores (sum to a 0-10 ceiling)
    qBody  = bodyRatio >= 0.80 ? 3.0 : bodyRatio >= 0.65 ? 2.5 : bodyRatio >= 0.50 ? 2.0 : bodyRatio >= 0.35 ? 1.0 : 0.5
    qClose = closePos  >= 0.90 ? 2.5 : closePos  >= 0.80 ? 2.0 : closePos  >= 0.70 ? 1.5 : closePos  >= 0.60 ? 1.0 : 0.5
    qRange = rangeATR  >= 1.50 ? 2.0 : rangeATR  >= 1.20 ? 1.5 : rangeATR  >= 1.00 ? 1.0 : rangeATR  >= 0.80 ? 0.5 : 0.0
    qOpp   = oppWickR  <= 0.15 ? 1.5 : oppWickR  <= 0.30 ? 1.0 : oppWickR  <= 0.60 ? 0.5 : 0.0
    qVol   = volRat    >= 1.50 ? 1.0 : volRat    >= 1.00 ? 0.6 : volRat    >= 0.70 ? 0.3 : 0.0
    rawStr = qBody + qClose + qRange + qOpp + qVol

    sizeOK = minRangeATR <= 0 or rangeATR >= minRangeATR
    rejOK  = not rejFilter or oppWick <= body
    emaVal = ta.ema(close, emaLen)
    emaOK  = not emaFilter or (bull ? c > emaVal : bear ? c < emaVal : false)

    isCandle = (bull or bear) and sizeOK and rejOK and emaOK
    sig = isCandle ? (bull ? 1 : -1) : 0
    strength = sig == 0 ? 0.0 : math.min(10.0, rawStr)

    dirTrade = sig == 0 ? 0 : (isMomentum ? sig : -sig)
    isBuy = dirTrade > 0

    zTop = 0.0
    zBot = 0.0
    if sig != 0
        if zoneSrc == "Candle Body"
            zTop := math.max(o, c)
            zBot := math.min(o, c)
        else
            zTop := h
            zBot := l

    buf   = slBufPts * pointSize
    entry = entryType == "50% Body" ? (o + c) / 2 : entryType == "50% Range" ? (h + l) / 2 : c
    sl    = isBuy ? l - buf : h + buf
    risk  = math.abs(entry - sl)
    tp1   = isBuy ? entry + risk * tp1R : entry - risk * tp1R

    [sig, zTop, zBot, strength, dirTrade, entry, sl, tp1, risk]

// -----------------------------------------------------------------------------
// State
// -----------------------------------------------------------------------------
type DZone
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

var array<DZone> activeZones = array.new<DZone>()
var array<DZone> histZones   = array.new<DZone>()
var array<line>  histLines   = array.new<line>()

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

zoneLabel(int dir, string tf, float strength) =>
    long  = dir > 0
    wr    = long ? bWR : sWR
    n     = long ? bTot : sTot
    wrTxt = na(wr) ? "n/a" : str.tostring(wr, "#") + "%"
    tf + " " + (long ? "BUY" : "SELL") + " • " + tierName(tierOf(strength)) + " " + str.tostring(strength, "#.#") + "/10 • WR " + wrTxt + " (n" + str.tostring(n) + ")"

fadeToHistoric(DZone z) =>
    isWin = z.resolved and z.win
    keepBox = showHist and (not histWinOnly or isWin)
    if keepBox
        col = histColorMode == "By Win/Loss" ? (isWin ? colWin : (z.resolved ? colLoss : color.gray)) : (z.resolved ? (z.dir > 0 ? colBull : colBear) : color.gray)
        z.bx.set_bgcolor(color.new(col, histTransp))
        z.bx.set_border_color(color.new(col, math.max(0, histTransp - 12)))
        z.bx.set_right(bar_index)
        z.bx.set_extend(extend.none)
        if not na(z.mid)
            z.mid.delete()
            z.mid := na
        if not na(z.lb)
            z.lb.delete()
            z.lb := na
        if histTag and z.resolved
            tagTxt = z.win ? "✓" : "✗"
            tagCol = z.win ? colWin : colLoss
            z.lb := label.new(bar_index, (z.top + z.bot) / 2, tagTxt, style=label.style_label_left, color=color.new(tagCol, 10), textcolor=color.white, size=size.small)
        histZones.push(z)
        if histZones.size() > histCap
            old = histZones.shift()
            old.bx.delete()
            if not na(old.lb)
                old.lb.delete()
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

makeZone(int dir, float top, float bot, float strength, string tf, float entry, float sl, float tp1) =>
    if showZones and top > bot
        baseCol = dir > 0 ? colBull : colBear
        bx = box.new(bar_index, top, bar_index, bot, border_color=color.new(baseCol, 35), border_width=1, bgcolor=color.new(baseCol, zoneTransp))
        ln = showMid ? line.new(bar_index, (top + bot) / 2, bar_index, (top + bot) / 2, color=color.new(baseCol, 25), style=line.style_dashed) : na
        lb = showLabels ? label.new(bar_index, top, zoneLabel(dir, tf, strength), style=dir > 0 ? label.style_label_down : label.style_label_up, color=color.new(baseCol, 20), textcolor=color.white, size=lblSizeF) : na
        z = DZone.new(bx, ln, lb, top, bot, dir, bar_index, time, strength, entry, sl, tp1, false, false, false)
        activeZones.push(z)
        if activeZones.size() > maxZones * 2
            fadeToHistoric(activeZones.shift())

[sigC, topC, botC, strC, dirC, entryC, slC, tp1C, riskC] = detectDaily()

buySignal  = false
sellSignal = false
qualNow = activeTF and sigC != 0 and strC >= minStrength and tierOf(strC) >= minTierV

if barstate.isconfirmed and qualNow
    makeZone(dirC, topC, botC, strC, timeframe.period, entryC, slC, tp1C)
    if dirC > 0
        bTot += 1
        bStrSum += strC
    else
        sTot += 1
        sStrSum += strC
    buySignal  := dirC > 0
    sellSignal := dirC < 0

tierTransp = strC >= 8.0 ? 0 : strC >= 6.5 ? 25 : strC >= 5.0 ? 45 : 65
candleCol  = colorCandles and qualNow ? (dirC > 0 ? color.new(colBull, tierTransp) : color.new(colBear, tierTransp)) : na
barcolor(activeTF ? candleCol : na)

// -----------------------------------------------------------------------------
// Zone management + HONEST stats (every resolved trade counted, losers kept)
// -----------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
// Latest-setup trade lines + live status
// -----------------------------------------------------------------------------
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

if showTrade and barstate.isconfirmed and qualNow
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
    table.cell(tpnl,0,0,"DAILY SIGNAL",text_color=color.white,bgcolor=hb,text_size=dashSizeF)
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

// -----------------------------------------------------------------------------
// Stats dashboard (revised for Strong Daily Candle)
// -----------------------------------------------------------------------------
dashPosV = dashPos == "Top Right" ? position.top_right : dashPos == "Bottom Left" ? position.bottom_left : position.bottom_right
var table ds = table.new(dashPosV, 3, 12, frame_color=color.new(color.gray,40), frame_width=1, border_color=color.new(color.gray,70), border_width=1)

pctTxt(v) => na(v) ? "n/a" : str.tostring(v, "#.#") + "%"
barTxt(v) => na(v) ? "n/a" : str.tostring(v, "#.#")
evTxt(v)  => (v>=0?"+":"") + str.tostring(v,"#.##") + "R"

if showDash and barstate.islast
    hb = color.new(color.gray,15)
    rb = color.new(color.black,25)
    modeTxt = isMomentum ? "Momentum" : "Fade"

    // header
    table.cell(ds,0,0,"STRONG DAILY CANDLE",text_color=color.white,bgcolor=hb,text_size=dashSizeF,text_halign=text.align_center)
    table.merge_cells(ds,0,0,2,0)
    table.cell(ds,0,1,"Gate ≥ "+str.tostring(minStrength,"#.#")+"/10 • Tier ≥ "+minTier+" • "+modeTxt,text_color=color.new(color.gray,0),bgcolor=rb,text_size=dashSizeF,text_halign=text.align_center)
    table.merge_cells(ds,0,1,2,1)

    // current daily candle readout
    curDir = activeTF ? (sigC>0?"BULL":sigC<0?"BEAR":"—") : "—"
    curCol = activeTF ? (sigC>0?colBull:sigC<0?colBear:color.gray) : color.gray
    curStr = activeTF and sigC!=0 ? str.tostring(strC,"#.#")+"/10 "+tierName(tierOf(strC)) : "—"
    table.cell(ds,0,2,"This candle",text_color=color.white,bgcolor=rb,text_size=dashSizeF)
    table.cell(ds,1,2,curDir,text_color=color.white,bgcolor=color.new(curCol,35),text_size=dashSizeF,text_halign=text.align_center)
    table.cell(ds,2,2,curStr,text_color=color.white,bgcolor=rb,text_size=dashSizeF,text_halign=text.align_center)

    // qualify banner
    bannerTxt = not activeTF ? "⚠ APPLY ON A DAILY (1D) CHART" : sigC==0 ? "No directional candle (doji / flat)" : qualNow ? "✓ STRONG "+(dirC>0?"BUY":"SELL")+" SETUP — "+str.tostring(strC,"#.#")+"/10" : "✗ Below gate — "+str.tostring(strC,"#.#")+"/10 (need "+str.tostring(minStrength,"#.#")+")"
    bannerCol = not activeTF ? color.new(#ff8f00,20) : qualNow ? color.new(dirC>0?colBull:colBear,10) : color.new(color.gray,30)
    table.cell(ds,0,3,bannerTxt,text_color=color.white,bgcolor=bannerCol,text_size=dashSizeF,text_halign=text.align_center)
    table.merge_cells(ds,0,3,2,3)

    // stats header
    table.cell(ds,0,4,"Metric",text_color=color.white,bgcolor=color.new(color.gray,40),text_size=dashSizeF)
    table.cell(ds,1,4,"BUY", text_color=color.white,bgcolor=color.new(colBull,40),text_size=dashSizeF,text_halign=text.align_center)
    table.cell(ds,2,4,"SELL",text_color=color.white,bgcolor=color.new(colBear,40),text_size=dashSizeF,text_halign=text.align_center)

    bAvgStr = bTot>0 ? bStrSum/bTot : na
    sAvgStr = sTot>0 ? sStrSum/sTot : na
    rows  = array.from("Win Rate","P(Touch)","Exp.Value","R : R","Avg Win","Avg Loss","W/L • n • Score")
    bvals = array.from(pctTxt(bWR), pctTxt(bPT), evTxt(bEV), "1:"+str.tostring(tp1R,"#.#"), barTxt(bAW)+"b", barTxt(bAL)+"b", str.tostring(bWins)+"/"+str.tostring(bLoss)+" • "+str.tostring(bTot)+" • "+barTxt(bAvgStr))
    svals = array.from(pctTxt(sWR), pctTxt(sPT), evTxt(sEV), "1:"+str.tostring(tp1R,"#.#"), barTxt(sAW)+"b", barTxt(sAL)+"b", str.tostring(sWins)+"/"+str.tostring(sLoss)+" • "+str.tostring(sTot)+" • "+barTxt(sAvgStr))
    for r = 0 to 6
        table.cell(ds,0,r+5,array.get(rows,r),text_color=color.white,bgcolor=rb,text_size=dashSizeF)
        table.cell(ds,1,r+5,array.get(bvals,r),text_color=color.new(colBull,0),bgcolor=rb,text_size=dashSizeF,text_halign=text.align_center)
        table.cell(ds,2,r+5,array.get(svals,r),text_color=color.new(colBear,0),bgcolor=rb,text_size=dashSizeF,text_halign=text.align_center)

// -----------------------------------------------------------------------------
// Alerts
// -----------------------------------------------------------------------------
alertcondition(buySignal,  "Strong Daily BUY",  "Strong daily candle BUY setup formed")
alertcondition(sellSignal, "Strong Daily SELL", "Strong daily candle SELL setup formed")
alertcondition(touchEvent, "Zone Touch", "Price touched a daily setup zone (entry filled)")
alertcondition(proxEvent,  "Zone Proximity", "Price approaching a daily setup zone")
````
