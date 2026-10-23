//+------------------------------------------------------------------+
//|                                      SmartFibonacci_Enhanced.mq5 |
//|                                         Copyright 2025, Enhanced |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 3
#property indicator_color1 DodgerBlue
#property indicator_color2 LimeGreen
#property indicator_color3 Gold

//--- Constants
#define MAX_HISTORY_RECORDS 4
#define FIBO_DATA_FIELDS 4
#define TEXT_POSITION_OFFSET 500
#define LINE_EXTEND_BARS 800

//--- Input parameters - Smart Fibonacci
input int SF_TimeFrame = 0;                 // Chart Period (0=current)
input int SF_ScanBars = 200;                // Bars for Wave Analysis
input double SF_MinDisplayLevel = -5.0;     // Minimum Level Threshold
input int SF_LinePattern = 0;               // Line Pattern Style
input bool SF_ShowLabels = true;            // Display Level Text
input string SF_TextFont = "Arial";         // Text Font Name
input int SF_TextHeight = 7;                // Text Height Size
input bool SF_UseBodyMode = false;          // Body-to-Body Mode (JPY)
input int SF_RetracementCount = 1;          // Retracement Display Count
input color SF_PrimaryColor = DarkGray;     // Primary Color Theme
input color SF_SecondaryColor = Lime;       // Secondary Color Theme
input color SF_TertiaryColor = HotPink;     // Tertiary Color Theme
input color SF_QuaternaryColor = Cyan;      // Quaternary Color Theme

//--- Input parameters - Wave Detection
input int WaveDetectionDepth = 5;           // Wave Detection Depth
input int WaveDeviationPips = 3;            // Wave Deviation Pips
input int WaveBackStep = 1;                 // Wave Back Step
input bool WaveLineVisible = false;         // Show Wave Detection Line

//--- Global variables
string SF_IndicatorName;
int SF_MaxRetracementCount;
bool validation_error_flag = false;
bool fetch_history_flag = false;
int detection_level = 3;

//--- Fibonacci levels configuration
const int TOTAL_FIBO_LEVELS = 23;
double RetracementRatios[23] = {
    0.0, 1.0, 0.114, 0.236, 0.382, 0.500, 0.618, 0.764, 0.886,
    1.272, 1.382, 1.618, 2.000, 2.618, 4.236, 4.618,
    -0.272, -0.382, -0.618, -1.0, -1.618, -3.236, -3.618
};

string RetracementLabels[23] = {
    "0.0", "100.0", "88.6", "76.4", "61.8", "50.0", "38.2", "23.6", "11.4",
    "127.2", "138.2", "161.8", "200.0", "261.8", "423.6", "461.8",
    "-27.2", "-38.2", "-61.8", "-100.0", "-161.8", "-323.6", "-361.8"
};

//--- Fibo history storage
double sf_retracement_colors[MAX_HISTORY_RECORDS];
double sf_retracement_history[MAX_HISTORY_RECORDS][FIBO_DATA_FIELDS];

