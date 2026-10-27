# Sniper FVG

- url: https://www.tradingview.com/script/UAEeWMIn-Sniper-FVG/
- type: indicator
- pine_id: PUB;b9ab9cf59e1e43edb26f477bea9df97d
- version: 7.0

## Description

This Pine Script indicator, Sniper FVG, is designed to highlight Fair Value Gaps (FVGs) within a defined trading session based on India Standard Time (IST). The user specifies a session window (default 19:00–01:40 IST), and the script automatically shades the chart background outside this range to keep focus on active trading hours. It also draws dashed vertical lines at session start and end for clear visual boundaries.

To filter signals, the script references higher‑timeframe EMA values (15m, 30m, 1h). At the first candle of each session, a bias is set: bullish if price is below all EMAs, bearish if price is above all EMAs, and neutral otherwise. Only FVGs aligned with this bias are drawn. The detection logic checks for gaps between the high of candle 1 and the low of candle 3 (bullish) or the low of candle 1 and the high of candle 3 (bearish). Boxes are extended a few bars forward, with customizable transparency, color, and minimum size percentage to avoid insignificant gaps.

Overall, the script combines session management, bias filtering, and gap visualization to help traders focus on meaningful FVG setups during their chosen trading hours.

## Source Code

````pine
//@version=6
indicator("Sniper FVG", overlay=true)

/// =========================
// INPUTS (Grouped per EMA)
// =========================
ema1_len   = input.int(50, "EMA1", minval = 1, inline = "EMA1")
ema1_tf    = input.timeframe("15", "", inline = "EMA1")
ema1_color = input.color(color.new(color.white, 80), "", inline = "EMA1")

ema2_len   = input.int(50, "EMA2", minval = 1, inline = "EMA2")
ema2_tf    = input.timeframe("30", "", inline = "EMA2")
ema2_color = input.color(color.new(color.green, 70), "", inline = "EMA2")

ema3_len   = input.int(50, "EMA3", minval = 1, inline = "EMA3")
ema3_tf    = input.timeframe("60", "", inline = "EMA3")
ema3_color = input.color(color.red, "", inline = "EMA3")

// =========================
// SECURITY CALLS
// =========================
ema1 = request.security(syminfo.tickerid, ema1_tf, ta.ema(close, ema1_len))
ema2 = request.security(syminfo.tickerid, ema2_tf, ta.ema(close, ema2_len))
ema3 = request.security(syminfo.tickerid, ema3_tf, ta.ema(close, ema3_len))

// =========================
// PLOTS
// =========================
plot(ema1, color = ema1_color, title = "EMA1")
plot(ema2, color = ema2_color, title = "EMA2")
plot(ema3, color = ema3_color, title = "EMA3")

//----------------------------------------------------
// User Inputs (IST times)
//----------------------------------------------------
sessionStart   = input.string("0700", "Session Start Time (HHMM, IST)")
sessionEnd     = input.string("2355", "Session End Time (HHMM, IST)")
tSessionStart   = input.string("1905", "Trading Start Time (HHMM, IST)")
tSessionEnd   = input.string("2155", "Trading End Time (HHMM, IST)")

//----------------------------------------------------
// Colors & Visuals
//----------------------------------------------------
// sessionStartColor = input.color(color.new(color.gray, 60), "Session Start Color")
sessionEndColor = input.color(color.new(color.gray, 80), "Session End Color")
tSessionEndColor = input.color(color.new(color.red, 80), "Trading End Color")

bullishColor   = input.color(color.new(color.red, 0), "Bullish FVG Color")
bearishColor   = input.color(color.new(color.green, 0), "Bearish FVG Color")
maxFvgExt      = input.int(11, "Max FVG Extension (candles)", minval=1, maxval=50)
atrLen         = input.int(14, "FVG Size basis ATR Length", minval=1, maxval=200)
isShowFvgLabel = input.bool(true, "Show FVG Label")
//----------------------------------------------------
// Bias Control
//----------------------------------------------------
forceBias = input.string(
     title = "Force Bias Or Automatic Investigate (AI)",
     defval = "AI",
     options = ["AI", "Bullish", "Bearish", "Both"]
)

//----------------------------------------------------

var line startLine = na
var line endLine   = na

//----------------------------------------------------
// Session Detection (explicit IST handling)
//----------------------------------------------------
curHour   = hour(time, "Asia/Kolkata")
curMinute = minute(time, "Asia/Kolkata")
curInt    = curHour * 100 + curMinute

startInt = str.tonumber(sessionStart)
endInt   = str.tonumber(sessionEnd)

// If sessionEnd is after sessionStart → same-day session
sameDaySession = endInt > startInt

inSession = sameDaySession ? (curInt >= startInt and curInt <= endInt) : (curInt >= startInt or curInt <= endInt)

tStartInt = str.tonumber(tSessionStart)
tEndInt = str.tonumber(tSessionEnd)
inTSession = (tEndInt > tStartInt) ? (curInt >= tStartInt and curInt <= tEndInt) : (curInt >= tStartInt or curInt <= tEndInt)


