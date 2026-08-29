<!-- tradingview-pine-id: PUB;87567a85da394b01877e68bffa96cf59 -->
<!-- tradingviewscripts-format: 1 -->
# VSA No Supply No Demand

Source: https://www.tradingview.com/script/K9ezG4WR-VSA-No-Supply-No-Demand/

## Description

VSA No Supply & No Demand

The **VSA No Supply & No Demand** indicator is a Volume Spread Analysis (VSA) tool designed to identify potential **No Supply (NS)** and **No Demand (ND)** conditions by analyzing price direction, relative volume, candle structure, and recent price behavior.

### 🟢 No Supply (NS)

A **No Supply** signal identifies a potential reduction in selling pressure.

The indicator looks for:

* A bearish candle
* Lower volume compared with the previous two bars
* Specific wick/pin-bar structure
* Confirmation from recent price behavior

**Interpretation:**
No Supply may indicate that sellers are becoming less aggressive. When it appears near support, after a selling climax, or following a downward move, it can provide an early indication that the market may be preparing for a bullish reaction.

### 🔴 No Demand (ND)

A **No Demand** signal identifies potential weakness in buying pressure.

The indicator looks for:

* A bullish candle
* Lower volume compared with the previous two bars
* Specific wick/pin-bar structure
* Confirmation from recent price behavior

**Interpretation:**
No Demand may indicate that buyers are not showing enough strength to continue pushing price higher. When it appears near resistance, after an extended rally, or following a buying climax, it can provide an early warning of potential bearish weakness.

### 📊 VSA Logic

The indicator is designed around the relationship between **Price, Volume and Market Context**.

Typical VSA interpretation:

**Selling Climax → Stopping Volume → No Supply → Bullish Confirmation**

**Buying Climax → Distribution → No Demand → Bearish Confirmation**

### ⚙️ NSND Count

The **NSND Count** setting controls how many recent bars are evaluated when checking the price-behavior conditions surrounding an NS or ND setup.

This allows traders to adjust the sensitivity of the indicator according to their timeframe and trading style.

### 🔔 Alerts

The indicator includes separate TradingView alerts for:

* **No Supply Alert**
* **No Demand Alert**

### ⚠️ Important

NS and ND signals should **not be treated as standalone trade entries**. VSA signals are most effective when combined with:

* Support & Resistance
* Market Structure
* Trend
* Volume Climax
* Stopping Volume
* Absorption
* Breakouts
* Higher-Timeframe Context

Use the indicator as a **confirmation and market-reading tool**, not as a guaranteed buy or sell system.

---

## Source Code

````pine
//@version=6
indicator("VSA No Supply No Demand", overlay=true, max_bars_back=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NSNDcount = input.int(10, "NSND Count", minval=1, maxval=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BULL / BEAR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_Bull_or_Bear() =>
    if open > close
        "Bear"
    else if close > open
        "Bull"
    else
        ""

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LOW VOLUME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_Low_Volume() =>
    not na(volume[2]) ? volume < volume[1] and volume < volume[2] : false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PIN / WICK
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_Pins(direction) =>
    pip = syminfo.mintick
    result = false

    if direction == "Bear"
        result := high > open + pip and low < close - pip

    if direction == "Bull"
        result := high > close + pip and low < open - pip

    result

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CURRENT BAR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullOrBear = f_Bull_or_Bear()
lowVolume = f_Low_Volume()
pins = f_Pins(bullOrBear)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CLOSE CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bearCloseBelow = false
bearCloseAbove = false
bullCloseAbove = false
bullCloseBelow = false

if bar_index >= NSNDcount
    for i = 0 to NSNDcount - 1
        if bullOrBear == "Bear"
            if close[i] < low
                bearCloseBelow := true
            if close[i] > high
                bearCloseAbove := true

        if bullOrBear == "Bull"
            if close[i] > high
                bullCloseAbove := true
            if close[i] < low
                bullCloseBelow := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NO DEMAND / NO SUPPLY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
noDemand = bullOrBear == "Bull" and lowVolume and pins and not bullCloseAbove and bullCloseBelow

noSupply = bullOrBear == "Bear" and lowVolume and pins and not bearCloseBelow and bearCloseAbove

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(noDemand, title="No Demand", location=location.abovebar, color=color.red, style=shape.triangledown, text="ND", textcolor=color.white, size=size.small)

plotshape(noSupply, title="No Supply", location=location.belowbar, color=color.lime, style=shape.triangleup, text="NS", textcolor=color.white, size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(noDemand, title="No Demand Alert", message="VSA No Demand signal detected")

alertcondition(noSupply, title="No Supply Alert", message="VSA No Supply signal detected")
````
