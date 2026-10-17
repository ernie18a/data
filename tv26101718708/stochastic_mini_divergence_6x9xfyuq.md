# Stochastic + Mini Divergence

- url: https://www.tradingview.com/script/6x9XFyuq-Stochastic-Mini-Divergence/
- type: indicator
- pine_id: PUB;c0d5fa20453a43c789c4a3787c181022
- version: 1.0

## Description

BULLISH MINI DIVERGENCE (Long Signal)
What price does:

Makes a lower low, or a double bottom (second low equal to or lower than the first)

What %K does:

First trough: %K hooks down, reaches 20 or below at some point
%K then hooks back up
%K then hooks back down again for the second trough
The second trough of %K is higher than the first trough
Price went lower or equal, %K went higher

What %D must do:

Must stay below 45 the entire time between the two lows
Must NOT recover into the 45-55 zone
If %D crosses back above 45 — pattern invalidated


BEARISH MINI DIVERGENCE (Short Signal)
What price does:

Makes a higher high, or a double top (second high equal to or higher than the first)

What %K does:

First peak: %K hooks up, reaches 80 or above at some point
%K then hooks back down
%K then hooks back up again for the second peak
The second peak of %K is lower than the first peak
Price went higher or equal, %K went lower

What %D must do:

Must stay above 55 the entire time between the two highs
Must NOT pull back into the 45-55 zone
If %D crosses back below 55 — pattern invalidated

## Source Code

````pine
//@version=6
indicator("Stochastic + Mini Divergence", "Stoch MiniDiv", format=format.price, precision=2)

// ── Inputs ────────────────────────────────────────────────────────────────────
periodK  = input.int(5,   "%K Length",    minval=1)
smoothK  = input.int(2,   "%K Smoothing", minval=1)
periodD  = input.int(3,   "%D Smoothing", minval=1)

d_upper  = input.float(55.0, "%D Upper Bound (bearish: %D must stay ABOVE)", minval=50.0, maxval=70.0, step=1.0, group="Mini Div Rules")
d_lower  = input.float(45.0, "%D Lower Bound (bullish: %D must stay BELOW)", minval=30.0, maxval=50.0, step=1.0, group="Mini Div Rules")
k_hi_min = input.float(80.0, "First bearish peak: %K must reach this or higher", minval=60.0, maxval=95.0, step=5.0, group="Mini Div Rules")
k_lo_max = input.float(20.0, "First bullish trough: %K must reach this or lower", minval=5.0,  maxval=40.0, step=5.0, group="Mini Div Rules")

show_bull = input.bool(true, "Show Bullish Mini Div", group="Display")
show_bear = input.bool(true, "Show Bearish Mini Div", group="Display")
bull_col  = input.color(color.new(color.green, 0), "Bullish Line Color", group="Display")
bear_col  = input.color(color.new(color.red,   0), "Bearish Line Color", group="Display")

// ── Stochastic ────────────────────────────────────────────────────────────────
k = ta.sma(ta.stoch(close, high, low, periodK), smoothK)
d = ta.sma(k, periodD)

