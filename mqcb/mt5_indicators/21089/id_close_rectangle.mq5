//+------------------------------------------------------------------+
//|                                           ID_Close_Rectangle.mq5 |
//|                                                      Dina Paches |
//|                             https://www.mql5.com/ru/users/dipach |
//+------------------------------------------------------------------+
#property copyright "Dina Paches"
#property link "https://www.mql5.com/ru/users/dipach"
#property version "1.008"
#property indicator_chart_window
#property indicator_plots 0
//---
#define CHART_ID                               (0)
#define OBJECTS_PREFIX                         "ID Cl R"
#define BUTT_WORK_PREFIX                       "cl "
#define BUTT_DEL_IND_PREFIX                    "del ind"
#define BUTT_WORK_TEXT                         "Close Rectangle"
#define BUTT_DEL_IND_TEXT                      (CharToString(251))
#define FONT_SIZE_MIN                          (6)
#define EDIT_W                                 (2)
#define EDIT_H                                 (11)
#define EDIT_WH(f,whc)                         (((f)+((f)%(whc)))/(whc))
#define CLR_PANEL                              C'218,218,225' 
#define CLR_TEXT                               C'59,59,59'
#define CLR_WORK                               clrAntiqueWhite
#define CLR_DEL_INDICATOR                      C'235,185,185'
#define BASE_CORNER                            CORNER_RIGHT_UPPER
//---
#define WARNING_TEXT_0(nm_0)                   "The object \"",(nm_0),"\" is not a rectangle"
#define WARNING_TEXT_1(nm_1)                   (nm_1)+": first point time >= second point time"
#define WARNING_TEXT_2(nm_2)                   (nm_2)+": time_0 and time_1 = same bar"
#define WARNING_ERR                            "Line: ",__LINE__,", ",__FUNCTION__,", Error Code = ",GetLastError()
//---
input bool   i_prefix_add_to_object_name       = true;
input bool   i_prefix_add_to_object_text       = true;
input bool   i_prefix_add_to_object_tooltip    = false;
input bool   i_alert_if_obj_inverted           = false;
input uchar  i_font_size                       = 10;
input ushort i_y_distance                      = 5;
input ushort i_x_distance                      = 5;
input ushort i_button_size_base                = 23;
//+------------------------------------------------------------------+
string      gp_name_butt_work,gp_name_butt_del_ind;
bool        gp_prefix_add;
//+------------------------------------------------------------------+
enum enum_Flag_click{STOP_,PANEL_,CHART_,};
enum_Flag_click ge_flag_click;
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!IndicatorShortNameSet(OBJECTS_PREFIX)){return(INIT_FAILED);}
//---
   ge_flag_click = STOP_;
   gp_prefix_add = (i_prefix_add_to_object_name || i_prefix_add_to_object_text
                    || i_prefix_add_to_object_tooltip);
//---
   PreparePanel();
//---
   ge_flag_click=PANEL_;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,OBJECTS_PREFIX,0);
//---
   if(reason==REASON_INITFAILED){ChIndicatorDelete(OBJECTS_PREFIX);}
//---
   ChartRedraw();
  }
//+------------------------------------------------------------------+
int OnCalculate(const int    rates_total,
                const int    prev_calculated,
                const int    begin,
                const double &price[])
  {return(rates_total);}
