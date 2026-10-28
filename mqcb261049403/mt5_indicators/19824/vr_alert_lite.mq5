//+==================================================================|//
//|                       VR Alert Lite MT 5.mq5                     |//
//|               Copyright 2018, Trading-go Project.                |//
//| Author: Voldemar, Version: 26.01.2018, Site http://trading-go.ru |//
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
//| Full version MetaTrader 4  https://www.mql5.com/ru/market/product/13548
//| Lite version MetaTrader 4  https://www.mql5.com/ru/code/11606
//| Full version MetaTrader 5  https://www.mql5.com/ru/market/product/23438   //Works with other indicators and price
//| Lite version MetaTrader 5  https://www.mql5.com/ru/code/19824
//|==================================================================|//
//| All products of the Author https://www.mql5.com/ru/users/voldemar/seller
//|==================================================================|//
#property copyright   "Copyright 2018, Trading-go Project."
#property link        "http://trading-go.ru"
#property version     "18.010"
#property description "VR Alert the indicator warns the trader that the price reached specified levels."
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
#property strict
MqlTick tick;
long Chart_ID;
string Prefix="DFSER-";
double PriceUP=9999999,PriceDW=0, prices=0;
int counter_up=0, counter_dw=0, counter_ti=0, signals=3;
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
int OnInit()
  {
   Comment("");
   Chart_ID=ChartID();

   if(ObjectFind(Chart_ID,Prefix+"ButtonUP")!=0)
      ButtonCreate(Chart_ID,Prefix+"ButtonUP",4,15,20,16,CORNER_LEFT_UPPER,"UP","Arial",8,clrWhite,clrBlue,clrNONE,false,false,false,true,0);

   if(ObjectFind(Chart_ID,Prefix+"ButtonDW")!=0)
      ButtonCreate(Chart_ID,Prefix+"ButtonDW",26,15,20,16,CORNER_LEFT_UPPER,"DW","Arial",8,clrWhite,clrTomato,clrNONE,false,false,false,true,0);

   if(ObjectFind(Chart_ID,Prefix+"ButtonTI")!=0)
      ButtonCreate(Chart_ID,Prefix+"ButtonTI",48,15,20,16,CORNER_LEFT_UPPER,"TI","Arial",8,clrWhite,clrGreen,clrNONE,false,false,false,true,0);

   EventSetTimer(1);
   ChartSetInteger(Chart_ID,CHART_EVENT_MOUSE_MOVE,true);
   return(INIT_SUCCEEDED);

  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {

   double chart_max=ChartGetDouble(Chart_ID,CHART_PRICE_MAX,0);
   double chart_min=ChartGetDouble(Chart_ID,CHART_PRICE_MIN,0);

   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      double chart_del=(chart_max-chart_min)/10;
      // ===
      if(ObjectFind(Chart_ID,Prefix+"ButtonUP")==0)
         if(GetState(Prefix+"ButtonUP"))
           {
            if(ObjectFind(Chart_ID,Prefix+"LineUP")!=0)
               HLineCreate(Chart_ID,Prefix+"LineUP",NormalizeDouble(chart_max-chart_del,Digits()),clrBlue,STYLE_DASH,1,false,true,true,0);
            if(ObjectFind(Chart_ID,Prefix+"TextUP")!=0)
               TextCreate(Chart_ID,Prefix+"TextUP",0,0,CharToString(233),"Wingdings",12,clrBlue,0.0,ANCHOR_LEFT_UPPER,false,false,true,0);
           }
      else
        {
         if(ObjectFind(Chart_ID,Prefix+"LineUP")==0)
            ObjectDelete(Chart_ID,Prefix+"LineUP");
         if(ObjectFind(Chart_ID,Prefix+"TextUP")==0)
            ObjectDelete(Chart_ID,Prefix+"TextUP");
        }
      // ===
      if(ObjectFind(Chart_ID,Prefix+"ButtonDW")==0)
         if(GetState(Prefix+"ButtonDW"))
           {
            if(ObjectFind(Chart_ID,Prefix+"LineDW")!=0)
               HLineCreate(Chart_ID,Prefix+"LineDW",NormalizeDouble(chart_min+chart_del,Digits()),clrRed,STYLE_DASH,1,false,true,true,0);
            if(ObjectFind(Chart_ID,Prefix+"TextDW")!=0)
               TextCreate(Chart_ID,Prefix+"TextDW",0,0,CharToString(234),"Wingdings",12,clrRed,0.0,ANCHOR_LEFT_LOWER,false,false,true,0);
           }
      else
        {
         if(ObjectFind(Chart_ID,Prefix+"LineDW")==0)
            ObjectDelete(Chart_ID,Prefix+"LineDW");
         if(ObjectFind(Chart_ID,Prefix+"TextDW")==0)
            ObjectDelete(Chart_ID,Prefix+"TextDW");
        }
      // ===
      if(ObjectFind(Chart_ID,Prefix+"ButtonTI")==0)
         if(GetState(Prefix+"ButtonTI"))
           {
            if(ObjectFind(Chart_ID,Prefix+"LineTI")!=0)
               VLineCreate(Chart_ID,Prefix+"LineTI",TimeCurrent()+PeriodSeconds()*5,clrGreen,STYLE_DASH,1,false,true,true,0);
            if(ObjectFind(Chart_ID,Prefix+"TextTI")!=0)
               TextCreate(Chart_ID,Prefix+"TextTI",0,0,CharToString(232),"Wingdings",12,clrGreen,0.0,ANCHOR_LEFT_UPPER,false,false,true,0);
           }
      else
        {
         if(ObjectFind(Chart_ID,Prefix+"LineTI")==0)
            ObjectDelete(Chart_ID,Prefix+"LineTI");
         if(ObjectFind(Chart_ID,Prefix+"TextTI")==0)
            ObjectDelete(Chart_ID,Prefix+"TextTI");
        }
      // ===
      ChartRedraw(Chart_ID);
     }
// === // === // ===
// === // === // ===
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      if(ObjectFind(Chart_ID,Prefix+"LineUP")==0)
        {
         double price_line  = GetPrice(Prefix+"LineUP");
         datetime time_line = TimeCurrent();
         SetPrice(Prefix+"TextUP",price_line);
         SetTime(Prefix+"TextUP",time_line);
        }
      if(ObjectFind(Chart_ID,Prefix+"LineDW")==0)
        {
         double price_line  = GetPrice(Prefix+"LineDW");
         datetime time_line = TimeCurrent();
         SetPrice(Prefix+"TextDW",price_line);
         SetTime(Prefix+"TextDW",time_line);
        }
      if(ObjectFind(Chart_ID,Prefix+"LineTI")==0)
        {
         datetime time_line=GetTime(Prefix+"LineTI");
         SetPrice(Prefix+"TextTI",prices);
         SetTime(Prefix+"TextTI",time_line);
        }
      // ===
      ChartRedraw(Chart_ID);
     }
