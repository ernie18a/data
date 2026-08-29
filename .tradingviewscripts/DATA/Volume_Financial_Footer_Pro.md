<!-- tradingview-pine-id: PUB;0a9ff3d33e564cbba94769ea5f180ae3 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Financial Footer Pro

Source: https://www.tradingview.com/script/nax7DkTT/

## Description

New version Volume Footer Financial Pro is a smart volume indicator built for traders who operate across multiple asset classes, including Forex, Crypto, Commodities, Indices, and Stocks. It combines a Proxy Volume Engine with a candle-based delta intensity system to deliver meaningful volume analysis even on platforms that do not provide real volume data.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
THE PROBLEM THIS INDICATOR SOLVES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Most retail brokers and CFD platforms — particularly those offering Forex, metals, and index CFDs — do not provide real volume data. The standard volume indicator on these platforms either returns zero, returns meaningless tick counts, or simply shows nothing. This makes volume-based analysis impossible for a large portion of the trading community.

Volume Financial Pro solves this with a built-in Proxy Volume Engine.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW THE PROXY VOLUME ENGINE WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The indicator automatically detects the current symbol and maps it to a liquid equivalent source that provides real, reliable volume data. For example:

• XAUUSD → COMEX:GC1! (Gold Futures)
• EURUSD → FX:EURUSD
• BTCUSD → BINANCE:BTCUSDT
• NDQUSD → OANDA:NAS100USD
• AAPL → NASDAQ:AAPL

Over 80 symbols are mapped across all major asset classes. If the platform provides native volume, it is used directly. If not, the proxy volume is fetched and applied transparently — no configuration needed from the user.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DELTA-BASED COLOR SYSTEM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Each volume bar is colored based on sell intensity, calculated from the relationship between the candle body size and its full high-low range. This approximates the proportion of buying versus selling pressure within each bar.

• Bullish bars → cyan
• Bearish bars with moderate selling → light red
• Bearish bars with high selling intensity (above 60%) → dark red

This gives traders an immediate visual read on conviction behind each move — not just whether price went up or down, but how aggressively it was bought or sold.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EMA OVERLAY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

An optional EMA (default: 9 periods) is plotted over the volume histogram to help identify trends in volume activity and spot anomalies such as volume spikes or dry-up zones that may precede price reversals.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• EMA Length — adjustable period for the volume EMA (default: 9).
• Show EMA — toggle the EMA line on or off.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPATIBLE WITH
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Forex majors, minors and exotics · Crypto (via Binance) · Gold, Silver, Platinum, Palladium · Oil and Natural Gas · Agricultural commodities · US Dollar Index · Major global indices: DOW, NASDAQ, S&P 500, Nikkei, DAX, FTSE, CAC, MIB, ASX, Hang Seng · Top US and European stocks.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This indicator is an original work. The Proxy Volume Engine, symbol mapping table, and delta intensity color logic were developed independently by the author and do not derive from any existing published script.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fabricionicolauxx
//
/// DISCLAIMER
// The volumes displayed are sourced from EXTERNAL PROXIES (Binance, FX, CME, etc.)
// These are NOT the volumes from the current chart or broker.
// Use only for educational analysis and trend confirmation.
// Do not use as the sole indicator for trading decisions.

//@version=6

// ═══════════════════════════════════════════════════════════════════
// Volume Financial Pro — Proxy Volume Engine
// ═══════════════════════════════════════════════════════════════════
// Author: Fabricio Nicolau
// ═══════════════════════════════════════════════════════════════════

indicator(title="Volume Financial Footer Pro", shorttitle="Vol Footer Pro", overlay=false)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
emaLength = input.int(9,     title="EMA Length", minval=1)
showEMA   = input.bool(true, title="Show EMA?")

// ─────────────────────────────────────────
// VOLUME PROXY ENGINE
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
        "NDQUSD" => "OANDA:NAS100USD"
        "NQCUSD" => "OANDA:NAS100USD"
        "SPIUSD" => "OANDA:SPX500USD"
        "SPCUSD" => "OANDA:SPX500USD"
        "NKIUSD" => "CME:NKD1!"
        "NKCJPY" => "CME:NKD1!"
        "DAXEUR" => "EUREX:FDAX1!"
        "DECEUR" => "EUREX:FDAX1!"
        "FTSGBP" => "ICEEUR:Z1!"
        "UKCGBP" => "ICEEUR:Z1!"
        "CACEUR" => "EURONEXT:FCE1!"
        "MIBEUR" => "EUREX:FESX1!"
        "EUCEUR" => "EUREX:FESX1!"
        "AUCAUD" => "ASX24:AP1!"
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
// VOLUME LOGIC — local or proxy
// ─────────────────────────────────────────
proxyVol     = request.security(getProxySymbol(), timeframe.period, volume, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
hasVol       = not na(volume) and volume > 0
effectiveVol = hasVol ? volume : (not na(proxyVol) and proxyVol > 0) ? proxyVol : 1.0

// ─────────────────────────────────────────
// DELTA — sell intensity
// ─────────────────────────────────────────
bodySize      = math.abs(close - open)
rangeSize     = math.abs(high - low)
ratio         = rangeSize > 0 ? bodySize / rangeSize : 0.5
sellVol       = close >= open ? effectiveVol * (1 - ratio) : effectiveVol * ratio
sellIntensity = effectiveVol > 0 ? math.min(sellVol / effectiveVol, 1.0) : 0.5

// ─────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────
isUp      = close >= open
buyColor  = color.new(#26c6da, 0)
sellColor = sellIntensity > 0.6 ? color.new(#c62828, 0) : color.new(#e53935, 0)
barColor  = isUp ? buyColor : sellColor

// ─────────────────────────────────────────
// EMA
// ─────────────────────────────────────────
emaVol = ta.ema(effectiveVol, emaLength)

// ─────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────
plot(effectiveVol,
     title="Volume",
     style=plot.style_columns,
     color=barColor)

plot(showEMA ? emaVol : na,
     title="EMA Volume",
     color=color.white,
     linewidth=2,
     style=plot.style_linebr)
````
