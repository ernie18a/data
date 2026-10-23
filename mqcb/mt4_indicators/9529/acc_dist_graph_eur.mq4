
#property copyright "Copyright © 2009, sHrung."
#property link      "http://www.something.com/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

//---- input parameters
extern int MomPeriod=1000;
//---- buffers
//--- currencies 
double EUR[];

//--- 
double ac_eurusd[];
double ac_eurgbp[], ac_eurjpy[];
double ac_eurchf[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
   //---- additional buffers used for counting.
  IndicatorBuffers(5);


//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,EUR);
   SetIndexBuffer(1,ac_eurgbp);
   SetIndexBuffer(2,ac_eurusd);
   SetIndexBuffer(3,ac_eurchf);
   SetIndexBuffer(4,ac_eurjpy);
   
   
   
//---- name for DataWindow and indicator subwindow label
   short_name="Accu/Dist Graph EUR ("+MomPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"EUR");
//----
   SetIndexDrawBegin(0,MomPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Four legs                                                        |
//+------------------------------------------------------------------+
int start()
  {
   int i,counted_bars=IndicatorCounted();
   int a, b, c, d, e, f, g, h, ii, j;
//----
   if(Bars<=MomPeriod) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=MomPeriod;i++) EUR[Bars-i]=0.0;
//----
   
   int limib=Bars-counted_bars;
   if(counted_bars>1) limib++;
   for(b=0; b<MomPeriod; b++)
   ac_eurusd[b] = iAD("EURUSD",0,b);
   
   
   int limie=Bars-counted_bars;
   if(counted_bars>1) limie++;
   for(e=0; e<MomPeriod; e++)
   ac_eurgbp[e] = iAD("EURGBP",0,e);

   int limif=Bars-counted_bars;
   if(counted_bars>1) limif++;
   for(f=0; f<MomPeriod; f++)
   ac_eurjpy[f] = iAD("EURJPY",0,f);
   
   int limig=Bars-counted_bars;
   if(counted_bars>1) limig++;
   for(g=0; g<MomPeriod; g++)
   ac_eurchf[g] = iAD("EURCHF",0,g);

//----
//----
   i=Bars-MomPeriod-1;
   if(counted_bars>=MomPeriod) i=Bars-counted_bars-1;
   while(i>=0)
     {
EUR[i] = ac_eurusd[i] + ac_eurgbp[i] + ac_eurjpy[i] + ac_eurchf[i];

    i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+