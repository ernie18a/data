//+------------------------------------------------------------------+
//|                                                      SrossMA.mq4 |
//|                                                        Submarine |
//|                                      WeChart:ExpertAdvisorTrader |
//+------------------------------------------------------------------+
#property copyright "Submarine"
#property link      "WeChart:ExpertAdvisorTrader"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot FastLine
#property indicator_label1  "FastLine"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SloeLine
#property indicator_label2  "SlowLine"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Long
#property indicator_label3  "Long"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Short
#property indicator_label4  "Short"
#property indicator_type4   DRAW_HISTOGRAM
#property indicator_color4  clrGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

//--- input Fast iMA parameters
input string             CommandFM            = "=====Fast_MA Paramater=====";
input ENUM_TIMEFRAMES    FastMA_timeframe     = 0;
input int                FastMA_period        = 9;
input int                FastMA_shift         = 0;
input ENUM_MA_METHOD     FastMA_method        = 0;
input ENUM_APPLIED_PRICE FastMA_applied_price = 0;

//--- input Slow iMA parameters
input string             CommandSM            = "=====Slow_MA Paramater=====";
input ENUM_TIMEFRAMES    SlowMA_timeframe     = 0;
input int                SlowMA_period        = 36;
input int                SlowMA_shift         = 0;
input ENUM_MA_METHOD     SlowMA_method        = 0;
input ENUM_APPLIED_PRICE SlowMA_applied_price = 0;

//--- indicator buffers
double         FastLineBuffer[];
double         SlowLineBuffer[];
double         LongBuffer[];
double         ShortBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,FastLineBuffer);
   SetIndexBuffer(1,SlowLineBuffer);
   SetIndexBuffer(2,LongBuffer);
   SetIndexBuffer(3,ShortBuffer);
   
   EventSetMillisecondTimer(300);
   
//---
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
//---
   
   OnTimer();
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }

void OnTimer()
  {
  
    for(int i=WindowFirstVisibleBar(); i>=0; i--)
       {
        
       FastLineBuffer[i]=iMA(NULL,FastMA_timeframe,FastMA_period,FastMA_shift,FastMA_method,FastMA_applied_price,i);
       SlowLineBuffer[i]=iMA(NULL,SlowMA_timeframe,SlowMA_period,SlowMA_shift,SlowMA_method,SlowMA_applied_price,i);
       
       LongBuffer[i]=FastLineBuffer[i];
       ShortBuffer[i]=SlowLineBuffer[i];
       
       }

  
  }