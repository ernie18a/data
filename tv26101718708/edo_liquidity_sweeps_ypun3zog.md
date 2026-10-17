# Edo Liquidity Sweeps

- url: https://www.tradingview.com/script/YPuN3zog-Edo-Liquidity-Sweeps/
- type: indicator
- pine_id: PUB;d8e7d4d2db194ef5a9e95449f4cbba68
- version: 1.0

## Description

Edo Liquidity Sweeps — Detects Liquidity Sweeps of Swing Highs and Lows and Tracks Each One Through Detected, Confirmed and Faded States

[image]https://www.tradingview.com/x/XsomHaR5/[/image]

[image]https://www.tradingview.com/x/oI98jUhc/[/image]


Markets move toward liquidity. Above every relevant swing high rests buy-side liquidity — the stops of short positions and the breakout buy orders waiting there. Below every relevant swing low rests sell-side liquidity — the stops of longs and the breakout sells. Those order clusters act as magnets: very often price travels precisely to reach them. A liquidity sweep is the moment that happens and is rejected — price wicks beyond the level to take the resting liquidity, then closes back on the other side, the classic trap that leaves breakout traders offside and frequently turns price around.

Edo Liquidity Sweeps isolates that single event and, crucially, tracks what happens next. It marks each sweep on the chart and follows it through three clear states — Detected, Confirmed and Faded — so you can separate the sweeps that actually reversed price from the ones that failed, all validated on closed bars so the indicator does not repaint. It is the sweep specialist of the Edolab structure family, designed to pair with Edo Liquidity Zones, which maps the liquidity pools these sweeps take.

LIQUIDITY LEVELS: SWING HIGHS AND LOWS

Everything starts from the swings that define where liquidity sits. A swing high is confirmed when a candle has the highest high of its surroundings; a swing low, the lowest low. The size of that surroundings is set by the Swing Profile: Scalper (5 bars each side) tracks short-term liquidity for intraday work, Swing (10 bars, the default) is the balanced setting for 4H and daily, and Long Term (21 bars) watches only the liquidity of the major structures. Each confirmed swing high becomes a buy-side liquidity level to monitor, and each swing low a sell-side one, until price sweeps it.

SWEEP DETECTION

A sweep is detected, on closed bars only, when price pierces a level with a wick but closes on the opposite side. A bearish sweep: the candle's high takes a swing high (grabbing the buy-side liquidity) but the close stays below that level — price pierced the high and rejected it, an downward reversal is expected. A bullish sweep: the candle's low loses a swing low (grabbing the sell-side liquidity) but the close stays above it — price pierced the low and rejected it, an upward reversal is expected. At detection the indicator draws a dotted line at the swept level with a Sweep ▲ or Sweep ▼ label, and records the high and low of the sweep candle itself, which will later decide whether the sweep confirms or fails. A wick that pierces a level but closes back on the same side generates nothing.

THREE STATES: DETECTED, CONFIRMED, FADED

A sweep is not a one-candle signal. The indicator follows each one through three states, evaluated on every closed bar against the range of the sweep candle. Detected: the sweep has just happened and it is not yet known whether price will turn — a dotted line. Confirmed: price confirms the reversal by closing beyond the sweep candle's extreme in the expected direction — the line turns solid and bold and the label gains a ✓. Faded: price closes the opposite way, reclaiming the level, so the sweep failed — the line turns dashed and faded grey and the label gains a ✕. For a bullish sweep, confirmation is a close above the sweep candle's high and a fade is a close below its low; for a bearish sweep it is the mirror. This follow-through confirmation is what separates the operative sweeps from the anecdotal ones: a Confirmed sweep has proven the rejection had continuation, while a Faded one warns that the trap did not work and the level has genuinely been broken.

INFORMATION PANEL

The panel condenses the read into a compact table. It shows the Last Sweep with its direction (Bull ▲ / Bear ▼) and state, and the live count of sweeps in each state: Detected, Confirmed and Faded. The Confirmed-to-Faded ratio gives a quick sense of how reliable sweeps are behaving on that instrument and timeframe. The panel sits in any of the four chart corners (Top Right by default), comes in three sizes (Tiny / Small / Normal) and two themes (Dark / Light), and can be hidden entirely.

NO REPAINTING

Sweeps are validated on closed bars only and on confirmed pivots, so a level and its sweep never appear or disappear intrabar. A wick that pierces a level but closes back inside generates nothing — the indicator waits for the close. This removes the false signals that clutter tools which mark instantly, at the cost of confirming each sweep once it has completed. There are no higher-timeframe functions: all logic runs on the current chart timeframe.

