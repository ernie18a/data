//------------------------------------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
//------------------------------------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers  6
#property indicator_plots    3
#property indicator_label1   "Uper DC"
#property indicator_type1    DRAW_FILLING
#property indicator_color1   C'200,225,200'
#property indicator_label2   "Lower DC"
#property indicator_type2    DRAW_FILLING
#property indicator_color2   clrBisque
#property indicator_label3   "Cci"
#property indicator_type3    DRAW_COLOR_LINE
#property indicator_color3   clrSilver,clrMediumSeaGreen,clrLimeGreen,clrDarkOrange,clrOrange
#property indicator_width3   2

//
//
//

input int                inpPeriod      = 50;            // Period
input ENUM_APPLIED_PRICE inpPrice       = PRICE_TYPICAL; // Price
input int                inpPricePeriod = 0;             // Price smoothing period
input ENUM_MA_METHOD     inpMethod      = MODE_SMA;      // Method
input uint               inpDcPeriod    = 50;            // Donchian channel period

//
//
//

double val[],valc[],dcuph[],dcupl[],dcdnh[],dcdnl[];
#define _maName(_method) StringSubstr(EnumToString(_method),5)
typedef double (*TAverage)(double price, int period, int index, int bars, int instance=0); TAverage cciAverage;
struct sGlobalStruct
{
   int cciPeriod;
};
sGlobalStruct global;

//------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,dcuph,INDICATOR_DATA);
   SetIndexBuffer(1,dcupl,INDICATOR_DATA);
   SetIndexBuffer(2,dcdnh,INDICATOR_DATA);
   SetIndexBuffer(3,dcdnl,INDICATOR_DATA);
   SetIndexBuffer(4,val  ,INDICATOR_DATA);
   SetIndexBuffer(5,valc ,INDICATOR_COLOR_INDEX);
   
      //
      //
      //

      global.cciPeriod = MathMax(inpPeriod,1);
      switch (inpMethod)
         {
            case MODE_SMA  : cciAverage = iSma;  break;
            case MODE_EMA  : cciAverage = iEma;  break;
            case MODE_SMMA : cciAverage = iSmma; break;
            case MODE_LWMA : cciAverage = iLwma; break;
         }
         
      //
      //
      //

   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);               
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);               
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Cci (%i,%i %s)",inpPeriod,inpPricePeriod,_maName(inpMethod),inpDcPeriod));            
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
{
   int _limit = (prev_calculated>0) ? prev_calculated-1 : 0;

   //
   //
   //

      for (int i=_limit; i<rates_total && !_StopFlag; i++)
         {
            double _rawPrice = iGetPrice(inpPrice,open,high,low,close,i);
            double _price    = (inpPricePeriod>0) ? cciAverage(_rawPrice,inpPricePeriod,i,rates_total,0) : _rawPrice;
            double _priceAvg = cciAverage(_price,global.cciPeriod,i,rates_total,1);
            double _diff     = _price-_priceAvg;
            double _diffAvg  = cciAverage((_diff>0 ? _diff : -_diff),global.cciPeriod,i,rates_total,2);
               val[i] = _diff/_diffAvg;
               
               //
               //
               //
       
               if (inpDcPeriod>0)
               {
                  int _start = int(i-inpDcPeriod); if (_start<0) _start=0;
                     double _max = val[ArrayMaximum(val,_start,inpDcPeriod)];
                     double _min = val[ArrayMinimum(val,_start,inpDcPeriod)];
                     
                        dcuph[i] = _max; dcupl[i] = _max-(_max-_min)/5.0;
                        dcdnl[i] = _min; dcdnh[i] = _min+(_max-_min)/5.0;

                        //
                        //
                        //
                        
                        valc[i] = (val[i]>dcuph[i]) ? 2 : (val[i]>dcupl[i]) ? 1 : (val[i]<dcdnl[i]) ? 4: (val[i]<dcdnh[i]) ? 3 : 0;
               }
               else { dcuph[i] = dcupl[i] = dcdnh[i] = dcdnl[i] = EMPTY_VALUE; valc[i] = (val[i]>0) ? 1 : (val[i]<0) ? 3 : 0; }
         }

   //
   //
   //

   return(rates_total);
}


