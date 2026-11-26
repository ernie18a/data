# Delta Volume Profile Pro

- url: https://www.tradingview.com/script/YNkc3h6w/
- type: indicator
- pine_id: PUB;a8adb91d11b7492f845731baec1a99c6
- version: 2.0

## Description

Delta Volume Profile Pro is a volume profile indicator built upon the quadrant structure originally introduced by BigBeluga in the Quadro Volume Profile [BigBeluga] script. Full credit for the original concept and core logic goes to BigBeluga.

🔍 What it does
This indicator divides the visible price range into four quadrants relative to the current price and distributes volume across price bins, revealing where the most significant buying and selling activity has occurred above and below the market.
Each quadrant displays:

Upper Sell Quad — sell volume concentrated above the current price
Upper Buy Quad — buy volume concentrated above the current price
Lower Buy Quad — buy volume concentrated below the current price
Lower Sell Quad — sell volume concentrated below the current price

A Point of Control (PoC) dashed line marks the price bin with the highest volume in each quadrant.
Four percentage labels at the current price level show how total volume is distributed across all quadrants, allowing traders to quickly assess the balance between buying and selling pressure on both sides of the market.

⚙️ Original additions over BigBeluga's base
1. Proxy Volume Engine — works on any broker
Many brokers and CFD platforms do not provide usable native volume data. This indicator includes an internal map of 80+ symbols to their most liquid equivalents:

Forex pairs → (tick volume, CFD-compatible scale)
Metals (Gold, Silver, Platinum) 
Crypto (BTC, ETH, etc.) 
Oil, Gas → 
Indices & Futures 
The proxy is fetched automatically via request.security. You do not need to change any settings when switching between brokers — the indicator detects the symbol and loads the appropriate volume source.
2. Proxy-First Priority
Unlike a simple fallback system, this indicator uses the proxy as the primary volume source for all mapped symbols. This guarantees consistent, real volume data regardless of the broker you are charting on — whether EasyMarkets, FXCM, or any CFD provider. The native volume is only used if the proxy fails or if you explicitly enable "Force Native Volume" in settings.
3. Daily Session Mode
When enabled, the profile anchors to the start of the current daily session and resets automatically at each new day — useful for intraday traders who want to see only today's volume distribution.
4. Daily VWAP Anchor
An optional Volume Weighted Average Price line anchored to the daily session open, calculated using the same proxy volume logic as the profile for accuracy across all brokers.

📐 How to read the indicator
Profile bars (left and right of the vertical axis):

Left side bars = dominant directional volume per price bin
Right side bars = opposing volume per price bin
Deeper color = higher volume concentration at that price level
Longer bars = more activity at that price — key support/resistance zones

The four labels at current price:
        SELL% | BUY%
        SELL  | BUY
  ──────────────────── ← current price
        BUY%  | BUY%
        BUY   | SELL

Upper left (SELL%) — percentage of total volume that was selling above current price
Upper right (BUY%) — percentage of total volume that was buying above current price
Lower left (BUY%) — percentage of total volume that was buying below current price
Lower right (SELL%) — percentage of total volume that was selling below current price

Point of Control (PoC) — dashed line:

Marks the single price level with the highest volume in each quadrant
Strong reference for support and resistance


📊 How to interpret the percentages
Example from chart — USDCAD 15M:
Upper:  SELL 2.90%  |  BUY 3.75%
Lower:  BUY 51.79%  |  SELL 41.57%
Reading:

51.79% of all volume below price was buying → strong buy accumulation below
41.57% of all volume below price was selling → significant sell pressure also present
Only 2.90% + 3.75% above price → very little activity above current price
Interpretation: price is near the top of the range with most activity below

General rules:

Large BUY% below + small SELL% above → bullish bias, buyers in control
Large SELL% above + small BUY% below → bearish bias, sellers in control
Balanced percentages on both sides → price in equilibrium, expect breakout
PoC line in lower quad with high BUY volume → strong support level
PoC line in upper quad with high SELL volume → strong resistance level


⚠️ Important notes

