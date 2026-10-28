# CVD Multi Exchange Percentile

- url: https://www.tradingview.com/script/LTpGIOxI/
- type: indicator
- pine_id: PUB;e1c16a08474147dc95114995f78af309
- version: 1.0

## Description

[b]CVD Multi Exchange Percentile[/b]

Aggregated order flow across four major crypto derivatives exchanges — with historical percentile ranking to measure how extreme today's session really is.

A Cumulative Volume Delta (CVD) indicator with daily reset, divergence detection, and absorption signals, built for perpetual futures.
It combines Binance, Bybit, OKX, and Bitget into a single aggregated flow, then ranks it against its own history to give you objective context.

█ 🧩 [b]KEY FEATURES[/b]

🔹 [b]Multi Exchange Aggregation[/b]
Four sources (Binance, Bybit, OKX, Bitget) can be toggled independently. The aggregated delta captures cross-exchange order flow that single-source CVD cannot detect — especially during liquidations or arbitrage-driven moves.

🔹 [b]Historical Percentile System[/b]
Each session's peak CVD is stored in a rolling buffer, separated by direction (bull vs bear). The current session is ranked against this distribution to measure how extreme the flow is compared to recent history.

🔹 [b]Live Percentile[/b]
A real-time percentile tracks the current CVD value as the session develops — no need to wait for session close.

🔹 [b]Swing Divergence[/b]
Detects divergences between price and CVD structure:
- Bullish: price makes lower low, CVD makes higher low
- Bearish: price makes higher high, CVD makes lower high
Filtered by percentile threshold and optional trend filter.

🔹 [b]Volume Absorption[/b]
Highlights conditions where price and CVD move in opposite directions under high volume:
- Bullish absorption: price down, CVD up
- Bearish absorption: price up, CVD down
Requires elevated volume and percentile confirmation.

🔹 [b]Visual Encoding[/b]
Histogram color reflects direction and momentum. Signal markers:
- Divergence bullish: dark green triangle up
- Divergence bearish: blue triangle down
- Absorption bullish: orange circle
- Absorption bearish: purple circle
Optional info table provides real-time stats.

Signal examples on TRXUSDT.P (1H) — three signal types visible:
- Orange circle (Absorption Bull): price dropping but CVD rising on high volume — buying pressure hidden under falling price

- Blue triangle (DIV- Bearish): price making higher high but CVD making lower high — selling pressure building despite rising price

- Purple circle (Absorption Bear): price rising but CVD falling on high volume — selling pressure hidden under rising price

https://www.tradingview.com/x/51cptgMI/

Signal examples on ETHUSDT.P (1H) — bullish signals visible:
- Dark green triangles (DIV+ Bullish): price making lower lows but CVD making higher lows — buying pressure increasing despite falling price, signaling potential reversal

- Orange circle (Absorption Bull): same logic as above — hidden buying under selling candles

https://www.tradingview.com/x/GtCgpCpf/


█ 🔧 [b]HOW IT WORKS[/b]

The script fetches lower-timeframe OHLCV data from each exchange using `request.security_lower_tf()`.
Each intrabar volume is classified using a CLV-based model (close location within range) to estimate buying vs selling pressure. The resulting deltas are summed across all exchanges and accumulated into a daily CVD, resetting at the start of each new UTC session.


█ 📖 [b]HOW TO USE[/b]

Apply the indicator to Perpetual Futures charts (.P).
The symbol is auto-detected from the chart and mapped across all supported exchanges — no manual input needed.
Suggested timeframe: 1H (default percentile lookback is 336 bars, which equals ~14 days on 1H charts).

Signals are contextual, not standalone triggers. Use them to identify:
- flow/price divergences
- potential absorption zones
- extreme participation conditions


█ ⚙️ [b]SETTINGS[/b]

