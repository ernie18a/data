# Early Reversal Candlestick Pattern 

- url: https://www.tradingview.com/script/TnhNcD24-Early-Reversal-Candlestick-Pattern/
- type: indicator
- pine_id: PUB;24d5e4e0c5f44ab89d23e532a170ef05
- version: 1.0

## Description

[b]Early Reversal Candlestick Pattern Indicator (TradingView Pine Script v6)[/b]

Identify high-probability market reversals with this advanced candlestick pattern indicator. The script automatically detects and confirms multiple bullish and bearish reversal setups, helping traders spot potential trend changes with greater confidence.

✅ Included Patterns

🔹 Inside Bar Breakout (Bullish)
🔹 Inside Bar Breakdown (Bearish)
🔹 Hammer Confirmation (Bullish)
🔹 Shooting Star Confirmation (Bearish)
🔹 Bullish Engulfing Reversal
🔹 Bearish Engulfing Reversal

⚡ Key Features
Adjustable confirmation candle count
Individual pattern enable/disable controls
Separate color customization for each setup
Automatic visual highlighting of confirmed reversal zones
Works on all markets and timeframes


📈 How It Works

The indicator doesn't just identify candlestick patterns—it waits for additional confirmation candles before marking a setup, reducing false signals and improving trade quality.

Perfect for:
✔️ Price Action Traders
✔️ Swing Traders
✔️ Intraday Traders
✔️ Trend Reversal Strategies

💡 Combine with support/resistance, volume, and market structure for even better results.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartTrader-X

//@version=6
indicator("Early Reversal Candle Stick Pattern", overlay = true)

// ─── General Settings ───────────────────────────────────────────────────────
EmaLength = input.int(20, title="EMA Length")
Ema = ta.ema(close, EmaLength)
Num = input.int(2, title="Confirmation Candles")

