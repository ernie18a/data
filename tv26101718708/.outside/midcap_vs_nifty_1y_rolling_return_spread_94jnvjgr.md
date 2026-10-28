# Midcap vs Nifty - 1Y Rolling Return Spread

- url: https://www.tradingview.com/script/94jNVJGR-Midcap-vs-Nifty-1Y-Rolling-Return-Spread/
- type: indicator
- pine_id: PUB;58dd7dd8317449c7b8c750bb11a11f4b
- version: 1.0

## Description

Spread between Nifty Midcap 150 1 years returns - Nifty 50 1 Year Returns

## Source Code

````pine
//@version=6
indicator("Midcap vs Nifty - 1Y Rolling Return Spread", overlay=false, max_bars_back=5000)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
lookback      = input.int(12,  title="Rolling Return Period (bars)",  minval=1)   // 12 months = 1 year
sd_period     = input.int(60,  title="SD Calculation Period (bars)",  minval=12)  // 60 months = 5 years
show_sd_bands = input.bool(true, title="Show SD Bands")
show_avg      = input.bool(true, title="Show Average Line")

// ─────────────────────────────────────────
// DATA
// ─────────────────────────────────────────
nifty50 = request.security("NSE:NIFTY",            "M", close)
midcap  = request.security("NSE:NIFTY_MIDCAP_150", "M", close)

// ─────────────────────────────────────────
// ROLLING 1-YEAR RETURNS
// ─────────────────────────────────────────
nifty_ret  = (nifty50 / nifty50[lookback] - 1) * 100
midcap_ret = (midcap  / midcap[lookback]  - 1) * 100

// ─────────────────────────────────────────
// SPREAD (Midcap - Nifty)
// ─────────────────────────────────────────
spread = midcap_ret - nifty_ret

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
plot(show_sd_bands ? p3 : na, color=color.new(color.purple, 20), linewidth=1, title="+3 SD")
plot(show_sd_bands ? p2 : na, color=color.new(color.blue,   20), linewidth=1, title="+2 SD")
plot(show_sd_bands ? p1 : na, color=color.new(color.teal,   20), linewidth=1, title="+1 SD")
plot(show_sd_bands ? m1 : na, color=color.new(color.navy,   20), linewidth=1, title="-1 SD")
plot(show_sd_bands ? m2 : na, color=color.new(color.red,    20), linewidth=1, title="-2 SD")

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
     title     = "Midcap - Nifty 1Y Return",
     color     = color.new(color.navy, 0),
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
              color     = color.navy,
              textcolor = color.white,
              style     = label.style_label_left,
              size      = size.small)
````
