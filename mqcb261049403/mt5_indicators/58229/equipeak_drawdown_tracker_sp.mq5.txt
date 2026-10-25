//+------------------------------------------------------------------+ 
//|                              Copyright 2025, Enrique Enguix      |
//|                              https://www.mql5.com/es/users/envex |
//+------------------------------------------------------------------+
#property copyright   "(c) 2025 Enrique Enguix"
#property link        "https://www.mql5.com/es/users/envex"
#property version     "1.02"
#property description "Rastrea el drawdown actual/histórico, con registro y notificaciones push."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#property strict

#include <Trade\PositionInfo.mqh>

//+------------------------------------------------------------------+
//| Objeto de información de posición                                |
//+------------------------------------------------------------------
CPositionInfo g_position;

//+------------------------------------------------------------------+
//| Enumeraciones                                                    |
//+------------------------------------------------------------------
enum EBalanceMode
  {
   REF_FIXED_BALANCE = 0, // Usar un balance fijo como referencia
   REF_PEAK_BALANCE  = 1  // Usar el balance pico como referencia (variable global)
  };

enum EMaxDDUpdateMode
  {
   NO_UPDATE_MAX_DD        = 0, // No actualizar el DD histórico máximo
   UPDATE_MAX_DD_IF_BIGGER = 1  // Actualizar si el DD actual excede el histórico
  };

//+------------------------------------------------------------------+
//| Enumeración para la selección de extensión de archivo            |
//+------------------------------------------------------------------
enum SFileExtension
  {
   UseCSV = 0, // Usar formato CSV (compatible con Excel)
   UseTXT = 1  // Usar formato TXT (texto plano)
  };

//+------------------------------------------------------------------+
//| Parámetros de entrada                                            |
//+------------------------------------------------------------------
input string  MagicNumbers               = "-1"; // Magics a monitorear (-1 rastrea todos)
input double  InitialMaxDrawdown         = 0.0;  // DD Máximo Inicial (%)
input uint    RefreshInterval            = 60;   // Frecuencia de actualización (segundos)
input EMaxDDUpdateMode UpdateMaxDrawdown = UPDATE_MAX_DD_IF_BIGGER; // Modo de actualización de MaxDD
input bool    SendPushNotifications      = true; // ¿Enviar notificaciones push?

//--- Modo de balance de referencia
input EBalanceMode ReferenceBalanceMode   = REF_FIXED_BALANCE; // ¿Balance fijo o pico?
input double       InpFixedBalance        = 0.0;  // Balance fijo (0 => balance actual)

//--- Estilo visual
input color CurrentDrawdownTextColor      = clrGray; // Color para el texto del DD actual
input color MaxDrawdownTextColor          = clrGray; // Color para el texto del DD máximo
input uint  CurrentDrawdownFontSize       = 25;      // Tamaño de fuente (DD actual)
input uint  MaxDrawdownFontSize           = 25;      // Tamaño de fuente (DD máximo)
input bool  DisplayLabelsInBackground     = true;    // ¿Mostrar etiquetas detrás del gráfico?

//--- Posición y espacio para las etiquetas
input int   LabelPosX                     = 200; // Posición X (pixeles)
input int   LabelPosY                     = 20;  // Posición Y (pixeles)
input uint  LabelSpacing                  = 10;  // Espaciado vertical

//--- Nivel de detalle del log
input bool  PrintDetailedLogs             = true; // ¿Imprimir detalles en el Journal?

//--- Nuevos inputs para registro en archivo
input bool           EnableFileLog        = true;   // Crear un archivo independiente para registrar valores de DD actual
input SFileExtension InpFileExtension     = UseTXT; // Extensión de archivo: CSV o TXT

