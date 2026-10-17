# Economic Confidence Model v3.14

- url: https://www.tradingview.com/script/BjWF2m8y-Economic-Confidence-Model-v3-14/
- type: indicator
- pine_id: PUB;1fdc8281423a44e4b32c683bb831c7ea
- version: 1.0

## Description

Every price chart is drawn on top of an economy it never shows. Yields, credit spreads, sovereign bonds, currencies, metals, fuel, freight, grain and livestock all move beneath a stock or an index, and the chart prints only the result. A trader who wants the field beneath the result usually opens a dozen tabs and tries to hold them in mind at once. Economic Confidence Model v3.14 (short-title "Socrates") holds them in one pane. Fetching 39 external feeds of its own, it then translates each into the same pressure units, and reports two engines on a shared axis of "BondMap" vs. "Bottleneck". Finally, the survey condenses their relationship into one of thirteen regime states, explains its verdicts with evidence tables rather than soliciting trust.

The word "Confidence" needs care before anything else. 

Here, it means coordination, the degree to which markets act as if they believe their own story. Three Card Monte and/or adversarial game theory may be a conceptual stretch among regulated company. Yet a market can be confidently liquidating, a currency can be confidently squeezing the world, and a commodity board confidently price scarcity. By design, the model measures the strength and source of coordination, never its virtue.

[b]Two Engines on One Axis
[/b]
The bond engine reads five modules. Rates watches the US 2-year, 10-year and 30-year yields; Duration watches TLT, IEF and SHY; Credit watches HYG, LQD and their ratio; Global watches German, French, British, Japanese, Chinese, Brazilian and South African 10-year yields; and FX Witness watches the dollar index, USDJPY, AUDJPY and EURUSD. Each module returns a verdict of Strain, Stress, Conflict, Stabilizing, Relief or Expansion. A sixth column, Route, names the spread or ratio most worth inspecting when the modules disagree, which turns a contradiction into a place to look.

Beneath the route, a spread lens prints that spread directly. It subtracts one yield from another, shows the result in percentage points, and classifies it: a US curve reads normal or inverted and steepening or flattening, while a cross-country pair such as French against German yields reads positive or negative and rising or falling. A credit-ratio route, or no route at all, sends the lens back to the US 10-year minus 2-year curve. The lens absorbs and retires the OverUnder Yield Spread, a separate script built on the same simple measure, as a spread this basic belongs beside the evidence that makes it worth reading.

The commodity engine reads six economic clusters rather than textbook categories. Monetary holds gold and silver, Industrial holds copper, platinum and iron ore, and Energy holds crude, natural gas, heating oil and the Baltic Dry Index as a freight witness. Grains, Softs and Livestock complete the food and input chain, with lumber placed among the softs as a construction-sensitive material. Each module returns Shock, Stress, Cross-Pressure, Stable, Thaw or Reflation, and a header reports the board's wave, breadth, intensity, persistence and fracture count.

No raw prices are ever averaged. A Treasury yield, a credit ratio and a bushel of wheat share neither units nor meaning, so every input is first converted into direction against a four-bar lookback, position against a 13-bar average, recent persistence and, for commodities, a 52-bar percentile rank. Those observations become module grades, and the grades become the two histograms. Both histograms speak the same pressure language, so their overlap means something: both rising describes coordinated confidence, both falling describes compound stress, and a split describes one engine carrying the pressure while the other refuses it.

[b]Thirteen States and a π Clock
[/b]
The regime layer maps the two engines into four families with three levels each. Shared Confidence means both engines are constructive, Compound Stress means both are stressed, Financial Stress / Input Relief means bonds are stressed while commodities are not, and Input Stress / Financial Relief means the reverse. The thirteenth state, Mixed Tape / Anomaly, marks the configurations that refuse the clean map. Repeated anomaly is not noise; it is the model reporting that the economy has stopped speaking its usual grammar.

Squares on the zero line carry the active state, and the background repeats its color with an opacity that rises with the level. Open circles mark π checkpoints, printed every three bars that a state survives, because Pine counts in whole bars and three is the nearest integer to π. The version number shares the same joke and the same discipline.

Beneath each engine sits a disagreement table that prints only active conflicts, such as duration bought while credit deteriorates, long-end supply stress, European sovereign divergence, copper rising while freight falls, or grains rising while livestock weakens. An empty table says the modules agree. A populated one outranks any quick summary of the verdict strip, since it names exactly where the evidence fights itself.

[b]Reading the Price Chart
[/b]
The chart above shows Palantir (PLTR) on the weekly clock, with "Socrates" in the lower pane. The stock has climbed from a 15.66 low to a 209.58 high and closed the week at 209.05, near that record. Every number in the pane, however, comes from bonds, currencies and commodities; none of it comes from Palantir.

The bond engine reads harshly. Rates, Global and FX Witness all read Strain, Duration reads Stress, and only Credit reads Stabilizing, with all three US yields rising, TLT, IEF and SHY all falling, and the dollar rising. The BondMap histogram sits at −2.00, the average of those five grades. The disagreement table names one conflict, European sovereign divergence, with French yields rising against German yields while the euro softens, and the Route column points to the FR10Y-DE10Y spread.

The commodity engine reads almost the opposite. Monetary reads Reflation and Softs reads Thaw, Energy reads Stable, Grains and Livestock read Cross-Pressure, and Industrial reads Shock, with most of the board falling. The header reads Quiet Tape, breadth 3 of 6 and intensity 62 percent, its lone disagreement is a local softs spike while metals fail, and the Bottleneck histogram sits at +0.24. A bond engine at −2.00 beside a commodity engine above zero places the week in the Financial Stress / Input Relief family: capital is getting more expensive while physical inputs are not adding to the pressure.

[b]Cyclical Context
[/b]
The Economic Confidence Model v3.14 is a supplementary instrument and runs in its own pane. The model never reads the chart symbol, so the same weekly reading sits beneath Palantir, Home Depot, Southwest Airlines, the dollar, gold, Treasuries or bitcoin, and the useful question becomes how each asset behaves under the same macro field. It can be read in companion mode beside a price chart, or in isolation mode as a macro chart in its own right.

The daily chart is the practical floor, the weekly chart is the model's natural home, and the monthly chart turns it into an archive of regimes. Below the daily clock its witnesses trade on different schedules, so a sub-daily read should be treated as provisional, suspect, or ruled out in the visibility defaults. A model-timeframe input lets the pane report weekly weather beneath a daily price chart, and a US-centric option shifts the bond engine's accent toward American rates and credit.

Feed counts sit in each table's footer, and a thin evidence set weakens the engine that lost it; the PLTR capture shows 20 of 20 bond feeds and 18 of 19 commodity feeds. The Data Window carries the state code, level, state age and checkpoint, and four sparse alerts cover compound stress, shared confidence, cross-pressure and π checkpoints. The model knows no news, forecasts no price and issues no trades. Nothing in this description or in the script is financial advice, and past behavior of the model does not predict future prices.

[b]Confidence Is Coordination, Not Health
[/b]
The PLTR capture holds two true statements in the same week. The stock is printing near its highest price on record, and the bond engine is reading Strain across rates, sovereigns and currencies. Neither cancels the other, and the model does not pretend to know which one will yield.

That coexistence is the point of measuring confidence as coordination. A rising price in a hostile field may be a haven, a squeeze, a late-cycle leader or crowded conviction, and only the trader's other tools can tell which. What the pane establishes is narrower and harder to ignore: the same weather falls on every roof, and a record high printed while the cost of capital rises is a different event from the same high printed under shared confidence, even when the candles look identical

## Source Code

````pine
//@version=6

// -----------------------------------------------------------------------------
// Economic Confidence Model v3.14
// Short title: "Socrates"
// Author variable: author = "The Leading Indicator"
//
// πECM fuses a full 20-feed Bond Pressure Matrix with a 19-feed Commodity
// Constraints representative engine, then adds a 13-state π regime layer. The 39 total request.security() contexts
// stay under TradingView's 40-context cap while preserving the diagnostic layout:
// Bond tables left, Commodity tables right, histogram field in the open center.
// -----------------------------------------------------------------------------

