//+------------------------------------------------------------------+
//|                            ATR Based Ranging Market Detector.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright phade 2024, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots 1


double consolidation_trend[];
double atr[], High[], Low[];
double buf_open[],buf_high[],buf_low[],buf_close[],buf_color[];

input ENUM_CHART_MODE chart_mode = CHART_BARS; // Chart Mode
input bool dynamic_detection = true; // Use ATR for range detection
input int pointThreshold = 60; // Point threshold if not using dynamic detection
input int atr_period=20; // ATR period
input double atr_multiplier = 0.5; // ATR multiplier
input int backstep = 1; // Box backstep

input int bar_lookback = 200; // Lookback

int handle = INVALID_HANDLE;

string obj_name;
color line_chart_col = clrNONE; // Line chart color

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
  SetIndexBuffer(0,buf_open,INDICATOR_DATA);
  SetIndexBuffer(1,buf_high,INDICATOR_DATA);
  SetIndexBuffer(2,buf_low,INDICATOR_DATA);
  SetIndexBuffer(3,buf_close,INDICATOR_DATA);   
  SetIndexBuffer(4,buf_color,INDICATOR_COLOR_INDEX);
  SetIndexBuffer(5,consolidation_trend, INDICATOR_CALCULATIONS);
  SetIndexBuffer(6,atr, INDICATOR_CALCULATIONS);
  SetIndexBuffer(7,High, INDICATOR_CALCULATIONS);
  SetIndexBuffer(8,Low, INDICATOR_CALCULATIONS);
  
  if(chart_mode == CHART_BARS){
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_COLOR_BARS);
   ChartSetInteger(0, CHART_MODE, CHART_LINE);
   ChartSetInteger(0, CHART_COLOR_CHART_LINE, line_chart_col);
   }
   
  if(chart_mode == CHART_CANDLES){
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_COLOR_CANDLES);  
   ChartSetInteger(0, CHART_MODE, CHART_LINE);
   ChartSetInteger(0, CHART_COLOR_CHART_LINE, line_chart_col);
   }
   
  if(chart_mode == CHART_LINE){
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);  
   ChartSetInteger(0, CHART_MODE, CHART_LINE);
   ChartSetInteger(0, CHART_COLOR_CHART_LINE, line_chart_col);
   ChartSetInteger(0, CHART_COLOR_CHART_UP, clrNONE); 
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrNONE);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrNONE); 
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrNONE);
   }

  PlotIndexSetInteger(0,PLOT_LINE_WIDTH,2);
  PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,3);
  PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrDarkSlateGray);
  PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,clrSeaGreen);
  PlotIndexSetInteger(0,PLOT_LINE_COLOR,2,clrCrimson); 
  
  ChartNavigate(0, CHART_END);
   
  IndicatorSetString(INDICATOR_SHORTNAME,"Market Range Detector");

  handle = iATR(Symbol(), 0, atr_period);

  return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//|      Rectangle to mark the area of the ranging market           |
//+------------------------------------------------------------------+
void ZoneMark(int startidx, int endidx, const datetime &time[], const double &high[], const double &low[])
{
    obj_name = "ConsolidationZone_" + IntegerToString(startidx) + "_" + IntegerToString(endidx);

    if(ObjectFind(0, obj_name) < 0){
 
     if (!ObjectCreate(0, obj_name, OBJ_RECTANGLE, 0, time[startidx], high[startidx], time[endidx], low[endidx])) {
         Print(__FUNCTION__, ": failed to create a rectangle! Error code = ", GetLastError());
         return;
         }
     }
     
     // Set object properties for the new rectangle
     ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clrGray);
     ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_DASH);
     ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 1);
     ObjectSetInteger(0, obj_name, OBJPROP_FILL, true);
     ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);
}

//+------------------------------------------------------------------+
//| Detect Consolidation and Draw the zone                           |
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
    if (rates_total < atr_period)
        return rates_total;


    int recalculationPoint = bar_lookback;

    if (CopyBuffer(handle, 0, 0, recalculationPoint+1, atr) < 0) {
        Print("Failed to copy ATR values!");
        return rates_total;
    }

    bool in_consolidation = false;
    int startidx = -1;
    int endidx = -1;

    int start = rates_total - recalculationPoint;
      
    for (int i = start; i < rates_total && !IsStopped(); i++){
       
        buf_open[i]=open[i];
        buf_high[i]=high[i];
        buf_low[i]=low[i];
        buf_close[i]=close[i];    
    
        High[i] = high[i];
        Low[i] = low[i];

        // Calculate highest/lowest range for consolidation
        for (int j = 1; j <= backstep; j++){
        
            if (high[i - j] > high[i]) 
                High[i] = high[i - j];
                
            else if (low[i - j] < low[i]) 
                Low[i] = low[i - j];
        }

        bool weak_change = false;

        if (dynamic_detection)
            weak_change = fabs(close[i] - close[i-1]) < atr[i] * atr_multiplier;
        else
            weak_change = fabs(close[i] - close[i-1])/_Point < pointThreshold;

        if (weak_change){
        
            buf_color[i]=0;
            consolidation_trend[i] = 1;

            if (!in_consolidation){
         
                in_consolidation = true;
                startidx = i; // start index of consolidation
                    
                ZoneMark(i, i, time, buf_high, buf_low);
            } 
            else
            {
               endidx = i;
                          
                if (ObjectFind(0, obj_name) >= 0){
                    ObjectMove(0, obj_name, 1, time[endidx], low[endidx]); // Update the end point of the consolidation zone
                }
            }
        } 
        else{
        
             if(close[i] > open[i])
               buf_color[i]=1;
               
             else if(close[i] < open[i])
               buf_color[i]=2;        
	       
             consolidation_trend[i] = 0;
     
             if (in_consolidation){ // end of consolidation period
            
                in_consolidation = false;
                endidx = i - 1;

                if (ObjectFind(0, obj_name) >= 0){
                    ObjectMove(0, obj_name, 1, time[endidx], low[endidx]); // Finalize the consolidation zone at end index
             }
         }

        }
    }
    
    RemoveHistoricObjects(rates_total-recalculationPoint, time);

    return rates_total;
}


void RemoveHistoricObjects(int shift, const datetime &time[]){

    // Calculate the time for recalculation point
    datetime recalculationTime = time[shift];
    
    // Loop through all objects on the chart
    int totalObjects = ObjectsTotal(0);
    
    for (int i = totalObjects - 1; i >= 0; i--) {
    
        string objName = ObjectName(0, i);  // Get the name of the object
        
        // Check if the object is a rectangle (or any other type you need to clean up)
        if (StringFind(objName, "ConsolidationZone_") != -1) {
        
            // Get the time of the start of the object (first anchor point)
            long objTime = ObjectGetInteger(0, objName, OBJPROP_TIME);
            
            // If the object starts before the recalculation point, delete it
            if (objTime < (long)recalculationTime){
            
                ObjectDelete(0, objName);
            }
        }
    }
}


void OnDeinit(const int reason)
{
  ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
  ObjectsDeleteAll(0, "ConsolidationZone_");
}
