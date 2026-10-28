# Helios v3 Live Regime Signal Tool

- url: https://www.tradingview.com/script/QML6SPtH-Helios-v3-Live-Regime-Signal-Tool/
- type: indicator
- pine_id: PUB;38571809a4244ed29fbe3e727a50e92c
- version: 1.0

## Description

Helios v3 — User Guide
Introduction
Helios v3 is a daily-timeframe market regime classifier and signal tool for TradingView. It tells you three things at a glance: what regime an asset is in (five states from Strong Bull to Strong Bear), whether a systematic entry or exit signal has fired, and — just as importantly — when a signal has been deliberately blocked because conditions make it a bad trade.

The core is a four-component trend score: MACD posture, the spread between the close-average and open-average, raw momentum, and position relative to a long moving average. Each component votes +1, 0, or −1, producing a score from −4 to +4 that maps to the regime. On top of that core, v3 adds two confirmation components the original lacked — volume participation (OBV trend) and relative strength against Bitcoin — and two protective gates: a realised-volatility cap that suppresses signals in conditions where trend-following historically fails, and an extension gate that refuses to buy parabolas or sell capitulation lows.

The philosophy: the regime tells you what the market is doing; the signals tell you when the system would act; the gates tell you when acting would be chasing. Transitions matter more than states — a slip from Strong Bull to Moderate Bull is information before any signal fires.

This is a decision-support tool, not financial advice. It describes price behavior; position sizing, risk, and the final call remain yours.


Installation
Open TradingView and load any chart, then set the timeframe to Daily (the tool is designed and calibrated for daily bars; volatility math assumes them).
Open the Pine Editor (bottom panel).
Delete any placeholder code, paste the entire contents of chameleon_v3_live.pine, and click Save (name it anything).
Click Add to chart. You should see colored bars, a regime label top-right, and the dashboard bottom-left.
To create alerts: click the three dots on the indicator name → Add alert, then pick a condition from the dropdown (see Alerts section below).


Choosing the right settings
Step 1 — Pick the volatility profile
Open the indicator settings and set Volatility Profile. This single dropdown switches all core parameters (MACD lengths, SMA, momentum lookback, confirmation days) and the volatility cap together:

Profile
90D Vol range
Vol cap
Typical assets
LV
under 50%
60%
S&P 500, Nasdaq, blue-chip stocks, major indices, BTC in calm regimes
MV
50–70%
80%
BTC and ETH in normal conditions, large-cap growth stocks
HV
71–90%
100%
Mid-cap cryptos (SOL-tier), volatile tech stocks, leveraged ETFs
SHV
over 90%
130%
Small-cap cryptos, meme coins, new listings, stocks in parabolic phases


You don't need to guess: the dashboard's 90D Vol row shows the asset's current volatility and prints ✓ Suitable or ✗ Use [profile] telling you which profile to switch to. Check it whenever you load a new asset, and re-check holdings every few weeks — volatility regimes drift, and an asset that was MV six months ago may be HV now.

Rule of thumb by asset class: indices and megacap equities → LV. Bitcoin and Ethereum → start with MV, follow the dashboard. Altcoins → HV or SHV, follow the dashboard. Anything freshly listed or in a mania phase → SHV.
Step 2 — Set the relative-strength benchmark (alts and stocks)
The RS benchmark input defaults to BINANCE:BTCUSDT, which is correct for altcoins: it asks "is this coin actually outperforming Bitcoin, or just riding its beta?" On a Bitcoin chart the component switches itself off automatically and the score range adapts.

For equities, change the benchmark to something meaningful — SP:SPX or NASDAQ:NDX — so the component measures strength against the relevant index instead of against Bitcoin. If you'd rather not use relative strength at all, untick Use Relative Strength vs benchmark.
Step 3 — Leave the gates alone (at first)
The defaults — buys blocked above z = 2.5, sells blocked below z = −2.5, auto vol cap on — are sensible starting values. Run the tool for a few weeks before adjusting anything. If you later find the vol gate too strict on a specific asset, untick Auto vol cap by profile and set a manual cap; that is the intended escape hatch, but use it knowingly — the gate exists because trend signals taken in extreme volatility have historically been the worst ones.


Reading the chart day to day
Bar colors = live regime. Bright green (Strong Bull, score +3 to +4), light green (Moderate Bull, +1 to +2), yellow (Neutral, 0), light red (Moderate Bear, −1 to −2), bright red (Strong Bear, −3 to −4). The top-right box states the regime in words.