//+------------------------------------------------------------------+
void OnChartEvent(const int    id,
                  const long   &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(ge_flag_click==STOP_){return;}
      //---если щелчок по какому-либо объекту на графике, кроме кнопок этого индикатора:
      if(StringFind(sparam,OBJECTS_PREFIX)!=0)
        {
         if(ge_flag_click==PANEL_){return;}
         //---
         if(!ActionsIfObjClick(sparam,(int)lparam,(int)dparam)){return;}
         //---panel
         ObSetIntegerColor(CHART_ID,gp_name_butt_work,OBJPROP_BGCOLOR,CLR_PANEL);
         ObSetIntegerBool(CHART_ID,gp_name_butt_work,OBJPROP_STATE,false);
         //---flag
         ge_flag_click=PANEL_;
         //---
         ChartRedraw();
        }
      else//если щелчок по одной из кнопок этого индикатора
        {
         if(StringCompare(sparam,gp_name_butt_work)==0)
           {
            bool  butt_state = ObjectGetInteger(CHART_ID,gp_name_butt_work,OBJPROP_STATE);
            color butt_clr   = CLR_WORK;
            //---
            if(butt_state){ge_flag_click=CHART_;}
            else{ge_flag_click=PANEL_; butt_clr=CLR_PANEL;}
            //---
            ObSetIntegerColor(CHART_ID,gp_name_butt_work,OBJPROP_BGCOLOR,butt_clr);
            //---
            ChartRedraw();
           }
         else
           {
            ge_flag_click=STOP_;
            //---
            ChIndicatorDelete(OBJECTS_PREFIX);
           }
        }
     }//if(id==CHARTEVENT_OBJECT_CLICK)
   return;
  }
//+------------------------------------------------------------------+
bool ActionsIfObjClick(const string name, const int x, const int y)
  {
   if(!TypeObjCheck(name)){return(false);}
//---
   datetime t=0;
//---
   ChartXYToTime(x,y,t);
//---
   if(!ActionsIfRectangle(name,t)){return(false);}
//---
   if(gp_prefix_add){if(!ActionsIfPrefixAddToObjText(name)){return(false);}}
//---
   return(true);
  }
//+------------------------------------------------------------------+
void Message(const string text)
  {if(i_alert_if_obj_inverted){Alert(text);}else{Print(text);}}
//+------------------------------------------------------------------+
bool TypeObjCheck(const string name)
  {
   ENUM_OBJECT type=(ENUM_OBJECT)ObjectGetInteger(CHART_ID,name,OBJPROP_TYPE);
//---
   if(type==OBJ_RECTANGLE){return(true);}
//---
   Print(WARNING_TEXT_0(name));
//---
   return(false);
  }
//+------------------------------------------------------------------+
void ChartXYToTime(const int x, const int y, datetime &t)
  {
   double p  = 0.0;
   int    sw = 0;
//---
   ChartXYToTimePrice(CHART_ID,x,y,sw,t,p);
  }
//+------------------------------------------------------------------+
bool ActionsIfRectangle(const string name, const datetime t)
  {
   datetime t0 = 0, t1 = 0;
   int      prop_modif = 1;
   bool     inverted   = false;
//---
   TimesObjGet(name,t0,t1);
//---
   if(t0>t1)
     {
      PreparePreInvertValues(prop_modif,inverted);
      //---
      InvertValues(t0,t1);
      //---
      Message(WARNING_TEXT_1(name));
     }
   else if(t0==t1){Message(WARNING_TEXT_2(name));return(false);}
//---
   if(t>=t1){return(false);}
//---
   if(!ObSetIntegerTimeMod(CHART_ID,name,prop_modif,t)){return(false);}
//---
   return(true);
  }
//+------------------------------------------------------------------+
void TimesObjGet(const string name, datetime &t0, datetime &t1)
  {
   t0 = (datetime)ObjectGetInteger(CHART_ID,name,OBJPROP_TIME,0);
   t1 = (datetime)ObjectGetInteger(CHART_ID,name,OBJPROP_TIME,1);
  }
//+------------------------------------------------------------------+
void PreparePreInvertValues(int &prop_modif, bool &inverted)
  {
   prop_modif = 0;
   inverted   = true;
  }
//+------------------------------------------------------------------+
void  InvertValues(datetime &v0, datetime &v1)
  {
   datetime v_ch=v0;
   v0 = v1;
   v1 = v_ch;
  }
//+------------------------------------------------------------------+
bool ActionsIfPrefixAddToObjText(const string name)
  {
   if(i_prefix_add_to_object_text)
     {if(!PrefixAddToObjText(name,BUTT_WORK_PREFIX,OBJPROP_TEXT)){return(false);}}
//---
   if(i_prefix_add_to_object_tooltip)
     {if(!PrefixAddToObjText(name,BUTT_WORK_PREFIX,OBJPROP_TOOLTIP)){return(false);}}
//---
   if(i_prefix_add_to_object_name)
     {if(!PrefixAddToObjText(name,BUTT_WORK_PREFIX,OBJPROP_NAME)){return(false);}}
//---
   return(true);
  }
