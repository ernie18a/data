# Technical Confluence Pro - Multi-Indicator Dashboard - V1

- url: https://www.tradingview.com/script/NOGF6gWW/
- type: indicator
- pine_id: PUB;f889dab92fda43fa904acb832187dbb1
- version: 2.0

## Description

🧠 TECHNICAL CONFLUENCE PRO — Multi-Indicator Confluence Dashboard

A powerful, fully customizable real-time confluence panel that combines 14 indicators across 3 groups + 5 timeframes into a single weighted score — helping traders identify trend direction, market momentum, and potential entry conditions at a glance.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 WHAT'S INSIDE — 3 PANELS SIDE BY SIDE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▸ ADVANCED INDICATORS
  • CM UltMACD MTF (TF60) — MACD momentum on the 60-minute timeframe
  • SQZMOM LB (11/2 · 11/1.5) — Squeeze Momentum, detects compression before explosive moves
  • QQE (14 · 5 · 4.236) — Quantitative Qualitative Estimation, smoothed RSI with dynamic ATR bands
  • Kalman Trend Strength (500 · 10) — Kalman filter oscillator, normalized over a 500-bar window
  • WTO hlc3 (10 · 21) — Wave Trend Oscillator, momentum direction with overbought/oversold zones

▸ TECHNICAL INDICATORS
  • EMA Stack 9 / 21 / 50 / 200 — full trend alignment across all key moving averages
  • Supertrend (3.0 · 10) — dynamic trend direction with trailing stop logic
  • RSI 14 — momentum with overbought / oversold detection
  • Stoch RSI — stochastic applied to RSI for precision timing
  • MACD (12 · 26 · 9) — classic momentum and signal crossover
  • ADX + DI — trend strength filter, avoids weak/ranging markets
  • VWAP — institutional price reference (above/below)
  • OBV — volume accumulation vs. distribution pressure
  • Volume — spike detection vs. 20-bar average

▸ TIMEFRAME ANALYSIS (EMA 21/50/200 alignment)
  • 1H · 12H · 1 Week · 2 Weeks · 1 Month

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📐 WEIGHTED SCORING SYSTEM (0–100)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Every signal contributes to a weighted score:

  • EMA Stack & Supertrend → weight ×2 (primary trend signals)
  • All other indicators → weight ×1
  • Timeframes 1H / 12H / 1W → weight ×2
  • Timeframes 2W / 1M → weight ×3 (macro bias)

Score interpretation:
  85–100 → Strong Uptrend   🟢🟢
  70–84  → Uptrend          🟢
  58–69  → Weak Uptrend     🟩
  43–57  → Neutral          ⬜
  31–42  → Weak Downtrend   🟥
  16–30  → Downtrend        🔴
  0–15   → Strong Downtrend 🔴🔴

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 CONCLUSION PANEL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• Trend — market direction based on weighted score
• Momentum — price condition: Favorable · Overbought · Oversold · Stretched Up/Down
• Indicators — count of bullish vs. bearish signals (e.g. 10 UP / 3 DN)
• Timeframes — count of aligned timeframes (e.g. 4 UP / 0 DN)
• Score — the final weighted confluence number out of 100
• Overall % — percentage of indicators pointing up vs. down (color matches trend)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ FULLY CUSTOMIZABLE SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Everything is adjustable to match your trading style:

📊 Technical Indicators
  → EMA periods (Fast / Mid / Slow / Long)
  → Supertrend multiplier and period
  → RSI period, overbought/oversold levels, bull/bear thresholds
  → ADX period and minimum trend strength
  → Volume spike multiplier

🔬 Advanced Indicators
  → SQZMOM: BB length, BB multiplier, KC multiplier, momentum length
  → QQE: RSI length, smoothing factor, ATR factor
  → Kalman: gain, fast EMA, slow EMA, normalization window
  → WTO: channel length, average length, overbought/oversold levels

🎯 Score Thresholds
  → Stretched % distance from EMA21 (momentum sensitivity)

