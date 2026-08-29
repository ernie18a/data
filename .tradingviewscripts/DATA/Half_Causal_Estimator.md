<!-- tradingview-pine-id: PUB;28b6b0520c9b45c597b96d7644327a89 -->
<!-- tradingviewscripts-format: 1 -->
# Half Causal Estimator

Source: https://www.tradingview.com/script/QETnobDk-Half-Causal-Estimator/

## Description

Overview

The Half Causal Estimator is a specialized filtering method that provides responsive averages of market variables (volume, true range, or price change) with significantly reduced time delay compared to traditional moving averages. It employs a hybrid approach that leverages both historical data and time-of-day patterns to create a timely representation of market activity while maintaining smooth output.

Core Concept

Traditional moving averages suffer from time lag, which can delay signals and reduce their effectiveness for real-time decision making. The Half Causal Estimator addresses this limitation by using a non-causal filtering method that incorporates recent historical data (the causal component) alongside expected future behavior based on time-of-day patterns (the non-causal component).

This dual approach allows the filter to respond more quickly to changing market conditions while maintaining smoothness. The name "Half Causal" refers to this hybrid methodology—half of the data window comes from actual historical observations, while the other half is derived from time-of-day patterns observed over multiple days. By incorporating these "future" values from past patterns, the estimator can reduce the inherent lag present in traditional moving averages.

How It Works

The indicator operates through several coordinated steps. First, it stores and organizes market data by specific times of day (minutes/hours). Then it builds a profile of typical behavior for each time period. For calculations, it creates a filtering window where half consists of recent actual data and half consists of expected future values based on historical time-of-day patterns. Finally, it applies a kernel-based smoothing function to weight the values in this composite window.

This approach is particularly effective because market variables like volume, true range, and price changes tend to follow recognizable intraday patterns (they are positive values without DC components). By leveraging these patterns, the indicator doesn't try to predict future values in the traditional sense, but rather incorporates the average historical behavior at those future times into the current estimate.

The benefit of using this "average future data" approach is that it counteracts the lag inherent in traditional moving averages. In a standard moving average, recent price action is underweighted because older data points hold equal influence. By incorporating time-of-day averages for future periods, the Half Causal Estimator essentially shifts the center of the filter window closer to the current bar, resulting in more timely outputs while maintaining smoothing benefits.

Understanding Kernel Smoothing

At the heart of the Half Causal Estimator is kernel smoothing, a statistical technique that creates weighted averages where points closer to the center receive higher weights. This approach offers several advantages over simple moving averages. Unlike simple moving averages that weight all points equally, kernel smoothing applies a mathematically defined weight distribution. The weighting function helps minimize the impact of outliers and random fluctuations. Additionally, by adjusting the kernel width parameter, users can fine-tune the balance between responsiveness and smoothness.

The indicator supports three kernel types. The Gaussian kernel uses a bell-shaped distribution that weights central points heavily while still considering distant points. The Epanechnikov kernel employs a parabolic function that provides efficient noise reduction with a finite support range. The Triangular kernel applies a linear weighting that decreases uniformly from center to edges. These kernel functions provide the mathematical foundation for how the filter processes the combined window of past and "future" data points.

Applicable Data Sources

The indicator can be applied to three different data sources: volume (the trading volume of the security), true range (expressed as a percentage, measuring volatility), and change (the absolute percentage change from one closing price to the next).

Each of these variables shares the characteristic of being consistently positive and exhibiting cyclical intraday patterns, making them ideal candidates for this filtering approach.

Practical Applications

The Half Causal Estimator excels in scenarios where timely information is crucial. It helps in identifying volume climaxes or diminishing volume trends earlier than conventional indicators. It can detect changes in volatility patterns with reduced lag. The indicator is also useful for recognizing shifts in price momentum before they become obvious in price action, and providing smoother data for algorithmic trading systems that require reduced noise without sacrificing timeliness.

When volatility or volume spikes occur, conventional moving averages typically lag behind, potentially causing missed opportunities or delayed responses. The Half Causal Estimator produces signals that align more closely with actual market turns.

