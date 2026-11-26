# MSL Liquidity Tails

- url: https://www.tradingview.com/script/VBVPauNJ-msl-liquidity-tails/
- type: indicator
- pine_id: PUB;fb0fd3e61d4d43c598aa5af484eeb8d2
- version: 1.0

## Description

MSL Liquidity Tails is a liquidity reaction indicator based on long candle wicks. It helps detect strong pin bar rejection candles and automatically projects potential supply and demand zones directly on the chart.
The indicator identifies candles with unusually long dominant wicks, filters them through volatility, candle-structure and signal-spacing conditions, and then builds visual zones from areas where price was strongly rejected.
A long upper wick creates a Sell Pressure zone.
A long lower wick creates a Buy Pressure zone.
Broken zones can remain visible as gray Ghost Zones, showing historical areas of previous price reaction.
The main purpose of the indicator is not to predict the market, but to highlight zones where price has already shown a noticeable reaction. These areas can be used as references for retests, market structure analysis, support/resistance work, and trade scenario planning.
1. Core idea
Many important market reactions begin with a failed price movement.
Price moves higher or lower, forms a long wick, and then closes away from the extreme. This type of candle often shows that the market tested a specific area, met strong opposition, and failed to hold that level.
MSL Liquidity Tails automatically marks these areas on the chart.
The indicator helps answer several practical questions:
• where price was sharply rejected;
• where buyers or sellers showed activity;
• which zones may be worth watching on a future retest;
• which broken zones may remain relevant as historical levels;
• where a support/resistance flip may appear after a zone break.
2. What the indicator shows
Sell Pressure zones
A red zone appears after a candle with a long upper wick.
This means price moved higher, but the move was rejected before the candle closed. This zone can be used as a potential supply, resistance, or sell-pressure reference area.
Important: a red zone does not mean price must fall. It only marks an area where sellers previously showed a noticeable reaction.
Buy Pressure zones
A green zone appears after a candle with a long lower wick.
This means price moved lower, but the move was rejected before the candle closed. This zone can be used as a potential demand, support, or buy-pressure reference area.
Important: a green zone does not mean price must rise. It only marks an area where buyers previously showed a noticeable reaction.
Ghost Zones
If price fully moves through an active zone, it can turn gray when Keep broken zones is enabled.
This zone is no longer treated as a fresh active reaction zone, but it remains on the chart as a historical reference. In some cases, broken zones may later work as support/resistance flip areas, but this scenario should always be confirmed with additional context.
3. Detection logic
The indicator uses several filters to avoid marking every random wick on the chart.
A new zone appears only when the candle passes all key conditions at the same time.
ATR filter
The wick must be large enough relative to current volatility.
The indicator uses ATR for this. This makes the detection adaptive to the selected instrument and timeframe: a quiet market is evaluated with one volatility context, while a more active market is evaluated with another.
Wick/Body filter
The wick must be large enough relative to the candle body.
This filter helps identify pin bar-style rejection candles rather than ordinary wide-range candles with balanced movement.
Wick Dominance filter
The active wick must be larger than the opposite wick.
For a Sell Pressure zone, the upper wick should dominate.
For a Buy Pressure zone, the lower wick should dominate.
This helps filter out unclear candles where neither side has a clearly expressed advantage.
Min Gap filter
A minimum number of bars must pass between new zones.
This filter reduces repeated zones and helps keep the chart cleaner, especially on volatile instruments.
4. Zone structure
Each active zone consists of several elements.
Zone body
The colored rectangle shows the wick area where price reaction was detected.
For Sell Pressure, the zone is built from the candle high to the upper edge of the candle body.
For Buy Pressure, the zone is built from the lower edge of the candle body to the candle low.
Mid-line
Each active zone has a dashed middle line.
It marks the 50% level of the zone and can be used as an additional reference during retests.
Volume label
The zone label shows the volume of the candle that created the zone.
Volume does not guarantee the strength of the level, but it provides useful context. Higher volume may indicate a more significant reaction when confirmed by price behavior, timeframe, and broader market structure.
Retest counter
The label also shows how many times price has returned to the zone.
Examples:
S: 261K x4
The Sell Pressure zone was formed on a candle with 261K volume, and price has returned to this zone four times.
B: 704K x3
The Buy Pressure zone was formed on a candle with 704K volume, and price has returned to this zone three times.
5. Zone lifecycle
Active zone
A new zone remains active until price fully breaks through it.
An active zone extends to the right side of the chart, keeps its color, displays the mid-line, and continues tracking retests.
Broken zone
If price fully moves through an active zone, the indicator treats it as broken.
If Keep broken zones is enabled, the zone becomes a gray ghost zone.
If Keep broken zones is disabled, the broken zone is removed from the chart.
Expired zone
Any zone is automatically removed after the value set in Max Age.
This helps prevent the chart from becoming overloaded with old areas that may no longer be relevant.
6. How to use the indicator
MSL Liquidity Tails is not a standalone trading system and does not provide ready-made buy or sell signals.
It is an analysis tool that highlights areas of interest. Trading decisions should only be made with additional context, such as market structure, trend direction, support and resistance levels, volume behavior, price action, and personal risk-management rules.
Potential LONG scenario
A LONG scenario may become interesting when price returns to an active green Buy Pressure zone, holds that area, and shows a buyer reaction.
The zone itself is not an entry point. It only marks an area where a trader may look for confirmation.
Potential SHORT scenario
A SHORT scenario may become interesting when price returns to an active red Sell Pressure zone, fails to hold above it, and shows a seller reaction.
The zone itself is not an entry point. It only marks an area where a trader may look for confirmation.
Potential FLIP scenario
A gray Ghost Zone can be used as a historical reference.
If price returns to a broken zone from the opposite side, this area may sometimes work as a support/resistance flip. This scenario also requires confirmation through price action and broader market context.
7. Suitable markets and timeframes
The indicator is best used on liquid instruments with enough volatility and clear price reactions.
Cryptocurrencies
Examples: BTC, ETH, SOL, ARB
Suggested timeframes: 15m, 1H, 4H, 1D
Crypto markets often produce long wicks, sharp sweeps, and fast price returns, so wick-based rejection zones can be useful for analysis.
US stocks
Examples: NVDA, TSLA, COIN, AAPL
Suggested timeframes: 1H, 4H, 1D
Liquid stocks often form strong rejection zones around news events, session opens, gaps, and strong intraday movements.
Forex majors
Examples: EURUSD, GBPUSD, USDJPY
Suggested timeframes: 1H, 4H
Major currency pairs can be useful for analyzing reactions around local extremes and key areas.
Indices
Examples: SPX, NDX, DAX
Suggested timeframes: 4H, 1D
Higher timeframes help reduce noise and make significant reaction zones easier to read.
Commodities
Examples: Gold, Oil
Suggested timeframes: 1H, 4H, 1D
Commodities often produce sharp spike movements during news, macro events, and session volatility, which can create clear rejection zones.
8. Main settings
ATR Period
The ATR period used to measure current volatility.
ATR Mult
Defines how large the wick must be relative to ATR.
Lower values create more zones but may add noise.
Higher values create fewer zones but apply stricter filtering.
Wick/Body
Defines the minimum wick-to-body ratio.
Higher values focus on cleaner pin bar-style structures.
Wick Dominance
Defines how strongly the active wick must dominate the opposite wick.
Higher values make the filter stricter and reduce the number of signals.
Min Gap
The minimum number of bars between new zones.
This helps avoid excessive signals and zone clustering.
Max Age
The number of bars after which a zone is automatically removed from the chart.
Opacity
Controls the transparency of active zones.
Keep broken zones
When enabled, broken zones remain visible as gray Ghost Zones.
When disabled, broken zones are removed after the break.
9. How to read the chart
It is best to read the chart with the indicator step by step.
First, identify active red and green zones.
Then check where price is relative to those zones.
When price returns to a zone, evaluate the reaction: hold, break, false break, or rejection.
Check whether the reaction aligns with the broader market structure.
Use additional confirmation before making any trading decision.
On the BTCUSDT chart, red zones show areas where price moved higher but was rejected. These zones can be watched as potential supply or resistance areas during future retests.
Green zones show areas where price moved lower but was bought back. These zones can be watched as potential demand or support areas.
Gray zones show older broken areas. They help identify where the market previously reacted and where future price interest may appear again.
10. Practical summary
MSL Liquidity Tails makes wick-based liquidity reactions easier to see and track.
The indicator is useful for:
• detecting strong rejection candles;
• building potential supply and demand zones;
• tracking live retests;
• keeping historical broken-zone context;
• analyzing support/resistance flips;
• building a cleaner market context around liquidity reactions.
The indicator works best as part of a complete analysis process, not as a mechanical signal generator.
Important notice
This indicator is intended for educational and analytical use only.
It is not financial or investment advice, does not provide guaranteed trading signals, and does not predict future price movement. All zones displayed on the chart are analytical references and should be evaluated together with market context, confirmation signals, and risk-management rules.
Trading involves risk. Users are fully responsible for their own trading decisions.[url=https://www.tradingview.com/x/bsuJ6oBM/]https://www.tradingview.com/x/bsuJ6oBM/[/url][image]https://www.tradingview.com/x/bsuJ6oBM/[/image]

## Source Code

````pine
// MSL Liquidity Tails — developed by MarketStructureLab.
// May your trades be green and your stops never hit. Good luck out there.
//@version=6
indicator("MSL Liquidity Tails", shorttitle="MSL Tails", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)
//==== INPUTS ====================================================================
groupCalc   = "Detection"
groupVisual = "Visual"
atrLen        = input.int(14,    "ATR Period",     minval=2,   maxval=100,  group=groupCalc, tooltip="ATR period used to calibrate wick size relative to current volatility.")
atrMult       = input.float(0.8, "ATR Mult",       minval=0.3, maxval=5.0,  step=0.1, group=groupCalc, tooltip="Wick must be at least this many times the ATR. Higher value = rarer, stronger signals.")
minWickRatio  = input.float(1.3, "Wick/Body",      minval=1.0, maxval=10.0, step=0.1, group=groupCalc, tooltip="Wick length relative to candle body. Pin bar shape filter. Higher = cleaner setups only.")
wickDominance = input.float(1.2, "Wick Dominance", minval=1.0, maxval=5.0,  step=0.1, group=groupCalc, tooltip="Active wick must be at least this many times the opposite wick. 1.0 = no opposite check (max signals), 2.0+ = pure pin bars only.")
minGap        = input.int(5,     "Min Gap",        minval=1,   maxval=200,  group=groupCalc, tooltip="Minimum bars between consecutive signals. Spam guard.")
maxAge        = input.int(500,   "Max Age",        minval=50,  maxval=5000, group=groupCalc, tooltip="Zone is auto-removed after this many bars regardless of state.")
bullColor   = input.color(color.rgb(0, 200, 100), "Bull/Bear", inline="col", group=groupVisual, tooltip="Green = Buy Pressure (lower wicks). Red = Sell Pressure (upper wicks).")
bearColor   = input.color(color.rgb(230, 60, 60), "",          inline="col", group=groupVisual)
zoneOpacity = input.int(75, "Opacity", minval=50, maxval=95, group=groupVisual, tooltip="Active zone fill opacity. 50 = saturated, 95 = nearly transparent.")
keepBroken  = input.bool(true, "Keep broken zones", group=groupVisual, tooltip="When ON, zones that price breaks through become gray ghosts and stay visible until Max Age (shows history of liquidity levels). When OFF, broken zones are deleted immediately.")
//==== COLORS ====================================================================
textColor    = chart.fg_color
ghostBorder  = color.new(color.gray, 40)
ghostFill    = color.new(color.gray, 90)
ghostMid     = color.new(color.gray, 60)
//==== HELPERS ===================================================================
zoneLabel(bool isTop, float v, int touches) =>
    volStr = (na(v) or v == 0) ? "n/a" : str.tostring(v, format.volume)
    (isTop ? "S: " : "B: ") + volStr + "\nx" + str.tostring(touches)
//==== CALCULATIONS ==============================================================
topShadow  = high - math.max(open, close)
botShadow  = math.min(open, close) - low
candleBody = math.max(math.abs(close - open), syminfo.mintick)
atrVal     = ta.atr(atrLen)
atrThresh   = atrMult * atrVal
ratioThresh = minWickRatio * candleBody
topAtrPass   = topShadow >= atrThresh
botAtrPass   = botShadow >= atrThresh
topRatioPass = topShadow >= ratioThresh
botRatioPass = botShadow >= ratioThresh
//==== SIGNAL ENGINE =============================================================
type LiqZone
    box   body
    line  midLine
    label tag
    bool  isTop
    float midPrice
    int   birthBar
    int   touches
    int   lastTouchBar
    float vol
    bool  spent
var array<LiqZone> zones       = array.new<LiqZone>()
var int            lastFireBar = 0
method dropZone(LiqZone z) =>
    z.body.delete()
    z.midLine.delete()
    z.tag.delete()
method markSpent(LiqZone z) =>
    z.body.set_border_color(ghostBorder)
    z.body.set_bgcolor(ghostFill)
    z.body.set_border_style(line.style_dashed)
    z.midLine.set_color(ghostMid)
    z.midLine.set_style(line.style_dotted)
    z.tag.delete()
    z.spent := true
topDominant = topShadow > botShadow * wickDominance
botDominant = botShadow > topShadow * wickDominance
sellFire = topAtrPass and topRatioPass and topDominant and bar_index - lastFireBar > minGap
buyFire  = botAtrPass and botRatioPass and botDominant and bar_index - lastFireBar > minGap
if barstate.isconfirmed
    if sellFire
        lastFireBar := bar_index
        zTop = high
        zBot = math.max(open, close)
        mid  = (zTop + zBot) / 2.0
        b = box.new(bar_index, zTop, bar_index + 20, zBot, border_color=bearColor, border_width=1, bgcolor=color.new(bearColor, zoneOpacity))
        m = line.new(bar_index, mid, bar_index + 20, mid, color=color.new(bearColor, 30), width=1, style=line.style_dashed)
        t = label.new(bar_index + 1, zTop, zoneLabel(true, volume, 0), style=label.style_label_down, color=color(na), textcolor=textColor, size=size.tiny)
        zones.push(LiqZone.new(b, m, t, true, mid, bar_index, 0, 0, volume, false))
    if buyFire
        lastFireBar := bar_index
        zTop = math.min(open, close)
        zBot = low
        mid  = (zTop + zBot) / 2.0
        b = box.new(bar_index, zTop, bar_index + 20, zBot, border_color=bullColor, border_width=1, bgcolor=color.new(bullColor, zoneOpacity))
        m = line.new(bar_index, mid, bar_index + 20, mid, color=color.new(bullColor, 30), width=1, style=line.style_dashed)
        t = label.new(bar_index + 1, zBot, zoneLabel(false, volume, 0), style=label.style_label_up, color=color(na), textcolor=textColor, size=size.tiny)
        zones.push(LiqZone.new(b, m, t, false, mid, bar_index, 0, 0, volume, false))
    // Reverse-iterate so removals don't shift remaining indices
    i = zones.size() - 1
    while i >= 0
        z = zones.get(i)
        isOlder = bar_index > z.birthBar
        tooOld  = bar_index - z.birthBar > maxAge
        if tooOld
            z.dropZone()
            zones.remove(i)
        else
            broken = isOlder and (z.isTop ? low >= z.body.get_top() : high <= z.body.get_bottom())
            if broken and not z.spent
                if keepBroken
                    z.markSpent()
                else
                    z.dropZone()
                    zones.remove(i)
            else if not z.spent
                z.body.set_right(bar_index + 20)
                z.midLine.set_x2(bar_index + 20)
                zEntry = z.isTop ? z.body.get_bottom() : z.body.get_top()
                inZone = isOlder and (z.isTop ? high >= zEntry : low <= zEntry)
                if inZone and bar_index - z.lastTouchBar > 2
                    z.touches      := z.touches + 1
                    z.lastTouchBar := bar_index
                    z.tag.set_text(zoneLabel(z.isTop, z.vol, z.touches))
        i := i - 1
//==== USAGE GUIDE ===============================================================
// MSL Liquidity Tails detects pin bars where price was aggressively rejected
// by a wick that's both:
//   1) at least atrMult x ATR long (volatility-relative size),
//   2) at least minWickRatio x body long (true pin bar shape).
//
// Long UPPER wick -> red Sell Pressure zone above the body (supply).
// Long LOWER wick -> green Buy Pressure zone below the body (demand).
//
// Each zone:
//   - extends right with a dashed mid line (50% level marker),
//   - shows origin volume + live retest counter,
//   - turns into a gray dashed "ghost" when price closes fully through it
//     (history of liquidity levels), or is deleted if Keep Broken is OFF,
//   - is removed after Max Age regardless of state.
//
// LONG : retest of a green active zone, hold + reaction -> buy idea.
// SHORT: retest of a red active zone,   hold + reaction -> sell idea.
// Ghost zones (gray) often act as flipped S/R on retest.
//
// Best on 1H / 4H / 1D for swing liquidity, 15m for intraday sweeps.
// Lower atrMult -> more zones (more noise). Higher minWickRatio -> cleaner pin bars only.
````
