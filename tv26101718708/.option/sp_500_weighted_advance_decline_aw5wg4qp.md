# S&P 500 Weighted Advance/ Decline

- url: https://www.tradingview.com/script/Aw5WG4qP-S-P-500-Weighted-Advance-Decline/
- type: indicator
- pine_id: PUB;50b49a527cb348d7bacd30a9d0eb2003
- version: 1.0

## Description

This indicator reads the internal health of the S&P 500 by tracking all 11 State Street sector ETFs (XLK, XLF, XLV, etc.) in real time. Instead of just watching price, it tells you who is driving the market and how broad the move really is.

The Two Lines
Histogram (teal/red bars) = "Big Companies that drive the market" 
This is a cap-weighted view of all 11 sectors. Each sector is weighted by how big it is in the S&P 500 — so Tech (XLK) at ~31% carries far more influence than Materials (XLB) at ~2%. When the bars are teal, the cap-weighted market is positive from today's open. When red, it's negative. This tells you what the index itself is doing.

White Line = "All sectors get equal vote" This is a simple average of all 11 sectors with equal weight — every sector gets one vote. This tells you what the average sector is doing, regardless of size. This is your breadth reading.

Divergence Line (aqua/orange thin line) = The Gap
This plots the difference between weighted and Unweighted. When it's positive, the weighted are outpacing the unweighted — the index is being carried by a few large sectors. When it's near zero, everything is moving together.

How To Read It
✅ Healthy rally — Histogram is teal AND white line is also above zero, both close together. Broad participation. Safe to be long and trade in the direction of the move.
⚠️ Narrow rally (warning sign) — Histogram is teal but the white line is lagging below it. Only the big sectors (usually Tech or Financials) are carrying the index. The rally lacks breadth and is fragile. Avoid chasing breakouts.
🔄 Rotation signal — Divergence line flips from positive to negative. Money is likely rotating from growth/tech into smaller or defensive sectors. Watch for a trend change.
🔴 Healthy selloff — Histogram is red AND white line is also below zero, both close together. Everything is selling off uniformly. High conviction bearish environment. Avoid longs.

Important Notes

This is an intraday tool. All readings are based on % change from today's open, so the slate resets every session. Apply it to any chart (SPY, SPX, ES). The indicator ignores the chart symbol — it always pulls data from the 11 sector ETFs.

Use it as confirmation, not a trigger. A long setup from your own strategy is stronger when both generals and soldiers are positive. A setup where only generals are positive deserves caution.
On big gap days, the histogram will open far from zero. Focus on whether it's expanding or contracting as the day progresses, not the absolute level.

The single most important thing to watch is the relationship between the histogram and the white line. When they agree, trust the move. When they diverge, be skeptical.

Teal Above zero, close Strong broad rally — trust it
Teal Below zero or lagging Narrow, fragile rally — be careful
Red Below zero, close Broad selloff — stay defensive
Red Above zero Only large caps selling — possible rotation
Either Divergence line widening Breadth breaking down — watch for reversal

## Source Code

````pine
// @version=5
indicator("Weighted A/D", overlay=false, precision=2)

// --- Sector Inputs ---
// Updated approximate weights for May 2026
w_xlk  = 0.315  // Tech
w_xlv  = 0.125  // Health Care
w_xlf  = 0.130  // Financials
w_xlc  = 0.095  // Comm Services
w_xly  = 0.105  // Cons Discretionary
w_xli  = 0.085  // Industrials
w_xlp  = 0.060  // Staples
w_xle  = 0.040  // Energy
w_xlu  = 0.025  // Utilities
w_xlre = 0.020  // Real Estate
w_xlb  = 0.020  // Materials

// --- Logic: Performance from Daily Open ---
get_perf(ticker) =>
    o = request.security(ticker, "D", open)
    c = request.security(ticker, "D", close)
    ((c - o) / o) * 100

p_xlk  = get_perf("XLK")
p_xlv  = get_perf("XLV")
p_xlf  = get_perf("XLF")
p_xlc  = get_perf("XLC")
p_xly  = get_perf("XLY")
p_xli  = get_perf("XLI")
p_xlp  = get_perf("XLP")
p_xle  = get_perf("XLE")
p_xlu  = get_perf("XLU")
p_xlre = get_perf("XLRE")
p_xlb  = get_perf("XLB")

// --- Calculations ---
// 1. Weighted Histogram (The "Generals")
weighted_val = (p_xlk * w_xlk) + (p_xlv * w_xlv) + (p_xlf * w_xlf) + (p_xlc * w_xlc) + 
               (p_xly * w_xly) + (p_xli * w_xli) + (p_xlp * w_xlp) + (p_xle * w_xle) + 
               (p_xlu * w_xlu) + (p_xlre * w_xlre) + (p_xlb * w_xlb)

// 2. Equal-Weighted Line (The "Soldiers")
equal_weight_val = (p_xlk + p_xlv + p_xlf + p_xlc + p_xly + p_xli + p_xlp + p_xle + p_xlu + p_xlre + p_xlb) / 11

// --- Visuals ---
plot(weighted_val, title="Weighted (Histogram)", color=weighted_val >= 0 ? color.teal : color.maroon, style=plot.style_columns, transp=40)
plot(equal_weight_val, title="Unweighted (Line)", color=color.white, linewidth=2)

hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)
````