[i]Data Sources (Perpetual Futures Only)[/i] — Enable/disable Binance, Bybit, OKX, Bitget
[i]Settings[/i] — Intrabar precision (1/5/15/60), daily reset
[i]Signals[/i] — Percentile lookback (default 336 bars, ~14 days on 1H), min percentile for divergence (75), swing length (8), trend filter SMA (20), absorption volume lookback (10) and multiplier (1.5), show/hide toggles for divergences, absorption, trend filter, and info table


█ 💡 [b]WHAT MAKES THIS DIFFERENT[/b]

Most CVD indicators rely on a single exchange and lack statistical context.
This script aggregates flow across venues and ranks it using a percentile system, providing a clear measure of whether current activity is extreme or routine.
Bull and bear distributions are handled separately, avoiding distortion from mixed data.


█ ⚠️ [b]LIMITATIONS[/b]

— Works only on perpetual futures (.P required)
— Delta is estimated from OHLCV, not tick-level order book data
— Exchange data availability may vary by symbol
— Intrabar resolution affects precision and performance


█ 📌 [b]DISCLAIMER[/b]

This is a contextual analysis tool, not a signal generator.
It does not provide buy/sell signals and should not be used as a standalone trading system. Always apply proper risk management.

## Source Code

````pine
//@version=6
indicator("CVD Multi Exchange Percentile", overlay=false, precision=2, format=format.volume)

// ══════════════════════════════════════════════════
//  CHECK PERPETUAL FUTURES
// ══════════════════════════════════════════════════
isPerpetual = str.contains(syminfo.ticker, ".P") or str.contains(syminfo.ticker, "PERP") or str.contains(syminfo.ticker, "_PERP")

if not isPerpetual
    runtime.error("⚠ This indicator works only on Perpetual Futures (.P) — Please switch to a perpetual contract (e.g. BTCUSDT.P)")

// ══════════════════════════════════════════════════
//  INPUT - EXCHANGES
// ══════════════════════════════════════════════════
group_ex  = "Data Sources (Perpetual Futures Only)"
uBinance  = input.bool(true,  "Binance", group=group_ex)
uBybit    = input.bool(true,  "Bybit",   group=group_ex)
uOKX      = input.bool(true,  "OKX",     group=group_ex)
uBitget   = input.bool(true,  "Bitget",  group=group_ex)

// ══════════════════════════════════════════════════
//  INPUT - CONFIGURATION
// ══════════════════════════════════════════════════
group_cfg = "Settings"
sourceTF  = input.string("1", "Intrabar Precision (min)", options=["1", "5", "15", "60"], group=group_cfg)
useReset  = input.bool(true,  "Daily Reset", group=group_cfg)

// ══════════════════════════════════════════════════
//  SYMBOL RESOLUTION (auto-detect from chart)
// ══════════════════════════════════════════════════
baseSymbol = str.replace_all(str.replace_all(str.replace_all(syminfo.ticker, ".P", ""), "PERP", ""), "_PERP", "")

symBin = "BINANCE:" + baseSymbol + ".P"
symByb = "BYBIT:"   + baseSymbol + ".P"
symOKX = "OKX:"     + baseSymbol + ".P"
symBgt = "BITGET:"  + baseSymbol + ".P"

// ══════════════════════════════════════════════════
//  INPUT - SIGNALS
// ══════════════════════════════════════════════════
group_sig  = "Signals"
lookbackD  = input.int(336, "Percentile lookback (bars)", minval=10, maxval=720, group=group_sig)
divThresh  = input.int(75, "Min percentile for divergence", minval=50, maxval=95, group=group_sig)
swingLen   = input.int(8,  "Swing length (bars)", minval=3, maxval=30, group=group_sig)
trendLen   = input.int(20, "Trend filter SMA", minval=5, maxval=100, group=group_sig)
absVolLen  = input.int(10, "Absorption volume lookback", minval=5, maxval=50, group=group_sig)
absThresh  = input.float(1.5, "Absorption volume multiplier", minval=1.0, maxval=5.0, step=0.1, group=group_sig, tooltip="Volume > average * multiplier to qualify as absorption")
showDiv    = input.bool(true,  "Show swing divergences", group=group_sig)
showAbs    = input.bool(true,  "Show absorption", group=group_sig)
useTrend   = input.bool(true,  "Trend filter active", group=group_sig)
showTable  = input.bool(true, "Show info table", group=group_sig)

