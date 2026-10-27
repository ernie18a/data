# Omega Effort [OmegaTools]

- url: https://www.tradingview.com/script/NqI9Tco8-Omega-Effort-OmegaTools/
- type: indicator
- pine_id: PUB;15a7621516ae400dbdffcb122061d167
- version: 1.0

## Description

[b]Ω Effort: Effort vs. Result Zones, Volume Blocks and Center of Gravity[/b]

Omega Effort is a volume-based overlay built on the Wyckoff principle of effort versus result. Volume is the effort; the price displacement it produces (the candle body) is the result. When a candle covers an unusually large distance on comparatively little volume, price has moved through thin liquidity with little opposition. When volume surges far above normal, an unusually large amount of trading has taken place on that bar, regardless of the outcome.

The indicator maps both sides of this relationship directly on the chart: statistically abnormal "result" bars become [b]Effort Zones[/b], statistically abnormal "effort" bars become [b]Volume Block[/b] markers, and a volume-weighted [b]Center of Gravity[/b] provides the location context used to classify them.


[b]1. HOW IT WORKS[/b]

[b]RECOMMENDED CHART: 50 RANGE[/b]
Omega Effort is designed to be used on a [b]50 Range[/b] chart. On a range chart every bar spans the same price range and candle bodies are close to constant, so the "result" side of the effort-versus-result equation is held steady and the efficiency z-score directly measures how much volume the market needed to complete each bar. An Effort Zone then marks a bar that completed its range on unusually low volume, while a Volume Block marks a bar that traded an unusually large amount of volume. Because range bars form on price movement rather than on the clock, the 21-bar statistics and the zone lengths are measured in units of market activity instead of time, which reduces the distortion caused by quiet overnight hours and busy session opens.
The indicator also works on time-based charts, where both body size and volume contribute to efficiency, but the 50 Range chart is the recommended setup.

[b]Efficiency[/b]
For every bar the script computes an efficiency ratio: the absolute body size (|close − open|) divided by volume, i.e. how far price travelled per unit of volume traded. This ratio is standardized as a z-score against its own 21-bar mean and standard deviation. Because the measure is normalized to its own recent history, the threshold adapts automatically to the instrument, timeframe and volatility regime. No fixed price or volume values are needed.

[b]Effort Zones[/b]
When the efficiency z-score exceeds the Sensitivity threshold (default 3.0 standard deviations), a zone is drawn over the full high-to-low range of the bar:
[list]
[*]Positive color: bullish displacement bar (close > open).
[*]Negative color: bearish displacement bar (close < open).
[*]Transparency scales with the z-score (100 − 10 × z, clamped between 0 and 100): the more abnormal the displacement, the more solid the zone. At the default threshold a zone is drawn at 70% transparency, a 5σ event at 50%.
[/list]
These zones mark areas the market crossed quickly and one-sidedly, with little two-way trade inside them. They are commonly treated as imbalances: price may later return to them, and the way it behaves on that return is the information the trader evaluates.

[b]Zone lifecycle[/b]
Each zone is projected 21 bars forward and then tracked bar by bar:
[list]
[*]A bullish zone is invalidated when a bar closes below its low. A bearish zone is invalidated when a bar closes above its high. Only closes count; wicks through the zone do not.
[*]Price moving away in the direction of the original displacement does not invalidate the zone.
[*]An invalidated zone is cut at the invalidating bar, with a minimum length of 7 bars so that short-lived zones remain readable.
[*]A zone that is not invalidated within 21 bars keeps its full length and stops being tracked.
[/list]
The length of each zone therefore carries information: full-length zones held, shortened zones were closed through on the opposite side.

[b]Center of Gravity[/b]
The dotted line is a volume-weighted average price smoothed with Wilder's RMA over 9 bars: RMA(close × volume) / RMA(volume). It is not related to Ehlers' Center of Gravity oscillator. It represents the recent volume-weighted mean price, the level around which the bulk of recent trading took place, and is used both as a visual reference for value and as the reference level for the zone filter.

[b]Location filter[/b]
Each qualifying bar is classified by the position of its midpoint (hl2) relative to the Center of Gravity:
[list]
[*][b]All[/b]: every qualifying zone is drawn.
[*][b]Preferred[/b]: bullish zones with the midpoint below the Center of Gravity and bearish zones with the midpoint above it. The displacement starts from the discounted side of recent value for buyers, or from the premium side for sellers.
[*][b]Distal[/b]: bullish zones above the Center of Gravity and bearish zones below it. The displacement extends further away from value, typical of momentum and continuation phases, or of late-stage extension.
[/list]
The filter applies to Effort Zones only. Volume Block markers are always displayed.

[b]Volume Blocks[/b]
Volume is standardized with the same 21-bar z-score. When it exceeds the Sensitivity threshold, a cross marker is plotted: above a bullish bar in the negative color, below a bearish bar in the positive color. The coloring is intentional. An abnormal volume spike means heavy participation on both sides of the market, and on a bar that closes up it can reflect large passive selling absorbing aggressive buying (and vice versa on a down bar). The marker therefore points to the side of potential absorption rather than to the direction of the bar. Hovering over the marker shows how many standard deviations the bar's volume sits above its 21-bar average.


[b]2. HOW THE COMPONENTS WORK TOGETHER[/b]