//--- Indicator buffers
double WaveBuffer[];
double PeakMapBuffer[];
double TroughMapBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    SF_IndicatorName = MQLInfoString(MQL_PROGRAM_NAME);
    
    // Set buffers as series
    ArraySetAsSeries(WaveBuffer, true);
    ArraySetAsSeries(PeakMapBuffer, true);
    ArraySetAsSeries(TroughMapBuffer, true);
    
    // Assign buffers
    SetIndexBuffer(0, WaveBuffer);
    SetIndexBuffer(1, PeakMapBuffer);
    SetIndexBuffer(2, TroughMapBuffer);
    
    // Configure plot visibility
    PlotIndexSetInteger(0, PLOT_DRAW_TYPE, WaveLineVisible ? DRAW_SECTION : DRAW_NONE);
    PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
    PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
    
    PlotIndexSetString(0, PLOT_LABEL, "SF_WaveDetection");
    
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
    PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
    PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);
    
    // Initialize Fibo settings
    SF_MaxRetracementCount = MathMin(SF_RetracementCount, MAX_HISTORY_RECORDS);
    
    ArrayInitialize(sf_retracement_history, 0.0);
    
    sf_retracement_colors[0] = SF_PrimaryColor;
    sf_retracement_colors[1] = SF_SecondaryColor;
    sf_retracement_colors[2] = SF_TertiaryColor;
    sf_retracement_colors[3] = SF_QuaternaryColor;
    
    IndicatorSetString(INDICATOR_SHORTNAME, 
        SF_IndicatorName + "(" + IntegerToString(SF_TimeFrame) + "," + 
        IntegerToString(WaveDetectionDepth) + "," + 
        IntegerToString(WaveDeviationPips) + "," + 
        IntegerToString(WaveBackStep) + ")");
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    // Skip if no new data
    if(rates_total < WaveDetectionDepth)
        return(0);
    
    // Validate timeframe setting
    if(SF_TimeFrame != 0)
    {
        if(SF_TimeFrame < Period())
        {
            if(!validation_error_flag)
            {
                Alert("SmartFibonacci: SF_TimeFrame must be >= current chart period!");
                validation_error_flag = true;
            }
            return(0);
        }
        else if(SF_TimeFrame > Period())
        {
            validation_error_flag = false;
            // Call indicator on higher timeframe
            iCustom(NULL, ConvertTimeFrame(SF_TimeFrame), SF_IndicatorName,
                    SF_TimeFrame, SF_ScanBars, SF_MinDisplayLevel,
                    SF_LinePattern, SF_ShowLabels, SF_TextFont, SF_TextHeight,
                    SF_UseBodyMode, SF_RetracementCount,
                    SF_PrimaryColor, SF_SecondaryColor, SF_TertiaryColor, SF_QuaternaryColor,
                    WaveDetectionDepth, WaveDeviationPips, WaveBackStep, WaveLineVisible);
            return(rates_total);
        }
    }
    
    validation_error_flag = false;
    
    // Calculate Wave Detection
    ComputeWaveDetection(rates_total, prev_calculated, high, low, time);
    
    // Draw Fibonacci levels
    RenderSmartFibonacci(time);
    
    return(rates_total);
}

