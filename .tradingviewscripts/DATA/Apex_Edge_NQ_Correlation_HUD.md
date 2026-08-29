<!-- tradingview-pine-id: PUB;a8234f644ec343f0acbdc45b25b6d036 -->
<!-- tradingviewscripts-format: 1 -->
# Apex Edge - NQ Correlation HUD

Source: https://www.tradingview.com/script/1Q3VJ61T-Apex-Edge-NQ-Correlation-HUD/

## Description

Apex Edge — NQ Correlation HUD
Note: This script is the HUD only. Screenshots may also show separate Supply & Demand zone and key-level tools running alongside it for extra confluence — those are independent indicators, not part of this script, and aren't required for the HUD to function.

What it does
Apex Edge — NQ Correlation HUD is a compact on-chart dashboard built for trading Nasdaq-100 index products (NQ, MNQ, and similar). Rather than manually flicking between the VIX and individual Mega-Cap Tech charts to gauge whether the broader market agrees with a setup, this indicator brings that context onto your current chart in one glance.

It scores your current instrument's own momentum and structure, then does the same for the VIX and seven Magnificent-7 stocks — live, every bar — and tells you visually which of those names are actually confirming your bias right now versus which aren't.

The HUD: Ticker / Fuel / Confluence
The dashboard is a simple 3-column table:

Ticker — the symbol for that row. Row 1 always reflects whatever chart you're currently on (so it updates automatically if you switch between NQ and MNQ, or any other symbol). Below that: VIX, then the 7 Mag7 names.

Fuel — a 0–10 momentum score for that symbol (see scoring below), shown as a fraction against your configured minimum threshold, e.g. 6/6.

Confluence — a directional vote out of 5, shown as ▲x/▼y, indicating how many of 5 independent components currently lean bullish versus bearish for that symbol.
What it monitors, and why

VIX — the market's fear gauge. It typically moves inversely to equities, so a VIX reading that's rising while your chart is bearish (or falling while your chart is bullish) is a classic confirmation signal. The HUD surfaces VIX's own Fuel and Confluence so you don't have to switch charts to check it.

The 7 Mag7 stocks (defaults: AAPL, MSFT, GOOGL, AMZN, NVDA, META, TSLA — all fully customizable in settings) — these carry substantial weight in the Nasdaq-100 and tend to drive a large share of its movement. When several of them are genuinely moving with your NQ/MNQ chart, that's real confirmation your setup isn't just noise on one instrument; when they're diverging, it's a reason for caution even if your chart alone looks clean.

How each pair offers confluence
A single chart can give a false signal — a stop run, a low-liquidity spike, an isolated headline. Checking whether the broader Nasdaq complex agrees filters a lot of that out. If your NQ/MNQ setup is bearish and the majority of Mag7 names are also showing bearish confluence while correlating with your chart's actual price action, and VIX is leaning bullish (its typical inverse relationship holding up), that's three independent confirmations lining up rather than one chart in isolation.

How the columns are scored
Fuel Score (0–10) is a multi-factor momentum read, built from:

Volume Z-score relative to a rolling average
Candle body dominance within its own range
Where the close sits within the bar's high-low range
ATR expansion versus its own rolling average

Confluence Score (out of 5) is a 5-component directional vote:

LTF trend (Hull moving average)
HTF trend (Hull moving average on a higher timeframe)
LTF RSI position
HTF RSI position
Price structure vs. a rolling range midpoint
Each component casts one bullish or bearish vote; the tally is shown as ▲bullish/▼bearish.

The correlation layer
This is what separates the Mag7 rows from a static watchlist. Each Mag7 ticker's title is colour-coded in real time:

Green — that symbol is BOTH rolling-correlated to your current chart above a threshold you set, AND its own Confluence is currently agreeing with your chart's direction.

Red — either condition fails: it's not correlating closely enough right now, or it's correlating but currently pointing the other way.

This means the HUD isn't just showing you 7 static numbers — it's telling you, live, which of the 7 are actually confirming your bias in this moment versus which are just along for the ride historically. Correlation lookback, the green/red threshold, and the correlation-guide tooltip (with standard statistical strength bands) are all configurable.

