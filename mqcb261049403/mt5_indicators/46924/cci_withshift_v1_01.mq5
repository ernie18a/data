#property copyright   "Phade & MetaQuotes Ltd."
#property description "CCI with shift"
#property version   "1.01"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_width1  1
#property indicator_label1  "CCI"
#property indicator_level1  -100.0
#property indicator_level2   100.0

// Indicator input parameters
input int period = 14; // Period
input ENUM_APPLIED_PRICE applied_price = PRICE_CLOSE; //Applied price
input int shift = 1; // Shift

// Indicator handle
int cci_handle;

double plotting_buffer[];
double data[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

    // Create the CCI indicator
    cci_handle = iCCI(Symbol(), Period(), period, applied_price);

    if (cci_handle == INVALID_HANDLE){
        Print("Failed to create CCI indicator!");
        return(INIT_FAILED);
    }

    // Set the indicator label
    string indicator_name = "CCI(" + IntegerToString(period) + ")";
    
    IndicatorSetString(INDICATOR_SHORTNAME, indicator_name);

    // Set up the indicator buffers
    SetIndexBuffer(0, plotting_buffer, INDICATOR_DATA);
    SetIndexBuffer(1, data, INDICATOR_CALCULATIONS);

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Release the CCI indicator
    IndicatorRelease(cci_handle);
}

//+------------------------------------------------------------------+
//| Custom indicator calculation function                            |
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
    // Check if we have enough bars to calculate
    if (rates_total <= period + shift)
        return(0);
        
    int calculated = BarsCalculated(cci_handle);
    
    if(calculated < rates_total){
    
      Print("Not all data of handle is calculated (", calculated, " bars). Error ", GetLastError());
      return 0;
    }

    int to_copy = (prev_calculated > rates_total || prev_calculated < 0) ? rates_total : rates_total - prev_calculated;
   
    if(prev_calculated > 0) to_copy++;
       

    // Calculate the CCI values and copy them to the buffer
    int copied = CopyBuffer(cci_handle, 0, 0, to_copy, data);
   
    if (copied <= 0){
        Print("Failed to copy CCI values!");
        return(0);
    }
      
    int limit = (prev_calculated == 0) ? 0 : prev_calculated - 1;   
    
    for(int i = rates_total-1; i > MathMax(limit, shift); i--){
    
         plotting_buffer[i - shift] = data[i];
    }
    
    for(int i = rates_total-shift; i < rates_total; i++){
    
         plotting_buffer[i] = EMPTY_VALUE;
    }   
    

    return(rates_total);
}