CONFIGURATION

The inputs are grouped by block. Detection sets the swing profile and the maximum number of sweeps kept on the chart (12 by default). Style exposes the bullish and bearish sweep colours, the faded colour, the label size and the Dark/Light theme. Panel controls panel visibility, position and size. The defaults are calibrated to work without adjustment on stocks, crypto, forex, indices and futures, on any timeframe — the input most users touch is the Swing Profile, to match the sensitivity of the tracked liquidity to their horizon.

ALERTS

Five predefined alerts cover the life of a sweep: Bullish Sweep Detected and Bearish Sweep Detected fire the moment a sweep is detected; Bullish Sweep Confirmed and Bearish Sweep Confirmed fire when a sweep confirms its reversal through follow-through; and Sweep Faded fires when a sweep fails and the level is reclaimed. The Detected alerts are the earliest but least confirmed, the Confirmed alerts are more reliable at the cost of arriving later, and the Faded alert is useful to discard a reversal idea. All alerts fire on bar close, consistent with the indicator's anti-repaint validation.

HOW TO READ IT

Wait for confirmation: a Detected sweep only flags that liquidity was taken and rejected, not that price will turn — waiting for it to become Confirmed reduces false signals at the cost of entering later, and the panel's Confirmed-to-Faded ratio shows how trustworthy sweeps are being. Read the fade as a warning: when a sweep turns Faded, the trap did not work and the level was genuinely broken — recognising a failed sweep in time avoids forcing a reversal idea the market has already rejected. Trade sweeps in confluence: a confirmed sweep that takes liquidity at an important level, a demand zone or a higher-timeframe support is a far more solid reference than an isolated one. And pairing Edo Liquidity Sweeps with Edo Liquidity Zones closes the loop — the zones say where liquidity sits, the sweeps say when it is taken.

OPEN SOURCE

Edo Liquidity Sweeps is published as a free open source indicator. The full Pine Script is publicly accessible on TradingView for study, adaptation and integration into any workflow. Part of the Edolab Markets free tools ecosystem alongside Edo Liquidity Zones, Edo Smart Money Map, Edo Order Blocks, Edo ZigZag Auto Fib SR and more available on TradingView.

This indicator is a technical analysis tool for educational and informational purposes only. It does not generate automatic buy or sell signals and should not be considered financial advice. Trading financial markets involves significant risk of capital loss. Past performance does not guarantee future results. Always use proper risk management.


TAGS
LiquiditySweep SmartMoneyConcepts Liquidity MarketStructure PriceAction StopHunt SwingHighLow SupplyDemand Reversal Overlay Indicator OpenSource Edolab EdolabMarkets Stocks Crypto Forex Indices

CATEGORIES (TradingView dropdowns)
— Direction: Both
— Market category: All markets (Stocks / Crypto / Forex / Indices)
— Analysis type: Trend Analysis / Chart patterns / Support and Resistance

## Source Code

````pine
// ─────────────────────────────────────────────────────────────────
// ███████╗██████╗  ██████╗ ██╗      █████╗ ██████╗
// ██╔════╝██╔══██╗██╔═══██╗██║     ██╔══██╗██╔══██╗
// █████╗  ██║  ██║██║   ██║██║     ███████║██████╔╝
// ██╔══╝  ██║  ██║██║   ██║██║     ██╔══██║██╔══██╗
// ███████╗██████╔╝╚██████╔╝███████╗██║  ██║██████╔╝
// ╚══════╝╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═════╝
// ─────────────────────────────────────────────────────────────────
// ███╗   ███╗ █████╗ ██████╗ ██╗  ██╗███████╗████████╗███████╗
// ████╗ ████║██╔══██╗██╔══██╗██║ ██╔╝██╔════╝╚══██╔══╝██╔════╝
// ██╔████╔██║███████║██████╔╝█████╔╝ █████╗     ██║   ███████╗
// ██║╚██╔╝██║██╔══██║██╔══██╗██╔═██╗ ██╔══╝     ██║   ╚════██║
// ██║ ╚═╝ ██║██║  ██║██║  ██║██║  ██╗███████╗   ██║   ███████║
// ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝
// ─────────────────────────────────────────────────────────────────
// © Edolab Markets

