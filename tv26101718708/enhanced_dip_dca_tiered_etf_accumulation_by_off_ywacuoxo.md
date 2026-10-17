# Enhanced Dip DCA - Tiered ETF Accumulation ( By Off )

- url: https://www.tradingview.com/script/ywACuoXO-Enhanced-Dip-DCA-Tiered-ETF-Accumulation-By-Off/
- type: indicator
- pine_id: PUB;5491e7c5e79d49fe8f30215d4d1e4cde
- version: 1.0

## Description

Indicator help for dip DCA ETF long term.
Use for DCA 5% 10% 20% from market.

## Source Code

````pine
//@version=6
// =============================================================================
//  ENHANCED DIP DCA  -  Tiered ETF Accumulation  (TradingView Pine Script v6)
// =============================================================================
//  Companion to "Enhanced_Dip_DCA_Framework.docx" and "Dip_DCA_ETF_Model.xlsx".
//
//  WHAT THIS DOES
//  Runs the Dip DCA framework on REAL chart data and compares it, side by side,
//  with plain Blind DCA. It simulates a monthly contribution, splits it into a
//  Core bucket (always invested) and a Reserve bucket (cash, deployed in tiers
//  on -5% / -10% / -15% drawdowns from the high), and shows a results table.
//
//  HOW TO USE
//  1. Open a daily chart of a broad-market ETF (SPY, VOO, VTI, IVV ... or QQQ).
//  2. Paste this whole file into the Pine Editor and click "Add to chart".
//  3. Read the table (top-right): Blind DCA vs Dip DCA on this symbol's history.
//  Designed for the DAILY timeframe (cash-yield accrual assumes ~252 bars/year).
//
//  NOTE: this is a research / education tool, NOT investment advice. The cost-
//  basis and wealth numbers depend on the chart's visible history.
// =============================================================================

indicator("Enhanced Dip DCA - Tiered ETF Accumulation", overlay = true)

// ----------------------------------------------------------------------------
// 1. INPUTS
// ----------------------------------------------------------------------------
gP            = "Plan"
monthlyBudget = input.float(1000.0, "Monthly contribution ($)", minval = 1, group = gP)
corePct       = input.float(70.0, "Core allocation (%)", minval = 0, maxval = 100, group = gP)
reserveCapM   = input.int(12, "Reserve cap (months of reserve saving)", minval = 1, group = gP)
cashAPY       = input.float(4.0, "Reserve cash yield (% APY)", minval = 0, group = gP)

gD            = "Dip definition"
useATH        = input.bool(true, "Measure dip from all-time high (off = 52-week high)", group = gD)
t1Trig        = input.float(5.0,  "Tier 1 trigger (% drawdown)", minval = 0.5, group = gD)
t2Trig        = input.float(10.0, "Tier 2 trigger (% drawdown)", minval = 0.5, group = gD)
t3Trig        = input.float(15.0, "Tier 3 trigger (% drawdown)", minval = 0.5, group = gD)
t1Dep         = input.float(25.0, "Tier 1 deploy (% of reserve)", minval = 0, maxval = 100, group = gD)
t2Dep         = input.float(35.0, "Tier 2 deploy (% of reserve)", minval = 0, maxval = 100, group = gD)
t3Dep         = input.float(40.0, "Tier 3 deploy (% of reserve)", minval = 0, maxval = 100, group = gD)
rearmPct      = input.float(2.0,  "Re-arm tiers within (% of high)", minval = 0, group = gD)

gT            = "Trend gate (200-DMA)"
useRegime     = input.bool(true, "Use trend regime gate", group = gT)
maLen         = input.int(200, "Trend MA length", minval = 5, group = gT)
bearBuffer    = input.float(8.0, "Bear regime: price this % below MA", minval = 0, group = gT)

gR            = "Optional RSI confirmation"
useRSI        = input.bool(false, "Require RSI confirmation on Tier 1", group = gR)
rsiLen        = input.int(14, "RSI length", minval = 2, group = gR)
rsiMax        = input.float(35.0, "Tier 1 only if RSI below", group = gR)

gV            = "Display"
showLevels    = input.bool(true, "Show tier price levels", group = gV)
showRegimeBg  = input.bool(true, "Shade Caution / Bear regimes", group = gV)

// ----------------------------------------------------------------------------
// 2. MARKET STATE
// ----------------------------------------------------------------------------
coreFrac    = corePct / 100.0
reserveFrac = 1.0 - coreFrac

// reference high  -  drawdown is measured from here
var float ath = na
ath := na(ath) ? high : math.max(ath, high)
hi52    = ta.highest(high, 252)
refHigh = useATH ? ath : hi52
dd      = close / refHigh - 1.0                       // drawdown from high (<= 0)

