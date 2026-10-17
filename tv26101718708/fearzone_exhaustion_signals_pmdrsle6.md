# Fearzone Exhaustion Signals

- url: https://www.tradingview.com/script/PMdrsLE6-Fearzone-Exhaustion-Signals/
- type: indicator
- pine_id: PUB;55c67cdc0ab84761bcb3537f110e9116
- version: 1.0

## Description

■ Overview
This indicator highlights bars where an overextended move starts to lose strength. A red background marks a possible short entry, and a green background marks a possible long entry.

Long signals are stricter than short signals. A long signal also requires a fear condition, so it appears only after a clear sell-off.

【Image: chart with red and green backgrounds】

■ How a signal is made
1. Overextension
Two RSIs, a short-term one and a long-term one, are calculated on smoothed prices. Both must be above 90 for a short, or below 10 for a long.

2. Fading momentum
The MACD histogram must be shrinking: above zero and lower than the previous bar for a short, below zero and higher than the previous bar for a long.

3. State filter
The efficiency ratio and the speed of the move (in ATRs per bar) classify the market as accelerating, pausing, or moving gently. By default, signals are skipped during a gentle, steady trend, where counter-trend entries tend to fail.

4. Fearzone (long only)
A long signal is shown only when the Fearzone condition is active: the drop from the recent high is larger than usual, and the smoothed price is lower than usual.

■ Settings
・Parameters: MA type, MA lengths, and the RSI levels
・MACD: the original MACD built from the two MAs, or the standard 12, 26, 9
・State Filter: on or off, and how strict it is
・Fearzone: periods, moving average type, and how many bars count as an overlap
・Display: show or hide each side, colors, and transparency
・Alert Settings: turn each side on or off

■ Alerts
Create an alert and select "Any alert() function call" to receive both sides in one alert. It fires once when the bar closes. The message includes the symbol and timeframe, for example "Long Signal: BTCUSDT (15)".

You can also choose "Long" or "Short" in the alert dialog to set them up separately. Use one of the two ways, not both.

■ Limitations
・Signals are counter-trend. In a strong one-directional move, price may continue after a signal.
・The indicator does not provide stop loss or take profit levels.
・Results differ by symbol and timeframe. Check recent signals before relying on them.

■ Credits
The Fearzone condition is based on "Fearzone - Contrarian Indicator" by Zeiierman, used under CC BY-NC-SA 4.0. This script is shared under the same license.

■ Disclaimer
For research and educational purposes only. This is not financial advice. Past signals do not guarantee future results.

## Source Code

````pine
//@version=6
// The Fearzone part is based on "Fearzone - Contrarian Indicator" by Zeiierman (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
indicator("Fearzone Exhaustion Signals", shorttitle="Fearzone Exhaustion Signals", overlay=true)

// =============================================================================
// --- Inputs ---
// =============================================================================
// Parameters (same settings as the original entry signal)
MAtype  = input.string("EMA", "MA type", options = ["EMA", "SMA"], group = "Parameters", display = display.none)
Period1 = input.int(13, "Short MA length", minval = 2, group = "Parameters", display = display.none)
Period2 = input.int(100, "Long MA length", minval = 2, group = "Parameters", display = display.none)
upperLv = input.float(90, "Upper line (sell)", group = "Parameters", display = display.none)
lowerLv = input.float(10, "Lower line (buy)", group = "Parameters", display = display.none)

MACD_ORIG = "Original MACD"
MACD_STD  = "Standard MACD (12, 26, 9)"
macdSrc = input.string(MACD_ORIG, "MACD to use", options = [MACD_ORIG, MACD_STD], group = "MACD", tooltip = "Original MACD: short MA − long MA, with the short MA length as the signal length.\nStandard MACD: the same as TradingView's default, 12, 26, 9 (EMA).", display = display.none)

