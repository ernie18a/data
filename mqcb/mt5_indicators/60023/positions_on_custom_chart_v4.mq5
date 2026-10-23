//+------------------------------------------------------------------+
//|                                 Positions_on_Custom_Chart_v3.mq5 |
//|                            Copyright 2023, Ryan Lawrence Johnson |
//|                                https://www.mql5.com/en/users/rjo |
//+------------------------------------------------------------------+
#property copyright "© 2023, Ryan Lawrence Johnson."
#property link      "https://www.mql5.com/en/users/rjo/seller"
#property version   "4.00"
#property indicator_chart_window

#property indicator_buffers 0
#property indicator_plots 0

#include <Trade\OrderInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>

COrderInfo orderInfo;
CDealInfo dealInfo;
CHistoryOrderInfo historyOrderInfo;

//--- input parameters
input string   BaseSymbol = "GBPJPY";
input int	 	TextBarsBack = 100;

long pos_id;
string pos_id_str;
string direction;
string text;
long ord_id;
string ord_id_str;
string pending;

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "BUY");
   ObjectsDeleteAll(0, "SELL");
   ObjectsDeleteAll(0, "SL");
   ObjectsDeleteAll(0, "TP");
   ObjectsDeleteAll(0, "BUY LIMIT");
   ObjectsDeleteAll(0, "BUY STOP");
   ObjectsDeleteAll(0, "BUY STOP LIMIT");
   ObjectsDeleteAll(0, "SELL LIMIT");
   ObjectsDeleteAll(0, "SELL STOP");
   ObjectsDeleteAll(0, "SELL STOP LIMIT");
  }


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   text = "text";
  
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
  
//--- obtain the total number of positions
	int positions = PositionsTotal();
