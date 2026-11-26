# Dr. David Paul Earnings Swing System VectorVest v3 Multi-TF

- url: https://www.tradingview.com/script/s9rZnpqp-Dr-David-Paul-Earnings-Swing-System-VectorVest-v3-Multi-TF/
- type: indicator
- pine_id: PUB;3528a0e931c840148108de7bb8704ce3
- version: 5.0

## Description

Buy signal fixed. Added Toggle for time chart periods optimization settings

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// ©jamin3816 — Fixed & Enhanced by Claude (Anthropic) — v5.0
//
// ██████╗ ██████╗     ██████╗  █████╗ ██╗   ██╗██╗██████╗     ██████╗  █████╗ ██╗   ██╗██╗
// ██╔══██╗██╔══██╗    ██╔══██╗██╔══██╗██║   ██║██║██╔══██╗    ██╔══██╗██╔══██╗██║   ██║██║
// ██║  ██║██████╔╝    ██║  ██║███████║██║   ██║██║██║  ██║    ██████╔╝███████║██║   ██║██║
// ██║  ██║██╔══██╗    ██║  ██║██╔══██║╚██╗ ██╔╝██║██║  ██║    ██╔═══╝ ██╔══██║██║   ██║██║
// ██████╔╝██║  ██║    ██████╔╝██║  ██║ ╚████╔╝ ██║██████╔╝    ██║     ██║  ██║╚██████╔╝███████╗
// ╚═════╝ ╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═════╝     ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝
//
// ══════════════════════════════════════════════════════════════════════════════════════
//  DR. DAVID PAUL — EARNINGS-BASED SWING TRADE SYSTEM  |  Pine Script® v6  |  v5.0
//  Methodology: VectorVest / Dr. David Paul Framework
// ══════════════════════════════════════════════════════════════════════════════════════
//
//  CHANGELOG v5.0:
//  ─────────────────────────────────────────────────
//  NEW — Score scale expanded to 0–10 with 3 new scored factors:
//        Factor 8:  MACD  — histogram above zero AND rising (momentum confirmation)
//        Factor 9:  VWAP  — price above VWAP (intraday institutional bias)
//        Factor 10: ADX   — ADX > 20 (trend strength, filters choppy markets)
//
//  NEW — Score thresholds updated for /10 scale:
//        ≥ 7 → GREEN  (Strong Buy)
//        4–6 → YELLOW (Watch)
//        < 4 → RED    (Avoid)
//
//  NEW — Alert threshold updated: 8+/10 for high-score alert
//
//  FIX — All low-contrast gray/dark colors in dashboard upgraded:
//        Column headers:  #888888 → #CCCCCC (bright gray)
//        EMA info values: #AAAAAA → #DDDDDD
//        EMA label f/s/t: #666666 → #AAAAAA
//        Cooldown cd label: #555555 → #AAAAAA
//        Border color:    #333333 → #555555
//        Volume ○ NORMAL: #888888 → #AAAAAA
//        BUY GATE bg:     #001A2B → #0A2540 (slightly brighter dark blue)
//        Header bg:       #0D0D0D → #1A1A1A
//
//  CARRY — All v4 fixes: simplified buy gate, 7-factor scoring, preset system,
//          score banner at top, BUY GATE diagnostic row, syntax fixes
// ══════════════════════════════════════════════════════════════════════════════════════

//@version=6
indicator(
     title             = "Dr. David Paul — Earnings Swing System [VectorVest] v5",
     shorttitle        = "DP·VST v5",
     overlay           = true,
     max_lines_count   = 500,
     max_labels_count  = 500,
     max_boxes_count   = 500
     )

// ╔══════════════════════════════════════════════════════════════╗
// ║           TIMEFRAME PRESET SELECTOR  ← START HERE           ║
// ╚══════════════════════════════════════════════════════════════╝

grpPreset = "⏱️ TIMEFRAME PRESET — Select to match your chart"
tfMode = input.string(
     "1H Swing",
     "▶ Active Preset",
     options = ["3m Scalp", "1H Swing", "1D Position", "Custom"],
     tooltip = "Match this to your chart timeframe. Custom unlocks all parameters below.",
     group   = grpPreset
     )

