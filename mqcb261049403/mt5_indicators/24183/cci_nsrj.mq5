//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "CCI with support and resistance levels "
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "Upper level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Lower level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "CCI"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width3  2

//
//
//
input int                inpPeriod      =  32;              // CCI period
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE;      // Price 
input double             inpLevelUp     =  100;             // Level up
input double             inpLevelDown   = -100;             // Level down
input string             inpUniqueID    = "CCILevels1";     // Unique ID for on chart objects
input color              inpColorUp     = clrDeepSkyBlue;   // Color for upper level broken line
input color              inpColorDown   = clrLightSalmon;   // Color for lower level broken line
input int                inpLinesWidth  = 2;                // Lines width
input ENUM_LINE_STYLE    inpLinesStyle  = STYLE_SOLID;      // Lines style

//
//
//

double val[],valc[],levu[],levd[]; 
int ª_indHandle;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,levu,INDICATOR_DATA);
         SetIndexBuffer(1,levd,INDICATOR_DATA);
         SetIndexBuffer(2,val ,INDICATOR_DATA);
         SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
            ª_indHandle = iCCI(_Symbol,0,inpPeriod,inpPrice); if (!_checkHandle(ª_indHandle,"CCI")) { return(INIT_FAILED); }
            _srHandler.setUniqueID(inpUniqueID);
            _srHandler.setLinesStyle(inpLinesStyle);
            _srHandler.setLinesWidth(inpLinesWidth);
            _srHandler.setSupportColor(inpColorDown);
            _srHandler.setResistanceColor(inpColorUp);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI with SR levels ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}

//
//---
//

void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(ª_indHandle,0,0,_copyCount,val)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //
  
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      levu[i] = inpLevelUp;
      levd[i] = inpLevelDown;
      valc[i] = (val[i]>levu[i]) ? 1 :(val[i]<levd[i]) ? 2 : 0;
         _srHandler.update(close[i],time[i],valc[i],i,rates_total);
   }         
   return (i);
}
  
//------------------------------------------------------------------
//    Custom function(s)
//------------------------------------------------------------------
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
         if (i>0)
         {
            if (m_array[i].state!=m_array[i-1].state)
            {
               m_array[i].time = time;
               if (m_array[i].state!=0)
               {
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
            }                  
            else  
            {
               m_array[i].time = m_array[i-1].time;
               
               //
               //---
               //
                  
               string _name = m_uniqueID+":"+(string)m_array[i].time;
                  if (m_array[i].state!=0)
                        ObjectSetInteger(0,_name,OBJPROP_TIME,1,time+PeriodSeconds(_Period));
                  else  if (ObjectFind(0,_name)>=0) ObjectDelete(0,_name);
            }
         }
         else m_array[i].time = time;
      }
      
};
COnChartSR _srHandler;

//
//---
//
bool _checkHandle(int _handle, string _description)
{
   static int  _handles[];
          int  _size   = ArraySize(_handles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_handles,_size+1); _handles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_handles[i]); ArrayResize(_handles,0); Alert(_description+" initialization failed"); }
   return(_answer);
} 
//+------------------------------------------------------------------+