//+------------------------------------------------------------------+
//| Calculate Wave Detection indicator                               |
//+------------------------------------------------------------------+
void ComputeWaveDetection(const int rates_total, 
                          const int prev_calculated,
                          const double &high[],
                          const double &low[],
                          const datetime &time[])
{
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(time, true);
    
    int calc_limit, wave_counter = 0, search_direction = 0;
    int last_peak_pos = 0, last_trough_pos = 0;
    double test_value, result_value;
    double current_trough = 0, current_peak = 0, previous_peak = 0, previous_trough = 0;
    
    // Determine calculation range
    if(prev_calculated == 0)
    {
        ArrayInitialize(WaveBuffer, 0.0);
        ArrayInitialize(PeakMapBuffer, 0.0);
        ArrayInitialize(TroughMapBuffer, 0.0);
        calc_limit = rates_total - WaveDetectionDepth;
        fetch_history_flag = true;
    }
    else
    {
        // Incremental calculation - only recalculate recent bars
        calc_limit = rates_total - prev_calculated + WaveDetectionDepth + 1;
        
        // Find last state
        int idx = 0;
        while(wave_counter < detection_level && idx < 100)
        {
            result_value = WaveBuffer[idx];
            if(result_value != 0) wave_counter++;
            idx++;
        }
        idx--;
        
        if(idx < calc_limit) calc_limit = idx;
        
        // Restore state
        if(TroughMapBuffer[idx] != 0)
        {
            current_trough = TroughMapBuffer[idx];
            search_direction = 1;
        }
        else if(PeakMapBuffer[idx] != 0)
        {
            current_peak = PeakMapBuffer[idx];
            search_direction = -1;
        }
        
        // Clear buffers in calculation range
        for(int j = calc_limit - 1; j >= 0; j--)
        {
            WaveBuffer[j] = 0.0;
            TroughMapBuffer[j] = 0.0;
            PeakMapBuffer[j] = 0.0;
        }
    }
    
    // Find extremums
    for(int shift = calc_limit; shift >= 0; shift--)
    {
        // Find local minimum
        test_value = low[ArrayMinimum(low, shift, WaveDetectionDepth)];
        if(test_value == previous_trough)
            test_value = 0.0;
        else
        {
            previous_trough = test_value;
            if((low[shift] - test_value) > (WaveDeviationPips * _Point))
                test_value = 0.0;
            else
            {
                for(int back = 1; back <= WaveBackStep; back++)
                {
                    result_value = TroughMapBuffer[shift + back];
                    if((result_value != 0) && (result_value > test_value))
                        TroughMapBuffer[shift + back] = 0.0;
                }
            }
        }
        TroughMapBuffer[shift] = (low[shift] == test_value) ? test_value : 0.0;
        
        // Find local maximum
        test_value = high[ArrayMaximum(high, shift, WaveDetectionDepth)];
        if(test_value == previous_peak)
            test_value = 0.0;
        else
        {
            previous_peak = test_value;
            if((test_value - high[shift]) > (WaveDeviationPips * _Point))
                test_value = 0.0;
            else
            {
                for(int back = 1; back <= WaveBackStep; back++)
                {
                    result_value = PeakMapBuffer[shift + back];
                    if((result_value != 0) && (result_value < test_value))
                        PeakMapBuffer[shift + back] = 0.0;
                }
            }
        }
        PeakMapBuffer[shift] = (high[shift] == test_value) ? test_value : 0.0;
    }
    
    // Build final Wave line
    if(search_direction == 0)
    {
        previous_trough = 0;
        previous_peak = 0;
    }
    else
    {
        previous_trough = current_trough;
        previous_peak = current_peak;
    }
    
    for(int shift = calc_limit; shift >= 0; shift--)
    {
        switch(search_direction)
        {
            case 0: // Look for first peak or valley
                if(previous_trough == 0 && previous_peak == 0)
                {
                    if(PeakMapBuffer[shift] != 0)
                    {
                        previous_peak = high[shift];
                        last_peak_pos = shift;
                        search_direction = -1;
                        WaveBuffer[shift] = previous_peak;
                    }
                    if(TroughMapBuffer[shift] != 0)
                    {
                        previous_trough = low[shift];
                        last_trough_pos = shift;
                        search_direction = 1;
                        WaveBuffer[shift] = previous_trough;
                    }
                }
                break;
                
            case 1: // Look for peak
                if(TroughMapBuffer[shift] != 0 && TroughMapBuffer[shift] < previous_trough && 
                   PeakMapBuffer[shift] == 0 && last_trough_pos > 0)
                {
                    WaveBuffer[last_trough_pos] = 0.0;
                    last_trough_pos = shift;
                    previous_trough = TroughMapBuffer[shift];
                    WaveBuffer[shift] = previous_trough;
                }
                if(PeakMapBuffer[shift] != 0 && TroughMapBuffer[shift] == 0)
                {
                    previous_peak = PeakMapBuffer[shift];
                    last_peak_pos = shift;
                    WaveBuffer[shift] = previous_peak;
                    search_direction = -1;
                }
                break;
                
            case -1: // Look for valley
                if(PeakMapBuffer[shift] != 0 && PeakMapBuffer[shift] > previous_peak && 
                   TroughMapBuffer[shift] == 0 && last_peak_pos > 0)
                {
                    WaveBuffer[last_peak_pos] = 0.0;
                    last_peak_pos = shift;
                    previous_peak = PeakMapBuffer[shift];
                    WaveBuffer[shift] = previous_peak;
                }
                if(TroughMapBuffer[shift] != 0 && PeakMapBuffer[shift] == 0)
                {
                    previous_trough = TroughMapBuffer[shift];
                    last_trough_pos = shift;
                    WaveBuffer[shift] = previous_trough;
                    search_direction = 1;
                }
                break;
        }
    }
}