Effort Zones and Volume Blocks measure opposite conditions and rarely appear on the same bar: a zone requires a large result for little effort, a block requires a large effort regardless of the result. Read together, they describe how participation and price movement interact:
[list]
[*][b]Zone, then Block on the return:[/b] heavy participation arriving at a thin-liquidity area. Watch whether closes hold the zone or pass through it.
[*][b]Block on a small-bodied bar:[/b] high effort with little result, a classic absorption signature. The marker color indicates the likely absorbing side.
[*][b]Block, then Zone in the same direction:[/b] effort converting into easy movement, which may indicate that the opposing side has been absorbed.
[*][b]Preferred vs. Distal zones:[/b] responsive activity near or against value versus initiative activity extending away from it.
[/list]


[b]3. HOW TO USE IT[/b]

[list=1]
[*]Apply the indicator to any chart with reliable volume data. Start with the default Sensitivity (3.0): lower values (2 to 2.5) show more zones and blocks, higher values (4 to 5) only the most extreme events.
[*]Select the filter that matches your approach: Preferred for mean-reversion and responsive trading, Distal for momentum and continuation, All for the complete map.
[*]Treat active zones as areas of interest, not as entry signals. Evaluate price behavior on the return: rejection and closes holding the zone, or closes through the opposite side, which invalidate it.
[*]Use Volume Blocks as context for absorption and potential turning points, especially when they occur at an active zone or far from the Center of Gravity.
[*]Combine with higher-timeframe structure and your own risk management. The indicator does not generate entries, exits or targets.
[/list]


[b]4. SETTINGS[/b]

[list]
[*][b]Sensitivity[/b] (2 to 5, default 3): z-score threshold shared by Effort Zones and Volume Blocks.
[*][b]Filter[/b] (All / Preferred / Distal): location filter for Effort Zones.
[*][b]Positive / Negative color[/b]: colors for bullish and bearish elements.
[/list]
The z-score lookback (21), the Center of Gravity length (9) and the zone lengths (7 bars minimum when invalidated, 21 bars maximum) are fixed by design, keeping the tool free of arbitrary tuning.


[b]5. NOTES AND LIMITATIONS[/b]

[list]
[*]Volume data is required. On symbols without volume the script has nothing to calculate. On spot FX and CFDs, volume is broker tick volume and should be interpreted accordingly.
[*]On range and Renko charts, candle bodies are close to constant, so efficiency is driven almost entirely by volume: zones then highlight bars that completed their range on unusually low volume. On time-based charts, both body size and volume contribute.
[*]Conditions are evaluated on bar values. On the live bar, zones and markers may appear or disappear until the bar closes. Once a bar is confirmed its zone or marker no longer changes; only the right edge of an active zone updates when it is invalidated.
[*]Bars with close equal to open are ignored by both components.
[*]Up to 500 zones and 500 markers are kept on the chart; older drawings are removed automatically.
[/list]


[b]DISCLAIMER[/b]
[i]This script is provided for educational and analytical purposes only. It does not constitute financial advice and does not guarantee future results. Past behavior of zones and volume events is not indicative of future performance. Always apply proper risk management.[/i]

## Source Code

````pine
// © OmegaTools

//@version=6
indicator(title = 'Omega Effort [OmegaTools]', shorttitle = 'Ω Effort', overlay = true, max_boxes_count = 500, max_labels_count = 500)

sens = input.float(3, 'Sentivity', minval = 2, maxval = 5, step = 0.25)
only = input.string('All', 'Filter', ['All', 'Preferred', 'Distal'])
upc = input.color(#2962ff, 'Positive color', group = 'Style')
dnc = input.color(#e91e63, 'Negative color', group = 'Style')

z(src) => (src - ta.sma(src, 21)) / ta.stdev(src, 21)

sma = ta.rma(close * volume, 9) / ta.rma(volume, 9)
efficency = math.abs(close - open) / volume
ze = z(efficency)
zv = z(volume)
effort = ze > sens
block = zv > sens
bull = close > open

opacity = math.min(math.max(math.round(100 - ze * 10), 0), 100)

type Zone
    box  b
    int  start
    bool bull
var array<Zone> active = array.new<Zone>()

if active.size() > 0
    for i = active.size() - 1 to 0
        zn  = active.get(i)
        age = bar_index - zn.start
        broken = zn.bull ? close < zn.b.get_bottom() : close > zn.b.get_top()
        if broken
            zn.b.set_right(zn.start + math.max(age, 7))
            active.remove(i)
        else if age >= 21
            active.remove(i)

if effort and close != open
    col = bull ? upc : dnc
    if (only == 'All') or ((only == 'Preferred' and bull and hl2 < sma) or (only == 'Preferred' and not bull and hl2 > sma)) or ((only == 'Distal' and not bull and hl2 < sma) or (only == 'Distal' and bull and hl2 > sma))
        b = box.new(bar_index, high, bar_index + 21, low, color.new(col, opacity - 10), bgcolor = color.new(col, opacity))
        active.push(Zone.new(b, bar_index, bull))

plot(sma, 'Center of Gravity', color.new(chart.fg_color, 50), linestyle = plot.linestyle_dotted)

if block and close != open
    label.new(bar_index, 0, yloc = bull ? yloc.abovebar : yloc.belowbar, color = bull ? dnc : upc, style = label.style_xcross, size = 3, tooltip = str.tostring(zv, '#.#') + 'X avg volume')

// End of Script
````
