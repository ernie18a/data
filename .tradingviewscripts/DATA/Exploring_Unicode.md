<!-- tradingview-pine-id: PUB;plVY7bXmjnUhB8phGlswFi1sf7BeCSqj -->
<!-- tradingviewscripts-format: 1 -->
# Exploring Unicode

Source: https://www.tradingview.com/script/0rFQOCKf-Exploring-Unicode/

## Description

This script demonstrates how to display Unicode characters and symbols, including emoji, in Pine:
 • Part 1 displays multi-line labels on hi/lo pivots.
 • Part 2 displays price/volume bumps using small up/down arrows plotted with [plotchar()](https://www.tradingview.com/pine-script-reference/v4/#fun_plotchar).
 • Part 3 detects bounces and uses [plotshape()](https://www.tradingview.com/pine-script-reference/v4/#fun_plotshape) to mark them.
  You can use our `f_bounceFrom()` function from this part as confirmation for signals in your strategies.

Note that the labels displayed on pivots with the code in Part 1 are plotted in the past. In realtime, they would only appear where they are after 50 bars have elapsed from that point. The other plots are plotted on the bar where their conditions are detected.

You can display thousands of Unicode characters and symbols using Pine. As you can see with our script, it is very easy to do so. The challenge will often be to find the exact symbols you are looking for. Many websites exist to help you explore Unicode characters or symbols. The PineCoders [Resources page](https://www.pinecoders.com/resources/#unicode-resources) contains a section presenting a few of them.

[Duyck](https://www.tradingview.com/u/Duyck/#published-scripts) has a [Unicode font function](https://www.tradingview.com/script/Bi1gJhKa-Unicode-font-function-JD/) script containing functions to convert strings to monospaced Unicode representations. TradingView uses the Trebuchet font for most of its text, including text displayed with Pine scripts. While its numerals are monospace and will align vertically in labels text, Duyck's functions will be handy when you need to convert characters to a monospaced form, so they also align vertically in multi-line labels.

What is Unicode?
[Unicode](https://en.wikipedia.org/wiki/Unicode) is to character encoding what Wikipedia is to knowledge; it holds codes to a good proportion of the characters or symbols used by humans, past or present. In the early days of computing, environments from different manufacturers often used different character encoding schemes, making transport between them difficult. Unicode solves that challenge. It is a comprehensive encoding scheme that visionaries from Xerox and Apple came up with in the late 80's. The addition of members from the Research Libraries Group, Sun Microsystems, Microsoft, Next and Metaphor created the "Unicode working group" and later, the [Unicode Consortium](https://en.wikipedia.org/wiki/Unicode_Consortium), which continues to improve and manage the Unicode standard.

Theoretically, Unicode encodes values representing characters or glyphs—not their pictorial representations. The letters "A" or "a", or the blue heart emoji "💙" are each represented by a Unicode value. In practice, however, there are many different versions of the Latin alphabet in Unicode. That is how our low pivot label can display different representations of the letters "ITV". The exact rendition of Unicode symbols on a specific device is left to equipment manufacturers and typeface designers.

The current Unicode space is comprised of 17 planes of 65,536 characters each, which allows for more than one million code points. Planes are further divided into character blocks, which typically hold a character set corresponding to one script—or language. Emoticons are in the character block starting at U+1F600.

[Look first. Then leap.](https://www.tradingview.com/athletes/)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView

//@version=6
indicator("Exploring Unicode", overlay = true)

// Exploring Unicode
// v3, 2026.04.14

// This code's style is based on the recommendations from the Pine Script User Manual's Style guide:
//    https://www.tradingview.com/pine-script-docs/writing/style-guide/



//#region —————————— Part 1: 
// Show large blocks of text/symbols using labels on high and low pivots.
// The script draws a label `LEGS` bars back using a `label.new()` call on each bar where a new pivot is confirmed.
string txt  = ""
int    LEGS = 50
float  pHi1 = ta.pivothigh(LEGS, LEGS)
float  pLo1 = ta.pivotlow(LEGS,  LEGS)
if not na(pHi1)
    txt := "✦✪◎◉●○\n" 
    txt += "🚩📈📉🀈\n"
    txt += "𓆖𓀗𓁼𓅂𓋾𓃩𓈗\n"
    txt += "🕠🕤💰💲\n"
    txt += "⟳⟲↭⤼⥅\n"
    txt += "🚀🙈🚨🚦"
    label.new(
        bar_index - LEGS, pHi1, txt, style = label.style_none, textcolor = color.silver, textalign = text.align_left, 
        size = size.huge
    )
    label.new(bar_index - LEGS / 2, high[LEGS / 2], "🟠\n🟡\n🟢", style = label.style_none, size = size.small)
else if not na(pLo1)
    // These variations were generated using https://lingojam.com/SpecialText
    txt := "I💙TV\n"
    txt += "𝐼💙𝒯𝒱\n"
    txt += "𝕀💙𝕋𝕍\n"
    txt += "Ｉ💙ＴＶ\n"
    txt += "🅸💙🆃🆅\n"
    txt += "Ⓘ💙ⓉⓋ\n"
    txt += "𝙄💙𝙏𝙑\n"
    label.new(
        bar_index - LEGS, pLo1, txt, color = color(na), style = label.style_label_up, textcolor = color.red, 
        size = size.huge
    )
//#endregion



//#region —————————— Part 2: 
// Use `plotchar()` calls to plot mirrored characters for rising and falling bars with rising volume.
// This page is a helpful resource for finding mirrored Unicode symbols: https://www.compart.com/en/unicode/mirrored
bool volumeRising = ta.rising(volume, 2)
bool bumpUp       = ta.rising(close,  2) and volumeRising
bool bumpDn       = ta.falling(close, 2) and volumeRising
plotchar(bumpUp, "bumpUp", "↗", location.abovebar, color.lime,    size = size.tiny)
plotchar(bumpDn, "bumpDn", "↘", location.belowbar, color.fuchsia, size = size.tiny)
//#endregion



//#region —————————— Part 3: 
// Use `plotshape()` calls to display an invisible shape with emoji text on price bounces.


// @function            Checks for a "bounce" condition. The condition occurs if the current `close` value breaks above 
//                      the lowest `high` value, or below the highest `low` value, since the last change in the 
//                      specified `price` value. 
// @param price         (series float) The series to use for resetting the bounce logic. The level for the condition 
//                      resets to the current `price` value on each bar where the value changes.
// @param long          (series bool) If `true`, the function checks for a break above the lowest `high` value since 
//                      the last change in the `price` series. If `false`, it checks for a break below the highest `low`
//                      value since the last change in the series.
// @returns             (float) `true` if the "bounce" condition occurs, and `false` otherwise.
bounceFrom(series float price, series bool long) =>
    var float level  = na
    var bool  bounce = false
    if price != price[1]
        level  := price
        bounce := false
    else
        bounce := not bounce and (long ? close > level : close < level)
        level  := bounce ? na : (long ? math.min(level, high) : math.max(level, low))
    bounce


// Declare constants to set the left and right length of pivot calculations.
int LEFT_LEGS  = 20
int RIGHT_LEGS = 5
// Declare persistent variables to store the latest price values for long and short "bounce" conditions.
var float risingPivotHiPrice  = na
var float fallingPivotLoPrice = na
// Calculate a moving average for confirmation.
float ma = ta.alma(close, LEFT_LEGS * 4, 0.85, 6)
// Detect new high and low pivots.
float pHi2 = ta.pivothigh(LEFT_LEGS, RIGHT_LEGS)
float pLo2 = ta.pivotlow(LEFT_LEGS,  RIGHT_LEGS)
// Calculate conditions for updating the price series in the "bounce" calculations.
bool long  = ta.rising(ma,  RIGHT_LEGS) and not na(pHi2)
bool short = ta.falling(ma, RIGHT_LEGS) and not na(pLo2) 
// Update the `risingPivotHiPrice` value when the `long` value is `true`.
if long
    risingPivotHiPrice  := pHi2
// Update the `fallingPivotLoPrice` value when the `short` value is `true`.
else if short
    fallingPivotLoPrice := pLo2
// Get the long and short "bounce" condition values. 
bool confirmedLong  = bounceFrom(risingPivotHiPrice,  true)
bool confirmedShort = bounceFrom(fallingPivotLoPrice, false)
// Plot invisible shapes with emoji text for each long and short condition. 
plotshape(
    confirmedLong,  "confirmedLong",  location = location.belowbar, color = na, textcolor = color.green, 
    text = "👆\n\nB\no\nu\nn\nc\ne"
)
plotshape(
    confirmedShort, "confirmedShort", location = location.abovebar, color = na, textcolor = color.red, 
    text = "B\no\nu\nn\nc\ne\n👇"
)
//#endregion
````
