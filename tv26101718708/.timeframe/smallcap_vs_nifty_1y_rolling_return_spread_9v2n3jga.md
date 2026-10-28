# Smallcap vs Nifty - 1Y Rolling Return Spread

- url: https://www.tradingview.com/script/9v2n3JgA-Smallcap-vs-Nifty-1Y-Rolling-Return-Spread/
- type: indicator
- pine_id: PUB;015aaa3442744cdfae8cccf8e4e85c0f
- version: 1.0

## Description

Difference in Returns between Smallcap vs Nifty 1 year rolling Returns

## Source Code

````pine
//@version=6
indicator("Smallcap vs Nifty - 1Y Rolling Return Spread", overlay=false, max_bars_back=5000)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
lookback      = input.int(12,  title="Rolling Return Period (bars)",  minval=1)
sd_period     = input.int(60,  title="SD Calculation Period (bars)",  minval=12)
show_sd_bands = input.bool(true, title="Show SD Bands")
show_avg      = input.bool(true, title="Show Average Line")

// ─────────────────────────────────────────
// DATA
// ─────────────────────────────────────────
nifty50   = request.security("NSE:NIFTY",              "M", close)
smallcap = request.security("NSE:CNXSMALLCAP", "M", close)

// ─────────────────────────────────────────
// ROLLING 1-YEAR RETURNS
// ─────────────────────────────────────────
nifty_ret    = (nifty50  / nifty50[lookback]  - 1) * 100
smallcap_ret = (smallcap / smallcap[lookback] - 1) * 100

// ─────────────────────────────────────────
// SPREAD (Smallcap - Nifty)
// ─────────────────────────────────────────
spread = smallcap_ret - nifty_ret

// ─────────────────────────────────────────
// STATISTICS
// ─────────────────────────────────────────
avg   = ta.sma(spread,   sd_period)
stdev = ta.stdev(spread, sd_period)

p1 = avg + 1 * stdev
p2 = avg + 2 * stdev
p3 = avg + 3 * stdev
p4 = avg + 4 * stdev
m1 = avg - 1 * stdev
m2 = avg - 2 * stdev

// ─────────────────────────────────────────
// SD BAND PLOTS
// ─────────────────────────────────────────
plot(show_sd_bands ? p4 : na, title="+4 SD", color=color.new(color.green,  20), linewidth=1)
plot(show_sd_bands ? p3 : na, title="+3 SD", color=color.new(color.purple, 20), linewidth=1)
plot(show_sd_bands ? p2 : na, title="+2 SD", color=color.new(color.blue,   20), linewidth=1)
plot(show_sd_bands ? p1 : na, title="+1 SD", color=color.new(color.teal,   20), linewidth=1)
plot(show_sd_bands ? m1 : na, title="-1 SD", color=color.new(color.navy,   20), linewidth=1)
plot(show_sd_bands ? m2 : na, title="-2 SD", color=color.new(color.red,    20), linewidth=1)

// ─────────────────────────────────────────
// AVERAGE LINE
// ─────────────────────────────────────────
plot(show_avg ? avg : na,
     title     = "Average",
     color     = color.orange,
     linewidth = 1,
     style     = plot.style_line,
     linestyle = plot.linestyle_dashed)

// ─────────────────────────────────────────
// ZERO LINE
// ─────────────────────────────────────────
hline(0, "Zero", color=color.gray, linewidth=1, linestyle=hline.style_solid)

// ─────────────────────────────────────────
// MAIN SPREAD LINE
// ─────────────────────────────────────────
plot(spread,
     title     = "Smallcap - Nifty 1Y Return",
     color     = color.new(color.maroon, 0),
     linewidth = 2,
     style     = plot.style_line)

// ─────────────────────────────────────────
// BACKGROUND SHADING
// ─────────────────────────────────────────
bgcolor(spread > p1 ? color.new(color.green, 90) :
        spread < m1 ? color.new(color.red,   90) : na,
        title = "Extreme Zone Highlight")

// ─────────────────────────────────────────
// CURRENT VALUE LABEL
// ─────────────────────────────────────────
if barstate.islast
    label.new(bar_index, spread,
              "Spread: " + str.tostring(math.round(spread, 1)) + "%",
              color     = color.maroon,
              textcolor = color.white,
              style     = label.style_label_left,
              size      = size.small)
````
