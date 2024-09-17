
#include "BluetoothSerial.h"

#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif

BluetoothSerial SerialBT;
int led[] = {18,19,22,23};
int button[] = {33,32,26,14};
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
  if (Serial.available()) {
    SerialBT.write(Serial.read());
  }
  if (SerialBT.available()) {
    Serial.write(SerialBT.read());
  }
  delay(20);
  for (int i=0;i<4;i++)
  { 
    if (digitalRead(button[i])==LOW && current != button[i] )
    {
      
      
        digitalWrite(led[i], HIGH);
      Serial.println(button[i]+60);
      SerialBT.write(button[i]+60);
      current = button[i];
      delay(50);
      
    
      
    }
    else if (digitalRead(button[i])==HIGH)
    {
      digitalWrite(led[i], LOW);
      

    }
  }
}