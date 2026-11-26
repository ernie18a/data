
#property copyright "Copyright © 2009, sHrung."
#property link      "http://www.something.com/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 LimeGreen

//---- input parameters
extern int MomPeriod=1000;
//---- buffers
//--- currencies 
double GBP[];

//--- 
double ac_gbpusd[];
double ac_eurgbp[];
double ac_gbpjpy[];
double ac_gbpchf[];

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
   SetIndexBuffer(0,GBP);
   SetIndexBuffer(1,ac_eurgbp);
   SetIndexBuffer(2,ac_gbpusd);
   SetIndexBuffer(3,ac_gbpchf);
   SetIndexBuffer(4,ac_gbpjpy);
   
   
   
//---- name for DataWindow and indicator subwindow label
   short_name="Accu/Dist Graph GBP ("+MomPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"GBP");
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
      for(i=1;i<=MomPeriod;i++) GBP[Bars-i]=0.0;
//----

    int limia=Bars-counted_bars;
   if(counted_bars>1) limia++;
   for(a=0; a<MomPeriod; a++)
   ac_gbpusd[a] = iAD("GBPUSD",0,a);
   
   int limie=Bars-counted_bars;
   if(counted_bars>1) limie++;
   for(e=0; e<MomPeriod; e++)
   ac_eurgbp[e] = iAD("EURGBP",0,e);

  
   int limih=Bars-counted_bars;
   if(counted_bars>1) limih++;
   for(h=0; h<MomPeriod; h++)
   ac_gbpjpy[h] = iAD("GBPJPY",0,h);
     
   int limij=Bars-counted_bars;
   if(counted_bars>1) limij++;
   for(j=0; j<MomPeriod; j++)
   ac_gbpchf[j] = iAD("GBPCHF",0,j);

//----
//----
   i=Bars-MomPeriod-1;
   if(counted_bars>=MomPeriod) i=Bars-counted_bars-1;
   while(i>=0)
     {
GBP[i] = ac_gbpusd[i] + ac_gbpchf[i] - ac_eurgbp[i] + ac_gbpjpy[i] ;

    i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+