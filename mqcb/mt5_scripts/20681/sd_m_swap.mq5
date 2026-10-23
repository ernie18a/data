//+------------------------------------------------------------------+
//|                                                    SD_M_Swap.mq5 |
//|                                                      Dina Paches |
//|                             https://www.mql5.com/ru/users/dipach |
//+------------------------------------------------------------------+
#property copyright "Dina Paches"
#property link      "https://www.mql5.com/ru/users/dipach"
#property version   "1.08"
//---
#property script_show_inputs
//---
#define CHART_ID                            (0)
#define SUB_WINDOW                          (0)
#define DIGITS                              (2)
#define OBJ_NUMBER                          (3)
#define CORRECTION_WIDTH                    (3)
#define CORRECTION_LOCATION_NEXT_OBJ        (11)
#define LINE_NUMBER                         "Line: ",__LINE__,", "
#define TEXT_SWAP_LONG                      "sw_long"
#define TEXT_SWAP_SHORT                     "sw_short"
#define TEXT_SYMB_DATE                      "sw_symb_date"
//---
input bool   i_delete_text_only      = false;
input color  i_color_plus            = clrGreen;
input color  i_color_minus           = clrRed;
input uchar  i_font_size             = 9;
input ushort i_y                     = 5;
//+------------------------------------------------------------------+
void OnStart()
  {
//--------------------------------------------------------------------
   string name_arr[OBJ_NUMBER]={TEXT_SWAP_LONG,TEXT_SWAP_SHORT,TEXT_SYMB_DATE};
//--------------------------------------------------------------------
   for(int i=OBJ_NUMBER-1;i>=0;i--)
     {if(!ObDelete(CHART_ID,name_arr[i])){return;}}
//--------------------------------------------------------------------
   if(i_delete_text_only){return;}
//--------------------------------------------------------------------
   double swap_arr[2]={0,0};
//---
   SwapGet(swap_arr[0],swap_arr[1]);
//--------------------------------------------------------------------
   string text_arr[OBJ_NUMBER]={"?","?","?"};
//---
   TextObjCreate_1(text_arr[2]);
//---
   for(int i=OBJ_NUMBER-2;i>=0;i--)
     {TextObjCreate_0(text_arr[i],name_arr[i],swap_arr[i],DIGITS);}
//--------------------------------------------------------------------
   color text_clr_arr[OBJ_NUMBER]={clrNONE,clrNONE,clrNONE};
//---
   for(int i=OBJ_NUMBER-2;i>=0;i--)
     {text_clr_arr[i]=(swap_arr[i]<0) ? i_color_minus : i_color_plus;}
//---
   text_clr_arr[2]=text_clr_arr[1];
//--------------------------------------------------------------------
   int width=0;
//---
   if(!ChWidthInPixels(CHART_ID,width)){return;}
//---
   width/=CORRECTION_WIDTH;
//--------------------------------------------------------------------
   for(int i=0;i<OBJ_NUMBER;i++)
     {
      LabelCreate(CHART_ID,name_arr[i],SUB_WINDOW,width,i_y,"\n",CORNER_LEFT_UPPER,
                  text_arr[i],"Arial",i_font_size,text_clr_arr[i]);
      //---
      width+=(i_font_size*CORRECTION_LOCATION_NEXT_OBJ);
     }
  }//OnStart()
//+------------------------------------------------------------------+
void SwapGet(double &value_long,double &value_short)
  {
   string symbol=Symbol();
//---
   value_long  = SymbolInfoDouble(symbol,SYMBOL_SWAP_LONG);
   value_short = SymbolInfoDouble(symbol,SYMBOL_SWAP_SHORT);
//---
   return;
  }
//+------------------------------------------------------------------+ 
bool ChWidthInPixels(const long chart_id,int &weight)
  {
   long result=-1;
//--- 
   if(!ChartGetInteger(chart_id,CHART_WIDTH_IN_PIXELS,0,result))
     {
      Print(LINE_NUMBER,__FUNCTION__,", Error = ",GetLastError());
     }
//---
   weight=(int)result;
//---
   return(true);
  }
//+------------------------------------------------------------------+
int TextObjCreate_0(string &text,string prefix,double value,int digits)
  {return(StringConcatenate(text,prefix," = ",DoubleToString(value,digits)));}
//+------------------------------------------------------------------+
int  TextObjCreate_1(string &text)
  {
   return(StringConcatenate(text,"(",Symbol()," ",
          TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES),")"));
  }
//+------------------------------------------------------------------+
bool ObDelete(long chart_id,string name)
  {
   if(ObjectFind(chart_id,name)>-1)
     {
      if(!ObjectDelete(chart_id,name))
        {
         Print(LINE_NUMBER,__FUNCTION__,", Error Code = ",GetLastError());
         return(false);
        }
     }
   return(true);
  }
//+--------------------------------------------------------------------+
bool ObSetString(long                        chart_id,
                 string                      name,
                 ENUM_OBJECT_PROPERTY_STRING prop_id,
                 string                      prop_value)
  {
   if(!ObjectSetString(chart_id,name,prop_id,prop_value))
     {
      Print(LINE_NUMBER,__FUNCTION__,", Error Code = ",GetLastError());
      return(false);
     }
   return(true);
  }
