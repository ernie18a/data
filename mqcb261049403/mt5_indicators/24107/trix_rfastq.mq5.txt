//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Triple Exponential Average using fast ema version"
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
   IndicatorSetString(INDICATOR_SHORTNAME,"TRIX (fast EMA)("+string(inpPeriodEma)+")");
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

class CTrix
{
   private :
      double m_period;
      double m_alpha;
      int    m_arraySize;
      struct sTrixStruct
      {
         double price;
         double ema1;
         double ema2;
         double ema3;
      };
      sTrixStruct m_array[];
   
   public :
      CTrix() : m_arraySize(-1), m_alpha(1) {}
     ~CTrix() { ArrayFree(m_array); };
      
      //
      //
      //
      
      bool init(int period)
      {
         m_period = (period>1) ? period : 1;
         m_alpha  = (2.0/(2.0+(m_period-1.0)/2.0));
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
            m_array[i].ema1 = m_array[i-1].ema1 + m_alpha*(price          -m_array[i-1].ema1);
            m_array[i].ema2 = m_array[i-1].ema2 + m_alpha*(m_array[i].ema1-m_array[i-1].ema2);
            m_array[i].ema3 = m_array[i-1].ema3 + m_alpha*(m_array[i].ema2-m_array[i-1].ema3);
               return((m_array[i].ema3-m_array[i-1].ema3)/m_array[i].ema3);
         }
         else m_array[i].ema1 = m_array[i].ema2 = m_array[i].ema3 = price;
               return(0);
      }
};
CTrix iTrix;