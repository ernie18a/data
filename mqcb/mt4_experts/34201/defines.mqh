#include <Controls\Button.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\CheckBox.mqh>
#include <Controls\Label.mqh>
#include <Controls\RadioGroup.mqh>

enum ENUM_TIME_TYPE
{
   Local,
   Server
};

struct Settings
{
   ENUM_TIME_TYPE TimeType;
   bool ClosePos;
   bool TurnedOn;
   string Monday;
   string Tuesday;
   string Wednesday;
   string Thursday;
   string Friday;
   string Saturday;
   string Sunday;
} sets;