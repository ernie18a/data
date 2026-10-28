# Stan Weinstein's Stag Analysis

- url: https://www.tradingview.com/script/jSeMUbq8-Stan-Weinstein-s-Stag-Analysis/
- type: indicator
- pine_id: PUB;50d3dc7f94814c9f95f40d24c3b85c64
- version: 1.0

## Description

Here is the complete translation of the terminology and the color-coded language of the system, explained in clear, actionable terms.

---

### **Part 1: The Color Codes (Your Visual Dashboard)**

The colors on your chart are not decorative; they are strict commands dictating your posture toward the market. 

**The Dominant Trend Line (The Moving Average)**
* **Yellow (Stage 1 - Accumulation):** The market is moving sideways. It is asleep. **Command:** Observe. Do not deploy capital. 
* **Green / Lime (Stage 2 - Markup):** The asset is structurally compounding in value. **Command:** Deploy capital and hold. This is where wealth is generated.
* **Orange (Stage 3 - Distribution):** The momentum is dying. The asset is becoming volatile and heavy. **Command:** Play defense. Take partial profits, tighten your safety net, and do not buy more.
* **Red (Stage 4 - Markdown):** The asset is in a structural collapse. **Command:** Absolute avoidance. Keep your capital in cash.

**The Action Signals (Shapes and Labels)**
* **Green "S2 PRO" Label (The Master Buy Signal):** This appears below the price when everything aligns—the stock is entering Green (Stage 2), institutional volume is exploding, *and* the broader market is healthy. **Command:** Execute your purchase.
* **Aqua / Light Blue Circles (The Survival Line):** This dotted line only appears when you are in a Green (Stage 2) trend. It climbs upward as the stock climbs. **Command:** This is your hard exit. If the price closes below these circles, the math says the trend is over. Sell immediately.
* **Blue Triangle Pointing Up (Wyckoff Spring):** Appears during the Yellow phase. It signifies that big institutions are briefly pushing the price down to scare people into selling, so they can buy cheaply. **Command:** An early warning that a Green phase might be coming soon.
* **Fuchsia / Pink Triangle Pointing Down (Wyckoff Upthrust):** Appears during the Orange phase. Big institutions are pushing the price up to create fake hype, tricking retail traders into buying while the institutions secretly sell. **Command:** A massive warning that a Red crash is likely imminent.

---

### **Part 2: The Customization Terms (Your Control Panel)**

When you open the settings of the indicator, you are calibrating the mathematics of the system to suit your specific trading style. 

#### **1. Macro Structure (Weinstein)**
This section defines how the system identifies the "Seasons" (Yellow, Green, Orange, Red).

* **WMA Length (Base):** *(Default: 30)*. This is the heartbeat of the system. It calculates the average price over the last 30 periods. By taking an average of 30 bars, it smooths out the daily chaos and reveals the true, underlying path of the money.
* **Slope Lookback (Bars):** *(Default: 4)*. To know if a car is turning, you have to watch it for more than a split second. This setting tells the system to look back 4 bars to prove the trend line is actually bending up or down, preventing you from getting faked out by a single weird day.
* **Flat/Equilibrium Threshold (%):** *(Default: 0.5)*. This defines "sideways." If the trend line is moving up or down by less than 0.5%, the system considers it flat (Yellow Stage 1 or Orange Stage 3). If you make this number higher, the system demands a much steeper climb before it will turn the line Green.

#### **2. Volume & Micro-Structure (Wyckoff)**
This section detects the footprints of massive institutional money (the "Whales").

* **Institutional Volume Multiplier:** *(Default: 1.5)*. A true breakout requires explosive money. This setting tells the script: *"Do not give me the 'S2 PRO' buy signal unless today's trading volume is at least 1.5 times (150%) bigger than the normal average."* * **Liquidity Sweep Lookback:** *(Default: 10)*. To find those Blue and Pink triangles (the institutional traps), the system needs to know what the recent high or low was. A setting of 10 means it will look at the last 10 bars to see if the big players just swept the price past recent levels to trigger people's stop-losses.