//+--------------------------------------------------------------------+
bool ObSetIntegerInt(long                         chart_id,
                     string                       name,
                     ENUM_OBJECT_PROPERTY_INTEGER prop_id,
                     int                          prop_value)
  {
   if(!ObjectSetInteger(chart_id,name,prop_id,prop_value))
     {
      Print(LINE_NUMBER,__FUNCTION__,", Error Code = ",GetLastError());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
bool ObSetIntegerCorner(long             chart_id,
                        string           name,
                        ENUM_BASE_CORNER prop_value)
  {
   if(!ObjectSetInteger(chart_id,name,OBJPROP_CORNER,prop_value))
     {
      Print(LINE_NUMBER,__FUNCTION__,", Error Code = ",GetLastError());
      return(false);
     }
   return(true);
  }
//+--------------------------------------------------------------------+
bool ObSetDouble(long                        chart_id,
                 string                      name,
                 ENUM_OBJECT_PROPERTY_DOUBLE prop_id,
                 double                      prop_value)
  {
   if(!ObjectSetDouble(chart_id,name,prop_id,prop_value))
     {
      Print(LINE_NUMBER,__FUNCTION__,", Error Code = ",GetLastError());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
bool ObSetIntegerAncorPoint(long              chart_id,
                            string            name,
                            ENUM_ANCHOR_POINT prop_value)
  {
   if(!ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,prop_value))
     {
      Print(LINE_NUMBER,__FUNCTION__,", Error Code = ",GetLastError());
      return(false);
     }
   return(true);
  }
//+--------------------------------------------------------------------+
bool ObSetIntegerColor(long                         chart_id,
                       string                       name,
                       ENUM_OBJECT_PROPERTY_INTEGER prop_id,
                       color                        prop_value)
  {
   if(!ObjectSetInteger(chart_id,name,prop_id,prop_value))
     {
      Print(LINE_NUMBER,__FUNCTION__,", Error Code = ",
            GetLastError());
      return(false);
     }
   return(true);
  }
//+-------------------------------------------------------------------+
bool ObSetIntegerBool(long                         chart_id,
                      string                       name,
                      ENUM_OBJECT_PROPERTY_INTEGER prop_id,
                      bool                         prop_value)
  {
   if(!ObjectSetInteger(chart_id,name,prop_id,prop_value))
     {
      Print(LINE_NUMBER,__FUNCTION__,", Error Code = ",GetLastError());
      return(false);
     }
   return(true);
  }
//+-------------------------------------------------------------------+
bool ObSetIntegerLong(long                         chart_id,
                      string                       name,
                      ENUM_OBJECT_PROPERTY_INTEGER prop_id,
                      long                         prop_value)
  {

   if(!ObjectSetInteger(chart_id,name,prop_id,prop_value))
     {
      Print(LINE_NUMBER,__FUNCTION__,", Error Code = ",GetLastError());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| На основе Справочника по MQL5                                    |
//+------------------------------------------------------------------+
bool LabelCreate(const long              chart_id=0,               // ID графика
                 const string            name="Label",             // имя метки
                 const int               sub_window=0,             // номер подокна
                 const int               x=0,                      // координата по оси X
                 const int               y=0,                      // координата по оси Y
                 const string            toolTip="\n",             // текст всплывающей подсказки
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // угол графика для привязки
                 const string            text="Label",             // текст
                 const string            font="Arial",             // шрифт
                 const int               font_size=10,             // размер шрифта
                 const color             clr=clrRed,               // цвет
                 const double            angle=0.0,                // наклон текста
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // способ привязки
                 const bool              back=false,               // на заднем плане
                 const bool              selection=false,          // выделить для перемещений
                 const bool              hidden=true,              // скрыт в списке объектов
                 const long              z_order=0,                // приоритет на нажатие мышью
                 const int               timeFrames=OBJ_ALL_PERIODS)//отображение объекта на различных периодах
  {
   if(!ObjectCreate(chart_id,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(LINE_NUMBER,__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
//---
   ObSetString(chart_id,name,OBJPROP_TOOLTIP,toolTip);
   ObSetIntegerInt(chart_id,name,OBJPROP_XDISTANCE,x);
   ObSetIntegerInt(chart_id,name,OBJPROP_YDISTANCE,y);
   ObSetIntegerCorner(chart_id,name,corner);
   ObSetString(chart_id,name,OBJPROP_TEXT,text);
   ObSetString(chart_id,name,OBJPROP_FONT,font);
   ObSetIntegerInt(chart_id,name,OBJPROP_FONTSIZE,font_size);
   ObSetDouble(chart_id,name,OBJPROP_ANGLE,angle);
   ObSetIntegerAncorPoint(chart_id,name,anchor);
   ObSetIntegerColor(chart_id,name,OBJPROP_COLOR,clr);
   ObSetIntegerBool(chart_id,name,OBJPROP_BACK,back);
   ObSetIntegerBool(chart_id,name,OBJPROP_SELECTABLE,selection);
   ObSetIntegerBool(chart_id,name,OBJPROP_SELECTED,selection);
   ObSetIntegerBool(chart_id,name,OBJPROP_HIDDEN,hidden);
   ObSetIntegerLong(chart_id,name,OBJPROP_ZORDER,z_order);
   ObSetIntegerInt(chart_id,name,OBJPROP_TIMEFRAMES,timeFrames);
//---
   return(true);
  }
//+------------------------------------------------------------------+