// State filter (efficiency ratio × speed)
PASS_LOOSE  = "Exclude gentle moves only"
PASS_STRICT = "Acceleration or pause only"
useState = input.bool(true, "Use the state filter", group = "State Filter (Efficiency Ratio × Speed)", display = display.none)
passMode = input.string(PASS_LOOSE, "States to pass", options = [PASS_LOOSE, PASS_STRICT], group = "State Filter (Efficiency Ratio × Speed)", tooltip = "Exclude gentle moves only: no signal during a gentle rise or fall.\nAcceleration or pause only: signals only during a sharp rise or fall, or a pause right after one (stricter).", display = display.none)
erLen    = input.int(8, "Lookback (bars)", minval = 2, group = "State Filter (Efficiency Ratio × Speed)", display = display.none)
atrLen   = input.int(50, "ATR length (measure of speed)", minval = 1, group = "State Filter (Efficiency Ratio × Speed)", display = display.none)
erTh     = input.float(0.5, "Efficiency ratio threshold", minval = 0, maxval = 1, step = 0.05, group = "State Filter (Efficiency Ratio × Speed)", display = display.none)
spTh     = input.float(0.4, "Speed threshold (ATRs per bar)", minval = 0, step = 0.05, group = "State Filter (Efficiency Ratio × Speed)", display = display.none)
pauseMem = input.int(10, "Bars counted as a pause after acceleration", minval = 1, group = "State Filter (Efficiency Ratio × Speed)", display = display.none)

// Fearzone (same defaults as the original indicator)
fzSrc    = input.source(ohlc4, "Source for Fearzone", group = "Fearzone", display = display.none)
fzHigh   = input.int(30, "High Period", minval = 1, group = "Fearzone", display = display.none)
fzStd    = input.int(50, "Stdev Period", minval = 2, group = "Fearzone", display = display.none)
fzMA     = input.string("WMA", "Moving average type", options = ["SMA", "EMA", "WMA", "HMA", "RMA"], group = "Fearzone", display = display.none)
fzWindow = input.int(0, "Overlap window (bars)", minval = 0, group = "Fearzone", tooltip = "0: only when Fearzone is active on the same bar.\n3: counts as an overlap if Fearzone was active within the last 3 bars.", display = display.none)

// Display
showShort  = input.bool(true, "Show short signals", group = "Display", display = display.none)
showLong   = input.bool(true, "Show long signals",  group = "Display", display = display.none)
shortColor = input.color(color.red,   "Short color", group = "Display", display = display.none)
longColor  = input.color(color.green, "Long color",  group = "Display", display = display.none)
bgTransp   = input.int(80, "Background transparency", minval = 0, maxval = 100, group = "Display", tooltip = "0 = opaque, 100 = fully transparent.", display = display.none)

// Alerts
alertOnShort = input.bool(true, "Enable short alert", group = "Alert Settings", display = display.none)
alertOnLong  = input.bool(true, "Enable long alert",  group = "Alert Settings", display = display.none)

// =============================================================================
// --- RSI (same formula as the original signal) ---
// =============================================================================
f_rsi(p) =>
    smLen  = math.round(p * 0.5)
    rsiLen = math.round(p * 0.3)
    src    = MAtype == "EMA" ? ta.ema(close, smLen) : ta.sma(close, smLen)
    ta.rsi(src, rsiLen)

rsiS = f_rsi(Period1)
rsiL = f_rsi(Period2)

rsiSell = rsiS >= upperLv and rsiL >= upperLv
rsiBuy  = rsiS <= lowerLv and rsiL <= lowerLv

// =============================================================================
// --- MACD histogram ---
// =============================================================================
shortMA = MAtype == "EMA" ? ta.ema(close, Period1) : ta.sma(close, Period1)
longMA  = MAtype == "EMA" ? ta.ema(close, Period2) : ta.sma(close, Period2)
macd0   = shortMA - longMA
sig0    = MAtype == "EMA" ? ta.ema(macd0, Period1) : ta.sma(macd0, Period1)
hist0   = macd0 - sig0
[_m, _s, histStd] = ta.macd(close, 12, 26, 9)
hist = macdSrc == MACD_ORIG ? hist0 : histStd

