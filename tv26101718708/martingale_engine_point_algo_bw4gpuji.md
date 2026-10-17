# Martingale Engine [point algo]

- url: https://www.tradingview.com/script/Bw4GPUJi-Martingale-Engine-point-algo/
- type: indicator
- pine_id: PUB;eb6c62c69d0a469ab82f57a7004174bb
- version: 1.0

## Description

Martingale Engine

The Martingale Engine is an educational quantitative analysis tool that visualizes whether a price series behaves more like a martingale, sub-martingale, or super-martingale using concepts from stochastic processes and financial mathematics.

The script combines Doob Decomposition, Variance Ratio Testing, and Quadratic Variation into a single dashboard for studying the statistical characteristics of market returns.
It is intended for analysis and research rather than providing standalone trading signals.

Mathematical Background

For a stochastic process Xt, Doob's Decomposition states:
X = M + A
where
[list]
[*]M is the martingale (unpredictable innovation) component.
[*]A is the predictable drift component.
[/list]

This indicator estimates both components from logarithmic returns and displays how much of the recent price movement is explained by drift versus random innovation.

[b]Included Models[/b]
1. Doob Decomposition

The indicator estimates
[list]
[*]Conditional Drift (μ)
[*]Martingale Innovation (ε)
[/list]

and separates total movement into

[list]
[*]Predictable component
[*]Random component
[/list]

This helps visualize whether recent price behavior has been primarily trend-driven or innovation-driven.

2. Martingale Probability Bands

Using the estimated innovation volatility, the script builds statistical bands around the estimated drift.

Displayed bands include
[list]
[*]±1 Standard Deviation
[*]±2 Standard Deviation
[/list]

These bands represent expected dispersion under the current volatility estimate and should not be interpreted as support, resistance, or guaranteed price targets.

3. Forward Martingale Cone
[list=1]
[*]The indicator projects a forward volatility cone based on the current innovation variance.
[*]The cone illustrates how expected dispersion increases over time under a martingale assumption.
[*]This feature is intended for visualization and educational analysis.
[/list]

4. Variance Ratio Test (Lo–MacKinlay)

The script performs the Variance Ratio Test over multiple aggregation periods.
Evaluated windows:
[list]
[*]q = 2
[*]q = 4
[*]q = 8
[*]q = 16
[/list]

Interpretation:
[list]
[*]VR > 1 → Momentum tendency
[*]VR < 1 → Mean-reverting tendency
[*]VR ≈ 1 → Random walk behavior
[/list]
Corresponding z-statistics are also displayed for reference.

5. Quadratic Variation

Quadratic Variation measures accumulated return variability over the selected estimation window.

The dashboard reports
[list]
[*]Total Quadratic Variation
[*]Martingale Component
[*]Drift Component
[/list]

along with a realized volatility band derived from the estimated variation.

[b]Process Classification[/b]
Based on the estimated annualized drift, the script classifies the process as:

Sub-Martingale
Expected future value exceeds the current value.

Martingale
Expected future value is approximately equal to the current value.

Super-Martingale
Expected future value is below the current value.

This classification reflects the estimated statistical process over the selected lookback window and may change as new data becomes available.

[b]Dashboard[/b]
The integrated dashboard displays:
[list]
[*]Doob decomposition
[*]Drift contribution
[*]Innovation contribution
[*]Variance Ratio statistics
[*]z-statistics
[*]Quadratic Variation
[*]Estimated realized volatility
[*]Annualized drift
[*]Estimated innovation volatility
[*]Current process classification
[/list]

[b]Inputs[/b]
Estimation Window : Number of historical bars used for calculations.
Doob Drift EMA Length : EMA length used to estimate conditional drift.
Forward Projection : Length of the projected martingale cone.
Show Doob Decomposition : Displays estimated drift and statistical bands.
Show Martingale Bounds Cone : Displays the forward projection cone.
Show Quadratic Variation Band : Displays the realized volatility band.

[b]Intended Use[/b]
This indicator may be useful for:
[list]
[*]Quantitative market research
[*]Studying stochastic price behavior
[*]Drift analysis
[*]Random walk analysis
[*]Mean reversion research
[*]Momentum research
[*]Educational demonstrations of martingale theory
[*]Financial mathematics
[/list]

[b]Important Notes[/b]
[list]
[*]The calculations are based on historical price data.
[*]Statistical estimates depend on the selected lookback period.
[*]The displayed probability bands are model-based estimates and are not predictive forecasts.
[*]The indicator should be used alongside other forms of technical or quantitative analysis.
[*]No statistical model can fully describe future market behavior.
[/list]