// ══════════════════════════════════════════════════
//  INTRABAR DELTA FUNCTION
// ══════════════════════════════════════════════════
getDelta(s, tf) =>
    [o, h, l, c, v] = request.security_lower_tf(s, tf, [open, high, low, close, volume], ignore_invalid_symbol=true)
    float d = 0.0
    int len = array.size(c)
    if len > 0 and array.size(h) == len and array.size(l) == len and array.size(o) == len and array.size(v) == len
        for i = 0 to len - 1
            op  = array.get(o, i)
            hi  = array.get(h, i)
            lo  = array.get(l, i)
            cl  = array.get(c, i)
            vol = array.get(v, i)
            float buyRatio = 0.5
            if hi != lo
                clvRatio = (cl - lo) / (hi - lo)
                buyRatio := cl >= op ? 0.5 + clvRatio * 0.5 : clvRatio * 0.5
            d += vol * (2.0 * buyRatio - 1.0)
    d

// ══════════════════════════════════════════════════
//  FETCH (Binance primary, others optional)
// ══════════════════════════════════════════════════
dBinVal = getDelta(symBin, sourceTF)
dBybVal = getDelta(symByb, sourceTF)
dOKXVal = getDelta(symOKX, sourceTF)
dBgtVal = getDelta(symBgt, sourceTF)

float dTot = 0.0
dTot := dBinVal + (uBybit ? dBybVal : 0.0) + (uOKX ? dOKXVal : 0.0) + (uBitget ? dBgtVal : 0.0)

// ══════════════════════════════════════════════════
//  DAILY CUMULATIVE CVD
// ══════════════════════════════════════════════════
var float cvdStack = 0.0
dayChange = ta.change(time("D"))
isNewDay  = useReset and dayChange != 0
if isNewDay
    cvdStack := 0.0
cvdStack := cvdStack + dTot

// ══════════════════════════════════════════════════
//  SESSION PEAK (separated by direction)
// ══════════════════════════════════════════════════
var float sessionBullPeak = 0.0
var float sessionBearPeak = 0.0
if isNewDay
    sessionBullPeak := 0.0
    sessionBearPeak := 0.0
if cvdStack > sessionBullPeak
    sessionBullPeak := cvdStack
if cvdStack < sessionBearPeak
    sessionBearPeak := cvdStack

// ══════════════════════════════════════════════════
//  HISTORICAL PEAK BUFFERS (separated by direction)
// ══════════════════════════════════════════════════
var float[] bullPeakBuffer = array.new_float(0)
var float[] bearPeakBuffer = array.new_float(0)
var float prevBullPeak = 0.0
var float prevBearPeak = 0.0

if isNewDay and bar_index > 0
    if prevBullPeak > 0
        array.push(bullPeakBuffer, prevBullPeak)
        if array.size(bullPeakBuffer) > lookbackD
            array.shift(bullPeakBuffer)
    if prevBearPeak < 0
        array.push(bearPeakBuffer, prevBearPeak)
        if array.size(bearPeakBuffer) > lookbackD
            array.shift(bearPeakBuffer)

prevBullPeak := sessionBullPeak
prevBearPeak := sessionBearPeak

// ══════════════════════════════════════════════════
//  PEAK PERCENTILE (session max intensity)
// ══════════════════════════════════════════════════
float bullPct = 0.0
float bearPct = 0.0

if array.size(bullPeakBuffer) >= 5 and sessionBullPeak > 0
    int belowCount = 0
    for i = 0 to array.size(bullPeakBuffer) - 1
        if sessionBullPeak >= array.get(bullPeakBuffer, i)
            belowCount += 1
    bullPct := float(belowCount) / float(array.size(bullPeakBuffer)) * 100.0

