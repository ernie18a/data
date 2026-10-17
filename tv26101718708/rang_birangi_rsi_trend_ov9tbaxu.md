# Rang Birangi RSI + Trend

- url: https://www.tradingview.com/script/oV9TBaxu-Rang-Birangi-RSI-Trend/
- type: indicator
- pine_id: PUB;6b9a33f322b0461f8841a9b1cd998160
- version: 1.0

## Description

======================================================================
  RANG BIRANGI RSI + TREND  —  BUY / SELL SIGNALS & RISK EXPLAINED
  (c) TGP_Analysis  |  Pine Script v6
======================================================================

PURPOSE OF THIS NOTE
--------------------
This note explains the actual trade signals in the indicator — the
coloured DIAMONDS — and shows how risk is already defined inside the
signal logic, plus where to place your stop on each trade.


----------------------------------------------------------------------
1. THE TWO RSI LINES (the engine behind everything)
----------------------------------------------------------------------
  - RSI 13  (slower)  = the baseline / trend of momentum
  - RSI 9   (faster)  = the trigger line

By default all signals read the FAST line, RSI 9 (the input
"Signal RSI = RSI 9" is ON). RSI 9 is what dips into oversold,
recovers, and fires the signals.

Reference levels used by the signals:
  - 40  = Bull trigger (mid line where a recovery is confirmed)
  - 60  = Bear trigger (mid line where a breakdown is confirmed)
  - 30 / 20 = Oversold TEST levels (shallow / deep)
  - 70 / 80 = Overbought TEST levels (shallow / deep)
  - Lookback = 20 bars (how recently the test must have happened)


----------------------------------------------------------------------
2. BUY SIGNAL  (GREEN DIAMOND)  — logic in plain words
----------------------------------------------------------------------
A buy is a two-stage event. BOTH stages must happen:

  STAGE 1 — THE TEST (fear / washout):
     Within the last 20 bars, RSI 9 fell to an oversold extreme:
        * touched 30  = shallow test
        * touched 20  = deep test (stronger washout)

  STAGE 2 — THE RECOVERY (confirmation):
     RSI 9 then turns up AND crosses back above 40,
     while it is actually rising (this bar > last bar).

Only when the recovery crosses 40 does the diamond print.

TWO GRADES OF BUY:
  - Light green diamond (plotted at RSI 37)  = "Bull 30-test"
        Price washed out to the 30 zone, then recovered. Milder.
  - Bright green diamond (plotted at RSI 34) = "Bull 20-test"
        Price washed out all the way to 20, then recovered.
        Deeper fear flushed out = higher-conviction buy.

Think of it as: the market got scared, sellers exhausted
themselves (the test), and buyers took control back (the cross
above 40). You are NOT catching a falling knife — you wait for
the turn to confirm.


----------------------------------------------------------------------
3. SELL SIGNAL  (RED / ORANGE DIAMOND)  — logic in plain words
----------------------------------------------------------------------
Mirror image of the buy. Two stages:

  STAGE 1 — THE TEST (greed / blow-off):
     Within the last 20 bars, RSI 9 pushed to an overbought
     extreme:
        * touched 70  = shallow test
        * touched 80  = deep test (stronger blow-off)

  STAGE 2 — THE ROLL-OVER (confirmation):
     RSI 9 then turns down AND crosses back below 60,
     while it is actually falling.

TWO GRADES OF SELL:
  - Orange diamond (plotted at RSI 63) = "Bear 70-test"
        Milder overbought, then roll-over.
  - Bright red diamond (plotted at RSI 66) = "Bear 80-test"
        Extreme overbought (80), then roll-over.
        Higher-conviction sell / exit.

Think of it as: the market got greedy, buyers exhausted
themselves (the test), sellers took control back (the cross
below 60).


----------------------------------------------------------------------
4. HOW RISK IS ALREADY "DEFINED" INSIDE THE SIGNAL
----------------------------------------------------------------------
The signal is deliberately built to reduce entry risk BEFORE you
even place a stop:

  (a) IT WAITS FOR CONFIRMATION.
      No signal fires at the oversold low itself. It only fires
      after RSI turns and reclaims 40 (buy) or loses 60 (sell).
      This filters out "it kept falling" scenarios.

  (b) IT REQUIRES A RECENT EXTREME.
      The 20-bar lookback means the setup must be a genuine
      reversal from stretched conditions — not a random mid-range
      wiggle.

  (c) IT GRADES CONVICTION FOR YOU.
      Deep-test diamonds (20 / 80) = size up / trust more.
      Shallow-test diamonds (30 / 70) = size down / be selective.
      This is position-risk control baked into the colour.


