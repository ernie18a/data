# VWAP Daily Bands Standard

- url: https://www.tradingview.com/script/fjgx1qTp/
- type: indicator
- pine_id: PUB;f36eaadb5bb045ad9fdae79ff748c045
- version: 2.0

## Description

VWAP Daily Bands is a volume-weighted average price indicator anchored to the daily session, enhanced with adaptive standard deviation bands designed to work accurately across all asset classes — including Forex, Crypto, Commodities, Indices, and Stocks.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
THE PROBLEM THIS INDICATOR SOLVES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Most VWAP band implementations calculate standard deviation using only intraday price variance. This creates a well-known flaw: at the start of each session, when very few bars have been processed, the bands collapse to near zero and are practically useless. As the session progresses, the bands gradually widen — but asymmetrically, because early price swings distort the variance calculation.

This indicator solves that with a fixed daily ATR seed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW THE ATR SEED WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Before the session opens, the indicator fetches the previous day's closing price and ATR from the daily timeframe. These two fixed values are used to calculate a minimum band width that holds constant throughout the entire trading day — it does not fluctuate with intraday price movement.

The standard deviation used for the bands is then taken as the larger of two values: the real-time intraday price variance, or the fixed ATR-based seed variance. This means the bands are always at least as wide as the prior day's volatility warrants, while still expanding naturally when intraday price action is more volatile than usual.

The result is symmetric, stable bands from the very first bar of the session.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PROXY VOLUME ENGINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Many brokers and CFD platforms do not provide real volume data. Without volume, a VWAP calculation loses its core meaning.

This indicator includes a built-in Proxy Volume Engine that automatically detects the current symbol and maps it to a liquid equivalent source with real volume data. For example, XAUUSD is mapped to COMEX:GC1!, EURUSD to FX:EURUSD, BTCUSD to BINANCE:BTCUSDT, and so on — covering over 80 symbols across all major asset classes. If the platform provides native volume, it is used directly. If not, the proxy volume is applied transparently with no action required from the user.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT IS PLOTTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• VWAP (white) — daily anchor VWAP calculated from HLC3, reset at the start of each session, weighted by effective volume.
• Upper bands (cyan) — 1σ, 2σ, and 3σ above the VWAP, indicating potential resistance or overbought zones.
• Lower bands (red) — 1σ, 2σ, and 3σ below the VWAP, indicating potential support or oversold zones.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• Show Daily VWAP — toggle the VWAP line on or off.
• Show Band 1σ / 2σ / 3σ — toggle each band pair individually.
• Band Width Multiplier — scales all bands up or down proportionally (default 1.0).
• Daily ATR Period — controls how many days are used to calculate the ATR seed (default 5).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPATIBLE WITH
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Forex majors, minors and exotics · Crypto (via Binance) · Gold, Silver, Platinum, Palladium · Oil and Natural Gas · Agricultural commodities · US Dollar Index · Major global indices: DOW, NASDAQ, S&P 500, Nikkei, DAX, FTSE, CAC, MIB, ASX, Hang Seng · Top US and European stocks.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The VWAP calculation uses Pine Script's native HLC3-based volume-weighted average price as its mathematical foundation. The ATR seed mechanism, Proxy Volume Engine, and adaptive band logic are original contributions developed specifically for this indicator to address real limitations found in standard VWAP band implementations.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fabricionicolauxx
// ⚠️ DISCLAIMER
// The volumes displayed are sourced from EXTERNAL PROXIES (Binance, FX, CME, etc.)
// These are NOT the volumes from the current chart or broker
// Use only for educational analysis and trend confirmation
// Do not use as the sole indicator for trading decisions
//@version=6
// VWAP Daily Bands
// Original concept inspired by the standard VWAP built-in (Pine Script)
// Author: Fabricio Nicolau
// ═══════════════════════════════════════════════════════════════════
// VWAP Daily Bands — Daily Anchor VWAP + Standard Deviation Bands
// ═══════════════════════════════════════════════════════════════════
// Author: Fabricio Nicolau
// ═══════════════════════════════════════════════════════════════════

indicator(title="VWAP Daily Bands Standard", shorttitle="VWAPBands Pro", overlay=true)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
showbase  = input.bool(true,  title="Show Daily VWAP?")
show1     = input.bool(true,  title="Show Band 1σ?")
show2     = input.bool(true,  title="Show Band 2σ?")
show3     = input.bool(true,  title="Show Band 3σ?")
seedMult  = input.float(1.0,  title="Band Width Multiplier", minval=0.1, maxval=10.0, step=0.1,
             tooltip="Fine-tune band width. 1.0 = automatic standard based on price %")