Technical Implementation

The implementation of the Half Causal Estimator involves several technical components working together. Data collection and organization is the first step—the indicator maintains a data structure that organizes market data by specific times of day. This creates a historical record of how volume, true range, or price change typically behaves at each minute/hour of the trading day.

For each calculation, the indicator constructs a composite window consisting of recent actual data points from the current session (the causal half) and historical averages for upcoming time periods from previous sessions (the non-causal half). The selected kernel function is then applied to this composite window, creating a weighted average where points closer to the center receive higher weights according to the mathematical properties of the chosen kernel. Finally, the kernel weights are normalized to ensure the output maintains proper scaling regardless of the kernel type or width parameter.

This framework enables the indicator to leverage the predictable time-of-day components in market data without trying to predict specific future values. Instead, it uses average historical patterns to reduce lag while maintaining the statistical benefits of smoothing techniques.

Configuration Options

The indicator provides several customization options. The data period setting determines the number of days of observations to store (0 uses all available data). Filter length controls the number of historical data points for the filter (total window size is length × 2 - 1). Filter width adjusts the width of the kernel function. Users can also select between Gaussian, Epanechnikov, and Triangular kernel functions, and customize visual settings such as colors and line width.

These parameters allow for fine-tuning the balance between responsiveness and smoothness based on individual trading preferences and the specific characteristics of the traded instrument.

Limitations

The indicator requires minute-based intraday timeframes, securities with volume data (when using volume as the source), and sufficient historical data to establish time-of-day patterns.

Conclusion

The Half Causal Estimator represents an innovative approach to technical analysis that addresses one of the fundamental limitations of traditional indicators: time lag. By incorporating time-of-day patterns into its calculations, it provides a more timely representation of market variables while maintaining the noise-reduction benefits of smoothing. This makes it a valuable tool for traders who need to make decisions based on real-time information about volume, volatility, or price changes.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © The_Peaceful_Lizard

//@version=6
indicator("Half Causal Estimator", format = format.volume)

// HEAD {

// enums and types {

enum Source
    vol = "Volume"
    tr = "True Range"
    change = "Change"
    test = "Sine Squared Test"

enum KernelType
    gaussian = "Gaussian"
    epanechnikov = "Epanechnikov"
    triangular = "Triangular"
    sinc = "Blackman Windowed Sinc"

enum ConfidenceAdjust
    symmetric = "Symmetric"
    linear = "Linear"
    none = "None"

type Key
    int m = minute
    int h = hour

type Vec
    float[] values

type Data
    Vec[] data
    bool[] valid

type Settings
    int data_period = 0
    int filter_length = 10
    int window_size = 20
    float kernel_width = 10
    KernelType kernel_type = KernelType.epanechnikov
    ConfidenceAdjust confidence_adjust = ConfidenceAdjust.symmetric
    float maximum_confidence_adjust = 1
    bool enable_expected_value = false
    int expected_value_length = 40
    color expected_value_color = #FEFEFE
    int expected_value_line_width = 2

// enums and types }

// extra smoothing {

na_fix(float source)=>
    var float first_value = na
    if not na(source) and na(first_value)
        first_value := source
    first_value

natural_number_sum(int length)=> length * (length + 1) * 0.5

wma(float source, int length)=>
    float first_value = na_fix(source)
    var float weight = natural_number_sum(length)

    float wma = source
    float sum = 0

    if length > 1 and not na(source)
        for i = 0 to length - 1
            float w = length - i
            sum += nz(source[i], first_value) * w
        wma := sum / weight
    wma

// extra smoothing }

// make data {

init_data()=>
    var int size = 1440 / timeframe.multiplier
    var const Vec[] data = array.new<Vec>(size)
    var const bool[] valid = array.new<bool>(size, false)
    Data.new(data, valid)

key_to_hash(Key key)=>
    int hash = int((key.h * 60 + key.m) / timeframe.multiplier)
    hash

