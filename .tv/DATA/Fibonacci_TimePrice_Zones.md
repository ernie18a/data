<!-- tradingview-pine-id: PUB;b479566fb5794c7ca3b8158bacb6f5b7 -->
<!-- tradingviewscripts-format: 1 -->
# Fibonacci Time-Price Zones

Source: https://www.tradingview.com/script/1NHVL40I-Fibonacci-Time-Price-Zones/

## Description

🟩 Fibonacci Time-Price Zones is a chart visualization tool that combines Fibonacci ratios with time-based and price-based geometry to analyze market behavior. Unlike typical Fibonacci indicators that focus solely on horizontal price levels, this indicator incorporates time into the analysis, providing a more dynamic perspective on price action. 

The indicator offers multiple ways to visualize Fibonacci relationships. Drawing segmented circles creates a unique perspective on price action by incorporating time into the analysis. These segmented circles, similar to TradingView's built-in Fibonacci Circles, are derived from Fibonacci time and price levels, allowing traders to identify potential turning points based on the dynamic interaction between price and time.

As another distinct visualization method, the indicator incorporates orthogonal patterns, created by the intersection of horizontal and vertical Fibonacci levels. These intersections form L-shaped connections on the chart, derived from key Fibonacci price and time intervals, highlighting potential areas of support or resistance at specific points in time.

In addition to these geometric approaches, another option is sloped lines, which project Fibonacci levels that account for both time and price along the trendline. These projections derive their angles from the interplay between Fibonacci price levels and Fibonacci time intervals, creating dynamic zones on the chart. The slope of these lines reflects the direction and angle of the trend, providing a visual representation of price alignment with market direction, while maintaining the time-price relationship unique to this indicator

The indicator also includes horizontal Fibonacci levels similar to traditional retracement and extension tools. However, unlike standard tools, traders can display retracement levels, extension levels, or both simultaneously from a single instance of the indicator. These horizontal levels maintain consistency with the chosen visualization method, automatically scaling and adapting whether used with circles, orthogonal patterns, or slope-based analysis.

By combining these distinct methods—circles, orthogonal patterns, sloped projections, and horizontal levels—the indicator provides a comprehensive approach to Fibonacci analysis based on both time and price relationships. Each visualization method offers a unique perspective on market structure while maintaining the core principle of time-price interaction.

⭕ THEORY AND CONCEPT ⭕

While traditional Fibonacci tools excel at identifying potential support and resistance levels through price-based ratios (0.236, 0.382, 0.618), they do not incorporate the dimension of time in market analysis. Extensions and retracements effectively measure price relationships within trends, yet markets move through both price and time dimensions simultaneously.

Fibonacci circles represent an evolution in technical analysis by incorporating time intervals alongside price levels. Based on the mathematical principle that markets often move in circular patterns proportional to Fibonacci ratios, these circles project potential support and resistance zones as partial circles radiating from significant price points. However, traditional circle-based tools can create visual complexity that obscures key market relationships. The integration of time into Fibonacci analysis reveals how price movements often respect both temporal and price-based ratios, suggesting a deeper geometric structure to market behavior.

The Fibonacci Time-Price Zones indicator advances these concepts by providing multiple geometric approaches to visualize time-price relationships. Each shape option—circles, orthogonal patterns, slopes, and horizontal levels—represents a different mathematical perspective on how Fibonacci ratios manifest across both dimensions. This multi-faceted approach allows traders to observe how price responds to Fibonacci-based zones that account for both time and price movements, potentially revealing market structure that purely price-based tools might miss.

Shape Options

The indicator employs four distinct geometric approaches to analyze Fibonacci relationships across time and price dimensions:

[*]Circular: [image]https://www.tradingview.com/x/Jg9SWpgK/[/image]Represents the cyclical nature of market movements through partial circles, where each radius is scaled by Fibonacci ratios incorporating both time and price components. This geometry suggests market movements may follow proportional circular paths from significant pivot points, reflecting the harmonic relationship between time and price.  

[*]Orthogonal:[image]https://www.tradingview.com/x/tXaRLrvy/[/image]Constructs L-shaped patterns that separate the time and price components of Fibonacci relationships. The horizontal component represents price levels, while the vertical component measures time intervals, allowing analysis of how these dimensions interact independently at key market points. 

[*]Sloped: [image]https://www.tradingview.com/x/ujdYOLjb/[/image]Projects Fibonacci levels along the prevailing trend, incorporating both time and price in the angle of projection. This approach suggests that support and resistance levels may maintain their relationship to price while adjusting to the temporal flow of the market. 

[*]Horizontal: [image]https://www.tradingview.com/x/XVJVgEqY/[/image]Provides traditional static Fibonacci levels that serve as a reference point for comparing price-only analysis with the dynamic time-price relationships shown in the other three shapes. This baseline approach allows traders to evaluate how the incorporation of time dimension enhances or modifies traditional Fibonacci analysis. 

By combining these geometric approaches, the Fibonacci Time-Price Zones indicator creates a comprehensive analytical framework that bridges traditional and advanced Fibonacci analysis. The horizontal levels serve as familiar reference points, while the dynamic elements—circular, orthogonal, and sloped projections—reveal how price action responds to temporal relationships. This multi-dimensional approach enables traders to study market structure through various geometric lenses, providing deeper insights into time-price symmetry within technical analysis. Whether applied to retracements, extensions, or trend analysis, the indicator offers a structured methodology for understanding how markets move through both price and time dimensions.

🛠️ CONFIGURATION AND SETTINGS 🛠️

