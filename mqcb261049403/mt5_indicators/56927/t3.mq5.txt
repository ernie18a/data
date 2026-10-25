//+------------------------------------------------------------------+
//|                      T3 Indicator for MQL5                       |
//|              Copyright © 2025 Salman Soltaniyan                  |
//|                                                                  |
//|                                                                  |
//| MIT License                                                      |
//|                                                                  |
//| Copyright (c) 2025 Salman Soltaniyan                             |
//|                                                                  |
//| Permission is hereby granted, free of charge, to any person      |
//| obtaining a copy of this software and associated documentation   |
//| files (the "Software"), to deal in the Software without          |
//| restriction, including without limitation the rights to use,     |
//| copy, modify, merge, publish, distribute, sublicense, and/or     |
//| sell copies of the Software, and to permit persons to whom the   |
//| Software is furnished to do so, subject to the following         |
//| conditions:                                                      |
//|                                                                  |
//| The above copyright notice and this permission notice shall be   |
//| included in all copies or substantial portions of the Software.  |
//|                                                                  |
//| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,  |
//| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES  |
//| OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND         |
//| NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT      |
//| HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,     |
//| WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     |
//| FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR    |
//| OTHER DEALINGS IN THE SOFTWARE.                                  |
//+------------------------------------------------------------------+

// Display the indicator in the main chart window instead of a separate window
#property indicator_chart_window

// Define the number of indicator buffers and plots
#property indicator_buffers 1  // One buffer to store the T3 values
#property indicator_plots   1  // One visual representation on the chart

//--- plot configuration for the T3 line
#property indicator_label1  "t3"        // Label for the T3 line
#property indicator_type1   DRAW_LINE   // Display as a continuous line
#property indicator_color1  clrRed      // Red color for the T3 line
#property indicator_style1  STYLE_SOLID // Solid line style (not dotted or dashed)
#property indicator_width1  1           // Line width of 1 pixel

// Input Parameters that can be adjusted in the indicator settings
input int T3_Length = 12;     // Period length for the T3 calculation (default: 12)
input double T3_Factor = 0.7; // Volume factor for the T3 calculation (default: 0.7)

// Indicator Buffer to store the calculated T3 values
double T3Buffer[];

// Handles for the six cascaded EMA calculations needed for T3
int hEMA1, hEMA2, hEMA3, hEMA4, hEMA5, hEMA6;

//+------------------------------------------------------------------+
//| Custom Indicator Initialization Function                        |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialize the cascaded EMA calculations
    // Each EMA takes the output of the previous EMA as input
    hEMA1 = iMA(Symbol(), PERIOD_CURRENT, T3_Length, 0, MODE_EMA, PRICE_CLOSE); // First EMA uses close price
    hEMA2 = iMA(Symbol(), PERIOD_CURRENT, T3_Length, 0, MODE_EMA, hEMA1);       // Second EMA uses first EMA output
    hEMA3 = iMA(Symbol(), PERIOD_CURRENT, T3_Length, 0, MODE_EMA, hEMA2);       // Third EMA uses second EMA output
    hEMA4 = iMA(Symbol(), PERIOD_CURRENT, T3_Length, 0, MODE_EMA, hEMA3);       // Fourth EMA uses third EMA output
    hEMA5 = iMA(Symbol(), PERIOD_CURRENT, T3_Length, 0, MODE_EMA, hEMA4);       // Fifth EMA uses fourth EMA output
    hEMA6 = iMA(Symbol(), PERIOD_CURRENT, T3_Length, 0, MODE_EMA, hEMA5);       // Sixth EMA uses fifth EMA output
    
    // Set up the indicator buffer
    SetIndexBuffer(0, T3Buffer);         // Assign the T3Buffer to the first indicator buffer
    ArraySetAsSeries(T3Buffer, true);    // Set the array as time-descending (newest values at lower indices)
    
    // Set the indicator name that appears on the chart
    IndicatorSetString(INDICATOR_SHORTNAME,"T3 Indicator" );
    
    return INIT_SUCCEEDED;  // Return successful initialization
}

//+------------------------------------------------------------------+
//| Function to Calculate T3 Indicator                              |
//+------------------------------------------------------------------+
double T3(int length, double factor, int shift)
{
    // Arrays to store EMA values from the indicator handles
    double ema1[], ema2[], ema3[], ema4[], ema5[], ema6[];
    
    // Set all arrays as time-descending (newest values at lower indices)
    ArraySetAsSeries(ema1, true);
    ArraySetAsSeries(ema2, true);
    ArraySetAsSeries(ema3, true);
    ArraySetAsSeries(ema4, true);
    ArraySetAsSeries(ema5, true);
    ArraySetAsSeries(ema6, true);
    
    // Copy data from each EMA indicator to the corresponding array
    // Parameters: (handle, buffer_num, start_pos, count, destination_array)
    CopyBuffer(hEMA1, 0, shift, 1, ema1);
    CopyBuffer(hEMA2, 0, shift, 1, ema2);
    CopyBuffer(hEMA3, 0, shift, 1, ema3);
    CopyBuffer(hEMA4, 0, shift, 1, ema4);
    CopyBuffer(hEMA5, 0, shift, 1, ema5);
    CopyBuffer(hEMA6, 0, shift, 1, ema6);
    
    // Calculate the coefficients for the T3 formula based on the factor
    // These coefficients implement the T3 calculation as a weighted sum of different EMAs
    double c1 = -factor * factor * factor;                                  // Weight for the 6th EMA
    double c2 = 3 * factor * factor + 3 * factor * factor * factor;         // Weight for the 5th EMA
    double c3 = -6 * factor * factor - 3 * factor - 3 * factor * factor * factor; // Weight for the 4th EMA
    double c4 = 1 + 3 * factor + factor * factor * factor + 3 * factor * factor; // Weight for the 3rd EMA
    
    // Apply the T3 formula: combine all EMAs with their respective coefficients
    // T3 = c1*EMA6 + c2*EMA5 + c3*EMA4 + c4*EMA3
    return (c1 * ema6[0] + c2 * ema5[0] + c3 * ema4[0] + c4 * ema3[0]);
}

//+------------------------------------------------------------------+
//| Custom Indicator Calculation Function                           |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,      // Total number of bars available
                const int prev_calculated,  // Number of bars calculated in previous call
                const datetime& time[],     // Time array
                const double& open[],       // Open price array
                const double& high[],       // High price array
                const double& low[],        // Low price array
                const double& close[],      // Close price array
                const long& tick_volume[],  // Tick volume array
                const long& volume[],       // Real volume array
                const int& spread[])        // Spread array
{
    // Calculate T3 values only for new bars that haven't been calculated yet
    for (int i = 0; i < rates_total-prev_calculated; i++)
    {
        // Calculate T3 value for each bar and store it in the buffer
        T3Buffer[i] = T3(T3_Length, T3_Factor, i);
    }
    
    // Return the total number of calculated bars
    return rates_total;
}