//+------------------------------------------------------------------+
//| Variables globales (no son inputs del usuario)                   |
//+------------------------------------------------------------------
double g_ReferenceBalance      = 0.0;  // Balance de referencia usado en cálculos de DD
double g_MaxDrawdown           = 0.0;  // DD máximo histórico (%), se almacena globalmente
double g_PeakBalance           = 0.0;  // Balance pico (si se usa REF_PEAK_BALANCE)

// Nombres de las variables globales con sufijo único (evita conflictos entre instancias)
string g_PeakBalanceGVName;
string g_MaxDrawdownGVName;

// Guardaremos extensiones y otros parámetros de forma interna
uint   g_RefreshIntervalVar      = 60;
uint   g_CurrentDrawdownFontSize = 35;
uint   g_MaxDrawdownFontSize     = 35;
string g_FileExtension           = ".csv"; // Valor por defecto

// Nombres de objetos de texto con sufijo único (ChartID)
string g_currentDrawdownObjName;
string g_maxDrawdownObjName;

// Control de spam en modo NO_UPDATE_MAX_DD (1 notificación cada 60 min)
datetime g_LastPushTimeNOUPDATE = 0;

//+------------------------------------------------------------------+
//| OnInit: Inicialización                                           |
//+------------------------------------------------------------------
int OnInit()
  {
   // Construir sufijos únicos para variables globales (usamos ChartID para distinguir instancias)
   g_PeakBalanceGVName    = "EquiPeakDT_PeakBalance_" + (string)ChartID();
   g_MaxDrawdownGVName    = "EquiPeakDT_MaxDD_"       + (string)ChartID();

   // Nombres de objetos de texto también únicos
   g_currentDrawdownObjName = "current_drawdown_" + (string)ChartID();
   g_maxDrawdownObjName     = "max_drawdown_"     + (string)ChartID();

   //--- Validar RefreshInterval
   if(RefreshInterval < 1)
     {
      g_RefreshIntervalVar = 10;
      if(PrintDetailedLogs)
         Print("[ADVERTENCIA] RefreshInterval < 1. Se usará 10 segundos como valor mínimo.");
     }
   else
      if(RefreshInterval > 3600)
        {
         g_RefreshIntervalVar = 3600;
         if(PrintDetailedLogs)
            Print("[ADVERTENCIA] RefreshInterval > 3600. Se usará 3600 segundos (1 hora) como máximo.");
        }
      else
        {
         g_RefreshIntervalVar = RefreshInterval;
        }

   //--- Validar CurrentDrawdownFontSize
   if(CurrentDrawdownFontSize < 1)
     {
      g_CurrentDrawdownFontSize = 12;
      if(PrintDetailedLogs)
         Print("[ADVERTENCIA] CurrentDrawdownFontSize <1. Se usará 12 como valor de respaldo.");
     }
   else
     {
      g_CurrentDrawdownFontSize = CurrentDrawdownFontSize;
     }

   //--- Validar MaxDrawdownFontSize
   if(MaxDrawdownFontSize < 1)
     {
      g_MaxDrawdownFontSize = 12;
      if(PrintDetailedLogs)
         Print("[ADVERTENCIA] MaxDrawdownFontSize <1. Se usará 12 como valor de respaldo.");
     }
   else
     {
      g_MaxDrawdownFontSize = MaxDrawdownFontSize;
     }

   //--- Determinar extensión de archivo según enum
   if(InpFileExtension == UseCSV)
      g_FileExtension = ".csv";
   else
      g_FileExtension = ".txt";

   //--- Establecer el temporizador con el intervalo validado
   EventSetTimer(g_RefreshIntervalVar);

   //--- Llamar OnTimer una vez para dibujar/logs inmediatamente
   OnTimer();

   //--- Configurar / leer el balance pico si se usa REF_PEAK_BALANCE
   if(ReferenceBalanceMode == REF_PEAK_BALANCE)
     {
      if(GlobalVariableCheck(g_PeakBalanceGVName))
        {
         g_PeakBalance = GlobalVariableGet(g_PeakBalanceGVName);
         if(PrintDetailedLogs)
            PrintFormat("[INFO] Cargado balance pico desde variable global: %.2f", g_PeakBalance);
        }
      else
        {
         g_PeakBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         GlobalVariableSet(g_PeakBalanceGVName, g_PeakBalance);
         if(PrintDetailedLogs)
            PrintFormat("[INFO] No se encontró variable global. Creado balance pico inicial: %.2f", g_PeakBalance);
        }
     }

   //--- Cargar o crear la variable global para el DD Máximo
   if(GlobalVariableCheck(g_MaxDrawdownGVName))
     {
      g_MaxDrawdown = GlobalVariableGet(g_MaxDrawdownGVName);
      if(PrintDetailedLogs)
         PrintFormat("[INFO] Cargado DD máximo histórico desde variable global: %.2f%%", g_MaxDrawdown);
     }
   else
     {
      g_MaxDrawdown = InitialMaxDrawdown;
      GlobalVariableSet(g_MaxDrawdownGVName, g_MaxDrawdown);
      if(PrintDetailedLogs)
         PrintFormat("[INFO] No se encontró variable global para DD máximo. Creado inicial con: %.2f%%", g_MaxDrawdown);
     }

   //--- Determinar balance de referencia
   if(ReferenceBalanceMode == REF_FIXED_BALANCE)
     {
      if(InpFixedBalance <= 0.0)
        {
         double fallback = AccountInfoDouble(ACCOUNT_BALANCE);
         g_ReferenceBalance = fallback;
         if(PrintDetailedLogs)
            PrintFormat("[ADVERTENCIA] InpFixedBalance <= 0. Se usará balance actual de la cuenta (%.2f).",
                        fallback);
        }
      else
        {
         g_ReferenceBalance = InpFixedBalance;
         if(PrintDetailedLogs)
            PrintFormat("[INFO] Usando Modo Balance Fijo. Referencia = %.2f", g_ReferenceBalance);
        }
     }
   else // REF_PEAK_BALANCE
     {
      g_ReferenceBalance = g_PeakBalance;
      if(PrintDetailedLogs)
         PrintFormat("[INFO] Usando Modo Balance Pico. Referencia = %.2f", g_ReferenceBalance);
     }

   //--- Evitar división por cero
   if(g_ReferenceBalance < 1e-8)
     {
      g_ReferenceBalance = 1e-8; // Valor mínimo
      if(PrintDetailedLogs)
         Print("[ERROR] El balance de referencia era 0 o inválido. Se fija en 1e-8 para evitar división por cero.");
     }

   //--- Mensaje final de inicialización
   if(PrintDetailedLogs)
     {
      Print("[INFO] EquiPeakDrawdownTracker inicializado correctamente.");
      PrintConfigurationSummary();
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| OnTimer: Se llama cada RefreshInterval segundos                  |
//+------------------------------------------------------------------
void OnTimer()
  {
   double realBalance    = AccountInfoDouble(ACCOUNT_BALANCE);
   double floatingProfit = GetFloatingProfit();
   double accountEquity  = realBalance + floatingProfit;

   //--- Si se usa PeakBalance, comprobar si aparece un nuevo pico (balance cerrado)
   if(ReferenceBalanceMode == REF_PEAK_BALANCE)
     {
      if(realBalance > g_PeakBalance)
        {
         double oldPeak     = g_PeakBalance;
         g_PeakBalance      = realBalance;
         GlobalVariableSet(g_PeakBalanceGVName, g_PeakBalance);
         g_ReferenceBalance = g_PeakBalance; // actualizar referencia

         if(PrintDetailedLogs)
            PrintFormat("[INFO] Detectado nuevo balance pico: %.2f (anterior pico era %.2f)",
                        g_PeakBalance, oldPeak);
        }
     }

   //--- Calcular drawdown actual
   double currentDrawdownPct = CalculateCurrentDrawdownPct(accountEquity, g_ReferenceBalance);

   //--- Lógica para actualizar el DD máximo
   if(UpdateMaxDrawdown == UPDATE_MAX_DD_IF_BIGGER)
     {
      // Si el DD actual es mayor que el DD histórico
      if(currentDrawdownPct > g_MaxDrawdown)
        {
         double oldMax = g_MaxDrawdown;
         g_MaxDrawdown = currentDrawdownPct;
         GlobalVariableSet(g_MaxDrawdownGVName, g_MaxDrawdown);

         if(PrintDetailedLogs)
            PrintFormat("[INFO] Se ha alcanzado un nuevo DD máximo: %.2f%% (el anterior era %.2f%%)",
                        g_MaxDrawdown, oldMax);

         // Enviar notificación push (solo si está configurado)
         if(SendPushNotifications)
            SendDetailedNotification(currentDrawdownPct, oldMax, true);
        }
     }
   else // NO_UPDATE_MAX_DD
     {
      // Solo enviar notificación cada 60 minutos (3600 seg)
      if(SendPushNotifications)
        {
         if((TimeCurrent() - g_LastPushTimeNOUPDATE) >= 3600)
           {
            SendDetailedNotification(currentDrawdownPct, g_MaxDrawdown, false);
            g_LastPushTimeNOUPDATE = TimeCurrent();
           }
        }
     }

   //--- (1) Actualizar etiquetas en el gráfico
   string currentDDText = StringFormat("Drawdown Actual: %.2f%%", currentDrawdownPct);
   string maxDDText     = StringFormat("Drawdown Histórico Máx: %.2f%%", g_MaxDrawdown);

   // Etiqueta 1: drawdown actual
   DrawLabel(g_currentDrawdownObjName,
             currentDDText,
             LabelPosX,
             LabelPosY,
             CurrentDrawdownTextColor,
             g_CurrentDrawdownFontSize);

   // Etiqueta 2: drawdown máximo
   int secondLabelY = LabelPosY + (int)g_CurrentDrawdownFontSize + (int)LabelSpacing;
   DrawLabel(g_maxDrawdownObjName,
             maxDDText,
             LabelPosX,
             secondLabelY,
             MaxDrawdownTextColor,
             g_MaxDrawdownFontSize);

   //--- (2) Registrar en archivo si está habilitado
   if(EnableFileLog)
      LogDrawdown(currentDrawdownPct);
  }

//+------------------------------------------------------------------+
//| OnDeinit: Limpieza final                                         |
//+------------------------------------------------------------------
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectDelete(0, g_currentDrawdownObjName);
   ObjectDelete(0, g_maxDrawdownObjName);

   if(PrintDetailedLogs)
      Print("[INFO] EquiPeakDrawdownTracker desinicializado.");
  }

//+------------------------------------------------------------------+
//| OnCalculate: Función de indicador (no se usa para gráficos)      |
//+------------------------------------------------------------------
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   // Este indicador no dibuja ningún buffer.
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| CalculateCurrentDrawdownPct: Retorna el DD flotante en %         |
//+------------------------------------------------------------------
double CalculateCurrentDrawdownPct(const double equity, const double referenceBalance)
  {
   double eps  = 1e-10;
   double diff = referenceBalance - equity;

   if(diff <= eps)
      return 0.0; // no hay drawdown si la equity >= referenceBalance (o casi)

   return (diff / referenceBalance) * 100.0;
  }

//+------------------------------------------------------------------+
//| GetFloatingProfit: Retorna la ganancia/pérdida flotante total    |
//| de los magics monitoreados                                       |
//+------------------------------------------------------------------
double GetFloatingProfit()
  {
   double totalProfit = 0.0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!g_position.SelectByIndex(i))
        {
         if(PrintDetailedLogs)
            PrintFormat("[ADVERTENCIA] No se pudo seleccionar posición en índice %d", i);
         continue;
        }

      long mNumber = g_position.Magic();
      if(IsTrackedMagicNumber(mNumber))
        {
         // Profit() ya incluye swap y comisiones
         totalProfit += g_position.Profit();
        }
     }
   return totalProfit;
  }

