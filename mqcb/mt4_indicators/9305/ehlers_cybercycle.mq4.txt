//+------------------------------------------------------------------+
//|                                                   CyberCycle.mq4 |
//|                                                                  |
//| Cyber Cycle                                                      |
//|                                                                  |
//| Algorithm taken from book                                        |
//|     "Cybernetics Analysis for Stock and Futures"                 |
//| by John F. Ehlers                                                |
//|                                                                  |
//|                                              contact@mqlsoft.com |
//|                                          http://www.mqlsoft.com/ |
//+------------------------------------------------------------------+
#property copyright "Coded by Witold Wozniak"
#property link      "www.mqlsoft.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

#property indicator_level1 0

double Cycle[];
double Trigger[];
double Smooth[];

extern double Alpha=0.07;
int buffers=0;
int drawBegin=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init() 
  {
   drawBegin=8;
   initBuffer(Cycle,"Cycle",DRAW_LINE);
   initBuffer(Trigger,"Trigger",DRAW_LINE);
   initBuffer(Smooth);
   IndicatorBuffers(buffers);
   IndicatorShortName("Cyber Cycle ["+DoubleToStr(Alpha,2)+"]");
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start() 
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+3;
   int s;
   for(s=limit; s>=0; s--) 
     {
      Smooth[s]=(P(s)+2.0 * P(s+1)+2.0 * P(s+2)+P(s+3))/6.0;
      Cycle[s] =(1.0-0.5 * Alpha) *(1.0-0.5 * Alpha) *(Smooth[s]-2.0 * Smooth[s+1]
                 + Smooth[s + 2]) + 2.0 *(1.0 - Alpha) * Cycle[s + 1] -(1.0 - Alpha) *(1.0 - Alpha) * Cycle[s + 2];
      if(s>Bars-8) 
        {
         Cycle[s]=(P(s)-2.0*P(s+1)+P(s+2))/4.0;
        }
      Trigger[s]=Cycle[s+1];
     }
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double P(int index) 
  {
   return ((High[index] + Low[index]) / 2.0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initBuffer(double array[],string label="",int type=DRAW_NONE,int arrow=0,int style=EMPTY,int width=EMPTY,color clr=CLR_NONE) 
  {
   SetIndexBuffer(buffers,array);
   SetIndexLabel(buffers,label);
   SetIndexEmptyValue(buffers,EMPTY_VALUE);
   SetIndexDrawBegin(buffers,drawBegin);
   SetIndexShift(buffers,0);
   SetIndexStyle(buffers,type,style,width);
   SetIndexArrow(buffers,arrow);
   buffers++;
  }
//+------------------------------------------------------------------+
