
#include "BluetoothSerial.h"

#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif

BluetoothSerial SerialBT;
int led[] = {18,19,22,2};
int button[] = {14,33,26,23};
int current = 0;
void setup()
{
  for (int i=0;i<4;i++)
  {
    pinMode(led[i], OUTPUT);
    pinMode(button[i], INPUT_PULLUP);
    
  }
  Serial.begin(115200);
  SerialBT.begin("ESP32test"); //Bluetooth device name
  Serial.println("The device started, now you can pair it with bluetooth!");
  
}

void loop()
{
  for (int i=0;i<4;i++)
  { 
    if (digitalRead(button[i])==LOW && current != button[i] )
    {
      
      
        digitalWrite(led[i], HIGH);
      switch (i) {
        case 0: 
        Serial.println("This is first command");
        SerialBT.println("J");
        break;
        case 1: Serial.println("This is second command");
        SerialBT.println("second");
        break;
        case 2: Serial.println("This is third command");
        SerialBT.println("third");
        break;
        case 3: Serial.println("This is fourth command");
        SerialBT.println("fourth");
        break;

      }
      Serial.println(button[i]);
      current = button[i];

    
      
    }
    else if (digitalRead(button[i])==HIGH)
    {
      digitalWrite(led[i], LOW);
      

    }
  }
}