This indicator is a visual analysis tool. It does not generate buy or sell signals.
Past volume distribution does not guarantee future price behavior.
The proxy volume reflects tick volume from the mapped exchange, not actual traded notional value.
On weekends or when markets are closed, volume may be incomplete, affecting the profile.


⚙️ Settings reference
ParameterDefaultDescriptionUse Daily Session ModeOFFON: resets profile each day. OFF: fixed lookbackLookback Period200Bars used when Session Mode is OFFForce Native VolumeOFFON: uses chart's native volume instead of proxyPrice Bins60Number of horizontal price levelsProfile Offset60Distance from last bar (in bars)Upper/Lower QuadsONShow/hide each profile sectionPoCON/OFFShow/hide Point of Control per quadrantShow Daily VWAPONPlots the session VWAP lineBuy ColorGreenProfile buy side colorSell ColorRedProfile sell side colorVWAP ColorWhiteVWAP line color

🙏 Credits
Original quadrant volume profile concept and core structure:
BigBeluga — Quadro Volume Profile [BigBeluga]
https://www.tradingview.com/u/BigBeluga/
Released under Mozilla Public License 2.0
https://mozilla.org/MPL/2.0/

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fabricionicolauxx
/// ⚠️ DISCLAIMER
// The volumes displayed are sourced from EXTERNAL PROXIES (Binance, FX, CME, etc.)
// These are NOT the volumes from the current chart or broker
// Use only for educational analysis and trend confirmation
// Do not use as the sole indicator for trading decisions

//@version=6

// ═══════════════════════════════════════════════════════════════════
// Delta Volume Profile Pro  v11
// ═══════════════════════════════════════════════════════════════════
// Base: Quadro Volume Profile [BigBeluga] — core 100% preservado,
// incluindo declaração VAR dos arrays de profile e reset explícito,
// que é o que garante barras do tamanho correto.
//
// Adições:
//   1. Proxy Volume Engine — 80+ símbolos CFD/Forex/Crypto/Metals
//   2. Auto Volume Priority — proxy primeiro (volume real em qualquer
//      broker, incluindo EasyMarkets). Nativo só como fallback.
//   3. Daily Session Mode
//   4. Daily VWAP Anchor
// ═══════════════════════════════════════════════════════════════════

indicator("Delta Volume Profile Pro", shorttitle="DVP Pro", overlay=true, max_boxes_count=500, calc_bars_count=500)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
grpMode    = "Profile Mode"
grpProfile = "Profile Settings"
grpVwap    = "VWAP Anchor"
grpColors  = "Colors"
grpVolume  = "Volume Settings"

sessionMode = input.bool(false,  title="Use Daily Session Mode?", group=grpMode,
                tooltip="ON: perfil reseta a cada nova sessão diária. OFF: usa lookback fixo.")
lookBack    = input.int(200,    title="Lookback Period (bars) — usado quando Session Mode = OFF", minval=10, maxval=500, group=grpMode)

forceProxy  = input.bool(false, title="Forçar Proxy Volume", group=grpVolume,
                tooltip="OFF (recomendado): usa sempre o proxy para garantir volume real em qualquer broker (EasyMarkets, FXCM, etc). Ative para usar o volume nativo do gráfico.")

bins   = input.int(60,  title="Price Bins",            minval=10, maxval=100, group=grpProfile)
offset = input.int(60,  title="Profile Offset (bars)", minval=1,  maxval=200, group=grpProfile)

showProfile1 = input.bool(true,  title="Upper Sell Quad", inline="1", group=grpProfile)
showPoc1     = input.bool(true,  title="PoC",             inline="1", group=grpProfile)
showProfile2 = input.bool(true,  title="Upper Buy Quad",  inline="2", group=grpProfile)
showPoc2     = input.bool(false, title="PoC",             inline="2", group=grpProfile)
showProfile3 = input.bool(true,  title="Lower Buy Quad",  inline="3", group=grpProfile)
showPoc3     = input.bool(true,  title="PoC",             inline="3", group=grpProfile)
showProfile4 = input.bool(true,  title="Lower Sell Quad", inline="4", group=grpProfile)
showPoc4     = input.bool(false, title="PoC",             inline="4", group=grpProfile)