hash_now()=> 
    key_to_hash(Key.new())

advance_key(Key self, int forward)=>
    int advanced_minute = self.m + (forward * timeframe.multiplier)
    int      new_minute = advanced_minute % 60
    int      new_hour   = (self.h + int(advanced_minute / 60)) % 24
    Key.new(new_minute, new_hour)

method maintain(float[] self, int length)=>
    if length > 0 and self.size() >= length
        self.pop()

method add_pop(float[] self, float value, int length)=>
    self.maintain(length)
    self.unshift(value)

method add_element(Data self, float source, int length)=>
    Vec[] data = self.data
    bool[] valid = self.valid
    int idx = hash_now()
    if not na(source)
        if valid.get(idx)
            data.get(idx).values.add_pop(source, length)
        else
            data.set(idx, Vec.new(array.from(source)))
            valid.set(idx, true)

method get_average(Data self, Key key)=>
    float result = na
    int idx = key_to_hash(key)
    if self.valid.get(idx)
        result := self.data.get(idx).values.avg()
    result

method i_cv(Data self, float maximum_confidence_adjust, Key key)=>
    float i_cv = 0
    int idx = key_to_hash(key)
    if self.valid.get(idx)
        float[] data = self.data.get(idx).values
        i_cv := nz(1.0 - math.min(1, math.max(0, data.stdev() / data.avg())) * maximum_confidence_adjust, 1)
    i_cv

// make data }

// testing {

time_sin()=>
    float cycle = 1440.0 / timeframe.multiplier
    math.max(0, math.pow(math.sin((math.pi / cycle) * hash_now()), 2)) * 100

// testing }

// filtering {

gaussian_kernel(float centered_index, float bandwidth) => 
    float ratio = centered_index / bandwidth
    math.exp(-math.pow(ratio, 2) / 4) / math.sqrt(2 * math.pi) 

epanechnikov_kernel(float centered_index, float bandwidth) =>
    float ratio = centered_index / bandwidth
    switch math.abs(ratio) <= 1
        true => 0.75 * (1 - math.pow(ratio, 2))
        false => 0.0

triangular_kernel(float centered_index, float bandwidth) =>
    float ratio = centered_index / bandwidth
    switch math.abs(ratio) <= 1
        true => 1 - math.abs(ratio)
        false => 0.0

blackman(float index, float length)=> 
    0.42 - 0.5 * math.cos((2 * math.pi * index) / (length - 1)) + 0.08 * math.cos((4 * math.pi * index) / (length - 1))

sinc(float centered_index, float width)=>
    float fc = 1.0 / width * 0.5
    centered_index == 0 ? 1 : math.sin(math.pi * fc * centered_index) / (math.pi * fc * centered_index)

blackman_windowed_sinc(float centered_index, float index, float width, float length)=>
    sinc(centered_index, width) * blackman(index, length)

select_kernel(float index, Settings config)=>
    float centered_index = index - (config.window_size - 1) / 2
    switch config.kernel_type
        KernelType.gaussian => gaussian_kernel(centered_index, config.kernel_width)
        KernelType.epanechnikov => epanechnikov_kernel(centered_index, config.kernel_width)
        KernelType.triangular => triangular_kernel(centered_index, config.kernel_width)
        KernelType.sinc => blackman_windowed_sinc(centered_index, index, config.kernel_width, config.window_size)

kernel_coef(Settings config)=>
    var const matrix<float> coef = matrix.new<float>(1, config.window_size)
    float normalization = 0
    for i = 0 to config.window_size - 1
        float weight = select_kernel(i, config)
        normalization += weight
        coef.set(0, i, weight)
    coef.mult(1.0 / normalization)

filter(float[] window, matrix<float> kernel)=>
    kernel.mult(window).first()

// filtering }

// estimator {

