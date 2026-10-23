
#property copyright "Copyright © 2009, sHrung."
#property link      "http://www.something.com/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 AliceBlue

//---- input parameters
extern int MomPeriod=1000;
//---- buffers
//--- currencies 
double USD[];

//--- 
double ac_gbpusd[], ac_eurusd[], ac_usdjpy[];
double ac_usdchf[];

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
   SetIndexBuffer(0,USD);
   SetIndexBuffer(1,ac_gbpusd);
   SetIndexBuffer(2,ac_eurusd);
   SetIndexBuffer(3,ac_usdchf);
   SetIndexBuffer(4,ac_usdjpy);
   
   
   
//---- name for DataWindow and indicator subwindow label
   short_name="Accu/Dist Graph USD ("+MomPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"USD");
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
      for(i=1;i<=MomPeriod;i++) USD[Bars-i]=0.0;
//----
   int limia=Bars-counted_bars;
   if(counted_bars>1) limia++;
   for(a=0; a<MomPeriod; a++)
   ac_gbpusd[a] = iAD("GBPUSD",0,a);
   
   int limib=Bars-counted_bars;
   if(counted_bars>1) limib++;
   for(b=0; b<MomPeriod; b++)
   ac_eurusd[b] = iAD("EURUSD",0,b);
   
   int limic=Bars-counted_bars;
   if(counted_bars>1) limic++;
   for(c=0; c<MomPeriod; c++)
   ac_usdjpy[c] = iAD("USDJPY",0,c);

   int limid=Bars-counted_bars;
   if(counted_bars>1) limid++;
   for(d=0; d<MomPeriod; d++)
   ac_usdchf[d] = iAD("USDCHF",0,d);

//----
 int limik=Bars-counted_bars;
   if(counted_bars>1) limik++;
   for(i=0; i<MomPeriod; i++)
//USD[i] = ac_usdjpy[i] + ac_usdchf[i] - ac_gbpusd[i] - ac_eurusd[i] ;
//----
   i=Bars-MomPeriod-1;
   if(counted_bars>=MomPeriod) i=Bars-counted_bars-1;
   while(i>=0)
     {
USD[i] = ac_usdjpy[i] + ac_usdchf[i] - ac_gbpusd[i] - ac_eurusd[i] ;

    i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+