//+------------------------------------------------------------------+
//| Draw Fibonacci retracements automatically                         |
//+------------------------------------------------------------------+
void RenderSmartFibonacci(const datetime &time[])
{
    ArraySetAsSeries(time, true);
    
    double wave_points[4];
    int wave_positions[4];
    ArrayInitialize(wave_points, 0);
    ArrayInitialize(wave_positions, 0);
    
    // Find last 4 Wave points
    int points_found = 0;
    for(int i = 0; i < SF_ScanBars && points_found < 4; i++)
    {
        if(WaveBuffer[i] != 0.0)
        {
            wave_points[points_found] = WaveBuffer[i];
            wave_positions[points_found] = i;
            points_found++;
        }
    }
    
    if(points_found < 4)
        return; // Not enough Wave points
    
    // Determine Fibonacci parameters based on pattern
    bool create_new_retracement = false;
    datetime start_time = 0, end_time = 0;
    double start_price = 0, end_price = 0;
    
    // Pattern 1: Uptrend continuation
    if(wave_points[3] < wave_points[2] && wave_points[1] < wave_points[2] && 
       wave_points[3] <= wave_points[1] && wave_points[1] < wave_points[0])
    {
        if(SF_UseBodyMode)
        {
            double body_low, body_high;
            ExtractBodyPrices(wave_positions[3], wave_positions[2], body_low, body_high);
            start_price = body_low;
            end_price = body_high;
        }
        else
        {
            start_price = wave_points[3];
            end_price = wave_points[2];
        }
        start_time = time[wave_positions[3]];
        end_time = time[wave_positions[2]];
        create_new_retracement = true;
    }
    // Pattern 2: Downtrend continuation
    else if(wave_points[3] > wave_points[2] && wave_points[1] > wave_points[2] && 
            wave_points[3] >= wave_points[1] && wave_points[1] > wave_points[0])
    {
        if(SF_UseBodyMode)
        {
            double body_low, body_high;
            ExtractBodyPrices(wave_positions[2], wave_positions[3], body_low, body_high);
            start_price = body_high;
            end_price = body_low;
        }
        else
        {
            start_price = wave_points[3];
            end_price = wave_points[2];
        }
        start_time = time[wave_positions[3]];
        end_time = time[wave_positions[2]];
        create_new_retracement = true;
    }
    // Pattern 3: Recent upswing
    else if(wave_points[3] < wave_points[2] && wave_points[1] < wave_points[3] && 
            wave_points[0] > wave_points[1])
    {
        if(SF_UseBodyMode)
        {
            double body_low, body_high;
            ExtractBodyPrices(wave_positions[1], wave_positions[2], body_low, body_high);
            start_price = body_low;
            end_price = body_high;
        }
        else
        {
            start_price = wave_points[1];
            end_price = wave_points[2];
        }
        start_time = time[wave_positions[1]];
        end_time = time[wave_positions[2]];
        create_new_retracement = true;
    }
    // Pattern 4: Recent downswing
    else if(wave_points[3] > wave_points[2] && wave_points[1] > wave_points[3] && 
            wave_points[0] < wave_points[1])
    {
        if(SF_UseBodyMode)
        {
            double body_low, body_high;
            ExtractBodyPrices(wave_positions[2], wave_positions[1], body_low, body_high);
            start_price = body_high;
            end_price = body_low;
        }
        else
        {
            start_price = wave_points[1];
            end_price = wave_points[2];
        }
        start_time = time[wave_positions[1]];
        end_time = time[wave_positions[2]];
        create_new_retracement = true;
    }
    
    // Update Retracement history if new pattern detected
    if(create_new_retracement && (start_time != (datetime)sf_retracement_history[0][0] || 
                                   end_time != (datetime)sf_retracement_history[0][2]))
    {
        // Shift history
        for(int i = SF_MaxRetracementCount - 1; i > 0; i--)
        {
            for(int j = 0; j < FIBO_DATA_FIELDS; j++)
            {
                sf_retracement_history[i][j] = sf_retracement_history[i-1][j];
            }
        }
        
        // Store new Retracement
        sf_retracement_history[0][0] = (double)start_time;
        sf_retracement_history[0][1] = start_price;
        sf_retracement_history[0][2] = (double)end_time;
        sf_retracement_history[0][3] = end_price;
    }
    
    // Draw all Fibonacci retracements
    RemoveOldRetracements();
    for(int i = 0; i < SF_MaxRetracementCount && sf_retracement_history[i][0] > 0; i++)
    {
        RenderRetracementLevels((datetime)sf_retracement_history[i][0], 
                                sf_retracement_history[i][1],
                                (datetime)sf_retracement_history[i][2], 
                                sf_retracement_history[i][3],
                                (color)sf_retracement_colors[i], i, time);
    }
}