Built-in alerts
Two included alert conditions ("HUD Setup: Long Bias" / "HUD Setup: Short Bias") fire when your chart's Confluence bias is shared by a configurable number of the 7 Mag7 symbols AND VIX Confluence is leaning the opposite way. These are deliberately price-agnostic — they tell you when the broader HUD context has aligned, not when to enter. Pair them with your own key-level or zone tools to time actual entries once the alert fires.

Settings
Fuel/Confluence Dashboard toggle, dashboard position, minimum Fuel threshold
Hull MA period and HTF resolution
Multi-Pair HUD toggle, monitor timeframe for the 7 Mag7 rows
VIX symbol, all 7 Mag7 symbols (freely swappable)
Correlation lookback length, correlation threshold, min Mag7 aligned count for alerts

Align it with other confluence indicators to time your entry.  Below is an example of the HUD running alongside 2 indicators (Key levels & Supply & Demand zones).

https://www.tradingview.com/x/pSOqyvud/

A NOTE ON USE:
Market hours affect the correlation rows. NQ/MNQ trade nearly 24 hours; the Mag7 equities only trade actively during NASDAQ hours (with an extended pre/post-market window beyond that). Outside those hours, correlation can legitimately read n/a for some or all Mag7 rows — that's expected behaviour, not a fault, since a closed/flat equity price has no variance to correlate against. Correlation readings are most meaningful during and immediately around the NASDAQ session; Fuel and Confluence continue working normally at all hours since they don't depend on cross-symbol variance.

This tool is designed to support discretionary trading decisions around Nasdaq-100 index products — it doesn't generate entries or exits on its own, and none of its readings guarantee a particular outcome. Fuel, Confluence, and correlation are all descriptive of current and historical price behaviour, not predictions. As with any tool, backtest and forward-test on a demo account before relying on it in a live or funded environment. Nothing in this script or its description constitutes financial advice.

---

## Source Code

````pine
// Apex Edge - NQ Correlation HUD
// Original work — Fuel Score, 5-component Confluence Score, and the
// correlation-and-direction-confirmed Multi-Pair (VIX + Mag7) HUD, plus the
// HUD Setup alerts. No third-party code.

//@version=6
indicator("Apex Edge - NQ Correlation HUD", shorttitle="Apex NQ HUD", overlay=true, max_labels_count=500)

// ============================ INPUTS ============================


// ---- SMC Tactical Suite: Fuel Score + Confluence HUD only ----
// Extracted from "Apex Edge - SMC Tactical Suite [Premium]". Entry signals,
// trap detection, TP/SL boxes, sessions and risk filters were intentionally
// left out — this brings across only the Fuel Score and 5-component
// Confluence Score, feeding a compact dashboard.
grpSMC = "SMC Fuel & Confluence"
showSMCDashboard = input.bool(true, "Show Fuel/Confluence Dashboard", group=grpSMC)
smcMinFuelToShow = input.int(6, "Min Fuel Score (1-10)", minval=1, maxval=10, group=grpSMC, tooltip="Used to color the Fuel row on the dashboard.")
smcHullPeriod    = input.int(50, "Hull MA Period", minval=10, group=grpSMC)
smcHtfResolution = input.timeframe("60", "HTF Resolution", group=grpSMC)
smcDashboardPosInput = input.string("Top Right", "Dashboard Position",
  options=["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Left", "Middle Right"], group=grpSMC)

// ---- Multi-Pair HUD: VIX + Mag7 fuel/confluence rows ----
// Adds extra HUD rows scoring OTHER symbols with the exact same Fuel Score
// and 5-component Confluence formula used above, so you can see VIX / Mag7
// context without switching charts. Each row is self-contained and scored
// against its own OHLCV/volume — self-contained, matching how the
// current-chart Fuel/Confluence HUD already works.
grpMP = "Multi-Pair HUD"
showMultiPairHUD = input.bool(true, "Show VIX + Mag7 Rows", group=grpMP, tooltip="Adds 10 extra HUD rows (Fuel + Confluence for VIX and 4 selected symbols) below your current chart's Fuel/Confluence rows.")
mpMonitorTF = input.timeframe("5", "Monitor Timeframe (VIX & Mag7 rows)", group=grpMP, tooltip="Timeframe used to score the LTF Fuel/Hull/RSI/Structure components for the extra rows. Independent of your main chart timeframe and of HTF Resolution above (which is still used for the HTF Hull/RSI components of every row, including these).")
mpVixSymbol  = input.symbol("TVC:VIX", "VIX Symbol", group=grpMP)

