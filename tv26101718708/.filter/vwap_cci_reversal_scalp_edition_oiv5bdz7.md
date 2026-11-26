# VWAP CCI Reversal  Scalp Edition

- url: https://www.tradingview.com/script/OIv5BdZ7/
- type: indicator
- pine_id: PUB;e29f018764db4eee8a07fccf72574e96
- version: 6.0

## Description

1. What Is This Indicator?
VWAP CCI Reversal (Scalp Edition) is a precision counter-trend indicator designed to catch short-term price reversals at statistically significant extremes. It combines two powerful concepts:

•	VWAP Standard Deviation Bands — identifies where price is statistically “too far” from the institutional average cost
•	CCI (±100) Crossback — detects the exact moment momentum shifts from extreme back toward neutral

Core idea: When price reaches the ±2σ VWAP band AND the CCI crosses back through ±100, the market is showing a high-probability mean-reversion setup. You are buying the statistical bottom and selling the statistical top — not guessing, but reacting to confirmed exhaustion.

IMPORTANT: This indicator is designed for intraday scalping on 1m, 3m, and 5m charts. It resets the Daily VWAP at midnight (server time). Do not use on daily or weekly charts.

2. How Signals Work
2.1 Buy Signal (Bottom Hunt) — BUY label
All of the following conditions must be true simultaneously:

•	Price low touches the −2σ VWAP band zone (the red shaded area below VWAP)
•	CCI crosses back above −100 (oversold exhaustion confirmed)
•	CCI reached below −120 within the last 10 bars (genuine extreme was visited)
•	Current candle closes bullish (close > open)
•	Volume exceeds its 20-bar average (real buying pressure, not a slow drift)

Take profit targets: TP1 = entry + ATR × 2.0   TP2 = entry + ATR × 3.5
Stop loss: entry − ATR × 1.5 (automatically drawn on chart for 15 bars)

2.2 Sell Signal (Top Hunt) — SELL label
The mirror image of the buy signal:

•	Price high touches the +2σ VWAP band zone (the upper red shaded area)
•	CCI crosses back below +100 (overbought exhaustion confirmed)
•	CCI reached above +120 within the last 10 bars
•	Current candle closes bearish (close < open)
•	Volume exceeds its 20-bar average

Take profit targets: TP1 = entry − ATR × 2.0   TP2 = entry − ATR × 3.5
Stop loss: entry + ATR × 1.5

3. Reading the Chart

Element	Color	Meaning
Daily VWAP	Blue line (thick)	Institutional average cost for today. Price is attracted to this.
Weekly VWAP	Orange dotted line	Larger-scale institutional cost. Above = macro bullish bias.
±1σ Band	Teal lines	Normal range. Price spends most time here. No signal zone.
±2σ Band	Orange lines	Extended range. Price reaching here = statistically stretched.
±3σ Band	Red lines	Extreme range. Rare. High-impact reversal if CCI confirms.
Red shaded zones	Between ±2σ and ±3σ	Active signal zone. Where BUY/SELL signals can appear.
BUY (green triangle)	Below bar	Long entry signal. All 5 conditions confirmed.
SELL (red triangle)	Above bar	Short entry signal. All 5 conditions confirmed.
SL / TP1 / TP2 lines	Red / Teal / Green	Risk management levels. Auto-drawn after signal, fades after 15 bars.
Bar highlight	Green or red glow	The exact signal bar for quick visual reference.

4. Settings Guide
4.1 CCI Settings
Parameter	Default	What It Does	When to Change
CCI Period	9	How many bars CCI looks back. Shorter = faster, noisier.	Try 7 for 1m, 10–14 for 5m.
CCI EMA Smoothing	2	Smooths the CCI line to reduce whipsaws.	Raise to 3–5 to cut false signals.