method init_make_window(float[] self, float maximum_confidence_adjust, Data data, int size, Key key_now, float[] weights)=>
    Key return_key = Key.new()
    self.clear()
    weights.clear()

    int idx = 1
    while self.size() < size
        Key key = advance_key(key_now, idx)
        if data.valid.get(key_to_hash(key))
            return_key := key
            float value = data.get_average(key)
            weights.unshift(math.max(0, data.i_cv(maximum_confidence_adjust, key)))
            self.unshift(value)
        idx += 1
    return_key

method maintain_window(float[] self, float maximum_confidence_adjust, Data data, Key window_key, float[] weights)=>
    Key key_now = window_key
    Key return_key = window_key
    int size = self.size()

    self.pop()
    weights.pop()
    int idx = 1 
    while self.size() < size
        Key key = advance_key(key_now, idx)
        if data.valid.get(key_to_hash(key))
            return_key := key
            float value = data.get_average(key)
            weights.unshift(math.max(0, data.i_cv(maximum_confidence_adjust, key)))
            self.unshift(value)
        idx += 1
    return_key

make_window(float source, Data data, bool ready, Settings config)=>
    var Key window_key = Key.new()
    var const float[] buffer = array.new<float>()
    var const float[] ahead = array.new<float>()
    var float[] weights = array.new<float>(config.filter_length - 1, 1)
    float[] confidence_weight = array.new<float>()    

    Key key_now = Key.new()
    buffer.add_pop(source, config.filter_length)

    bool update = session.isfirstbar or session.isfirstbar_regular
    if ready
        if update
            window_key := ahead.init_make_window(config.maximum_confidence_adjust, data, config.filter_length - 1, key_now, weights)
        else
            window_key := ahead.maintain_window(config.maximum_confidence_adjust, data, window_key, weights)

    float[] window = ahead.copy().concat(buffer)

    if config.confidence_adjust == ConfidenceAdjust.symmetric
        float[] causal_weight = array.new<float>(config.filter_length, 2)
        for i = 0 to causal_weight.size() - 2
            causal_weight.set(i, 2 - weights.get(i))

        causal_weight.reverse()
        causal_weight.set(0, 1)
        confidence_weight := weights.copy().concat(causal_weight)

    else if config.confidence_adjust == ConfidenceAdjust.linear
        float sum = 0
        for i = 0 to weights.size() - 1
            sum += weights.get(i)
        sum := 2 - sum / (config.filter_length - 1)

        float[] causal_weight = array.new<float>(config.filter_length, sum)
        confidence_weight := weights.copy().concat(causal_weight)

    if confidence_weight.size() == config.window_size
        for i = 0 to window.size() - 1
            window.set(i, window.get(i) * confidence_weight.get(i))
    window

make_smooth(float[] window, bool ready, Settings config)=>
    float smooth = na
    var const matrix<float> kernel = kernel_coef(config)
    if ready
        smooth := filter(window, kernel)
    smooth

// estimator }

// expected value {


method expected_value_make_window(float[] self, float[] buffer, Data data, int size, Key key_now)=>
    float[] window = buffer.copy()
    Key return_key = Key.new()

    int idx = 1
    while window.size() < size
        Key key = advance_key(key_now, idx)
        if data.valid.get(key_to_hash(key))
            return_key := key
            float value = data.get_average(key)
            window.unshift(value)
        idx += 1

    self.clear()
    self.concat(window)
    return_key

method expected_value_maintain_window(float[] self, Key window_key, Data data)=>
    Key key_now = window_key
    Key return_key = window_key
    int size = self.size()

    self.pop()
    int idx = 1 
    while self.size() < size
        Key key = advance_key(key_now, idx)
        if data.valid.get(key_to_hash(key))
            return_key := key
            float value = data.get_average(key)
            self.unshift(value)
        idx += 1
    return_key