// trend regime via the long moving average
ma     = ta.sma(close, maLen)
regime = not useRegime or na(ma) ? "Bull" : close > ma ? "Bull" : close > ma * (1.0 - bearBuffer / 100.0) ? "Caution" : "Bear"
mult   = regime == "Bull" ? 1.0 : regime == "Caution" ? 0.7 : 0.5

rsiVal = ta.rsi(close, rsiLen)

// ----------------------------------------------------------------------------
// 3. STRATEGY STATE  (persists bar to bar)
// ----------------------------------------------------------------------------
var float shares       = 0.0      // Dip DCA shares held
var float investedEq   = 0.0      // $ that actually bought ETF shares (Dip DCA)
var float reserve      = 0.0      // Dip DCA cash reserve
var bool  armed1       = true
var bool  armed2       = true
var bool  armed3       = true
var int   n1           = 0
var int   n2           = 0
var int   n3           = 0
var float blindShares  = 0.0      // Blind DCA shares held
var float contributed  = 0.0      // total cash contributed (same for both methods)

dailyCash  = math.pow(1.0 + cashAPY / 100.0, 1.0 / 252.0) - 1.0
reserveCap = reserveCapM * reserveFrac * monthlyBudget
coreAmt    = coreFrac * monthlyBudget
resAmt     = reserveFrac * monthlyBudget

// ----------------------------------------------------------------------------
// 4. DAILY CASH-YIELD ACCRUAL ON THE RESERVE
// ----------------------------------------------------------------------------
if reserve > 0.0
    reserve := reserve * (1.0 + dailyCash)

// ----------------------------------------------------------------------------
// 5. MONTHLY CONTRIBUTION
// ----------------------------------------------------------------------------
newMonth = timeframe.change("1M")
if newMonth and close > 0.0
    // Dip DCA  -  core is always invested
    shares      := shares + coreAmt / close
    investedEq  := investedEq + coreAmt
    reserve     := reserve + resAmt
    // anti cash-drag: overflow above the cap is invested immediately
    if reserve > reserveCap
        overflow   = reserve - reserveCap
        shares     := shares + overflow / close
        investedEq := investedEq + overflow
        reserve    := reserveCap
    // Blind DCA  -  the whole budget goes straight in
    blindShares := blindShares + monthlyBudget / close
    contributed := contributed + monthlyBudget

// ----------------------------------------------------------------------------
// 6. RE-ARM TIERS once price has recovered near its high
// ----------------------------------------------------------------------------
if dd >= -rearmPct / 100.0
    armed1 := true
    armed2 := true
    armed3 := true

// ----------------------------------------------------------------------------
// 7. TIER DEPLOYMENT  (deepest tier first, so a crash front-loads buying)
//    regime gate: Tier 1 needs Bull; Tier 2 needs Bull/Caution; Tier 3 any
// ----------------------------------------------------------------------------
gate1 = regime == "Bull"
gate2 = regime == "Bull" or regime == "Caution"
gate3 = true

// Tier 3  ( -15% )
fireT3 = armed3 and dd <= -t3Trig / 100.0 and reserve > 1.0 and gate3 and close > 0.0
if fireT3
    deploy      = reserve * (t3Dep / 100.0) * mult
    shares     := shares + deploy / close
    investedEq := investedEq + deploy
    reserve    := reserve - deploy
    armed3     := false
    n3         := n3 + 1

// Tier 2  ( -10% )
fireT2 = armed2 and dd <= -t2Trig / 100.0 and reserve > 1.0 and gate2 and close > 0.0
if fireT2
    deploy      = reserve * (t2Dep / 100.0) * mult
    shares     := shares + deploy / close
    investedEq := investedEq + deploy
    reserve    := reserve - deploy
    armed2     := false
    n2         := n2 + 1

// Tier 1  ( -5% )  -  optional RSI confirmation
rsiOK  = not useRSI or rsiVal < rsiMax
fireT1 = armed1 and dd <= -t1Trig / 100.0 and reserve > 1.0 and gate1 and rsiOK and close > 0.0
if fireT1
    deploy      = reserve * (t1Dep / 100.0) * mult
    shares     := shares + deploy / close
    investedEq := investedEq + deploy
    reserve    := reserve - deploy
    armed1     := false
    n1         := n1 + 1

// ----------------------------------------------------------------------------
// 8. PLOTS
// ----------------------------------------------------------------------------
plot(ma, "Trend MA", color = color.new(color.gray, 0), linewidth = 1)
plot(showLevels ? refHigh : na, "Reference high", color = color.new(color.gray, 55), style = plot.style_stepline)
plot(showLevels ? refHigh * (1.0 - t1Trig / 100.0) : na, "Tier 1 level", color = color.new(color.orange, 35), style = plot.style_stepline)
plot(showLevels ? refHigh * (1.0 - t2Trig / 100.0) : na, "Tier 2 level", color = color.new(color.yellow, 35), style = plot.style_stepline)
plot(showLevels ? refHigh * (1.0 - t3Trig / 100.0) : na, "Tier 3 level", color = color.new(color.red, 35), style = plot.style_stepline)