----------------------------------------------------------------------
5. WHERE TO PLACE YOUR STOP (defining the money-risk)
----------------------------------------------------------------------
The signal defines the SETUP; you define the STOP from price.

  ON A GREEN (BUY) DIAMOND:
     - Stop just below the swing LOW made during the oversold
       test (the price low that occurred while RSI was at 30/20).
     - That low is your invalidation point: if price trades
       below it, the reversal has failed.
     - Risk per unit = Entry price  -  that swing low.

  ON A RED (SELL) DIAMOND:
     - Stop just above the swing HIGH made during the overbought
       test (the price high while RSI was at 70/80).
     - Risk per unit = that swing high  -  Entry price.

  TARGET / TRAIL:
     - Use the Trend Engine line (the "Trend Line" / avg) and the
       Up / Down label as your trail. Stay long while the trend
       line is green and price holds above it; stay short while
       it is red and price holds below it.
     - A deep-test diamond in the OPPOSITE direction is a natural
       exit for an existing position.


----------------------------------------------------------------------
6. BEST-PRACTICE FILTER (combine signal + trend)
----------------------------------------------------------------------
Highest-quality trades = signal AGREES with the trend engine:

  - BUY diamond + price above the green Trend Line  = with-trend
    long (strongest).
  - SELL diamond + price below the red Trend Line   = with-trend
    short (strongest).
  - A diamond AGAINST the trend line = counter-trend; treat as a
    quick mean-reversion / scalp only, tighter stop, smaller size.

Optional extra confirmation already in the tool:
  - "Mean Reversion" dots and "Strong Mean Reversion" dots
    mark momentum snapping back from an extreme. A buy diamond
    landing near an up mean-reversion dot adds confidence.


----------------------------------------------------------------------
7. QUICK REFERENCE TABLE
----------------------------------------------------------------------
  SIGNAL              RSI TEST     CONFIRM CROSS   CONVICTION   STOP
  -----------------   ----------   -------------   ----------   -----------------
  Bright green dia.   touched 20   up through 40   HIGH (buy)   below test-low
  Light  green dia.   touched 30   up through 40   MED  (buy)   below test-low
  Bright red  dia.    touched 80   down thru 60    HIGH (sell)  above test-high
  Orange      dia.    touched 70   down thru 60    MED  (sell)  above test-high


----------------------------------------------------------------------
8. ONE-LINE SUMMARY
----------------------------------------------------------------------
  BUY  = RSI washed out (30/20), then recovered above 40  -> stop
         below the washout low.
  SELL = RSI blew off (70/80), then rolled under 60        -> stop
         above the blow-off high.
  Deeper the test, stronger the signal. Trade in the direction of
  the Trend Line for best results.

======================================================================

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Sunny9009
//@version=6
indicator("Rang Birangi RSI + Trend", overlay = false, max_labels_count = 500)