mpAutoCorr = input.bool(true, "Colour-Code Titles by Correlation + Direction", group=grpMP, tooltip="When on, a Mag7 row title is green only if BOTH: its rolling correlation to this chart meets or exceeds the threshold, AND its own Confluence currently agrees with your chart's Confluence bias (both bullish or both bearish). Otherwise red. Uncapped — anywhere from 0 to all 7 can be green depending on what's actually confirming your bias right now.")
mpCorrLen  = input.int(50, "Correlation Lookback (bars)", minval=10, group=grpMP, tooltip="Rolling correlation window, measured on this chart's own timeframe (not the Monitor Timeframe).")
mpCorrThreshold = input.float(0.5, "Min Correlation to Colour Green", minval=-1.0, maxval=1.0, step=0.05, group=grpMP, tooltip="Any Mag7 symbol whose rolling correlation to this chart meets or exceeds this value is coloured green — uncapped, so anywhere from 0 to all 7 can be green at once. Below it, the title stays red. Correlation itself ranges -1.0 (perfect inverse) to +1.0 (perfect lockstep).\n\nGeneral guide for what the value means (standard stats convention, not specific to this script):\n0.8 to 1.0 = very strong — moves almost in lockstep\n0.6 to 0.8 = strong — reliable confirmation\n0.4 to 0.6 = moderate — some relationship, treat as a lean not a signal\n0.2 to 0.4 = weak — little practical use\n0.0 to 0.2 = negligible — effectively unrelated\n\n0.5-0.6 is a reasonable starting threshold for 'meaningfully correlating.' Raise it (e.g. 0.7) if you want fewer, higher-conviction green rows; lower it if you want a broader read of what's moving with you.")
mpAlertMinAligned = input.int(5, "HUD Setup Alert: Min Mag7 Aligned (of 7)", minval=1, maxval=7, group=grpMP, tooltip="The HUD Setup alert fires when this many (or more) of the 7 Mag7 symbols share the same Confluence bias as your current chart, AND VIX Confluence leans the opposite way. This is a 'go check the chart' alert, not an entry signal — it doesn't check price at all, so still wait for price to touch your key level (SD zone or Spaceman) before entering in the direction the HUD shows.")

mpCand1 = input.symbol("NASDAQ:AAPL",  "Mag7 Symbol 1", group=grpMP)
mpCand2 = input.symbol("NASDAQ:MSFT",  "Mag7 Symbol 2", group=grpMP)
mpCand3 = input.symbol("NASDAQ:GOOGL", "Mag7 Symbol 3", group=grpMP)
mpCand4 = input.symbol("NASDAQ:AMZN",  "Mag7 Symbol 4", group=grpMP)
mpCand5 = input.symbol("NASDAQ:NVDA",  "Mag7 Symbol 5", group=grpMP)
mpCand6 = input.symbol("NASDAQ:META",  "Mag7 Symbol 6", group=grpMP)
mpCand7 = input.symbol("NASDAQ:TSLA",  "Mag7 Symbol 7", group=grpMP)


// ============================ SMC FUEL SCORE ============================
// Multi-factor Fuel Score (0-10): volume Z-score, body dominance, close
// location within the bar's own range, and ATR expansion vs its 50-bar average.
smcBody       = math.abs(close - open)
smcPriceRange = math.max(high - low, syminfo.mintick)
smcRangeAvg   = ta.sma(smcPriceRange, 20)
smcRangeStd   = ta.stdev(smcPriceRange, 20)
smcVolumeAvg  = ta.sma(volume, 20)
smcVolumeStd  = ta.stdev(volume, 20)
smcRangeZ     = smcRangeStd  > 0 ? (smcPriceRange - smcRangeAvg) / smcRangeStd  : 0.0
smcVolumeZ    = smcVolumeStd > 0 ? (volume - smcVolumeAvg)      / smcVolumeStd  : 0.0

smcAtr    = ta.atr(14)
smcAtrAvg = ta.sma(smcAtr, 50)

