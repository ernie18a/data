# Gann Levels v6 - Signals Dashboard Full

- url: https://www.tradingview.com/script/f0oHMRsP-Gann-Levels-v6-Signals-Dashboard-Full/
- type: indicator
- pine_id: PUB;e83a4bb003b84b8f8b036c5702264b7d
- version: 1.0

## Description

This script gives you a daily trade map from yesterday’s price data, then projects today’s support and resistance on the chart, shows the prices on the right, and can print simple B/S/SL/TP labels. It is not a guaranteed entry system by itself; it is a level-based framework that helps you decide bias, entry zone, stop placement, and target ladder before taking a trade.

What the script shows
The script has two level engines. The first is Square Root, which starts from yesterday’s close and projects levels outward using square-root progression, a common Gann-style way to locate possible reaction zones from one anchor price. The second is Pivot Style, which uses yesterday’s high, low, and close to compute a central pivot plus R1-R3 and S1-S3 for the current session.

It also lets you:

Show one method only, or both together.

See price tags on the right side of the chart for each level.

Use a light dashboard with adjustable font size.

Change line thickness for R1/S1, R2/S2, and R3/S3.

Show simple B, S, SL, and TP labels.

How to read levels
In Square Root mode, the previous day close is the main anchor. If price stays above that base, the upper square-root levels R1, R2, and R3 become upside targets; if price stays below it, S1, S2, and S3 become downside targets.

In Pivot mode, the pivot base is the center line for the day. If price is above the pivot, the day is often treated as bullish-biased; if price is below it, bearish-biased, with R1-R3 and S1-S3 acting as likely reaction or target zones.

When both modes are close to each other, that is called confluence. Confluence matters because when a square-root level and a pivot level sit near the same price, traders often expect a stronger reaction there than from a single level alone.

How to take trades
The best way to use this script is to first decide the day bias, then use the nearest levels to plan a low-risk trade. A simple approach is to wait for price to come to the base or to a level, then watch whether price holds, rejects, or breaks and retests it before entering.

For a buy setup:

Prefer price above Pivot Base or above Square Root Base.

Wait for a pullback to base, S1, or a confluence zone.

Enter only after price holds that zone and closes back upward.

Keep SL below the support that justified the entry.

Take TP at the next resistance level, then the next one after that.For a sell setup:

Prefer price below Pivot Base or below Square Root Base.

Wait for a bounce into base, R1, or a confluence zone.

Enter only after price rejects that zone and closes back downward.

Keep SL above the resistance that justified the short.

Take TP at the next support level, then the next one after that.

Entry, SL, TP logic
A clean rule is: entry at reaction, SL beyond invalidation, TP at next level. This works because pivot and Gann-style levels are most useful as structured support/resistance ladders, so the next ladder step naturally becomes the next target while the opposite side of the setup becomes the invalidation area.

Example long trade:

Price opens above Pivot Base.

It pulls back to Pivot Base or Square Root Base.

A bullish candle closes back above the level.

Entry = above that candle high.

SL = below the level or below the candle low.

TP1 = nearest R1.

TP2 = R2.

TP3 = R3 if trend stays strong.

Example short trade:

Price is trading below the base.

It retraces into R1 or into a base-confluence zone.

A bearish candle rejects the level.

Entry = below that candle low.

SL = above the rejection high.

TP1 = nearest S1.

TP2 = S2.

TP3 = S3 if momentum continues.

What B and S mean
In your script, B and S are currently simple trigger markers, not a full institutional strategy. They are based on price crossing the active base line, so you should treat them as a first alert and then confirm with candle behavior, trend, and nearby levels before entering a real trade.

That means:

B is stronger when it appears above the base and near support or confluence.

S is stronger when it appears below the base and near resistance or confluence.

Ignore B/S signals that appear in the middle of a noisy range with no level context.

Best practical workflow
A practical daily routine with this script is:

Check whether price is above or below the Pivot Base at market open.

Mark where Square Root Base sits relative to Pivot Base.

Look for overlap between SQ and PV levels.

Trade only at or near those key zones.

Take partial profit at the next level, and trail the rest.

A simple rule to keep you safe is:

Trend day: use base pullbacks and aim for R1 to R2 to R3, or S1 to S2 to S3.

Range day: use outer levels like R2/R3 or S2/S3 for reversal attempts, but only with clear rejection candles. Pivot strategies commonly distinguish between breakout continuation and reversal behavior around outer levels, which is why the same script can help in both conditions.What not to do
Do not buy just because price touches S1, and do not short just because price touches R1. These levels are decision zones, not automatic entries, so you still need price confirmation such as rejection, break-retest, or momentum continuation.

