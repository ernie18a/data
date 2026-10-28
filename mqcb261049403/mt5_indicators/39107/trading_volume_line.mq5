//+------------------------------------------------------------------+
//|                                          Trading Volume Line.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1 50
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Bulls
#property indicator_label1  "Bulls"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDeepSkyBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Bears
#property indicator_label2  "Bears"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrCoral
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//+------------------------------------------------------------------+
//| Enum Ratio                                                       |
//+------------------------------------------------------------------+
enum ENUM_RATIO
  {
   ratio_close = 0,  // Close Ratio
   ratio_open  = 1,  // Open Ratio
   ratio_body  = 2,  // Body Ratio
  };
//--- input parameters
input ENUM_RATIO  InpRatio = ratio_close;   // Ratio type:
//--- indicator buffers
double   BullsBuffer[];
double   BearsBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BullsBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,BearsBuffer,INDICATOR_DATA);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- name for DataWindow and indicator subwindow label
   string str_ratio="-";
   switch(InpRatio)
     {
      case  ratio_close:
         str_ratio="Close";
         break;
      case  ratio_open:
         str_ratio="Open";
         break;
      default:
         str_ratio="Body";
         break;
     }
   IndicatorSetString(INDICATOR_SHORTNAME,"Trading Volume Line("+str_ratio+")");
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
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=0;
   for(int i=limit; i<rates_total; i++)
     {
      switch(InpRatio)
        {
         case  ratio_close:
           {
            double BidRatio=0.0;
            double PairH=high[i];
            double PairL=low[i];
            double PairB=close[i];
            double PRange=(PairH-PairL)*Point();
            if(PRange>0)
               BidRatio=(PairB-PairL)/(PairH-PairL);
            BullsBuffer[i]=BidRatio*100.0;
            BearsBuffer[i]=(1.0-BidRatio)*100.0;
           }
         break;
         case  ratio_open:
           {
            double BidRatio=0.0;
            double PairH=high[i];
            double PairL=low[i];
            double PairB=open[i];
            double PRange=(PairH-PairL)*Point();
            if(PRange>0)
               BidRatio=(PairH-PairB)/(PairH-PairL);
            BullsBuffer[i]=BidRatio*100.0;
            BearsBuffer[i]=(1.0-BidRatio)*100.0;
           }
         break;
         default:
           {
            double Percent=0.0;
            double Bulls=0.0,Bears=0.0;
            double Length0=high[i]-low[i];
            double Body0=MathAbs(open[i]-close[i]);
            if(Length0>0)
               Percent=Body0/Length0;
            double Remain=1.0-Percent;
            //--- DownCandle
            if(open[i]>close[i])
              {
               BullsBuffer[i]=Remain/2.0*100.0;
               BearsBuffer[i]=(Percent+Remain/2.0)*100.0;
              }
            //--- UpCandle
            else
              {
               BearsBuffer[i]=Remain/2.0*100.0;
               BullsBuffer[i]=(Percent+Remain/2.0)*100.0;
              }
           }
         break;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