smcVolComp   = math.min(2.5, math.max(0.0, smcVolumeZ * 0.9 + 0.5))
smcBodyComp  = math.min(2.5, (smcBody / smcPriceRange) * 2.5)
smcCloseComp = math.min(2.5, math.abs((close - (high + low) * 0.5) / smcPriceRange) * 5.0)
smcAtrComp   = math.min(2.5, math.max(0.0, (smcAtr / math.max(smcAtrAvg, syminfo.mintick) - 0.8) * 3.0))
smcFuelScore = math.round(smcVolComp + smcBodyComp + smcCloseComp + smcAtrComp)

// ============================ SMC CONFLUENCE SCORE ============================
// 5-component vote: LTF Hull, HTF Hull, LTF RSI, HTF RSI, structure vs 20-bar midpoint.
smcRsiVal = ta.rsi(close, 14)
smcHullMA = ta.wma(2 * ta.wma(close, smcHullPeriod / 2) - ta.wma(close, smcHullPeriod), math.round(math.sqrt(smcHullPeriod)))

smcHtfClose = request.security(syminfo.tickerid, smcHtfResolution, close)
smcHtfHull  = request.security(syminfo.tickerid, smcHtfResolution,
                ta.wma(2 * ta.wma(close, smcHullPeriod / 2) - ta.wma(close, smcHullPeriod),
                math.round(math.sqrt(smcHullPeriod))))
smcHtfRsi   = request.security(syminfo.tickerid, smcHtfResolution, ta.rsi(close, 14))
smcHtfUptrend = smcHtfClose > smcHtfHull

smcMidRange20    = (ta.highest(high, 20) + ta.lowest(low, 20)) * 0.5
smcLtfHullBull   = close      > smcHullMA     ? 1 : 0
smcHtfHullBull   = smcHtfUptrend              ? 1 : 0
smcLtfRSIBull    = smcRsiVal  > 50            ? 1 : 0
smcHtfRSIBull    = smcHtfRsi  > 50            ? 1 : 0
smcStructureBull = close      > smcMidRange20 ? 1 : 0

smcBullConfluence = smcLtfHullBull + smcHtfHullBull + smcLtfRSIBull + smcHtfRSIBull + smcStructureBull
smcBearConfluence = (1 - smcLtfHullBull) + (1 - smcHtfHullBull) + (1 - smcLtfRSIBull) + (1 - smcHtfRSIBull) + (1 - smcStructureBull)

// ============================ MULTI-PAIR HUD: FUEL + CONFLUENCE FOR OTHER SYMBOLS ============================
// Same formulas as above (Fuel Score + 5-component Confluence), evaluated
// against a different symbol/timeframe via request.security. Split into an
// LTF call and an HTF call per symbol because request.security cannot be
// nested inside another request.security call.
f_mpLtf() =>
    _body       = math.abs(close - open)
    _range      = math.max(high - low, syminfo.mintick)
    _volAvg     = ta.sma(volume, 20)
    _volStd     = ta.stdev(volume, 20)
    _volZ       = _volStd > 0 ? (volume - _volAvg) / _volStd : 0.0
    _atr        = ta.atr(14)
    _atrAvg     = ta.sma(_atr, 50)
    _volComp    = math.min(2.5, math.max(0.0, _volZ * 0.9 + 0.5))
    _bodyComp   = math.min(2.5, (_body / _range) * 2.5)
    _closeComp  = math.min(2.5, math.abs((close - (high + low) * 0.5) / _range) * 5.0)
    _atrComp    = math.min(2.5, math.max(0.0, (_atr / math.max(_atrAvg, syminfo.mintick) - 0.8) * 3.0))
    _fuel       = math.round(_volComp + _bodyComp + _closeComp + _atrComp)
    _rsi        = ta.rsi(close, 14)
    _hull       = ta.wma(2 * ta.wma(close, smcHullPeriod / 2) - ta.wma(close, smcHullPeriod), math.round(math.sqrt(smcHullPeriod)))
    _mid20      = (ta.highest(high, 20) + ta.lowest(low, 20)) * 0.5
    _hullBull   = close > _hull ? 1 : 0
    _rsiBull    = _rsi > 50 ? 1 : 0
    _structBull = close > _mid20 ? 1 : 0
    [_fuel, _hullBull, _rsiBull, _structBull]

