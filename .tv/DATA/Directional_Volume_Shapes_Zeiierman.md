<!-- tradingview-pine-id: PUB;e34ee6d48a3442009b22dcfbd252dd52 -->
<!-- tradingviewscripts-format: 1 -->
# Directional Volume Shapes (Zeiierman)

Source: https://www.tradingview.com/script/3XE8qqfr-Directional-Volume-Shapes-Zeiierman/

## Description

█ Overview
Directional Volume Shapes (Zeiierman) is a regime-classification oscillator that reframes volume analysis around a different question: not simply “how much volume traded,” but “what statistical shape has directional pressure been forming, and which way is it leaning?”

Instead of plotting raw buy and sell volume bar by bar, the indicator scores each candle for directional pressure using a triangular intrabar distribution model. It collects those scores in a rolling window, classifies the pattern into one of seven distribution shapes, and displays a smooth synthetic template of the detected shape.

The result is less like a traditional volume indicator and more like a distribution-regime display, showing the type of pressure environment currently developing.
[image]https://www.tradingview.com/x/BpdfR6L8/[/image]
⚪ Why Is This One Unique?

Most volume tools show exactly what happened: green bar up, red bar down, and taller bar equals more volume. This indicator uses a two-stage process: classify, then synthesize.

It combines:

• A triangular CDF candle scorer that estimates directional pressure from OHLC data
• A rolling shape classifier using skewness, Gaussian-smoothed peak detection, and time correlation
• Seven possible classifications: Bell, Right-skewed, Left-skewed, J-shaped, Reverse-J, Bimodal, and Multimodal
• A template generator that displays an idealized mathematical version of the active shape
• A separate EMA-based polarity engine that controls bullish or bearish direction
[image]https://www.tradingview.com/x/bK4X7k4C/[/image]

█ How It Works

⚪ 1. Scores Each Candle’s Directional Pressure

Instead of using a simple “close above open equals bullish” rule, the indicator models the candle’s high-low range as a triangular probability distribution centered at the close.

The scr() function evaluates the candle’s full OHLC structure and returns a value between 0 and 1. That result is then converted into a signed pressure score between -1 and +1.
[pine]dm = scr(open, high, low, close)
ps = 2.0 * dm - 1.0[/pine]
Values near +1 represent stronger bullish pressure, while values near -1 represent stronger bearish pressure. Values near zero indicate a more balanced candle.

⚪ 2. Optionally Weights Pressure by Volume

When Volume Weighting is enabled, the pressure score is multiplied by raw volume.
[pine]src = vw ? volume * ps : ps[/pine]
This gives high-volume bars more influence over the rolling shape-classification window. When disabled, the classifier uses directional pressure alone.

Volume still controls the height of the plotted columns regardless of this setting.

⚪ 3. Classifies Pressure Shape, Not Direction

The indicator stores recent pressure values in a rolling window. Before classification, it converts each value into its absolute magnitude.
[pine]for i = 0 to buf.size() - 1
    mag.set(i, math.abs(buf.get(i)))[/pine]
Using math.abs() removes bullish and bearish direction from the classification stage. The classifier analyzes how pressure strength has been distributed, not which direction it points.

It measures:

• Skewness in the raw pressure magnitudes
• Local peaks in a Gaussian-smoothed version of the data
• Whether pressure strength is generally increasing or decreasing through time

The final shape is selected using a fixed priority order:
[pine]if peaks >= 2
    out := peaks == 2 ? "Bimodal" : "Multimodal"
else if corr > 0.5
    out := "J-shaped"
else if corr < -0.5
    out := "Reverse-J"
else if skew > 0.1
    out := "Right-skewed"
else if skew < -0.1
    out := "Left-skewed"
else
    out := "Bell"[/pine]
Multiple peaks are checked first, followed by rising or falling behavior, then skewness. Bell is used when no other condition is detected.

⚪ 4. Requires Persistence Before Changing Shapes

The active shape changes only after five consecutive bars produce a classification different from the shape currently displayed.
[pine]if ns != sh
    sc += 1
else
    sc := 0

if sc >= 5
    sh := ns
    ph := 0.0
    sc := 0[/pine]