//+------------------------------------------------------------------+
//| Get body prices for Body Mode                                    |
//+------------------------------------------------------------------+
void ExtractBodyPrices(int pos1, int pos2, double &body_low, double &body_high)
{
    double open_array1[], close_array1[], open_array2[], close_array2[];
    ArraySetAsSeries(open_array1, true);
    ArraySetAsSeries(close_array1, true);
    ArraySetAsSeries(open_array2, true);
    ArraySetAsSeries(close_array2, true);
    
    CopyOpen(_Symbol, _Period, 0, pos1 + 1, open_array1);
    CopyClose(_Symbol, _Period, 0, pos1 + 1, close_array1);
    CopyOpen(_Symbol, _Period, 0, pos2 + 1, open_array2);
    CopyClose(_Symbol, _Period, 0, pos2 + 1, close_array2);
    
    body_low = close_array1[pos1];
    if(open_array1[pos1] < close_array1[pos1])
        body_low = open_array1[pos1];
    
    body_high = close_array2[pos2];
    if(open_array2[pos2] > close_array2[pos2])
        body_high = open_array2[pos2];
}

//+------------------------------------------------------------------+
//| Draw Fibonacci levels                                            |
//+------------------------------------------------------------------+
void RenderRetracementLevels(datetime start_time, double start_price, 
                             datetime end_time, double end_price,
                             color theme_color, int retracement_id, 
                             const datetime &time[])
{
    ArraySetAsSeries(time, true);
    
    double price_range = end_price - start_price;
    datetime extension_time = time[0] + LINE_EXTEND_BARS * PeriodSeconds();
    
    // Draw base line
    DrawTrendLine(start_time, start_price, end_time, end_price, theme_color, retracement_id);
    
    // Draw level lines
    for(int i = 0; i < TOTAL_FIBO_LEVELS; i++)
    {
        if(RetracementRatios[i] >= SF_MinDisplayLevel)
        {
            double level_price = start_price + RetracementRatios[i] * price_range;
            DrawHorizontalLevel(start_time, extension_time, level_price, 
                                RetracementLabels[i], theme_color, retracement_id, i, time);
        }
    }
}

//+------------------------------------------------------------------+
//| Draw base trend line                                             |
//+------------------------------------------------------------------+
void DrawTrendLine(datetime start_time, double start_price, 
                   datetime end_time, double end_price,
                   color line_color, int retracement_id)
{
    string object_name = StringFormat("SFIB_Trend%d_%d_%d_%d_%d",
                                      retracement_id, SF_TimeFrame, WaveDetectionDepth, 
                                      WaveDeviationPips, WaveBackStep);
    
    if(ObjectFind(0, object_name) >= 0)
        ObjectDelete(0, object_name);
    
    ObjectCreate(0, object_name, OBJ_TREND, 0, start_time, start_price, end_time, end_price);
    ObjectSetInteger(0, object_name, OBJPROP_COLOR, line_color);
    ObjectSetInteger(0, object_name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, object_name, OBJPROP_RAY_RIGHT, false);
    ObjectSetInteger(0, object_name, OBJPROP_BACK, true);
}

