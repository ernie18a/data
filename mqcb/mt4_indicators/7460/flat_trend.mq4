//+------------------------------------------------------------------+
//|                                                    FlatTrend.mq4 |
//|                                                       Kirk Sloan |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Kirk Sloan"
#property link      "https://www.metaquotes.net"
//----
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 1
#property indicator_buffers 3
#property indicator_color1 clrRed
#property indicator_color2 clrLimeGreen
#property indicator_color3 clrGold
//---- input parameters
extern ENUM_TIMEFRAMES tf=PERIOD_M5;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
//---
double Ma;
double hhigh,llow;
double Psar;
double PADX,NADX;
string TimeFrameStr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,1,clrRed);
   SetIndexBuffer(0,ExtMapBuffer1);
//---
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,1,clrLimeGreen);
   SetIndexBuffer(1,ExtMapBuffer2);
//---
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,1,clrGold);
   SetIndexBuffer(2,ExtMapBuffer3);
   switch(tf)
     {
      case PERIOD_M1    : TimeFrameStr="Period_M1"; break;
      case PERIOD_M5    : TimeFrameStr="Period_M5"; break;
      case PERIOD_M15   : TimeFrameStr="Period_M15"; break;
      case PERIOD_M30   : TimeFrameStr="Period_M30"; break;
      case PERIOD_H1    : TimeFrameStr="Period_H1"; break;
      case PERIOD_H4    : TimeFrameStr="Period_H4"; break;
      case PERIOD_D1    : TimeFrameStr="Period_D1"; break;
      case PERIOD_W1    : TimeFrameStr="Period_W1"; break;
      case PERIOD_MN1   : TimeFrameStr="Period_MN1"; break;
      default : TimeFrameStr="Current Timeframe"; tf=PERIOD_CURRENT;
     }
     if(tf!=Period()) tf=(ENUM_TIMEFRAMES)Period();
   IndicatorShortName("Flat Trend ("+TimeFrameStr+")");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
   for(int i=0; i<Bars; i++)
     {
      ExtMapBuffer1[i]=0;
      ExtMapBuffer2[i]=0;
      ExtMapBuffer3[i]=0;
      //----
      PADX=iADX(NULL,tf,14 ,PRICE_CLOSE,1,i);
      NADX=iADX(NULL,tf,14 ,PRICE_CLOSE,2,i);
      Psar=iSAR(NULL,tf,0.02,0.2,i);
      if(Psar<iClose(NULL,tf,i) && PADX>NADX)
        {
         ExtMapBuffer2[i]=1;
        }
      if(Psar>iClose(NULL,tf,i) && NADX>PADX)
        {
         ExtMapBuffer1[i]=1;
        }
      if(ExtMapBuffer1[i]==0 && ExtMapBuffer2[i]==0)
        {
         ExtMapBuffer3[i]=1;
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
