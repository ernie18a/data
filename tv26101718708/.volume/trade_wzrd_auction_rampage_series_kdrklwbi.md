# Trade Wzrd - Auction [Rampage Series]

- url: https://www.tradingview.com/script/kDrKLwBi-Trade-Wzrd-Auction-Rampage-Series/
- type: indicator
- pine_id: PUB;69e1ab86d4fe49d681ea15e448ac7330
- version: 1.0

## Description

[b]✨ Trade Wzrd - Auction [Rampage Series][/b] a higher-timeframe volume auction rebuilt live on your chart: the forming HTF candle wears its order flow on its body, with buy volume winging right and sell volume winging left per price row, a gold point-of-control frame, a dashed volume-weighted control line, and the live auction delta on top. Multi-timeframe order flow and volume profile logic, readable in half a second.
[quote]Every higher-timeframe candle is an auction playing out in slow motion. Most tools show you the candle after it closes. Auction shows you the bidding INSIDE it while it forms - and tells you who is winning.[/quote]
[b]THE AUCTION[/b]

Every chart bar's volume is split by who won its close, then filed at the price where it traded across the forming candle's range. The result rides on the candle itself:
[list]
[*] Buy mass wings out to the RIGHT of the body, sell mass to the LEFT - each row's width and intensity scaled by what actually traded there.
[*] The gold frame = POINT OF CONTROL: the row the auction has accepted most.
[*] The dashed line = CONTROL PRICE: the volume-weighted mean of everything bid so far, drawn back to where the bidding started.
[*] The delta tag = who is carrying the auction right now. The split tag = the exact buy/sell balance.
[/list]
When the candle closes, its POC settles into a dotted gold FOSSIL - the settled auctions stay on chart until price crosses them again. The archaeology of where fair value used to sit.

[b]THE SIGNALS - THE AUCTION RESOLVES TWO WAYS[/b]
[list=1]
[*] [b]POC RECLAIM[/b] - price crosses back through the LAST settled auction's point of control after real time on the other side (Acceptance Bars). The fairest price of the last auction changed hands. Ridden toward the settled extreme, stopped back through the POC. Side-colored chip.
[*] [b]DELTA DRIVE[/b] - the forming auction flips who is carrying it (delta crosses the trigger) with price on the matching side of the control price. Fresh control, ride the momentum, stopped back through control. Gold chip.
[/list]
Every signal carries a [b]CONVICTION score[/b]: this chart's own live win-rate database, bucketed by delta strength, fused with auction alignment, kinetic fuel and absorption into one number. Hover any chip for the full deep-dive: the settled POC, the control price, the auction's delta and sample count, the win probability, the verdict.

[b]THE DASHBOARD[/b]

The auction timeframe and sample count. Live delta and the buy/sell split. The forming POC and control price. The settled POC and which side price stands on. The win-rate database, the best session, the record, kinetic fuel, automation status.

[b]TRADEWZRD AUTOMATION[/b]

Built in, zero config. Enable Automation, create ONE alert choosing "Any alert() function call", paste your webhook URL. Entries, opposite-signal closes and TP/SL-hit closes all emit plain-text order strings - the same grammar drives automation across 7+ platforms (MT4, MT5, cTrader and major crypto exchanges). Full trade box on chart: entry, stop, auction-magnet target, R:R, and win/loss stamps where the trade actually closed.

[b]HOW TO READ IT[/b]
[list]
[*] The candle beside price = the forming HTF auction. Its color = winning or losing its open.
[*] Right wing heavier than left = buyers own this auction. Watch the balance shift row by row.
[*] Gold frame = the price most accepted. Dashed line = the mean of all bidding.
[*] Delta tag = net delta of the forming candle. Flip past the trigger = DELTA DRIVE.
[*] Dotted gold fossils = settled auctions' control prices. Price crossing one erases it.
[/list]
[b]THE RAMPAGE SERIES[/b]

Rift maps WHERE the volume traded. Tide knows WHO OWNS every price - and watches them defend it. Null Range knows WHERE THE VOLUME NETS TO NOTHING. Anchor knows WHERE PRICE BELONGS. Auction knows WHO IS WINNING THE CURRENT AUCTION - and shows you the bidding.

Educational shell. Not a signal service, not financial advice. Works on any symbol; pick an auction timeframe above your chart timeframe. Without volume data the wings, delta and conviction stand down.

## Source Code

````pine
// © trade-wzrd
// =============================================================================
// Trade Wzrd - Auction [Rampage Series]
// Every higher-timeframe candle is an auction playing out in slow motion.
// Auction rebuilds the FORMING candle on your chart and shows you the
// bidding inside it: every chart bar's volume is split by who won the close
// and filed at the price where it traded, so the growing candle wears its
// volume on its body - buy mass winging out to the right, sell mass to the
// left, each row's size and intensity scaled by what actually traded there.
// The gold frame is the point of control: the price the auction has
// accepted most. The dashed line is the control price: the volume-weighted
// mean of everything bid so far. The delta tag names who is carrying the
// auction right now. When the candle closes, its POC settles into a fossil
// line - the settled auctions stay on chart until price crosses them again.
// The signals are the auction resolving. POC RECLAIM: price crosses back
// through the LAST settled auction's point of control after real time on
// the other side - the fairest price changed hands, ride it toward the
// settled extreme. DELTA DRIVE: the forming auction flips who is carrying
// it, with price on the matching side of control - momentum with the fresh
// control. Every signal carries a conviction score: this chart's live
// win-rate database (bucketed by delta strength) fused with auction
// alignment, kinetic fuel and absorption into one number, with a reactive
// hover verdict. Trade box, win/loss stamps, session schedule. Built-in
// automation: entries, opposite-signal closes and TP/SL-hit closes all
// emit webhook-ready order strings.
// Educational shell. Not a signal service. Works on any symbol; without
// volume data the wings, delta and conviction stand down. Pick an auction
// timeframe ABOVE your chart timeframe.
// =============================================================================

//@version=6
indicator("Trade Wzrd - Auction [Rampage Series]", shorttitle = "Trade Wzrd - Auction [Rampage Series]", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, precision = 6, explicit_plot_zorder = true, calc_bars_count = 5000)

// =============================================================================
// INPUTS
// =============================================================================

