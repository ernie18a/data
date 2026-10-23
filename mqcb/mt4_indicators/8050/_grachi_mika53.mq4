//+------------------------------------------------------------------+
//|                                                  Grachi_Mika.mq4 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//| Индикатор написан по системе торговли описанной вот здесь:       |
//| http://forum.fibo-forex.ru/viewtopic.php?t=1368                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes Software Corp."
#property link      "http://www.xrusr@land.ru"
//---------------
//---- indicator parameters
extern int ExtDepth = 12;
extern int ExtDeviation = 5;
extern int ExtBackstep = 3;
//---------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Gray
#property indicator_color2 Gray
#property indicator_color3 Blue
#property indicator_color4 Red
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_SECTION);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(1,0.0);
   SetIndexStyle(2,DRAW_SECTION,EMPTY,2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexEmptyValue(2,0.0);
   SetIndexStyle(3,DRAW_SECTION,EMPTY,2);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexEmptyValue(3,0.0);
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
   int ap=0,dn=0;
//----
   if(counted_bars>0)
        counted_bars--;
     
   int limit=Bars-counted_bars;
   for(int i=0;i<Bars;i++)
   {
   ExtMapBuffer1[i]=iCustom(NULL, 0, "Zigzag2_R_", ExtDepth, ExtDeviation, ExtBackstep, 0, i);
   ExtMapBuffer2[i]=iCustom(NULL, 0, "Zigzag2_R_", ExtDepth, ExtDeviation, ExtBackstep, 1, i);
   if(ExtMapBuffer1[i]!=0){ExtMapBuffer4[i]=ExtMapBuffer1[i];}
   if(ExtMapBuffer2[i]!=0){ExtMapBuffer4[i]=ExtMapBuffer2[i];}
   if(ExtMapBuffer1[i]!=0)
    {
     ap++;
      if(ap%2==0){dn++;ExtMapBuffer3[i]=ExtMapBuffer1[i];}
       }
   
   if(ExtMapBuffer2[i]!=0)
    {
    dn++;
     if(dn%2==0){ap++;ExtMapBuffer3[i]=ExtMapBuffer2[i];}
      }   
   }    
//----
   return(0);
  }
//+------------------------------------------------------------------+