plot(k, "%K", color=#2962FF, linewidth=1)
plot(d, "%D", color=#FF6D00, linewidth=1)
h0 = hline(80, "Upper Band", color=#787B86)
hline(50, "Middle Band", color=color.new(#787B86, 50))
h1 = hline(20, "Lower Band", color=#787B86)
fill(h0, h1, color=color.rgb(33, 150, 243, 90), title="Background")

// ── %D zone classification ────────────────────────────────────────────────────
d_above = d > d_upper   // %D above upper bound — bearish cycle alive
d_below = d < d_lower   // %D below lower bound — bullish cycle alive

// ── %K local turning points (3-bar; turning point is the prior bar) ───────────
k_peak   = k[2] < k[1] and k[1] >= k   // previous bar was a local high
k_trough = k[2] > k[1] and k[1] <= k   // previous bar was a local low

// ══════════════════════════════════════════════════════════════════════════════
// BEARISH MINI DIVERGENCE  (short signal)
//   Price:  higher high or double top (2nd high ≥ 1st high)
//   %K:     1st peak reaches ≥ 80 → hooks down → hooks back up to 2nd peak
//           2nd peak LOWER than 1st peak
//   %D:     must stay ABOVE 55 the entire time between the two highs.
//           If %D crosses back to/below 55 → pattern invalidated.
// ══════════════════════════════════════════════════════════════════════════════
var int   bear_phase  = 0
var float bear_k1     = na   // reference (latest qualifying) %K peak
var int   bear_bar1   = na   // bar of that peak
var float bear_price1 = na   // price high at that peak
bear_div = false

if bear_phase > 0 and not d_above
    // %D dropped to/below the upper bound — cycle complete, invalidate
    bear_phase := 0
else if bear_phase == 0
    // Look for first peak: %D above bound AND %K peak reached 80+
    if d_above and k_peak and k[1] >= k_hi_min
        bear_phase  := 1
        bear_k1     := k[1]
        bear_bar1   := bar_index - 1
        bear_price1 := high[1]
else if bear_phase == 1
    // %K must hook down first
    if k_trough
        bear_phase := 2
else if bear_phase == 2
    // %K hooks back up — evaluate the second peak
    if k_peak
        if k[1] < bear_k1
            // Lower %K peak → divergence if price made equal/higher high
            if high[1] >= bear_price1
                bear_div := true
                if show_bear
                    line.new(x1=bear_bar1, y1=bear_k1,
                             x2=bar_index - 1, y2=k[1],
                             color=bear_col, width=2, xloc=xloc.bar_index)
            bear_phase := 0
        else
            // Higher %K peak → no divergence yet; this becomes the new reference
            bear_k1     := k[1]
            bear_bar1   := bar_index - 1
            bear_price1 := high[1]
            bear_phase  := 1

// ══════════════════════════════════════════════════════════════════════════════
// BULLISH MINI DIVERGENCE  (long signal)
//   Price:  lower low or double bottom (2nd low ≤ 1st low)
//   %K:     1st trough reaches ≤ 20 → hooks up → hooks back down to 2nd trough
//           2nd trough HIGHER than 1st trough
//   %D:     must stay BELOW 45 the entire time between the two lows.
//           If %D crosses back to/above 45 → pattern invalidated.
// ══════════════════════════════════════════════════════════════════════════════
var int   bull_phase  = 0
var float bull_k1     = na   // reference (latest qualifying) %K trough
var int   bull_bar1   = na   // bar of that trough
var float bull_price1 = na   // price low at that trough
bull_div = false

if bull_phase > 0 and not d_below
    // %D rose to/above the lower bound — cycle complete, invalidate
    bull_phase := 0
else if bull_phase == 0
    // Look for first trough: %D below bound AND %K trough reached 20-
    if d_below and k_trough and k[1] <= k_lo_max
        bull_phase  := 1
        bull_k1     := k[1]
        bull_bar1   := bar_index - 1
        bull_price1 := low[1]
else if bull_phase == 1
    // %K must hook up first
    if k_peak
        bull_phase := 2
else if bull_phase == 2
    // %K hooks back down — evaluate the second trough
    if k_trough
        if k[1] > bull_k1
            // Higher %K trough → divergence if price made equal/lower low
            if low[1] <= bull_price1
                bull_div := true
                if show_bull
                    line.new(x1=bull_bar1, y1=bull_k1,
                             x2=bar_index - 1, y2=k[1],
                             color=bull_col, width=2, xloc=xloc.bar_index)
            bull_phase := 0
        else
            // Lower %K trough → no divergence yet; this becomes the new reference
            bull_k1     := k[1]
            bull_bar1   := bar_index - 1
            bull_price1 := low[1]
            bull_phase  := 1

// ── Labels ────────────────────────────────────────────────────────────────────
plotshape(bull_div, "Bull Mini Div",
     style=shape.labelup, location=location.bottom,
     color=bull_col, textcolor=color.white, text="Bull", size=size.tiny)

plotshape(bear_div, "Bear Mini Div",
     style=shape.labeldown, location=location.top,
     color=bear_col, textcolor=color.white, text="Bear", size=size.tiny)

// ── Background: show active cycle ────────────────────────────────────────────
bgcolor(bear_phase > 0 ? color.new(color.red,   95) : na, title="Bear cycle active")
bgcolor(bull_phase > 0 ? color.new(color.green, 95) : na, title="Bull cycle active")

// ── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(bull_div, "Bullish Mini Div", "Stoch bullish mini divergence detected")
alertcondition(bear_div, "Bearish Mini Div", "Stoch bearish mini divergence detected")
````
