
#property copyright "Copyright © 2009, sHrung."
#property link      "http://www.something.com/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Tomato

//---- input parameters
extern int MomPeriod=1000;
//---- buffers
//--- currencies 
double JPY[];

//--- 
double ac_usdjpy[];
double ac_eurjpy[];
double ac_gbpjpy[], ac_chfjpy[];

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
   SetIndexBuffer(0,JPY);
   SetIndexBuffer(1,ac_eurjpy);
   SetIndexBuffer(2,ac_gbpjpy);
   SetIndexBuffer(3,ac_chfjpy);
   SetIndexBuffer(4,ac_usdjpy);
   
   
   
//---- name for DataWindow and indicator subwindow label
   short_name="Accu/Dist Graph JPY ("+MomPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"JPY");
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
      for(i=1;i<=MomPeriod;i++) JPY[Bars-i]=0.0;
//----

   
  
   int limih=Bars-counted_bars;
   if(counted_bars>1) limih++;
   for(h=0; h<MomPeriod; h++)
   ac_gbpjpy[h] = iAD("GBPJPY",0,h);
   
  int limic=Bars-counted_bars;
   if(counted_bars>1) limic++;
   for(c=0; c<MomPeriod; c++)
   ac_usdjpy[c] = iAD("USDJPY",0,c);
   
    int limif=Bars-counted_bars;
   if(counted_bars>1) limif++;
   for(f=0; f<MomPeriod; f++)
   ac_eurjpy[f] = iAD("EURJPY",0,f);
   
  
   int limii=Bars-counted_bars;
   if(counted_bars>1) limii++;
   for(ii=0; ii<MomPeriod; ii++)
   ac_chfjpy[ii] = iAD("CHFJPY",0,ii);
   
//----
//----
   i=Bars-MomPeriod-1;
   if(counted_bars>=MomPeriod) i=Bars-counted_bars-1;
   while(i>=0)
     {
JPY[i] =  - ac_usdjpy[i] - ac_eurjpy[i] - ac_gbpjpy[i] - ac_chfjpy[i];

    i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+