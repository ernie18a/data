# Institutional Dealer Exposure 

- url: https://www.tradingview.com/script/CSnHVh0p-Institutional-Dealer-Exposure/
- type: indicator
- pine_id: PUB;b66ba88c39354d8d976250cc86fdef33
- version: 1.0

## Description

[b]Institutional Dealer Exposure: The Market Maker Footprint[/b]

In the high-frequency world of Futures [b](NQ, ES, GC)[/b], liquidity is not just a number—it is a battleground. Market Makers [b](Dealers)[/b] are required to provide liquidity by taking the opposite side of every retail and institutional order. When a massive "[i]Order Flow[/i]" imbalance occurs, dealers are often forced into "[i]unbalanced inventory[/i]" positions.

[b]The Institutional Dealer Exposure indicator[/b] is a sophisticated volatility-volume model designed to track these forced dealer entries. By calculating the statistical deviation of price from its Volume Weighted Average Price [b](VWAP)[/b] in conjunction with Relative Volume spikes, this tool identifies the exact "[i]Strike Prices[/i]" where dealers are stepping in to facilitate reversals and balance their books.

[b]The Mathematical Engine (The "Dealer Inventory" Proxy)[/b]
The core of this indicator relies on the relationship between Volume, Price, and Fair Value. Unlike standard oscillators, this tool uses a "[i]Z-Score[/i]" model of price-VWAP deviation:

Volume Weighted Average Price [b](VWAP)[/b]: We utilize VWAP as the "[i]Anchor of Fair Value[/i]." Dealers generally try to keep the market near this mean.
[b]Exposure Z-Score:[/b] We calculate the Standard Deviation of the distance between the current Price and VWAP. When the Z-Score exceeds +/- 2.0 (user-adjustable), it indicates a statistical anomaly—meaning the market is "[i]over-extended[/i]" in a way that requires institutional intervention.
Relative Volume [b](RVold)[/b]: A signal is only valid if it occurs during an Institutional Volatility Spike. We compare the current bar's volume to a 20-period average. If the volume is 2.5x the average (default), it confirms that "[i]Big Money[/i]" is active.
[b]Estimated Delta[/b]: The tool analyzes the internal candle action to estimate Buy vs. Sell pressure, providing a "[i]B[/i]:" or "[i]S[/i]:" metric on every bubble to show the aggressive intent of participants.

[b]Visual Execution & Advanced Order Flow Features[/b]
The script is built for professional clarity, providing a "[i]layered[/i]" view of the market's internal mechanics:

[b]Exposure Bubbles:[/b] High-visibility markers that trigger only on Volume Climaxes [b](local peaks)[/b]. These represent the "Entry Points" of institutional hedging.
[b]Dealer Zones:[/b] These are projected areas of interest. Unlike standard supply/demand zones, these are calculated from the high/low of the specific institutional "[i]Climax Candle[/i]."
The Strike Price [b](POC)[/b]: Every zone contains a solid white line representing the exact average price of the institutional entry. This acts as a high-precision magnet for future retests.
Internal Levels (Midline/Fib/Defense): Users can toggle between the Midline (Equilibrium), Fibonacci levels, or the "[i]80% Defense Line[/i]." These show exactly where the dealer is likely to protect their position.
[b]Auto-Invalidation[/b]: In a fast market like NQ, broken levels are dangerous. If the market closes beyond the 80% Defense Line, the zone automatically turns Gray, signaling that the institutional interest has shifted.

[b]Professional Strategy & Market Application[/b]
This tool is optimized for the 1-Minute and 5-Minute timeframes on high-liquidity assets like Nasdaq [b](NQ)[/b], S&P 500 [b](ES)[/b], and Gold [b](GC)[/b].

[b]The "Dealer Rejection" Setup:[/b]

[b]Wait for the Bubble:[/b] Identify an extreme inventory imbalance.
[b]Watch the Midline:[/b] After the bubble, look for the Institutional Defense Signals (▲/▼). These triangles appear when price retests the zone's midline and rejects it, confirming the dealer is "[i]defending[/i]" the level.
[b]The Absorption Factor (Optional):[/b] Enable the "[i]A[/i]" markers to find "[i]Hidden Orders[/i]." This highlights bars where massive volume was absorbed by the dealer without allowing price to continue in the direction of the trend—a classic institutional trap.
[b]The Divergence Warning (Optional):[/b] Enable "[i]D[/i]" markers to catch trend exhaustion. If price makes a new high but the Dealer Inventory Z-score is dropping, a reversal is imminent.