showVwap   = input.bool(true,                     title="Show Daily VWAP Anchor?", group=grpVwap)
colorPlus  = input.color(color.rgb(3, 127, 159), "", inline="col", group=grpColors)
colorMinus = input.color(color.rgb(230, 30, 30),  "", inline="col", group=grpColors)
colorVwap  = input.color(color.white,             title="VWAP Color", group=grpColors)

// ─────────────────────────────────────────
// PROXY VOLUME ENGINE
// ─────────────────────────────────────────
getProxySymbol() =>
    sym = syminfo.ticker
    result = switch sym
        "BTCUSD"  => "BINANCE:BTCUSDT"
        "ETHUSD"  => "BINANCE:ETHUSDT"
        "BCHUSD"  => "BINANCE:BCHUSDT"
        "LTCUSD"  => "BINANCE:LTCUSDT"
        "XRPUSD"  => "BINANCE:XRPUSDT"
        "DOGUSD"  => "BINANCE:DOGEUSDT"
        "DOTUSD"  => "BINANCE:DOTUSDT"
        "SOLUSD"  => "BINANCE:SOLUSDT"
        "EURUSD"  => "OANDA:EURUSD"
        "EURJPY"  => "OANDA:EURJPY"
        "EURGBP"  => "OANDA:EURGBP"
        "EURCHF"  => "OANDA:EURCHF"
        "EURCAD"  => "OANDA:EURCAD"
        "EURAUD"  => "OANDA:EURAUD"
        "EURNOK"  => "OANDA:EURNOK"
        "EURNZD"  => "OANDA:EURNZD"
        "GBPUSD"  => "OANDA:GBPUSD"
        "GBPJPY"  => "OANDA:GBPJPY"
        "GBPAUD"  => "OANDA:GBPAUD"
        "GBPCHF"  => "OANDA:GBPCHF"
        "GBPCAD"  => "OANDA:GBPCAD"
        "GBPNZD"  => "OANDA:GBPNZD"
        "GBPSGD"  => "OANDA:GBPSGD"
        "USDJPY"  => "OANDA:USDJPY"
        "CADJPY"  => "OANDA:CADJPY"
        "AUDJPY"  => "OANDA:AUDJPY"
        "CHFJPY"  => "OANDA:CHFJPY"
        "NZDJPY"  => "OANDA:NZDJPY"
        "AUDUSD"  => "OANDA:AUDUSD"
        "AUDNZD"  => "OANDA:AUDNZD"
        "AUDCAD"  => "OANDA:AUDCAD"
        "CHFAUD"  => "OANDA:AUDCHF"
        "USDCAD"  => "OANDA:USDCAD"
        "CADCHF"  => "OANDA:CADCHF"
        "USDCHF"  => "OANDA:USDCHF"
        "NZDCHF"  => "OANDA:NZDCHF"
        "NZDUSD"  => "OANDA:NZDUSD"
        "USDCNH"  => "OANDA:USDCNH"
        "USDMXN"  => "OANDA:USDMXN"
        "XAUUSD"  => "OANDA:XAUUSD"
        "XAGUSD"  => "OANDA:XAGUSD"
        "XPTUSD"  => "OANDA:XPTUSD"
        "XPDUSD"  => "OANDA:XPDUSD"
        "CPRUSD"  => "COMEX:HG1!"
        "BRTUSD"  => "OANDA:BCOUSD"
        "OILUSD"  => "OANDA:WTICOUSD"
        "NGSUSD"  => "NYMEX:NG1!"
        "CRNUSD"  => "CBOT:ZC1!"
        "WHTUSD"  => "CBOT:ZW1!"
        "SGRUSD"  => "ICEUS:SB1!"
        "CTNUSD"  => "ICEUS:CT1!"
        "CCOUSD"  => "ICEUS:CC1!"
        "USXUSD"  => "ICEUS:DX1!"
        "DOWUSD"  => "CBOT:YM1!"
        "DJCUSD"  => "CBOT:YM1!"
        "NDQUSD"  => "CME:NQ1!"
        "NQCUSD"  => "CME:NQ1!"
        "SPIUSD"  => "CME:ES1!"
        "SPCUSD"  => "CME:ES1!"
        "NKIUSD"  => "CME:NKD1!"
        "NKCJPY"  => "CME:NKD1!"
        "DAXEUR"  => "EUREX:FDAX1!"
        "DECEUR"  => "EUREX:FDAX1!"
        "FTSGBP"  => "ICEEUR:Z1!"
        "UKCGBP"  => "ICEEUR:Z1!"
        "CACEUR"  => "EURONEXT:FCE1!"
        "MIBEUR"  => "EUREX:FESX1!"
        "EUCEUR"  => "EUREX:FESX1!"
        "AUCAUD"  => "CME:AES1!"
        "HSXHKD"  => "HKEX:MHI1!"
        "APLUSD"  => "NASDAQ:AAPL"
        "AMZUSD"  => "NASDAQ:AMZN"
        "GOOUSD"  => "NASDAQ:GOOGL"
        "MSFUSD"  => "NASDAQ:MSFT"
        "NFXUSD"  => "NASDAQ:NFLX"
        "NVDUSD"  => "NASDAQ:NVDA"
        "TSLUSD"  => "NASDAQ:TSLA"
        "FBKUSD"  => "NASDAQ:META"
        "JPMUSD"  => "NYSE:JPM"
        "UBEUSD"  => "NYSE:UBER"
        "EXOUSD"  => "NYSE:XOM"
        "DISUSD"  => "NYSE:DIS"
        "MCDUSD"  => "NYSE:MCD"
        "FRDUSD"  => "NYSE:F"
        "ADSEUR"  => "XETR:ADS"
        "HBCHKD"  => "HKEX:5"
        => "BINANCE:BTCUSDT"
    result

