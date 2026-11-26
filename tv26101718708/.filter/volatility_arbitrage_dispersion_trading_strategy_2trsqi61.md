# Volatility Arbitrage Dispersion Trading Strategy 

- url: https://www.tradingview.com/script/2TrSqi61-Volatility-Arbitrage-Dispersion-Trading-Strategy/
- type: strategy
- pine_id: PUB;7e23d3de94ba47ceb99099c8944a23ab
- version: 1.0

## Description

OVERVIEW
Volatility Arbitrage Dispersion Trading Strategy Quantitative Finance is a professional, rules-based relative-value system by Viprasol Tech Private Limited. It brings the core ideas of institutional volatility arbitrage and dispersion trading to TradingView using quantitative finance methods: basket volatility decomposition, implied correlation, regime filtering and an Ornstein-Uhlenbeck mean-reversion model.

In classic dispersion trading, desks compare index volatility with the volatility of its components and trade the gap between implied and realized correlation. This volatility arbitrage dispersion trading strategy measures the same structure from price data and trades the chart asset when it becomes statistically mispriced against its basket.

█ HOW IT WORKS
⚪ 1. Dispersion Engine
▸ Builds a weighted basket (index) from up to 5 components
▸ Measures index volatility, average component volatility and dispersion (the gap between them)
▸ Calculates implied correlation from the index variance decomposition:
   ρ = (σ_index² − Σw²σᵢ²) / ((Σwσᵢ)² − Σw²σᵢ²)
▸ Automatically removes the chart asset from the basket so it is never compared with itself

⚪ 2. Regime Filter (volatility arbitrage risk control)
Dispersion trading is known to suffer in crises, when correlations spike. The strategy only trades when:
▸ Implied correlation is above the minimum (the basket moves as one)
▸ Correlation is NOT spiking (correlation z-score below the block level)
▸ The asset's volatility is not expanding sharply (short RV / long RV)
▸ Optional: implied volatility is above realized volatility (positive volatility risk premium, e.g. Deribit DVOL for BTC)

⚪ 3. Residual Model (quantitative finance core)
▸ Hedges the chart asset against the basket with a rolling beta
▸ Models the cumulative residual as an Ornstein-Uhlenbeck (AR-1) process
▸ Estimates the mean-reversion half-life and the equilibrium (fair value)
▸ Produces an s-score: how many standard deviations the asset is from fair value
▸ Trades only when the half-life shows real, fast mean reversion

█ ENTRIES & EXITS
▸ Signal: s-score crosses back inside the entry band (reversal hook), only in a tradeable regime
▸ Reverse Mode (default ON): BUY ↔ SELL are flipped
▸ Take Profit: Fair Value (price where the residual returns to equilibrium) or Risk:Reward
▸ Stop Loss: ATR-based
▸ Statistical exits: fair value reached, s-score stop, time stop (multiple of half-life)
▸ Cooldown after each exit to avoid overtrading

█ POSITION SIZING
Volatility targeting (default 25% annual volatility, capped by max leverage) or fixed % of equity — standard practice in quantitative finance.

█ VISUALS
▸ Profit / loss position boxes on price with TP and SL levels
▸ BUY / SELL markers
▸ s-score pane with cheap / rich zones, or a Correlation & Dispersion view
▸ Pro dashboard: regime status (TRADEABLE / STAND ASIDE / MODEL INVALID), dispersion metrics, implied correlation, half-life, fair value and live performance

█ RECOMMENDED USE
▸ Timeframe: 4H or 1D (lower timeframes are dominated by fees and noise)
▸ Best on liquid assets that belong to a clear basket (e.g. major crypto vs the crypto basket)
▸ Adjust commission and slippage in Properties to match your broker

█ DEFAULT BACKTEST PROPERTIES
Initial capital 10,000 · Volatility-target sizing · Commission 0.05% · Slippage 2 ticks · Orders on bar close.

█ DISCLAIMER
This volatility arbitrage dispersion trading strategy is for educational and research purposes in quantitative finance only and is not financial advice. It estimates correlation from realized price data and does not trade options. Past performance does not guarantee future results.

© Viprasol Tech Private Limited

## Source Code