//--- scan the list of orders
	for(int i=0; i<positions; i++)
     {
	   ResetLastError();
	   //--- copy into the cache, the position by its number in the list
	   string symbol = PositionGetSymbol(i); // obtain the name of the symbol by which the position was opened
		if(symbol != "") // if the position was copied into cache, work with it
        {
		   pos_id					   = PositionGetInteger(POSITION_IDENTIFIER);
		   pos_id_str					= (string)pos_id;
		   double price				= PositionGetDouble(POSITION_PRICE_OPEN);
		   double lots             = PositionGetDouble(POSITION_VOLUME);
		   double stoploss			= PositionGetDouble(POSITION_SL);
		   double takeprofit			= PositionGetDouble(POSITION_TP);
		   ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
		   long pos_magic				= PositionGetInteger(POSITION_MAGIC);
		   string Comment				= PositionGetString(POSITION_COMMENT);	   
		   
		   //--- show position levels on chart
			if(symbol == BaseSymbol)
			  {
			   if(type == POSITION_TYPE_BUY)
			     {
			      direction = "BUY";
			     }
				if(type == POSITION_TYPE_SELL)
				  {
				  	direction = "SELL";
				  }
				
				//--- create horizontal line at price of position
				ObjectCreate(0, direction + " " + pos_id_str, OBJ_HLINE, 0, 0, price);
				ObjectSetInteger(0, direction + " " + pos_id_str, OBJPROP_COLOR, clrLimeGreen);
				ObjectSetInteger(0, direction + " " + pos_id_str, OBJPROP_STYLE, STYLE_DOT);
			   
			   //--- create text showing direction of trade, and POSITION_IDENTIFIER
				ObjectCreate(0, direction + text + " " + pos_id_str, OBJ_TEXT, 0, iTime(NULL, 0, TextBarsBack), price);
				ObjectSetString(0, direction + text + " " + pos_id_str, OBJPROP_TEXT, direction + "   " + (string)lots + " lots   " + "   price " + DoubleToString(NormalizeDouble(price, _Digits), _Digits) + "     ticket# " + pos_id_str);
				ObjectSetInteger(0, direction + text + " " + pos_id_str, OBJPROP_COLOR, clrWhite);
				ObjectSetString(0, direction + text + " " + pos_id_str, OBJPROP_FONT, "Arial");				
				ObjectSetInteger(0, direction + text + " " + pos_id_str, OBJPROP_FONTSIZE, 8);
				
				if(stoploss > 0)
				  {
					//--- create horizontal line at stoploss of position
					ObjectCreate(0, "SL" + " " + pos_id_str, OBJ_HLINE, 0, 0, stoploss);
					ObjectSetInteger(0, "SL" + " " + pos_id_str, OBJPROP_COLOR, clrRed);
					ObjectSetInteger(0, "SL" + " " + pos_id_str, OBJPROP_STYLE, STYLE_DASHDOT);
					
				   //--- create text showing stoploss of trade, and POSITION_IDENTIFIER
					ObjectCreate(0, "SL" + text + " " + pos_id_str, OBJ_TEXT, 0, iTime(NULL, 0, TextBarsBack), stoploss);
					ObjectSetString(0, "SL" + text + " " + pos_id_str, OBJPROP_TEXT, "SL" + "   " + (string)lots + " lots   " + "   price " + DoubleToString(NormalizeDouble(stoploss, _Digits), _Digits) + "     ticket# " + pos_id_str);
					ObjectSetInteger(0, "SL" + text + " " + pos_id_str, OBJPROP_COLOR, clrWhite);
					ObjectSetString(0, "SL" + text + " " + pos_id_str, OBJPROP_FONT, "Arial");				
					ObjectSetInteger(0, "SL" + text + " " + pos_id_str, OBJPROP_FONTSIZE, 8);
				  }
				  
				if(takeprofit > 0)
				  {
					//--- create horizontal line at takeprofit of position
					ObjectCreate(0, "TP" + " " + pos_id_str, OBJ_HLINE, 0, 0, takeprofit);
					ObjectSetInteger(0, "TP" + " " + pos_id_str, OBJPROP_COLOR, clrRed);
					ObjectSetInteger(0, "TP" + " " + pos_id_str, OBJPROP_STYLE, STYLE_DASHDOT);
					
				   //--- create text showing takeprofit of trade, and POSITION_IDENTIFIER
					ObjectCreate(0, "TP" + text + " " + pos_id_str, OBJ_TEXT, 0, iTime(NULL, 0, TextBarsBack), takeprofit);
					ObjectSetString(0, "TP" + text + " " + pos_id_str, OBJPROP_TEXT, "TP" + "   " + (string)lots + " lots   " + "   price " + DoubleToString(NormalizeDouble(takeprofit, _Digits), _Digits) + "     ticket# " + pos_id_str);
					ObjectSetInteger(0, "TP" + text + " " + pos_id_str, OBJPROP_COLOR, clrWhite);
					ObjectSetString(0, "TP" + text + " " + pos_id_str, OBJPROP_FONT, "Arial");				
					ObjectSetInteger(0, "TP" + text + " " + pos_id_str, OBJPROP_FONTSIZE, 8);
				  }					 			
			  }
        }
     }
     
//--- select the total number of deals and orders  		  
	HistorySelect(0,TimeCurrent());			
//--- obtain the total number of deals
	int deals = HistoryDealsTotal();
//--- scan the list of deals
	for(int i=0; i<deals; i++)
     {
	   //--- if the position is closed...
	   if(dealInfo.SelectByIndex(i))
		  {
		   // Read deal out and get deal time
			if(dealInfo.PositionId()==pos_id
				&& dealInfo.Entry()==DEAL_ENTRY_OUT)
				  // delete the horizontal line
				  {   
				   ObjectDelete(0, direction + " " + pos_id_str);
				   ObjectDelete(0, direction + text + " " + pos_id_str);
				   ObjectDelete(0, "SL" + " " + pos_id_str);
				   ObjectDelete(0, "SL" + text + " " + pos_id_str);
				   ObjectDelete(0, "TP" + " " + pos_id_str);
				   ObjectDelete(0, "TP" + text + " " + pos_id_str);
				  }
		  }
		else 				  // call to PositionGetSymbol() was unsuccessful
		  {
		   PrintFormat("Error when receiving into the cache position with index &d." +
		   				" Error code: %d", i, GetLastError());
		  }
     }
     
