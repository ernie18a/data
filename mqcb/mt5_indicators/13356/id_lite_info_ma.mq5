//+------------------------------------------------------------------+
//|                                              ID Lite Info MA.mq5 |
//|                                                2015, Dina Paches |
//|                             https://www.mql5.com/ru/users/dipach |
//|                                                                  |
//| Составлен на основе индикатора для МТ4 "ID Lite Info MA":        |
//| https://www.mql5.com/ru/code/13266                               |
//+------------------------------------------------------------------+
#property copyright "2017, Dina Paches"
#property link      "https://www.mql5.com/ru/users/dipach"
#property version   "1.45"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Label1
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCornflowerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Label2
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrCornflowerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//---
#define CHART_ID                      (0)
#define COLUMNS                       (9)    //количество ячеек таблицы по оси Х (>=2 and <=~30)
#define ROWS                          (5)    //количество строк в таблице по оси Y (без заголовка)
#define MIN_COLUMNS                   (2)    
#define MAX_COLUMNS                   (30)
#define NUMBER_ROWS_FOR_ONE_MA        (2)
#define SMALL_ROW(hw)                 ((hw/3)*2)
#define HEIGHT_LONG_BUTTON(h)         ((h/3)-1)
#define DISTANCE_XY                   (1)
#define BUFF_0                        (0)
#define BUFF_1                        (1)     
#define NUMBER_BUFFERS                (2)    //number Moving Averages
#define MA_PERIOD_MAX                 (3000) //ограничение периода усреднения МА (произвольное число)
#define MA_SHIFT                      (0)
#define BAR_ADD                       (1)
#define MIN_BARS                      (5)
#define PREFIX_COLUMNS                ("_edit_")
#define PREFIX_BUTTONS                ("_butt")
#define PREFIX_TITLE                  ("_title_")
#define CODE_BUTTON                   (229)
#define LINE_NUMBER                    "Line: ",__LINE__,", "
//---
enum enum_Digits
  {
   auto=-1,//current chart
   dig0=0,//0
   dig1=1,//1
   dig2=2,//2
   dig3=3,//3
   dig4=4,//4
   dig5=5,//5
   dig6=6,//6
   dig7=7,//7
   dig8=8,//8
  };
//---
input bool               i_show_lines=false;              // Show lines MA
input int                i_ma_0_indent=0;                 // Shift in points from MA1 (-/+ Down or Up)
input int                i_ma_1_indent=0;                 // Shift in points from MA2 (-/+ Down or Up)
input enum_Digits        i_digits=auto;                   // Decimal digits
input uint               i_shift=1;                       // Shift (bar for first value): 
sinput string i_stripe_0="+++++++++++++++++++++";//+++++++++++++++++++++
input uint               i_ma_0_period=1;                 // Period Moving Averages (1)>= 1 or <= 3000:
input ENUM_MA_METHOD     i_ma_0_method=MODE_SMA;          // MA method (1):
input ENUM_APPLIED_PRICE i_ma_0_applied_price=PRICE_HIGH; // Apply to (1):
sinput string i_stripe_1="+++++++++++++++++++++";//+++++++++++++++++++++
input uint               i_ma_1_period=1;                 // Period Moving Averages (2)>= 1 or <= 3000:
input ENUM_MA_METHOD     i_ma_1_method=MODE_SMA;          // MA method (2): 
input ENUM_APPLIED_PRICE i_ma_1_applied_price=PRICE_LOW;  // Apply to (2):
sinput string i_stripe_2="+++++++++++++++++++++";//+++++++++++++++++++++
input uint               i_distance_x=3;                  // X coordinate
input uint               i_distance_y=3;                  // Y coordinate
input color              i_clr_back_main=C'224,224,224';  // Background color (table and Equal)
input color              i_clr_back_up=clrCornflowerBlue; // Background color (Up)
input color              i_clr_back_down=C'255,85,85';    // Background color (Down)
input color              i_clr_text_ma=C'48,48,48';       // Text color for MA
input color              i_clr_text_delta=clrDimGray;     // Color text for delta
input uint               i_obj_width=60;                  // Width
input uint               i_obj_height=18;                 // Height
input uint               i_font_size=9;                   // Font size
input bool               i_behind=true;                   // Table of the indicator behind bars
//---
double
ma_0_buff[],
ma_1_buff[];
string
gp_symbol,
gp_ind_shortname,
gp_name_butt,
ga_name[ROWS][COLUMNS],
ga_text_odd_row[NUMBER_BUFFERS+1][COLUMNS],
ga_text_even_row[NUMBER_BUFFERS][COLUMNS];
color
ga_clr_back_odd_row[NUMBER_BUFFERS+1][COLUMNS],
ga_clr_text_even_row[NUMBER_BUFFERS][COLUMNS];
int
gp_first_bar,
gp_min_rates_total,
ga_ma_handle[NUMBER_BUFFERS];
bool gp_first;
//+------------------------------------------------------------------+
enum enum_DisplayTable{NO_,IS_,MINIMIZED,};
enum enum_UsePrice{HANDLE,HIGH,LOW,OPEN,CLOSE,};
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES   gp_tf;
enum_DisplayTable gp_display_table=NO_;
enum_UsePrice     ga_use_price[NUMBER_BUFFERS]={HANDLE,HANDLE};
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!InitAny())return(REASON_CHARTCHANGE);
//---
   BuffersInit();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(reason!=REASON_CHARTCHANGE){ObjectsDeleteAll(CHART_ID,gp_ind_shortname);}
