//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "iTrendd ADXVMA"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   5
#property indicator_label1  "iTrend up"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrLimeGreen,clrLimeGreen
#property indicator_label2  "iTrend down"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  clrDeepPink,clrDeepPink
#property indicator_label3  "iTrend line up"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkGray
#property indicator_width3  2
#property indicator_label4  "iTrend line down"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDarkGray
#property indicator_width4  2
#property indicator_label5  "iTrend"
#property indicator_type5   DRAW_COLOR_LINE
#property indicator_color5  clrDarkGray,clrLime,clrHotPink
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2

input int                ItPeriod          = 14;             // iTrend period
input ENUM_APPLIED_PRICE ItPrice           = PRICE_CLOSE;    // Price
input int                LevelBars         = 300;            // Look back period for levels
input double             LevelFactor       = 0.283;          // Levels factor

double itrend[],itrendc[],lup[],ldn[],fillu[],filluz[],filld[],filldz[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,fillu  ,INDICATOR_DATA);
   SetIndexBuffer(1,filluz ,INDICATOR_DATA);
   SetIndexBuffer(2,filld  ,INDICATOR_DATA);
   SetIndexBuffer(3,filldz ,INDICATOR_DATA);
   SetIndexBuffer(4,lup    ,INDICATOR_DATA);
   SetIndexBuffer(5,ldn    ,INDICATOR_DATA);
   SetIndexBuffer(6,itrend ,INDICATOR_DATA); 
   SetIndexBuffer(7,itrendc,INDICATOR_COLOR_INDEX); 
      PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
      PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
   IndicatorSetString(INDICATOR_SHORTNAME,"iTrend ADXVMA ("+(string)ItPeriod+")");
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
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
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
   {
      double ma = getPrice(ItPrice,open,close,high,low,i,rates_total);
      double mv = iAdxvma(ma,ItPeriod,i,rates_total,0);
             fillu[i] = (ma - mv);                lup[i] = fillu[i]; filluz[i] = 0;
             filld[i] = (-(low[i]+high[i]-2*mv)); ldn[i] = filld[i]; filldz[i] = 0;

             //
             //
             //
             //
             //
             
             double hi = MathMax(fillu[i],filld[i]);
                  for (int k=1; k<LevelBars && (i-k)>=0; k++) hi = MathMax(hi,MathMax(fillu[i-k],filld[i-k]));
                  itrend[i]  = hi*LevelFactor; 
                  itrendc[i] = (fillu[i]>itrend[i]) ? 1 : (filld[i]>itrend[i]) ? 2 : (i>0) ? itrendc[i-1] : 0;
   }
   return(rates_total);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//---
//
#define _adxVmaInstances 1
#define _adxVmaInstancesSize 7
double  adxvmaWork[][_adxVmaInstances*_adxVmaInstancesSize];
#define _adxvmaWprc 0
#define _adxvmaWpdm 1
#define _adxvmaWmdm 2
#define _adxvmaWpdi 3
#define _adxvmaWmdi 4
#define _adxvmaWout 5
#define _adxvmaWval 6
//
//--
//
double iAdxvma(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(adxvmaWork,0)!=bars) ArrayResize(adxvmaWork,bars); instanceNo*=_adxVmaInstancesSize;
//
//---
//
   adxvmaWork[r][instanceNo+_adxvmaWprc]=price;
   if(r<1)
     {
      adxvmaWork[r][instanceNo+_adxvmaWval]=adxvmaWork[r][instanceNo+_adxvmaWprc];
      return(adxvmaWork[r][_adxvmaWval]);
     }
//
//---
//
   double tpdm = 0;
   double tmdm = 0;
   double diff = adxvmaWork[r][instanceNo+_adxvmaWprc]-adxvmaWork[r-1][instanceNo+_adxvmaWprc];
   if(diff>0)
      tpdm =  diff;
   else  tmdm = -diff;
   adxvmaWork[r][instanceNo+_adxvmaWpdm] = ((period-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWpdm]+tpdm)/period;
   adxvmaWork[r][instanceNo+_adxvmaWmdm] = ((period-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWmdm]+tmdm)/period;
//
//---
//
   double trueRange = adxvmaWork[r][instanceNo+_adxvmaWpdm]+adxvmaWork[r][instanceNo+_adxvmaWmdm];
   double tpdi      = 0;
   double tmdi      = 0;
   if(trueRange>0)
     {
      tpdi = adxvmaWork[r][instanceNo+_adxvmaWpdm]/trueRange;
      tmdi = adxvmaWork[r][instanceNo+_adxvmaWmdm]/trueRange;
     }
   adxvmaWork[r][instanceNo+_adxvmaWpdi] = ((period-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWpdi]+tpdi)/period;
   adxvmaWork[r][instanceNo+_adxvmaWmdi] = ((period-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWmdi]+tmdi)/period;
//
//---
//
   double tout=0;
   if((adxvmaWork[r][instanceNo+_adxvmaWpdi]+adxvmaWork[r][instanceNo+_adxvmaWmdi])>0)
      tout=MathAbs(adxvmaWork[r][instanceNo+_adxvmaWpdi]-adxvmaWork[r][instanceNo+_adxvmaWmdi])/(adxvmaWork[r][instanceNo+_adxvmaWpdi]+adxvmaWork[r][instanceNo+_adxvmaWmdi]);
   adxvmaWork[r][instanceNo+_adxvmaWout]=((period-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWout]+tout)/period;
//
//---
//
   double thi = MathMax(adxvmaWork[r][instanceNo+_adxvmaWout],adxvmaWork[r-1][instanceNo+_adxvmaWout]);
   double tlo = MathMin(adxvmaWork[r][instanceNo+_adxvmaWout],adxvmaWork[r-1][instanceNo+_adxvmaWout]);
   for(int j=2; j<(int)period && r-j>=0; j++)
     {
      thi = MathMax(adxvmaWork[r-j][instanceNo+_adxvmaWout],thi);
      tlo = MathMin(adxvmaWork[r-j][instanceNo+_adxvmaWout],tlo);
     }
   double vi=0; if((thi-tlo)>0) vi=(adxvmaWork[r][instanceNo+_adxvmaWout]-tlo)/(thi-tlo);
//
//---
//
   adxvmaWork[r][instanceNo+_adxvmaWval]=((period-vi)*adxvmaWork[r-1][instanceNo+_adxvmaWval]+vi*adxvmaWork[r][instanceNo+_adxvmaWprc])/period;
   return(adxvmaWork[r][instanceNo+_adxvmaWval]);
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