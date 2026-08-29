<!-- tradingview-pine-id: PUB;e052a638ea184dfd9c21976461b35059 -->
<!-- tradingviewscripts-format: 1 -->
# ATR Range Filter

Source: https://www.tradingview.com/script/GVJJ3zXW-ATR-Range-Filter/

## Description

Here's a description you can paste into the publish dialog:

ATR Range Filter

Highlights candles whose range is unusually large relative to recent volatility.

What it does

For every bar, the script divides the bar's range (high − low) by the Average True Range. If that ratio meets or exceeds your threshold — 1.5 by default — the bar is redrawn with a custom border and wick colour. All other bars are left untouched, so your normal chart styling shows through.

How it works

ATR uses Wilder's (RMA) smoothing, the standard definition, with a configurable lookback (default 14). The comparison is (high − low) ÷ ATR, so the threshold reads directly as a multiple: 1.5 means the bar is one and a half times the average true range.

An option is included to exclude the current bar from the ATR calculation and use the previous bar's value instead. This is useful around session opens, where a short ATR lookback is still averaging in quiet pre-session bars and can understate real volatility, producing false flags.

Settings

ATR length and threshold multiple
Separate border and wick colours for up and down bars
Optional body recolouring (off by default, so only the outline changes)
Optional numeric label showing the exact ratio above each flagged bar
Optional background tint
Alert condition when a bar exceeds the threshold
Ratio is plotted to the Data Window for reference

Ideas for use

Outsized bars often mark volatility expansion, news reactions, stop runs, or exhaustion moves. Depending on your approach you may want to stand aside after one, wait for the range to settle, or treat it as a signal in its own right. The indicator only identifies the condition — what you do with it is up to your own testing.

This is a visual filter, not a trading system, and produces no buy or sell signals.

---

## Source Code

````pine
//@version=6
indicator("ATR Range Filter", overlay = true)

// ─── Inputs ────────────────────────────────────────────────────────────────
grpCalc = "Calculation"
atrLen    = input.int(14,    "ATR length",              minval = 1,               group = grpCalc)
threshold = input.float(1.5, "Flag bars with range ≥",  minval = 0.1, step = 0.05, group = grpCalc,
     tooltip = "Bar range (high − low) divided by ATR. 1.5 = bar is one and a half times the average true range.")
usePrevATR = input.bool(false, "Exclude current bar from ATR",  group = grpCalc,
     tooltip = "Uses the ATR value as of the previous bar. Helpful at the cash open, where a 14-period ATR is still averaging in quiet pre-open bars and understates real volatility.")

grpCol = "Colors"
colorBody = input.bool(false, "Also recolor the body", group = grpCol)
upBorder   = input.color(color.new(#FF9800, 0),  "Up   border", group = grpCol, inline = "up")
upWick     = input.color(color.new(#FF9800, 0),  "wick",        group = grpCol, inline = "up")
dnBorder   = input.color(color.new(#E040FB, 0),  "Down border", group = grpCol, inline = "dn")
dnWick     = input.color(color.new(#E040FB, 0),  "wick",        group = grpCol, inline = "dn")
upBody     = input.color(color.new(#FF9800, 40), "Up   body",   group = grpCol, inline = "ub")
dnBody     = input.color(color.new(#E040FB, 40), "Down body",   group = grpCol, inline = "ub")

grpExtra = "Extras"
showRatio  = input.bool(false, "Show ratio above flagged bars", group = grpExtra)
showBg     = input.bool(false, "Tint background on flagged bars", group = grpExtra)
bgCol      = input.color(color.new(#FF9800, 90), "Background tint", group = grpExtra)

// ─── Calculation ───────────────────────────────────────────────────────────
// ta.atr() uses Wilder (RMA) smoothing, matching the standard ATR definition.
atrRaw = ta.atr(atrLen)
atrVal = usePrevATR ? atrRaw[1] : atrRaw

barRange = high - low
ratio    = na(atrVal) or atrVal == 0 ? na : barRange / atrVal
isBig    = not na(ratio) and ratio >= threshold

isUp = close >= open

// ─── Plotting ──────────────────────────────────────────────────────────────
// Only flagged bars are drawn; everything else falls through to your normal candles.
plotcandle(isBig ? open  : na,
           isBig ? high  : na,
           isBig ? low   : na,
           isBig ? close : na,
           title       = "Flagged bar",
           color       = colorBody ? (isUp ? upBody : dnBody) : (isUp ? color.new(upBody, 100) : color.new(dnBody, 100)),
           bordercolor = isUp ? upBorder : dnBorder,
           wickcolor   = isUp ? upWick   : dnWick)

bgcolor(showBg and isBig ? bgCol : na, title = "Flagged background")

if showRatio and isBig
    label.new(bar_index, high,
         text  = str.tostring(ratio, "#.##"),
         style = label.style_label_down,
         color = color.new(color.black, 100),
         textcolor = isUp ? upBorder : dnBorder,
         size  = size.tiny)

// ─── Alert ─────────────────────────────────────────────────────────────────
alertcondition(isBig, title = "Bar range over ATR threshold",
     message = "Bar range exceeded the ATR threshold")

// Optional plot for use in other scripts / data window
plot(ratio, title = "Range ÷ ATR", color = color.new(color.gray, 100), display = display.data_window)
````