plotshape(fireT1, "Tier 1 buy", shape.triangleup, location.belowbar, color.new(color.orange, 0), text = "T1", textcolor = color.white, size = size.tiny)
plotshape(fireT2, "Tier 2 buy", shape.triangleup, location.belowbar, color.new(#E0A21E, 0), text = "T2", textcolor = color.white, size = size.tiny)
plotshape(fireT3, "Tier 3 buy", shape.triangleup, location.belowbar, color.new(color.red, 0),    text = "T3", textcolor = color.white, size = size.tiny)

regimeBg = not showRegimeBg ? na : regime == "Bear" ? color.new(color.red, 90) : regime == "Caution" ? color.new(color.orange, 92) : na
bgcolor(regimeBg, title = "Regime shading")

// ----------------------------------------------------------------------------
// 9. RESULTS TABLE  -  Blind DCA vs Dip DCA on this symbol's history
//    Helper functions are declared at global scope (Pine forbids declaring
//    functions inside an if-block).
// ----------------------------------------------------------------------------
money(x)  => "$" + str.tostring(x, "0")
money2(x) => "$" + str.tostring(x, "0.00")
pctTxt(x) => str.tostring(x * 100.0, "0.0") + "%"

var table tbl = table.new(position.top_right, 3, 11, frame_color = color.gray, frame_width = 1, border_color = color.new(color.gray, 60), border_width = 1)

rowLabel(r, txt) => table.cell(tbl, 0, r, txt, text_color = color.black, bgcolor = color.new(color.gray, 92), text_size = size.small, text_halign = text.align_left)
rowVal(c, r, v)  => table.cell(tbl, c, r, v,  text_color = color.black, bgcolor = color.new(color.gray, 92), text_size = size.small)

if barstate.islast and shares > 0.0 and blindShares > 0.0
    blindVal  = blindShares * close
    blindCost = contributed / blindShares
    blindRet  = blindVal / contributed - 1.0
    dipEqVal  = shares * close
    dipTotVal = dipEqVal + reserve
    dipCost   = investedEq / shares
    dipRet    = dipTotVal / contributed - 1.0
    hdrBg     = color.new(#2E6FB7, 0)

    table.cell(tbl, 0, 0, "Metric",    text_color = color.white, bgcolor = hdrBg, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 0, "Blind DCA", text_color = color.white, bgcolor = hdrBg, text_size = size.small)
    table.cell(tbl, 2, 0, "Dip DCA",   text_color = color.white, bgcolor = hdrBg, text_size = size.small)

    rowLabel(1, "Total contributed")
    rowVal(1, 1, money(contributed))
    rowVal(2, 1, money(contributed))
    rowLabel(2, "Value in ETF")
    rowVal(1, 2, money(blindVal))
    rowVal(2, 2, money(dipEqVal))
    rowLabel(3, "Cash reserve left")
    rowVal(1, 3, money(0.0))
    rowVal(2, 3, money(reserve))
    rowLabel(4, "Total value")
    rowVal(1, 4, money(blindVal))
    rowVal(2, 4, money(dipTotVal))
    rowLabel(5, "Shares held")
    rowVal(1, 5, str.tostring(blindShares, "0.000"))
    rowVal(2, 5, str.tostring(shares, "0.000"))
    rowLabel(6, "Avg cost basis / share")
    rowVal(1, 6, money2(blindCost))
    rowVal(2, 6, money2(dipCost))
    rowLabel(7, "Total return")
    rowVal(1, 7, pctTxt(blindRet))
    rowVal(2, 7, pctTxt(dipRet))
    rowLabel(8, "Dip triggers T1/T2/T3")
    rowVal(1, 8, "-")
    rowVal(2, 8, str.tostring(n1) + " / " + str.tostring(n2) + " / " + str.tostring(n3))
    rowLabel(9, "Current regime")
    rowVal(1, 9, "-")
    rowVal(2, 9, regime)

    winTxt = dipTotVal > blindVal ? "Dip ahead" : "Blind ahead"
    winBg  = dipTotVal > blindVal ? color.new(color.green, 65) : color.new(color.red, 70)
    table.cell(tbl, 0, 10, "Verdict", text_color = color.black, bgcolor = winBg, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 10, winTxt, text_color = color.black, bgcolor = winBg, text_size = size.small)
    table.cell(tbl, 2, 10, pctTxt(dipTotVal / blindVal - 1.0), text_color = color.black, bgcolor = winBg, text_size = size.small)
````
