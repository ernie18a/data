<!-- tradingview-pine-id: PUB;b1834ae235344b4e8bb45b12106b4d12 -->
<!-- tradingviewscripts-format: 1 -->
# [MAD] Acceleration based dampened SMA projections

Source: https://www.tradingview.com/script/QREVZoDw-MAD-Acceleration-based-dampened-SMA-projections/

## Description

This indicator utilizes concepts of arrays inside arrays to calculate and display projections of multiple Smoothed Moving Average (SMA) lines via polylines.

This is partly an experiment as an educational post, on how to work with multidimensional arrays by using User-Defined Types

------------------

Input Controls for User Interaction:
The indicator provides several input controls, allowing users to adjust parameters like the SMA window, acceleration window, and dampening factors. 
This flexibility lets users customize the behavior and appearance of the indicator to fit their analysis needs.

sma length: 
Defines the length of the simple moving average (SMA).

acceleration window: 
Sets the window size for calculating the acceleration of the SMA.

Input Series: 
Selects the input source for calculating the SMA (typically the closing price).

Offset: 
Determines the offset for the input source, affecting the positioning of the SMA. Here it´s possible to add external indicators like bollinger bands,.. in that case as double sma this sma should be very short.
(Thanks Fikira for that idea)

Startfactor dampening: 
Initial dampening factor for the polynomial curve projections, influencing their starting curvature.

Growfactor dampening: 
Growth rate of the dampening factor, affecting how the curvature of the projections changes over time.

Prediction length: 
Sets the length of the projected polylines, extending beyond the current bar.

cleanup history: 
Boolean input to control whether to clear the previous polyline projections before drawing new ones.

Key technologies used in this indicator include:

User-Defined Types (UDT): 
This indicator uses UDT to create a custom type named type_polypaths. 
This type is designed to store information for each polyline, including an array of points (array<chart.point>), a color for the polyline, and a dampening factor. 
UDTs in Pine Script enable the creation of complex data structures, which are essential for organizing and manipulating data efficiently.
[pine]type type_polypaths
    array<chart.point>  polyline_points = na
    color               polyline_color  = na
    float               dampening_factor= na
[/pine]

Arrays and Nested Arrays: 
The script heavily utilizes arrays. 
For example, it uses a color array (colorpreset) to store different colors for the polyline. 
Moreover, an array of type_polypaths (polypaths) is used, which is an array consisting of user-defined types. Each element of this array contains another array (polyline_points), demonstrating nested array usage. 
This structure is essential for handling multiple polylines, each with its set of points and attributes.
[pine]var type_polypaths [] polypaths = array.new<type_polypaths>()[/pine]

Polyline Creation and Manipulation: 
The core visual aspect of the indicator is the creation of polylines. 
Polyline points are calculated based on a dampened polynomial curve, which is influenced by the SMA's slope and acceleration. 

Filling initial dampening data 
[pine]    array_size = 9
    middle_index = math.floor(array_size / 2)
    for i = 0 to array_size - 1
        damp_factor = f_calculate_damp_factor(i, middle_index, Startfactor, Growfactor)
        polyline_color = colorpreset.get(i)
        polypaths.push(type_polypaths.new(array.new<chart.point>(0, na), polyline_color, damp_factor))
[/pine]

The script dynamically generates these polyline points and stores them in the polyline_points array of each type_polypaths instance based on those prefilled dampening factors
[pine]if barstate.islast or cleanup == false
    for damp_factor_index = 0 to polypaths.size() - 1
        GET_RW = polypaths.get(damp_factor_index)
        GET_RW.polyline_points.clear()

        for i = 0 to predictionlength
            y = f_dampened_poly_curve(bar_index + i , src_input[src_off], sma_slope[src_off], sma_acceleration[src_off], GET_RW.dampening_factor)
            p = chart.point.from_index(bar_index + i - src_off, y)
            GET_RW.polyline_points.push(p)
        polypaths.set(damp_factor_index, GET_RW)[/pine]

Polyline Drawout
The polyline is then drawn on the chart using the polyline.new() function, which uses these points and additional attributes like color and width.
[pine]    for pl_s = 0 to polypaths.size() - 1
        GET_RO = polypaths.get(pl_s)
        polyline.new(points = GET_RO.polyline_points, line_width = 1, line_color = GET_RO.polyline_color, xloc = xloc.bar_index)[/pine]