atrPeriod = input.int(5, title="Daily ATR Period (seed)", minval=1, maxval=20)

// ─────────────────────────────────────────
// VOLUME PROXY MAP
// ─────────────────────────────────────────
getProxySymbol() =>
    sym = syminfo.ticker
    result = switch sym
        "BTCUSD" => "BINANCE:BTCUSDT"
        "ETHUSD" => "BINANCE:ETHUSDT"
        "BCHUSD" => "BINANCE:BCHUSDT"
        "LTCUSD" => "BINANCE:LTCUSDT"
        "XRPUSD" => "BINANCE:XRPUSDT"
        "DOGUSD" => "BINANCE:DOGEUSDT"
        "DOTUSD" => "BINANCE:DOTUSDT"
        "SOLUSD" => "BINANCE:SOLUSDT"
        "EURUSD" => "FX:EURUSD"
        "EURJPY" => "FX:EURJPY"
        "EURGBP" => "FX:EURGBP"
        "EURCHF" => "FX:EURCHF"
        "EURCAD" => "FX:EURCAD"
        "EURAUD" => "FX:EURAUD"
        "EURNOK" => "FX:EURNOK"
        "EURNZD" => "FX:EURNZD"
        "GBPUSD" => "FX:GBPUSD"
        "GBPJPY" => "FX:GBPJPY"
        "GBPAUD" => "FX:GBPAUD"
        "GBPCHF" => "FX:GBPCHF"
        "GBPCAD" => "FX:GBPCAD"
        "GBPNZD" => "FX:GBPNZD"
        "GBPSGD" => "FX:GBPSGD"
        "USDJPY" => "FX:USDJPY"
        "CADJPY" => "FX:CADJPY"
        "AUDJPY" => "FX:AUDJPY"
        "CHFJPY" => "FX:CHFJPY"
        "NZDJPY" => "FX:NZDJPY"
        "AUDUSD" => "FX:AUDUSD"
        "AUDNZD" => "FX:AUDNZD"
        "AUDCAD" => "FX:AUDCAD"
        "CHFAUD" => "FX:AUDCHF"
        "USDCAD" => "FX:USDCAD"
        "CADCHF" => "FX:CADCHF"
        "USDCHF" => "FX:USDCHF"
        "NZDCHF" => "FX:NZDCHF"
        "NZDUSD" => "FX:NZDUSD"
        "USDCNH" => "FX:USDCNH"
        "USDMXN" => "FX:USDMXN"
        "XAUUSD" => "COMEX:GC1!"
        "XAGUSD" => "COMEX:SI1!"
        "XPTUSD" => "NYMEX:PL1!"
        "XPDUSD" => "NYMEX:PA1!"
        "CPRUSD" => "COMEX:HG1!"
        "BRTUSD" => "ICEEUR:BRN1!"
        "OILUSD" => "NYMEX:CL1!"
        "NGSUSD" => "NYMEX:NG1!"
        "CRNUSD" => "CBOT:ZC1!"
        "WHTUSD" => "CBOT:ZW1!"
        "SGRUSD" => "ICEUS:SB1!"
        "CTNUSD" => "ICEUS:CT1!"
        "CCOUSD" => "ICEUS:CC1!"
        "USXUSD" => "ICEUS:DX1!"
        "DOWUSD" => "CBOT:YM1!"
        "DJCUSD" => "CBOT:YM1!"
        "NDQUSD" => "CME:NQ1!"
        "NQCUSD" => "CME:NQ1!"
        "SPIUSD" => "CME:ES1!"
        "SPCUSD" => "CME:ES1!"
        "NKIUSD" => "CME:NKD1!"
        "NKCJPY" => "CME:NKD1!"
        "DAXEUR" => "EUREX:FDAX1!"
        "DECEUR" => "EUREX:FDAX1!"
        "FTSGBP" => "ICEEUR:Z1!"
        "UKCGBP" => "ICEEUR:Z1!"
        "CACEUR" => "EURONEXT:FCE1!"
        "MIBEUR" => "EUREX:FESX1!"
        "EUCEUR" => "EUREX:FESX1!"
        "AUCAUD" => "CME:AES1!"
        "HSXHKD" => "HKEX:MHI1!"
        "APLUSD" => "NASDAQ:AAPL"
        "AMZUSD" => "NASDAQ:AMZN"
        "GOOUSD" => "NASDAQ:GOOGL"
        "MSFUSD" => "NASDAQ:MSFT"
        "NFXUSD" => "NASDAQ:NFLX"
        "NVDUSD" => "NASDAQ:NVDA"
        "TSLUSD" => "NASDAQ:TSLA"
        "FBKUSD" => "NASDAQ:META"
        "JPMUSD" => "NYSE:JPM"
        "UBEUSD" => "NYSE:UBER"
        "EXOUSD" => "NYSE:XOM"
        "DISUSD" => "NYSE:DIS"
        "MCDUSD" => "NYSE:MCD"
        "FRDUSD" => "NYSE:F"
        "ADSEUR" => "XETR:ADS"
        "HBCHKD" => "HKEX:5"
        => "BINANCE:BTCUSDT"
    result

