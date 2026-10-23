//+------------------------------------------------------------------+
//|                                     ID_Close_Rectangle_TL_AL.mq5 |
//|                                                      Dina Paches |
//|                             https://www.mql5.com/ru/users/dipach |
//+------------------------------------------------------------------+
#property copyright "Dina Paches"
#property link "https://www.mql5.com/ru/users/dipach"
#property version "1.119"
#property indicator_chart_window
#property indicator_plots 0
//---
#define CHART_ID                               (0)
#define OBJECTS_PREFIX                         "ID Cl RTA"
#define BUTT_WORK_PREFIX                       "cl "
#define BUTT_DEL_IND_PREFIX                    "del ind"
#define BUTT_WORK_TEXT                         "Close R, TL, AL"
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
#define NEUTRAL                                (0)
#define	PERHAPS_A_SMALL_ANGLE                  (5)
#define NO_PREFIX_CHANGE_IF_NO_RAY_TO_RIGHT    (8)
#define ND(p)                                  (NormalizeDouble(p,gp_dig))
#define EDIT_FOR_LEFT_VERTICAL_RAY             (Point()*(6))
//---
#define WARNING_TEXT_0(nm_0)                   "The object \"",(nm_0),"\" is not a rectangle, a trend line or an arrowed line"
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
string      gp_name_butt_work,gp_name_butt_del_ind,gp_name;
datetime    gp_t,gp_t0,gp_t1;
double      gp_p,gp_p0,gp_p1;
int         gp_prop_modif,gp_ps,gp_dig;
ENUM_OBJECT gp_type;
bool        gp_prefix_add,gp_inverted;
//+------------------------------------------------------------------+
enum enum_Flag_click{STOP_,PANEL_,CHART_,};
enum_Flag_click ge_flag_click;
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!IndicatorShortNameSet(OBJECTS_PREFIX)){return(INIT_FAILED);}
//---
   InitVarStrct();
//---
   ge_flag_click = STOP_;
   gp_ps         = PeriodSeconds();
   gp_dig        = Digits();
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
bool ActionsIfObjClick(const string name,
                       const int    x,
                       const int    y)
  {
   InitVarStrct(name);
//---
   if(!TypeObjCheck()){return(false);}
//---
   ChartXYToTimeAndPrice(x,y);
//---
   TimesObjGet();
//---
   if(gp_t0>gp_t1){PreparePreInvertValues();}
//---
   if(!FurtherActionsDependingOnTheObjectType()){return(false);}
//---
   if(gp_prefix_add){if(!ActionsIfPrefixAddToObjText()){return(false);}}
//---
   InitVarStrct();
//---
   return(true);
  }
//+------------------------------------------------------------------+
void Message(string text)
  {if(i_alert_if_obj_inverted){Alert(text);}else{Print(text);}}
//+------------------------------------------------------------------+
void InitVarStrct(string name=NULL)
  {
   gp_name       = name;
   gp_t          = gp_t0 = gp_t1 = 0;
   gp_p          = gp_p0 = gp_p1 = 0.0;
   gp_prop_modif = 1;
   gp_type       = -1;
   gp_inverted   = false;
  }
//+------------------------------------------------------------------+
bool TypeObjCheck()
  {
   gp_type = (ENUM_OBJECT)ObjectGetInteger(CHART_ID,gp_name,OBJPROP_TYPE);
//---
   if(gp_type==OBJ_RECTANGLE || gp_type==OBJ_ARROWED_LINE || gp_type==OBJ_TREND){return(true);}
//---
   Print(WARNING_TEXT_0(gp_name));
//---
   return(false);
  }
//+------------------------------------------------------------------+
void TimesObjGet()
  {
   gp_t0 = (datetime)ObjectGetInteger(CHART_ID,gp_name,OBJPROP_TIME,0);
   gp_t1 = (datetime)ObjectGetInteger(CHART_ID,gp_name,OBJPROP_TIME,1);
  }
//+------------------------------------------------------------------+
void PricesObjGet()
  {
   gp_p0 = ObjectGetDouble(CHART_ID,gp_name,OBJPROP_PRICE,0);
   gp_p1 = ObjectGetDouble(CHART_ID,gp_name,OBJPROP_PRICE,1);
  }
//+------------------------------------------------------------------+
void PreparePreInvertValues()
  {
   gp_inverted   = true;
   gp_prop_modif = 0;
//---
   Message(WARNING_TEXT_1(gp_name));
  }
//+------------------------------------------------------------------+
void ChartXYToTimeAndPrice(const int x,
                           const int y)
  {
   int sw = 0;
//---
   ChartXYToTimePrice(CHART_ID,x,y,sw,gp_t,gp_p);
  }