//+------------------------------------------------------------------+
//| IsTrackedMagicNumber: Compara el magic number con la lista       |
//| (o -1)                                                           |
//+------------------------------------------------------------------
bool IsTrackedMagicNumber(long magicNumber)
  {
   string magicList[];
   int count = StringSplit(MagicNumbers, ',', magicList);
   bool trackAll = false;

   //--- Primero comprobar si "-1" está en la lista
   for(int i = 0; i < count; i++)
     {
      string magicStr = magicList[i];
      StringReplace(magicStr, " ", ""); // quitar espacios
      if(magicStr == "-1")
        {
         trackAll = true;
         break;
        }
     }

   if(trackAll)
      return true;

   //--- De lo contrario, comparar con cada valor
   for(int i = 0; i < count; i++)
     {
      string magicStr = magicList[i];
      StringReplace(magicStr, " ", "");

      double parsed = StringToDouble(magicStr);
      if(parsed == (double)magicNumber)
         return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//| SendDetailedNotification: Envía mensaje push con más detalles    |
//+------------------------------------------------------------------
void SendDetailedNotification(double currentDD, double oldMaxDD, bool isNewRecord)
  {
   string server  = AccountInfoString(ACCOUNT_SERVER);
   long   login   = AccountInfoInteger(ACCOUNT_LOGIN);
   string timeStr = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);

   // Mensaje más completo
   string msg = StringFormat(
                   "EquiPeak Drawdown Tracker v1.00\nBroker/Servidor: %s\nCuenta: %lld\nHora: %s\n"
                   "DD Actual: %.2f%%\nDD Histórico Máx: %.2f%%",
                   server,
                   login,
                   timeStr,
                   currentDD,
                   g_MaxDrawdown
                );

   if(isNewRecord)
      msg += StringFormat("\n[RECORD] ¡Nuevo DD Máx alcanzado! (el anterior era %.2f%%)", oldMaxDD);

   bool sent = SendNotification(msg);
   if(!sent && PrintDetailedLogs)
     {
      PrintFormat("[ADVERTENCIA] No se pudo enviar notificación push: %s", msg);
     }
  }

//+------------------------------------------------------------------+
//| PrintConfigurationSummary: Muestra la configuración elegida      |
//+------------------------------------------------------------------
void PrintConfigurationSummary()
  {
   if(!PrintDetailedLogs)
      return;

   Print("===== Resumen de Configuración EquiPeak Drawdown Tracker =====");

   // Magic numbers
   PrintFormat(" > MagicNumbers a rastrear: %s", MagicNumbers);

   // Modo de Balance
   if(ReferenceBalanceMode == REF_FIXED_BALANCE)
      PrintFormat(" > Modo de Balance: FIJO, balance de referencia = %.2f", g_ReferenceBalance);
   else
      PrintFormat(" > Modo de Balance: PICO (pico cargado = %.2f)", g_PeakBalance);

   // Modo de actualización del DD
   if(UpdateMaxDrawdown == UPDATE_MAX_DD_IF_BIGGER)
      Print(" > Modo de Actualización del DD Máx: ACTUALIZAR SI ES MAYOR");
   else
      Print(" > Modo de Actualización del DD Máx: NO ACTUALIZAR (con notificaciones limitadas)");

   // DD máximo actual
   PrintFormat(" > DD Máx almacenado actualmente = %.2f%%", g_MaxDrawdown);

   // Intervalo de refresco
   PrintFormat(" > Intervalo de refresco (segundos): %u", g_RefreshIntervalVar);

   // Notificaciones push
   PrintFormat(" > Notificaciones Push: %s", SendPushNotifications ? "HABILITADAS" : "DESHABILITADAS");

   // Etiquetas
   PrintFormat(" > Tamaños de fuente (DD/MaxDD): %u / %u", g_CurrentDrawdownFontSize, g_MaxDrawdownFontSize);
   PrintFormat(" > Posiciones de etiqueta: X=%d, Y=%d, Espaciado=%u", LabelPosX, LabelPosY, LabelSpacing);

   // Registro en archivo
   PrintFormat(" > Registro en Archivo: %s", EnableFileLog ? "HABILITADO" : "DESHABILITADO");
   if(EnableFileLog)
     {
      string tf = PeriodToStringLowerCase(_Period);
      string fileName = "DD_" + _Symbol + "_" + tf + "_Magic_" + MagicNumbers + g_FileExtension;
      PrintFormat(" > Extensión de archivo: %s", g_FileExtension);
      PrintFormat(" > Ruta de archivo (aprox.): Common/Files/%s", fileName);
     }

   Print("==============================================================");
  }

//+------------------------------------------------------------------+
//| LogDrawdown: Añade info de DD en un archivo (CSV o TXT)          |
//+------------------------------------------------------------------
void LogDrawdown(double currentDrawdown)
  {
   string symbol    = _Symbol;
   string tfString  = PeriodToStringLowerCase(_Period);
   string fileName  = "DD_" + symbol + "_" + tfString + "_Magic_" + MagicNumbers + g_FileExtension;

   int flags = FILE_READ | FILE_WRITE | FILE_COMMON;
   if(g_FileExtension == ".csv")
      flags |= FILE_CSV;

   int handle = FileOpen(fileName, flags);
   if(handle == INVALID_HANDLE)
     {
      Print("[ERROR] No se pudo abrir/crear el archivo de log: ", fileName);
      return;
     }

   FileSeek(handle, 0, SEEK_END);
   string timeStr = TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);

   // Obtener valores de Balance y Equity
   double realBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = realBalance + GetFloatingProfit();

   // Escribir en el archivo: se agregarán Balance y Equity a la línea de log
   FileWrite(handle, timeStr, MagicNumbers, DoubleToString(currentDrawdown, 2),
             DoubleToString(realBalance, 2), DoubleToString(equity, 2));
   FileClose(handle);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------
string PeriodToStringLowerCase(ENUM_TIMEFRAMES period)
  {
   switch(period)
     {
      case PERIOD_M1:
         return "m1";
      case PERIOD_M2:
         return "m2";
      case PERIOD_M3:
         return "m3";
      case PERIOD_M4:
         return "m4";
      case PERIOD_M5:
         return "m5";
      case PERIOD_M6:
         return "m6";
      case PERIOD_M10:
         return "m10";
      case PERIOD_M12:
         return "m12";
      case PERIOD_M15:
         return "m15";
      case PERIOD_M20:
         return "m20";
      case PERIOD_M30:
         return "m30";
      case PERIOD_H1:
         return "h1";
      case PERIOD_H2:
         return "h2";
      case PERIOD_H3:
         return "h3";
      case PERIOD_H4:
         return "h4";
      case PERIOD_H6:
         return "h6";
      case PERIOD_H8:
         return "h8";
      case PERIOD_H12:
         return "h12";
      case PERIOD_D1:
         return "d1";
      case PERIOD_W1:
         return "w1";
      case PERIOD_MN1:
         return "mn1";
      default:
         return "unknown";
     }
  }

//+------------------------------------------------------------------+
//| DrawLabel: Crea/actualiza una etiqueta en el gráfico             |
//+------------------------------------------------------------------
void DrawLabel(string name,
               string text,
               int x,
               int y,
               color clr,
               uint fontSize)
  {
   if(ObjectFind(0, name) == -1)
     {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_BACK, DisplayLabelsInBackground);
     }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }
//+------------------------------------------------------------------+