Watch transitions, not states. Promotion into bright green is a confirmed breakout. Bright green fading to light green means the trend is losing a component — open the dashboard and see which one. Yellow rolling to light red to bright red is a regime change in progress. Climbing out of bright red suggests bear exhaustion and a possible base.

The dashboard is the diagnosis panel. It shows each component's current vote (MACD / Spread / Momentum / SMA, then Volume and Relative Strength), the total score against its maximum, the confirmation streak progress, the extension z-score, the vol gate status, your position state, and what size a signal would carry if it fired right now. The most useful daily habit: when a regime weakens, check whether volume (OBV) confirmed the move or diverged from it. Price-up with OBV voting −1 is a hollow rally; price flat with OBV voting +1 is quiet accumulation.

Triangles are signals:

Solid green triangle "FULL" — buy signal at full conviction: score at least +5 and price not extended (z below 1.5).
Lighter green triangle "HALF" — valid buy, but either the score is at the minimum threshold or price is somewhat extended. The system suggests half size.
Solid red triangle "SELL" — exit signal: score collapsed to −4 or worse for the required confirmation days.
Grey hollow triangle "BLK" — a blocked signal. Score and streak fully qualified, but a gate refused it: either realised vol is above the cap, or price is too extended (buys above z 2.5, sells below z −2.5). Blocked buys are worth tracking — when the same setup later fires at lower extension, it is typically the highest-quality entry the system produces.

Signal mechanics, for reference: a buy requires the extended score (core four components plus volume plus relative strength) to hold at +4 or better for the confirmation period — 2 consecutive days on LV/MV, 3 on HV/SHV — with the vol gate open and extension acceptable. Sells mirror this at −4. The system tracks one position state (long or flat) and will not repeat signals while in a position.


Alerts
Five alert conditions are available from the alert dialog:

BUY (full size) — highest-conviction entries.
BUY (half size) — valid but qualified entries.
SELL — confirmed regime breakdown exit.
Signal blocked — conditions met but gated; useful as a "watch this asset" ping.
Regime change — fires on any of the five-state transitions; the best low-noise alert for assets you hold but aren't actively trading.

A practical configuration: regime-change alerts on every core holding, plus buy/sell alerts on the handful of assets you'd actually trade systematically.


Honest limitations
The tool is a trend follower; it will always be late at exact tops and bottoms by design, and it loses money in choppy sideways ranges through whipsaw — the confirmation days and gates reduce this but cannot eliminate it. The volatility cap means some assets in extreme conditions produce no signals at all; that silence is itself the message. Backtested statistics on systems like this rest on a small number of historical trades, so treat any past-performance figure as descriptive, not predictive. And no indicator knows about news, unlocks, earnings, or liquidity events — the regime score is an input to judgment, not a replacement for it.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// HELIOS CHAMELEON v3 — LIVE REGIME & SIGNAL TOOL (indicator, not strategy)
//
// Core: faithful recreation of the 4-component Trend Chameleon score (-4..+4)
// New in v3:
//   • Component 5 — Volume participation (OBV vs its 20 SMA)
//   • Component 6 — Relative strength vs BTC (auto-disabled on BTC charts)
//   • Extension gate — z-score vs profile SMA blocks chasing / capitulation exits
//   • Sizing tiers — FULL / HALF suggested allocation on each buy signal
//   • 90D realised vol gate (60% cap), as per original
//
// Recommended timeframe: DAILY. Vol annualisation assumes daily bars (sqrt 365).
// ─────────────────────────────────────────────────────────────────────────────
indicator("Helios Chameleon v3 — Live Regime & Signal Tool", "Chameleon v3", overlay = true)

// ── INPUTS ───────────────────────────────────────────────────────────────────
grpP  = "Profile"
grpC  = "Components"
grpG  = "Gates"
grpV  = "Visuals"

profile = input.string("LV", "Volatility Profile", options = ["LV", "MV", "HV", "SHV"], group = grpP,
     tooltip = "Match to the asset's 90D realised vol (shown in dashboard):\nLV <50% | MV 50–70% | HV 71–90% | SHV >90%")

// Profile parameter sets (published spec)
macdFast = profile == "LV" ? 12 : profile == "MV" ? 16 : profile == "HV" ? 21 : 26
macdSlow = profile == "LV" ? 26 : profile == "MV" ? 34 : profile == "HV" ? 42 : 52
macdSig  = profile == "LV" ? 9  : profile == "MV" ? 12 : profile == "HV" ? 14 : 18
smaLen   = profile == "LV" ? 50 : profile == "MV" ? 75 : profile == "HV" ? 100 : 120
momLen   = profile == "LV" ? 14 : profile == "MV" ? 21 : profile == "HV" ? 28 : 35
confirmN = profile == "LV" or profile == "MV" ? 2 : 3