//---
   for(int i=NUMBER_BUFFERS-1;i>=0;i--) {if(ga_use_price[i]==HANDLE){IndicatorRelease(ga_ma_handle[i]);}}
//---
   if(reason==REASON_INITFAILED){ChIndicatorDelete(gp_ind_shortname);}
//---
   ChartRedraw();
  }
//+------------------------------------------------------------------+
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
   if(gp_first){if(rates_total-1<gp_min_rates_total || prev_calculated<0) return(rates_total);}
//---
   static datetime time_new_bar=0;
   static int      limit=0;
   static int      digits=DigitsSet(i_digits);
   static int      point_pow=(int)MathPow(10,digits);
   static double   ma_0_indent=IndentDoubleSet(i_ma_0_indent,point_pow,digits);
   static double   ma_1_indent=IndentDoubleSet(i_ma_1_indent,point_pow,digits);
   static bool     ma_0_change_clr_arr[COLUMNS];
   static bool     ma_1_change_clr_arr[COLUMNS];
//---
   ArraySetAsSeries(time,true);
//---
   if(prev_calculated==0)
     {
      if(!StopDataClear())
        {
         time_new_bar=0;
         ArrayInitialize(ma_0_buff,0.0);
         ArrayInitialize(ma_1_buff,0.0);
        }
      //---
      limit=COLUMNS+gp_first_bar+BAR_ADD;
     }
   else{limit=rates_total-prev_calculated+BAR_ADD;}
//---
   if(time_new_bar!=time[0])
     {
      time_new_bar=time[0];
      //---
      if(ga_use_price[BUFF_0]!=HANDLE)
        {if(!CopyPrice(gp_symbol,gp_tf,gp_first_bar,limit,ma_0_buff,ma_0_indent,digits,ga_use_price[BUFF_0])){return(0);}}
      else {if(!CopyIMA(ga_ma_handle[BUFF_0],0,gp_first_bar,limit,ma_0_indent,digits,ma_0_buff)){return(0);}}
      //---
      if(ga_use_price[BUFF_1]!=HANDLE)
        {if(!CopyPrice(gp_symbol,gp_tf,gp_first_bar,limit,ma_1_buff,ma_1_indent,digits,ga_use_price[BUFF_1])){return(0);}}
      else{if(!CopyIMA(ga_ma_handle[BUFF_1],0,gp_first_bar,limit,ma_1_indent,digits,ma_1_buff)){return(0);}}
      //---
      int count=MathMin(limit,COLUMNS);
      //---
      if(count>0)
        {
         TableValuesSet(0,ma_0_buff,point_pow,BUFF_0,count,digits,ma_0_change_clr_arr,gp_first);
         TableValuesSet(NUMBER_ROWS_FOR_ONE_MA,ma_1_buff,point_pow,BUFF_1,count,digits,ma_1_change_clr_arr,gp_first);
         TableDeltaBetweenBuffers(NUMBER_ROWS_FOR_ONE_MA*NUMBER_BUFFERS,ma_0_buff,ma_1_buff,point_pow,NUMBER_BUFFERS,count,gp_first);
         //---
         if(gp_first)
           {
            gp_first=false;
            gp_display_table=IS_;
            TableCreate();
           }
         //---
         if(i_show_lines){BuffersLineClrChange();}
         //---
         BufferBegin(rates_total-(COLUMNS+gp_first_bar+BAR_ADD));
        }
     }//if(time_new_bar!=time[0])
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int    id,
                  const long   &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(StringFind(sparam,gp_ind_shortname)==0)
        {
         string clickedChartObject=sparam;
         //---
         if(gp_display_table==IS_)
           {
            if(StringCompare(clickedChartObject,gp_name_butt,true)==0)
              {
               gp_display_table=MINIMIZED;
               //---
               ObjectsDeleteAll(CHART_ID,gp_ind_shortname);
               //---
               TableButtonsSet(gp_display_table,gp_name_butt,i_distance_x+i_obj_height,
                               i_distance_y,i_obj_height);
               //---
               ChartRedraw();
               return;
              }
           }
         else if(gp_display_table==MINIMIZED)
           {
            gp_display_table=IS_;
            //---
            TableCreate();
            //---
            ChartRedraw();
            return;
           }
         return;
        }
      return;
     }
   return;
  }