The Fibonacci Time-Price Zones indicator offers a range of configurable settings to tailor its functionality and visual representation to your specific analysis needs. These options allow you to customize zone visibility, structures, horizontal lines, and other features.

Important Note: The indicator's calculations are anchored to user-defined start and end points on the chart. When switching between charts with significantly different price scales (e.g., from Bitcoin at $100,000 to Silver at $30), adjustment of these anchor points is required to ensure correct positioning of the Fibonacci elements.

Fibonacci Levels  
[image]https://www.tradingview.com/x/q2DNDHoE/[/image]
The indicator allows users to customize Fibonacci levels for both retracement and extension analysis. Each level can be individually configured with the following options:
[*]Visibility: Toggle the visibility of each level to focus on specific areas of interest.
[*]Level Value: Set the Fibonacci ratio for the level, such as 0.618 or 1.000, to align with your analysis needs.
[*]Color: Customize the color of each level for better visual clarity.
[*]Line Thickness: Adjust the line thickness to emphasize critical levels or maintain a cleaner chart.

Setup
[image]https://www.tradingview.com/x/sYTm54Ou/[/image]
[*]Zone Type: Select which Fibonacci zones to display:
   - Retracement: Shows potential pull back levels within the trend
   - Extension: Projects levels beyond the trend for potential continuation targets
   - Both: Displays both retracement and extension zones simultaneously

[*]Shape: Choose from four visualization methods:
   - Circular: Time-price based semicircles centered on point B
   - Orthogonal: L-shaped patterns combining time and price levels
   - Sloped: Trend-aligned projections of Fibonacci levels
   - Horizontal: Traditional horizontal Fibonacci levels

Visual Settings
[image]https://www.tradingview.com/x/qQ437M8t/[/image]
[*]Fill %: Adjusts the fill intensity of zones:
0%: No fill between levels
100%: Maximum fill between levels

[*]Lines:
Trendline: The base A-B trend with customizable color
Extension: B-C projection line
Retracement: B-D pullback line

[*]Labels:
Points: Show/hide A, B, C, D markers
Levels: Show/hide Fibonacci percentages

Time-Price Points
Set the time and price for the points that define the Fibonacci zones and horizontal levels. These points are defined upon loading the chart. These points can be configured directly in the settings or adjusted interactively on the live chart.

[*]A and B Points: These user-defined time and price points determine the basis for calculating the semicircles and Fibonacci levels. While the settings panel displays their exact values for fine-tuning, the easiest way to modify these points is by dragging them directly on the chart for quick adjustments.
[*]Interactive Adjustments: Any changes made to the points on the chart will automatically synchronize with the settings panel, ensuring consistency and precision.

🖼️ CHART EXAMPLES 🖼️

[image]https://www.tradingview.com/x/BqGslFKH/[/image]
Fibonacci Time-Price Zones using the 'Circular' Shape option. Note the price interaction at the 0.786 level, which acts as a support zone. Additional points of interest include resistance near the 0.618 level and consolidation around the 0.5 level, highlighting the utility of both horizontal and semicircular Fibonacci projections in identifying key price areas.

[image]https://www.tradingview.com/x/AkqajQXM/[/image]
Fibonacci Time-Price Zones using the 'Sloped' Shape option. The chart displays price retracing along the sloped Fibonacci levels, with blue arrows highlighting potential support zones at 0.618 and 0.786, and a red arrow indicating potential resistance at the 1.0 level. This visual representation aligns with the prevailing downtrend, suggesting potential selling pressure at the 1.0 Fibonacci level.

[image]https://www.tradingview.com/x/WmD5iihD/[/image]
Fibonacci Time-Price Zones using the 'Orthogonal' Shape option. The chart demonstrates price action interacting with vertical zones created by the orthogonal lines at the 0.618, 0.786, and 1.0 Fibonacci levels. Blue arrows highlight potential support areas, while red arrows indicate potential resistance areas, revealing how the orthogonal lines can identify distinct points of price interaction.

[image]https://www.tradingview.com/x/WXuy0HYT/[/image]
Fibonacci Time-Price Zones using the 'Circular' Shape option. The chart displays price action in relation to segmented circles emanating from the starting point (point A). The circles represent different Fibonacci ratios (0.382, 0.5, 0.618, 0.786) and their intersections with the price axis create potential zones of support and resistance. This approach offers a visually distinct way to analyze potential turning points based on both price and time.

[image]https://www.tradingview.com/x/zbCqlAe9/[/image]
Fibonacci Time-Price Zones using the 'Sloped' Shape option. The sloped Fibonacci levels (0.786, 0.618, 0.5) create zones of potential support and resistance, with price finding clear interaction within these areas. The ellipses highlight this price action, particularly the support between 0.786 and 0.618, which aligns closely with the trend.

[image]https://www.tradingview.com/x/bRp0yBmZ/[/image]
Fibonacci Time-Price Zones using the 'Circular' Shape option. The price action appears to be ‘hugging’ the 0.5 Fibonacci level, suggesting potential resistance. This demonstrates how the circular zones can identify potential turning points and areas of consolidation which might not be seen with linear analysis.

[image]https://www.tradingview.com/x/z1mdwhCo/[/image]
Fibonacci Time-Price Zones using the 'Sloped' Shape option with Point D marker enabled. The chart demonstrates clear price action closely following along the sloped Retracement line until the orthogonal intersection at the 0.618 levels where the trend is broken and price dips throughout the 0.618 to 0.786 horizontal zone. Price jumps back to the retracement slope at the start of the 0.786 horizontal zone and continues to the 1.0 horizontal zone. The aqua-colored retracement line is enabled to further emphasize this retracement slope.