f_mpHtf() =>
    _hull     = ta.wma(2 * ta.wma(close, smcHullPeriod / 2) - ta.wma(close, smcHullPeriod), math.round(math.sqrt(smcHullPeriod)))
    _rsi      = ta.rsi(close, 14)
    _hullBull = close > _hull ? 1 : 0
    _rsiBull  = _rsi > 50 ? 1 : 0
    [_hullBull, _rsiBull]

f_mpScore(string sym) =>
    [ltfFuel, ltfHullBull, ltfRsiBull, structBull] = request.security(sym, mpMonitorTF, f_mpLtf())
    [htfHullBull, htfRsiBull] = request.security(sym, smcHtfResolution, f_mpHtf())
    bull = ltfHullBull + htfHullBull + ltfRsiBull + htfRsiBull + structBull
    bear = 5 - bull
    [ltfFuel, bull, bear]

f_mpScoreGated(string sym) =>
    // VIX always scores when the HUD is on; manual Mag7 symbols only score
    // when Auto-Select is off (saves security calls when auto-ranking is on).
    if showMultiPairHUD
        f_mpScore(sym)
    else
        [int(na), int(na), int(na)]

[mpVixFuel, mpVixBull, mpVixBear] = f_mpScoreGated(mpVixSymbol)

// ---- 7 Mag7 rows: Fuel/Confluence always computed and always displayed.
// Correlation is computed separately (gated on the colour-code toggle) purely
// to rank the 7 and colour each row's title green (top 4) or red (bottom 3).
f_candCloseGated(string sym) =>
    if showMultiPairHUD and mpAutoCorr
        request.security(sym, timeframe.period, close)
    else
        float(na)

f_mpCandGated(string sym) =>
    if showMultiPairHUD
        f_mpScore(sym)
    else
        [int(na), int(na), int(na)]

cand1Close = f_candCloseGated(mpCand1)
cand2Close = f_candCloseGated(mpCand2)
cand3Close = f_candCloseGated(mpCand3)
cand4Close = f_candCloseGated(mpCand4)
cand5Close = f_candCloseGated(mpCand5)
cand6Close = f_candCloseGated(mpCand6)
cand7Close = f_candCloseGated(mpCand7)

corr1 = ta.correlation(close, cand1Close, mpCorrLen)
corr2 = ta.correlation(close, cand2Close, mpCorrLen)
corr3 = ta.correlation(close, cand3Close, mpCorrLen)
corr4 = ta.correlation(close, cand4Close, mpCorrLen)
corr5 = ta.correlation(close, cand5Close, mpCorrLen)
corr6 = ta.correlation(close, cand6Close, mpCorrLen)
corr7 = ta.correlation(close, cand7Close, mpCorrLen)

[cand1Fuel, cand1Bull, cand1Bear] = f_mpCandGated(mpCand1)
[cand2Fuel, cand2Bull, cand2Bear] = f_mpCandGated(mpCand2)
[cand3Fuel, cand3Bull, cand3Bear] = f_mpCandGated(mpCand3)
[cand4Fuel, cand4Bull, cand4Bear] = f_mpCandGated(mpCand4)
[cand5Fuel, cand5Bull, cand5Bear] = f_mpCandGated(mpCand5)
[cand6Fuel, cand6Bull, cand6Bear] = f_mpCandGated(mpCand6)
[cand7Fuel, cand7Bull, cand7Bear] = f_mpCandGated(mpCand7)

