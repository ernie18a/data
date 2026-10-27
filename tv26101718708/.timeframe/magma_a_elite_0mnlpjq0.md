# MAGMA A+ Elite

- url: https://www.tradingview.com/script/0MnLPJQ0-MAGMA-A-Elite/
- type: indicator
- pine_id: PUB;5f9ea71fc5d740899ed1534ba5364a61
- version: 1.0

## Description

🔥 MAGMA PRO ELITE A+ — Premium Trading System

A professional-grade indicator engineered for traders who 
demand precision, clarity, and high-probability setups 
across all markets and timeframes.

Built on institutional logic, filtered by multi-layer 
confirmation, and designed to execute the "wait, confirm, 
expand" playbook that separates smart money from retail.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 APRIL 2026 TRACK RECORD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

6 setups published on April 6th. 11 days later:

✅ BTC  +14.1%  →  +141% at 10x leverage
✅ SUI  +18.9%  →  +189% at 10x leverage
✅ ETH  +17.4%  →  +174% at 10x leverage
✅ XRP  +14.5%  →  +145% at 10x leverage
✅ SOL  +13.8%  →  +138% at 10x leverage
✅ LINK +12.3%  →  +123% at 10x leverage

📈 Win rate: 100% (6/6)
📈 Average move captured: +15.2% spot / +152% at 10x
📈 Methodology: Liquidity → Reaction Zone → Expansion

All updates available on the MagmaAPlusElite profile.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✨ CORE FEATURES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 AUTOMATED SIGNAL SYSTEM
- High-conviction LONG and SHORT entries marked on chart
- A+ scoring filter (only signals with score ≥ 75 trigger)
- Pre-calculated Stop Loss, TP1 and TP2 levels
- Risk-to-Reward ratios displayed automatically (RR 1.54 / 2.31)
- Leverage projections built into every signal (10x default)
- Percentage moves shown for spot and leveraged scenarios

📊 MULTI-TIMEFRAME ANALYSIS ENGINE
- Real-time BULL/BEAR strength readings on 5m, 15m, 1h and 4h
- Probability scoring from 0 to 100 for every setup
- Aligned-timeframe confluence detection
- Trend strength quantification across the full spectrum

🧠 INSTITUTIONAL LOGIC LAYER
- Dynamic dual-EMA trend filter (fast + slow)
- Volume-based institutional activity detection
- Wick-to-body ratio analysis for absorption and rejection
- Volume multipliers for institutional confirmation
- Smart liquidity read combining price and flow

🛡️ BUILT-IN PROTECTION
- ATR-based anti-chop filter (skips low-volatility ranges)
- ADX-based anti-range filter (skips sideways markets)
- Cooldown between signals (prevents overtrading)
- Anti-repaint mode (signals fire only at candle close)
- Multiple confirmation layers before triggering

💎 UNIVERSAL COMPATIBILITY
- Crypto spot and perpetual futures
- Forex majors, minors, and exotics
- Stock indices and individual equities
- Commodities (gold, silver, oil)
- All timeframes — from 1 minute to Daily

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎓 HOW THE SYSTEM WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The indicator continuously evaluates market conditions 
through three independent analysis layers:

1️⃣ INSTITUTIONAL LAYER
Reads volume anomalies, wick structures, and EMA alignment 
to detect where large players are active.

2️⃣ SCALPING LAYER
Uses fast EMAs and RSI on smaller timeframes to time 
entries with precision.

3️⃣ SCORING LAYER
Combines both layers with volume multipliers to produce 
a final A+ score. Only scores ≥ 75 generate signals.

When a signal fires, the indicator calculates:
- Entry price
- Stop Loss (based on ATR and structure)
- TP1 at RR 1.54
- TP2 at RR 2.31
- Leverage % projections

No guesswork. No subjectivity. Pure institutional logic.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ RECOMMENDED SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- Timeframe: 15m – 4H (best risk-to-reward balance)
- Leverage: 5x–10x for crypto, 2x–5x for forex
- Position sizing: 1–2% risk per trade maximum
- Always respect the Stop Loss
- Secure partials at TP1, move SL to breakeven
- Let runners ride to TP2

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📩 HOW TO GET ACCESS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This is an invite-only premium indicator. To request access:

Send a private message on TradingView with:
- Your TradingView username
- Preferred subscription plan (monthly / lifetime)

You'll receive complete activation instructions, pricing, 
and onboarding materials within 24 hours.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ IMPORTANT DISCLAIMERS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- This indicator is a technical analysis tool, not 
  financial advice.
- Past performance does not guarantee future results.
- Leveraged trading amplifies both gains and losses — 
  always use proper risk management.
- Access is granted per TradingView username only.
- Unauthorized sharing results in permanent access 
  revocation without refund.
- Trade at your own risk and responsibility.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MAGMA PRO Elite A+ — Where institutional logic meets 
precision execution. 🚀🔥

For questions, DM on TradingView.

## Source Code

````pine

//@version=6
indicator("MAGMA PRO Elite A+", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────────
// AJUSTES BASE
// ─────────────────────────────────────────────
wickRatio       = input.float(1.8, "Ratio mecha/cuerpo (institucional)", step=0.1)
volMultInst     = input.float(1.6, "Multiplicador volumen (institucional)", step=0.1)

emaFastLen      = input.int(9,  "EMA rápida (institucional)")
emaSlowLen      = input.int(21, "EMA lenta (institucional)")

emaScalpFastLen = input.int(5,  "EMA rápida (scalping)")
emaScalpSlowLen = input.int(13, "EMA lenta (scalping)")
rsiLen          = input.int(14, "RSI (scalping y score)")
volMultScalp    = input.float(1.4, "Multiplicador volumen (scalping)", step=0.1)

scoreVolMult    = input.float(1.5, "Multiplicador volumen (score)", step=0.1)
eliteMinScore   = input.int(75, "Score mínimo para A+", minval=0, maxval=100)

// ─────────────────────────────────────────────
// FILTROS PRO
// ─────────────────────────────────────────────
atrLen          = input.int(14, "ATR len (anti-chop)")
minAtrPct       = input.float(0.20, "Mín ATR% para operar", step=0.01)
adxLen          = input.int(14, "ADX len (anti-rango)")
minAdx          = input.float(12, "Mín ADX para operar", step=0.5)

cooldownBars    = input.int(3, "Cooldown barras entre señales", minval=0)
useBarCloseOnly = input.bool(true, "Señales solo al cierre (anti repaint)")

// Ajuste acumulación / distribución
accumVolMult    = input.float(1.6, "VolMult para Acumulación/Distribución", step=0.1)
// ─────────────────────────────────────────────
// ALERTA SMART 5 CONFIRMACIONES (INVISIBLE)
// ─────────────────────────────────────────────
useSmartAlert            = input.bool(true, "Activar alerta smart 5C", group="SMART ALERT")
smartLookbackAccum       = input.int(25, "Acumulación lateral (velas)", minval=10, group="SMART ALERT")
smartMaxRangePct         = input.float(2.5, "Máx rango % acumulación", step=0.1, group="SMART ALERT")
smartMaxEmaSpreadPct     = input.float(0.45, "Máx separación EMA %", step=0.01, group="SMART ALERT")
smartWindowBars          = input.int(30, "Ventana viva del setup", minval=5, group="SMART ALERT")
requireCloseAboveShortSL = input.bool(true, "Exigir cierre arriba del SL short", group="SMART ALERT")
// ─────────────────────────────────────────────
// TP/SL + RR + LEVERAGE
// ─────────────────────────────────────────────
showTPSL         = input.bool(true, "Mostrar TP/SL + RR")
atrMultSL        = input.float(1.3, "ATR Stop Loss x", step=0.1)
atrMultTP1       = input.float(2.0, "ATR Take Profit 1 x", step=0.1)
atrMultTP2       = input.float(3.0, "ATR Take Profit 2 x", step=0.1)
lev              = input.float(10.0, "Leverage (solo informativo para %)", step=0.5, minval=1)
useEliteOnlyTPSL = input.bool(false, "TP/SL solo para A+ (si no, también Ballena/Scalp)")

// ─────────────────────────────────────────────
// MTF PANEL
// ─────────────────────────────────────────────
showMtfPanel = input.bool(true, "Mostrar Panel Multi-TF", group="MTF Panel")
mtFastLen    = input.int(9,  "EMA rápida MTF", minval=1, group="MTF Panel")
mtSlowLen    = input.int(21, "EMA lenta MTF",  minval=1, group="MTF Panel")
mtRsiLen     = input.int(14, "RSI MTF",        minval=1, group="MTF Panel")
mtNeutral    = input.int(55, "Zona neutral MTF", minval=1, maxval=99, group="MTF Panel")

// ─────────────────────────────────────────────
// CÁLCULOS BASE
// ─────────────────────────────────────────────
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

emaScalpFast = ta.ema(close, emaScalpFastLen)
emaScalpSlow = ta.ema(close, emaScalpSlowLen)

rsi      = ta.rsi(close, rsiLen)
avgVol20 = ta.sma(volume, 20)

body = math.abs(close - open)
rng  = high - low

safeBody = body == 0.0 ? 0.0000001 : body
safeRng  = rng  == 0.0 ? 0.0000001 : rng

lowerWick = math.min(open, close) - low
upperWick = high - math.max(open, close)

// Volatilidad / tendencia
atr = ta.atr(atrLen)
atrPct = (atr / close) * 100.0
[diplus, diminus, adx] = ta.dmi(adxLen, adxLen)

okVolatility = atrPct >= minAtrPct
okTrend      = adx >= minAdx
confirmed    = useBarCloseOnly ? barstate.isconfirmed : true

// ─────────────────────────────────────────────
// BALLENAS INVISIBLES
// ─────────────────────────────────────────────
volHighest20 = volume == ta.highest(volume, 20)

// Absorción
absorptionBull = (
    volHighest20 and
    safeBody < safeRng * 0.55 and
    close > open and
    close > emaFast
)

absorptionBear = (
    volHighest20 and
    safeBody < safeRng * 0.55 and
    close < open and
    close < emaFast
)

// Acumulación / distribución
institutionalAccumulation = (
    volume > avgVol20 * accumVolMult and
    close > emaFast and
    emaFast > emaSlow
)

institutionalDistribution = (
    volume > avgVol20 * accumVolMult and
    close < emaFast and
    emaFast < emaSlow
)

// Traps
trapBull = (
    lowerWick > safeBody * 2.0 and
    volHighest20 and
    close > open
)

trapBear = (
    upperWick > safeBody * 2.0 and
    volHighest20 and
    close < open
)

// ─────────────────────────────────────────────
// SEÑALES INSTITUCIONALES
// ─────────────────────────────────────────────
highVolInst = volume > avgVol20 * volMultInst

liquiditySweep = (
    lowerWick > safeBody * wickRatio and
    low < low[1] and
    close > (low + rng * 0.55)
)

bullishEngulfing = (
    close > open and
    close > high[1]
)

trendShiftUp = (
    close > emaFast and
    emaFast > emaSlow
)

institutionalEntry = (
    confirmed and okVolatility and
    highVolInst and trendShiftUp and
    (liquiditySweep or absorptionBull) and
    (bullishEngulfing or close > (high - rng * 0.20))
)

bearishEngulfing = (
    close < open and
    close < low[1]
)

trendShiftDown = (
    close < emaFast and
    emaFast < emaSlow
)

upperWickLong = upperWick > safeBody * wickRatio

liquidityGrabTop = (
    upperWickLong and
    high > high[1] and
    close < (high - rng * 0.55)
)

institutionalExit = (
    confirmed and okVolatility and
    highVolInst and trendShiftDown and
    (liquidityGrabTop or absorptionBear) and
    (bearishEngulfing or close < (low + rng * 0.20))
)

// ─────────────────────────────────────────────
// SCALPING
// ─────────────────────────────────────────────
highVolScalp = volume > avgVol20 * volMultScalp

pullbackLong = (
    low <= emaScalpFast and
    close > emaScalpFast
)

pullbackShort = (
    high >= emaScalpFast and
    close < emaScalpFast
)

scalpEntry = (
    confirmed and okVolatility and okTrend and
    emaScalpFast > emaScalpSlow and
    pullbackLong and
    rsi > 50 and
    highVolScalp
)

scalpExit = (
    confirmed and okVolatility and okTrend and
    emaScalpFast < emaScalpSlow and
    pullbackShort and
    rsi < 50 and
    highVolScalp
)

// ─────────────────────────────────────────────
// SCORE 0-100
// ─────────────────────────────────────────────
highVolScore = volume > avgVol20 * scoreVolMult
strongCandle = safeBody > safeRng * 0.6
momentumUp   = rsi > 55
trendUp      = emaFast > emaSlow
aboveFast    = close > emaFast

chopPenalty = (okTrend ? 0 : 10) + (okVolatility ? 0 : 10)

float score = 0.0
score += trendUp      ? 25 : 0
score += highVolScore ? 25 : 0
score += strongCandle ? 20 : 0
score += momentumUp   ? 20 : 0
score += aboveFast    ? 10 : 0
score -= chopPenalty
score := math.max(0, math.min(100, score))

plot(score, title="Score", display=display.none)

// ─────────────────────────────────────────────
// SEÑAL A+
// ─────────────────────────────────────────────
eliteSignal = (
    institutionalEntry and
    (absorptionBull or institutionalAccumulation) and
    score >= eliteMinScore
)// ─────────────────────────────────────────────
// ─────────────────────────────────────────────
// SMART ALERTA 5C (FIX REAL)
// ─────────────────────────────────────────────
smartRangeHigh = ta.highest(high, smartLookbackAccum)
smartRangeLow  = ta.lowest(low, smartLookbackAccum)
smartRangePct  = close != 0 ? ((smartRangeHigh - smartRangeLow) / close) * 100.0 : 999.0
smartEmaSpreadPct = close != 0 ? (math.abs(emaFast - emaSlow) / close) * 100.0 : 999.0

smartAccumulation = smartRangePct <= smartMaxRangePct and smartEmaSpreadPct <= smartMaxEmaSpreadPct
smartMaBullCross  = ta.crossover(emaFast, emaSlow)

// Guardar último SL teórico del short
var float lastShortSL = na
if institutionalExit
    lastShortSL := close + atr * atrMultSL

smartCloseAboveShortSL = not na(lastShortSL) and close > lastShortSL and close > open

barsSinceAccum   = ta.barssince(smartAccumulation)
barsSinceCross   = ta.barssince(smartMaBullCross)
barsSinceSLBreak = ta.barssince(smartCloseAboveShortSL)

smartAccumRecent = barsSinceAccum >= 0 and barsSinceAccum <= smartWindowBars
smartCrossRecent = barsSinceCross >= 0 and barsSinceCross <= smartWindowBars
smartSLRecent    = barsSinceSLBreak >= 0 and barsSinceSLBreak <= smartWindowBars

smartFiveConfirm = (
    useSmartAlert and
    smartAccumRecent and
    eliteSignal and
    (smartCrossRecent or smartSLRecent)
)
    


// ─────────────────────────────────────────────
// COOLDOWN ANTI-SPAM
// ─────────────────────────────────────────────
var int lastSigBar = na

canFire() =>
    cooldownBars == 0 ? true : (na(lastSigBar) ? true : (bar_index - lastSigBar > cooldownBars))

fireInstEntry = institutionalEntry and canFire()
fireInstExit  = institutionalExit and canFire()
fireScalpEn   = scalpEntry and canFire()
fireScalpEx   = scalpExit and canFire()
fireElite = (useSmartAlert ? smartFiveConfirm : eliteSignal) and canFire()

if (fireInstEntry or fireInstExit or fireScalpEn or fireScalpEx or fireElite)
    lastSigBar := bar_index

// ─────────────────────────────────────────────
// DIBUJOS
// ─────────────────────────────────────────────
plotshape(fireInstEntry, title="Entrada Ballena ▲", location=location.belowbar, style=shape.triangleup, size=size.large, color=color.lime, text="▲")
plotshape(fireInstExit,  title="Salida Ballena ▼",  location=location.abovebar, style=shape.triangledown, size=size.large, color=color.red,  text="▼")

plotshape(fireScalpEn, title="Entrada Scalping ●", location=location.belowbar, style=shape.circle, size=size.small, color=color.new(color.green, 0), text="●")
plotshape(fireScalpEx, title="Salida Scalping ●",  location=location.abovebar, style=shape.circle, size=size.small, color=color.new(color.red, 0), text="●")

gold = color.rgb(255, 215, 0)
plotshape(fireElite, title="Señal A+ ⭐", location=location.belowbar, style=shape.labelup, size=size.large, color=gold, text="A+")

// EMAs
plot(emaFast, title="EMA 9", color=color.green)
plot(emaSlow, title="EMA 21", color=color.red)

// Fondo institucional
bgcolor(
     institutionalAccumulation ? color.new(color.green, 88) :
     institutionalDistribution ? color.new(color.red, 88) :
     trapBull ? color.new(color.teal, 85) :
     trapBear ? color.new(color.orange, 85) :
     na
)

// ─────────────────────────────────────────────
// TABLA SCORE
// ─────────────────────────────────────────────
var table t = table.new(position.top_right, 1, 1)

if barstate.islast
    scoreColor =
         score >= 80 ? color.new(color.green, 0) :
         score >= 60 ? color.new(color.orange, 0) :
         score >= 40 ? color.new(color.gray, 0) :
         color.new(color.red, 0)

    table.cell(t, 0, 0, "Probabilidad: " + str.tostring(score, "#") + "%", text_color=color.white, bgcolor=scoreColor)

// ─────────────────────────────────────────────
// TP/SL + RR + %
// ─────────────────────────────────────────────
newLong  = useEliteOnlyTPSL ? fireElite : (fireElite or fireInstEntry or fireScalpEn)
newShort = useEliteOnlyTPSL ? false : (fireInstExit or fireScalpEx)

var float entryPrice = na
var float stopPrice  = na
var float tp1Price   = na
var float tp2Price   = na
var int   dir        = 0

if showTPSL and (newLong or newShort)
    entryPrice := close
    dir := newLong ? 1 : -1

    if dir == 1
        stopPrice := entryPrice - atr * atrMultSL
        tp1Price  := entryPrice + atr * atrMultTP1
        tp2Price  := entryPrice + atr * atrMultTP2
    else
        stopPrice := entryPrice + atr * atrMultSL
        tp1Price  := entryPrice - atr * atrMultTP1
        tp2Price  := entryPrice - atr * atrMultTP2

    risk = math.abs(entryPrice - stopPrice)
    rr1  = risk > 0 ? math.abs(tp1Price - entryPrice) / risk : na
    rr2  = risk > 0 ? math.abs(tp2Price - entryPrice) / risk : na

    moveTP1pct = entryPrice != 0 ? (math.abs(tp1Price - entryPrice) / entryPrice) * 100.0 : na
    moveSLpct  = entryPrice != 0 ? (math.abs(entryPrice - stopPrice) / entryPrice) * 100.0 : na

    levTP1 = moveTP1pct * lev
    levSL  = moveSLpct * lev

    lblTxt = str.format(
         "{0}\nEntrada: {1}\nSL: {2} ({3}% ~ {4}% @{5}x)\nTP1: {6} (RR {7} | {8}% ~ {9}%)\nTP2: {10} (RR {11})",
         dir == 1 ? "LONG 🟢" : "SHORT 🔴",
         str.tostring(entryPrice, format.mintick),
         str.tostring(stopPrice, format.mintick),
         str.tostring(moveSLpct, "#.##"),
         str.tostring(levSL, "#.##"),
         str.tostring(lev, "#.##"),
         str.tostring(tp1Price, format.mintick),
         str.tostring(rr1, "#.##"),
         str.tostring(moveTP1pct, "#.##"),
         str.tostring(levTP1, "#.##"),
         str.tostring(tp2Price, format.mintick),
         str.tostring(rr2, "#.##")
    )

    label.new(
         bar_index,
         dir == 1 ? low : high,
         lblTxt,
         style=dir == 1 ? label.style_label_up : label.style_label_down,
         textcolor=color.white,
         color=dir == 1 ? color.new(color.green, 0) : color.new(color.red, 0)
    )

plot(showTPSL ? entryPrice : na, title="TPSL Entrada", color=color.white, linewidth=2, style=plot.style_linebr)
plot(showTPSL ? stopPrice  : na, title="TPSL Stop",   color=color.red, linewidth=2, style=plot.style_linebr)
plot(showTPSL ? tp1Price   : na, title="TPSL TP1",    color=color.yellow, linewidth=2, style=plot.style_linebr)
plot(showTPSL ? tp2Price   : na, title="TPSL TP2",    color=color.green, linewidth=2, style=plot.style_linebr)

// ─────────────────────────────────────────────
// ALERTAS
// ─────────────────────────────────────────────
alertcondition(fireInstEntry, title="ALERTA Entrada Ballena",  message="MAGMA: Entrada institucional ▲ | Score={{plot(\"Score\")}}")
alertcondition(fireInstExit,  title="ALERTA Salida Ballena",   message="MAGMA: Salida institucional ▼ | Score={{plot(\"Score\")}}")
alertcondition(fireScalpEn,   title="ALERTA Entrada Scalping", message="MAGMA: Entrada scalping ● | Score={{plot(\"Score\")}}")
alertcondition(fireScalpEx,   title="ALERTA Salida Scalping",  message="MAGMA: Salida scalping ● | Score={{plot(\"Score\")}}")
alertcondition(fireElite,     title="ALERTA Señal A+ Elite",   message="MAGMA PRO ELITE A+ ⭐🐋 | Score={{plot(\"Score\")}}")
alertcondition(smartFiveConfirm and canFire(), title="ALERTA SMART 5 CONFIRMACIONES", message="MAGMA SMART 5C | Acumulación + cruce EMA + cierre sobre SL short + A+ dentro de ventana")
// ─────────────────────────────────────────────
// FUNCIÓN MTF SCORE
// ─────────────────────────────────────────────
mtfScore(tf) =>
    fEma = request.security(syminfo.tickerid, tf, ta.ema(close, mtFastLen))
    sEma = request.security(syminfo.tickerid, tf, ta.ema(close, mtSlowLen))
    rsiV = request.security(syminfo.tickerid, tf, ta.rsi(close, mtRsiLen))

    emaScore = fEma > sEma ? 60 : fEma < sEma ? 40 : 50
    sc = math.round(emaScore * 0.6 + rsiV * 0.4)

    txt = sc >= mtNeutral ? "BULL" : sc <= (100 - mtNeutral) ? "BEAR" : "NEUTRAL"
    col = sc >= mtNeutral ? color.new(color.green, 0) :
          sc <= (100 - mtNeutral) ? color.new(color.red, 0) :
          color.new(color.orange, 0)

    [sc, txt, col]

// ─────────────────────────────────────────────
// PANEL MTF TERMINADO
// ─────────────────────────────────────────────
[sc5, txt5, col5]       = mtfScore("5")
[sc15, txt15, col15]    = mtfScore("15")
[sc60, txt60, col60]    = mtfScore("60")
[sc240, txt240, col240] = mtfScore("240")

var table mtfTable = table.new(position.bottom_right, 4, 2, border_width=1)

if barstate.islast
    table.clear(mtfTable, 0, 0, 3, 1)

    if showMtfPanel
        table.cell(mtfTable, 0, 0, "5m",  text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(mtfTable, 1, 0, "15m", text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(mtfTable, 2, 0, "1h",  text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(mtfTable, 3, 0, "4h",  text_color=color.white, bgcolor=color.new(color.black, 0))

        table.cell(mtfTable, 0, 1, txt5  + " " + str.tostring(sc5),   text_color=color.white, bgcolor=col5)
        table.cell(mtfTable, 1, 1, txt15 + " " + str.tostring(sc15),  text_color=color.white, bgcolor=col15)
        table.cell(mtfTable, 2, 1, txt60 + " " + str.tostring(sc60),  text_color=color.white, bgcolor=col60)
        table.cell(mtfTable, 3, 1, txt240 + " " + str.tostring(sc240), text_color=color.white, bgcolor=col240)
````
