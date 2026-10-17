# SMC+ICT Liquidity Sweep

- url: https://www.tradingview.com/script/dNUSsJuI-SMC-ICT-Liquidity-Sweep/
- type: indicator
- pine_id: PUB;1f7b45a777b946fc96bdd803035ba527
- version: 1.0

## Description

SMC+ICT Liquidity Sweep
[url=https://www.tradingview.com/u/Michael_Fx_Trader/]https://www.tradingview.com/u/Michael_Fx_Trader/[/url]
OVERVIEW
SMC+ICT Liquidity Sweep is a clean, price-action based indicator that automatically finds and marks liquidity on your chart and then highlights the exact candle where that liquidity is swept. Every liquidity level is drawn as a clearly labeled box with the text "Liquidity", and every sweep is drawn as a separate labeled box with the text "Liquidity Sweep". The goal is to give traders a clear, uncluttered, chart-ready view of where liquidity was resting and where it was taken.
The indicator works on every timeframe and every market, including Forex, Gold, Crypto, Indices, Stocks and Futures.
WHAT IS LIQUIDITY
In Smart Money Concepts (SMC) and Inner Circle Trader (ICT) style analysis, liquidity is the area where a large number of pending orders and stop losses are likely to be sitting. The two most common places are:
Buy-side liquidity: above swing highs. Stop losses of sellers and breakout buy orders rest here.
Sell-side liquidity: below swing lows. Stop losses of buyers and breakout sell orders rest here.
Price is often drawn toward these levels because they offer the orders needed for larger participants to enter or exit positions. A liquidity sweep happens when price pushes through one of these levels, takes the resting orders, and then reacts.
WHY THIS INDICATOR WAS CREATED
Marking liquidity by hand is slow, inconsistent and easy to get wrong, especially when you move between many charts and timeframes. This indicator was built to remove that manual work and to make liquidity and sweeps visible in a simple, consistent and readable way. Every level is drawn with the same style, every label is clear, and the chart stays clean so you can focus on reading price.
HOW IT WORKS
Step 1: Detecting liquidity. The script looks for confirmed swing highs and swing lows using the Swing Length setting. A swing is confirmed only after the chosen number of bars has formed on both sides of it. A confirmed swing high becomes a buy-side liquidity box placed just above the high. A confirmed swing low becomes a sell-side liquidity box placed just below the low. Each box is labeled "Liquidity".
Step 2: Extending the level. As long as price has not traded through the level, the liquidity box keeps extending to the right, showing that the liquidity is still untouched.
Step 3: Detecting the sweep. When price trades through a liquidity level, the script checks the candle according to the selected Sweep Mode.
Wick + Close Back (default): price must break the level with a wick and then close back on the original side. This is the classic liquidity grab. If price instead closes beyond the level, it is treated as a breakout and not as a sweep.
Wick Only: any wick through the level is counted as a sweep.
Step 4: Marking the sweep. When a sweep is confirmed, the liquidity box is closed at that candle and stays on the chart as history. A new box is drawn at the extreme of the sweep candle and labeled "Liquidity Sweep". For buy-side sweeps the label sits above the box, and for sell-side sweeps it sits below the box.
Step 5: Automatic sizing. The height of every box is calculated from ATR multiplied by the Box Thickness setting, so the boxes look proportionate on any market and any timeframe without manual adjustment.
Confirmed swings are not repainted. All drawing and updating is done on closed bars, so the historical chart and the live chart behave the same way.
HOW TO READ THE CHART
Liquidity box above a swing high: buy-side liquidity is resting above this level.
Liquidity box below a swing low: sell-side liquidity is resting below this level.
Liquidity box still extending to the right: the level has not been taken yet and may act as a possible target for price.
Liquidity Sweep box above price: buy-side liquidity was taken at that candle.
Liquidity Sweep box below price: sell-side liquidity was taken at that candle.
HOW TO USE IT FOR ANALYSIS
The indicator is a visual analysis tool. It is not a buy or sell signal generator. Here are common ways traders can use the information it provides.
1. Identify targets. Untouched liquidity boxes above and below price show where price may be drawn next.
2. Watch for reactions after a sweep. After a buy-side sweep, some traders look for bearish confirmation. After a sell-side sweep, some traders look for bullish confirmation.
3. Combine with confirmation. Sweeps are stronger when combined with a market structure shift, a higher timeframe bias, an order block, a fair value gap or a key session level.
4. Use multiple timeframes. Higher timeframe liquidity is generally more significant than lower timeframe liquidity. Check a higher timeframe first, then refine on a lower one.
5. Manage risk. Always use a stop loss and proper position sizing. A sweep does not guarantee a reversal.
WHAT IS SHOWN ON THE CHART AND IN THE SETTINGS PANEL
This indicator does not use a dashboard table. It keeps the chart clean and shows everything directly on the price chart.
On the chart you will see:
Liquidity boxes with the label "Liquidity".
Liquidity Sweep boxes with the label "Liquidity Sweep".
Boxes that stay extended while liquidity is untouched and stop at the candle where liquidity is taken.
In the settings panel you can control:
Swing Length: how strong a swing must be to count as liquidity.
Sweep Mode: Wick + Close Back or Wick Only.
Show Buy-side Liquidity and Show Sell-side Liquidity switches.
Maximum active liquidity levels per side and maximum stored old boxes.
ATR Length and Box Thickness.
Sweep Box Width.
Border width, box colors, border colors, text color and text size.
Custom text for the "Liquidity" and "Liquidity Sweep" labels.

ALERTS
Three alert conditions are included:
Buy-side Liquidity Sweep.
Sell-side Liquidity Sweep.
Any Liquidity Sweep.
Alerts are triggered when the candle closes and the sweep is confirmed.

SETTINGS GUIDE
Lower Swing Length (for example 5 to 10): more liquidity levels, suitable for scalping and lower timeframes.
Default Swing Length (15): balanced view for intraday analysis.
Higher Swing Length (25 and above): fewer but more significant levels, suitable for swing analysis and higher timeframes.
If the chart looks crowded, reduce the maximum active levels or increase Swing Length. If the boxes look too thin or too thick, adjust Box Thickness.

ORIGINAL SCRIPT DECLARATION

This script is an original work. The source code was written from scratch and is not copied, forked, re-used, translated or derived from any third-party script, library or open-source code. The logic, structure and design were implemented independently for this indicator.




AUTHOR VERIFICATION AND CLARIFICATION

Script Name: SMC+ICT Liquidity Sweep
Author: Michael_Fx_Trader
Publisher: Michael_Fx_Trader
Rights Holder: Michael_Fx_Trader
Language and Version: Pine Script v6
Origin: 100 percent original implementation by the author named above.




COPYRIGHT AND RIGHTS

Copyright 2026 Michael_Fx_Trader. All Rights Reserved. All rights to this source code, its logic, its design and its published version belong exclusively to Michael_Fx_Trader. Copying, re-publishing, re-selling, re-distributing or claiming authorship of this code, in whole or in part, without the written permission of the author is strictly prohibited.




DISCLAIMER

This indicator is provided for educational and analytical purposes only. It is not financial advice and does not guarantee any profit. Past behavior of price does not guarantee future results. Trading involves risk, and you are responsible for your own trading decisions.

## Source Code

````pine
// =====================================================================================================
//  SMC+ICT Liquidity Sweep
// =====================================================================================================
//
//  ORIGINAL SCRIPT DECLARATION
//  ---------------------------
//  This script is an ORIGINAL work. The source code was written from scratch and is NOT copied,
//  forked, re-used, translated or derived from any third-party script, library or open-source code.
//  The logic (swing-based liquidity zones + sweep detection + box/label rendering) is an independent
//  implementation created specifically for this indicator.
//
//  AUTHOR VERIFICATION & CLARIFICATION
//  -----------------------------------
//  Script Name      : SMC+ICT Liquidity Sweep
//  Author           : Michael_Fx_Trader
//  Publisher        : Michael_Fx_Trader
//  Rights Holder    : Michael_Fx_Trader
//  Language/Version : Pine Script(R) v6
//  Origin           : 100% original implementation by the author named above.
//
//  COPYRIGHT & RIGHTS
//  ------------------
//  (c) 2026 Michael_Fx_Trader. All Rights Reserved.
//  All rights to this source code, its logic, its design and its published version belong
//  exclusively to Michael_Fx_Trader. Copying, re-publishing, re-selling, re-distributing or
//  claiming authorship of this code, in whole or in part, without the written permission of the
//  author is strictly prohibited.
//
//  WHAT THE INDICATOR DOES
//  -----------------------
//  1) LIQUIDITY: Detects swing highs (buy-side liquidity) and swing lows (sell-side liquidity).
//     Each one is marked with a box and the text "Liquidity". The box stays extended to the right
//     until price trades through the level.
//  2) LIQUIDITY SWEEP: When price takes out a liquidity level, the liquidity box is closed at that
//     candle and a new box is drawn on the sweep candle's extreme with the text "Liquidity Sweep".
//  3) Works on every timeframe and every market (Forex, Gold, Crypto, Indices, Stocks, Futures)
//     because the box thickness is automatically scaled by ATR.
//
//  NOTES
//  -----
//  - Liquidity is confirmed after "Swing Length" bars to the right (no repainting of confirmed zones).
//  - All drawing/updating is done on confirmed (closed) bars only, so history and live behave the same.
//  - This tool is for educational and analytical purposes only. It is not financial advice and does
//    not guarantee any profit. Trading involves risk.
// =====================================================================================================

//@version=6
indicator("SMC+ICT Liquidity Sweep", shorttitle="SMC+ICT LS", overlay=true, max_boxes_count=500, max_labels_count=500)

// =====================================================================================================
// INPUTS
// =====================================================================================================
const string GRP_DET = "Liquidity Detection"
const string GRP_BOX = "Box Settings"
const string GRP_COL = "Colors & Text"

int    swingLen    = input.int(15, "Swing Length (left/right bars)", minval=2, maxval=100, group=GRP_DET, tooltip="Number of bars on each side used to confirm a swing high / swing low. Bigger value = fewer but stronger liquidity levels.")
string sweepMode   = input.string("Wick + Close Back", "Sweep Mode", options=["Wick + Close Back", "Wick Only"], group=GRP_DET, tooltip="Wick + Close Back: price must break the level with a wick and close back inside (classic liquidity grab). If price closes beyond the level, it is treated as a breakout, not a sweep.\nWick Only: any wick through the level counts as a sweep.")
bool   showHighs   = input.bool(true, "Show Buy-side Liquidity (Swing Highs)", group=GRP_DET)
bool   showLows    = input.bool(true, "Show Sell-side Liquidity (Swing Lows)", group=GRP_DET)
int    maxActive   = input.int(20, "Max Active Liquidity Levels (per side)", minval=1, maxval=100, group=GRP_DET)
int    maxHistory  = input.int(100, "Max Stored Old Boxes", minval=10, maxval=240, group=GRP_DET, tooltip="How many old (already finished) boxes are kept on the chart.")

int    atrLen      = input.int(14, "ATR Length", minval=1, group=GRP_BOX)
float  boxThick    = input.float(0.25, "Box Thickness (x ATR)", minval=0.05, step=0.05, group=GRP_BOX, tooltip="Box height is calculated automatically as ATR x this value, so it fits every market and timeframe.")
int    sweepExt    = input.int(12, "Sweep Box Width (bars)", minval=2, maxval=100, group=GRP_BOX)
int    borderW     = input.int(1, "Border Width", minval=1, maxval=4, group=GRP_BOX)

color  liqFill     = input.color(#5C1A22, "Liquidity Box Fill", group=GRP_COL)
color  liqBorder   = input.color(#FFFFFF, "Liquidity Box Border", group=GRP_COL)
color  swpFill     = input.color(#5C1A22, "Sweep Box Fill", group=GRP_COL)
color  swpBorder   = input.color(#FFFFFF, "Sweep Box Border", group=GRP_COL)
color  txtColor    = input.color(#FFFFFF, "Text Color", group=GRP_COL)
string txtSize     = input.string(size.small, "Text Size", options=[size.tiny, size.small, size.normal, size.large], group=GRP_COL)
string liqText     = input.string("Liquidity", "Liquidity Text", group=GRP_COL)
string swpText     = input.string("Liquidity Sweep", "Liquidity Sweep Text", group=GRP_COL)

// =====================================================================================================
// TYPES & STORAGE
// =====================================================================================================
type LiquidityZone
    float  price
    int    startBar
    bool   isHigh
    float  thick
    box    zone
    label  tag

var array<LiquidityZone> activeHighs = array.new<LiquidityZone>()
var array<LiquidityZone> activeLows  = array.new<LiquidityZone>()
var array<box>           oldBoxes    = array.new<box>()
var array<label>         oldLabels   = array.new<label>()

// =====================================================================================================
// HELPER FUNCTIONS
// =====================================================================================================

// Creates a clear text tag. High-side tags sit above the box, low-side tags sit below the box.
f_tag(int x, float y, string txt, bool above) =>
    label.new(x, y, txt, xloc.bar_index, yloc.price, color.new(color.white, 100), above ? label.style_label_down : label.style_label_up, txtColor, txtSize)

// Horizontal middle of a box (used to center the text).
f_mid(int leftBar, int rightBar) =>
    int(math.round((leftBar + rightBar) / 2.0))

// Keeps the number of stored old drawings under control.
f_trim_history() =>
    while oldBoxes.size() > maxHistory
        box.delete(oldBoxes.shift())
    while oldLabels.size() > maxHistory
        label.delete(oldLabels.shift())

// Checks every active liquidity level. Extends it, or closes it when price trades through it.
// Returns true when at least one real liquidity sweep happened on this bar.
f_process(array<LiquidityZone> arr, bool isHigh) =>
    bool anySweep = false
    int  i = arr.size() - 1
    while i >= 0
        LiquidityZone z = arr.get(i)
        bool touched = isHigh ? high > z.price : low < z.price
        // Always keep the liquidity box extended to the current bar
        box.set_right(z.zone, bar_index)
        label.set_x(z.tag, f_mid(z.startBar, bar_index))
        if touched
            bool closedBack = isHigh ? close < z.price : close > z.price
            bool isSweep    = sweepMode == "Wick Only" or closedBack
            if isSweep
                anySweep := true
                // Draw the Liquidity Sweep box on the extreme of the sweep candle
                float  topP = isHigh ? high + z.thick : low
                float  botP = isHigh ? high : low - z.thick
                box sb = box.new(bar_index, topP, bar_index + sweepExt, botP, border_color=swpBorder, border_width=borderW, bgcolor=swpFill)
                label sl = f_tag(bar_index + int(sweepExt / 2), isHigh ? topP : botP, swpText, isHigh)
                oldBoxes.push(sb)
                oldLabels.push(sl)
            // Liquidity level is finished (swept or broken) -> keep drawing as history
            oldBoxes.push(z.zone)
            oldLabels.push(z.tag)
            arr.remove(i)
        i -= 1
    anySweep

// =====================================================================================================
// CALCULATIONS
// =====================================================================================================
float atrV = ta.atr(atrLen)
float ph   = ta.pivothigh(high, swingLen, swingLen)
float pl   = ta.pivotlow(low, swingLen, swingLen)

bool sweptHigh = false   // buy-side liquidity swept on this bar
bool sweptLow  = false   // sell-side liquidity swept on this bar

if barstate.isconfirmed
    float thick = math.max(nz(atrV) * boxThick, syminfo.mintick * 2)
    int   x1    = bar_index - swingLen

    // ---- New buy-side liquidity (swing high) ----
    if showHighs and not na(ph)
        box b = box.new(x1, ph + thick, bar_index, ph, border_color=liqBorder, border_width=borderW, bgcolor=liqFill)
        label t = f_tag(f_mid(x1, bar_index), ph + thick, liqText, true)
        activeHighs.push(LiquidityZone.new(ph, x1, true, thick, b, t))
        if activeHighs.size() > maxActive
            LiquidityZone old = activeHighs.shift()
            box.delete(old.zone)
            label.delete(old.tag)

    // ---- New sell-side liquidity (swing low) ----
    if showLows and not na(pl)
        box b = box.new(x1, pl, bar_index, pl - thick, border_color=liqBorder, border_width=borderW, bgcolor=liqFill)
        label t = f_tag(f_mid(x1, bar_index), pl - thick, liqText, false)
        activeLows.push(LiquidityZone.new(pl, x1, false, thick, b, t))
        if activeLows.size() > maxActive
            LiquidityZone old = activeLows.shift()
            box.delete(old.zone)
            label.delete(old.tag)

    // ---- Update levels / detect sweeps ----
    sweptHigh := f_process(activeHighs, true)
    sweptLow  := f_process(activeLows, false)

    f_trim_history()

// =====================================================================================================
// ALERTS
// =====================================================================================================
alertcondition(sweptHigh, "Buy-side Liquidity Sweep", "SMC+ICT Liquidity Sweep: Buy-side liquidity (swing high) swept on {{ticker}} {{interval}}")
alertcondition(sweptLow,  "Sell-side Liquidity Sweep", "SMC+ICT Liquidity Sweep: Sell-side liquidity (swing low) swept on {{ticker}} {{interval}}")
alertcondition(sweptHigh or sweptLow, "Any Liquidity Sweep", "SMC+ICT Liquidity Sweep: Liquidity swept on {{ticker}} {{interval}}")

// =====================================================================================================
//  END OF SCRIPT  |  SMC+ICT Liquidity Sweep  |  Author & Publisher: Michael_Fx_Trader
//  (c) 2026 Michael_Fx_Trader. All Rights Reserved. Original implementation.
// =====================================================================================================
````