#### **3. Breadth Alignment (Dow Theory)**
This section ensures you are not swimming against a massive economic tide.

* **Require Nifty 50 Uptrend?** and **Macro Index:** If this box is checked, the system will secretly look at the Nifty 50. If the Nifty 50 is crashing, the system will **refuse** to give you a Green "S2 PRO" buy signal on your individual stock. It protects you from buying a good stock on a day the whole market is collapsing.
* **Require Sector Uptrend?** and **Sector Index:** Similar to above, but specific to an industry. If you are looking at an IT stock, you set the index to `NSE:NIFTYIT`. The system will ensure the entire IT sector is healthy before letting you buy that specific IT company. 

#### **4. Risk Management (Survival)**
This section mathematically calculates exactly where your safety net (the Aqua Circles) should be.

* **ATR Length:** *(Default: 14)*. ATR stands for Average True Range. It measures the stock's "breathing pattern"—how far it typically swings up and down over the last 14 bars. A highly volatile stock takes deep breaths; a slow stock takes shallow breaths.
* **ATR Trailing Stop Multiplier:** *(Default: 2.0)*. This setting multiplies that breathing pattern. If the stock normally swings ₹10 a day (its ATR), a multiplier of 2.0 places your Aqua Circle safety net exactly ₹20 below the current price. It gives the stock enough room to breathe and wiggle naturally, but forces you to sell if it violently drops further than its normal behavior dictates.

## Source Code

````pine
//@version=5
indicator("Stan Weinstein's Stag Analysis", overlay=true, max_labels_count=500)

// =========================================================================
// 1. SYSTEM PARAMETERS & CALIBRATION
// =========================================================================

grp_ma   = "1. Macro Structure (Weinstein)"
lenWMA   = input.int(30, title="WMA Length (Base)", group=grp_ma)
rocLen   = input.int(4,  title="Slope Lookback (Bars)", minval=1, group=grp_ma)
flatPct  = input.float(0.5, title="Flat/Equilibrium Threshold (%)", step=0.1, group=grp_ma)

grp_vol  = "2. Volume & Micro-Structure (Wyckoff)"
volMult  = input.float(1.5, title="Institutional Volume Multiplier", group=grp_vol)
lookback = input.int(10, title="Liquidity Sweep Lookback", tooltip="Bars used to identify Wyckoff Springs and Upthrusts", group=grp_vol)

grp_dow  = "3. Breadth Alignment (Dow Theory)"
useNifty = input.bool(true, title="Require Nifty 50 Uptrend?", group=grp_dow)
niftyIdx = input.symbol("NSE:NIFTY", title="Macro Index", group=grp_dow)
useSec   = input.bool(true, title="Require Sector Uptrend?", group=grp_dow)
secIdx   = input.symbol("NSE:BANKNIFTY", title="Sector Index", group=grp_dow)

grp_risk = "4. Risk Management (Survival)"
atrLen   = input.int(14, title="ATR Length", group=grp_risk)
atrMult  = input.float(2.0, title="ATR Trailing Stop Multiplier", group=grp_risk)


// =========================================================================
// 2. CORE MATHEMATICS (PRICE, VOLUME, ATR)
// =========================================================================

// Asset WMA and Slope
wma30 = ta.wma(close, lenWMA)
wma_roc = (wma30 - wma30[rocLen]) / wma30[rocLen] * 100

// Institutional Volume Detection
avgVol = ta.sma(volume, lenWMA)
isVolSpike = volume > (avgVol * volMult)

// Slope Conditions
isRising  = wma_roc > flatPct
isFalling = wma_roc < -flatPct
isFlat    = math.abs(wma_roc) <= flatPct
priceAbove = close > wma30
priceBelow = close < wma30