spreadLen   = input.int(20, "Spread MA length", minval = 2, group = grpC)
obvLen      = input.int(20, "OBV confirmation SMA", minval = 2, group = grpC)
useRSInput  = input.bool(true, "Use Relative Strength vs benchmark (alts)", group = grpC)
benchSym    = input.symbol("BINANCE:BTCUSDT", "RS benchmark", group = grpC)
rsLen       = input.int(50, "RS ratio SMA length", minval = 2, group = grpC)

volLen      = input.int(90, "Realised vol lookback (bars)", minval = 10, group = grpG)
volAutoCap  = input.bool(true, "Auto vol cap by profile (LV 60 / MV 80 / HV 100 / SHV 130)", group = grpG)
volCapMan   = input.float(60.0, "Manual vol cap (%) — used when auto is off", minval = 1, group = grpG)
volCap      = volAutoCap ? (profile == "LV" ? 60.0 : profile == "MV" ? 80.0 : profile == "HV" ? 100.0 : 130.0) : volCapMan
volSmooth   = input.bool(false, "EMA-smooth vol", group = grpG)
volSmoothL  = input.int(10, "Vol smoothing length", minval = 2, group = grpG)
extZBuy     = input.float(2.5, "Block buys above z =", step = 0.1, group = grpG)
extZSell    = input.float(-2.5, "Block sells below z =", step = 0.1, group = grpG)
fullSizeZ   = input.float(1.5, "FULL size requires z below", step = 0.1, group = grpG)

showRegBox  = input.bool(true, "Top-right regime label", group = grpV)
showDash    = input.bool(true, "Bottom-left dashboard", group = grpV)
showBlocked = input.bool(true, "Show blocked-signal markers", group = grpV)
colorBars   = input.bool(true, "Colour bars by regime", group = grpV)

// ── CORE 4 COMPONENTS (original Chameleon) ──────────────────────────────────
[macdLine, signalLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSig)
c1 = macdLine > 0 and signalLine > 0 ? 1 : macdLine < 0 and signalLine < 0 ? -1 : 0

smaC = ta.sma(close, spreadLen)
smaO = ta.sma(open, spreadLen)
c2 = smaC > smaO ? 1 : smaC < smaO ? -1 : 0

c3 = close > close[momLen] ? 1 : close < close[momLen] ? -1 : 0

smaVal = ta.sma(close, smaLen)
c4 = close > smaVal ? 1 : -1   // binary, no neutral (per spec)

coreScore = c1 + c2 + c3 + c4

// ── NEW COMPONENTS ───────────────────────────────────────────────────────────
// 5: Volume participation — OBV vs its own SMA
obvMa = ta.sma(ta.obv, obvLen)
c5 = ta.obv > obvMa ? 1 : ta.obv < obvMa ? -1 : 0

// 6: Relative strength vs benchmark (auto-off on BTC-base charts)
isBtcChart = syminfo.basecurrency == "BTC"
useRS = useRSInput and not isBtcChart
benchClose = request.security(benchSym, timeframe.period, close)
rsRatio = close / benchClose
rsMa = ta.sma(rsRatio, rsLen)
c6 = useRS ? (rsRatio > rsMa ? 1 : -1) : 0

extScore = coreScore + c5 + c6
maxScore = useRS ? 6 : 5

// ── GATES ────────────────────────────────────────────────────────────────────
logRet  = math.log(close / close[1])
rawVol  = ta.stdev(logRet, volLen) * math.sqrt(365) * 100
volEma  = ta.ema(rawVol, volSmoothL)
vol90   = volSmooth ? volEma : rawVol
volOpen = vol90 <= volCap

zExt = (close - smaVal) / ta.stdev(close, smaLen)

// ── REGIME (from core score, faithful to original taxonomy) ──────────────────
regime = coreScore >= 3 ? 4 : coreScore >= 1 ? 3 : coreScore == 0 ? 2 : coreScore >= -2 ? 1 : 0
regimeTxt = regime == 4 ? "STRONG BULL" : regime == 3 ? "MODERATE BULL" : regime == 2 ? "NEUTRAL" : regime == 1 ? "MODERATE BEAR" : "STRONG BEAR"
regimeCol = regime == 4 ? #00C853 : regime == 3 ? #9CCC65 : regime == 2 ? #FDD835 : regime == 1 ? #EF5350 : #D50000