````pine
// © Viprasol Tech Private Limited — all rights reserved
//
// Volatility Arbitrage Dispersion Trading Strategy Quantitative Finance — by Viprasol (v2 Pro)
// ────────────────────────────────────────────────────────────────────────
// A volatility arbitrage dispersion trading strategy built on quantitative finance in three layers:
//   1. Dispersion engine   – basket index vol, average component vol, dispersion and
//                            realized implied-correlation (index variance decomposition).
//   2. Regime filter       – trades only in calm, high-correlation regimes; blocks
//                            correlation spikes (crisis), volatility expansion and,
//                            optionally, negative volatility-risk-premium (IV < RV).
//   3. Residual s-score    – beta-hedged residual of the chart asset vs the basket,
//                            modelled as an Ornstein-Uhlenbeck (AR-1) process.
//                            Trades only statistically valid mean-reversion
//                            (half-life filter) and enters on a confirmed hook.
// Designed & developed by Viprasol Tech Private Limited.

//@version=6
strategy("Volatility Arbitrage Dispersion Trading Strategy Quantitative Finance", shorttitle = "VADT Viprasol",
     overlay = false, initial_capital = 10000,
     default_qty_type = strategy.percent_of_equity, default_qty_value = 20,
     commission_type = strategy.commission.percent, commission_value = 0.05, slippage = 2,
     process_orders_on_close = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// ═════════════════════════════ INPUTS ═════════════════════════════
G1 = "① Dispersion Basket"
use1 = input.bool(true, "", inline = "1", group = G1)
s1   = input.symbol("BINANCE:BTCUSDT", "", inline = "1", group = G1)
w1   = input.float(1.0, "w", minval = 0, step = 0.1, inline = "1", group = G1)
use2 = input.bool(true, "", inline = "2", group = G1)
s2   = input.symbol("BINANCE:ETHUSDT", "", inline = "2", group = G1)
w2   = input.float(1.0, "w", minval = 0, step = 0.1, inline = "2", group = G1)
use3 = input.bool(true, "", inline = "3", group = G1)
s3   = input.symbol("BINANCE:SOLUSDT", "", inline = "3", group = G1)
w3   = input.float(1.0, "w", minval = 0, step = 0.1, inline = "3", group = G1)
use4 = input.bool(true, "", inline = "4", group = G1)
s4   = input.symbol("BINANCE:BNBUSDT", "", inline = "4", group = G1)
w4   = input.float(1.0, "w", minval = 0, step = 0.1, inline = "4", group = G1)
use5 = input.bool(true, "", inline = "5", group = G1)
s5   = input.symbol("BINANCE:XRPUSDT", "", inline = "5", group = G1)
w5   = input.float(1.0, "w", minval = 0, step = 0.1, inline = "5", group = G1)
autoEx = input.bool(true, "Auto-exclude the chart asset from the basket", group = G1,
     tooltip = "Prevents comparing the asset with itself (e.g. BTC chart vs a basket that contains BTC)")

G2 = "② Residual Model (s-score)"
betaLen  = input.int(60, "Hedge-ratio (beta) window", minval = 20, group = G2)
sLen     = input.int(60, "OU estimation window", minval = 20, group = G2)
sOpen    = input.float(1.25, "Entry |s|", step = 0.05, group = G2)
sExit    = input.float(0.50, "Exit |s| (back to fair value)", step = 0.05, group = G2)
sStop    = input.float(3.00, "Statistical stop |s|", step = 0.1, group = G2)
useHook  = input.bool(true, "Require reversal hook (s re-enters the band)", group = G2,
     tooltip = "Waits for the residual to turn back inside the entry band instead of catching a falling knife")
minHL    = input.float(1.0, "Min half-life (bars)", step = 0.5, group = G2)
maxHL    = input.float(30.0, "Max half-life (bars)", step = 1, group = G2,
     tooltip = "Only trades residuals that statistically mean-revert fast enough")

G3 = "③ Regime Filter"
minCorr   = input.float(0.40, "Min implied correlation", minval = -1, maxval = 1, step = 0.05, group = G3)
corrZLen  = input.int(100, "Correlation z-score window", minval = 20, group = G3)
maxCorrZ  = input.float(2.0, "Block correlation spikes above z", step = 0.1, group = G3)
rvLen     = input.int(20, "Realized vol window (short)", minval = 5, group = G3)
rvLongLen = input.int(100, "Realized vol window (long)", minval = 20, group = G3)
maxVolRat = input.float(1.5, "Max vol expansion (short RV / long RV)", step = 0.05, group = G3)
daysYear  = input.int(365, "Days per year", options = [252, 365], group = G3)
useVrp    = input.bool(false, "Use implied-vol (VRP) filter", group = G3)
ivSym     = input.symbol("DERIBIT:DVOL", "Implied vol index", group = G3)
minVrp    = input.float(0.0, "Min premium IV − RV (vol pts)", step = 0.5, group = G3)

G4 = "④ Risk & Execution"
sizeMode  = input.string("Volatility Target", "Position sizing", options = ["Volatility Target", "% of Equity"], group = G4)
targetVol = input.float(25.0, "Target annual volatility %", step = 1, group = G4)
maxLev    = input.float(1.0, "Max leverage", step = 0.1, minval = 0.1, group = G4)
atrLen    = input.int(14, "ATR length", group = G4)
slAtr     = input.float(2.5, "Stop Loss (x ATR)", step = 0.1, group = G4)
tpMode    = input.string("Fair Value", "Take Profit", options = ["Fair Value", "Risk:Reward", "s-score exit only"], group = G4,
     tooltip = "Fair Value = price where the residual returns to its equilibrium (s = 0)")
rrTP      = input.float(4.1, "Risk:Reward (if selected)", step = 0.1, group = G4)
hlMult    = input.float(3.0, "Time stop (x half-life)", step = 0.5, group = G4)
maxBars   = input.int(60, "Time stop cap (bars)", minval = 1, group = G4)
cooldown  = input.int(3, "Cooldown after exit (bars)", minval = 0, group = G4)
reverseMode = input.bool(true, "Reverse Mode (BUY ↔ SELL)", group = G4)

G5 = "⑤ Visuals"
showPos   = input.bool(true, "Position boxes on price", group = G5)
showSig   = input.bool(true, "BUY / SELL markers on price", group = G5)
paneView  = input.string("S-Score", "Pane view", options = ["S-Score", "Correlation & Dispersion"], group = G5)
showDash  = input.bool(true, "Dashboard", group = G5)
dashPos   = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G5)
dashSize  = input.string("Small", "Dashboard text", options = ["Tiny", "Small", "Normal"], group = G5)
cBull     = input.color(#00C9A7, "Long", inline = "c", group = G5)
cBear     = input.color(#FF4D6D, "Short", inline = "c", group = G5)
cNeutral  = input.color(#5B9CF6, "Accent", inline = "c", group = G5)

// ═════════════════════════════ DATA ═════════════════════════════
annF = math.sqrt(daysYear * 86400.0 / timeframe.in_seconds())
getRet(simple string sym) => request.security(sym, timeframe.period, math.log(close / close[1]), lookahead = barmerge.lookahead_off)

isSelf(simple string sym) =>
    base = syminfo.basecurrency
    autoEx and (sym == syminfo.tickerid or (str.length(base) > 0 and str.contains(sym, ":" + base)))

r1 = getRet(s1)
r2 = getRet(s2)
r3 = getRet(s3)
r4 = getRet(s4)
r5 = getRet(s5)

v1 = ta.stdev(r1, rvLen) * annF
v2 = ta.stdev(r2, rvLen) * annF
v3 = ta.stdev(r3, rvLen) * annF
v4 = ta.stdev(r4, rvLen) * annF
v5 = ta.stdev(r5, rvLen) * annF

ok1 = use1 and not isSelf(s1) and not na(v1)
ok2 = use2 and not isSelf(s2) and not na(v2)
ok3 = use3 and not isSelf(s3) and not na(v3)
ok4 = use4 and not isSelf(s4) and not na(v4)
ok5 = use5 and not isSelf(s5) and not na(v5)
wSum = (ok1 ? w1 : 0) + (ok2 ? w2 : 0) + (ok3 ? w3 : 0) + (ok4 ? w4 : 0) + (ok5 ? w5 : 0)
nw1 = wSum > 0 and ok1 ? w1 / wSum : 0.0
nw2 = wSum > 0 and ok2 ? w2 / wSum : 0.0
nw3 = wSum > 0 and ok3 ? w3 / wSum : 0.0
nw4 = wSum > 0 and ok4 ? w4 / wSum : 0.0
nw5 = wSum > 0 and ok5 ? w5 / wSum : 0.0
nComp = (ok1 ? 1 : 0) + (ok2 ? 1 : 0) + (ok3 ? 1 : 0) + (ok4 ? 1 : 0) + (ok5 ? 1 : 0)

// ── Dispersion engine
rB      = nw1 * nz(r1) + nw2 * nz(r2) + nw3 * nz(r3) + nw4 * nz(r4) + nw5 * nz(r5)
volI    = ta.stdev(rB, rvLen) * annF
sumWV   = nw1 * nz(v1) + nw2 * nz(v2) + nw3 * nz(v3) + nw4 * nz(v4) + nw5 * nz(v5)
sumW2V2 = math.pow(nw1 * nz(v1), 2) + math.pow(nw2 * nz(v2), 2) + math.pow(nw3 * nz(v3), 2) + math.pow(nw4 * nz(v4), 2) + math.pow(nw5 * nz(v5), 2)
den      = math.pow(sumWV, 2) - sumW2V2
implCorr = den > 0 and nComp >= 2 ? math.max(-1, math.min(1, (math.pow(volI, 2) - sumW2V2) / den)) : na
dispersion = sumWV - volI
corrZ    = (implCorr - ta.sma(implCorr, corrZLen)) / ta.stdev(implCorr, corrZLen)

// ── Chart asset
rA     = math.log(close / close[1])
rvS    = ta.stdev(rA, rvLen) * annF
rvL    = ta.stdev(rA, rvLongLen) * annF
volRat = rvS / rvL
beta   = ta.correlation(rA, rB, betaLen) * ta.stdev(rA, betaLen) / ta.stdev(rB, betaLen)
atr    = ta.atr(atrLen)

// ── Residual OU model (Avellaneda-Lee style s-score)
resid = nz(rA) - nz(beta[1]) * rB
X     = ta.cum(resid)
X1    = X[1]
mX    = ta.sma(X, sLen)
mX1   = ta.sma(X1, sLen)
covXY = ta.sma(X * X1, sLen) - mX * mX1
varX1 = ta.sma(X1 * X1, sLen) - mX1 * mX1
varX  = ta.sma(X * X, sLen) - mX * mX
b1    = varX1 > 0 ? covXY / varX1 : na
a0    = mX - b1 * mX1
mrOK  = not na(b1) and b1 > 0 and b1 < 1
varEp = math.max(varX - nz(b1) * covXY, 0)
hl    = mrOK ? math.log(2) / -math.log(b1) : na
mEq   = mrOK ? a0 / (1 - b1) : na
sigEq = mrOK and varEp > 0 ? math.sqrt(varEp / (1 - b1 * b1)) : na
sScore = not na(sigEq) and sigEq > 0 ? (X - mEq) / sigEq : na
fairPx = not na(mEq) ? close * math.exp(mEq - X) : na

// ── Volatility risk premium
ivRaw = request.security(ivSym, timeframe.period, close, ignore_invalid_symbol = true, lookahead = barmerge.lookahead_off)
vrp   = ivRaw - rvS * 100

// ═════════════════════════════ REGIME & SIGNALS ═════════════════════════════
corrOK   = not na(implCorr) and implCorr >= minCorr
spikeOK  = na(corrZ) or corrZ <= maxCorrZ
volOK    = not na(volRat) and volRat <= maxVolRat
vrpOK    = not useVrp or (not na(vrp) and vrp >= minVrp)
hlOK     = not na(hl) and hl >= minHL and hl <= maxHL
regimeOK = corrOK and spikeOK and volOK and vrpOK
modelOK  = hlOK and not na(sScore) and wSum > 0

longSetup  = useHook ? ta.crossover(sScore, -sOpen) : sScore <= -sOpen
shortSetup = useHook ? ta.crossunder(sScore, sOpen) : sScore >=  sOpen
rawLong  = regimeOK and modelOK and longSetup  and sScore > -sStop
rawShort = regimeOK and modelOK and shortSetup and sScore <  sStop
goLong   = reverseMode ? rawShort : rawLong
goShort  = reverseMode ? rawLong  : rawShort

volTgtQty = rvS > 0 ? strategy.equity * math.min(targetVol / 100 / rvS, maxLev) / close : na
qty = sizeMode == "Volatility Target" ? volTgtQty : na

// ═════════════════════════════ EXECUTION ═════════════════════════════
var box   bxProfit  = na
var box   bxLoss    = na
var line  lnEntry   = na
var bool  tradeLive = false
var int   entryBar  = na
var int   lastExit  = -100000
var bool  sigLong   = false
var int   tLimit    = na

flat   = strategy.position_size == 0 and not tradeLive
coolOK = bar_index - lastExit > cooldown

if flat and coolOK and (goLong or goShort)
    isLong = goLong
    e    = close
    risk = atr * slAtr
    slP  = isLong ? e - risk : e + risk
    fvOK = not na(fairPx) and (isLong ? fairPx > e : fairPx < e)
    rrPx = isLong ? e + risk * rrTP : e - risk * rrTP
    tp   = tpMode == "Fair Value" ? (fvOK ? fairPx : rrPx) : tpMode == "Risk:Reward" ? rrPx : na
    tag  = (isLong ? "Long" : "Short") + (reverseMode ? " R" : "")
    if isLong
        strategy.entry("Long", strategy.long, qty = qty, comment = tag)
        strategy.exit("Long X", "Long", stop = slP, limit = tp, comment_loss = "SL", comment_profit = "TP")
    else
        strategy.entry("Short", strategy.short, qty = qty, comment = tag)
        strategy.exit("Short X", "Short", stop = slP, limit = tp, comment_loss = "SL", comment_profit = "TP")
    if showPos
        tpDraw = na(tp) ? rrPx : tp
        bxProfit := box.new(bar_index, math.max(e, tpDraw), bar_index + 1, math.min(e, tpDraw),
             border_color = color.new(cBull, 40), bgcolor = color.new(cBull, 85),
             text = (na(tp) ? "Target ~ " : "TP ") + str.tostring(tpDraw, format.mintick), text_size = size.tiny,
             text_color = cBull, text_halign = text.align_right, text_valign = isLong ? text.align_top : text.align_bottom,
             force_overlay = true)
        bxLoss := box.new(bar_index, math.max(e, slP), bar_index + 1, math.min(e, slP),
             border_color = color.new(cBear, 40), bgcolor = color.new(cBear, 85),
             text = "SL " + str.tostring(slP, format.mintick), text_size = size.tiny,
             text_color = cBear, text_halign = text.align_right, text_valign = isLong ? text.align_bottom : text.align_top,
             force_overlay = true)
        lnEntry := line.new(bar_index, e, bar_index + 1, e, color = cNeutral, width = 2, force_overlay = true)
    tradeLive := true
    entryBar  := bar_index
    sigLong   := rawLong
    tLimit    := math.min(maxBars, math.max(1, int(math.round(nz(hl, maxBars) * hlMult))))

// Statistical exits (fair value reached / s-stop / time stop)
if strategy.position_size != 0 and bar_index > entryBar
    meanHit  = sigLong ? sScore >= -sExit : sScore <= sExit
    sStopHit = sigLong ? sScore <= -sStop : sScore >= sStop
    tStop    = bar_index - entryBar >= tLimit
    if meanHit or sStopHit or tStop
        strategy.close_all(comment = meanHit ? "Fair value" : sStopHit ? "s-Stop" : "Time")

// Keep position graphics running until the trade closes
if tradeLive
    if strategy.position_size != 0 or bar_index == entryBar
        if showPos and not na(bxProfit)
            box.set_right(bxProfit, bar_index + 1)
            box.set_right(bxLoss, bar_index + 1)
            line.set_x2(lnEntry, bar_index + 1)
    else
        tradeLive := false
        lastExit  := bar_index

// ═════════════════════════════ PANE ═════════════════════════════
isS = paneView == "S-Score"
bgcolor(regimeOK and modelOK ? color.new(cNeutral, 93) : na, title = "Tradeable regime")

hOpenU = hline(sOpen,  "Entry +", color = color.new(cBear, isS ? 50 : 100), linestyle = hline.style_dashed)
hOpenD = hline(-sOpen, "Entry −", color = color.new(cBull, isS ? 50 : 100), linestyle = hline.style_dashed)
hStopU = hline(sStop,  "Stop +",  color = color.new(cBear, isS ? 75 : 100), linestyle = hline.style_dotted)
hStopD = hline(-sStop, "Stop −",  color = color.new(cBull, isS ? 75 : 100), linestyle = hline.style_dotted)
hline(0, "Fair value", color = color.new(#787B86, 60))
fill(hOpenU, hStopU, color = color.new(cBear, isS ? 92 : 100), title = "Rich zone")
fill(hOpenD, hStopD, color = color.new(cBull, isS ? 92 : 100), title = "Cheap zone")

sCol = sScore >= 0 ? color.from_gradient(sScore, 0, sStop, #B2B5BE, cBear) : color.from_gradient(sScore, -sStop, 0, cBull, #B2B5BE)
plot(isS ? sScore : na, "s-score", color = sCol, linewidth = 2)
plot(isS and (rawLong or rawShort) ? sScore : na, "Signal", color = rawLong ? cBull : cBear, style = plot.style_circles, linewidth = 4)

plot(not isS ? implCorr : na, "Implied correlation", color = cNeutral, linewidth = 2)
plot(not isS ? dispersion : na, "Dispersion (vol)", color = #FFB020, linewidth = 1)
plot(not isS ? minCorr : na, "Min correlation", color = color.new(#787B86, 40))

plotshape(showSig and goLong,  "BUY",  shape.labelup,   location.belowbar, cBull, text = "BUY",  textcolor = color.white, size = size.tiny, force_overlay = true)
plotshape(showSig and goShort, "SELL", shape.labeldown, location.abovebar, cBear, text = "SELL", textcolor = color.white, size = size.tiny, force_overlay = true)

// ═════════════════════════════ DASHBOARD ═════════════════════════════
tPos = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
tSz  = dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : size.small
var table dash = table.new(tPos, 2, 18, bgcolor = color.new(#0E1117, 5), border_color = #2A2E39, border_width = 1, frame_color = color.new(cNeutral, 40), frame_width = 1)

fP(float x) => na(x) ? "–" : str.tostring(x * 100, "#.0") + "%"
fN(float x, string f) => na(x) ? "–" : str.tostring(x, f)
okC(bool b) => b ? cBull : cBear

row(int r, string k, string v, color vc) =>
    table.cell(dash, 0, r, k, text_color = #B2B5BE, text_size = tSz, text_halign = text.align_left)
    table.cell(dash, 1, r, v, text_color = vc, text_size = tSz, text_halign = text.align_right)

section(int r, string t) =>
    table.cell(dash, 0, r, t, text_color = cNeutral, text_size = tSz, text_halign = text.align_left, bgcolor = color.new(cNeutral, 88))
    table.cell(dash, 1, r, "", bgcolor = color.new(cNeutral, 88))

if showDash and barstate.islast
    status = not modelOK ? "MODEL INVALID" : regimeOK ? "TRADEABLE" : "STAND ASIDE"
    table.cell(dash, 0, 0, "VADT · Viprasol", text_color = color.white, text_size = tSz, text_halign = text.align_left)
    table.cell(dash, 1, 0, status, text_color = color.white, text_size = tSz, bgcolor = regimeOK and modelOK ? color.new(cBull, 20) : color.new(cBear, 20))
    section(1, "DISPERSION")
    row(2, "Index vol",         fP(volI), color.white)
    row(3, "Avg component vol", fP(sumWV), color.white)
    row(4, "Dispersion",        fP(dispersion), color.white)
    row(5, "Implied corr (z)",  fN(implCorr, "#.00") + "  (" + fN(corrZ, "#.0") + ")", okC(corrOK and spikeOK))
    row(6, "Vol expansion",     fN(volRat, "#.00") + "x", okC(volOK))
    row(7, "Vol risk premium",  not useVrp ? "off" : na(vrp) ? "no IV data" : fN(vrp, "#.0") + " pts", okC(vrpOK))
    section(8, "RESIDUAL MODEL")
    row(9,  "Beta to basket",   fN(beta, "#.00"), color.white)
    row(10, "s-score",          fN(sScore, "#.00"), math.abs(nz(sScore)) >= sOpen ? #FFB020 : color.white)
    row(11, "Half-life (bars)", fN(hl, "#.0"), okC(hlOK))
    row(12, "Fair value",       fN(fairPx, format.mintick), color.white)
    section(13, "PERFORMANCE")
    wins  = strategy.wintrades
    total = strategy.closedtrades
    pf    = strategy.grossloss > 0 ? strategy.grossprofit / strategy.grossloss : na
    row(14, "Trades · Win rate", str.tostring(total) + " · " + (total > 0 ? str.tostring(wins * 100.0 / total, "#.0") + "%" : "–"), color.white)
    row(15, "Profit factor",     fN(pf, "#.00"), okC(nz(pf) >= 1))
    row(16, "Net P/L",           str.tostring(strategy.netprofit / strategy.initial_capital * 100, "#.00") + "%", okC(strategy.netprofit >= 0))
    tfWarn = timeframe.in_seconds() < 3600
    row(17, tfWarn ? "⚠ Timeframe" : "Mode", tfWarn ? "Use 1H+ (4H / 1D best)" : reverseMode ? "Reverse" : "Normal", tfWarn ? #FFB020 : color.white)
````
