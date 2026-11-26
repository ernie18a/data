# Confirmed Fibonacci with Market Structure

- url: https://www.tradingview.com/script/Tq0mhQIn-Confirmed-Fibonacci-with-Market-Structure/
- type: indicator
- pine_id: PUB;1635688f30a147109cd2e8c088fad4fc
- version: 1.0

## Description

Confirmed Fibonacci with Market Structure

-Description

A Fibonacci retracement tool for trend-continuation setups. It draws only after price has confirmed a directional move through market structure, then locks the levels in place so the pullback zone stays where it was set.

-What it does

The script applies three conditions before it draws a retracement, and once it draws, the anchors are fixed until the setup is invalidated:

- it requires a break of structure, not just any swing;
- it requires the impulse to be large enough relative to recent volatility;
- it can require agreement from the higher timeframe.

The result is a small number of retracements, drawn on moves that have shifted structure, that stay in place once set.

-How the detection works

1. Swing pivots. The script identifies swing highs and lows using pivot detection — a bar is a pivot high when it is the highest over a set number of bars to its left and right (the Pivot length input), and the reverse for a pivot low. These pivots define the prior swing and the structural reference levels.

2. Break of structure. For a bullish leg, the script takes the most recent prior swing low as the origin, then looks for an impulse high that trades above the last swing high formed before that low. Trading above that prior high is the break of structure — confirmation that buyers have shifted structure upward. The bearish case is the mirror image (a swing high origin, and an impulse low that breaks the prior swing low).

3. Displacement filter. The impulse is only accepted if its size (impulse high minus origin low) is at least a chosen multiple of ATR(14) — the Min displacement (ATR) input. Normalising to ATR judges a move on a quiet instrument and a volatile one on the same scale, and filters out small, insignificant structural breaks.

4. Draw timing. In Fast Draw mode the leg confirms on an asymmetric impulse pivot (fewer bars required to the right of the extreme), so the fib appears sooner after the high or low. With Fast Draw off, it instead waits for a completed pullback pivot before drawing — slower, but it only commits once a retracement is already underway.

-The Fibonacci leg and golden zone

When a bullish leg confirms, 0.0 is placed at the impulse high and 1.0 at the origin low, so the retracement levels measure how far price pulls back into the move (bearish legs are inverted). The shaded 0.618–0.786 band is the golden zone — the area where trend-continuation pullbacks commonly find support or resistance. A dashed line marks the broken structure level (BOS), and the impulse leg is labelled at its anchors (HH/HL for a bull leg, LH/LL for a bear leg).

-Higher-timeframe bias

The optional bias filter reads swing structure from the next standard timeframe up (for example, a 1-hour chart reads the 4-hour). That timeframe is rated bullish when its recent structure prints higher highs and higher lows, and bearish on lower highs and lower lows. With the filter on, the script only draws bullish legs in a bullish higher-timeframe context and bearish legs in a bearish one, and it clears the active leg if the higher timeframe flips against it. The request uses confirmed values with no lookahead.

-Invalidation and refresh

A bullish leg is invalidated when price closes below its origin low, with a small ATR buffer to absorb wicks; bearish legs mirror this. A leg is also cleared if it goes stale — when no new structure forms within a configurable number of bars. Until one of those happens, the anchors stay locked, so the levels on your chart are the same ones set when the leg confirmed.

-How to use it

This tool is built for trending markets and continuation trading, not ranges. The premise is simple: after a structure break and a displaced impulse, a trend often pauses and retraces before continuing in the same direction, and the golden zone is where that retracement commonly runs out of steam.