Also, do not take every B/S signal blindly. The script maps structure well, but the signal logic is still simple and works best when combined with trend direction, candle confirmation, and confluence between the two methods.

Best settings
For cleaner use:

Keep showBoth = true to see confluence.

Use larger thickness for R3/S3 because outer levels are often more important reaction zones.

Keep dashboard small or normal so the chart remains readable.

Use right-side price tags on, especially for intraday work.

If you want, I can now make the next version smarter, with:

buy only on bullish candle confirmation,

sell only on bearish candle confirmation,

automatic SL below swing low / above swing high,

TP1, TP2, TP3 ladder in the dashboard.

## Source Code

````pine
//@version=6
indicator("Gann Levels v6 - Signals Dashboard Full", overlay=true, max_lines_count=500, max_labels_count=500)

//==================================================
// Inputs
//==================================================
modeSel      = input.string("Square Root", "Primary Mode", options=["Square Root", "Pivot"])
showBoth     = input.bool(false, "Show Both Modes Together")
showR        = input.bool(true, "Show Resistance Levels")
showS        = input.bool(true, "Show Support Levels")
showBase     = input.bool(true, "Show Base Lines")
showTags     = input.bool(true, "Show Right Price Tags")
showDash     = input.bool(true, "Show Dashboard")
showSignals  = input.bool(true, "Show B/S/SL/TP Signals")

extendBars   = input.int(30, "Tag Distance", minval=5, maxval=200)
dashPosIn    = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
dashFontIn   = input.string("small", "Dashboard Font Size", options=["tiny", "small", "normal", "large"])
sigFontIn    = input.string("small", "Signal Label Size", options=["tiny", "small", "normal", "large"])

// Line thickness
w1 = input.int(2, "R1 / S1 Thickness", minval=1, maxval=6)
w2 = input.int(2, "R2 / S2 Thickness", minval=1, maxval=6)
w3 = input.int(3, "R3 / S3 Thickness", minval=1, maxval=6)
wBase = input.int(2, "Base Thickness", minval=1, maxval=6)

// Colors
sqResColor   = input.color(color.rgb(185, 40, 40), "Square Root Resistance")
sqSupColor   = input.color(color.rgb(20, 120, 50), "Square Root Support")
sqBaseColor  = input.color(color.black, "Square Root Base")

pvResColor   = input.color(color.rgb(210, 110, 0), "Pivot Resistance")
pvSupColor   = input.color(color.rgb(0, 105, 150), "Pivot Support")
pvBaseColor  = input.color(color.rgb(90, 90, 90), "Pivot Base")

buyColor     = input.color(color.rgb(0, 140, 60), "Buy Label Color")
sellColor    = input.color(color.rgb(190, 30, 45), "Sell Label Color")
slColor      = input.color(color.rgb(60, 60, 60), "SL Label Color")
tpColor      = input.color(color.rgb(25, 110, 180), "TP Label Color")
tagTextCol   = input.color(color.white, "Tag Text")

//==================================================
// Helpers
//==================================================
f_fmt(v) =>
    str.tostring(v, format.mintick)

f_tag(name, price) =>
    name + "  " + f_fmt(price)

f_pos(p) =>
    p == "Top Left" ? position.top_left : p == "Bottom Right" ? position.bottom_right : p == "Bottom Left" ? position.bottom_left : position.top_right

f_size(sz) =>
    sz == "tiny" ? size.tiny : sz == "small" ? size.small : sz == "large" ? size.large : size.normal

//==================================================
// Previous completed daily values
//==================================================
prevClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
prevHigh  = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
prevLow   = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)

//==================================================
// Square Root calculations
//==================================================
root   = math.sqrt(prevClose)
sqBase = prevClose
sqR1   = math.pow(root + 0.125, 2)
sqR2   = math.pow(root + 0.250, 2)
sqR3   = math.pow(root + 0.375, 2)
sqS1   = math.pow(root - 0.125, 2)
sqS2   = math.pow(root - 0.250, 2)
sqS3   = math.pow(root - 0.375, 2)

//==================================================
// Pivot calculations
//==================================================
pp     = (prevHigh + prevLow + prevClose) / 3.0
pvBase = pp
pvR1   = 2.0 * pp - prevLow
pvS1   = 2.0 * pp - prevHigh
pvR2   = pp + (prevHigh - prevLow)
pvS2   = pp - (prevHigh - prevLow)
pvR3   = prevHigh + 2.0 * (pp - prevLow)
pvS3   = prevLow  - 2.0 * (prevHigh - pp)