// ─────────────────────────────────────────
// EFFECTIVE VOLUME
// Prioridade: nativo > 0 → nativo | senão → proxy | senão → 1.0
// ─────────────────────────────────────────
proxyVolSeries = request.security(
     getProxySymbol(), timeframe.period, volume,
     gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true)

getEffVol(i) =>
    nv  = volume[i]
    pv  = proxyVolSeries[i]
    nOk = not na(nv) and nv > 0
    pOk = not na(pv) and pv > 0
    // Proxy tem prioridade — garante volume real em qualquer broker (EasyMarkets, etc)
    // forceProxy=true → usa volume nativo do gráfico em vez do proxy
    // Cascata: proxy → nativo → 1.0
    forceProxy ? (nOk ? nv : 1.0)
               : (pOk ? pv : (nOk ? nv : 1.0))

// ─────────────────────────────────────────
// SESSION BARS COUNTER
// ─────────────────────────────────────────
var int sessionBars = 0
if ta.change(time("D")) != 0
    sessionBars := 1
else
    sessionBars += 1

activeLookback = sessionMode ? math.min(sessionBars, 500) : math.min(lookBack, 500)

// ─────────────────────────────────────────
// DAILY VWAP ANCHOR
// ─────────────────────────────────────────
var float cumPV = 0.0
var float cumV  = 0.0

if ta.change(time("D")) != 0
    cumPV := hlc3 * getEffVol(0)
    cumV  := getEffVol(0)
else
    cumPV += hlc3 * getEffVol(0)
    cumV  += getEffVol(0)

vwapAnchor = cumV > 0 ? cumPV / cumV : close

plot(showVwap ? vwapAnchor : na,
     title="Daily VWAP Anchor",
     color=color.new(colorVwap, 30),
     linewidth=2,
     style=plot.style_line)

// ═══════════════════════════════════════════════════════════════════
// BIGBELUGA CORE — preservado byte a byte
// Diferenças mínimas em relação ao original:
//   · volume[i]      →  getEffVol(i)      — proxy volume engine
//   · lookBack        →  activeLookback    — suporte ao Session Mode
//   · var leftProfile / rightProfile com reset explícito por barstate.islast
// ═══════════════════════════════════════════════════════════════════
type values
    float BuyVol
    float SellVol
    float price

