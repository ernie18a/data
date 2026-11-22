//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Pearson coeficcient"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   4
#property indicator_label1  "Level up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrForestGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Middle level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Level down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrCrimson
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Pearson coeficcient"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrCrimson,clrForestGreen
#property indicator_width4  2
//--- input parameters
enum enColorMode
{
   col_onZero, // Change color on middle line cross
   col_onOuter // Change color on outer levels cross
};
input string             inpSymbol      = "";          // Second symbol
input int                inpPeriod      = 30;          // Period
input int                inpLag         = 1;           // Lag of the second symbol
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE; // Price
input enColorMode        inpColorMode   = col_onOuter; // Change color mode 
//--- indicator buffers
double val[],valc[],flup[],flmi[],fldn[],diff[],difl[];
string _forSymbol;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,flup,INDICATOR_DATA);
   SetIndexBuffer(1,flmi,INDICATOR_DATA);
   SetIndexBuffer(2,fldn,INDICATOR_DATA);
   SetIndexBuffer(3,val,INDICATOR_DATA);
   SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,diff,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,difl,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   _forSymbol = (inpSymbol=="") ? _Symbol : inpSymbol;
   IndicatorSetString(INDICATOR_SHORTNAME,"Pearson "+_Symbol+" to "+_forSymbol+" coeficcient ("+(string)inpPeriod+","+(string)inpLag+")");
//---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   
   //
   //---
   //

   double pers = MathSqrt(inpPeriod);
      MqlRates _ratesf[1];
      MqlRates _ratesl[1];
      for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !_StopFlag; i++)
      {
         int _ratesfCopied =               CopyRates(_Symbol   ,0,time[i       ],1,_ratesf);
         int _rateslCopied = (i>=inpLag) ? CopyRates(_forSymbol,0,time[i-inpLag],1,_ratesl) : CopyRates(_forSymbol,0,time[i],1,_ratesl);
         diff[i] = (_ratesfCopied == 1) ? getPrice(inpPrice,_ratesf) : 0;
         difl[i] = (_rateslCopied == 1) ? getPrice(inpPrice,_ratesl) : 0;
            double dev1 = iDeviation(diff,inpPeriod,i);
            double dev2 = iDeviation(difl,inpPeriod,i);
                   val[i]  = (dev1!=0 && dev2!=0) ? iCovariance(diff,difl,inpPeriod,i)/(dev1*dev2) : 0;
            double pe      = 0.6745*(1.0-val[i]*val[i])/pers;
            flup[i] =  6.0*pe;
            fldn[i] = -6.0*pe;
            flmi[i] =       0;
            switch (inpColorMode)
            {
               case col_onOuter : valc[i] = (val[i]>flup[i]) ? 2 :(val[i]<fldn[i]) ? 1 : 0; break;
               case col_onZero  : valc[i] = (val[i]>flmi[i]) ? 2 :(val[i]<flmi[i]) ? 1 : (i>0) ? valc[i-1]: 0; break;
            }            
      }
   return(rates_total);
  }
  
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double iDeviation(double& array[], int size, int i, bool isSample = false)
{
   double avg = array[i]; for (int k=1; k<size && (i-k)>=0; k++) avg  += array[i-k];  avg /= (double)size;
   double sum = 0;
      for (int k=0; k<size&& (i-k)>=0; k++) sum += (array[i-k]-avg)*(array[i-k]-avg);
   
      if (isSample)         
            return(MathSqrt(sum/(double)(size-1)));
      else  return(MathSqrt(sum/(double)(size)));
}
//
//---
//
double iCovariance(double& indep[], double& depen[], int size, int i, bool isSample = false)
{
   double avgi = indep[i]; for (int k=1; k<size && (i-k)>=0; k++) avgi += indep[i-k]; avgi /= size;
   double avgd = depen[i]; for (int k=1; k<size && (i-k)>=0; k++) avgd += depen[i-k]; avgd /= size;
   double sum = 0;
      for (int k=0; k<size && (i-k)>=0; k++) sum += (indep[i-k]-avgi)*(depen[i-k]-avgd);

      if (isSample)         
            return(sum/(size-1));
      else  return(sum/(size));
} 
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice, MqlRates& _rates[])
  {
      switch(tprice)
        {
         case PRICE_CLOSE:     return(_rates[0].close);
         case PRICE_OPEN:      return(_rates[0].open);
         case PRICE_HIGH:      return(_rates[0].high);
         case PRICE_LOW:       return(_rates[0].low);
         case PRICE_MEDIAN:    return((_rates[0].high+_rates[0].low)/2.0);
         case PRICE_TYPICAL:   return((_rates[0].high+_rates[0].low+_rates[0].close)/3.0);
         case PRICE_WEIGHTED:  return((_rates[0].high+_rates[0].low+_rates[0].close+_rates[0].close)/4.0);
        }
        return(0);
  }
//+------------------------------------------------------------------+