// ===
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
int OnCalculate (const int rates_total,      // размер массива price[] 
                 const int prev_calculated,  // обработано баров на предыдущем вызове 
                 const int begin,            // откуда начинаются значимые данные 
                 const double& price[]       // массив для расчета 
                 )
  {
   return(rates_total);
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
void OnTimer()
  {
// ===
   if(!SymbolInfoTick(Symbol(),tick))
      Print("SymbolInfoTick() failed, error = ",GetLastError());

   prices=tick.ask;
// ===
   if(ObjectFind(Chart_ID,Prefix+"LineUP")==0)
     {
      double line_price=NormalizeDouble(GetPrice(Prefix+"LineUP"),Digits());
      if((line_price-tick.ask)>=50*Point())
         counter_up=0;
     }
// ===
   if(ObjectFind(Chart_ID,Prefix+"LineDW")==0)
     {
      double line_price=NormalizeDouble(GetPrice(Prefix+"LineDW"),Digits());
      if((tick.bid-line_price)>=50*Point())
         counter_dw=0;
     }
// ===
   if(ObjectFind(Chart_ID,Prefix+"LineTI")==0)
     {
      datetime line_time=GetTime(Prefix+"LineTI");
      if((line_time-tick.time)>=PeriodSeconds()*5)
         counter_ti=0;
     }
// === // === // ===
// === // === // ===
   string text=Symbol()+" "+StringSubstr(EnumToString(Period()),7);
// ===
   if(GetState(Prefix+"ButtonUP"))
      if(ObjectFind(Chart_ID,Prefix+"LineUP")==0 && counter_up<signals)
        {
         double Price= ObjectGetDouble(Chart_ID,Prefix+"LineUP",OBJPROP_PRICE);
         if(tick.ask>=NormalizeDouble(Price,Digits()) && Price > 0 )
           {
            Alert(text," Current price >= Line UP");
            counter_up++;
           }
        }
// ===
   if(GetState(Prefix+"ButtonDW"))
      if(ObjectFind(Chart_ID,Prefix+"LineDW")==0 && counter_dw<signals)
        {
         double Price= ObjectGetDouble(Chart_ID,Prefix+"LineDW",OBJPROP_PRICE);
         if(tick.bid<=NormalizeDouble(Price,Digits()) && Price > 0 )
           {
            Alert(text," Current price <= Line DW");
            counter_dw++;
           }
        }
// ===
   if(GetState(Prefix+"ButtonTI"))
      if(ObjectFind(Chart_ID,Prefix+"LineTI")==0 && counter_ti<signals)
        {
         datetime Times=(datetime)ObjectGetInteger(Chart_ID,Prefix+"LineTI",OBJPROP_TIME);
         if(tick.time>=Times && Times!=NULL)
           {
            Alert(text," Current time >= Line TI");
            counter_ti++;
           }
        }
// ===
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
void OnDeinit(const int reason)
  {
   if(reason==REASON_REMOVE || reason==REASON_RECOMPILE || reason==REASON_INITFAILED)
      ObjectsDeleteAll(Chart_ID,Prefix);

   EventKillTimer();
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
bool GetState(string aName)
  {
   long value=0;
   ObjectGetInteger(Chart_ID,aName,OBJPROP_STATE,0,value);
   return  (bool)value;
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
bool SetState(string aName,bool SetState)
  {
   return ObjectSetInteger(Chart_ID,aName,OBJPROP_STATE,SetState);
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
double GetPrice(string aName)
  {
   return ObjectGetDouble(Chart_ID,aName,OBJPROP_PRICE);
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
datetime GetTime(string aName)
  {
   datetime aValue=NULL;
   ObjectGetInteger(Chart_ID,aName,OBJPROP_TIME,0,aValue);
   return aValue;
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
bool SetPrice(string aName,double aPrice)
  {
   return ObjectSetDouble(Chart_ID,aName,OBJPROP_PRICE,0,aPrice);
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
bool SetTime(string aName,datetime aTime)
  {
   return ObjectSetInteger(Chart_ID,aName,OBJPROP_TIME,0, aTime);
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
bool ButtonCreate(const long              chart_ID=0,               // ID графика 
                  const string            name="Button",            // имя кнопки 
                  const int               x=0,                      // координата по оси X 
                  const int               y=0,                      // координата по оси Y 
                  const int               width=50,                 // ширина кнопки 
                  const int               height=18,                // высота кнопки 
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // угол графика для привязки 
                  const string            text="Button",            // текст 
                  const string            font="Arial",             // шрифт 
                  const int               font_size=10,             // размер шрифта 
                  const color             clr=clrBlack,             // цвет текста 
                  const color             back_clr=C'236,233,216',  // цвет фона 
                  const color             border_clr=clrNONE,       // цвет границы 
                  const bool              state=false,              // нажата/отжата 
                  const bool              back=false,               // на заднем плане 
                  const bool              selection=false,          // выделить для перемещений 
                  const bool              hidden=true,              // скрыт в списке объектов 
                  const long              z_order=0)                // приоритет на нажатие мышью 
  {
   if(ObjectCreate(chart_ID,name,OBJ_BUTTON,0,0,0))
     {
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      return(true);
     }
   else
      return (false);
   return(true);
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
bool HLineCreate(const long            chart_ID=0,// ID графика 
                 const string          name="HLine",      // имя линии 
                 double                price=0,           // цена линии 
                 const color           clr=clrRed,        // цвет линии 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линии 
                 const int             width=1,           // толщина линии 
                 const bool            back=false,        // на заднем плане 
                 const bool            selection=true,    // выделить для перемещений 
                 const bool            hidden=true,       // скрыт в списке объектов 
                 const long            z_order=0)         // приоритет на нажатие мышью 
  {
   if(ObjectCreate(chart_ID,name,OBJ_HLINE,0,0,price))
     {
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      return(true);
     }
   else
      return (false);
   return(true);
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
bool VLineCreate(const long            chart_ID=0,// ID графика 
                 const string          name="VLine",      // имя линии 
                 datetime              time=0,            // время линии 
                 const color           clr=clrRed,        // цвет линии 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линии 
                 const int             width=1,           // толщина линии 
                 const bool            back=false,        // на заднем плане 
                 const bool            selection=true,    // выделить для перемещений 
                 const bool            ray=true,          // продолжение линии вниз 
                 const bool            hidden=true,       // скрыт в списке объектов 
                 const long            z_order=0)         // приоритет на нажатие мышью 
  {
   if(ObjectCreate(chart_ID,name,OBJ_VLINE,0,time,0))
     {
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_RAY,ray);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      return(true);
     }
   else
      return (false);
   return(true);
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
bool TextCreate(const long              chart_ID=0,               // ID графика 
                const string            name="Text",              // имя объекта 
                datetime                time=0,                   // время точки привязки 
                double                  price=0,                  // цена точки привязки 
                const string            text="Text",              // сам текст 
                const string            font="Arial",             // шрифт 
                const int               font_size=10,             // размер шрифта 
                const color             clr=clrRed,               // цвет 
                const double            angle=0.0,                // наклон текста 
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // способ привязки 
                const bool              back=false,               // на заднем плане 
                const bool              selection=false,          // выделить для перемещений 
                const bool              hidden=true,              // скрыт в списке объектов 
                const long              z_order=0)                // приоритет на нажатие мышью 
  {
   if(ObjectCreate(chart_ID,name,OBJ_TEXT,0,time,price))
     {
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
      ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      return(true);
     }
   else
      return (false);
   return(true);
  }
//|==================================================================|//
//|                                                                  |//
//|==================================================================|//