barcolor(colorBars ? regimeCol : na)

// ── SIGNAL ENGINE ────────────────────────────────────────────────────────────
buyTh  = 4
sellTh = -4

buyCondRaw  = extScore >= buyTh
sellCondRaw = extScore <= sellTh

bsBuy  = ta.barssince(not buyCondRaw)
bsSell = ta.barssince(not sellCondRaw)
streakBuy  = buyCondRaw  ? nz(bsBuy, 9999)  : 0
streakSell = sellCondRaw ? nz(bsSell, 9999) : 0

var bool inLong = false

readyBuy  = streakBuy  >= confirmN and not inLong
readySell = streakSell >= confirmN and inLong

buySignal  = readyBuy  and volOpen and zExt <= extZBuy
sellSignal = readySell and volOpen and zExt >= extZSell

// Blocked markers: shown once, on the bar the signal would first have fired
blockedBuy  = showBlocked and readyBuy  and streakBuy  == confirmN and not buySignal
blockedSell = showBlocked and readySell and streakSell == confirmN and not sellSignal

// Sizing tier (evaluated at buy)
fullSize = extScore >= buyTh + 1 and zExt < fullSizeZ
buyFull = buySignal and fullSize
buyHalf = buySignal and not fullSize

var string lastSignal = "—"
if buySignal
    inLong := true
    lastSignal := (fullSize ? "BUY FULL " : "BUY HALF ") + str.tostring(close, format.mintick)
if sellSignal
    inLong := false
    lastSignal := "SELL " + str.tostring(close, format.mintick)

