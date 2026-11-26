# Milman's Crypto Breadth: % Above MA

- url: https://www.tradingview.com/script/oWT4ZTll-Milman-s-Crypto-Breadth-Above-MA/
- type: indicator
- pine_id: PUB;49db5c73f9fb43dba84658a8e1ab96c4
- version: 2.0

## Description

Select the interval (100DMA and 200DMA recommended) and enjoy the power of b r e a d t h !

## Source Code

````pine
// ============================================================
//  Crypto Breadth: % Above Moving Average
//  Author  : Generated for TradingView (Pine Script v6)
//  Source  : CRYPTOCAP (market-cap data, exchange-neutral)
//  Assets  : Top-40 non-stablecoin cryptos by market cap
//
//  READING THE INDICATOR
//  ─────────────────────
//  • >80%  → Broad bull market (most coins in uptrend)
//  • 50%   → Neutral / transition zone
//  • <20%  → Broad bear market (most coins in downtrend)
//
//  Divergences vs. BTC price are high-value signals:
//  • Price makes new high but breadth falls  → weakening rally
//  • Price makes new low but breadth rises   → potential bottom
//
//  TIMEFRAME GUIDANCE
//  ──────────────────
//  Daily  + MA 200  → macro market health (recommended)
//  Daily  + MA 50   → medium-term trend check
//  Weekly + MA 20   → multi-month cycle view
// ============================================================

//@version=6
indicator("Crypto Breadth: % Above MA", shorttitle="Crypto Breadth %",
          overlay=false, max_bars_back=500)

// ════════════════════════════════════════════
//   INPUTS
// ════════════════════════════════════════════

maLength  = input.int   (200,   "MA Length",        minval=10, maxval=500, step=10, group="Settings")
maType    = input.string("SMA", "MA Type",          options=["SMA","EMA"],          group="Settings")
sigLen    = input.int   (10,    "Signal EMA Length", minval=2,  maxval=50,          group="Settings",
                         tooltip="Smoothed signal line plotted over the histogram. Crossovers can act as entry/exit triggers.")
obLevel   = input.int   (80,    "Overbought Level", minval=51, maxval=99,           group="Levels")
osLevel   = input.int   (20,    "Oversold Level",   minval=1,  maxval=49,           group="Levels")

// ════════════════════════════════════════════
//   HELPER — is asset above its MA?
// ════════════════════════════════════════════

f_above(sym) =>
    c  = request.security("CRYPTOCAP:" + sym, timeframe.period, close,
                           ignore_invalid_symbol=true)
    ma = maType == "EMA" ? ta.ema(c, maLength) : ta.sma(c, maLength)
    na(c) ? 0 : (c > ma ? 1 : 0)

// ════════════════════════════════════════════
//   TOP-40 NON-STABLECOIN CRYPTOS
//   Last reviewed : 2026-06-07
//
//   Skips: USDT, USDC, BUSD, DAI, WBTC, WETH
//   (stablecoins and wrapped tokens distort breadth)
//
//   HOW TO KEEP THIS LIST CURRENT
//   ─────────────────────────────
//   Pine Script cannot auto-fetch market cap rankings.
//   Review quarterly or after major market rotations:
//   1. Open coinmarketcap.com → Top 100 → filter out stables/wrapped
//   2. Compare against the 40 tickers below
//   3. Swap out any coin that has dropped below ~rank 50
//      and replace with the new entrant (edit the ticker string)
//   4. Update the "Last reviewed" date above
//
//   REMOVED  : FLOW (fell ~rank 80+), SNX (fell ~rank 80+)
//   ADDED    : HYPE (#11 Hyperliquid), SUI (#~15 Sui Network)
// ════════════════════════════════════════════

a01 = f_above("BTC")
a02 = f_above("ETH")
a03 = f_above("BNB")
a04 = f_above("SOL")
a05 = f_above("XRP")
a06 = f_above("ADA")
a07 = f_above("AVAX")
a08 = f_above("DOGE")
a09 = f_above("TON")
a10 = f_above("TRX")
a11 = f_above("HYPE")   // Hyperliquid  — added 2026-06-07 (#11)
a12 = f_above("LINK")
a13 = f_above("DOT")
a14 = f_above("MATIC")
a15 = f_above("SHIB")
a16 = f_above("LTC")
a17 = f_above("BCH")
a18 = f_above("UNI")
a19 = f_above("ATOM")
a20 = f_above("XLM")
a21 = f_above("ETC")
a22 = f_above("APT")
a23 = f_above("SUI")    // Sui Network  — added 2026-06-07 (~#15)
a24 = f_above("NEAR")
a25 = f_above("ICP")
a26 = f_above("FIL")
a27 = f_above("ARB")
a28 = f_above("OP")
a29 = f_above("HBAR")
a30 = f_above("VET")
a31 = f_above("ALGO")
a32 = f_above("EGLD")
a33 = f_above("AAVE")
a34 = f_above("FTM")
a35 = f_above("EOS")
a36 = f_above("MKR")
a37 = f_above("THETA")
a38 = f_above("SAND")
a39 = f_above("MANA")
a40 = f_above("AXS")