4.2 VWAP Band Settings
Parameter	Default	What It Does	When to Change
Band 1 Multiplier	1.0	Sets the inner (±1σ) boundary.	Leave at 1.0 in most cases.
Band 2 Multiplier	2.0	Sets the signal zone boundary. Price must reach this.	Lower to 1.5 for more signals.
Band 3 Multiplier	3.0	Sets the outer extreme boundary.	Raise to 3.5 for quieter markets.
Zone Buffer	0.5	How far beyond ±2σ price is still accepted (in σ units).	Raise to 0.8 if signals are too rare.

4.3 Confirmation Filters
Filter	Default	Purpose	Tip
Weekly VWAP Bias	OFF	Only buy above / sell below the weekly VWAP.	Turn ON for swing context awareness.
Volume Confirmation	ON	Requires current volume > SMA × multiplier.	Keep ON. Removes dead-market noise.
Volume Multiplier	1.0×	Minimum volume spike required.	Raise to 1.3× for stricter entries.
Reversal Candle	ON	Buy signal needs bullish close, sell needs bearish close.	Keep ON. Filters half-formed moves.
CCI Extreme Visit	ON	CCI must have visited ±120 recently.	Turn OFF if signals are too rare.
Extreme Lookback	10 bars	How far back to check for the CCI extreme.	Raise to 15 on slower instruments.

5. Pro Tips for Scalping
Best times to trade
•	Tokyo session open (09:00–11:00 JST) — strong directional moves, VWAP bands respected
•	London/NY overlap (22:00–24:00 JST) — highest volume, most reliable signals
•	NY open (22:30 JST) — often produces the cleanest ±2σ spikes of the day

Times to avoid
•	Tokyo lunch break (11:30–12:30 JST) — volume collapses, CCI produces false crossbacks
•	First 5 minutes after market open — VWAP and bands not yet stable
•	News events — price can gap through ±3σ and keep going; always check the economic calendar

Tuning signals for your instrument
Instrument	Recommended CCI Period	Zone Buffer	Notes
Forex majors (USD/JPY, EUR/USD)	9	0.5	Standard defaults work well.
Crypto (BTC, ETH)	7	0.8	Higher volatility; widen the zone.
Nikkei / US indices (futures)	10	0.4	Tighter zone; very mean-reverting.
Gold (XAU/USD)	9	0.6	Moderate settings; watch for trend days.

Signal quality checklist
Before entering, confirm all of these mentally:

•	Is the signal bar in the red shaded zone (between ±2σ and ±3σ)?
•	Is there a visible spike in volume on or just before the signal bar?
•	Is the broader VWAP trend aligned? (Price above VWAP = prefer longs)
•	Is there a clean SL level visible on the chart?
•	Is the risk/reward at least 1:2? (Check TP1 vs SL distance)

6. Common Mistakes to Avoid

Mistake 1: Trading during low-volume hours The Volume Confirmation filter helps, but the best practice is to simply avoid trading between midnight and 7:00 JST and during the Tokyo lunch break. The VWAP bands narrow and CCI crossbacks become meaningless.

Mistake 2: Ignoring the trend on trend days On strong trend days, price can stay at ±2σ for extended periods and keep pushing. If you see 3+ consecutive signal bars all in the same direction without follow-through, that is a trend — stand aside.

Mistake 3: Moving the stop loss The SL is placed at ATR × 1.5 for a reason. If price hits your stop, exit. Do not widen the SL hoping for a recovery — this is the single biggest account-killer in scalping.

Mistake 4: Taking TP2 targets on scalp timeframes TP2 (ATR × 3.5) is ambitious for 1–5 minute charts. Consider taking full profit at TP1 and trail a small portion to TP2. A bird in hand is worth more than a theoretical target.

7. Setting Up Alerts
The indicator includes 3 pre-built alert conditions. To set up in TradingView:

•	Right-click on the chart and select “Add Alert”
•	Set Condition to “VWAP CCI Reversal — Scalp Edition”
•	Choose from the available alert triggers:
◦	Bottom Hunt — Long: fires on every buy signal
◦	Top Hunt — Short: fires on every sell signal
◦	Any Reversal Signal: fires on either direction
•	Set notification to “Once Per Bar Close” for confirmed signals (recommended)
•	Or use “Once Per Bar” for faster alerts (more false positives possible)

8. Quick Reference — Default Parameters
Parameter	Default Value	Group
CCI Period	9	CCI Settings
CCI EMA Smoothing	2	CCI Settings
Band 1 Multiplier (±1σ)	1.0	VWAP Bands
Band 2 Multiplier (±2σ, signal zone)	2.0	VWAP Bands
Band 3 Multiplier (±3σ, extreme)	3.0	VWAP Bands
Zone Buffer	0.5σ	Entry Zone Filter
Wide Zone mode	OFF	Entry Zone Filter
Weekly VWAP Bias Filter	OFF	Confirmation Filters
Volume Confirmation	ON	Confirmation Filters
Volume SMA Period	20	Confirmation Filters
Volume Multiplier	1.0×	Confirmation Filters
Reversal Candle Confirmation	ON	Confirmation Filters
Require CCI Extreme Visit (±120)	ON	Confirmation Filters
Extreme CCI Lookback	10 bars	Confirmation Filters
ATR Period (SL/TP)	14	Risk Management
Stop Loss ATR Multiplier	1.5×	Risk Management
TP1 ATR Multiplier	2.0×	Risk Management
TP2 ATR Multiplier	3.5×	Risk Management
SL/TP Display Duration	15 bars	Risk Management

Disclaimer
This indicator is provided for educational purposes only. It does not constitute financial advice. Past performance of any indicator does not guarantee future results. Trading involves substantial risk of loss. Always use proper position sizing and risk management. Never risk more than you can afford to lose.

## Source Code

````pine
//@version=6
indicator(title="VWAP CCI Reversal — Scalp Edition (Chikou Filter)", shorttitle="VWAP CCI Scalp CK", overlay=true, max_bars_back=1000)

// ==========================================
// Groups
// ==========================================

g1 = "VWAP Settings"
g2 = "VWAP Bands"
g3 = "CCI Settings"
g4 = "Entry Zone Filter"
g5 = "Confirmation Filters"
g6 = "Risk Management"
g7 = "Display"
g8 = "Chikou Span Filter"

// ==========================================
// 1. Daily VWAP + Bands
// ==========================================

isNewDay = ta.change(time("D")) != 0

var float cumPV  = 0.0
var float cumVol = 0.0
var float cumPV2 = 0.0

if isNewDay
    cumPV  := 0.0
    cumVol := 0.0
    cumPV2 := 0.0

typPrice = hlc3
cumPV   := cumPV  + typPrice * volume
cumVol  := cumVol + volume
cumPV2  := cumPV2 + typPrice * typPrice * volume

dayVwap  = cumVol > 0 ? cumPV / cumVol : typPrice
variance = cumVol > 0 ? cumPV2 / cumVol - dayVwap * dayVwap : 0.0
stdDev   = variance > 0 ? math.sqrt(variance) : 0.0

// Band multipliers (user configurable)
band1Mult = input.float(1.0, minval=0.5, step=0.25, title="Band 1 Multiplier (inner)", group=g2)
band2Mult = input.float(2.0, minval=1.0, step=0.25, title="Band 2 Multiplier (signal zone)", group=g2)
band3Mult = input.float(3.0, minval=1.5, step=0.25, title="Band 3 Multiplier (extreme)", group=g2)

vU1 = dayVwap + band1Mult * stdDev
vD1 = dayVwap - band1Mult * stdDev
vU2 = dayVwap + band2Mult * stdDev
vD2 = dayVwap - band2Mult * stdDev
vU3 = dayVwap + band3Mult * stdDev
vD3 = dayVwap - band3Mult * stdDev

