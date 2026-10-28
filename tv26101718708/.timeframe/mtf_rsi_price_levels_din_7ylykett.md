# MTF RSI Price Levels [DIN]

- url: https://www.tradingview.com/script/7ylYkeTt-MTF-RSI-Price-Levels-DIN/
- type: indicator
- pine_id: PUB;db4f1c97d5e34e848fdee3a18d0e12d4
- version: 2.0

## Description

## 📌 MTF RSI Price Levels [DIN]

**What if your RSI could tell you exactly where price needs to go — before it gets there?**

Most traders use RSI to read momentum after the fact. This indicator flips that entirely. Instead of watching RSI react to price, **MTF RSI Price Levels projects the exact price required for RSI to reach overbought or oversold on up to four timeframes simultaneously** — plotted live, directly on your chart, right now.

The result is a set of forward-looking price levels that act as precision targets and confluence zones. Whether you're scalping the 1H or positioning on the weekly, you'll know in advance where RSI exhaustion lives — and when multiple timeframes agree, those levels become some of the most powerful areas on your chart.

---

## 🔬 How It Works

The RSI Price Level math is built on Wilder's smoothing algorithm — the same engine that powers the standard RSI. At every bar close, the indicator works backwards through the formula: given the current average gain and average loss at a specific timeframe, it solves for the exact closing price that would push RSI to your target level (default 70 overbought / 30 oversold) on the next bar.

This is not an approximation. It is a mathematically derived price level, recalculated live across every timeframe you have enabled, displayed as a labeled box and a centerline extending right from the current bar. Every time price moves, the levels update. Every time a new bar closes, the calculation refreshes.

Run it on crypto, forex, indices, or equities — wherever RSI has teeth, these levels will show you exactly where the market is being pulled.

---

## ☁️ The MTF Cloud

Above and below price, two dynamic clouds form — one anchored at your overbought RSI level, one at oversold — each blending between two user-selected timeframes. Where the clouds from different timeframes converge, you get a gradient zone of confluence. The closer price approaches these areas, the more compressed momentum tends to become.

The cloud is not decorative. It represents the space between what two different timeframe RSI calculations say about the same price level. When they agree, the cloud tightens. When they diverge, it widens. Bull and bear coloring shifts automatically based on where current price sits relative to the zone, giving you an instant read on whether you're approaching resistance or support.

---

## 📐 Built-In Divergence Engine

Hidden momentum shifts are detected automatically using a pivot-based divergence system running on your chosen timeframe. When price prints a higher high but RSI prints a lower high — or vice versa — the signal is marked directly on the chart with a clear label. No separate RSI panel needed. No manual scanning. The divergence comes to you.

- **Bearish Divergence (DIV▼)** — Price higher high, RSI lower high. Momentum fading into resistance.
- **Bullish Divergence (DIV▲)** — Price lower low, RSI higher low. Momentum building into support.

Both pivot lookback and divergence timeframe are fully adjustable.

---

## ⚙️ Full Customization — Built for Serious Traders

This indicator was designed so that no two setups have to look alike. Every parameter that matters is exposed in the settings panel, organized by group:

**Per Timeframe (up to 4 timeframes):**
- Timeframe selection (any TF supported by TradingView)
- Independent RSI length per timeframe
- Independent RSI source per timeframe
- Custom overbought and oversold threshold levels
- Individual box color, line color, and transparency per TF

**Cloud Settings:**
- Choose any two timeframes to anchor the cloud
- Set your own Level A and Level B for the fill range
- Independent bull and bear color for inner and outer cloud layers
- Gradual two-layer gradient fade built in

**Box & Line Style:**
- Box extend length (how far right the box projects)
- Box height as a percentage of price (works across all asset classes)
- Line width and line style (solid, dashed, dotted)
- Toggle labels on/off with adjustable label size

**Divergence:**
- Enable/disable divergence detection independently
- Choose the timeframe RSI runs the divergence scan on
- Adjust RSI length and pivot lookback for sensitivity control

**Alerts (4 Conditions):**
- Price enters any overbought zone
- Price enters any oversold zone
- Bullish divergence detected
- Bearish divergence detected

Set your alerts once. Let the indicator do the watching.

---

## 🎯 Best Use Cases

- **Confluence trading** — Stack multiple TF RSI levels and watch for price to cluster around the same area across 1H, 4H, Daily, and Weekly simultaneously. These are your highest-conviction zones.
- **Target projection** — In a trending move, use the OB levels on higher timeframes as your take-profit targets. The math tells you where RSI exhaustion lives.
- **Reversal hunting** — When price is approaching a major OS level on the Daily or Weekly with bullish divergence firing beneath, you have a layered, high-probability setup.
- **Scalping structure** — On lower timeframes, the levels act as short-term magnets. Watch how price respects or breaks through these zones and trade the reaction.

