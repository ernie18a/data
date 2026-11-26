# Giovanni's Power Law Model | Astral Vision 

- url: https://www.tradingview.com/script/Qn6edLAP/
- type: indicator
- pine_id: PUB;caf7d838044b4c38af56a54771878924
- version: 1.0

## Description

[b]Giovanni's Power Law Model | Astral Vision 🌠💠[/b]

This indicator implements the Bitcoin Power Law model as formalized by physicist Giovanni Santostasi, which models Bitcoin's long-term price trajectory as a power function of the number of days elapsed since the genesis block. Unlike standard log-linear regression applied directly to price, this implementation uses a configurable root transformation of price before fitting, which allows the user to explore how the statistical quality of the power law relationship changes depending on which power of price is used as the dependent variable.

[b]Calculation ⚙️[/b]

The number of days elapsed since the genesis block (January 3, 2009) is computed for each bar. Both the day count and price are transformed logarithmically: the X variable is log(days), and the Y variable is log(price^(1/k)), where k is a configurable integer exponent. This is equivalent to fitting the relationship log(price) = k × (slope × log(days) + intercept), meaning the model regresses log(price^(1/k)) against log(days) and then raises the result to the power k to recover the price-scale fit.

The regression is computed from scratch using ordinary least squares via cumulative sums of X, Y, XY, X², and Y² accumulated across all valid historical bars, then solved analytically at each bar using the standard OLS closed-form solution: slope = (n × ΣXY − ΣX × ΣY) / (n × ΣX² − (ΣX)²) and intercept = (ΣY − slope × ΣX) / n. This produces a true full-history regression that updates on every bar as new data is added, without any approximation.

The fitted price at each bar is: fitPrice = exp(intercept + slope × log(days))^k. Upper and lower bands are then derived by multiplying or dividing the fitted price by configurable band multipliers raised to the power k, ensuring the bands maintain consistent proportional spacing in the transformed space rather than in raw price terms. The R² coefficient of determination is computed at the last bar by comparing the explained variance of the regression against the total variance of the Y variable, quantifying how well the power law model fits the full historical data.

[b]Plots 📊[/b]
[list]
[*]Central power law regression line in neutral color
[*]Two upper bands with fill between them, colored with the positive theme color
[*]Two lower bands with fill between them, colored with the negative theme color
[*]Table displaying the current k exponent and the R² goodness-of-fit statistic
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]K Exponent: the root applied to price before regression, between 1 and 7; higher values compress the price scale more aggressively
[*]Upper Band 2 and Upper Band 3: multipliers for the two upper bands
[*]Lower Band 2 and Lower Band 3: multipliers for the two lower bands
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Hermes.

[b]Purpose 🎯[/b]
Standard log-linear regression on Bitcoin price assumes a fixed exponential relationship between time and price. Giovanni Santostasi's formulation derives the power law from first principles of network science and thermodynamics, arguing that Bitcoin's adoption follows the same scaling laws observed in physical and biological systems. The configurable k parameter allows direct exploration of which root transformation produces the tightest regression, with the displayed R² providing an objective statistical measure of fit quality rather than a visual approximation. The OLS computation across the full price history from genesis makes the fitted line anchored to the entire dataset rather than to a recent window, producing a structurally stable long-term reference.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision
//@version=6
indicator("Giovanni's Power Law Model | Astral Vision 🌠💠", overlay=true)

group0 = "Settings"
group1 = "Upper Bands"
group2 = "Lower Bands"
group3 = "Astral Colors"

int k = input.int(6, "K Exponent (1/k)", minval=1, maxval=7, group=group0)

float uMult2 = input.float(1.15, "Upper Band 2", step=0.01, group=group1)
float uMult3 = input.float(1.2,  "Upper Band 3", step=0.01, group=group1)
float lMult2 = input.float(1.15, "Lower Band 2", step=0.01, group=group2)
float lMult3 = input.float(1.2,  "Lower Band 3", step=0.01, group=group2)