var vValues      = array.new<values>(500)
var topBot       = array.new<float>()
// ← CHAVE: declarados com VAR e tamanho = bins, igual ao BigBeluga
var leftProfile  = array.new<float>(bins, 0)
var rightProfile = array.new<float>(bins, 0)

start = bar_index + offset

if barstate.islast
    var boxes  = array.new<box>()
    var lines  = array.new<line>()
    var labels = array.new<label>()

    // ← CHAVE: reset explícito dos arrays de profile — igual BigBeluga
    for i = 0 to leftProfile.size() - 1
        leftProfile.set(i, 0)
        rightProfile.set(i, 0)

    if boxes.size() > 0
        for b in boxes
            b.delete()
        for l in lines
            l.delete()
        for lbl in labels
            lbl.delete()
        lines.clear()
        boxes.clear()
        labels.clear()

    topBot.clear()

    int lb = activeLookback

    for i = 0 to lb - 1
        isBull = close[i] > open[i]
        effV   = getEffVol(i)
        vValues.set(i, values.new(isBull ? effV : 0, isBull ? 0 : effV, close[i]))
        topBot.push(high[i])
        topBot.push(low[i])

    top  = topBot.max()
    bot  = topBot.min()
    step = (top - bot) / bins
    mid  = bot + (top - bot) / 2

    for i = 0 to lb - 1
        vals    = vValues.get(i)
        price   = vals.price
        bullVol = vals.BuyVol
        bearVol = vals.SellVol

        for k = 0 to bins - 1
            loww   = bot + step * k
            highh  = loww + step
            middle = loww + step / 2

            if price >= loww - step and price <= highh + step and close > middle
                leftProfile.set(k, leftProfile.get(k) + bullVol)
            if price >= loww - step and price <= highh + step and close < middle
                leftProfile.set(k, leftProfile.get(k) + bearVol)
            if price >= loww - step and price <= highh + step and close > middle
                rightProfile.set(k, rightProfile.get(k) + bearVol)
            if price >= loww - step and price <= highh + step and close < middle
                rightProfile.set(k, rightProfile.get(k) + bullVol)

    totBuy1  = array.new<float>()
    totBuy2  = array.new<float>()
    totSell1 = array.new<float>()
    totSell2 = array.new<float>()
    totalVol = 0.

    for k = 0 to bins - 1
        loww  = bot + step * k
        highh = loww + step
        Vol1  = leftProfile.get(k)
        Vol2  = rightProfile.get(k)

        volValue1 = int(Vol1 / leftProfile.max()  * 50)
        volValue2 = int(Vol2 / rightProfile.max() * 50)

        if close < loww
            totSell1.push(Vol1)
            totBuy1.push(Vol2)
        if close > highh
            totBuy2.push(Vol1)
            totSell2.push(Vol2)

        totalVol := totSell1.sum() + totBuy1.sum() + totSell2.sum() + totBuy2.sum()

        if close > highh
            if showProfile3
                boxes.push(box.new(start - volValue1 - 1, highh, start - 1, loww,
                     chart.bg_color, 1,
                     bgcolor=color.from_gradient(volValue1, 0, 50, color.new(colorPlus, 50), colorPlus)))
            if showProfile4
                boxes.push(box.new(start + volValue2 + 1, highh, start + 1, loww,
                     chart.bg_color, 1,
                     bgcolor=color.from_gradient(volValue2, 0, 50, color.new(colorMinus, 50), colorMinus)))

        if close < loww
            if showProfile1
                boxes.push(box.new(start - volValue1 - 1, highh, start - 1, loww,
                     chart.bg_color, 1,
                     bgcolor=color.from_gradient(volValue1, 0, 50, color.new(colorMinus, 50), colorMinus)))
            if showProfile2
                boxes.push(box.new(start + volValue2 + 1, highh, start + 1, loww,
                     chart.bg_color, 1,
                     bgcolor=color.from_gradient(volValue2, 0, 50, color.new(colorPlus, 50), colorPlus)))

        if close < highh and close > loww
            lines.push(line.new(start - lb - offset, close, start + 50, close,
                 color=close < open ? colorMinus : colorPlus,
                 width=1, style=line.style_solid, extend=extend.right))

    for k = 0 to bins - 1
        loww   = bot + step * k
        highh  = loww + step
        middle = loww + step / 2
        Vol1   = leftProfile.get(k)
        Vol2   = rightProfile.get(k)

        volValue1 = int(Vol1 / leftProfile.max()  * 50)
        volValue2 = int(Vol2 / rightProfile.max() * 50)

        if close < highh and close > loww
            labels.push(label.new(start, middle,
                 "SELL\n" + str.tostring(totSell1.sum(), format.volume) + "\n" + str.tostring(totSell1.sum() / totalVol * 100, format.percent),
                 style=label.style_label_lower_right, textcolor=chart.fg_color,
                 color=color.new(chart.bg_color, 80), force_overlay=true))
            labels.push(label.new(start, middle,
                 "BUY\n" + str.tostring(totBuy1.sum(), format.volume) + "\n" + str.tostring(totBuy1.sum() / totalVol * 100, format.percent),
                 style=label.style_label_lower_left, textcolor=chart.fg_color,
                 color=color.new(chart.bg_color, 80), force_overlay=true))
            labels.push(label.new(start, middle,
                 str.tostring(totSell2.sum() / totalVol * 100, format.percent) + "\n" + str.tostring(totSell2.sum(), format.volume) + "\nSELL",
                 style=label.style_label_upper_left, textcolor=chart.fg_color,
                 color=color.new(chart.bg_color, 80), force_overlay=true))
            labels.push(label.new(start, middle,
                 str.tostring(totBuy2.sum() / totalVol * 100, format.percent) + "\n" + str.tostring(totBuy2.sum(), format.volume) + "\nBUY",
                 style=label.style_label_upper_right, textcolor=chart.fg_color,
                 color=color.new(chart.bg_color, 80), force_overlay=true))

        if close > highh
            if Vol1 == totBuy2.max()
                if showPoc3 and totBuy2.max() != 0
                    lines.push(line.new(start - lb - offset, middle, start - volValue1, middle,
                         color=colorPlus, width=1, force_overlay=true, style=line.style_dashed))
                    labels.push(label.new(start - volValue1, middle,
                         "+" + str.tostring(totBuy2.max(), format.volume),
                         style=label.style_label_left, color=color(na), textcolor=chart.fg_color))
            if Vol2 == totSell2.max()
                if showPoc4 and totSell2.max() != 0
                    lines.push(line.new(start - lb - offset, middle, start, middle,
                         color=colorMinus, width=1, force_overlay=true, style=line.style_dashed))
                    labels.push(label.new(start + volValue2, middle,
                         "-" + str.tostring(totSell2.max(), format.volume),
                         style=label.style_label_right, color=color(na), textcolor=chart.fg_color))

        if close < loww
            if Vol2 == totBuy1.max()
                if showPoc2 and totBuy1.max() != 0
                    lines.push(line.new(start - lb - offset, middle, start, middle,
                         color=colorPlus, width=1, force_overlay=true, style=line.style_dashed))
                    labels.push(label.new(start + volValue2, middle,
                         "+" + str.tostring(totBuy1.max(), format.volume),
                         style=label.style_label_right, color=color(na), textcolor=chart.fg_color))
            if Vol1 == totSell1.max()
                if showPoc1 and totSell1.max() != 0
                    lines.push(line.new(start - lb - offset, middle, start - volValue1, middle,
                         color=colorMinus, width=1, force_overlay=true, style=line.style_dashed))
                    labels.push(label.new(start - volValue1, middle,
                         "-" + str.tostring(totSell1.max(), format.volume),
                         style=label.style_label_left, color=color(na), textcolor=chart.fg_color))

    line.delete(line.new(start, top, start, bot, color=chart.fg_color, width=3, force_overlay=true)[1])
````
