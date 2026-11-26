# ES vs NQ EMA Strength  Dashboard

- url: https://www.tradingview.com/script/dzPaJMcN-ES-vs-NQ-EMA-Strength-Dashboard/
- type: indicator
- pine_id: PUB;aea0dfa77d84422a9359bacd37985eff
- version: 1.0

## Description

📊 ES/NQ Strength Matrix

A multi-timeframe momentum dashboard designed to track trend strength and alignment between ES and NQ futures using EMA structure.

This indicator provides a clear, real-time view of whether the market is bullish, bearish, or neutral across key intraday timeframes, helping traders quickly identify high-probability conditions.

🔍 What It Does

The dashboard compares:

ES Futures vs NQ Futures
Across multiple timeframes:
1m, 5m, 15m, 30m, 1H

Each timeframe is classified into 5 strength levels:

S.BULL → Strong bullish alignment (full EMA stack + price above)
BULL → Bullish but not fully stacked
NEUTRAL → Mixed / no clear direction
BEAR → Bearish but not fully stacked
S.BEAR → Strong bearish alignment (full EMA stack + price below)
⚙️ How It Works

Uses EMA structure:

Fast EMA (9)
Mid EMA (21)
Trend EMA (50)

Strength is determined by:

EMA stacking (trend structure)
Price position relative to EMAs
🎯 How to Use
Look for alignment across timeframes for higher probability trades
Strong setups occur when:
ES and NQ both show S.BULL or S.BEAR
Avoid trades during:
NEUTRAL conditions (choppy market)

Best suited for:

Scalping (1m–5m)
Intraday momentum trading
⚡ Features
Real-time ES vs NQ comparison
Multi-timeframe trend strength
Clean, minimal dashboard
Quick decision-making tool
Adjustable table position
⚠️ Notes
Requires futures data for ES/NQ symbols
Works best on lower timeframes (1m–5m charts)
Designed as a confirmation tool, not a standalone strategy[i][/i][i][/i][s][/s]

## Source Code

````pine
//@version=6
indicator("ES vs NQ EMA Strength Dashboard", overlay=true)

// ── SYMBOLS ────────────────────────────────────
es = "CME_MINI:ES1!"
nq = "CME_MINI:NQ1!"

// ── SETTINGS ───────────────────────────────────
fastLen = input.int(9,  "Fast EMA")
midLen  = input.int(21, "Mid EMA")
slowLen = input.int(50, "Slow EMA")

posInput = input.string("bottom_right", "Table Position",
     options=["top_left","top_right","bottom_left","bottom_right"])

offset = input.int(0, "Vertical Offset", minval=0, maxval=5)

// ── POSITION ───────────────────────────────────
pos = posInput == "top_left" ? position.top_left :
      posInput == "top_right" ? position.top_right :
      posInput == "bottom_left" ? position.bottom_left :
      position.bottom_right

// ── FUNCTION: TREND STRENGTH ───────────────────
f_strength(sym, tf) =>
    c = request.security(sym, tf, close)
    e9  = request.security(sym, tf, ta.ema(close, fastLen))
    e21 = request.security(sym, tf, ta.ema(close, midLen))
    e50 = request.security(sym, tf, ta.ema(close, slowLen))

    bullStack = e9 > e21 and e21 > e50
    bearStack = e9 < e21 and e21 < e50

    aboveAll = c > e9 and c > e21 and c > e50
    belowAll = c < e9 and c < e21 and c < e50

    result =
         bullStack and aboveAll ? "S.BULL" :
         bearStack and belowAll ? "S.BEAR" :
         aboveAll ? "BULL" :
         belowAll ? "BEAR" : "NEUTRAL"

    result

// ── COLOR FUNCTION ─────────────────────────────
f_color(txt) =>
     txt == "S.BULL" ? color.lime :
     txt == "BULL"   ? color.green :
     txt == "S.BEAR" ? color.red :
     txt == "BEAR"   ? color.orange :
     color.gray

// ── DATA ───────────────────────────────────────
es1  = f_strength(es, "1")
es5  = f_strength(es, "5")
es15 = f_strength(es, "15")
es30 = f_strength(es, "30")
es60 = f_strength(es, "60")

nq1  = f_strength(nq, "1")
nq5  = f_strength(nq, "5")
nq15 = f_strength(nq, "15")
nq30 = f_strength(nq, "30")
nq60 = f_strength(nq, "60")

// ── TABLE ──────────────────────────────────────
var table t = table.new(position.bottom_right, 3, 7,
     bgcolor=color.new(color.black, 85),
     border_width=1)

// ── UPDATE ─────────────────────────────────────
if barstate.islast
    table.set_position(t, pos)

    // clear
    for r = 0 to 6
        for c = 0 to 2
            table.cell(t, c, r, "")

    row = offset

    // HEADER
    headerBg = color.new(color.gray, 60)

    table.cell(t, 0, row, "TF", text_color=color.white, bgcolor=headerBg)
    table.cell(t, 1, row, "ES", text_color=color.white, bgcolor=headerBg)
    table.cell(t, 2, row, "NQ", text_color=color.white, bgcolor=headerBg)

    // ROWS
    table.cell(t, 0, row+1, "1m",  text_color=color.white)
    table.cell(t, 1, row+1, es1,  text_color=f_color(es1))
    table.cell(t, 2, row+1, nq1,  text_color=f_color(nq1))

    table.cell(t, 0, row+2, "5m",  text_color=color.white)
    table.cell(t, 1, row+2, es5,  text_color=f_color(es5))
    table.cell(t, 2, row+2, nq5,  text_color=f_color(nq5))

    table.cell(t, 0, row+3, "15m", text_color=color.white)
    table.cell(t, 1, row+3, es15, text_color=f_color(es15))
    table.cell(t, 2, row+3, nq15, text_color=f_color(nq15))

    table.cell(t, 0, row+4, "30m", text_color=color.white)
    table.cell(t, 1, row+4, es30, text_color=f_color(es30))
    table.cell(t, 2, row+4, nq30, text_color=f_color(nq30))

    table.cell(t, 0, row+5, "1H",  text_color=color.white)
    table.cell(t, 1, row+5, es60, text_color=f_color(es60))
    table.cell(t, 2, row+5, nq60, text_color=f_color(nq60))
````