//+------------------------------------------------------------------+
bool InitAny()
  {
   gp_display_table =NO_;
   gp_first         =true;
   gp_symbol        =Symbol();
   gp_tf            =Period();
   gp_first_bar     =(i_shift<BAR_ADD) ? BAR_ADD :(int) i_shift;
//---
   IndicatorShortNameSet(gp_ind_shortname,gp_symbol);
//---
   if(COLUMNS<MIN_COLUMNS || COLUMNS>MAX_COLUMNS)
     {Print(LINE_NUMBER,"Error code: COLUMNS.");return(false);}
//---
   int ma_period_arr[NUMBER_BUFFERS]={1,1};
//---
   if(!MADataInit(ma_period_arr)){return(false);}
//---
   gp_min_rates_total=MinRatesTotalNumberSet(ma_period_arr);
//---
   for(int row=0;row<NUMBER_BUFFERS+1;row++)
     {for(int i=0;i<COLUMNS;i++){ga_clr_back_odd_row[row][i]=i_clr_back_main;}}
//---
   StringConcatenate(gp_name_butt,gp_ind_shortname,PREFIX_BUTTONS);
//---
   ObjNameTwoDArray(ROWS,ga_name,PREFIX_COLUMNS);
//---
   return(true);
  }
//+------------------------------------------------------------------+
void IndicatorShortNameSet(string &name,string symbol)
  {
   IndicatorShortNameCreate(name,symbol);
   IndicatorSetString(INDICATOR_SHORTNAME,name);
   return;
  }
//+------------------------------------------------------------------+
int IndicatorShortNameCreate(string &name,string symbol)
  {return(StringConcatenate(name,"MA(table): ",symbol,", x",i_distance_x,", y",i_distance_y));}