// --------------------------- TRADEWZRD AUTOMATION ----------------------------
g_tw = "TradeWzrd Automation"
tw_about     = input.bool(false, "What Is Trade Wzrd?", group = g_tw, tooltip = "Trade Wzrd is the automation layer built into every Rampage Series script.\n\nIt turns each signal into a plain-text order string:\n- Entry with stop and target\n- Opposite-signal close\n- TP/SL-hit close\n\nThe same syntax drives automation across 7+ platforms, including MT4, MT5, cTrader, TradeLocker, DxTrade, Tradovate and NinjaTrader.\n\nSupports percent-risk or fixed-volume sizing, magic numbers, and order comments.\n\nNo lock-in: the strings are plain text, so you can wire them to whatever endpoint you already use.")
tw_enabled   = input.bool(true, "Enable Automation", group = g_tw, tooltip = "Signals fire alert() strings. Create ONE alert on 'Any alert() function call' and point it at your webhook endpoint.")
tw_symbol    = input.string("", "Symbol Override (Blank = Chart)", group = g_tw)
tw_vol_type  = input.string("VOL", "Volume Mode", ["RISK", "VOL"], group = g_tw, inline = "twv")
tw_vol_val   = input.float(1.0, "Risk % or Volume", minval = 0.0, step = 0.1, group = g_tw, inline = "twv")
tw_opp_close = input.bool(true, "Close On Opposite Signal", group = g_tw, inline = "twc", tooltip = "Entry strings prepend a CLOSE for the opposite side before the new order.")
tw_exit_close = input.bool(true, "Close On TP / SL Hit", group = g_tw, inline = "twc", tooltip = "When the open trade's stop or target is hit, a CLOSE alert fires for that side. Mirrors the on-chart trade box.")
tw_magic     = input.string("", "Magic Number", group = g_tw, inline = "twm")
tw_comment   = input.string("Auction", "Comment", group = g_tw, inline = "twm")

// ------------------------------- AUCTION ENGINE ------------------------------
g_au = "Auction Engine"
i_htf     = input.timeframe("D", "Auction Timeframe", group = g_au, tooltip = "The candle being auctioned. Must be ABOVE your chart timeframe - on a 15m chart, 1H/4H/D all work.")
i_rows    = input.int(48, "Auction Rows", minval = 12, maxval = 48, group = g_au, inline = "au1", tooltip = "Price rows in the auction profile. More rows = finer wings, thinner bricks.")
i_sampMax = input.int(240, "Max Samples", minval = 60, maxval = 1000, group = g_au, inline = "au1", tooltip = "Chart bars stored per auction. Past the cap, adjacent samples merge - the profile stays exact in volume, coarser in time.")
i_gap     = input.int(20, "Gap From Price (Bars)", minval = 2, maxval = 30, group = g_au, inline = "au2", tooltip = "Horizontal distance between live price and the auction candle.")
i_wing    = input.int(12, "Max Wing Width (Bars)", minval = 4, maxval = 30, group = g_au, inline = "au2", tooltip = "How far the heaviest row wings out from the candle body.")
i_bodyW   = input.int(2, "Body Half-Width (Bars)", minval = 1, maxval = 5, group = g_au, inline = "au3")

// ---------------------------------- SIGNALS ----------------------------------
g_sg = "Signals"
i_sigType = input.string("Reclaims + Delta Drive", "Signal Models", ["Reclaims + Delta Drive", "Reclaims Only", "Delta Drive Only"], group = g_sg, inline = "sg1", tooltip = "POC RECLAIM: price crosses back through the last settled auction's point of control after time on the other side. DELTA DRIVE: the forming auction flips who carries it, with price on the matching side of control.")
i_accBars = input.int(5, "Acceptance Bars", minval = 1, maxval = 20, group = g_sg, inline = "sg2", tooltip = "Bars price must spend beyond the settled POC before a cross back counts as a reclaim. Filters flip-flops.")
i_ddMin   = input.float(10, "Delta Drive Trigger (%)", minval = 5, maxval = 40, step = 5, group = g_sg, inline = "sg2", tooltip = "The forming auction's delta must cross this share of its volume before a drive fires.")
i_cool    = input.int(0, "Cooldown (Bars)", minval = 0, maxval = 500, group = g_sg, inline = "sg3", tooltip = "After a signal, both sides rest this many bars.")
i_v_sig   = input.bool(true, "Signal Chips", group = g_sg, inline = "sg3", tooltip = "The typed chips at every signal: model and conviction, full deep-dive on hover.")

// ---------------------------------- FILTERS ----------------------------------
g_fi = "Filters"
i_minProb = input.int(0, "Min Win Probability (%)", minval = 0, maxval = 100, step = 5, group = g_fi, inline = "fi1", tooltip = "0 = off. Signals from delta tiers below this win rate are skipped - but only once the tier has enough samples to judge.")
i_minSamp = input.int(100, "Min Samples", minval = 1, maxval = 100, group = g_fi, inline = "fi1")
i_fuelMin = input.float(0.0, "Min Kinetic Fuel (0-1)", minval = 0.0, maxval = 1.0, step = 0.05, group = g_fi, tooltip = "Kinetic fuel floor: volume times speed on the signal bar. 0 = off.")
i_balF    = input.bool(true, "Require Auction Alignment", group = g_fi, tooltip = "Longs only while the forming auction's delta leans buy, shorts on the mirror - trade with the current bidding, not against it.")

// ----------------------------- SESSION SCHEDULE ------------------------------
g_sc = "Session Schedule"
i_lonOpen = input.int(7, "London Open (Hour)", minval = 0, maxval = 23, group = g_sc, inline = "sc1", tooltip = "Exchange timezone. Every closed trade is filed by session so the dashboard learns which hours the auction resolves cleanly on this chart.")
i_nyOpen  = input.int(12, "New York Open (Hour)", minval = 0, maxval = 23, group = g_sc, inline = "sc1")
i_nyClose = input.int(21, "Session Close (Hour)", minval = 0, maxval = 23, group = g_sc, inline = "sc1", tooltip = "After this hour trades file as OFF HOURS.")

// ----------------------------------- RISK ------------------------------------
g_rk = "Risk"
i_atrLen = input.int(14, "ATR Length", minval = 1, group = g_rk, inline = "rk1")
i_slBuf  = input.float(1, "Stop Buffer (ATR)", minval = 0.0, maxval = 5.0, step = 0.1, group = g_rk, inline = "rk1", tooltip = "Reclaims stop back through the settled POC; drives stop back through the control price - plus this buffer.")
i_tpMode = input.string("Auction Magnet", "Target Model", ["Auction Magnet", "R Multiple"], group = g_rk, tooltip = "Auction Magnet: signals aim at the settled auction's far extreme (capped at 3R, falls back to the multiple). R Multiple: fixed reward:risk.")
i_rr     = input.float(3.0, "R Multiple", minval = 0.5, maxval = 10.0, step = 0.5, group = g_rk)