- Trade with the leg, into the pullback. On a confirmed bullish leg, treat the 0.618–0.786 golden zone as a pullback entry zone for longs — you are looking to join the move as price retraces into it, not to fade it. On a bearish leg, the same zone is where you look for shorts as price pulls back up into it.
- Use the higher-timeframe filter for alignment. Leaving HTF Bias on keeps you taking pullbacks in the direction of the larger trend, which is the context where continuation setups tend to hold up best. Turning it off shows every confirmed leg regardless of the bigger picture.
- Anchor risk to the structure the tool already marks. The origin (the 1.0 level, where the leg began) is the natural invalidation — a close back through it means the continuation idea has failed, which is also when the script clears the leg. Targets are typically toward the impulse extreme or beyond it. The BOS line shows the level whose break confirmed the move.
- Read the zone, don't blindly buy or sell it. The golden zone is an area of interest, not a trigger. Wait for your own confirmation inside it — a reaction candle, a lower-timeframe shift in structure, or whatever you normally use — before committing.
- The golden zone isn't the only level worth watching. Shallower retracements such as the 0.382 or the 0.500 often hold in strong trends that don't pull back far, while the deeper 0.618–0.786 zone tends to come into play on bigger retracements. Different instruments and timeframes react at different levels, so test which ones your pairs respect and toggle the levels you don't use off to keep the chart clean.
- Filter the chop. In ranging or low-momentum conditions a structure break is more likely to fail. Raise Min displacement (ATR) so the tool only draws on decisive moves, and set Pivot length to suit the timeframe (suggested starting points are in each input's tooltip).

-Inputs

-Structure

- Fast Draw (default on). On, the retracement is drawn as soon as the impulse, break of structure and displacement all confirm — the earliest possible draw. Off, it waits for a completed pullback pivot before drawing, which is slower but only commits once a retracement is already under way. Turning it off gives later but more conservative entries.
- Pivot length (default 8). Bars to the left and right used to confirm the structural swing highs and lows that define the prior swing and the break-of-structure reference. Higher values track larger, slower swings and draw fewer legs; lower values react to smaller swings and draw more. Rough starting points: 18 on 15m, 8 on 1h, 4 on 4h, 3 on daily.
- Impulse pivot R (default 3, Fast Draw only). The number of bars required to the right of the impulse extreme before it is accepted. Lower confirms the leg sooner after the high or low; higher waits for more confirmation, so the leg draws later but the extreme is more settled.
- Pullback pivot length (default 2, used only when Fast Draw is off). Bars left and right for the pullback pivot the script waits on before drawing. Lower draws faster on shallower pullbacks; higher requires a deeper, more developed pullback first.
- Min displacement (ATR) (default 1.5). The minimum impulse size, measured in ATR(14) units, before a structure break counts. Raising it ignores small moves and only draws on decisive ones; lowering it draws on smaller breaks too. As a guide: 0 accepts any impulse, 1.0 is modest, 1.5 is meaningful, 2.5 and up captures only major moves.
- Invalidation buffer (ATR) (default 0.25). A tolerance, in ATR(14) units, added beyond the origin before the leg is invalidated, so a single wick through the level doesn't cancel the setup. Higher gives the trade more room before it's cleared; lower invalidates more strictly.
- Max leg age (bars) (default 150). If no new structure forms within this many bars, the leg is treated as stale and cleared. Lower keeps only fresh setups on the chart; higher lets a quiet leg persist longer.
- Pivots retained (default 15). How many recent pivots the script keeps in memory to look back through when building a sequence. Higher allows it to reference older swings; lower keeps it focused on the most recent structure. Mostly affects edge cases — the default suits most charts.

HTF Bias

- Use HTF bias filter (default on). When on, the script only draws legs that agree with the higher-timeframe trend and clears a leg if that timeframe flips against it. Turning it off shows every confirmed leg regardless of the larger trend.
- HTF pivot length (default 3). Bars left and right used to read swing structure on the higher timeframe. Higher reads a broader, slower higher-timeframe trend; lower makes the bias more responsive.

Fib Levels

- 0.000 to 1.000 toggles. Switch each standard retracement level on or off independently, so you can show only the ones you trade.
- Custom level (default off, 0.75). Enables one extra level at a ratio you choose, with its own colour — useful for a level such as 0.705 or 0.79 that sits outside the standard set. Drawn alongside the standard levels.

Visual

- Colour Theme (default "Default"). Sets the dashboard colours and the fib line colour. Ten themes are included; purely cosmetic.
- 0.500 line color, Golden zone fill, Golden zone edge, Impulse line color, BOS line/label color. Individual colour controls for those specific elements, so you can tune contrast against your chart.
- Show BOS line + label (default on). Draws the dashed line at the broken structure level with a "BOS" tag. Off hides it for a cleaner chart.
- Show impulse line (default on). Draws the dashed line connecting the two anchors of the leg.
- Extend right (default on). Extends the level lines to the right of the current bar so they project forward; off ends them at the current bar.
- Price labels (default on). Shows the price value beside each level.
- Anchor markers (default on). Labels the two anchor points (HH/HL or LH/LL) of the leg.
- Info panel (default on). Shows the dashboard with structure state, higher-timeframe bias, anchor prices and how long ago the impulse confirmed.

Alerts

- Alert on new fib drawn (default on). Fires when a new bullish or bearish leg is drawn.
- Alert on Golden Zone touch (default on). Fires the first time price touches the golden zone of the active leg.

**Notes**

Swing pivots confirm a fixed number of bars after the actual high or low, so a leg appears after that confirmation delay rather than at the exact extreme — this is inherent to pivot-based detection. Once drawn, anchors are locked and do not move. The higher-timeframe bias uses confirmed values without lookahead, so it does not repaint on historical bars, though like any higher-timeframe data it can update within a forming higher-timeframe bar in real time. These levels are decision support, not buy or sell signals.

**Disclaimer**

This indicator is for educational and informational purposes only and is not financial or investment advice. Past performance does not guarantee future results. Always do your own analysis and manage your own risk.

## Source Code

````pine
//@version=6
// =============================================================================
// Confirmed Fibonacci with Market Structure — v6.0
// Auto-anchored Fibonacci retracement gated by market-structure confirmation.

indicator("Confirmed Fibonacci with Market Structure", overlay = true, max_lines_count = 100, max_labels_count = 100, max_boxes_count = 20)

// -------------------- INPUTS --------------------
grpS = "Structure"
fastDraw        = input.bool(true, "Fast Draw (skip pullback pivot)", group = grpS, tooltip = "ON: Fib draws as soon as impulse + BOS + displacement confirm. Earliest possible draw, anchors lock once drawn.\nOFF: original behaviour — waits for the pullback pivot before drawing.")
pivotLen        = input.int(8,    "Pivot length (L/R)",        minval = 1, maxval = 30, group = grpS, tooltip = "Bars left & right for STRUCTURAL pivots (prior swing + BOS reference).\n• 15M → 18\n• 1H → 8\n• 4H → 4\n• Daily → 3")
impulseR        = input.int(3,    "Impulse pivot R (Fast Draw)", minval = 1, maxval = 15, group = grpS, tooltip = "Right-side bars before the impulse extreme confirms (Fast Draw only).\nLower = Fib draws sooner relative to the impulse peak.\nWith anchor lock, the first detected impulse is locked even if a higher high prints later.\nSuggested: 3 standard, 2 fast, 5 conservative.")
pullbackPivotL  = input.int(2,    "Pullback pivot length (L/R)", minval = 1, maxval = 15, group = grpS, tooltip = "Only used when Fast Draw is OFF. Bars left & right for the PULLBACK pivot.\nLower = faster draw, weaker pullbacks. Suggested: 2 standard, 1 fast, 5 strict.")
displacementATR = input.float(1.5, "Min displacement (ATR)",   minval = 0.0, maxval = 10.0, step = 0.1, group = grpS, tooltip = "Minimum impulse size in ATR(14) units.\n• 0 → any impulse\n• 1.0 → modest\n• 1.5 → meaningful (default)\n• 2.5+ → major moves only")
invalidBufATR   = input.float(0.25, "Invalidation buffer (ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = grpS, tooltip = "Wick tolerance on close-below-priorLow (above-priorHigh) invalidation, in ATR(14) units.")
maxLegAgeBars   = input.int(150,  "Max leg age (bars)",        minval = 20, maxval = 2000, group = grpS, tooltip = "Auto-refresh: leg cleared if anchors haven't updated in this many bars.")
historyDepth    = input.int(15,   "Pivots retained",           minval = 6, maxval = 30, group = grpS, tooltip = "Recent pivots kept in memory for sequence lookback.")

grpB = "HTF Bias"
useBias    = input.bool(true, "Use HTF bias filter",  group = grpB, tooltip = "Bias auto-resolves to NEXT standard TF up.")
biasPivotL = input.int(3,     "HTF pivot length (L/R)", minval = 1, maxval = 15, group = grpB)

grpF = "Fib Levels"
lvl0    = input.bool(true, "0.000", group = grpF, inline = "a")
lvl236  = input.bool(true, "0.236", group = grpF, inline = "a")
lvl382  = input.bool(true, "0.382", group = grpF, inline = "b")
lvl5    = input.bool(true, "0.500", group = grpF, inline = "b")
lvl618  = input.bool(true, "0.618", group = grpF, inline = "c")
lvl786  = input.bool(true, "0.786", group = grpF, inline = "c")
lvl1    = input.bool(true, "1.000", group = grpF, inline = "d")
useCustom   = input.bool(false, "Custom level",                 group = grpF, inline = "e", tooltip = "Enable a single custom fib level (e.g. 0.705, 0.75, 0.79). Drawn alongside the standard levels.")
customLevel = input.float(0.75, "",                             minval = 0.0, maxval = 1.0, step = 0.001, group = grpF, inline = "e")
customColor = input.color(color.rgb(0, 220, 200), "",           group = grpF, inline = "e")

grpV = "Visual"
themeStr    = input.string("Default", "Colour Theme", options = ["Default", "Midnight", "Stealth", "Blood Red", "Matrix", "Arctic", "Neon Orange", "Royal Blue", "Forest", "Monochrome"], group = grpV, tooltip = "Drives dashboard colours and fib line colour.")
midColor    = input.color(color.rgb(160, 160, 170),    "0.500 line color",    group = grpV)
goldFill    = input.color(color.new(#FFD700, 80),      "Golden zone fill",    group = grpV)
goldEdge    = input.color(color.new(#B8860B, 40),      "Golden zone edge",    group = grpV)
impulseCol  = input.color(color.rgb(140, 140, 160),    "Impulse line color",  group = grpV)
showBOS     = input.bool(true, "Show BOS line + label",         group = grpV, tooltip = "Draws a dashed line at the broken pivot level (the level the impulse cleared to confirm Break of Structure), with a 'BOS' label centered on the line.")
bosColor    = input.color(color.rgb(255, 215, 0),     "BOS line/label color", group = grpV)
showImpulse = input.bool(true,  "Show impulse line", group = grpV)
extendRight = input.bool(true,  "Extend right",   group = grpV)
showLabels  = input.bool(true,  "Price labels",   group = grpV)
showAnchors = input.bool(true,  "Anchor markers", group = grpV)
showInfo    = input.bool(true,  "Info panel",     group = grpV)

grpA = "Alerts"
alertOnNewFib = input.bool(true, "Alert on new fib drawn",      group = grpA)
alertOnZone   = input.bool(true, "Alert on Golden Zone touch",  group = grpA)

// -------------------- THEME PALETTES --------------------
color cBg_P     = color.rgb(8,   0,  15)
color cPanel_P  = color.rgb(15,  0,  32)
color cHeader_P = color.rgb(22,  0,  48)
color cBrand_P  = color.rgb(28,  0,  58)
color cFrame_P  = color.rgb(204, 0, 255)
color cGrid_P   = color.rgb(28,  0,  58)
color cFib_P    = color.rgb(156, 39, 176)
color cBull_P   = color.rgb(0,   255, 160)
color cBear_P   = color.rgb(255, 70,  70)

color cBg_M     = color.rgb(5,   5,    8)
color cPanel_M  = color.rgb(10,  10,  14)
color cHeader_M = color.rgb(15,  15,  22)
color cBrand_M  = color.rgb(18,  18,  28)
color cFrame_M  = color.rgb(0,   210, 255)
color cGrid_M   = color.rgb(18,  18,  28)
color cFib_M    = color.rgb(0,   210, 255)
color cBull_M   = color.rgb(0,   255, 160)
color cBear_M   = color.rgb(255, 70,  70)

color cBg_S     = color.rgb(18,  18,  18)
color cPanel_S  = color.rgb(26,  26,  26)
color cHeader_S = color.rgb(34,  34,  34)
color cBrand_S  = color.rgb(40,  40,  40)
color cFrame_S  = color.rgb(200, 160, 40)
color cGrid_S   = color.rgb(40,  40,  40)
color cFib_S    = color.rgb(200, 160, 40)
color cBull_S   = color.rgb(80,  200, 80)
color cBear_S   = color.rgb(220, 60,  60)

color cBg_R     = color.rgb(10,  0,   0)
color cPanel_R  = color.rgb(20,  0,   0)
color cHeader_R = color.rgb(32,  0,   0)
color cBrand_R  = color.rgb(42,  0,   0)
color cFrame_R  = color.rgb(220, 0,   0)
color cGrid_R   = color.rgb(42,  0,   0)
color cFib_R    = color.rgb(220, 0,   0)
color cBull_R   = color.rgb(255, 80,  80)
color cBear_R   = color.rgb(180, 0,   0)

color cBg_X     = color.rgb(0,   5,   0)
color cPanel_X  = color.rgb(0,   10,  0)
color cHeader_X = color.rgb(0,   18,  0)
color cBrand_X  = color.rgb(0,   24,  0)
color cFrame_X  = color.rgb(0,   255, 70)
color cGrid_X   = color.rgb(0,   24,  0)
color cFib_X    = color.rgb(0,   255, 70)
color cBull_X   = color.rgb(0,   255, 70)
color cBear_X   = color.rgb(0,   180, 50)

color cBg_A     = color.rgb(5,   10,  18)
color cPanel_A  = color.rgb(8,   16,  28)
color cHeader_A = color.rgb(12,  22,  40)
color cBrand_A  = color.rgb(15,  28,  50)
color cFrame_A  = color.rgb(140, 210, 255)
color cGrid_A   = color.rgb(15,  28,  50)
color cFib_A    = color.rgb(140, 210, 255)
color cBull_A   = color.rgb(140, 220, 255)
color cBear_A   = color.rgb(80,  160, 220)

color cBg_O     = color.rgb(12,  6,   0)
color cPanel_O  = color.rgb(22,  10,  0)
color cHeader_O = color.rgb(32,  14,  0)
color cBrand_O  = color.rgb(40,  18,  0)
color cFib_O    = color.rgb(255, 120, 0)
color cFrame_O  = color.rgb(255, 120, 0)
color cGrid_O   = color.rgb(40,  18,  0)
color cBull_O   = color.rgb(255, 160, 40)
color cBear_O   = color.rgb(200, 80,  0)

color cBg_B     = color.rgb(4,   6,   18)
color cPanel_B  = color.rgb(6,   10,  30)
color cHeader_B = color.rgb(8,   14,  44)
color cBrand_B  = color.rgb(10,  18,  56)
color cFrame_B  = color.rgb(40,  120, 255)
color cGrid_B   = color.rgb(10,  18,  56)
color cFib_B    = color.rgb(40,  120, 255)
color cBull_B   = color.rgb(100, 180, 255)
color cBear_B   = color.rgb(40,  80,  200)

color cBg_F     = color.rgb(4,   12,  4)
color cPanel_F  = color.rgb(6,   20,  6)
color cHeader_F = color.rgb(8,   28,  8)
color cBrand_F  = color.rgb(10,  36,  10)
color cFrame_F  = color.rgb(100, 255, 50)
color cGrid_F   = color.rgb(10,  36,  10)
color cFib_F    = color.rgb(100, 255, 50)
color cBull_F   = color.rgb(100, 255, 50)
color cBear_F   = color.rgb(50,  180, 20)

color cBg_Mo     = color.rgb(8,   8,   8)
color cPanel_Mo  = color.rgb(16,  16,  16)
color cHeader_Mo = color.rgb(26,  26,  26)
color cBrand_Mo  = color.rgb(34,  34,  34)
color cFrame_Mo  = color.rgb(220, 220, 220)
color cGrid_Mo   = color.rgb(34,  34,  34)
color cFib_Mo    = color.rgb(220, 220, 220)
color cBull_Mo   = color.rgb(200, 200, 200)
color cBear_Mo   = color.rgb(120, 120, 120)

color cBg     = themeStr == "Midnight" ? cBg_M     : themeStr == "Stealth" ? cBg_S     : themeStr == "Blood Red" ? cBg_R     : themeStr == "Matrix" ? cBg_X     : themeStr == "Arctic" ? cBg_A     : themeStr == "Neon Orange" ? cBg_O     : themeStr == "Royal Blue" ? cBg_B     : themeStr == "Forest" ? cBg_F     : themeStr == "Monochrome" ? cBg_Mo     : cBg_P
color cPanel  = themeStr == "Midnight" ? cPanel_M  : themeStr == "Stealth" ? cPanel_S  : themeStr == "Blood Red" ? cPanel_R  : themeStr == "Matrix" ? cPanel_X  : themeStr == "Arctic" ? cPanel_A  : themeStr == "Neon Orange" ? cPanel_O  : themeStr == "Royal Blue" ? cPanel_B  : themeStr == "Forest" ? cPanel_F  : themeStr == "Monochrome" ? cPanel_Mo  : cPanel_P
color cHeader = themeStr == "Midnight" ? cHeader_M : themeStr == "Stealth" ? cHeader_S : themeStr == "Blood Red" ? cHeader_R : themeStr == "Matrix" ? cHeader_X : themeStr == "Arctic" ? cHeader_A : themeStr == "Neon Orange" ? cHeader_O : themeStr == "Royal Blue" ? cHeader_B : themeStr == "Forest" ? cHeader_F : themeStr == "Monochrome" ? cHeader_Mo : cHeader_P
color cBrand  = themeStr == "Midnight" ? cBrand_M  : themeStr == "Stealth" ? cBrand_S  : themeStr == "Blood Red" ? cBrand_R  : themeStr == "Matrix" ? cBrand_X  : themeStr == "Arctic" ? cBrand_A  : themeStr == "Neon Orange" ? cBrand_O  : themeStr == "Royal Blue" ? cBrand_B  : themeStr == "Forest" ? cBrand_F  : themeStr == "Monochrome" ? cBrand_Mo  : cBrand_P
color cFrame  = themeStr == "Midnight" ? cFrame_M  : themeStr == "Stealth" ? cFrame_S  : themeStr == "Blood Red" ? cFrame_R  : themeStr == "Matrix" ? cFrame_X  : themeStr == "Arctic" ? cFrame_A  : themeStr == "Neon Orange" ? cFrame_O  : themeStr == "Royal Blue" ? cFrame_B  : themeStr == "Forest" ? cFrame_F  : themeStr == "Monochrome" ? cFrame_Mo  : cFrame_P
color cGrid   = themeStr == "Midnight" ? cGrid_M   : themeStr == "Stealth" ? cGrid_S   : themeStr == "Blood Red" ? cGrid_R   : themeStr == "Matrix" ? cGrid_X   : themeStr == "Arctic" ? cGrid_A   : themeStr == "Neon Orange" ? cGrid_O   : themeStr == "Royal Blue" ? cGrid_B   : themeStr == "Forest" ? cGrid_F   : themeStr == "Monochrome" ? cGrid_Mo   : cGrid_P
color cFib    = themeStr == "Midnight" ? cFib_M    : themeStr == "Stealth" ? cFib_S    : themeStr == "Blood Red" ? cFib_R    : themeStr == "Matrix" ? cFib_X    : themeStr == "Arctic" ? cFib_A    : themeStr == "Neon Orange" ? cFib_O    : themeStr == "Royal Blue" ? cFib_B    : themeStr == "Forest" ? cFib_F    : themeStr == "Monochrome" ? cFib_Mo    : cFib_P
color cBull   = themeStr == "Midnight" ? cBull_M   : themeStr == "Stealth" ? cBull_S   : themeStr == "Blood Red" ? cBull_R   : themeStr == "Matrix" ? cBull_X   : themeStr == "Arctic" ? cBull_A   : themeStr == "Neon Orange" ? cBull_O   : themeStr == "Royal Blue" ? cBull_B   : themeStr == "Forest" ? cBull_F   : themeStr == "Monochrome" ? cBull_Mo   : cBull_P
color cBear   = themeStr == "Midnight" ? cBear_M   : themeStr == "Stealth" ? cBear_S   : themeStr == "Blood Red" ? cBear_R   : themeStr == "Matrix" ? cBear_X   : themeStr == "Arctic" ? cBear_A   : themeStr == "Neon Orange" ? cBear_O   : themeStr == "Royal Blue" ? cBear_B   : themeStr == "Forest" ? cBear_F   : themeStr == "Monochrome" ? cBear_Mo   : cBear_P

color cText   = color.rgb(235, 235, 235)
color cSub    = color.rgb(150, 150, 160)
color cDim    = color.rgb(110, 110, 125)

color brandBG  = color.new(cBrand,  0)
color headerBG = color.new(cHeader, 0)
color panelBG  = color.new(cPanel,  0)
color frameCl  = color.new(cFrame,  0)
color gridCl   = color.new(cGrid,   0)

// -------------------- DYNAMIC HTF BIAS TF --------------------
int chartSec = timeframe.in_seconds(timeframe.period)
int sec1H    = timeframe.in_seconds("60")
int sec4H    = timeframe.in_seconds("240")
int secD     = timeframe.in_seconds("D")
int secW     = timeframe.in_seconds("W")
int secM     = timeframe.in_seconds("M")

string biasTF        = chartSec < sec1H ? "60" : chartSec < sec4H ? "240" : chartSec < secD ? "D" : chartSec < secW ? "W" : chartSec < secM ? "M" : ""
bool   biasAvailable = biasTF != ""
bool   effBias       = useBias and biasAvailable

string biasTFname = ""
if biasTF == "60"
    biasTFname := "1H"
else if biasTF == "240"
    biasTFname := "4H"
else if biasTF == "D"
    biasTFname := "Daily"
else if biasTF == "W"
    biasTFname := "Weekly"
else if biasTF == "M"
    biasTFname := "Monthly"

// -------------------- PIVOTS --------------------
// Conservative structural pivots (L=R=pivotLen) — for prior swings + BOS reference.
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,   pivotLen, pivotLen)

// Asymmetric impulse pivots (L=pivotLen, R=impulseR) — for Fast Draw impulse extremes.
phFast = ta.pivothigh(high, pivotLen, impulseR)
plFast = ta.pivotlow(low,   pivotLen, impulseR)

// Pullback pivots (only used when Fast Draw is OFF).
phPull = ta.pivothigh(high, pullbackPivotL, pullbackPivotL)
plPull = ta.pivotlow(low,   pullbackPivotL, pullbackPivotL)

var float[] phPrices = array.new_float()
var int[]   phBars   = array.new_int()
var float[] plPrices = array.new_float()
var int[]   plBars   = array.new_int()

var float[] phFastPrices = array.new_float()
var int[]   phFastBars   = array.new_int()
var float[] plFastPrices = array.new_float()
var int[]   plFastBars   = array.new_int()

var float[] phPullPrices = array.new_float()
var int[]   phPullBars   = array.new_int()
var float[] plPullPrices = array.new_float()
var int[]   plPullBars   = array.new_int()

if not na(ph)
    array.push(phPrices, ph)
    array.push(phBars,   bar_index - pivotLen)
    if array.size(phPrices) > historyDepth
        array.shift(phPrices)
        array.shift(phBars)
if not na(pl)
    array.push(plPrices, pl)
    array.push(plBars,   bar_index - pivotLen)
    if array.size(plPrices) > historyDepth
        array.shift(plPrices)
        array.shift(plBars)

if not na(phFast)
    array.push(phFastPrices, phFast)
    array.push(phFastBars,   bar_index - impulseR)
    if array.size(phFastPrices) > historyDepth
        array.shift(phFastPrices)
        array.shift(phFastBars)
if not na(plFast)
    array.push(plFastPrices, plFast)
    array.push(plFastBars,   bar_index - impulseR)
    if array.size(plFastPrices) > historyDepth
        array.shift(plFastPrices)
        array.shift(plFastBars)

if not na(phPull)
    array.push(phPullPrices, phPull)
    array.push(phPullBars,   bar_index - pullbackPivotL)
    if array.size(phPullPrices) > historyDepth
        array.shift(phPullPrices)
        array.shift(phPullBars)
if not na(plPull)
    array.push(plPullPrices, plPull)
    array.push(plPullBars,   bar_index - pullbackPivotL)
    if array.size(plPullPrices) > historyDepth
        array.shift(plPullPrices)
        array.shift(plPullBars)

// -------------------- HTF STRUCTURAL BIAS --------------------
f_structBias() =>
    pHi = ta.pivothigh(high, biasPivotL, biasPivotL)
    pLo = ta.pivotlow(low,   biasPivotL, biasPivotL)
    lastPH  = ta.valuewhen(not na(pHi), pHi, 0)
    priorPH = ta.valuewhen(not na(pHi), pHi, 1)
    lastPL  = ta.valuewhen(not na(pLo), pLo, 0)
    priorPL = ta.valuewhen(not na(pLo), pLo, 1)
    bull = not na(lastPH) and not na(priorPH) and not na(lastPL) and not na(priorPL) and lastPH > priorPH and lastPL > priorPL
    bear = not na(lastPH) and not na(priorPH) and not na(lastPL) and not na(priorPL) and lastPH < priorPH and lastPL < priorPL
    bull ? 1 : bear ? -1 : 0

string biasTFsafe = biasAvailable ? biasTF : "D"
structB = request.security(syminfo.tickerid, biasTFsafe, f_structBias(), barmerge.gaps_off, barmerge.lookahead_off)

int htfBias = not effBias ? 0 : structB

atr14 = ta.atr(14)

// -------------------- STATE --------------------
var int    trend       = 0
var float  anchorHi    = na
var int    anchorHiBar = na
var float  anchorLo    = na
var int    anchorLoBar = na
var string stateStr    = "No Active Structure"
var int    stickyAge   = 0

var float  zoneTop        = na
var float  zoneBot        = na
var bool   zoneAlertFired = false

// BOS visualization state
var float  bosRefStored      = na   // price level of broken pivot
var int    bosRefBarStored   = na   // bar where broken pivot originally formed
var int    bosBreakBarStored = na   // bar where impulse first pierced bosRef (wick)

bool newBullFib = false
bool newBearFib = false

// -------------------- DRAWING --------------------
var line[]  fibLines    = array.new_line()
var label[] fibLabels   = array.new_label()
var box     goldBox     = na
var label   anchorHiLbl = na
var label   anchorLoLbl = na
var line    impulseLine = na
var line    bosLineDraw  = na
var label   bosLabelDraw = na

var table info = table.new(position.top_right, 2, 6, bgcolor = color.new(cBg, 0), border_width = 0, border_color = gridCl, frame_color = frameCl, frame_width = 2)

f_clearDrawings() =>
    if array.size(fibLines) > 0
        for i = 0 to array.size(fibLines) - 1
            line.delete(array.get(fibLines, i))
        array.clear(fibLines)
    if array.size(fibLabels) > 0
        for i = 0 to array.size(fibLabels) - 1
            label.delete(array.get(fibLabels, i))
        array.clear(fibLabels)
    if not na(goldBox)
        box.delete(goldBox)
    if not na(anchorHiLbl)
        label.delete(anchorHiLbl)
    if not na(anchorLoLbl)
        label.delete(anchorLoLbl)
    if not na(impulseLine)
        line.delete(impulseLine)
    if not na(bosLineDraw)
        line.delete(bosLineDraw)
    if not na(bosLabelDraw)
        label.delete(bosLabelDraw)

// -------------------- HTF BIAS CONFLICT RESET --------------------
if effBias and trend == 1 and htfBias == -1
    trend       := 0
    anchorHi    := na
    anchorHiBar := na
    anchorLo    := na
    anchorLoBar := na
    bosRefStored      := na
    bosRefBarStored   := na
    bosBreakBarStored := na
    stateStr    := "Conflict with Higher Timeframe"
    stickyAge   := 0
    zoneTop     := na
    zoneBot     := na
    zoneAlertFired := false
    f_clearDrawings()
else if effBias and trend == -1 and htfBias == 1
    trend       := 0
    anchorHi    := na
    anchorHiBar := na
    anchorLo    := na
    anchorLoBar := na
    bosRefStored      := na
    bosRefBarStored   := na
    bosBreakBarStored := na
    stateStr    := "Conflict with Higher Timeframe"
    stickyAge   := 0
    zoneTop     := na
    zoneBot     := na
    zoneAlertFired := false
    f_clearDrawings()

// -------------------- BULL SEQUENCE --------------------
// Fast Draw: triggers on phFast (asymmetric impulse pivot), uses slower pl/ph for priorLow + BOS.
// Strict mode: triggers on pullback pivot.
bool bullTrig = fastDraw ? not na(phFast) : not na(plPull)

if bullTrig and array.size(plBars) >= 1 and array.size(phBars) >= 1
    bool bullAllowed = (not effBias) or htfBias == 1
    if bullAllowed
        int   refBar       = na
        if fastDraw
            refBar := array.get(phFastBars, array.size(phFastBars) - 1)
        else
            refBar := array.get(plPullBars, array.size(plPullBars) - 1)

        float priorLow    = na
        int   priorLowBar = na
        for i = array.size(plBars) - 1 to 0
            int b = array.get(plBars, i)
            if b < refBar
                priorLowBar := b
                priorLow    := array.get(plPrices, i)
                break

        float impulseHH    = na
        int   impulseHHBar = na
        if fastDraw
            int   latestPhBar   = array.get(phFastBars, array.size(phFastBars) - 1)
            float latestPhPrice = array.get(phFastPrices, array.size(phFastBars) - 1)
            if not na(priorLowBar) and latestPhBar > priorLowBar
                impulseHH    := latestPhPrice
                impulseHHBar := latestPhBar
        else
            if not na(priorLowBar)
                for i = 0 to array.size(phBars) - 1
                    int b = array.get(phBars, i)
                    if b > priorLowBar and b < refBar
                        float p = array.get(phPrices, i)
                        if na(impulseHH) or p > impulseHH
                            impulseHH    := p
                            impulseHHBar := b

        // BOS reference + its bar
        float bosRef     = na
        int   bosRefBar  = na
        if not na(priorLowBar) and array.size(phBars) > 0
            for i = array.size(phBars) - 1 to 0
                int b = array.get(phBars, i)
                if b < priorLowBar
                    bosRef    := array.get(phPrices, i)
                    bosRefBar := b
                    break

        bool pullbackOk = true
        if not fastDraw and array.size(plPullBars) >= 1
            float candHL = array.get(plPullPrices, array.size(plPullPrices) - 1)
            pullbackOk := not na(impulseHH) and not na(priorLow) and candHL > priorLow and candHL < impulseHH

        bool seqOk = not na(priorLow) and not na(impulseHH) and not na(bosRef) and impulseHH > bosRef and (impulseHH - priorLow) >= displacementATR * atr14 and pullbackOk

        if seqOk
            // LOCK: only update anchors on trend entry
            if trend != 1
                trend       := 1
                anchorHi    := impulseHH
                anchorHiBar := impulseHHBar
                anchorLo    := priorLow
                anchorLoBar := priorLowBar

                // store BOS data for visualization
                bosRefStored    := bosRef
                bosRefBarStored := bosRefBar

                // Find break bar — first bar after priorLow whose HIGH pierced bosRef (wick counts)
                bosBreakBarStored := na
                if not na(priorLowBar) and not na(impulseHHBar) and impulseHHBar > priorLowBar
                    int barsBackStart = bar_index - priorLowBar - 1
                    int barsBackEnd   = bar_index - impulseHHBar
                    if barsBackStart >= barsBackEnd and barsBackStart >= 0
                        for off = barsBackStart to barsBackEnd
                            if high[off] > bosRef
                                bosBreakBarStored := bar_index - off
                                break

                stateStr    := "Bull Structure Detected"
                stickyAge   := 0
                zoneAlertFired := false
                newBullFib  := true
                f_clearDrawings()

// -------------------- BEAR SEQUENCE --------------------
bool bearTrig = fastDraw ? not na(plFast) : not na(phPull)

if bearTrig and array.size(phBars) >= 1 and array.size(plBars) >= 1
    bool bearAllowed = (not effBias) or htfBias == -1
    if bearAllowed
        int refBar = na
        if fastDraw
            refBar := array.get(plFastBars, array.size(plFastBars) - 1)
        else
            refBar := array.get(phPullBars, array.size(phPullBars) - 1)

        float priorHigh    = na
        int   priorHighBar = na
        for i = array.size(phBars) - 1 to 0
            int b = array.get(phBars, i)
            if b < refBar
                priorHighBar := b
                priorHigh    := array.get(phPrices, i)
                break

        float impulseLL    = na
        int   impulseLLBar = na
        if fastDraw
            int   latestPlBar   = array.get(plFastBars, array.size(plFastBars) - 1)
            float latestPlPrice = array.get(plFastPrices, array.size(plFastBars) - 1)
            if not na(priorHighBar) and latestPlBar > priorHighBar
                impulseLL    := latestPlPrice
                impulseLLBar := latestPlBar
        else
            if not na(priorHighBar)
                for i = 0 to array.size(plBars) - 1
                    int b = array.get(plBars, i)
                    if b > priorHighBar and b < refBar
                        float p = array.get(plPrices, i)
                        if na(impulseLL) or p < impulseLL
                            impulseLL    := p
                            impulseLLBar := b

        // BOS reference + its bar
        float bosRefLow    = na
        int   bosRefLowBar = na
        if not na(priorHighBar) and array.size(plBars) > 0
            for i = array.size(plBars) - 1 to 0
                int b = array.get(plBars, i)
                if b < priorHighBar
                    bosRefLow    := array.get(plPrices, i)
                    bosRefLowBar := b
                    break

        bool pullbackOk = true
        if not fastDraw and array.size(phPullBars) >= 1
            float candLH = array.get(phPullPrices, array.size(phPullPrices) - 1)
            pullbackOk := not na(impulseLL) and not na(priorHigh) and candLH < priorHigh and candLH > impulseLL

        bool seqOk = not na(priorHigh) and not na(impulseLL) and not na(bosRefLow) and impulseLL < bosRefLow and (priorHigh - impulseLL) >= displacementATR * atr14 and pullbackOk

        if seqOk
            // LOCK: only update anchors on trend entry
            if trend != -1
                trend       := -1
                anchorHi    := priorHigh
                anchorHiBar := priorHighBar
                anchorLo    := impulseLL
                anchorLoBar := impulseLLBar

                // store BOS data for visualization
                bosRefStored    := bosRefLow
                bosRefBarStored := bosRefLowBar

                // Find break bar — first bar after priorHigh whose LOW pierced bosRefLow (wick counts)
                bosBreakBarStored := na
                if not na(priorHighBar) and not na(impulseLLBar) and impulseLLBar > priorHighBar
                    int barsBackStart = bar_index - priorHighBar - 1
                    int barsBackEnd   = bar_index - impulseLLBar
                    if barsBackStart >= barsBackEnd and barsBackStart >= 0
                        for off = barsBackStart to barsBackEnd
                            if low[off] < bosRefLow
                                bosBreakBarStored := bar_index - off
                                break

                stateStr    := "Bear Structure Detected"
                stickyAge   := 0
                zoneAlertFired := false
                newBearFib  := true
                f_clearDrawings()

// -------------------- INVALIDATION --------------------
if trend == 1 and not na(anchorLo) and close < anchorLo - invalidBufATR * atr14
    trend       := 0
    anchorHi    := na
    anchorHiBar := na
    anchorLo    := na
    anchorLoBar := na
    bosRefStored      := na
    bosRefBarStored   := na
    bosBreakBarStored := na
    stateStr    := "Bull Structure Broken"
    stickyAge   := 0
    zoneTop     := na
    zoneBot     := na
    zoneAlertFired := false
    f_clearDrawings()
else if trend == -1 and not na(anchorHi) and close > anchorHi + invalidBufATR * atr14
    trend       := 0
    anchorHi    := na
    anchorHiBar := na
    anchorLo    := na
    anchorLoBar := na
    bosRefStored      := na
    bosRefBarStored   := na
    bosBreakBarStored := na
    stateStr    := "Bear Structure Broken"
    stickyAge   := 0
    zoneTop     := na
    zoneBot     := na
    zoneAlertFired := false
    f_clearDrawings()

// -------------------- LEG STALENESS --------------------
if trend != 0 and not na(anchorHiBar) and not na(anchorLoBar)
    int youngestAnchor = math.max(anchorHiBar, anchorLoBar)
    int legAge         = bar_index - youngestAnchor
    if legAge > maxLegAgeBars
        trend       := 0
        anchorHi    := na
        anchorHiBar := na
        anchorLo    := na
        anchorLoBar := na
        bosRefStored      := na
        bosRefBarStored   := na
        bosBreakBarStored := na
        stateStr    := "Structure Expired"
        stickyAge   := 0
        zoneTop     := na
        zoneBot     := na
        zoneAlertFired := false
        f_clearDrawings()

// -------------------- STATE LABELS --------------------
bool isSticky = stateStr == "Conflict with Higher Timeframe" or stateStr == "Bull Structure Broken" or stateStr == "Bear Structure Broken" or stateStr == "Structure Expired"

if trend == 1
    stateStr  := "Active — Bull Structure"
    stickyAge := 0
else if trend == -1
    stateStr  := "Active — Bear Structure"
    stickyAge := 0
else if isSticky
    stickyAge := stickyAge + 1
    if stickyAge > 5
        stateStr  := "No Active Structure"
        stickyAge := 0
else
    stateStr  := "No Active Structure"
    stickyAge := 0

// -------------------- RENDER FIB --------------------
var float lastDrawnHi = na
var float lastDrawnLo = na
var int   lastDrawnT  = 0

needsRedraw = trend != 0 and (anchorHi != lastDrawnHi or anchorLo != lastDrawnLo or trend != lastDrawnT)

f_drawLevel(float p, int x1, int x2, color col, int w, bool dashed, string txt) =>
    line ln = line.new(x1, p, x2, p, color = col, width = w, style = dashed ? line.style_dashed : line.style_solid)
    array.push(fibLines, ln)
    if showLabels
        label lb = label.new(x2, p, txt + "  (" + str.tostring(p, format.mintick) + ")", textcolor = col, color = color.new(color.black, 100), style = label.style_label_left, size = size.small)
        array.push(fibLabels, lb)

if needsRedraw
    f_clearDrawings()
    float zero     = trend == 1 ? anchorHi : anchorLo
    float one      = trend == 1 ? anchorLo : anchorHi
    float rng      = one - zero
    int   startBar = trend == 1 ? anchorLoBar : anchorHiBar
    int   endBar   = extendRight ? bar_index + 20 : bar_index

    float p618 = zero + rng * 0.618
    float p786 = zero + rng * 0.786
    float gTop = math.max(p618, p786)
    float gBot = math.min(p618, p786)
    goldBox := box.new(startBar, gTop, endBar, gBot, border_color = goldEdge, border_width = 1, bgcolor = goldFill)

    zoneTop := gTop
    zoneBot := gBot

    if lvl0
        f_drawLevel(zero, startBar, endBar, cFib, 1, false, "0.000")
    if lvl236
        f_drawLevel(zero + rng * 0.236, startBar, endBar, cFib, 1, false, "0.236")
    if lvl382
        f_drawLevel(zero + rng * 0.382, startBar, endBar, cFib, 1, false, "0.382")
    if lvl5
        f_drawLevel(zero + rng * 0.5,   startBar, endBar, midColor, 1, true,  "0.500")
    if lvl618
        f_drawLevel(p618, startBar, endBar, goldEdge, 1, false, "0.618")
    if lvl786
        f_drawLevel(p786, startBar, endBar, goldEdge, 1, false, "0.786")
    if lvl1
        f_drawLevel(one, startBar, endBar, cFib, 1, false, "1.000")

    // custom user-defined level
    if useCustom
        f_drawLevel(zero + rng * customLevel, startBar, endBar, customColor, 1, false, str.tostring(customLevel, "#.###"))

    if showImpulse
        impulseLine := line.new(anchorLoBar, anchorLo, anchorHiBar, anchorHi, color = impulseCol, width = 1, style = line.style_dashed)

    // BOS line + centered label
    if showBOS and not na(bosRefStored) and not na(bosRefBarStored)
        int bosEnd = na(bosBreakBarStored) ? (trend == 1 ? anchorHiBar : anchorLoBar) : bosBreakBarStored
        bosLineDraw := line.new(bosRefBarStored, bosRefStored, bosEnd, bosRefStored, color = bosColor, width = 1, style = line.style_dashed)
        int midBar = math.round((bosRefBarStored + bosEnd) / 2)
        bosLabelDraw := label.new(midBar, bosRefStored, "BOS", color = color.new(color.black, 100), textcolor = bosColor, style = label.style_none, size = size.small)

    if showAnchors
        string hiTag = trend == 1 ? "HH" : "LH"
        string loTag = trend == 1 ? "HL" : "LL"
        string hiTxt = hiTag + "  (" + str.tostring(anchorHi, format.mintick) + ")"
        string loTxt = loTag + "  (" + str.tostring(anchorLo, format.mintick) + ")"
        anchorHiLbl := label.new(anchorHiBar, anchorHi, hiTxt, style = label.style_label_down, color = cFib, textcolor = color.white, size = size.small)
        anchorLoLbl := label.new(anchorLoBar, anchorLo, loTxt, style = label.style_label_up,   color = cFib, textcolor = color.white, size = size.small)

    lastDrawnHi := anchorHi
    lastDrawnLo := anchorLo
    lastDrawnT  := trend

// -------------------- ALERTS --------------------
if alertOnNewFib and newBullFib
    alert("Confirmed Fib — New Bull Fib Drawn", alert.freq_once_per_bar)
if alertOnNewFib and newBearFib
    alert("Confirmed Fib — New Bear Fib Drawn", alert.freq_once_per_bar)

if alertOnZone and trend != 0 and not zoneAlertFired and not na(zoneTop) and not na(zoneBot)
    bool touched = low <= zoneTop and high >= zoneBot
    if touched
        zoneAlertFired := true
        string dir = trend == 1 ? "Bull" : "Bear"
        alert("Confirmed Fib — Golden Zone Touched (" + dir + ")", alert.freq_once_per_bar)

alertcondition(alertOnNewFib and newBullFib, "New Bull Fib Drawn", "Confirmed Fib — New Bull Fib Drawn")
alertcondition(alertOnNewFib and newBearFib, "New Bear Fib Drawn", "Confirmed Fib — New Bear Fib Drawn")

// -------------------- INFO PANEL --------------------
if showInfo and barstate.islast

    color stateCol = cText
    if str.contains(stateStr, "Bull") and not str.contains(stateStr, "Broken")
        stateCol := cBull
    else if str.contains(stateStr, "Bear") and not str.contains(stateStr, "Broken")
        stateCol := cBear
    else if isSticky
        stateCol := cDim

    string biasTxt = ""
    color  biasCol = cText
    if not useBias
        biasTxt := "Filter Off"
    else if not biasAvailable
        biasTxt := "Not Available"
    else if htfBias == 1
        biasTxt := "Bull (" + biasTFname + ")"
        biasCol := cBull
    else if htfBias == -1
        biasTxt := "Bear (" + biasTFname + ")"
        biasCol := cBear
    else
        biasTxt := "Neutral (" + biasTFname + ")"

    string anchorHiTxt = na(anchorHi) ? "—" : str.tostring(anchorHi, format.mintick)
    string anchorLoTxt = na(anchorLo) ? "—" : str.tostring(anchorLo, format.mintick)
    color  anchorHiCol = cText
    color  anchorLoCol = cText
    if trend == 1
        anchorHiCol := cBull
        anchorLoCol := cBear
    else if trend == -1
        anchorHiCol := cBear
        anchorLoCol := cBull

    string pullbackTxt = "—"
    if trend != 0 and not na(anchorHiBar) and not na(anchorLoBar)
        int youngestBar = math.max(anchorHiBar, anchorLoBar)
        int barsSince   = bar_index - youngestBar
        pullbackTxt := str.tostring(barsSince) + " bars ago"

    table.cell(info, 0, 0, "Confirmed Fibonacci", text_color = cText, bgcolor = brandBG, text_size = size.normal, text_halign = text.align_center)
    table.cell(info, 1, 0, "Market Structure", text_color = cText, bgcolor = brandBG, text_size = size.normal, text_halign = text.align_center)

    table.cell(info, 0, 1, "Structure",                text_color = cSub,     bgcolor = headerBG, text_size = size.small, text_halign = text.align_center)
    table.cell(info, 1, 1, stateStr,                   text_color = stateCol, bgcolor = headerBG, text_size = size.small, text_halign = text.align_center)

    table.cell(info, 0, 2, "Higher Timeframe Bias",    text_color = cSub,    bgcolor = panelBG, text_size = size.small, text_halign = text.align_center)
    table.cell(info, 1, 2, biasTxt,                    text_color = biasCol, bgcolor = panelBG, text_size = size.small, text_halign = text.align_center)

    table.cell(info, 0, 3, "Anchor High",              text_color = cSub,        bgcolor = panelBG, text_size = size.small, text_halign = text.align_center)
    table.cell(info, 1, 3, anchorHiTxt,                text_color = anchorHiCol, bgcolor = panelBG, text_size = size.small, text_halign = text.align_center)

    table.cell(info, 0, 4, "Anchor Low",               text_color = cSub,        bgcolor = panelBG, text_size = size.small, text_halign = text.align_center)
    table.cell(info, 1, 4, anchorLoTxt,                text_color = anchorLoCol, bgcolor = panelBG, text_size = size.small, text_halign = text.align_center)

    table.cell(info, 0, 5, "Impulse Confirmed",        text_color = cSub,  bgcolor = panelBG, text_size = size.small, text_halign = text.align_center)
    table.cell(info, 1, 5, pullbackTxt,                text_color = cText, bgcolor = panelBG, text_size = size.small, text_halign = text.align_center)
````