If the cleanup input is enabled, existing polylines are deleted before new ones are drawn, maintaining clarity and accuracy in the visualization.
[pine]if cleanup
    for pl_delete in polyline.all
        pl_delete.delete()[/pine]

------------------

The mathematics 
in the (ABDP) indicator primarily focuses on projecting the behavior of a Smoothed Moving Average (SMA) based on its current trend and acceleration.

SMA Calculation: 
The indicator computes a simple moving average (SMA) over a specified window (sma_window). This SMA serves as the baseline for further calculations.

Slope and Acceleration Analysis: 
It calculates the slope of the SMA by subtracting the current SMA value from its previous value. Additionally, it computes the SMA's acceleration by evaluating the sum of differences between consecutive SMA values over an acceleration window (acceleration_window). This acceleration represents the rate of change of the SMA's slope.
[pine]
sma_slope = src_input - src_input[1]
sma_acceleration = sma_acceleration_sum_calc(src_input, acceleration_window) / acceleration_window

sma_acceleration_sum_calc(src, window) =>
    sum = 0.0
    for i = 0 to window - 1
        if not na(src[i + 2])
            sum := sum + src - 2 * src[i + 1] + src[i + 2]
    sum[/pine]

Dampening Factors: 
Custom dampening factors for each polyline, which are based on the user-defined starting and growth factors (Startfactor, Growfactor). 
These factors adjust the curvature of the projected polylines, simulating various future scenarios of SMA movement.
[pine]f_calculate_damp_factor(index, middle, start_factor, growth_factor) =>
    start_factor + (index - middle) * growth_factor[/pine]

Polynomial Curve Projection: 
Using the SMA value, its slope, acceleration, and dampening factors, the script calculates points for polynomial curves. These curves represent potential future paths of the SMA, factoring in its current direction and rate of change.
[pine]f_dampened_poly_curve(index, initial_value, initial_slope, acceleration, damp_factor) =>
    delta = index - bar_index
    initial_value + initial_slope * delta + 0.5 * damp_factor * acceleration * delta * delta

damp_factor = f_calculate_damp_factor(i, middle_index, Startfactor, Growfactor)[/pine]

Have fun trading :-)

---

## Source Code

````pine
//@version=5
// © djmad
//233 is version without final optimizing

indicator("[MAD] Acceleration based dampened SMA projections", shorttitle = "ABDP" ,overlay=true, max_polylines_count = 100)

//  _______                    
// |__   __|                   
//    | |_   _ _ __   ___  ___ 
//    | | | | | '_ \ / _ \/ __|
//    | | |_| | |_) |  __/\__ \
//    |_|\__, | .__/ \___||___/
//        __/ | |              
//       |___/|_|              {

// User-defined types for storing polyline points, polypaths, and dampening factors
type type_polypaths
    array<chart.point>  polyline_points = na
    color               polyline_color  = na
    float               dampening_factor= na

//}

//  _____                   _                         _                       
// |_   _|                 | |                       | |                      
//   | |  _ __  _ __  _   _| |_ ___    __ _ _ __   __| | __   ____ _ _ __ ___ 
//   | | | '_ \| '_ \| | | | __/ __|  / _` | '_ \ / _` | \ \ / / _` | '__/ __|
//  _| |_| | | | |_) | |_| | |_\__ \ | (_| | | | | (_| |  \ V / (_| | |  \__ \
// |_____|_| |_| .__/ \__,_|\__|___/  \__,_|_| |_|\__,_|   \_/ \__,_|_|  |___/
//             | |                                                            
//             |_|                                                              {

// Inputs
sma_window = input.int(20,"sma length")
acceleration_window = input.int(5,"acceleration window")
src_input = ta.sma(input.source(close, "Input Series", inline='src'), sma_window)
src_off   = input.int(20, 'Offset', minval=0, maxval=400, inline='src')

Startfactor = input.float(0,"Startfactor dampening",step=0.1, group="dampening and spread") 
Growfactor = input.float(0.5,"Growfactor dampening",step=0.1, group="dampening and spread")
predictionlength = input.int(10,"Prediction length") + src_off
cleanup = input.bool(true, "cleanup history")

