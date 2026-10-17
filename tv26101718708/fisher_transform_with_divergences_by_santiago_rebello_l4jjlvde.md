# Fisher Transform with Divergences by Santiago Rebello

- url: https://www.tradingview.com/script/L4JJlvDe-Fisher-Transform-with-Divergences-by-Santiago-Rebello/
- type: indicator
- pine_id: PUB;cfb38d091abd4fe88a7dad5e43c92063
- version: 1.0

## Description

### Concept & Purpose
This indicator is a advanced volatility-normalized momentum oscillator that merges J.F. Ehlers' classic Fisher Transform formula with an automated multi-type structural divergence engine. It aims to isolate structural market turning points by tracking momentum shifts before they reflect in linear price bars.

### How It Works (Components & Logic)
To maintain complete clarity and pass library publishing guidelines, here is the technical logic:
1. **Gaussian Data Normalization:** The script samples the median price (HL2) over a user-defined lookback length. It normalizes this range to sit tightly between -0.999 and 0.999 using an index clipping function.
2. **The Fisher Transform:** It converts this normalized data into a probability density function ($IFish = 0.5 \cdot \ln(\frac{1 + v}{1 - v})$). This converts smooth, rounded momentum curves into razor-sharp peaks and valleys, removing traditional lagging signals found in standard indicators.
3. **Automated Divergence Scanning:** The script maps price structures against the Fisher peaks using global-scope pivot point arrays.

### How to Trade This Script
* **Regular Bullish Divergence (Bull Reg):** Price creates a lower low, but the Fisher Transform creates a higher low. This indicates selling pressure is structurally exhausted. Look for a long entry as Fisher hooks upwards.
* **Hidden Bullish Divergence (Bull Hid):** Price creates a higher low, but the Fisher Transform creates a lower low. This signifies trend continuation; momentum is loading up for another push higher.
* **Regular Bearish Divergence (Bear Reg):** Price marks a higher high, but the Fisher Transform creates a lower high. Look for trend exhaustion shorts.
* **Hidden Bearish Divergence (Bear Hid):** Price marks a lower high, but Fisher marks a higher high. Signifies a strong trend continuation short setup.

### Settings & Optimization Notes
* **Pivot Left/Right:** Adjust these settings to increase or decrease the structural validation filter. Higher numbers result in fewer, more reliable long-term macro divergence lines. Lower numbers are optimal for short-term scalping structures.

## Source Code

````pine
//@version=6
indicator(title="Fisher Transform with Divergences", shorttitle="Fisher Div", format=format.price, precision=2, max_lines_count=500, max_labels_count=500)

// Inputs
len        = input.int(9, minval=1, title="Length")
pivL       = input.int(5, minval=1, title="Pivot Left")
pivR       = input.int(5, minval=1, title="Pivot Right")
showReg    = input.bool(true, title="Show Regular Divergence")
showHidden = input.bool(true, title="Show Hidden Divergence")

// Fisher Transform
high_ = ta.highest(hl2, len)
low_  = ta.lowest(hl2, len)

round_(val) => val > 0.99 ? 0.999 : val < -0.99 ? -0.999 : val

value = 0.0
value := round_(0.66 * ((hl2 - low_) / math.max(high_ - low_, syminfo.mintick) - 0.5) + 0.67 * nz(value[1]))

fish1 = 0.0
fish1 := 0.5 * math.log((1 + value) / (1 - value)) + 0.5 * nz(fish1[1])
fish2 = fish1[1]

// Plots
hline(1.5, "1.5", color=#E91E63)
hline(0.75, "0.75", color=#787B86)
hline(0, "0", color=#E91E63)
hline(-0.75, "-0.75", color=#787B86)
hline(-1.5, "-1.5", color=#E91E63)

plot(fish1, color=#2962FF, title="Fisher")
plot(fish2, color=#FF6D00, title="Trigger")

// Pivot detection
plPrice = ta.pivotlow(low, pivL, pivR)
phPrice = ta.pivothigh(high, pivL, pivR)
plFish  = ta.pivotlow(fish1, pivL, pivR)
phFish  = ta.pivothigh(fish1, pivL, pivR)

// Previous pivots
var float prevPriceLow = na
var float prevFishLow  = na
var int   prevLowBar   = na

var float prevPriceHigh = na
var float prevFishHigh  = na
var int   prevHighBar   = na

// Bullish divergences
if not na(plPrice) and not na(plFish)
    curBar   = bar_index - pivR
    curPrice = plPrice
    curFish  = plFish

    if not na(prevPriceLow) and not na(prevFishLow)
        bullReg    = curPrice < prevPriceLow and curFish > prevFishLow
        bullHidden = curPrice > prevPriceLow and curFish < prevFishLow

        if showReg and bullReg
            line.new(prevLowBar, prevFishLow, curBar, curFish, xloc=xloc.bar_index, color=color.lime, width=2)
            label.new(curBar, curFish, "Bull Reg", xloc=xloc.bar_index, style=label.style_label_up, textcolor=color.white, color=color.lime)

        if showHidden and bullHidden
            line.new(prevLowBar, prevFishLow, curBar, curFish, xloc=xloc.bar_index, color=color.teal, width=2)
            label.new(curBar, curFish, "Bull Hid", xloc=xloc.bar_index, style=label.style_label_up, textcolor=color.white, color=color.teal)

    prevPriceLow := curPrice
    prevFishLow  := curFish
    prevLowBar   := curBar

// Bearish divergences
if not na(phPrice) and not na(phFish)
    curBar   = bar_index - pivR
    curPrice = phPrice
    curFish  = phFish

    if not na(prevPriceHigh) and not na(prevFishHigh)
        bearReg    = curPrice > prevPriceHigh and curFish < prevFishHigh
        bearHidden = curPrice < prevPriceHigh and curFish > prevFishHigh

        if showReg and bearReg
            line.new(prevHighBar, prevFishHigh, curBar, curFish, xloc=xloc.bar_index, color=color.red, width=2)
            label.new(curBar, curFish, "Bear Reg", xloc=xloc.bar_index, style=label.style_label_down, textcolor=color.white, color=color.red)

        if showHidden and bearHidden
            line.new(prevHighBar, prevFishHigh, curBar, curFish, xloc=xloc.bar_index, color=color.orange, width=2)
            label.new(curBar, curFish, "Bear Hid", xloc=xloc.bar_index, style=label.style_label_down, textcolor=color.white, color=color.orange)

    prevPriceHigh := curPrice
    prevFishHigh  := curFish
    prevHighBar   := curBar
````
