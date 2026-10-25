//+------------------------------------------------------------------+
//|                                                      Garch11.mq4 |
//|                                              Andres Barale Sarti |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, andresbarale@gmail.com  "
#property link      "https://forge.mql5.io"

#property indicator_separate_window
#property indicator_color1 Blue
#property indicator_width1 2
#property indicator_buffers 2
#property strict

double ExtOutputBuffer[]; // output buffer
double MA_Buffer[];
double GarchNumVar;
string INDICATOR_NAME="Garch11";

//************************************************************
// Input parameters
//************************************************************
 
enum DATA_TYPE {
                  CandleClose,
                  CandleOpen,
                  CandleHigh,
                  CandleLow
               };
extern DATA_TYPE          e_type_data   = CandleClose;
extern int                e_reverse_data   = 0;
extern double             e_alpha = 0.010; 
extern double             e_beta = 0.450;
extern int                MA_Period = 50;
extern ENUM_MA_METHOD     MA_Method = MODE_EMA;
extern double multi = 100;

double tmpArray[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  GarchNumVar = 0.000001;
//--- indicator buffers mapping
   IndicatorBuffers(2);
   SetIndexBuffer(0, ExtOutputBuffer );
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2,clrWhite);
   
   SetIndexBuffer(1,MA_Buffer);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2,clrLimeGreen);   
   
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
      int limit;
      int counted_bars = IndicatorCounted();
      if(counted_bars < 0) 
         return(-1);
      limit = Bars - counted_bars -1;
      
      double GarchNumber;
      double residual;
      double residualSquared;
      static double GarchNumVar_;
      if(limit <= 0)
         GarchNumVar_ = 0.0;
      
      GarchNumVar = GarchNumVar_;
      //limit = 3000;
      for(int i = limit-1; i >= 1; i--) {
         
         switch(e_type_data) {
            case CandleClose: residual = Close[i] - Close[i+1]; break;
            case CandleOpen: residual = Open[i] - Open[i+1]; break;
            case CandleHigh: residual = High[i] - High[i+1]; break;
            case CandleLow: residual = Low[i] - Low[i+1]; break;
            default: residual = Close[i] - Close[i+1];
         }
         
         residualSquared = MathPow(residual, 2.0);
         GarchNumVar = (e_alpha * residualSquared) + (e_beta * GarchNumVar);
         GarchNumber = MathSqrt(GarchNumVar);
         GarchNumber = GarchNumber * multi;
         ExtOutputBuffer[i] = GarchNumber;
         
         if(i)
            GarchNumVar_ = GarchNumVar;
         
         MA_Buffer[i] = iMAOnArray(ExtOutputBuffer, 0, MA_Period, 0, MA_Method, i); //ignoring shift
      }
        switch(e_type_data) {
            case CandleClose: residual = Close[0] - Close[1]; break;
            case CandleOpen: residual = Open[0] - Open[1]; break;
            case CandleHigh: residual = High[0] - High[1]; break;
            case CandleLow: residual = Low[0] - Low[1]; break;
            default: residual = Close[0] - Close[1];
         }
         residualSquared = MathPow(residual, 2.0);
         GarchNumVar = (e_alpha * residualSquared) + (e_beta * GarchNumVar);
         GarchNumber = MathSqrt(GarchNumVar);
         GarchNumber = GarchNumber * multi;
         ExtOutputBuffer[0] = GarchNumber;
         MA_Buffer[0] = iMAOnArray(ExtOutputBuffer, 0, MA_Period, 0, MA_Method, 0); //ignoring shift
      //ExtOutputBuffer[0] = 0;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