if array.size(bearPeakBuffer) >= 5 and sessionBearPeak < 0
    int belowCount = 0
    for i = 0 to array.size(bearPeakBuffer) - 1
        if sessionBearPeak <= array.get(bearPeakBuffer, i)
            belowCount += 1
    bearPct := float(belowCount) / float(array.size(bearPeakBuffer)) * 100.0

// ══════════════════════════════════════════════════
//  LIVE PERCENTILE (current flow state)
// ══════════════════════════════════════════════════
float livePct = 0.0

if cvdStack > 0 and array.size(bullPeakBuffer) >= 5
    int belowCount = 0
    for i = 0 to array.size(bullPeakBuffer) - 1
        if cvdStack >= array.get(bullPeakBuffer, i)
            belowCount += 1
    livePct := float(belowCount) / float(array.size(bullPeakBuffer)) * 100.0

else if cvdStack < 0 and array.size(bearPeakBuffer) >= 5
    int belowCount = 0
    for i = 0 to array.size(bearPeakBuffer) - 1
        if cvdStack <= array.get(bearPeakBuffer, i)
            belowCount += 1
    livePct := float(belowCount) / float(array.size(bearPeakBuffer)) * 100.0

currentPct = livePct

// ══════════════════════════════════════════════════
//  TREND FILTER (price SMA)
// ══════════════════════════════════════════════════
priceSMA  = ta.sma(close, trendLen)
trendBull = close > priceSMA
trendBear = close < priceSMA

// ══════════════════════════════════════════════════
//  SWING DIVERGENCE (no pivot delay)
// ══════════════════════════════════════════════════
priceLocalHigh = ta.highest(close,    swingLen)
priceLocalLow  = ta.lowest(close,     swingLen)
cvdLocalHigh   = ta.highest(cvdStack, swingLen)
cvdLocalLow    = ta.lowest(cvdStack,  swingLen)

prevPriceHigh = ta.highest(close,    swingLen)[swingLen]
prevPriceLow  = ta.lowest(close,     swingLen)[swingLen]
prevCVDHigh   = ta.highest(cvdStack, swingLen)[swingLen]
prevCVDLow    = ta.lowest(cvdStack,  swingLen)[swingLen]

swingBullDiv = priceLocalLow < prevPriceLow and cvdLocalLow > prevCVDLow and bullPct >= divThresh
swingBearDiv = priceLocalHigh > prevPriceHigh and cvdLocalHigh < prevCVDHigh and bearPct >= divThresh

bullDiv = swingBullDiv and (not useTrend or trendBull) and not swingBullDiv[1]
bearDiv = swingBearDiv and (not useTrend or trendBear) and not swingBearDiv[1]

// ══════════════════════════════════════════════════
//  ABSORPTION
// ══════════════════════════════════════════════════
volSMA    = ta.sma(volume, absVolLen)
highVol   = volume > volSMA * absThresh

bearAbsorption = close > close[1] and cvdStack < cvdStack[1] and highVol and bearPct >= divThresh
bullAbsorption = close < close[1] and cvdStack > cvdStack[1] and highVol and bullPct >= divThresh

showBullAbs = bullAbsorption and not bullAbsorption[1]
showBearAbs = bearAbsorption and not bearAbsorption[1]

