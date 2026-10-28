//+------------------------------------------------------------------+
//|                                            BareMovingAverage.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright phade 2024, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 1

#property indicator_label1  "MA Line"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen, clrRed, clrNONE
#property indicator_width1  2

#property indicator_label2  "Uptrend"
#property indicator_type2   DRAW_NONE

#property indicator_label3  "Downtrend"
#property indicator_type3  DRAW_NONE


#define ma_buffer_register 0
#define ma_color_register 1
#define ma_uptrend_register 2
#define ma_downtrend_register 3


input int MA_Period = 10; // MA Period
input ENUM_MA_METHOD MA_Method = MODE_SMA; // MA Mode
input ENUM_APPLIED_PRICE MA_Price = PRICE_CLOSE; // Applied price

double ma[];
double color_buf[];
double uptrend[], downtrend[];

int ma_handle = INVALID_HANDLE;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{          
   IndicatorSetString(INDICATOR_SHORTNAME,"MA (Period " + IntegerToString(MA_Period) + ")");
    
        
   InitializeMovingAverage(ma_handle, ma, color_buf, MA_Period, MA_Method, MA_Price); 
   
     
   return INIT_SUCCEEDED; 
}


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
   
   BuildMovingAverage(ma_handle, prev_calculated, rates_total, ma, color_buf); 
   
   int shift = 0;
   
   if(uptrend[shift] > 0) Comment("Bull trend");
    
   if(downtrend[shift] > 0) Comment("Bear trend");
      
   return rates_total; 
}


void OnDeinit(const int reason){

   Comment("");
}


//------------------------------------------------------------------------------


bool InitializeMovingAverage(int &handle, 
                             double &buffer[], 
                             double &color_buffer[], 
                             int ma_period, 
                             ENUM_MA_METHOD ma_method, 
                             ENUM_APPLIED_PRICE applied_price)
{
   SetIndexBuffer(ma_buffer_register, buffer, INDICATOR_DATA);
   SetIndexBuffer(ma_color_register, color_buffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(ma_uptrend_register, uptrend, INDICATOR_DATA);
   SetIndexBuffer(ma_downtrend_register, downtrend, INDICATOR_DATA);
   
   ArraySetAsSeries(buffer, true);
   ArraySetAsSeries(color_buffer, true);
   ArraySetAsSeries(uptrend, true);
   ArraySetAsSeries(downtrend, true);
                
   handle = iMA(Symbol(), Period(), ma_period, 0, ma_method, applied_price);
   
   return (handle != INVALID_HANDLE);
}



bool BuildMovingAverage(int handle, int prev_calculated, int rates_total, double &buffer[], double &colbuff[])
{
   int to_copy;
   
   if(prev_calculated > rates_total || prev_calculated < 0) 
      to_copy = rates_total;
   else 
   {
      to_copy = rates_total - prev_calculated;
      if(prev_calculated > 0) to_copy++;
   }
   
   if(CopyBuffer(handle, 0, 0, to_copy, buffer) < 0){
   
      ChartRedraw();
   }
      
   int start = (prev_calculated < 0) ? 0 : prev_calculated - 1;
   
   for(int i=start; i>=0 && !IsStopped(); i--){
   
      if(i+2<start){        
         uptrend[i] = 0;
         downtrend[i] = 0;
         
         if(ma[i] > ma[i+1] && ma[i+1] > ma[i+2]){ colbuff[i] = 0; uptrend[i] = 1; downtrend[i] = 0; }        
                 
         else if(ma[i] < ma[i+1] && ma[i+1] < ma[i+2]){ colbuff[i] = 1; uptrend[i] = 0; downtrend[i] = 1; }                  
      }

   }     
      
   return true;
}


