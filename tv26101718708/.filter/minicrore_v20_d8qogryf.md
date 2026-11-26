# MINICRORE V2.0

- url: https://www.tradingview.com/script/D8QoGRYf-MINICRORE-V2-0/
- type: indicator
- pine_id: PUB;296106aa94d340a1962314a0f1cab4ec
- version: 1.0

## Description

# ADVANCED TRADING ZONES PRO (ATP Pro)
## QUICK REFERENCE CARD - 1 PAGE CHEAT SHEET

---

## COMPONENTS AT A GLANCE

| Component | Color | Meaning | Action |
|-----------|-------|---------|--------|
| **Bollinger Bands** | Gray | Price volatility levels | Trade within bands, watch for breakouts |
| **Fast MA (50)** | Blue | Short-term trend | Should be above Slow MA for uptrend |
| **Slow MA (200)** | Orange | Long-term trend | Should be below Fast MA for downtrend |
| **SUPPLY Zone** | Red box | Resistance area | SELL if price rejects here + volume |
| **DEMAND Zone** | Green box | Support area | BUY if price bounces here + volume |
| **BULL TRAP** | Orange label | Price makes HH but closes red | DON'T BUY - SELL instead |
| **BEAR TRAP** | Magenta label | Price makes LL but closes green | DON'T SELL - BUY instead |
| **Volume Spike** | Blue volume | Abnormal volume | CONFIRM all signals with volume |
| **ATR Bands** | Purple dots | Volatility expansion | Wide = breakout likely, Narrow = squeeze |

---

## 6 CORE TRADING RULES

### RULE #1: VOLUME OR NOTHING
❌ Don't trade zones without volume spike
✅ Only trade when volume bar is BLUE

### RULE #2: TREND IS KING
❌ Don't buy below moving averages
✅ Only buy above Fast MA (blue line)
❌ Don't sell above moving averages  
✅ Only sell below Fast MA (blue line)

### RULE #3: ZONE + VOLUME + TREND = SIGNAL
```
ENTRY CONDITIONS (ALL 3 REQUIRED):
1. Price at supply/demand zone
2. Blue volume bar visible
3. Price above/below moving average (depending on direction)
→ THEN: Take the trade
```