The five classifications do not need to match each other. They only need to differ from the current active shape.

When the fifth differing classification arrives, the indicator switches to that bar’s shape and restarts the template cycle.

⚪ 5. Tracks Polarity Separately

Bullish or bearish polarity is calculated independently from the shape classification.

A short EMA is applied to the original signed pressure score:
[pine]pr = ta.ema(ps, pl)
string np = pr >= 0 ? "Bull" : "Bear"[/pine]
When the EMA is above or equal to zero, polarity is Bull. When it is below zero, polarity is Bear.

Because polarity can change as soon as the EMA crosses zero, it usually reacts faster than the shape classifier.

⚪ 6. Displays a Synthetic Shape Template

Once a shape is selected, the indicator does not plot the original pressure values.

Instead, it generates an idealized mathematical template for the active shape. For example, Bell uses a Gaussian curve, J-shaped uses a squared rising curve, and Bimodal combines two separate Gaussian peaks.

The generated template is then scaled by recent average volume and signed according to polarity.
[pine]p   = pol == "Bull" ? ph : 1.0 - ph
tv  = tpl(sh, p)
sgn = pol == "Bull" ? 1.0 : -1.0
amp = ta.sma(volume, 3) * 1.8
y   = amp * tv * sgn[/pine]
The template advances by a fixed amount on each bar. Template Cycle Length controls how many bars are used to complete one full cycle.

█ Assumptions We Are Explicitly Making
The indicator’s usefulness depends on whether its modeling assumptions are suitable for the instrument and timeframe being analyzed.

These are not facts about market behavior. They are simplifying assumptions used because Pine Script does not provide true intrabar tick or order-flow data.

⚪ Intrabar Activity Is Approximated With a Triangular Distribution

The model approximates intrabar activity using a triangular distribution centered at the close. It does not know where price actually spent the most time within the candle. 

Using another reference point, such as VWAP, the midpoint, or the open, could produce a different pressure score.

⚪ Shape and Direction Are Treated Separately

The shape classifier analyzes the magnitude of pressure but removes its bullish or bearish direction. Two windows with similar pressure-strength patterns but opposite directional bias can therefore receive the same shape classification. 

The shape describes how pressure has been distributed, while the separate polarity calculation determines whether it is leaning Bull or Bear.

⚪ Seven Shapes Are Used to Describe Pressure Behavior

Every window is placed into one of seven fixed categories using predefined thresholds:

• Skewness thresholds of ±0.1
• Correlation thresholds of ±0.5
• Peak prominence above 10% of the smoothed envelope’s maximum

The classifier follows a fixed priority order rather than selecting the mathematically closest-fitting shape.

There is also no statistical significance test behind these thresholds, so borderline classifications may change because of noise.

⚪ The Displayed Curve Represents the Classification, Not the Raw Data

After classification, the indicator displays an idealized template rather than the original pressure values. Two different pressure windows classified as Bell will use the same normalized Bell template.

The final column height and direction can still differ because the template is scaled by recent volume and signed by polarity.
█ How to Use

⚪ Directional Volume Reading

Use the indicator as you would a traditional volume oscillator.

• Readings above zero indicate bullish volume strength.
• Readings below zero indicate bearish volume strength.
[image]https://www.tradingview.com/x/wmOUiuMv/[/image]
⚪ Divergences

Use the columns to identify divergences in volume strength.

• Bullish divergence: Price makes a lower low while the indicator forms a higher low.
• Bearish divergence: Price makes a higher high while the indicator forms a lower high.
[image]https://www.tradingview.com/x/dEs1Wg00/[/image]

⚪ Interpreting the Shape Labels

• Bell: Pressure intensity is relatively symmetric and contains one main area of activity.
• Right-skewed / Left-skewed: Pressure intensity is uneven and has a longer tail on one side of the distribution.
• J-shaped: Pressure intensity has generally increased toward the most recent bars.
• Reverse-J: Pressure intensity was stronger earlier in the window and has weakened toward the present.
• Bimodal / Multimodal: The smoothed pressure path contains two or more separate periods of stronger activity within the detection window.
[image]https://www.tradingview.com/x/q3hl7QGI/[/image]