// Fading histogram: above 0 and lower than the previous bar / below 0 and higher than the previous bar
macdSellLight = hist > 0 and hist < hist[1]
macdBuyLight  = hist < 0 and hist > hist[1]

// =============================================================================
// --- State filter (efficiency ratio × speed) ---
// =============================================================================
chg   = close - close[erLen]
pathLen = math.sum(math.abs(close - close[1]), erLen)
er    = pathLen > 0 ? math.abs(chg) / pathLen : 0.0
atrV  = ta.atr(atrLen)
speed = atrV > 0 ? math.abs(chg) / erLen / atrV : 0.0

trending = er >= erTh
isFast   = speed >= spTh

accelUp  = trending and isFast and chg > 0
accelDn  = trending and isFast and chg < 0
gentleUp = trending and not isFast and chg > 0
gentleDn = trending and not isFast and chg < 0

pauseUp = not trending and nz(ta.barssince(accelUp), 1000000) <= pauseMem
pauseDn = not trending and nz(ta.barssince(accelDn), 1000000) <= pauseMem

passSell = not useState ? true : passMode == PASS_LOOSE ? not gentleUp : (accelUp or pauseUp)
passBuy  = not useState ? true : passMode == PASS_LOOSE ? not gentleDn : (accelDn or pauseDn)

// =============================================================================
// --- Fearzone ---
// =============================================================================
f_avg(s, l) =>
    vSMA = ta.sma(s, l)
    vEMA = ta.ema(s, l)
    vWMA = ta.wma(s, l)
    vHMA = ta.hma(s, l)
    vRMA = ta.rma(s, l)
    switch fzMA
        "SMA" => vSMA
        "EMA" => vEMA
        "WMA" => vWMA
        "HMA" => vHMA
        => vRMA

// Condition 1: the drop from the recent high is clearly larger than usual
fzHH   = ta.highest(fzSrc, fzHigh)
FZ1    = (fzHH - fzSrc) / fzHH
FZ1Lim = f_avg(FZ1, fzStd) + ta.stdev(FZ1, fzStd)
// Condition 2: the smoothed price level is clearly lower than usual
FZ2    = f_avg(fzSrc, fzHigh)
FZ2Lim = f_avg(FZ2, fzStd) - ta.stdev(FZ2, fzStd)

fearCon = FZ1 > FZ1Lim and FZ2 < FZ2Lim

// Overlap check, allowing for the window
fearNear  = nz(ta.barssince(fearCon), 1000000) <= fzWindow


// =============================================================================
// --- Final signals ---
// =============================================================================
rawSell = rsiSell and macdSellLight
rawBuy  = rsiBuy and macdBuyLight

// Short: shown regardless of Fearzone / Long: shown only when it overlaps with Fearzone
shortSig = rawSell and passSell
longSig  = rawBuy and passBuy and fearNear

// =============================================================================
// --- Display (background color only; colors are set under "Display" in the settings) ---
// =============================================================================
bgcolor(shortSig and showShort ? color.new(shortColor, bgTransp) : na, title = "Short")
bgcolor(longSig  and showLong  ? color.new(longColor,  bgTransp) : na, title = "Long")

// =============================================================================
// --- Alerts ---
// =============================================================================
// Simple alerts: create one alert with "Any alert() function call".
// It fires once when the bar closes, and each side can be switched on or off in the settings.
where = ": " + syminfo.ticker + " (" + timeframe.period + ")"

if alertOnShort and shortSig
    alert("Short Signal" + where, alert.freq_once_per_bar_close)

if alertOnLong and longSig
    alert("Long Signal" + where, alert.freq_once_per_bar_close)

// Separate alerts: choose "Long" or "Short" in the alert dialog to set them up one by one.
alertcondition(longSig,  "Long",  "Long condition met ({{ticker}} {{interval}})")
alertcondition(shortSig, "Short", "Short condition met ({{ticker}} {{interval}})")
````