🎨 Display
  → Table position: Top Right · Top Left · Top Center · Middle · Bottom
  → Font size: Tiny · Small · Normal · Large

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This indicator is for educational and analytical purposes only.
It does NOT constitute financial advice or a recommendation to buy or sell any asset.
Always apply proper risk management and make your own informed decisions.

The advanced indicators (SQZMOM, QQE, Kalman, WTO) are implemented as equivalent logic based on their original parameters — not direct copies of proprietary scripts.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏷️ TAGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
confluence · dashboard · multi-indicator · trend · momentum · EMA · RSI · MACD · VWAP · OBV · squeeze · QQE · Kalman · WTO · timeframe · scoring · overlay · customizable · settings

## Source Code

````pine
//@version=6
indicator("Technical Confluence Pro [Diego]", overlay=true)

// ════════════════════════════════════════════════
// SETTINGS — Group 1: Technical Indicators
// ════════════════════════════════════════════════
grpTec = "Technical Indicators"
i_ema1      = input.int(9,     "EMA Fast",              group=grpTec, minval=1)
i_ema2      = input.int(21,    "EMA Mid",               group=grpTec, minval=1)
i_ema3      = input.int(50,    "EMA Slow",              group=grpTec, minval=1)
i_ema4      = input.int(200,   "EMA Long",              group=grpTec, minval=1)
i_stMult    = input.float(3.0, "Supertrend Mult",       group=grpTec, minval=0.1, step=0.1)
i_stPer     = input.int(10,    "Supertrend Period",     group=grpTec, minval=1)
i_rsiLen    = input.int(14,    "RSI Period",            group=grpTec, minval=1)
i_rsiOB     = input.int(70,    "RSI Overbought",        group=grpTec, minval=50, maxval=100)
i_rsiOS     = input.int(30,    "RSI Oversold",          group=grpTec, minval=1,  maxval=49)
i_rsiBull   = input.int(55,    "RSI Bullish Threshold", group=grpTec, minval=50, maxval=70)
i_rsiBear   = input.int(45,    "RSI Bearish Threshold", group=grpTec, minval=30, maxval=50)
i_adxLen    = input.int(14,    "ADX Period",            group=grpTec, minval=1)
i_adxMin    = input.int(25,    "ADX Min Strength",      group=grpTec, minval=10, maxval=40)
i_volMult   = input.float(1.2, "Volume Multiplier",     group=grpTec, minval=1.0, step=0.1)

// ════════════════════════════════════════════════
// SETTINGS — Group 2: Advanced Indicators
// ════════════════════════════════════════════════
grpAdv = "Advanced Indicators"
i_sqzLen    = input.int(11,    "SQZMOM BB/KC Length",   group=grpAdv, minval=1)
i_sqzBBMult = input.float(2.0, "SQZMOM BB Mult",        group=grpAdv, minval=0.1, step=0.1)
i_sqzKCMult = input.float(1.5, "SQZMOM KC Mult",        group=grpAdv, minval=0.1, step=0.1)
i_sqzMomLen = input.int(9,     "SQZMOM Momentum",       group=grpAdv, minval=1)
i_qqeRsiLen = input.int(14,    "QQE RSI Length",        group=grpAdv, minval=1)
i_qqeSmooth = input.int(5,     "QQE Smooth",            group=grpAdv, minval=1)
i_qqeFactor = input.float(4.236,"QQE Factor",           group=grpAdv, minval=0.1, step=0.1)
i_kalGain   = input.float(0.02, "Kalman Gain",          group=grpAdv, minval=0.001, maxval=1.0, step=0.001)
i_kalFast   = input.int(10,    "Kalman Fast EMA",       group=grpAdv, minval=1)
i_kalSlow   = input.int(20,    "Kalman Slow EMA",       group=grpAdv, minval=1)
i_kalLen    = input.int(500,   "Kalman Norm Window",    group=grpAdv, minval=50)
i_wtoN1     = input.int(10,    "WTO Channel Length",    group=grpAdv, minval=1)
i_wtoN2     = input.int(21,    "WTO Average Length",    group=grpAdv, minval=1)
i_wtoOB     = input.int(60,    "WTO Overbought",        group=grpAdv, minval=40, maxval=100)
i_wtoOS     = input.int(-60,   "WTO Oversold",          group=grpAdv, minval=-100, maxval=-10)