method make_extrapolation(polyline[] self, Data data, float[] window, Key window_key, matrix<float> kernel, float first_point, Settings config)=>
    while self.size() > 0
        self.pop().delete()

    if config.enable_expected_value and config.expected_value_length > 0
        chart.point[] extrapolation_points = array.from(chart.point.new(na, bar_index, first_point))
        float[] extrapolation_window = window.copy()
        Key extrapolation_key = window_key

        for i = 0 to config.expected_value_length - 1
            extrapolation_key := extrapolation_window.expected_value_maintain_window(extrapolation_key, data)
            extrapolation_points.push(chart.point.new(na, bar_index + 1 + i, filter(extrapolation_window, kernel)))
        
        self.push(polyline.new(extrapolation_points, false, false, xloc.bar_index, config.expected_value_color, na, line.style_solid, config.expected_value_line_width))

expected_value(Data data, bool ready, Settings config)=>
    var Key window_key = Key.new()
    float smooth = na

    var const polyline[] extrapolate_line = array.new<polyline>()
    var const float[] buffer = array.new<float>()
    var const float[] window = array.new<float>()
    
    if config.enable_expected_value
        var matrix<float> kernel = kernel_coef(config)
        Key key_now = Key.new()
        buffer.add_pop(data.get_average(key_now), config.filter_length)

        bool update = session.isfirstbar or session.isfirstbar_regular

        if ready
            if update
                window_key := window.expected_value_make_window(buffer, data, config.window_size, key_now)
            else
                window_key := window.expected_value_maintain_window(window_key, data)

            smooth := filter(window, kernel)

            if barstate.islast
                extrapolate_line.make_extrapolation(data, window, window_key, kernel, smooth, config)
    smooth

// expected value }

// main {

ready(Settings config)=>
    var bool ready = false
    if not ready and bar_index > (config.window_size) and session.isfirstbar
        ready := true
    ready

main(float source, Settings config)=>
    bool ready = ready(config)
    var Data data = init_data()
    float[] window = make_window(source, data, ready, config)
    float smooth = make_smooth(window, ready, config)
    float expected_value = expected_value(data, ready, config)
    data.add_element(source, config.data_period)
    [smooth, expected_value]

// main }

// HEAD }


// BODY {

// inputs {

const string estimator_group = "Estimator Settings"

const string source_tip = "Volume: This source utilizes the symbols volume. \n
 \nTR: True range for the symbol expressed as a percent. \n
 \nChange: The percent change from one close to the next. \n
 \nSin Squared Test: This will produce a rectified sine wave with a period of one day no matter the timeframe." 

const string period_tip = "This is the number of days worth of observations to store for the estimate. A value of 0
 will use all available observations."

const string length_tip = "This is the number of historical data points for the filter. The actual size of the filter
 is length * 2 - 1 as half of the window is future points. When the Kernel Type is set to Blackman Windowed Sinc the
 length will automatically be doubled."

const string width_tip = "This controls the width of the filter. Generally you will want it to be the same as your
 length, but you can adjust it to be any size. A value larger than the length will make the kernel larger than the set,
 while a number smaller than the length will effectivly make the filter the size of the width."

const string confidence_tip = "This controls the weight of estimated future points. If the variability of the observed
 historical time-of-day points is high, then it will decrease the weight of that point and rebalance it into the causal
 portion of the window.\n
 \nSymmetric: This mode will reduce a weight on the right of center and increase the weight of on the mirror side on the
 left.\n
 \nLinear: This will redistribute the weight linearly across the left half, and individually reduce the weight on the
 right.\n
 \nNone: This removes the confidence weighting."

const string maximum_confidence_adjust_tip = "This metric controls the level of confidence penalization. When set to 100
 the Confidence Correction will be applied in full. When set to 0 it will not be applied. Any percent inbetween will 
 apply it to that degree."

const string extra_smoothing_tip = "Apply some extra smoothing to the estimation using a wma."