// Weekly VWAP for bias
isNewWeek = ta.change(time("W")) != 0
var float wCumPV  = 0.0
var float wCumVol = 0.0
if isNewWeek
    wCumPV  := 0.0
    wCumVol := 0.0
wCumPV  := wCumPV  + typPrice * volume
wCumVol := wCumVol + volume
weekVwap = wCumVol > 0 ? wCumPV / wCumVol : typPrice

// ==========================================
// 2. CCI Calculation
// ==========================================

cciLen    = input.int(9, minval=5, maxval=50, title="CCI Period", group=g3,
            tooltip="14〜20推奨。短いほど感度高・ノイズ多。長いほど安定・シグナル少。")
cciSrc    = input(hl2, title="CCI Source", group=g3)
cciSmooth = input.int(2, minval=1, maxval=10, title="CCI EMA Smoothing", group=g3,
            tooltip="1=スムージングなし。3〜5でダマシ軽減。")

cciMa  = ta.sma(cciSrc, cciLen)
cciRaw = (cciSrc - cciMa) / (0.015 * ta.dev(cciSrc, cciLen))
cci    = ta.ema(cciRaw, cciSmooth)

// CCI crossback signals
cciBuyTrigger  = ta.crossover(cci,  -100)  // -100 kara ue-nuke
cciSellTrigger = ta.crossunder(cci,  100)  // +100 kara shita-nuke

// ==========================================
// 3. Entry Zone Detection
// ==========================================

zoneBufferPct = input.float(0.5, minval=0.0, maxval=1.0, step=0.1,
                title="Zone Buffer (σ units beyond band)", group=g4,
                tooltip="バンドからどれだけ外側まで許容するか。0.3 = ±2σの30%外側まで許容")

inBuyZone  = low  <= vD2 + stdDev * zoneBufferPct and low  >= vD3 - stdDev * zoneBufferPct
inSellZone = high >= vU2 - stdDev * zoneBufferPct and high <= vU3 + stdDev * zoneBufferPct

useWideZone = input.bool(false, title="Wide Zone (±1σ以遠 すべて許可)", group=g4,
              tooltip="ONにするとシグナル頻度増加。精度は下がる。")
inBuyZoneW  = close < vD1
inSellZoneW = close > vU1

finalBuyZone  = useWideZone ? inBuyZoneW  : inBuyZone
finalSellZone = useWideZone ? inSellZoneW : inSellZone

// ==========================================
// 4. Confirmation Filters (Precision mode)
// ==========================================

useWeekBias = input.bool(false, title="Weekly VWAP Bias Filter", group=g5,
              tooltip="ONで週次VWAPより上の買い・下の売りのみ許可。逆張りの精度を上げる。")
weekBuyOk   = useWeekBias ? close > weekVwap : true
weekSellOk  = useWeekBias ? close < weekVwap : true

useVolConf  = input.bool(true, title="Volume Confirmation", group=g5)
volLen      = input.int(52, minval=5, title="Volume SMA Period", group=g5)
volMult     = input.float(1.0, minval=0.5, step=0.1, title="Volume Multiplier", group=g5)
volSma      = ta.sma(volume, volLen)
isVolOk     = useVolConf ? volume > volSma * volMult : true

useCandleConf  = input.bool(true, title="Reversal Candle Confirmation", group=g5,
                 tooltip="買いシグナル = 陽線確定足。売りシグナル = 陰線確定足。")
isBullCandle   = close > open
isBearCandle   = close < open
candleBuyOk    = useCandleConf ? isBullCandle : true
candleSellOk   = useCandleConf ? isBearCandle : true

extremeLookback = input.int(10, minval=1, maxval=20, title="Extreme CCI Lookback (bars)", group=g5,
                  tooltip="直近N本以内にCCIが±150を超えていた場合のみシグナル。本物の極値反転を狙う。")
