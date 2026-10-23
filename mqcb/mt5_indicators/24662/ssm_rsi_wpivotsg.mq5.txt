//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   8
#property indicator_label8  "Ssm RSI"
#property indicator_type8   DRAW_COLOR_LINE
#property indicator_color8  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width8  2

//
//---
//

enum enTimeFrames
{
   tf_cu  = PERIOD_CURRENT, // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m2  = PERIOD_M2,      // 2 minutes
   tf_m3  = PERIOD_M3,      // 3 minutes
   tf_m4  = PERIOD_M4,      // 4 minutes
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m6  = PERIOD_M6,      // 6 minutes
   tf_m10 = PERIOD_M10,     // 10 minutes
   tf_m12 = PERIOD_M12,     // 12 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m20 = PERIOD_M20,     // 20 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h2  = PERIOD_H2,      // 2 hours
   tf_h3  = PERIOD_H3,      // 3 hours
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_h6  = PERIOD_H6,      // 6 hours
   tf_h8  = PERIOD_H8,      // 8 hours
   tf_h12 = PERIOD_H12,     // 12 hours
   tf_d1  = PERIOD_D1,      // daily
   tf_w1  = PERIOD_W1,      // weekly
   tf_mn  = PERIOD_MN1,     // monthly
   tf_cp1 = -1,             // Next higher time frame
   tf_cp2 = -2,             // Second higher time frame
   tf_cp3 = -3              // Third higher time frame
};
input enTimeFrames       inpTimeFrame = tf_h4;             // Time frame
input int                inpPeriod    = 50;                // Period
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE;       // Price
input color              inpColorSup  = clrOrangeRed;      // Support color
input color              inpColorRes  = clrMediumSeaGreen; // Resistance color
input color              inpColorPiv  = clrGray;           // Resistance color
enum enDisplayType
{
   type_1=0, // Display pivot only
   type_2=1, // Display pivot + SR 1
   type_3=2, // Display pivot + SR 1,2
   type_4=3, // Display pivot + SR 1,2,3
};
input enDisplayType inpDisplayType = type_3; // Display type

//
//---
//

double val[],valc[],sup1[],sup2[],sup3[],res1[],res2[],res3[],piv[];
ENUM_TIMEFRAMES _pivotsTimeFrame;

//------------------------------------------------------------------ 
//  Custom indicator initialization function
//------------------------------------------------------------------
//
//---
//

int OnInit()
{
   //
   //---- indicator buffers mapping
   //
         SetIndexBuffer(0,sup3,INDICATOR_DATA);
         SetIndexBuffer(1,sup2,INDICATOR_DATA);
         SetIndexBuffer(2,sup1,INDICATOR_DATA);
         SetIndexBuffer(3,piv ,INDICATOR_DATA);
         SetIndexBuffer(4,res1,INDICATOR_DATA);
         SetIndexBuffer(5,res2,INDICATOR_DATA);
         SetIndexBuffer(6,res3,INDICATOR_DATA);
         SetIndexBuffer(7,val ,INDICATOR_DATA);
         SetIndexBuffer(8,valc,INDICATOR_COLOR_INDEX);
            for (int i=0; i<7; i++)
            {
               switch (i)
               {
                  case 0 : 
                  case 1 : 
                  case 2 : PlotIndexSetInteger(i,PLOT_LINE_COLOR,inpColorSup); break;
                  case 3 : PlotIndexSetInteger(i,PLOT_LINE_COLOR,inpColorPiv); break;
                  case 4 : 
                  case 5 : 
                  case 6 : PlotIndexSetInteger(i,PLOT_LINE_COLOR,inpColorRes); break;
               }
               PlotIndexSetInteger(i,PLOT_DRAW_TYPE,DRAW_LINE);                
               PlotIndexSetInteger(i,PLOT_LINE_STYLE,STYLE_DOT);
               PlotIndexSetInteger(i,PLOT_SHOW_DATA,false);
            }
            
            iSsmRsi.init(inpPeriod);
            _pivotsTimeFrame = MathMax(_Period,timeFrameGet(inpTimeFrame));
   //            
   //----
   //
 
   IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(_pivotsTimeFrame)+" Ssm RSI ("+(string)inpPeriod+")");
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//  Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_where,_index) { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _where = close[_index];                                              break; \
      case PRICE_OPEN:     _where = open[_index];                                               break; \
      case PRICE_HIGH:     _where = high[_index];                                               break; \
      case PRICE_LOW:      _where = low[_index];                                                break; \
      case PRICE_MEDIAN:   _where = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _where = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _where = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _where = 0; \
   }}

//
//---
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   static int    prev_i=-1;
   static double prev_max=0,prev_min=0,prev_close=0;

   //
   //
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      val[i]  = iSsmRsi.caculate(_price,i);
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
      sup1[i] = sup2[i] = sup3[i] = res1[i] = res2[i] = res3[i] = EMPTY_VALUE;
      
      //
      //
      //
      
         if (prev_i!=i)
         {
            prev_i = i; 
               datetime _startTime = iTime(_Symbol,_pivotsTimeFrame,iBarShift(_Symbol,_pivotsTimeFrame,time[i])+1);
               datetime _endTime   = iTime(_Symbol,_pivotsTimeFrame,iBarShift(_Symbol,_pivotsTimeFrame,time[i]));
               int      _startBar  = iBarShift(_Symbol,_Period,_startTime);
               int      _endBar    = iBarShift(_Symbol,_Period,_endTime);
               if (_endBar < _startBar) 
               {
                  int _period = _startBar-_endBar;
                     prev_max = val[ArrayMaximum(val,rates_total-_startBar-1,_period)];
                     prev_min = val[ArrayMinimum(val,rates_total-_startBar-1,_period)];
               }                     
               prev_close = (_endBar>0) ? val[rates_total-_endBar-1] : val[i];
         }
         
         //
         //---
         //
         
            double range = (prev_max-prev_min);
            double pivot = (prev_max+prev_min+prev_close)/3.0;
            switch (inpDisplayType)
            {
               case 3 : 
                        res3[i] = pivot*2.0+prev_max-prev_min*2.0;
                        sup3[i] = pivot*2.0+prev_min-prev_max*2.0;
               case 2 :                         
                        res2[i] = pivot    +range;
                        sup2[i] = pivot    -range;
               case 1 :                         
                        res1[i] = pivot*2.0-prev_min;
                        sup1[i] = pivot*2.0-prev_max;
               case 0 : piv[i]  = pivot;
            }               
   }
   return(i);
}