//+------------------------------------------------------------------+
bool PrefixAddToObjText(const string                      name,
                        const string                      prefix,
                        const ENUM_OBJECT_PROPERTY_STRING prop_string)
  {
   string text=ObjectGetString(CHART_ID,name,prop_string);
//---
   StringConcatenate(text,prefix,text);
//---
   if(!ObSetString(CHART_ID,name,prop_string,text)){return(false);}
//---
   return(true);
  }
//+------------------------------------------------------------------+
bool IndicatorShortNameSet(const string name)
  {
   if(!IndicatorSetString(INDICATOR_SHORTNAME,name)){Print(WARNING_ERR); return(false);}
   return(true);
  }
//+------------------------------------------------------------------+
void PreparePanel()
  {
   ObjNameCreate(gp_name_butt_work,OBJECTS_PREFIX,BUTT_WORK_PREFIX);
   ObjNameCreate(gp_name_butt_del_ind,OBJECTS_PREFIX,BUTT_DEL_IND_PREFIX);
//---
   PanelCreate();
//---
   return;
  }
//+------------------------------------------------------------------+
int ObjNameCreate(string &name, const string prefix, const string dt)
  {return(StringConcatenate(name,prefix,"_",dt));}
//+------------------------------------------------------------------+
void PanelCreate()
  {
   int fs    = (i_font_size < FONT_SIZE_MIN) ? FONT_SIZE_MIN : i_font_size;
   int w     = i_button_size_base;
   int h     = i_button_size_base*EDIT_WH(fs,EDIT_H);
   int x_dis = i_x_distance+w;
//---
   if(ObjectFind(CHART_ID,gp_name_butt_del_ind)<0)
     {
      ButtonCreate(CHART_ID,gp_name_butt_del_ind,0,x_dis,i_y_distance,w,h,BASE_CORNER,
                   BUTT_DEL_IND_TEXT,"\n","Wingdings",fs,CLR_TEXT,CLR_DEL_INDICATOR);
     }
//---
   w    *= EDIT_WH(fs,EDIT_W);
   x_dis = i_x_distance+w+i_button_size_base;
//---
   if(ObjectFind(CHART_ID,gp_name_butt_work)<0)
     {
      ButtonCreate(CHART_ID,gp_name_butt_work,0,x_dis,i_y_distance,w,h,BASE_CORNER,
                   BUTT_WORK_TEXT,"\n","Arial",fs,CLR_TEXT,CLR_PANEL);
     }
//---
   return;
  }
//+------------------------------------------------------------------+
bool ChIndicatorDelete(const string sh_name)
  {
   int sw=ChartWindowFind();
//---
   if(!ChartIndicatorDelete(CHART_ID,sw,sh_name))
     {
      Print(WARNING_ERR,". Failed to delete indicator:\"",sh_name,"\"");
      return(false);
     }
//---
   return(true);
  }
//+--------------------------------------------------------------------+
bool ObSetIntegerColor(const long                         chart_id,
                       const string                       name,
                       const ENUM_OBJECT_PROPERTY_INTEGER prop_id,
                       const color                        prop_value)
  {
   if(!ObjectSetInteger(chart_id,name,prop_id,prop_value)){Print(WARNING_ERR); return(false);}
   return(true);
  }
//+------------------------------------------------------------------+
bool ObSetIntegerTimeMod(const long     chart_id,
                         const string   name,
                         const int      prop_modifier,
                         const datetime prop_value)
  {
   if(!ObjectSetInteger(chart_id,name,OBJPROP_TIME,prop_modifier,prop_value)){Print(WARNING_ERR); return(false);}
   return(true);
  }
//+-------------------------------------------------------------------+
bool ObSetIntegerBool(const long                         chart_id,
                      const string                       name,
                      const ENUM_OBJECT_PROPERTY_INTEGER prop_id,
                      const bool                         prop_value)
  {
   if(!ObjectSetInteger(chart_id,name,prop_id,prop_value)){Print(WARNING_ERR); return(false);}
   return(true);
  }