useExtreme  = input.bool(true, title="Require CCI Extreme Visit (±120)", group=g5)
hadExtLow   = ta.lowest(cci, extremeLookback)  < -120
hadExtHigh  = ta.highest(cci, extremeLookback) >  120
extremeBuyOk  = useExtreme ? hadExtLow  : true
extremeSellOk = useExtreme ? hadExtHigh : true

// ==========================================
// 4.5 Chikou Span Touch Filter
// ==========================================

useChikou = input.bool(true, title="遅行スパン接触フィルター", group=g8,
            tooltip="直近N本以内に遅行スパンがローソク足の実体+ヒゲのレンジに接触していた場合のみシグナルを出す。")

chikouShift = input.int(13, minval=1, maxval=52, title="遅行スパン シフト本数", group=g8,
              tooltip="一目均衡表の26期間はTradingView上では25本シフト（当日を1本目に数えるため）。標準は25。")

chikouLB = input.int(26, minval=0, maxval=50, title="接触の有効期間 N本", group=g8,
           tooltip="0 = そのバーで接触していることが必須。5 = 直近5本以内に接触があればOK。")

chikouTolTick = input.float(0.0, minval=0.0, step=1.0, title="接触の許容幅 (tick)", group=g8,
                tooltip="高値・安値のレンジを上下に何tick広げて「接触」とみなすか。0 = ヒゲに完全に触れている必要あり。日経225ミニなら5〜10で緩めになる。")

chikouUse1m = input.bool(true, title="1分足で判定する", group=g8,
              tooltip="ONの場合、チャートが1分超（3分・5分など）でも遅行スパンの接触判定は1分足データで行う。チャートが1分足のときは自動的にチャート足を使用。")

useSegment = input.bool(false, title="線分で接触を判定", group=g8,
             tooltip="遅行スパンの前バー値と現在値を結ぶ線分がローソクのレンジと交差していれば接触とみなす。1分足のまま30秒足相当の取りこぼしを補える。OFFにすると終値の点のみで判定（厳しめ）。")

showChikou = input.bool(false, title="遅行スパンを表示 (チャートTF)", group=g8)

// touch = chikou span (current close plotted N bars back) overlapping the high-low range of that bar
f_chikouRecentTouch(shift, lb, tolTick, seg) =>
    tol   = tolTick * syminfo.mintick
    hiRef = high[shift]
    loRef = low[shift]
    ckHi  = seg ? math.max(close, close[1]) : close
    ckLo  = seg ? math.min(close, close[1]) : close
    touch = not na(hiRef) and not na(loRef) and ckLo <= hiRef + tol and ckHi >= loRef - tol
    nz(ta.barssince(touch), 99999) <= lb

chikouTouchChart = f_chikouRecentTouch(chikouShift, chikouLB, chikouTolTick, useSegment)
chikouTouch1m    = request.security(syminfo.tickerid, "1",
                     f_chikouRecentTouch(chikouShift, chikouLB, chikouTolTick, useSegment) ? 1 : 0,
                     lookahead=barmerge.lookahead_off)

isHigherThan1m = timeframe.in_seconds("") > 60
useLowerTF     = chikouUse1m and isHigherThan1m
chikouTouchRaw = useLowerTF ? nz(chikouTouch1m, 0) > 0 : chikouTouchChart
chikouOk       = useChikou ? chikouTouchRaw : true

// ==========================================
// 5. Final Signals
// ==========================================

longSignal  = cciBuyTrigger  and finalBuyZone  and weekBuyOk  and isVolOk and candleBuyOk  and extremeBuyOk  and chikouOk
shortSignal = cciSellTrigger and finalSellZone and weekSellOk and isVolOk and candleSellOk and extremeSellOk and chikouOk

// ==========================================
// 6. Risk Management
// ==========================================