[b]Trading the Power Hours:[/b]
Use the built-in Session Filter to focus strictly on the London and New York opens, where dealer inventory fluctuates the most. Combine this with the Higher Timeframe Trend Filter [b](EMA 200)[/b] to ensure you are trading alongside the broader institutional flow.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Institutional Dealer Exposure", "IDE", overlay = true, max_boxes_count = 100, max_labels_count = 150, max_lines_count = 500)

string G_CORE = "Institutional Logic"
string G_VIS  = "Visuals & Themes"
string G_OPT  = "Optional Filters"
string G_ADD  = "Complementary Additions"

int   lookbackInput  = input.int(20, "Lookback Period", minval = 5, group = G_CORE)
float relVolThresh   = input.float(2.5, "Relative Volume Threshold", minval = 1.0, step = 0.1, group = G_CORE)
float zScoreThresh   = input.float(2.0, "Exposure Z-Score", minval = 0.5, step = 0.1, group = G_CORE)
int   climaxWindow   = input.int(10, "Volume Climax Window", minval = 1, group = G_CORE)
int   cooldown       = input.int(8, "Signal Cooldown", minval = 0, group = G_CORE)

bool  useSession     = input.bool(false, "London/NY Session Filter", group = G_OPT)
string sessionTime   = input.session("0300-1200", "Session Hours (UTC)", group = G_OPT)
bool  useTrendFilter = input.bool(false, "Higher Timeframe Filter (EMA 200)", group = G_OPT)

string themeInput    = input.string("Rogue (Classic)", "Color Theme", options = ["Rogue (Classic)", "Emerald & Ruby", "Neon Ghost", "Cyberpunk", "Monochrome", "Gold Standard"], group = G_VIS)
string internalStyle = input.string("Midline", "Zone Internal Style", options = ["Midline", "Fibonacci", "80% Defense Line"], group = G_VIS)
int   zoneAlpha      = input.int(80, "Zone Transparency", minval = 0, maxval = 100, group = G_VIS)

bool showDefense      = input.bool(true, "Show Institutional Defense Signals", group = G_ADD)
bool autoInvalidate   = input.bool(true, "Auto-Invalidate Broken Zones", group = G_ADD)
bool showStrike       = input.bool(true, "Show 'Strike Price' (POC Highlight)", group = G_ADD)
bool showAbsorption   = input.bool(false, "Show Absorption Markers (A)", group = G_ADD, tooltip = "Off by default. Identifies hidden dealer orders.")
bool showDivergence   = input.bool(false, "Show Institutional Divergence (D)", group = G_ADD, tooltip = "Off by default. Highlights trend exhaustion.")
int  divLookback      = input.int(10, "Divergence Lookback", minval = 5, group = G_ADD, tooltip = "Increasing this reduces the frequency of 'D' signals.")

color bullColor = switch themeInput
    "Rogue (Classic)" => #089981
    "Emerald & Ruby"  => #2ecc71
    "Neon Ghost"      => #00ffcc
    "Cyberpunk"       => #39ff14
    "Monochrome"      => #d1d4dc
    "Gold Standard"   => #ffd700
    => #089981

color bearColor = switch themeInput
    "Rogue (Classic)" => #f23645
    "Emerald & Ruby"  => #e74c3c
    "Neon Ghost"      => #ff0055
    "Cyberpunk"       => #ff00ff
    "Monochrome"      => #5d606b
    "Gold Standard"   => #c5a059
    => #f23645

float avgVol    = ta.sma(volume, lookbackInput)
bool  isVolPeak = volume >= ta.highest(volume, climaxWindow)
bool  isVolSpike = (volume / avgVol) >= relVolThresh

float vwapPrice = ta.vwap(hlc3)
float priceDiff = close - vwapPrice
float zScore    = priceDiff / ta.stdev(priceDiff, lookbackInput)

bool inSession  = not useSession or not na(time(timeframe.period, sessionTime, "UTC"))
float ema200    = ta.ema(close, 200)
bool trendLong  = not useTrendFilter or (close > ema200)
bool trendShort = not useTrendFilter or (close < ema200)

var int lastSignalBar = 0
bool onCooldown = (bar_index - lastSignalBar) < cooldown

