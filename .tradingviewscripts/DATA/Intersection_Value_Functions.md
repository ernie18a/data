<!-- tradingview-pine-id: PUB;073b755f02f54f97a6225245febac7a0 -->
<!-- tradingviewscripts-format: 1 -->
# Intersection Value Functions

Source: https://www.tradingview.com/script/gD1gDOyI-Intersection-Value-Functions/

## Description

Winning entry for the first Pinefest contest. The challenge required providing three functions returning the intersection value between two series source1 and source2 in the event of a cross, crossunder, and crossover.

Feel free to use the code however you like.

🔶 CHALLENGE FUNCTIONS

🔹crossValue()

[pine]
//@function Finds intersection value of 2 lines/values if any cross occurs - First function of challenge -> crossValue(source1, source2)
//@param    source1 (float) source value 1 
//@param    source2 (float) source value 2
//@returns  Intersection value
[/pine]

example:

[pine]
value = crossValue(close, close[25])
[/pine]

🔹crossoverValue()

[pine]
//@function Finds intersection value of 2 lines/values if crossover occurs - Second function of challenge -> crossoverValue(source1, source2) 
//@param    source1 (float) source value 1 
//@param    source2 (float) source value 2
//@returns  Intersection value
[/pine]

example:

[pine]
value = crossoverValue(close, close[25])
[/pine]

🔹crossunderValue()

[pine]
//@function Finds intersect of 2 lines/values if crossunder occurs - Third function of challenge -> crossunderValue(source1, source2) 
//@param    source1 (float) source value 1 
//@param    source2 (float) source value 2
//@returns  Intersection value
[/pine]

example:

[pine]
value = crossunderValue(close, close[25])
[/pine]

🔶 DETAILS

A series of values can be displayed as a series of points, where the point location highlights its value, however, it is more common to connect each point with a line to have a continuous aspect.

[image]https://www.tradingview.com/x/Bt7dGQzJ/[/image]

A line is a geometrical object connecting two points, each having y and x coordinates. A line has a slope controlling its steepness and an intercept indicating where the line crosses an axis. With these elements, we can describe a line as follows:

[pine]
slope × x + intercept
[/pine]

[image]https://www.tradingview.com/x/3d2fwPW6/[/image]

A cross between two series of values occurs when one series is greater or lower than the other while its previous value isn't.

[image]https://www.tradingview.com/x/QpTG1p1b/[/image]

We are interested in finding the "intersection value", that is the value where two crossing lines are equal. This problem can be approached via linear interpolation.

A simple and direct approach to finding our intersection value is to find the common scaling factor of the slopes of the lines, that is the multiplicative factor that multiplies both lines slopes such that the resulting points are equal. 

Given:

[pine]
A = Point A1 + m1 × scaling_factor
B = Point B1 + m2 × scaling_factor
[/pine]

where scaling_factor is the common scaling factor, and m1 and m2 the slopes:

[pine]
m1 = Point A2 - Point A1
m2 = Point B2 - Point B1
[/pine]

In our cases, since the horizontal distance between two points is simply 1, our lines slopes are equal to their vertical distance (rise).

Under the event of a cross, there exists a scaling_factor satisfying A = B, which allows us to directly compute our intersection value. The solution is given by:

[pine]
scaling_factor = (B1 - A1)/(m1 - m2)
[/pine]

As such our intersection value can be given by the following equivalent calculations:

[pine]
(1) A1 + m1 × (B1 - A1)/(m1 - m2)
(2) B1 + m2 × (B1 - A1)/(m1 - m2)
(3) A2 - m2 × (A2 - B2)/(m1 - m2)
(4) B2 - m2 × (A2 - B2)/(m1 - m2)
[/pine]

The proposed functions use the third calculation.

[image]https://www.tradingview.com/x/vvmMVbRC/[/image]

This approach is equivalent to expressions using the classical line equation, with:

[pine]
slope1 × x + intercept1 = slope2 × x + intercept2
[/pine]