atrLen  = input.int(14, minval=5, title="ATR Period", group=g6)
slMult  = input.float(1.5, minval=0.5, step=0.25, title="SL ATR Multiplier", group=g6)
tp1Mult = input.float(2.0, minval=0.5, step=0.25, title="TP1 ATR Multiplier", group=g6)
tp2Mult = input.float(3.5, minval=0.5, step=0.25, title="TP2 ATR Multiplier", group=g6)
showLevels = input.bool(true, title="Show SL / TP Lines", group=g6)
levelBars  = input.int(15, minval=5, maxval=50, title="SL/TP Display Duration (bars)", group=g6)

atrVal = ta.atr(atrLen)

var float slLine  = na
var float tp1Line = na
var float tp2Line = na
var int   barsSinceSig = 999

if longSignal
    slLine     := close - atrVal * slMult
    tp1Line    := close + atrVal * tp1Mult
    tp2Line    := close + atrVal * tp2Mult
    barsSinceSig := 0
else if shortSignal
    slLine     := close + atrVal * slMult
    tp1Line    := close - atrVal * tp1Mult
    tp2Line    := close - atrVal * tp2Mult
    barsSinceSig := 0
else
    barsSinceSig := barsSinceSig + 1

showNow = showLevels and barsSinceSig <= levelBars

// ==========================================
// 7. Plots — VWAP & Bands
// ==========================================

showBands = input.bool(true, title="Show All Bands", group=g7)