// Vars
// Creating a symmetrical color array //
colorpreset = array.new_color(9)
colorpreset.set(0, color.rgb(255, 0, 0))     // Red
colorpreset.set(1, color.rgb(255, 128, 0))   // Orange-Red
colorpreset.set(2, color.rgb(255, 255, 0))   // Yellow
colorpreset.set(3, color.rgb(128, 255, 0))   // Yellow-Green
colorpreset.set(4, color.rgb(0, 255, 0))     // Green
colorpreset.set(5, color.rgb(128, 255, 0))   // Yellow-Green
colorpreset.set(6, color.rgb(255, 255, 0))   // Yellow
colorpreset.set(7, color.rgb(255, 128, 0))   // Orange-Red
colorpreset.set(8, color.rgb(255, 0, 0))     // Red

// Creating Array of Polypaths
var type_polypaths [] polypaths = array.new<type_polypaths>()

// }

//   ______                _   _                 
//  |  ____|              | | (_)                
//  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___ 
//  |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
//  | |  | |_| | | | | (__| |_| | (_) | | | \__ \
//  |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/                           {

// Initialize array of polypaths with dampening factors
f_calculate_damp_factor(index, middle, start_factor, growth_factor) =>
    start_factor + (index - middle) * growth_factor

f_dampened_poly_curve(index, initial_value, initial_slope, acceleration, damp_factor) =>
    delta = index - bar_index
    initial_value + initial_slope * delta + 0.5 * damp_factor * acceleration * delta * delta

// Calculate sum of accelerations over the window
sma_acceleration_sum_calc(src, window) =>
    sum = 0.0
    for i = 0 to window - 1
        if not na(src[i + 2])
            sum := sum + src[i] - 2 * src[i + 1] + src[i + 2]
    sum
//}

//   _____             _   _                
//  |  __ \           | | (_)               
//  | |__) |   _ _ __ | |_ _ _ __ ___   ___ 
//  |  _  / | | | '_ \| __| | '_ ` _ \ / _ \
//  | | \ \ |_| | | | | |_| | | | | | |  __/
//  |_|  \_\__,_|_| |_|\__|_|_| |_| |_|\___|                           {

// get slope and acceleration
sma_slope = src_input - src_input[1]
sma_acceleration = sma_acceleration_sum_calc(src_input, acceleration_window) / acceleration_window

// Fill the Dampening Array
if barstate.isfirst
    array_size = 9
    middle_index = math.floor(array_size / 2)
    for i = 0 to array_size - 1
        damp_factor = f_calculate_damp_factor(i, middle_index, Startfactor, Growfactor)
        polyline_color = colorpreset.get(i)
        polypaths.push(type_polypaths.new(array.new<chart.point>(0, na), polyline_color, damp_factor))

// Function to calculate a point on a dampened polynomial curve
// Generate and store points for each curve with associated dampening factors
if barstate.islast or cleanup == false
    for damp_factor_index = 0 to polypaths.size() - 1
        GET_RW = polypaths.get(damp_factor_index)
        GET_RW.polyline_points.clear()

        for i = 0 to predictionlength
            y = f_dampened_poly_curve(bar_index + i , src_input[src_off], sma_slope[src_off], sma_acceleration[src_off], GET_RW.dampening_factor)
            p = chart.point.from_index(bar_index + i - src_off, y)
            GET_RW.polyline_points.push(p)
        polypaths.set(damp_factor_index, GET_RW)

/// }

//   _____  _       _   _   _             
//  |  __ \| |     | | | | (_)            
//  | |__) | | ___ | |_| |_ _ _ __   __ _ 
//  |  ___/| |/ _ \| __| __| | '_ \ / _` |
//  | |    | | (_) | |_| |_| | | | | (_| |
//  |_|    |_|\___/ \__|\__|_|_| |_|\__, |
//                                   __/ |
//                                  |___/                           {

// Plot the curves
if cleanup
    for pl_delete in polyline.all
        pl_delete.delete()

// Drawout all polylines
if barstate.islast or cleanup == false
    for pl_s = 0 to polypaths.size() - 1
        GET_RO = polypaths.get(pl_s)
        polyline.new(points = GET_RO.polyline_points, line_width = 1, line_color = GET_RO.polyline_color, xloc = xloc.bar_index)

// Plot SMA
plot(src_input, color=color.green, title="SMA")

//}
````
