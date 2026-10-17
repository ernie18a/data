# NASDAQ Flow Profile PRO CLEAN MTF + LTF

- url: https://www.tradingview.com/script/tLStsiYT/
- type: indicator
- pine_id: PUB;3501da00425c4199836246ed9b518f9f
- version: 2.0

## Description

This indicator delivers a multi-timeframe volume-weighted flow profile designed specifically for fast markets like NASDAQ. It combines Main TF, Higher Timeframes (HTF), and Lower Timeframe (LTF) structure into a single, clean visual framework — without repainting or external data requests.

🔍 Core Concept

Instead of using traditional fixed volume profile tools, this script dynamically calculates:

POC (Point of Control) → volume-weighted average price
VAH (Value Area High) → upper deviation from POC
VAL (Value Area Low) → lower deviation from POC

All levels are derived using:

Pure price × volume weighting
Rolling lookback windows
Standard deviation–based value areas

This creates a live, adaptive flow profile that reacts instantly to market conditions.

⚙️ Multi-Timeframe Engine
🟡 Main Timeframe (Chart TF)
Core structure of the current market
Smoothed using EMA for clarity
Defines the active trading range
🟠 HTF x5 (Higher Timeframe)
Mid-term directional bias
Filters noise and highlights institutional flow zones
🔵 HTF x15 (Higher Timeframe)
Macro structure
Identifies major accumulation/distribution areas

All HTF levels are calculated internally using length multiplication, not request.security, ensuring:

No repainting
Perfect alignment with the current chart
⚡ LTF Precision Layer
⚪ Lower Timeframe (LTF)
Ultra-fast microstructure detection
Uses reduced lookback + tighter value area (ltfTight)
Ideal for:
Entries
Scalping confirmation
Fine-tuning execution
🎯 Key Features
✅ True volume-weighted POC calculation (not approximated)
✅ Dynamic Value Areas using variance & standard deviation
✅ Full MTF stacking (x1 / x5 / x15)
✅ Integrated LTF microstructure layer
✅ Independent visibility toggles for all components
✅ Clean EMA smoothing (no lag-heavy filters)
✅ Fully customizable colors
✅ Overlay directly on price chart
🚀 What’s Improved vs. Standard / Original Versions
🔥 Added LTF Layer
→ Most flow/profile indicators only show HTF bias.
→ This version adds a true lower timeframe execution layer.
🔥 No request.security Usage
→ Eliminates repainting and sync issues
→ Uses mathematical TF projection (length scaling) instead
🔥 Cleaner Visualization
→ Removed unsupported dashed styles
→ Replaced with transparency-based hierarchy
🔥 Optimized for NASDAQ
→ Faster reaction via shorter default lookback
→ Better suited for M1 / M5 scalping
🔥 More Accurate VA Calculation
→ Uses volume-weighted variance, not simple price deviation
🔥 Performance Optimized
→ Lightweight loops
→ No external data calls
→ Stable even on low timeframes
🧠 How to Use
Price above POC → bullish control
Price below POC → bearish control
VAH = potential resistance
VAL = potential support
Best Confluence:
LTF aligns with HTF direction → high-probability entry
Price reacts at HTF VA zones → institutional levels
Compression between VAH/VAL → breakout potential
🏁 Summary

This is not a classic volume profile.

It’s a real-time flow engine that maps:

Microstructure (LTF)
Current structure (Main TF)
Macro bias (HTF)

All in one — clean, fast, and built for precision trading.

## Source Code

````pine
//@version=6
indicator("NASDAQ Flow Profile PRO CLEAN (MTF + MID + LTF)", overlay=true)

//━━━━━━━━ INPUTS ━━━━━━━━
len     = input.int(120, "Main Lookback", minval=20)
smooth  = input.int(5, "Main Smoothing", minval=1)

// HTF
htfMult1 = input.int(5, "HTF x5 Multiplier")
htfMult2 = input.int(15, "HTF x15 Multiplier")

// MID
midMult   = input.float(0.6, "MID Multiplier (zwischen Main & LTF)", step=0.05)
midSmooth = input.int(3, "MID Smoothing", minval=1)

// LTF
ltfMult   = input.float(0.25, "LTF Multiplier (<1 = kleiner TF)", step=0.05)
ltfSmooth = input.int(1, "LTF Smoothing", minval=1)
ltfTight  = input.float(0.6, "LTF VA Tightness", step=0.1)

// VISIBILITY
showMainPOC = input.bool(true, "Show MAIN POC")
showMainVAH = input.bool(true, "Show MAIN VAH")
showMainVAL = input.bool(true, "Show MAIN VAL")

showMIDPOC = input.bool(true, "Show MID POC")
showMIDVAH = input.bool(true, "Show MID VAH")
showMIDVAL = input.bool(true, "Show MID VAL")

showHTF1POC = input.bool(true, "Show HTF x5 POC")
showHTF2POC = input.bool(true, "Show HTF x15 POC")

showHTF1VA  = input.bool(true, "Show HTF x5 VA")
showHTF2VA  = input.bool(true, "Show HTF x15 VA")

showLTFPOC  = input.bool(true, "Show LTF POC")
showLTFVAH  = input.bool(true, "Show LTF VAH")
showLTFVAL  = input.bool(true, "Show LTF VAL")

