//+------------------------------------------------------------------+
//|                                               KeyboardTrader.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

CTrade trade;  // Handelsobjekt
input int magicNumber = 123456; // Magische Nummer zur Identifizierung von Orders

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  // Setzen der magischen Nummer für Handelsoperationen
  trade.SetExpertMagicNumber(magicNumber);

  // Initialisierung des Expert Advisors
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  // Bereinigung bei der Deinitialisierung
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  // Hauptlogik für Tick-Daten; für dieses Skript nicht benötigt
}

//+------------------------------------------------------------------+
//| Chart event function                                             |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
  if (id == CHARTEVENT_KEYDOWN)
  {
    char key = (char)lparam;  // Konvertierung des Tastencodes von long zu char
    switch(key)
    {
      case '1':
        // Kaufauftrag mit Standardparametern
        trade.Buy(0.1, _Symbol, 0, 0, 0, "Buy Order");
        break;

      case '2':
        // Verkaufsauftrag mit Standardparametern
        trade.Sell(0.1, _Symbol, 0, 0, 0, "Sell Order");
        break;

      case '3':
        // Schließen aller Positionen
        CloseAllPositions();
        break;
    }
  }
}

//+------------------------------------------------------------------+
//| Funktion zum Schließen aller Positionen                          |
//+------------------------------------------------------------------+
void CloseAllPositions()
{
  for (int i = PositionsTotal() - 1; i >= 0; i--)
  {
    ulong ticket = PositionGetTicket(i);
    if (PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == magicNumber)
    {
      trade.PositionClose(ticket);
    }
  }
}
