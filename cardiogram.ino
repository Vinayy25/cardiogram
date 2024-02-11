
#define WIFI_SSID "poseidon"
#define WIFI_PASSWORD "123456789"
#define DEVICE_ID 115

#include "MAX30100_PulseOximeter.h"
#include <Arduino.h>
#if defined(ESP32)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#elif __has_include(<WiFiNINA.h>)
#include <WiFiNINA.h>
#elif __has_include(<WiFi101.h>)
#include <WiFi101.h>
#elif __has_include(<WiFiS3.h>)
#include <WiFiS3.h>
#endif

#include <Firebase_ESP_Client.h>

// Provide the token generation process info.
#include <addons/TokenHelper.h>

// Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>
#include <OneWire.h>
#include <DallasTemperature.h>

#define ONE_WIRE_BUS 5

OneWire oneWire(ONE_WIRE_BUS);

DallasTemperature sensors(&oneWire);

float Celsius = 0;

/* 1. Define the WiFi credentials */

#define USER_EMAIL "test@gmail.com"
#define USER_PASSWORD "123456789"
// For the following credentials, see examples/Authentications/SignInAsUser/EmailPassword/EmailPassword.ino

/* 2. Define the API Key */
#define API_KEY "AIzaSyBXW4jD4Mg7BBoEmTdrgSmjwLIFPtuWohU"

/* 3. Define the RTDB URL */
#define DATABASE_URL "https://cardiogram-proj-default-rtdb.firebaseio.com/" //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app

/* 4. Define the user Email and password that alreadey registerd or added in your project */

unsigned long sendDataPrevMillis = 0;

// Define Firebase Data object
FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;
#define REPORTING_PERIOD_MS 1000

// PulseOximeter is the higher level interface to the sensor
// it offers:
//  * beat detection reporting
//  * heart rate calculation
//  * SpO2 (oxidation level) calculation
PulseOximeter pox;
#define ADC_VREF_mV 3300.0 // in millivolt
#define ADC_RESOLUTION 4096.0
#define PIN_LM35 33 // ESP32 pin GPIO36 (ADC0) connected to LM35
uint32_t tsLastReport = 0;

#if defined(ARDUINO_RASPBERRY_PI_PICO_W)
WiFiMulti multi;
#endif

float temp = 0;
float oxygen = 0;
float heartRate = 0;

TaskHandle_t GetReadings;
TaskHandle_t PostToFirebase;

// Callback (registered below) fired when a pulse is detected
void onBeatDetected()
{
  delay(1);
}

void setup()
{
  Serial.begin(115200);

  sensors.begin();

#if defined(ARDUINO_RASPBERRY_PI_PICO_W)
  multi.addAP(WIFI_SSID, WIFI_PASSWORD);
  multi.run();
#else
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
#endif

  Serial.print("Connecting to Wi-Fi");
  unsigned long ms = millis();
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
#if defined(ARDUINO_RASPBERRY_PI_PICO_W)
    if (millis() - ms > 10000)
      break;
#endif
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the user sign in credentials */
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h

  // Comment or pass false value when WiFi reconnection will control by your code or third party library e.g. WiFiManager
  Firebase.reconnectNetwork(true);

  fbdo.setBSSLBufferSize(4096 /* Rx buffer size in bytes from 512 - 16384 */, 1024 /* Tx buffer size in bytes from 512 - 16384 */);

  // Limit the size of response payload to be collected in FirebaseData
  fbdo.setResponseSize(2048);

  Firebase.begin(&config, &auth);

  // The WiFi credentials are required for Pico W
  // due to it does not have reconnect feature.
#if defined(ARDUINO_RASPBERRY_PI_PICO_W)
  config.wifi.clearAP();
  config.wifi.addAP(WIFI_SSID, WIFI_PASSWORD);
#endif

  Firebase.setDoubleDigits(5);

  config.timeout.serverResponse = 10 * 1000;
  Serial.print("Initializing pulse oximeter..");

  // Initialize the PulseOximeter instance
  // Failures are generally due to an improper I2C wiring, missing power supply
  // or wrong target chip
  if (!pox.begin())
  {
    Serial.println("FAILED");
    for (;;)
      ;
  }
  else
  {
    Serial.println("SUCCESS");
  }

  // The default current for the IR LED is 50mA and it could be changed
  //   by uncommenting the following line. Check MAX30100_Registers.h for all the
  //   available options.
  // pox.setIRLedCurrent(MAX30100_LED_CURR_7_6MA);

  // Register a callback for the beat detection
  pox.setOnBeatDetectedCallback(onBeatDetected);
  xTaskCreatePinnedToCore(SensorReadings, "GetReadings", 1724, NULL, 0, &GetReadings, 0);

  xTaskCreatePinnedToCore(SendReadingsToFirebase, "PostToFirebase", 6268, NULL, 0, &PostToFirebase, 1);
}

void SendReadingsToFirebase(void *parameter)
{

  while (true)
  {

    if (Firebase.ready() && (millis() - sendDataPrevMillis > 1000 || sendDataPrevMillis == 0))
    {
      // added here because of the incompatibility  between temp sensor and pulse oximeter sensor lib files
      //////////////////////////////////
      sendDataPrevMillis = millis();
      sensors.requestTemperatures();
      Celsius = sensors.getTempCByIndex(0);
      temp = Celsius;
      /////////////////////////////////////////////

      // firebase logic to upload code to realtime database
      bool flag1 = Firebase.RTDB.setInt(&fbdo, ("/" + String(DEVICE_ID) + "/heartrate").c_str(), int(heartRate));
      bool flag2 = Firebase.RTDB.setInt(&fbdo, ("/" + String(DEVICE_ID) + "/oxygen").c_str(), int(oxygen));
      bool flag3 = Firebase.RTDB.setInt(&fbdo, ("/" + String(DEVICE_ID) + "/temperature").c_str(), int(temp));
      if (flag1 && flag2 && flag3)
      {
        Serial.println("Done uploading");
      }
    }
  }
}

void SensorReadings(void *parameter)
{

  while (true)
  {
    pox.update();

    // Asynchronously dump heart rate and oxidation levels to the serial
    // For both, a value of 0 means "invalid"
    if (millis() - tsLastReport > REPORTING_PERIOD_MS)
    {

      Serial.print("Heart rate:");
      Serial.print(pox.getHeartRate());
      Serial.print(" bpm; SpO2:");
      Serial.print(pox.getSpO2());
      Serial.print(" bpm; Temp:");
      Serial.print(Celsius); // print the temperature in °C
      Serial.println("°C");
      heartRate = pox.getHeartRate();
      oxygen = pox.getSpO2();

      tsLastReport = millis();
    }
  }
}

void loop()
{

  delay(1);
}