// ════════════════════════════════════════════════
// SETTINGS — Group 3: Score Thresholds
// ════════════════════════════════════════════════
grpScr = "Score Thresholds"
i_stretchPct = input.float(5.0, "Stretched % from EMA21", group=grpScr, minval=1.0, maxval=20.0, step=0.5)

// ════════════════════════════════════════════════
// SETTINGS — Group 4: Display
// ════════════════════════════════════════════════
grpDsp = "Display"
i_pos = input.string("Top Right", "Table Position", group=grpDsp,
        options=["Top Right","Top Left","Top Center","Middle Right","Middle Left","Bottom Right","Bottom Left"])
i_fsz = input.string("Small", "Font Size", group=grpDsp,
        options=["Tiny","Small","Normal","Large"])

tPos = i_pos == "Top Right"    ? position.top_right    :
       i_pos == "Top Left"     ? position.top_left     :
       i_pos == "Top Center"   ? position.top_center   :
       i_pos == "Middle Right" ? position.middle_right :
       i_pos == "Middle Left"  ? position.middle_left  :
       i_pos == "Bottom Right" ? position.bottom_right : position.bottom_left

tFsz = i_fsz == "Tiny"   ? size.tiny   :
       i_fsz == "Small"   ? size.small  :
       i_fsz == "Normal"  ? size.normal : size.large

// ════════════════════════════════════════════════
// BASE INDICATORS
// ════════════════════════════════════════════════
ema9   = ta.ema(close, i_ema1)
ema21  = ta.ema(close, i_ema2)
ema50  = ta.ema(close, i_ema3)
ema200 = ta.ema(close, i_ema4)

[stVal, stDir]   = ta.supertrend(i_stMult, i_stPer)
stAlta           = stDir < 0

rsi              = ta.rsi(close, i_rsiLen)
stochRsi         = ta.stoch(rsi, rsi, rsi, i_rsiLen)
kLine            = ta.sma(stochRsi, 3)
dLine            = ta.sma(kLine, 3)

[macdL, sigL, _] = ta.macd(close, 12, 26, 9)
[diP, diM, adx]  = ta.dmi(i_adxLen, i_adxLen)

vwap             = ta.vwap(hlc3)
obv              = ta.obv
obvEma           = ta.ema(obv, 21)
volMed           = ta.sma(volume, 20)
atr              = ta.atr(14)

// ════════════════════════════════════════════════
// CM UltMACD MTF (TF60)
// ════════════════════════════════════════════════
getMacdLine() =>
    [m, s, h] = ta.macd(close, 12, 26, 9)
    m - s

getMacdSig() =>
    [m, s, h] = ta.macd(close, 12, 26, 9)
    s

macd60Line = request.security(syminfo.tickerid, "60", getMacdLine())
macd60Sig  = request.security(syminfo.tickerid, "60", getMacdSig())
macdMTF    = macd60Line > macd60Sig

// ════════════════════════════════════════════════
// SQZMOM LB
// ════════════════════════════════════════════════
sqzBasis  = ta.sma(close, i_sqzLen)
sqzDev    = i_sqzBBMult * ta.stdev(close, i_sqzLen)
sqzBBUp   = sqzBasis + sqzDev
sqzBBDn   = sqzBasis - sqzDev
sqzATR    = ta.atr(i_sqzLen)
sqzKCUp   = sqzBasis + i_sqzKCMult * sqzATR
sqzKCDn   = sqzBasis - i_sqzKCMult * sqzATR
sqzActive = sqzBBUp < sqzKCUp and sqzBBDn > sqzKCDn
sqzMidHL  = math.avg(ta.highest(high, i_sqzLen), ta.lowest(low, i_sqzLen))
sqzMidBB  = math.avg(sqzBBUp, sqzBBDn)
sqzMom    = ta.linreg(close - math.avg(sqzMidHL, sqzMidBB), i_sqzMomLen, 0)
sqzBull   = sqzMom > 0 and sqzMom > sqzMom[1]
sqzBear   = sqzMom < 0 and sqzMom < sqzMom[1]