// =========================================================================
// 3. THE STATE MACHINE (WEINSTEIN'S 4 STAGES)
// =========================================================================

var int stage = 1 

if stage == 1 
    if isRising and priceAbove
        stage := 2
    else if isFalling and priceBelow
        stage := 4
else if stage == 2 
    if isFlat or (isFalling and priceAbove)
        stage := 3
    else if isFalling and priceBelow
        stage := 4
else if stage == 3 
    if isFalling and priceBelow
        stage := 4
    else if isRising and priceAbove
        stage := 2 
else if stage == 4 
    if isFlat or (isRising and priceBelow)
        stage := 1
    else if isRising and priceAbove
        stage := 2 

// Assign Stage Colors
color stageColor = stage == 1 ? color.new(color.yellow, 0) : 
                   stage == 2 ? color.new(color.lime, 0) : 
                   stage == 3 ? color.new(color.orange, 0) : 
                   color.new(color.red, 0)

plot(wma30, title="Institutional WMA", color=stageColor, linewidth=3)
barcolor(stageColor)


// =========================================================================
// 4. DOW THEORY BREADTH FILTER (NIFTY & SECTOR)
// =========================================================================

// Function to calculate WMA slope for external symbols safely
f_get_bullish_state(sym, len, rocLength, threshold) =>
    symClose = request.security(sym, timeframe.period, close)
    symWma = ta.wma(symClose, len)
    symRoc = (symWma - symWma[rocLength]) / symWma[rocLength] * 100
    symRoc > threshold

niftyBullish = useNifty ? f_get_bullish_state(niftyIdx, lenWMA, rocLen, flatPct) : true
secBullish   = useSec   ? f_get_bullish_state(secIdx, lenWMA, rocLen, flatPct) : true
breadthConfirmed = niftyBullish and secBullish


// =========================================================================
// 5. WYCKOFF MICRO-STRUCTURE (SPRINGS & UPTHRUSTS)
// =========================================================================

// Spring: Sweeps a recent low but closes back above it (Only valid in Stage 1 Accumulation)
recentLow = ta.lowest(low[1], lookback)
isSpring = (low < recentLow) and (close > recentLow) and (stage == 1)
plotshape(isSpring, title="Wyckoff Spring", style=shape.triangleup, location=location.belowbar, color=color.blue, size=size.small, text="SPRING", textcolor=color.blue)

// Upthrust: Sweeps a recent high but closes back below it (Only valid in Stage 3 Distribution)
recentHigh = ta.highest(high[1], lookback)
isUpthrust = (high > recentHigh) and (close < recentHigh) and (stage == 3)
plotshape(isUpthrust, title="Wyckoff Upthrust", style=shape.triangledown, location=location.abovebar, color=color.fuchsia, size=size.small, text="UPTHRUST", textcolor=color.fuchsia)


// =========================================================================
// 6. CAPITAL DEPLOYMENT & RISK MANAGEMENT
// =========================================================================

// The Pro S2 Breakout: Transitioning to Stage 2 + Volume + Sector/Nifty Confirmation
enteringStage2 = stage == 2 and stage[1] != 2
validBreakout = enteringStage2 and isVolSpike and breadthConfirmed
plotshape(validBreakout, title="Stage 2 Pro Breakout", style=shape.labelup, location=location.belowbar, color=color.lime, size=size.small, text="S2\nPRO", textcolor=color.white)

// The Survival Line: Volatility Adjusted Trailing Stop (Active only in Stage 2)
atr = ta.atr(atrLen)
var float trailStop = na

if stage == 2
    stopLevel = close - (atr * atrMult)
    trailStop := na(trailStop) ? stopLevel : math.max(trailStop, stopLevel)
else
    trailStop := na // System resets the risk line when capital is no longer compounding

plot(stage == 2 ? trailStop : na, title="S2 Trailing Stop", color=color.new(color.aqua, 0), style=plot.style_circles, linewidth=2)
````