var Source data_source = input.enum(Source.vol, "Source", tooltip = source_tip, group = estimator_group)
int data_period = input.int(5, "Data Period", minval = 0, tooltip = period_tip, group = estimator_group)
int filter_length = input.int(20, "Filter Length", minval = 2, tooltip = length_tip, group = estimator_group)
float kernel_width = input.float(20, "Filter Width", minval = 0.125, step = 0.125, tooltip = width_tip, group = estimator_group)
var KernelType kernel_type = input.enum(KernelType.epanechnikov, "Kernel Type", group = estimator_group)
var ConfidenceAdjust confidence_adjust = input.enum(ConfidenceAdjust.symmetric, "Confidence Correction", tooltip = confidence_tip, group = estimator_group)
float maximum_confidence_adjust = input.float(100, "Maximum Confidence Correction Percent", step = 1, minval = 0, maxval = 100, tooltip = maximum_confidence_adjust_tip, group = estimator_group)
int extra_smoothing = input.int(0, "Extra Smoothing", minval = 0, tooltip = extra_smoothing_tip, group = estimator_group)


const string expected_value_group = "Expected Value Settings"

const string expected_value_tip = "The Expected Value only uses the average historical time of day data for all aspects
 of the calculation. This results in an estimation that is only related to the average behaviour of the signal. Because
 of this, you can extrapolate the estimation into the future to see what might happen. All of the estimator settings
 apply except the Confidence Correction. This also lets you see what data is being used for the future half of the
 window when extrapolating."

bool enable_expected_value = input.bool(false, "Enable Expected Value", tooltip = expected_value_tip, group = expected_value_group)
int expected_value_length = input.int(50, "Expected Value Extrapolation Length", minval = 0, group = expected_value_group)


const string visual_group = "Visual Settings"

color estimator_color = input.color(#FEFEFE, "Estimator Color", group = visual_group)
color bullish_color = input.color(#089981, "Bullish Color", group = visual_group)
color bearish_color = input.color(#f23645, "Bearish Color", group = visual_group)
int line_width = input.int(2, "Estimator Line Width", minval = 1, group = visual_group)
color expected_value_color = input.color(#e9f236, "Expected Value Color", group = visual_group)
int expected_value_line_width = input.int(2, "Expected Value Line Width", minval = 1, group = visual_group)


int real_filter_length = switch kernel_type
    KernelType.sinc => filter_length * 2
    => filter_length

var Settings config = Settings.new(
   data_period
 , real_filter_length
 , real_filter_length * 2 - 1 
 , kernel_width
 , kernel_type
 , confidence_adjust
 , maximum_confidence_adjust * 0.01
 , enable_expected_value
 , expected_value_length
 , expected_value_color
 , expected_value_line_width
 )

// inputs }

// calculations {

float source = switch data_source
    Source.vol => volume
    Source.tr => (high - low) / low * 100
    Source.change => math.abs(close - nz(close[1], close)) / math.min(close, nz(close[1], close)) * 100
    Source.test => time_sin()

[estimate, expected_value] = main(source, config)
float smooth_estimate = wma(estimate, extra_smoothing + 1)

color colour = switch data_source
    Source.test => bullish_color
    Source.change => close > close[1] ? bullish_color: bearish_color
    => open < close ? bullish_color : bearish_color

// calculations }

// plot {

show_volume = data_source == Source.vol ? display.all : display.none
show_percent = data_source != Source.vol ? display.all : display.none

plot(source, "Volume", colour, 1, plot.style_columns, format = format.volume, display = show_volume)
plot(smooth_estimate, "Volume Average", estimator_color, line_width, format = format.volume, display = show_volume)
plot(expected_value, "Expected Value Volume Average", expected_value_color, expected_value_line_width, format = format.volume, display = show_volume)

plot(source, "Percent Change", colour, 1, plot.style_columns, format = format.percent, display = show_percent)
plot(smooth_estimate, "Percent Change Average", estimator_color, line_width, format = format.percent, display = show_percent)
plot(expected_value, "Expected Value Percent Change Average", expected_value_color, expected_value_line_width, format = format.percent, display = show_percent)

// plot }

// errors {

float has_volume = ta.cum(volume)

if barstate.isfirst
    if not timeframe.isminutes
        runtime.error("Timeframe must be minute/s intraday.")

if barstate.islast
    if has_volume == 0
        runtime.error("To use volume, the symbol must have volume.")

// errors }

// BODY }
````