//+------------------------------------------------------------------+
bool  FurtherActionsDependingOnTheObjectType()
  {
   if(gp_type==OBJ_RECTANGLE){if(!ActionsIfRectangle()){return(false);}}
   else
     {
      PricesObjGet();
      //---
      bool equal_t0_t1 = Equal(gp_t0,gp_t1);
      bool equal_p0_p1 = Equal(gp_p0,gp_p1);
      //---
      if(equal_t0_t1)
        {
         if(equal_p0_p1){return(false);}
         //---
         if(!Equal(gp_t,gp_t1)){gp_t=gp_t1;}
        }
      //---
      if(gp_type==OBJ_TREND)
        {
         bool   is_ray_right = ObjectGetInteger(CHART_ID,gp_name,OBJPROP_RAY_RIGHT);
         bool   is_ray_left  = ObjectGetInteger(CHART_ID,gp_name,OBJPROP_RAY_LEFT);
         //---
         if(!is_ray_left && !is_ray_right)
           {if(!ActionsIfLineHowArrowedLine(equal_t0_t1,equal_p0_p1)){return(false);}}
         //---
         else {if(!ActionsIfTrendLine(equal_t0_t1,equal_p0_p1,is_ray_right,is_ray_left)){return(false);}}
        }
      else if(gp_type==OBJ_ARROWED_LINE)
        {if(!ActionsIfLineHowArrowedLine(equal_t0_t1,equal_p0_p1)){return(false);}}
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
bool Equal(const datetime t0,const datetime t1){return(t0==t1);}
//+------------------------------------------------------------------+
bool Equal(const double v0,const double v1){return(ND(v0-v1)==0);}
//+------------------------------------------------------------------+
template<typename T>
//+------------------------------------------------------------------+
void  InvertValues(T &v0,T &v1)
  {
   T v_ch=v0;
   v0 = v1;
   v1 = v_ch;
  }
//+------------------------------------------------------------------+
bool ActionsIfRectangle()
  {
   if(Equal(gp_t0,gp_t1)){Message(WARNING_TEXT_2(gp_name));return(false);}
//---
   if(gp_inverted){InvertValues(gp_t0,gp_t1);}
//---
   if(gp_t>=gp_t1){return(false);}
//---
   if(!ObSetIntegerTimeMod(CHART_ID,gp_name,gp_prop_modif,gp_t)){return(false);}
//---
   return(true);
  }
//+------------------------------------------------------------------+
bool ActionsIfLineHowArrowedLine(const bool equal_t0_t1,const bool equal_p0_p1)
  {
   if(gp_inverted)
     {
      if(!equal_t0_t1){InvertValues(gp_t0,gp_t1);}
      if(!equal_p0_p1){InvertValues(gp_p0,gp_p1);}
     }
//---change:
   if(Equal(gp_t,gp_t1) && Equal(gp_p,gp_p1)){return(false);}
//---
   bool price_new_set = true;
   bool time_new_set  = true;
//---если линия вертикальна:
   if(equal_t0_t1){time_new_set=false;}
//---если линия горизонтальна:
   else if(equal_p0_p1){price_new_set=false;}
//---завершающие штрихи (в т.ч., если линия расположена под каким-то углом):
   if(price_new_set)
     {if(!ObSetDoubleMod(CHART_ID,gp_name,OBJPROP_PRICE,gp_prop_modif,ND(gp_p))){return(false);}}
//---
   if(time_new_set)
     {if(!ObSetIntegerTimeMod(CHART_ID,gp_name,gp_prop_modif,gp_t)){return(false);}}
//---
   return(true);
  }
//+------------------------------------------------------------------+
bool ActionsIfTrendLine(const bool equal_t0_t1,
                        const bool equal_p0_p1,
                        const bool is_ray_right,
                        const bool is_ray_left)
  {
   bool is_ray_ls=is_ray_left;
//---
   if(gp_inverted)
     {
      if(!equal_t0_t1){InvertValues(gp_t0,gp_t1);}
      if(!equal_p0_p1){InvertValues(gp_p0,gp_p1);}
      //---
      is_ray_ls=is_ray_right;
     }
//---change:
   int  res=NEUTRAL;
//---если линия вертикальна:
   if(equal_t0_t1){if(!TrendLineVerticalChange(res,is_ray_ls)){return(false);}}
//---если линия горизонтальна:
   else if(equal_p0_p1){if(!TrendLineHorisontalChange(res,is_ray_ls)){return(false);}}
//---если линия расположена под каким-то углом:
   else if(!TrendLineCrnrChange(res,is_ray_ls,equal_p0_p1)){return(false);}
//---завершающие штрихи:
      if(!gp_inverted)
        {if(is_ray_right){if(!ObSetIntegerBool(CHART_ID,gp_name,OBJPROP_RAY_RIGHT,false)){return(false);}}
        else if(res==NO_PREFIX_CHANGE_IF_NO_RAY_TO_RIGHT){if(gp_prefix_add){gp_prefix_add=false;}}}
      else
        {if(is_ray_left){if(!ObSetIntegerBool(CHART_ID,gp_name,OBJPROP_RAY_LEFT,false)){return(false);}}
        else if(res==NO_PREFIX_CHANGE_IF_NO_RAY_TO_RIGHT){if(gp_prefix_add){gp_prefix_add=false;}}}
//---
   return(true);
  }
//+--------------------------------------------------------------------+
bool TrendLineHorisontalChange(int  &res,
                               bool is_ray_ls)
  {
   bool time_new_set      = true;
   bool move_left_ray_h_c = false;
//---
   if(gp_t==gp_t1)
     {
      time_new_set = false;
      res          = NO_PREFIX_CHANGE_IF_NO_RAY_TO_RIGHT;
     }
   else if(gp_t<gp_t0+gp_ps){if(is_ray_ls){move_left_ray_h_c=true;}}
//---change:
   if(move_left_ray_h_c){if(!MoveLeftRaytForLineHorizontalOrCorner()){return(false);}}
//---
   if(time_new_set)
     {if(!ObSetIntegerTimeMod(CHART_ID,gp_name,gp_prop_modif,gp_t)){return(false);}}
//---
   return(true);
  }
//+--------------------------------------------------------------------+
bool TrendLineCrnrChange(int          &res,
                         bool         is_ray_ls,
                         const bool   equal_p0_p1)
  {
   bool p_set             = false;
   bool p_new_set         = false;
   bool time_new_set      = true;
   bool move_left_ray_h_c = false;
//---
   res=LittleDistanceCheckT();
//---если щелчок по линии был правее её правой точки привязки:
   if(gp_t>gp_t1)
     {
      if(!equal_p0_p1)
        {
         if(res==PERHAPS_A_SMALL_ANGLE){p_set=true;}
         else{p_new_set=true;}
        }
     }
//---если щелчок совпал по координате времени с точкой привязки, расположенной на графике справа:
   else if(gp_t==gp_t1)
     {
      if(Equal(gp_p,gp_p1))
        {res=NO_PREFIX_CHANGE_IF_NO_RAY_TO_RIGHT; return(true);}//если щелчок по правой точке привязки, то выходим
      else{time_new_set=false; p_set=true;}
     }
//---если щелчок попал между (t0 + 1 бар) и t1:
   else if(gp_t>gp_t0+gp_ps)
     {
      if(res==PERHAPS_A_SMALL_ANGLE){p_set=true;}
      else{p_new_set=true;}
     }
//---если щелчок попал на <= (t0 + 1 бар):
   else
     {
      if(is_ray_ls)
        {
         move_left_ray_h_c=true;
         //---
         if(res==PERHAPS_A_SMALL_ANGLE){p_set=true;}
         else{p_new_set=true;}
        }
     }
//---change:
   if(move_left_ray_h_c)
     {if(!MoveLeftRaytForLineHorizontalOrCorner()){return(false);}}
//---
   if(p_set)
     {if(!ObSetDoubleMod(CHART_ID,gp_name,OBJPROP_PRICE,gp_prop_modif,ND(gp_p))){return(false);}}
//---
   else if(p_new_set)
     {if(!ObjPriceNewSet(gp_t,gp_prop_modif)){return(false);}}
//---
   if(time_new_set || res!=NO_PREFIX_CHANGE_IF_NO_RAY_TO_RIGHT)
     {if(!ObSetIntegerTimeMod(CHART_ID,gp_name,gp_prop_modif,gp_t)){return(false);}}
//---
   return(true);
  }
//+--------------------------------------------------------------------+
bool TrendLineVerticalChange(int  &res,
                             bool is_ray_ls)
  {
   double delta             = gp_p1-gp_p0;
   bool   move_left_point_v = false;
//---
   if(ND(delta)>0)
     {
      delta=gp_p-gp_p1;
      //---
      if(ND(delta)==0){res=NO_PREFIX_CHANGE_IF_NO_RAY_TO_RIGHT;return(true);}
      else if(delta<0)
        {
         delta=gp_p-gp_p0;
         //---
         if(ND(delta)<=0 && is_ray_ls)
           {
            move_left_point_v = true;
            delta             = EDIT_FOR_LEFT_VERTICAL_RAY;
           }
        }
     }
   else
     {
      delta=gp_p1-gp_p;
      //---
      if(ND(delta)==0){res=NO_PREFIX_CHANGE_IF_NO_RAY_TO_RIGHT; return(true);}
      else if(delta<0)
        {
         delta=gp_p0-gp_p;
         //---
         if(ND(delta)<=0 && is_ray_ls)
           {
            move_left_point_v = true;
            delta             = -EDIT_FOR_LEFT_VERTICAL_RAY;
           }
        }
     }
//---change:
   if(!ObSetDoubleMod(CHART_ID,gp_name,OBJPROP_PRICE,gp_prop_modif,ND(gp_p))){return(false);}
//---
   if(move_left_point_v){if(!MoveLeftRayForLineVertical(gp_p,delta)){return(false);}}
//---
   return(true);
  }
//+--------------------------------------------------------------------+
int LittleDistanceCheckT()
  {
   datetime delta=gp_t1-gp_t0;
//---
   if(((gp_t>gp_t0) && (gp_t-gp_t0<=delta)) || 
      ((gp_t>gp_t1) && (gp_t-gp_t1<=delta))){return(PERHAPS_A_SMALL_ANGLE);}
//---
   return(NEUTRAL);
  }
//+--------------------------------------------------------------------+
bool MoveLeftRayForLineVertical(const double p,const double delta)
  {
   int prop_modif=(gp_prop_modif==1) ? 0 : 1;
//---
   if(!ObSetDoubleMod(CHART_ID,gp_name,OBJPROP_PRICE,prop_modif,ND(p-delta))){return(false);}
//---
   return(true);
  }
//+--------------------------------------------------------------------+
bool  MoveLeftRaytForLineHorizontalOrCorner()
  {
   int bars = Bars(Symbol(),Period(),gp_t,TimeCurrent());
   int res  = BarTimeGet(bars+5,gp_t0);
//---
   if(res<bars){return(false);}
//---
   res=(gp_prop_modif==1) ? 0 : 1;
//---
   if(!ObjPriceNewSet(gp_t0,res)){return(false);}
//---
   if(!ObSetIntegerTimeMod(CHART_ID,gp_name,res,gp_t0)){return(false);}
//---
   return(true);
  }
//+--------------------------------------------------------------------+
int BarTimeGet(const int bars,datetime &t)
  {
   datetime arr[];
   ArrayResize(arr,bars,bars);
//---
   int c=CopyTime(Symbol(),Period(),0,bars,arr);
//---
   if(c<bars){Print("Error CopyTime");return(c);}
//---
   t=arr[0];
//---
   return(c);
  }
//+------------------------------------------------------------------+
bool ObjPriceNewSet(const datetime time,const int prop_modif)
  {
   double p=ObjectGetValueByTime(CHART_ID,gp_name,time);
//---
   if(!ObSetDoubleMod(CHART_ID,gp_name,OBJPROP_PRICE,prop_modif,ND(p))){return(false);}
//---
   return(true);
  }
//+------------------------------------------------------------------+
bool ActionsIfPrefixAddToObjText()
  {
   if(i_prefix_add_to_object_text)
     {if(!PrefixAddToObjText(gp_name,BUTT_WORK_PREFIX,OBJPROP_TEXT)){return(false);}}
//---
   if(i_prefix_add_to_object_tooltip)
     {if(!PrefixAddToObjText(gp_name,BUTT_WORK_PREFIX,OBJPROP_TOOLTIP)){return(false);}}
//---
   if(i_prefix_add_to_object_name)
     {if(!PrefixAddToObjText(gp_name,BUTT_WORK_PREFIX,OBJPROP_NAME)){return(false);}}
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
int ObjNameCreate(string &name,const string prefix,const string dt)
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
   w     *= EDIT_WH(fs,EDIT_W);
   x_dis  = i_x_distance+w+i_button_size_base;
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
//+--------------------------------------------------------------------+
bool ObSetDoubleMod(const long                        chart_id,
                    const string                      name,
                    const ENUM_OBJECT_PROPERTY_DOUBLE prop_id,
                    const int                         prop_modifier,
                    const double                      prop_value)
  {
   if(!ObjectSetDouble(chart_id,name,prop_id,prop_modifier,prop_value)){Print(WARNING_ERR); return(false);}
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
     {
      Print(WARNING_ERR,", ",name,", ",EnumToString(prop_id));return(false);
     }
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