// ── SHAPES ───────────────────────────────────────────────────────────────────
plotshape(buyFull,  "Buy (full)",  shape.triangleup,   location.belowbar, #00C853, text = "FULL",  textcolor = color.white, size = size.small)
plotshape(buyHalf,  "Buy (half)",  shape.triangleup,   location.belowbar, #9CCC65, text = "HALF",  textcolor = color.white, size = size.small)
plotshape(sellSignal, "Sell",      shape.triangledown, location.abovebar, #D50000, text = "SELL",  textcolor = color.white, size = size.small)
plotshape(blockedBuy,  "Blocked buy",  shape.triangleup,   location.belowbar, color.new(color.gray, 30), text = "BLK", textcolor = color.silver, size = size.tiny)
plotshape(blockedSell, "Blocked sell", shape.triangledown, location.abovebar, color.new(color.gray, 30), text = "BLK", textcolor = color.silver, size = size.tiny)

plot(smaVal, "Profile SMA", color.new(color.gray, 40), 1)

// Data-window diagnostics
plot(coreScore, "Core score (-4..+4)", display = display.data_window)
plot(extScore,  "Extended score",      display = display.data_window)
plot(vol90,     "90D realised vol %",  display = display.data_window)
plot(zExt,      "Extension z",         display = display.data_window)

// ── TOP-RIGHT REGIME BOX ─────────────────────────────────────────────────────
var table regBox = table.new(position.top_right, 1, 1)
if barstate.islast and showRegBox
    table.cell(regBox, 0, 0, regimeTxt, text_color = color.white, bgcolor = color.new(regimeCol, 15), text_size = size.normal)

// ── BOTTOM-LEFT DASHBOARD ────────────────────────────────────────────────────
suitTxt = profile == "LV" ? (vol90 < 50 ? "✓ Suitable" : "✗ Use " + (vol90 <= 70 ? "MV" : vol90 <= 90 ? "HV" : "SHV")) :
     profile == "MV" ? (vol90 >= 50 and vol90 <= 70 ? "✓ Suitable" : "✗ Use " + (vol90 < 50 ? "LV" : vol90 <= 90 ? "HV" : "SHV")) :
     profile == "HV" ? (vol90 > 70 and vol90 <= 90 ? "✓ Suitable" : "✗ Use " + (vol90 < 50 ? "LV" : vol90 <= 70 ? "MV" : "SHV")) :
     (vol90 > 90 ? "✓ Suitable" : "✗ Use " + (vol90 < 50 ? "LV" : vol90 <= 70 ? "MV" : "HV"))

compTxt(int v) =>
    v > 0 ? "+1" : v < 0 ? "−1" : "0"

var table dash = table.new(position.bottom_left, 2, 13, border_width = 1)
if barstate.islast and showDash
    hdrBg = color.new(#1E88E5, 10)
    rowBg = color.new(#37474F, 25)
    txtC  = color.white
    table.cell(dash, 0, 0,  "Chameleon v3 — " + profile, text_color = txtC, bgcolor = hdrBg)
    table.cell(dash, 1, 0,  syminfo.ticker, text_color = txtC, bgcolor = hdrBg)
    table.cell(dash, 0, 1,  "90D Vol", text_color = txtC, bgcolor = rowBg)
    table.cell(dash, 1, 1,  str.tostring(vol90, "#.##") + "%  " + suitTxt, text_color = txtC, bgcolor = rowBg)
    table.cell(dash, 0, 2,  "Vol gate", text_color = txtC, bgcolor = rowBg)
    table.cell(dash, 1, 2,  volOpen ? "OPEN" : "CLOSED (>" + str.tostring(volCap, "#") + "%)", text_color = volOpen ? #00C853 : #EF5350, bgcolor = rowBg)
    table.cell(dash, 0, 3,  "Regime", text_color = txtC, bgcolor = rowBg)
    table.cell(dash, 1, 3,  regimeTxt + "  (" + (coreScore > 0 ? "+" : "") + str.tostring(coreScore) + ")", text_color = color.white, bgcolor = color.new(regimeCol, 35))
    table.cell(dash, 0, 4,  "MACD / Spread / Mom / SMA", text_color = txtC, bgcolor = rowBg)
    table.cell(dash, 1, 4,  compTxt(c1) + " / " + compTxt(c2) + " / " + compTxt(c3) + " / " + compTxt(c4), text_color = txtC, bgcolor = rowBg)
    table.cell(dash, 0, 5,  "Volume (OBV)", text_color = txtC, bgcolor = rowBg)
    table.cell(dash, 1, 5,  compTxt(c5), text_color = c5 > 0 ? #00C853 : c5 < 0 ? #EF5350 : txtC, bgcolor = rowBg)
    table.cell(dash, 0, 6,  "Rel. strength", text_color = txtC, bgcolor = rowBg)
    table.cell(dash, 1, 6,  useRS ? compTxt(c6) : "off (BTC)", text_color = useRS ? (c6 > 0 ? #00C853 : #EF5350) : color.silver, bgcolor = rowBg)
    table.cell(dash, 0, 7,  "Total score", text_color = txtC, bgcolor = rowBg)
    table.cell(dash, 1, 7,  (extScore > 0 ? "+" : "") + str.tostring(extScore) + " / ±" + str.tostring(maxScore), text_color = txtC, bgcolor = rowBg)
    table.cell(dash, 0, 8,  "Confirm streak", text_color = txtC, bgcolor = rowBg)
    table.cell(dash, 1, 8,  str.tostring(math.max(streakBuy, streakSell)) + " / " + str.tostring(confirmN), text_color = txtC, bgcolor = rowBg)
    table.cell(dash, 0, 9,  "Extension z", text_color = txtC, bgcolor = rowBg)
    extBlockedNow = zExt > extZBuy or zExt < extZSell
    table.cell(dash, 1, 9,  str.tostring(zExt, "#.##") + (extBlockedNow ? "  ⚠ gate" : ""), text_color = extBlockedNow ? #FDD835 : txtC, bgcolor = rowBg)
    table.cell(dash, 0, 10, "Position", text_color = txtC, bgcolor = rowBg)
    table.cell(dash, 1, 10, inLong ? "LONG" : "FLAT", text_color = inLong ? #00C853 : color.silver, bgcolor = rowBg)
    table.cell(dash, 0, 11, "Size if signal now", text_color = txtC, bgcolor = rowBg)
    table.cell(dash, 1, 11, fullSize ? "FULL" : "HALF", text_color = txtC, bgcolor = rowBg)
    table.cell(dash, 0, 12, "Last signal", text_color = txtC, bgcolor = rowBg)
    table.cell(dash, 1, 12, lastSignal, text_color = txtC, bgcolor = rowBg)

// ── ALERTS ───────────────────────────────────────────────────────────────────
alertcondition(buyFull,    "Chameleon v3: BUY (full size)",  "Chameleon v3 BUY — full size conditions met")
alertcondition(buyHalf,    "Chameleon v3: BUY (half size)",  "Chameleon v3 BUY — half size (lower score or extended)")
alertcondition(sellSignal, "Chameleon v3: SELL",             "Chameleon v3 SELL — regime breakdown confirmed")
alertcondition(blockedBuy or blockedSell, "Chameleon v3: signal blocked", "Chameleon v3 — signal met score conditions but a gate blocked it")
alertcondition(regime != regime[1], "Chameleon v3: regime change", "Chameleon v3 — regime changed")
````