// ── Custom Parameters (active only when preset = Custom) ───────
grpCustom = "⚙️ Custom Parameters (only used when preset = Custom)"
c_fastLen     = input.int(21,    "Fast EMA",                minval=3,   maxval=100,  group=grpCustom)
c_slowLen     = input.int(55,    "Slow EMA",                minval=5,   maxval=300,  group=grpCustom)
c_trendLen    = input.int(200,   "Trend EMA",               minval=20,  maxval=500,  group=grpCustom)
c_epsRocLen   = input.int(20,    "EPS ROC Lookback",        minval=3,   maxval=100,  group=grpCustom)
c_epsAccelLen = input.int(10,    "EPS Accel Smoothing",     minval=2,   maxval=50,   group=grpCustom)
c_epsThresh   = input.float(2.0, "EPS Accel Threshold %",   minval=0.1, maxval=10.0, step=0.1, group=grpCustom)
c_rsLen       = input.int(50,    "RS Lookback",             minval=5,   maxval=200,  group=grpCustom)
c_rsThresh    = input.float(1.05,"RS Ratio Min",            minval=0.5, maxval=3.0,  step=0.01, group=grpCustom)
c_volLen      = input.int(20,    "Volume MA Length",        minval=3,   maxval=100,  group=grpCustom)
c_volMult     = input.float(1.5, "Volume Surge Multiplier", minval=1.0, maxval=5.0,  step=0.1,  group=grpCustom)
c_atrLen      = input.int(14,    "ATR Length",              minval=3,   maxval=50,   group=grpCustom)
c_atrMult     = input.float(2.5, "ATR Stop Multiplier",     minval=0.5, maxval=6.0,  step=0.1,  group=grpCustom)
c_regimeLen   = input.int(50,    "Regime EMA Length",       minval=10,  maxval=200,  group=grpCustom)
c_strict      = input.bool(false, "Strict Regime",                                   group=grpCustom)
c_stochK      = input.int(14,    "Stochastic %K Length",    minval=3,   maxval=50,   group=grpCustom)
c_stochD      = input.int(3,     "Stochastic %D Smooth",    minval=1,   maxval=10,   group=grpCustom)
c_stochSmooth = input.int(3,     "Stochastic %K Smooth",    minval=1,   maxval=10,   group=grpCustom)
c_macdFast    = input.int(12,    "MACD Fast Length",        minval=3,   maxval=50,   group=grpCustom)
c_macdSlow    = input.int(26,    "MACD Slow Length",        minval=5,   maxval=100,  group=grpCustom)
c_macdSig     = input.int(9,     "MACD Signal Length",      minval=1,   maxval=30,   group=grpCustom)
c_adxLen      = input.int(14,    "ADX Length",              minval=5,   maxval=50,   group=grpCustom)
c_adxThresh   = input.float(20.0,"ADX Threshold",           minval=10.0,maxval=40.0, step=1.0, group=grpCustom)
c_crossLook   = input.int(10,    "Cross Lookback (buy)",    minval=1,   maxval=50,   group=grpCustom)
c_underLook   = input.int(10,    "Cross Lookback (sell)",   minval=1,   maxval=50,   group=grpCustom)
c_cooldown    = input.int(10,    "Signal Cooldown (bars)",  minval=0,   maxval=100,  group=grpCustom)
c_minScore    = input.int(5,     "Min Score for Buy (0-10)",minval=0,   maxval=10,   group=grpCustom)
c_sellScore   = input.int(3,     "Max Score for Sell (0-10)",minval=0,  maxval=10,   group=grpCustom)

// ── Shared Display ─────────────────────────────────────────────
grpDisp  = "🖥️ Display"
showStop = input.bool(true,  "Show ATR Stop Zone",   group=grpDisp)
showBG   = input.bool(true,  "Show Regime BG Color", group=grpDisp)
showBuy  = input.bool(true,  "Show Buy Signals",     group=grpDisp)
showSell = input.bool(true,  "Show Sell Signals",    group=grpDisp)
showDash = input.bool(true,  "Show Dashboard",       group=grpDisp)
dashPos  = input.string("Top Right", "Dashboard Position",
           options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpDisp)
rsBench  = input.symbol("SPY", "Benchmark Symbol (RS)", group=grpDisp)

// ╔══════════════════════════════════════════════════════════════╗
// ║           PRESET PARAMETER RESOLUTION                        ║
// ╚══════════════════════════════════════════════════════════════╝

is3m = tfMode == "3m Scalp"
is1H = tfMode == "1H Swing"
is1D = tfMode == "1D Position"