[b]References[/b]
This script is inspired by concepts from:
[list]
[*]Doob Decomposition
[*]Martingale Theory
[*]Quadratic Variation
[*]Lo & MacKinlay Variance Ratio Test
[*]Stochastic Processes
[*]Financial Econometrics
[/list]

[b]Disclaimer[/b]
This indicator is provided for educational and analytical purposes only. It does not provide investment advice or guarantee future market performance. Users should perform their own research and apply appropriate risk management before making trading decisions.

## Source Code

````pine
//@version=6
indicator("Martingale Engine", "Martingale Engine", overlay=true, max_lines_count=500, max_labels_count=500)

gMG = "Martingale Settings"
int  lookback  = input.int(60,  "Estimation Window (bars)",      minval=20, maxval=500, group=gMG)
int  driftLen  = input.int(10,  "Doob Drift EMA Length",         minval=3,  maxval=50,  group=gMG)
int  projBars  = input.int(20,  "Forward Projection (bars)",     minval=5,  maxval=50,  group=gMG)
bool showDoob  = input.bool(true, "Show Doob Decomposition",     group=gMG)
bool showCone  = input.bool(true, "Show Martingale Bounds Cone", group=gMG)
bool showQV    = input.bool(true, "Show Quadratic Variation Band", group=gMG)

gUI = "Terminal"
uiPos = input.string("Top Right", "Position", options=["Top Right","Middle Right","Bottom Right","Top Left","Middle Left","Bottom Left"], group=gUI)

pos = position.top_right
if uiPos == "Middle Right"
    pos := position.middle_right
else if uiPos == "Bottom Right"
    pos := position.bottom_right
else if uiPos == "Top Left"
    pos := position.top_left
else if uiPos == "Middle Left"
    pos := position.middle_left
else if uiPos == "Bottom Left"
    pos := position.bottom_left

float r1 = math.log(close / math.max(close[1], 0.0001))


float mu_t    = ta.ema(r1, driftLen)
float eps_t   = r1 - nz(mu_t[1])

float A_T     = math.sum(nz(mu_t[1]), lookback)
float M_T     = math.sum(eps_t,       lookback)

float S_anchor      = nz(close[lookback], close)
float doobDrift     = S_anchor * math.exp(A_T)

float sigma_eps     = ta.stdev(eps_t, lookback)
float sqrtLB        = math.sqrt(float(lookback))

float martUpperBand  = doobDrift * math.exp( 1.0 * sigma_eps * sqrtLB)
float martLowerBand  = doobDrift * math.exp(-1.0 * sigma_eps * sqrtLB)
float mart2UpperBand = doobDrift * math.exp( 2.0 * sigma_eps * sqrtLB)
float mart2LowerBand = doobDrift * math.exp(-2.0 * sigma_eps * sqrtLB)


float r_q2  = r1 + nz(r1[1])
float r_q4  = r_q2  + nz(r1[2])  + nz(r1[3])
float r_q8  = r_q4  + nz(r1[4])  + nz(r1[5])  + nz(r1[6])  + nz(r1[7])
float r_q16 = r_q8  + nz(r1[8])  + nz(r1[9])  + nz(r1[10]) + nz(r1[11]) +
              nz(r1[12]) + nz(r1[13]) + nz(r1[14]) + nz(r1[15])

float var1  = math.max(ta.variance(r1,    lookback), 0.0000001)
float var2  = ta.variance(r_q2,  lookback)
float var4  = ta.variance(r_q4,  lookback)
float var8  = ta.variance(r_q8,  lookback)
float var16 = ta.variance(r_q16, lookback)

float VR2   = var2  / (2.0  * var1)
float VR4   = var4  / (4.0  * var1)
float VR8   = var8  / (8.0  * var1)
float VR16  = var16 / (16.0 * var1)


float T_f = float(lookback)
zStat(vr, q) =>
    float theta = math.sqrt(2.0 * (2.0*q - 1.0) * (q - 1.0) / (3.0 * q * T_f))
    theta > 0 ? (vr - 1.0) / theta : 0.0

float z2    = zStat(VR2,   2.0)
float z4    = zStat(VR4,   4.0)
float z8    = zStat(VR8,   8.0)
float z16   = zStat(VR16, 16.0)

float QV_T   = math.sum(r1 * r1,                          lookback)
float QV_M   = math.sum(eps_t * eps_t,                    lookback)
float QV_A   = math.sum(nz(mu_t[1]) * nz(mu_t[1]),        lookback)

