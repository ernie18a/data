//+------------------------------------------------------------------+
//|                                                       Painel.mq5 |
//|                                  Copyright 2023, Robos Day Trade |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Robos Day Trade"
#property link      "https://www.instagram/robosdaytrade.com"
#property version   "1.00"


//+------------------------------------------------------------------+
//|                     ARMAZEN. TAMANHO DA TELA                     |
//+------------------------------------------------------------------+
long           Altura, Largura;                // Armazena o tamanho da tela da maquina
long           Altura1, Largura1;              // Armazena o tamanho da tela da maquina
long           Altura3, Largura3;              // Armazena o tamanho da tela da maquina
//+------------------------------------------------------------------+
//|              FIM    ARMAZEN. TAMANHO DA TELA                     |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                  EDITAVEIS VARIS                                 |
//+------------------------------------------------------------------+
string infos[8] = {"ATIVO EM OPERAÇÃO:", "PREÇO ATUAL DO ATIVO:", "POSIÇÃO DO ROBÔ:", "PREÇO MAXIMO DO ATIVO:", "PREÇO MINIMO DO ATIVO:","USUARIO:", "LUCRO:","SALDO:",};
string infos3[1] = {"R$"};
string infos1[1] = {"NOME DA SUA ESTRATEGIA"};
string infos4[1] = {"R$"};
string infos5[1] = {"TAKE PROFIT"};
//+------------------------------------------------------------------+
//|           FIM    EDITAVEIS VARIS                                 |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   //+------------------------------------------------------------------+
//|                  PAINEL DE INFOS                                 |
//+------------------------------------------------------------------+
   Altura = ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   Largura = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
//---

   int delta_x = 5;
   int delta_y = 5;
   int x_size = 300;
   int line_size = 15;
   int y_size = line_size*ArraySize(infos)+10;

//--- Criar o painel

// Background
   if(!ObjectCreate(0, "Background", OBJ_RECTANGLE_LABEL, 0, 0, 0))
      return(INIT_FAILED);

   ObjectSetInteger(0, "Background", OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, "Background", OBJPROP_XDISTANCE, delta_x);
   ObjectSetInteger(0, "Background", OBJPROP_YDISTANCE, y_size + delta_y);
   ObjectSetInteger(0, "Background", OBJPROP_XSIZE, x_size);
   ObjectSetInteger(0, "Background", OBJPROP_YSIZE, y_size);
   ObjectSetInteger(0, "Background", OBJPROP_BGCOLOR, clrWhite);
   ObjectSetInteger(0, "Background", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, "Background", OBJPROP_BORDER_COLOR, clrBlack);

// Criar campos
   for(int i=0; i<ArraySize(infos); i++)
     {
      if(!ObjectCreate(0, infos[i], OBJ_LABEL, 0, 0, 0))
         return(INIT_FAILED);
      ObjectSetInteger(0, infos[i], OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0, infos[i], OBJPROP_CORNER, CORNER_LEFT_LOWER);
      ObjectSetInteger(0, infos[i], OBJPROP_XDISTANCE, delta_x + 5);
      ObjectSetInteger(0, infos[i], OBJPROP_YDISTANCE, delta_y - 5 + y_size - i*line_size);
      ObjectSetInteger(0, infos[i], OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, infos[i], OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, infos[i], OBJPROP_TEXT, infos[i]);
     }

// Iniciar valores
   for(int i=0; i<ArraySize(infos); i++)
     {
      string name = infos[i] + "Valor";
      if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
         return(INIT_FAILED);

      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, delta_x + x_size - 5);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, delta_y - 5 + y_size - i*line_size);

      ObjectSetInteger(0, name, OBJPROP_COLOR, clrDarkRed);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, name, OBJPROP_TEXT, " ");
     }

//+------------------------------------------------------------------+
//|              PAINEL DE SEGUNDAS INFOS                            |
//+------------------------------------------------------------------+
   Altura1 = ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   Largura1 = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
//---

   int delta_x1 = 5;
   int delta_y1 = 135;
   int x_size1 = 300;
   int line_size1 = 15;
   int y_size1 = line_size1*ArraySize(infos1)+10;

//--- Criar o painel
// Background

   if(!ObjectCreate(0, "Background1", OBJ_RECTANGLE_LABEL, 0, 0, 0))
      return(INIT_FAILED);

   ObjectSetInteger(0, "Background1", OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, "Background1", OBJPROP_XDISTANCE, delta_x1);
   ObjectSetInteger(0, "Background1", OBJPROP_YDISTANCE, y_size1 + delta_y1);
   ObjectSetInteger(0, "Background1", OBJPROP_XSIZE, x_size1);
   ObjectSetInteger(0, "Background1", OBJPROP_YSIZE, y_size1);
   ObjectSetInteger(0, "Background1", OBJPROP_BGCOLOR, clrDarkViolet);
   ObjectSetInteger(0, "Background1", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, "Background1", OBJPROP_BORDER_COLOR, clrWhite);

// Criar campos
   for(int i=0; i<ArraySize(infos1); i++)
     {
      if(!ObjectCreate(0, infos1[i], OBJ_LABEL, 0, 0, 0))
         return(INIT_FAILED);
      ObjectSetInteger(0, infos1[i], OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0, infos1[i], OBJPROP_CORNER, CORNER_LEFT_LOWER);
      ObjectSetInteger(0, infos1[i], OBJPROP_XDISTANCE, delta_x1 + 45);
      ObjectSetInteger(0, infos1[i], OBJPROP_YDISTANCE, delta_y1 - 5 + y_size1 - i*line_size1);
      ObjectSetInteger(0, infos1[i], OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, infos1[i], OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, infos1[i], OBJPROP_TEXT, infos1[i]);
     }

// Iniciar valores
   for(int i=0; i<ArraySize(infos1); i++)
     {
      string name = infos1[i] + "Valor";
      if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
         return(INIT_FAILED);

      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, delta_x + x_size - 5);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, delta_y - 5 + y_size - i*line_size);

      ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, name, OBJPROP_TEXT, " ");
     }
//+------------------------------------------------------------------+
//|                    FIM PAINEL INFOS                              |
//+------------------------------------------------------------------+
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

//+------------------------------------------------------------------+
//|                        PEGA AS INFORMAÇOES DO ATIVO E DO GRAFICO |
//+------------------------------------------------------------------+

      string posicao = "ZERADO";
      if(PositionSelect(_Symbol))
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
            posicao = "COMPRADO";
         else
            posicao = "VENDIDO";
        }
      ObjectSetString(0, infos[0] + "Valor", OBJPROP_TEXT, _Symbol);
      ObjectSetString(0, infos[1] + "Valor", OBJPROP_TEXT, DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_LAST),0));
      ObjectSetString(0, infos[2] + "Valor", OBJPROP_TEXT, posicao);
      ObjectSetString(0, infos[3] + "Valor", OBJPROP_TEXT, DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_LASTHIGH),0));
      ObjectSetString(0, infos[4] + "Valor", OBJPROP_TEXT, DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_LASTLOW),0));
      ObjectSetString(0, infos[5] + "Valor", OBJPROP_TEXT, AccountInfoString(ACCOUNT_NAME));
      ObjectSetString(0, infos[6] + "Valor", OBJPROP_TEXT, DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT),2));
      ObjectSetString(0, infos[7] + "Valor", OBJPROP_TEXT, DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2));      
     
  }
//+------------------------------------------------------------------+