//==================================================
// Display control
//==================================================
showSquare = showBoth or modeSel == "Square Root"
showPivot  = showBoth or modeSel == "Pivot"

dashFont = f_size(dashFontIn)
sigFont  = f_size(sigFontIn)

//==================================================
// Line handles
//==================================================
var line lSqBase = na
var line lSqR1 = na
var line lSqR2 = na
var line lSqR3 = na
var line lSqS1 = na
var line lSqS2 = na
var line lSqS3 = na

var line lPvBase = na
var line lPvR1 = na
var line lPvR2 = na
var line lPvR3 = na
var line lPvS1 = na
var line lPvS2 = na
var line lPvS3 = na

var label lbSqBase = na
var label lbSqR1 = na
var label lbSqR2 = na
var label lbSqR3 = na
var label lbSqS1 = na
var label lbSqS2 = na
var label lbSqS3 = na

var label lbPvBase = na
var label lbPvR1 = na
var label lbPvR2 = na
var label lbPvR3 = na
var label lbPvS1 = na
var label lbPvS2 = na
var label lbPvS3 = na

var label lbBuy = na
var label lbSell = na
var label lbSL = na
var label lbTP = na

//==================================================
// Draw levels
//==================================================
if barstate.islast
    if showSquare and showBase
        if na(lSqBase)
            lSqBase := line.new(bar_index - 1, sqBase, bar_index + 1, sqBase, xloc=xloc.bar_index, extend=extend.right, color=sqBaseColor, width=wBase, style=line.style_solid)
        else
            line.set_xy1(lSqBase, bar_index - 1, sqBase)
            line.set_xy2(lSqBase, bar_index + 1, sqBase)
            line.set_extend(lSqBase, extend.right)
            line.set_color(lSqBase, sqBaseColor)
            line.set_width(lSqBase, wBase)
    else
        if not na(lSqBase)
            line.delete(lSqBase)
            lSqBase := na

    if showSquare and showR
        if na(lSqR1)
            lSqR1 := line.new(bar_index - 1, sqR1, bar_index + 1, sqR1, xloc=xloc.bar_index, extend=extend.right, color=sqResColor, width=w1, style=line.style_dashed)
            lSqR2 := line.new(bar_index - 1, sqR2, bar_index + 1, sqR2, xloc=xloc.bar_index, extend=extend.right, color=sqResColor, width=w2, style=line.style_dashed)
            lSqR3 := line.new(bar_index - 1, sqR3, bar_index + 1, sqR3, xloc=xloc.bar_index, extend=extend.right, color=sqResColor, width=w3, style=line.style_dashed)
        else
            line.set_xy1(lSqR1, bar_index - 1, sqR1)
            line.set_xy2(lSqR1, bar_index + 1, sqR1)
            line.set_extend(lSqR1, extend.right)
            line.set_color(lSqR1, sqResColor)
            line.set_width(lSqR1, w1)
            line.set_style(lSqR1, line.style_dashed)

            line.set_xy1(lSqR2, bar_index - 1, sqR2)
            line.set_xy2(lSqR2, bar_index + 1, sqR2)
            line.set_extend(lSqR2, extend.right)
            line.set_color(lSqR2, sqResColor)
            line.set_width(lSqR2, w2)
            line.set_style(lSqR2, line.style_dashed)

            line.set_xy1(lSqR3, bar_index - 1, sqR3)
            line.set_xy2(lSqR3, bar_index + 1, sqR3)
            line.set_extend(lSqR3, extend.right)
            line.set_color(lSqR3, sqResColor)
            line.set_width(lSqR3, w3)
            line.set_style(lSqR3, line.style_dashed)
    else
        if not na(lSqR1)
            line.delete(lSqR1)
            lSqR1 := na
        if not na(lSqR2)
            line.delete(lSqR2)
            lSqR2 := na
        if not na(lSqR3)
            line.delete(lSqR3)
            lSqR3 := na

    if showSquare and showS
        if na(lSqS1)
            lSqS1 := line.new(bar_index - 1, sqS1, bar_index + 1, sqS1, xloc=xloc.bar_index, extend=extend.right, color=sqSupColor, width=w1, style=line.style_dotted)
            lSqS2 := line.new(bar_index - 1, sqS2, bar_index + 1, sqS2, xloc=xloc.bar_index, extend=extend.right, color=sqSupColor, width=w2, style=line.style_dotted)
            lSqS3 := line.new(bar_index - 1, sqS3, bar_index + 1, sqS3, xloc=xloc.bar_index, extend=extend.right, color=sqSupColor, width=w3, style=line.style_dotted)
        else
            line.set_xy1(lSqS1, bar_index - 1, sqS1)
            line.set_xy2(lSqS1, bar_index + 1, sqS1)
            line.set_extend(lSqS1, extend.right)
            line.set_color(lSqS1, sqSupColor)
            line.set_width(lSqS1, w1)
            line.set_style(lSqS1, line.style_dotted)

            line.set_xy1(lSqS2, bar_index - 1, sqS2)
            line.set_xy2(lSqS2, bar_index + 1, sqS2)
            line.set_extend(lSqS2, extend.right)
            line.set_color(lSqS2, sqSupColor)
            line.set_width(lSqS2, w2)
            line.set_style(lSqS2, line.style_dotted)

            line.set_xy1(lSqS3, bar_index - 1, sqS3)
            line.set_xy2(lSqS3, bar_index + 1, sqS3)
            line.set_extend(lSqS3, extend.right)
            line.set_color(lSqS3, sqSupColor)
            line.set_width(lSqS3, w3)
            line.set_style(lSqS3, line.style_dotted)
    else
        if not na(lSqS1)
            line.delete(lSqS1)
            lSqS1 := na
        if not na(lSqS2)
            line.delete(lSqS2)
            lSqS2 := na
        if not na(lSqS3)
            line.delete(lSqS3)
            lSqS3 := na

    if showPivot and showBase
        if na(lPvBase)
            lPvBase := line.new(bar_index - 1, pvBase, bar_index + 1, pvBase, xloc=xloc.bar_index, extend=extend.right, color=pvBaseColor, width=wBase, style=line.style_solid)
        else
            line.set_xy1(lPvBase, bar_index - 1, pvBase)
            line.set_xy2(lPvBase, bar_index + 1, pvBase)
            line.set_extend(lPvBase, extend.right)
            line.set_color(lPvBase, pvBaseColor)
            line.set_width(lPvBase, wBase)
    else
        if not na(lPvBase)
            line.delete(lPvBase)
            lPvBase := na

    if showPivot and showR
        if na(lPvR1)
            lPvR1 := line.new(bar_index - 1, pvR1, bar_index + 1, pvR1, xloc=xloc.bar_index, extend=extend.right, color=pvResColor, width=w1, style=line.style_dashed)
            lPvR2 := line.new(bar_index - 1, pvR2, bar_index + 1, pvR2, xloc=xloc.bar_index, extend=extend.right, color=pvResColor, width=w2, style=line.style_dashed)
            lPvR3 := line.new(bar_index - 1, pvR3, bar_index + 1, pvR3, xloc=xloc.bar_index, extend=extend.right, color=pvResColor, width=w3, style=line.style_dashed)
        else
            line.set_xy1(lPvR1, bar_index - 1, pvR1)
            line.set_xy2(lPvR1, bar_index + 1, pvR1)
            line.set_extend(lPvR1, extend.right)
            line.set_color(lPvR1, pvResColor)
            line.set_width(lPvR1, w1)
            line.set_style(lPvR1, line.style_dashed)

            line.set_xy1(lPvR2, bar_index - 1, pvR2)
            line.set_xy2(lPvR2, bar_index + 1, pvR2)
            line.set_extend(lPvR2, extend.right)
            line.set_color(lPvR2, pvResColor)
            line.set_width(lPvR2, w2)
            line.set_style(lPvR2, line.style_dashed)

            line.set_xy1(lPvR3, bar_index - 1, pvR3)
            line.set_xy2(lPvR3, bar_index + 1, pvR3)
            line.set_extend(lPvR3, extend.right)
            line.set_color(lPvR3, pvResColor)
            line.set_width(lPvR3, w3)
            line.set_style(lPvR3, line.style_dashed)
    else
        if not na(lPvR1)
            line.delete(lPvR1)
            lPvR1 := na
        if not na(lPvR2)
            line.delete(lPvR2)
            lPvR2 := na
        if not na(lPvR3)
            line.delete(lPvR3)
            lPvR3 := na

    if showPivot and showS
        if na(lPvS1)
            lPvS1 := line.new(bar_index - 1, pvS1, bar_index + 1, pvS1, xloc=xloc.bar_index, extend=extend.right, color=pvSupColor, width=w1, style=line.style_dotted)
            lPvS2 := line.new(bar_index - 1, pvS2, bar_index + 1, pvS2, xloc=xloc.bar_index, extend=extend.right, color=pvSupColor, width=w2, style=line.style_dotted)
            lPvS3 := line.new(bar_index - 1, pvS3, bar_index + 1, pvS3, xloc=xloc.bar_index, extend=extend.right, color=pvSupColor, width=w3, style=line.style_dotted)
        else
            line.set_xy1(lPvS1, bar_index - 1, pvS1)
            line.set_xy2(lPvS1, bar_index + 1, pvS1)
            line.set_extend(lPvS1, extend.right)
            line.set_color(lPvS1, pvSupColor)
            line.set_width(lPvS1, w1)
            line.set_style(lPvS1, line.style_dotted)

            line.set_xy1(lPvS2, bar_index - 1, pvS2)
            line.set_xy2(lPvS2, bar_index + 1, pvS2)
            line.set_extend(lPvS2, extend.right)
            line.set_color(lPvS2, pvSupColor)
            line.set_width(lPvS2, w2)
            line.set_style(lPvS2, line.style_dotted)

            line.set_xy1(lPvS3, bar_index - 1, pvS3)
            line.set_xy2(lPvS3, bar_index + 1, pvS3)
            line.set_extend(lPvS3, extend.right)
            line.set_color(lPvS3, pvSupColor)
            line.set_width(lPvS3, w3)
            line.set_style(lPvS3, line.style_dotted)
    else
        if not na(lPvS1)
            line.delete(lPvS1)
            lPvS1 := na
        if not na(lPvS2)
            line.delete(lPvS2)
            lPvS2 := na
        if not na(lPvS3)
            line.delete(lPvS3)
            lPvS3 := na