float martFrac  = QV_T > 0 ? QV_M / QV_T * 100.0 : 0.0
float driftFrac = QV_T > 0 ? QV_A / QV_T * 100.0 : 0.0
float rvBand    = close * (math.exp(math.sqrt(QV_T)) - 1.0)



var line[] martLines = array.new<line>()

if barstate.islast and showCone
    for ln in martLines
        line.delete(ln)
    array.clear(martLines)

    float S0      = close
    float prevMed = S0, prevUp1 = S0, prevDn1 = S0
    float prevUp2 = S0, prevDn2 = S0

    for h = 1 to projBars
        float sqrtH   = math.sqrt(float(h))
        float medLine = S0
        float up1     = S0 * math.exp( 1.0 * sigma_eps * sqrtH)
        float dn1     = S0 * math.exp(-1.0 * sigma_eps * sqrtH)
        float up2     = S0 * math.exp( 2.0 * sigma_eps * sqrtH)
        float dn2     = S0 * math.exp(-2.0 * sigma_eps * sqrtH)

        int xF = bar_index + h - 1
        int xT = bar_index + h

        array.push(martLines, line.new(xF, prevMed,  xT, medLine, color=color.new(#FFFFFF,40), width=2, style=line.style_dashed))
        array.push(martLines, line.new(xF, prevUp1,  xT, up1,     color=color.new(#00E5FF,30), width=1, style=line.style_dashed))
        array.push(martLines, line.new(xF, prevDn1,  xT, dn1,     color=color.new(#00E5FF,30), width=1, style=line.style_dashed))
        array.push(martLines, line.new(xF, prevUp2,  xT, up2,     color=color.new(#E040FB,40), width=1, style=line.style_dotted))
        array.push(martLines, line.new(xF, prevDn2,  xT, dn2,     color=color.new(#E040FB,40), width=1, style=line.style_dotted))

        prevMed := medLine
        prevUp1 := up1,  prevDn1 := dn1
        prevUp2 := up2,  prevDn2 := dn2


float driftRate = ta.sma(mu_t, lookback) * 252.0

string mgType = ""
color  mgCol  = color.white
if driftRate > 0.01
    mgType := "SUB-MARTINGALE  (E[X_{t+1}] > X_t)"
    mgCol  := #00E676
else if driftRate < -0.01
    mgType := "SUPER-MARTINGALE (E[X_{t+1}] < X_t)"
    mgCol  := #FF1744
else
    mgType := "MARTINGALE       (E[X_{t+1}] ≈ X_t)"
    mgCol  := #FFEB3B

float vrAvg    = (VR2 + VR4 + VR8 + VR16) / 4.0
string vrState = vrAvg > 1.05 ? "MOMENTUM (VR̄ > 1)" : vrAvg < 0.95 ? "MEAN-REVERSION (VR̄ < 1)" : "RANDOM WALK (VR̄ ≈ 1)"
color  vrCol   = vrAvg > 1.05 ? #00E676 : vrAvg < 0.95 ? #FF1744 : #FFEB3B

string vrSig2  = math.abs(z2)  > 1.96 ? "✗" : "✓"
string vrSig4  = math.abs(z4)  > 1.96 ? "✗" : "✓"
string vrSig8  = math.abs(z8)  > 1.96 ? "✗" : "✓"
string vrSig16 = math.abs(z16) > 1.96 ? "✗" : "✓"


plot(showDoob ? doobDrift     : na, "Doob Drift A_t", color=mgCol,                  linewidth=2)


pUp1 = plot(showDoob ? martUpperBand  : na, "Mart +1σ",   color=color.new(#00E5FF,70), linewidth=1)
pDn1 = plot(showDoob ? martLowerBand  : na, "Mart -1σ",   color=color.new(#00E5FF,70), linewidth=1)
fill(pUp1, pDn1, color=color.new(#00E5FF, 93), title="Martingale Band")
plot(showDoob ? mart2UpperBand : na, "Mart +2σ", color=color.new(#E040FB,60), linewidth=1)
plot(showDoob ? mart2LowerBand : na, "Mart -2σ", color=color.new(#E040FB,60), linewidth=1)
plot(showQV ? close + rvBand : na, "QV Upper", color=color.new(#FF9800,70), linewidth=1, style=plot.style_stepline)
plot(showQV ? close - rvBand : na, "QV Lower", color=color.new(#FF9800,70), linewidth=1, style=plot.style_stepline)


if math.abs(eps_t) > 2.0 * sigma_eps
    label.new(bar_index,
         eps_t > 0 ? high : low,
         text      = eps_t > 0 ? "M+" : "M−",
         color     = color.new(#E040FB, 55),
         textcolor = color.white,
         style     = eps_t > 0 ? label.style_label_up : label.style_label_down,
         yloc      = eps_t > 0 ? yloc.abovebar : yloc.belowbar,
         size      = size.tiny,
         tooltip   = "Martingale Innovation: ε = " + str.tostring(eps_t / sigma_eps,"#.2") + "σ  |  r = " + str.tostring(r1*100,"#.3") + "%")


var table mgTable = table.new(pos, 1, 7, frame_width=1, border_width=1, border_color=#37474F)

if barstate.islast
    table.cell(mgTable, 0, 0, "🎲 POINTALGO: MARTINGALE ENGINE", text_color=#FFEA00, bgcolor=#0A0A0A, text_font_family=font.family_monospace, text_halign=text.align_left)

    string doobTxt = "▶ DOOB DECOMPOSITION  X = M + A:\n"
    doobTxt += "A_T (drift QV):  " + str.tostring(driftFrac, "#.1") + "% of total QV\n"
    doobTxt += "M_T (innov QV):  " + str.tostring(martFrac,  "#.1") + "% of total QV\n"
    doobTxt += "μ_t (cond.mean): " + str.tostring(mu_t*100,  "#.4") + "% /bar\n"
    doobTxt += "ε_t (innovation):" + str.tostring(eps_t*100, "#.4") + "% /bar"
    table.cell(mgTable, 0, 1, doobTxt, text_color=#B0BEC5, bgcolor=#141414, text_font_family=font.family_monospace, text_halign=text.align_left)

    string vrTxt = "▶ VARIANCE RATIO TEST (Lo-MacKinlay):\n"
    vrTxt += "q=02  VR=" + str.tostring(VR2,  "#.3") + "  z=" + str.tostring(z2,  "#.2") + "  H₀:" + vrSig2  + "\n"
    vrTxt += "q=04  VR=" + str.tostring(VR4,  "#.3") + "  z=" + str.tostring(z4,  "#.2") + "  H₀:" + vrSig4  + "\n"
    vrTxt += "q=08  VR=" + str.tostring(VR8,  "#.3") + "  z=" + str.tostring(z8,  "#.2") + "  H₀:" + vrSig8  + "\n"
    vrTxt += "q=16  VR=" + str.tostring(VR16, "#.3") + "  z=" + str.tostring(z16, "#.2") + "  H₀:" + vrSig16 + "\n"
    vrTxt += "VR̄ avg = " + str.tostring(vrAvg,"#.3") + "  → " + vrState
    table.cell(mgTable, 0, 2, vrTxt, text_color=vrCol, bgcolor=#0A0A0A, text_font_family=font.family_monospace, text_halign=text.align_left)

    string qvTxt = "▶ QUADRATIC VARIATION  [X,X]_T:\n"
    qvTxt += "[X,X]_T total: " + str.tostring(QV_T * 10000, "#.2") + " bps²\n"
    qvTxt += "[M,M]_T mart:  " + str.tostring(QV_M * 10000, "#.2") + " bps²\n"
    qvTxt += "[A,A]_T drift: " + str.tostring(QV_A * 10000, "#.2") + " bps²\n"
    qvTxt += "RV Band (±):   " + str.tostring(rvBand, "#.2")
    table.cell(mgTable, 0, 3, qvTxt, text_color=#00E5FF, bgcolor=#141414, text_font_family=font.family_monospace, text_halign=text.align_left)

    string driftTxt = "▶ DRIFT ANALYSIS:\n"
    driftTxt += "Ann. drift μ:  " + str.tostring(driftRate * 100,              "#.2") + "% /yr\n"
    driftTxt += "Ann. σ_ε:      " + str.tostring(sigma_eps * math.sqrt(252) * 100, "#.2") + "% /yr"
    table.cell(mgTable, 0, 4, driftTxt, text_color=mgCol, bgcolor=#0A0A0A, text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(mgTable, 0, 5, "---------------------------------", text_color=#37474F, bgcolor=#0A0A0A, text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(mgTable, 0, 6, "[PROCESS TYPE]:\n" + mgType, text_color=mgCol, bgcolor=#141414, text_font_family=font.family_monospace, text_halign=text.align_left, text_formatting=text.format_bold)
````