string theme      = input.string("Hermes", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group3)
bool   usecustom  = input.bool(false, "Custom Colors", group=group3)
color  custom_pos = input.color(color.rgb(255,0,0),  "Custom Positive", group=group3)
color  custom_neg = input.color(color.rgb(120,0,0),  "Custom Negative", group=group3)

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)    :
     theme == "Paradiso" ? color.rgb(0,210,255)  :
     theme == "Futura"   ? color.rgb(0,255,180)  :
     theme == "Infinito" ? color.rgb(180,120,255) :
     color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)    :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80)  :
     color.rgb(0,180,120)

color neu_col = color.rgb(120,120,120)

int genesisTime = timestamp("2009-01-03")
float daysFromGenesis = (time - genesisTime) / 86400000.0

float price = request.security("INDEX:BTCUSD", "D", close, barmerge.gaps_off, barmerge.lookahead_on)

float X = daysFromGenesis > 0 and not na(price) and price > 0 ? math.log(daysFromGenesis) : na
float Y = daysFromGenesis > 0 and not na(price) and price > 0 ? math.log(math.pow(price, 1.0 / k)) : na

var float sumX  = 0.0
var float sumY  = 0.0
var float sumXY = 0.0
var float sumX2 = 0.0
var float sumY2 = 0.0
var int   n     = 0

if not na(X) and not na(Y)
    sumX  += X
    sumY  += Y
    sumXY += X * Y
    sumX2 += X * X
    sumY2 += Y * Y
    n     += 1

float denom     = (n * sumX2 - sumX * sumX)
float slope     = denom != 0 ? (n * sumXY - sumX * sumY) / denom : 0.0
float intercept = (sumY - slope * sumX) / n

float logFit   = intercept + slope * X
float fitPrice = math.pow(math.exp(logFit), k)

float u2 = fitPrice * math.pow(uMult2, k)
float u3 = fitPrice * math.pow(uMult3, k)
float l2 = fitPrice / math.pow(lMult2, k)
float l3 = fitPrice / math.pow(lMult3, k)

float r2 = 0.0
if barstate.islast and n > 1
    float ssTot_num = n * sumY2 - sumY * sumY
    float ssReg_num = math.pow(n * sumXY - sumX * sumY, 2) / denom
    r2 := ssReg_num / ssTot_num

p0  = plot(fitPrice, "Power Law", color=neu_col,                   linewidth=1)
pu2 = plot(u2,       "Upper 2",   color=color.new(pos_col, 40),    linewidth=2)
pu3 = plot(u3,       "Upper 3",   color=pos_col,                   linewidth=3)
pl2 = plot(l2,       "Lower 2",   color=color.new(neg_col, 40),    linewidth=2)
pl3 = plot(l3,       "Lower 3",   color=neg_col,                   linewidth=3)

fill(pu2, pu3, color=color.new(pos_col, 50))
fill(pl2, pl3, color=color.new(neg_col, 50))

var table t = table.new(position.top_right, 1, 3,
     bgcolor      = color.new(color.black, 60),
     border_color = color.rgb(40, 40, 40),
     border_width = 1,
     frame_color  = color.rgb(40, 40, 40),
     frame_width  = 2)

if barstate.islast
    table.cell(t, 0, 0, "Giovanni's Power Law 🌠💠",
         text_color  = color.black,
         bgcolor     = pos_col,
         text_halign = text.align_center,
         text_size   = size.normal, 
         text_formatting = text.format_bold, 
         text_font_family = font.family_monospace)

    table.cell(t, 0, 1, "k  =  1 / " + str.tostring(k),
         text_color  = color.rgb(200, 200, 200),
         bgcolor     = color.rgb(12, 12, 12),
         text_halign = text.align_center,
         text_size   = size.normal)

    table.cell(t, 0, 2, "R²  =  " + str.tostring(math.round(r2, 6)),
         text_color  = pos_col,
         bgcolor     = color.rgb(12, 12, 12),
         text_halign = text.align_center,
         text_size   = size.normal)
````