[image]https://www.tradingview.com/x/fvLWj1w6/[/image]  
Geometric validation using TradingView's built-in Fibonacci Circle tool (overlaid). The alignment at the 0.5 and 1.0 levels demonstrates the indicator's consistent approximation of Fibonacci Circles.

[image]https://www.tradingview.com/x/o68xMQov/[/image]  
Comparison of Fibonacci Time-Price Zones (Shape: Horizontal) with TradingView's Built-in Retracement and Extension Tools (overlaid): This example demonstrates how the Horizontal structure aligns with TradingView’s retracement and extension levels, allowing users to integrate multiple tools seamlessly. The Fibonacci circle connects retracement and extension zones, highlighting the potential relationship between past retracements and future extensions.

📐 GEOMETRIC FOUNDATIONS 📐

This indicator integrates circular and straight representations of Fibonacci levels, specifically the Circular, Orthogonal, Sloped, and Horizontal shape options. The geometric principles behind these shapes differ significantly, requiring distinct scaling methods for accurate representation. The Circular shape employs logarithmic scaling with radial expansion, where the distance from a central point determines the level's position, creating partial circles that align with TradingView's built-in Fibonacci Circle tool. The other three shapes utilize geometric progression scaling for linear extension from a starting point, resulting in straight lines that align with TradingView's built-in Fibonacci retracement and extension tools. Due to these distinct geometric foundations and scaling methods, perfectly aligning both the partial circles and straight lines simultaneously is mathematically constrained, though any differences are typically visually imperceptible.

The Circular shape's partial circles are calculated and scaled to align with TradingView's built-in Fibonacci Circles. These circles are plotted from the second swing point onward. This approach ensures consistent and accurate visualization across all market types, including those with gaps or closed sessions, which unlike 24/7 markets, do not have a direct one-to-one correspondence between bar indices and time. To maintain accurate geometric proportions across varying chart scales, the indicator calculates an aspect ratio by normalizing the proportional difference between vertical (price) and horizontal (time) distances of the swing points. This normalization factor ensures geometric shapes maintain their mathematical properties regardless of price scale magnitude or time period span, while maintaining the correct proportions of the geometric constructions at any chart zoom level.

The indicator automatically applies the appropriate scaling factor based on the selected shape option, optimizing either circular proportions and proper radius calculations for each Fibonacci level, or straight-line relationships between Fibonacci levels. These distinct scaling approaches maintain mathematical integrity while preserving the essential characteristics of each geometric representation, ensuring optimal visualization accuracy whether using circular or linear shapes.

⚠️ DISCLAIMER ⚠️

The Fibonacci Time-Price Zones indicator is a visual analysis tool designed to illustrate Fibonacci relationships through geometric constructions incorporating both curved and straight lines, providing a structured framework for identifying potential areas of price interaction. It is not intended as a predictive or standalone trading signal indicator.

The indicator calculates levels and projections using user-defined anchor points and Fibonacci ratios. While it aims to align with TradingView’s Fibonacci extension, retracement, and circle tools by employing mathematical and geometric formulas, no guarantee is made that its calculations are identical to TradingView's proprietary methods.

Like all technical and visual indicators, these visual representations may visually align with key price zones in hindsight, reflecting observed price dynamics. However, these visualizations are not standalone signals for trading decisions and should be interpreted as part of a broader analytical approach.

This indicator is intended for educational and analytical purposes, complementing other tools and methods of market analysis. Users are encouraged to integrate it into a comprehensive trading strategy, customizing its settings to suit their specific needs and market conditions.

🧠 BEYOND THE CODE 🧠

The Fibonacci Time-Price Zones indicator is designed to encourage both education and community engagement. By integrating time-sensitive geometry with Fibonacci-based frameworks, it bridges traditional grid-based analysis with dynamic time-price relationships. The inclusion of semicircles, horizontal levels, orthogonal structures, and sloped trends provides users with versatile tools to explore the interaction between price movements and temporal intervals while maintaining clarity and adaptability.

As an open-source tool, the indicator invites exploration, experimentation, and customization. Whether used as a standalone resource or alongside other technical strategies, it serves as a practical and educational framework for understanding market structure and Fibonacci relationships in greater depth.

Your feedback and contributions are essential to refining and enhancing the Fibonacci Time-Price Zones indicator. We look forward to the creative applications, adaptations, and insights this tool inspires within the trading community.

---

## Source Code

````pine
//@version=6
indicator('Fibonacci Time-Price Zones',  shorttitle='Fib Time-Price [xxattaxx]', overlay=true)   

// ===========================  TOOLTIPS  ===========================

ttLev    = "Fibonacci Levels: Configures this Fibonacci level. \n" +
         " ■ Toggle visibility, set the level value, customize the color, and adjust line thickness."
ttPoint  = "A-B-C-D Points: Toggles the visibility of the labels for A, B, and C points on the chart. \n" +
         " ■ A and B are user-defined time and price points. \n" +" ■ C is the calculated end point of the Trend Extension. \n" +
         " ■ D is the calculated end point of the Trend Retracement."
ttRetr   = "Retrace: Visibility of the trend retracement line connecting B-D. \n"
ttFill   = "Fill %: Adjusts the transparency of the fill area. \n" + " ■ 0% is fully transparent \n ■ 100% is fully opaque.\n" 
ttTrend  = "Trendline: Toggles the visibility of the trend line connecting points A and B. \n" +
         " ■ Extension: Toggles the visibility of the trend extension line connecting B-C. \n" +
         " ■ Retracement: Toggles the visibility of the trend retracement line connecting B-D."
