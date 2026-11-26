//+------------------------------------------------------------------+
//|                                              TendenciaDiaria.mq5 |
//|                                                Emanuel Kowalczuk |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright   "Emanuel Kowalczuk"
#property link        "e.kwk@hotmail.com"
#property description "Este indicador exibe a tendência do dia em qualquer tempo gráfico"
#property indicator_chart_window // Exibe o indicador na janela do gráfico
#property indicator_buffers 0    // Não usa buffers de indicador
#property indicator_plots 0      // Não desenha gráficos

//+------------------------------------------------------------------+
//| Enum para as opções de posição do texto                          |
//+------------------------------------------------------------------+
enum ENUM_POSICAO_TEXTO
  {
   SUPERIOR_ESQUERDO = 1,  // Canto Superior Esquerdo
   SUPERIOR_DIREITO  = 2,  // Canto Superior Direito
   INFERIOR_ESQUERDO = 3,  // Canto Inferior Esquerdo
   INFERIOR_DIREITO  = 4   // Canto Inferior Direito
  };

//+------------------------------------------------------------------+
//| Input parameters (customizáveis pelo usuário)                    |
//+------------------------------------------------------------------+
input int TamanhoFonte = 12; // Tamanho da fonte do texto
input ENUM_POSICAO_TEXTO PosicaoTexto = SUPERIOR_DIREITO; // Posição do texto
input int MargemHorizontal = 100; // Margem horizontal (espaçamento da borda)
input int MargemVertical = 20;   // Margem vertical (espaçamento da borda)
input color CorAlta = clrGreen;  // Cor tendência de alta
input color CorBaixa = clrRed;   // Cor tendência de baixa
input color CorNeutra = clrGray; // Cor tendência neutra

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Inicialização bem-sucedida
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Deleta o rótulo quando o indicador é removido do gráfico
   ObjectDelete(0, "TendenciaLabel");
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
   // Obtém o preço de abertura e o preço atual do dia (timeframe D1)
   double precoAbertura = iOpen(NULL, PERIOD_D1, 0);
   double precoAtual = iClose(NULL, PERIOD_D1, 0);

   // Calcula a variação percentual
   double variacaoPercentual = (precoAtual - precoAbertura) / precoAbertura * 100;

   // Formata a variação percentual com duas casas decimais
   string textoVariacao = DoubleToString(variacaoPercentual, 2) + "%";

   // Limpa o rótulo anterior antes de desenhar o novo
   ObjectDelete(0, "TendenciaLabel");

   // Define a posição do texto com base na escolha do usuário
   int xDistance = MargemHorizontal; // Distância horizontal (margem)
   int yDistance = MargemVertical;   // Distância vertical (margem)

   switch(PosicaoTexto)
     {
      case SUPERIOR_ESQUERDO: // Canto Superior Esquerdo
         xDistance = MargemHorizontal;
         yDistance = MargemVertical;
         break;
      case SUPERIOR_DIREITO: // Canto Superior Direito
         xDistance = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) - MargemHorizontal - 150; // Ajuste conforme o tamanho do texto
         yDistance = MargemVertical;
         break;
      case INFERIOR_ESQUERDO: // Canto Inferior Esquerdo
         xDistance = MargemHorizontal;
         yDistance = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS) - MargemVertical - 40; // Ajuste conforme o tamanho do texto
         break;
      case INFERIOR_DIREITO: // Canto Inferior Direito
         xDistance = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) - MargemHorizontal - 150; // Ajuste conforme o tamanho do texto
         yDistance = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS) - MargemVertical - 40; // Ajuste conforme o tamanho do texto
         break;
      default:
         break;
     }

   // Verifica a tendência e desenha o texto na tela
   if(variacaoPercentual >= 0.10)
     {
      ObjectCreate(0, "TendenciaLabel", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "TendenciaLabel", OBJPROP_TEXT, "Tendência Diária: Alta (" + textoVariacao + ")");
      ObjectSetInteger(0, "TendenciaLabel", OBJPROP_COLOR, CorAlta); // Usa a cor definida pelo usuário
      ObjectSetInteger(0, "TendenciaLabel", OBJPROP_XDISTANCE, xDistance);
      ObjectSetInteger(0, "TendenciaLabel", OBJPROP_YDISTANCE, yDistance);
      ObjectSetInteger(0, "TendenciaLabel", OBJPROP_FONTSIZE, TamanhoFonte); // Usa o tamanho da fonte definido pelo usuário
     }
   else if(variacaoPercentual <= -0.10)
     {
      ObjectCreate(0, "TendenciaLabel", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "TendenciaLabel", OBJPROP_TEXT, "Tendência Diária: Baixa (" + textoVariacao + ")");
      ObjectSetInteger(0, "TendenciaLabel", OBJPROP_COLOR, CorBaixa); // Usa a cor definida pelo usuário
      ObjectSetInteger(0, "TendenciaLabel", OBJPROP_XDISTANCE, xDistance);
      ObjectSetInteger(0, "TendenciaLabel", OBJPROP_YDISTANCE, yDistance);
      ObjectSetInteger(0, "TendenciaLabel", OBJPROP_FONTSIZE, TamanhoFonte); // Usa o tamanho da fonte definido pelo usuário
     }
   else
     {
      ObjectCreate(0, "TendenciaLabel", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "TendenciaLabel", OBJPROP_TEXT, "Tendência Diária: Neutra (" + textoVariacao + ")");
      ObjectSetInteger(0, "TendenciaLabel", OBJPROP_COLOR, CorNeutra); // Usa a cor definida pelo usuário
      ObjectSetInteger(0, "TendenciaLabel", OBJPROP_XDISTANCE, xDistance);
      ObjectSetInteger(0, "TendenciaLabel", OBJPROP_YDISTANCE, yDistance);
      ObjectSetInteger(0, "TendenciaLabel", OBJPROP_FONTSIZE, TamanhoFonte); // Usa o tamanho da fonte definido pelo usuário
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+