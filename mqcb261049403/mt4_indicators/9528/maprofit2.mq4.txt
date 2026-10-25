//+------------------------------------------------------------------+
//|                                               MA Profit Diff.mq4 |
//|                                 Copyright © 2010, Thomas Quester |
//|                                                  tquester@gmx.de |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Thomas Quester"
#property link      "tquester@gmx.de"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

double ExtMapBuffer1[];

extern int       PeriodShort=6;
extern int       PeriodLong=40;
extern int       Method=0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   GetVars();
//----
   return(0);
  }
  
void GetVars()
{
   //Print("GetVars");
   string sym = Symbol()+Period();
   int PeriodShort1 = GlobalVariableGet(sym+"PeriodShort");
   if(GetLastError()!=0) Print("Error getting "+sym+"PeriodShort");

   int PeriodLong1 = GlobalVariableGet(sym+"PeriodLong");
   if(GetLastError()!=0) Print("Error getting "+sym+"PeriodLong");
   int Method1 = GlobalVariableGet(sym+"Method");
   if(GetLastError()!=0) Print("Error getting "+sym+"Method");
   Print("GetVars ",sym," - ",PeriodShort1,"/",PeriodLong1);
   
   if (PeriodShort1!=0) PeriodShort=PeriodShort1;
   if (PeriodLong1!=0) PeriodLong=PeriodLong1;
   if (Method1!=0) Method=Method1;
}  
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   int i;
   double maS,maL;
   //GetVars();
   //Print("MA2 Periode=",PeriodShort,"/",PeriodLong);
   
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit--;
      
   for (i=limit;i>=0;i--)
   {
      maS      = iMA(NULL,0,PeriodShort,0,Method,PRICE_MEDIAN,i);
      maL      = iMA(NULL,0,PeriodLong,0,Method,PRICE_MEDIAN,i);
      ExtMapBuffer1[i] = (maS-maL)/Point;
//----
   }
   return(0);
  }
//+------------------------------------------------------------------+