bool bullSignal = isVolPeak and isVolSpike and zScore <= -zScoreThresh and not onCooldown and inSession and trendLong
bool bearSignal = isVolPeak and isVolSpike and zScore >= zScoreThresh and not onCooldown and inSession and trendShort

float candleRange = high - low
float buyPressure = candleRange != 0 ? (close - low) / candleRange : 0.5
float sellPressure = 1.0 - buyPressure
float estBuyVol   = volume * buyPressure
float estSellVol  = volume * sellPressure

bool bullAbsorption = isVolSpike and estBuyVol > estSellVol * 1.3 and close <= open
bool bearAbsorption = isVolSpike and estSellVol > estBuyVol * 1.3 and close >= open

bool bullDiv = ta.lowest(low, divLookback) == low and zScore > ta.lowest(zScore, divLookback) and zScore < -1.5
bool bearDiv = ta.highest(high, divLookback) == high and zScore < ta.highest(zScore, divLookback) and zScore > 1.5

if bullSignal or bearSignal
    lastSignalBar := bar_index

f_formatVol(float v) =>
    v >= 1000000 ? str.format("{0,number,#.##}M", v / 1000000) :
     v >= 1000 ? str.format("{0,number,#.##}K", v / 1000) :
     str.tostring(v, "#")

var box[] activeZones = array.new_box()
var bool[] zoneIsBullArr = array.new_bool()
var float[] zoneDefLineArr = array.new_float()

f_drawInternal(float top, float bot, color c, bool isBull) =>
    int endIdx = bar_index + 15
    float defLine = isBull ? bot + (top - bot) * 0.8 : top - (top - bot) * 0.8
    if internalStyle == "Midline"
        line.new(bar_index, (top + bot) / 2, endIdx, (top + bot) / 2, color = color.new(c, 50), style = line.style_dashed)
    else if internalStyle == "Fibonacci"
        float boxRange = top - bot
        line.new(bar_index, bot + boxRange * 0.236, endIdx, bot + boxRange * 0.236, color = color.new(c, 70), width = 1)
        line.new(bar_index, bot + boxRange * 0.382, endIdx, bot + boxRange * 0.382, color = color.new(c, 60), width = 1)
        line.new(bar_index, bot + boxRange * 0.618, endIdx, bot + boxRange * 0.618, color = color.new(c, 60), width = 1)
        line.new(bar_index, bot + boxRange * 0.786, endIdx, bot + boxRange * 0.786, color = color.new(c, 70), width = 1)
    else if internalStyle == "80% Defense Line"
        line.new(bar_index, defLine, endIdx, defLine, color = color.new(c, 20), width = 2)
    defLine

f_drawZone(bool isBull, color c) =>
    float top = math.max(open, close)
    float bot = math.min(open, close)
    int endIdx = bar_index + 15
    box b = box.new(bar_index, top, endIdx, bot, border_color = color.new(c, 100), bgcolor = color.new(c, zoneAlpha))
    line.new(bar_index, top, endIdx, top, color = color.new(c, 30), width = 1)
    line.new(bar_index, bot, endIdx, bot, color = color.new(c, 30), width = 1)
    
    if showStrike
        line.new(bar_index, hlc3, endIdx, hlc3, color = color.white, width = 1, style = line.style_solid)

    float defY = f_drawInternal(top, bot, c, isBull)
    array.push(activeZones, b)
    array.push(zoneIsBullArr, isBull)
    array.push(zoneDefLineArr, defY)
    if array.size(activeZones) > 20
        array.shift(activeZones)
        array.shift(zoneIsBullArr)
        array.shift(zoneDefLineArr)

if bullSignal
    f_drawZone(true, bullColor)
    label.new(bar_index, low, str.format("{0}\n{1,number,#.##}x\nB: {2}", f_formatVol(volume), volume/avgVol, f_formatVol(estBuyVol)), color = bullColor, textcolor = color.white, style = label.style_diamond, yloc = yloc.belowbar, size = size.small)

if bearSignal
    f_drawZone(false, bearColor)
    label.new(bar_index, high, str.format("{0}\n{1,number,#.##}x\nS: {2}", f_formatVol(volume), volume/avgVol, f_formatVol(estSellVol)), color = bearColor, textcolor = color.white, style = label.style_diamond, yloc = yloc.abovebar, size = size.small)