//==================================================
// Right-side price tags
//==================================================
if barstate.islast
    if showTags
        if showSquare and showBase
            if na(lbSqBase)
                lbSqBase := label.new(bar_index + extendBars, sqBase, f_tag("SQ Base", sqBase), xloc=xloc.bar_index, style=label.style_label_left, color=sqBaseColor, textcolor=tagTextCol, size=sigFont)
            else
                label.set_x(lbSqBase, bar_index + extendBars)
                label.set_y(lbSqBase, sqBase)
                label.set_text(lbSqBase, f_tag("SQ Base", sqBase))
                label.set_color(lbSqBase, sqBaseColor)
                label.set_textcolor(lbSqBase, tagTextCol)
                label.set_size(lbSqBase, sigFont)
        else
            if not na(lbSqBase)
                label.delete(lbSqBase)
                lbSqBase := na

        if showSquare and showR
            if na(lbSqR1)
                lbSqR1 := label.new(bar_index + extendBars, sqR1, f_tag("SQ R1", sqR1), xloc=xloc.bar_index, style=label.style_label_left, color=sqResColor, textcolor=tagTextCol, size=sigFont)
                lbSqR2 := label.new(bar_index + extendBars, sqR2, f_tag("SQ R2", sqR2), xloc=xloc.bar_index, style=label.style_label_left, color=sqResColor, textcolor=tagTextCol, size=sigFont)
                lbSqR3 := label.new(bar_index + extendBars, sqR3, f_tag("SQ R3", sqR3), xloc=xloc.bar_index, style=label.style_label_left, color=sqResColor, textcolor=tagTextCol, size=sigFont)
            else
                label.set_x(lbSqR1, bar_index + extendBars)
                label.set_y(lbSqR1, sqR1)
                label.set_text(lbSqR1, f_tag("SQ R1", sqR1))
                label.set_color(lbSqR1, sqResColor)
                label.set_textcolor(lbSqR1, tagTextCol)
                label.set_size(lbSqR1, sigFont)

                label.set_x(lbSqR2, bar_index + extendBars)
                label.set_y(lbSqR2, sqR2)
                label.set_text(lbSqR2, f_tag("SQ R2", sqR2))
                label.set_color(lbSqR2, sqResColor)
                label.set_textcolor(lbSqR2, tagTextCol)
                label.set_size(lbSqR2, sigFont)

                label.set_x(lbSqR3, bar_index + extendBars)
                label.set_y(lbSqR3, sqR3)
                label.set_text(lbSqR3, f_tag("SQ R3", sqR3))
                label.set_color(lbSqR3, sqResColor)
                label.set_textcolor(lbSqR3, tagTextCol)
                label.set_size(lbSqR3, sigFont)
        else
            if not na(lbSqR1)
                label.delete(lbSqR1)
                lbSqR1 := na
            if not na(lbSqR2)
                label.delete(lbSqR2)
                lbSqR2 := na
            if not na(lbSqR3)
                label.delete(lbSqR3)
                lbSqR3 := na

        if showSquare and showS
            if na(lbSqS1)
                lbSqS1 := label.new(bar_index + extendBars, sqS1, f_tag("SQ S1", sqS1), xloc=xloc.bar_index, style=label.style_label_left, color=sqSupColor, textcolor=tagTextCol, size=sigFont)
                lbSqS2 := label.new(bar_index + extendBars, sqS2, f_tag("SQ S2", sqS2), xloc=xloc.bar_index, style=label.style_label_left, color=sqSupColor, textcolor=tagTextCol, size=sigFont)
                lbSqS3 := label.new(bar_index + extendBars, sqS3, f_tag("SQ S3", sqS3), xloc=xloc.bar_index, style=label.style_label_left, color=sqSupColor, textcolor=tagTextCol, size=sigFont)
            else
                label.set_x(lbSqS1, bar_index + extendBars)
                label.set_y(lbSqS1, sqS1)
                label.set_text(lbSqS1, f_tag("SQ S1", sqS1))
                label.set_color(lbSqS1, sqSupColor)
                label.set_textcolor(lbSqS1, tagTextCol)
                label.set_size(lbSqS1, sigFont)

                label.set_x(lbSqS2, bar_index + extendBars)
                label.set_y(lbSqS2, sqS2)
                label.set_text(lbSqS2, f_tag("SQ S2", sqS2))
                label.set_color(lbSqS2, sqSupColor)
                label.set_textcolor(lbSqS2, tagTextCol)
                label.set_size(lbSqS2, sigFont)

                label.set_x(lbSqS3, bar_index + extendBars)
                label.set_y(lbSqS3, sqS3)
                label.set_text(lbSqS3, f_tag("SQ S3", sqS3))
                label.set_color(lbSqS3, sqSupColor)
                label.set_textcolor(lbSqS3, tagTextCol)
                label.set_size(lbSqS3, sigFont)
        else
            if not na(lbSqS1)
                label.delete(lbSqS1)
                lbSqS1 := na
            if not na(lbSqS2)
                label.delete(lbSqS2)
                lbSqS2 := na
            if not na(lbSqS3)
                label.delete(lbSqS3)
                lbSqS3 := na

        if showPivot and showBase
            if na(lbPvBase)
                lbPvBase := label.new(bar_index + extendBars, pvBase, f_tag("PV Base", pvBase), xloc=xloc.bar_index, style=label.style_label_left, color=pvBaseColor, textcolor=tagTextCol, size=sigFont)
            else
                label.set_x(lbPvBase, bar_index + extendBars)
                label.set_y(lbPvBase, pvBase)
                label.set_text(lbPvBase, f_tag("PV Base", pvBase))
                label.set_color(lbPvBase, pvBaseColor)
                label.set_textcolor(lbPvBase, tagTextCol)
                label.set_size(lbPvBase, sigFont)
        else
            if not na(lbPvBase)
                label.delete(lbPvBase)
                lbPvBase := na

        if showPivot and showR
            if na(lbPvR1)
                lbPvR1 := label.new(bar_index + extendBars, pvR1, f_tag("PV R1", pvR1), xloc=xloc.bar_index, style=label.style_label_left, color=pvResColor, textcolor=tagTextCol, size=sigFont)
                lbPvR2 := label.new(bar_index + extendBars, pvR2, f_tag("PV R2", pvR2), xloc=xloc.bar_index, style=label.style_label_left, color=pvResColor, textcolor=tagTextCol, size=sigFont)
                lbPvR3 := label.new(bar_index + extendBars, pvR3, f_tag("PV R3", pvR3), xloc=xloc.bar_index, style=label.style_label_left, color=pvResColor, textcolor=tagTextCol, size=sigFont)
            else
                label.set_x(lbPvR1, bar_index + extendBars)
                label.set_y(lbPvR1, pvR1)
                label.set_text(lbPvR1, f_tag("PV R1", pvR1))
                label.set_color(lbPvR1, pvResColor)
                label.set_textcolor(lbPvR1, tagTextCol)
                label.set_size(lbPvR1, sigFont)

                label.set_x(lbPvR2, bar_index + extendBars)
                label.set_y(lbPvR2, pvR2)
                label.set_text(lbPvR2, f_tag("PV R2", pvR2))
                label.set_color(lbPvR2, pvResColor)
                label.set_textcolor(lbPvR2, tagTextCol)
                label.set_size(lbPvR2, sigFont)

                label.set_x(lbPvR3, bar_index + extendBars)
                label.set_y(lbPvR3, pvR3)
                label.set_text(lbPvR3, f_tag("PV R3", pvR3))
                label.set_color(lbPvR3, pvResColor)
                label.set_textcolor(lbPvR3, tagTextCol)
                label.set_size(lbPvR3, sigFont)
        else
            if not na(lbPvR1)
                label.delete(lbPvR1)
                lbPvR1 := na
            if not na(lbPvR2)
                label.delete(lbPvR2)
                lbPvR2 := na
            if not na(lbPvR3)
                label.delete(lbPvR3)
                lbPvR3 := na

        if showPivot and showS
            if na(lbPvS1)
                lbPvS1 := label.new(bar_index + extendBars, pvS1, f_tag("PV S1", pvS1), xloc=xloc.bar_index, style=label.style_label_left, color=pvSupColor, textcolor=tagTextCol, size=sigFont)
                lbPvS2 := label.new(bar_index + extendBars, pvS2, f_tag("PV S2", pvS2), xloc=xloc.bar_index, style=label.style_label_left, color=pvSupColor, textcolor=tagTextCol, size=sigFont)
                lbPvS3 := label.new(bar_index + extendBars, pvS3, f_tag("PV S3", pvS3), xloc=xloc.bar_index, style=label.style_label_left, color=pvSupColor, textcolor=tagTextCol, size=sigFont)
            else
                label.set_x(lbPvS1, bar_index + extendBars)
                label.set_y(lbPvS1, pvS1)
                label.set_text(lbPvS1, f_tag("PV S1", pvS1))
                label.set_color(lbPvS1, pvSupColor)
                label.set_textcolor(lbPvS1, tagTextCol)
                label.set_size(lbPvS1, sigFont)

                label.set_x(lbPvS2, bar_index + extendBars)
                label.set_y(lbPvS2, pvS2)
                label.set_text(lbPvS2, f_tag("PV S2", pvS2))
                label.set_color(lbPvS2, pvSupColor)
                label.set_textcolor(lbPvS2, tagTextCol)
                label.set_size(lbPvS2, sigFont)

                label.set_x(lbPvS3, bar_index + extendBars)
                label.set_y(lbPvS3, pvS3)
                label.set_text(lbPvS3, f_tag("PV S3", pvS3))
                label.set_color(lbPvS3, pvSupColor)
                label.set_textcolor(lbPvS3, tagTextCol)
                label.set_size(lbPvS3, sigFont)
        else
            if not na(lbPvS1)
                label.delete(lbPvS1)
                lbPvS1 := na
            if not na(lbPvS2)
                label.delete(lbPvS2)
                lbPvS2 := na
            if not na(lbPvS3)
                label.delete(lbPvS3)
                lbPvS3 := na
    else
        if not na(lbSqBase)
            label.delete(lbSqBase)
            lbSqBase := na
        if not na(lbSqR1)
            label.delete(lbSqR1)
            lbSqR1 := na
        if not na(lbSqR2)
            label.delete(lbSqR2)
            lbSqR2 := na
        if not na(lbSqR3)
            label.delete(lbSqR3)
            lbSqR3 := na
        if not na(lbSqS1)
            label.delete(lbSqS1)
            lbSqS1 := na
        if not na(lbSqS2)
            label.delete(lbSqS2)
            lbSqS2 := na
        if not na(lbSqS3)
            label.delete(lbSqS3)
            lbSqS3 := na
        if not na(lbPvBase)
            label.delete(lbPvBase)
            lbPvBase := na
        if not na(lbPvR1)
            label.delete(lbPvR1)
            lbPvR1 := na
        if not na(lbPvR2)
            label.delete(lbPvR2)
            lbPvR2 := na
        if not na(lbPvR3)
            label.delete(lbPvR3)
            lbPvR3 := na
        if not na(lbPvS1)
            label.delete(lbPvS1)
            lbPvS1 := na
        if not na(lbPvS2)
            label.delete(lbPvS2)
            lbPvS2 := na
        if not na(lbPvS3)
            label.delete(lbPvS3)
            lbPvS3 := na

