# Crypto Risk/Reward Tool

- url: https://www.tradingview.com/script/YNCzdZwb-Crypto-Risk-Reward-Tool/
- type: indicator
- pine_id: PUB;830d6eb31cdb47079e5da503482167fc
- version: 2.0

## Description

Crypto Risk/Reward Tool
A precision risk management overlay designed for crypto traders. Automatically calculates position size, stop loss, and take profit levels based on your defined risk in USD — no manual math required.
Features:

Position size calculated dynamically using your risk amount and stop loss distance
Supports any crypto pair — from BTC to DOGE, handles all decimal formats automatically
Adjustable Risk:Reward ratio from 1:1 up to 1:10
Round-trip commission cost (0.08%) calculated and displayed on chart
Color-coded SL/TP zones with clean right-side price labels
Fully customizable label colors, text size, and background opacity
Auto Long/Short Detection — The indicator reads price position relative to the 9 EMA in real time. When price is above the 9 EMA, it automatically switches to Long mode and draws SL below entry and TP above. When price is below the 9 EMA, it switches to Short mode and flips the levels accordingly — no manual toggling needed

How to use:

Count your Stop Loss distance — Use TradingView's built-in Price Range Tool (found in the left toolbar) to measure the exact price difference between your entry and your intended stop loss level. The tool will show you the distance in points directly on the chart
Enter that value — Type the measured price difference into the Stop Loss (Price Difference) input field in the indicator settings. For example, if Price Range Tool shows 200 for BTC or 0.0076 for DOGE, enter that exact number — no rounding, no conversion needed
Set your Risk Amount ($) — Enter the maximum USD amount you are willing to lose on the trade
Choose your Risk:Reward ratio — Select from 1:1 up to 1:10
The indicator will automatically detect long/short bias using EMA(9) and instantly draw your entry, stop loss, and take profit levels on the chart



Please Note:
This tool is built purely for trade planning and risk visualization — it does not generate buy or sell signals, and should not be used as standalone trading advice. Always apply your own analysis, strategy, and judgment before entering any trade. Past performance of any setup does not guarantee future results. Trade responsibly and never risk more than you can afford to lose.


— Ayush

## Source Code

````pine
//@version=6
indicator("Crypto Risk/Reward Tool", overlay=true, max_lines_count=50, max_labels_count=20, max_boxes_count=20)

//////////////////////////////////////////////////////////////////
// ================= USER INPUTS ================================
//////////////////////////////////////////////////////////////////

riskDollars     = input.float(100,  "Risk Amount ($)",              minval=0)
slPoints        = input.float(200,  "Stop Loss (Price Difference)", minval=0)

rrRatioInput    = input.string("1:3", "Risk:Reward",
     options=["1:1","1:2","1:3","1:4","1:5","1:6","1:7","1:8","1:9","1:10"])

bgOpacity       = input.int(70,  "Background Opacity (%)", minval=0, maxval=100)
showLines       = input.bool(true, "Show SL/TP")

// ---- Label styling ----
textColor       = input.color(color.white, "Label Text Color")
labelSize       = input.string("normal",   "Label Text Size",
     options=["tiny","small","normal","large","huge"])
slLabelColor    = input.color(color.red,   "SL Label BG Color")
tpLabelColor    = input.color(color.green, "TP Label BG Color")
entryLabelColor = input.color(color.gray,  "Entry Label BG Color")

// ---- Top Centre Label Toggle ----
showTopLabels = input.bool(false, "Show Top Centre Labels", group="Top Centre Labels")
topLabelSize  = input.string("normal", "Top Label Text Size",
     options=["tiny","small","normal","large","huge"], group="Top Centre Labels")

//////////////////////////////////////////////////////////////////
// ================= RR CALCULATION =============================
//////////////////////////////////////////////////////////////////

rrRatio =
     rrRatioInput == "1:1"  ? 1.0  :
     rrRatioInput == "1:2"  ? 2.0  :
     rrRatioInput == "1:3"  ? 3.0  :
     rrRatioInput == "1:4"  ? 4.0  :
     rrRatioInput == "1:5"  ? 5.0  :
     rrRatioInput == "1:6"  ? 6.0  :
     rrRatioInput == "1:7"  ? 7.0  :
     rrRatioInput == "1:8"  ? 8.0  :
     rrRatioInput == "1:9"  ? 9.0  : 10.0

//////////////////////////////////////////////////////////////////
// ================= CRYPTO POSITION SIZE =======================
//////////////////////////////////////////////////////////////////

positionSize  = slPoints > 0 ? riskDollars / slPoints : na
entryPrice    = close
notional      = positionSize * entryPrice
commission    = notional * 0.0008
tpPoints      = slPoints * rrRatio
tpDollar      = riskDollars * rrRatio
slDollar      = riskDollars

//////////////////////////////////////////////////////////////////
// ================= ENTRY LOGIC ================================
//////////////////////////////////////////////////////////////////

isLong  = close > ta.ema(close, 9)
slPrice = isLong ? entryPrice - slPoints : entryPrice + slPoints
tpPrice = isLong ? entryPrice + tpPoints : entryPrice - tpPoints

//////////////////////////////////////////////////////////////////
// ================= PRECISION FORMATTING =======================
//////////////////////////////////////////////////////////////////