//--- obtain the total number of orders
	int orders = OrdersTotal();
//--- scan the list of orders    
   for(int i=0; i<orders; i++)
     {
      ResetLastError();
	   //--- copy into the cache, the order by its number in the list
	   ulong ticket = OrderGetTicket(i); // obtain the ticket of the order
	   if(ticket != 0) // if the order was copied into cache, work with it
	     {
	      string osymbol				= OrderGetString(ORDER_SYMBOL);  
	      ord_id					   = OrderGetInteger(ORDER_TICKET);
	      ord_id_str					= (string)ord_id;
	      double oprice				= OrderGetDouble(ORDER_PRICE_OPEN);
	      double olots				= OrderGetDouble(ORDER_VOLUME_INITIAL);
		   double ostoploss			= OrderGetDouble(ORDER_SL);
		   double otakeprofit		= OrderGetDouble(ORDER_TP);	      
		   ENUM_ORDER_TYPE otype   = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
		   long ord_magic			   = OrderGetInteger(ORDER_MAGIC);
		   string Comment			   = OrderGetString(ORDER_COMMENT);
		 
		   //--- show order levels on chart
			if(osymbol == BaseSymbol)
			  {
			   if(otype == ORDER_TYPE_BUY_LIMIT)
			     {
			      pending = "BUY LIMIT";
			     }
			   if(otype == ORDER_TYPE_BUY_STOP)
			     {
			      pending = "BUY STOP";
			     }
			   if(otype == ORDER_TYPE_BUY_STOP_LIMIT)
			     {
			      pending = "BUY STOP LIMIT";
			     }
			   if(otype == ORDER_TYPE_SELL_LIMIT)
			     {
			      pending = "SELL LIMIT";
			     }
			   if(otype == ORDER_TYPE_SELL_STOP)
			     {
			      pending = "SELL STOP";
			     }
			   if(otype == ORDER_TYPE_SELL_STOP_LIMIT)
			     {
			      pending = "SELL STOP LIMIT";
			     }
			     
				//--- create horizontal line at price of order
				ObjectCreate(0, pending + " " + ord_id_str, OBJ_HLINE, 0, 0, oprice);
				ObjectSetInteger(0, pending + " " + ord_id_str, OBJPROP_COLOR, clrGreen);
				ObjectSetInteger(0, pending + " " + ord_id_str, OBJPROP_STYLE, STYLE_DASHDOT);
			   
			   //--- create text showing type of order, and ORDER_ID
				ObjectCreate(0, pending + text + " " + ord_id_str, OBJ_TEXT, 0, iTime(NULL, 0, TextBarsBack), oprice);
				ObjectSetString(0, pending + text + " " + ord_id_str, OBJPROP_TEXT, pending + "   " + (string)olots + " lots   " + "   price " + DoubleToString(NormalizeDouble(oprice, _Digits), _Digits) + "     ticket# " + ord_id_str);
				ObjectSetInteger(0, pending + text + " " + ord_id_str, OBJPROP_COLOR, clrWhite);
				ObjectSetString(0, pending + text + " " + ord_id_str, OBJPROP_FONT, "Arial");				
				ObjectSetInteger(0, pending + text + " " + ord_id_str, OBJPROP_FONTSIZE, 8);
				
				if(ostoploss > 0)
				  {
					//--- create horizontal line at stoploss of position
					ObjectCreate(0, "SL" + " " + ord_id_str, OBJ_HLINE, 0, 0, ostoploss);
					ObjectSetInteger(0, "SL" + " " + ord_id_str, OBJPROP_COLOR, clrRed);
					ObjectSetInteger(0, "SL" + " " + ord_id_str, OBJPROP_STYLE, STYLE_DASHDOT);
					
				   //--- create text showing stoploss of trade, and POSITION_IDENTIFIER
					ObjectCreate(0, "SL" + text + " " + ord_id_str, OBJ_TEXT, 0, iTime(NULL, 0, TextBarsBack), ostoploss);
					ObjectSetString(0, "SL" + text + " " + ord_id_str, OBJPROP_TEXT, "SL" + "   " + (string)olots + " lots   " + "   price " + string(NormalizeDouble(ostoploss, _Digits)) + "     ticket# " + ord_id_str);
					ObjectSetInteger(0, "SL" + text + " " + ord_id_str, OBJPROP_COLOR, clrWhite);
					ObjectSetString(0, "SL" + text + " " + ord_id_str, OBJPROP_FONT, "Arial");				
					ObjectSetInteger(0, "SL" + text + " " + ord_id_str, OBJPROP_FONTSIZE, 8);
				  }
				  
				if(otakeprofit > 0)
				  {
					//--- create horizontal line at takeprofit of position
					ObjectCreate(0, "TP" + " " + ord_id_str, OBJ_HLINE, 0, 0, otakeprofit);
					ObjectSetInteger(0, "TP" + " " + ord_id_str, OBJPROP_COLOR, clrRed);
					ObjectSetInteger(0, "TP" + " " + ord_id_str, OBJPROP_STYLE, STYLE_DASHDOT);
					
				   //--- create text showing takeprofit of trade, and POSITION_IDENTIFIER
					ObjectCreate(0, "TP" + text + " " + ord_id_str, OBJ_TEXT, 0, iTime(NULL, 0, TextBarsBack), otakeprofit);
					ObjectSetString(0, "TP" + text + " " + ord_id_str, OBJPROP_TEXT, "TP" + "   " + (string)olots + " lots   " + "   price " + DoubleToString(NormalizeDouble(otakeprofit, _Digits), _Digits) + "     ticket# " + ord_id_str);
					ObjectSetInteger(0, "TP" + text + " " + ord_id_str, OBJPROP_COLOR, clrWhite);
					ObjectSetString(0, "TP" + text + " " + ord_id_str, OBJPROP_FONT, "Arial");				
					ObjectSetInteger(0, "TP" + text + " " + ord_id_str, OBJPROP_FONTSIZE, 8);
				  }					   
			  }	     
	   }
    }