//==================================================
// Signal logic
//==================================================
buyCond  = (showSquare and ta.crossover(close, sqBase)) or (showPivot and ta.crossover(close, pvBase))
sellCond = (showSquare and ta.crossunder(close, sqBase)) or (showPivot and ta.crossunder(close, pvBase))

longSL  = showSquare ? sqS1 : pvS1
longTP  = showSquare ? sqR1 : pvR1
shortSL = showSquare ? sqR1 : pvR1
shortTP = showSquare ? sqS1 : pvS1

if showSignals
    if buyCond
        if not na(lbBuy)
            label.delete(lbBuy)
        if not na(lbSL)
            label.delete(lbSL)
        if not na(lbTP)
            label.delete(lbTP)
        lbBuy := label.new(bar_index, low, "B", style=label.style_label_up, color=buyColor, textcolor=color.white, size=sigFont)
        lbSL  := label.new(bar_index, longSL, "SL " + f_fmt(longSL), style=label.style_label_left, color=slColor, textcolor=color.white, size=sigFont)
        lbTP  := label.new(bar_index, longTP, "TP " + f_fmt(longTP), style=label.style_label_left, color=tpColor, textcolor=color.white, size=sigFont)

    if sellCond
        if not na(lbSell)
            label.delete(lbSell)
        if not na(lbSL)
            label.delete(lbSL)
        if not na(lbTP)
            label.delete(lbTP)
        lbSell := label.new(bar_index, high, "S", style=label.style_label_down, color=sellColor, textcolor=color.white, size=sigFont)
        lbSL   := label.new(bar_index, shortSL, "SL " + f_fmt(shortSL), style=label.style_label_left, color=slColor, textcolor=color.white, size=sigFont)
        lbTP   := label.new(bar_index, shortTP, "TP " + f_fmt(shortTP), style=label.style_label_left, color=tpColor, textcolor=color.white, size=sigFont)

