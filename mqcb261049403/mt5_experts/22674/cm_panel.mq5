//+------------------------------------------------------------------+
//|                               Copyright © 2018, Хлыстов Владимир |
//|                                                cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, http://cmillion.ru"
#property link      "cmillion@narod.ru"
#property strict
#property description "Советник выставляет ордера при нажатии на кнопки"
//--------------------------------------------------------------------
extern int     LevelB               = 100;         //расстояние до BuyStop ордеров
extern int     LevelS               = 100;         //расстояние до SellStop ордеров
extern double  LotB                 = 0.10;        //объем BuyStop ордеров 
extern double  LotS                 = 0.10;        //объем SellStop ордеров 
extern int     StopLossBUY          = 100;
extern int     StopLossSELL         = 100;
extern int     TakeProfitBUY        = 150;
extern int     TakeProfitSELL       = 150;
extern int     Magic                = 1;           //магик ордеров
extern int X=100;
extern int Y=25;
//--------------------------------------------------------------------
double STOPLEVEL;
double Bid,Ask;
MqlTradeRequest request;
MqlTradeResult result;
//-------------------------------------------------------------------- 
int OnInit()
{ 
   RectLabelCreate(0,"cm Rect" ,0,X,Y,270,80);Y+=5;
   EditCreate(0,"cm Buy LevelT",0,X+5,Y,40,20,"Level","Arial",8,ALIGN_CENTER,true,0,clrBlack,clrLightGray);
   EditCreate(0,"cm Buy LotT"  ,0,X+50,Y,40,20,"Lot","Arial",8,ALIGN_CENTER,true,0,clrBlack,clrLightGray);
   EditCreate(0,"cm Buy slT"   ,0,X+95,Y,40,20,"SL","Arial",8,ALIGN_CENTER,true,0,clrBlack,clrLightGray);
   EditCreate(0,"cm Buy tpT"   ,0,X+140,Y,40,20,"TP","Arial",8,ALIGN_CENTER,true,0,clrBlack,clrLightGray);
   ButtonCreate(0,"cm delete",0,X+185,Y,80,20,"delete");
   //EditCreate(0,"cm cmillion"  ,0,X+185,Y,80,20,"http://cmillion.ru","Arial",8,ALIGN_CENTER,true,0,clrBlack,clrLightGray);
   
   Y+=25;
   EditCreate(0,"cm Buy Level" ,0,X+5,Y,40,20,IntegerToString(LevelB),"Arial",8,ALIGN_CENTER,false);
   EditCreate(0,"cm Buy Lot"   ,0,X+50,Y,40,20,DoubleToString(LotB,2),"Arial",8,ALIGN_CENTER,false);
   EditCreate(0,"cm Buy sl"    ,0,X+95,Y,40,20,IntegerToString(StopLossBUY),"Arial",8,ALIGN_CENTER,false);
   EditCreate(0,"cm Buy tp"    ,0,X+140,Y,40,20,IntegerToString(TakeProfitBUY),"Arial",8,ALIGN_CENTER,false);
   ButtonCreate(0,"cm open Buy",0,X+185,Y,80,20,"Buy Stop");
   
   Y+=25;
   EditCreate(0,"cm Sell Level" ,0,X+5,Y,40,20,IntegerToString(LevelS),"Arial",8,ALIGN_CENTER,false);
   EditCreate(0,"cm Sell Lot"   ,0,X+50,Y,40,20,DoubleToString(LotS,2),"Arial",8,ALIGN_CENTER,false);
   EditCreate(0,"cm Sell sl"    ,0,X+95,Y,40,20,IntegerToString(StopLossSELL),"Arial",8,ALIGN_CENTER,false);
   EditCreate(0,"cm Sell tp"    ,0,X+140,Y,40,20,IntegerToString(TakeProfitSELL),"Arial",8,ALIGN_CENTER,false);
   ButtonCreate(0,"cm open Sell",0,X+185,Y,80,20,"Sell Stop");
   return(INIT_SUCCEEDED);
}
//-------------------------------------------------------------------
void OnTick()
{
   Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   STOPLEVEL=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   LotB=StringToDouble(ObjectGetString(0,"cm Buy Lot",OBJPROP_TEXT));
   LotS=StringToDouble(ObjectGetString(0,"cm Sell Lot",OBJPROP_TEXT));
   LevelB=(int)StringToInteger(ObjectGetString(0,"cm Buy Level",OBJPROP_TEXT));
   LevelS=(int)StringToInteger(ObjectGetString(0,"cm Sell Level",OBJPROP_TEXT));
   
   StopLossBUY=(int)StringToInteger(ObjectGetString(0,"cm Buy sl",OBJPROP_TEXT));
   StopLossSELL=(int)StringToInteger(ObjectGetString(0,"cm Sell sl",OBJPROP_TEXT));
   TakeProfitBUY=(int)StringToInteger(ObjectGetString(0,"cm Buy tp",OBJPROP_TEXT));
   TakeProfitSELL=(int)StringToInteger(ObjectGetString(0,"cm Sell tp",OBJPROP_TEXT));

   //---
   bool buy=ObjectGetInteger(0,"cm open Buy",OBJPROP_STATE);
   bool sell=ObjectGetInteger(0,"cm open Sell",OBJPROP_STATE);
   if (ObjectGetInteger(0,"cm delete",OBJPROP_STATE))
   {
      int i;
      ulong Ticket=0;
      for(i=0; i<OrdersTotal(); i++)
      {
         ZeroMemory(request);
         if((Ticket=OrderGetTicket(i))>0)
         {
            if(OrderGetInteger(ORDER_MAGIC)!=Magic || OrderGetString(ORDER_SYMBOL)!=_Symbol) continue;
            if (OrderGetInteger(ORDER_TYPE)>1)  
            {
               request.order=Ticket;
               request.action=TRADE_ACTION_REMOVE;
               request.comment="deleteorders";
               if(!OrderSend(request,result))
                  PrintFormat("OrderSend ",request.type," error %d",GetLastError()); 
            }
         }
      }
      if (Ticket==0) ObjectSetInteger(0,"cm delete",OBJPROP_STATE,false);
   }
   //---
   ZeroMemory(request);
   ZeroMemory(result);
   request.action=TRADE_ACTION_DEAL;
   request.symbol=_Symbol;
   request.volume = 0; 
   //---
   if (buy)
   {
      request.volume = LotB; 
      request.price = NormalizeDouble(Ask+LevelB*_Point,_Digits);
      request.type=ORDER_TYPE_BUY_STOP;
      request.sl = NormalizeDouble(request.price-StopLossBUY*_Point,_Digits);
      request.tp = NormalizeDouble(request.price+TakeProfitBUY*_Point,_Digits);
   } 
   if (sell)
   {
      request.volume = LotS; 
      request.price = NormalizeDouble(Bid-LevelS*_Point,_Digits);
      request.type=ORDER_TYPE_SELL_STOP;
      request.sl = NormalizeDouble(request.price+StopLossSELL*_Point,_Digits);
      request.tp = NormalizeDouble(request.price-TakeProfitSELL*_Point,_Digits);
   } 
   //---
   if(request.volume != 0)
   { 
      request.action=TRADE_ACTION_PENDING;
      request.symbol=_Symbol;
      request.comment="www.cmillion.ru";
      request.type_time=ORDER_TIME_GTC;
      request.magic=Magic;
      if(!OrderSend(request,result))
         PrintFormat("OrderSend ",request.type," error %d",GetLastError()); 
      else
      {
         ObjectSetInteger(0,"cm open Buy",OBJPROP_STATE,false);
         ObjectSetInteger(0,"cm open Sell",OBJPROP_STATE,false);
      }
   }
return;
}
//--------------------------------------------------------------------
color Color(bool P,color a,color b)
{
   if (P) return(a);
   else return(b);
}
//------------------------------------------------------------------
void DrawLABEL(string name, string Name, int x, int y, color clr,ENUM_ANCHOR_POINT align=ANCHOR_RIGHT)
{
   if (ObjectFind(0,name)==-1)
   {
      ObjectCreate(0,name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0,name,OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,align); 
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr); 
      ObjectSetString(0,name,OBJPROP_FONT,"Arial"); 
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,8); 
      ObjectSetDouble(0,name,OBJPROP_ANGLE,0); 
   }
   ObjectSetString(0,name,OBJPROP_TEXT,Name); 
}
//--------------------------------------------------------------------
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0,"cm");
   Comment("");
}
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,               // ID графика
                  const string            name="Button",            // имя кнопки
                  const int               sub_window=0,             // номер подокна
                  const long               x=0,                      // координата по оси X
                  const long               y=0,                      // координата по оси Y
                  const int               width=50,                 // ширина кнопки
                  const int               height=18,                // высота кнопки
                  const string            text="Button",            // текст
                  const string            font="Arial",             // шрифт
                  const int               font_size=8,             // размер шрифта
                  const color             clr=clrBlack,               // цвет текста
                  const color             clrON=clrLightGray,            // цвет фона
                  const color             clrOFF=clrLightGray,          // цвет фона
                  const color             border_clr=clrNONE,       // цвет границы
                  const bool              state=false,       // цвет границы
                  const ENUM_BASE_CORNER  CORNER=CORNER_LEFT_UPPER)
  {
   if (ObjectFind(chart_ID,name)==-1)
   {
      ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,CORNER);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,1);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,1);
      ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
   }
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
   color back_clr;
   if (ObjectGetInteger(chart_ID,name,OBJPROP_STATE)) back_clr=clrON; else back_clr=clrOFF;
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   return(true);
}
//--------------------------------------------------------------------
bool RectLabelCreate(const long             chart_ID=0,               // ID графика
                     const string           name="RectLabel",         // имя метки
                     const int              sub_window=0,             // номер подокна
                     const long              x=0,                     // координата по оси X
                     const long              y=0,                     // координата по оси y
                     const int              width=50,                 // ширина
                     const int              height=18,                // высота
                     const color            back_clr=clrWhite,        // цвет фона
                     const color            clr=clrBlack,             // цвет плоской границы (Flat)
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // стиль плоской границы
                     const int              line_width=1,             // толщина плоской границы
                     const bool             back=false,               // на заднем плане
                     const bool             selection=false,          // выделить для перемещений
                     const bool             hidden=true,              // скрыт в списке объектов
                     const long             z_order=0)                // приоритет на нажатие мышью
  {
   ResetLastError();
   if (ObjectFind(chart_ID,name)==-1)
   {
      ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0);
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   }
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   return(true);
}
//--------------------------------------------------------------------
bool EditCreate(const long             chart_ID=0,               // ID графика 
                const string           name="Edit",              // имя объекта 
                const int              sub_window=0,             // номер подокна 
                const int              x=0,                      // координата по оси X 
                const int              y=0,                      // координата по оси Y 
                const int              width=50,                 // ширина 
                const int              height=18,                // высота 
                const string           text="Text",              // текст 
                const string           font="Arial",             // шрифт 
                const int              font_size=8,             // размер шрифта 
                const ENUM_ALIGN_MODE  align=ALIGN_RIGHT,       // способ выравнивания 
                const bool             read_only=true,           // возможность редактировать 
                const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // угол графика для привязки 
                const color            clr=clrBlack,             // цвет текста 
                const color            back_clr=clrWhite,        // цвет фона 
                const color            border_clr=clrNONE,       // цвет границы 
                const bool             back=false,               // на заднем плане 
                const bool             selection=false,          // выделить для перемещений 
                const bool             hidden=true,              // скрыт в списке объектов 
                const long             z_order=0)                // приоритет на нажатие мышью 
  { 
   ResetLastError(); 
   if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0)) 
     { 
      Print(__FUNCTION__, 
            ": не удалось создать объект ",name,"! Код ошибки = ",GetLastError()); 
      return(false); 
     } 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y); 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height); 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align); 
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only); 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner); 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr); 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr); 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