// ════════════════════════════════════════════
//   BREADTH CALCULATION
// ════════════════════════════════════════════

TOTAL      = 40
aboveCount = a01 + a02 + a03 + a04 + a05 + a06 + a07 + a08 + a09 + a10 +
             a11 + a12 + a13 + a14 + a15 + a16 + a17 + a18 + a19 + a20 +
             a21 + a22 + a23 + a24 + a25 + a26 + a27 + a28 + a29 + a30 +
             a31 + a32 + a33 + a34 + a35 + a36 + a37 + a38 + a39 + a40

breadth = (aboveCount / TOTAL) * 100.0
signal  = ta.ema(breadth, sigLen)

// ════════════════════════════════════════════
//   COLORS
// ════════════════════════════════════════════

bullColor = color.new(#26a69a, 10)   // teal-green
bearColor = color.new(#ef5350, 10)   // red
neutColor = color.new(#b0bec5, 25)   // grey-blue
barColor  = breadth >= obLevel ? bullColor : breadth <= osLevel ? bearColor : neutColor

// ════════════════════════════════════════════
//   REFERENCE LINES & ZONE FILLS
// ════════════════════════════════════════════

h100 = hline(100,     "",                                                  color=color.new(color.gray, 80))
h_ob = hline(obLevel, "Overbought",  color=color.new(#26a69a, 40), linestyle=hline.style_dashed)
h50  = hline(50,      "Midline",     color=color.new(color.gray, 55), linestyle=hline.style_dotted)
h_os = hline(osLevel, "Oversold",    color=color.new(#ef5350, 40), linestyle=hline.style_dashed)
h0   = hline(0,       "",                                                  color=color.new(color.gray, 80))

fill(h_ob, h100, color=color.new(#26a69a, 88), title="Bull Zone")
fill(h0,   h_os, color=color.new(#ef5350, 88), title="Bear Zone")

// ════════════════════════════════════════════
//   PLOTS
// ════════════════════════════════════════════

plot(breadth, "Breadth %",         color=barColor,                    linewidth=2, style=plot.style_histogram)
plot(breadth, "Breadth % (line)",  color=color.new(barColor, 40),     linewidth=1)
plot(signal,  "Signal EMA",        color=color.new(color.yellow, 10), linewidth=1)

// ════════════════════════════════════════════
//   INFO TABLE (top-right corner)
// ════════════════════════════════════════════

var table t = table.new(
     position.top_right, 2, 5,
     bgcolor      = color.new(color.black, 60),
     border_width = 1,
     border_color = color.new(color.gray, 70),
     frame_width  = 1,
     frame_color  = color.new(color.gray, 70))

if barstate.islast
    statusText  = breadth >= obLevel ? "BULLISH" : breadth <= osLevel ? "BEARISH" : "NEUTRAL"
    statusColor = breadth >= obLevel ? color.green : breadth <= osLevel ? color.red : color.orange

    bg = color.new(color.black, 60)
    table.cell(t, 0, 0, "Breadth",  text_color=color.silver, text_size=size.small,  bgcolor=bg)
    table.cell(t, 1, 0, str.tostring(breadth, "#.0") + "%",
               text_color=color.white,  text_size=size.normal, bgcolor=bg)
    table.cell(t, 0, 1, "Above",    text_color=color.silver, text_size=size.small,  bgcolor=bg)
    table.cell(t, 1, 1, str.tostring(aboveCount) + " / " + str.tostring(TOTAL),
               text_color=color.white,  text_size=size.small,  bgcolor=bg)
    table.cell(t, 0, 2, "MA",       text_color=color.silver, text_size=size.small,  bgcolor=bg)
    table.cell(t, 1, 2, maType + "(" + str.tostring(maLength) + ")",
               text_color=color.white,  text_size=size.small,  bgcolor=bg)
    table.cell(t, 0, 3, "Status",   text_color=color.silver, text_size=size.small,  bgcolor=bg)
    table.cell(t, 1, 3, statusText, text_color=statusColor,  text_size=size.small,  bgcolor=bg)
    table.cell(t, 0, 4, "Reviewed", text_color=color.silver, text_size=size.small,  bgcolor=bg)
    table.cell(t, 1, 4, "2026-06-07", text_color=color.gray, text_size=size.small,  bgcolor=bg)
````