// THEME ---------------------------------------------------------------------------------------------------------------{
string grpT       = "Theme"
string themeMode  = input.string("Dark", "Background Theme", options = ["Dark", "Light", "Auto (chart default)"], group = grpT)
bool   paintPrice = input.bool(false, "Also paint price-chart background", group = grpT)
color  darkBg     = input.color(#131722, "Dark BG",  group = grpT, inline = "tb")
color  lightBg    = input.color(#FFFFFF, "Light BG", group = grpT, inline = "tb")
color  darkFg     = input.color(#D1D4DC, "Dark Text",  group = grpT, inline = "tf")
color  lightFg    = input.color(#131722, "Light Text", group = grpT, inline = "tf")

bool   isDark  = themeMode == "Dark"
bool   isLight = themeMode == "Light"
color  themeBg = isDark ? darkBg : isLight ? lightBg : color(na)
color  themeFg = isDark ? darkFg : isLight ? lightFg : chart.fg_color

bgcolor(themeBg, title = "Theme BG (pane)")
bgcolor(paintPrice ? themeBg : na, title = "Theme BG (price chart)", force_overlay = true)
//}

// RSI -----------------------------------------------------------------------------------------------------------------{
string grpR    = "RSI"
int rsi_period_1  = input.int(13, "RSI Period 1", minval = 1, group = grpR)
int rsi_period_2  = input.int(9,  "RSI Period 2", minval = 1, group = grpR)
int rsi_thickness = input.int(2, "RSI Line Thickness", minval = 1, maxval = 10, group = grpR)
color rsi1Col     = input.color(color.rgb(8, 211, 93),   "RSI 13 (neutral)", group = grpR)
color rsi2UpCol   = input.color(color.rgb(12, 206, 60),  "RSI 9 Up",   group = grpR, inline = "r2")
color rsi2DnCol   = input.color(color.rgb(245, 14, 14),  "RSI 9 Down", group = grpR, inline = "r2")
color rsi2NeuCol  = input.color(color.rgb(241, 19, 19),  "RSI 9 Neutral", group = grpR)

rsi_1 = ta.rsi(close, rsi_period_1)
rsi_2 = ta.rsi(close, rsi_period_2)

bool rsi_trend_up   = rsi_2 > rsi_1
bool rsi_trend_down = rsi_2 < rsi_1
bool rsi_fight      = not (rsi_trend_up or rsi_trend_down)

p_rsi1 = plot(rsi_1, "RSI 13", color = rsi_fight ? rsi1Col : na, linewidth = rsi_thickness)
p_rsi2 = plot(rsi_2, "RSI 9",  color = rsi_trend_up ? rsi2UpCol : rsi_trend_down ? rsi2DnCol : rsi2NeuCol, linewidth = rsi_thickness)
//}

// RSI SHADING ---------------------------------------------------------------------------------------------------------{
string grpS      = "RSI Shading"
bool   shadeX    = input.bool(true, "Shade between RSI 9 & RSI 13", group = grpS)
color  shadeUp   = input.color(color.new(color.rgb(12, 206, 60), 75), "Bull cloud", group = grpS, inline = "sx")
color  shadeDn   = input.color(color.new(color.rgb(245, 14, 14), 75), "Bear cloud", group = grpS, inline = "sx")
bool   shadeZone = input.bool(true, "Shade RSI beyond OB / OS levels", group = grpS)
string zoneSrc   = input.string("RSI 9", "Zone shading RSI", options = ["RSI 9", "RSI 13"], group = grpS)
float  obLvl     = input.float(72, "Overbought level", group = grpS, inline = "ob")
color  obCol     = input.color(color.new(color.rgb(245, 14, 14), 60), "", group = grpS, inline = "ob")
float  osLvl     = input.float(28, "Oversold level", group = grpS, inline = "os")
color  osCol     = input.color(color.new(color.rgb(12, 206, 60), 60), "", group = grpS, inline = "os")
bool   shadeBand = input.bool(false, "Shade mid band (between Level 3 & Level 2)", group = grpS)
color  bandFill  = input.color(color.new(color.gray, 90), "Mid band color", group = grpS)

float zRsi = zoneSrc == "RSI 9" ? rsi_2 : rsi_1

// cloud between the two RSI lines
fill(p_rsi2, p_rsi1, color = shadeX ? (rsi_trend_up ? shadeUp : rsi_trend_down ? shadeDn : na) : na, title = "RSI Cloud")

// zone fills: RSI vs. OB / OS reference (reference plots are invisible)
p_zRsi = plot(zRsi,  "Zone RSI (ref)", display = display.none, editable = false)
p_ob   = plot(obLvl, "OB ref",         display = display.none, editable = false)
p_os   = plot(osLvl, "OS ref",         display = display.none, editable = false)
fill(p_zRsi, p_ob, color = shadeZone and zRsi > obLvl ? obCol : na, title = "Overbought Shade")
fill(p_zRsi, p_os, color = shadeZone and zRsi < osLvl ? osCol : na, title = "Oversold Shade")
//}

// THRESHOLD LINES -----------------------------------------------------------------------------------------------------{
string grpL = "Threshold Lines"
float lvl72 = input.float(72, "Level 1", group = grpL, inline = "l1")
color col72 = input.color(color.rgb(150, 142, 142, 43), "", group = grpL, inline = "l1")
float lvl60 = input.float(60, "Level 2", group = grpL, inline = "l2")
color col60 = input.color(color.rgb(167, 5, 5), "", group = grpL, inline = "l2")
float lvl40 = input.float(40, "Level 3", group = grpL, inline = "l3")
color col40 = input.color(#058010, "", group = grpL, inline = "l3")
float lvl28 = input.float(28, "Level 4", group = grpL, inline = "l4")
color col28 = input.color(#636060, "", group = grpL, inline = "l4")

hline(lvl72, "Level 72", color = col72)
h60 = hline(lvl60, "Level 60", color = col60)
h40 = hline(lvl40, "Level 40", color = col40)
fill(h60, h40, color = shadeBand ? bandFill : na, title = "Mid Band Shade")
hline(lvl28, "Level 28", color = col28)
//}

// DIAMOND REVERSAL SIGNALS --------------------------------------------------------------------------------------------{
string grpD     = "Diamond Signals"
bool   useRSI9  = input.bool(true,  "Signal RSI = RSI 9 (uncheck for RSI 13)", group = grpD)
int    lookbk   = input.int(20, "Test Lookback (bars)", minval = 1, maxval = 200, group = grpD)
float  bullTrig = input.float(40, "Bull Trigger Level", group = grpD)
float  bearTrig = input.float(60, "Bear Trigger Level", group = grpD)
float  loTest1  = input.float(30, "Bull Test Level 1", group = grpD, inline = "bt")
float  loTest2  = input.float(20, "Bull Test Level 2", group = grpD, inline = "bt")
float  hiTest1  = input.float(70, "Bear Test Level 1", group = grpD, inline = "st")
float  hiTest2  = input.float(80, "Bear Test Level 2", group = grpD, inline = "st")
bool   showDia  = input.bool(true, "Show Diamonds", group = grpD)
color  bullShCol = input.color(color.new(#04752a, 10),              "Bull 30-test", group = grpD, inline = "dc1")
color  bullDpCol = input.color(color.rgb(0, 255, 80),               "Bull 20-test", group = grpD, inline = "dc1")
color  bearShCol = input.color(color.new(#f3970c, 11),              "Bear 70-test", group = grpD, inline = "dc2")
color  bearDpCol = input.color(color.rgb(255, 0, 0),                "Bear 80-test", group = grpD, inline = "dc2")

float rsi_sig = useRSI9 ? rsi_2 : rsi_1

int sinceLo1 = nz(ta.barssince(rsi_sig <= loTest1), 999999)
int sinceLo2 = nz(ta.barssince(rsi_sig <= loTest2), 999999)
int sinceHi1 = nz(ta.barssince(rsi_sig >= hiTest1), 999999)
int sinceHi2 = nz(ta.barssince(rsi_sig >= hiTest2), 999999)

bool tested30 = sinceLo1 <= lookbk
bool tested20 = sinceLo2 <= lookbk
bool tested70 = sinceHi1 <= lookbk
bool tested80 = sinceHi2 <= lookbk

bool turningUp = rsi_sig > rsi_sig[1]
bool turningDn = rsi_sig < rsi_sig[1]

bool bullCross = ta.crossover(rsi_sig, bullTrig)  and turningUp
bool bearCross = ta.crossunder(rsi_sig, bearTrig) and turningDn

bool bullDeep    = showDia and bullCross and tested20
bool bullShallow = showDia and bullCross and tested30 and not tested20
bool bearDeep    = showDia and bearCross and tested80
bool bearShallow = showDia and bearCross and tested70 and not tested80

plotshape(bullShallow ? bullTrig - 3.0 : na, "Bull Diamond (30 test)", shape.diamond, location.absolute, bullShCol, size = size.tiny)
plotshape(bullDeep    ? bullTrig - 6.0 : na, "Bull Diamond (20 test)", shape.diamond, location.absolute, bullDpCol, size = size.tiny)
plotshape(bearShallow ? bearTrig + 3.0 : na, "Bear Diamond (70 test)", shape.diamond, location.absolute, bearShCol, size = size.tiny)
plotshape(bearDeep    ? bearTrig + 6.0 : na, "Bear Diamond (80 test)", shape.diamond, location.absolute, bearDpCol, size = size.tiny)

alertcondition(bullShallow or bullDeep, "RSI Bull Diamond", "RSI turned up through 40 after testing oversold")
alertcondition(bearShallow or bearDeep, "RSI Bear Diamond", "RSI turned down through 60 after testing overbought")
//}

// TREND ENGINE INPUTS -------------------------------------------------------------------------------------------------{
string grpE = "Trend Engine"
int    period   = input.int(17, "Period", minval = 17, group = grpE, inline = "m")
int    width    = input.int(2, "Width", options = [1, 2, 3, 4], group = grpE, inline = "m")
string mode     = input.string("Normal", "Mode", options = ["Normal", "Sensitive"], group = grpE)
bool   show_bnd = input.bool(true,  "Volatility Bands", group = grpE)
bool   show_dev = input.bool(false, "Price Deviation", group = grpE)
bool   show_ws  = input.bool(false, "Mean Reversion", group = grpE)
bool   show_ss  = input.bool(false, "Strong Mean Reversion", group = grpE)
bool   show_lbl = input.bool(true,  "Show Up/Down Label", group = grpE)

string grpC = "Trend Colors"
color up       = input.color(color.rgb(20, 236, 31), "Trend Up",   group = grpC, inline = "c")
color dn       = input.color(color.rgb(243, 17, 17), "Trend Down", group = grpC, inline = "c")
int   flatTr   = input.int(40, "Flat-trend transparency", minval = 0, maxval = 100, group = grpC)
int   bandTr   = input.int(50, "Band transparency",       minval = 0, maxval = 100, group = grpC)
int   ribbonUp = input.int(30, "Ribbon transparency Up",  minval = 0, maxval = 100, group = grpC, inline = "rb")
int   ribbonDn = input.int(40, "Down",                    minval = 0, maxval = 100, group = grpC, inline = "rb")
color zeroCol  = input.color(color.gray, "Deviation zero line (Auto = theme)", group = grpC)
bool  zeroAuto = input.bool(true, "Use theme color for zero line / label", group = grpC)
color mrUpCol  = input.color(color.new(color.rgb(20, 236, 31), 50), "MR Up",   group = grpC, inline = "mr")
color mrDnCol  = input.color(color.new(color.rgb(243, 17, 17), 50), "MR Down", group = grpC, inline = "mr")
color smrUpCol = input.color(color.rgb(20, 236, 31), "Strong MR Up",   group = grpC, inline = "smr")
color smrDnCol = input.color(color.rgb(243, 17, 17), "Strong MR Down", group = grpC, inline = "smr")
//}

// CALCULATION ---------------------------------------------------------------------------------------------------------{
float src = ta.hma(hl2, 25)
float vlt = ta.sma(high - low, 100)

var array<float> AVG = array.new<float>(period, na)

bool pushCond = mode == "Normal" ? bar_index == 122 : bar_index % period == 0
if pushCond
    AVG.push(close)

if bar_index % period == 0
    if close > AVG.last()
        AVG.push(low - vlt)
    if close < AVG.last()
        AVG.push(high + vlt)

float avg   = math.sum(AVG.last(), 10) / 10
float upper = avg + vlt
float lower = avg - vlt

color trend_color = src > avg
     ? (avg == avg[1] or avg < avg[1] ? color.new(up, flatTr) : up)
     : (avg == avg[1] or avg > avg[1] ? color.new(dn, flatTr) : dn)

color trend_color1 = src > avg ? up : dn

float osc  = src - avg
float osc1 = osc / ta.stdev(osc, 50)
//}

// PLOTTING ------------------------------------------------------------------------------------------------------------{
color fgCol = zeroAuto ? themeFg : zeroCol

plot(avg, "Trend Line", color = trend_color, linewidth = width, force_overlay = true)

color bandCol = bar_index % 2 == 0 ? color.new(trend_color1, bandTr) : na
plot(show_bnd ? lower : na, "Lower Band", color = bandCol, force_overlay = true)
plot(show_bnd ? upper : na, "Upper Band", color = bandCol, force_overlay = true)

plot(show_dev ? osc1 : na, "Price Deviation", color = color.from_gradient(osc1, -3, 3, up, dn), style = plot.style_area)
plot(show_dev ? 0 : na, "Deviation Zero", color = fgCol)

color trend_bgcolor = color.from_gradient(osc1, -0.5, 0.5,
     color.new(dn, show_dev ? 100 : ribbonDn), color.new(up, show_dev ? 100 : ribbonUp))
plot(5, "Trend Ribbon", color = trend_bgcolor, style = plot.style_area, linewidth = 5)

plotchar(ta.crossover(osc1, osc1[1])  and osc1 < -2 and show_ws, "Mean Reversion UP", "●",
     location = location.belowbar, color = mrUpCol, size = size.tiny, force_overlay = true)
plotchar(ta.crossunder(osc1, osc1[1]) and osc1 > 2  and show_ws, "Mean Reversion DN", "●",
     location = location.abovebar, color = mrDnCol, size = size.tiny, force_overlay = true)
plotchar(ta.crossover(osc1, -4) and show_ss, "Strong Mean Reversion UP", "•",
     location = location.belowbar, color = smrUpCol, size = size.small, force_overlay = true)
plotchar(ta.crossunder(osc1, 4) and show_ss, "Strong Mean Reversion DN", "•",
     location = location.abovebar, color = smrDnCol, size = size.small, force_overlay = true)

var label trendLbl = na
if barstate.islast
    label.delete(trendLbl)
    trendLbl := na
    if show_lbl and not show_dev
        trendLbl := label.new(bar_index + 5, 0, close > avg ? "Up" : "Down",
             style = label.style_label_left, color = color(na), textcolor = fgCol)
//}
````
