//+------------------------------------------------------------------+
//|                                               Test_CustomCCI.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_separate_window

#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_width1  1
#property indicator_label1  "CCI"
#property indicator_level1  -100.0
#property indicator_level2   100.0
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

input int ma_period = 14;
input ENUM_APPLIED_PRICE applied_price = PRICE_CLOSE;
input int shift = 0;

int custom_cci_handle = INVALID_HANDLE;

double test_buf[];

int OnInit(){

   SetIndexBuffer(0, test_buf, INDICATOR_DATA);
 
  
   custom_cci_handle = iCustom(Symbol(), Period(), "Examples\\CCI_withShift.ex5", ma_period, applied_price, shift); //the modded custom CCI
   
   
   if (custom_cci_handle == INVALID_HANDLE){
      Print("Still shows as invalid handle. Failed to initialize custom CCI indicator!");
      return INIT_FAILED;
   }

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
                const int &spread[]){


    int copied = CopyBuffer(custom_cci_handle, 0, 0, rates_total, test_buf);
   
    if (copied <= 0){
        Print("Failed to copy CCI values!");
        return(0);
    }

   
   return(rates_total);
}
//+------------------------------------------------------------------+