⚪ Choosing the Shape Speed

Template Cycle Length controls how quickly the displayed shape moves through its synthetic cycle. It changes the visual speed of the columns, not the shape-detection window or Bull/Bear polarity.

• 3 bars, Fast: Creates tight, fast-moving shapes. This is the most responsive and active-looking setting.
• 4 bars, Balanced: Gives each shape slightly more time to develop while remaining responsive.
• 5 to 7 bars, Slow: Stretches the shape across more bars, creating smoother and slower visual cycles.

A value of 3 is useful when you prefer compact, fast-moving shapes. Increase the value when you want each shape to develop more gradually and remain visible for longer.

█  Settings

[*]Use Volume Weighting: Controls whether volume multiplies directional pressure before shape classification. Volume still controls the plotted column height when this setting is disabled.
[*]Detection Window: Sets the number of recent bars used to classify the current shape. Higher values produce slower and more stable classifications. Lower values react faster and may change shape more often.
[*]Polarity Smoothing: Sets the EMA length used to determine Bull or Bear polarity. Higher values create steadier polarity. Lower values react faster.
[*]Template Cycle Length: Sets the number of bars used to complete one synthetic shape template. Lower values create faster and tighter cycles. Higher values stretch the template over more bars.
[*]Show Moving Average: Shows or hides a moving average of the final plotted output.
[*]Type: Selects the moving-average method: SMA, EMA, RMA, or WMA.
[*]Length: Sets the moving-average period.
[*]Maximum Transparency: Sets the maximum transparency applied near the lower points of each template. A value of 0 disables the transparency fade.