//+--------------------------------------------------------------------+
bool ObSetString(const long                        chart_id,
                 const string                      name,
                 const ENUM_OBJECT_PROPERTY_STRING prop_id,
                 const string                      prop_value)
  {
   if(!ObjectSetString(chart_id,name,prop_id,prop_value))
     {Print(WARNING_ERR,", ",name,", ",EnumToString(prop_id));return(false);}
   return(true);
  }
//+--------------------------------------------------------------------+
bool ObSetIntegerInt(const long                         chart_id,
                     const string                       name,
                     const ENUM_OBJECT_PROPERTY_INTEGER prop_id,
                     const int                          prop_value)
  {
   if(!ObjectSetInteger(chart_id,name,prop_id,prop_value)){Print(WARNING_ERR); return(false);}
   return(true);
  }
//+------------------------------------------------------------------+
bool ObSetIntegerCorner(const long             chart_id,
                        const string           name,
                        const ENUM_BASE_CORNER prop_value)
  {
   if(!ObjectSetInteger(chart_id,name,OBJPROP_CORNER,prop_value)){Print(WARNING_ERR); return(false);}
   return(true);
  }
//+-------------------------------------------------------------------+
bool ObSetIntegerLong(const long                         chart_id,
                      const string                       name,
                      const ENUM_OBJECT_PROPERTY_INTEGER prop_id,
                      const long                         prop_value)
  {
   if(!ObjectSetInteger(chart_id,name,prop_id,prop_value)){Print(WARNING_ERR); return(false);}
   return(true);
  }
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_id=0,
                  const string            name="Button",
                  const int               sw=0,
                  const int               x=0,
                  const int               y=0,
                  const int               w=50,
                  const int               h=18,
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER,
                  const string            text="Button",
                  const string            toolTip="\n",
                  const string            font="Arial",
                  const int               fs=10,
                  const color             clr=clrBlack,
                  const color             back_clr=C'236,233,216',
                  const color             border_clr=clrNONE,
                  const bool              state=false,
                  const bool              back=false,
                  const bool              selection=false,
                  const bool              hidden=true,
                  const long              z_order=0,
                  const int               tf=OBJ_ALL_PERIODS)
  {
   if(!ObjectCreate(chart_id,name,OBJ_BUTTON,sw,0,0)){Print(WARNING_ERR); return(false);}
//---
   ObSetIntegerInt(chart_id,name,OBJPROP_XDISTANCE,x);
   ObSetIntegerInt(chart_id,name,OBJPROP_YDISTANCE,y);
   ObSetIntegerInt(chart_id,name,OBJPROP_XSIZE,w);
   ObSetIntegerInt(chart_id,name,OBJPROP_YSIZE,h);
   ObSetIntegerCorner(chart_id,name,corner);
   ObSetString(chart_id,name,OBJPROP_TEXT,text);
   ObSetString(chart_id,name,OBJPROP_FONT,font);
   ObSetIntegerInt(chart_id,name,OBJPROP_FONTSIZE,fs);
   ObSetString(chart_id,name,OBJPROP_TOOLTIP,toolTip);
   ObSetIntegerColor(chart_id,name,OBJPROP_COLOR,clr);
   ObSetIntegerColor(chart_id,name,OBJPROP_BGCOLOR,back_clr);
   ObSetIntegerColor(chart_id,name,OBJPROP_BORDER_COLOR,border_clr);
   ObSetIntegerBool(chart_id,name,OBJPROP_BACK,back);
   ObSetIntegerBool(chart_id,name,OBJPROP_STATE,state);
   ObSetIntegerBool(chart_id,name,OBJPROP_SELECTABLE,selection);
   ObSetIntegerBool(chart_id,name,OBJPROP_SELECTED,selection);
   ObSetIntegerBool(chart_id,name,OBJPROP_HIDDEN,hidden);
   ObSetIntegerLong(chart_id,name,OBJPROP_ZORDER,z_order);
   ObSetIntegerInt(chart_id,name,OBJPROP_TIMEFRAMES,tf);
//---
   return(true);
  }
//+------------------------------------------------------------------+