// ---- HUD Setup Alert: current chart's own Confluence bias, shared by
// mpAlertMinAligned+ of the 7 Mag7 symbols, with VIX Confluence leaning the
// opposite way. Price-agnostic on purpose — it's a "go check the chart" cue;
// entry still waits for price to reach an SD zone or Spaceman key level.
// Only count a Mag7 symbol if it's BOTH correlating (green, per the same
// threshold that colours the HUD titles) AND its Confluence agrees with the
// direction — otherwise the alert could fire off symbols that aren't
// actually moving with this chart right now, which is what the title colour
// is supposed to rule out.
mag7BullCount = (not na(corr1) and corr1 >= mpCorrThreshold and cand1Bull > cand1Bear ? 1 : 0) + (not na(corr2) and corr2 >= mpCorrThreshold and cand2Bull > cand2Bear ? 1 : 0) + (not na(corr3) and corr3 >= mpCorrThreshold and cand3Bull > cand3Bear ? 1 : 0) + (not na(corr4) and corr4 >= mpCorrThreshold and cand4Bull > cand4Bear ? 1 : 0) + (not na(corr5) and corr5 >= mpCorrThreshold and cand5Bull > cand5Bear ? 1 : 0) + (not na(corr6) and corr6 >= mpCorrThreshold and cand6Bull > cand6Bear ? 1 : 0) + (not na(corr7) and corr7 >= mpCorrThreshold and cand7Bull > cand7Bear ? 1 : 0)
mag7BearCount = (not na(corr1) and corr1 >= mpCorrThreshold and cand1Bear > cand1Bull ? 1 : 0) + (not na(corr2) and corr2 >= mpCorrThreshold and cand2Bear > cand2Bull ? 1 : 0) + (not na(corr3) and corr3 >= mpCorrThreshold and cand3Bear > cand3Bull ? 1 : 0) + (not na(corr4) and corr4 >= mpCorrThreshold and cand4Bear > cand4Bull ? 1 : 0) + (not na(corr5) and corr5 >= mpCorrThreshold and cand5Bear > cand5Bull ? 1 : 0) + (not na(corr6) and corr6 >= mpCorrThreshold and cand6Bear > cand6Bull ? 1 : 0) + (not na(corr7) and corr7 >= mpCorrThreshold and cand7Bear > cand7Bull ? 1 : 0)

chartBullish = smcBullConfluence > smcBearConfluence
chartBearish = smcBearConfluence > smcBullConfluence
vixBullish   = mpVixBull > mpVixBear
vixBearish   = mpVixBear > mpVixBull

hudLongSetup  = showMultiPairHUD and chartBullish and mag7BullCount >= mpAlertMinAligned and vixBearish
hudShortSetup = showMultiPairHUD and chartBearish and mag7BearCount >= mpAlertMinAligned and vixBullish

// ============================ SMC FUEL/CONFLUENCE DASHBOARD ============================
smcDashboardPos = smcDashboardPosInput == "Top Left"     ? position.top_left    :
                   smcDashboardPosInput == "Top Right"    ? position.top_right   :
                   smcDashboardPosInput == "Bottom Left"  ? position.bottom_left :
                   smcDashboardPosInput == "Bottom Right" ? position.bottom_right:
                   smcDashboardPosInput == "Middle Left"  ? position.middle_left : position.middle_right

smcTableRows = showMultiPairHUD ? 10 : 2
var table smcTable = table.new(smcDashboardPos, 3, smcTableRows, bgcolor=color.new(color.black, 70), border_width=1, border_color=color.new(color.white, 80))

mpFuelColor(int f) => f >= smcMinFuelToShow ? color.lime : color.orange
mpConfColor(int bull, int bear) => bull > bear ? color.lime : bear > bull ? color.red : color.white
mpRowLabel(string sym) =>
    int colonIdx = str.pos(sym, ":")
    string shortSym = na(colonIdx) ? sym : str.substring(sym, colonIdx + 1)
    str.length(shortSym) > 12 ? str.substring(shortSym, 0, 12) : shortSym