//------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------
//
//
//

#define _maInstances 3
double iSma(double value, int period, int i, int bars, int instanceNo=0)
{
   struct sdataStruct
         {
            double value;
            double valueSum;
         };
   struct sWorkStruct { sdataStruct data[_maInstances]; };
   static sWorkStruct m_work[];
   static int         m_workSize = -1;
                  if (m_workSize<bars) m_workSize = ArrayResize(m_work,bars+500,2000);         

   //
   //
   //

      m_work[i].data[instanceNo].value = value;
         if (i>=period)
               { m_work[i].data[instanceNo].valueSum = m_work[i-1].data[instanceNo].valueSum + m_work[i].data[instanceNo].value - m_work[i-period].data[instanceNo].value; }
         else  { m_work[i].data[instanceNo].valueSum = m_work[i].data[instanceNo].value; for (int k=1; k<period && i>=k; k++) m_work[i].data[instanceNo].valueSum += m_work[i-k].data[instanceNo].value; }
   return (period>0 ? m_work[i].data[instanceNo].valueSum/(double)period : m_work[i].data[instanceNo].value);
}

//
//
//

double iEma(double value, int period, int i, int bars, int instanceNo=0)
{
   struct sdataStruct
         {
            double ema;
         };
   struct sWorkStruct { sdataStruct data[_maInstances]; };
   static sWorkStruct m_work[];
   static int         m_workSize = -1;
                  if (m_workSize<bars) m_workSize = ArrayResize(m_work,bars+500,2000);         

   //
   //
   //

           m_work[i].data[instanceNo].ema = (i>0 && period >1) ? m_work[i-1].data[instanceNo].ema + (2.0 / (1.0 + (double)period))*(value - m_work[i-1].data[instanceNo].ema) : value;
   return (m_work[i].data[instanceNo].ema);
}

//
//
//

double iSmma(double value, int period, int i, int bars, int instanceNo=0)
{
   struct sdataStruct
         {
            double smma;
         };
   struct sWorkStruct { sdataStruct data[_maInstances]; };
   static sWorkStruct m_work[];
   static int         m_workSize = -1;
                  if (m_workSize<bars) m_workSize = ArrayResize(m_work,bars+500,2000);         

   //
   //
   //

           m_work[i].data[instanceNo].smma = (i>0 && period >1) ? m_work[i-1].data[instanceNo].smma + (value - m_work[i-1].data[instanceNo].smma)/(double)period : value;
   return (m_work[i].data[instanceNo].smma);
}

//
//
//

double iLwma(double value, int period, int i, int bars, int instanceNo=0)
{
   struct sdataStruct
         {
            double value;
         };
   struct sWorkStruct { sdataStruct data[_maInstances]; };
   static sWorkStruct m_work[];
   static int         m_workSize = -1;
                  if (m_workSize<bars) m_workSize = ArrayResize(m_work,bars+500,2000);         

   //
   //
   //

      m_work[i].data[instanceNo].value = value;
      
         //
         //
         //
         
         double sumw = period;
         double sum  = period*m_work[i].data[instanceNo].value;
            if (period>1)
                  for(int k=1; k<period && i>=k; k++)
                     {
                        double weight = period-k;
                               sumw += weight;
                               sum  += weight*m_work[i-k].data[instanceNo].value;  
                     }             
            else sumw = 1;
   return (sum/sumw);
}

//------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------
//
//
//

double iGetPrice(ENUM_APPLIED_PRICE price,const double& open[], const double& high[], const double& low[], const double& close[], int i)
{
   switch (price)
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