if showAbsorption
    if bullAbsorption and not bullSignal
        label.new(bar_index, low, "A", color = bullColor, textcolor = color.white, style = label.style_label_up, size = size.tiny)
    if bearAbsorption and not bearSignal
        label.new(bar_index, high, "A", color = bearColor, textcolor = color.white, style = label.style_label_down, size = size.tiny)

if showDivergence
    if bullDiv and not bullSignal and not bullAbsorption
        label.new(bar_index, low, "D", color = #00000000, textcolor = bullColor, style = label.style_label_up, size = size.tiny)
    if bearDiv and not bearSignal and not bearAbsorption
        label.new(bar_index, high, "D", color = #00000000, textcolor = bearColor, style = label.style_label_down, size = size.tiny)

if array.size(activeZones) > 0
    for i = 0 to array.size(activeZones) - 1
        box b = array.get(activeZones, i)
        bool isBull = array.get(zoneIsBullArr, i)
        float defY = array.get(zoneDefLineArr, i)
        float top = box.get_top(b)
        float bot = box.get_bottom(b)
        int start = box.get_left(b)
        int end = box.get_right(b)
        
        if bar_index > start and bar_index <= end
            if showDefense
                if isBull and low <= (top+bot)/2 and close > (top+bot)/2
                    label.new(bar_index, low, "▲", color = #00000000, textcolor = bullColor, style = label.style_label_up, size = size.tiny)
                else if not isBull and high >= (top+bot)/2 and close < (top+bot)/2
                    label.new(bar_index, high, "▼", color = #00000000, textcolor = bearColor, style = label.style_label_down, size = size.tiny)
            if autoInvalidate
                if (isBull and close < defY) or (not isBull and close > defY)
                    box.set_bgcolor(b, color.new(color.gray, 90))

var table helpTable = table.new(position.top_right, 2, 8, bgcolor = color.new(color.black, 50), border_width = 1, border_color = color.gray)
if barstate.islast
    table.cell(helpTable, 0, 0, "Institutional Dealer Exposure - GUIDE", text_color = color.white, text_size = size.small)
    table.merge_cells(helpTable, 0, 0, 1, 0)
    table.cell(helpTable, 0, 1, "METRICS", text_color = color.gray, text_size = size.tiny)
    table.cell(helpTable, 1, 1, "Vol | Rel Vol Spike | Est. Buy/Sell Delta", text_color = color.white, text_size = size.tiny, text_halign = text.align_left)
    table.cell(helpTable, 0, 2, "ABSORPTION (A)", text_color = color.gray, text_size = size.tiny)
    table.cell(helpTable, 1, 2, "Dealer absorbing flow (Off by Default).", text_color = color.white, text_size = size.tiny, text_halign = text.align_left)
    table.cell(helpTable, 0, 3, "DEFENSE (▲/▼)", text_color = color.gray, text_size = size.tiny)
    table.cell(helpTable, 1, 3, "Price rejection of zone equilibrium.", text_color = color.white, text_size = size.tiny, text_halign = text.align_left)
    table.cell(helpTable, 0, 4, "STRIKE PRICE", text_color = color.gray, text_size = size.tiny)
    table.cell(helpTable, 1, 4, "White line: Exact institutional entry point.", text_color = color.white, text_size = size.tiny, text_halign = text.align_left)
    table.cell(helpTable, 0, 5, "DIVERGENCE (D)", text_color = color.gray, text_size = size.tiny)
    table.cell(helpTable, 1, 5, "Trend exhaustion signals (Off by Default).", text_color = color.white, text_size = size.tiny, text_halign = text.align_left)
    table.cell(helpTable, 0, 6, "SENTIMENT", text_color = color.gray, text_size = size.tiny)
    table.cell(helpTable, 1, 6, zScore > 1.5 ? "Extreme Long" : zScore < -1.5 ? "Extreme Short" : "Neutral", text_color = color.white, text_size = size.tiny, text_halign = text.align_left)
    table.cell(helpTable, 0, 7, "MARKET STATUS", text_color = color.gray, text_size = size.tiny)
    table.cell(helpTable, 1, 7, isVolSpike ? "Institutional Activity" : "Retail Flow", text_color = color.white, text_size = size.tiny, text_halign = text.align_left)

plotshape(bullSignal, "MM Buy Bubble", shape.circle, location.belowbar, bullColor, size = size.normal)
plotshape(bearSignal, "MM Sell Bubble", shape.circle, location.abovebar, bearColor, size = size.normal)
````
