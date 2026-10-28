//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Trix with support and resistance levels "
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "TRiX"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrDodgerBlue,clrSandyBrown
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//
//---
//

enum enColorOn
{
   on_slope, // Change color on slope change
   on_zero   // Change color on zero cross
};
input int                inpPeriod      = 14;               // Period
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE;      // Price
input enColorOn          inpColorOn     = on_zero;          // Color change mode 
input string             inpUniqueID    = "TrixLevels1";    // Unique ID for on chart objects
input color              inpColorUp     = clrDeepSkyBlue;   // Color for upper level broken line
input color              inpColorDown   = clrLightSalmon;   // Color for lower level broken line
input int                inpLinesWidth  = 2;                // Lines width
input ENUM_LINE_STYLE    inpLinesStyle  = STYLE_SOLID;      // Lines style

double val[],valc[];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   SetIndexBuffer(0,val ,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);

   //
   //---
   //
   
      iTrix.init(inpPeriod);
         _srHandler.setUniqueID(inpUniqueID);
         _srHandler.setLinesStyle(inpLinesStyle);
         _srHandler.setLinesWidth(inpLinesWidth);
         _srHandler.setSupportColor(inpColorDown);
         _srHandler.setResistanceColor(inpColorUp);
   IndicatorSetString(INDICATOR_SHORTNAME,"TRiX with SR("+(string)inpPeriod+")");
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

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
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
         val[i] = iTrix.calculate(_price,i,rates_total);
         if (inpColorOn==on_slope)
               valc[i] = i>0 ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0 ;
         else  valc[i] = (val[i]>0) ? 1 : (val[i]<0) ? 2 : 0;
         _srHandler.update(close[i],time[i],valc[i],i,rates_total);
   }      
   return(i);
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
         m_alpha  = 2.0/(1.0+m_period);
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

//
//---
//

class COnChartSR
{
   private :
      string m_uniqueID;
      color  m_colorSup;
      color  m_colorRes;
      int    m_linesWidth;
      int    m_linesStyle;
      int    m_arraySize;
      struct sOnChartSRStruct
      {
         datetime time;
         double   state;
      };
      sOnChartSRStruct m_array[];
         
   public :
      COnChartSR() : m_colorSup(clrOrangeRed), m_colorRes(clrMediumSeaGreen), m_linesWidth(1), m_linesStyle(STYLE_SOLID), m_arraySize(-1) { return; }
     ~COnChartSR() { ObjectsDeleteAll(0,m_uniqueID+":"); ChartRedraw(0); return; }
     
      //
      //
      //
      
      void setUniqueID(string _id)          { m_uniqueID = _id; return; }
      void setSupportColor(color _color)    { m_colorSup = _color; return; }
      void setResistanceColor(color _color) { m_colorRes = _color; return; }
      void setLinesWidth(int _width)        { m_linesWidth = _width; return; }
      void setLinesStyle(int _style)        { m_linesStyle = _style; return; }
      void update(double price, datetime time, double state, int i, int bars)
      {
         if (m_arraySize<bars)
         {
            m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return;
         }
         
         //
         //
         //
         
         m_array[i].state = state;
         if (state==0)
         {
            m_array[i].time = time;
               string _name = m_uniqueID+":"+(string)m_array[i].time;
                  if (ObjectFind(0,_name)>=0) ObjectDelete(0,_name);               
         }
         else
            if (i>0)
            {
               if (m_array[i].state!=m_array[i-1].state)
               {
                  m_array[i].time = time;
                     string _name = m_uniqueID+":"+(string)time;
                     ObjectCreate(0,_name,OBJ_TREND,0,0,0);
                        ObjectSetInteger(0,_name,OBJPROP_WIDTH,m_linesWidth);
                        ObjectSetInteger(0,_name,OBJPROP_STYLE,m_linesStyle);
                        ObjectSetInteger(0,_name,OBJPROP_COLOR,(state==1 ? m_colorRes : m_colorSup));
                        ObjectSetInteger(0,_name,OBJPROP_HIDDEN,true);
                        ObjectSetInteger(0,_name,OBJPROP_BACK,true);
                        ObjectSetInteger(0,_name,OBJPROP_SELECTABLE,false);
                        ObjectSetInteger(0,_name,OBJPROP_RAY,false);
                        ObjectSetInteger(0,_name,OBJPROP_TIME,0,time);
                        ObjectSetInteger(0,_name,OBJPROP_TIME,1,time+PeriodSeconds(_Period));
                           ObjectSetDouble(0,_name,OBJPROP_PRICE,0,price);
                           ObjectSetDouble(0,_name,OBJPROP_PRICE,1,price);
               }                  
               else  
               {
                  m_array[i].time = m_array[i-1].time;
                     string _name = m_uniqueID+":"+(string)m_array[i].time;
                           ObjectSetInteger(0,_name,OBJPROP_TIME,1,time+PeriodSeconds(_Period));
               }
            }
            else m_array[i].time = time;
      }
};
COnChartSR _srHandler;