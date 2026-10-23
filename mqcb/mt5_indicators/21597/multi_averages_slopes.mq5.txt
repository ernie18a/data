//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Multi averages slopes"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_label1  "Multi averages slopes up"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrLimeGreen
#property indicator_width1  2
#property indicator_label2  "Multi averages slopes down"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrCrimson
#property indicator_width2  2
//
//---
//
enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };
//
//---
//
input enMaTypes          inpMaType  = ma_ema; // Averages types
input int                inpPeriod1 =  8; // Period 1
input int                inpPeriod2 = 11; // Period 2
input int                inpPeriod3 = 14; // Period 3
input int                inpPeriod4 = 17; // Period 4
input int                inpPeriod5 = 20; // Period 5
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE; // Price

double histou[],histod[],averages[][5];
string _averageNames[] = {"SMA","EMA","SMMA","LWMA"};
//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,histou,INDICATOR_DATA); 
   SetIndexBuffer(1,histod,INDICATOR_DATA); 
   IndicatorSetString(INDICATOR_SHORTNAME,"Multi "+_averageNames[inpMaType]+" slopes ("+string(inpPeriod1)+","+string(inpPeriod2)+","+string(inpPeriod3)+","+string(inpPeriod4)+","+string(inpPeriod5)+")");
   return(INIT_SUCCEEDED);
}
//
//---
//
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   if (ArrayRange(averages,0)!=rates_total) ArrayResize(averages,rates_total);
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
   {
      double _price = getPrice(inpPrice,open,close,high,low,i,rates_total);
      averages[i][0] = iCustomMa(inpMaType,_price,inpPeriod1,i,rates_total,0);
      averages[i][1] = iCustomMa(inpMaType,_price,inpPeriod2,i,rates_total,1);
      averages[i][2] = iCustomMa(inpMaType,_price,inpPeriod3,i,rates_total,2);
      averages[i][3] = iCustomMa(inpMaType,_price,inpPeriod4,i,rates_total,3);
      averages[i][4] = iCustomMa(inpMaType,_price,inpPeriod5,i,rates_total,4);
         histou[i] = histod[i] = 0;
         if (i>0)
         {
            if (averages[i][0]>averages[i-1][0]) histou[i]++;
            if (averages[i][0]<averages[i-1][0]) histod[i]--;
            if (averages[i][1]>averages[i-1][1]) histou[i]++;
            if (averages[i][1]<averages[i-1][1]) histod[i]--;
            if (averages[i][2]>averages[i-1][2]) histou[i]++;
            if (averages[i][2]<averages[i-1][2]) histod[i]--;
            if (averages[i][3]>averages[i-1][3]) histou[i]++;
            if (averages[i][3]<averages[i-1][3]) histod[i]--;
            if (averages[i][4]>averages[i-1][4]) histou[i]++;
            if (averages[i][4]<averages[i-1][4]) histod[i]--;
         }
   }      
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _maInstances 5
#define _maWorkBufferx1 1*_maInstances
//
//---
//
double iCustomMa(int mode,double price,double length,int r,int bars,int instanceNo=0)
  {
   switch(mode)
     {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      default       : return(price);
     }
  }
//
//---
//
double workSma[][_maWorkBufferx1];
//
//---
//
double iSma(double price,int period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars); int k;

   workSma[r][instanceNo+0]=price;
   double avg=price; for(k=1; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo+0];
   return(avg/k);
  }
//
//---
//
double workEma[][_maWorkBufferx1];
//
//---
//
double iEma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=_bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo]=price;
   if(r>0 && period>1)
      workEma[r][instanceNo]=workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
  }
//
//---
//
double workSmma[][_maWorkBufferx1];
//
//---
//
double iSmma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSmma,0)!=_bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo]=price;
   if(r>1 && period>1)
      workSmma[r][instanceNo]=workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
  }
//
//---
//
double workLwma[][_maWorkBufferx1];
//
//---
//
double iLwma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workLwma,0)!=_bars) ArrayResize(workLwma,_bars);

   workLwma[r][instanceNo] = price; if(period<=1) return(price);
   double sumw = period;
   double sum  = period*price;

   for(int k=1; k<period && (r-k)>=0; k++)
     {
      double weight = period-k;
      sumw  += weight;
      sum   += weight*workLwma[r-k][instanceNo];
     }
   return(sum/sumw);
  }
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   if(i>=0)
      switch(tprice)
        {
         case PRICE_CLOSE:     return(close[i]);
         case PRICE_OPEN:      return(open[i]);
         case PRICE_HIGH:      return(high[i]);
         case PRICE_LOW:       return(low[i]);
         case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
         case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
         case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
        }
   return(0);
  }
//+------------------------------------------------------------------+