fastLen     = is3m ? 8    : is1H ? 13   : is1D ? 21   : c_fastLen
slowLen     = is3m ? 21   : is1H ? 34   : is1D ? 55   : c_slowLen
trendLen    = is3m ? 100  : is1H ? 150  : is1D ? 200  : c_trendLen
epsRocLen   = is3m ? 5    : is1H ? 12   : is1D ? 20   : c_epsRocLen
epsAccelLen = is3m ? 3    : is1H ? 6    : is1D ? 10   : c_epsAccelLen
epsThresh   = is3m ? 1.0  : is1H ? 1.5  : is1D ? 2.0  : c_epsThresh
rsLen       = is3m ? 20   : is1H ? 30   : is1D ? 50   : c_rsLen
rsThresh    = is3m ? 1.02 : is1H ? 1.03 : is1D ? 1.05 : c_rsThresh
volLen      = is3m ? 10   : is1H ? 14   : is1D ? 20   : c_volLen
volMult     = is3m ? 2.0  : is1H ? 1.75 : is1D ? 1.5  : c_volMult
atrLen      = is3m ? 7    : is1H ? 10   : is1D ? 14   : c_atrLen
atrMult     = is3m ? 1.5  : is1H ? 2.0  : is1D ? 2.5  : c_atrMult
regimeLen   = 50
strictReg   = is3m ? false : is1H ? false : is1D ? true  : c_strict
stochK      = 14
stochD      = 3
stochSmooth = 3
macdFast    = 12
macdSlow    = 26
macdSig     = 9
adxLen      = is3m ? 10   : is1H ? 14   : is1D ? 14   : c_adxLen
adxThresh   = is3m ? 18.0 : is1H ? 20.0 : is1D ? 20.0 : c_adxThresh
crossLook   = is3m ? 8    : is1H ? 10   : is1D ? 7    : c_crossLook
underLook   = is3m ? 8    : is1H ? 10   : is1D ? 7    : c_underLook
cooldown    = is3m ? 5    : is1H ? 8    : is1D ? 15   : c_cooldown
minScore    = is3m ? 5    : is1H ? 5    : is1D ? 5    : c_minScore
sellScore   = is3m ? 3    : is1H ? 3    : is1D ? 3    : c_sellScore

// ╔══════════════════════════════════════════════════════════════╗
// ║        CORE CALCULATIONS — 10 SCORED FACTORS                ║
// ║                                                              ║
// ║  F1  Trend (EMA ribbon)        max 2 pts                    ║
// ║  F2  EPS Momentum proxy        max 1 pt                     ║
// ║  F3  Relative Strength vs SPY  max 1 pt                     ║
// ║  F4  Volume Surge              max 1 pt                     ║
// ║  F5  Market Regime (EMA)       max 1 pt                     ║
// ║  F6  RSI (>50, not OB)         max 1 pt                     ║
// ║  F7  Stochastic %K/%D          max 1 pt                     ║
// ║  F8  MACD histogram bullish    max 1 pt   ← NEW v5          ║
// ║  F9  Price above VWAP          max 1 pt   ← NEW v5          ║
// ║  F10 ADX trend strength ≥ 20   max 1 pt   ← NEW v5          ║
// ║                          TOTAL max 10 pts                   ║
// ╚══════════════════════════════════════════════════════════════╝

// ── F1: Relative Timing (EMA Trend) ── max 2 pts ───────────────
emaFast   = ta.ema(close, fastLen)
emaSlow   = ta.ema(close, slowLen)
emaTrend  = ta.ema(close, trendLen)
bullTrend  = emaFast > emaSlow
bearTrend  = emaFast < emaSlow
aboveTrend = close > emaTrend
trendScore = bullTrend and aboveTrend ? 2 : bullTrend or aboveTrend ? 1 : 0

// ── F2: EPS Momentum Proxy ── max 1 pt ─────────────────────────
roc1      = ta.roc(close, epsRocLen)
roc2      = ta.roc(close, epsRocLen * 2)
epsAccel  = roc1 - roc2
epsSmooth = ta.ema(epsAccel, epsAccelLen)
epsSignal = epsSmooth > epsThresh
epsScore  = epsSignal ? 1 : 0

// ── F3: Relative Strength vs Benchmark ── max 1 pt ─────────────
benchClose = request.security(rsBench, timeframe.period, close)
stockPerf  = close / close[rsLen]
benchPerf  = benchClose / benchClose[rsLen]
rsRatio    = stockPerf / benchPerf
rsStrong   = rsRatio >= rsThresh
rsScore    = rsStrong ? 1 : 0

// ── F4: Volume Surge ── max 1 pt ───────────────────────────────
volMA    = ta.sma(volume, volLen)
volSurge = volume >= volMA * volMult
volScore = volSurge ? 1 : 0

