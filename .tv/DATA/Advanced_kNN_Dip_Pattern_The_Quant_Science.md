<!-- tradingview-pine-id: PUB;a535ae9458ab4e16a70062dcc40d6a23 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Advanced kNN Dip Pattern [The Quant Science]

Source: https://www.tradingview.com/script/Wqeqnvo8-Advanced-kNN-Dip-Pattern-The-Quant-Science/

## Description

Advanced kNN Dip Pattern is designed to identify significant price drops and evaluate their bounce probability using historical past patterns through our kNN Lorentzian Classification machine learning library.
[image]https://www.tradingview.com/x/PuTuSlyh/[/image]
[image]https://www.tradingview.com/x/JqJc4Ng6/[/image]

To train the machine learning model, the script extracts and normalizes four fundamental geometric metrics of each candle using a fifty-period min-max scaling function.

🔹 The first feature is the candle body size, calculated as the absolute value between the close and the open.
🔹 The second feature is the total candle range, defined by the difference between the high price and the low price.
🔹 The third and fourth features measure the wicks instead, calculating respectively the space between the high and the highest point between the close and the open for the upper wick, and the distance between the lowest point between the close and the open and the low for the lower wick.

👉 About our kNN Lorentzian Classification Library:  [https://www.tradingview.com/script/pVSBWUxj-kNNLorentzianMachineLearning/](https://www.tradingview.com/script/pVSBWUxj-kNNLorentzianMachineLearning/)

🔷 What It Does
The script analyzes real-time candle structure and detects sudden downturns by comparing them against a dynamic historical database.

[*]Detects the dip by monitoring the market for user-defined percentage drops relative to the recent high price.
[*]Performs kNN classification by extracting four geometric candle features, namely body size, total range, upper wick, and lower wick, normalizing them, and comparing them with historical patterns through the algorithm.
[*]Finally, applies a signal filter, generating an entry only when a significant drop occurs in conjunction with a positive prediction based on the most similar historical neighbors.

🔷 What It Is Used For
This indicator is a key tool for mean reversion and dip buying strategies.

[*]Helps filter out false crashes by distinguishing healthy, high-probability bounce corrections from strongly bearish trends.
[*]The automatically drawn boxes and lines also allow you to visually assess the extent of the movement and price reaction in historical tests.
[*]Thanks to the percentage confidence, the trader also knows how closely the current pattern historically resembles winning setups.
[image]https://www.tradingview.com/x/1b05f9BF/[/image]

🔷 Who Uses It

[*]Quantitative and systematic traders who want to leverage statistical classification models without leaving the TradingView environment.
[*]Swing traders looking for optimal entry points on volatile assets such as cryptocurrencies or growth stocks during market correction phases.
[*]Algo-trading enthusiasts interested in understanding how to implement matrices, arrays, and external libraries in Pine Script v6.

🔷 How to Use It

[*]Add the script to your chart, which requires importing the dedicated library.
[*]Configure the main parameters in the settings panel by defining the analysis period in bars and the minimum percentage drawdown threshold required to trigger the analysis.
[*]Monitor the chart, and when the signal turns on, the script colors the bar, draws a transparent box highlighting the magnitude of the drop from the peak to the low, and prints an HUD label with the statistical details.

🔷 User Interface Management
Configure the main parameters in the settings group by defining the Analysis Period expressed in bars, set to a default of 2, and the percentage Dip Threshold, set to a default of -5 percent.
[image]https://www.tradingview.com/x/TF7vzmY2/[/image]

[*]Analysis Period indicates the number of bars the script considers to calculate the recent high price against which the drawdown is measured.
[*]Dip Threshold represents the minimum percentage price drop threshold required for the system to recognize a movement as a valid dip and initiate the machine learning analysis.

Machine Learning Vs. Traditional Dip Patterns
Traditional patterns historically suffer from the severe flaw of triggering right in the middle of strong downward trends, catching what is jargon-wise called the falling knife and leading to massive losses. The integration of k Nearest Neighbors in this script brilliantly overcomes this limit by analyzing the geometric microstructure of the candle and comparing it with thousands of past events. The system does not merely observe how far the price has dropped, but evaluates whether that precise candle profile historically has a good probability of generating a bounce or if it instead anticipates a prolonged collapse, filtering out false signals and protecting capital.

Below you can find a quickly comparison analysis between a classic Dip and a kNN Dip.
To do that, we used our Dip & Rip Patterns indicator:  [https://www.tradingview.com/script/H2RutLp1-Dip-Rip-Patterns-The-Quant-Science/](https://www.tradingview.com/script/H2RutLp1-Dip-Rip-Patterns-The-Quant-Science/)
[image]https://www.tradingview.com/x/hQADYR6U/[/image]
[image]https://www.tradingview.com/x/0HZl6byc/[/image]

---

## Source Code

````pine
//@version=6
indicator("Advanced kNN Dip Pattern [The Quant Science]", overlay=true, max_bars_back=2000, max_boxes_count = 500)

import thequantscience/kNNLorentzianMachineLearning/1 as ml

analysis_period = input.int(defval = 2, title = "Analysis Period [Bars]", minval = 2, maxval = 100, group = "Settings")
dip_move_value  = input.float(defval = -5.0, title = "Dip Threshold [%]", step = 0.50, maxval = -0.50, group = "Settings")

past_highest = ta.highest(high[1], analysis_period - 1)
dip_perf = ((low - past_highest) / past_highest) * 100.0
is_dip = dip_perf <= dip_move_value

float body_size = math.abs(close - open)
float candle_rng = high - low
float upper_wd = high - math.max(close, open)
float lower_wd = math.min(close, open) - low

float f1 = ml.f_minmax(body_size, 50)
float f2 = ml.f_minmax(candle_rng, 50)
float f3 = ml.f_minmax(upper_wd, 50)
float f4 = ml.f_minmax(lower_wd, 50)

array<float> current_features = array.from(f1, f2, f3, f4)

var matrix<float> hist_matrix = matrix.new<float>(0, 5, na)

float target_dir = na
if bar_index >= 1
    target_dir := (close > close[1]) ? 1.0 : 0.0

ml.f_update_history_matrix(hist_matrix, current_features, target_dir, 300)

[raw_signal, confidence] = ml.f_calc_knn_matrix(8, 0.75, current_features, hist_matrix, 1)

// 6. Condizione di entrata finale
bool buy_condition = is_dip and (raw_signal == 1)

barcolor(buy_condition ? #ff0000 : na, title="Dip Bar")

// Calcolo globale obbligatorio per ta.highestbars
int raw_offset = -ta.highestbars(high[1], analysis_period - 1)
int peak_offset = math.max(1, raw_offset)

if (buy_condition) 
    int peak_bar = bar_index - peak_offset
    float peak_price = past_highest

    string hudText = "kNN DIP\n" + 
                     "• Conf: " + str.tostring(confidence * 100, "#.##") + "%\n" + 
                     "• Depth: " + str.tostring(dip_perf, "#.##") + "%"
    
    label.new(bar_index, low, 
              text=hudText, 
              xloc=xloc.bar_index, 
              yloc=yloc.belowbar, 
              style=label.style_label_upper_left, 
              color=color.new(#190b0b, 15), 
              textcolor=#fdfdfd,             
              size=size.small)

    box.new(left=peak_bar, top=peak_price, right=bar_index, bottom=low, 
            bgcolor=color.new(#ff0000, 85), 
            border_color=color.new(#ff0000, 40), 
            border_width=1, 
            xloc=xloc.bar_index)

    line.new(peak_bar, peak_price, bar_index, low, xloc=xloc.bar_index, color=#ff0000, style=line.style_solid, width=1)
    line.new(peak_bar, peak_price, peak_bar, peak_price, xloc=xloc.bar_index, color=#ff0000, style=line.style_solid, width=1)
    line.new(bar_index, low, bar_index, low, xloc=xloc.bar_index, color=#ff0000, style=line.style_solid, width=1)

plotshape(buy_condition, title="Dip", style=shape.circle, location=location.belowbar, color=color.new(#ff0055, 40), size=size.tiny)
````
