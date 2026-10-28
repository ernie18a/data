//------------------------------------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
//------------------------------------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers  6
#property indicator_plots    4
#property indicator_label1   "Uper DC"
#property indicator_type1    DRAW_FILLING
#property indicator_color1   clrBisque
#property indicator_label2   "Lower DC"
#property indicator_type2    DRAW_FILLING
#property indicator_color2   clrPaleGreen
#property indicator_label3   "Rex"
#property indicator_type3    DRAW_LINE
#property indicator_color3   clrDarkOrange
#property indicator_width3   2
#property indicator_label4   "Rex signal"
#property indicator_type4    DRAW_LINE
#property indicator_color4   clrDarkGray

//
//
//

input uint           inpPeriod    = 14;         // Rex period
input ENUM_MA_METHOD inpMethod    = MODE_SMA;   // Rex method
input uint           inpPeriodSig = 14;         // Signal period
input ENUM_MA_METHOD inpMethodSig = MODE_SMA;   // Signal method
input uint           inpDcPeriod  = 89;         // Donchian channel period

//
//
//

double val[],sig[],dcuph[],dcupl[],dcdnh[],dcdnl[];
#define _maName(_method) StringSubstr(EnumToString(_method),5)
typedef double (*TAverage)(double price, int period, int index, int bars, int instance=0); TAverage rexAverage,sigAverage;

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
   SetIndexBuffer(5,sig  ,INDICATOR_DATA);
   
      //
      //
      //

      switch (inpMethod)
         {
            case MODE_SMA  : rexAverage = iSma;  break;
            case MODE_EMA  : rexAverage = iEma;  break;
            case MODE_SMMA : rexAverage = iSmma; break;
            case MODE_LWMA : rexAverage = iLwma; break;
         }
      switch (inpMethodSig)
         {
            case MODE_SMA  : sigAverage = iSma;  break;
            case MODE_EMA  : sigAverage = iEma;  break;
            case MODE_SMMA : sigAverage = iSmma; break;
            case MODE_LWMA : sigAverage = iLwma; break;
         }
         
      //
      //
      //
               
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Rex (%i %s,%i %s, %i)",inpPeriod,_maName(inpMethod),inpPeriodSig,_maName(inpMethodSig),inpDcPeriod));            
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
                const int &spread[])
{
   int _limit = (prev_calculated>0) ? prev_calculated-1 : 0;

   //
   //
   //

      for (int i=_limit; i<rates_total; i++)
         {
            double _rexPrice = 3.0*close[i]-(low[i]+open[i]+high[i]);
               val[i] = rexAverage(_rexPrice,inpPeriod   ,i,rates_total,0);
               sig[i] = sigAverage(val[i]   ,inpPeriodSig,i,rates_total,1);
               
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
               }
               else dcuph[i] = dcupl[i] = dcdnh[i] = dcdnl[i] = EMPTY_VALUE;                     
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

#define _maInstances 2
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