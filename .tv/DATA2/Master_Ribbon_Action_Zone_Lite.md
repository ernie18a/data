<!-- tradingview-pine-id: PUB;cf2b85411e434540a710c7e3ccdb820f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Master Ribbon Action Zone - Lite

Source: https://www.tradingview.com/script/yc46fnuq-Master-Ribbon-Action-Zone-Lite-with-Alert/

## Description

The Ultimate Multi-Layer Trend & Zone Compass

The Master Ribbon Action Zone - Lite is a professional-grade trend-following indicator designed to eliminate market noise and keep you perfectly aligned with the macro trend. It combines the structural strength of a Master Moving Average with an advanced Symmetrical Ribbon Fill to give you a clean, distraction-free visual interface.

Unlike traditional two-state indicators that flip blindly between long and short, this indicator introduces intelligent zone mapping using a hidden multi-layer framework. It maps market health dynamically into three distinct action zones without cluttering your chart with unnecessary filter lines.

🔥 Key Features:

[*] Symmetrical Ribbon Zones (Green / Yellow / Red): Dynamically colors the ribbon based on absolute price health. Green indicates a strong uptrend; Red indicates a confirmed downtrend; Yellow signals a critical pullback or rebound zone, letting you manage risk and spot re-entry opportunities seamlessly.
[*] Clean & Distraction-Free UI: Engineered for absolute clarity. The underlying calculation layers operate silently in the background, keeping your chart free from visual clutter while delivering precise structural accuracy.
[*] Master Trend Anchoring: Relies on a robust baseline framework (Default: 200 EMA & 55 VWMA structure) to filter out standard market consolidations and prevent premature exits.
[*] Multi-Asset Versatility: Highly adaptable across equities, crypto, and futures across multiple timeframes, providing a robust visual edge for modern trend followers.

💡 How to Use:

[*] Riding the Wave (Green Zone): Stay strictly long or hold your core positions as long as the ribbon remains in the clean green continuation zone.
[*] Pullback & Re-entry Management (Yellow Zone): When the ribbon shifts to yellow, treat it as a structural pause or pullback zone. Use it to lock in partial profits or wait for the color to flip back to green for high-probability add-ons.
[*] Risk Off (Red Zone): Avoid long exposure or shift to defensive positioning entirely when the structure breaks down into the red zone.
[*] Setting up Alerts: You can set alerts directly via TradingView's alert menu using "Any alert() function call" or standard crossing conditions to get notified instantly when price crosses the Master MA or Smoothing MA.

Please Enjoy !!

---

## Source Code

````pine
// © PhantomTrader108
//@version=6
indicator(title="Master Ribbon Action Zone - Lite", shorttitle="MRA Zone - Lite", overlay=true)


calc_ma(src, len, maType) =>
    switch maType
        "SMA"   => ta.sma(src, len)
        "EMA"   => ta.ema(src, len)
        "WMA"   => ta.wma(src, len)
        "VWMA"  => ta.vwma(src, len)
        "HMA"   => ta.hma(src, len)
        => ta.ema(src, len)


GRP_MASTER = "Master MA"
masterType = input.string("EMA", "Type", options=["SMA", "EMA", "WMA", "VWMA", "HMA"], group=GRP_MASTER)
len = input.int(200, minval=1, title="Length", group=GRP_MASTER)
src = input(close, title="Source", group=GRP_MASTER)
offset = input.int(title="Offset", defval=0, minval=-500, maxval=500, display=display.none, group=GRP_MASTER)

out = calc_ma(src, len, masterType)
p1 = plot(out, title="Master MA", color=color.blue, offset=offset)


GRP_SMOOTH = "Smoothing MA"
smoothSrc = input.source(close, "Source", group=GRP_SMOOTH)
maTypeInput = input.string("HMA", "Type", options = ["None", "SMA", "EMA", "WMA", "VWMA", "HMA"], group = GRP_SMOOTH, display = display.none)
maLengthInput = input.int(200, "Length", group = GRP_SMOOTH, display = display.none, active = maTypeInput != "None")
var enableMA = maTypeInput != "None"

smoothingMA = enableMA ? calc_ma(smoothSrc, maLengthInput, maTypeInput) : na
p2 = plot(smoothingMA, "Smoothing MA", color=color.yellow, display = enableMA ? display.all : display.none, editable = enableMA)


GRP_FILTER = "Trend Filter MA"
filterType = input.string("VWMA", "Type", options=["SMA", "EMA", "WMA", "VWMA", "HMA"], group=GRP_FILTER, display=display.none)
filterLen = input.int(55, "Length", group=GRP_FILTER, display=display.none)
filterSrc = input(close, "Source", group=GRP_FILTER, display=display.none)

trendFilter = calc_ma(filterSrc, filterLen, filterType)
plot(trendFilter, title="Trend Filter", color=color.white, display=display.none, editable=false)


color ribbonColor = na
if enableMA
    if close >= out and close >= trendFilter
        ribbonColor := color.new(color.green, 80)   // ขาขึ้นแข็งแกร่ง (เขียวโปร่งใส)
    else if close >= out and close < trendFilter
        ribbonColor := color.new(color.yellow, 80)  // ขาขึ้นแต่ย่อตัว (เหลืองโปร่งใส)
    else if close < out and close > trendFilter
        ribbonColor := color.new(color.yellow, 80)  // ขาลงแต่รีบาวด์ (เหลืองโปร่งใส)
    else
        ribbonColor := color.new(color.red, 80)     // ขาลงเต็มตัว (แดงโปร่งใส)

fill(p1, p2, color=ribbonColor, title="Master Ribbon Fill")


crossAboveMaster = ta.crossover(close, out)
crossUnderMaster = ta.crossunder(close, out)

alertcondition(crossAboveMaster, title="Price Crosses Above Master MA", message="MRA Lite: Price crossed ABOVE Master MA!")
alertcondition(crossUnderMaster, title="Price Crosses Below Master MA", message="MRA Lite: Price crossed BELOW Master MA!")

if crossAboveMaster
    alert("MRA Lite: Price crossed ABOVE Master MA!", alert.freq_once_per_bar)
if crossUnderMaster
    alert("MRA Lite: Price crossed BELOW Master MA!", alert.freq_once_per_bar)

crossAboveSmooth = enableMA and ta.crossover(close, smoothingMA)
crossUnderSmooth = enableMA and ta.crossunder(close, smoothingMA)

alertcondition(crossAboveSmooth, title="Price Crosses Above Smoothing MA", message="MRA Lite: Price crossed ABOVE Smoothing MA!")
alertcondition(crossUnderSmooth, title="Price Crosses Below Smoothing MA", message="MRA Lite: Price crossed BELOW Smoothing MA!")

if crossAboveSmooth
    alert("MRA Lite: Price crossed ABOVE Smoothing MA!", alert.freq_once_per_bar)
if crossUnderSmooth
    alert("MRA Lite: Price crossed BELOW Smoothing MA!", alert.freq_once_per_bar)
````
