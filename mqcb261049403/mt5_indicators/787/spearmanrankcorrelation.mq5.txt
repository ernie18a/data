//+------------------------------------------------------------------+
//|                                      SpearmanRankCorrelation.mq5 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
// http://www.infamed.com/stat/s05.html
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
//---- indicator version
#property version   "1.00"
//---- plot in a separate window
#property indicator_separate_window
//---- number of buffers used
#property indicator_buffers 1
//---- number of plots used
#property indicator_plots   1
//---- drawing style - line
#property indicator_type1   DRAW_LINE
//---- line color - Magenta
#property indicator_color1  Magenta
//---- line style - solid line
#property indicator_style1  STYLE_SOLID
//---- line width - 2
#property indicator_width1  2
//---- indicator minimum/maximum values
#property indicator_minimum -1
#property indicator_maximum +1
//---- horizontal levels
#property indicator_level1  +0.50
#property indicator_level2   0
#property indicator_level3  -0.50
#property indicator_levelcolor Blue
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input int  rangeN=14;
input int  CalculatedBars=0;
input int  Maxrange=30;
input bool direction=true;
//+----------------------------------------------+
//---- declaration of dynamic array, used as indicator buffer
double ExtLineBuffer[];
//----
double multiply;
double R2[],TrueRanks[];
int    PriceInt[],SortInt[],Maxrange_;
//+------------------------------------------------------------------+
//| calculate  RSP  function                                         |
//+------------------------------------------------------------------+
double SpearmanRankCorrelation(double &Ranks[],int N)
  {
//----
   double res,z2=0.0;

   for(int iii=0; iii<N; iii++) z2+=MathPow(Ranks[iii]-iii-1,2);
   res=1-6*z2/(MathPow(N,3)-N);
//----
   return(res);
  }
//+------------------------------------------------------------------+
//| Ranking array of prices function                                 |
//+------------------------------------------------------------------+
void RankPrices(double &TrueRanks_[],int &InitialArray[])
  {
//----
   int i,k,m,dublicat,counter,etalon;
   double dcounter,averageRank;

   ArrayCopy(SortInt,InitialArray,0,0,WHOLE_ARRAY);

   for(i=0; i<rangeN; i++) TrueRanks_[i]=i+1;
   
   ArraySort(SortInt);
   
   for(i=0; i<rangeN-1; i++)
     {
      if(SortInt[i]!=SortInt[i+1]) continue;

      dublicat=SortInt[i];
      k=i+1;
      counter=1;
      averageRank=i+1;

      while(k<rangeN)
        {
         if(SortInt[k]==dublicat)
           {
            counter++;
            averageRank+=k+1;
            k++;
           }
         else
            break;
        }
      dcounter=counter;
      averageRank=averageRank/dcounter;

      for(m=i; m<k; m++)
         TrueRanks_[m]=averageRank;
      i=k;
     }
   for(i=0; i<rangeN; i++)
     {
      etalon=InitialArray[i];
      k=0;
      while(k<rangeN)
        {
         if(etalon==SortInt[k])
           {
            R2[i]=TrueRanks_[k];
            break;
           }
         k++;
        }
     }
//----
   return;
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- prepare arrays
   ArrayResize(R2,rangeN);
   ArrayResize(PriceInt,rangeN);
   ArrayResize(SortInt,rangeN);
   
   ArrayInitialize(R2,0);
   ArrayInitialize(PriceInt,0);
   ArrayInitialize(PriceInt,0);
   
//---- set indexing as series
   if(direction) ArraySetAsSeries(SortInt,true);
   ArrayResize(TrueRanks,rangeN);
   ArrayInitialize(TrueRanks,0);
//---- initalize variables
   if(Maxrange<=0)
      Maxrange_=10;
   else Maxrange_=Maxrange;
   multiply=MathPow(10,_Digits);
//---- set ExtLineBuffer[] as indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- set plot draw begin
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rangeN);
//---- set indexing as time series
   ArraySetAsSeries(ExtLineBuffer,true);
//---- prepare indicator short name
   string shortname;
   if(rangeN>Maxrange_)
      shortname="Decrease rangeN input!";
   else StringConcatenate(shortname,"Spearman(",rangeN,")");
//--- set label
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//--- set indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- set precision
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- define empty values
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initialization finished
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at current tick
                const int prev_calculated,// number of bars in history at previous call
                const int begin,          // starting index
                const double &price[]     // price array
                )
  {
//---- checking of bars
   if(rates_total<rangeN+begin) return(0);

   if(rangeN>Maxrange_) return(0);

//---- declaration of local variables
   int limit;

//---- calculation of starting index
   if(prev_calculated>rates_total || prev_calculated<=0) // checking of first call
     {
      limit=rates_total-2-rangeN-begin; // starting index for all bars
      //--- increase position to "plot draw begin" bar
      if(begin>0) PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rangeN+begin);
     }
   else
     {
      if(CalculatedBars==0)
         limit = rates_total - prev_calculated;
      else limit = CalculatedBars;
     }

//---- set indexing as time series
   ArraySetAsSeries(price,true);

//---- calculation of indicator values
   for(int bar=limit; bar>=0; bar--)
     {
      for(int k=0; k<rangeN; k++) PriceInt[k]=int(price[bar+k]*multiply);

      RankPrices(TrueRanks,PriceInt);
      ExtLineBuffer[bar]=SpearmanRankCorrelation(R2,rangeN);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+