-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Zeiierman {
//@version=6
indicator("Directional Volume Shapes (Zeiierman)", overlay=false, max_labels_count=500, precision=1)
//}

// ~~ Tooltips {
var const string t1  = "Controls whether volume influences shape detection. ON multiplies candle-direction pressure by volume, giving high-volume bars more influence. OFF uses candle-direction pressure alone, while volume still controls the plotted column height."
var const string t2  = "Sets the number of recent bars used to detect the distribution shape. Higher values produce slower, smoother, and more stable classifications but require more processing. Lower values react faster and may switch shape more often."
var const string t3  = "Sets the EMA length used to determine bullish or bearish polarity from candle-direction pressure. Higher values produce steadier polarity with fewer flips. Lower values respond faster to direction changes."
var const string t4  = "Sets how many bars are used to traverse one generated shape template. Lower values create faster and tighter shape cycles. Higher values stretch each template across more bars."
var const string t5  = "Shows or hides a moving average of the final plotted directional-volume output. This setting is visual only and does not affect shape detection, polarity, or the column values."
var const string t6  = "Selects the smoothing method for the moving average. SMA uses equal weighting, EMA emphasizes recent values, RMA applies Wilder smoothing, and WMA applies linearly increasing weight to recent values."
var const string t7  = "Sets the number of output bars used by the moving average. Lower values follow the columns more closely. Higher values create a smoother and slower line."
var const string t8  = "Sets the display color of the moving-average line. This setting changes appearance only and does not affect any calculations."
var const string t9  = "Sets the thickness of the moving-average line. Higher values produce a thicker line. This setting changes appearance only."
var const string t10 = "Sets the maximum transparency applied to the distribution columns. Higher values make the low portions of each template more transparent. A value of 0 disables the template-based transparency fade."
var const string t11 = "Shows a label when a newly detected distribution shape is confirmed and becomes active."
var const string t12 = "Sets the display size of the confirmed shape labels."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
vw  = input.bool(true, "Use Volume Weighting", group="Shape Detection", tooltip=t1)
len = input.int(20, "Detection Window", minval=6, maxval=60, group="Shape Detection", tooltip=t2)

pl = input.int(20, "Polarity Smoothing", minval=1, maxval=50, group="Direction & Timing", tooltip=t3)
cl = input.int(3, "Template Cycle Length", minval=3, maxval=7, group="Direction & Timing", tooltip=t4)

showMa  = input.bool(false, "Show Moving Average", group="Moving Average", tooltip=t5)
maType  = input.string("EMA", "Type", options=["SMA", "EMA", "RMA", "WMA"], group="Moving Average", tooltip=t6)
maLen   = input.int(20, "Length", minval=1, maxval=200, group="Moving Average", tooltip=t7)
maCol   = input.color(color.blue, "Color", group="Moving Average", tooltip=t8)
maWidth = input.int(1, "Width", minval=1, maxval=5, group="Moving Average", tooltip=t9)

showLabels = input.bool(false, "Show Shape Labels", group="Shape Labels", tooltip=t11)
labelSizeInput = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Shape Labels", tooltip=t12)

mt = input.float(45.0, "Maximum Transparency", minval=0, maxval=100, step=1.0, group="Style", tooltip=t10)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Label size mapping {
labelSize = labelSizeInput == "Tiny" ? size.tiny :
     labelSizeInput == "Small" ? size.small :
     labelSizeInput == "Large" ? size.large :
     labelSizeInput == "Huge" ? size.huge :
     size.normal
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Triangular candle-direction score {
scr(o, h, l, c) =>
    rng = h - l
    float cdf = na
    if rng == 0
        cdf := c > o ? 0.0 : (c < o ? 1.0 : 0.5)
    else
        op = math.max(math.min(o, h), l)
        md = math.max(math.min(c, h), l)
        if md == l
            cdf := op <= l ? 0.0 : 1.0 - math.pow((h - op) / rng, 2)
        else if md == h
            cdf := op >= h ? 1.0 : math.pow((op - l) / rng, 2)
        else
            lw = md - l
            rw = h - md
            if op <= l
                cdf := 0.0
            else if op <= md
                cdf := math.pow(op - l, 2) / (rng * lw)
            else if op < h
                cdf := 1.0 - math.pow(h - op, 2) / (rng * rw)
            else
                cdf := 1.0
    1.0 - cdf

dm  = scr(open, high, low, close)
ps  = 2.0 * dm - 1.0
src = vw ? volume * ps : ps
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Cache Gaussian weights once {
var array<float> ker = array.new_float(len, 0.0)

if barstate.isfirst
    bw0 = math.max(len / 2.0, 1.0)
    for d = 0 to len - 1
        ker.set(d, math.exp(-(d * d) / (2 * bw0 * bw0)))
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Shape classifier {
cls(a, k) =>
    n   = a.size()
    avg = a.avg()
    sd  = a.stdev()
    float m3 = 0.0

    for i = 0 to n - 1
        d = a.get(i) - avg
        m3 += math.pow(d, 3)

    skew = sd == 0 ? 0.0 : (m3 / n) / math.pow(sd, 3)

    env = array.new_float(n)

    for i = 0 to n - 1
        float sw = 0.0
        float sv = 0.0

        for j = 0 to n - 1
            dx = i - j
            w  = k.get(math.abs(dx))
            sw += w
            sv += w * a.get(j)

        env.set(i, sv / sw)

    mx = env.max()

    int peaks = 0

    for i = 1 to n - 2
        v = env.get(i)

        if v > env.get(i - 1) and v > env.get(i + 1) and v > mx * 0.1
            peaks += 1

    mi = (n - 1) / 2.0
    me = env.avg()
    float cov = 0.0
    float vx  = 0.0
    float vy  = 0.0

    for i = 0 to n - 1
        x = i - mi
        y = env.get(i) - me
        cov += x * y
        vx += x * x
        vy += y * y

    corr = vx > 0 and vy > 0 ? cov / math.sqrt(vx * vy) : 0.0

    string out = "Bell"

    if peaks >= 2
        out := peaks == 2 ? "Bimodal" : "Multimodal"
    else if corr > 0.5
        out := "J-shaped"
    else if corr < -0.5
        out := "Reverse-J"
    else if skew > 0.1
        out := "Right-skewed"
    else if skew < -0.1
        out := "Left-skewed"
    else
        out := "Bell"

    out
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Template generator {
tpl(sh, p) =>
    float v = 0.0

    if sh == "Bell"
        v := math.exp(-math.pow(p - 0.5, 2) / (2 * math.pow(0.15, 2)))
    else if sh == "Right-skewed"
        v := (p * math.exp(-p * 5)) / 0.0736
    else if sh == "Left-skewed"
        v := ((1 - p) * math.exp(-(1 - p) * 5)) / 0.0736
    else if sh == "J-shaped"
        v := p * p
    else if sh == "Reverse-J"
        v := math.exp(-3 * p)
    else if sh == "Bimodal"
        v := math.exp(-math.pow(p - 0.3, 2) / (2 * math.pow(0.06, 2))) + math.exp(-math.pow(p - 0.7, 2) / (2 * math.pow(0.06, 2)))
    else
        v := math.exp(-math.pow(p - 0.2, 2) / (2 * math.pow(0.05, 2))) + 0.8 * math.exp(-math.pow(p - 0.5, 2) / (2 * math.pow(0.05, 2))) + 0.6 * math.exp(-math.pow(p - 0.8, 2) / (2 * math.pow(0.05, 2)))

    math.min(v, 1.2)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Moving average {
avg(x, n, t) =>
    t == "SMA" ? ta.sma(x, n) : t == "EMA" ? ta.ema(x, n) : t == "RMA" ? ta.rma(x, n) : ta.wma(x, n)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Color {
col(sh, pol) =>
    color c = na

    if pol == "Bull"
        c := sh == "Bell" ? color.new(#00e676, 0) : sh == "Right-skewed" ? color.new(#1de9b6, 0) : sh == "Left-skewed" ? color.new(#76ff03, 0) : sh == "J-shaped" ? color.new(#00c853, 0) : sh == "Reverse-J" ? color.new(#64dd17, 0) : color.new(#00bfa5, 0)
    else
        c := sh == "Bell" ? color.new(#ff5252, 0) : sh == "Right-skewed" ? color.new(#ff6e40, 0) : sh == "Left-skewed" ? color.new(#ff4081, 0) : sh == "J-shaped" ? color.new(#d50000, 0) : sh == "Reverse-J" ? color.new(#c51162, 0) : color.new(#aa00ff, 0)

    c
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ State machines {
var string sh = "Bell"
var int sc = 0
var float ph = 0.0
var array<float> buf = array.new_float(0)
var string pol = "Bull"
var int pc = 0

bool shapeChanged = false

buf.push(src)

if buf.size() > len
    buf.shift()

mag = array.new_float(buf.size())

for i = 0 to buf.size() - 1
    mag.set(i, math.abs(buf.get(i)))

string ns = buf.size() >= len ? cls(mag, ker) : sh

if ns != sh
    sc += 1
else
    sc := 0

if sc >= 5
    sh := ns
    ph := 0.0
    sc := 0
    shapeChanged := true

pr = ta.ema(ps, pl)
string np = pr >= 0 ? "Bull" : "Bear"

if np != pol
    pc += 1
else
    pc := 0

if pc >= 1
    pol := np
    pc := 0
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Output {
p   = pol == "Bull" ? ph : 1.0 - ph
tv  = tpl(sh, p)
sgn = pol == "Bull" ? 1.0 : -1.0
amp = ta.sma(volume, 3) * 1.8
raw = volume * (close >= open ? 1.0 : -1.0)
y   = raw * (1.0 - 1.0) + amp * tv * sgn * 1.0
ma  = avg(y, maLen, maType)

ph += 1.0 / cl

if ph > 1.0
    ph -= 1.0

bc = color.new(col(sh, pol), mt - mt * math.min(tv, 1.0))
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Shape labels {
if showLabels and shapeChanged
    labelY = pol == "Bull" ? amp * 1.35 : -amp * 1.35

    label.new(
         bar_index,
         labelY,
         sh,
         style=pol == "Bull" ? label.style_label_down : label.style_label_up,
         color=col(sh, pol),
         textcolor=color.white,
         size=labelSize
     )
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Plots {
plot(y, title="Directional Volume Shape", style=plot.style_columns, color=bc)
plot(showMa ? ma : na, title="Directional Volume Shape MA", color=maCol, linewidth=maWidth)
hline(0, "Zero", color=color.new(color.gray, 70))
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