mintick  = syminfo.mintick
decimals =
     mintick >= 1.0     ? 0 :
     mintick >= 0.1     ? 1 :
     mintick >= 0.01    ? 2 :
     mintick >= 0.001   ? 3 :
     mintick >= 0.0001  ? 4 :
     mintick >= 0.00001 ? 5 : 6

priceFormat =
     decimals == 0 ? "#"       :
     decimals == 1 ? "#.0"     :
     decimals == 2 ? "#.00"    :
     decimals == 3 ? "#.000"   :
     decimals == 4 ? "#.0000"  :
     decimals == 5 ? "#.00000" : "#.000000"

//////////////////////////////////////////////////////////////////
// ================= DRAWING ====================================
//////////////////////////////////////////////////////////////////

x1 = bar_index
x2 = bar_index + 5
xR = bar_index + 6
xM = bar_index + 2

var line  entryLine   = na
var line  slLine      = na
var line  tpLine      = na
var box   slBox       = na
var box   tpBox       = na
var label entryLabel  = na
var label slLabel     = na
var label tpLabel     = na
var label topEntryLbl = na
var label topSlLbl    = na
var label topTpLbl    = na

if showLines and not na(positionSize)

    if not na(entryLine)
        line.delete(entryLine)
        line.delete(slLine)
        line.delete(tpLine)
        box.delete(slBox)
        box.delete(tpBox)
        label.delete(entryLabel)
        label.delete(slLabel)
        label.delete(tpLabel)
        label.delete(topEntryLbl)
        label.delete(topSlLbl)
        label.delete(topTpLbl)

    greenBG = color.new(color.green, 100 - bgOpacity)
    redBG   = color.new(color.red,   100 - bgOpacity)

    // ---- SIZE MAPPING INSIDE THE IF BLOCK (fixes the size bug) ----
    txtSize =
         labelSize == "tiny"  ? size.tiny  :
         labelSize == "small" ? size.small :
         labelSize == "large" ? size.large :
         labelSize == "huge"  ? size.huge  : size.normal

    topTxtSize =
         topLabelSize == "tiny"  ? size.tiny  :
         topLabelSize == "small" ? size.small :
         topLabelSize == "large" ? size.large :
         topLabelSize == "huge"  ? size.huge  : size.normal

    // ---- Lines ----
    entryLine := line.new(x1, entryPrice, x2, entryPrice,
         color=color.gray, style=line.style_dotted)
    slLine    := line.new(x1, slPrice, x2, slPrice,
         color=slLabelColor, width=2)
    tpLine    := line.new(x1, tpPrice, x2, tpPrice,
         color=tpLabelColor, width=2)

    // ---- Boxes ----
    slBox := box.new(x1, math.max(entryPrice, slPrice),
                     x2, math.min(entryPrice, slPrice),
                     bgcolor=redBG,
                     border_color=color.new(color.red, 100))
    tpBox := box.new(x1, math.max(entryPrice, tpPrice),
                     x2, math.min(entryPrice, tpPrice),
                     bgcolor=greenBG,
                     border_color=color.new(color.green, 100))

    // ------------------------------------------------------------------
    // MODE A — normal right-side labels (showTopLabels = OFF)
    // ------------------------------------------------------------------
    if not showTopLabels

        // Entry — Qty + Commission only
        entryLabel := label.new(xR, entryPrice,
             "Qty: " + str.tostring(positionSize, "#.######") +
             "  Comm: $" + str.tostring(commission, "#.00"),
             xloc=xloc.bar_index,
             style=label.style_label_left,
             textcolor=textColor, color=entryLabelColor,
             size=txtSize)

        // SL — loss amount only, no commission
        slLabel := label.new(xR, slPrice,
             "SL  -$" + str.tostring(slDollar, "#.00"),
             xloc=xloc.bar_index,
             style=isLong ? label.style_label_lower_left : label.style_label_upper_left,
             textcolor=textColor, color=slLabelColor,
             size=txtSize)

        // TP — profit in USD only
        tpLabel := label.new(xR, tpPrice,
             "TP  +$" + str.tostring(tpDollar, "#.00"),
             xloc=xloc.bar_index,
             style=isLong ? label.style_label_upper_left : label.style_label_lower_left,
             textcolor=textColor, color=tpLabelColor,
             size=txtSize)

    // ------------------------------------------------------------------
    // MODE B — top centre labels (showTopLabels = ON)
    // ------------------------------------------------------------------
    else

        // Entry — Qty + Commission only
        topEntryLbl := label.new(xM, entryPrice,
             "Qty: " + str.tostring(positionSize, "#.######") +
             "  Comm: $" + str.tostring(commission, "#.00"),
             xloc=xloc.bar_index,
             style=label.style_label_down,
             textcolor=textColor, color=entryLabelColor,
             size=topTxtSize)

        // SL — loss amount only, no commission
        topSlLbl := label.new(xM, slPrice,
             "SL  -$" + str.tostring(slDollar, "#.00"),
             xloc=xloc.bar_index,
             style=isLong ? label.style_label_up : label.style_label_down,
             textcolor=textColor, color=slLabelColor,
             size=topTxtSize)

        // TP — profit in USD only
        topTpLbl := label.new(xM, tpPrice,
             "TP  +$" + str.tostring(tpDollar, "#.00"),
             xloc=xloc.bar_index,
             style=isLong ? label.style_label_down : label.style_label_up,
             textcolor=textColor, color=tpLabelColor,
             size=topTxtSize)

plot(na)
````
