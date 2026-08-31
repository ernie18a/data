<!-- tradingview-pine-id: PUB;daf815b894df4cd5b403a04e0fa50977 -->
<!-- tradingviewscripts-format: 1 -->
# CTZ MVRV Z-Score & Realized Cap

Source: https://www.tradingview.com/script/kcj7YINJ-CTZ-MVRV-Z-Score-Realized-Cap/

## Description

Here's a TradingView description for it. I've kept the emphasis where you asked — it's a stronger bottom-picker than top-picker — and stayed honest about what it is and its limits.

---

**CTZ MVRV Z-Score & Realized Cap**

An on-chain valuation tool for Bitcoin that compares what the market is paying for BTC against what holders actually paid for it — and flags when price has fallen below the aggregate cost basis, which is historically where major bottoms form.

This pulls real on-chain data (CoinMetrics Market Cap and Realized Cap via TradingView), not a price-based approximation. Run it on a BTCUSD chart for full history.

WHAT IT MEASURES

Market Cap is Bitcoin's price times circulating supply — what the network is worth right now. Realized Cap values every coin at the price it last moved on-chain, so it represents the aggregate cost basis of all holders — what the market actually paid.

From these two it builds:

MVRV Ratio — Market Cap divided by Realized Cap. Above 1, holders are in aggregate profit; below 1, the market is in aggregate loss, which is rare and historically a strong accumulation signal.

MVRV Z-Score — the orange line. It standardises the gap between market value and realized value against its own historical deviation, so extremes stand out clearly across cycles. A green accumulation band sits at the bottom, a red distribution band up top.

Below-Realized flag — when Market Cap drops below Realized Cap (price below the average cost basis of the whole market), the background shades green. This is the core bottom condition and the reason the tool leans the way it does.

BETTER FOR BOTTOMS THAN TOPS — READ THIS

Be clear on how to use this: it is a far more reliable bottom-picker than top-picker.

The bottom signal is grounded in something real and hard to fake — when price falls below the market's aggregate cost basis, the average holder is underwater, and that level of capitulation has marked every major Bitcoin bottom to date. It's a rare, high-conviction condition. When the Z-Score sinks into the green zone or the background flags below-realized, history says you are near a generational buying area.

The top signal is looser. Cycle tops have printed at very different Z-Score peaks as the asset has matured — each cycle tends to top at a lower Z-Score than the last as Bitcoin grows and volatility compresses. So the red band is a "getting expensive, take note" warning, not a precise sell trigger. Treat a green-zone reading as a strong signal to accumulate; treat a red-zone reading as a caution flag to pair with your own confirmation, never as a standalone exit.

In short: lean on it hard at the bottoms, lean on it lightly at the tops.

HOW TO USE IT

Run it on BTCUSD (or INDEX:BTCUSD / BLX for the longest history). Watch for the orange Z-Score entering the green band or the green background appearing — those are your accumulation windows. Use the red band as an overvaluation caution rather than a timed top. You can toggle between the Z-Score and the raw MVRV ratio, and adjust the zone thresholds to your own cycle read.

NOTES

This relies on TradingView's on-chain data feed. If the on-chain series don't resolve on your plan, the tool shows a notice instead of plotting approximate data — it will never fake the metric. Because Realized Cap is Bitcoin-specific, this is a BTC-only tool.

Valuation extremes tell you when, roughly, not exactly. Bottoms are a zone, not a single day, and tops even more so. Use this as a cycle-position framework alongside your own analysis, not as a standalone buy/sell signal.

For educational and analytical purposes only. Not financial advice.

---

## Source Code

````pine
//@version=6
indicator("CTZ MVRV Z-Score & Realized Cap", shorttitle="CTZ MVRV Z", overlay=false, max_labels_count=100)

// ================= Data source =================
// Real on-chain series from CoinMetrics via TradingView.
// Requires BTCUSD (or BLX) as the chart symbol for full history.
grpS = "Data / Display"
show_caps = input.bool(true,  "Show Market & Realized Cap (log)", group=grpS)
show_mvrv = input.bool(false, "Show MVRV Ratio instead of Z-Score", group=grpS)
tf        = input.timeframe("1D", "Calc Timeframe (leave 1D)", group=grpS)

marketCap   = request.security("BTC_MARKETCAP",     tf, close, ignore_invalid_symbol=true)
realizedCap = request.security("BTC_MARKETCAPREAL", tf, close, ignore_invalid_symbol=true)