indicator("Economic Confidence Model v3.14", shorttitle = "Socrates", overlay = false, dynamic_requests = true)

string author = "The Leading Indicator"

// -- Inputs -------------------------------------------------------------------

grpE = "Engine"
mtf = input.timeframe("", "Model timeframe (blank = chart)", group = grpE)
rocLen = input.int(4, "Direction lookback", minval = 1, group = grpE)
maLen = input.int(13, "Trend MA length", minval = 2, group = grpE)
pctLen = input.int(52, "Commodity percentile window", minval = 10, group = grpE)
leanUS = input.bool(false, "Bond lean mode (US-centric)", group = grpE)

grpD = "Histogram Display"
showBondHist = input.bool(true, "Show BondMap histogram", group = grpD)
showCommHist = input.bool(true, "Show Bottleneck histogram", group = grpD)
bondTransp = input.int(62, "BondMap transparency", minval = 0, maxval = 100, group = grpD)
commTransp = input.int(54, "Bottleneck transparency", minval = 0, maxval = 100, group = grpD)
showBlend = input.bool(true, "Show ECM blend line", group = grpD)
blendTransp = input.int(67, "Blend transparency", minval = 0, maxval = 100, group = grpD)
showLevels = input.bool(true, "Show level guides", group = grpD)

grpR = "π Regime Layer"
showRegimeSquares = input.bool(true, "Show zero-line regime squares", group = grpR)
showPiCircles = input.bool(true, "Show π checkpoint circles", group = grpR)
showRegimeBg = input.bool(true, "Show regime background shading", group = grpR)
piStepBars = input.int(3, "π checkpoint step (bars)", minval = 1, maxval = 34, group = grpR, tooltip = "Default 3 approximates π in Pine's integer bar clock. Circles print at each completed checkpoint inside the active regime state.")
bgLevel1Op = input.int(8, "Background opacity L1", minval = 0, maxval = 100, group = grpR)
bgLevel2Op = input.int(18, "Background opacity L2", minval = 0, maxval = 100, group = grpR)
bgLevel3Op = input.int(30, "Background opacity L3", minval = 0, maxval = 100, group = grpR)
bgMixedOp = input.int(22, "Background opacity State 13", minval = 0, maxval = 100, group = grpR)