// ══════════════════════════════════════════════════
//  CVD COLOR
// ══════════════════════════════════════════════════
rising = cvdStack > cvdStack[1]
color barColor = na
if cvdStack >= 0 and rising
    barColor := color.new(#00ffbb, 0)
else if cvdStack >= 0 and not rising
    barColor := color.new(#00ffbb, 60)
else if cvdStack < 0 and not rising
    barColor := color.new(#ff0055, 0)
else
    barColor := color.new(#ff0055, 60)

// ══════════════════════════════════════════════════
//  PLOT CVD
// ══════════════════════════════════════════════════
plot(cvdStack, "CVD", color=barColor, style=plot.style_columns, linewidth=4)
hline(0, "Base", color=color.white, linestyle=hline.style_dotted)

// ══════════════════════════════════════════════════
//  SWING DIVERGENCE SIGNALS — Triangles
// ══════════════════════════════════════════════════
plotshape(showDiv and bullDiv ? cvdStack : na,
     title="DIV+ Bullish",
     style=shape.triangleup,
     location=location.absolute,
     color=color.new(#2e7d32, 0),
     size=size.small,
     offset=0)

plotshape(showDiv and bearDiv ? cvdStack : na,
     title="DIV- Bearish",
     style=shape.triangledown,
     location=location.absolute,
     color=color.new(#1565c0, 0),
     size=size.small,
     offset=0)

// ══════════════════════════════════════════════════
//  ABSORPTION SIGNALS — Circles
// ══════════════════════════════════════════════════
plotshape(showAbs and showBullAbs ? cvdStack : na,
     title="Absorption Bull",
     style=shape.circle,
     location=location.absolute,
     color=color.new(#ff9800, 0),
     size=size.small,
     offset=0)

plotshape(showAbs and showBearAbs ? cvdStack : na,
     title="Absorption Bear",
     style=shape.circle,
     location=location.absolute,
     color=color.new(#9c27b0, 0),
     size=size.small,
     offset=0)

// ══════════════════════════════════════════════════
//  INFO TABLE (optional)
// ══════════════════════════════════════════════════
var table infoT = na

if showTable
    if na(infoT)
        infoT := table.new(position.top_right, 2, 7, bgcolor=color.new(#1a1a2e, 0), border_width=1, border_color=color.new(color.white, 60))

    if barstate.islast
        bullReady = array.size(bullPeakBuffer) >= 5
        bearReady = array.size(bearPeakBuffer) >= 5
        liveReady = bullReady or bearReady
        cvdValCol = cvdStack >= 0 ? color.new(#00e676, 0) : color.new(#ff9800, 0)
        sigStatus = bullDiv ? "DIV+" : bearDiv ? "DIV-" : showBullAbs ? "ABS+" : showBearAbs ? "ABS-" : "none"
        sigCol    = bullDiv or showBullAbs ? color.new(#00e676, 0) : bearDiv or showBearAbs ? color.new(#ff9800, 0) : color.white

        table.cell(infoT, 0, 0, "CVD Today",     text_color=color.white,              text_size=size.small)
        table.cell(infoT, 1, 0, str.tostring(cvdStack, format.volume), text_color=cvdValCol, text_size=size.small)
        table.cell(infoT, 0, 1, "Live Pct",      text_color=color.white,              text_size=size.small)
        table.cell(infoT, 1, 1, liveReady ? str.tostring(math.round(livePct)) + "%" : "...", text_color=cvdValCol, text_size=size.small)
        table.cell(infoT, 0, 2, "Bull Peak",     text_color=color.new(#00e676, 0),    text_size=size.small)
        table.cell(infoT, 1, 2, str.tostring(sessionBullPeak, format.volume), text_color=color.new(#00e676, 0), text_size=size.small)
        table.cell(infoT, 0, 3, "Bull Pct",      text_color=color.new(#00e676, 0),    text_size=size.small)
        table.cell(infoT, 1, 3, bullReady ? str.tostring(math.round(bullPct)) + "%" : "...", text_color=color.new(#00e676, 0), text_size=size.small)
        table.cell(infoT, 0, 4, "Bear Peak",     text_color=color.new(#ff9800, 0),    text_size=size.small)
        table.cell(infoT, 1, 4, str.tostring(sessionBearPeak, format.volume), text_color=color.new(#ff9800, 0), text_size=size.small)
        table.cell(infoT, 0, 5, "Bear Pct",      text_color=color.new(#ff9800, 0),    text_size=size.small)
        table.cell(infoT, 1, 5, bearReady ? str.tostring(math.round(bearPct)) + "%" : "...", text_color=color.new(#ff9800, 0), text_size=size.small)
        table.cell(infoT, 0, 6, "Signal",        text_color=color.white,              text_size=size.small)
        table.cell(infoT, 1, 6, sigStatus,       text_color=sigCol,                   text_size=size.small)
````