//--- select the total number of deals and orders     		  
	HistorySelect(0,TimeCurrent());			
//--- obtain the total number of orders
	int horders = HistoryOrdersTotal();
//--- scan the list of deals
	for(int i=0; i<horders; i++)
     {
      //--- if the order is closed...
      if(historyOrderInfo.SelectByIndex(i))
		  {
		   // Read order out and get order state
		   if((historyOrderInfo.Ticket()==ord_id)
			  && (historyOrderInfo.State()==ORDER_STATE_CANCELED
			  || historyOrderInfo.State()==ORDER_STATE_EXPIRED
			  || historyOrderInfo.State()==ORDER_STATE_FILLED
			  || historyOrderInfo.State()==ORDER_STATE_PARTIAL
			  || historyOrderInfo.State()==ORDER_STATE_REJECTED))
				 // delete the horizontal line
				 {   
				  ObjectDelete(0, pending + " " + ord_id_str);
				  ObjectDelete(0, pending + text + " " + ord_id_str);
				  ObjectDelete(0, "SL" + " " + ord_id_str);
				  ObjectDelete(0, "SL" + text + " " + ord_id_str);
				  ObjectDelete(0, "TP" + " " + ord_id_str);
				  ObjectDelete(0, "TP" + text + " " + ord_id_str);				  
				  
				 }
		  }
		else 				  // call to PositionGetSymbol() was unsuccessful
		  {
		   PrintFormat("Error when receiving into the cache order with index &d." +
		   				" Error code: %d", i, GetLastError());
		  }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//--------------------------------------------------------------------