// ─────────────────────────────────────────
// EFFECTIVE VOLUME — local or proxy
// ─────────────────────────────────────────
proxyVol     = request.security(getProxySymbol(), timeframe.period, volume, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
hasVol       = not na(volume) and volume > 0
effectiveVol = hasVol ? volume : (not na(proxyVol) and proxyVol > 0) ? proxyVol : 1.0

// ─────────────────────────────────────────
// SEED: ATR% using fixed prior-day close
// Both fetched at D timeframe with shift [1]
// → seed is a fixed daily value, does not fluctuate with intraday price
// → solves asymmetry between upper and lower bands
// ─────────────────────────────────────────
[prevDayClose, prevDayATR] = request.security(
     syminfo.tickerid, "D",
     [close[1], ta.atr(atrPeriod)[1]],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

atrPct  = nz(prevDayATR / prevDayClose, (high - low) / close)
atrSeed = prevDayClose * atrPct * seedMult / 2

// ─────────────────────────────────────────
// DAILY ANCHOR VWAP
// ─────────────────────────────────────────
src      = hlc3
isNewDay = ta.change(time("D")) != 0

var float cumPV  = 0.0
var float cumV   = 0.0
var float cumPV2 = 0.0

if isNewDay
    cumPV  := src * effectiveVol
    cumV   := effectiveVol
    cumPV2 := effectiveVol * math.pow(src, 2)
else
    cumPV  += src * effectiveVol
    cumV   += effectiveVol
    cumPV2 += effectiveVol * math.pow(src, 2)

vwap = cumPV / cumV

// ─────────────────────────────────────────
// STANDARD DEVIATION WITH FIXED DAILY SEED
// ─────────────────────────────────────────
priceVariance    = math.max(cumPV2 / cumV - math.pow(vwap, 2), 0)
seedVariance     = math.pow(atrSeed, 2)
combinedVariance = math.max(priceVariance, seedVariance)
stdev            = math.sqrt(combinedVariance)

upper1 = vwap + 1 * stdev
upper2 = vwap + 2 * stdev
upper3 = vwap + 3 * stdev
lower1 = vwap - 1 * stdev
lower2 = vwap - 2 * stdev
lower3 = vwap - 3 * stdev

// ─────────────────────────────────────────
// COLORS
// Upper bands → cyan  (resistance / overbought zones)
// Lower bands → red   (support / oversold zones)
// VWAP        → white
// ─────────────────────────────────────────
colorUpper = color.rgb(201, 20, 20, 20)
colorLower = color.new(#31e7ff, 20)
colorVWAP  = color.new(color.white, 20)

// ─────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────
plot(showbase ? vwap   : na, color=colorVWAP,  title="Daily VWAP",    style=plot.style_line, linewidth=2)
plot(show1    ? upper1 : na, color=colorUpper, title="Upper Band 1σ", style=plot.style_line, linewidth=1)
plot(show2    ? upper2 : na, color=colorUpper, title="Upper Band 2σ", style=plot.style_line, linewidth=1)
plot(show3    ? upper3 : na, color=colorUpper, title="Upper Band 3σ", style=plot.style_line, linewidth=1)
plot(show1    ? lower1 : na, color=colorLower, title="Lower Band 1σ", style=plot.style_line, linewidth=1)
plot(show2    ? lower2 : na, color=colorLower, title="Lower Band 2σ", style=plot.style_line, linewidth=1)
plot(show3    ? lower3 : na, color=colorLower, title="Lower Band 3σ", style=plot.style_line, linewidth=1)
````