// ════════════════════════════════════════════════
// QQE
// ════════════════════════════════════════════════
qqeRsi   = ta.rsi(close, i_qqeRsiLen)
qqeSmRsi = ta.ema(qqeRsi, i_qqeSmooth)
qqeAtr   = math.abs(qqeSmRsi - qqeSmRsi[1])
qqeMAtr  = ta.ema(qqeAtr, i_qqeRsiLen * 2 - 1)
qqeBand  = i_qqeFactor * qqeMAtr
var float qqeLine = na
qqeLine  := na(qqeLine[1]) ? qqeSmRsi : qqeSmRsi > qqeLine[1] + qqeBand ? qqeSmRsi - qqeBand : qqeSmRsi < qqeLine[1] - qqeBand ? qqeSmRsi + qqeBand : qqeLine[1]
qqeTrend  = qqeSmRsi > qqeLine

// ════════════════════════════════════════════════
// KALMAN TREND
// ════════════════════════════════════════════════
var float kalPrice = na
kalPrice   := na(kalPrice[1]) ? close : kalPrice[1] + i_kalGain * (close - kalPrice[1])
kalOsc      = ta.ema(kalPrice, i_kalFast) - ta.ema(kalPrice, i_kalSlow)
kalHigh     = ta.highest(kalOsc, i_kalLen)
kalLow      = ta.lowest(kalOsc,  i_kalLen)
kalRange    = kalHigh - kalLow
kalNorm     = kalRange != 0 ? (kalOsc - kalLow) / kalRange * 100 : 50
kalBull     = kalNorm > 60 and kalOsc > kalOsc[1]
kalBear     = kalNorm < 40 and kalOsc < kalOsc[1]

// ════════════════════════════════════════════════
// WTO
// ════════════════════════════════════════════════
wtoEsa  = ta.ema(hlc3, i_wtoN1)
wtoDe   = ta.ema(math.abs(hlc3 - wtoEsa), i_wtoN1)
wtoCi   = wtoDe != 0 ? (hlc3 - wtoEsa) / (0.015 * wtoDe) : 0
wtoTci  = ta.ema(wtoCi, i_wtoN2)
wtoWt2  = ta.sma(wtoTci, 4)
wtoBull = wtoTci > wtoWt2 and wtoTci < i_wtoOB
wtoBear = wtoTci < wtoWt2 and wtoTci > i_wtoOS

// ════════════════════════════════════════════════
// TIMEFRAMES
// ════════════════════════════════════════════════
tfBull(tf) =>
    e21  = request.security(syminfo.tickerid, tf, ta.ema(close, i_ema2))
    e50  = request.security(syminfo.tickerid, tf, ta.ema(close, i_ema3))
    e200 = request.security(syminfo.tickerid, tf, ta.ema(close, i_ema4))
    e21 > e50 and e50 > e200

tfBear(tf) =>
    e21  = request.security(syminfo.tickerid, tf, ta.ema(close, i_ema2))
    e50  = request.security(syminfo.tickerid, tf, ta.ema(close, i_ema3))
    e200 = request.security(syminfo.tickerid, tf, ta.ema(close, i_ema4))
    e21 < e50 and e50 < e200

b1h   = tfBull("60")
br1h  = tfBear("60")
b12h  = tfBull("720")
br12h = tfBear("720")
b1s   = tfBull("W")
br1s  = tfBear("W")
b2s   = tfBull("2W")
br2s  = tfBear("2W")
b1m   = tfBull("M")
br1m  = tfBear("M")