// ---------------------------------- VISUALS ----------------------------------
g_vs = "Visuals"
i_v_auc   = input.bool(true, "Auction Candle", group = g_vs, inline = "vv0", tooltip = "The hero: the forming higher-timeframe candle rebuilt beside price.")
i_v_wings = input.bool(true, "Volume Wings", group = g_vs, inline = "vv0", tooltip = "The buy/sell mass per price row, winging right and left off the body, sized and tinted by what traded.")
i_v_pocL  = input.bool(true, "POC Frame", group = g_vs, inline = "vv1", tooltip = "Gold frame on the row the auction has accepted most, with its price tagged.")
i_v_ctrl  = input.bool(true, "Control Line", group = g_vs, inline = "vv1", tooltip = "The volume-weighted mean of the whole auction, dashed back to where bidding started.")
i_v_abs   = input.bool(true, "Absorption Diamonds", group = g_vs, inline = "vv2", tooltip = "Gold diamonds where effort and result disagree: climax volume, no progress.")
i_v_trade = input.bool(true, "Trade Box", group = g_vs, inline = "vv2")

// --------------------------- FOSSILS (HISTORY) -------------------------------
g_fs = "Fossils (History)"
i_v_fos  = input.bool(true, "Settled POC Fossils", group = g_fs, inline = "fs1", tooltip = "When an auction closes, its point of control settles into a dotted gold line - and stays until price crosses it again.")
i_fosMax = input.int(8, "Max Fossils", minval = 2, maxval = 20, group = g_fs, inline = "fs1")

// --------------------------------- DASHBOARD ---------------------------------
g_db = "Dashboard"
i_dbShow = input.bool(true, "Show Dashboard", group = g_db)
i_dbLoc  = input.string("Bottom Right", "Position", ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = g_db, inline = "db1")
i_dbSize = input.string("Small", "Size", ["Tiny", "Small", "Normal", "Large"], group = g_db, inline = "db1")