//+------------------------------------------------------------------+
//| Draw single Fibonacci level line                                 |
//+------------------------------------------------------------------+
void DrawHorizontalLevel(datetime start_time, datetime extension_time, 
                         double level_price, string level_label, color line_color,
                         int retracement_id, int level_index, const datetime &time[])
{
    ArraySetAsSeries(time, true);
    
    string line_object = StringFormat("SFIB_Level%d_%d_%s_%.5f",
                                      retracement_id, level_index, level_label, level_price);
    string text_object = StringFormat("SFIB_Text%d_%d_%s",
                                      retracement_id, level_index, level_label);
    
    // Draw line
    if(ObjectFind(0, line_object) >= 0)
        ObjectDelete(0, line_object);
    
    ObjectCreate(0, line_object, OBJ_TREND, 0, start_time, level_price, extension_time, level_price);
    ObjectSetInteger(0, line_object, OBJPROP_STYLE, SF_LinePattern);
    ObjectSetInteger(0, line_object, OBJPROP_COLOR, line_color);
    ObjectSetInteger(0, line_object, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, line_object, OBJPROP_RAY_RIGHT, false);
    ObjectSetInteger(0, line_object, OBJPROP_BACK, true);
    
    // Draw label
    if(SF_ShowLabels)
    {
        if(ObjectFind(0, text_object) >= 0)
            ObjectDelete(0, text_object);
        
        datetime text_time = time[0] + TEXT_POSITION_OFFSET * PeriodSeconds();
        ObjectCreate(0, text_object, OBJ_TEXT, 0, text_time, level_price);
        ObjectSetString(0, text_object, OBJPROP_TEXT, 
                       level_label + " - " + DoubleToString(level_price, _Digits));
        ObjectSetInteger(0, text_object, OBJPROP_FONTSIZE, SF_TextHeight);
        ObjectSetString(0, text_object, OBJPROP_FONT, SF_TextFont);
        ObjectSetInteger(0, text_object, OBJPROP_COLOR, line_color);
    }
}

//+------------------------------------------------------------------+
//| Delete old Fibonacci objects                                     |
//+------------------------------------------------------------------+
void RemoveOldRetracements()
{
    ObjectsDeleteAll(0, "SFIB", 0, OBJ_TREND);
    ObjectsDeleteAll(0, "SFIB", 0, OBJ_TEXT);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    RemoveOldRetracements();
    Comment("");
}

//+------------------------------------------------------------------+
//| Migrate old timeframe values to ENUM_TIMEFRAMES                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES ConvertTimeFrame(int tf)
{
    switch(tf)
    {
        case 0: return PERIOD_CURRENT;
        case 1: return PERIOD_M1;
        case 5: return PERIOD_M5;
        case 15: return PERIOD_M15;
        case 30: return PERIOD_M30;
        case 60: return PERIOD_H1;
        case 240: return PERIOD_H4;
        case 1440: return PERIOD_D1;
        case 10080: return PERIOD_W1;
        case 43200: return PERIOD_MN1;
        case 2: return PERIOD_M2;
        case 3: return PERIOD_M3;
        case 4: return PERIOD_M4;
        case 6: return PERIOD_M6;
        case 10: return PERIOD_M10;
        case 12: return PERIOD_M12;
        case 16385: return PERIOD_H1;
        case 16386: return PERIOD_H2;
        case 16387: return PERIOD_H3;
        case 16388: return PERIOD_H4;
        case 16390: return PERIOD_H6;
        case 16392: return PERIOD_H8;
        case 16396: return PERIOD_H12;
        case 16408: return PERIOD_D1;
        case 32769: return PERIOD_W1;
        case 49153: return PERIOD_MN1;
        default: return PERIOD_CURRENT;
    }
}
//+------------------------------------------------------------------+