ttLabel  = "Labels: Toggles the visibility of the Fibonacci level labels."
ttZone   = "ZoneType: Toggles the visibility of the Upper, Lower, or Both Fibonacci segments. \n" 
ttShape  = "Shape: Selects the structure of Fibonacci plots. \n" +
         " ■ Circular: Represents Fibonacci levels as arcs that incorporate both time and price dimensions. \n" +
         " ■ Orthogonal: Displays L-shaped patterns combining horizontal and vertical components to reflect time and price relationships. \n" +
         " ■ Slope: Aligns Fibonacci levels along the trend line, emphasizing trend direction and momentum. \n" +
         " ■ Horizontal: Traditional horizontal lines for Fibonacci levels, focusing solely on price-based relationships. \n\n"
ttA      = 'Exact Start Time/Price Point' 
ttC      = 'Exact End Time/Price Point'

// ===========================  INPUTS  ===========================

gL              = 'Show            '  +  'Level                  '  + 'Color            '  +  'Linewidth'
isEnabled0      = input.bool    (true,                          '',           group=gL,         inline='Level0')
levelValue0     = input.float   (0.236,                         '',           group=gL,         inline='Level0')
levelColor0     = input.color   (color.new(#87CEEB, 30),        '',           group=gL,         inline='Level0')
levelThick0     = input.string  ('▬▬▬',        title =          '',           group=gL,         inline='Level0',
                                 options=['────', '▬▬▬', '▄▄▄▄'],                                                tooltip=ttLev)
isEnabled1      = input.bool    (true,                         '',            group=gL,         inline='Level1')
levelValue1     = input.float   (0.382,                         '',           group=gL,         inline='Level1')
levelColor1     = input.color   (color.new(#4682B4, 30),        '',           group=gL,         inline='Level1')
levelThick1     = input.string  ('▬▬▬',        title =          '',           group=gL,         inline='Level1',
                                 options=['────', '▬▬▬', '▄▄▄▄'],                                                tooltip=ttLev)
isEnabled2      = input.bool    (true,                          '',           group=gL,         inline='Level2')
levelValue2     = input.float   (0.500,                         '',           group=gL,         inline='Level2')
levelColor2     = input.color   (color.new(#32CD32, 30),        '',           group=gL,         inline='Level2')
levelThick2     = input.string  ('▬▬▬',        title =          '',           group=gL,         inline='Level2',
                                 options=['────', '▬▬▬', '▄▄▄▄'],                                                tooltip=ttLev)
isEnabled3      = input.bool    (true,                         '' ,           group=gL,         inline='Level3')
levelValue3     = input.float   (0.618,                         '',           group=gL,         inline='Level3')
levelColor3     = input.color   (color.new(#FFEB3B, 30),        '',           group=gL,         inline='Level3')
levelThick3     = input.string  ('▬▬▬',        title =          '',           group=gL,         inline='Level3',
                                 options=['────', '▬▬▬', '▄▄▄▄'],                                                tooltip=ttLev)
isEnabled4      = input.bool    (true,                         '' ,           group=gL,         inline='Level4')
levelValue4     = input.float   (0.786,                         '',           group=gL,         inline='Level4')
levelColor4     = input.color   (color.new(#FF8C00, 30),        '',           group=gL,         inline='Level4')
levelThick4     = input.string  ('▬▬▬',        title =          '',           group=gL,         inline='Level4',
                                 options=['────', '▬▬▬', '▄▄▄▄'],                                                tooltip=ttLev)
isEnabled5      = input.bool    (true,                          '',           group=gL,         inline='Level5')
levelValue5     = input.float   (1.000,                         '',           group=gL,         inline='Level5')
levelColor5     = input.color   (color.new(#8B0000, 30),        '',           group=gL,         inline='Level5')
levelThick5     = input.string  ('▬▬▬',        title =          '',           group=gL,         inline='Level5',
                                 options=['────', '▬▬▬', '▄▄▄▄'],                                                tooltip=ttLev)
isEnabled6      = input.bool    (false,                         '',           group=gL,         inline='Level6')
levelValue6     = input.float   (1.236,                         '',           group=gL,         inline='Level6')
levelColor6     = input.color   (color.new(#6A5ACD, 30),        '',           group=gL,         inline='Level6')
levelThick6     = input.string  ('▬▬▬',        title =          '',           group=gL,         inline='Level6',
                                 options=['────', '▬▬▬', '▄▄▄▄'],                                                tooltip=ttLev)

gS              = 'Setup'
ZoneType        = input.string  ('Retracement', 'Zone Type',                  group=gS,         inline='s1',
                                 options=['Retracement','Extension','Both'],                                     tooltip=ttZone)   

Shape           = input.string   ('Circular',  'Shape      ',                 group=gS,         inline='s3',     
                                 options=['Circular', 'Orthogonal ',
                                 'Slope', 'Horizontal' ],                                                        tooltip=ttShape)

gV              = 'Visual Settings'
fillT           = input.float   (15, 'Fill %  ', maxval=100, minval=0,        group=gV,          inline='v1',    tooltip=ttFill)
ShowTrend       = input.bool    (true,   'Trendline     ',                    group=gV,          inline='t1',    tooltip=ttTrend)
colTrend        = input.color   (color.new(color.aqua, 75), '',               group=gV,          inline='t1',    tooltip=ttTrend)
ShowExtend      = input.bool    (false,  'Extension     ',                    group=gV,          inline='t2',    tooltip=ttTrend)
colExtend       = input.color   (color.new(color.blue, 75), '',               group=gV,          inline='t2',    tooltip=ttTrend)
ShowRetrace     = input.bool    (false,  'Retracement',                       group=gV,          inline='t3',    tooltip=ttTrend)
colRetrace      = input.color   (color.new(color.blue, 75), '',               group=gV,          inline='t3',    tooltip=ttTrend)

gLab            = 'Labels'
ShowA           = input.bool    (true,  'A ',                                 group=gLab,        inline='p1',    tooltip=ttPoint)
ShowB           = input.bool    (true,  'B ',                                 group=gLab,        inline='p1',    tooltip=ttPoint)
ShowC           = input.bool    (false, 'C ',                                 group=gLab,        inline='p1',    tooltip=ttPoint)
ShowD           = input.bool    (false, 'D ',                                 group=gLab,        inline='p1',    tooltip=ttPoint)
ShowLabels      = input.bool    (true, 'Fib Levels',                          group=gLab,        inline='l1',    tooltip=ttLabel)

TP              = 'Time/Price'  
A_Time_         = input.time    (timestamp('2024-08-12'), '', confirm=true,   group=TP,          inline='B')
A_Price_        = input.price   (0, '', confirm=true,                         group=TP,          inline='B',     tooltip=ttA)
B_Time_         = input.time    (timestamp('2024-08-12'), '', confirm=true,   group=TP,          inline='C')
B_Price_        = input.price   (0, '', confirm=true,                         group=TP,          inline='C',     tooltip=ttC)


// ===========================  VARIABLES  ===========================

// Ensure A_Time is less than B_Time, otherwise swap values
A_Price        = A_Time_ > B_Time_ ? B_Price_ : A_Price_
A_Time         = A_Time_ > B_Time_ ? B_Time_  : A_Time_
B_Price        = A_Time_ > B_Time_ ? A_Price_ : B_Price_
B_Time         = A_Time_ > B_Time_ ? A_Time_  : B_Time_

// Assign Time/Bar Index Variables
float A             = A_Price
float B             = B_Price
var int A_Index     = na  
var int B_Index     = na  
var int C_Index     = na  
var int D_Index     = na  
var float C_Price   = na  
var float D_Price   = na  

if na(A_Index) and time == A_Time
    A_Index         := bar_index 

if na(B_Index) and time == B_Time
    B_Index         := bar_index  
    AB_IndexDiff    =  B_Index - A_Index
    AB_PriceDiff    =  B_Price - A_Price
    C_Index         := B_Index  + AB_IndexDiff
    D_Index         := B_Index  + AB_IndexDiff
    C_Price         := B_Price  + AB_PriceDiff
    D_Price         := B_Price  - AB_PriceDiff

After_A             = time >= A_Time
After_B             = time >= B_Time
Setup               = After_A and not After_B
InRange             = After_A and bar_index <= C_Index

// Assign Trend Direction Variables and Segment Fill
var int Trend       =  A_Price < B_Price ? 1 : -1
bool U              = ZoneType == 'Both' or (Trend == 1 and ZoneType == 'Extension')   or (Trend == -1 and ZoneType == 'Retracement')
bool L              = ZoneType == 'Both' or (Trend == 1 and ZoneType == 'Retracement') or (Trend == -1 and ZoneType == 'Extension')
T                   =  100-fillT
Fill                =  fillT > 0  and After_A

// Initializes arrays to store the radii, upper boundaries, and lower boundaries of circles for each level.
var float[] upperArray      =  array.new_float(7)
var float[] lowerArray      =  array.new_float(7)
var float[] upperInitial    =  array.new_float(7)
var float[] lowerInitial    =  array.new_float(7)

// Arrays for storing Fibonacci level configurations
EnablArray          = array.from (isEnabled0,  isEnabled1,  isEnabled2,  isEnabled3,  isEnabled4,  isEnabled5,  isEnabled6)
LevlArray           = array.from (levelValue0, levelValue1, levelValue2, levelValue3, levelValue4, levelValue5, levelValue6)
ColorArray          = array.from (levelColor0, levelColor1, levelColor2, levelColor3, levelColor4, levelColor5, levelColor6)
ThickArray          = array.from (levelThick0, levelThick1, levelThick2, levelThick3, levelThick4, levelThick5, levelThick6)


// ===========================  FUNCTIONS  ===========================

f_lw(weight) => 
    weight  == '────'?   1  :  weight == '▬▬▬'?    2  :   weight == '▄▄▄▄'?   3  :  1

f_fib_radius    (base_radius, scale_factor, fib_level) => base_radius * fib_level * scale_factor

f_calc_y_values(radius, adj_x, start_price, end_price, aspect_ratio) =>
    x_center            = (B_Index - A_Index) * aspect_ratio  
    y_offset_sq         = radius * radius - math.pow(adj_x - x_center, 2)
    y_offset            = y_offset_sq >= 0 ? math.sqrt(y_offset_sq) : na
    y_center            = B_Price
    y_upper             = not na(y_offset)? y_center + y_offset : na
    y_lower             = not na(y_offset)? y_center - y_offset : na
    [y_upper, y_lower]

f_calc_fib(start_price, end_price, fib_level, trend, scale_factor) =>   
    price_diff          = end_price - start_price
    offset              = price_diff * math.sqrt(2) * scale_factor * fib_level
    upper_fib           = trend == 1?  end_price + offset : end_price - offset
    lower_fib           = trend == 1?  end_price - offset : end_price + offset
    [upper_fib, lower_fib]

f_slope_line(start_index, start_price, slope, index_input) =>
    delta_index         = (index_input - start_index)  
    slope_adj_price     = start_price + (slope * delta_index)                     
    slope_adj_price

f_text_box(boxtext, col, y_upper, y_lower) =>
    var box text_upper  = na
    var box text_lower  = na
    var bool created    = false
    if not created and (not na(y_lower)  or not na(y_upper))
        box.new(bar_index, y_upper, bar_index, y_upper, xloc=xloc.bar_index, border_width=0, 
                     text=boxtext, text_color=col, text_size=size.normal, text_halign=text.align_right)
        box.new(bar_index, y_lower, bar_index, y_lower, xloc=xloc.bar_index, border_width=0, 
                     text=boxtext, text_color=col, text_size=size.normal, text_halign=text.align_right)
        created := true
    if na(text_lower) 
        text_lower := box.new(bar_index, y_lower, bar_index, y_lower, xloc=xloc.bar_index, border_width=0, text=' ' + boxtext,
                     text_color=col, text_size=size.normal, text_halign=text.align_left, text_valign= text.align_top)
    if na(text_upper)
        text_upper := box.new(bar_index, y_upper, bar_index, y_upper, xloc=xloc.bar_index, border_width=0, text=' ' + boxtext,
                     text_color=col, text_size=size.normal, text_halign=text.align_left, text_valign= text.align_bottom) 
    if not na(y_lower) 
        box.set_right   (text_lower, bar_index)
        box.set_left    (text_lower, bar_index)
        box.set_top     (text_lower, y_lower)
        box.set_bottom  (text_lower, y_lower)
    if not na(y_upper)
        box.set_right   (text_upper, bar_index)
        box.set_left    (text_upper, bar_index)
        box.set_top     (text_upper, y_upper)
        box.set_bottom  (text_upper, y_upper)
    if na(y_upper) and na(y_lower) and not na(text_upper) and not na(text_lower)
        var EndBox = box.new(bar_index, B_Price, bar_index, B_Price, xloc=xloc.bar_index, border_width=0, 
                     text_valign= text.align_center, text=boxtext, text_color=col, text_size=size.normal, text_halign=text.align_left)
        box.delete(text_upper)
        box.delete(text_lower)
    [text_upper, text_lower]


// ===========================  MAIN CODE  ===========================

// Calculate slope and circle parameters
scale_factor =  Shape=='Circular'? math.log(2) : math.sqrt(2) / 2
float Slope                 =  na(A_Index) or na(B_Index) ? na : (B_Price - A_Price) / (B_Index - A_Index)  
s_line                      =  f_slope_line(A_Index, A_Price,  Slope,  bar_index)
r_line                      =  f_slope_line(B_Index, B_Price, -Slope,  bar_index)

var float radius            =  na
var float aspect_ratio      =  na
if  time == B_Time
    radius                  := 0
    aspect_ratio            := 0
    delta_price             =  B_Price - A_Price
    delta_index             =  B_Index - A_Index
    aspect_ratio            := nz(delta_index != 0 ? delta_price / delta_index : 0)
    float adj_delta         =  delta_index * aspect_ratio
    radius                  := math.sqrt(adj_delta * adj_delta + delta_price * delta_price)
    
float adj_x                 =  (bar_index - A_Index) * aspect_ratio

// Initialize the Fibonacci levels for the first time when A_Time is reached.
if time == A_Time
    for [i, level] in LevlArray
        isEnabled = array.get(EnablArray, i)

        if isEnabled
            // Calculate the initial Fibonacci levels using the scaled function
            [initialUpper, initialLower] = f_calc_fib(A_Price, B_Price, level, Trend, scale_factor)

            // Assign values to the initial arrays
            array.set(upperInitial, i, initialUpper)
            array.set(lowerInitial, i, initialLower)
        else
            // Assign 'na' for disabled levels
            array.set(upperInitial, i, na)
            array.set(lowerInitial, i, na)

// After A_Time, calculate the radii, upper boundaries, and lower boundaries of the circles for each enabled level.
if After_A
    for [i, level] in LevlArray
        isEnabled = array.get(EnablArray, i)
        if isEnabled  // Only perform calculations if level is enabled
            //level_radius  = f_fib_radius(radius, scale_factor, level)
            level_radius  = f_fib_radius(radius, scale_factor, level)
            aspect_radius = math.abs(math.round(level_radius / aspect_ratio))
            initial_upper = array.get(upperInitial, i)
            initial_lower = array.get(lowerInitial, i)
            inRadius      = bar_index <= aspect_radius + B_Index
            
            if Setup 
                upperValue = array.get(upperInitial, i)
                lowerValue = array.get(lowerInitial, i)
                array.set(upperArray, i, upperValue)
                array.set(lowerArray, i, lowerValue)
            else
                [upperCir, lowerCir] = f_calc_y_values(level_radius, adj_x, A_Price, B_Price, aspect_ratio)
                upperLin    = Shape == "Horizontal" or Shape == 'Orthogonal ' and inRadius?  initial_upper : na
                lowerLin    = Shape == "Horizontal" or Shape == 'Orthogonal ' and inRadius?  initial_lower : na
                upperSlope  = inRadius ?  f_slope_line(B_Index, initial_upper, Trend * -Slope,  bar_index) : na
                lowerSlope  = inRadius ?  f_slope_line(B_Index, initial_lower, Trend * Slope,   bar_index) : na
                upperValue  = Shape == 'Circular' ? upperCir : Shape != "Slope"? upperLin : upperSlope  
                lowerValue  = Shape == 'Circular' ? lowerCir : Shape != "Slope"? lowerLin : lowerSlope
                
                array.set(upperArray, i, upperValue)
                array.set(lowerArray, i, lowerValue)

                // Draw horizontal connecting line, only for 'Orthogonal ' type
                if (bar_index >= aspect_radius + B_Index and bar_index-1 < aspect_radius + B_Index) and Shape != 'Circular'
                    line_color = array.get(ColorArray, i)
                    lw         = f_lw(array.get(ThickArray, i))
                    DrawUpper  = Trend == 1 and ZoneType != 'Retracement' or Trend == -1 and ZoneType != 'Extension'
                    DrawLower  = Trend == 1 and ZoneType != 'Extension'   or Trend == -1 and ZoneType != 'Retracement'
                    if DrawUpper and Shape == 'Orthogonal '
                        line.new(bar_index, upperValue, bar_index, B_Price, xloc=xloc.bar_index, color=line_color,
                         width=lw, style=line.style_solid)
                    if DrawLower and Shape == 'Orthogonal '
                        line.new(bar_index, lowerValue, bar_index, B_Price, xloc=xloc.bar_index, color=line_color,
                         width=lw, style=line.style_solid)
        else
            array.set(upperArray, i, na)
            array.set(lowerArray, i, na)

    f_text_box(ShowLabels and isEnabled0?str.tostring(levelValue0):'', levelColor0, U?array.get(upperArray, 0):na, L?array.get(lowerArray, 0):na)   
    f_text_box(ShowLabels and isEnabled1?str.tostring(levelValue1):'', levelColor1, U?array.get(upperArray, 1):na, L?array.get(lowerArray, 1):na)
    f_text_box(ShowLabels and isEnabled2?str.tostring(levelValue2):'', levelColor2, U?array.get(upperArray, 2):na, L?array.get(lowerArray, 2):na)
    f_text_box(ShowLabels and isEnabled3?str.tostring(levelValue3):'', levelColor3, U?array.get(upperArray, 3):na, L?array.get(lowerArray, 3):na)
    f_text_box(ShowLabels and isEnabled4?str.tostring(levelValue4):'', levelColor4, U?array.get(upperArray, 4):na, L?array.get(lowerArray, 4):na)
    f_text_box(ShowLabels and isEnabled5?str.tostring(levelValue5):'', levelColor5, U?array.get(upperArray, 5):na, L?array.get(lowerArray, 5):na)
    f_text_box(ShowLabels and isEnabled6?str.tostring(levelValue6):'', levelColor6, U?array.get(upperArray, 6):na, L?array.get(lowerArray, 6):na)

// Plots the circles for each enabled level, then applies the fill
Mid_U    =  U? na : B_Price
Mid_L    =  L? na : B_Price
P0_Upper = plot(isEnabled0 and U and After_A? array.get(upperArray, 0) : Mid_U, 'Level 0 Upper', color=U?levelColor0:na, linewidth=f_lw(levelThick0))
P1_Upper = plot(isEnabled1 and U and After_A? array.get(upperArray, 1) : Mid_U, 'Level 1 Upper', color=U?levelColor1:na, linewidth=f_lw(levelThick1))
P2_Upper = plot(isEnabled2 and U and After_A? array.get(upperArray, 2) : Mid_U, 'Level 2 Upper', color=U?levelColor2:na, linewidth=f_lw(levelThick2))
P3_Upper = plot(isEnabled3 and U and After_A? array.get(upperArray, 3) : Mid_U, 'Level 3 Upper', color=U?levelColor3:na, linewidth=f_lw(levelThick3))
P4_Upper = plot(isEnabled4 and U and After_A? array.get(upperArray, 4) : Mid_U, 'Level 4 Upper', color=U?levelColor4:na, linewidth=f_lw(levelThick4))
P5_Upper = plot(isEnabled5 and U and After_A? array.get(upperArray, 5) : Mid_U, 'Level 5 Upper', color=U?levelColor5:na, linewidth=f_lw(levelThick5))
P6_Upper = plot(isEnabled6 and U and After_A? array.get(upperArray, 6) : Mid_U, 'Level 6 Upper', color=U?levelColor6:na, linewidth=f_lw(levelThick6))
P0_Mid   = plot(After_A? B_Price : na,                                          'B Price',       color=color.new(color.aqua, 100))
P0_Lower = plot(isEnabled0 and L and After_A? array.get(lowerArray, 0) : Mid_L, 'Level 0 Lower', color=L?levelColor0:na, linewidth=f_lw(levelThick0))
P1_Lower = plot(isEnabled1 and L and After_A? array.get(lowerArray, 1) : Mid_L, 'Level 1 Lower', color=L?levelColor1:na, linewidth=f_lw(levelThick1))
P2_Lower = plot(isEnabled2 and L and After_A? array.get(lowerArray, 2) : Mid_L, 'Level 2 Lower', color=L?levelColor2:na, linewidth=f_lw(levelThick2))
P3_Lower = plot(isEnabled3 and L and After_A? array.get(lowerArray, 3) : Mid_L, 'Level 3 Lower', color=L?levelColor3:na, linewidth=f_lw(levelThick3))
P4_Lower = plot(isEnabled4 and L and After_A? array.get(lowerArray, 4) : Mid_L, 'Level 4 Lower', color=L?levelColor4:na, linewidth=f_lw(levelThick4))
P5_Lower = plot(isEnabled5 and L and After_A? array.get(lowerArray, 5) : Mid_L, 'Level 5 Lower', color=L?levelColor5:na, linewidth=f_lw(levelThick5))
P6_Lower = plot(isEnabled6 and L and After_A? array.get(lowerArray, 6) : Mid_L, 'Level 6 Lower', color=L?levelColor6:na, linewidth=f_lw(levelThick6))

fill (P6_Upper, P6_Lower, color = Fill and na(array.get(upperArray,5)) ?     color.new(array.get(ColorArray, 6), T): na)
fill (P5_Upper, P5_Lower, color = Fill and na(array.get(upperArray,4)) ?     color.new(array.get(ColorArray, 5), T): na)
fill (P4_Upper, P4_Lower, color = Fill and na(array.get(upperArray,3)) ?     color.new(array.get(ColorArray, 4), T): na)
fill (P3_Upper, P3_Lower, color = Fill and na(array.get(upperArray,2)) ?     color.new(array.get(ColorArray, 3), T): na)
fill (P2_Upper, P2_Lower, color = Fill and na(array.get(upperArray,1)) ?     color.new(array.get(ColorArray, 2), T): na)
fill (P1_Upper, P1_Lower, color = Fill and na(array.get(upperArray,0)) ?     color.new(array.get(ColorArray, 1), T): na)
fill (P0_Upper, P0_Lower, color = Fill and na(array.get(upperArray,0)) ?     color.new(array.get(ColorArray, 0), T): na)
fill (P0_Upper, P1_Upper, color = Fill and not na(array.get(upperArray,1)) ? color.new(array.get(ColorArray, 1), T): na)
fill (P1_Upper, P2_Upper, color = Fill and not na(array.get(upperArray,2)) ? color.new(array.get(ColorArray, 2), T): na)
fill (P2_Upper, P3_Upper, color = Fill and not na(array.get(upperArray,3)) ? color.new(array.get(ColorArray, 3), T): na)
fill (P3_Upper, P4_Upper, color = Fill and not na(array.get(upperArray,4)) ? color.new(array.get(ColorArray, 4), T): na)
fill (P4_Upper, P5_Upper, color = Fill and not na(array.get(upperArray,5)) ? color.new(array.get(ColorArray, 5), T): na)
fill (P5_Upper, P6_Upper, color = Fill and not na(array.get(upperArray,6)) ? color.new(array.get(ColorArray, 6), T): na)
fill (P0_Lower, P1_Lower, color = Fill and not na(array.get(lowerArray,1)) ? color.new(array.get(ColorArray, 1), T): na)
fill (P1_Lower, P2_Lower, color = Fill and not na(array.get(lowerArray,2)) ? color.new(array.get(ColorArray, 2), T): na)
fill (P2_Lower, P3_Lower, color = Fill and not na(array.get(lowerArray,3)) ? color.new(array.get(ColorArray, 3), T): na)
fill (P3_Lower, P4_Lower, color = Fill and not na(array.get(lowerArray,4)) ? color.new(array.get(ColorArray, 4), T): na)
fill (P4_Lower, P5_Lower, color = Fill and not na(array.get(lowerArray,5)) ? color.new(array.get(ColorArray, 5), T): na)
fill (P5_Lower, P6_Lower, color = Fill and not na(array.get(lowerArray,6)) ? color.new(array.get(ColorArray, 6), T): na)

// Calculates the upper and lower boundaries of the fill area based on the slope line and the circles.
float UpperValue        =  na,      float LowerValue        =  na
float ExtenLine         =  na,      float RetraceLine       =  na

if After_B and Trend == 1
    UpperValue          := math.min(array.max(upperArray, 0), math.max(s_line, r_line))
    LowerValue          := math.max(array.min(lowerArray, 0), math.min(s_line, r_line))
    ExtenLine           := na(UpperValue) or not(ShowExtend)?  na : s_line
    RetraceLine         := na(LowerValue) or not(ShowRetrace)? na : r_line

if After_B and Trend == -1
    UpperValue          := math.max(array.max(upperArray, 0), math.max(s_line, r_line))
    LowerValue          := math.min(array.min(lowerArray, 0), math.min(s_line, r_line))
    ExtenLine           := na(LowerValue) or not(ShowExtend)?  na : s_line
    RetraceLine         := na(UpperValue) or not(ShowRetrace)? na : r_line

// Draws the Trend Setup line and plots the Extension and Retracement lines.
if time == B_Time and ShowTrend
    line.new(A_Time, A_Price, B_Time, B_Price, xloc=xloc.bar_time,
     width=4, color=color.new(color.aqua, 60), extend=extend.none, style=line.style_dotted)

plot(ShowExtend  and bar_index % 10 == 0 and InRange? ExtenLine   : na, 'Slope Line',   color=colExtend,  linewidth=2, style=plot.style_circles)
plot(ShowRetrace and bar_index % 10 == 0 and InRange? RetraceLine : na, 'Retrace Line', color=colRetrace, linewidth=2, style=plot.style_circles)

// Labels for Points A, B, C, and D
if time == A_Time and ShowA
    box.new(A_Time,A_Price,A_Time,A_Price, xloc=xloc.bar_time, border_width=0, text_valign= text.align_center,
         border_color=na, text='A', text_color=color.new(color.aqua,0), text_size=size.large, text_halign=text.align_center)
if time == B_Time and ShowB
    box.new(B_Time,B_Price,B_Time,B_Price, xloc=xloc.bar_time, border_width=0, text_valign= text.align_center,
         border_color=na, text='B', text_color=color.new(color.aqua,0), text_size=size.large, text_halign=text.align_center)
if bar_index == C_Index and ShowC
    box.new(C_Index,C_Price,C_Index,C_Price, xloc=xloc.bar_index, border_width=0, text_valign= text.align_center,
         border_color=na, text='C', text_color=color.new(color.aqua,0), text_size=size.large, text_halign=text.align_center)
if bar_index == D_Index and ShowD
    box.new(D_Index,D_Price,D_Index,D_Price, xloc=xloc.bar_index, border_width=0, text_valign= text.align_center,
         border_color=na, text='D', text_color=color.new(color.aqua,0), text_size=size.large, text_halign=text.align_center)
````