// ── F5: Market Regime ── max 1 pt ──────────────────────────────
regimeEMA     = ta.ema(close, regimeLen)
regimeRising  = ta.rising(regimeEMA, 3)
regimeFalling = ta.falling(regimeEMA, 3)
bullRegime = strictReg ? (close > regimeEMA and regimeRising)  : (close > regimeEMA)
bearRegime = strictReg ? (close < regimeEMA and regimeFalling) : (close < regimeEMA)
neutRegime = not bullRegime and not bearRegime
regimeScore = bullRegime ? 1 : 0

// ── F6: RSI ── max 1 pt ────────────────────────────────────────
rsi14    = ta.rsi(close, 14)
notOB    = rsi14 < 75
notOS    = rsi14 > 25
rsiScore = (rsi14 > 50 and notOB) ? 1 : 0

// ── F7: Stochastic ── max 1 pt ─────────────────────────────────
stochKval  = ta.sma(ta.stoch(close, high, low, stochK), stochSmooth)
stochDval  = ta.sma(stochKval, stochD)
stochBull  = stochKval > stochDval and stochKval < 80
stochBear  = stochKval < stochDval and stochKval > 20
stochScore = stochBull ? 1 : 0

// ── F8: MACD ── max 1 pt ───────────────────────────────────────
// Scores 1 if: histogram is positive AND rising (momentum expanding up)
[macdLine, macdSignal, macdHist] = ta.macd(close, macdFast, macdSlow, macdSig)
macdBull  = macdHist > 0 and macdHist > macdHist[1]
macdBear  = macdHist < 0 and macdHist < macdHist[1]
macdScore = macdBull ? 1 : 0

// ── F9: VWAP ── max 1 pt ───────────────────────────────────────
// Scores 1 if price is above VWAP (institutional intraday bias)
// Note: VWAP resets daily so is most meaningful on intraday TFs
// On daily chart it reflects price vs session VWAP (still valid directional signal)
vwapVal   = ta.vwap(hlc3)
aboveVWAP = close > vwapVal
vwapScore = aboveVWAP ? 1 : 0

// ── F10: ADX (Trend Strength) ── max 1 pt ──────────────────────
// Scores 1 if ADX >= threshold (trend is strong enough to trade)
// Filters out choppy/sideways markets that generate false signals
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)
adxStrong = adxVal >= adxThresh
adxScore  = adxStrong ? 1 : 0

// ── COMPOSITE SCORE (0–10) ─────────────────────────────────────
totalScore = trendScore + epsScore + rsScore + volScore + regimeScore + rsiScore + stochScore + macdScore + vwapScore + adxScore

// ── ATR Stop ───────────────────────────────────────────────────
atr       = ta.atr(atrLen)
trailStop = bullTrend ? close - atr * atrMult : close + atr * atrMult

// ╔══════════════════════════════════════════════════════════════╗
// ║              SIGNAL LOGIC                                    ║
// ╚══════════════════════════════════════════════════════════════╝

barsSinceCross = ta.barssince(ta.crossover(emaFast, emaSlow))
barsSinceUnder = ta.barssince(ta.crossunder(emaFast, emaSlow))
recentCross    = not na(barsSinceCross) and barsSinceCross <= crossLook
recentUnder    = not na(barsSinceUnder) and barsSinceUnder <= underLook

var int lastBuyBar  = -100
var int lastSellBar = -100
buyReady  = cooldown == 0 or (bar_index - lastBuyBar)  > cooldown
sellReady = cooldown == 0 or (bar_index - lastSellBar) > cooldown

buySignal  = totalScore >= minScore and bullTrend and bullRegime and recentCross and buyReady
sellSignal = totalScore <= sellScore and bearTrend and bearRegime and recentUnder and sellReady

if buySignal
    lastBuyBar := bar_index
if sellSignal
    lastSellBar := bar_index

// ╔══════════════════════════════════════════════════════════════╗
// ║              VISUAL RENDERING                                ║
// ╚══════════════════════════════════════════════════════════════╝