// ════════════════════════════════════════════════
// SCORES
// ════════════════════════════════════════════════
emaBull  = ema9 > ema21 and ema21 > ema50 and ema50 > ema200
emaBear  = ema9 < ema21 and ema21 < ema50 and ema50 < ema200
sc_ema   = emaBull ? 2 : emaBear ? -2 : 0
sc_st    = stAlta ? 2 : -2
rsiBull  = rsi > i_rsiBull
rsiBear  = rsi < i_rsiBear
sc_rsi   = rsiBull ? 1 : rsiBear ? -1 : 0
sc_stoch = kLine > dLine ? 1 : -1
sc_macd  = macdL > sigL ? 1 : -1
adxBull  = adx > i_adxMin and diP > diM
adxBear  = adx > i_adxMin and diM > diP
sc_adx   = adxBull ? 1 : adxBear ? -1 : 0
sc_vwap  = close > vwap ? 1 : -1
sc_obv   = obv > obvEma ? 1 : -1
sc_vol   = volume > volMed * i_volMult ? 1 : -1
sc_mtf    = macdMTF ? 1 : -1
sc_sqz    = sqzBull ? 1 : sqzBear ? -1 : 0
sc_qqe    = qqeTrend ? 1 : -1
sc_kalman = kalBull ? 1 : kalBear ? -1 : 0
sc_wto    = wtoBull ? 1 : wtoBear ? -1 : 0
sc_1h  = b1h  ? 2 : br1h  ? -2 : 0
sc_12h = b12h ? 2 : br12h ? -2 : 0
sc_1s  = b1s  ? 2 : br1s  ? -2 : 0
sc_2s  = b2s  ? 3 : br2s  ? -3 : 0
sc_1m  = b1m  ? 3 : br1m  ? -3 : 0

totalTec  = sc_ema + sc_st + sc_rsi + sc_stoch + sc_macd + sc_adx + sc_vwap + sc_obv + sc_vol
totalNovo = sc_mtf + sc_sqz + sc_qqe + sc_kalman + sc_wto
totalTF   = sc_1h + sc_12h + sc_1s + sc_2s + sc_1m
total     = totalTec + totalNovo + totalTF
scoreNorm = math.max(0, math.min(100, math.round((total + 31) / 62 * 100)))

// ════════════════════════════════════════════════
// TREND AND MOMENTUM
// ════════════════════════════════════════════════
tendTxt = scoreNorm >= 85 ? "Strong Uptrend"   : scoreNorm >= 70 ? "Uptrend"       :
          scoreNorm >= 58 ? "Weak Uptrend"     : scoreNorm >= 43 ? "Neutral"       :
          scoreNorm >= 31 ? "Weak Downtrend"   : scoreNorm >= 16 ? "Downtrend"     : "Strong Downtrend"