// COLORS
pocColor  = input.color(color.yellow, "MAIN POC")
vahColor  = input.color(color.aqua, "MAIN VAH")
valColor  = input.color(color.fuchsia, "MAIN VAL")

midColor  = input.color(color.lime, "MID")

htf1Color = input.color(color.orange, "HTF x5")
htf2Color = input.color(color.blue, "HTF x15")

ltfColor  = input.color(color.white, "LTF")

//━━━━━━━━ CORE ━━━━━━━━
calc_poc(_len)=>
    float volSum = 0.0
    float pvSum  = 0.0
    for i = 0 to _len - 1
        volSum += volume[i]
        pvSum  += close[i] * volume[i]
    volSum > 0 ? pvSum / volSum : close

calc_va(_len, _poc, _tight)=>
    float variance = 0.0
    float volSum2 = 0.0
    for i = 0 to _len - 1
        variance += volume[i] * math.pow(close[i] - _poc, 2)
        volSum2  += volume[i]
    variance := volSum2 > 0 ? variance / volSum2 : 0
    stdev = math.sqrt(variance) * _tight
    [_poc + stdev, _poc - stdev]

//━━━━━━━━ MAIN ━━━━━━━━
poc = calc_poc(len)
[vah, val] = calc_va(len, poc, 1.0)

poc_s = ta.ema(poc, smooth)
vah_s = ta.ema(vah, smooth)
val_s = ta.ema(val, smooth)

//━━━━━━━━ MID ━━━━━━━━
len_mid = math.max(10, int(len * midMult))

poc_mid = calc_poc(len_mid)
[vah_mid, val_mid] = calc_va(len_mid, poc_mid, 1.0)

poc_mids = ta.ema(poc_mid, midSmooth)
vah_mids = ta.ema(vah_mid, midSmooth)
val_mids = ta.ema(val_mid, midSmooth)

//━━━━━━━━ HTF ━━━━━━━━
len_htf1 = len * htfMult1
len_htf2 = len * htfMult2

poc_htf1 = calc_poc(len_htf1)
poc_htf2 = calc_poc(len_htf2)

[vah_htf1, val_htf1] = calc_va(len_htf1, poc_htf1, 1.0)
[vah_htf2, val_htf2] = calc_va(len_htf2, poc_htf2, 1.0)

poc_htf1s = ta.ema(poc_htf1, smooth)
poc_htf2s = ta.ema(poc_htf2, smooth)

vah_htf1s = ta.ema(vah_htf1, smooth)
val_htf1s = ta.ema(val_htf1, smooth)

vah_htf2s = ta.ema(vah_htf2, smooth)
val_htf2s = ta.ema(val_htf2, smooth)

//━━━━━━━━ LTF ━━━━━━━━
len_ltf = math.max(5, int(len * ltfMult))

poc_ltf = calc_poc(len_ltf)
[vah_ltf, val_ltf] = calc_va(len_ltf, poc_ltf, ltfTight)

poc_ltfs = ta.ema(poc_ltf, ltfSmooth)
vah_ltfs = ta.ema(vah_ltf, ltfSmooth)
val_ltfs = ta.ema(val_ltf, ltfSmooth)

//━━━━━━━━ PLOTS ━━━━━━━━

// MAIN
plot(showMainPOC ? poc_s : na, color=pocColor, linewidth=3, title="MAIN • POC")
plot(showMainVAH ? vah_s : na, color=vahColor, linewidth=1, title="MAIN • VAH")
plot(showMainVAL ? val_s : na, color=valColor, linewidth=1, title="MAIN • VAL")

// MID
plot(showMIDPOC ? poc_mids : na, color=midColor, linewidth=2, title="MID • POC")
plot(showMIDVAH ? vah_mids : na, color=color.new(midColor, 20), linewidth=1, title="MID • VAH")
plot(showMIDVAL ? val_mids : na, color=color.new(midColor, 20), linewidth=1, title="MID • VAL")

// HTF x5
plot(showHTF1POC ? poc_htf1s : na, color=htf1Color, linewidth=2, title="HTF x5 • POC")
plot(showHTF1VA ? vah_htf1s : na, color=color.new(htf1Color, 40), linewidth=1, title="HTF x5 • VAH")
plot(showHTF1VA ? val_htf1s : na, color=color.new(htf1Color, 40), linewidth=1, title="HTF x5 • VAL")

// HTF x15
plot(showHTF2POC ? poc_htf2s : na, color=htf2Color, linewidth=2, title="HTF x15 • POC")
plot(showHTF2VA ? vah_htf2s : na, color=color.new(htf2Color, 40), linewidth=1, title="HTF x15 • VAH")
plot(showHTF2VA ? val_htf2s : na, color=color.new(htf2Color, 40), linewidth=1, title="HTF x15 • VAL")

// LTF
plot(showLTFPOC ? poc_ltfs : na, color=ltfColor, linewidth=2, title="LTF • POC")
plot(showLTFVAH ? vah_ltfs : na, color=ltfColor, linewidth=1, title="LTF • VAH")
plot(showLTFVAL ? val_ltfs : na, color=ltfColor, linewidth=1, title="LTF • VAL")
````
