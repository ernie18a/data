//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Variance"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "Variance"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue

//
//
//

input int inpVarPeriod = 14; // Variance period

double val[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val ,INDICATOR_DATA);

      //
      //
      //
      
      iVariance.init(inpVarPeriod);
   IndicatorSetString(INDICATOR_SHORTNAME,"Variance ("+(string)inpVarPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++) 
   { 
      val[i] = iVariance.calculate(close[i],i,rates_total); 
   }
   return(i);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

class CVariance
{
   private :
         int    m_period;
         struct sVarStruct
         {
            double value;
         };
         sVarStruct m_array[];
         int        m_arraySize;
   public :
      CVariance() : m_period(1), m_arraySize(-1) { return; }
     ~CVariance()                                { return; }
     
     //
     //---
     //
     
     void init(int period)
         {
            m_period = (period>1) ? period : 1;
         }
      double calculate(double value, int i, int bars)
         {
            if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }
            
            //
            //
            //
            
            m_array[i].value = value;
            double _m=0,_s=0,_oldm=0;
            for (int k=0; k<m_period && i>=k; k++)
            {
               _oldm = _m;
               _m    = _m+(m_array[i-k].value-_m)/(1.0+k);
               _s    = _s+(m_array[i-k].value-_m)*(m_array[i-k].value-_oldm);
            }
            return(_s/(m_period-1));
         }   
};
CVariance iVariance;