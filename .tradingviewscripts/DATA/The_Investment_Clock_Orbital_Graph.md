<!-- tradingview-pine-id: PUB;5546852563404331bd01c318ac7f6848 -->
<!-- tradingviewscripts-format: 1 -->
# The Investment Clock Orbital Graph

Source: https://www.tradingview.com/script/ifjXxAlC-The-Investment-Clock-Orbital-Graph/

## Description

The Investment Clock Orbital Graph is an advanced visualization tool designed to help traders and investors track economic cycles using a dynamic scatter plot of GDP growth vs. CPI inflation rates.

This indicator is a fusion of two powerful TradingView indicators:

[*][LuxAlgo](https://www.tradingview.com/u/LuxAlgo/#search-scripts=relative%20strength)’s [Relative Strength Scatter Plot](https://www.tradingview.com/script/XZPlAujd-Relative-Strength-Scatter-Plot-LuxAlgo/) – A robust scatter plot for tracking relative strength.
[*][The Investment Clock](https://www.tradingview.com/script/RYvFEPHs-The-Investment-Clock/) Indicator – A cycle-based approach to market rotation. This indicator contains more information regarding The Investment Clock.

By combining these approaches, the Investment Clock Orbital Graph enables traders to visualize economic momentum and inflationary trends in a unique, orbital-style scatter plot.

Key Features & Improvements

[*]Orbital Graph Representation – Displays GDP growth and CPI inflation as a dynamic, evolving scatter plot, showing how the economy moves through different phases.
[*]Quadrant-Based Market Regimes – Identifies four key economic phases:
     1)🔥 Overheating (High Growth, High Inflation)
     2)📉 Stagflation (Low Growth, High Inflation)
     3)🤒 Recovery (High Growth, Low Inflation)
     4)🎈 Reflation (Low Growth, Low Inflation)
[*]Data-Driven Analysis – Utilizes FRED (Federal Reserve Economic Data) for accurate real-world GDP & CPI data.
[*]Trailing Path of Economic Evolution – Tracks historical economic cycles over time to show momentum and cyclical movements.
[*]Customizable Parameters – Set sustainable GDP growth and inflation thresholds, adjust trail length, and fine-tune scatter plot resolution.
[*]Auto-Labeled Quadrants & Revised Accurate Market Guidance – Each quadrant includes newly updated tooltips and annotations (like ETF suggestions) to help traders make informed decisions.
[*]Live Macro Forecasting Tool – Helps traders anticipate future market conditions, rate hikes/cuts, and sector rotations.

How to Use for Trading Decisions

The Investment Clock Orbital Graph helps traders and macro investors by identifying market phases and providing insights into asset class performance during different economic conditions.

📌 Step 1: Identify the Current Quadrant

[*]Locate the most recent point on the orbital graph to see if the economy is in Overheating, Stagflation, Recovery, or Reflation.

📌 Step 2: Forecast Market Trends

[*]The trajectory of the points can predict upcoming economic shifts:
[*]Overheating → Stagflation ➡️ Expect economic slowdowns, bearish stock markets.
[*]Stagflation → Reflation ➡️ Interest rate cuts likely, bonds and defensive stocks perform well.
[*]Reflation → Recovery ➡️ Risk-on rally, technology and cyclicals perform best.
[*]Recovery → Overheating ➡️ Commodities surge, inflation rises, and central banks intervene.

📌 Step 3: Align Trading & Investing Strategies

[*]🔥 Overheating – Favor commodities & energy (Oil, Industrial Stocks, Materials).
[*]📉 Stagflation – Favor defensive assets (Cash, Utilities, Healthcare).
[*]🤒 Recovery – Favor growth stocks (Technology, Consumer Discretionary).
[*]🎈 Reflation – Favor bonds, value stocks, and financials.

📌 Step 4: Monitor Trends Over Time

[*]The indicator visualizes economic movement over multiple months, allowing traders to confirm long-term trends vs. short-term noise.

The Investment Clock Orbital Graph is an essential macro trading tool, providing a real-time visualization of economic conditions. By tracking GDP growth vs. CPI inflation, traders and investors can align their portfolios with major macroeconomic shifts, predict sector rotations, and anticipate central bank policy changes.