grpT = "Tables"
showBondMx = input.bool(true, "Show Bond Matrix", group = grpT)
showBondDis = input.bool(true, "Show Bond Disagreement", group = grpT)
showCommMx = input.bool(true, "Show Commodity Matrix", group = grpT)
showCommDis = input.bool(true, "Show Commodity Disagreement", group = grpT)
bondMxPosS = input.string("Top Left", "Bond Matrix Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpT)
bondDisPosS = input.string("Bottom Left", "Bond Disagreement Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpT)
commMxPosS = input.string("Top Right", "Commodity Matrix Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpT)
commDisPosS = input.string("Bottom Right", "Commodity Disagreement Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpT)
tableSizeInput = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpT)
tableBgInput = input.color(color.new(#2A2E39, 20), "Background", group = grpT)
tableLabelInput = input.color(#FAF3B2, "Label Color", group = grpT)
tableBorderCInput = input.color(color.new(#FAF3B2, 70), "Border Color", group = grpT)
tableBorderWInput = input.int(1, "Border Width", minval = 0, maxval = 5, group = grpT)
showFootnote = input.bool(true, "Show Settings Footnote", group = grpT)

grpB = "Bond Symbols"
sy02 = input.string("TVC:US02Y", "US 2Y", group = grpB)
sy10 = input.string("TVC:US10Y", "US 10Y", group = grpB)
sy30 = input.string("TVC:US30Y", "US 30Y", group = grpB)
sTLT = input.string("NASDAQ:TLT", "TLT", group = grpB)
sIEF = input.string("NASDAQ:IEF", "IEF", group = grpB)
sSHY = input.string("NASDAQ:SHY", "SHY", group = grpB)
sHYG = input.string("AMEX:HYG", "HYG", group = grpB)
sLQD = input.string("AMEX:LQD", "LQD", group = grpB)
sRatio = input.string("AMEX:HYG/AMEX:LQD", "HYG/LQD", group = grpB)
sDE = input.string("TVC:DE10Y", "DE10Y", group = grpB)
sFR = input.string("TVC:FR10Y", "FR10Y", group = grpB)
sGB = input.string("TVC:GB10Y", "GB10Y", group = grpB)
sJP = input.string("TVC:JP10Y", "JP10Y", group = grpB)
sCN = input.string("TVC:CN10Y", "CN10Y", group = grpB)
sBR = input.string("TVC:BR10Y", "BR10Y", group = grpB)
sZA = input.string("TVC:ZA10Y", "ZA10Y", group = grpB)
sDXY = input.string("TVC:DXY", "DXY", group = grpB)
sUJ = input.string("FX:USDJPY", "USDJPY", group = grpB)
sAJ = input.string("FX:AUDJPY", "AUDJPY", group = grpB)
sEU = input.string("FX:EURUSD", "EURUSD", group = grpB)

grpC = "Commodity Symbols (19-feed ECM set)"
sGC = input.string("COMEX:GC1!", "Gold futures", group = grpC)
sSI = input.string("COMEX:SI1!", "Silver futures", group = grpC)
sXAU = input.string("OANDA:XAUUSD", "Spot gold", group = grpC)
sHG = input.string("COMEX:HG1!", "Copper", group = grpC)
sPL = input.string("NYMEX:PL1!", "Platinum", group = grpC)
sTIO = input.string("TIO1!", "Iron ore", group = grpC)
sCL = input.string("NYMEX:CL1!", "WTI crude", group = grpC)
sNG = input.string("NYMEX:NG1!", "Natural gas", group = grpC)
sHO = input.string("NYMEX:HO1!", "Heating oil", group = grpC)
sBDI = input.string("TVC:BDI", "Baltic Dry Index", group = grpC)
sZC = input.string("CBOT:ZC1!", "Corn", group = grpC)
sZW = input.string("CBOT:ZW1!", "Wheat", group = grpC)
sZM = input.string("CBOT:ZM1!", "Soymeal", group = grpC)
sKC = input.string("ICEUS:KC1!", "Coffee", group = grpC)
sCC = input.string("ICEUS:CC1!", "Cocoa", group = grpC)
sLBR = input.string("CME:LBR1!", "Lumber", group = grpC)
sLE = input.string("CME:LE1!", "Live cattle", group = grpC)
sGF = input.string("CME:GF1!", "Feeder cattle", group = grpC)
sHE = input.string("CME:HE1!", "Lean hogs", group = grpC)

// -- Colors -------------------------------------------------------------------

color C_RED = #E5484D
color C_ORANGE = #FF8C42
color C_LEMON = color.rgb(250, 243, 178)
color C_SOFT_TEXT = #E6E6E6
color BOND_YELLOW = #FDE68A
color BOND_GREEN = #16C784
color BOND_BLUE = #38BDF8
color BOND_VIOLET = #6366F1
color COMM_YELLOW = #FFD84D
color COMM_GREEN = #4ADE80
color COMM_BLUE = #3B82F6
color COMM_VIOLET = #A78BFA

color REG_SHARED = #3B82F6 // shared confidence / coordinated conviction
color REG_COMPOUND = #FFB000 // compound stress / hazard-gold
color REG_FIN_STRESS = #00BCD4 // financial stress with input relief
color REG_INPUT_STRESS = #B87333 // input stress with financial relief
color REG_MIXED = #BA68C8 // State 13 anomaly / mixed tape

// -- Helpers ------------------------------------------------------------------

f_feed(string sym) => request.security(sym, mtf == "" ? timeframe.period : mtf, [close, close[rocLen], close > close[rocLen] ? 1.0 : close < close[rocLen] ? -1.0 : 0.0, close > ta.ema(close, maLen) ? 1.0 : -1.0, math.min(3.0, nz(ta.barssince(not (close > close[rocLen])), 3)), math.min(3.0, nz(ta.barssince(not (close < close[rocLen])), 3)), ta.percentrank(close, pctLen)], lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off, ignore_invalid_symbol = true)
f_wu(float dir, float upS) => nz(dir) > 0 ? (nz(upS) >= 1 ? 2 : 1) : 0
f_wd(float dir, float dnS) => nz(dir) < 0 ? (nz(dnS) >= 1 ? 2 : 1) : 0
f_word(float dir) => nz(dir) > 0 ? "rising" : nz(dir) < 0 ? "falling" : "flat"
f_dirW(float dir, float upS, float dnS) => nz(dir) > 0 ? (nz(upS) >= 1 ? 2.0 : 1.0) : nz(dir) < 0 ? (nz(dnS) >= 1 ? -2.0 : -1.0) : 0.0
f_vote(float dir, float ma, float upS, float dnS, float pol) => pol * (f_dirW(dir, upS, dnS) + nz(ma))
f_bondGrade(int net, bool conflict) => conflict and net > -3 and net < 3 ? -1 : net >= 6 ? 3 : net >= 3 ? 2 : net >= 1 ? 1 : net <= -6 ? -3 : net <= -3 ? -2 : -1
f_commGrade(float net, bool conflict, bool deepStress) => conflict and net > -1.5 and net < 1.5 ? -1 : net >= 2.2 ? (deepStress ? 2 : 3) : net >= 0.8 ? 2 : net > -0.8 ? 1 : net > -2.2 ? -2 : -3
f_zI(int g) => g == -1 ? 0 : g
f_zF(int g, float net) => g == -1 ? 0.0 : net
f_bondState(int g) => g == 3 ? "Expansion" : g == 2 ? "Relief" : g == 1 ? "Stabilizing" : g == -2 ? "Stress" : g == -3 ? "Strain" : "Conflict"
f_commState(int g) => g == 3 ? "Reflation" : g == 2 ? "Thaw" : g == 1 ? "Stable" : g == -2 ? "Stress" : g == -3 ? "Shock" : "Cross-Pressure"
f_bondCol(int g) => g == 3 ? BOND_VIOLET : g == 2 ? BOND_BLUE : g == 1 ? BOND_GREEN : g == -2 ? C_ORANGE : g == -3 ? C_RED : BOND_YELLOW
f_commCol(int g) => g == 3 ? COMM_VIOLET : g == 2 ? COMM_BLUE : g == 1 ? COMM_GREEN : g == -2 ? C_ORANGE : g == -3 ? C_RED : COMM_YELLOW
f_bondHist(float v) => na(v) ? color.new(C_SOFT_TEXT, 100) : v <= -2.0 ? C_RED : v <= -1.0 ? C_ORANGE : v < 0.25 ? BOND_YELLOW : v < 1.0 ? BOND_GREEN : v < 2.0 ? BOND_BLUE : BOND_VIOLET
f_commHist(float v) => na(v) ? color.new(C_SOFT_TEXT, 100) : v <= -2.0 ? C_RED : v <= -0.8 ? C_ORANGE : v < 0.25 ? COMM_YELLOW : v < 0.8 ? COMM_GREEN : v < 2.0 ? COMM_BLUE : COMM_VIOLET
f_pos(string s) => s == "Top Left" ? position.top_left : s == "Top Center" ? position.top_center : s == "Top Right" ? position.top_right : s == "Middle Left" ? position.middle_left : s == "Middle Center" ? position.middle_center : s == "Middle Right" ? position.middle_right : s == "Bottom Center" ? position.bottom_center : s == "Bottom Right" ? position.bottom_right : position.bottom_left
f_size(string s) => s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : s == "Huge" ? size.huge : size.small
string tblSize = f_size(tableSizeInput)
f_cell(table t, int c, int r, string txt, color tc, color bg = na) => table.cell(t, c, r, txt, text_color = tc, bgcolor = bg, text_size = tblSize, text_halign = text.align_left)
f_dirCol(float dir, bool risingIsStress) => na(dir) ? C_SOFT_TEXT : nz(dir) > 0 ? (risingIsStress ? C_ORANGE : COMM_GREEN) : nz(dir) < 0 ? (risingIsStress ? COMM_GREEN : C_RED) : C_SOFT_TEXT
f_level(float strength) => strength >= 2.0 ? 3 : strength >= 1.0 ? 2 : 1
f_finLevel(float stressVal, float reliefVal) => stressVal <= -2.0 and reliefVal >= 0.8 ? 3 : stressVal <= -2.0 or reliefVal >= 0.25 ? 2 : 1
f_inputLevel(float stressVal, float reliefVal) => stressVal <= -2.0 and reliefVal >= 1.0 ? 3 : stressVal <= -2.0 or reliefVal >= 0.25 ? 2 : 1
f_regimeColor(int state) => state <= 3 ? REG_SHARED : state <= 6 ? REG_COMPOUND : state <= 9 ? REG_FIN_STRESS : state <= 12 ? REG_INPUT_STRESS : REG_MIXED
f_regimeLevel(int state) => state == 13 ? 0 : ((state - 1) % 3) + 1
f_regimeBgOpacity(int state) => state == 13 ? bgMixedOp : f_regimeLevel(state) == 3 ? bgLevel3Op : f_regimeLevel(state) == 2 ? bgLevel2Op : bgLevel1Op
f_regimeName(int state) => state <= 3 ? "Shared Confidence" : state <= 6 ? "Compound Stress" : state <= 9 ? "Financial Stress / Input Relief" : state <= 12 ? "Input Stress / Financial Relief" : "Mixed Tape / Anomaly"

// -- Fetch: 39 contexts --------------------------------------------------------

[c02, p02, d02, m02, u02, n02, q02] = f_feed(sy02)
[c10, p10, d10, m10, u10, n10, q10] = f_feed(sy10)
[c30, p30, d30, m30, u30, n30, q30] = f_feed(sy30)
[cTLT, pTLT, dTLT, mTLT, uTLT, nTLT, qTLT] = f_feed(sTLT)
[cIEF, pIEF, dIEF, mIEF, uIEF, nIEF, qIEF] = f_feed(sIEF)
[cSHY, pSHY, dSHY, mSHY, uSHY, nSHY, qSHY] = f_feed(sSHY)
[cHYG, pHYG, dHYG, mHYG, uHYG, nHYG, qHYG] = f_feed(sHYG)
[cLQD, pLQD, dLQD, mLQD, uLQD, nLQD, qLQD] = f_feed(sLQD)
[cRAT, pRAT, dRAT, mRAT, uRAT, nRAT, qRAT] = f_feed(sRatio)
[cDE, pDE, dDE, mDE, uDE, nDE, qDE] = f_feed(sDE)
[cFR, pFR, dFR, mFR, uFR, nFR, qFR] = f_feed(sFR)
[cGB, pGB, dGB, mGB, uGB, nGB, qGB] = f_feed(sGB)
[cJP, pJP, dJP, mJP, uJP, nJP, qJP] = f_feed(sJP)
[cCN, pCN, dCN, mCN, uCN, nCN, qCN] = f_feed(sCN)
[cBR, pBR, dBR, mBR, uBR, nBR, qBR] = f_feed(sBR)
[cZA, pZA, dZA, mZA, uZA, nZA, qZA] = f_feed(sZA)
[cDX, pDX, dDX, mDX, uDX, nDX, qDX] = f_feed(sDXY)
[cUJ, pUJ, dUJ, mUJ, uUJ, nUJ, qUJ] = f_feed(sUJ)
[cAJ, pAJ, dAJ, mAJ, uAJ, nAJ, qAJ] = f_feed(sAJ)
[cEU, pEU, dEU, mEU, uEU, nEU, qEU] = f_feed(sEU)
[cGC, pGC, dGC, mGC, uGC, nGC, qGC] = f_feed(sGC)
[cSI, pSI, dSI, mSI, uSI, nSI, qSI] = f_feed(sSI)
[cXAU, pXAU, dXAU, mXAU, uXAU, nXAU, qXAU] = f_feed(sXAU)
[cHG, pHG, dHG, mHG, uHG, nHG, qHG] = f_feed(sHG)
[cPL, pPL, dPL, mPL, uPL, nPL, qPL] = f_feed(sPL)
[cTIO, pTIO, dTIO, mTIO, uTIO, nTIO, qTIO] = f_feed(sTIO)
[cCL, pCL, dCL, mCL, uCL, nCL, qCL] = f_feed(sCL)
[cNG, pNG, dNG, mNG, uNG, nNG, qNG] = f_feed(sNG)
[cHO, pHO, dHO, mHO, uHO, nHO, qHO] = f_feed(sHO)
[cBDI, pBDI, dBDI, mBDI, uBDI, nBDI, qBDI] = f_feed(sBDI)
[cZC, pZC, dZC, mZC, uZC, nZC, qZC] = f_feed(sZC)
[cZW, pZW, dZW, mZW, uZW, nZW, qZW] = f_feed(sZW)
[cZM, pZM, dZM, mZM, uZM, nZM, qZM] = f_feed(sZM)
[cKC, pKC, dKC, mKC, uKC, nKC, qKC] = f_feed(sKC)
[cCC, pCC, dCC, mCC, uCC, nCC, qCC] = f_feed(sCC)
[cLBR, pLBR, dLBR, mLBR, uLBR, nLBR, qLBR] = f_feed(sLBR)
[cLE, pLE, dLE, mLE, uLE, nLE, qLE] = f_feed(sLE)
[cGF, pGF, dGF, mGF, uGF, nGF, qGF] = f_feed(sGF)
[cHE, pHE, dHE, mHE, uHE, nHE, qHE] = f_feed(sHE)

int liveBond = (na(c02) ? 0 : 1) + (na(c10) ? 0 : 1) + (na(c30) ? 0 : 1) + (na(cTLT) ? 0 : 1) + (na(cIEF) ? 0 : 1) + (na(cSHY) ? 0 : 1) + (na(cHYG) ? 0 : 1) + (na(cLQD) ? 0 : 1) + (na(cRAT) ? 0 : 1) + (na(cDE) ? 0 : 1) + (na(cFR) ? 0 : 1) + (na(cGB) ? 0 : 1) + (na(cJP) ? 0 : 1) + (na(cCN) ? 0 : 1) + (na(cBR) ? 0 : 1) + (na(cZA) ? 0 : 1) + (na(cDX) ? 0 : 1) + (na(cUJ) ? 0 : 1) + (na(cAJ) ? 0 : 1) + (na(cEU) ? 0 : 1)
int liveComm = (na(cGC) ? 0 : 1) + (na(cSI) ? 0 : 1) + (na(cXAU) ? 0 : 1) + (na(cHG) ? 0 : 1) + (na(cPL) ? 0 : 1) + (na(cTIO) ? 0 : 1) + (na(cCL) ? 0 : 1) + (na(cNG) ? 0 : 1) + (na(cHO) ? 0 : 1) + (na(cBDI) ? 0 : 1) + (na(cZC) ? 0 : 1) + (na(cZW) ? 0 : 1) + (na(cZM) ? 0 : 1) + (na(cKC) ? 0 : 1) + (na(cCC) ? 0 : 1) + (na(cLBR) ? 0 : 1) + (na(cLE) ? 0 : 1) + (na(cGF) ? 0 : 1) + (na(cHE) ? 0 : 1)

// -- Bond engine ---------------------------------------------------------------

bool longFaster = not na(c30) and not na(c10) and nz(d30) > 0 and (c30 - p30) > (c10 - p10)
int ratesNet = f_wd(d02, n02) + f_wd(d10, n10) + f_wd(d30, n30) - f_wu(d02, u02) - f_wu(d10, u10) - f_wu(d30, u30) - (longFaster ? 1 : 0)
bool ratesConf = (f_wd(d02, n02) > 0 and f_wu(d30, u30) > 0) or (f_wu(d02, u02) > 0 and f_wd(d30, n30) > 0)
int gRates = f_bondGrade(ratesNet, ratesConf)
bool rejection = nz(dSHY) > 0 and nz(dTLT) < 0
int durNet = f_wu(dTLT, uTLT) - f_wd(dTLT, nTLT) + f_wu(dIEF, uIEF) - f_wd(dIEF, nIEF) + (nz(mTLT) > 0 ? 1 : -1) - (rejection ? 2 : 0)
bool durConf = (nz(dTLT) > 0 and nz(dIEF) < 0) or (nz(dTLT) < 0 and nz(dIEF) > 0)
int gDur = f_bondGrade(durNet, durConf)
int credNet = 2 * (f_wu(dRAT, uRAT) - f_wd(dRAT, nRAT)) + f_wu(dHYG, uHYG) - f_wd(dHYG, nHYG) + (nz(mHYG) > 0 ? 1 : -1)
bool credConf = (nz(dHYG) >= 0 and f_wd(dRAT, nRAT) > 0) or (nz(dHYG) < 0 and nz(dLQD) > 0)
int gCred = f_bondGrade(credNet, credConf)
int coreUpW = f_wu(dDE, uDE) + f_wu(dFR, uFR) + (leanUS ? 0 : f_wu(dGB, uGB)) + f_wu(dJP, uJP) + (leanUS ? 0 : f_wu(dCN, uCN))
int coreDnW = f_wd(dDE, nDE) + f_wd(dFR, nFR) + (leanUS ? 0 : f_wd(dGB, nGB)) + f_wd(dJP, nJP) + (leanUS ? 0 : f_wd(dCN, nCN))
int emUpW = leanUS ? 0 : f_wu(dBR, uBR) + f_wu(dZA, uZA)
int emDnW = leanUS ? 0 : f_wd(dBR, nBR) + f_wd(dZA, nZA)
bool contagion = emUpW >= 3 and coreUpW == 0
int globNet = coreDnW + emDnW - coreUpW - emUpW - (contagion ? 2 : 0)
bool globConf = coreUpW > 0 and coreDnW > 0
int gGlob = f_bondGrade(globNet, globConf)
bool funding = f_wd(dUJ, nUJ) >= 2 and f_wd(dAJ, nAJ) >= 1
int fxNet = f_wd(dDX, nDX) - f_wu(dDX, uDX) + f_wu(dAJ, uAJ) - f_wd(dAJ, nAJ) + (leanUS ? 0 : f_wu(dEU, uEU) - f_wd(dEU, nEU)) - (funding ? 2 : 0)
bool fxConf = f_wu(dAJ, uAJ) > 0 and f_wu(dDX, uDX) > 0
int gFX = f_bondGrade(fxNet, fxConf)
float bondComp = (f_zI(gRates) + f_zI(gDur) + f_zI(gCred) + f_zI(gGlob) + f_zI(gFX)) / 5.0
bool disCredDur = nz(dTLT) > 0 and f_wd(dRAT, nRAT) > 0
bool disReflate = nz(d10) > 0 and nz(dHYG) > 0
bool disSupply = longFaster and nz(dTLT) < 0
bool disEurope = nz(dFR) > 0 and nz(dDE) <= 0 and nz(dEU) < 0
bool disJapan = nz(dJP) > 0 and nz(dUJ) < 0
bool disEMFund = (f_wu(dBR, uBR) + f_wu(dZA, uZA)) >= 3 and nz(dDX) > 0
string route = gCred <= -2 ? "HYG/LQD" : disSupply ? "US30Y-US02Y" : ratesConf ? "US10Y-US02Y" : disEurope ? "FR10Y-DE10Y" : disJapan ? "JP10Y-US10Y" : disEMFund ? "BR10Y-US10Y" : gGlob <= -2 ? "DE10Y-US10Y" : "-"
// The spread lens reads the routed yield pair, or the US 10Y-2Y curve when the
// route is a credit ratio or no inspection is urged. It reports the spread in
// percentage points, whether it sits above or below zero, and whether it has
// widened or narrowed across the direction lookback. US curves read as normal or
// inverted and steepening or flattening; cross-country pairs read as positive or
// negative and rising or falling.
string lensPair = route == "US30Y-US02Y" or route == "FR10Y-DE10Y" or route == "JP10Y-US10Y" or route == "BR10Y-US10Y" or route == "DE10Y-US10Y" ? route : "US10Y-US02Y"
float lensLong = lensPair == "US30Y-US02Y" ? c30 : lensPair == "FR10Y-DE10Y" ? cFR : lensPair == "JP10Y-US10Y" ? cJP : lensPair == "BR10Y-US10Y" ? cBR : lensPair == "DE10Y-US10Y" ? cDE : c10
float lensShort = lensPair == "FR10Y-DE10Y" ? cDE : lensPair == "JP10Y-US10Y" or lensPair == "BR10Y-US10Y" or lensPair == "DE10Y-US10Y" ? c10 : c02
float lensLongPrior = lensPair == "US30Y-US02Y" ? p30 : lensPair == "FR10Y-DE10Y" ? pFR : lensPair == "JP10Y-US10Y" ? pJP : lensPair == "BR10Y-US10Y" ? pBR : lensPair == "DE10Y-US10Y" ? pDE : p10
float lensShortPrior = lensPair == "FR10Y-DE10Y" ? pDE : lensPair == "JP10Y-US10Y" or lensPair == "BR10Y-US10Y" or lensPair == "DE10Y-US10Y" ? p10 : p02
float lensSpread = lensLong - lensShort
float lensChange = lensSpread - (lensLongPrior - lensShortPrior)
bool lensBelow = lensSpread < 0
bool lensWidening = lensChange > 0
string lensValue = na(lensSpread) ? lensPair + " --" : lensPair + " " + (lensSpread >= 0 ? "+" : "") + str.tostring(lensSpread, "0.00") + "%"
bool lensCurve = lensPair == "US10Y-US02Y" or lensPair == "US30Y-US02Y"
string lensRegime = na(lensSpread) or na(lensChange) ? "Spread unavailable" : lensCurve ? (lensBelow ? "Inverted" : "Normal") + " · " + (lensWidening ? "steepening" : "flattening") : (lensBelow ? "Negative" : "Positive") + " · " + (lensWidening ? "rising" : "falling")
color lensColor = na(lensSpread) or na(lensChange) ? C_SOFT_TEXT : not lensBelow and lensWidening ? BOND_GREEN : not lensBelow ? BOND_BLUE : lensWidening ? C_ORANGE : C_RED
string routeWhy = gCred <= -2 ? "Credit damage" : disSupply ? "Long-end supply" : ratesConf ? "Policy-lag conflict" : disEurope ? "European divergence" : disJapan ? "BoJ/Fed divergence" : disEMFund ? "EM funding stress" : gGlob <= -2 ? "Global transmission" : "No inspection urged"

// -- Commodity engine ----------------------------------------------------------

float v1a = f_vote(dGC, mGC, uGC, nGC, -1.0)
float v1b = f_vote(dSI, mSI, uSI, nSI, -1.0)
float v1c = f_vote(dXAU, mXAU, uXAU, nXAU, -1.0)
bool havenScarcity = nz(dXAU) > 0 and nz(dDX) > 0
float netMon = (v1a + v1b + v1c) / 3.0 - (havenScarcity ? 0.5 : 0.0)
float rawMon = (f_dirW(dGC, uGC, nGC) + f_dirW(dSI, uSI, nSI) + f_dirW(dXAU, uXAU, nXAU)) / 3.0
bool confMon = (v1a >= 2 or v1b >= 2 or v1c >= 2) and (v1a <= -2 or v1b <= -2 or v1c <= -2)
int gMon = f_commGrade(netMon, confMon, v1a <= -2 or v1b <= -2 or v1c <= -2)

float v2a = f_vote(dHG, mHG, uHG, nHG, 1.0)
float v2b = f_vote(dPL, mPL, uPL, nPL, 1.0)
float v2c = f_vote(dTIO, mTIO, uTIO, nTIO, 1.0)
float netInd = (v2a + v2b + v2c) / 3.0
float rawInd = (f_dirW(dHG, uHG, nHG) + f_dirW(dPL, uPL, nPL) + f_dirW(dTIO, uTIO, nTIO)) / 3.0
bool confInd = (v2a >= 2 or v2b >= 2 or v2c >= 2) and (v2a <= -2 or v2b <= -2 or v2c <= -2)
int gInd = f_commGrade(netInd, confInd, v2a <= -2 or v2b <= -2 or v2c <= -2)

float v3a = f_vote(dCL, mCL, uCL, nCL, -1.0)
float v3b = f_vote(dNG, mNG, uNG, nNG, -1.0)
float v3c = f_vote(dHO, mHO, uHO, nHO, -1.0)
float v3d = f_vote(dBDI, mBDI, uBDI, nBDI, -1.0)
float netEn = (v3a + v3b + v3c + v3d) / 4.0
float rawEn = (f_dirW(dCL, uCL, nCL) + f_dirW(dNG, uNG, nNG) + f_dirW(dHO, uHO, nHO) + f_dirW(dBDI, uBDI, nBDI)) / 4.0
bool confEn = (v3a >= 2 or v3b >= 2 or v3c >= 2 or v3d >= 2) and (v3a <= -2 or v3b <= -2 or v3c <= -2 or v3d <= -2)
int gEn = f_commGrade(netEn, confEn, v3a <= -2 or v3b <= -2 or v3c <= -2 or v3d <= -2)

float v4a = f_vote(dZC, mZC, uZC, nZC, -1.0)
float v4b = f_vote(dZW, mZW, uZW, nZW, -1.0)
float v4c = f_vote(dZM, mZM, uZM, nZM, -1.0)
float netGr = (v4a + v4b + v4c) / 3.0
float rawGr = (f_dirW(dZC, uZC, nZC) + f_dirW(dZW, uZW, nZW) + f_dirW(dZM, uZM, nZM)) / 3.0
bool confGr = (v4a >= 2 or v4b >= 2 or v4c >= 2) and (v4a <= -2 or v4b <= -2 or v4c <= -2)
int gGr = f_commGrade(netGr, confGr, v4a <= -2 or v4b <= -2 or v4c <= -2)

float v5a = f_vote(dKC, mKC, uKC, nKC, -1.0)
float v5b = f_vote(dCC, mCC, uCC, nCC, -1.0)
float v5c = f_vote(dLBR, mLBR, uLBR, nLBR, -1.0)
float netSf = (v5a + v5b + v5c) / 3.0
float rawSf = (f_dirW(dKC, uKC, nKC) + f_dirW(dCC, uCC, nCC) + f_dirW(dLBR, uLBR, nLBR)) / 3.0
bool confSf = (v5a >= 2 or v5b >= 2 or v5c >= 2) and (v5a <= -2 or v5b <= -2 or v5c <= -2)
int gSf = f_commGrade(netSf, confSf, v5a <= -2 or v5b <= -2 or v5c <= -2)

float v6a = f_vote(dLE, mLE, uLE, nLE, -1.0)
float v6b = f_vote(dGF, mGF, uGF, nGF, -1.0)
float v6c = f_vote(dHE, mHE, uHE, nHE, -1.0)
float netLv = (v6a + v6b + v6c) / 3.0
float rawLv = (f_dirW(dLE, uLE, nLE) + f_dirW(dGF, uGF, nGF) + f_dirW(dHE, uHE, nHE)) / 3.0
bool confLv = (v6a >= 2 or v6b >= 2 or v6c >= 2) and (v6a <= -2 or v6b <= -2 or v6c <= -2)
int gLv = f_commGrade(netLv, confLv, v6a <= -2 or v6b <= -2 or v6c <= -2)

bool indUp = rawInd >= 0.5
bool enUp = rawEn >= 0.5
bool grUp = rawGr >= 0.5
bool sfUp = rawSf >= 0.5
bool lvDn = rawLv <= -0.5
bool monUp = rawMon >= 0.5
bool frUp = nz(dBDI) > 0
bool fuelFlat = nz(dCL) <= 0 and nz(dNG) <= 0
bool quietAll = math.abs(rawMon) < 0.5 and math.abs(rawInd) < 0.5 and math.abs(rawEn) < 0.5 and math.abs(rawGr) < 0.5 and math.abs(rawSf) < 0.5 and math.abs(rawLv) < 0.5
bool loneSpike = math.abs(v1a) >= 3 or math.abs(v2a) >= 3 or math.abs(v3a) >= 3 or math.abs(v4b) >= 3 or math.abs(v5b) >= 3 or math.abs(v6a) >= 3
string wave = enUp and (grUp or sfUp) and not indUp ? "Supply-Led" : (enUp or grUp) and lvDn ? "Margin Compression" : indUp and enUp and frUp ? "Demand-Led" : monUp and not indUp ? (havenScarcity ? "Haven Scarcity" : "Currency-Led") : frUp and indUp ? "Freight-Led" : (grUp or sfUp) and not indUp and not enUp ? "Weather-Led" : quietAll and loneSpike ? "Synthetic Calm" : "Quiet Tape"
float boardNet = netMon + netInd + netEn + netGr + netSf + netLv
int breadth = 0
breadth += math.abs(netMon) >= 0.8 and math.sign(netMon) == math.sign(boardNet) ? 1 : 0
breadth += math.abs(netInd) >= 0.8 and math.sign(netInd) == math.sign(boardNet) ? 1 : 0
breadth += math.abs(netEn) >= 0.8 and math.sign(netEn) == math.sign(boardNet) ? 1 : 0
breadth += math.abs(netGr) >= 0.8 and math.sign(netGr) == math.sign(boardNet) ? 1 : 0
breadth += math.abs(netSf) >= 0.8 and math.sign(netSf) == math.sign(boardNet) ? 1 : 0
breadth += math.abs(netLv) >= 0.8 and math.sign(netLv) == math.sign(boardNet) ? 1 : 0
float inten = (math.abs(nz(qGC) - 50) + math.abs(nz(qSI) - 50) + math.abs(nz(qXAU) - 50) + math.abs(nz(qHG) - 50) + math.abs(nz(qPL) - 50) + math.abs(nz(qTIO) - 50) + math.abs(nz(qCL) - 50) + math.abs(nz(qNG) - 50) + math.abs(nz(qHO) - 50) + math.abs(nz(qBDI) - 50) + math.abs(nz(qZC) - 50) + math.abs(nz(qZW) - 50) + math.abs(nz(qZM) - 50) + math.abs(nz(qKC) - 50) + math.abs(nz(qCC) - 50) + math.abs(nz(qLBR) - 50) + math.abs(nz(qLE) - 50) + math.abs(nz(qGF) - 50) + math.abs(nz(qHE) - 50)) / 19.0 * 2.0
var int persBars = 0
persBars := wave == wave[1] ? persBars + 1 : 1
string modelTf = mtf == "" ? timeframe.period : mtf
int modelSec = timeframe.in_seconds(modelTf)
string persUnit = modelSec == timeframe.in_seconds("1D") ? "D" : modelSec == timeframe.in_seconds("1W") ? "W" : modelSec == timeframe.in_seconds("1M") ? "M" : " bars"
bool fx1 = nz(dHG) > 0 and nz(dBDI) < 0
bool fx2 = enUp and not indUp and not frUp
bool fx3 = havenScarcity
bool fx4 = grUp and lvDn
bool fx5 = nz(dKC) > 0 and nz(dHG) <= 0
int fractures = (fx1 ? 1 : 0) + (fx2 ? 1 : 0) + (fx3 ? 1 : 0) + (fx4 ? 1 : 0) + (fx5 ? 1 : 0)
float commComp = (f_zF(gMon, netMon) + f_zF(gInd, netInd) + f_zF(gEn, netEn) + f_zF(gGr, netGr) + f_zF(gSf, netSf) + f_zF(gLv, netLv)) / 6.0

// -- Histograms and π regime layer --------------------------------------------

float ecmBlend = (bondComp + commComp) / 2.0

bool sharedConfidence = bondComp >= 0.25 and commComp >= 0.25
bool compoundStress = bondComp <= -1.0 and commComp <= -0.8
bool financialStressInputRelief = bondComp <= -1.0 and commComp > -0.8
bool inputStressFinancialRelief = commComp <= -0.8 and bondComp > -1.0
int sharedLevel = f_level(math.min(bondComp, commComp))
int compoundLevel = f_level(math.min(math.abs(bondComp), math.abs(commComp)))
int financialLevel = f_finLevel(bondComp, commComp)
int inputLevel = f_inputLevel(commComp, bondComp)
int ecmState = sharedConfidence ? sharedLevel : compoundStress ? 3 + compoundLevel : financialStressInputRelief ? 6 + financialLevel : inputStressFinancialRelief ? 9 + inputLevel : 13
int ecmLevel = f_regimeLevel(ecmState)
color ecmRegimeColor = f_regimeColor(ecmState)

var int ecmStateAge = 0
ecmStateAge := ecmState == ecmState[1] ? ecmStateAge + 1 : 1
bool piCheckpoint = ecmStateAge >= piStepBars and ecmStateAge % piStepBars == 0

bgcolor(showRegimeBg ? color.new(ecmRegimeColor, 100 - f_regimeBgOpacity(ecmState)) : na, title = "πECM Regime Background")
plotshape(showRegimeSquares ? 0.0 : na, "πECM Regime Square", style = shape.square, location = location.absolute, color = ecmRegimeColor, size = size.tiny)
plot(showPiCircles and piCheckpoint ? 0.0 : na, "πECM π Checkpoint", style = plot.style_circles, linewidth = 4, color = ecmRegimeColor)

hline(0, "Neutral", color = showLevels ? color.new(color.gray, 40) : color.new(color.gray, 100))
hline(3, "+3", color = showLevels ? color.new(color.gray, 82) : color.new(color.gray, 100), linestyle = hline.style_dotted)
hline(-3, "-3", color = showLevels ? color.new(color.gray, 82) : color.new(color.gray, 100), linestyle = hline.style_dotted)
plot(showBondHist ? bondComp : na, "BondMap", style = plot.style_columns, histbase = 0, color = color.new(f_bondHist(bondComp), bondTransp))
plot(showCommHist ? commComp : na, "Bottleneck", style = plot.style_columns, histbase = 0, color = color.new(f_commHist(commComp), commTransp))
plot(showBlend ? ecmBlend : na, "ECM Blend", color = color.new(C_LEMON, blendTransp), linewidth = 2, style = plot.style_stepline)

// -- Tables -------------------------------------------------------------------

var table bmx = table.new(f_pos(bondMxPosS), 6, 6, bgcolor = tableBgInput, frame_color = tableBorderCInput, frame_width = tableBorderWInput, border_color = tableBorderCInput, border_width = tableBorderWInput)
if showBondMx and barstate.islast
    table.clear(bmx, 0, 0, 5, 5)
    string[] heads = array.from("Rates", "Duration", "Credit", "Global", "FX Witness", "Route")
    for i = 0 to 5
        f_cell(bmx, i, 0, array.get(heads, i), tableLabelInput)
    int[] bg = array.from(gRates, gDur, gCred, gGlob, gFX)
    for i = 0 to 4
        int g = array.get(bg, i)
        f_cell(bmx, i, 1, f_bondState(g), color.black, f_bondCol(g))
    f_cell(bmx, 5, 1, route, tableLabelInput, color.new(color.gray, 60))
    f_cell(bmx, 0, 2, "US02Y " + f_word(d02), f_dirCol(d02, true))
    f_cell(bmx, 0, 3, "US10Y " + f_word(d10), f_dirCol(d10, true))
    f_cell(bmx, 0, 4, longFaster ? "US30Y faster" : "US30Y " + f_word(d30), longFaster ? C_ORANGE : f_dirCol(d30, true))
    f_cell(bmx, 1, 2, "TLT " + f_word(dTLT), f_dirCol(dTLT, false))
    f_cell(bmx, 1, 3, "IEF " + f_word(dIEF), f_dirCol(dIEF, false))
    f_cell(bmx, 1, 4, rejection ? "SHY sheltering" : "SHY " + f_word(dSHY), rejection ? BOND_YELLOW : f_dirCol(dSHY, false))
    f_cell(bmx, 2, 2, "HYG " + f_word(dHYG), f_dirCol(dHYG, false))
    f_cell(bmx, 2, 3, "LQD " + f_word(dLQD), f_dirCol(dLQD, false))
    f_cell(bmx, 2, 4, "HYG/LQD " + f_word(dRAT), f_dirCol(dRAT, false))
    f_cell(bmx, 3, 2, "Core " + (coreUpW > coreDnW ? "rising" : coreDnW > coreUpW ? "falling" : "split"), coreUpW > coreDnW ? C_ORANGE : coreDnW > coreUpW ? COMM_GREEN : BOND_YELLOW)
    f_cell(bmx, 3, 3, "EM " + (emUpW > emDnW ? "rising" : emDnW > emUpW ? "falling" : "flat"), emUpW > emDnW ? C_ORANGE : emDnW > emUpW ? COMM_GREEN : C_SOFT_TEXT)
    f_cell(bmx, 3, 4, contagion ? "Contagion tilt" : globConf ? "Regional split" : "Aligned", contagion ? C_RED : globConf ? BOND_YELLOW : COMM_GREEN)
    f_cell(bmx, 4, 2, "DXY " + f_word(dDX), f_dirCol(dDX, true))
    f_cell(bmx, 4, 3, "AUDJPY " + f_word(dAJ), f_dirCol(dAJ, false))
    f_cell(bmx, 4, 4, funding ? "Yen funding strain" : "USDJPY " + f_word(dUJ), funding ? C_ORANGE : f_dirCol(dUJ, false))
    f_cell(bmx, 5, 2, routeWhy, routeWhy == "No inspection urged" ? C_SOFT_TEXT : BOND_YELLOW)
    f_cell(bmx, 5, 3, lensValue, C_SOFT_TEXT)
    f_cell(bmx, 5, 4, lensRegime, lensColor)
    f_cell(bmx, 0, 5, "Feeds " + str.tostring(liveBond) + "/20", liveBond < 16 ? C_ORANGE : C_SOFT_TEXT)
    f_cell(bmx, 1, 5, "TF " + (mtf == "" ? timeframe.period : mtf), C_SOFT_TEXT)
    f_cell(bmx, 2, 5, leanUS ? "Lean (US)" : "Global", leanUS ? BOND_YELLOW : C_SOFT_TEXT)
    f_cell(bmx, 3, 5, showFootnote ? "ROC " + str.tostring(rocLen) : "", C_SOFT_TEXT)
    f_cell(bmx, 4, 5, showFootnote ? "MA " + str.tostring(maLen) : "", C_SOFT_TEXT)
    f_cell(bmx, 5, 5, showFootnote ? "πECM" : "", tableLabelInput)

var table bdis = table.new(f_pos(bondDisPosS), 4, 7, bgcolor = tableBgInput, frame_color = tableBorderCInput, frame_width = tableBorderWInput, border_color = tableBorderCInput, border_width = tableBorderWInput)
if showBondDis and barstate.islast
    table.clear(bdis, 0, 0, 3, 6)
    f_cell(bdis, 0, 0, "Disagreement", tableLabelInput)
    f_cell(bdis, 1, 0, "Evidence", tableLabelInput)
    f_cell(bdis, 2, 0, "Read", tableLabelInput)
    f_cell(bdis, 3, 0, "Route", tableLabelInput)
    int r = 1
    if disCredDur
        f_cell(bdis, 0, r, "Duration bid, credit damage", color.white)
        f_cell(bdis, 1, r, "TLT up, HYG/LQD down", color.white)
        f_cell(bdis, 2, r, "Defensive demand, not easing", BOND_YELLOW)
        f_cell(bdis, 3, r, "HYG/LQD", color.white)
        r += 1
    if disReflate
        f_cell(bdis, 0, r, "Reflation or rate shock", color.white)
        f_cell(bdis, 1, r, "US10Y up, HYG up", color.white)
        f_cell(bdis, 2, r, "Risk accepts higher yields", BOND_YELLOW)
        f_cell(bdis, 3, r, "US10Y-US02Y", color.white)
        r += 1
    if disSupply
        f_cell(bdis, 0, r, "Long-end supply stress", color.white)
        f_cell(bdis, 1, r, "US30Y faster, TLT weak", color.white)
        f_cell(bdis, 2, r, "Term premium may dominate", BOND_YELLOW)
        f_cell(bdis, 3, r, "US30Y-US02Y", color.white)
        r += 1
    if disEurope
        f_cell(bdis, 0, r, "European sovereign divergence", color.white)
        f_cell(bdis, 1, r, "FR10Y up vs DE10Y, EURUSD soft", color.white)
        f_cell(bdis, 2, r, "Political/credit stress surfacing", BOND_YELLOW)
        f_cell(bdis, 3, r, "FR10Y-DE10Y", color.white)
        r += 1
    if disJapan
        f_cell(bdis, 0, r, "Japan policy divergence", color.white)
        f_cell(bdis, 1, r, "JP10Y up, yen confirming", color.white)
        f_cell(bdis, 2, r, "BoJ/Fed spread logic shifting", BOND_YELLOW)
        f_cell(bdis, 3, r, "JP10Y-US10Y", color.white)
        r += 1
    if disEMFund
        f_cell(bdis, 0, r, "EM funding stress", color.white)
        f_cell(bdis, 1, r, "DXY up, BR/ZA yields up", color.white)
        f_cell(bdis, 2, r, "Dollar leaking into sovereigns", BOND_YELLOW)
        f_cell(bdis, 3, r, "BR10Y-US10Y", color.white)
        r += 1
    if r == 1
        f_cell(bdis, 0, r, "No meaningful conflicts", C_SOFT_TEXT)
        f_cell(bdis, 1, r, "-", C_SOFT_TEXT)
        f_cell(bdis, 2, r, "Modules agree; trust the strip", C_SOFT_TEXT)
        f_cell(bdis, 3, r, "-", C_SOFT_TEXT)

var table cmx = table.new(f_pos(commMxPosS), 7, 7, bgcolor = tableBgInput, frame_color = tableBorderCInput, frame_width = tableBorderWInput, border_color = tableBorderCInput, border_width = tableBorderWInput)
if showCommMx and barstate.islast
    table.clear(cmx, 0, 0, 6, 6)
    f_cell(cmx, 0, 0, "Wave", tableLabelInput)
    f_cell(cmx, 1, 0, wave, color.white, color.new(f_commHist(commComp), 70))
    f_cell(cmx, 2, 0, "Breadth " + str.tostring(breadth) + "/6", breadth >= 4 ? COMM_GREEN : breadth <= 1 ? C_SOFT_TEXT : tableLabelInput)
    f_cell(cmx, 3, 0, "Intensity " + str.tostring(math.round(inten)) + "%", inten >= 70 ? C_ORANGE : tableLabelInput)
    f_cell(cmx, 4, 0, "Persist " + str.tostring(persBars) + persUnit, persBars >= 3 ? COMM_YELLOW : tableLabelInput)
    f_cell(cmx, 5, 0, "Fractures " + str.tostring(fractures), fractures >= 3 ? COMM_YELLOW : tableLabelInput)
    f_cell(cmx, 6, 0, "ECM v3.14", C_SOFT_TEXT)
    string[] ch = array.from("", "Monetary", "Industrial", "Energy", "Grains", "Softs", "Livestock")
    for i = 0 to 6
        f_cell(cmx, i, 1, array.get(ch, i), tableLabelInput)
    f_cell(cmx, 0, 2, "Verdict", C_SOFT_TEXT)
    int[] cg = array.from(gMon, gInd, gEn, gGr, gSf, gLv)
    for i = 0 to 5
        int g = array.get(cg, i)
        f_cell(cmx, i + 1, 2, f_commState(g), color.black, f_commCol(g))
    f_cell(cmx, 0, 3, "Evidence 1", C_SOFT_TEXT)
    f_cell(cmx, 0, 4, "Evidence 2", C_SOFT_TEXT)
    f_cell(cmx, 0, 5, "Evidence 3", C_SOFT_TEXT)
    f_cell(cmx, 1, 3, "GC " + f_word(dGC), f_dirCol(dGC, true))
    f_cell(cmx, 1, 4, havenScarcity ? "XAU up w/ DXY" : "XAU " + f_word(dXAU), havenScarcity ? COMM_YELLOW : f_dirCol(dXAU, true))
    f_cell(cmx, 1, 5, "SI " + f_word(dSI), f_dirCol(dSI, false))
    f_cell(cmx, 2, 3, "HG " + f_word(dHG), f_dirCol(dHG, false))
    f_cell(cmx, 2, 4, "TIO* " + f_word(dTIO), f_dirCol(dTIO, false))
    f_cell(cmx, 2, 5, "PL " + f_word(dPL), f_dirCol(dPL, false))
    f_cell(cmx, 3, 3, "CL " + f_word(dCL), f_dirCol(dCL, true))
    f_cell(cmx, 3, 4, "HO " + f_word(dHO), f_dirCol(dHO, true))
    f_cell(cmx, 3, 5, "BDI* " + f_word(dBDI), nz(dBDI) < 0 and enUp ? COMM_YELLOW : f_dirCol(dBDI, false))
    f_cell(cmx, 4, 3, "ZW " + f_word(dZW), f_dirCol(dZW, true))
    f_cell(cmx, 4, 4, "ZC " + f_word(dZC), f_dirCol(dZC, true))
    f_cell(cmx, 4, 5, "ZM " + f_word(dZM), f_dirCol(dZM, true))
    f_cell(cmx, 5, 3, "KC " + f_word(dKC), f_dirCol(dKC, true))
    f_cell(cmx, 5, 4, "CC " + f_word(dCC), f_dirCol(dCC, true))
    f_cell(cmx, 5, 5, "LBR " + f_word(dLBR), f_dirCol(dLBR, false))
    f_cell(cmx, 6, 3, "LE " + f_word(dLE), f_dirCol(dLE, true))
    f_cell(cmx, 6, 4, "GF " + f_word(dGF), f_dirCol(dGF, true))
    f_cell(cmx, 6, 5, fx4 ? "Feed>margin damage" : "HE " + f_word(dHE), fx4 ? COMM_YELLOW : f_dirCol(dHE, true))
    f_cell(cmx, 0, 6, "Feeds " + str.tostring(liveComm) + "/19", liveComm < 15 ? C_ORANGE : C_SOFT_TEXT)
    f_cell(cmx, 1, 6, "TF " + (mtf == "" ? timeframe.period : mtf), C_SOFT_TEXT)
    f_cell(cmx, 2, 6, showFootnote ? "ROC " + str.tostring(rocLen) : "", C_SOFT_TEXT)
    f_cell(cmx, 3, 6, showFootnote ? "MA " + str.tostring(maLen) : "", C_SOFT_TEXT)
    f_cell(cmx, 4, 6, showFootnote ? "Pct " + str.tostring(pctLen) : "", C_SOFT_TEXT)
    f_cell(cmx, 5, 6, showFootnote ? "πECM 19/32 set" : "", C_SOFT_TEXT)
    f_cell(cmx, 6, 6, showFootnote ? "Scarcity" : "", tableLabelInput)

var table cdis = table.new(f_pos(commDisPosS), 3, 7, bgcolor = tableBgInput, frame_color = tableBorderCInput, frame_width = tableBorderWInput, border_color = tableBorderCInput, border_width = tableBorderWInput)
if showCommDis and barstate.islast
    table.clear(cdis, 0, 0, 2, 6)
    f_cell(cdis, 0, 0, "Disagreement", tableLabelInput)
    f_cell(cdis, 1, 0, "Evidence", tableLabelInput)
    f_cell(cdis, 2, 0, "Read", tableLabelInput)
    int r = 1
    if fx1
        f_cell(cdis, 0, r, "Copper up, shipping down", color.white)
        f_cell(cdis, 1, r, "HG up, BDI* down", color.white)
        f_cell(cdis, 2, r, "Optimism lacks freight proof", COMM_YELLOW)
        r += 1
    if fx2
        f_cell(cdis, 0, r, "Energy up, cycle unconfirmed", color.white)
        f_cell(cdis, 1, r, "Fuel up, metals/freight flat", color.white)
        f_cell(cdis, 2, r, "Energy acting as a tax", COMM_YELLOW)
        r += 1
    if fx3
        f_cell(cdis, 0, r, "Gold up, dollar up", color.white)
        f_cell(cdis, 1, r, "XAU and DXY rising together", color.white)
        f_cell(cdis, 2, r, "Haven demand over inflation", COMM_YELLOW)
        r += 1
    if fx4
        f_cell(cdis, 0, r, "Grains up, livestock down", color.white)
        f_cell(cdis, 1, r, "Feed up, LE/GF weak", color.white)
        f_cell(cdis, 2, r, "Producer margins under damage", COMM_YELLOW)
        r += 1
    if fx5
        f_cell(cdis, 0, r, "Softs spike, metals flat", color.white)
        f_cell(cdis, 1, r, "KC/CC up, HG fails", color.white)
        f_cell(cdis, 2, r, "Crop stress local", COMM_YELLOW)
        r += 1
    if r == 1
        f_cell(cdis, 0, r, "No meaningful conflicts", C_SOFT_TEXT)
        f_cell(cdis, 1, r, "-", C_SOFT_TEXT)
        f_cell(cdis, 2, r, "Board internally coherent", C_SOFT_TEXT)

// -- Data Window and Alerts ----------------------------------------------------

plot(ecmState, "πECM State Code", format = format.price, precision = 0, display = display.data_window)
plot(ecmLevel, "πECM Level (0 for State 13)", format = format.price, precision = 0, display = display.data_window)
plot(ecmStateAge, "πECM State Age", format = format.price, precision = 0, display = display.data_window)
plot(piCheckpoint ? 1 : 0, "πECM π Checkpoint", format = format.price, precision = 0, display = display.data_window)

bool compoundStressAlert = bondComp <= -1.0 and commComp <= -0.8
bool sharedPermission = bondComp >= 0.25 and commComp >= 0.25
bool crossPressure = (bondComp <= -1.0 and commComp >= 0.25) or (commComp <= -0.8 and bondComp >= 0.25)
alertcondition(compoundStressAlert and not compoundStressAlert[1], "πECM: compound stress", "Bond and commodity pressure are both stressed.")
alertcondition(sharedPermission and not sharedPermission[1], "πECM: shared confidence", "Bond and commodity engines are both coherently constructive. Confidence means coherence, not health.")
alertcondition(crossPressure and not crossPressure[1], "πECM: cross-pressure", "Bond and commodity pressure disagree across the stress boundary.")
alertcondition(piCheckpoint, "πECM: π checkpoint", "The current ECM regime state completed another π checkpoint in Pine bar time.")
````
