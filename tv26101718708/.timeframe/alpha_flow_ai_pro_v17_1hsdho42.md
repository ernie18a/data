# Alpha Flow AI Pro V17

- url: https://www.tradingview.com/script/1HSdHo42-Alpha-Flow-AI-Pro-V17/
- type: indicator
- pine_id: PUB;a2ce7d10f63c4d25bdbe39b54b72711b
- version: 3.0

## Description

Alpha Flow AI Pro is an all-in-one trading assistant that combines multi-timeframe trend analysis, smart money concepts and automated risk management.

It gives clear buy and sell signals with a confidence score, dynamic support and resistance zones, trading session tracking, and automatic take profit and stop loss levels with lot size calculation for any account size.

Main features:
- 8 factor AI confidence engine with multi-timeframe confirmation
- Automatic TP1, TP2, TP3 and Stop Loss with live profit tracking
- Smart lot size calculation for forex, indices and gold
- Dynamic support and resistance with session overlays
- Clean all-in-one dashboard

Works on all markets and timeframes. For educational purposes only, not financial advice.

## Source Code

````pine
//@version=6
indicator("Alpha Flow AI™ Pro V17", shorttitle="AF-AI V17", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500, dynamic_requests=true, format=format.price, precision=0)

//══════════════════════════════════════════════════════════════════════════════
//                          ⚙️ EINSTELLUNGEN
//══════════════════════════════════════════════════════════════════════════════

grpAI = "🤖 KI-ENGINE"
fastLength = input.int(7, "Schnell", minval=2, maxval=50, group=grpAI, inline="ma")
slowLength = input.int(14, "Mittel", minval=5, maxval=100, group=grpAI, inline="ma")
superSlowLength = input.int(28, "Langsam", minval=10, maxval=200, group=grpAI, inline="ma")
minConfidence = input.int(60, "Min. Konfidenz %", minval=0, maxval=100, group=grpAI)

grpFilter = "🎯 SIGNAL FILTER"
perfectSetupOnly = input.bool(false, "✨ Nur PERFEKTE Setups", group=grpFilter, tooltip="Zeigt nur Signale wenn ALLE Bedingungen erfüllt sind:\n• KI ≥ 70%\n• MTF ≥ 3/4\n• ADX > 25\n• Trail stützt\n• London/Overlap Session")
requireMinConf = input.int(70, "Min. KI-Konfidenz", minval=50, maxval=95, group=grpFilter)
requireMinMTF = input.int(3, "Min. MTF Übereinstimmung", minval=1, maxval=4, group=grpFilter)
requireMinADX = input.int(25, "Min. ADX Stärke", minval=15, maxval=50, group=grpFilter)
requireTrailConfirm = input.bool(true, "Trail muss stützen", group=grpFilter)
requireGoodSession = input.bool(true, "Nur London/Overlap", group=grpFilter)

grpSignals = "📡 SIGNALE"
showPremiumSignals = input.bool(true, "Premium ⭐", group=grpSignals, inline="sig")
showStandardSignals = input.bool(true, "Standard", group=grpSignals, inline="sig")
showReversalSignals = input.bool(true, "Umkehr", group=grpSignals, inline="sig")

grpSMC = "🏦 SMART MONEY CONCEPTS"
showSupportResistance = input.bool(true, "Support/Resistance Zonen", group=grpSMC)
showDynamicSR = input.bool(true, "Dynamische S/R Intensität", group=grpSMC)
showOrderBlocks = input.bool(false, "Order Blocks", group=grpSMC)
showFVG = input.bool(false, "Fair Value Gaps (FVG)", group=grpSMC)
showSwingStructure = input.bool(false, "Swing Structure (HH/HL/LL/LH)", group=grpSMC)
showBOS = input.bool(false, "Break of Structure (BOS)", group=grpSMC)
showDivergences = input.bool(true, "RSI Divergenzen", group=grpSMC, tooltip="Erkennt bullische/bärische Divergenzen zwischen Preis und RSI (Umkehr-Frühwarnung)")

