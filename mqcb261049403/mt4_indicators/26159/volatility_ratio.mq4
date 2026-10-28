//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Volatility ratio"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_label1  "Volatility ratio"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2
#property indicator_label2  "Volatility ratio - bellow zero"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_width2  2
#property indicator_label3  "Volatility ratio - bellow zero"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrangeRed
#property indicator_width3  2
#property strict

//
//
//


input int                inpPeriod = 25;          // Volatility period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price 

//
//---
//

double val[],valda[],valdb[],valc[];

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
int OnInit()
{
   //
   //--- indicator buffers mapping
   //
      IndicatorBuffers(4);
         SetIndexBuffer(0,val  ,INDICATOR_DATA);
         SetIndexBuffer(1,valda,INDICATOR_DATA);
         SetIndexBuffer(2,valdb,INDICATOR_DATA);
         SetIndexBuffer(3,valc ,INDICATOR_CALCULATIONS); 

      //
      //
      //

      iVolatilityRatio.init(inpPeriod);
         IndicatorSetString(INDICATOR_SHORTNAME,"Volatility ratio ("+(string)inpPeriod+")");
   return(0);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
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
   int limit= MathMin(rates_total-prev_calculated+1,rates_total-1); 

   //
   //
   //
   
   if (valc[limit]==2) iCleanPoint(limit,valda,valdb);
   for (int i=limit; i>=0 && !_StopFlag; i--)
   {
         valda[i] = valdb[i] = EMPTY_VALUE;
         val[i]   = iVolatilityRatio.calculate(iMA(_Symbol,_Period,1,0,MODE_SMA,inpPrice,i),rates_total-i-1,rates_total);
         valc[i]  = (val[i]>1) ? 1 :(val[i]<1) ? 2 : 0;
         if (valc[i]==2) iPlotPoint(i,valda,valdb,val);
   }      
   return(rates_total);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//

class cStdDevVolatilityRatio
{
   private :
      int    m_period;
      int    m_arraySize;
         struct sStdDevVolatilityRatioStruct
         {
            public :
               double price;
               double price2;
               double sum;
               double sum2;
               double sumd;
               double deviation;
         };
      sStdDevVolatilityRatioStruct m_array[];
   public:
      cStdDevVolatilityRatio() : m_period(1), m_arraySize(-1) {  }
     ~cStdDevVolatilityRatio()                                { ArrayFree(m_array); }

      //
      //---
      //

      void init(int period)
      {
         m_period  = (period>1) ? period : 1;
      }
      
      double calculate(double price, int i, int bars)
      {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500,10000); if (m_arraySize<bars) return(0); }

            m_array[i].price =price;
            m_array[i].price2=price*price;
            
            //
            //---
            //
            
            if (i>m_period)
            {
                  m_array[i].sum  = m_array[i-1].sum +m_array[i].price -m_array[i-m_period].price;
                  m_array[i].sum2 = m_array[i-1].sum2+m_array[i].price2-m_array[i-m_period].price2;
            }
            else  
            {
                  m_array[i].sum  = m_array[i].price;
                  m_array[i].sum2 = m_array[i].price2; 
                  for(int k=1; k<m_period && i>=k; k++) 
                  {
                        m_array[i].sum  += m_array[i-k].price; 
                        m_array[i].sum2 += m_array[i-k].price2; 
                  }                  
            }         
            m_array[i].deviation = (MathSqrt((m_array[i].sum2-m_array[i].sum*m_array[i].sum/(double)m_period)/(double)m_period));
            if (i>m_period) 
                  m_array[i].sumd  = m_array[i-1].sumd +m_array[i].deviation -m_array[i-m_period].deviation;
            else
            {
                  m_array[i].sumd = m_array[i].deviation;
                  for(int k=1; k<m_period && i>=k; k++) 
                        m_array[i].sumd += m_array[i-k].deviation; 
            }

            double deviationAverage = m_array[i].sumd/(double)m_period;
            return(deviationAverage != 0 ? m_array[i].deviation/deviationAverage : 1);
      }
};
cStdDevVolatilityRatio iVolatilityRatio;

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//

void iCleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void iPlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}