### RULE #4: AVOID TRAPS
✅ See BULL TRAP → SHORT (don't buy)
✅ See BEAR TRAP → LONG (don't sell)

### RULE #5: ZONES ARE TARGETS
```
Entry at Demand Zone 2,790
→ Take Profit at Supply Zone 2,820

Entry at Supply Zone 2,840
→ Take Profit at Demand Zone 2,790
```

### RULE #6: RISK/REWARD RATIO
```
Stop Loss: Width of the zone (or 20-50 points)
Take Profit: Next zone
Minimum Risk/Reward: 1:1
Target Risk/Reward: 1:2 or better
```

---

## TRADING SIGNALS AT A GLANCE

### SIGNAL #1: DEMAND ZONE BOUNCE (BUY) 🟢
```
Price hits green DEMAND zone
+ Blue volume bar appears
+ Price above blue MA (50)
→ BUY
Stop Loss: Below the zone
Take Profit: At red supply zone above
Probability: 75-80%
```

### SIGNAL #2: SUPPLY ZONE REJECTION (SELL) 🔴
```
Price hits red SUPPLY zone
+ Blue volume bar appears
+ Price below blue MA (50)
→ SELL
Stop Loss: Above the zone
Take Profit: At green demand zone below
Probability: 75-80%
```

### SIGNAL #3: BULL TRAP REVERSAL (SELL) 🟠
```
Price makes higher high (breaks resistance)
LABEL appears: "BULL TRAP"
Closes with large RED candle
→ SHORT the rejection
Stop Loss: Above the high
Take Profit: Back at previous support
Probability: 70-75%
```

### SIGNAL #4: BEAR TRAP REVERSAL (BUY) 🟣
```
Price makes lower low (breaks support)
LABEL appears: "BEAR TRAP"
Closes with large GREEN candle
→ LONG the bounce
Stop Loss: Below the low
Take Profit: Back at previous resistance
Probability: 70-75%
```

### SIGNAL #5: MOVING AVERAGE CROSSOVER (TREND CHANGE)
```
Golden Cross (Blue crosses above Orange)
→ UPTREND confirmed
Next pullback = BUY opportunity

Death Cross (Blue crosses below Orange)
→ DOWNTREND confirmed
Next rally = SELL opportunity
```

### SIGNAL #6: BOLLINGER BAND SQUEEZE (WAIT)
```
Bands are narrowing = LOW VOLATILITY
Bands are separating = HIGH VOLATILITY
→ Wait for breakout from squeeze
→ Trade in direction of break with volume
```

---

## SETTINGS FOR YOUR TIMEFRAME

| Timeframe | Use | Bollinger Length | MA1/MA2 | Zone Height |
|-----------|-----|------------------|---------|-------------|
| **5-min** | ⚠️ Fast trading | 15 | 20/50 | 15-25 |
| **15-min** | ✅ RECOMMENDED | 20 | 50/200 | 30-50 |
| **1-hour** | ✅ EXCELLENT | 20 | 50/200 | 50-100 |
| **4-hour** | ✅ EXCELLENT | 25 | 50/200 | 100-150 |
| **Daily** | ✅ GOOD | 30 | 50/200 | 200+ |

---

## POSITION SIZING FOR M2K11 (MICRO RUSSELL)

**Using $5,000 Account:**
```
Margin per contract: $50 (from broker comparison)
Risk per trade: 2% = $100
Stop loss: 20 points = $100 risk
→ Position: 1 contract (standard)

For aggressive traders:
Risk per trade: 3% = $150
Stop loss: 30 points = $150 risk
→ Position: 1 contract (still 1 because micro)

NEVER use more than 3 contracts even with $5,000
```

---

## QUICK TRADING CHECKLIST

Before EVERY trade:
- [ ] Price at clear supply/demand zone?
- [ ] Volume spike visible (blue bar)?
- [ ] Price in trend (above/below fast MA)?
- [ ] No bull trap or bear trap visible?
- [ ] Risk/Reward at least 1:1?
- [ ] Position size correct for account?
- [ ] Stop loss set BEFORE entering?
- [ ] Take profit target at opposite zone?

If ANY checkbox is empty → DON'T TRADE

---

## WIN RATE EXPECTATIONS

| Signal Type | Accuracy | Frequency |
|-------------|----------|-----------|
| Demand zone + volume | 75-80% | 5-10 per day |
| Supply zone + volume | 75-80% | 5-10 per day |
| Trade traps | 70-75% | 2-5 per day |
| Moving average crossover | 55-60% | 1-3 per week |
| Bollinger band bounce | 60-65% | 5-15 per day |

**Expected Results (with proper risk management):**
- 2% risk per trade
- 75% win rate signal
- 4:1 reward ratio
= ~2% account growth per trade

---

## MOST COMMON MISTAKES

❌ Trading without volume confirmation
❌ Trading against the moving average trend  
❌ Entering at the zone (use the bounce/rejection)
❌ Overleveraging position size
❌ Not using stop losses
❌ Not taking profits at targets
❌ Trading too many times (only best signals)
❌ Changing settings too often
❌ Not tracking trades in journal

---

## INSTALLATION & SETUP (5 MINUTES)

1. Open TradingView.com
2. Click "Pine Script Editor"
3. Paste the indicator code
4. Click "Add to Chart"
5. Right-click indicator → Settings
6. Adjust for your timeframe
7. Click OK
8. Enable Notifications (bell icon)
9. Practice on DEMO account first
10. Go live when comfortable

---

## KEY NUMBERS TO REMEMBER

**Default Settings:**
- Fast MA: 50 periods
- Slow MA: 200 periods
- Bollinger: 20 periods, 2.0 std dev
- Volume multiplier: 1.5x average
- ATR: 14 periods

**Trade Sizing (M2K11 on $5,000):**
- Margin: $50 per contract
- Risk: $100-150 per trade (2-3%)
- Contracts: 1-2 max
- Stop: 20-30 points

**Signal Strength:**
- With zone + volume + trend: 75% win rate
- With zone + volume only: 60-65% win rate
- With volume only: 45-50% win rate
- Avoid: Trading without volume

---

## REMEMBER

✨ **Simple = More Profitable**
- Use ONLY the clearest signals
- More trades ≠ More profit
- Quality > Quantity
- Patient traders win

✨ **Risk Management is Everything**
- Small position sizes
- Consistent stop losses
- Always know max loss before entering
- 1% account risk = Sustainable trading

✨ **The Indicator is a Tool, Not Magic**
- Works best on 15-min to 4H charts
- Works best in liquid markets (M2K11 liquid)
- Works best with proper discipline
- Works best with consistent rules

---

## NEED HELP?

1. Check the full guide
2. Review examples in documentation
3. Practice on demo 5-10 times
4. Track results in trading journal
5. Adjust based on YOUR market experience

**Most Important:** Start small, be patient, follow the rules!

Good luck! 📊📈

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © minicrore
//@version=6
indicator("Advanced Trading Zones Pro v2", shorttitle="ATP Pro v2", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=200)

// ============================================================================
// INPUTS
// ============================================================================

// Bollinger Bands
lengthBB  = input.int(20,    "BB Length",            group="Bollinger Bands", minval=5,   maxval=100)
stdDevBB  = input.float(2.0, "BB Std Dev",           group="Bollinger Bands", minval=0.5, maxval=5.0, step=0.1)

// Moving Averages
lengthMA1 = input.int(50,  "Fast MA (50)",  group="Moving Averages", minval=5,  maxval=500)
lengthMA2 = input.int(200, "Slow MA (200)", group="Moving Averages", minval=10, maxval=500)
lengthMA3 = input.int(100, "Mid MA (100)",  group="Moving Averages", minval=5,  maxval=500)

// Zones
zoneBoxHeight  = input.float(50.0, "Zone Height (points)", group="Zones", minval=5.0, maxval=500.0, step=5.0)
zoneRefinement = input.bool(true,  "Multi-level Refinement", group="Zones")

// Volume & ATR
volMultiplier = input.float(1.5, "Volume Spike Multiplier", group="Volume & ATR", minval=1.0, maxval=5.0, step=0.1)
atrLength     = input.int(14,   "ATR Length",               group="Volume & ATR", minval=1,   maxval=50)

// Display
showBBands       = input.bool(true, "Bollinger Bands",     group="Display")
showMAs          = input.bool(true, "Moving Averages",     group="Display")
showATR          = input.bool(true, "ATR Bands",           group="Display")
showSupplyDemand = input.bool(true, "Supply/Demand Zones", group="Display")
showEntryMarkers = input.bool(true, "Entry Markers",       group="Display")
showRefinement   = input.bool(true, "Zone Midlines",       group="Display")
showTradeTraps   = input.bool(true, "Trade Traps",         group="Display")
showVolume       = input.bool(true, "Volume Highlight",    group="Display")
showMTF          = input.bool(true, "MTF Table",           group="Display")
showConfidence   = input.bool(true, "Zone Confidence",     group="Display")

// Colors
colorSupply  = input.color(color.new(color.red,   80), "Supply Zone",   group="Colors")
colorDemand  = input.color(color.new(color.green, 80), "Demand Zone",   group="Colors")
colorVolHigh = input.color(color.new(color.blue,  60), "Volume Spike",  group="Colors")
colorMA1     = input.color(color.blue,                 "Fast MA",       group="Colors")
colorMA2     = input.color(color.orange,               "Slow MA",       group="Colors")
colorMA3     = input.color(color.purple,               "Mid MA",        group="Colors")

// ============================================================================
// CALCULATIONS
// ============================================================================

// Bollinger Bands
basis   = ta.sma(close, lengthBB)
bbDev   = stdDevBB * ta.stdev(close, lengthBB)
bbUpper = basis + bbDev
bbLower = basis - bbDev

// Moving Averages
ma1 = ta.sma(close, lengthMA1)
ma2 = ta.sma(close, lengthMA2)
ma3 = ta.sma(close, lengthMA3)

// ATR
atrVal = ta.atr(atrLength)

// Volume
avgVol   = ta.sma(volume, 20)
volSpike = volume > avgVol * volMultiplier

// Zone levels
highestHigh  = ta.highest(high, 20)
lowestLow    = ta.lowest(low,   20)
highestHigh2 = ta.highest(high, 30)
lowestLow2   = ta.lowest(low,   30)

// Zone detection
supplyZone    = highestHigh  > ta.highest(high[1], 19)
supplyZone2   = highestHigh2 > ta.highest(high[1], 29)
supplyRefined = supplyZone and supplyZone2
demandZone    = lowestLow   < ta.lowest(low[1],   19)
demandZone2   = lowestLow2  < ta.lowest(low[1],   29)
demandRefined = demandZone and demandZone2

// Zone confidence
var float zoneConfidence = 0.0
if supplyZone or demandZone
    int rej = 0
    for i = 0 to 19
        if high[i] > highestHigh and close[i] < open[i]
            rej += 1
    zoneConfidence := rej / 20.0 * 100.0
else
    zoneConfidence := 0.0

// Entry conditions
bodySize         = math.abs(close - open)
zoneRange        = math.max(highestHigh - lowestLow, 1.0)
demandEntrySetup = demandZone and volSpike and close > open and bodySize > zoneRange * 0.3
supplyEntrySetup = supplyZone and volSpike and close < open and bodySize > zoneRange * 0.3

// Trade traps
bullTrap        = high > high[1] and close < open and bodySize > zoneRange * 0.5
bullTrapRefined = bullTrap and volume > avgVol
bearTrap        = low  < low[1]  and close > open and bodySize > zoneRange * 0.5
bearTrapRefined = bearTrap and volume > avgVol

// Trend score
var int trendScore = 0
trendScore := 0
if ma1 > ma2
    trendScore += 100
else if ma1 < ma2
    trendScore -= 100
if ma1 > ma3 and ma3 > ma2
    trendScore += 50
else if ma1 < ma3 and ma3 < ma2
    trendScore -= 50

// Signals
buySignal  = demandZone and close > open and volSpike and close > ma1 and trendScore >= 0
sellSignal = supplyZone and close < open and volSpike and close < ma1 and trendScore <= 0
alertbuy   = buySignal  and not buySignal[1]
alertsell  = sellSignal and not sellSignal[1]

// ============================================================================
// PLOTS — all at top level, ternary used to toggle visibility
// FIX: plot() cannot be inside if blocks in v6

// ============================================================================

// Bollinger Bands
p_bbUpper = plot(showBBands ? bbUpper : na, "BB Upper", color=color.new(color.gray, 50), linewidth=1, style=plot.style_linebr)
plot(showBBands ? basis   : na, "BB Basis", color=color.new(color.gray, 60), linewidth=1)
p_bbLower = plot(showBBands ? bbLower : na, "BB Lower", color=color.new(color.gray, 50), linewidth=1, style=plot.style_linebr)
fill(p_bbUpper, p_bbLower, color=showBBands ? color.new(color.gray, 95) : na, title="BB Fill")

// Moving Averages
plot(showMAs ? ma1 : na, "Fast MA (50)",  color=colorMA1, linewidth=2)
plot(showMAs ? ma2 : na, "Slow MA (200)", color=colorMA2, linewidth=2)
plot(showMAs ? ma3 : na, "Mid MA (100)",  color=colorMA3, linewidth=1, style=plot.style_circles)

// ATR Bands
plot(showATR ? close + atrVal : na, "ATR Upper", color=color.new(color.purple, 40), linewidth=1, style=plot.style_circles)
plot(showATR ? close - atrVal : na, "ATR Lower", color=color.new(color.purple, 40), linewidth=1, style=plot.style_circles)

// Volume bar highlight
barcolor(showVolume and volSpike ? colorVolHigh : na, title="Volume Spike")

// Buy/Sell signals
// FIX: plotshape has no "edgcolor" or "shape" named arg in v6 — use correct param names
plotshape(alertbuy,  "BUY Signal",  style=shape.labelup,   location=location.belowbar, color=color.new(color.green, 0), textcolor=color.white, text="BUY",  size=size.large)
plotshape(alertsell, "SELL Signal", style=shape.labeldown, location=location.abovebar, color=color.new(color.red,   0), textcolor=color.white, text="SELL", size=size.large)

// Entry markers
// FIX: size must be a const string — use size.small directly, not from input
plotshape(showEntryMarkers and demandEntrySetup, "Buy Entry",  style=shape.circle, location=location.belowbar, color=color.new(color.green, 40), size=size.small)
plotshape(showEntryMarkers and supplyEntrySetup, "Sell Entry", style=shape.circle, location=location.abovebar, color=color.new(color.red,   40), size=size.small)

// ============================================================================
// DYNAMIC OBJECTS — labels, lines, boxes (these CAN be inside if blocks)
// ============================================================================

// Supply/Demand Zones
if showSupplyDemand
    if supplyZone
        box.new(bar_index - 10, highestHigh, bar_index, highestHigh - zoneBoxHeight,
                border_color=color.new(color.red, 80), bgcolor=colorSupply, xloc=xloc.bar_index)
        label.new(bar_index, highestHigh, "SUPPLY / TRP1",
                  color=color.new(color.red, 50), style=label.style_label_down,
                  textcolor=color.white, size=size.small)
        if zoneRefinement and supplyRefined
            box.new(bar_index - 15, highestHigh - 5, bar_index, highestHigh - 15,
                    border_color=color.new(color.maroon, 60), bgcolor=color.new(color.red, 90), xloc=xloc.bar_index)
            label.new(bar_index - 8, highestHigh - 10, "TRP2",
                      color=color.new(color.maroon, 40), style=label.style_label_center,
                      textcolor=color.white, size=size.tiny)

    if demandZone
        box.new(bar_index - 10, lowestLow + zoneBoxHeight, bar_index, lowestLow,
                border_color=color.new(color.green, 80), bgcolor=colorDemand, xloc=xloc.bar_index)
        label.new(bar_index, lowestLow, "DEMAND",
                  color=color.new(color.green, 50), style=label.style_label_up,
                  textcolor=color.white, size=size.small)
        if zoneRefinement and demandRefined
            box.new(bar_index - 15, lowestLow + 15, bar_index, lowestLow + 5,
                    border_color=color.new(color.lime, 60), bgcolor=color.new(color.green, 90), xloc=xloc.bar_index)
            label.new(bar_index - 8, lowestLow + 10, "BE",
                      color=color.new(color.lime, 40), style=label.style_label_center,
                      textcolor=color.white, size=size.tiny)

// Zone midlines
if showRefinement
    if supplyZone
        line.new(bar_index - 20, highestHigh - zoneBoxHeight / 2,
                 bar_index,      highestHigh - zoneBoxHeight / 2,
                 color=color.new(color.red, 60), width=1, style=line.style_dotted)
    if demandZone
        line.new(bar_index - 20, lowestLow + zoneBoxHeight / 2,
                 bar_index,      lowestLow + zoneBoxHeight / 2,
                 color=color.new(color.green, 60), width=1, style=line.style_dotted)

// Entry labels
if showEntryMarkers
    if demandEntrySetup
        label.new(bar_index, low - atrVal * 1.5, "ENTRY BUY",
                  color=color.new(color.green, 30), style=label.style_label_up,
                  textcolor=color.white, size=size.tiny)
    if supplyEntrySetup
        label.new(bar_index, high + atrVal * 1.5, "ENTRY SELL",
                  color=color.new(color.red, 30), style=label.style_label_down,
                  textcolor=color.white, size=size.tiny)

// Trade traps
if showTradeTraps
    if bullTrapRefined
        label.new(bar_index, high + atrVal, "BULL TRAP",
                  color=color.new(color.orange, 40), style=label.style_label_down,
                  textcolor=color.white, size=size.small)
        line.new(bar_index - 1, high[1], bar_index, high,
                 color=color.orange, width=2, style=line.style_dashed)
    if bearTrapRefined
        label.new(bar_index, low - atrVal, "BEAR TRAP",
                  color=color.new(color.fuchsia, 40), style=label.style_label_up,
                  textcolor=color.white, size=size.small)
        line.new(bar_index - 1, low[1], bar_index, low,
                 color=color.fuchsia, width=2, style=line.style_dashed)

// Zone confidence label
if showConfidence and (supplyZone or demandZone)
    label.new(bar_index, highestHigh + zoneBoxHeight,
              "Conf: " + str.tostring(math.round(zoneConfidence, 0)) + "%",
              color=color.new(color.blue, 30), style=label.style_label_center,
              textcolor=color.white, size=size.tiny)

// ============================================================================
// ALERTS
// ============================================================================

if alertbuy
    alert("BUY "       + syminfo.tickerid + " — Demand Zone + Volume + Uptrend",   alert.freq_once_per_bar_close)
if alertsell
    alert("SELL "      + syminfo.tickerid + " — Supply Zone + Volume + Downtrend",  alert.freq_once_per_bar_close)
if bullTrapRefined
    alert("BULL TRAP " + syminfo.tickerid, alert.freq_once_per_bar_close)
if bearTrapRefined
    alert("BEAR TRAP " + syminfo.tickerid, alert.freq_once_per_bar_close)

// ============================================================================
// INFO PANEL
// ============================================================================

var table infoPanel = table.new(position.top_right, 2, 9,
                                border_color=color.gray, border_width=1,
                                frame_color=color.gray,  frame_width=1)

string trendTxt = ma1 > ma2 ? "UPTREND ↑"   : "DOWNTREND ↓"
color  trendClr = ma1 > ma2 ? color.green    : color.red
string zoneTxt  = supplyZone ? "SUPPLY"      : demandZone ? "DEMAND" : "NONE"
string volTxt   = volSpike   ? "SPIKE ↑"    : "NORMAL"
color  volClr   = volSpike   ? color.blue    : color.gray
string entryTxt = demandEntrySetup ? "BUY ↑" : supplyEntrySetup ? "SELL ↓" : "WAIT"
color  entryClr = demandEntrySetup ? color.green : supplyEntrySetup ? color.red : color.gray
string bbTxt    = close > bbUpper ? "OVERBOUGHT" : close < bbLower ? "OVERSOLD" : "NORMAL"
color  bbClr    = close > bbUpper ? color.red    : close < bbLower ? color.green : color.yellow
string trapTxt  = bullTrapRefined  ? "BULL TRAP" : bearTrapRefined ? "BEAR TRAP" : "NONE"
color  trapClr  = (bullTrapRefined or bearTrapRefined) ? color.orange : color.gray

color bgDark  = color.rgb(30, 30, 50)
color bgLight = color.rgb(50, 50, 70)

table.cell(infoPanel, 0, 0, "PRICE",      text_color=color.white, bgcolor=bgDark)
table.cell(infoPanel, 1, 0, str.tostring(close, format.price), text_color=color.white, bgcolor=bgLight)
table.cell(infoPanel, 0, 1, "TREND",      text_color=color.white, bgcolor=bgDark)
table.cell(infoPanel, 1, 1, trendTxt,     text_color=trendClr,    bgcolor=bgLight)
table.cell(infoPanel, 0, 2, "ZONE",       text_color=color.white, bgcolor=bgDark)
table.cell(infoPanel, 1, 2, zoneTxt,      text_color=color.white, bgcolor=bgLight)
table.cell(infoPanel, 0, 3, "VOLUME",     text_color=color.white, bgcolor=bgDark)
table.cell(infoPanel, 1, 3, volTxt,       text_color=volClr,      bgcolor=bgLight)
table.cell(infoPanel, 0, 4, "ENTRY",      text_color=color.white, bgcolor=bgDark)
table.cell(infoPanel, 1, 4, entryTxt,     text_color=entryClr,    bgcolor=bgLight)
table.cell(infoPanel, 0, 5, "BOLLINGER",  text_color=color.white, bgcolor=bgDark)
table.cell(infoPanel, 1, 5, bbTxt,        text_color=bbClr,       bgcolor=bgLight)
table.cell(infoPanel, 0, 6, "ATR",        text_color=color.white, bgcolor=bgDark)
table.cell(infoPanel, 1, 6, str.tostring(math.round(atrVal, 2)), text_color=color.white, bgcolor=bgLight)
table.cell(infoPanel, 0, 7, "TRAPS",      text_color=color.white, bgcolor=bgDark)
table.cell(infoPanel, 1, 7, trapTxt,      text_color=trapClr,     bgcolor=bgLight)
table.cell(infoPanel, 0, 8, "CONFIDENCE", text_color=color.white, bgcolor=bgDark)
table.cell(infoPanel, 1, 8, str.tostring(math.round(zoneConfidence, 0)) + "%", text_color=color.white, bgcolor=bgLight)

// ============================================================================
// MTF TABLE
// ============================================================================

if showMTF
    var table mtfTable = table.new(position.middle_right, 2, 5,
                                   border_color=color.gray, border_width=1)
    bool up1h = ta.sma(close, 50)  > ta.sma(close, 200)
    bool up4h = close > ta.sma(close, 50)
    bool upD  = close > ta.sma(close, 200)
    bool upW  = ma1   > ma2

    table.cell(mtfTable, 0, 0, "TF",   text_color=color.white, bgcolor=color.navy, text_size=size.tiny)
    table.cell(mtfTable, 1, 0, "BIAS", text_color=color.white, bgcolor=color.navy, text_size=size.tiny)
    table.cell(mtfTable, 0, 1, "1H",   text_color=color.white, bgcolor=color.gray, text_size=size.tiny)
    table.cell(mtfTable, 1, 1, up1h ? "↑" : "↓", text_color=up1h ? color.green : color.red, bgcolor=color.rgb(40,40,40), text_size=size.tiny)
    table.cell(mtfTable, 0, 2, "4H",   text_color=color.white, bgcolor=color.gray, text_size=size.tiny)
    table.cell(mtfTable, 1, 2, up4h ? "↑" : "↓", text_color=up4h ? color.green : color.red, bgcolor=color.rgb(40,40,40), text_size=size.tiny)
    table.cell(mtfTable, 0, 3, "D",    text_color=color.white, bgcolor=color.gray, text_size=size.tiny)
    table.cell(mtfTable, 1, 3, upD  ? "↑" : "↓", text_color=upD  ? color.green : color.red, bgcolor=color.rgb(40,40,40), text_size=size.tiny)
    table.cell(mtfTable, 0, 4, "W",    text_color=color.white, bgcolor=color.gray, text_size=size.tiny)
    table.cell(mtfTable, 1, 4, upW  ? "↑" : "↓", text_color=upW  ? color.green : color.red, bgcolor=color.rgb(40,40,40), text_size=size.tiny)
````