//@version=6
indicator("Edo Liquidity Sweeps", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ================== SETTINGS — DETECTION ==================

profile  = input.string("Swing", "Swing Profile", options = ["Scalper", "Swing", "Long Term"], group = "Detection", tooltip = "Sensitivity of the swing pivots whose liquidity is tracked.\nScalper: fast · Swing: balanced · Long Term: major swings.")
maxEvents = input.int(12, "Max Sweeps Kept", minval = 2, maxval = 50, group = "Detection")

swingLen = profile == "Scalper" ? 5 : profile == "Long Term" ? 21 : 10

// ================== SETTINGS — STYLE ==================

bullCol   = input.color(#26a69a, "Bullish sweep", inline = "c1", group = "Style", tooltip = "Sweep of sell-side liquidity below a swing low (bullish reversal expected).")
bearCol   = input.color(#ef5350, "Bearish sweep", inline = "c1", group = "Style", tooltip = "Sweep of buy-side liquidity above a swing high (bearish reversal expected).")
fadeCol   = input.color(#787b86, "Faded", group = "Style")
labelSize = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal"], group = "Style")
themeMode = input.string("Dark",  "Theme Mode", options = ["Dark", "Light"], group = "Style", tooltip = "Match your TradingView background theme.")

// ================== SETTINGS — PANEL ==================

showPanel = input.bool(true, "Show Panel", group = "Panel")
panelPos  = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = "Panel")
panelSize = input.string("Small", "Panel Size", options = ["Tiny", "Small", "Normal"], group = "Panel")

// ================== THEME ==================

isDark   = themeMode == "Dark"
textCol  = isDark ? #ffffff : #131722
headerBg = isDark ? #2a2e39 : #d1d4dc
subBg    = isDark ? #363a45 : #e0e3eb
cellBg   = isDark ? #1e222d : #f0f3fa
cellTxt  = isDark ? #d1d4dc : #363a45

lblSizeTxt = labelSize == "Tiny" ? size.tiny : labelSize == "Normal" ? size.normal : size.small
panSizeTxt = panelSize == "Tiny" ? size.tiny : panelSize == "Normal" ? size.normal : size.small

// ================== SWING LIQUIDITY LEVELS ==================

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low,  swingLen, swingLen)

var float shLevel = na   // swing high = buy-side liquidity
var int   shBar   = na
var bool  shSwept = false
var float slLevel = na   // swing low  = sell-side liquidity
var int   slBar   = na
var bool  slSwept = false

if not na(ph)
    shLevel := ph
    shBar   := bar_index - swingLen
    shSwept := false
if not na(pl)
    slLevel := pl
    slBar   := bar_index - swingLen
    slSwept := false

// ================== SWEEP DETECTION (confirmed bars) ==================
// Bearish sweep: wick takes a swing high but price closes back below it.
// Bullish sweep: wick takes a swing low  but price closes back above it.

bearSweep = barstate.isconfirmed and not na(shLevel) and not shSwept and high > shLevel and close < shLevel
bullSweep = barstate.isconfirmed and not na(slLevel) and not slSwept and low  < slLevel and close > slLevel

// ================== SWEEP STORAGE ==================

var line[]  swLine    = array.new<line>()
var label[] swLbl     = array.new<label>()
var bool[]  swIsBull  = array.new<bool>()
var int[]   swState   = array.new<int>()   // 0 detected, 1 confirmed, 2 faded
var float[] swRefHigh = array.new<float>()
var float[] swRefLow  = array.new<float>()
var int[]   swStart   = array.new<int>()

var string lastSweep    = "—"
var color  lastSweepCol = na

newBull = false
newBear = false

makeSweep(bool isBull, float lvl, int lvlBar) =>
    col = isBull ? bullCol : bearCol
    ln  = line.new(lvlBar, lvl, bar_index, lvl, color = color.new(col, 0), width = 1, style = line.style_dotted)
    lb  = label.new(bar_index, isBull ? low : high, isBull ? "Sweep ▲" : "Sweep ▼", style = isBull ? label.style_label_up : label.style_label_down, color = color.new(col, 75), textcolor = col, size = lblSizeTxt)
    swLine.push(ln)
    swLbl.push(lb)
    swIsBull.push(isBull)
    swState.push(0)
    swRefHigh.push(high)
    swRefLow.push(low)
    swStart.push(bar_index)

if bearSweep
    makeSweep(false, shLevel, shBar)
    shSwept      := true
    newBear      := true
    lastSweep    := "Bear ▼ Detected"
    lastSweepCol := bearCol
if bullSweep
    makeSweep(true, slLevel, slBar)
    slSwept      := true
    newBull      := true
    lastSweep    := "Bull ▲ Detected"
    lastSweepCol := bullCol

// ================== SWEEP STATE — confirm / fade ==================

confBull = false
confBear = false
fadedAny = false

if swLine.size() > 0
    for i = swLine.size() - 1 to 0
        st = swState.get(i)
        if st == 0
            ln    = swLine.get(i)
            lb    = swLbl.get(i)
            isB   = swIsBull.get(i)
            rHigh = swRefHigh.get(i)
            rLow  = swRefLow.get(i)
            startB = swStart.get(i)
            if bar_index > startB
                line.set_x2(ln, bar_index)
                confirmed = isB ? close > rHigh : close < rLow
                faded     = isB ? close < rLow  : close > rHigh
                if confirmed
                    swState.set(i, 1)
                    col = isB ? bullCol : bearCol
                    line.set_style(ln, line.style_solid)
                    line.set_width(ln, 2)
                    label.set_text(lb, isB ? "Sweep ▲ ✓" : "Sweep ▼ ✓")
                    if isB
                        confBull := true
                        lastSweep := "Bull ▲ Confirmed"
                    else
                        confBear := true
                        lastSweep := "Bear ▼ Confirmed"
                    lastSweepCol := col
                else if faded
                    swState.set(i, 2)
                    line.set_color(ln, color.new(fadeCol, 30))
                    line.set_style(ln, line.style_dashed)
                    label.set_color(lb, color.new(fadeCol, 80))
                    label.set_textcolor(lb, fadeCol)
                    label.set_text(lb, isB ? "Sweep ▲ ✕" : "Sweep ▼ ✕")
                    fadedAny := true
                    lastSweep := (isB ? "Bull ▲" : "Bear ▼") + " Faded"
                    lastSweepCol := fadeCol

// ================== TRIM ==================

while swLine.size() > maxEvents
    line.delete(swLine.shift())
    label.delete(swLbl.shift())
    swIsBull.shift()
    swState.shift()
    swRefHigh.shift()
    swRefLow.shift()
    swStart.shift()

// ================== PANEL ==================

if showPanel and barstate.islast
    panelPosTV = switch panelPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

    var table panel = table.new(panelPosTV, 2, 5, frame_color = isDark ? #363a45 : #b2b5be, frame_width = 1, border_color = isDark ? #434651 : #c8cbda, border_width = 1)

    detCnt = 0
    cnfCnt = 0
    fadCnt = 0
    if swState.size() > 0
        for i = 0 to swState.size() - 1
            s = swState.get(i)
            if s == 0
                detCnt += 1
            else if s == 1
                cnfCnt += 1
            else
                fadCnt += 1

    evtCol = na(lastSweepCol) ? cellTxt : lastSweepCol

    table.cell(panel, 0, 0, "EDO LIQUIDITY SWEEPS", text_color = textCol, bgcolor = headerBg, text_size = panSizeTxt)
    table.merge_cells(panel, 0, 0, 1, 0)

    table.cell(panel, 0, 1, "Last Sweep", text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 1, lastSweep,    text_color = evtCol,  bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 2, "Detected",  text_color = cellTxt, bgcolor = subBg, text_size = panSizeTxt)
    table.cell(panel, 1, 2, str.tostring(detCnt), text_color = textCol, bgcolor = subBg, text_size = panSizeTxt)

    table.cell(panel, 0, 3, "Confirmed", text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 3, str.tostring(cnfCnt), text_color = #26a69a, bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 4, "Faded",     text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 4, str.tostring(fadCnt), text_color = color.new(fadeCol, 0), bgcolor = cellBg, text_size = panSizeTxt)

// ================== ALERTS ==================

alertcondition(newBull,  "Bullish Sweep Detected",  "Edo Liquidity Sweeps — Bullish sweep (sell-side liquidity taken) on {{ticker}}")
alertcondition(newBear,  "Bearish Sweep Detected",  "Edo Liquidity Sweeps — Bearish sweep (buy-side liquidity taken) on {{ticker}}")
alertcondition(confBull, "Bullish Sweep Confirmed", "Edo Liquidity Sweeps — Bullish sweep confirmed on {{ticker}}")
alertcondition(confBear, "Bearish Sweep Confirmed", "Edo Liquidity Sweeps — Bearish sweep confirmed on {{ticker}}")
alertcondition(fadedAny, "Sweep Faded",             "Edo Liquidity Sweeps — A liquidity sweep faded (failed) on {{ticker}}")
````