if showSMCDashboard and barstate.islast
    table.cell(smcTable, 0, 0, "Ticker", text_color=color.white, text_size=size.small)
    table.cell(smcTable, 1, 0, "Fuel", text_color=color.white, text_size=size.small)
    table.cell(smcTable, 2, 0, "Conf", text_color=color.white, text_size=size.small)

    smcFuelColor = smcFuelScore >= smcMinFuelToShow ? color.lime : color.orange
    smcConfColor = smcBullConfluence > smcBearConfluence ? color.lime : smcBearConfluence > smcBullConfluence ? color.red : color.white
    table.cell(smcTable, 0, 1, mpRowLabel(syminfo.ticker), text_color=color.white, text_size=size.small)
    table.cell(smcTable, 1, 1, str.tostring(smcFuelScore) + "/" + str.tostring(smcMinFuelToShow), text_color=smcFuelColor, text_size=size.small)
    table.cell(smcTable, 2, 1, "▲" + str.tostring(smcBullConfluence) + "/▼" + str.tostring(smcBearConfluence), text_color=smcConfColor, text_size=size.small)

    if showMultiPairHUD
        table.cell(smcTable, 0, 2, mpRowLabel(mpVixSymbol), text_color=color.white, text_size=size.small)
        table.cell(smcTable, 1, 2, str.tostring(mpVixFuel) + "/" + str.tostring(smcMinFuelToShow), text_color=mpFuelColor(mpVixFuel), text_size=size.small)
        table.cell(smcTable, 2, 2, "▲" + str.tostring(mpVixBull) + "/▼" + str.tostring(mpVixBear), text_color=mpConfColor(mpVixBull, mpVixBear), text_size=size.small)

        // 7 Mag7 rows always render (rows 3-9). Ticker colour flags the top 4
        // vs bottom 3 by rolling correlation to this chart.
        array<string> aSym  = array.new<string>()
        array<float>  aCorr = array.new<float>()
        array<int>    aFuel = array.new<int>()
        array<int>    aBull = array.new<int>()
        array<int>    aBear = array.new<int>()
        array.push(aSym, mpCand1)
        array.push(aSym, mpCand2)
        array.push(aSym, mpCand3)
        array.push(aSym, mpCand4)
        array.push(aSym, mpCand5)
        array.push(aSym, mpCand6)
        array.push(aSym, mpCand7)
        array.push(aCorr, corr1)
        array.push(aCorr, corr2)
        array.push(aCorr, corr3)
        array.push(aCorr, corr4)
        array.push(aCorr, corr5)
        array.push(aCorr, corr6)
        array.push(aCorr, corr7)
        array.push(aFuel, cand1Fuel)
        array.push(aFuel, cand2Fuel)
        array.push(aFuel, cand3Fuel)
        array.push(aFuel, cand4Fuel)
        array.push(aFuel, cand5Fuel)
        array.push(aFuel, cand6Fuel)
        array.push(aFuel, cand7Fuel)
        array.push(aBull, cand1Bull)
        array.push(aBull, cand2Bull)
        array.push(aBull, cand3Bull)
        array.push(aBull, cand4Bull)
        array.push(aBull, cand5Bull)
        array.push(aBull, cand6Bull)
        array.push(aBull, cand7Bull)
        array.push(aBear, cand1Bear)
        array.push(aBear, cand2Bear)
        array.push(aBear, cand3Bear)
        array.push(aBear, cand4Bear)
        array.push(aBear, cand5Bear)
        array.push(aBear, cand6Bear)
        array.push(aBear, cand7Bear)

        chartBullishHUD = smcBullConfluence > smcBearConfluence
        chartBearishHUD = smcBearConfluence > smcBullConfluence

        for i = 0 to 6
            string sym    = array.get(aSym, i)
            int    fuel   = array.get(aFuel, i)
            int    bull   = array.get(aBull, i)
            int    bear   = array.get(aBear, i)
            float  corrV  = array.get(aCorr, i)
            bool   corrOk = not na(corrV) and corrV >= mpCorrThreshold
            // Green requires BOTH: correlating above threshold AND this
            // symbol's own Confluence currently agreeing with your chart's
            // bias — a symbol can be historically correlated but pointing
            // the other way right now, so plain correlation alone isn't
            // enough to call it "with you" for entry purposes.
            bool dirAgrees = (chartBullishHUD and bull > bear) or (chartBearishHUD and bear > bull)
            color titleCol = not mpAutoCorr ? color.white : (corrOk and dirAgrees ? color.lime : color.red)
            int row = 3 + i
            table.cell(smcTable, 0, row, mpRowLabel(sym), text_color=titleCol, text_size=size.small)
            table.cell(smcTable, 1, row, str.tostring(fuel) + "/" + str.tostring(smcMinFuelToShow), text_color=mpFuelColor(fuel), text_size=size.small)
            table.cell(smcTable, 2, row, "▲" + str.tostring(bull) + "/▼" + str.tostring(bear) + " r:" + (na(corrV) ? "n/a" : str.tostring(corrV, "#.##")), text_color=mpConfColor(bull, bear), text_size=size.small)

alertcondition(hudLongSetup, "HUD Setup: Long Bias", "Chart Confluence is bullish, Mag7 aligned bullish, VIX Confluence bearish. Go check the chart — wait for price to touch a key level before entering long.")
alertcondition(hudShortSetup, "HUD Setup: Short Bias", "Chart Confluence is bearish, Mag7 aligned bearish, VIX Confluence bullish. Go check the chart — wait for price to touch a key level before entering short.")
````