cBull     = color.new(#00E676, 0)
cBear     = color.new(#FF1744, 0)
cNeutral  = color.new(#FFD600, 0)
cFast     = color.new(#00BCD4, 0)
cSlow     = color.new(#9C27B0, 0)
cTrend    = color.new(#FF9800, 30)
cStop     = color.new(#FF5722, 70)
cBullBG   = color.new(#00E676, 95)
cBearBG   = color.new(#FF1744, 95)
cNeutBG   = color.new(#FFD600, 97)
cVolSurge = color.new(#FF9800, 0)

// Bar color scaled to /10
barCol = totalScore >= 8 ? color.new(#00E676, 0) :
         totalScore >= 6 ? color.new(#69F0AE, 0) :
         totalScore >= 5 ? color.new(#FFD600, 0) :
         totalScore >= 4 ? color.new(#FF9800, 0) :
         totalScore >= 2 ? color.new(#FF5722, 0) :
                           color.new(#FF1744, 0)
barcolor(barCol, title="Momentum Score Bar Color")

bgcolor(
     showBG and bullRegime ? cBullBG :
     showBG and bearRegime ? cBearBG :
     showBG and neutRegime ? cNeutBG : na,
     title="Market Regime Background"
     )

p1 = plot(emaFast,  "Fast EMA",  color=cFast,  linewidth=2)
p2 = plot(emaSlow,  "Slow EMA",  color=cSlow,  linewidth=2)
p3 = plot(emaTrend, "Trend EMA", color=cTrend, linewidth=1, style=plot.style_line)
fill(p1, p2, color=bullTrend ? color.new(#00E676, 80) : color.new(#FF1744, 80), title="Trend Ribbon Fill")

stopPlot = plot(showStop and bullTrend ? trailStop : na, "ATR Trailing Stop", color=cStop, linewidth=1, style=plot.style_linebr)
pClose   = plot(close, display=display.none)
fill(pClose, stopPlot, color=showStop and bullTrend ? color.new(#FF5722, 92) : na, title="Stop Zone Fill")

plotshape(volSurge and bullTrend,      title="Volume Surge",  style=shape.diamond,    location=location.belowbar, color=cVolSurge,                  size=size.tiny)
plotshape(showBuy  and buySignal,      title="BUY Signal",    style=shape.labelup,    location=location.belowbar, color=cBull,     textcolor=color.white, size=size.normal, text="▲ BUY")
plotshape(showSell and sellSignal,     title="SELL Signal",   style=shape.labeldown,  location=location.abovebar, color=cBear,     textcolor=color.white, size=size.normal, text="▼ SELL")
plotshape(epsSignal and not buySignal, title="EPS Accel",     style=shape.circle,     location=location.belowbar, color=color.new(#00BCD4, 40),     size=size.tiny)
plotshape(stochBull and not buySignal, title="Stoch Bull",    style=shape.triangleup, location=location.belowbar, color=color.new(#9C27B0, 40),     size=size.tiny)
plotshape(macdBull  and not buySignal, title="MACD Bull",     style=shape.cross,      location=location.belowbar, color=color.new(#00E676, 50),     size=size.tiny)


// ╔══════════════════════════════════════════════════════════════╗
// ║   SCORE DASHBOARD  v5.2 — COMPACT / HIGH CONTRAST / 3-COL   ║
// ╚══════════════════════════════════════════════════════════════╝

scoreBlock(val, maxVal) =>
    out = ""
    for i = 1 to maxVal
        out += i <= val ? "█" : "░"
    out

// Short preset labels — saves width
// Colors: 3M=GREEN, 1H=YELLOW, 1D=RED, CUSTOM=PURPLE
presetLabel = is3m ? "3M" : is1H ? "1H" : is1D ? "1D" : "C"
presetCol   = is3m ? color.new(#00E676, 0) : is1H ? color.new(#FFD600, 0) : is1D ? color.new(#FF4444, 0) : color.new(#CE93D8, 0)
presetBG    = is3m ? color.new(#003300, 0) : is1H ? color.new(#2B2200, 0) : is1D ? color.new(#3A0000, 0) : color.new(#1A0033, 0)

// Score banner — 7-10 green | 5-6 yellow | 0-4 bright red
scoreBannerCol = totalScore >= 7 ? color.new(#00E676, 0) :
                 totalScore >= 5 ? color.new(#FFD600, 0) :
                                   color.new(#FF4444, 0)
scoreBannerBG  = totalScore >= 7 ? color.new(#003300, 0) :
                 totalScore >= 5 ? color.new(#2B2200, 0) :
                                   color.new(#3A0000, 0)
scoreBannerTxt = totalScore >= 7 ? "BUY ▲"  :
                 totalScore >= 5 ? "WATCH →" :
                                   "AVOID ✗"

// ── HIGH CONTRAST PALETTE — all white, bright red, no grays ────
cWhite   = color.white
cRed     = color.new(#FF4444, 0)   // bright red — replaces #FF1744 (too dark)
cBorder  = color.new(#666666, 0)
cRowA    = color.new(#1A1A1A, 0)
cRowB    = color.new(#141414, 0)
cRowInfo = color.new(#0F0F0F, 0)
cHdrBG   = color.new(#111111, 0)

// 3 columns: [FACTOR | STATUS | PTS]
// Row 0: [ score+preset | verdict ]  (2 cells, col 1 merged into col 0 partial)
var table dash = table.new(
     position     = dashPos == "Top Right"    ? position.top_right    :
                    dashPos == "Top Left"     ? position.top_left     :
                    dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left,
     columns      = 3,
     rows         = 14,
     bgcolor      = color.new(#0D0D0D, 10),
     border_width = 1,
     border_color = cBorder,
     frame_width  = 2,
     frame_color  = scoreBannerCol
     )

if showDash and barstate.islast

    // ── ROW 0: BUFFER | SCORE+VERDICT | PRESET BADGE ─────────────
    // Col 0 is a blank spacer — keeps score away from the dropdown arrow
    // Col 1 holds score + verdict in center
    // Col 2 holds the TF preset badge pushed to far right
    scoreCell = str.tostring(totalScore) + "/10  " + scoreBannerTxt
    table.cell(dash, 0, 0, "  ",
         text_color=scoreBannerCol, text_size=size.tiny,
         bgcolor=scoreBannerBG, text_halign=text.align_center)
    table.cell(dash, 1, 0, scoreCell,
         text_color=scoreBannerCol, text_size=size.small,
         bgcolor=scoreBannerBG, text_halign=text.align_center)
    table.cell(dash, 2, 0, presetLabel,
         text_color=presetCol, text_size=size.small,
         bgcolor=presetBG, text_halign=text.align_center)


    // ── ROW 1: F1 Trend ────────────────────────────────────────
    trendTxt = trendScore == 2 ? "STRONG" : trendScore == 1 ? "MIXED" : "WEAK"
    trendCol = trendScore == 2 ? cBull : trendScore == 1 ? cNeutral : cRed
    table.cell(dash, 0, 1, "TIMING",  text_color=cWhite,   text_size=size.tiny, bgcolor=cRowA, text_halign=text.align_left)
    table.cell(dash, 1, 1, trendTxt,  text_color=trendCol, text_size=size.tiny, bgcolor=cRowA, text_halign=text.align_center)
    table.cell(dash, 2, 1, scoreBlock(trendScore, 2), text_color=trendCol, text_size=size.tiny, bgcolor=cRowA, text_halign=text.align_center)

    // ── ROW 2: F2 EPS ─────────────────────────────────────────
    epsTxt = epsSignal ? "ACCEL" : "FLAT"
    epsCol = epsSignal ? cBull : cRed
    table.cell(dash, 0, 2, "EPS",     text_color=cWhite, text_size=size.tiny, bgcolor=cRowB, text_halign=text.align_left)
    table.cell(dash, 1, 2, epsTxt,    text_color=epsCol, text_size=size.tiny, bgcolor=cRowB, text_halign=text.align_center)
    table.cell(dash, 2, 2, scoreBlock(epsScore, 1), text_color=epsCol, text_size=size.tiny, bgcolor=cRowB, text_halign=text.align_center)

    // ── ROW 3: F3 RS ──────────────────────────────────────────
    rsTxt = rsStrong ? "OUTPERF" : "LAGGING"
    rsCol = rsStrong ? cBull : cRed
    table.cell(dash, 0, 3, "REL STR", text_color=cWhite, text_size=size.tiny, bgcolor=cRowA, text_halign=text.align_left)
    table.cell(dash, 1, 3, rsTxt,     text_color=rsCol,  text_size=size.tiny, bgcolor=cRowA, text_halign=text.align_center)
    table.cell(dash, 2, 3, scoreBlock(rsScore, 1), text_color=rsCol, text_size=size.tiny, bgcolor=cRowA, text_halign=text.align_center)

    // ── ROW 4: F4 Volume ──────────────────────────────────────
    volTxt = volSurge ? "SURGE" : "NORMAL"
    volCol = volSurge ? cVolSurge : cWhite
    table.cell(dash, 0, 4, "VOLUME",  text_color=cWhite, text_size=size.tiny, bgcolor=cRowB, text_halign=text.align_left)
    table.cell(dash, 1, 4, volTxt,    text_color=volCol, text_size=size.tiny, bgcolor=cRowB, text_halign=text.align_center)
    table.cell(dash, 2, 4, scoreBlock(volScore, 1), text_color=volCol, text_size=size.tiny, bgcolor=cRowB, text_halign=text.align_center)

    // ── ROW 5: F5 Regime ──────────────────────────────────────
    regimeTxt = bullRegime ? "BULL" : bearRegime ? "BEAR" : "NEUTRAL"
    regimeCol = bullRegime ? cBull : bearRegime ? cRed : cNeutral
    table.cell(dash, 0, 5, "REGIME",  text_color=cWhite,    text_size=size.tiny, bgcolor=cRowA, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt, text_color=regimeCol, text_size=size.tiny, bgcolor=cRowA, text_halign=text.align_center)
    table.cell(dash, 2, 5, scoreBlock(regimeScore, 1), text_color=regimeCol, text_size=size.tiny, bgcolor=cRowA, text_halign=text.align_center)

    // ── ROW 6: F6 RSI ─────────────────────────────────────────
    rsiTxt = rsi14 >= 75 ? "OB " + str.tostring(math.round(rsi14)) :
             rsi14 <= 25 ? "OS " + str.tostring(math.round(rsi14)) :
             str.tostring(math.round(rsi14))
    rsiCol = rsi14 >= 75 ? cRed : rsi14 <= 25 ? cBull : rsi14 > 50 ? cBull : cRed
    table.cell(dash, 0, 6, "RSI",     text_color=cWhite, text_size=size.tiny, bgcolor=cRowB, text_halign=text.align_left)
    table.cell(dash, 1, 6, rsiTxt,    text_color=rsiCol, text_size=size.tiny, bgcolor=cRowB, text_halign=text.align_center)
    table.cell(dash, 2, 6, scoreBlock(rsiScore, 1), text_color=rsiCol, text_size=size.tiny, bgcolor=cRowB, text_halign=text.align_center)

    // ── ROW 7: F7 Stochastic ──────────────────────────────────
    stochTxt = stochBull ? "K=" + str.tostring(math.round(stochKval)) + " BULL" :
               stochBear ? "K=" + str.tostring(math.round(stochKval)) + " BEAR" :
               "K=" + str.tostring(math.round(stochKval)) + " OB"
    stochCol = stochBull ? cBull : stochBear ? cRed : cNeutral
    table.cell(dash, 0, 7, "STOCH",   text_color=cWhite,   text_size=size.tiny, bgcolor=cRowA, text_halign=text.align_left)
    table.cell(dash, 1, 7, stochTxt,  text_color=stochCol, text_size=size.tiny, bgcolor=cRowA, text_halign=text.align_center)
    table.cell(dash, 2, 7, scoreBlock(stochScore, 1), text_color=stochCol, text_size=size.tiny, bgcolor=cRowA, text_halign=text.align_center)

    // ── ROW 8: F8 MACD ────────────────────────────────────────
    macdTxt = macdBull ? "BULL " + str.tostring(math.round(macdHist * 100) / 100) :
              macdBear ? "BEAR " + str.tostring(math.round(macdHist * 100) / 100) :
              str.tostring(math.round(macdHist * 100) / 100)
    macdCol = macdBull ? cBull : macdBear ? cRed : cNeutral
    table.cell(dash, 0, 8, "MACD",    text_color=cWhite,  text_size=size.tiny, bgcolor=cRowB, text_halign=text.align_left)
    table.cell(dash, 1, 8, macdTxt,   text_color=macdCol, text_size=size.tiny, bgcolor=cRowB, text_halign=text.align_center)
    table.cell(dash, 2, 8, scoreBlock(macdScore, 1), text_color=macdCol, text_size=size.tiny, bgcolor=cRowB, text_halign=text.align_center)

    // ── ROW 9: F9 VWAP ───────────────────────────────────────
    vwapTxt = aboveVWAP ? "ABOVE" : "BELOW"
    vwapCol = aboveVWAP ? cBull : cRed
    table.cell(dash, 0, 9, "VWAP",    text_color=cWhite,  text_size=size.tiny, bgcolor=cRowA, text_halign=text.align_left)
    table.cell(dash, 1, 9, vwapTxt,   text_color=vwapCol, text_size=size.tiny, bgcolor=cRowA, text_halign=text.align_center)
    table.cell(dash, 2, 9, scoreBlock(vwapScore, 1), text_color=vwapCol, text_size=size.tiny, bgcolor=cRowA, text_halign=text.align_center)

    // ── ROW 10: F10 ADX ──────────────────────────────────────
    adxTxt = adxStrong ? "ADX " + str.tostring(math.round(adxVal)) : "WEAK " + str.tostring(math.round(adxVal))
    adxCol = adxStrong ? cBull : cRed
    table.cell(dash, 0, 10, "ADX",    text_color=cWhite, text_size=size.tiny, bgcolor=cRowB, text_halign=text.align_left)
    table.cell(dash, 1, 10, adxTxt,   text_color=adxCol, text_size=size.tiny, bgcolor=cRowB, text_halign=text.align_center)
    table.cell(dash, 2, 10, scoreBlock(adxScore, 1), text_color=adxCol, text_size=size.tiny, bgcolor=cRowB, text_halign=text.align_center)

    // ── ROW 11: EMA Cross ────────────────────────────────────
    crossBars   = na(barsSinceCross) ? 999 : barsSinceCross
    crossStatus = crossBars <= crossLook ? str.tostring(crossBars) + "B AGO" :
                  crossBars <= 20        ? str.tostring(crossBars) + "B OLD" :
                                           str.tostring(crossBars) + "B WAIT"
    crossCol    = crossBars <= crossLook ? cBull : crossBars <= 20 ? cNeutral : cRed
    table.cell(dash, 0, 11, "EMA X",     text_color=cWhite,    text_size=size.tiny, bgcolor=cRowInfo, text_halign=text.align_left)
    table.cell(dash, 1, 11, crossStatus, text_color=crossCol,  text_size=size.tiny, bgcolor=cRowInfo, text_halign=text.align_center)
    table.cell(dash, 2, 11, crossBars <= crossLook ? "IN WIN" : "WAIT", text_color=crossCol, text_size=size.tiny, bgcolor=cRowInfo, text_halign=text.align_center)

    // ── ROW 12: Active EMAs ───────────────────────────────────
    emaInfoTxt = str.tostring(fastLen) + "/" + str.tostring(slowLen) + "/" + str.tostring(trendLen)
    table.cell(dash, 0, 12, "EMAS",      text_color=cWhite, text_size=size.tiny, bgcolor=cRowInfo, text_halign=text.align_left)
    table.cell(dash, 1, 12, emaInfoTxt,  text_color=cWhite, text_size=size.tiny, bgcolor=cRowInfo, text_halign=text.align_center)
    table.cell(dash, 2, 12, "F/S/T",     text_color=cWhite, text_size=size.tiny, bgcolor=cRowInfo, text_halign=text.align_center)

    // ── ROW 13: Cooldown ─────────────────────────────────────
    barsSinceLastBuy = bar_index - lastBuyBar
    cooldownTxt = barsSinceLastBuy > cooldown ? "READY" : str.tostring(cooldown - barsSinceLastBuy) + "B LEFT"
    cooldownCol = barsSinceLastBuy > cooldown ? cBull : cNeutral
    table.cell(dash, 0, 13, "COOLDOWN",  text_color=cWhite,    text_size=size.tiny, bgcolor=cRowInfo, text_halign=text.align_left)
    table.cell(dash, 1, 13, cooldownTxt, text_color=cooldownCol,text_size=size.tiny, bgcolor=cRowInfo, text_halign=text.align_center)
    table.cell(dash, 2, 13, str.tostring(cooldown) + "B CD", text_color=cWhite, text_size=size.tiny, bgcolor=cRowInfo, text_halign=text.align_center)

// ╔══════════════════════════════════════════════════════════════╗
// ║                      ALERTS                                  ║
// ╚══════════════════════════════════════════════════════════════╝

alertcondition(buySignal,
     title   = "DP·VST — BUY Signal",
     message = "DP·VST BUY ▲ | {{ticker}} | Price: {{close}} | TF: {{interval}} | Check dashboard for score /10"
     )
alertcondition(sellSignal,
     title   = "DP·VST — SELL / Exit Signal",
     message = "DP·VST SELL ▼ | {{ticker}} | Price: {{close}} | TF: {{interval}} | Trend + regime breakdown"
     )
alertcondition(totalScore >= 8 and bullRegime,
     title   = "DP·VST — High Score Setup (8+/10)",
     message = "DP·VST HIGH SCORE | {{ticker}} | Price: {{close}} | Score 8+/10 | Strong confluence setup"
     )
alertcondition(volSurge and macdBull and bullTrend,
     title   = "DP·VST — Volume + MACD Surge",
     message = "DP·VST VOL+MACD | {{ticker}} | Price: {{close}} | Volume surge with MACD bull momentum"
     )
````
