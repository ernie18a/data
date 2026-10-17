# Gold Trading Assistant v1.0

- url: https://www.tradingview.com/script/ElmiVnkD-Gold-Trading-Assistant-v1-0/
- type: indicator
- pine_id: PUB;96b7cd1b2a2f4e64ad3df41981644b46
- version: 1.0

## Description

Gold Trading Assistant that help you to trad gold during different sessions and with the changes of the market

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
// 🎯 Gold Trading Assistant — V1.0 RELEASE
// ════════════════════════════════════════════════════════════════════════════
//   Pattern + MTF + Macro (Z-Score) + News + Confluence + Hybrid TPs
//   Tuned for Spot Gold (XAU/USD) on 15m timeframe
//   No-repaint protocol, structure-aware targets, A/B/C grading
// ════════════════════════════════════════════════════════════════════════════
indicator("Gold Trading Assistant v1.0", "GTA v1.0", overlay=true,
     max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                        PRESETS & THEME                                   ║
// ╚══════════════════════════════════════════════════════════════════════════╝
grpTheme = "🎨 Theme & Presets"
preset    = input.string("Balanced", "⚡ Preset", options=["Conservative", "Balanced", "Aggressive", "Custom"], group=grpTheme, tooltip="Conservative: A-grade only, strict filters | Balanced: default | Aggressive: more signals, lower threshold")
theme     = input.string("Dark",     "🎨 Theme",  options=["Dark", "Light"], group=grpTheme)
dashPos   = input.string("Top Right","📊 Dashboard Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpTheme)
dashSize  = input.string("Normal",   "📏 Dashboard Size",     options=["Compact", "Normal", "Detailed"], group=grpTheme)

// Theme colors
bgCol      = theme == "Dark" ? color.new(color.black, 15)  : color.new(color.white, 5)
textCol    = theme == "Dark" ? color.white : color.black
borderCol  = theme == "Dark" ? color.new(color.gray, 40) : color.new(color.gray, 60)
titleBg    = theme == "Dark" ? color.new(color.blue, 20)  : color.new(color.blue, 70)
headerBg   = theme == "Dark" ? color.new(color.purple, 40) : color.new(color.purple, 70)

// Dashboard position
dPos = dashPos == "Top Right"    ? position.top_right :
       dashPos == "Top Left"     ? position.top_left :
       dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left

// Apply presets (override custom values)
isConservative = preset == "Conservative"
isAggressive   = preset == "Aggressive"
isBalanced     = preset == "Balanced"

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                        SIGNAL GENERATION                                 ║
// ╚══════════════════════════════════════════════════════════════════════════╝

// ─── Patterns ──────────────────────────────────────────────────────────────
grpPat = "🕯️ Pattern Detection"
useEngulf  = input.bool(true, "Engulfing", group=grpPat)
engulfBodyIn = input.float(0.7, "Engulfing Body Ratio", minval=0.3, maxval=3.0, step=0.1, group=grpPat)
usePinBar  = input.bool(true, "Pin Bar / Hammer", group=grpPat)
pinRatioIn = input.float(1.5, "Pin Wick:Body Ratio", minval=1.2, maxval=4.0, step=0.1, group=grpPat)

engulfBody = isConservative ? 1.0 : isAggressive ? 0.5 : isBalanced ? 0.7 : engulfBodyIn
pinRatio   = isConservative ? 2.0 : isAggressive ? 1.3 : isBalanced ? 1.5 : pinRatioIn

// ─── MTF ───────────────────────────────────────────────────────────────────
grpMTF = "📊 Multi-Timeframe"
useMTF       = input.bool(true,  "Enable MTF", group=grpMTF)
htfTimeframe = input.timeframe("60", "Higher TF", group=grpMTF)
ltfTimeframe = input.timeframe("5",  "Lower TF",  group=grpMTF)
htfFastMA    = input.int(20, "HTF Fast EMA", minval=5, maxval=50, group=grpMTF)
htfSlowMA    = input.int(50, "HTF Slow EMA", minval=20, maxval=200, group=grpMTF)
mtfReqIn = input.bool(false, "Require Alignment", group=grpMTF)
mtfRequireAlignment = isConservative ? true : mtfReqIn

// ─── Macro ─────────────────────────────────────────────────────────────────
grpMacro = "🌍 Macro Filter (Auto)"
useMacro   = input.bool(true, "Enable Macro", group=grpMacro)
dxySym     = input.symbol("TVC:DXY",    "DXY",    group=grpMacro)
silverSym  = input.symbol("TVC:SILVER", "Silver", group=grpMacro)
yieldsSym  = input.symbol("TVC:US10Y",  "US10Y",  group=grpMacro)
macroTF    = input.timeframe("15", "Macro TF", group=grpMacro)
lookbackBars = input.int(96, "Lookback (bars)", minval=20, maxval=500, group=grpMacro)
zScorePeriod = input.int(100, "Z-Score Period", minval=20, maxval=500, group=grpMacro)
useZScore  = input.bool(true, "Use Z-Score (Adaptive)", group=grpMacro)
zStrongThr = input.float(2.0, "Z Strong Threshold", minval=1.0, maxval=4.0, step=0.1, group=grpMacro)
zMildThr   = input.float(1.0, "Z Mild Threshold",   minval=0.5, maxval=2.0, step=0.1, group=grpMacro)
macroReqIn = input.bool(false, "Block if Macro Opposes", group=grpMacro)
macroRequired = isConservative ? true : macroReqIn

// ─── News ──────────────────────────────────────────────────────────────────
grpNewsCfg = "📰 News Config"
useNews       = input.bool(true, "Enable News Filter", group=grpNewsCfg)
blackoutHigh  = input.int(30, "High Blackout (min)", minval=0, maxval=240, group=grpNewsCfg)
blackoutMed   = input.int(15, "Medium Blackout (min)", minval=0, maxval=120, group=grpNewsCfg)
blackoutLow   = input.int(5,  "Low Blackout (min)", minval=0, maxval=60, group=grpNewsCfg)
showNewsLines = input.bool(true, "Draw News Lines", group=grpNewsCfg)
showBlackout  = input.bool(true, "Shade Blackout Zones", group=grpNewsCfg)

grpN1 = "📰 News 1-5"
n01en = input.bool(false, "1", group=grpN1, inline="n1")
n01tm = input.time(timestamp("2026-05-28T12:30:00"), "Time", group=grpN1, inline="n1")
n01im = input.string("High", "", options=["High","Medium","Low"], group=grpN1, inline="n1")
n02en = input.bool(false, "2", group=grpN1, inline="n2")
n02tm = input.time(timestamp("2026-05-28T14:00:00"), "Time", group=grpN1, inline="n2")
n02im = input.string("Medium", "", options=["High","Medium","Low"], group=grpN1, inline="n2")
n03en = input.bool(false, "3", group=grpN1, inline="n3")
n03tm = input.time(timestamp("2026-05-29T12:30:00"), "Time", group=grpN1, inline="n3")
n03im = input.string("High", "", options=["High","Medium","Low"], group=grpN1, inline="n3")
n04en = input.bool(false, "4", group=grpN1, inline="n4")
n04tm = input.time(timestamp("2026-05-29T14:00:00"), "Time", group=grpN1, inline="n4")
n04im = input.string("Medium", "", options=["High","Medium","Low"], group=grpN1, inline="n4")
n05en = input.bool(false, "5", group=grpN1, inline="n5")
n05tm = input.time(timestamp("2026-05-29T18:00:00"), "Time", group=grpN1, inline="n5")
n05im = input.string("Low", "", options=["High","Medium","Low"], group=grpN1, inline="n5")

grpN2 = "📰 News 6-10"
n06en = input.bool(false, "6", group=grpN2, inline="n6")
n06tm = input.time(timestamp("2026-06-01T12:30:00"), "Time", group=grpN2, inline="n6")
n06im = input.string("High", "", options=["High","Medium","Low"], group=grpN2, inline="n6")
n07en = input.bool(false, "7", group=grpN2, inline="n7")
n07tm = input.time(timestamp("2026-06-01T14:00:00"), "Time", group=grpN2, inline="n7")
n07im = input.string("Medium", "", options=["High","Medium","Low"], group=grpN2, inline="n7")
n08en = input.bool(false, "8", group=grpN2, inline="n8")
n08tm = input.time(timestamp("2026-06-02T12:30:00"), "Time", group=grpN2, inline="n8")
n08im = input.string("High", "", options=["High","Medium","Low"], group=grpN2, inline="n8")
n09en = input.bool(false, "9", group=grpN2, inline="n9")
n09tm = input.time(timestamp("2026-06-03T18:00:00"), "Time", group=grpN2, inline="n9")
n09im = input.string("High", "", options=["High","Medium","Low"], group=grpN2, inline="n9")
n10en = input.bool(false, "10", group=grpN2, inline="n10")
n10tm = input.time(timestamp("2026-06-04T12:30:00"), "Time", group=grpN2, inline="n10")
n10im = input.string("Medium", "", options=["High","Medium","Low"], group=grpN2, inline="n10")

grpN3 = "📰 News 11-15"
n11en = input.bool(false, "11", group=grpN3, inline="n11")
n11tm = input.time(timestamp("2026-06-05T12:30:00"), "Time", group=grpN3, inline="n11")
n11im = input.string("High", "", options=["High","Medium","Low"], group=grpN3, inline="n11")
n12en = input.bool(false, "12", group=grpN3, inline="n12")
n12tm = input.time(timestamp("2026-06-05T14:00:00"), "Time", group=grpN3, inline="n12")
n12im = input.string("Medium", "", options=["High","Medium","Low"], group=grpN3, inline="n12")
n13en = input.bool(false, "13", group=grpN3, inline="n13")
n13tm = input.time(timestamp("2026-06-08T12:30:00"), "Time", group=grpN3, inline="n13")
n13im = input.string("Low", "", options=["High","Medium","Low"], group=grpN3, inline="n13")
n14en = input.bool(false, "14", group=grpN3, inline="n14")
n14tm = input.time(timestamp("2026-06-09T12:30:00"), "Time", group=grpN3, inline="n14")
n14im = input.string("High", "", options=["High","Medium","Low"], group=grpN3, inline="n14")
n15en = input.bool(false, "15", group=grpN3, inline="n15")
n15tm = input.time(timestamp("2026-06-10T18:00:00"), "Time", group=grpN3, inline="n15")
n15im = input.string("High", "", options=["High","Medium","Low"], group=grpN3, inline="n15")

// ─── Confluence ────────────────────────────────────────────────────────────
grpConf = "🎯 Confluence Scoring"
useConfluence = input.bool(true, "Enable Confluence Filter", group=grpConf)
minScoreIn    = input.int(45, "Min Score to Trigger (0-100)", minval=0, maxval=100, group=grpConf)
gradeAThr     = input.int(85, "Grade A threshold", minval=70, maxval=100, group=grpConf)
gradeBThr     = input.int(70, "Grade B threshold", minval=50, maxval=99,  group=grpConf)
showScoreLbl  = input.bool(true, "Show score label on signals", group=grpConf)

minScore = isConservative ? 70 : isAggressive ? 35 : isBalanced ? 45 : minScoreIn

// ─── Hybrid Targets ────────────────────────────────────────────────────────
grpHyb = "📐 Hybrid Targets"
useHybrid       = input.bool(true, "Enable Hybrid Targets", group=grpHyb)
useRoundNumbers = input.bool(true, "Use Round Numbers", group=grpHyb)
roundStep       = input.float(50.0, "Round Number Step", minval=10.0, maxval=200.0, group=grpHyb)
usePrevDay      = input.bool(true, "Use Prev Day H/L", group=grpHyb)
usePrevWeek     = input.bool(true, "Use Prev Week H/L", group=grpHyb)
useSwings       = input.bool(true, "Use Recent Swing H/L", group=grpHyb)
swingLookbackLR = input.int(5, "Swing Pivot L/R", minval=2, maxval=20, group=grpHyb)
structBufferPip = input.float(3.0, "Structure Buffer (pips)", minval=0.0, maxval=20.0, step=0.1, group=grpHyb)
minRRIn         = input.float(1.2, "Min R:R Required", minval=0.5, maxval=5.0, step=0.1, group=grpHyb)
showStructLines = input.bool(true, "Draw Structure Lines", group=grpHyb)
minRR = isConservative ? 2.0 : isAggressive ? 1.0 : isBalanced ? 1.2 : minRRIn

// ─── Volume ────────────────────────────────────────────────────────────────
grpVol = "📊 Volume"
useVolume = input.bool(false, "Use Volume Confirmation", group=grpVol, tooltip="Spot Gold volume unreliable on most brokers — keep OFF")
volMult   = input.float(1.3, "Volume Multiplier", minval=1.0, maxval=3.0, step=0.1, group=grpVol)

// ─── Risk ──────────────────────────────────────────────────────────────────
grpRisk = "💰 Risk Management"
atrPeriod = input.int(14, "ATR Period", minval=5, maxval=50, group=grpRisk)
atrSLMult = input.float(1.5, "SL ATR Mult", minval=0.5, maxval=5.0, step=0.1, group=grpRisk)
tp1RR     = input.float(1.5, "TP1 R:R", minval=0.5, maxval=10, step=0.1, group=grpRisk)
tp2RR     = input.float(2.5, "TP2 R:R", minval=1.0, maxval=10, step=0.1, group=grpRisk)
tp3RR     = input.float(4.0, "TP3 R:R", minval=1.0, maxval=20, step=0.1, group=grpRisk)
swingLen  = input.int(10, "SL Swing Lookback", minval=3, maxval=50, group=grpRisk)
slBuffer  = input.float(0.5, "SL Buffer (× ATR)", minval=0.0, maxval=2.0, step=0.1, group=grpRisk)

// ─── Filters ───────────────────────────────────────────────────────────────
grpFilt = "🔍 Entry Filters"
maxBodyATRIn  = input.float(1.5, "Max Body × ATR", minval=0.5, maxval=3.0, step=0.1, group=grpFilt)
recentMoveBars = input.int(5, "Recent Move Bars", minval=2, maxval=20, group=grpFilt)
recentMoveATRIn = input.float(5.0, "Max Recent Move × ATR", minval=1.0, maxval=10, step=0.1, group=grpFilt)
minBarsBetweenIn = input.int(4, "Min Bars Between Signals", minval=1, maxval=20, group=grpFilt)
maxBodyATR     = isConservative ? 1.0 : isAggressive ? 2.0 : isBalanced ? 1.5 : maxBodyATRIn
recentMoveATR  = isConservative ? 3.0 : isAggressive ? 7.0 : isBalanced ? 5.0 : recentMoveATRIn
minBarsBetween = isConservative ? 8   : isAggressive ? 2   : isBalanced ? 4   : minBarsBetweenIn

// ─── Mode ──────────────────────────────────────────────────────────────────
grpMode = "⚙️ Mode"
strictMode = input.bool(true, "Strict Mode (bar-close)", group=grpMode)
showDash   = input.bool(true, "Show Dashboard", group=grpMode)
showLines  = input.bool(true, "Show SL/TP Lines", group=grpMode)
showDebug  = input.bool(false, "🐛 Show Debug Markers", group=grpMode)

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                        CORE COMPUTATIONS                                 ║
// ╚══════════════════════════════════════════════════════════════════════════╝
atr = ta.atr(atrPeriod)
body   = math.abs(close - open)
bodyHi = math.max(close, open)
bodyLo = math.min(close, open)
upWick = high - bodyHi
dnWick = bodyLo - low
isBull = close > open
isBear = close < open

bullEngulf = useEngulf and isBull and close[1] < open[1] and close >= open[1] and open <= close[1] and body >= body[1] * engulfBody
bearEngulf = useEngulf and isBear and close[1] > open[1] and close <= open[1] and open >= close[1] and body >= body[1] * engulfBody
hammer       = usePinBar and dnWick >= body * pinRatio and upWick <= body * 0.5 and body > 0
shootingStar = usePinBar and upWick >= body * pinRatio and dnWick <= body * 0.5 and body > 0

bullPattern = bullEngulf or hammer
bearPattern = bearEngulf or shootingStar

volMA20 = ta.sma(volume, 20)
volOK   = not useVolume or volume >= volMA20 * volMult
volStrong = volume >= volMA20 * (volMult + 0.5)

notExtended     = body <= atr * maxBodyATR
recentRange     = ta.highest(high, recentMoveBars) - ta.lowest(low, recentMoveBars)
notOverextended = recentRange <= atr * recentMoveATR

var int lastSignalBar = -1000
barsSinceLast = bar_index - lastSignalBar
spacingOK = barsSinceLast >= minBarsBetween

// MTF
htfClose   = useMTF ? request.security(syminfo.tickerid, htfTimeframe, close[1], lookahead=barmerge.lookahead_off) : close
htfFastEMA = useMTF ? request.security(syminfo.tickerid, htfTimeframe, ta.ema(close, htfFastMA)[1], lookahead=barmerge.lookahead_off) : close
htfSlowEMA = useMTF ? request.security(syminfo.tickerid, htfTimeframe, ta.ema(close, htfSlowMA)[1], lookahead=barmerge.lookahead_off) : close
htfBullish = htfClose > htfFastEMA and htfFastEMA > htfSlowEMA
htfBearish = htfClose < htfFastEMA and htfFastEMA < htfSlowEMA
curFast = ta.ema(close, htfFastMA)
curSlow = ta.ema(close, htfSlowMA)
curBullish = close > curFast and curFast > curSlow
curBearish = close < curFast and curFast < curSlow
ltfClose   = useMTF ? request.security(syminfo.tickerid, ltfTimeframe, close[1], lookahead=barmerge.lookahead_off) : close
ltfFastEMA = useMTF ? request.security(syminfo.tickerid, ltfTimeframe, ta.ema(close, htfFastMA)[1], lookahead=barmerge.lookahead_off) : close
ltfBullish = ltfClose > ltfFastEMA
ltfBearish = ltfClose < ltfFastEMA
mtfBullAlign = (htfBullish ? 1 : 0) + (curBullish ? 1 : 0) + (ltfBullish ? 1 : 0)
mtfBearAlign = (htfBearish ? 1 : 0) + (curBearish ? 1 : 0) + (ltfBearish ? 1 : 0)
mtfBuyOK  = not useMTF or not mtfRequireAlignment or mtfBullAlign >= 2
mtfSellOK = not useMTF or not mtfRequireAlignment or mtfBearAlign >= 2

// Macro
[dxyNow, dxyPast] = request.security(dxySym,    macroTF, [close[1], close[lookbackBars + 1]], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[xagNow, xagPast] = request.security(silverSym, macroTF, [close[1], close[lookbackBars + 1]], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[yldNow, yldPast] = request.security(yieldsSym, macroTF, [close[1], close[lookbackBars + 1]], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
dxyOK = not na(dxyNow) and not na(dxyPast) and dxyPast != 0
xagOK = not na(xagNow) and not na(xagPast) and xagPast != 0
yldOK = not na(yldNow) and not na(yldPast)
macroAvailable = (dxyOK ? 1 : 0) + (xagOK ? 1 : 0) + (yldOK ? 1 : 0)
dxyRet = dxyOK ? (dxyNow - dxyPast) / dxyPast * 100 : 0.0
xagRet = xagOK ? (xagNow - xagPast) / xagPast * 100 : 0.0
yldBps = yldOK ? (yldNow - yldPast) * 100 : 0.0
dxyReturnSeries = request.security(dxySym,    macroTF, ((close[1] - close[lookbackBars + 1]) / close[lookbackBars + 1] * 100), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
xagReturnSeries = request.security(silverSym, macroTF, ((close[1] - close[lookbackBars + 1]) / close[lookbackBars + 1] * 100), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
yldChangeSeries = request.security(yieldsSym, macroTF, ((close[1] - close[lookbackBars + 1]) * 100), lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
dxyRetClean = nz(dxyReturnSeries)
xagRetClean = nz(xagReturnSeries)
yldRetClean = nz(yldChangeSeries)
dxyMean = ta.sma(dxyRetClean, zScorePeriod)
dxyStd  = ta.stdev(dxyRetClean, zScorePeriod)
xagMean = ta.sma(xagRetClean, zScorePeriod)
xagStd  = ta.stdev(xagRetClean, zScorePeriod)
yldMean = ta.sma(yldRetClean, zScorePeriod)
yldStd  = ta.stdev(yldRetClean, zScorePeriod)
dxyZ = dxyStd > 0 ? (dxyRet - dxyMean) / dxyStd : 0.0
xagZ = xagStd > 0 ? (xagRet - xagMean) / xagStd : 0.0
yldZ = yldStd > 0 ? (yldBps - yldMean) / yldStd : 0.0
dxySignal = useZScore ? (dxyZ <= -zStrongThr ? 2 : dxyZ <= -zMildThr ? 1 : dxyZ >= zStrongThr ? -2 : dxyZ >= zMildThr ? -1 : 0) : (dxyRet <= -0.5 ? 2 : dxyRet <= -0.2 ? 1 : dxyRet >= 0.5 ? -2 : dxyRet >= 0.2 ? -1 : 0)
xagSignal = useZScore ? (xagZ >= zStrongThr ? 2 : xagZ >= zMildThr ? 1 : xagZ <= -zStrongThr ? -2 : xagZ <= -zMildThr ? -1 : 0) : (xagRet >= 1.0 ? 2 : xagRet >= 0.3 ? 1 : xagRet <= -1.0 ? -2 : xagRet <= -0.3 ? -1 : 0)
yldSignal = useZScore ? (yldZ <= -zStrongThr ? 2 : yldZ <= -zMildThr ? 1 : yldZ >= zStrongThr ? -2 : yldZ >= zMildThr ? -1 : 0) : (yldBps <= -25 ? 2 : yldBps <= -10 ? 1 : yldBps >= 25 ? -2 : yldBps >= 10 ? -1 : 0)
macroRawScore = (dxyOK ? dxySignal * 1.0 : 0) + (xagOK ? xagSignal * 1.2 : 0) + (yldOK ? yldSignal * 0.8 : 0)
macroMaxAbs   = (dxyOK ? 2.0 : 0) + (xagOK ? 2.4 : 0) + (yldOK ? 1.6 : 0)
macroPct      = macroMaxAbs > 0 ? macroRawScore / macroMaxAbs : 0.0
macroBuyScore  = macroPct > 0 ? macroPct * 20 : 0.0
macroSellScore = macroPct < 0 ? -macroPct * 20 : 0.0
macroMode = not useMacro ? "OFF" : macroAvailable == 3 ? "FULL" : macroAvailable >= 1 ? "PARTIAL" : "NONE"
macroBuyOK  = not useMacro or not macroRequired or macroPct >= 0
macroSellOK = not useMacro or not macroRequired or macroPct <= 0

// News
enArr = array.from(n01en, n02en, n03en, n04en, n05en, n06en, n07en, n08en, n09en, n10en, n11en, n12en, n13en, n14en, n15en)
tmArr = array.from(n01tm, n02tm, n03tm, n04tm, n05tm, n06tm, n07tm, n08tm, n09tm, n10tm, n11tm, n12tm, n13tm, n14tm, n15tm)
imArr = array.from(n01im, n02im, n03im, n04im, n05im, n06im, n07im, n08im, n09im, n10im, n11im, n12im, n13im, n14im, n15im)

f_blackoutMs(string imp) =>
    int mins = imp == "High" ? blackoutHigh : imp == "Medium" ? blackoutMed : blackoutLow
    mins * 60000

var bool   _inBlack    = false
var string _activeImp  = ""
var float  _minsToNext = -1.0
var string _nextImp    = ""
var int    _enabledCnt = 0
_inBlack    := false
_activeImp  := ""
_minsToNext := -1.0
_nextImp    := ""
_enabledCnt := 0
if useNews
    for i = 0 to 14
        if array.get(enArr, i)
            _enabledCnt += 1
            et = array.get(tmArr, i)
            im = array.get(imArr, i)
            bms = f_blackoutMs(im)
            if math.abs(time - et) <= bms
                _inBlack := true
                rank = im == "High" ? 3 : im == "Medium" ? 2 : 1
                cur  = _activeImp == "High" ? 3 : _activeImp == "Medium" ? 2 : _activeImp == "Low" ? 1 : 0
                if rank > cur
                    _activeImp := im
            if et > time
                m = (et - time) / 60000.0
                if _minsToNext < 0 or m < _minsToNext
                    _minsToNext := m
                    _nextImp    := im
newsBlackout = useNews and _inBlack
newsBuyOK    = not newsBlackout
newsSellOK   = not newsBlackout
newsClearBonus = useNews and (not newsBlackout) and (_minsToNext < 0 or _minsToNext > 60)

// Structure
pdh = usePrevDay  ? request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off) : na
pdl = usePrevDay  ? request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_off) : na
pwh = usePrevWeek ? request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_off) : na
pwl = usePrevWeek ? request.security(syminfo.tickerid, "W", low[1],  lookahead=barmerge.lookahead_off) : na
swingPivotHi = useSwings ? ta.pivothigh(high, swingLookbackLR, swingLookbackLR) : na
swingPivotLo = useSwings ? ta.pivotlow(low,  swingLookbackLR, swingLookbackLR) : na
var float lastSwingHi1 = na
var float lastSwingHi2 = na
var float lastSwingLo1 = na
var float lastSwingLo2 = na
if not na(swingPivotHi)
    lastSwingHi2 := lastSwingHi1
    lastSwingHi1 := swingPivotHi
if not na(swingPivotLo)
    lastSwingLo2 := lastSwingLo1
    lastSwingLo1 := swingPivotLo

f_nearestAbove(float fromPx, float upToPx) =>
    float best = na
    if usePrevDay and not na(pdh) and pdh > fromPx and pdh <= upToPx and (na(best) or pdh < best)
        best := pdh
    if usePrevWeek and not na(pwh) and pwh > fromPx and pwh <= upToPx and (na(best) or pwh < best)
        best := pwh
    if useSwings and not na(lastSwingHi1) and lastSwingHi1 > fromPx and lastSwingHi1 <= upToPx and (na(best) or lastSwingHi1 < best)
        best := lastSwingHi1
    if useSwings and not na(lastSwingHi2) and lastSwingHi2 > fromPx and lastSwingHi2 <= upToPx and (na(best) or lastSwingHi2 < best)
        best := lastSwingHi2
    if useRoundNumbers
        nrAbove = math.ceil(fromPx / roundStep) * roundStep
        if nrAbove > fromPx and nrAbove <= upToPx and (na(best) or nrAbove < best)
            best := nrAbove
    best

f_nearestBelow(float fromPx, float downToPx) =>
    float best = na
    if usePrevDay and not na(pdl) and pdl < fromPx and pdl >= downToPx and (na(best) or pdl > best)
        best := pdl
    if usePrevWeek and not na(pwl) and pwl < fromPx and pwl >= downToPx and (na(best) or pwl > best)
        best := pwl
    if useSwings and not na(lastSwingLo1) and lastSwingLo1 < fromPx and lastSwingLo1 >= downToPx and (na(best) or lastSwingLo1 > best)
        best := lastSwingLo1
    if useSwings and not na(lastSwingLo2) and lastSwingLo2 < fromPx and lastSwingLo2 >= downToPx and (na(best) or lastSwingLo2 > best)
        best := lastSwingLo2
    if useRoundNumbers
        nrBelow = math.floor(fromPx / roundStep) * roundStep
        if nrBelow < fromPx and nrBelow >= downToPx and (na(best) or nrBelow > best)
            best := nrBelow
    best

nearStructAbove = f_nearestAbove(close, close + atr * 1.0)
nearStructBelow = f_nearestBelow(close, close - atr * 1.0)
structNearBuy   = not na(nearStructBelow)
structNearSell  = not na(nearStructAbove)

// SL/TP Hybrid
swingLow  = ta.lowest(low,  swingLen)
swingHigh = ta.highest(high, swingLen)
buf       = structBufferPip * 0.01
buyEntry  = close
buySL     = math.min(swingLow - atr * slBuffer, close - atr * atrSLMult)
buyRisk   = buyEntry - buySL
buyATPa1  = buyEntry + buyRisk * tp1RR
buyATPa2  = buyEntry + buyRisk * tp2RR
buyATPa3  = buyEntry + buyRisk * tp3RR
struct_buy1 = useHybrid ? f_nearestAbove(buyEntry, buyATPa1) : na
struct_buy2 = useHybrid ? f_nearestAbove(buyEntry, buyATPa2) : na
struct_buy3 = useHybrid ? f_nearestAbove(buyEntry, buyATPa3) : na
buyTP1 = not na(struct_buy1) ? struct_buy1 - buf : buyATPa1
buyTP2_cand = not na(struct_buy2) and struct_buy2 - buf > buyTP1 ? struct_buy2 - buf : buyATPa2
buyTP2 = math.max(buyTP2_cand, buyTP1 + atr * 0.3)
buyTP3_cand = not na(struct_buy3) and struct_buy3 - buf > buyTP2 ? struct_buy3 - buf : buyATPa3
buyTP3 = math.max(buyTP3_cand, buyTP2 + atr * 0.5)
buyR1 = buyRisk > 0 ? (buyTP1 - buyEntry) / buyRisk : 0.0
buyRROK = buyR1 >= minRR

sellEntry = close
sellSL    = math.max(swingHigh + atr * slBuffer, close + atr * atrSLMult)
sellRisk  = sellSL - sellEntry
sellATPa1 = sellEntry - sellRisk * tp1RR
sellATPa2 = sellEntry - sellRisk * tp2RR
sellATPa3 = sellEntry - sellRisk * tp3RR
struct_sell1 = useHybrid ? f_nearestBelow(sellEntry, sellATPa1) : na
struct_sell2 = useHybrid ? f_nearestBelow(sellEntry, sellATPa2) : na
struct_sell3 = useHybrid ? f_nearestBelow(sellEntry, sellATPa3) : na
sellTP1 = not na(struct_sell1) ? struct_sell1 + buf : sellATPa1
sellTP2_cand = not na(struct_sell2) and struct_sell2 + buf < sellTP1 ? struct_sell2 + buf : sellATPa2
sellTP2 = math.min(sellTP2_cand, sellTP1 - atr * 0.3)
sellTP3_cand = not na(struct_sell3) and struct_sell3 + buf < sellTP2 ? struct_sell3 + buf : sellATPa3
sellTP3 = math.min(sellTP3_cand, sellTP2 - atr * 0.5)
sellR1 = sellRisk > 0 ? (sellEntry - sellTP1) / sellRisk : 0.0
sellRROK = sellR1 >= minRR

// Confluence
patternScore = 25
mtfBuyScore100  = mtfBullAlign == 3 ? 25 : mtfBullAlign == 2 ? 15 : mtfBullAlign == 1 ? 7 : 0
mtfSellScore100 = mtfBearAlign == 3 ? 25 : mtfBearAlign == 2 ? 15 : mtfBearAlign == 1 ? 7 : 0
volScore = volStrong ? 10 : volOK ? 5 : 0
structScoreBuy  = structNearBuy  ? 10 : 0
structScoreSell = structNearSell ? 10 : 0
emaSlope    = (curFast - curFast[5]) / atr
trendBuyScore  = emaSlope > 0.3 ? 5 : emaSlope > 0.1 ? 3 : 0
trendSellScore = emaSlope < -0.3 ? 5 : emaSlope < -0.1 ? 3 : 0
newsScore = newsClearBonus ? 5 : 0
buyConfluence  = patternScore + mtfBuyScore100  + macroBuyScore  + volScore + structScoreBuy  + trendBuyScore  + newsScore
sellConfluence = patternScore + mtfSellScore100 + macroSellScore + volScore + structScoreSell + trendSellScore + newsScore
f_grade(float s) =>
    s >= gradeAThr ? "A" : s >= gradeBThr ? "B" : s >= minScore ? "C" : "—"
buyGrade  = f_grade(buyConfluence)
sellGrade = f_grade(sellConfluence)
confluenceBuyOK  = not useConfluence or buyConfluence  >= minScore
confluenceSellOK = not useConfluence or sellConfluence >= minScore

// Final signal
confirmed = not strictMode or barstate.isconfirmed
rawBuy  = bullPattern and volOK and notExtended and notOverextended and spacingOK and confirmed
rawSell = bearPattern and volOK and notExtended and notOverextended and spacingOK and confirmed
buySignal  = rawBuy  and mtfBuyOK  and macroBuyOK  and newsBuyOK  and confluenceBuyOK  and buyRROK
sellSignal = rawSell and mtfSellOK and macroSellOK and newsSellOK and confluenceSellOK and sellRROK
if buySignal or sellSignal
    lastSignalBar := bar_index

// Debug
patternFormed = bullPattern or bearPattern
string blockReason = ""
if patternFormed and not buySignal and not sellSignal
    if not confirmed
        blockReason := "C"
    else if not volOK
        blockReason := "V"
    else if not notExtended
        blockReason := "X"
    else if not notOverextended
        blockReason := "M"
    else if not spacingOK
        blockReason := "S"
    else if bullPattern and not mtfBuyOK
        blockReason := "T"
    else if bearPattern and not mtfSellOK
        blockReason := "T"
    else if bullPattern and not macroBuyOK
        blockReason := "A"
    else if bearPattern and not macroSellOK
        blockReason := "A"
    else if not newsBuyOK
        blockReason := "N"
    else if bullPattern and not confluenceBuyOK
        blockReason := "F"
    else if bearPattern and not confluenceSellOK
        blockReason := "F"
    else if bullPattern and not buyRROK
        blockReason := "R"
    else if bearPattern and not sellRROK
        blockReason := "R"

if showDebug and patternFormed and blockReason != ""
    label.new(bar_index, bullPattern ? low - atr * 0.4 : high + atr * 0.4, blockReason,
       color=color.new(color.gray, 30),
       style=bullPattern ? label.style_label_up : label.style_label_down,
       textcolor=color.white, size=size.tiny,
       tooltip="C=not Closed | V=Volume | X=eXtended | M=recent Move | S=Spacing | T=mTF | A=mAcro | N=News | F=conFluence | R=R:R")

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                        VISUAL OUTPUT                                     ║
// ╚══════════════════════════════════════════════════════════════════════════╝
plotshape(buySignal,  "BUY",  shape.triangleup,   location.belowbar, color.new(color.green, 0), size=size.normal, text="BUY")
plotshape(sellSignal, "SELL", shape.triangledown, location.abovebar, color.new(color.red,   0), size=size.normal, text="SELL")

if buySignal and showScoreLbl
    gradeBg = buyGrade == "A" ? color.new(color.green, 10) : buyGrade == "B" ? color.new(color.green, 30) : color.new(color.olive, 30)
    label.new(bar_index, low - atr * 0.5,
       "🟢 BUY  [" + buyGrade + "]" +
       "\n@ " + str.tostring(buyEntry, "#.##") +
       "\nSL: "  + str.tostring(buySL,  "#.##") +
       "\nTP1: " + str.tostring(buyTP1, "#.##") + " (" + str.tostring(buyR1, "0.0") + "R)" +
       "\nTP2: " + str.tostring(buyTP2, "#.##") +
       "\nTP3: " + str.tostring(buyTP3, "#.##") +
       "\n🎯 " + str.tostring(buyConfluence, "0") + "/100",
       color=gradeBg, style=label.style_label_up, textcolor=color.white, size=size.small)

if sellSignal and showScoreLbl
    gradeBg = sellGrade == "A" ? color.new(color.red, 10) : sellGrade == "B" ? color.new(color.red, 30) : color.new(color.maroon, 30)
    label.new(bar_index, high + atr * 0.5,
       "🔴 SELL [" + sellGrade + "]" +
       "\n@ " + str.tostring(sellEntry, "#.##") +
       "\nSL: "  + str.tostring(sellSL,  "#.##") +
       "\nTP1: " + str.tostring(sellTP1, "#.##") + " (" + str.tostring(sellR1, "0.0") + "R)" +
       "\nTP2: " + str.tostring(sellTP2, "#.##") +
       "\nTP3: " + str.tostring(sellTP3, "#.##") +
       "\n🎯 " + str.tostring(sellConfluence, "0") + "/100",
       color=gradeBg, style=label.style_label_down, textcolor=color.white, size=size.small)

if showLines and buySignal
    line.new(bar_index, buyEntry, bar_index + 20, buyEntry, color=color.gray, width=1)
    line.new(bar_index, buySL,    bar_index + 20, buySL,    color=color.red,  width=2)
    line.new(bar_index, buyTP1,   bar_index + 20, buyTP1,   color=color.new(color.green, 50), width=1)
    line.new(bar_index, buyTP2,   bar_index + 20, buyTP2,   color=color.new(color.green, 30), width=1)
    line.new(bar_index, buyTP3,   bar_index + 20, buyTP3,   color=color.new(color.green, 0),  width=2)

if showLines and sellSignal
    line.new(bar_index, sellEntry, bar_index + 20, sellEntry, color=color.gray, width=1)
    line.new(bar_index, sellSL,    bar_index + 20, sellSL,    color=color.red,  width=2)
    line.new(bar_index, sellTP1,   bar_index + 20, sellTP1,   color=color.new(color.green, 50), width=1)
    line.new(bar_index, sellTP2,   bar_index + 20, sellTP2,   color=color.new(color.green, 30), width=1)
    line.new(bar_index, sellTP3,   bar_index + 20, sellTP3,   color=color.new(color.green, 0),  width=2)

// News lines + blackout boxes
var line[] newsLines = array.new<line>(15, na)
var box[]  newsBoxes = array.new<box>(15, na)
if barstate.islast
    for i = 0 to 14
        L = array.get(newsLines, i)
        B = array.get(newsBoxes, i)
        if not na(L)
            line.delete(L)
        if not na(B)
            box.delete(B)
        array.set(newsLines, i, na)
        array.set(newsBoxes, i, na)
        if useNews and array.get(enArr, i)
            et = array.get(tmArr, i)
            im = array.get(imArr, i)
            lc = im == "High" ? color.red : im == "Medium" ? color.orange : color.yellow
            if showNewsLines
                ln = line.new(et, low - atr * 10, et, high + atr * 10, xloc=xloc.bar_time, color=lc, style=line.style_dashed, width=1)
                array.set(newsLines, i, ln)
            if showBlackout
                bms = f_blackoutMs(im)
                bx = box.new(et - bms, high + atr * 10, et + bms, low - atr * 10, xloc=xloc.bar_time, bgcolor=color.new(lc, 88), border_color=color.new(lc, 60), border_width=1)
                array.set(newsBoxes, i, bx)

// Structure lines
var line lnPdh = na
var line lnPdl = na
var line lnPwh = na
var line lnPwl = na
if barstate.islast and showStructLines
    if not na(lnPdh)
        line.delete(lnPdh)
    if not na(lnPdl)
        line.delete(lnPdl)
    if not na(lnPwh)
        line.delete(lnPwh)
    if not na(lnPwl)
        line.delete(lnPwl)
    if usePrevDay and not na(pdh)
        lnPdh := line.new(bar_index - 50, pdh, bar_index + 5, pdh, color=color.new(color.aqua, 40), style=line.style_dotted, width=1)
    if usePrevDay and not na(pdl)
        lnPdl := line.new(bar_index - 50, pdl, bar_index + 5, pdl, color=color.new(color.aqua, 40), style=line.style_dotted, width=1)
    if usePrevWeek and not na(pwh)
        lnPwh := line.new(bar_index - 100, pwh, bar_index + 5, pwh, color=color.new(color.fuchsia, 30), style=line.style_dashed, width=1)
    if usePrevWeek and not na(pwl)
        lnPwl := line.new(bar_index - 100, pwl, bar_index + 5, pwl, color=color.new(color.fuchsia, 30), style=line.style_dashed, width=1)

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                        DASHBOARD                                         ║
// ╚══════════════════════════════════════════════════════════════════════════╝
if showDash and barstate.islast
    nRows = dashSize == "Compact" ? 8 : dashSize == "Detailed" ? 20 : 14
    var table dash = table.new(dPos, 2, 20, bgcolor=bgCol, border_width=1, border_color=borderCol)
    
    // ─── Header ─────────────────────────────────────
    table.cell(dash, 0, 0, "🎯 GTA v1.0", bgcolor=titleBg, text_color=textCol, text_size=size.normal)
    table.cell(dash, 1, 0, "🎨 " + preset, bgcolor=titleBg, text_color=textCol, text_size=size.small)
    
    // ─── Confluence Bar (always visible) ─────────────
    bestSide   = buyConfluence >= sellConfluence ? "BUY"  : "SELL"
    bestScore  = math.max(buyConfluence, sellConfluence)
    bestGrade  = bestSide == "BUY" ? buyGrade : sellGrade
    bestEmoji  = bestGrade == "A" ? "💎" : bestGrade == "B" ? "✅" : bestGrade == "C" ? "⚡" : "○"
    bestBg     = bestGrade == "A" ? color.new(color.green, 20) : bestGrade == "B" ? color.new(color.green, 50) : bestGrade == "C" ? color.new(color.yellow, 60) : color.new(color.gray, 70)
    table.cell(dash, 0, 1, "🎯 Live", text_color=textCol, text_size=size.small)
    table.cell(dash, 1, 1, bestEmoji + " " + bestSide + " " + str.tostring(bestScore, "0") + " [" + bestGrade + "]", bgcolor=bestBg, text_color=color.white, text_size=size.small)
    
    if dashSize != "Compact"
        // ─── MTF ─────────────────────────────────────
        htfTxt = (htfBullish ? "▲" : htfBearish ? "▼" : "─") + (curBullish ? "▲" : curBearish ? "▼" : "─") + (ltfBullish ? "▲" : ltfBearish ? "▼" : "─")
        mtfBest100 = math.max(mtfBuyScore100, mtfSellScore100)
        mtfBg = mtfBullAlign == 3 ? color.new(color.green, 40) : mtfBearAlign == 3 ? color.new(color.red, 40) : color.new(color.gray, 60)
        table.cell(dash, 0, 2, "📊 MTF", text_color=textCol, text_size=size.small)
        table.cell(dash, 1, 2, htfTxt + " " + str.tostring(mtfBest100, "#") + "/25", bgcolor=mtfBg, text_color=color.white, text_size=size.small)
        
        // ─── Macro ───────────────────────────────────
        macroNetTxt = macroPct > 0.3 ? "🟢 BULL" : macroPct > 0.1 ? "🟢 mild" : macroPct < -0.3 ? "🔴 BEAR" : macroPct < -0.1 ? "🔴 mild" : "─ neutral"
        macroBg = macroPct > 0.1 ? color.new(color.green, 50) : macroPct < -0.1 ? color.new(color.red, 50) : color.new(color.gray, 60)
        table.cell(dash, 0, 3, "🌍 Macro " + macroMode, text_color=textCol, text_size=size.small)
        table.cell(dash, 1, 3, macroNetTxt + " " + str.tostring(macroPct * 100, "0") + "%", bgcolor=macroBg, text_color=color.white, text_size=size.small)
        
        // ─── News ────────────────────────────────────
        newsTxt = newsBlackout ? "🚫 " + _activeImp : useNews ? "✓ Clear" : "OFF"
        newsBg = newsBlackout ? color.new(color.red, 40) : useNews ? color.new(color.green, 60) : color.new(color.gray, 70)
        table.cell(dash, 0, 4, "📰 News (" + str.tostring(_enabledCnt) + ")", text_color=textCol, text_size=size.small)
        table.cell(dash, 1, 4, newsTxt, bgcolor=newsBg, text_color=color.white, text_size=size.small)
        
        // ─── Structure ───────────────────────────────
        nearTxt = not na(nearStructBelow) ? "↓" + str.tostring(nearStructBelow, "#.0") : not na(nearStructAbove) ? "↑" + str.tostring(nearStructAbove, "#.0") : "—"
        table.cell(dash, 0, 5, "📐 " + (useHybrid ? "Hybrid" : "ATR"), text_color=textCol, text_size=size.small)
        table.cell(dash, 1, 5, nearTxt, bgcolor=color.new(color.aqua, 60), text_color=color.white, text_size=size.small)
    
    if dashSize == "Detailed"
        // Full macro breakdown
        table.cell(dash, 0, 6, "DXY " + (dxyOK ? "✓" : "✗"), text_color=textCol, text_size=size.small)
        dxyTxt = dxyOK ? str.tostring(dxyRet, "+0.00") + "% z" + str.tostring(dxyZ, "+0.0") : "N/A"
        table.cell(dash, 1, 6, dxyTxt, bgcolor=dxySignal > 0 ? color.new(color.green, 60) : dxySignal < 0 ? color.new(color.red, 60) : color.new(color.gray, 60), text_color=color.white, text_size=size.small)
        table.cell(dash, 0, 7, "Silver " + (xagOK ? "✓" : "✗"), text_color=textCol, text_size=size.small)
        xagTxt = xagOK ? str.tostring(xagRet, "+0.00") + "% z" + str.tostring(xagZ, "+0.0") : "N/A"
        table.cell(dash, 1, 7, xagTxt, bgcolor=xagSignal > 0 ? color.new(color.green, 60) : xagSignal < 0 ? color.new(color.red, 60) : color.new(color.gray, 60), text_color=color.white, text_size=size.small)
        table.cell(dash, 0, 8, "US10Y " + (yldOK ? "✓" : "✗"), text_color=textCol, text_size=size.small)
        yldTxt = yldOK ? str.tostring(yldBps, "+0.0") + "bps z" + str.tostring(yldZ, "+0.0") : "N/A"
        table.cell(dash, 1, 8, yldTxt, bgcolor=yldSignal > 0 ? color.new(color.green, 60) : yldSignal < 0 ? color.new(color.red, 60) : color.new(color.gray, 60), text_color=color.white, text_size=size.small)
        table.cell(dash, 0, 9, "PDH/PDL", text_color=textCol, text_size=size.small)
        pdTxt = not na(pdh) and not na(pdl) ? str.tostring(pdh, "#.#") + " / " + str.tostring(pdl, "#.#") : "N/A"
        table.cell(dash, 1, 9, pdTxt, text_color=textCol, text_size=size.small)
        table.cell(dash, 0, 10, "PWH/PWL", text_color=textCol, text_size=size.small)
        pwTxt = not na(pwh) and not na(pwl) ? str.tostring(pwh, "#.#") + " / " + str.tostring(pwl, "#.#") : "N/A"
        table.cell(dash, 1, 10, pwTxt, text_color=textCol, text_size=size.small)
        table.cell(dash, 0, 11, "Vol Filter", text_color=textCol, text_size=size.small)
        volTxt = not useVolume ? "OFF" : volStrong ? "💪 Strong" : volOK ? "✓ OK" : "✗ LOW"
        volBg  = not useVolume ? color.new(color.gray, 70) : volStrong ? color.new(color.green, 40) : volOK ? color.new(color.green, 60) : color.new(color.red, 60)
        table.cell(dash, 1, 11, volTxt, bgcolor=volBg, text_color=color.white, text_size=size.small)
        table.cell(dash, 0, 12, "ATR", text_color=textCol, text_size=size.small)
        table.cell(dash, 1, 12, str.tostring(atr, "#.##"), text_color=textCol, text_size=size.small)
        table.cell(dash, 0, 13, "Bars Since", text_color=textCol, text_size=size.small)
        table.cell(dash, 1, 13, str.tostring(barsSinceLast), text_color=textCol, text_size=size.small)
    
    // Always show bottom status
    statusRow = dashSize == "Compact" ? 2 : dashSize == "Normal" ? 6 : 14
    table.cell(dash, 0, statusRow, strictMode ? "🔒 Strict" : "⚡ Fast", bgcolor=color.new(color.blue, 60), text_color=textCol, text_size=size.tiny)
    table.cell(dash, 1, statusRow, "📊 " + timeframe.period + " | " + syminfo.ticker, bgcolor=color.new(color.blue, 60), text_color=textCol, text_size=size.tiny)

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                        ALERTS                                            ║
// ╚══════════════════════════════════════════════════════════════════════════╝
if buySignal
    alert("🟢 GOLD BUY [" + buyGrade + "] @ " + str.tostring(buyEntry, "#.##") + " | SL: " + str.tostring(buySL, "#.##") + " | TP: " + str.tostring(buyTP1, "#.##") + "/" + str.tostring(buyTP2, "#.##") + "/" + str.tostring(buyTP3, "#.##") + " | Conf: " + str.tostring(buyConfluence, "0") + "/100 | R: " + str.tostring(buyR1, "0.0"), alert.freq_once_per_bar_close)
if sellSignal
    alert("🔴 GOLD SELL [" + sellGrade + "] @ " + str.tostring(sellEntry, "#.##") + " | SL: " + str.tostring(sellSL, "#.##") + " | TP: " + str.tostring(sellTP1, "#.##") + "/" + str.tostring(sellTP2, "#.##") + "/" + str.tostring(sellTP3, "#.##") + " | Conf: " + str.tostring(sellConfluence, "0") + "/100 | R: " + str.tostring(sellR1, "0.0"), alert.freq_once_per_bar_close)

// Granular alertconditions for per-grade alerts
alertcondition(buySignal,  "GTA Buy (any grade)",  "Gold Buy")
alertcondition(sellSignal, "GTA Sell (any grade)", "Gold Sell")
alertcondition(buySignal  and buyGrade  == "A", "GTA Buy Grade A",  "Gold A-Grade Buy 💎")
alertcondition(sellSignal and sellGrade == "A", "GTA Sell Grade A", "Gold A-Grade Sell 💎")
alertcondition(buySignal  and buyGrade  == "B", "GTA Buy Grade B",  "Gold B-Grade Buy ✅")
alertcondition(sellSignal and sellGrade == "B", "GTA Sell Grade B", "Gold B-Grade Sell ✅")
alertcondition(newsBlackout and not newsBlackout[1], "News Blackout Start", "📰 News blackout window starting")
alertcondition(not newsBlackout and newsBlackout[1], "News Blackout End",   "📰 News blackout window ended")
````