By solving for x, the intersection point is obtained by evaluating any of the line equations for the obtained x solution.

🔶 APPLICATIONS

The intersection point of two crossing lines might lead to interesting applications and creations, in this section various information/tools derived from the proposed calculations are presented.

This supplementary material is available within the script.

🔹Intersections As Support/Resistances

[image]https://www.tradingview.com/x/X53f2p2z/[/image]

The script allows extending the lines of the intersection value when a cross is detected, these extended lines could have applications as support/resistance lines.

🔹Using The Scaling Factor

The core of the proposed calculation method is the common scaling factor, which can be used to return useful information, such as the position of the cross relative to the x coordinates of a line.

[image]https://www.tradingview.com/x/Ywqo005K/[/image]

The above image highlights two moving averages (in green and red), the cross-interval areas are highlighted in blue, and the intersection point is highlighted as a blue line.

The pane below shows a bar plot displaying:

[pine]1 - scaling factor = 1 - [(source1 - source2) / (m1 - m2)][/pine]

Values closer to 1 indicate that the cross location is closer to x2 (the right coordinate of the lines), while values closer to 0 indicate that the cross location is closer to x1.

🔹Intersection Matrix

The main proposed functions of this challenge focus on the crossings between two series of values, however, we might be interested in applying this over a collection of series.

[image]https://www.tradingview.com/x/ym2NBrIX/[/image]