---

## Source Code

````pine
// The Investment Clock: Orbital Graph Edition
// This indicator visualizes the relationship between GDP growth and CPI inflation rates over time, creating a dynamic orbital plot that shows the economy's position in different market cycles.
// Based on the Royal London Investment Clock framework:
// https://adviser.royallondon.com/investment/our-investment-options/governed-range/governed-portfolios/investment-clock/

// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Original Investment Clock by BarefootJoey
// https://www.tradingview.com/script/RYvFEPHs-The-Investment-Clock/
// Editor: © BarefootJoey

// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// Original Scatter plot aka orbital graph by LuxAlgo
// https://www.tradingview.com/script/XZPlAujd-Relative-Strength-Scatter-Plot-LuxAlgo/
// Author: © LuxAlgo

//@version=5
indicator("The Investment Clock Orbital Graph"
  , max_lines_count  = 500
  , max_bars_back    = 500
  , max_labels_count = 500)
  
// Input Groups for Organization
grg = "Growth"    // Group for GDP growth related inputs
gri = "Inflation" // Group for inflation related inputs

// GDP Growth Configuration
// -----------------------
// Default sustainable growth rate is 2.5% based on historical averages
sustainable = input.float(2.5, "Sustainable Growth", minval=0, group=grg)

// GDP data from FRED (Federal Reserve Economic Data)
i_input = input.symbol("GDPC1", title="Growth Ticker", group=grg, 
  tooltip="Uses FRED's Real GDP data (GDPC1). Chart timeframe/ticker should match 1M CPILFESL")
tickeri = request.security(i_input, "D", close)
// Calculate year-over-year GDP growth rate as percentage
tickero = (ta.change(tickeri,12) / tickeri[12]) *100

// Inflation Configuration
// ---------------------
// Default sustainable inflation rate is 3% based on common central bank targets
sustainable2 = input.float(3, "Sustainable Inflation", minval=0, group=gri)

// CPI data from FRED (Federal Reserve Economic Data)
i_input2 = input.symbol("CPILFESL", title="Inflation Ticker", group=gri, 
  tooltip="Uses FRED's Core CPI data (CPILFESL). Chart timeframe/ticker should match 1M CPILFESL")
tickeri2 = request.security(i_input2, "D", close)
// Calculate year-over-year CPI change as percentage
tickero2 = (ta.change(tickeri2,12) / tickeri2[12]) *100

// Visual Settings
// -------------
// Color settings for the orbital trail
plot_col = input.color(color.white, 'Investment Clock Plot Color'
  , inline = 'inline0')

// Graph Configuration
// -----------------
trail_len = input(24, 'Trail Length'
  , group = 'Graph Settings'
  , tooltip="Number of historical points to display in the orbital trail")

res = input(20., 'Scatter Plot Resolution'
  , group = 'Graph Settings'
  , tooltip="Controls the spacing between points. Higher values = more spread out")

// Initialize Data Structures
// ------------------------
// Matrices to store the lines and labels for the orbital trail
var lines_matrix = matrix.new<line>(0,0)   // Stores lines connecting points
var labels_matrix = matrix.new<label>(0,0) // Stores point labels and tooltips