grpHTF = "📐 HÖHERE ZEITRAHMEN S/R"
showHTFLevels = input.bool(true, "Levels anzeigen", group=grpHTF)
htfTF1 = input.timeframe("60", "Zeitrahmen 1", group=grpHTF, inline="htf1")
htfTF1Color = input.color(#3B82F6, "", group=grpHTF, inline="htf1")
htfTF2 = input.timeframe("240", "Zeitrahmen 2", group=grpHTF, inline="htf2")
htfTF2Color = input.color(#F59E0B, "", group=grpHTF, inline="htf2")
htfTF3 = input.timeframe("D", "Zeitrahmen 3", group=grpHTF, inline="htf3")
htfTF3Color = input.color(#EF4444, "", group=grpHTF, inline="htf3")
htfLookback = input.int(50, "Lookback Kerzen", minval=10, maxval=200, group=grpHTF)

grpOverlays = "🎯 OVERLAYS"
showSmartTrail = input.bool(true, "Alpha Trail", group=grpOverlays, inline="ov1")
showTrendCloud = input.bool(true, "Trend Cloud", group=grpOverlays, inline="ov1")
showTrendRibbon = input.bool(true, "Trend Ribbon (6 EMA)", group=grpOverlays)
trailLength = input.int(10, "Trail Länge", minval=3, maxval=50, group=grpOverlays)
trailMult = input.float(2.5, "Trail Faktor", minval=1.0, maxval=5.0, step=0.1, group=grpOverlays)

grpSessions = "🌍 TRADING SESSIONS"
showSessionBoxes = input.bool(true, "Session Hintergrund", group=grpSessions)
showSessionLabels = input.bool(true, "Session Labels", group=grpSessions)
showSessionLines = input.bool(true, "Session Trennlinien", group=grpSessions)

grpTPSL = "💰 TAKE PROFIT / STOP LOSS"
showTPSL = input.bool(true, "TP/SL anzeigen", group=grpTPSL)
showZones = input.bool(true, "Profit/Risk Zonen", group=grpTPSL)
tp1Mult = input.float(1.5, "TP1", minval=0.5, maxval=10.0, step=0.1, group=grpTPSL, inline="tp")
tp2Mult = input.float(2.5, "TP2", minval=0.5, maxval=15.0, step=0.1, group=grpTPSL, inline="tp")
tp3Mult = input.float(4.0, "TP3", minval=0.5, maxval=20.0, step=0.1, group=grpTPSL, inline="tp")
slMult = input.float(1.5, "SL", minval=0.5, maxval=5.0, step=0.1, group=grpTPSL, inline="tp")

grpMTF = "📊 MULTI-TIMEFRAME"
useMTF = input.bool(true, "MTF aktivieren", group=grpMTF)
mtfTF1 = input.timeframe("15", "TF1", group=grpMTF, inline="mtf")
mtfTF2 = input.timeframe("60", "TF2", group=grpMTF, inline="mtf")
mtfTF3 = input.timeframe("240", "TF3", group=grpMTF, inline="mtf")
mtfTF4 = input.timeframe("D", "TF4", group=grpMTF, inline="mtf")

grpDash = "📈 DASHBOARD"
showMainDash = input.bool(true, "Haupt-Dashboard", group=grpDash)
showRightPanel = input.bool(true, "Analyse + TP Panel", group=grpDash)
showMTFPanel = input.bool(true, "MTF-Panel", group=grpDash)
showWatermark = input.bool(true, "Alpha Flow Branding", group=grpDash)
showFilterStatus = input.bool(true, "Filter-Status anzeigen", group=grpDash)
beginnerMode = input.bool(false, "👶 Anfänger-Modus (vereinfacht)", group=grpDash, tooltip="Zeigt nur die wichtigsten Infos in einfacher Sprache")

grpRisk = "💼 RISIKO MANAGEMENT"
riskPercent = input.float(0.1, "Risiko pro Trade %", minval=0.05, maxval=2.0, step=0.05, group=grpRisk)
account50k = input.bool(true, "50K Konto anzeigen", group=grpRisk, inline="acc")
account100k = input.bool(true, "100K Konto anzeigen", group=grpRisk, inline="acc")
account200k = input.bool(true, "200K Konto anzeigen", group=grpRisk, inline="acc")

grpVisual = "🎨 DARSTELLUNG"
colorTheme = input.string("Gold Luxury", "🎨 Theme", options=["Gold Luxury", "Ice Blue", "Neon Purple", "Matrix Green"], group=grpVisual, tooltip="Farbschema für Dashboard, Watermark, Signale und Akzente")
candleColoring = input.bool(true, "Kerzen färben", group=grpVisual)
momentumGlow = input.bool(true, "Momentum-Glow Kerzen", group=grpVisual)
showGlowEffects = input.bool(true, "Glow Effekte", group=grpVisual)
showMomentumCandles = input.bool(true, "Momentum Kerzen Marker", group=grpVisual)
bullColor = input.color(#10b981, "Kauf", group=grpVisual, inline="col")
bearColor = input.color(#ef4444, "Verkauf", group=grpVisual, inline="col")
neutralColor = input.color(#6b7280, "Neutral", group=grpVisual, inline="col")

grpNeural = "🧠 NEURAL NETWORK VISUAL"
showNeuralNetwork = input.bool(true, "Neural Network anzeigen", group=grpNeural, tooltip="Zeigt visuelle 'KI-Berechnungen' die zum Preis konvergieren")
neuralIntensity = input.int(70, "Aktivierungs-Schwelle %", minval=50, maxval=95, group=grpNeural)
showLiquidityPulse = input.bool(true, "Liquidity Pulsing", group=grpNeural, tooltip="S/R Zonen pulsieren bei hoher Aktivität")
autoCleanSL = input.bool(true, "Trade bei SL ausblenden", group=grpNeural, tooltip="Entfernt alle Linien wenn Stop Loss erreicht wurde")

//══════════════════════════════════════════════════════════════════════════════
//                    🎨 FARBPALETTE — 4 UMSCHALTBARE THEMES
//══════════════════════════════════════════════════════════════════════════════
// luxGold = Haupt-Akzent (Header, Watermark, Entry, Premium-Signale)
// luxCyan = Sekundär-Akzent (Info-Zeilen, MTF-Panel, Neural-Lines)
// Emerald/Ruby/Amber bleiben semantisch (Gewinn/Verlust/Warnung) in allen Themes

bool thGold   = colorTheme == "Gold Luxury"
bool thIce    = colorTheme == "Ice Blue"
bool thPurple = colorTheme == "Neon Purple"
// sonst: Matrix Green

var color luxBgDark     = thGold ? #0b0e11 : thIce ? #0a111a : thPurple ? #0d0a14 : #050b07
var color luxBgPanel    = thGold ? #12161c : thIce ? #0e1622 : thPurple ? #140f1e : #0a120c
var color luxBorder     = thGold ? #1e2530 : thIce ? #1c2a3a : thPurple ? #2a2140 : #14301c
var color luxTextMain   = #f0f0f0   // Cremeweiß (alle Themes)
var color luxTextMuted  = thGold ? #6b7280 : thIce ? #64748b : thPurple ? #7c7194 : #4d7c5f
var color luxGold       = thGold ? #d4af37 : thIce ? #38bdf8 : thPurple ? #a78bfa : #22c55e
var color luxEmerald    = #10b981   // Gewinn-Grün (semantisch, alle Themes)
var color luxRuby       = #ef4444   // Verlust-Rot (semantisch, alle Themes)
var color luxCyan       = thGold ? #06b6d4 : thIce ? #7dd3fc : thPurple ? #e879f9 : #86efac
var color luxAmber      = #f59e0b   // Warn-Amber (semantisch, alle Themes)

//══════════════════════════════════════════════════════════════════════════════
//                          📊 BERECHNUNGEN
//══════════════════════════════════════════════════════════════════════════════

fastMA = ta.ema(close, fastLength)
slowMA = ta.ema(close, slowLength)
superSlowMA = ta.ema(close, superSlowLength)

trendDir = fastMA > slowMA ? 1 : fastMA < slowMA ? -1 : 0
strongTrend = fastMA > slowMA and slowMA > superSlowMA ? 1 : fastMA < slowMA and slowMA < superSlowMA ? -1 : 0

[diPlus, diMinus, adx] = ta.dmi(14, 14)
rsi = ta.rsi(close, 14)
[macdLine, signalLine, histLine] = ta.macd(close, 12, 26, 9)
atr = ta.atr(14)
mfi = ta.mfi(hlc3, 14)
cci = ta.cci(close, 20)
mom = ta.mom(close, 14)
momMA = ta.ema(mom, 5)

volMA = ta.sma(volume, 20)
relVol = nz(volume / volMA, 1)
volat = atr / close * 100

// Anfängerfreundliche Volatilitäts-Beschreibung
volatLevel = volat > 1.5 ? "HOCH" : volat > 0.8 ? "NORMAL" : "RUHIG"
volatCol = volat > 1.5 ? luxRuby : volat > 0.8 ? luxAmber : luxEmerald

// Pip-Berechnung (broker-unabhängig)
// Ein "Pip" ist die Standard-Stelle: 0.01 bei JPY-Paaren, sonst 0.0001.
// Broker mit fraktionalem Pricing (eine extra Nachkommastelle, z.B. 1.08453
// oder 156.123) bekommen automatisch ×10, weil mintick dann 10× kleiner ist.
// Nicht-Forex (Indizes, Gold, Krypto, CFDs): 1 Tick = 1 "Pip" (pipMultiplier=1).
//   Beispiele:
//   EURUSD mintick 0.00001 → round(0.0001/0.00001)=10 → onePip 0.0001
//   EURUSD mintick 0.0001  → round(0.0001/0.0001) =1  → onePip 0.0001
//   USDJPY mintick 0.001   → round(0.01/0.001)   =10 → onePip 0.01
//   USDJPY mintick 0.01    → round(0.01/0.01)    =1  → onePip 0.01
isForexPair = syminfo.type == "forex"
standardPip = syminfo.currency == "JPY" ? 0.01 : 0.0001
pipMultiplier = isForexPair and syminfo.mintick > 0 ? math.round(standardPip / syminfo.mintick) : 1
onePip = syminfo.mintick * pipMultiplier

// TP-Multiplikatoren intern sortieren — garantiert TP1 < TP2 < TP3,
// egal wie der User die Inputs einstellt (verhindert kaputte Zonen/Progress-Bar)
float tpM1 = math.min(tp1Mult, math.min(tp2Mult, tp3Mult))
float tpM3 = math.max(tp1Mult, math.max(tp2Mult, tp3Mult))
float tpM2 = tp1Mult + tp2Mult + tp3Mult - tpM1 - tpM3

// Timeframe → Anzeigename (z.B. "15" → "15m", "240" → "4H")
f_tfName(string tf) =>
    tf == "1" ? "1m" : tf == "3" ? "3m" : tf == "5" ? "5m" : tf == "15" ? "15m" : tf == "30" ? "30m" : tf == "45" ? "45m" : tf == "60" ? "1H" : tf == "120" ? "2H" : tf == "180" ? "3H" : tf == "240" ? "4H" : tf == "D" ? "1D" : tf == "W" ? "1W" : tf == "M" ? "1M" : tf

// MTF-Panel Helfer (müssen global definiert sein)
f_mtfArrow(int dir) =>
    dir > 0 ? "▲ BULLISCH" : dir < 0 ? "▼ BÄRISCH" : "• NEUTRAL"
f_mtfColor(int dir) =>
    dir > 0 ? luxEmerald : dir < 0 ? luxRuby : luxTextMuted

//══════════════════════════════════════════════════════════════════════════════
//                    🌈 TREND RIBBON (6 EMA GRADIENT)
//══════════════════════════════════════════════════════════════════════════════

ema1 = ta.ema(close, 8)
ema2 = ta.ema(close, 13)
ema3 = ta.ema(close, 21)
ema4 = ta.ema(close, 34)
ema5 = ta.ema(close, 55)
ema6 = ta.ema(close, 89)

ribbonBull = ema1 > ema2 and ema2 > ema3 and ema3 > ema4 and ema4 > ema5 and ema5 > ema6
ribbonBear = ema1 < ema2 and ema2 < ema3 and ema3 < ema4 and ema4 < ema5 and ema5 < ema6
ribbonColor = ribbonBull ? bullColor : ribbonBear ? bearColor : neutralColor

p1 = plot(showTrendRibbon ? ema1 : na, "EMA 8", color=color.new(ribbonColor, 20), linewidth=1, display=display.pane)
p2 = plot(showTrendRibbon ? ema2 : na, "EMA 13", color=color.new(ribbonColor, 35), linewidth=1, display=display.pane)
p3 = plot(showTrendRibbon ? ema3 : na, "EMA 21", color=color.new(ribbonColor, 50), linewidth=1, display=display.pane)
p4 = plot(showTrendRibbon ? ema4 : na, "EMA 34", color=color.new(ribbonColor, 65), linewidth=1, display=display.pane)
p5 = plot(showTrendRibbon ? ema5 : na, "EMA 55", color=color.new(ribbonColor, 80), linewidth=1, display=display.pane)
p6 = plot(showTrendRibbon ? ema6 : na, "EMA 89", color=color.new(ribbonColor, 90), linewidth=1, display=display.pane)

fill(p1, p2, color=color.new(ribbonColor, ribbonBull or ribbonBear ? 85 : 95))
fill(p2, p3, color=color.new(ribbonColor, ribbonBull or ribbonBear ? 88 : 96))
fill(p3, p4, color=color.new(ribbonColor, ribbonBull or ribbonBear ? 91 : 97))
fill(p4, p5, color=color.new(ribbonColor, ribbonBull or ribbonBear ? 93 : 98))
fill(p5, p6, color=color.new(ribbonColor, ribbonBull or ribbonBear ? 95 : 99))

//══════════════════════════════════════════════════════════════════════════════
//                    🌍 TRADING SESSIONS
//══════════════════════════════════════════════════════════════════════════════

// Sessions mit ECHTEN Zeitzonen — time() berücksichtigt Sommer-/Winterzeit automatisch.
// Tokio:  09:00-17:00 JST   (ganzjährig, Japan hat keine DST)
// London: 08:00-16:00 London (BST im Sommer, GMT im Winter)
// NY:     08:00-17:00 NY (EDT/EST)
// Overlap London×NY = 13:00-16:00 London Zeit
asiaSessMs    = time("", "0900-1700", "Asia/Tokyo")
londonSessMs  = time("", "0800-1600", "Europe/London")
nySessMs      = time("", "0800-1700", "America/New_York")
overlapSessMs = time("", "1300-1600", "Europe/London")

isAsiaSession    = not na(asiaSessMs)
isLondonSession  = not na(londonSessMs)
isNewYorkSession = not na(nySessMs)
isOverlap        = not na(overlapSessMs)

// Session-Start = erste Bar in der Session
asiaStart   = isAsiaSession    and not isAsiaSession[1]
londonStart = isLondonSession  and not isLondonSession[1]
nyStart     = isNewYorkSession and not isNewYorkSession[1]

isGoodSession = isLondonSession or isOverlap

asiaCol = #9C27B0
londonCol = #2196F3
nyCol = #4CAF50
overlapCol = #FFD700

sessionName = isOverlap ? "🔥 OVERLAP" : isLondonSession ? "🇬🇧 LONDON" : isNewYorkSession ? "🇺🇸 NEW YORK" : isAsiaSession ? "🌏 ASIA" : "📴 CLOSED"
sessionCol = isOverlap ? overlapCol : isLondonSession ? londonCol : isNewYorkSession ? nyCol : isAsiaSession ? asiaCol : #666666

bgcolor(showSessionBoxes and isAsiaSession and not isOverlap ? color.new(asiaCol, 95) : na, title="Asia BG")
bgcolor(showSessionBoxes and isLondonSession and not isOverlap ? color.new(londonCol, 95) : na, title="London BG")
bgcolor(showSessionBoxes and isNewYorkSession and not isLondonSession ? color.new(nyCol, 95) : na, title="NY BG")
bgcolor(showSessionBoxes and isOverlap ? color.new(overlapCol, 92) : na, title="Overlap BG")

var line asiaLine = na
var line londonLine = na
var line nyLine = na
var label asiaLabel = na
var label londonLabel = na
var label nyLabel = na

if showSessionLines and asiaStart
    line.delete(asiaLine)
    label.delete(asiaLabel)
    asiaLine := line.new(bar_index, high + atr * 2, bar_index, low - atr * 2, color=color.new(asiaCol, 30), width=2, style=line.style_solid)
    if showSessionLabels
        asiaLabel := label.new(bar_index, high + atr * 2.5, "🌏 ASIA", style=label.style_label_down, color=asiaCol, textcolor=color.white, size=size.small)

if showSessionLines and londonStart
    line.delete(londonLine)
    label.delete(londonLabel)
    londonLine := line.new(bar_index, high + atr * 2, bar_index, low - atr * 2, color=color.new(londonCol, 30), width=2, style=line.style_solid)
    if showSessionLabels
        londonLabel := label.new(bar_index, high + atr * 2.5, "🇬🇧 LONDON", style=label.style_label_down, color=londonCol, textcolor=color.white, size=size.small)

if showSessionLines and nyStart
    line.delete(nyLine)
    label.delete(nyLabel)
    nyLine := line.new(bar_index, high + atr * 2, bar_index, low - atr * 2, color=color.new(nyCol, 30), width=2, style=line.style_solid)
    if showSessionLabels
        nyLabel := label.new(bar_index, high + atr * 2.5, "🇺🇸 NEW YORK", style=label.style_label_down, color=nyCol, textcolor=color.white, size=size.small)

var float sessionHigh = na
var float sessionLow = na
var int sessionStartBar = na

if asiaStart or londonStart or nyStart
    sessionHigh := high
    sessionLow := low
    sessionStartBar := bar_index

if not na(sessionHigh)
    sessionHigh := math.max(sessionHigh, high)
    sessionLow := math.min(sessionLow, low)

var box sessionRangeBox = na

if showSessionBoxes and not na(sessionStartBar) and bar_index > sessionStartBar
    box.delete(sessionRangeBox)
    currentSessionCol = isOverlap ? overlapCol : isLondonSession ? londonCol : isNewYorkSession ? nyCol : asiaCol
    sessionRangeBox := box.new(sessionStartBar, sessionHigh, bar_index, sessionLow, bgcolor=color.new(currentSessionCol, 97), border_color=color.new(currentSessionCol, 70), border_width=1, border_style=line.style_dashed)

//══════════════════════════════════════════════════════════════════════════════
//         🔥 DYNAMISCHE SUPPORT / RESISTANCE ZONEN
//══════════════════════════════════════════════════════════════════════════════

pivHighSR = ta.pivothigh(high, 15, 15)
pivLowSR = ta.pivotlow(low, 15, 15)

var float resistanceLevel = na
var float supportLevel = na
var box resZone = na
var box supZone = na
var box resGlow = na
var box supGlow = na

// Zähle wie oft S/R getestet wurde
var int resTouchCount = 0
var int supTouchCount = 0

if not na(pivHighSR)
    resistanceLevel := pivHighSR
    resTouchCount := 0

if not na(pivLowSR)
    supportLevel := pivLowSR
    supTouchCount := 0

// Zähle Berührungen
if not na(resistanceLevel) and high >= resistanceLevel - atr * 0.1 and high <= resistanceLevel + atr * 0.3
    resTouchCount := resTouchCount + 1
if not na(supportLevel) and low <= supportLevel + atr * 0.1 and low >= supportLevel - atr * 0.3
    supTouchCount := supTouchCount + 1

distToRes = not na(resistanceLevel) ? math.abs(close - resistanceLevel) / atr : 99
distToSup = not na(supportLevel) ? math.abs(close - supportLevel) / atr : 99

// Liquidity Pulsing - Zonen pulsieren bei oft getesteten Levels
pulseWave = math.sin(time / 300) * 0.5 + 0.5  // Wert 0-1 pulsierend
resPulseIntensity = showLiquidityPulse and resTouchCount >= 2 ? pulseWave * 15 : 0
supPulseIntensity = showLiquidityPulse and supTouchCount >= 2 ? pulseWave * 15 : 0

resAlpha = showDynamicSR ? math.max(60, 95 - math.max(0, (5 - distToRes)) * 8 - resPulseIntensity) : 90
supAlpha = showDynamicSR ? math.max(60, 95 - math.max(0, (5 - distToSup)) * 8 - supPulseIntensity) : 90

resGlowAlpha = showDynamicSR ? math.max(75, 98 - math.max(0, (5 - distToRes)) * 5 - resPulseIntensity) : 98
supGlowAlpha = showDynamicSR ? math.max(75, 98 - math.max(0, (5 - distToSup)) * 5 - supPulseIntensity) : 98

// Spezielle Farbe für "Hot" Zonen (oft getestet)
resZoneColor = resTouchCount >= 3 ? luxAmber : bearColor
supZoneColor = supTouchCount >= 3 ? luxCyan : bullColor

if showSupportResistance and not na(pivHighSR)
    box.delete(resZone)
    box.delete(resGlow)
    if showDynamicSR and distToRes < 3
        resGlow := box.new(bar_index - 15, pivHighSR + atr * 0.4, bar_index + 50, pivHighSR - atr * 0.4, bgcolor=color.new(resZoneColor, resGlowAlpha), border_color=na)
    zoneTxt = resTouchCount >= 3 ? "🔥 STARKER WIDERSTAND (" + str.tostring(resTouchCount) + "x)" : resTouchCount >= 2 ? "⚡ WIDERSTAND (" + str.tostring(resTouchCount) + "x)" : "⚡ WIDERSTAND"
    resZone := box.new(bar_index - 15, pivHighSR + atr * 0.2, bar_index + 50, pivHighSR - atr * 0.2, bgcolor=color.new(resZoneColor, resAlpha), border_color=color.new(resZoneColor, resAlpha - 20), border_width=1, text=zoneTxt, text_color=color.new(resZoneColor, resAlpha - 40), text_size=size.tiny, text_halign=text.align_left)

if showSupportResistance and not na(pivLowSR)
    box.delete(supZone)
    box.delete(supGlow)
    if showDynamicSR and distToSup < 3
        supGlow := box.new(bar_index - 15, pivLowSR + atr * 0.4, bar_index + 50, pivLowSR - atr * 0.4, bgcolor=color.new(supZoneColor, supGlowAlpha), border_color=na)
    zoneTxt = supTouchCount >= 3 ? "🔥 STARKE UNTERSTÜTZUNG (" + str.tostring(supTouchCount) + "x)" : supTouchCount >= 2 ? "⚡ UNTERSTÜTZUNG (" + str.tostring(supTouchCount) + "x)" : "⚡ UNTERSTÜTZUNG"
    supZone := box.new(bar_index - 15, pivLowSR + atr * 0.2, bar_index + 50, pivLowSR - atr * 0.2, bgcolor=color.new(supZoneColor, supAlpha), border_color=color.new(supZoneColor, supAlpha - 20), border_width=1, text=zoneTxt, text_color=color.new(supZoneColor, supAlpha - 40), text_size=size.tiny, text_halign=text.align_left)

//══════════════════════════════════════════════════════════════════════════════
//                    💪 MOMENTUM KERZEN HIGHLIGHTING
//══════════════════════════════════════════════════════════════════════════════

bodySize = math.abs(close - open)
avgBody = ta.sma(bodySize, 20)
isMomentumCandle = bodySize > avgBody * 2 and volume > volMA * 1.3

plotshape(showMomentumCandles and isMomentumCandle and close > open, "Bull Momentum", shape.diamond, location.abovebar, bullColor, size=size.tiny)
plotshape(showMomentumCandles and isMomentumCandle and close < open, "Bear Momentum", shape.diamond, location.belowbar, bearColor, size=size.tiny)

//══════════════════════════════════════════════════════════════════════════════
//              🔀 RSI DIVERGENZEN (UMKEHR-FRÜHWARNUNG)
//══════════════════════════════════════════════════════════════════════════════
// Bullisch: Preis macht tieferes Tief, RSI macht höheres Tief (Abwärtsdruck lässt nach)
// Bärisch:  Preis macht höheres Hoch, RSI macht tieferes Hoch (Aufwärtsdruck lässt nach)

rsiPivLow = ta.pivotlow(rsi, 5, 5)
rsiPivHigh = ta.pivothigh(rsi, 5, 5)

var float lastRsiLow = na
var float lastRsiLowPrice = na
var float lastRsiHigh = na
var float lastRsiHighPrice = na

bool bullDiv = false
bool bearDiv = false

if not na(rsiPivLow)
    priceAtLow = low[5]
    // RSI-Filter (<45): Divergenzen nur im überverkauften Bereich werten
    if not na(lastRsiLow) and rsiPivLow > lastRsiLow and priceAtLow < lastRsiLowPrice and rsiPivLow < 45
        bullDiv := true
    lastRsiLow := rsiPivLow
    lastRsiLowPrice := priceAtLow

if not na(rsiPivHigh)
    priceAtHigh = high[5]
    if not na(lastRsiHigh) and rsiPivHigh < lastRsiHigh and priceAtHigh > lastRsiHighPrice and rsiPivHigh > 55
        bearDiv := true
    lastRsiHigh := rsiPivHigh
    lastRsiHighPrice := priceAtHigh

// offset=-5: Marker sitzt am Pivot-Punkt (Bestätigung erfolgt 5 Kerzen später)
plotshape(showDivergences and bullDiv, "Bullische Divergenz", shape.triangleup, location.belowbar, luxCyan, offset=-5, text="DIV", textcolor=luxCyan, size=size.small)
plotshape(showDivergences and bearDiv, "Bärische Divergenz", shape.triangledown, location.abovebar, luxAmber, offset=-5, text="DIV", textcolor=luxAmber, size=size.small)

//══════════════════════════════════════════════════════════════════════════════
//              📐 HÖHERE ZEITRAHMEN - UNTERSTÜTZUNG / WIDERSTAND
//══════════════════════════════════════════════════════════════════════════════

// HTF Pivot Berechnung (nur Pivot-Levels für Performance)
getHTFPivots(tf) =>
    htfPivHigh = request.security(syminfo.tickerid, tf, ta.pivothigh(high, 5, 5), barmerge.gaps_off, barmerge.lookahead_on)
    htfPivLow = request.security(syminfo.tickerid, tf, ta.pivotlow(low, 5, 5), barmerge.gaps_off, barmerge.lookahead_on)
    [htfPivHigh, htfPivLow]

[htf1PivH, htf1PivL] = getHTFPivots(htfTF1)
[htf2PivH, htf2PivL] = getHTFPivots(htfTF2)
[htf3PivH, htf3PivL] = getHTFPivots(htfTF3)

// HTF Lines zeichnen
var line htf1ResLine = na, var line htf1SupLine = na
var line htf2ResLine = na, var line htf2SupLine = na
var line htf3ResLine = na, var line htf3SupLine = na
var label htf1ResLbl = na, var label htf1SupLbl = na
var label htf2ResLbl = na, var label htf2SupLbl = na
var label htf3ResLbl = na, var label htf3SupLbl = na

if barstate.islast and showHTFLevels
    // Alte löschen
    line.delete(htf1ResLine), line.delete(htf1SupLine)
    line.delete(htf2ResLine), line.delete(htf2SupLine)
    line.delete(htf3ResLine), line.delete(htf3SupLine)
    label.delete(htf1ResLbl), label.delete(htf1SupLbl)
    label.delete(htf2ResLbl), label.delete(htf2SupLbl)
    label.delete(htf3ResLbl), label.delete(htf3SupLbl)
    
    int lineLen = htfLookback  // Input "Lookback Kerzen" steuert die Linien-Länge
    
    // TF Namen auf Deutsch
    string tf1Name = htfTF1 == "60" ? "1 Std" : htfTF1 == "240" ? "4 Std" : htfTF1 == "D" ? "Täglich" : htfTF1 == "W" ? "Woche" : htfTF1
    string tf2Name = htfTF2 == "60" ? "1 Std" : htfTF2 == "240" ? "4 Std" : htfTF2 == "D" ? "Täglich" : htfTF2 == "W" ? "Woche" : htfTF2
    string tf3Name = htfTF3 == "60" ? "1 Std" : htfTF3 == "240" ? "4 Std" : htfTF3 == "D" ? "Täglich" : htfTF3 == "W" ? "Woche" : htfTF3
    
    // TF1 (z.B. 1 Stunde)
    if not na(htf1PivH)
        htf1ResLine := line.new(bar_index - lineLen, htf1PivH, bar_index + 20, htf1PivH, color=color.new(htfTF1Color, 30), width=1, style=line.style_dashed)
        htf1ResLbl := label.new(bar_index + 22, htf1PivH, tf1Name + " Widerstand", style=label.style_label_left, color=color.new(htfTF1Color, 50), textcolor=htfTF1Color, size=size.tiny)
    if not na(htf1PivL)
        htf1SupLine := line.new(bar_index - lineLen, htf1PivL, bar_index + 20, htf1PivL, color=color.new(htfTF1Color, 30), width=1, style=line.style_dashed)
        htf1SupLbl := label.new(bar_index + 22, htf1PivL, tf1Name + " Unterstützung", style=label.style_label_left, color=color.new(htfTF1Color, 50), textcolor=htfTF1Color, size=size.tiny)
    
    // TF2 (z.B. 4 Stunden)
    if not na(htf2PivH)
        htf2ResLine := line.new(bar_index - lineLen, htf2PivH, bar_index + 20, htf2PivH, color=color.new(htfTF2Color, 20), width=2, style=line.style_dashed)
        htf2ResLbl := label.new(bar_index + 22, htf2PivH, tf2Name + " Widerstand", style=label.style_label_left, color=color.new(htfTF2Color, 40), textcolor=htfTF2Color, size=size.small)
    if not na(htf2PivL)
        htf2SupLine := line.new(bar_index - lineLen, htf2PivL, bar_index + 20, htf2PivL, color=color.new(htfTF2Color, 20), width=2, style=line.style_dashed)
        htf2SupLbl := label.new(bar_index + 22, htf2PivL, tf2Name + " Unterstützung", style=label.style_label_left, color=color.new(htfTF2Color, 40), textcolor=htfTF2Color, size=size.small)
    
    // TF3 (z.B. Täglich) - Dickste Linien
    if not na(htf3PivH)
        htf3ResLine := line.new(bar_index - lineLen, htf3PivH, bar_index + 20, htf3PivH, color=color.new(htfTF3Color, 10), width=3, style=line.style_solid)
        htf3ResLbl := label.new(bar_index + 22, htf3PivH, "📍 " + tf3Name + " Widerstand", style=label.style_label_left, color=htfTF3Color, textcolor=color.white, size=size.small)
    if not na(htf3PivL)
        htf3SupLine := line.new(bar_index - lineLen, htf3PivL, bar_index + 20, htf3PivL, color=color.new(htfTF3Color, 10), width=3, style=line.style_solid)
        htf3SupLbl := label.new(bar_index + 22, htf3PivL, "📍 " + tf3Name + " Unterstützung", style=label.style_label_left, color=htfTF3Color, textcolor=color.white, size=size.small)

//══════════════════════════════════════════════════════════════════════════════
//              🔲 ORDER BLOCKS (Institutionelle Zonen)
//══════════════════════════════════════════════════════════════════════════════

var box[] bullOBs = array.new_box()
var box[] bearOBs = array.new_box()

// Bullish Order Block: Letzte rote Kerze vor starker Aufwärtsbewegung
bullOB = close[1] < open[1] and close > open and close > high[1] and (close - open) > avgBody * 1.5
// Bearish Order Block: Letzte grüne Kerze vor starker Abwärtsbewegung  
bearOB = close[1] > open[1] and close < open and close < low[1] and (open - close) > avgBody * 1.5

if showOrderBlocks and bullOB
    // Alte OBs begrenzen (max 3)
    if array.size(bullOBs) >= 3
        box.delete(array.shift(bullOBs))
    newOB = box.new(bar_index - 1, high[1], bar_index + 50, low[1], bgcolor=color.new(luxEmerald, 85), border_color=luxEmerald, border_width=1, text="🟢 OB", text_size=size.tiny, text_color=luxEmerald, text_halign=text.align_left)
    array.push(bullOBs, newOB)

if showOrderBlocks and bearOB
    if array.size(bearOBs) >= 3
        box.delete(array.shift(bearOBs))
    newOB = box.new(bar_index - 1, high[1], bar_index + 50, low[1], bgcolor=color.new(luxRuby, 85), border_color=luxRuby, border_width=1, text="🔴 OB", text_size=size.tiny, text_color=luxRuby, text_halign=text.align_left)
    array.push(bearOBs, newOB)

//══════════════════════════════════════════════════════════════════════════════
//              ⚡ FAIR VALUE GAPS (FVG / Imbalance)
//══════════════════════════════════════════════════════════════════════════════

var box[] bullFVGs = array.new_box()
var box[] bearFVGs = array.new_box()

// Bullish FVG: Gap zwischen high[2] und low[0]
bullFVG = low > high[2] and close > open
bullFVGTop = low
bullFVGBot = high[2]

// Bearish FVG: Gap zwischen low[2] und high[0]
bearFVG = high < low[2] and close < open
bearFVGTop = low[2]
bearFVGBot = high

if showFVG and bullFVG and (bullFVGTop - bullFVGBot) > atr * 0.2
    if array.size(bullFVGs) >= 5
        box.delete(array.shift(bullFVGs))
    fvgBox = box.new(bar_index - 2, bullFVGTop, bar_index + 30, bullFVGBot, bgcolor=color.new(luxCyan, 88), border_color=color.new(luxCyan, 60), border_width=1, border_style=line.style_dotted, text="FVG", text_size=size.tiny, text_color=luxCyan)
    array.push(bullFVGs, fvgBox)

if showFVG and bearFVG and (bearFVGTop - bearFVGBot) > atr * 0.2
    if array.size(bearFVGs) >= 5
        box.delete(array.shift(bearFVGs))
    fvgBox = box.new(bar_index - 2, bearFVGTop, bar_index + 30, bearFVGBot, bgcolor=color.new(luxAmber, 88), border_color=color.new(luxAmber, 60), border_width=1, border_style=line.style_dotted, text="FVG", text_size=size.tiny, text_color=luxAmber)
    array.push(bearFVGs, fvgBox)

//══════════════════════════════════════════════════════════════════════════════
//              📍 SWING STRUCTURE (HH / HL / LH / LL) + BOS
//══════════════════════════════════════════════════════════════════════════════

// Swing Detection
swingLen = 5
swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHigh = na
var float lastSwingLow = na
var float prevSwingHigh = na
var float prevSwingLow = na
var int lastSwingHighBar = na
var int lastSwingLowBar = na

// Labels für Structure
var label hhLabel = na, var label hlLabel = na, var label lhLabel = na, var label llLabel = na

// Neue Swing Highs
if not na(swingHigh)
    prevSwingHigh := lastSwingHigh
    lastSwingHigh := swingHigh
    lastSwingHighBar := bar_index - swingLen
    
    if showSwingStructure
        label.delete(hhLabel)
        label.delete(lhLabel)
        if not na(prevSwingHigh)
            if swingHigh > prevSwingHigh
                hhLabel := label.new(bar_index - swingLen, swingHigh, "HH", style=label.style_label_down, color=color.new(luxEmerald, 30), textcolor=color.white, size=size.tiny)
            else
                lhLabel := label.new(bar_index - swingLen, swingHigh, "LH", style=label.style_label_down, color=color.new(luxRuby, 30), textcolor=color.white, size=size.tiny)

// Neue Swing Lows
if not na(swingLow)
    prevSwingLow := lastSwingLow
    lastSwingLow := swingLow
    lastSwingLowBar := bar_index - swingLen
    
    if showSwingStructure
        label.delete(hlLabel)
        label.delete(llLabel)
        if not na(prevSwingLow)
            if swingLow > prevSwingLow
                hlLabel := label.new(bar_index - swingLen, swingLow, "HL", style=label.style_label_up, color=color.new(luxEmerald, 30), textcolor=color.white, size=size.tiny)
            else
                llLabel := label.new(bar_index - swingLen, swingLow, "LL", style=label.style_label_up, color=color.new(luxRuby, 30), textcolor=color.white, size=size.tiny)

// Break of Structure (BOS)
var line bosLine = na
var label bosLabel = na

bullBOS = not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh
bearBOS = not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow

if showBOS and bullBOS
    line.delete(bosLine)
    label.delete(bosLabel)
    bosLine := line.new(lastSwingHighBar, lastSwingHigh, bar_index, lastSwingHigh, color=luxEmerald, width=2, style=line.style_solid)
    bosLabel := label.new(bar_index, lastSwingHigh, "⚡ BOS", style=label.style_label_left, color=luxEmerald, textcolor=color.white, size=size.small)

if showBOS and bearBOS
    line.delete(bosLine)
    label.delete(bosLabel)
    bosLine := line.new(lastSwingLowBar, lastSwingLow, bar_index, lastSwingLow, color=luxRuby, width=2, style=line.style_solid)
    bosLabel := label.new(bar_index, lastSwingLow, "⚡ BOS", style=label.style_label_left, color=luxRuby, textcolor=color.white, size=size.small)

//══════════════════════════════════════════════════════════════════════════════
//                          🎯 KI-KONFIDENZ (8 FAKTOREN)
//══════════════════════════════════════════════════════════════════════════════

trendScore = math.abs(strongTrend) * 20.0
adxScore = math.min(adx / 40 * 15, 15)
rsiScore = trendDir > 0 ? (rsi > 50 and rsi < 70 ? 12 : 6) : trendDir < 0 ? (rsi < 50 and rsi > 30 ? 12 : 6) : 6
macdScore = (trendDir > 0 and macdLine > signalLine) or (trendDir < 0 and macdLine < signalLine) ? 12 : 4
volScore = relVol > 2 ? 12 : relVol > 1.5 ? 10 : relVol > 1 ? 7 : 4
mfiScore = trendDir > 0 ? (mfi > 50 ? 10 : 5) : trendDir < 0 ? (mfi < 50 ? 10 : 5) : 5
cciScore = trendDir > 0 ? (cci > 0 ? 10 : 4) : trendDir < 0 ? (cci < 0 ? 10 : 4) : 5
momScoreVal = (trendDir > 0 and mom > momMA) or (trendDir < 0 and mom < momMA) ? 9 : 3

aiConf = math.min(trendScore + adxScore + rsiScore + macdScore + volScore + mfiScore + cciScore + momScoreVal, 100)
confBlocks = math.round(aiConf / 10)

// Anfängerfreundliche Stärke-Beschreibung
strengthText = aiConf >= 80 ? "SEHR STARK" : aiConf >= 70 ? "STARK" : aiConf >= 60 ? "GUT" : aiConf >= 50 ? "OKAY" : "SCHWACH"
strengthCol = aiConf >= 70 ? luxEmerald : aiConf >= 50 ? luxAmber : luxRuby

// KI "Kalibrierung": erst bereit wenn alle Indikatoren genug Daten haben
// (89er EMA + ADX + Langsam-MA brauchen Vorlauf — ehrlicher Warm-up-Check)
bool aiReady = not na(ema6) and not na(adx) and not na(superSlowMA)

//══════════════════════════════════════════════════════════════════════════════
//                          📊 MTF ANALYSE
//══════════════════════════════════════════════════════════════════════════════

getMTFTrend(tf) =>
    mFast = request.security(syminfo.tickerid, tf, ta.ema(close, fastLength), barmerge.gaps_off, barmerge.lookahead_on)
    mSlow = request.security(syminfo.tickerid, tf, ta.ema(close, slowLength), barmerge.gaps_off, barmerge.lookahead_on)
    mFast > mSlow ? 1 : mFast < mSlow ? -1 : 0

mtf1 = useMTF ? getMTFTrend(mtfTF1) : 0
mtf2 = useMTF ? getMTFTrend(mtfTF2) : 0
mtf3 = useMTF ? getMTFTrend(mtfTF3) : 0
mtf4 = useMTF ? getMTFTrend(mtfTF4) : 0

mtfBullish = (mtf1 > 0 ? 1 : 0) + (mtf2 > 0 ? 1 : 0) + (mtf3 > 0 ? 1 : 0) + (mtf4 > 0 ? 1 : 0)
mtfBearish = (mtf1 < 0 ? 1 : 0) + (mtf2 < 0 ? 1 : 0) + (mtf3 < 0 ? 1 : 0) + (mtf4 < 0 ? 1 : 0)
mtfConf = math.max(mtfBullish, mtfBearish)

//══════════════════════════════════════════════════════════════════════════════
//                          🛤️ QUANTUM TRAIL MIT GLOW
//══════════════════════════════════════════════════════════════════════════════

var float qTrail = na
var int qDir = 0
qATR = ta.atr(trailLength) * trailMult

if na(qTrail)
    qTrail := close
    qDir := 1

if close > qTrail
    qTrail := math.max(qTrail, close - qATR)
    qDir := 1
else
    qTrail := math.min(qTrail, close + qATR)
    qDir := -1

qColor = qDir > 0 ? bullColor : bearColor

plot(showSmartTrail and showGlowEffects ? qTrail : na, "Q-Trail Glow3", color=color.new(qColor, 85), linewidth=8, style=plot.style_linebr, display=display.pane)
plot(showSmartTrail and showGlowEffects ? qTrail : na, "Q-Trail Glow2", color=color.new(qColor, 70), linewidth=5, style=plot.style_linebr, display=display.pane)
plot(showSmartTrail ? qTrail : na, "Q-Trail", color=qColor, linewidth=2, style=plot.style_linebr, display=display.pane)

//══════════════════════════════════════════════════════════════════════════════
//                    ☁️ DYNAMISCHE TREND CLOUD
//══════════════════════════════════════════════════════════════════════════════

ema8 = ta.ema(close, 8)
ema55_cloud = ta.ema(close, 55)

cloudStrength = math.abs(ema8 - ema55_cloud) / atr
cloudAlpha = math.min(cloudStrength * 25, 85)
cloudColor = ema8 > ema55_cloud ? bullColor : bearColor

pCloud1 = plot(showTrendCloud ? ema8 : na, "EMA8", color=color.new(cloudColor, 85), linewidth=1, display=display.pane)
pCloud2 = plot(showTrendCloud ? ema55_cloud : na, "EMA55", color=color.new(cloudColor, 85), linewidth=1, display=display.pane)
fill(pCloud1, pCloud2, color=color.new(cloudColor, 100 - cloudAlpha))

//══════════════════════════════════════════════════════════════════════════════
//                    🎯 PERFECT SETUP FILTER CHECKS
//══════════════════════════════════════════════════════════════════════════════

confOK = aiConf >= requireMinConf
mtfOK = mtfConf >= requireMinMTF
adxOK = adx >= requireMinADX
trailBullOK = not requireTrailConfirm or qDir > 0
trailBearOK = not requireTrailConfirm or qDir < 0
sessionOK = not requireGoodSession or isGoodSession

bullFiltersOK = (confOK ? 1 : 0) + (mtfBullish >= requireMinMTF ? 1 : 0) + (adxOK ? 1 : 0) + (trailBullOK ? 1 : 0) + (sessionOK ? 1 : 0)
bearFiltersOK = (confOK ? 1 : 0) + (mtfBearish >= requireMinMTF ? 1 : 0) + (adxOK ? 1 : 0) + (trailBearOK ? 1 : 0) + (sessionOK ? 1 : 0)

perfectBullSetup = confOK and mtfBullish >= requireMinMTF and adxOK and trailBullOK and sessionOK
perfectBearSetup = confOK and mtfBearish >= requireMinMTF and adxOK and trailBearOK and sessionOK

//══════════════════════════════════════════════════════════════════════════════
//                          📡 SIGNAL-LOGIK MIT FILTER
//══════════════════════════════════════════════════════════════════════════════

bbBasis = ta.sma(close, 20)
bbDev = ta.stdev(close, 20) * 2.2
bbUp = bbBasis + bbDev
bbLo = bbBasis - bbDev

bullCross = ta.crossover(fastMA, slowMA)
bearCross = ta.crossunder(fastMA, slowMA)

basePremBull = bullCross and strongTrend >= 0 and rsi > 45 and close > qTrail and aiConf >= 70 and mtfConf >= 3
basePremBear = bearCross and strongTrend <= 0 and rsi < 55 and close < qTrail and aiConf >= 70 and mtfConf >= 3

baseStdBull = bullCross and aiConf >= minConfidence and not basePremBull
baseStdBear = bearCross and aiConf >= minConfidence and not basePremBear

baseRevBull = close <= bbLo and rsi < 30 and ta.crossover(close, bbLo) and aiConf >= minConfidence
baseRevBear = close >= bbUp and rsi > 70 and ta.crossunder(close, bbUp) and aiConf >= minConfidence

premBull = perfectSetupOnly ? (basePremBull and perfectBullSetup) : basePremBull
premBear = perfectSetupOnly ? (basePremBear and perfectBearSetup) : basePremBear

stdBull = perfectSetupOnly ? (baseStdBull and perfectBullSetup) : baseStdBull
stdBear = perfectSetupOnly ? (baseStdBear and perfectBearSetup) : baseStdBear

revBull = perfectSetupOnly ? (baseRevBull and perfectBullSetup) : baseRevBull
revBear = perfectSetupOnly ? (baseRevBear and perfectBearSetup) : baseRevBear

anyBullSignal = (showPremiumSignals and premBull) or (showStandardSignals and stdBull) or (showReversalSignals and revBull)
anyBearSignal = (showPremiumSignals and premBear) or (showStandardSignals and stdBear) or (showReversalSignals and revBear)

//══════════════════════════════════════════════════════════════════════════════
//                    💰 POSITION & TP TRACKING
//══════════════════════════════════════════════════════════════════════════════

var int posDir = 0
var float entryPx = na
var int entryBar = na
var int entryTime = na
var float tp1Px = na
var float tp2Px = na
var float tp3Px = na
var float slPx = na
var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false
var bool slHit = false

if anyBullSignal
    posDir := 1
    entryPx := close
    entryBar := bar_index
    entryTime := time
    tp1Px := close + atr * tpM1
    tp2Px := close + atr * tpM2
    tp3Px := close + atr * tpM3
    slPx := close - atr * slMult
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    slHit := false

if anyBearSignal
    posDir := -1
    entryPx := close
    entryBar := bar_index
    entryTime := time
    tp1Px := close - atr * tpM1
    tp2Px := close - atr * tpM2
    tp3Px := close - atr * tpM3
    slPx := close + atr * slMult
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    slHit := false

if posDir == 1 and not na(entryPx) and bar_index > entryBar
    if not tp1Hit and high >= tp1Px
        tp1Hit := true
    if not tp2Hit and high >= tp2Px
        tp2Hit := true
    if not tp3Hit and high >= tp3Px
        tp3Hit := true
    if not slHit and low <= slPx
        slHit := true

if posDir == -1 and not na(entryPx) and bar_index > entryBar
    if not tp1Hit and low <= tp1Px
        tp1Hit := true
    if not tp2Hit and low <= tp2Px
        tp2Hit := true
    if not tp3Hit and low <= tp3Px
        tp3Hit := true
    if not slHit and high >= slPx
        slHit := true

livePL = posDir == 1 ? (close - entryPx) / entryPx * 100 : posDir == -1 ? (entryPx - close) / entryPx * 100 : 0.0
livePLColor = livePL >= 0 ? bullColor : bearColor

pipsValue = posDir == 1 ? (close - entryPx) / syminfo.mintick / pipMultiplier : posDir == -1 ? (entryPx - close) / syminfo.mintick / pipMultiplier : 0.0

// Pips für TP/SL
tp1Pips = math.abs(tp1Px - entryPx) / syminfo.mintick / pipMultiplier
tp2Pips = math.abs(tp2Px - entryPx) / syminfo.mintick / pipMultiplier
tp3Pips = math.abs(tp3Px - entryPx) / syminfo.mintick / pipMultiplier
slPips = math.abs(slPx - entryPx) / syminfo.mintick / pipMultiplier

// Dynamische Pip-Wert Berechnung für ALLE Währungspaare
// Generische Formel: Pip-Wert in USD pro Standard Lot
//                  = onePip × Kontraktgröße × (Quote-Währung → USD)
//
// Beispiele (Standard Lot = 100.000 Einheiten):
// EUR/USD: 0.0001 × 100000 × 1            = $10.00
// USD/JPY @150: 0.01 × 100000 / 150       = $6.67
// USD/CHF @0.90: 0.0001 × 100000 / 0.90   = $11.11
// EUR/JPY @150 (USDJPY): 0.01 × 100000 / USDJPY = $6.67
// EUR/GBP @0.85 (GBPUSD=1.25): 0.0001 × 100000 × 1.25 = $12.50

isUSDQuote = syminfo.currency == "USD"
isUSDBase = syminfo.basecurrency == "USD"
tickerUpper = str.upper(syminfo.ticker)
isGold = str.contains(tickerUpper, "XAU")
// WICHTIG: "DJ" als Substring matcht fälschlich CADJPY, USDJPY etc.!
// Daher "DJ30" / "DOW" verwenden und nur als Ticker-PRÄFIX prüfen.
// Indizes haben zudem niemals eine Forex-Base-Währung → Ausschluss über syminfo.type.
isForexSym = syminfo.type == "forex"
isIndex = not isForexSym and (str.contains(tickerUpper, "US30") or str.contains(tickerUpper, "NAS") or str.contains(tickerUpper, "SPX") or str.contains(tickerUpper, "DAX") or str.contains(tickerUpper, "DJ30") or str.contains(tickerUpper, "DOW") or str.contains(tickerUpper, "FTSE") or str.contains(tickerUpper, "UK100") or str.contains(tickerUpper, "CAC") or str.contains(tickerUpper, "NIKKEI") or str.contains(tickerUpper, "JP225") or str.contains(tickerUpper, "HSI") or str.contains(tickerUpper, "AUS200"))

// Hole USD-Kurs für Quote-Währung (Cross-Paare UND Nicht-USD-Indizes wie DAX/FTSE)
quoteCurrency = syminfo.currency
quoteToUSD = 1.0

if (not isUSDQuote and not isUSDBase and not isGold) or (isIndex and not isUSDQuote)
    if quoteCurrency == "JPY"
        quoteToUSD := 1.0 / request.security("FX:USDJPY", timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_on)
    else if quoteCurrency == "GBP"
        quoteToUSD := request.security("FX:GBPUSD", timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_on)
    else if quoteCurrency == "EUR"
        quoteToUSD := request.security("FX:EURUSD", timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_on)
    else if quoteCurrency == "CHF"
        quoteToUSD := 1.0 / request.security("FX:USDCHF", timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_on)
    else if quoteCurrency == "CAD"
        quoteToUSD := 1.0 / request.security("FX:USDCAD", timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_on)
    else if quoteCurrency == "AUD"
        quoteToUSD := request.security("FX:AUDUSD", timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_on)
    else if quoteCurrency == "NZD"
        quoteToUSD := request.security("FX:NZDUSD", timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_on)
    else if quoteCurrency == "HKD"
        quoteToUSD := 1.0 / request.security("FX_IDC:USDHKD", timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_on)

// Pip-Wert in USD pro Standard Lot (100.000 Einheiten Basiswährung)
// WICHTIG: contractSize als const float (nicht reassigned) + Literal-Fallback,
// da Pine v6 eine Variable in mehrfach verwendeten Multiplikationen mitunter
// falsch auflöst wenn sie weiter oben als "float" statt "const float" deklariert ist.
const float CONTRACT_SIZE = 100000.0
float contractSize = CONTRACT_SIZE  // nur noch für Debug-Anzeige
float pipValuePerLot = 10.0

if isGold
    // Gold (XAU/USD): $10 pro Pip bei 0.10 Bewegung, 100 oz Kontrakt
    pipValuePerLot := 10.0
else if isIndex
    // Indizes: Wert pro VOLLEM Indexpunkt (CFD-Standard = 1 in Quote-Währung)
    // Achtung: mintick kann 0.25/0.1/0.5 sein → onePip ≠ 1 Punkt, daher skalieren:
    //   riskPerLot = slPips × pipValuePerLot
    //              = (diff/onePip) × pipValuePerLot  ← soll = diff × pointValue sein
    //   → pipValuePerLot = onePip × pointValue × quoteToUSD
    float pointValue = 1.0  // CFD-Standard: 1 Einheit Quote-Währung pro Indexpunkt
    pipValuePerLot := onePip * pointValue * (isUSDQuote ? 1.0 : nz(quoteToUSD, 1.0))
else if isUSDQuote
    // XXX/USD (z.B. EUR/USD): onePip × 100000 (bereits in USD)
    pipValuePerLot := onePip * 100000.0
else if isUSDBase
    // USD/XXX (z.B. USD/JPY, USD/CHF): onePip × 100000 / Kurs
    // → JPY: 0.01 × 100000 / close  | CHF: 0.0001 × 100000 / close
    pipValuePerLot := close > 0 ? onePip * 100000.0 / close : 0.0
else
    // Cross-Paare (z.B. EUR/JPY, GBP/JPY, EUR/GBP): onePip × 100000 × QuoteToUSD
    pipValuePerLot := onePip * 100000.0 * nz(quoteToUSD, 1.0)

// Lot Size Berechnung (Risiko% vom Konto)
// Formel: Lot = (Kontogröße × Risiko%) / (SL Pips × Pip-Wert pro Lot)
lot50k = slPips > 0 and pipValuePerLot > 0 ? (50000 * riskPercent / 100) / (slPips * pipValuePerLot) : 0
lot100k = slPips > 0 and pipValuePerLot > 0 ? (100000 * riskPercent / 100) / (slPips * pipValuePerLot) : 0
lot200k = slPips > 0 and pipValuePerLot > 0 ? (200000 * riskPercent / 100) / (slPips * pipValuePerLot) : 0

// Gewinn-Berechnung pro TP Level in USD
// Formel: Gewinn $ = TP Pips × Pip-Wert pro Lot × Lot Size
profit50k_TP1 = tp1Pips * pipValuePerLot * lot50k
profit50k_TP2 = tp2Pips * pipValuePerLot * lot50k
profit50k_TP3 = tp3Pips * pipValuePerLot * lot50k

profit100k_TP1 = tp1Pips * pipValuePerLot * lot100k
profit100k_TP2 = tp2Pips * pipValuePerLot * lot100k
profit100k_TP3 = tp3Pips * pipValuePerLot * lot100k

profit200k_TP1 = tp1Pips * pipValuePerLot * lot200k
profit200k_TP2 = tp2Pips * pipValuePerLot * lot200k
profit200k_TP3 = tp3Pips * pipValuePerLot * lot200k

// Risiko in $ (sollte = Kontogröße × Risiko% sein)
risk50k = slPips * pipValuePerLot * lot50k
risk100k = slPips * pipValuePerLot * lot100k
risk200k = slPips * pipValuePerLot * lot200k

riskAmount = math.abs(entryPx - slPx)
rewardTP3 = math.abs(tp3Px - entryPx)
rrRatio = riskAmount != 0 ? rewardTP3 / riskAmount : 0

timeSinceEntry = time - entryTime
hoursElapsed = math.floor(timeSinceEntry / (1000 * 60 * 60))
minutesElapsed = math.floor((timeSinceEntry % (1000 * 60 * 60)) / (1000 * 60))

//══════════════════════════════════════════════════════════════════════════════
//         🧠 NEURAL NETWORK VISUAL - "KI-BERECHNUNG" EFFEKT
//══════════════════════════════════════════════════════════════════════════════

// Neural Network Lines - konvergieren zum Preis bei hoher Konfidenz
var line[] neuralLines = array.new_line()

// Lösche alte Neural Lines
if barstate.islast and showNeuralNetwork
    // Nur löschen wenn Array nicht leer
    if array.size(neuralLines) > 0
        for i = array.size(neuralLines) - 1 to 0
            line.delete(array.get(neuralLines, i))
        array.clear(neuralLines)
    
    // Nur anzeigen wenn Konfidenz über Schwelle
    if aiConf >= neuralIntensity
        // Berechne Konvergenz-Intensität basierend auf Konfidenz
        convergeFactor = (aiConf - neuralIntensity) / (100 - neuralIntensity)  // 0 bis 1
        
        // Neural Nodes (EMA Quellen)
        float[] nodeValues = array.from(ema1, ema2, ema3, ema4, ema5, ema6, ema8, ema55_cloud)
        color[] nodeColors = array.from(
             color.new(luxCyan, 60), 
             color.new(luxCyan, 55), 
             color.new(luxCyan, 50), 
             color.new(luxCyan, 45),
             color.new(luxGold, 50),
             color.new(luxGold, 45),
             color.new(luxEmerald, 50),
             color.new(luxEmerald, 45)
         )
        
        // Zeichne konvergierende Linien
        targetPrice = close
        startBar = bar_index - 15
        
        for i = 0 to array.size(nodeValues) - 1
            nodeVal = array.get(nodeValues, i)
            nodeCol = array.get(nodeColors, i)
            
            // Start weiter weg, Ende näher am Preis basierend auf Konfidenz
            endY = nodeVal + (targetPrice - nodeVal) * convergeFactor * 0.8
            
            // Hauptlinie
            neuralLine = line.new(startBar, nodeVal, bar_index - 2, endY, color=nodeCol, width=1, style=line.style_dotted)
            array.push(neuralLines, neuralLine)
            
            // Glow bei hoher Konfidenz
            if aiConf >= 85
                glowLine = line.new(startBar, nodeVal, bar_index - 2, endY, color=color.new(nodeCol, 80), width=3, style=line.style_dotted)
                array.push(neuralLines, glowLine)
        
        // Zentraler "Processing Node" am Preis
        if aiConf >= 80
            // Pulsierender Kreis-Effekt durch Box
            pulseSize = atr * 0.05 * (1 + math.sin(time / 500) * 0.2)
            processingNode = line.new(bar_index - 2, close - pulseSize, bar_index - 2, close + pulseSize, color=color.new(luxGold, 30), width=4)
            array.push(neuralLines, processingNode)

//══════════════════════════════════════════════════════════════════════════════
//         🎯 SMART-INFO - JETZT IM DASHBOARD INTEGRIERT
//══════════════════════════════════════════════════════════════════════════════

// Smart Label wurde ins Dashboard verschoben - kein separates Label mehr auf dem Chart
// Die Infos (Kerzen-Countdown, Vola, Volume) sind jetzt im unified Dashboard rechts

//══════════════════════════════════════════════════════════════════════════════
//         🎨 GRÖßERE, KLARERE SIGNAL LABELS MIT QUALITÄTS-BADGE
//══════════════════════════════════════════════════════════════════════════════

var label sigLabel = na
var box sigBox = na
var box sigGlow = na

if showPremiumSignals and premBull
    label.delete(sigLabel), box.delete(sigBox), box.delete(sigGlow)
    // Äußerer Glow
    sigGlow := box.new(bar_index - 2, high + atr * 0.15, bar_index + 2, low - atr * 0.15, bgcolor=color.new(luxGold, 90), border_color=na)
    sigBox := box.new(bar_index - 1, high + atr * 0.1, bar_index + 1, low - atr * 0.1, bgcolor=color.new(luxGold, 75), border_color=luxGold, border_width=3)
    sigLabel := label.new(bar_index + 3, close, "⭐ KAUFEN · " + str.tostring(aiConf, "#") + "%\n" + str.tostring(close, format.mintick), style=label.style_label_left, color=color.new(luxGold, 0), textcolor=luxBgDark, size=size.normal)

if showPremiumSignals and premBear
    label.delete(sigLabel), box.delete(sigBox), box.delete(sigGlow)
    sigGlow := box.new(bar_index - 2, high + atr * 0.15, bar_index + 2, low - atr * 0.15, bgcolor=color.new(luxGold, 90), border_color=na)
    sigBox := box.new(bar_index - 1, high + atr * 0.1, bar_index + 1, low - atr * 0.1, bgcolor=color.new(luxGold, 75), border_color=luxGold, border_width=3)
    sigLabel := label.new(bar_index + 3, close, "⭐ VERKAUFEN · " + str.tostring(aiConf, "#") + "%\n" + str.tostring(close, format.mintick), style=label.style_label_left, color=color.new(luxGold, 0), textcolor=luxBgDark, size=size.normal)

if showStandardSignals and stdBull
    label.delete(sigLabel), box.delete(sigBox), box.delete(sigGlow)
    sigBox := box.new(bar_index - 1, high + atr * 0.05, bar_index + 1, low - atr * 0.05, bgcolor=color.new(bullColor, 85), border_color=bullColor, border_width=2)
    sigLabel := label.new(bar_index + 3, close, "KAUFEN · " + str.tostring(aiConf, "#") + "%\n" + str.tostring(close, format.mintick), style=label.style_label_left, color=bullColor, textcolor=color.white, size=size.normal)

if showStandardSignals and stdBear
    label.delete(sigLabel), box.delete(sigBox), box.delete(sigGlow)
    sigBox := box.new(bar_index - 1, high + atr * 0.05, bar_index + 1, low - atr * 0.05, bgcolor=color.new(bearColor, 85), border_color=bearColor, border_width=2)
    sigLabel := label.new(bar_index + 3, close, "VERKAUFEN · " + str.tostring(aiConf, "#") + "%\n" + str.tostring(close, format.mintick), style=label.style_label_left, color=bearColor, textcolor=color.white, size=size.normal)

if showReversalSignals and revBull
    label.delete(sigLabel), box.delete(sigBox), box.delete(sigGlow)
    sigBox := box.new(bar_index - 1, high + atr * 0.05, bar_index + 1, low - atr * 0.05, bgcolor=color.new(luxCyan, 85), border_color=luxCyan, border_width=2)
    sigLabel := label.new(bar_index + 3, close, "↩ UMKEHR · " + str.tostring(aiConf, "#") + "%\n" + str.tostring(close, format.mintick), style=label.style_label_left, color=luxCyan, textcolor=color.white, size=size.normal)

if showReversalSignals and revBear
    label.delete(sigLabel), box.delete(sigBox), box.delete(sigGlow)
    sigBox := box.new(bar_index - 1, high + atr * 0.05, bar_index + 1, low - atr * 0.05, bgcolor=color.new(luxAmber, 85), border_color=luxAmber, border_width=2)
    sigLabel := label.new(bar_index + 3, close, "↩ UMKEHR · " + str.tostring(aiConf, "#") + "%\n" + str.tostring(close, format.mintick), style=label.style_label_left, color=luxAmber, textcolor=color.white, size=size.normal)

//══════════════════════════════════════════════════════════════════════════════
//      💰 TP/SL LINIEN - IMMER SICHTBAR BEI AKTIVEM TRADE
//══════════════════════════════════════════════════════════════════════════════

var line entryL = na, var line entryGlow1 = na, var line entryGlow2 = na
var line tp1L = na, var line tp2L = na, var line tp3L = na, var line tp3Glow = na
var line slL = na, var line slGlow = na
var label entryLbl = na, var label tp1Lbl = na, var label tp2Lbl = na, var label tp3Lbl = na, var label slLbl = na
var box riskZone = na, var box tp1Zone = na, var box tp2Zone = na, var box tp3Zone = na

colEntry = luxGold
colTP1 = #10b981
colTP2 = #34d399
colTP3 = #6ee7b7
colSL = luxRuby
colHit = luxTextMuted

// ═══ BEI SL HIT: KOMPLETT AUFRÄUMEN ═══
if slHit and autoCleanSL
    // Signal Label löschen
    label.delete(sigLabel)
    box.delete(sigBox)
    box.delete(sigGlow)
    
    // TP/SL Linien löschen
    line.delete(entryL), line.delete(entryGlow1), line.delete(entryGlow2)
    line.delete(tp1L), line.delete(tp2L), line.delete(tp3L), line.delete(tp3Glow)
    line.delete(slL), line.delete(slGlow)
    label.delete(entryLbl), label.delete(tp1Lbl), label.delete(tp2Lbl), label.delete(tp3Lbl), label.delete(slLbl)
    box.delete(riskZone), box.delete(tp1Zone), box.delete(tp2Zone), box.delete(tp3Zone)
    
    // Trade Status komplett zurücksetzen
    posDir := 0
    entryPx := na
    tp1Px := na
    tp2Px := na
    tp3Px := na
    slPx := na
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    slHit := false

// IMMER auf letzter Bar neu zeichnen wenn Trade aktiv ist
if barstate.islast and showTPSL and posDir != 0 and not na(entryPx) and not slHit
    
    // Erst alle alten Objekte löschen
    line.delete(entryL), line.delete(entryGlow1), line.delete(entryGlow2)
    line.delete(tp1L), line.delete(tp2L), line.delete(tp3L), line.delete(tp3Glow)
    line.delete(slL), line.delete(slGlow)
    label.delete(entryLbl), label.delete(tp1Lbl), label.delete(tp2Lbl), label.delete(tp3Lbl), label.delete(slLbl)
    box.delete(riskZone), box.delete(tp1Zone), box.delete(tp2Zone), box.delete(tp3Zone)
    
    // Start Bar für Linien
    int startBar = entryBar > 0 ? entryBar : bar_index - 30
    int endBar = bar_index + 25  // Linien weiter nach rechts
    int lblBar = bar_index + 18  // Labels weit rechts um Signal-Label nicht zu überlappen
    
    // Entry Line mit Glow
    if showGlowEffects
        entryGlow2 := line.new(startBar, entryPx, endBar, entryPx, color=color.new(colEntry, 80), width=10)
        entryGlow1 := line.new(startBar, entryPx, endBar, entryPx, color=color.new(colEntry, 60), width=6)
    entryL := line.new(startBar, entryPx, endBar, entryPx, color=colEntry, width=2)
    
    // TP Lines - Farbe ändert sich bei Hit
    color tp1LineCol = tp1Hit ? colHit : colTP1
    color tp2LineCol = tp2Hit ? colHit : colTP2
    color tp3LineCol = tp3Hit ? luxGold : colTP3
    
    tp1L := line.new(startBar, tp1Px, endBar, tp1Px, color=tp1LineCol, width=1, style=tp1Hit ? line.style_dotted : line.style_dashed)
    tp2L := line.new(startBar, tp2Px, endBar, tp2Px, color=tp2LineCol, width=1, style=tp2Hit ? line.style_dotted : line.style_dashed)
    if showGlowEffects and not tp3Hit
        tp3Glow := line.new(startBar, tp3Px, endBar, tp3Px, color=color.new(colTP3, 70), width=6)
    tp3L := line.new(startBar, tp3Px, endBar, tp3Px, color=tp3LineCol, width=2)
    
    // SL Line
    if showGlowEffects
        slGlow := line.new(startBar, slPx, endBar, slPx, color=color.new(colSL, 70), width=6)
    slL := line.new(startBar, slPx, endBar, slPx, color=colSL, width=2)
    
    // Profit/Risk Zonen
    if showZones
        riskZone := box.new(startBar, entryPx, endBar, slPx, bgcolor=color.new(colSL, 92), border_color=color.new(colSL, 100))
        tp1Zone := box.new(startBar, entryPx, endBar, tp1Px, bgcolor=color.new(colTP1, 94), border_color=color.new(colTP1, 100))
        tp2Zone := box.new(startBar, tp1Px, endBar, tp2Px, bgcolor=color.new(colTP2, 94), border_color=color.new(colTP2, 100))
        tp3Zone := box.new(startBar, tp2Px, endBar, tp3Px, bgcolor=color.new(colTP3, 94), border_color=color.new(colTP3, 100))
    
    // Labels - immer am rechten Rand sichtbar
    entryLbl := label.new(lblBar, entryPx, "► Entry: " + str.tostring(entryPx, format.mintick), style=label.style_label_left, color=colEntry, textcolor=#000000, size=size.small)
    
    string tp1Txt = tp1Hit ? "✅ TP1 ERREICHT" : "🎯 TP1: " + str.tostring(tp1Px, format.mintick)
    tp1Lbl := label.new(lblBar, tp1Px, tp1Txt, style=label.style_label_left, color=tp1Hit ? luxCyan : color.new(colTP1, 20), textcolor=color.white, size=size.small)
    
    string tp2Txt = tp2Hit ? "✅ TP2 ERREICHT" : "🎯 TP2: " + str.tostring(tp2Px, format.mintick)
    tp2Lbl := label.new(lblBar, tp2Px, tp2Txt, style=label.style_label_left, color=tp2Hit ? luxCyan : color.new(colTP2, 20), textcolor=color.white, size=size.small)
    
    string tp3Txt = tp3Hit ? "🏆 ALLE TPs!" : "🏆 TP3: " + str.tostring(tp3Px, format.mintick)
    tp3Lbl := label.new(lblBar, tp3Px, tp3Txt, style=label.style_label_left, color=tp3Hit ? luxGold : colTP3, textcolor=#000000, size=size.small)
    
    slLbl := label.new(lblBar, slPx, "🛑 SL: " + str.tostring(slPx, format.mintick), style=label.style_label_left, color=colSL, textcolor=color.white, size=size.small)

//══════════════════════════════════════════════════════════════════════════════
//              🔥 MOMENTUM-GLOW KERZEN-FÄRBUNG
//══════════════════════════════════════════════════════════════════════════════

candleMomentum = bodySize / atr
momIntensity = math.min(candleMomentum * 40, 80)

trendIntensity = math.abs((fastMA - slowMA) / atr)
normIntensity = math.min(trendIntensity, 3) / 3 * 100

glowIntensity = momentumGlow ? math.max(momIntensity, normIntensity * 0.8) : normIntensity * 0.8

candleCol = trendDir > 0 ? color.new(bullColor, math.round(100 - glowIntensity)) : trendDir < 0 ? color.new(bearColor, math.round(100 - glowIntensity)) : color.new(neutralColor, 70)
barcolor(candleColoring ? candleCol : na)

//══════════════════════════════════════════════════════════════════════════════
//              💎 ALPHA FLOW WATERMARK
//══════════════════════════════════════════════════════════════════════════════

if showWatermark and barstate.islast
    var table watermark = table.new(position.top_center, 1, 2, bgcolor=color.new(color.black, 100))
    table.cell(watermark, 0, 0, "ALPHA FLOW™", text_color=color.new(luxGold, 70), text_size=size.huge, bgcolor=color.new(color.black, 100))
    table.cell(watermark, 0, 1, aiReady ? syminfo.ticker + "  ·  " + f_tfName(timeframe.period) + "  ·  AI ENGINE V17" : "🔄 AI ENGINE KALIBRIERT…", text_color=color.new(aiReady ? luxTextMuted : luxAmber, 55), text_size=size.small, bgcolor=color.new(color.black, 100))

//══════════════════════════════════════════════════════════════════════════════
//      📊 UNIFIED DASHBOARD (RECHTS) - ALLES AUF EINEN BLICK
//══════════════════════════════════════════════════════════════════════════════

if (showMainDash or showRightPanel) and barstate.islast
    var table unifiedDash = table.new(position.top_right, 5, 24, bgcolor=color.new(luxBgPanel, 0), frame_color=color.new(luxGold, 40), frame_width=2, border_width=1)
    // Verhindert veraltete Zellen (z.B. Progress-Bar nach Trade-Ende)
    table.clear(unifiedDash, 0, 0, 4, 23)

    // ═══ ADAPTIVE OPTIK: Panel "leuchtet auf" bei aktivem Trade ═══
    table.set_frame_color(unifiedDash, posDir != 0 ? color.new(luxGold, 0) : color.new(luxGold, 55))
    table.set_frame_width(unifiedDash, posDir != 0 ? 3 : 1)
    table.set_bgcolor(unifiedDash, posDir != 0 ? color.new(luxBgPanel, 0) : color.new(luxBgPanel, 20))

    // ═══ HEADER ═══
    table.cell(unifiedDash, 0, 0, "🤖 ALPHA FLOW AI™", text_color=luxGold, text_size=size.small, bgcolor=color.new(luxBgDark, 0))
    table.merge_cells(unifiedDash, 0, 0, 3, 0)
    table.cell(unifiedDash, 4, 0, "V17", text_color=luxBgDark, text_size=size.tiny, bgcolor=color.new(luxGold, 10))

    // ═══ STATUS (mit KI-Kalibrierungs-Anzeige bei zu wenig Daten) ═══
    actionTxt = not aiReady ? "🔄 KI KALIBRIERT…" : posDir == 1 ? "📈 KAUF LÄUFT" : posDir == -1 ? "📉 VERKAUF LÄUFT" : aiConf >= 70 and trendDir > 0 ? "👀 KAUF MÖGLICH" : aiConf >= 70 and trendDir < 0 ? "👀 VERKAUF MÖGLICH" : "⏸ ABWARTEN"
    actionCol = not aiReady ? luxAmber : posDir == 1 ? luxEmerald : posDir == -1 ? luxRuby : aiConf >= 70 ? (trendDir > 0 ? color.new(luxEmerald, 30) : color.new(luxRuby, 30)) : luxTextMuted
    plTxt = posDir != 0 ? (pipsValue >= 0 ? "+" : "") + str.tostring(pipsValue, "#.#") + " Pips\n" + (livePL >= 0 ? "+" : "") + str.tostring(livePL, "#.##") + "%" : ""
    plCol = pipsValue >= 0 ? luxEmerald : luxRuby

    // Status als farbige "Pill"-Badges (modernes UI-Design)
    table.cell(unifiedDash, 0, 1, actionTxt, text_color=actionCol, text_size=size.normal, bgcolor=color.new(actionCol, 84))
    table.merge_cells(unifiedDash, 0, 1, 2, 1)
    table.cell(unifiedDash, 3, 1, plTxt, text_color=plCol, text_size=size.normal, bgcolor=posDir != 0 ? color.new(plCol, 87) : color.new(luxBgPanel, 10))
    table.merge_cells(unifiedDash, 3, 1, 4, 1)

    // ═══ ANALYSE ═══ (goldenes Akzent-Band statt ASCII-Linie)
    table.cell(unifiedDash, 0, 2, "", text_size=size.tiny, bgcolor=color.new(luxGold, 78))
    table.merge_cells(unifiedDash, 0, 2, 4, 2)

    // Signal Stärke
    confBar = ""
    for i = 1 to 10
        confBar := confBar + (i <= confBlocks ? "▰" : "▱")
    table.cell(unifiedDash, 0, 3, "Signal:", text_color=luxTextMuted, text_size=size.tiny)
    table.cell(unifiedDash, 1, 3, confBar + " " + str.tostring(aiConf, "#") + "%", text_color=strengthCol, text_size=size.tiny)
    table.merge_cells(unifiedDash, 1, 3, 2, 3)
    table.cell(unifiedDash, 3, 3, strengthText, text_color=strengthCol, text_size=size.tiny)
    table.merge_cells(unifiedDash, 3, 3, 4, 3)

    // Trend (im Anfänger-Modus ausgeblendet)
    if not beginnerMode
        trendTxt = strongTrend > 0 ? "STARK ▲▲" : strongTrend < 0 ? "STARK ▼▼" : trendDir > 0 ? "AUFWÄRTS ▲" : trendDir < 0 ? "ABWÄRTS ▼" : "SEITWÄRTS"
        trendCol = trendDir > 0 ? luxEmerald : trendDir < 0 ? luxRuby : luxTextMuted
        table.cell(unifiedDash, 0, 4, "Trend:", text_color=luxTextMuted, text_size=size.tiny)
        table.cell(unifiedDash, 1, 4, trendTxt, text_color=trendCol, text_size=size.tiny)
        table.merge_cells(unifiedDash, 1, 4, 2, 4)
        table.cell(unifiedDash, 3, 4, "MTF: " + str.tostring(mtfConf) + "/4", text_color=mtfConf >= 3 ? luxEmerald : luxTextMuted, text_size=size.tiny)
        table.merge_cells(unifiedDash, 3, 4, 4, 4)

    // Session
    table.cell(unifiedDash, 0, 5, "Session:", text_color=luxTextMuted, text_size=size.tiny)
    table.cell(unifiedDash, 1, 5, sessionName, text_color=sessionCol, text_size=size.tiny)
    table.merge_cells(unifiedDash, 1, 5, 2, 5)
    table.cell(unifiedDash, 3, 5, "R:R " + str.tostring(rrRatio, "#.#") + "x", text_color=rrRatio >= 2 ? luxEmerald : luxAmber, text_size=size.tiny)
    table.merge_cells(unifiedDash, 3, 5, 4, 5)

    // Volatilität + Volumen (im Anfänger-Modus ausgeblendet)
    if not beginnerMode
        table.cell(unifiedDash, 0, 6, "Vola:", text_color=luxTextMuted, text_size=size.tiny)
        table.cell(unifiedDash, 1, 6, volatLevel, text_color=volatCol, text_size=size.tiny)
        table.merge_cells(unifiedDash, 1, 6, 2, 6)
        table.cell(unifiedDash, 3, 6, "Vol: " + str.tostring(relVol, "#.#") + "x", text_color=relVol > 1.2 ? luxEmerald : luxTextMuted, text_size=size.tiny)
        table.merge_cells(unifiedDash, 3, 6, 4, 6)

    // Filter-Status (5 Checks, einzeln gefärbt)
    if showFilterStatus and not beginnerMode
        mtfSideOK = trendDir > 0 ? mtfBullish >= requireMinMTF : trendDir < 0 ? mtfBearish >= requireMinMTF : false
        trailSideOK = trendDir > 0 ? qDir > 0 : trendDir < 0 ? qDir < 0 : false
        table.cell(unifiedDash, 0, 7, confOK ? "KI ✓" : "KI ✗", text_color=confOK ? luxEmerald : luxRuby, text_size=size.tiny)
        table.cell(unifiedDash, 1, 7, mtfSideOK ? "MTF ✓" : "MTF ✗", text_color=mtfSideOK ? luxEmerald : luxRuby, text_size=size.tiny)
        table.cell(unifiedDash, 2, 7, adxOK ? "ADX ✓" : "ADX ✗", text_color=adxOK ? luxEmerald : luxRuby, text_size=size.tiny)
        table.cell(unifiedDash, 3, 7, trailSideOK ? "Trail ✓" : "Trail ✗", text_color=trailSideOK ? luxEmerald : luxRuby, text_size=size.tiny)
        table.cell(unifiedDash, 4, 7, isGoodSession ? "Sess ✓" : "Sess ✗", text_color=isGoodSession ? luxEmerald : luxRuby, text_size=size.tiny)
    
    // ═══ LOT SIZES ═══
    // Konten-Toggles (account50k/100k/200k) blenden Spalten ein/aus
    acc1Hdr = account50k ? "50K" : ""
    acc2Hdr = account100k ? "100K" : ""
    acc3Hdr = account200k ? "200K" : ""

    table.cell(unifiedDash, 0, 8, "", text_size=size.tiny, bgcolor=color.new(luxBorder, 30))
    table.merge_cells(unifiedDash, 0, 8, 4, 8)

    // Sektions-Kopf als farbiges Band (Card-Design)
    table.cell(unifiedDash, 0, 9, "💼 LOT SIZE", text_color=luxCyan, text_size=size.tiny, bgcolor=color.new(luxCyan, 86))
    table.cell(unifiedDash, 1, 9, acc1Hdr, text_color=luxTextMain, text_size=size.tiny, bgcolor=color.new(luxCyan, 86))
    table.cell(unifiedDash, 2, 9, acc2Hdr, text_color=luxTextMain, text_size=size.tiny, bgcolor=color.new(luxCyan, 86))
    table.cell(unifiedDash, 3, 9, acc3Hdr, text_color=luxTextMain, text_size=size.tiny, bgcolor=color.new(luxCyan, 86))
    table.cell(unifiedDash, 4, 9, "", text_size=size.tiny, bgcolor=color.new(luxCyan, 86))

    lot50kTxt = account50k ? (lot50k > 0 ? str.tostring(lot50k, "#.##") : "---") : ""
    lot100kTxt = account100k ? (lot100k > 0 ? str.tostring(lot100k, "#.##") : "---") : ""
    lot200kTxt = account200k ? (lot200k > 0 ? str.tostring(lot200k, "#.##") : "---") : ""
    table.cell(unifiedDash, 0, 10, "Lot:", text_color=luxTextMuted, text_size=size.tiny)
    table.cell(unifiedDash, 1, 10, lot50kTxt, text_color=luxTextMain, text_size=size.tiny)
    table.cell(unifiedDash, 2, 10, lot100kTxt, text_color=luxTextMain, text_size=size.tiny)
    table.cell(unifiedDash, 3, 10, lot200kTxt, text_color=luxTextMain, text_size=size.tiny)
    table.cell(unifiedDash, 4, 10, "", text_size=size.tiny)

    // ═══ TRADE LEVELS ═══
    table.cell(unifiedDash, 0, 11, "", text_size=size.tiny, bgcolor=color.new(luxBorder, 30))
    table.merge_cells(unifiedDash, 0, 11, 4, 11)

    table.cell(unifiedDash, 0, 12, "🎯 LEVELS", text_color=luxGold, text_size=size.tiny, bgcolor=color.new(luxGold, 86))
    table.cell(unifiedDash, 1, 12, "Preis", text_color=luxTextMain, text_size=size.tiny, bgcolor=color.new(luxGold, 86))
    table.cell(unifiedDash, 2, 12, acc1Hdr, text_color=luxTextMain, text_size=size.tiny, bgcolor=color.new(luxGold, 86))
    table.cell(unifiedDash, 3, 12, acc2Hdr, text_color=luxTextMain, text_size=size.tiny, bgcolor=color.new(luxGold, 86))
    table.cell(unifiedDash, 4, 12, acc3Hdr, text_color=luxTextMain, text_size=size.tiny, bgcolor=color.new(luxGold, 86))

    // Entry
    entryTxt = not na(entryPx) ? str.tostring(entryPx, format.mintick) : "---"
    table.cell(unifiedDash, 0, 13, "► Entry", text_color=luxGold, text_size=size.tiny)
    table.cell(unifiedDash, 1, 13, entryTxt, text_color=luxGold, text_size=size.tiny)
    table.cell(unifiedDash, 2, 13, "", text_size=size.tiny)
    table.cell(unifiedDash, 3, 13, "", text_size=size.tiny)
    table.cell(unifiedDash, 4, 13, "", text_size=size.tiny)

    // TP1
    tp1PriceTxt = not na(tp1Px) ? str.tostring(tp1Px, format.mintick) : "---"
    tp1_50k = not account50k ? "" : posDir == 0 ? "---" : tp1Hit ? "✅" : "+$" + str.tostring(profit50k_TP1, "#")
    tp1_100k = not account100k ? "" : posDir == 0 ? "---" : tp1Hit ? "✅" : "+$" + str.tostring(profit100k_TP1, "#")
    tp1_200k = not account200k ? "" : posDir == 0 ? "---" : tp1Hit ? "✅" : "+$" + str.tostring(profit200k_TP1, "#")
    table.cell(unifiedDash, 0, 14, "🎯 TP1", text_color=tp1Hit ? luxEmerald : luxTextMuted, text_size=size.tiny)
    table.cell(unifiedDash, 1, 14, tp1PriceTxt, text_color=tp1Hit ? luxEmerald : luxTextMuted, text_size=size.tiny)
    table.cell(unifiedDash, 2, 14, tp1_50k, text_color=luxEmerald, text_size=size.tiny)
    table.cell(unifiedDash, 3, 14, tp1_100k, text_color=luxEmerald, text_size=size.tiny)
    table.cell(unifiedDash, 4, 14, tp1_200k, text_color=luxEmerald, text_size=size.tiny)

    // TP2 + TP3 (im Anfänger-Modus ausgeblendet — weniger Info, mehr Klarheit)
    if not beginnerMode
        tp2PriceTxt = not na(tp2Px) ? str.tostring(tp2Px, format.mintick) : "---"
        tp2_50k = not account50k ? "" : posDir == 0 ? "---" : tp2Hit ? "✅" : "+$" + str.tostring(profit50k_TP2, "#")
        tp2_100k = not account100k ? "" : posDir == 0 ? "---" : tp2Hit ? "✅" : "+$" + str.tostring(profit100k_TP2, "#")
        tp2_200k = not account200k ? "" : posDir == 0 ? "---" : tp2Hit ? "✅" : "+$" + str.tostring(profit200k_TP2, "#")
        table.cell(unifiedDash, 0, 15, "🎯 TP2", text_color=tp2Hit ? luxEmerald : luxTextMuted, text_size=size.tiny)
        table.cell(unifiedDash, 1, 15, tp2PriceTxt, text_color=tp2Hit ? luxEmerald : luxTextMuted, text_size=size.tiny)
        table.cell(unifiedDash, 2, 15, tp2_50k, text_color=luxEmerald, text_size=size.tiny)
        table.cell(unifiedDash, 3, 15, tp2_100k, text_color=luxEmerald, text_size=size.tiny)
        table.cell(unifiedDash, 4, 15, tp2_200k, text_color=luxEmerald, text_size=size.tiny)

        tp3PriceTxt = not na(tp3Px) ? str.tostring(tp3Px, format.mintick) : "---"
        tp3_50k = not account50k ? "" : posDir == 0 ? "---" : tp3Hit ? "🏆" : "+$" + str.tostring(profit50k_TP3, "#")
        tp3_100k = not account100k ? "" : posDir == 0 ? "---" : tp3Hit ? "🏆" : "+$" + str.tostring(profit100k_TP3, "#")
        tp3_200k = not account200k ? "" : posDir == 0 ? "---" : tp3Hit ? "🏆" : "+$" + str.tostring(profit200k_TP3, "#")
        table.cell(unifiedDash, 0, 16, "🏆 TP3", text_color=tp3Hit ? luxGold : luxTextMuted, text_size=size.tiny)
        table.cell(unifiedDash, 1, 16, tp3PriceTxt, text_color=tp3Hit ? luxGold : luxTextMuted, text_size=size.tiny)
        table.cell(unifiedDash, 2, 16, tp3_50k, text_color=luxEmerald, text_size=size.tiny)
        table.cell(unifiedDash, 3, 16, tp3_100k, text_color=luxEmerald, text_size=size.tiny)
        table.cell(unifiedDash, 4, 16, tp3_200k, text_color=luxEmerald, text_size=size.tiny)

    // Separator (rubinrot getönt — Risiko-Zone beginnt)
    table.cell(unifiedDash, 0, 17, "", text_size=size.tiny, bgcolor=color.new(luxRuby, 88))
    table.merge_cells(unifiedDash, 0, 17, 4, 17)

    // SL
    slPriceTxt = not na(slPx) ? str.tostring(slPx, format.mintick) : "---"
    sl_50k = not account50k ? "" : posDir == 0 ? "---" : slHit ? "❌" : "-$" + str.tostring(risk50k, "#")
    sl_100k = not account100k ? "" : posDir == 0 ? "---" : slHit ? "❌" : "-$" + str.tostring(risk100k, "#")
    sl_200k = not account200k ? "" : posDir == 0 ? "---" : slHit ? "❌" : "-$" + str.tostring(risk200k, "#")
    table.cell(unifiedDash, 0, 18, "🛑 SL", text_color=slHit ? luxRuby : luxTextMuted, text_size=size.tiny)
    table.cell(unifiedDash, 1, 18, slPriceTxt, text_color=slHit ? luxRuby : luxTextMuted, text_size=size.tiny)
    table.cell(unifiedDash, 2, 18, sl_50k, text_color=luxRuby, text_size=size.tiny)
    table.cell(unifiedDash, 3, 18, sl_100k, text_color=luxRuby, text_size=size.tiny)
    table.cell(unifiedDash, 4, 18, sl_200k, text_color=luxRuby, text_size=size.tiny)

    // ═══ TIP ═══
    table.cell(unifiedDash, 0, 19, "", text_size=size.tiny, bgcolor=color.new(luxBorder, 30))
    table.merge_cells(unifiedDash, 0, 19, 4, 19)

    tipTxt = tp1Hit ? "💡 Stop auf Einstieg setzen!" : slHit ? "❌ Trade beendet" : posDir != 0 ? "💡 Warte auf TP1" : "💡 Warte auf Signal"
    tipCol = tp1Hit ? luxAmber : slHit ? luxRuby : luxTextMuted
    table.cell(unifiedDash, 0, 20, tipTxt, text_color=tipCol, text_size=size.tiny, bgcolor=color.new(tipCol, 88))
    table.merge_cells(unifiedDash, 0, 20, 4, 20)

    // ═══ TRADE PROGRESS BAR ═══
    if posDir != 0 and not na(entryPx) and not na(tp1Px) and not na(tp2Px) and not na(tp3Px) and not slHit
        table.cell(unifiedDash, 0, 21, "", text_size=size.tiny, bgcolor=color.new(luxBorder, 30))
        table.merge_cells(unifiedDash, 0, 21, 4, 21)

        // Berechne Progress zu TP1
        float totalDistTP1 = math.abs(tp1Px - entryPx)
        float totalDistTP2 = math.abs(tp2Px - entryPx)
        float totalDistTP3 = math.abs(tp3Px - entryPx)
        float currentDist  = posDir == 1 ? close - entryPx : entryPx - close
        float progressTP1  = totalDistTP1 > 0 ? math.min(100, math.max(0, currentDist / totalDistTP1 * 100)) : 0
        float progressTP3  = totalDistTP3 > 0 ? math.min(100, math.max(0, currentDist / totalDistTP3 * 100)) : 0

        // TP1/TP2 Marker-Positionen — mit Div/0-Schutz und Clamp auf [0..19]
        int tp1Marker = totalDistTP3 > 0 ? math.max(0, math.min(19, math.floor(totalDistTP1 / totalDistTP3 * 20))) : -1
        int tp2Marker = totalDistTP3 > 0 ? math.max(0, math.min(19, math.floor(totalDistTP2 / totalDistTP3 * 20))) : -1

        // Progress Bar bauen (20 Zeichen)
        int filledBars = math.floor(progressTP3 / 5)
        string progressBar = ""
        for i = 0 to 19
            if i < filledBars
                progressBar := progressBar + "█"
            else if i == tp1Marker
                progressBar := progressBar + "│"  // TP1 Marker
            else if i == tp2Marker
                progressBar := progressBar + "│"  // TP2 Marker
            else
                progressBar := progressBar + "░"

        // Farbe basierend auf Fortschritt
        color progressCol = progressTP1 >= 100 ? luxGold : progressTP3 >= 30 ? luxEmerald : luxCyan

        table.cell(unifiedDash, 0, 22, "📈 FORTSCHRITT", text_color=luxCyan, text_size=size.tiny, bgcolor=color.new(luxCyan, 86))
        table.merge_cells(unifiedDash, 0, 22, 4, 22)

        string progressTxt = progressBar + " " + str.tostring(progressTP3, "#") + "%"
        string targetTxt = tp3Hit ? "🏆 ALLE ZIELE!" : tp2Hit ? "→ TP3" : tp1Hit ? "→ TP2" : "→ TP1 (" + str.tostring(progressTP1, "#") + "%)"

        table.cell(unifiedDash, 0, 23, progressTxt, text_color=progressCol, text_size=size.tiny)
        table.merge_cells(unifiedDash, 0, 23, 2, 23)
        table.cell(unifiedDash, 3, 23, targetTxt, text_color=progressCol, text_size=size.tiny)
        table.merge_cells(unifiedDash, 3, 23, 4, 23)

//══════════════════════════════════════════════════════════════════════════════
//      📊 MTF-PANEL (MITTE RECHTS) — TREND PRO ZEITRAHMEN
//══════════════════════════════════════════════════════════════════════════════

if showMTFPanel and useMTF and barstate.islast
    var table mtfPanel = table.new(position.middle_right, 2, 5, bgcolor=color.new(luxBgPanel, 10), frame_color=color.new(luxCyan, 50), frame_width=1, border_width=1)
    table.cell(mtfPanel, 0, 0, "📊 MTF TREND", text_color=luxCyan, text_size=size.tiny, bgcolor=color.new(luxCyan, 85))
    table.merge_cells(mtfPanel, 0, 0, 1, 0)

    // Trend-Zellen als farbige Pills (Hintergrund folgt der Richtung)
    table.cell(mtfPanel, 0, 1, f_tfName(mtfTF1), text_color=luxTextMuted, text_size=size.tiny)
    table.cell(mtfPanel, 1, 1, f_mtfArrow(mtf1), text_color=f_mtfColor(mtf1), text_size=size.tiny, bgcolor=color.new(f_mtfColor(mtf1), 88))
    table.cell(mtfPanel, 0, 2, f_tfName(mtfTF2), text_color=luxTextMuted, text_size=size.tiny)
    table.cell(mtfPanel, 1, 2, f_mtfArrow(mtf2), text_color=f_mtfColor(mtf2), text_size=size.tiny, bgcolor=color.new(f_mtfColor(mtf2), 88))
    table.cell(mtfPanel, 0, 3, f_tfName(mtfTF3), text_color=luxTextMuted, text_size=size.tiny)
    table.cell(mtfPanel, 1, 3, f_mtfArrow(mtf3), text_color=f_mtfColor(mtf3), text_size=size.tiny, bgcolor=color.new(f_mtfColor(mtf3), 88))
    table.cell(mtfPanel, 0, 4, f_tfName(mtfTF4), text_color=luxTextMuted, text_size=size.tiny)
    table.cell(mtfPanel, 1, 4, f_mtfArrow(mtf4), text_color=f_mtfColor(mtf4), text_size=size.tiny, bgcolor=color.new(f_mtfColor(mtf4), 88))

//══════════════════════════════════════════════════════════════════════════════
//                          🔔 ALARME
//══════════════════════════════════════════════════════════════════════════════

alertcondition(premBull, "⭐ Premium Kauf", "AF-AI: KAUFEN @ {{close}} - Starkes Signal!")
alertcondition(premBear, "⭐ Premium Verkauf", "AF-AI: VERKAUFEN @ {{close}} - Starkes Signal!")
alertcondition(stdBull, "Standard Kauf", "AF-AI: KAUFEN @ {{close}}")
alertcondition(stdBear, "Standard Verkauf", "AF-AI: VERKAUFEN @ {{close}}")
alertcondition(tp1Hit and not tp1Hit[1], "✅ Ziel 1 erreicht!", "AF-AI: Ziel 1 ERREICHT! Setze Stop auf Einstieg!")
alertcondition(tp2Hit and not tp2Hit[1], "✅ Ziel 2 erreicht!", "AF-AI: Ziel 2 ERREICHT!")
alertcondition(tp3Hit and not tp3Hit[1], "🏆 Ziel 3 erreicht!", "AF-AI: ALLE ZIELE ERREICHT! Super Trade!")
alertcondition(slHit and not slHit[1], "❌ Stop ausgelöst", "AF-AI: Stop wurde ausgelöst")
alertcondition(ribbonBull and not ribbonBull[1], "🌈 Trend wird stark bullisch", "AF-AI: Starker Aufwärtstrend beginnt!")
alertcondition(ribbonBear and not ribbonBear[1], "🌈 Trend wird stark bärisch", "AF-AI: Starker Abwärtstrend beginnt!")
alertcondition(londonStart, "🇬🇧 London Session", "AF-AI: Gute Trading-Zeit beginnt!")
alertcondition(nyStart, "🇺🇸 New York Session", "AF-AI: Gute Trading-Zeit beginnt!")
alertcondition(bullDiv, "🔀 Bullische Divergenz", "AF-AI: Bullische RSI-Divergenz erkannt - mögliche Umkehr nach oben!")
alertcondition(bearDiv, "🔀 Bärische Divergenz", "AF-AI: Bärische RSI-Divergenz erkannt - mögliche Umkehr nach unten!")
````