//==================================================
// Dashboard
//==================================================
var table dash = table.new(f_pos(dashPosIn), 2, 13, border_width=1)

bgHead = color.rgb(235, 235, 235)
bgCell = color.rgb(250, 250, 250)
txtBlk = color.black

modeText = showBoth ? "Both" : modeSel
signalText = buyCond ? "BUY" : sellCond ? "SELL" : "WAIT"

if barstate.islast and showDash
    table.clear(dash, 0, 0, 1, 12)

    table.cell(dash, 0, 0, "Gann Dashboard", text_color=txtBlk, bgcolor=bgHead, text_size=dashFont)
    table.cell(dash, 1, 0, syminfo.ticker, text_color=txtBlk, bgcolor=bgHead, text_size=dashFont)

    table.cell(dash, 0, 1, "Mode", text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)
    table.cell(dash, 1, 1, modeText, text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)

    table.cell(dash, 0, 2, "Prev Close", text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)
    table.cell(dash, 1, 2, f_fmt(prevClose), text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)

    table.cell(dash, 0, 3, "Prev High / Low", text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)
    table.cell(dash, 1, 3, f_fmt(prevHigh) + " / " + f_fmt(prevLow), text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)

    table.cell(dash, 0, 4, "SQ R1/S1", text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)
    table.cell(dash, 1, 4, f_fmt(sqR1) + " / " + f_fmt(sqS1), text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)

    table.cell(dash, 0, 5, "SQ R2/S2", text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)
    table.cell(dash, 1, 5, f_fmt(sqR2) + " / " + f_fmt(sqS2), text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)

    table.cell(dash, 0, 6, "SQ R3/S3", text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)
    table.cell(dash, 1, 6, f_fmt(sqR3) + " / " + f_fmt(sqS3), text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)

    table.cell(dash, 0, 7, "PV R1/S1", text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)
    table.cell(dash, 1, 7, f_fmt(pvR1) + " / " + f_fmt(pvS1), text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)

    table.cell(dash, 0, 8, "PV R2/S2", text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)
    table.cell(dash, 1, 8, f_fmt(pvR2) + " / " + f_fmt(pvS2), text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)

    table.cell(dash, 0, 9, "PV R3/S3", text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)
    table.cell(dash, 1, 9, f_fmt(pvR3) + " / " + f_fmt(pvS3), text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)

    table.cell(dash, 0, 10, "Spot", text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)
    table.cell(dash, 1, 10, f_fmt(close), text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)

    table.cell(dash, 0, 11, "Signal", text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)
    table.cell(dash, 1, 11, signalText, text_color=signalText == "BUY" ? buyColor : signalText == "SELL" ? sellColor : txtBlk, bgcolor=bgCell, text_size=dashFont)

    table.cell(dash, 0, 12, "Thickness", text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)
    table.cell(dash, 1, 12, "R1/S1=" + str.tostring(w1) + " R2/S2=" + str.tostring(w2) + " R3/S3=" + str.tostring(w3), text_color=txtBlk, bgcolor=bgCell, text_size=dashFont)

if barstate.islast and not showDash
    table.clear(dash, 0, 0, 1, 12)
````