// Create initial empty arrays for lines and labels
if barstate.isfirst
    for i = 0 to 4  // Only using first row currently, but matrix supports up to 5
        array_lines = array.new_line(0)
        array_labels = array.new_label(0)
        
        // Initialize arrays with placeholder objects
        for j = 0 to trail_len-1
            array.push(array_lines, line.new(na, na, na, na))
            
            // Create empty labels with dot symbol
            array.push(array_labels
              , label.new(na
              , na
              , text = '⊙'  // Dot symbol for data points
              , style = label.style_label_center
              , size = size.small
              , color = color.new(#2157f3, 100)))
        
        matrix.add_row(lines_matrix, i, array_lines)
        matrix.add_row(labels_matrix, i, array_labels)

// Helper Functions
// --------------
// Function to get latest GDP and CPI values
gdp_cpi()=>
    [tickero2, tickero]  // Returns [CPI, GDP] for plotting

// Function to create background boxes with labels and tooltips
box_lbl(left, top, right, bottom, lbl_x, lbl_y, lbl_style, css, txt, tooltip_text)=>
    // Create a box for the quadrant
    box.delete(box.new(left
          , top
          , right
          , bottom
          , border_color = na
          , bgcolor = color.new(css,90))[1])
    
    // Create a label for the quadrant name with tooltip
    label.delete(label.new(lbl_x
      , lbl_y
      , text = txt
      , style = lbl_style
      , textcolor = color.new(css,25)
      , color = color.new(#2157f3,100)
      , tooltip = tooltip_text)[1])

// Get Latest Data
// -------------
[sym_a_ratio, sym_a_mom] = gdp_cpi()

// Plot Construction
// --------------
n = bar_index  // Current bar position for plotting

// Create legend table
var tb = table.new(position.middle_right,1,5,frame_color=na)

// Add legend entry for GDP vs CPI plot
if barstate.isfirst
    table.cell(tb, 0, 0, '⊙ GDP vs CPI'
      , text_color = plot_col
      , text_halign = text.align_left)

// Main Plotting Logic
// ----------------
if barstate.islast
    max_loc = 0     // Tracks maximum x-axis deviation
    max_range = 0.  // Tracks maximum y-axis deviation
    
    cpi_yoy = 0.    // Current CPI value
    gdp_yoy = 0.    // Current GDP value
    color plot_css = na
    
    // Plot Historical Points
    // -------------------
    for i = 0 to 4  // Currently only using first row (i=0)
        float y1 = na  // Previous point's y coordinate
        int x1 = na    // Previous point's x coordinate
        
        // Plot each point in the trail
        for j = 0 to trail_len-1
            if i == 0
                cpi_yoy := sym_a_ratio[j] // Get CPI for x-axis
                gdp_yoy := sym_a_mom[j]   // Get GDP for y-axis
                
                // Calculate transparency based on point age
                // Newer points are more opaque (15%), older points more transparent (70%)
                transp = math.round(15 + (70 * j/trail_len))
                plot_css := color.new(plot_col, transp)
            else
                break
                
            // Calculate point position
            // Center x=0 at sustainable inflation level
            loc = math.round((cpi_yoy - sustainable2) * res)
            r = math.abs(gdp_yoy - sustainable)
            
            // Calculate actual coordinates
            x2 = n + loc
            y2 = gdp_yoy
            
            // Draw line connecting to previous point
            get_line = matrix.get(lines_matrix, i, j)
            line.set_xy1(get_line, x1, y1)
            line.set_xy2(get_line, x2, y2)
            line.set_color(get_line, plot_css)
            
            // Store current point as previous for next iteration
            x1 := x2
            y1 := y2
            
            // Update plot boundaries
            max_loc := math.max(math.abs(loc),max_loc)
            max_range := math.max(r,max_range)
            
            // Create Point Labels
            // ----------------
            // Format timestamp for tooltip
            point_time = str.format_time(time[j], "yyyy-MM-dd")
            
            // Determine which quadrant the point is in
            label_tooltip = cpi_yoy > sustainable2 and gdp_yoy>sustainable ? ' Overheating'
              : cpi_yoy>sustainable2 and gdp_yoy<sustainable ? ' Stagflation'
              : cpi_yoy<sustainable2 and gdp_yoy<sustainable ? ' Reflation'
              : cpi_yoy<sustainable2 and gdp_yoy>sustainable ? ' Recovery'
              : na
            
            // Update point label
            get_label = matrix.get(labels_matrix, i, j)
            label.set_xy(get_label, x2, y2)
            label.set_textcolor(get_label, plot_css)
            label.set_tooltip(get_label, str.tostring(j + 1) + label_tooltip + 
              "\nDate: " + point_time +
              "\nGDP: " + str.tostring(gdp_yoy, "#.####") + "%" +
              "\nCPI: " + str.tostring(cpi_yoy, "#.####") + "%")

    // Draw Quadrant Backgrounds and Labels
    // --------------------------------
    
    // Overheating Quadrant (High Growth, High Inflation)
    box_lbl(n
      , sustainable + max_range
      , n + max_loc + 10
      , sustainable
      , n + max_loc + 10
      , sustainable + max_range
      , label.style_label_left
      , color.orange
      , '🔥 Overheat ⛽'
      , "⬆️ High Inflation (>" + str.tostring(sustainable2, "#.##") + "%)\n💪 High Growth (>" + str.tostring(sustainable, "#.##") + "%)" + "\n🤞 Hold commodities, cyclical value, & industrials $IYJ \n🟢 Build oil & gas $IEO \n🔴 Fade info-tech $IYW & basic materials $IYM \n👀 See Rate Hikes 📈 \n👀 See Bearish Flattening yield curve \n🔮 Anticipate Stagflation or Recovery")
    
    // Stagflation Quadrant (Low Growth, High Inflation)
    box_lbl(n
      , sustainable
      , n + max_loc + 10
      , sustainable - max_range
      , n + max_loc + 10
      , sustainable - max_range
      , label.style_label_left
      , color.red
      , '📉 Stagflation 💰'
      , "⬆️ High Inflation (>" + str.tostring(sustainable2, "#.##") + "%)\n🥵 Low Growth (<" + str.tostring(sustainable, "#.##") + "%)" + "\n🤞 Hold cash, defensive value, & utilities $IDU \n🟢 Build pharmaceuticals $IHE & consumer staples $IYK \n🔴 Fade oil & gas $IEO \n🔮 Anticipate Reflation or Overheating")
    
    // Recovery Quadrant (High Growth, Low Inflation)
    box_lbl(n - max_loc - 10
      , sustainable + max_range
      , n
      , sustainable
      , n - max_loc - 10
      , sustainable + max_range
      , label.style_label_right
      , color.green
      , '🤒 Recovery 📈'
      , "⬇️ Low Inflation (<" + str.tostring(sustainable2, "#.##") + "%)\n💪 High Growth (>" + str.tostring(sustainable, "#.##") + "%)" + "\n🤞 Hold stocks, cyclical growth, & telecoms $IYZ \n🟢 Build info-tech $IYW & basic materials $IYM \n🔴 Fade consumer discretionary $IYC \n🔮 Anticipate Overheating or Reflation")
    
    // Reflation Quadrant (Low Growth, Low Inflation)
    box_lbl(n - max_loc - 10
      , sustainable
      , n
      , sustainable - max_range
      , n - max_loc - 10
      , sustainable - max_range
      , label.style_label_right
      , color.yellow
      , '🎈 Reflation 🎫'
      , "⬇️ Low Inflation (<" + str.tostring(sustainable2, "#.##") + "%)\n🥵 Low Growth (<" + str.tostring(sustainable, "#.##") + "%)" + "\n🤞 Hold bonds, defensive growth, & financials $IYF \n🟢 Build consumer discretionary $IYC \n🔴 Fade pharmaceuticals $IHE & consumer staples $IYK \n👀 See Rate Cuts 📉 \n👀 See Bullish Steepening yield curve \n🔮 Anticipate Recovery or Stagflation")
      
    // Add Axis Labels
    // ------------
    // Y-axis (Growth) label
    label.delete(label.new(n - max_loc - 10
      , sustainable
      , text = 'Growth'
      , style = label.style_label_right
      , textcolor = chart.fg_color
      , color = color.new(#2157f3,100)
      , tooltip = "Sustainable Rate: \nGrowth = " + str.tostring(sustainable, "#.##") + "%")[1])
    
    // X-axis (Inflation) label
    label.delete(label.new(n
      , sustainable - max_range
      , text = 'Inflation'
      , style = label.style_label_up
      , textcolor = chart.fg_color
      , color = color.new(#2157f3,100)
      , tooltip = "Sustainable Rate: \nInflation = " + str.tostring(sustainable2, "#.##") + "%")[1])

// Made with ❤ by @BarefootJoey ✌💗📈
````