bool dataOk = not na(marketCap) and not na(realizedCap)

// ================= Core metrics =================
// MVRV ratio = Market Cap / Realized Cap
mvrv = dataOk ? marketCap / realizedCap : na

// MVRV Z-Score = (Market Cap - Realized Cap) / cumulative std(Market Cap)
var float sumMC  = 0.0
var float sumMC2 = 0.0
var int   nMC    = 0
if dataOk
    sumMC  += marketCap
    sumMC2 += marketCap * marketCap
    nMC    += 1
float meanMC = nMC > 0 ? sumMC / nMC : na
float varMC  = nMC > 1 ? (sumMC2 - sumMC * sumMC / nMC) / (nMC - 1) : na
float stdMC  = varMC > 0 ? math.sqrt(varMC) : na
float zscore = dataOk and not na(stdMC) and stdMC > 0 ? (marketCap - realizedCap) / stdMC : na

// ================= Zone thresholds =================
grpZ = "Zone Levels"
topTrig = input.float(6.85, "Top Zone (Z upper)", step=0.05, group=grpZ)
topLo   = input.float(5.5,  "Top Zone (Z lower)", step=0.05, group=grpZ)
botTrig = input.float(0.1,  "Bottom Zone (Z upper)", step=0.05, group=grpZ)
botLo   = input.float(-0.5, "Bottom Zone (Z lower)", step=0.05, group=grpZ)
zCol    = input.color(color.new(color.orange, 0), "Z-Score / MVRV Colour", group=grpZ)

// ================= Plots =================
// Main line: Z-Score by default, MVRV if toggled
plotVal = show_mvrv ? mvrv : zscore
plot(plotVal, "MVRV Z-Score", color=zCol, linewidth=2)

// Top (distribution) band — red
topU = plot(show_mvrv ? na : topTrig, "Top Upper", color=color.new(color.red, 60))
topL = plot(show_mvrv ? na : topLo,   "Top Lower", color=color.new(color.red, 60))
fill(topU, topL, color=color.new(color.red, 85), title="Top Zone")

// Bottom (accumulation) band — green
botU = plot(show_mvrv ? na : botTrig, "Bottom Upper", color=color.new(color.green, 60))
botL = plot(show_mvrv ? na : botLo,   "Bottom Lower", color=color.new(color.green, 60))
fill(botU, botL, color=color.new(color.green, 80), title="Bottom Zone")

hline(show_mvrv ? 1.0 : 0.0, "Zero / Parity", color=color.new(color.gray, 50), linestyle=hline.style_dashed)

// ================= Market vs Realized cap (log, secondary) =================
// Plotted small in the same pane on a log-ish scale via log10 transform
f_log10(x) => not na(x) and x > 0 ? math.log(x) / math.log(10) : na
mcL = f_log10(marketCap)
rcL = f_log10(realizedCap)
// Rescale the log-cap lines to sit in the oscillator's visual range (optional context)
plot(show_caps ? mcL : na, "Market Cap (log)",   color=color.new(color.black, 20), linewidth=1, display=display.pane)
plot(show_caps ? rcL : na, "Realized Cap (log)", color=color.new(color.blue,  20), linewidth=1, display=display.pane)

// ================= Below-realized-price signal =================
// When market cap < realized cap, price is below aggregate cost basis:
// this is where Z-Score drops into the green zone and historically bottoms.
belowReal = dataOk and marketCap < realizedCap
bgcolor(belowReal ? color.new(color.green, 90) : na, title="Below Realized (cost-basis) Zone")

// Triangle markers at extremes
inTop = not na(zscore) and zscore >= topTrig
inBot = not na(zscore) and (zscore <= botTrig or belowReal)
plotshape(inTop and not inTop[1], "Top Signal", shape.triangledown, location.top,    color=color.red,   size=size.normal)
plotshape(inBot and not inBot[1], "Bottom Signal", shape.triangleup, location.bottom, color=color.green, size=size.normal)

// ================= Data-missing notice =================
if barstate.islast and not dataOk
    label.new(bar_index, 0, "⚠ On-chain data not available on this symbol.\nRun on BTCUSD or INDEX:BTCUSD for full history.",
         style=label.style_label_left, color=color.new(color.red, 10), textcolor=color.white, size=size.normal)
````
