//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Chande\'s DMI with discontinued signal lines"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_label1  "Upper level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Middle level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Lower level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Chande DMI"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width4  2

//
//
//


input int                 inpDMIPeriod       = 15;           // DMI period
input int                 inpDmiLowerLimit   = 10;           // DMI lower bound
input int                 inpDmiUpperLimit   = 50;           // DMI upper bound
input ENUM_APPLIED_PRICE  inpPrice           = PRICE_CLOSE;  // Price 
input int                 inpDevPeriod       = 10;           // Period of smoothing
enum enColorChangeOn
{
   cchange_onSlope,  // Change color on slope change
   cchange_onLevels, // Change color on outer levels cross
   cchange_onZero    // Change color on middle level cross
};
input int                inpDslPeriod   = 10;               // DSL period
input enColorChangeOn    inpColorChange = cchange_onLevels; // Color changing mode

//
//---
//

double val[],valc[],levu[],levd[],levm[],m_array[][13],_dslPeriod;

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
         SetIndexBuffer(0,levu,INDICATOR_DATA);
         SetIndexBuffer(1,levm,INDICATOR_DATA);
         SetIndexBuffer(2,levd,INDICATOR_DATA);
         SetIndexBuffer(3,val ,INDICATOR_DATA);
         SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX); 

      //
      //
      //

      iVolatilityRatio.init(inpDevPeriod);
         _dslPeriod = (inpDslPeriod>1 ? inpDslPeriod : 1);
         IndicatorSetString(INDICATOR_SHORTNAME,"Chandes DMI ("+(string)inpDMIPeriod+","+(string)inpDslPeriod+")");
   return(0);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
#define _setPrice(_priceType,_target,_index) \
   { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _target = close[_index];                                              break; \
      case PRICE_OPEN:     _target = open[_index];                                               break; \
      case PRICE_HIGH:     _target = high[_index];                                               break; \
      case PRICE_LOW:      _target = low[_index];                                                break; \
      case PRICE_MEDIAN:   _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}

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
   static int m_arraySize = -1;
          if (m_arraySize<rates_total) { m_arraySize = ArrayResize(m_array,rates_total+500); if (m_arraySize<rates_total) return(0); }

   //
   //---
   //
   
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      double vr = iVolatilityRatio.calculate(_price,i,rates_total);
      double td = (inpDMIPeriod/vr);
             if (td>inpDmiUpperLimit) td=inpDmiUpperLimit;
             if (td<inpDmiLowerLimit) td=inpDmiLowerLimit;
      double kg = (3.0)/(2.0+td);
      double hg = 1.0-kg;

      //
      //---
      //
         
         m_array[i][12] = _price;
         if (i>0) 
         {
               double mom = m_array[i][12]-m_array[i-1][12];
               double moa = (mom>0) ? mom : -mom;

               #define _mom(_a,_b) (1.5*m_array[i][_a] - 0.5*m_array[i][_b])

                  m_array[i][ 0] = kg*mom                + hg*m_array[i-1][ 0];
                  m_array[i][ 1] = kg*m_array[i][ 0] + hg*m_array[i-1][ 1];
                  m_array[i][ 2] = kg*_mom(0,1)          + hg*m_array[i-1][ 2];
                  m_array[i][ 3] = kg*m_array[i][ 2] + hg*m_array[i-1][ 3];
                  m_array[i][ 4] = kg*_mom(2,3)          + hg*m_array[i-1][ 4];
                  m_array[i][ 5] = kg*m_array[i][ 4] + hg*m_array[i-1][ 5];
                  m_array[i][ 6] = kg*moa                + hg*m_array[i-1][ 6];
                  m_array[i][ 7] = kg*m_array[i][ 6] + hg*m_array[i-1][ 7];
                  m_array[i][ 8] = kg*_mom(6,7)          + hg*m_array[i-1][ 8];
                  m_array[i][ 9] = kg*m_array[i][ 8] + hg*m_array[i-1][ 9]; 
                  m_array[i][10] = kg*_mom(8,9)          + hg*m_array[i-1][10];
                  m_array[i][11] = kg*m_array[i][10] + hg*m_array[i-1][11]; 

                  mom = _mom( 4, 5);
                  moa = _mom(10,11);
                  #undef _mom

            //
            //---
            //
            
            val[i]  = (mom/(moa>DBL_MIN?moa:DBL_MIN)+1.0)*50.0; 
            double _alpha = 2.0 / (1.0 + _dslPeriod/vr);
            levu[i] = (val[i]>50) ?  levu[i-1]+_alpha*(val[i]-levu[i-1]) : levu[i-1]; 
            levd[i] = (val[i]<50) ?  levd[i-1]+_alpha*(val[i]-levd[i-1]) : levd[i-1]; 
            levm[i] = (levu[i]+levd[i])/2.0;
         }
         else { for (int k=0; k<12; k++) m_array[i][k] = 0; levm[i] = levu[i] = levd[i] = val[i] = 0; }
         
      //
      //---
      //
               
         switch (inpColorChange)
         {
            case cchange_onLevels : valc[i] = (val[i]>levu[i]) ? 1 :(val[i]<levd[i]) ? 2 : 0; break;
            case cchange_onSlope  : valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
            case cchange_onZero   : valc[i] = (val[i]>levm[i]) ? 1 :(val[i]<levm[i]) ? 2 : 0; break;
         }         
   }      
   return(i);
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
      int m_period;
      int m_arraySize;
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
      cStdDevVolatilityRatio() : m_arraySize(-1) {  }
     ~cStdDevVolatilityRatio()                   { ArrayFree(m_array); }

      //
      //---
      //

      void init(int period)
      {
         m_period = (period>1) ? period : 1;
      }
      
      double calculate(double price, int i, int bars)
      {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }

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

            return(m_array[i].sumd > 0 ? (double)m_period*m_array[i].deviation/m_array[i].sumd : 1);
      }
};
cStdDevVolatilityRatio iVolatilityRatio;