//------------------------------------------------------------------
//  Custom function(s)
//------------------------------------------------------------------
//
//---
//

class CSsmRsi
{
   private :
      int    m_period;
      double m_coeff1;
      double m_coeff2;
      double m_coeff3;
      int    m_arraySize;
         struct sSsmRsiArrayStruct
         {
            double value;
            double diffp;
            double diffn;
            double sump;
            double sumn;
            double sumps;
            double sumns;
         };
      sSsmRsiArrayStruct m_array[];         

   public :
      CSsmRsi() {};
     ~CSsmRsi() { ArrayFree(m_array); };
     
      ///
      ///
      ///
     
      bool init(int period)
      {
           m_period = (period>1) ? period : 1;
           double a = MathExp(-1.414*M_PI/m_period);
               m_coeff2 = 2*a*MathCos(1.414*M_PI/m_period);
               m_coeff3 = -a*a;
               m_coeff1 = 1-m_coeff2-m_coeff3;      

            //
            //
            //
                              
            m_arraySize = m_period+32;
            if (ArrayResize(m_array,m_arraySize)!=m_arraySize) return(false);
                                                               return(true); 
      }

      double caculate(double value, int i)
      {
         int _indC = (i)%m_arraySize; m_array[_indC].value=value;
         int _indP = _indC-1; if (_indP<0) _indP += m_arraySize;
                          
         //
         //
         //
         
         if (i>m_period)
            {
               int _indF = (i-m_period)%m_arraySize; 
                  if (m_array[_indC].value > m_array[_indP].value)
                                 { m_array[_indC].diffp = m_array[_indC].value - m_array[_indP].value; m_array[_indC].diffn = 0; }
                           else  { m_array[_indC].diffn = m_array[_indP].value - m_array[_indC].value; m_array[_indC].diffp = 0; }
                  m_array[_indC].sump = m_array[_indP].sump + m_array[_indC].diffp - m_array[_indF].diffp;
                  m_array[_indC].sumn = m_array[_indP].sumn + m_array[_indC].diffn - m_array[_indF].diffn;
            }
         else
            {
               m_array[_indC].diffp = (i>0) ? (m_array[_indC].value>m_array[_indP].value) ? m_array[_indC].value - m_array[_indP].value : 0 : 0;
               m_array[_indC].diffn = (i>0) ? (m_array[_indC].value<m_array[_indP].value) ? m_array[_indP].value - m_array[_indC].value : 0 : 0;
               m_array[_indC].sump  = m_array[_indC].diffp;
               m_array[_indC].sumn  = m_array[_indC].diffn;
                  for (int k=1, _indF=_indP; k<m_period && i>=k; k++, _indF--)
                  {
                     m_array[_indC].sump += m_array[_indF].diffp;
                     m_array[_indC].sumn += m_array[_indF].diffn;
                  }
            }

            //
            //
            //
         
            if (i>1) 
            {
               m_array[_indC].sumps = m_coeff1*(m_array[_indC].sump+m_array[_indP].sump)/2.0 + m_coeff2*m_array[_indP].sumps + m_coeff3*m_array[(i-2)%m_arraySize].sumps;
               m_array[_indC].sumns = m_coeff1*(m_array[_indC].sumn+m_array[_indP].sumn)/2.0 + m_coeff2*m_array[_indP].sumns + m_coeff3*m_array[(i-2)%m_arraySize].sumns;
            }               
            else
            {
               m_array[_indC].sumps = m_array[_indC].sump;
               m_array[_indC].sumns = m_array[_indC].sumn;
            }               
            return((m_array[_indC].sumns!=0) ? 100.0-(100.0/(1.0+m_array[_indC].sumps/m_array[_indC].sumns)) : 0);
      }
};
CSsmRsi iSsmRsi;

//
//---
//

ENUM_TIMEFRAMES _tfsPer[]={PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string          _tfsStr[]={"1 minute","2 minutes","3 minutes","4 minutes","5 minutes","6 minutes","10 minutes","12 minutes","15 minutes","20 minutes","30 minutes","1 hour","2 hours","3 hours","4 hours","6 hours","8 hours","12 hours","daily","weekly","monthly"};

//
//---
//

string timeFrameToString(int period)
{
   if(period==PERIOD_CURRENT)
      period=_Period;
   int i; for(i=0;i<ArraySize(_tfsPer);i++) if(period==_tfsPer[i]) break;
   return(_tfsStr[i]);
}

//
//---
//

ENUM_TIMEFRAMES timeFrameGet(int period)
{
   int _shift = (period<0 ? MathAbs(period) : 0); if (period<=0) period=_Period;
   int i; for(i=0;i<ArraySize(_tfsPer);i++) if(period==_tfsPer[i]) break;
      return(_tfsPer[(int)MathMin(i+_shift,ArraySize(_tfsPer)-1)]);
}
//------------------------------------------------------------------