tendCor = scoreNorm >= 85 ? color.new(#006400, 0) : scoreNorm >= 70 ? color.new(#228B22, 0) :
          scoreNorm >= 58 ? color.new(#6aaa6a, 0) : scoreNorm >= 43 ? color.new(color.gray, 40) :
          scoreNorm >= 31 ? color.new(#b06060, 0) : scoreNorm >= 16 ? color.new(#cc2222, 0) : color.new(#8B0000, 0)

distEma21     = (close - ema21) / ema21 * 100
sobrecomprado = rsi > i_rsiOB
sobrevendido  = rsi < i_rsiOS
esticadoAlta  = distEma21 > i_stretchPct and not sobrecomprado
esticadoBaixa = distEma21 < -i_stretchPct and not sobrevendido

momentoTxt = sobrecomprado ? "Overbought"    : sobrevendido  ? "Oversold"      :
             esticadoAlta  ? "Stretched Up"  : esticadoBaixa ? "Stretched Down" : "Favorable"
momentoCor = sobrecomprado ? color.new(#8B4500, 0) : sobrevendido  ? color.new(#8B4500, 0) :
             esticadoAlta  ? color.new(color.orange, 20) : esticadoBaixa ? color.new(color.orange, 20) : color.new(#1a6e35, 0)

// ════════════════════════════════════════════════
// COLORS AND TEXTS
// ════════════════════════════════════════════════
cV  = color.new(color.green, 0)
cR  = color.new(color.red,   0)
cG  = color.new(color.gray,  0)
cO  = color.orange
bgE = color.new(color.gray, 70)
bgT = color.new(color.gray, 15)
bgA = color.new(#1a4a8a, 10)
bgX = color.new(color.black, 100)

fc(v)           => v > 0 ? cV : v < 0 ? cR : cG
ftxt(bull,bear) => bull ? "Bullish" : bear ? "Bearish" : "Neutral"
fcor(bull,bear) => bull ? cV : bear ? cR : cG

emaTxt   = sc_ema > 0 ? "Bullish" : sc_ema < 0 ? "Bearish" : "Neutral"
stTxt    = stAlta ? "Bullish" : "Bearish"
rsiTxt   = rsi > i_rsiOB ? "Overbought" : rsi < i_rsiOS ? "Oversold" :
           rsi > i_rsiBull ? "Bullish" : rsi < i_rsiBear ? "Bearish" : "Neutral"
rsiCor   = rsi > i_rsiOB ? cO : rsi < i_rsiOS ? cO :
           rsi > i_rsiBull ? cV : rsi < i_rsiBear ? cR : cG
stochTxt = kLine > dLine ? "Bullish" : "Bearish"
macdTxt  = macdL > sigL ? "Bullish" : "Bearish"
adxTxt   = adx < i_adxMin ? "Neutral" : diP > diM ? "Bullish" : "Bearish"
adxCor   = adx < i_adxMin ? cG : diP > diM ? cV : cR
vwapTxt  = close > vwap ? "Above" : "Below"
obvTxt   = obv > obvEma ? "Accumulation" : "Distribution"
volTxt   = volume > volMed * i_volMult ? "High" : "Normal"
volCor   = volume > volMed * i_volMult ? cV : cG
mtfTxt   = macdMTF ? "Bullish" : "Bearish"
sqzTxt   = sqzBull ? "Bullish" : sqzBear ? "Bearish" : "Neutral"
sqzCor   = sqzBull ? cV : sqzBear ? cR : cG
qqeTxt   = qqeTrend ? "Bullish" : "Bearish"
kalTxt   = kalBull ? "Bullish" : kalBear ? "Bearish" : "Neutral"
kalCor   = kalBull ? cV : kalBear ? cR : cG
wtoTxt   = wtoBull ? "Bullish" : wtoBear ? "Bearish" : "Neutral"
wtoCor   = wtoBull ? cV : wtoBear ? cR : cG

// ════════════════════════════════════════════════
// COUNTS
// ════════════════════════════════════════════════
bc1=sc_ema>0?1:0
bc2=sc_st>0?1:0
bc3=sc_rsi>0?1:0
bc4=sc_stoch>0?1:0
bc5=sc_macd>0?1:0
bc6=sc_adx>0?1:0
bc7=sc_vwap>0?1:0
bc8=sc_obv>0?1:0
bc9=sc_vol>0?1:0
bn1=sc_mtf>0?1:0
bn2=sc_sqz>0?1:0
bn3=sc_qqe>0?1:0
bn4=sc_kalman>0?1:0
bn5=sc_wto>0?1:0
bullCount = bc1+bc2+bc3+bc4+bc5+bc6+bc7+bc8+bc9+bn1+bn2+bn3+bn4+bn5

bd1=sc_ema<0?1:0
bd2=sc_st<0?1:0
bd3=sc_rsi<0?1:0
bd4=sc_stoch<0?1:0
bd5=sc_macd<0?1:0
bd6=sc_adx<0?1:0
bd7=sc_vwap<0?1:0
bd8=sc_obv<0?1:0
bd9=sc_vol<0?1:0
bdn1=sc_mtf<0?1:0
bdn2=sc_sqz<0?1:0
bdn3=sc_qqe<0?1:0
bdn4=sc_kalman<0?1:0
bdn5=sc_wto<0?1:0
bearCount = bd1+bd2+bd3+bd4+bd5+bd6+bd7+bd8+bd9+bdn1+bdn2+bdn3+bdn4+bdn5

tb1=sc_1h>0?1:0
tb2=sc_12h>0?1:0
tb3=sc_1s>0?1:0
tb4=sc_2s>0?1:0
tb5=sc_1m>0?1:0
tfBullCount = tb1+tb2+tb3+tb4+tb5

td1=sc_1h<0?1:0
td2=sc_12h<0?1:0
td3=sc_1s<0?1:0
td4=sc_2s<0?1:0
td5=sc_1m<0?1:0
tfBearCount = td1+td2+td3+td4+td5

pctBull    = math.round(bullCount / 14 * 100)
pctBear    = math.round(bearCount / 14 * 100)
pctNeutral = 100 - pctBull - pctBear
overallStr = str.tostring(pctBull) + "% bull\n" + str.tostring(pctNeutral) + "% neutral\n" + str.tostring(pctBear) + "% bear"

// ════════════════════════════════════════════════
// TABLE — 6 cols x 18 rows
// ════════════════════════════════════════════════
var table t = table.new(tPos, 6, 18, border_width=0, frame_width=0)

sp = ""

if barstate.islast

    // ══ COL 0-1: ADVANCED ═════════════════════════
    table.cell(t,0, 0,"ADVANCED",            text_color=color.white, bgcolor=bgA, text_size=tFsz)
    table.cell(t,1, 0,"SIGNAL",              text_color=color.white, bgcolor=bgA, text_size=tFsz)
    table.cell(t,0, 1,"CM UltMACD TF60",     text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,1, 1,mtfTxt,                text_color=color.white, bgcolor=fc(sc_mtf),   text_size=tFsz)
    table.cell(t,0, 2,"SQZMOM 11-2/11-1.5",  text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,1, 2,sqzTxt,                text_color=color.white, bgcolor=sqzCor,       text_size=tFsz)
    table.cell(t,0, 3,"QQE 14-5",            text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,1, 3,qqeTxt,                text_color=color.white, bgcolor=fc(sc_qqe),   text_size=tFsz)
    table.cell(t,0, 4,"Kalman 500-10",       text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,1, 4,kalTxt,                text_color=color.white, bgcolor=kalCor,       text_size=tFsz)
    table.cell(t,0, 5,"WTO hlc3 10-21",      text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,1, 5,wtoTxt,                text_color=color.white, bgcolor=wtoCor,       text_size=tFsz)

    // ══ COL 0-1: TIMEFRAMES ═══════════════════════
    table.cell(t,0, 6,"TIMEFRAMES",           text_color=color.white, bgcolor=bgA, text_size=tFsz)
    table.cell(t,1, 6,"EMA " + str.tostring(i_ema2) + "-" + str.tostring(i_ema3) + "-" + str.tostring(i_ema4), text_color=color.white, bgcolor=bgA, text_size=tFsz)
    table.cell(t,0, 7,"1H",                  text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,1, 7,ftxt(b1h,br1h),        text_color=color.white, bgcolor=fcor(b1h,br1h),   text_size=tFsz)
    table.cell(t,0, 8,"12H",                 text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,1, 8,ftxt(b12h,br12h),      text_color=color.white, bgcolor=fcor(b12h,br12h), text_size=tFsz)
    table.cell(t,0, 9,"1 Week",              text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,1, 9,ftxt(b1s,br1s),        text_color=color.white, bgcolor=fcor(b1s,br1s),   text_size=tFsz)
    table.cell(t,0,10,"2 Weeks",             text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,1,10,ftxt(b2s,br2s),        text_color=color.white, bgcolor=fcor(b2s,br2s),   text_size=tFsz)
    table.cell(t,0,11,"1 Month",             text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,1,11,ftxt(b1m,br1m),        text_color=color.white, bgcolor=fcor(b1m,br1m),   text_size=tFsz)

    for r = 12 to 17
        table.cell(t,0,r,sp, bgcolor=bgX, text_size=size.tiny)
        table.cell(t,1,r,sp, bgcolor=bgX, text_size=size.tiny)

    // ══ COL 2: SPACER ═════════════════════════════
    for r = 0 to 17
        table.cell(t,2,r,sp, bgcolor=bgX, text_size=size.tiny)

    // ══ COL 3-4: TECHNICAL ════════════════════════
    table.cell(t,3, 0,"TECHNICAL",           text_color=color.white, bgcolor=bgA, text_size=tFsz)
    table.cell(t,4, 0,"SIGNAL",              text_color=color.white, bgcolor=bgA, text_size=tFsz)
    table.cell(t,3, 1,"EMA " + str.tostring(i_ema1) + "-" + str.tostring(i_ema2) + "-" + str.tostring(i_ema3) + "-" + str.tostring(i_ema4), text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,4, 1,emaTxt,                text_color=color.white, bgcolor=fc(sc_ema),   text_size=tFsz)
    table.cell(t,3, 2,"Supertrend",          text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,4, 2,stTxt,                 text_color=color.white, bgcolor=fc(sc_st),    text_size=tFsz)
    table.cell(t,3, 3,"RSI " + str.tostring(i_rsiLen), text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,4, 3,rsiTxt,                text_color=color.white, bgcolor=rsiCor,       text_size=tFsz)
    table.cell(t,3, 4,"Stoch RSI",           text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,4, 4,stochTxt,              text_color=color.white, bgcolor=fc(sc_stoch), text_size=tFsz)
    table.cell(t,3, 5,"MACD 12-26-9",        text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,4, 5,macdTxt,               text_color=color.white, bgcolor=fc(sc_macd),  text_size=tFsz)
    table.cell(t,3, 6,"ADX + DI",            text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,4, 6,adxTxt,                text_color=color.white, bgcolor=adxCor,       text_size=tFsz)
    table.cell(t,3, 7,"VWAP",                text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,4, 7,vwapTxt,               text_color=color.white, bgcolor=fc(sc_vwap),  text_size=tFsz)
    table.cell(t,3, 8,"OBV",                 text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,4, 8,obvTxt,                text_color=color.white, bgcolor=fc(sc_obv),   text_size=tFsz)
    table.cell(t,3, 9,"Volume",              text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,4, 9,volTxt,                text_color=color.white, bgcolor=volCor,       text_size=tFsz)

    table.cell(t,3,10,sp, bgcolor=bgX, text_size=size.tiny)
    table.cell(t,4,10,sp, bgcolor=bgX, text_size=size.tiny)

    // ══ COL 3-4: CONCLUSION ═══════════════════════
    table.cell(t,3,11,"CONCLUSION",          text_color=color.white, bgcolor=bgA, text_size=tFsz)
    table.cell(t,4,11,sp,                    text_color=color.white, bgcolor=bgA, text_size=tFsz)
    table.merge_cells(t, 3, 11, 4, 11)

    table.cell(t,3,12,"Trend",               text_color=color.white, bgcolor=bgE,      text_size=tFsz)
    table.cell(t,4,12,tendTxt,               text_color=color.white, bgcolor=tendCor,   text_size=tFsz)

    table.cell(t,3,13,"Momentum",            text_color=color.white, bgcolor=bgE,        text_size=tFsz)
    table.cell(t,4,13,momentoTxt,            text_color=color.white, bgcolor=momentoCor,  text_size=tFsz)

    table.cell(t,3,14,"Indicators",          text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,4,14,str.tostring(bullCount) + " UP / " + str.tostring(bearCount) + " DN", text_color=color.white, bgcolor=bgT, text_size=tFsz)

    table.cell(t,3,15,"Timeframes",          text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,4,15,str.tostring(tfBullCount) + " UP / " + str.tostring(tfBearCount) + " DN", text_color=color.white, bgcolor=bgT, text_size=tFsz)

    table.cell(t,3,16,"Score",               text_color=color.white, bgcolor=bgE, text_size=tFsz)
    table.cell(t,4,16,str.tostring(scoreNorm) + " / 100", text_color=color.white, bgcolor=bgT, text_size=tFsz)

    table.cell(t,3,17,"Overall %",           text_color=color.white, bgcolor=bgE,    text_size=tFsz)
    table.cell(t,4,17,overallStr,            text_color=color.white, bgcolor=tendCor, text_size=tFsz)

    // ══ COL 5: RIGHT SPACER ═══════════════════════
    for r = 0 to 17
        table.cell(t,5,r,sp, bgcolor=bgX, text_size=size.tiny)

alertcondition(scoreNorm >= 70, "Buy Signal",         "Buy signal detected!")
alertcondition(scoreNorm >= 85, "Strong Buy Signal",  "Strong buy signal detected!")
alertcondition(scoreNorm <= 30, "Sell Signal",        "Sell signal detected!")
alertcondition(scoreNorm <= 15, "Strong Sell Signal", "Strong sell signal detected!")
````