// ----------------------------------- STYLE -----------------------------------
g_st = "Style"
i_colBull = input.color(#00e1ff, "Buy Wing", group = g_st, inline = "st1")
i_colBear = input.color(#ff3d71, "Sell Wing", group = g_st, inline = "st1")
i_colGold = input.color(#ffd740, "POC & Drives", group = g_st, inline = "st2")

// =============================================================================
// HELPERS
// =============================================================================
f_fmt(float p) => str.tostring(p, format.mintick)
twSym = tw_symbol != "" ? tw_symbol : syminfo.ticker
f_tail() => (tw_magic != "" ? ", MAGIC=" + tw_magic : "") + (tw_comment != "" ? ", COMMENT=" + tw_comment : "")
sesName(int i) => i == 0 ? "ASIA" : i == 1 ? "LONDON" : i == 2 ? "NEW YORK" : "OFF HOURS"
f_dtier(float d) => math.abs(d) < 15 ? 0 : math.abs(d) < 30 ? 1 : 2   // delta tier: stirring / driving / stampeding

// =============================================================================
// THE AUCTION ENGINE - the forming HTF candle's volume, filed by price
// =============================================================================
var array<float> sH = array.new<float>()
var array<float> sL = array.new<float>()
var array<float> sC = array.new<float>()
var array<float> sV = array.new<float>()

// settled auction: the last closed candle's receipts, frozen at the boundary
var float aucOpen   = na
var float prevPOC   = na
var float prevHigh  = na
var float prevLow   = na
var float prevCtrl  = na
var float prevDelta = na

float pocV   = na
float ctrlV  = na
float deltaPct = 0.0
float totBuy  = 0.0
float totSell = 0.0
float maxRow  = 1.0
float hH = na
float hL = na
float step = na
int   pocBin = -1
int   aucN = 0

newAuc = timeframe.change(i_htf)

// fossils of settled auctions live here - declared before the boundary freeze
var array<line>  fosL = array.new<line>()
var array<float> fosP = array.new<float>()

atrV = ta.atr(i_atrLen)

if newAuc
    if aucN > 0 and not na(pocV)
        // the auction settles: freeze its receipts, fossilize its control
        prevPOC   := pocV
        prevHigh  := hH
        prevLow   := hL
        prevCtrl  := ctrlV
        prevDelta := deltaPct
        if i_v_fos and not na(atrV)
            dup = false
            if fosP.size() > 0
                for i = 0 to fosP.size() - 1
                    if math.abs(fosP.get(i) - pocV) < atrV * 0.3
                        dup := true
                        break
            if not dup
                fosL.push(line.new(bar_index - aucN, pocV, bar_index + 12, pocV, color = color.new(i_colGold, 75), style = line.style_dotted, width = 1))
                fosP.push(pocV)
                if fosL.size() > i_fosMax
                    line.delete(fosL.shift())
                    fosP.shift()
    sH.clear()
    sL.clear()
    sC.clear()
    sV.clear()
    aucOpen := open

// this bar joins the auction
sH.push(high)
sL.push(low)
sC.push(close)
sV.push(nz(volume, 0.0))

// bounded memory: adjacent samples merge in pairs, volume stays exact
if sV.size() > i_sampMax
    int half = int(math.floor(sV.size() / 2))
    for i = 0 to half - 1
        v1 = sV.get(2 * i)
        v2 = sV.get(2 * i + 1)
        sH.set(i, math.max(sH.get(2 * i), sH.get(2 * i + 1)))
        sL.set(i, math.min(sL.get(2 * i), sL.get(2 * i + 1)))
        sC.set(i, v1 + v2 > 0 ? (sC.get(2 * i) * v1 + sC.get(2 * i + 1) * v2) / (v1 + v2) : sC.get(2 * i + 1))
        sV.set(i, v1 + v2)
    if sV.size() % 2 == 1
        int last = sV.size() - 1
        sH.set(half, sH.get(last))
        sL.set(half, sL.get(last))
        sC.set(half, sC.get(last))
        sV.set(half, sV.get(last))
        half += 1
    while sV.size() > half
        sH.pop()
        sL.pop()
        sC.pop()
        sV.pop()

// rebuild the rows: every sample's volume split by who won its close
var array<float> rowBuy  = array.new_float(i_rows, 0.0)
var array<float> rowSell = array.new_float(i_rows, 0.0)
aucN := sV.size()
if aucN > 0
    hH := sH.max()
    hL := sL.min()
    if hH > hL
        step := (hH - hL) / i_rows
        rowBuy.fill(0.0)
        rowSell.fill(0.0)
        float ctrlSum = 0.0
        for i = 0 to aucN - 1
            sh = sH.get(i)
            sl = sL.get(i)
            sc = sC.get(i)
            sv = sV.get(i)
            if sv > 0 and sh > sl
                cPos = (sc - sl) / (sh - sl)
                bBuy = sv * cPos
                bSel = sv * (1.0 - cPos)
                b0 = math.max(0, int(math.floor((sl - hL) / step)))
                b1 = math.min(i_rows - 1, int(math.floor((sh - hL) / step)))
                if b1 >= 0 and b0 <= i_rows - 1 and b0 <= b1
                    for b = b0 to b1
                        binLo = hL + b * step
                        top = math.min(sh, binLo + step)
                        bot = math.max(sl, binLo)
                        if top > bot
                            w = (top - bot) / (sh - sl)
                            rowBuy.set(b, rowBuy.get(b) + bBuy * w)
                            rowSell.set(b, rowSell.get(b) + bSel * w)
                ctrlSum += sv * (sh + sl + sc) / 3
        totBuy  := rowBuy.sum()
        totSell := rowSell.sum()
        float tot = totBuy + totSell
        deltaPct := tot > 0 ? (totBuy - totSell) / tot * 100 : 0.0
        ctrlV := tot > 0 ? ctrlSum / tot : na
        maxRow := 0.0
        float pocT = 0.0
        pocBin := -1
        for b = 0 to i_rows - 1
            tv = rowBuy.get(b) + rowSell.get(b)
            if tv > maxRow
                maxRow := tv
            if tv > pocT
                pocT := tv
                pocBin := b
        if pocBin >= 0
            pocV := hL + (pocBin + 0.5) * step
    else
        step := na

aucWarm = aucN >= 5

// =============================================================================
// VOLUME GRADING - absorption, kinetic fuel, the session clock
// =============================================================================
volAvg  = ta.sma(volume, 30)
sprAvg  = ta.sma(high - low, 30)
relV    = not na(volAvg) and volAvg > 0 ? volume / volAvg : 1.0
relS    = not na(sprAvg) and sprAvg > 0 ? (high - low) / sprAvg : 1.0
absorb  = relV >= 2.0 and relS <= 0.7
absBull = absorb and (high > low ? (close - low) / (high - low) : 0.5) >= 0.5
absBear = absorb and (high > low ? (close - low) / (high - low) : 0.5) < 0.5

kinRaw = volume * math.abs(close - close[1])
kinMax = ta.highest(kinRaw, 100)
kinMin = ta.lowest(kinRaw, 100)
kinN   = not na(kinRaw) and kinMax > kinMin ? (kinRaw - kinMin) / (kinMax - kinMin) : 0.0
fuelOK = i_fuelMin <= 0 or kinN >= i_fuelMin

// session index: 0 asia / 1 london / 2 new york / 3 off
h = hour(time)
sesIdx = h >= i_nyClose or h < i_lonOpen ? 3 : h >= i_nyOpen ? 2 : h >= i_lonOpen ? 1 : 0

// =============================================================================
// THE RAW SIGNALS - the settled auction's control changes hands, or the forming one flips
// =============================================================================
var int belowN = 0
var int aboveN = 0
belowN := not na(prevPOC) ? (close < prevPOC ? belowN + 1 : 0) : 0
aboveN := not na(prevPOC) ? (close > prevPOC ? aboveN + 1 : 0) : 0

// POC RECLAIM: back through the settled point of control after real time away
recLraw = not na(prevPOC) and close > prevPOC and close[1] <= prevPOC and belowN[1] >= i_accBars
recSraw = not na(prevPOC) and close < prevPOC and close[1] >= prevPOC and aboveN[1] >= i_accBars

// DELTA DRIVE: the forming auction flips who carries it, price on the matching side of control
ddLraw = aucWarm and not na(ctrlV) and deltaPct > i_ddMin and deltaPct[1] <= i_ddMin and close > ctrlV
ddSraw = aucWarm and not na(ctrlV) and deltaPct < -i_ddMin and deltaPct[1] >= -i_ddMin and close < ctrlV

wantL = (i_sigType != "Delta Drive Only" and recLraw) or (i_sigType != "Reclaims Only" and ddLraw)
wantS = (i_sigType != "Delta Drive Only" and recSraw) or (i_sigType != "Reclaims Only" and ddSraw)

// auction alignment: trade with the current bidding
balOK_L = not i_balF or deltaPct > 0
balOK_S = not i_balF or deltaPct < 0

// =============================================================================
// THE DATABASE - this chart's own receipts, bucketed by delta strength
// =============================================================================
var array<int> attRL = array.new_int(3, 0)   // long signals, tiers 0/1/2
var array<int> winRL = array.new_int(3, 0)
var array<int> attRS = array.new_int(3, 0)   // short signals
var array<int> winRS = array.new_int(3, 0)
var array<int> sesA  = array.new_int(4, 0)
var array<int> sesW  = array.new_int(4, 0)

int tierL = na
int tierS = na
if wantL
    tierL := f_dtier(deltaPct)
if wantS
    tierS := f_dtier(deltaPct)
attL  = not na(tierL) ? attRL.get(tierL) : 0
winL  = not na(tierL) ? winRL.get(tierL) : 0
attS  = not na(tierS) ? attRS.get(tierS) : 0
winS  = not na(tierS) ? winRS.get(tierS) : 0
rateL = attL > 0 ? winL * 100.0 / attL : na
rateS = attS > 0 ? winS * 100.0 / attS : na
probOK_L = attL < i_minSamp or (not na(rateL) and rateL >= i_minProb)
probOK_S = attS < i_minSamp or (not na(rateS) and rateS >= i_minProb)

// =============================================================================
// THE STATE MACHINE - one signal per resolution, cooldown between
// =============================================================================
var int lastSig = na
coolOK = na(lastSig) or bar_index - lastSig >= i_cool

longSignal  = wantL and not na(atrV) and probOK_L and balOK_L and fuelOK and coolOK and barstate.isconfirmed
shortSignal = wantS and not na(atrV) and probOK_S and balOK_S and fuelOK and coolOK and barstate.isconfirmed and not longSignal

string mdlL = "-"
string mdlS = "-"
int accNL = 0
int accNS = 0
if longSignal
    lastSig := bar_index
    mdlL := recLraw ? "RECLAIM" : "DRIVE"
    accNL := recLraw ? belowN[1] : 0
if shortSignal
    lastSig := bar_index
    mdlS := recSraw ? "RECLAIM" : "DRIVE"
    accNS := recSraw ? aboveN[1] : 0

// =============================================================================
// CONVICTION - the database base, bent by delta strength, alignment, fuel
// =============================================================================
f_conv(float dlt, bool al, float fuel, bool absB, float rate, int att) =>
    base = att >= i_minSamp and not na(rate) ? rate : 50.0
    s = base + (math.abs(dlt) >= 30 ? 8.0 : math.abs(dlt) >= 15 ? 4.0 : 0.0) + (al ? 8 : -8) + (fuel >= 0.85 ? 10 : fuel >= 0.5 ? 4 : fuel < 0.2 ? -4 : 0) + (absB ? 5 : 0)
    int(math.round(math.max(5, math.min(95, s))))

convL = wantL ? f_conv(deltaPct, deltaPct > 0, kinN, absorb, rateL, attL) : 50
convS = wantS ? f_conv(deltaPct, deltaPct < 0, kinN, absorb, rateS, attS) : 50

// --- hover deep-dive: the auction, its control, its receipts ---
tipL = "MODEL  " + (mdlL == "RECLAIM" ? "POC RECLAIM - price crossed back above the settled auction's point of control after " + str.tostring(accNL) + " bars below. The fairest price of the last auction is back in buyers' hands." : "DELTA DRIVE - buyers just took the forming auction (delta " + str.tostring(deltaPct, "#") + "%) with price above the control price. Fresh control, ride it.")
tipL += "\nSETTLED POC  " + (not na(prevPOC) ? f_fmt(prevPOC) : "-") + " · CONTROL  " + (not na(ctrlV) ? f_fmt(ctrlV) : "-")
tipL += "\nAUCTION  delta " + (deltaPct > 0 ? "+" : "") + str.tostring(deltaPct, "#") + "% over " + str.tostring(aucN) + " samples " + (deltaPct > 0 ? "- buyers carry the bidding, aligned" : "- sellers carry the bidding, exposed")
tipL += "\nWIN PROB  " + (attL >= i_minSamp ? str.tostring(rateL, "#") + "% · tier " + str.tostring(nz(tierL, 0) + 1) + " · " + str.tostring(attL) + " signals" : "BUILDING · tier " + str.tostring(nz(tierL, 0) + 1) + " · " + str.tostring(attL) + "/" + str.tostring(i_minSamp))
tipL += "\nCONVICTION  " + str.tostring(convL) + " - the tier's win rate bent by delta strength, alignment, fuel and absorption"
tipL += "\nKINETIC  " + str.tostring(kinN, "#.##") + (absorb ? " · ABSORPTION live" : "")
tipS = "MODEL  " + (mdlS == "RECLAIM" ? "POC LOSS - price crossed back below the settled auction's point of control after " + str.tostring(accNS) + " bars above. The fairest price of the last auction is back in sellers' hands." : "DELTA DRIVE - sellers just took the forming auction (delta " + str.tostring(deltaPct, "#") + "%) with price below the control price. Fresh control, ride it.")
tipS += "\nSETTLED POC  " + (not na(prevPOC) ? f_fmt(prevPOC) : "-") + " · CONTROL  " + (not na(ctrlV) ? f_fmt(ctrlV) : "-")
tipS += "\nAUCTION  delta " + (deltaPct > 0 ? "+" : "") + str.tostring(deltaPct, "#") + "% over " + str.tostring(aucN) + " samples " + (deltaPct < 0 ? "- sellers carry the bidding, aligned" : "- buyers carry the bidding, exposed")
tipS += "\nWIN PROB  " + (attS >= i_minSamp ? str.tostring(rateS, "#") + "% · tier " + str.tostring(nz(tierS, 0) + 1) + " · " + str.tostring(attS) + " signals" : "BUILDING · tier " + str.tostring(nz(tierS, 0) + 1) + " · " + str.tostring(attS) + "/" + str.tostring(i_minSamp))
tipS += "\nCONVICTION  " + str.tostring(convS) + " - the tier's win rate bent by delta strength, alignment, fuel and absorption"
tipS += "\nKINETIC  " + str.tostring(kinN, "#.##") + (absorb ? " · ABSORPTION live" : "")

// --- the chips: model and conviction on the signal, gold for drives ---
var array<label> chips = array.new<label>()
f_chip(label lb) =>
    chips.push(lb)
    if chips.size() > 40
        label.delete(chips.shift())

if i_v_sig and longSignal
    f_chip(label.new(bar_index, low - nz(atrV, high - low) * 0.3, "BUY · " + mdlL + " " + str.tostring(convL), style = label.style_label_up, color = color.new(i_colBull, 15), textcolor = #ffffff, size = size.small, tooltip = tipL))
if i_v_sig and shortSignal
    f_chip(label.new(bar_index, high + nz(atrV, high - low) * 0.3, "SELL · " + mdlS + " " + str.tostring(convS), style = label.style_label_down, color = color.new(i_colBear, 15), textcolor = #ffffff, size = size.small, tooltip = tipS))

// =============================================================================
// RISK - settled-POC stops on reclaims, control stops on drives, auction magnets
// =============================================================================
float slLong  = na
float slShort = na
float tpLong  = na
float tpShort = na
if not na(atrV)
    slLong  := recLraw and not na(prevPOC) ? prevPOC - atrV * i_slBuf : not na(ctrlV) ? ctrlV - atrV * i_slBuf : low - atrV * i_slBuf
    slShort := recSraw and not na(prevPOC) ? prevPOC + atrV * i_slBuf : not na(ctrlV) ? ctrlV + atrV * i_slBuf : high + atrV * i_slBuf
    if slLong >= close
        slLong := close - atrV
    if slShort <= close
        slShort := close + atrV
    riskL = close - slLong
    riskS = slShort - close
    // the auction magnet: aim at the settled auction's far extreme
    magL = i_tpMode == "Auction Magnet" and not na(prevHigh) ? prevHigh - close : 0.0
    magS = i_tpMode == "Auction Magnet" and not na(prevLow) ? close - prevLow : 0.0
    tpLong  := magL > atrV * 0.2 and magL <= riskL * 3.0 ? prevHigh : close + riskL * i_rr
    tpShort := magS > atrV * 0.2 and magS <= riskS * 3.0 ? prevLow : close - riskS * i_rr
    slLong  := math.round_to_mintick(slLong)
    slShort := math.round_to_mintick(slShort)
    tpLong  := math.round_to_mintick(tpLong)
    tpShort := math.round_to_mintick(tpShort)

// =============================================================================
// TRADEWZRD AUTOMATION - webhook-ready order strings
// =============================================================================
if longSignal and tw_enabled
    msg = (tw_opp_close ? "CLOSE," + twSym + ",SIDE=SELL" + f_tail() + ";" : "") + "BUY," + twSym + ", " + tw_vol_type + "=" + str.tostring(tw_vol_val) + ", SL=" + f_fmt(slLong) + ", TP=" + f_fmt(tpLong) + ", TPSLTYPE=PRICE" + f_tail()
    alert(msg, alert.freq_once_per_bar_close)

if shortSignal and tw_enabled
    msg = (tw_opp_close ? "CLOSE," + twSym + ",SIDE=BUY" + f_tail() + ";" : "") + "SELL," + twSym + ", " + tw_vol_type + "=" + str.tostring(tw_vol_val) + ", SL=" + f_fmt(slShort) + ", TP=" + f_fmt(tpShort) + ", TPSLTYPE=PRICE" + f_tail()
    alert(msg, alert.freq_once_per_bar_close)

// =============================================================================
// TRADE BOX - entry, stop and target carried as one position; dies where filled
// =============================================================================
var int      tbDir    = 0
var int      tbBar    = na
var float    tbEPx    = na
var float    tbSlPx   = na
var float    tbTpPx   = na
var int      tbTier   = na
var int      tbSes    = na
var line     tbEntry  = na
var line     tbSL     = na
var line     tbTP     = na
var label    tbLbE    = na
var label    tbLbS    = na
var label    tbLbT    = na
var linefill tbRisk   = na
var linefill tbReward = na

// --- the receipts: every closed trade feeds the record ---
var int    winN        = 0
var int    lossN       = 0
var string lastOutcome = ""
var string lastMdl     = "-"
var int    lastSigBar  = na
var int    lastConv    = na

if longSignal or shortSignal
    line.delete(tbEntry)
    line.delete(tbSL)
    line.delete(tbTP)
    label.delete(tbLbE)
    label.delete(tbLbS)
    label.delete(tbLbT)
    linefill.delete(tbRisk)
    linefill.delete(tbReward)
    tbEntry  := na
    tbSL     := na
    tbTP     := na
    tbLbE    := na
    tbLbS    := na
    tbLbT    := na
    tbRisk   := na
    tbReward := na
    tbDir  := longSignal ? 1 : -1
    tbBar  := bar_index
    tbEPx  := close
    tbSlPx := longSignal ? slLong : slShort
    tbTpPx := longSignal ? tpLong : tpShort
    tbTier := longSignal ? tierL : tierS
    tbSes  := sesIdx
    lastMdl    := longSignal ? mdlL : mdlS
    lastSigBar := bar_index
    lastConv   := longSignal ? convL : convS
    if i_v_trade
        ec = tbDir == 1 ? i_colBull : i_colBear
        rrTxt = str.tostring(math.abs(tbTpPx - tbEPx) / math.max(math.abs(tbEPx - tbSlPx), syminfo.mintick), "#.#")
        tbEntry  := line.new(bar_index, tbEPx, bar_index + 1, tbEPx, color = ec, width = 2)
        tbSL     := line.new(bar_index, tbSlPx, bar_index + 1, tbSlPx, color = color.new(i_colBear, 40), style = line.style_dashed, width = 1)
        tbTP     := line.new(bar_index, tbTpPx, bar_index + 1, tbTpPx, color = color.new(i_colBull, 40), width = 1)
        tbLbE    := label.new(bar_index, tbEPx, (tbDir == 1 ? "BUY " : "SELL ") + f_fmt(tbEPx) + " · " + lastMdl + " C" + str.tostring(lastConv), style = label.style_label_left, color = ec, textcolor = #161616, size = size.small, tooltip = longSignal ? tipL : tipS)
        tbLbS    := label.new(bar_index, tbSlPx, "SL " + f_fmt(tbSlPx), style = label.style_label_left, color = color.new(i_colBear, 40), textcolor = #ffffff, size = size.small)
        tbLbT    := label.new(bar_index, tbTpPx, "TP " + f_fmt(tbTpPx) + " · " + rrTxt + "R", style = label.style_label_left, color = color.new(i_colBull, 40), textcolor = #161616, size = size.small)
        tbRisk   := linefill.new(tbEntry, tbSL, color.new(i_colBear, 84))
        tbReward := linefill.new(tbEntry, tbTP, color.new(i_colBull, 84))

// --- toggled off mid-trade: wipe the drawings, keep the state machine alive ---
if not i_v_trade and not na(tbEntry)
    line.delete(tbEntry)
    line.delete(tbSL)
    line.delete(tbTP)
    label.delete(tbLbE)
    label.delete(tbLbS)
    label.delete(tbLbT)
    linefill.delete(tbRisk)
    linefill.delete(tbReward)
    tbEntry  := na
    tbSL     := na
    tbTP     := na
    tbLbE    := na
    tbLbS    := na
    tbLbT    := na
    tbRisk   := na
    tbReward := na

// --- live: the box follows price, then freezes exactly where stop or target is hit ---
if tbDir != 0
    if not na(tbEntry)
        line.set_x2(tbEntry, bar_index + 1)
        line.set_x2(tbSL, bar_index + 1)
        line.set_x2(tbTP, bar_index + 1)
        label.set_x(tbLbE, bar_index)
        label.set_x(tbLbS, bar_index)
        label.set_x(tbLbT, bar_index)
    hitSl = tbDir == 1 ? low  <= tbSlPx : high >= tbSlPx
    hitTp = tbDir == 1 ? high >= tbTpPx : low  <= tbTpPx
    if hitSl and hitTp
        hitTp := false  // both tagged in one bar: call it honestly, stop first
    if bar_index > tbBar and (hitSl or hitTp)
        if not na(tbEntry)
            line.set_x2(tbEntry, bar_index)
            line.set_x2(tbSL, bar_index)
            line.set_x2(tbTP, bar_index)
            label.new(bar_index, hitTp ? tbTpPx : tbSlPx, hitTp ? "✓ TP HIT" : "✗ SL HIT", style = label.style_label_left, color = color.new(hitTp ? i_colBull : i_colBear, 15), textcolor = hitTp ? #161616 : #ffffff, size = size.tiny)
        // the database learns: record the outcome in the tier it came from
        if not na(tbTier)
            if tbDir == 1
                attRL.set(tbTier, attRL.get(tbTier) + 1)
                if hitTp
                    winRL.set(tbTier, winRL.get(tbTier) + 1)
            else
                attRS.set(tbTier, attRS.get(tbTier) + 1)
                if hitTp
                    winRS.set(tbTier, winRS.get(tbTier) + 1)
            tbTier := na
        // and the schedule learns: file the outcome by session
        if not na(tbSes)
            sesA.set(tbSes, sesA.get(tbSes) + 1)
            if hitTp
                sesW.set(tbSes, sesW.get(tbSes) + 1)
            tbSes := na
        if hitTp
            winN += 1
        else
            lossN += 1
        lastOutcome := hitTp ? "TP" : "SL"
        if tw_enabled and tw_exit_close
            alert("CLOSE," + twSym + ",SIDE=" + (tbDir == 1 ? "BUY" : "SELL") + f_tail(), alert.freq_once_per_bar_close)
        tbDir := 0

// =============================================================================
// THE CANVAS - the forming auction, its wings, its control, its receipts
// =============================================================================
var array<box>   dBox = array.new<box>()
var array<line>  dLn  = array.new<line>()
var array<label> dLb  = array.new<label>()

if barstate.islast
    while dBox.size() > 0
        box.delete(dBox.pop())
    while dLn.size() > 0
        line.delete(dLn.pop())
    while dLb.size() > 0
        label.delete(dLb.pop())
    if i_v_auc and aucN > 0 and not na(step) and not na(hH) and hH > hL
        x0 = bar_index + i_gap
        bodyC = close >= nz(aucOpen, open) ? i_colBull : i_colBear
        // the wings: buy mass right, sell mass left - size and intensity by what traded
        if i_v_wings and maxRow > 0
            for b = 0 to i_rows - 1
                bv = rowBuy.get(b)
                sv = rowSell.get(b)
                if bv + sv > 0
                    yB = hL + b * step
                    yT = yB + step
                    if bv > 0
                        bw = math.max(1, int(math.round(bv / maxRow * i_wing)))
                        dBox.push(box.new(x0 + i_bodyW + 1, yT, x0 + i_bodyW + 1 + bw, yB, bgcolor = color.new(i_colBull, 92 - int(bv / maxRow * 52)), border_color = color.new(#161616, 0), border_width = 1))
                    if sv > 0
                        sw = math.max(1, int(math.round(sv / maxRow * i_wing)))
                        dBox.push(box.new(x0 - i_bodyW - 1 - sw, yT, x0 - i_bodyW - 1, yB, bgcolor = color.new(i_colBear, 92 - int(sv / maxRow * 52)), border_color = color.new(#161616, 0), border_width = 1))
        // the candle itself
        dLn.push(line.new(x0, hL, x0, hH, color = color.new(bodyC, 30), width = 1))
        dBox.push(box.new(x0 - i_bodyW, math.max(nz(aucOpen, open), close), x0 + i_bodyW, math.min(nz(aucOpen, open), close), bgcolor = color.new(bodyC, 72), border_color = bodyC, border_width = 1))
        // the point of control: gold frame on the most-accepted row
        if i_v_pocL and pocBin >= 0 and not na(pocV)
            dBox.push(box.new(x0 - i_bodyW - 1 - i_wing, hL + (pocBin + 1) * step, x0 + i_bodyW + 1 + i_wing, hL + pocBin * step, bgcolor = color.new(i_colGold, 100), border_color = color.new(i_colGold, 25), border_width = 1))
            dLb.push(label.new(x0 + i_bodyW + i_wing + 3, pocV, "POC " + f_fmt(pocV), style = label.style_none, textcolor = color.new(i_colGold, 15), size = size.tiny, tooltip = "POINT OF CONTROL - the row this auction has accepted most. When the candle closes, this settles into a fossil line."))
        // the control price: volume-weighted mean of everything bid, dashed back to the open
        if i_v_ctrl and not na(ctrlV)
            dLn.push(line.new(bar_index - aucN + 1, ctrlV, x0 + i_bodyW + i_wing + 2, ctrlV, color = color.new(#DBDBDB, 55), style = line.style_dashed, width = 1))
            dLb.push(label.new(x0 + i_bodyW + i_wing + 3, ctrlV, "CTL " + f_fmt(ctrlV), style = label.style_none, textcolor = color.new(#DBDBDB, 35), size = size.tiny, tooltip = "CONTROL PRICE - the volume-weighted mean of the whole auction so far. Price above it = buyers in control of the bidding."))
        // receipts: delta on top, the split below
        dLb.push(label.new(x0, hH + nz(atrV, hH - hL) * 0.25, "Δ " + (deltaPct > 0 ? "+" : "") + str.tostring(deltaPct, "#") + "%", style = label.style_none, textcolor = deltaPct > 5 ? i_colBull : deltaPct < -5 ? i_colBear : #808080, size = size.small, tooltip = "AUCTION DELTA - the forming candle's net buy/sell balance over " + str.tostring(aucN) + " samples. Crosses past the trigger with price on the matching side of control = DELTA DRIVE."))
        buyPct = totBuy + totSell > 0 ? totBuy / (totBuy + totSell) * 100 : 50.0
        dLb.push(label.new(x0, hL - nz(atrV, hH - hL) * 0.25, str.tostring(buyPct, "#") + " · " + str.tostring(100 - buyPct, "#"), style = label.style_none, textcolor = color.new(#DBDBDB, 45), size = size.tiny, tooltip = "THE SPLIT - buy mass versus sell mass inside this auction, percent."))

// --- fossils of settled auctions die on any cross: control changed hands, the level is spent ---
if fosL.size() > 0
    for i = fosL.size() - 1 to 0
        if (close - fosP.get(i)) * (close[1] - fosP.get(i)) < 0
            line.delete(fosL.get(i))
            fosL.remove(i)
            fosP.remove(i)

if not i_v_fos and fosL.size() > 0
    while fosL.size() > 0
        line.delete(fosL.pop())
    fosP.clear()

plotshape(i_v_abs and absBull, "Absorption Bull", shape.diamond, location.belowbar, color.new(i_colGold, 0), size = size.tiny)
plotshape(i_v_abs and absBear, "Absorption Bear", shape.diamond, location.abovebar, color.new(i_colGold, 0), size = size.tiny)

// =============================================================================
// DASHBOARD - instrument panel: dark chrome, dividers, right-aligned values
// =============================================================================
color DB_DATA = #DBDBDB
color DB_HEAD = #808080
color DB_BG   = #161616
color DB_BORD = #2E2E2E

dbPos  = i_dbLoc == "Top Right" ? position.top_right : i_dbLoc == "Top Left" ? position.top_left : i_dbLoc == "Middle Right" ? position.middle_right : i_dbLoc == "Middle Left" ? position.middle_left : i_dbLoc == "Bottom Left" ? position.bottom_left : position.bottom_right
dbSize = i_dbSize == "Tiny" ? size.tiny : i_dbSize == "Normal" ? size.normal : i_dbSize == "Large" ? size.large : size.small

var table db = table.new(dbPos, 2, 19, bgcolor = DB_BG, border_width = 0, frame_color = DB_BORD, frame_width = 1, force_overlay = true)
var bool dbDrawn = false

f_dbCell(int col, int row, string txt, color fg, string align) =>
    table.cell(db, col, row, txt, text_color = fg, text_size = dbSize, text_halign = align, bgcolor = color(na))

f_dbDiv(int row) =>
    table.merge_cells(db, 0, row, 1, row)
    table.cell(db, 0, row, "━━━━━━━━━━━━━━", text_color = DB_BORD, text_size = dbSize, text_halign = text.align_center, bgcolor = color(na))

if barstate.islast and i_dbShow
    dbDrawn := true
    bullTx = color.new(#089981, 0)
    bearTx = color.new(#f23645, 0)
    buyPct2 = totBuy + totSell > 0 ? totBuy / (totBuy + totSell) * 100 : 50.0
    table.merge_cells(db, 0, 0, 1, 0)
    f_dbCell(0, 0, "A U C T I O N", DB_DATA, text.align_center)
    f_dbDiv(1)
    f_dbCell(0, 2, "AUCTION", DB_HEAD, text.align_left)
    f_dbCell(1, 2, i_htf + " · " + str.tostring(aucN) + " SMPL", DB_DATA, text.align_right)
    f_dbCell(0, 3, "DELTA", DB_HEAD, text.align_left)
    f_dbCell(1, 3, (deltaPct > 0 ? "+" : "") + str.tostring(deltaPct, "#") + "%", deltaPct > 5 ? bullTx : deltaPct < -5 ? bearTx : DB_DATA, text.align_right)
    f_dbCell(0, 4, "SPLIT", DB_HEAD, text.align_left)
    f_dbCell(1, 4, str.tostring(buyPct2, "#") + " · " + str.tostring(100 - buyPct2, "#"), buyPct2 > 55 ? bullTx : buyPct2 < 45 ? bearTx : DB_DATA, text.align_right)
    f_dbDiv(5)
    f_dbCell(0, 6, "POC", DB_HEAD, text.align_left)
    f_dbCell(1, 6, na(pocV) ? "-" : f_fmt(pocV), color.new(i_colGold, 0), text.align_right)
    f_dbCell(0, 7, "CONTROL", DB_HEAD, text.align_left)
    f_dbCell(1, 7, na(ctrlV) ? "-" : f_fmt(ctrlV), DB_DATA, text.align_right)
    f_dbCell(0, 8, "SETTLED POC", DB_HEAD, text.align_left)
    f_dbCell(1, 8, na(prevPOC) ? "NONE SETTLED" : f_fmt(prevPOC) + (close > prevPOC ? " · BELOW PRICE" : " · ABOVE PRICE"), na(prevPOC) ? DB_HEAD : DB_DATA, text.align_right)
    f_dbDiv(9)
    f_dbCell(0, 10, "LAST SIGNAL", DB_HEAD, text.align_left)
    f_dbCell(1, 10, lastMdl == "-" ? "-" : lastMdl + (na(lastConv) ? "" : " C" + str.tostring(lastConv)) + " · " + str.tostring(bar_index - lastSigBar) + "B", DB_DATA, text.align_right)
    totD  = attRL.sum() + attRS.sum()
    winD  = winRL.sum() + winRS.sum()
    hiAtt = attRL.get(2) + attRS.get(2)
    hiWin = winRL.get(2) + winRS.get(2)
    dbTxt = (totD > 0 ? str.tostring(math.round(winD * 100.0 / totD)) + "%" : "-") + (hiAtt >= 3 ? " · T3 " + str.tostring(math.round(hiWin * 100.0 / hiAtt)) + "%" : "") + " · " + str.tostring(totD) + " TRK"
    f_dbCell(0, 11, "DATABASE", DB_HEAD, text.align_left)
    f_dbCell(1, 11, totD == 0 ? "BUILDING..." : dbTxt, totD == 0 ? DB_HEAD : winD >= totD / 2.0 ? bullTx : bearTx, text.align_right)
    bestI = -1
    bestR = 0.0
    for i = 0 to 3
        a = sesA.get(i)
        if a >= 3
            r = sesW.get(i) * 100.0 / a
            if r > bestR
                bestR := r
                bestI := i
    f_dbCell(0, 12, "BEST SESSION", DB_HEAD, text.align_left)
    f_dbCell(1, 12, bestI < 0 ? "LEARNING..." : sesName(bestI) + " " + str.tostring(bestR, "#") + "%", bestI < 0 ? DB_HEAD : color.new(i_colGold, 0), text.align_right)
    f_dbDiv(13)
    f_dbCell(0, 14, "RECORD", DB_HEAD, text.align_left)
    f_dbCell(1, 14, str.tostring(winN) + "W · " + str.tostring(lossN) + "L" + (lastOutcome != "" ? " · " + lastOutcome : ""), DB_DATA, text.align_right)
    f_dbCell(0, 15, "SESSION", DB_HEAD, text.align_left)
    f_dbCell(1, 15, sesName(sesIdx), DB_DATA, text.align_right)
    f_dbCell(0, 16, "KINETIC", DB_HEAD, text.align_left)
    f_dbCell(1, 16, str.tostring(kinN, "#.##") + (kinN >= 0.85 ? " SPIKE" : ""), kinN >= 0.85 ? color.new(i_colGold, 0) : DB_DATA, text.align_right)
    f_dbCell(0, 17, "AUTOMATION", DB_HEAD, text.align_left)
    f_dbCell(1, 17, tw_enabled ? "ARMED" : "OFF", tw_enabled ? bullTx : bearTx, text.align_right)
    f_dbCell(0, 18, "SYMBOL", DB_HEAD, text.align_left)
    f_dbCell(1, 18, twSym, DB_DATA, text.align_right)

if not i_dbShow and dbDrawn
    table.clear(db, 0, 0, 1, 18)
    dbDrawn := false

// =============================================================================
// API - hidden plots for external scanners
// =============================================================================
plot(longSignal ? 1 : shortSignal ? -1 : 0, "API Signal", display = display.none)
plot(deltaPct > 0 ? 1 : -1, "API Auction Delta", display = display.none)

alertcondition(longSignal, title = "Auction Long Signal", message = "Auction LONG on {{ticker}} @ {{close}}")
alertcondition(shortSignal, title = "Auction Short Signal", message = "Auction SHORT on {{ticker}} @ {{close}}")
````