// When current bar matches sessionEnd time in IST
if not inSession and inSession[1]
    endLine := line.new(
        x1=bar_index, 
        y1=low, 
        x2=bar_index, 
        y2=high, 
        extend=extend.both, 
        color=sessionEndColor, 
        width=1,
        style = line.style_dashed)

// When current bar matches sessionEnd time in IST
if not inTSession and inTSession[1]
    endLine := line.new(
        x1=bar_index, 
        y1=low, 
        x2=bar_index, 
        y2=high, 
        extend=extend.both, 
        color=tSessionEndColor, 
        width=1,
        style = line.style_dashed)
    
//----------------------------------------------------
// Grey out outside session
//----------------------------------------------------
bgcolor(
     inSession ? na : color.new(color.gray, 99),   // 85 = transparency
     title = "Outside Session Shading"
)

//----------------------------------------------------
// Bias variables (fixed at first session candle)
//----------------------------------------------------
var int sessionBias = 0   // 0 = none, 1 = bullish, -1 = bearish
// var bool biasSet = false

if inSession // and not biasSet
    // First candle of session decides bias
    if close > ema3 // close > ema50_30m and close > ema50_15m 
        sessionBias := 1   // bullish bias → only bearish FVGs
    else if close < ema3 // close < ema50_30m and close < ema50_15m 
        sessionBias := -1    // bearish bias → only bullish FVGs
    else
        sessionBias := 0    // no bias → no FVGs
    // biasSet := true

if not inSession and inSession[1] // and inSession[1]
    sessionBias := 0
    // biasSet := false

//----------------------------------------------------
// FVG size vs ATR
// T < 25% | S 25-50% | M 50-100% | B >= 100%
//----------------------------------------------------
atrVal = ta.atr(atrLen)

fvgSizeLabel(gap) =>
    ratio = (na(atrVal) or atrVal <= 0) ? 1.0 : gap / atrVal
    ratio < 0.25 ? "" : ratio < 0.50 ? "s" : ratio < 1.0 ? "m" : "B"

//----------------------------------------------------
// Helper Function: Draw FVG Box
//----------------------------------------------------
drawFVG(leftIndex, rightIndex, top, bottom, fvgColor, fvgText) =>
    box.new(left=leftIndex, 
            right=rightIndex, 
            top=top, 
            bottom=bottom, 
            bgcolor=na,
            border_color=fvgColor,
            border_width=1,
            border_style=line.style_dotted,
            text= isShowFvgLabel ? fvgText : "",
            text_color=color.white,//fvgColor,
            text_size=size.tiny,
            text_halign=text.align_center,
            text_valign=text.align_center)

//----------------------------------------------------
// FVG State (extend max 9 candles, close-based break)
//----------------------------------------------------
type FvgObj
    box bx
    float top
    float bot
    int created
    bool isBull
    bool active

var FvgObj[] fvgs = array.new<FvgObj>()

updateFvgBoxes() =>
    sz = array.size(fvgs)
    if sz > 0
        for i = 0 to sz - 1
            fvg = array.get(fvgs, i)
            if fvg.active and bar_index > fvg.created
                ext = bar_index - fvg.created
                if ext <= maxFvgExt
                    // Close-based break: bullish FVG broken when close enters/through from above;
                    // bearish FVG broken when close enters/through from below.
                    broken = fvg.isBull ? (close <= fvg.bot) : (close >= fvg.top)
                    if broken
                        // Breaking candle is never included
                        box.set_right(fvg.bx, bar_index + 1)
                        fvg.active := false
                    else
                        box.set_right(fvg.bx, bar_index)
                        if ext == maxFvgExt
                            fvg.active := false

//----------------------------------------------------
// FVG Detection Logic
//----------------------------------------------------
// fvgBuffer = 1
fvgBuffer = (1 + (0.0061/100))
// Bullish FVG (show when sessionBias = -1 or forceBias = Bearish)
// isBearishFVG = (low > high[2])
isBearishFVG = (low > (high[2] * fvgBuffer))
bullishCandleCond = inSession and ((forceBias == "AI" and sessionBias == -1) or forceBias == "Bearish" or forceBias == "Both") and isBearishFVG

// Bearish FVG (show when sessionBias = 1 or forceBias = Bullish)
// isBullishFVG = (high < low[2])
isBullishFVG = ((high * fvgBuffer) < low[2])
bearishCandleCond = inSession and ((forceBias == "AI" and sessionBias == 1) or forceBias == "Bullish" or forceBias == "Both") and isBullishFVG

// Close-based: update existing FVGs first, then create new ones on confirmed bars only
if barstate.isconfirmed
    updateFvgBoxes()
    if bullishCandleCond
        bullGap = math.abs(low - high[2])
        bx = drawFVG(bar_index - 2, bar_index, high[2], low, bullishColor, fvgSizeLabel(bullGap))
        array.push(fvgs, FvgObj.new(bx, low, high[2], bar_index, true, true))
    if bearishCandleCond
        bearGap = math.abs(low[2] - high)
        bx = drawFVG(bar_index - 2, bar_index, low[2], high, bearishColor, fvgSizeLabel(bearGap))
        array.push(fvgs, FvgObj.new(bx, low[2], high, bar_index, false, true))
````