plot(dayVwap,  title="Daily VWAP",  color=color.new(#2196F3, 0),  linewidth=2)
plot(weekVwap, title="Weekly VWAP", color=color.new(#FF9800, 20), linewidth=1, style=plot.style_circles)

pU1 = plot(showBands ? vU1 : na, title="+1σ", color=color.new(#26A69A, 70), linewidth=1)
pD1 = plot(showBands ? vD1 : na, title="-1σ", color=color.new(#26A69A, 70), linewidth=1)
pU2 = plot(showBands ? vU2 : na, title="+2σ", color=color.new(#FF9800, 50), linewidth=1)
pD2 = plot(showBands ? vD2 : na, title="-2σ", color=color.new(#FF9800, 50), linewidth=1)
pU3 = plot(showBands ? vU3 : na, title="+3σ", color=color.new(#EF5350, 40), linewidth=1)
pD3 = plot(showBands ? vD3 : na, title="-3σ", color=color.new(#EF5350, 40), linewidth=1)

fill(pU1, pD1, color=color.new(#2196F3, 95), title="±1σ Fill")
fill(pU2, pU1, color=color.new(#FF9800, 90), title="+1~2σ Fill")
fill(pD1, pD2, color=color.new(#FF9800, 90), title="-1~2σ Fill")
fill(pU3, pU2, color=color.new(#EF5350, 88), title="+2~3σ Fill — Signal Zone")
fill(pD2, pD3, color=color.new(#EF5350, 88), title="-2~3σ Fill — Signal Zone")

// Chikou span (chart timeframe)
plot(showChikou ? close : na, title="Chikou Span", color=color.new(#9C27B0, 20),
     linewidth=1, offset=-chikouShift)

// ==========================================
// 8. Plots — Signals
// ==========================================

plotshape(longSignal,  title="Long — Bottom Hunt",  location=location.belowbar,
    style=shape.triangleup, size=size.large,
    color=color.new(#00C853, 0), text="BUY")

plotshape(shortSignal, title="Short — Top Hunt", location=location.abovebar,
    style=shape.triangledown, size=size.large,
    color=color.new(#D50000, 0), text="SELL")

bgcolor(longSignal  ? color.new(#00C853, 88) :
        shortSignal ? color.new(#D50000, 88) : na,
        title="Signal Bar Highlight")

plot(showNow ? slLine  : na, title="Stop Loss", color=color.new(#EF5350, 10), linewidth=1, style=plot.style_linebr)
plot(showNow ? tp1Line : na, title="TP 1",      color=color.new(#26A69A, 10), linewidth=1, style=plot.style_linebr)
plot(showNow ? tp2Line : na, title="TP 2",      color=color.new(#1B5E20, 20), linewidth=1, style=plot.style_linebr)

// ==========================================
// 9. Info Table
// ==========================================

var table tbl = table.new(position.top_right, 2, 9, bgcolor=color.new(color.black, 72))

if barstate.islast
    table.cell(tbl, 0, 0, "VWAP",        text_color=color.white,           text_size=size.small)
    table.cell(tbl, 1, 0, str.tostring(dayVwap, "#.####"),
        text_color=color.new(#2196F3, 0), text_size=size.small)

    table.cell(tbl, 0, 1, "+2σ / -2σ",   text_color=color.white,           text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(vU2, "#.####") + " / " + str.tostring(vD2, "#.####"),
        text_color=color.new(#FF9800, 0), text_size=size.small)

    table.cell(tbl, 0, 2, "CCI",          text_color=color.white,           text_size=size.small)
    cciColor = cci > 100 ? color.red : cci < -100 ? color.lime : color.gray
    table.cell(tbl, 1, 2, str.tostring(cci, "#.#"),
        text_color=cciColor,              text_size=size.small)

    table.cell(tbl, 0, 3, "Buy Zone",     text_color=color.white,           text_size=size.small)
    table.cell(tbl, 1, 3, finalBuyZone  ? "Active" : "-",
        text_color=finalBuyZone  ? color.lime : color.gray, text_size=size.small)

    table.cell(tbl, 0, 4, "Sell Zone",    text_color=color.white,           text_size=size.small)
    table.cell(tbl, 1, 4, finalSellZone ? "Active" : "-",
        text_color=finalSellZone ? color.red  : color.gray, text_size=size.small)

    table.cell(tbl, 0, 5, "Volume",       text_color=color.white,           text_size=size.small)
    table.cell(tbl, 1, 5, isVolOk ? "OK" : "Low",
        text_color=isVolOk ? color.lime : color.gray,       text_size=size.small)

    table.cell(tbl, 0, 6, "Week VWAP",    text_color=color.white,           text_size=size.small)
    wBiasText  = close > weekVwap ? "Above" : "Below"
    wBiasColor = close > weekVwap ? color.lime : color.red
    table.cell(tbl, 1, 6, wBiasText,      text_color=wBiasColor,            text_size=size.small)

    ckSrcText  = useLowerTF ? "1m" : timeframe.period
    ckText     = not useChikou ? "OFF" : chikouTouchRaw ? "Touch (" + ckSrcText + ")" : "No touch"
    ckColor    = not useChikou ? color.gray : chikouTouchRaw ? color.lime : color.gray
    table.cell(tbl, 0, 7, "Chikou",       text_color=color.white,           text_size=size.small)
    table.cell(tbl, 1, 7, ckText,         text_color=ckColor,               text_size=size.small)

    sigText  = longSignal ? "LONG" : shortSignal ? "SHORT" : "-"
    sigColor = longSignal ? color.lime : shortSignal ? color.red : color.gray
    table.cell(tbl, 0, 8, "Signal",        text_color=color.white,          text_size=size.small)
    table.cell(tbl, 1, 8, sigText,          text_color=sigColor,            text_size=size.small)

// ==========================================
// 10. Alerts
// ==========================================

alertcondition(longSignal,
    title="Bottom Hunt — Long",
    message="[BUY] VWAP -2σ ゾーン + CCI -100 クロスバック + 遅行スパン接触 — 底値反転シグナル")

alertcondition(shortSignal,
    title="Top Hunt — Short",
    message="[SELL] VWAP +2σ ゾーン + CCI +100 クロスバック + 遅行スパン接触 — 天井反転シグナル")

alertcondition(longSignal or shortSignal,
    title="Any Reversal Signal",
    message="VWAP CCI Reversal — 反転シグナル発火")
````