//+------------------------------------------------------------------+
bool MADataInit(int &ma_period_arr[])
  {
   if(!MaPeriodSet(i_ma_0_period,BUFF_0+1,ma_period_arr[BUFF_0]))return(false);
   if(!MaPeriodSet(i_ma_1_period,BUFF_1+1,ma_period_arr[BUFF_1]))return(false);
//---
   PriseUse(ma_period_arr[BUFF_0],i_ma_0_method,i_ma_0_applied_price,ga_use_price[BUFF_0]);
   PriseUse(ma_period_arr[BUFF_1],i_ma_1_method,i_ma_1_applied_price,ga_use_price[BUFF_1]);
//---
   if(ga_use_price[BUFF_0]==HANDLE)
     {
      if(!HandleIMACreate(ga_ma_handle[BUFF_0],gp_symbol,gp_tf,ma_period_arr[BUFF_0],MA_SHIFT,i_ma_0_method,i_ma_0_applied_price))
         return(false);
     }
   if(ga_use_price[BUFF_1]==HANDLE)
     {
      if(!HandleIMACreate(ga_ma_handle[BUFF_1],gp_symbol,gp_tf,ma_period_arr[BUFF_1],MA_SHIFT,i_ma_1_method,i_ma_1_applied_price))
         return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
bool MaPeriodSet(const int ma_period,
                 const int index,
                 int       &result)
  {
   if(ma_period<1 || ma_period>MA_PERIOD_MAX)
     {
      Alert("Indicator removed. Period Moving Averages (",IntegerToString(index),": < 1 or > ",MA_PERIOD_MAX,")");
      return(false);
     }
   result=ma_period;
//---
   return(true);
  }
//+------------------------------------------------------------------+
void PriseUse(int ma_period,ENUM_MA_METHOD method,ENUM_APPLIED_PRICE applied_price,enum_UsePrice &use_price)
  {
   if(ma_period==1 && method==MODE_SMA)
     {
      if(applied_price==PRICE_HIGH){use_price=HIGH;return;}
      else if(applied_price==PRICE_LOW){use_price=LOW;return;}
      else if(applied_price==PRICE_OPEN){use_price=OPEN;return;}
      else if(applied_price==PRICE_CLOSE){use_price=CLOSE;return;}
     }
   return;
  }
//+------------------------------------------------------------------+
bool HandleIMACreate(int                &handle,
                     string             symbol,
                     ENUM_TIMEFRAMES    tf,
                     int                ma_period,
                     int                ma_shift,
                     ENUM_MA_METHOD     ma_method,
                     ENUM_APPLIED_PRICE applied_price)
  {
   handle=iMA(symbol,tf,ma_period,ma_shift,ma_method,applied_price);
//---
   if(handle==INVALID_HANDLE)
     {
      Print(LINE_NUMBER,"Failed to create handle of the iMA indicator: ",
            EnumToString(tf),", error: ",GetLastError());
      //---
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
int MinRatesTotalNumberSet(int &period_arr[])
  {
//---две строки ниже применимы только для значений МА с текущего таймфрейма и символа:
   int min[NUMBER_BUFFERS]={1,1};
//---
   for(int i=NUMBER_BUFFERS-1;i>=0;i--){min[i]=period_arr[i]+COLUMNS+gp_first_bar+MIN_BARS;}
//---минимальное количество баров на графике, при котором индикатор будет работать:
   return(min[ArrayMaximum(min)]);
  }
//+------------------------------------------------------------------+
void ObjNameTwoDArray(int    rows,               //сколько строк по оси Y
                      string &array[][COLUMNS],  //массив для имен объектов
                      string pr="_")
  {
   string text=pr;
//---
   for(int row=0;row<rows;row++)
      for(int i=0;i<COLUMNS;i++)
        {
         StringConcatenate(text,gp_ind_shortname,pr,IntegerToString(row),IntegerToString(i));
         //---
         array[row][i]=text;
        }
//---
   return;
  }
//+------------------------------------------------------------------+
bool ChIndicatorDelete(const string short_name,
                       const long   chart_id=0,
                       const int    sub_window=0)
  {
   bool res=ChartIndicatorDelete(chart_id,sub_window,short_name);
//---
   if(!res)
     {
      Print("Failed to delete indicator:\"",short_name,"\". Error: ",GetLastError());
      //---
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
void BuffersInit()
  {
   IndicatorSetInteger(INDICATOR_DIGITS,DigitsSet(i_digits));
//---
   SetIndexBuffer(BUFF_0,ma_0_buff,INDICATOR_DATA);
   SetIndexBuffer(BUFF_1,ma_1_buff,INDICATOR_DATA);
//---
   string name_buff_arr[NUMBER_BUFFERS];
//---
   BufferMaNameSet(name_buff_arr[BUFF_0],BUFF_0+1,i_ma_0_period);
   BufferMaNameSet(name_buff_arr[BUFF_1],BUFF_1+1,i_ma_1_period);
//---
   for(int i=NUMBER_BUFFERS-1;i>=0;i--) {PlotIndexSetString(i,PLOT_LABEL,name_buff_arr[i]);}
   BufferBegin(COLUMNS+gp_first_bar+BAR_ADD);
//---
   for(int i=NUMBER_BUFFERS-1;i>=0;i--) {PlotIndexSetInteger(i,PLOT_LINE_COLOR,clrNONE);}
//---
   for(int i=NUMBER_BUFFERS-1;i>=0;i--) {PlotIndexSetDouble(i,PLOT_EMPTY_VALUE,0.0);}
//---
   return;
  }
//+------------------------------------------------------------------+
int DigitsSet(const enum_Digits variant)
  {return((i_digits==auto) ? Digits() : i_digits);}
//+------------------------------------------------------------------+
int BufferMaNameSet(string &name,int index,int ma_period)
  {return(StringConcatenate(name,index," MA(",IntegerToString(ma_period),"):"));}
//+------------------------------------------------------------------+
void BufferBegin(const int count)
  {
   for(int i=NUMBER_BUFFERS-1;i>=0;i--) {PlotIndexSetInteger(i,PLOT_DRAW_BEGIN,count);}
   return;
  }
//+------------------------------------------------------------------+
template<typename TB>
//+------------------------------------------------------------------+
bool ArrayResizeAndSetAsSeries(TB         &array[],
                               const int  new_size,
                               const int  reserve_size=-1,
                               const bool flag=true)
  {
   ArrayResize(array,new_size,reserve_size);
   int array_size=ArraySize(array);
//---
   if(array_size>1){ArraySetAsSeries(array,flag);}
   else if(array_size<0){return(false);}
   return(true);
  }
//+------------------------------------------------------------------+
double IndentDoubleSet(const int    indent,
                       const int    point_pow,
                       int          digits)
  {
   int max_value=(int)(100*point_pow);//произвольное число: 100 умноженное на 10 в степени digits
   int int_value=(int)MathAbs(indent);
//---
   return((int_value==0 || int_value>=max_value) ? 0.0 : indent*Point());
  }
//+------------------------------------------------------------------+
bool CopyPrice(string          symbol,
               ENUM_TIMEFRAMES tf,
               int             start_pos,
               int             count,
               double          &buffer[],
               double          indent,
               int             digits,
               enum_UsePrice   use)
  {
   double dt[];
   if(!ArrayResizeAndSetAsSeries(dt,count+start_pos,count+start_pos))
     {Print(LINE_NUMBER,"Error code = ",GetLastError());return(false);}
//---
   int copied=-1;
//---
   if(use==HIGH){copied=CopyHigh(symbol,tf,start_pos-BAR_ADD,count,dt);}
   else if(use==LOW){copied=CopyLow(symbol,tf,start_pos-BAR_ADD,count,dt);}
   else if(use==OPEN){copied=CopyOpen(symbol,tf,start_pos-BAR_ADD,count,dt);}
   else if(use==CLOSE){copied=CopyClose(symbol,tf,start_pos-BAR_ADD,count,dt);}
//---
   if(copied<count)
     {
      Print(LINE_NUMBER,"Error code = ",GetLastError());
      return(false);
     }
   else{IndentAdd(buffer,dt,indent,digits,start_pos,count);}
//---
   return(true);
  }
//+------------------------------------------------------------------+
bool  CopyIMA(int    indicator_handle,
              int    buffer_num,
              int    start_pos,
              int    count,
              double indent,
              int    digits,
              double &buffer[])
  {
   double dt[];
   if(!ArrayResizeAndSetAsSeries(dt,count+start_pos,count+start_pos))
     {Print(LINE_NUMBER,"Error code = ",GetLastError());return(-1);}
//---
   if(CopyBuffer(indicator_handle,buffer_num,start_pos-BAR_ADD,count,dt)<0)
     {
      Print(LINE_NUMBER,"Failed to copy data from the iMA indicator, error code: ",GetLastError());
      return(false);
     }
//---
   IndentAdd(buffer,dt,indent,digits,start_pos,count);
//---
   return(true);
  }
//+------------------------------------------------------------------+
void  IndentAdd(double &buffer[],double &array[],double indent,int digits,int start_pos,int count)
  {
   ArraySetAsSeries(buffer,true);
//--- 
   for(int i=count-1;i>=start_pos;i--){buffer[i]=NormalizeDouble(array[i]+indent,digits);}
   for(int i=start_pos-1;i>=0;i--){buffer[i]=0.0;}
   return;
  }
//+------------------------------------------------------------------+
void BuffersLineClrChange()
  {
   static color clr_arr[NUMBER_BUFFERS]={clrNONE,clrNONE};
//---
   for(int i=NUMBER_BUFFERS-1;i>=0;i--)
     {
      if(clr_arr[i]!=ga_clr_back_odd_row[i][0] || clr_arr[i]==clrNONE)
        {
         clr_arr[i]=ga_clr_back_odd_row[i][0];
         //---
         PlotIndexSetInteger(i,PLOT_LINE_COLOR,clr_arr[i]);
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//| Изменение текста и расцветок в ячейках таблицы                   |
//+------------------------------------------------------------------+
void TableValuesSet(const int    row,            //номер начальной строки для МА 
                    const double &buffers[],
                    const double point_pow,
                    const int    index,          //индекс буфера &buffers[]
                    const int    count,          //сколько новых баров для расчета
                    const int    digits,
                    bool         &change_clr[],
                    const bool   flag_first,
                    const long   chart_ID=0)
  {
   double delta_arr[COLUMNS];
   int    copy_old=COLUMNS-count;
//---
   if(copy_old>0)//если был не полный пересчет значений, то перемещение старых значений
     {
      if(!flag_first)
        {
         for(int i=COLUMNS-1;i>=count; i--){ga_text_odd_row[index][i]=ga_text_odd_row[index][i-1];}
         //---
         for(int i=COLUMNS-1;i>=count; i--)
           {
            if(ga_clr_back_odd_row[index][i]!=ga_clr_back_odd_row[index][i-1])
              {
               ga_clr_back_odd_row[index][i]=ga_clr_back_odd_row[index][i-1];
               ga_clr_text_even_row[index][i]=ga_clr_text_even_row[index][i-1];
               change_clr[i]=true;
              }
            else {if(change_clr[i])change_clr[i]=false;}
           }
         for(int i=COLUMNS-1;i>=count; i--){ga_text_even_row[index][i]=ga_text_even_row[index][i-1];}
        }
      else{for(int i=COLUMNS-1;i>=count; i--)change_clr[i]=true;}
     }
//---подготовительные расчеты по еще непосчитанным барам:
   for(int i=count-1;i>=0; i--){ga_text_odd_row[index][i]=DoubleToString(buffers[i+gp_first_bar],digits);}
//---
   for(int i=count-1;i>=0;i--)
     {
      delta_arr[i]=NormalizeDouble((buffers[i+gp_first_bar]-buffers[i+gp_first_bar+1])*point_pow,0);
      ga_text_even_row[index][i]=DoubleToString(delta_arr[i],0);
     }
//---
   ClrChangeInArrays(index,count,delta_arr,ga_clr_back_odd_row,ga_clr_text_even_row,
                     change_clr,0);
//---смена текста и расцветок в строках таблицы на графике:
   if(gp_display_table==IS_)
     {
      for(int i=COLUMNS-1;i>=0;i--)
        {
         if(ObjectFind(0,ga_name[row][i])>-1){ObjSetString(0,ga_name[row][i],OBJPROP_TEXT,ga_text_odd_row[index][i]);}
         //---
         if(change_clr[i]==true){ObjSetIntegerColor(0,ga_name[row][i],OBJPROP_BGCOLOR,ga_clr_back_odd_row[index][i]);}
        }
      //---
      for(int i=COLUMNS-1;i>=0;i--)
        {
         if(ObjectFind(0,ga_name[row+1][i])>-1){ObjSetString(0,ga_name[row+1][i],OBJPROP_TEXT,ga_text_even_row[index][i]);}
         //---
         if(change_clr[i]==true)
           {
            ObjSetIntegerColor(0,ga_name[row+1][i],OBJPROP_COLOR,ga_clr_text_even_row[index][i]);
            change_clr[i]=false;
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//| Текст дельты между двумя разными МА                              |
//+------------------------------------------------------------------+
void TableDeltaBetweenBuffers(const int    row,
                              const double &buffers0[],
                              const double &buffers1[],
                              const double point_pow,
                              const int    index_text,
                              const int    count,
                              const bool   flag_first,
                              const long   chart_ID=0)
  {
   double delta_value =0;
   int    copy_old    =COLUMNS-count;
//---
   if(copy_old>0)//если был не полный пересчет значений, то перемещение старых значений
     {if(!flag_first) {for(int i=COLUMNS-1;i>=count; i--){ga_text_odd_row[index_text][i]=ga_text_odd_row[index_text][i-1];}}}
//---подготовительные расчеты по еще непосчитанным барам:
   for(int i=count-1;i>=0; i--)
     {
      delta_value=MathAbs((buffers0[i+gp_first_bar]-buffers1[i+gp_first_bar])*point_pow);
      ga_text_odd_row[index_text][i]=DoubleToString(delta_value,0);
     }
//---изменения в таблице на графике:
   if(gp_display_table==IS_)
     {
      for(int i=COLUMNS-1;i>=0;i--)
        {
         if(ObjectFind(chart_ID,ga_name[row][i])>-1)
           {ObjSetString(chart_ID,ga_name[row][i],OBJPROP_TEXT,ga_text_odd_row[index_text][i]);}
        }
      ChartRedraw();
     }
   return;
  }
//+------------------------------------------------------------------+
void ObjDelete(long chart_ID,string name)
  {
   if(ObjectFind(chart_ID,name)>-1){ObjectDelete(chart_ID,name);}
   return;
  }
//+------------------------------------------------------------------+
void TableCreate()
  {
   static string ma_0_tooltip =ObjTooltipSet(0,gp_tf,i_ma_0_period,i_ma_0_method,i_ma_0_applied_price);
   static string ma_1_tooltip =ObjTooltipSet(1,gp_tf,i_ma_1_period,i_ma_1_method,i_ma_1_applied_price);
   static int    heigh_small  =SMALL_ROW((int)i_obj_height);
//---
   string tooltip=ma_0_tooltip;
//---
   int height     =(int)i_obj_height;
   int x_dis      =TableTitleSet(heigh_small);
   int y_dis      =(int)i_distance_y+heigh_small+DISTANCE_XY;
   int y_dis_ch   =0;
   int row        =0;
   int step       =0;
//---
   TableButtonsSet(gp_display_table,gp_name_butt,x_dis*COLUMNS,y_dis,HEIGHT_LONG_BUTTON((int)i_obj_height));
//--- 
   y_dis=y_dis+DISTANCE_XY*COLUMNS;
//--- 
   do
     {
      y_dis_ch=y_dis+((height+heigh_small)*(row-step))+((DISTANCE_XY*NUMBER_BUFFERS)*(row-step));
      //---
      if(row==NUMBER_ROWS_FOR_ONE_MA){tooltip=ma_1_tooltip;}
      else if(row==NUMBER_ROWS_FOR_ONE_MA*NUMBER_BUFFERS){tooltip="MA1 - MA2";height=heigh_small;}
      //---
      for(int i=0;i<COLUMNS;i++)
        {
         if(ObjectFind(CHART_ID,ga_name[row][i])<0)
           {
            EditCreate(CHART_ID,ga_name[row][i],0,i_distance_x+x_dis*(i+DISTANCE_XY),
                       y_dis_ch,i_obj_width,height,ga_text_odd_row[row-step][i],tooltip,
                       "Arial",i_font_size,ALIGN_RIGHT,true,CORNER_RIGHT_UPPER,
                       i_clr_text_ma,ga_clr_back_odd_row[row-step][i],clrSnow,i_behind);
           }
        }
      //---
      row+=NUMBER_ROWS_FOR_ONE_MA;
      step++;
     }
   while(row<ROWS && !IsStopped());
//---
   int width_small =SMALL_ROW((int)i_obj_width);
   height          =(int)i_obj_height;
   y_dis           =y_dis+(height+DISTANCE_XY);
   row             =1;
   step            =1;
//--- 
   do
     {
      tooltip=(row>=NUMBER_ROWS_FOR_ONE_MA)? ma_1_tooltip: ma_0_tooltip;
      //---
      y_dis_ch=y_dis+((height+heigh_small)*(row-step))+((DISTANCE_XY*NUMBER_BUFFERS)*(row-step));
      for(int i=0;i<COLUMNS;i++)
        {
         if(ObjectFind(CHART_ID,ga_name[row][i])<0)
           {
            EditCreate(CHART_ID,ga_name[row][i],0,i_distance_x+x_dis*(i+DISTANCE_XY),
                       y_dis_ch,width_small,heigh_small,ga_text_even_row[row-step][i],tooltip,
                       "Arial",i_font_size-1,ALIGN_CENTER,true,CORNER_RIGHT_UPPER,
                       ga_clr_text_even_row[row-step][i],i_clr_back_main,clrSnow,i_behind);
           }
        }
      //---
      row+=NUMBER_ROWS_FOR_ONE_MA;
      step++;
     }
   while(row<ROWS && !IsStopped());
//---
   return;
  }
//+------------------------------------------------------------------+
int  TableTitleSet(const int height)
  {
   static int    x_dis=(int)i_obj_width+DISTANCE_XY;
   static string name_arr[COLUMNS];
   static bool   first=true;
//---
   string        tooltip="Number of bar";
//---
   if(first)
     {
      first=false;
      //---
      for(int i=COLUMNS-1;i>=0;i--){StringConcatenate(name_arr[i],gp_ind_shortname,PREFIX_TITLE,i);}
     }
//---
   for(int i=0;i<COLUMNS;i++)
     {
      if(ObjectFind(CHART_ID,name_arr[i])<0)
        {
         EditCreate(CHART_ID,name_arr[i],0,i_distance_x+x_dis*(i+DISTANCE_XY),
                    i_distance_y,i_obj_width,height,IntegerToString(gp_first_bar+i),
                    tooltip,"Arial",i_font_size-1,ALIGN_CENTER,true,CORNER_RIGHT_UPPER,
                    i_clr_text_delta,i_clr_back_main,clrSnow,i_behind);
        }
     }
   return(x_dis);
  }
//+------------------------------------------------------------------+
string ObjTooltipSet(const int index,ENUM_TIMEFRAMES tf,int ma_period,ENUM_MA_METHOD method,ENUM_APPLIED_PRICE applied_price)
  {
   string text="MA ";
   StringConcatenate(text,text,IntegerToString(index+1),": ",EnumToString(tf),",\r\n",
                     "ma_period: ",ma_period,",\r\n",
                     EnumToString(method),",\r\n",
                     EnumToString(applied_price));
   return(text);
  }
//+------------------------------------------------------------------+
//| Создание кнопок минимизации, в зависимости от условий            |
//+------------------------------------------------------------------+
void TableButtonsSet(enum_DisplayTable flag,string name,int x,int y,int height)
  {
   ObjDelete(CHART_ID,name);
//---
   if(flag==IS_)
     {
      ButtonCreate(CHART_ID,name,0,x,y,i_obj_width*COLUMNS,height,CORNER_RIGHT_UPPER,"","\n",
                   "Arial",0,clrBlack,i_clr_back_main,clrNONE,false,i_behind);
     }
   else if(flag==MINIMIZED)
     {
      ButtonCreate(CHART_ID,name,0,x,y,height,height,CORNER_RIGHT_UPPER,CharToString(CODE_BUTTON),"ID Lite Info MA",
                   "Wingdings",i_font_size+1,clrBlack,i_clr_back_main,clrNONE,false,i_behind);
     }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Функция создает кнопку.                                          |
//| Составлена на основе:                                            |
//| Справочник MQL5  / Стандартные константы, перечисления и         |
//| структуры  / Константы объектов  / Типы объектов / OBJ_BUTTON    |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,           
                  const string            name="Button",           
                  const int               sub_window=0,             
                  const int               x=0,                    
                  const int               y=0,                      
                  const int               width=50,                 
                  const int               height=18,                
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, 
                  const string            text="Button",            
                  const string            tooltip="\n",            
                  const string            font="Arial",            
                  const int               font_size=10,             
                  const color             clr=clrBlack,             
                  const color             back_clr=C'236,233,216',  
                  const color             border_clr=clrNONE,      
                  const bool              state=false,            
                  const bool              back=false,              
                  const bool              selection=false,         
                  const bool              hidden=true,             
                  const long              z_order=0,                
                  const int               timeframes=OBJ_ALL_PERIODS)
  {
//---
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(LINE_NUMBER,__FUNCTION__,
            ": failed to create the button!Error code=",GetLastError());
      return(false);
     }
   ObjSetIntegerInt(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjSetIntegerInt(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjSetIntegerInt(chart_ID,name,OBJPROP_XSIZE,width);
   ObjSetIntegerInt(chart_ID,name,OBJPROP_YSIZE,height);
   ObjSetIntegerCorner(chart_ID,name,corner);
   ObjSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
   ObjSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjSetIntegerInt(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjSetIntegerColor(chart_ID,name,OBJPROP_COLOR,clr);
   ObjSetIntegerColor(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjSetIntegerColor(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
   ObjSetIntegerBool(chart_ID,name,OBJPROP_BACK,back);
   ObjSetIntegerBool(chart_ID,name,OBJPROP_STATE,state);
   ObjSetIntegerBool(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjSetIntegerBool(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjSetIntegerBool(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjSetIntegerLong(chart_ID,name,OBJPROP_ZORDER,z_order);
   ObjSetIntegerInt(chart_ID,name,OBJPROP_TIMEFRAMES,timeframes);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Функция создает объект "Поле ввода".                             |
//| Составлена на основе:                                            |
//| Справочник MQL5 / Стандартные константы, перечисления и          |
//| структуры / Константы объектов / Типы объектов / OBJ_EDIT        |  
//+------------------------------------------------------------------+
bool EditCreate(const long             chart_ID=0,               
                const string           name="Edit",             
                const int              sub_window=0,             
                const int              x=0,                      
                const int              y=0,                      
                const int              width=50,                
                const int              height=20,                
                const string           text="Text",             
                const string           tooltip="\n",             
                const string           font="Arial",             
                const int              font_size=9,              
                const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       
                const bool             read_only=false,          
                const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, 
                const color            clr=clrBlack,            
                const color            back_clr=clrWhite,    
                const color            border_clr=clrNONE,      
                const bool             back=false,             
                const bool             selection=false,          
                const bool             hidden=true,             
                const long             z_order=0,                
                const int             timeframes=OBJ_ALL_PERIODS)
  {
//---
   if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0))
     {
      Print(LINE_NUMBER,__FUNCTION__,
            ": failed to create \"Edit\" object! Error code = ",GetLastError());
      return(false);
     }
   ObjSetIntegerInt(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjSetIntegerInt(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjSetIntegerInt(chart_ID,name,OBJPROP_XSIZE,width);
   ObjSetIntegerInt(chart_ID,name,OBJPROP_YSIZE,height);
   ObjSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
   ObjSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjSetIntegerInt(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjSetIntegerAlign(chart_ID,name,align);
   ObjSetIntegerBool(chart_ID,name,OBJPROP_READONLY,read_only);
   ObjSetIntegerCorner(chart_ID,name,corner);
   ObjSetIntegerColor(chart_ID,name,OBJPROP_COLOR,clr);
   ObjSetIntegerColor(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjSetIntegerColor(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
   ObjSetIntegerBool(chart_ID,name,OBJPROP_BACK,back);
   ObjSetIntegerBool(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjSetIntegerBool(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjSetIntegerBool(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjSetIntegerLong(chart_ID,name,OBJPROP_ZORDER,z_order);
   ObjSetIntegerInt(chart_ID,name,OBJPROP_TIMEFRAMES,timeframes);
//---
   return(true);
  }
//+-------------------------------------------------------------------------------------+
bool ObjSetIntegerInt(long chart_ID,string name,ENUM_OBJECT_PROPERTY_INTEGER pr,int dt)
  {
   if(!ObjectSetInteger(chart_ID,name,pr,dt))
     {
      Print(LINE_NUMBER,__FUNCTION__,", Error Code = ",GetLastError());
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------------------------+
bool ObjSetIntegerCorner(long chart_ID,string name,ENUM_BASE_CORNER corner)
  {
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner))
     {
      Print(LINE_NUMBER,__FUNCTION__,", Error Code = ",GetLastError());
      return(false);
     }
//---
   return(true);
  }
//+---------------------------------------------------------------------------------------------+
bool ObjSetString(long chart_ID,string name,ENUM_OBJECT_PROPERTY_STRING pr,string font)
  {
   if(!ObjectSetString(chart_ID,name,pr,font))
     {
      Print(LINE_NUMBER,__FUNCTION__,", Error Code = ",GetLastError());
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------------------------+
bool ObjSetIntegerColor(long chart_ID,string name,ENUM_OBJECT_PROPERTY_INTEGER pr,color dt)
  {
   if(!ObjectSetInteger(chart_ID,name,pr,dt))
     {
      Print(LINE_NUMBER,__FUNCTION__,", Error Code = ",GetLastError());
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------------------------+
bool ObjSetIntegerLong(long chart_ID,string name,ENUM_OBJECT_PROPERTY_INTEGER pr,long dt)
  {
   if(!ObjectSetInteger(chart_ID,name,pr,dt))
     {
      Print(LINE_NUMBER,__FUNCTION__,", Error Code = ",GetLastError());
      return(false);
     }
   return(true);
  }
//+-------------------------------------------------------------------------------------+
bool ObjSetIntegerBool(long chart_ID,string name,ENUM_OBJECT_PROPERTY_INTEGER pr,bool dt)
  {
   if(!ObjectSetInteger(chart_ID,name,pr,dt))
     {
      Print(LINE_NUMBER,__FUNCTION__,", Error Code = ",GetLastError());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
bool ObjSetIntegerAlign(long chart_ID,string name,ENUM_ALIGN_MODE align)
  {
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align))
     {
      Print(LINE_NUMBER,__FUNCTION__,", Error Code = ",GetLastError());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Функция задает цвет в строке массива, в зависимости от условия   |
//| (на основе сравнения значения дельты с нулем):                   |
//+------------------------------------------------------------------+
void ClrChangeInArrays(int       row,
                       int       columns,
                       double    &price[],
                       color     &back_clr[][COLUMNS],
                       color     &clr[][COLUMNS],
                       bool      &change_clr[],
                       const int digits)
  {
   color clr_0=clrNONE,clr_1=clrNONE;
//---
   for(int i=columns-1;i>=0;i--)
     {
      if(NormalizeDouble(price[i],digits)>0) {clr_0=clr_1=i_clr_back_up;} //if price[1]>price[2]
      else if(NormalizeDouble(price[i],digits)<0) {clr_0=clr_1=i_clr_back_down;} //if price[1]<price[2]
      else if(NormalizeDouble(price[i],digits)==0) {clr_0=i_clr_back_main;clr_1=i_clr_text_delta;} //price[1]=price[2]
      //---
      if(back_clr[row][i]!=clr_0)
        {
         back_clr[row][i]=clr_0;
         clr[row][i]=clr_1;
         change_clr[i]=true;
        }
      else{change_clr[i]=false;}
     }
//---
   return;
  }
//+------------------------------------------------------------------+
bool StopDataClear()
  {
   static int change=0;
//---
   if(change==2){change=0;return(true);}
//---
   change++;
//---
   return(false);
  }
//+------------------------------------------------------------------+