---

## 📋 Usage Notes

- **Higher timeframe levels carry more weight.** A Weekly OB level that aligns with a Daily OB level is significantly more significant than either alone.
- **The box height input is a percentage of price.** The default (0.003 = 0.3%) works well for most assets. Crypto with large price ranges may benefit from a lower value; lower-priced assets may need it slightly higher.
- **Divergence signals are plotted with an offset** equal to the pivot lookback period. This means the signal appears when the pivot is confirmed, not at the exact candle — this is intentional and keeps signals non-repainting.
- **Cloud timeframes are independent of the level timeframes.** You can run 1H + 4H levels while anchoring your cloud to 4H + Daily for a broader confluence picture.

---

## 🔔 Alerts Setup

After adding the indicator to your chart, go to the Alerts panel, create a new alert, and select this indicator from the condition dropdown. Four conditions are available:

1. Price in OB Zone
2. Price in OS Zone
3. Bearish Divergence Found
4. Bullish Divergence Found

---

*Built for traders who want their RSI to work harder.*
*Clean levels. Real math. No guessing.*

**— DIN**

## Source Code

````pine
//@version=5
indicator("MTF RSI Price Levels [DIN] v6", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════
//  GROUP: CLOUD SETTINGS
// ═══════════════════════════════════════════════════════════
grpCloud = "☁️ Cloud Settings"
showCloud       = input.bool(false,  "Show Cloud",                        group=grpCloud)
cloudTF1        = input.timeframe("15",  "Cloud TF1 (fastest)",         group=grpCloud)
cloudTF2        = input.timeframe("60",  "Cloud TF2",                   group=grpCloud)
cloudTF3        = input.timeframe("240", "Cloud TF3",                   group=grpCloud)
cloudTF4        = input.timeframe("D",   "Cloud TF4 (slowest)",         group=grpCloud)
cloudRsiLen     = input.int(14, "Cloud RSI Length",                     group=grpCloud, minval=2)
cloudOB         = input.float(60.0, "Bearish threshold (RSI >)",        group=grpCloud, minval=50, maxval=99, step=1.0)
cloudOS         = input.float(40.0, "Bullish threshold (RSI <)",        group=grpCloud, minval=1,  maxval=50, step=1.0)
cloudSmooth     = input.int(3, "Cloud Smoothing (bars)",                group=grpCloud, minval=1, maxval=10)

// Bull gradient: outer (faint) → inner (rich)
cBull1 = input.color(color.new(color.green, 92), "Bull Layer 1 (outer)", group=grpCloud)
cBull2 = input.color(color.new(color.green, 82), "Bull Layer 2",         group=grpCloud)
cBull3 = input.color(color.new(color.green, 68), "Bull Layer 3",         group=grpCloud)
cBull4 = input.color(color.new(color.green, 50), "Bull Layer 4 (inner)", group=grpCloud)

// Bear gradient: outer (faint) → inner (rich)
cBear1 = input.color(color.new(color.red, 92), "Bear Layer 1 (outer)", group=grpCloud)
cBear2 = input.color(color.new(color.red, 82), "Bear Layer 2",          group=grpCloud)
cBear3 = input.color(color.new(color.red, 68), "Bear Layer 3",          group=grpCloud)
cBear4 = input.color(color.new(color.red, 50), "Bear Layer 4 (inner)", group=grpCloud)

// ═══════════════════════════════════════════════════════════
//  GROUP: TIMEFRAME 1
// ═══════════════════════════════════════════════════════════
grpTF1 = "⏱ Timeframe 1"
showTF1      = input.bool(true,   "Show TF1",             group=grpTF1)
tf1          = input.timeframe("60",  "Timeframe 1",      group=grpTF1)
rsiLen1      = input.int(14,      "RSI Length TF1",       group=grpTF1, minval=2)
rsiSrc1      = input.source(close,"RSI Source TF1",       group=grpTF1)
obLevel1     = input.float(70.0,  "Overbought Level TF1", group=grpTF1, minval=50, maxval=99, step=0.5)
osLevel1     = input.float(30.0,  "Oversold Level TF1",   group=grpTF1, minval=1,  maxval=50, step=0.5)
boxColorOB1  = input.color(color.new(color.red,   75), "OB Box Color TF1", group=grpTF1)
boxColorOS1  = input.color(color.new(color.green, 75), "OS Box Color TF1", group=grpTF1)
lineColorOB1 = input.color(color.new(color.red,   20), "OB Line Color TF1", group=grpTF1)
lineColorOS1 = input.color(color.new(color.green, 20), "OS Line Color TF1", group=grpTF1)

// ═══════════════════════════════════════════════════════════
//  GROUP: TIMEFRAME 2
// ═══════════════════════════════════════════════════════════
grpTF2 = "⏱ Timeframe 2"
showTF2      = input.bool(true,   "Show TF2",             group=grpTF2)
tf2          = input.timeframe("240", "Timeframe 2",      group=grpTF2)
rsiLen2      = input.int(14,      "RSI Length TF2",       group=grpTF2, minval=2)
rsiSrc2      = input.source(close,"RSI Source TF2",       group=grpTF2)
obLevel2     = input.float(70.0,  "Overbought Level TF2", group=grpTF2, minval=50, maxval=99, step=0.5)
osLevel2     = input.float(30.0,  "Oversold Level TF2",   group=grpTF2, minval=1,  maxval=50, step=0.5)
boxColorOB2  = input.color(color.new(color.orange, 75), "OB Box Color TF2", group=grpTF2)
boxColorOS2  = input.color(color.new(color.teal,   75), "OS Box Color TF2", group=grpTF2)
lineColorOB2 = input.color(color.new(color.orange, 20), "OB Line Color TF2", group=grpTF2)
lineColorOS2 = input.color(color.new(color.teal,   20), "OS Line Color TF2", group=grpTF2)

// ═══════════════════════════════════════════════════════════
//  GROUP: TIMEFRAME 3
// ═══════════════════════════════════════════════════════════
grpTF3 = "⏱ Timeframe 3"
showTF3      = input.bool(true,   "Show TF3",             group=grpTF3)
tf3          = input.timeframe("D",   "Timeframe 3",      group=grpTF3)
rsiLen3      = input.int(14,      "RSI Length TF3",       group=grpTF3, minval=2)
rsiSrc3      = input.source(close,"RSI Source TF3",       group=grpTF3)
obLevel3     = input.float(70.0,  "Overbought Level TF3", group=grpTF3, minval=50, maxval=99, step=0.5)
osLevel3     = input.float(30.0,  "Oversold Level TF3",   group=grpTF3, minval=1,  maxval=50, step=0.5)
boxColorOB3  = input.color(color.new(color.purple, 75), "OB Box Color TF3", group=grpTF3)
boxColorOS3  = input.color(color.new(color.blue,   75), "OS Box Color TF3", group=grpTF3)
lineColorOB3 = input.color(color.new(color.purple, 20), "OB Line Color TF3", group=grpTF3)
lineColorOS3 = input.color(color.new(color.blue,   20), "OS Line Color TF3", group=grpTF3)

// ═══════════════════════════════════════════════════════════
//  GROUP: TIMEFRAME 4
// ═══════════════════════════════════════════════════════════
grpTF4 = "⏱ Timeframe 4"
showTF4      = input.bool(true,   "Show TF4",             group=grpTF4)
tf4          = input.timeframe("W",   "Timeframe 4",      group=grpTF4)
rsiLen4      = input.int(14,      "RSI Length TF4",       group=grpTF4, minval=2)
rsiSrc4      = input.source(close,"RSI Source TF4",       group=grpTF4)
obLevel4     = input.float(70.0,  "Overbought Level TF4", group=grpTF4, minval=50, maxval=99, step=0.5)
osLevel4     = input.float(30.0,  "Oversold Level TF4",   group=grpTF4, minval=1,  maxval=50, step=0.5)
boxColorOB4  = input.color(color.new(color.yellow, 75), "OB Box Color TF4", group=grpTF4)
boxColorOS4  = input.color(color.new(color.aqua,   75), "OS Box Color TF4", group=grpTF4)
lineColorOB4 = input.color(color.new(color.yellow, 20), "OB Line Color TF4", group=grpTF4)
lineColorOS4 = input.color(color.new(color.aqua,   20), "OS Line Color TF4", group=grpTF4)

// ═══════════════════════════════════════════════════════════
//  GROUP: BOX / LINE / LABEL STYLE
// ═══════════════════════════════════════════════════════════
grpStyle = "🎨 Box & Line Style"
boxExtend    = input.int(20,      "Box Extend (bars right)",    group=grpStyle, minval=1, maxval=200)
boxHeight    = input.float(0.003, "Box Height (% of price)",    group=grpStyle, minval=0.0001, maxval=0.05, step=0.0005)
lineWidth    = input.int(1,       "Line Width",                  group=grpStyle, minval=1, maxval=4)
lineStyle    = input.string("solid", "Line Style",              group=grpStyle, options=["solid","dashed","dotted"])
showLabels   = input.bool(true,   "Show Labels",                 group=grpStyle)

// ═══════════════════════════════════════════════════════════
//  GROUP: RSI BOLLINGER BANDS (on chart)
// ═══════════════════════════════════════════════════════════
grpBB = "📊 RSI Bollinger Bands"
showRSIBB       = input.bool(false, "Show RSI BB Levels on Chart", group=grpBB)
rsiBBLen        = input.int(20,     "BB Length",                   group=grpBB, minval=2)
rsiBBMult       = input.float(2.0,  "BB Multiplier",               group=grpBB, minval=0.1, maxval=5.0, step=0.1)
rsiBBTF         = input.timeframe("60", "RSI BB Timeframe",        group=grpBB)
rsiBBRsiLen     = input.int(14,     "RSI Length for BB",           group=grpBB, minval=2)
rsiBBUpperColor = input.color(color.new(color.fuchsia, 50), "BB Upper Band Color", group=grpBB)
rsiBBLowerColor = input.color(color.new(color.aqua,    50), "BB Lower Band Color", group=grpBB)
rsiBBMidColor   = input.color(color.new(color.gray,    70), "BB Mid Color",        group=grpBB)

// ═══════════════════════════════════════════════════════════
//  GROUP: DIVERGENCE
// ═══════════════════════════════════════════════════════════
grpDiv = "📐 Divergence"
showDiv      = input.bool(true,  "Show Divergence Signals",   group=grpDiv)
divTF        = input.timeframe("60", "Divergence Timeframe",  group=grpDiv)
divRsiLen    = input.int(14,     "Divergence RSI Length",      group=grpDiv, minval=2)
divLookback  = input.int(5,      "Pivot Lookback",             group=grpDiv, minval=2, maxval=20)
divBullColor = input.color(color.new(color.lime, 0),  "Bull Div Color", group=grpDiv)
divBearColor = input.color(color.new(color.red,  0),  "Bear Div Color", group=grpDiv)

// ═══════════════════════════════════════════════════════════
//  GROUP: ALERTS
// ═══════════════════════════════════════════════════════════
grpAlert = "🔔 Alerts"
alertOB  = input.bool(true, "Alert: Price Enters OB Zone (any TF)", group=grpAlert)
alertOS  = input.bool(true, "Alert: Price Enters OS Zone (any TF)", group=grpAlert)
alertDiv = input.bool(true, "Alert: Divergence Detected",           group=grpAlert)

// ═══════════════════════════════════════════════════════════
//  RSI COMPONENT + PRICE LEVEL MATH
// ═══════════════════════════════════════════════════════════
f_rsiComponents(src, len) =>
    change_val = ta.change(src)
    gain       = change_val > 0 ? change_val : 0.0
    loss       = change_val < 0 ? -change_val : 0.0
    avgGain    = ta.rma(gain, len)
    avgLoss    = ta.rma(loss, len)
    [avgGain, avgLoss]

f_priceForRSI(avgGain, avgLoss, currentClose, targetRSI, len) =>
    float targetPrice = na
    if not na(avgGain) and not na(avgLoss) and targetRSI > 0 and targetRSI < 100
        RS_target      = targetRSI / (100.0 - targetRSI)
        newAvgLoss_up  = avgLoss * (len - 1) / len
        if newAvgLoss_up > 1e-10
            change_needed = RS_target * newAvgLoss_up * len - avgGain * (len - 1)
            candidate     = currentClose + change_needed
            if change_needed >= 0
                targetPrice := candidate
        if na(targetPrice)
            if RS_target > 1e-10
                loss_needed = avgGain * (len - 1) / RS_target - avgLoss * (len - 1)
                candidate2  = currentClose - loss_needed
                if loss_needed >= 0
                    targetPrice := candidate2
    targetPrice

// ═══════════════════════════════════════════════════════════
//  FETCH MTF RSI COMPONENTS (for price levels)
// ═══════════════════════════════════════════════════════════
[ag1, al1] = request.security(syminfo.tickerid, tf1, f_rsiComponents(rsiSrc1, rsiLen1), lookahead=barmerge.lookahead_off)
[ag2, al2] = request.security(syminfo.tickerid, tf2, f_rsiComponents(rsiSrc2, rsiLen2), lookahead=barmerge.lookahead_off)
[ag3, al3] = request.security(syminfo.tickerid, tf3, f_rsiComponents(rsiSrc3, rsiLen3), lookahead=barmerge.lookahead_off)
[ag4, al4] = request.security(syminfo.tickerid, tf4, f_rsiComponents(rsiSrc4, rsiLen4), lookahead=barmerge.lookahead_off)

close1 = request.security(syminfo.tickerid, tf1, close, lookahead=barmerge.lookahead_off)
close2 = request.security(syminfo.tickerid, tf2, close, lookahead=barmerge.lookahead_off)
close3 = request.security(syminfo.tickerid, tf3, close, lookahead=barmerge.lookahead_off)
close4 = request.security(syminfo.tickerid, tf4, close, lookahead=barmerge.lookahead_off)

obPrice1 = f_priceForRSI(ag1, al1, close1, obLevel1, rsiLen1)
osPrice1 = f_priceForRSI(ag1, al1, close1, osLevel1, rsiLen1)
obPrice2 = f_priceForRSI(ag2, al2, close2, obLevel2, rsiLen2)
osPrice2 = f_priceForRSI(ag2, al2, close2, osLevel2, rsiLen2)
obPrice3 = f_priceForRSI(ag3, al3, close3, obLevel3, rsiLen3)
osPrice3 = f_priceForRSI(ag3, al3, close3, osLevel3, rsiLen3)
obPrice4 = f_priceForRSI(ag4, al4, close4, obLevel4, rsiLen4)
osPrice4 = f_priceForRSI(ag4, al4, close4, osLevel4, rsiLen4)

// ═══════════════════════════════════════════════════════════
//  RSI BB LEVELS (on chart)
// ═══════════════════════════════════════════════════════════
[bbAG, bbAL] = request.security(syminfo.tickerid, rsiBBTF, f_rsiComponents(close, rsiBBRsiLen), lookahead=barmerge.lookahead_off)
bbRsiRaw     = request.security(syminfo.tickerid, rsiBBTF, ta.rsi(close, rsiBBRsiLen),           lookahead=barmerge.lookahead_off)
bbClose      = request.security(syminfo.tickerid, rsiBBTF, close,                                lookahead=barmerge.lookahead_off)
bbMid        = ta.sma(bbRsiRaw, rsiBBLen)
bbStdDv      = ta.stdev(bbRsiRaw, rsiBBLen)
bbUpperRSI   = math.min(bbMid + rsiBBMult * bbStdDv, 99)
bbLowerRSI   = math.max(bbMid - rsiBBMult * bbStdDv, 1)
bbMidRSI     = math.min(math.max(bbMid, 1), 99)
bbUpperPrice = f_priceForRSI(bbAG, bbAL, bbClose, bbUpperRSI, rsiBBRsiLen)
bbLowerPrice = f_priceForRSI(bbAG, bbAL, bbClose, bbLowerRSI, rsiBBRsiLen)
bbMidPrice   = f_priceForRSI(bbAG, bbAL, bbClose, bbMidRSI,   rsiBBRsiLen)

plot(showRSIBB and not na(bbUpperPrice) ? bbUpperPrice : na, "RSI BB Upper", color=rsiBBUpperColor, linewidth=1)
plot(showRSIBB and not na(bbLowerPrice) ? bbLowerPrice : na, "RSI BB Lower", color=rsiBBLowerColor, linewidth=1)
plot(showRSIBB and not na(bbMidPrice)   ? bbMidPrice   : na, "RSI BB Mid",   color=rsiBBMidColor,   linewidth=1, style=plot.style_circles)

// ═══════════════════════════════════════════════════════════
//  CLOUD ENGINE — EMA Ribbon style
//
//  Core idea: 
//    Each cloud TF gives us an RSI value (smoothed). 
//    We map RSI → a "band offset" around the current close.
//    The offset = how far price is from the OB/OS midpoint,
//    scaled by recent ATR so the cloud breathes with volatility.
//    We stack 4 smoothed price bands (one per cloud TF) and 
//    fill between adjacent pairs with a gradient.
//    The fill color reflects CONFLUENCE: more TFs agreeing
//    = deeper/richer color.
// ═══════════════════════════════════════════════════════════

// Fetch RSI for each cloud TF and smooth
rsiC1_raw = request.security(syminfo.tickerid, cloudTF1, ta.rsi(close, cloudRsiLen), lookahead=barmerge.lookahead_off)
rsiC2_raw = request.security(syminfo.tickerid, cloudTF2, ta.rsi(close, cloudRsiLen), lookahead=barmerge.lookahead_off)
rsiC3_raw = request.security(syminfo.tickerid, cloudTF3, ta.rsi(close, cloudRsiLen), lookahead=barmerge.lookahead_off)
rsiC4_raw = request.security(syminfo.tickerid, cloudTF4, ta.rsi(close, cloudRsiLen), lookahead=barmerge.lookahead_off)

// Smooth RSI values to eliminate choppiness
rsiC1 = ta.ema(nz(rsiC1_raw, 50), cloudSmooth)
rsiC2 = ta.ema(nz(rsiC2_raw, 50), cloudSmooth)
rsiC3 = ta.ema(nz(rsiC3_raw, 50), cloudSmooth)
rsiC4 = ta.ema(nz(rsiC4_raw, 50), cloudSmooth)

// ATR for scaling cloud band width to price volatility
atrVal = ta.atr(14)

// RSI → signed distance from neutral (50)
// +100% overbought → band pushes far above price
// -100% oversold   → band pushes far below price
// Scale: 1 ATR per 50 RSI points from neutral
f_rsiToBand(rsiVal, atr) =>
    neutralized = (rsiVal - 50) / 50.0   // range: -1 to +1
    neutralized * atr * 2.5              // scaled band offset

offset1 = f_rsiToBand(rsiC1, atrVal)
offset2 = f_rsiToBand(rsiC2, atrVal)
offset3 = f_rsiToBand(rsiC3, atrVal)
offset4 = f_rsiToBand(rsiC4, atrVal)

// Build 5 smooth price bands: close ± weighted offsets
// Band ordering: sort by offset so fills are always valid (no flipping)
// We use an EMA of close as anchor so cloud doesn't hug every candle
cloudAnchor = ta.ema(close, 3)

band1 = cloudAnchor + offset1   // TF1 (fastest)
band2 = cloudAnchor + offset2   // TF2
band3 = cloudAnchor + offset3   // TF3
band4 = cloudAnchor + offset4   // TF4 (slowest)
bandMid = cloudAnchor           // center line

// Sort bands into upper/lower groups per-bar to avoid fill crossing
// For fills: we layer outward from center
// Upper cloud = positive offsets (bull bands above price)
// Lower cloud = negative offsets (bear bands below price)
upperBand4 = math.max(band1, band2, band3, band4)
upperBand3 = math.max(
     math.min(math.max(band1, band2, band3), math.max(band1, band2, band4), math.max(band1, band3, band4)),
     math.min(math.max(band2, band3, band4), math.max(band1, band2, band4), math.max(band1, band3, band4))
     )
lowerBand4 = math.min(band1, band2, band3, band4)
lowerBand3 = math.min(
     math.max(math.min(band1, band2, band3), math.min(band1, band2, band4), math.min(band1, band3, band4)),
     math.max(math.min(band2, band3, band4), math.min(band1, band2, band4), math.min(band1, band3, band4))
     )

// Simplified but reliable: sort all 4 offsets
sortedHigh  = math.max(offset1, offset2, offset3, offset4)
sortedLow   = math.min(offset1, offset2, offset3, offset4)
sortedMidHi = math.max(offset1, offset2, offset3, offset4) - math.abs(sortedHigh - sortedLow) * 0.33
sortedMidLo = math.min(offset1, offset2, offset3, offset4) + math.abs(sortedHigh - sortedLow) * 0.33

p4Hi = cloudAnchor + sortedHigh          // outermost upper
p3Hi = cloudAnchor + sortedMidHi         // inner upper
p3Lo = cloudAnchor + sortedMidLo         // inner lower
p4Lo = cloudAnchor + sortedLow           // outermost lower

// Confluence score: how many TFs agree on direction?
// +1 for bull (RSI < cloudOS), -1 for bear (RSI > cloudOB), 0 neutral
score1 = rsiC1 < cloudOS ? 1 : rsiC1 > cloudOB ? -1 : 0
score2 = rsiC2 < cloudOS ? 1 : rsiC2 > cloudOB ? -1 : 0
score3 = rsiC3 < cloudOS ? 1 : rsiC3 > cloudOB ? -1 : 0
score4 = rsiC4 < cloudOS ? 1 : rsiC4 > cloudOB ? -1 : 0
confluence = score1 + score2 + score3 + score4   // range: -4 to +4

isBull = confluence > 0
isBear = confluence < 0

// Gradient layer colors based on confluence strength
// Outer layers = always faint, inner = scales with confluence
outerFillUp = isBull ? cBull1 : isBear ? cBear1 : color.new(color.gray, 93)
midFillUp   = isBull ? (math.abs(confluence) >= 3 ? cBull3 : cBull2) : isBear ? (math.abs(confluence) >= 3 ? cBear3 : cBear2) : color.new(color.gray, 88)
outerFillDn = isBull ? cBull1 : isBear ? cBear1 : color.new(color.gray, 93)
midFillDn   = isBull ? (math.abs(confluence) >= 3 ? cBull3 : cBull2) : isBear ? (math.abs(confluence) >= 3 ? cBear3 : cBear2) : color.new(color.gray, 88)
innerFill   = isBull ? (math.abs(confluence) == 4 ? cBull4 : cBull3) : isBear ? (math.abs(confluence) == 4 ? cBear4 : cBear3) : color.new(color.gray, 85)

// Plot the 4 band lines (invisible, just anchors for fill)
p_top    = plot(showCloud ? p4Hi      : na, "Cloud Top",      color=na, editable=false)
p_midHi  = plot(showCloud ? p3Hi      : na, "Cloud Mid-Hi",   color=na, editable=false)
p_anchor = plot(showCloud ? cloudAnchor: na, "Cloud Anchor",  color=na, editable=false)
p_midLo  = plot(showCloud ? p3Lo      : na, "Cloud Mid-Lo",   color=na, editable=false)
p_bot    = plot(showCloud ? p4Lo      : na, "Cloud Bot",      color=na, editable=false)

// 4 gradient fills: outer upper → mid upper → anchor → mid lower → outer lower
fill(p_top,    p_midHi,  outerFillUp, "Cloud Outer Upper")
fill(p_midHi,  p_anchor, midFillUp,   "Cloud Mid Upper")
fill(p_anchor, p_midLo,  midFillDn,   "Cloud Mid Lower")
fill(p_midLo,  p_bot,    outerFillDn, "Cloud Outer Lower")

// ═══════════════════════════════════════════════════════════
//  LABEL + BOX HELPERS
// ═══════════════════════════════════════════════════════════
f_lineStyle(s) =>
    s == "dashed" ? line.style_dashed : s == "dotted" ? line.style_dotted : line.style_solid

f_priceFmt(p) =>
    p >= 1000 ? str.tostring(p, "#,###.##") :
     p >= 100  ? str.tostring(p, "###.##")  :
     p >= 10   ? str.tostring(p, "##.####") :
                 str.tostring(p, "#.#####")

f_pctChange(levelPrice) =>
    pct  = (levelPrice - close) / close * 100
    sign = pct >= 0 ? "+" : ""
    sign + str.tostring(pct, "#.##") + "%"

var box[]   boxStore  = array.new_box()
var line[]  lineStore = array.new_line()
var label[] lblStore  = array.new_label()

f_drawLevel(price, isOB, tfLabel, bColor, lColor, show) =>
    if show and not na(price) and barstate.islast
        halfH        = price * boxHeight / 2
        bTop         = price + halfH
        bBot         = price - halfH
        // Semantic colors: OB always red, OS always green — matches label
        boxBg  = isOB ? color.new(color.red,   45) : color.new(color.green, 45)
        boxBdr = isOB ? color.new(color.red,   20) : color.new(color.green, 20)
        b = box.new(bar_index, bTop, bar_index + boxExtend, bBot,
             border_color=boxBdr, bgcolor=boxBg,
             border_width=lineWidth, border_style=f_lineStyle(lineStyle),
             extend=extend.none)
        array.push(boxStore, b)
        l = line.new(bar_index - 3, price, bar_index + boxExtend, price,
             color=boxBdr, width=lineWidth, style=f_lineStyle(lineStyle))
        array.push(lineStore, l)
        if showLabels
            lblBg  = isOB ? color.new(color.red, 45) : color.new(color.green, 45)
            pct    = (price - close) / close * 100
            pctStr = (pct >= 0 ? "+" : "") + str.tostring(pct, "#.##") + "%"
            pctCol = pct >= 0 ? color.new(color.lime, 0) : color.new(color.red, 0)
            prStr  = f_priceFmt(price)
            tag    = isOB ? "Overbought " + tfLabel : "Oversold " + tfLabel
            lbl = label.new(bar_index + boxExtend, price,
                 tag + "  " + prStr + "  " + pctStr,
                 color=lblBg, textcolor=color.white,
                 style=label.style_label_left, size=size.tiny)
            array.push(lblStore, lbl)

// ═══════════════════════════════════════════════════════════
//  PURGE + REDRAW
// ═══════════════════════════════════════════════════════════
if barstate.islast
    for b in boxStore
        box.delete(b)
    array.clear(boxStore)
    for l in lineStore
        line.delete(l)
    array.clear(lineStore)
    for lbl in lblStore
        label.delete(lbl)
    array.clear(lblStore)

    f_drawLevel(obPrice1, true,  "1H",  boxColorOB1, lineColorOB1, showTF1)
    f_drawLevel(osPrice1, false, "1H",  boxColorOS1, lineColorOS1, showTF1)
    f_drawLevel(obPrice2, true,  "4H",  boxColorOB2, lineColorOB2, showTF2)
    f_drawLevel(osPrice2, false, "4H",  boxColorOS2, lineColorOS2, showTF2)
    f_drawLevel(obPrice3, true,  "D",   boxColorOB3, lineColorOB3, showTF3)
    f_drawLevel(osPrice3, false, "D",   boxColorOS3, lineColorOS3, showTF3)
    f_drawLevel(obPrice4, true,  "W",   boxColorOB4, lineColorOB4, showTF4)
    f_drawLevel(osPrice4, false, "W",   boxColorOS4, lineColorOS4, showTF4)

    // RSI BB labels
    if showRSIBB
        if not na(bbUpperPrice)
            halfH = bbUpperPrice * boxHeight / 2
            b = box.new(bar_index, bbUpperPrice + halfH, bar_index + boxExtend, bbUpperPrice - halfH,
                 border_color=rsiBBUpperColor, bgcolor=color.new(color.fuchsia, 88),
                 border_width=1, border_style=line.style_dashed, extend=extend.none)
            array.push(boxStore, b)
            lbl = label.new(bar_index + boxExtend, bbUpperPrice,
                 "BB+ " + rsiBBTF + "\n" + f_priceFmt(bbUpperPrice) + "  " + f_pctChange(bbUpperPrice),
                 color=color.new(color.fuchsia, 50), textcolor=color.white,
                 style=label.style_label_left, size=size.tiny)
            array.push(lblStore, lbl)
        if not na(bbLowerPrice)
            halfH = bbLowerPrice * boxHeight / 2
            b = box.new(bar_index, bbLowerPrice + halfH, bar_index + boxExtend, bbLowerPrice - halfH,
                 border_color=rsiBBLowerColor, bgcolor=color.new(color.aqua, 88),
                 border_width=1, border_style=line.style_dashed, extend=extend.none)
            array.push(boxStore, b)
            lbl = label.new(bar_index + boxExtend, bbLowerPrice,
                 "BB- " + rsiBBTF + "\n" + f_priceFmt(bbLowerPrice) + "  " + f_pctChange(bbLowerPrice),
                 color=color.new(color.aqua, 50), textcolor=color.white,
                 style=label.style_label_left, size=size.tiny)
            array.push(lblStore, lbl)
        if not na(bbMidPrice)
            lbl = label.new(bar_index + boxExtend, bbMidPrice,
                 "BB~ " + rsiBBTF + "\n" + f_priceFmt(bbMidPrice) + "  " + f_pctChange(bbMidPrice),
                 color=color.new(color.gray, 60), textcolor=color.white,
                 style=label.style_label_left, size=size.tiny)
            array.push(lblStore, lbl)

// ═══════════════════════════════════════════════════════════
//  DIVERGENCE ENGINE
// ═══════════════════════════════════════════════════════════
divRsi       = request.security(syminfo.tickerid, divTF, ta.rsi(close, divRsiLen), lookahead=barmerge.lookahead_off)
pricePivHigh = ta.pivothigh(high,   divLookback, divLookback)
pricePivLow  = ta.pivotlow(low,     divLookback, divLookback)
rsiPivHigh   = ta.pivothigh(divRsi, divLookback, divLookback)
rsiPivLow    = ta.pivotlow(divRsi,  divLookback, divLookback)

bearDiv = not na(pricePivHigh) and not na(rsiPivHigh)
         and pricePivHigh > ta.valuewhen(not na(pricePivHigh), pricePivHigh, 1)
         and rsiPivHigh   < ta.valuewhen(not na(rsiPivHigh),   rsiPivHigh,   1)

bullDiv = not na(pricePivLow) and not na(rsiPivLow)
         and pricePivLow < ta.valuewhen(not na(pricePivLow), pricePivLow, 1)
         and rsiPivLow   > ta.valuewhen(not na(rsiPivLow),   rsiPivLow,   1)

plotshape(showDiv and bearDiv, "Bear Divergence", shape.labeldown, location.abovebar, divBearColor, text="DIV▼", textcolor=color.white, size=size.small, offset=-divLookback)
plotshape(showDiv and bullDiv, "Bull Divergence", shape.labelup,   location.belowbar, divBullColor, text="DIV▲", textcolor=color.white, size=size.small, offset=-divLookback)

// ═══════════════════════════════════════════════════════════
//  OB / OS ZONE DETECTION
// ═══════════════════════════════════════════════════════════
inOB1 = not na(obPrice1) and close >= obPrice1
inOS1 = not na(osPrice1) and close <= osPrice1
inOB2 = not na(obPrice2) and close >= obPrice2
inOS2 = not na(osPrice2) and close <= osPrice2
inOB3 = not na(obPrice3) and close >= obPrice3
inOS3 = not na(osPrice3) and close <= osPrice3
inOB4 = not na(obPrice4) and close >= obPrice4
inOS4 = not na(osPrice4) and close <= osPrice4
anyOB = inOB1 or inOB2 or inOB3 or inOB4
anyOS = inOS1 or inOS2 or inOS3 or inOS4

// ═══════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════
alertcondition(alertOB and anyOB,    "Price in OB Zone",         "RSI Price Levels: Price entered Overbought zone.")
alertcondition(alertOS and anyOS,    "Price in OS Zone",         "RSI Price Levels: Price entered Oversold zone.")
alertcondition(alertDiv and bearDiv, "Bearish Divergence Found",  "RSI Price Levels: Bearish divergence detected.")
alertcondition(alertDiv and bullDiv, "Bullish Divergence Found",  "RSI Price Levels: Bullish divergence detected.")
````