// ─── Pattern On/Off Toggles ──────────────────────────────────────────────────
showPattern1 = input.bool(true, title="Inside Bar Breakout (Bull)",       group="Pattern Visibility", inline="pattern1")
Pattern1Color = input.color(#0ea813b4, "",                                 group="Pattern Visibility", inline="pattern1")
showPattern1S = input.bool(true, title="Inside Bar Breakdown (Bear)",      group="Pattern Visibility", inline="pattern1s")
Pattern1SColor = input.color(color.rgb(180, 20, 20, 40), "",               group="Pattern Visibility", inline="pattern1s")

showPattern2 = input.bool(true, title="Hammer Confirmation (Bull)",        group="Pattern Visibility", inline="pattern2")
Pattern2Color = input.color(color.rgb(11, 100, 14, 27), "",                group="Pattern Visibility", inline="pattern2")
showPattern2S = input.bool(true, title="Shooting Star Confirmation (Bear)",group="Pattern Visibility", inline="pattern2s")
Pattern2SColor = input.color(color.rgb(180, 30, 30, 27), "",               group="Pattern Visibility", inline="pattern2s")

showPattern3 = input.bool(true, title="Bullish Engulfing Reversal (Bull)", group="Pattern Visibility", inline="pattern3")
Pattern3Color = input.color(color.rgb(33, 112, 36, 40), "",                group="Pattern Visibility", inline="pattern3")
showPattern3S = input.bool(true, title="Bearish Engulfing Reversal (Bear)",group="Pattern Visibility", inline="pattern3s")
Pattern3SColor = input.color(color.rgb(180, 30, 30, 40), "",               group="Pattern Visibility", inline="pattern3s")

// ─── Candle Direction ────────────────────────────────────────────────────────
IsGreen = close > open
IsRed   = close < open

// ══════════════════════════════════════════════════════════════════════════════
// ─── Pattern 1 BUY : Inside Bar Breakout ─────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
Style1Up = IsRed[2] and IsGreen[1] and IsGreen and high[1] < high[2] and low[1] > low[2] and close > high[2]

var UpestAfterSec1      = 0.0
var UpestAfterSec1Index = 0
var LookForUp           = false
var SatrtPiointH        = 0.0
var SatrtPiointL        = 0.0
var SatrtPiointI        = 0
var Style1Count         = 0

if showPattern1
    if Style1Up
        LookForUp    := true
        Style1Count  += 1
        UpestAfterSec1 := open[2]
        SatrtPiointH := open[2]
        SatrtPiointL := low[2]
        SatrtPiointI := bar_index[2]
    if LookForUp and LookForUp[1]
        if close > UpestAfterSec1
            UpestAfterSec1 := high
            Style1Count    += 1
        if close < SatrtPiointL
            LookForUp   := false
            Style1Count := 0
    if LookForUp
        if Style1Count >= Num
            LookForUp   := false
            Style1Count := 0
            box.new(SatrtPiointI, SatrtPiointL, bar_index, close, #f4ebeb00, bgcolor=Pattern1Color)

// ══════════════════════════════════════════════════════════════════════════════
// ─── Pattern 1 SELL : Inside Bar Breakdown ───────────────────────────────────
// Bearish mirror: green mother candle → inside bar → breaks below mother's low
// ══════════════════════════════════════════════════════════════════════════════
Style1Down = IsGreen[2] and IsRed[1] and IsRed and high[1] < high[2] and low[1] > low[2] and close < low[2]

var LowestAfterSec1S  = 0.0
var LookForDown1      = false
var StartPointH1S     = 0.0
var StartPointL1S     = 0.0
var StartPointI1S     = 0
var Style1SCount      = 0

if showPattern1S
    if Style1Down
        LookForDown1    := true
        Style1SCount    += 1
        LowestAfterSec1S := open[2]
        StartPointH1S   := high[2]
        StartPointL1S   := open[2]
        StartPointI1S   := bar_index[2]
    if LookForDown1 and LookForDown1[1]
        if close < LowestAfterSec1S
            LowestAfterSec1S := low
            Style1SCount     += 1
        if close > StartPointH1S
            LookForDown1 := false
            Style1SCount := 0
    if LookForDown1
        if Style1SCount >= Num
            LookForDown1 := false
            Style1SCount := 0
            box.new(StartPointI1S, close, bar_index, StartPointH1S, #f4ebeb00, bgcolor=Pattern1SColor)

// ══════════════════════════════════════════════════════════════════════════════
// ─── Pattern 2 BUY : Hammer Confirmation ─────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
bodySize    = math.abs(close - open)
lowerShadow = math.min(open, close) - low
upperShadow = high - math.max(open, close)

isHammer = lowerShadow > bodySize * 2 and upperShadow < bodySize * 0.5 and (close < open[1] and close < close[1])

Style2Trigger = isHammer[1] and close > high[1] and close < Ema

var UpestAfterSec2 = 0.0
var LookForUp2     = false
var SatrtPiointH2  = 0.0
var SatrtPiointL2  = 0.0
var SatrtPiointI2  = 0
var Style2Count    = 0

if showPattern2
    if Style2Trigger
        LookForUp2     := true
        UpestAfterSec2 := open[1]
        SatrtPiointH2  := open[1]
        SatrtPiointL2  := low[1]
        SatrtPiointI2  := bar_index[1]
    if LookForUp2 and LookForUp2[1]
        if close > UpestAfterSec2
            UpestAfterSec2 := high
            Style2Count    += 1
        if close < SatrtPiointL2
            LookForUp2  := false
            Style2Count := 0

Style2Up = false
if showPattern2
    if LookForUp2
        if Style2Count >= Num
            LookForUp2  := false
            Style2Count := 0
            Style2Up    := true
            box.new(SatrtPiointI2, SatrtPiointL2, bar_index, close, #f4ebeb00, bgcolor=Pattern2Color)

// ══════════════════════════════════════════════════════════════════════════════
// ─── Pattern 2 SELL : Shooting Star Confirmation ─────────────────────────────
// Bearish mirror: shooting star (long upper shadow) above EMA,
// confirmed by a close below the shooting star's low
// ══════════════════════════════════════════════════════════════════════════════
isShootingStar = upperShadow > bodySize * 2 and lowerShadow < bodySize * 0.5 and (close > open[1] and close > close[1])

Style2STrigger = isShootingStar[1] and close < low[1] and close > Ema

var LowestAfterSec2S = 0.0
var LookForDown2     = false
var StartPointH2S    = 0.0
var StartPointL2S    = 0.0
var StartPointI2S    = 0
var Style2SCount     = 0

if showPattern2S
    if Style2STrigger
        LookForDown2     := true
        LowestAfterSec2S := open[1]
        StartPointH2S    := high[1]
        StartPointL2S    := open[1]
        StartPointI2S    := bar_index[1]
    if LookForDown2 and LookForDown2[1]
        if close < LowestAfterSec2S
            LowestAfterSec2S := low
            Style2SCount     += 1
        if close > StartPointH2S
            LookForDown2 := false
            Style2SCount := 0

Style2Down = false
if showPattern2S
    if LookForDown2
        if Style2SCount >= Num
            LookForDown2 := false
            Style2SCount := 0
            Style2Down   := true
            box.new(StartPointI2S, close, bar_index, StartPointH2S, #f4ebeb00, bgcolor=Pattern2SColor)

// ══════════════════════════════════════════════════════════════════════════════
// ─── Pattern 3 BUY : Bullish Engulfing Reversal ───────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
Style3Trigger = IsGreen[1] and IsRed and close < open[1] and open > close[1]

var UpestAfterSec3 = 0.0
var LookForUp3     = false
var SatrtPiointH3  = 0.0
var SatrtPiointL3  = 0.0
var SatrtPiointI3  = 0
Style3Up           = false
var Style3Count    = 0

if showPattern3
    if Style3Trigger
        LookForUp3     := true
        Style3Count    += 0
        UpestAfterSec3 := close[1]
        SatrtPiointH3  := close[1]
        SatrtPiointL3  := math.min(low[1], low)
        SatrtPiointI3  := bar_index[1]
    if LookForUp3 and LookForUp3[1]
        if close > UpestAfterSec3
            UpestAfterSec3 := high
            Style3Count    += 1
        if close < SatrtPiointL3
            LookForUp3  := false
            Style3Count := 0
    if LookForUp3
        if Style3Count >= Num
            LookForUp3  := false
            Style3Count := 0
            Style3Up    := true
            box.new(SatrtPiointI3, SatrtPiointL3, bar_index, close, #f4ebeb00, bgcolor=Pattern3Color)

// ══════════════════════════════════════════════════════════════════════════════
// ─── Pattern 3 SELL : Bearish Engulfing Reversal ─────────────────────────────
// Bearish engulf: red candle fully engulfs prior green candle
// Confirmed by N candles continuing lower
// ══════════════════════════════════════════════════════════════════════════════
Style3STrigger = IsRed[1] and IsGreen and close > open[1] and open < close[1]

var LowestAfterSec3S = 0.0
var LookForDown3     = false
var StartPointH3S    = 0.0
var StartPointL3S    = 0.0
var StartPointI3S    = 0
Style3Down           = false
var Style3SCount     = 0

if showPattern3S
    if Style3STrigger
        LookForDown3     := true
        Style3SCount     := 0
        LowestAfterSec3S := close[1]
        StartPointH3S    := math.max(high[1], high)
        StartPointL3S    := close[1]
        StartPointI3S    := bar_index[1]
    if LookForDown3 and LookForDown3[1]
        if close < LowestAfterSec3S
            LowestAfterSec3S := low
            Style3SCount     += 1
        if close > StartPointH3S
            LookForDown3 := false
            Style3SCount := 0
    if LookForDown3
        if Style3SCount >= Num
            LookForDown3 := false
            Style3SCount := 0
            Style3Down   := true
            box.new(StartPointI3S, close, bar_index, StartPointH3S, #f4ebeb00, bgcolor=Pattern3SColor)
````