We can see in the image above how the lines connecting two points intersect with each other, we can construct a [matrix](https://www.tradingview.com/pine-script-docs/en/v5/language/Matrices.html) populated with the intersection value of two corresponding lines. If (X, Y) represents the intersection value between lines X and Y we have the following matrix:

[pine]
       | Line A | Line B | Line C | Line D |
-------|--------|--------|--------|--------|
Line A |        | (A, B) | (A, C) | (A, D) |
Line B | (B, A) |        | (B, C) | (B, D) |
Line C | (C, A) | (C, B) |        | (C, D) |
Line D | (D, A) | (D, B) | (D, C) |        |
[/pine]

We can see that the upper triangular part of this matrix is redundant, which is why the script does not compute it. This function is provided in the script as intersectionMatrix:

[pine]
//@function Return the N * N intersection matrix from an array of values
//@param    array_series (array<float>) array of values, requires an array supporting historical referencing
//@returns  (matrix<float>) Intersection matrix showing intersection values between all array entries
[/pine]

In the script, we create an intersection matrix from an array containing the outputs of simple moving averages with a period in a specific user set range and can highlight if a simple moving average of a certain period crosses with another moving average with a different period, as well as the intersection value.

[image]https://www.tradingview.com/x/7MX0IV1v/[/image]

🔹Magnification Glass

Crosses on a chart can be quite small and might require zooming in significantly to see a detailed picture of them. Using the obtained scaling factor allows reconstructing crossing events with an higher resolution.

[image]https://www.tradingview.com/x/fqQHxAxc/[/image]

A simple supplementary zoomIn function is provided to this effect:

[pine]
//@function Display an higher resolution representation of intersecting lines
//@param    source1      (float) source value 1
//@param    source2      (float) source value 2
//@param    css1         (color) color of source 1 line
//@param    css2         (color) color of source 2 line
//@param    intersec_css (color) color of intersection line
//@param    area_css     (color) color of box area
[/pine]

Users can obtain a higher resolution by modifying the provided "Resolution" setting.

The function returns a higher resolution representation of the most recent crosses between two input series, the intersection value is also provided.

---

## Source Code

````pine
_                                                                                                                                                                                                        = '
 "Pinefest #1 October 21-28, 2023"
  ----------------------------------------------------------------------------------------------------------------------------------------- 
 | █ CHALLENGE                                                                                                                             |
 |                                                                                                                                         |
 |   Create three functions that will return the exact value where two data series intersect:                                              |
 |                                                                                                                                         |
 |   • crossValue     (source1, source2)                                                                                                   | 
 |   • crossoverValue (source1, source2)                                                                                                   | 
 |   • crossunderValue(source1, source2)                                                                                                   |
 |                                                                                                                                         |
 |   When a cross occurs, the functions must return the intersection`s value. When no cross occurs, they must return na.                   |
 |                                                                                                                                         |
  -----------------------------------------------------------------------------------------------------------------------------------------                                                                '

//@version=5
indicator(  title = 'Intersection Value Functions'
     , max_boxes_count  = 500
     , max_lines_count  = 500
     , max_labels_count = 500
     , overlay          = true
     )

//---------------------------------------------------------------------------------------------------------------------}
//Challenge Functions
//---------------------------------------------------------------------------------------------------------------------{
// getSlopes()
//
//@function Get the slope of the lines connecting source1/source2 to source1[1]/source2[1]
//@param    source1 (float) source value 1
//@param    source2 (float) source value 2 
//@returns  Slopes of the lines
getSlopes(float source1, float source2) =>

    //Get slopes
    m1  =  ta.change(source1) 
    m2  =  ta.change(source2)

    //Output
    [m1 , m2]

// commonScalingFactor()
//
//@function Common scaling factor of the lines connecting source1/source2 to source1[1]/source2[1]
//@param    source1 (float) source value 1 
//@param    source2 (float) source value 2
//@param    m1      (float) slope of the line originating from source1 
//@param    m2      (float) slope of the line originating from source2 
//@returns  Common scaling factor
commonScalingFactor(float source1, float source2, float m1, float m2) => 
    
    //Output
    (source1 - source2) / (m1 - m2) 

// crossValue()
//
//@function Finds intersection value of 2 lines/values if any cross occurs - First function of challenge -> crossValue(source1, source2)
//@param    source1 (float) source value 1 
//@param    source2 (float) source value 2
//@returns  Intersection value
method crossValue(float source1, float source2)=>
    float insct = na

    //Slope calculations, called on each bar
    [m1, m2] = getSlopes(source1, source2)

    //Test for cross
    if ta.cross(source1, source2)

        //Find common scaling factor
        sf = commonScalingFactor(source1, source2, m1, m2)
    
        //Find intersection value
        insct := source1 - sf * m1

// crossoverValue()
//
//@function Finds intersection value of 2 lines/values if crossover occurs - Second function of challenge -> crossoverValue(source1, source2) 
//@param    source1 (float) source value 1 
//@param    source2 (float) source value 2
//@returns  Intersection value
method crossoverValue(float source1, float source2)=>
    float insct = na

    //Slope calculations, called on each bar
    [m1, m2] = getSlopes(source1, source2)

    //Test for cross
    if ta.crossover(source1, source2)

        //Find common scaling factor
        sf = commonScalingFactor(source1, source2, m1, m2)
    
        //Find intersection value
        insct := source1 - sf * m1

// crossunderValue()
//
//@function Finds intersect of 2 lines/values if crossunder occurs - Third function of challenge -> crossunderValue(source1, source2) 
//@param    source1 (float) source value 1 
//@param    source2 (float) source value 2
//@returns  Intersection value
method crossunderValue(float source1, float source2) =>
    float insct = na

    //Slope calculations, called on each bar
    [m1, m2] = getSlopes(source1, source2)

    //Test for cross
    if ta.crossunder(source1, source2)

        //Find common scaling factor
        sf = commonScalingFactor(source1, source2, m1, m2)
    
        //Find intersection value
        insct := source1 - sf * m1

//---------------------------------------------------------------------------------------------------------------------}
//Usage - Code used to highlight the proposed functions usage.
//---------------------------------------------------------------------------------------------------------------------{
//Settings
//-----------------------------------------------------------------------------{
//Sources selection
sourceA = input.string('SMA', 'Source A'
  , options = ['SMA', 'EMA', 'WMA', 'Hull', 'External A']
  , inline  = 'sourceA')

lenA    = input.int(9, '', minval = 1
  , inline = 'sourceA')

externalA = input.source(close, 'External A')

sourceB = input.string('SMA', 'Source B'
  , options = ['SMA', 'EMA', 'WMA', 'Hull', 'External B']
  , inline  = 'sourceB')

lenB    = input.int(20, '', minval = 1
  , inline = 'sourceB')

externalB = input.source(open, 'External B')

//Style
coCss = input.color(#2962ff, 'Crossover'
  , inline = 'crossover')

coAreaCss = input.color(color.new(#2962ff, 90), ''
  , inline = 'crossover')

cuCss = input.color(#ff5d00, 'Crossover'
  , inline = 'crossunder')

cuAreaCss = input.color(color.new(#ff5d00, 90), ''
  , inline = 'crossunder')

extend = input(true, 'Extend Intersections')

//SMA Intersection Matrix
showDash  = input(true, 'Show Matrix'
  , group = 'SMA Intersection Matrix')

minLen = input.int(10, 'SMA Length Range'
  , minval = 1
  , inline = 'lenrange'
  , group = 'SMA Intersection Matrix')

maxLen = input.int(20, ''
  , minval = 1
  , inline = 'lenrange'
  , group = 'SMA Intersection Matrix')

dashLoc  = input.string('Top Right', 'Location'
  , options = ['Top Right', 'Bottom Right', 'Bottom Left']
  , group = 'SMA Intersection Matrix')

textSize = input.string('Small', 'Size'
  , options = ['Tiny', 'Small', 'Normal']
  , group = 'SMA Intersection Matrix')

//Magnifying Glass
magnify = input(true, 'Magnify'
  , group = 'Magnifying Glass')

resolution = input.int(20, 'Resolution'
  , minval = 2
  , group = 'Magnifying Glass')

offset = input.int(10, 'Offset'
  , minval = 2
  , group = 'Magnifying Glass')

//----------------------------------------------------------------------------}
//Methods/Functions
//----------------------------------------------------------------------------{
//@function Return various supported moving averages outputs based on an input string
//@param    id       (string) determine the function output, supported strings include ['SMA', 'EMA', 'WMA', 'Hull'], else an external value is returned
//@param    len      (simple int) moving average length if applicable
//@param    external (float) external source
//@returns  Chosen moving average output or "external" if "id" is not part of supported options 
method source(string id, simple int len, float external) =>
    sma = ta.sma(close, len)
    ema = ta.ema(close, len)
    wma = ta.wma(close, len)
    hma = ta.hma(close, len)

    output = switch id
        'SMA'  => sma
        'EMA'  => ema
        'WMA'  => wma
        'Hull' => hma
        => external

//@function Return the N * N intersection matrix from an array of values with size N and the values in its previous instance
//@param    array_series (array<float>) array of values, requires an array supporting historical referencing
//@returns  (matrix<float>) Intersection matrix showing intersection value between all array entries
intersectionMatrix(array_series)=>
    N = array_series.size()-1
    ismt = matrix.new<float>(N+1, N+1)
    sfmt = matrix.new<float>(N+1, N+1)
    
    prev_array = array_series[1]

    if not na(prev_array)
        //Columns
        for i = 0 to N
            //Get source1 and previous source1 value
            source1 = array_series.get(i)
            prev1 = prev_array.get(i)

            //source1 slope
            m1 = source1 - prev1

            //Rows
            for j = i to N
                //Na is column index = row index
                if i == j
                    ismt.set(j, i, float(na))
                else
                    //Get source2 and previous source2 value
                    source2 = array_series.get(j)
                    prev2 = prev_array.get(j)

                    //source2 slope
                    m2 = source2 - prev2
                    
                    //Test for cross
                    if (source1 - source2) * (prev1 - prev2) < 0
                        //Find common scaling factor
                        sf = commonScalingFactor(source1, source2, m1, m2)

                        //Find intersection value
                        insct = source1 - sf * m1
                        
                        //Set matrix intersection and scaling factor values
                        ismt.set(i, j, insct)
                        sfmt.set(i, j, 1 - sf)

    //Output
    [ismt, sfmt]

//@function Draw graphical elements on the chart highlighting crossing events and intersection value/area
//@param    intersection_val (float) Intersection value between source1 and source2
//@param    scaling_factor   (float) Common scaling factor between two crossing lines
//@param    max              (float) area top
//@param    min              (float) area bottom
//@param    crossover        (bool)  true if the lines are crossing over each other
//@param    css              (color) color of the line/label text
//@param    css_area         (color) color of the box area
//@returns  [line, label, box] drawing elements 
draw(intersection_val, scaling_factor, max, min, crossover, css, css_area)=>
    n = bar_index

    //Intersection level
    lvl = line.new(
      chart.point.from_index(n-1, intersection_val)
      , chart.point.from_index(n, intersection_val)
      , color = css)

    //Intersection value label and display 1 - scaling factor when hovering over label
    lbl = label.new(
      chart.point.from_index(n, crossover ? min : max)
      , color = color(na)
      , textcolor = css
      , text = str.tostring(math.round_to_mintick(intersection_val))
      , style = crossover ? label.style_label_up : label.style_label_down
      , size = size.small
      , tooltip = str.tostring(1 - scaling_factor, '#.##'))
    
    //Highlight intersection area
    bx = box.new(
      chart.point.from_index(n-1, max)
      , chart.point.from_index(n, min)
      , na
      , bgcolor = css_area)

    [lvl, lbl, bx]

//@function Display an higher resolution representation of intersecting lines
//@param    source1      (float) source value 1
//@param    source2      (float) source value 2
//@param    css1         (color) color of source 1 line
//@param    css2         (color) color of source 2 line
//@param    intersec_css (color) color of intersection line
//@param    area_css     (color) color of box area
zoomIn(source1, source2, css1, css2, intersec_css, area_css)=>
    var source1_l  = line.new(na, na, na, na, color = css1) 
    var source2_l  = line.new(na, na, na, na, color = css2)
    var intersec_l = line.new(na, na, na, na)
    var cross_area = box.new(na, na, na, na, chart.fg_color) 
    
    n = bar_index

    //Find intersection value on crosses
    intersection_val = source1.crossValue(source2)

    //Draw new elements on crossing event
    if not na(intersection_val)
        //Get common scaling factor
        sf = commonScalingFactor(source1, source2, source1 - source1[1], source2 - source2[1])
        
        //Slopes run
        dx1 = int(resolution * (1 - sf))
        dx2 = int(resolution * sf)

        //Offset
        start = int(resolution * (1 - sf)) + offset

        //Coordinates
        l1y1 = source1 - (source1 - source1[1]) * dx1
        l1y2 = source1 + (source1 - source1[1]) * dx2

        l2y1 = source2 - (source2 - source2[1]) * dx1
        l2y2 = source2 + (source2 - source2[1]) * dx2

        //Set new lines coordinates
        source1_l.set_xy1(n - dx1 + start, l1y1) 
        source1_l.set_xy2(n + dx2 + start, l1y2)

        source2_l.set_xy1(n - dx1 + start, l2y1)
        source2_l.set_xy2(n + dx2 + start, l2y2)

        intersec_l.set_xy1(n - dx1 + start, intersection_val)
        intersec_l.set_xy2(n + dx2 + start, intersection_val)
        intersec_l.set_color(intersec_css)

        //Area
        cross_area.set_lefttop(n - dx1 + start, math.max(l1y1, l1y2, l2y1, l2y2))
        cross_area.set_rightbottom(n + dx2 + start, math.min(l1y1, l1y2, l2y1, l2y2))
        cross_area.set_bgcolor(area_css)
    else
        //Update coordinates
        x1 = source1_l.get_x1()
        x2 = source1_l.get_x2()

        source1_l.set_x1(x1 + 1)   , source1_l.set_x2(x2 + 1)
        source2_l.set_x1(x1 + 1)   , source2_l.set_x2(x2 + 1)
        intersec_l.set_x1(x1 + 1)  , intersec_l.set_x2(x2 + 1)
        cross_area.set_left(x1 + 1), cross_area.set_right(x2 + 1)

//----------------------------------------------------------------------------}
//Highlight crosses and intersection value
//----------------------------------------------------------------------------{
//Intersections drawing elements
var line  intersection_lvl = na 
var label intersection_lbl = na 
var box   intersection_box  = na

n = bar_index
source1 = sourceA.source(lenA, externalA)
source2 = sourceB.source(lenB, externalB)

//Find intersection value on crosses
intersection_val = source1.crossValue(source2)

var l1 = line.new(na,na,na,na)
var l2 = line.new(na,na,na,na)
var l3 = line.new(na,na,na,na)

//Highlight intersection information
if not na(intersection_val)

    //Get common scaling factor
    sf = commonScalingFactor(source1, source2, source1 - source1[1], source2 - source2[1])
    
    //Draw elements
    crossover = source1 > source2
    max = math.max(source1, source2, source1[1], source2[1])
    min = math.min(source1, source2, source1[1], source2[1])

    [lvl_, lbl_, bx_] = draw(intersection_val, sf, max, min
      , crossover
      , crossover ? coCss : cuCss
      , crossover ? coAreaCss : cuAreaCss)
    
    intersection_lvl := lvl_
    intersection_lbl := lbl_
    intersection_box := bx_

else
    //Extend
    if extend
        intersection_lvl.set_x2(n)
        intersection_lbl.set_x(int(math.avg(n, intersection_lvl.get_x1())))
        intersection_box.set_right(n)

//Zoom
if magnify
    zoomIn(source1, source2, #089981, #f23645
      , source1 > source2 ? coCss : cuCss
      , source1 > source2 ? coAreaCss : cuAreaCss)

//-----------------------------------------------------------------------------}
//Highlight SMA intersection matrix
//-----------------------------------------------------------------------------{
var table_position = dashLoc == 'Bottom Left' ? position.bottom_left 
  : dashLoc == 'Top Right' ? position.top_right 
  : position.bottom_right

var table_size = textSize == 'Tiny' ? size.tiny 
  : textSize == 'Small' ? size.small 
  : size.normal

//Declare array of sma values
sma_array = array.new<float>(0)

csum = ta.cum(close)

//Calculate SMA for periods from min_per to max_per
for i = minLen to maxLen
    ma = (csum - csum[i]) / i
    sma_array.push(ma)

//Get matrices
[ismt, sfmt] = intersectionMatrix(sma_array)

//Set SMA intersection matrix
if barstate.islast and showDash
    cols = ismt.columns()
    rows = ismt.rows()
    
    //Table
    tb = table.new(table_position, cols+2, rows+2
      , bgcolor = #1e222d
      , border_color = #373a46
      , border_width = 1
      , frame_color = #373a46
      , frame_width = 1)

    for i = 0 to rows-1
        //SMA periods
        tb.cell(0, i+1, str.tostring(minLen + i)
          , text_color = color.white
          , text_size = table_size)

        tb.cell(i+1, 0, str.tostring(minLen + i)
          , text_color = color.white
          , text_size = table_size)

        for j = 0 to cols-1
            //Set intersection value
            if not na(ismt.get(i, j))
                tb.cell(i+1, j+1, str.tostring(math.round_to_mintick(ismt.get(i, j)))
                  , text_color = color.white
                  , text_size = table_size
                  , tooltip = str.tostring(sfmt.get(i, j), '#.##'))
    
    //Dashboard title
    tb.cell(0, rows, 'SMA Intersection Matrix'
      , text_color = color.white
      , text_size = table_size)
    tb.merge_cells(0, rows, cols, rows)

//----------------------------------------------------------------------------}
//Plots
//----------------------------------------------------------------------------{
plot(source1, 'Source A', #089981)
plot(source2, 'Source B', #f23645)

//----------------------------------------------------------------------------}
//---------------------------------------------------------------------------------------------------------------------}
````
