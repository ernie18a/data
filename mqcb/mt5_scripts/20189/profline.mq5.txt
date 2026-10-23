//+------------------------------------------------------------------+
//|                                                     ProfLine.mq5 |
//|                                                              x5d |
//|                                https://www.mql5.com/ru/users/x5d |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, x5d"
#property link      "https://www.mql5.com/ru/users/x5d"
#property indicator_chart_window
#property version   "1.00"

//+------------------------------------------------------------------+
//| Declaration of variables                                         |
//+------------------------------------------------------------------+
extern double Profit=0.0; 
extern int MagicNumber = 0; 
extern string NameBuy = "LineBuy"; 
extern string NameSell = "LineSell"; 
extern color ColorBuy = DarkBlue; 
extern color ColorSell = FireBrick; 
double LotsBuy, LotsSell; 

//+------------------------------------------------------------------+ 
//| Custom indicator deinitialization function                       | 
//+------------------------------------------------------------------+ 
 void deinit() 
 { 
   if (ObjectFind(0,NameBuy)!=-1) ObjectDelete(0,NameBuy); 
   if (ObjectFind(0,NameSell)!=-1) ObjectDelete(0,NameSell); 
 } 

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   if (ObjectFind(0,NameBuy)!=-1) ObjectDelete(0,NameBuy); 
   if (ObjectFind(0,NameSell)!=-1) ObjectDelete(0,NameSell); 
    
   double ProfitBuy = ProfitPrice(Symbol(), "ORDER_TYPE_BUY", MagicNumber, Profit); 
   double ProfitSell = ProfitPrice(Symbol(), "ORDER_TYPE_SELL", MagicNumber, Profit); 

   if (ObjectFind(0,NameBuy)==-1)
   {
    if(!HLineCreate(0,NameBuy,0,ProfitBuy,ColorBuy)) 
     { 
      return; 
     } 
   ChartRedraw(); 
   }
   if (ObjectFind(0,NameSell)==-1)
   {
    if(!HLineCreate(0,NameSell,0,ProfitSell,ColorSell)) 
     { 
      return; 
     } 
   ChartRedraw(); 
   }
   
  }
  
//+------------------------------------------------------------------+
//| Function of drawing a horizontal line                            |
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID=0,        // ID графика 
                 const string          name="HLine",      // имя линии 
                 const int             sub_window=0,      // номер подокна 
                 double                price=0,           // цена линии 
                 const color           clr=clrRed,        // цвет линии 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линии 
                 const int             width=1,           // толщина линии 
                 const bool            back=false,        // на заднем плане 
                 const bool            selection=true,    // выделить для перемещений 
                 const bool            hidden=true,       // скрыт в списке объектов 
                 const long            z_order=0)         // приоритет на нажатие мышью 
  { 

   ResetLastError(); 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price)) 
     { 
      Print(__FUNCTION__, 
            ": не удалось создать горизонтальную линию! Код ошибки = ",GetLastError()); 
      return(false); 
     } 
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


//+------------------------------------------------------------------+
//| Profit line calculation function                                 |
//+------------------------------------------------------------------+
double ProfitPrice(string fSymbol, string fType, int fMagic=0, double MyProfit=0.0)
{ 
   //Функция возвращает цену, на которую необходимо установить уровень TakeProfit, чтобы получить прибыль MyProfit 
   double SummPrice=0.0, SummLots=0.0, Formula=0.0; 
   int SumTiket =0;
   int total=PositionsTotal();
      
   for(int i=total-1; i>=0; i--)
   {
   PositionGetSymbol(i);
    if(PositionGetString(POSITION_SYMBOL)==fSymbol)
     {
     if(PositionGetInteger(POSITION_MAGIC)==fMagic || fMagic==0)
      {
      if(EnumToString(ENUM_ORDER_TYPE(PositionGetInteger(POSITION_TYPE)))==fType)
       {
        SummLots=SummLots+PositionGetDouble(POSITION_VOLUME);
        SummPrice=SummPrice+(PositionGetDouble(POSITION_PRICE_OPEN)*PositionGetDouble(POSITION_VOLUME));
        SumTiket = SumTiket+1;
       }
      }
     }
   }
   
   if(SumTiket>0)
   { 
    
    if(fType=="ORDER_TYPE_BUY")
    { 
     Formula = SummPrice/SummLots + 
     MyProfit * SymbolInfoDouble(fSymbol,SYMBOL_POINT) / 
     (SymbolInfoDouble(fSymbol,SYMBOL_TRADE_TICK_SIZE) * SummLots) + 
     (SymbolInfoInteger(fSymbol,SYMBOL_SPREAD) * SymbolInfoDouble(fSymbol,SYMBOL_POINT)); 
     LotsBuy = SummLots; 
    } 
    if(fType=="ORDER_TYPE_SELL") 
    { 
     Formula = SummPrice/SummLots - 
     MyProfit * SymbolInfoDouble(fSymbol,SYMBOL_POINT) / 
     (SymbolInfoDouble(fSymbol,SYMBOL_TRADE_TICK_SIZE) * SummLots) - 
     (SymbolInfoInteger(fSymbol,SYMBOL_SPREAD) * SymbolInfoDouble(fSymbol,SYMBOL_POINT));
     LotsSell = SummLots;    
    } 
   } 
   
   return(Formula); 
}//ProfitPrice() 