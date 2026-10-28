//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Triple Exponential Average using double smoothed Wilder's EMA"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDimGray,clrMediumSeaGreen,clrRed
#property indicator_width1  2
#property indicator_label1  "TRIX"
#property indicator_applied_price PRICE_CLOSE

//
//--- input parameters
//

input int inpPeriodEma=14; // EMA period

//
//--- indicator buffers
//

double val[],valc[];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
//
//
//

void OnInit()
{
   SetIndexBuffer(0,val ,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
      iTrix.init(inpPeriodEma);
   IndicatorSetString(INDICATOR_SHORTNAME,"TRIX (ds Wilder\'s EMA)("+string(inpPeriodEma)+")");
}

//------------------------------------------------------------------
// Triple Exponential Average
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      val[i]  = iTrix.calculate(price[i],i,rates_total);
      valc[i] = val[i]>0 ? 1 : val[i]<0 ? 2 : 0;
   }      
   return(rates_total);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

class CTrixDsWilders
{
   private :
      double m_period;
      double m_alpha;
      int    m_arraySize;
      struct sTrixDsWildersStruct
      {
         double price;
         double ema10;
         double ema11;
         double ema20;
         double ema21;
         double ema30;
         double ema31;
      };
      sTrixDsWildersStruct m_array[];
   
   public :
      CTrixDsWilders() : m_arraySize(-1), m_alpha(1) {}
     ~CTrixDsWilders() { ArrayFree(m_array); };
      
      //
      //
      //
      
      bool init(int period)
      {
         m_period = (period>1) ? period : 1;
         m_alpha  = 2.0/(1.0+MathSqrt(m_period));
            return(true);
      }
      
      double calculate(double price, int i, int bars)
      {
          if (m_arraySize<bars)
            { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }

         //
         //---
         //
      
         if (i>0)
         {
            m_array[i].ema10 = m_array[i-1].ema10 + m_alpha*(price           -m_array[i-1].ema10);
            m_array[i].ema11 = m_array[i-1].ema11 + m_alpha*(m_array[i].ema10-m_array[i-1].ema11);
            m_array[i].ema20 = m_array[i-1].ema20 + m_alpha*(m_array[i].ema11-m_array[i-1].ema20);
            m_array[i].ema21 = m_array[i-1].ema21 + m_alpha*(m_array[i].ema20-m_array[i-1].ema21);
            m_array[i].ema30 = m_array[i-1].ema30 + m_alpha*(m_array[i].ema21-m_array[i-1].ema30);
            m_array[i].ema31 = m_array[i-1].ema31 + m_alpha*(m_array[i].ema30-m_array[i-1].ema31);
               return((m_array[i].ema31-m_array[i-1].ema31)/m_array[i].ema31);
         }
         else m_array[i].ema10 = m_array[i].ema11 = m_array[i].ema20 = m_array[i].ema21 = m_array[i].ema30 = m_array[i].ema31 = price;
               return(0);
      }
};
CTrixDsWilders iTrix;