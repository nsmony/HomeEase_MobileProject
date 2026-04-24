#include <WiFi.h>
#include <WiFiManager.h>
#include <Firebase_ESP_Client.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>
#include <DHT.h>

// ── Firebase ──────────────────────────────────────
#define API_KEY      "AIzaSyBGyxooz2ddHBb2Znt-3aI8VTKn1-Vt920"
#define DATABASE_URL "https://homeease-16dfd-default-rtdb.asia-southeast1.firebasedatabase.app"
#define DEVICE_ID    "HSE-00001"

// ── Pins ──────────────────────────────────────────
#define DHTPIN       4
#define DHTTYPE      DHT11
#define GAS_PIN      34
#define RELAY_PIN    19
#define IR_PIN       27
#define TRIG_PIN     5
#define ECHO_PIN     18

// ── Thresholds ────────────────────────────────────
#define GAS_THRESHOLD      2000
#define PRESENCE_DISTANCE  100

// ── Auto light settings ───────────────────────────
#define AUTO_LIGHT_TIMEOUT 30000

DHT dht(DHTPIN, DHTTYPE);
FirebaseData fbdo;
FirebaseData fbdoRelay;
FirebaseAuth auth;
FirebaseConfig config;

// ── State tracking ────────────────────────────────
bool lastRelayState   = false;
bool autoLightEnabled = true;
bool personPresent    = false;
unsigned long lastPresenceTime  = 0;
unsigned long lastSensorUpdate  = 0;
const long SENSOR_INTERVAL      = 3000;

// ── Ultrasonic distance read ──────────────────────
float readDistance() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  long duration = pulseIn(ECHO_PIN, HIGH, 30000);
  if (duration == 0) return -1;
  return duration * 0.034 / 2;
}

void setup() {
  Serial.begin(115200);

  pinMode(RELAY_PIN, OUTPUT);
  pinMode(IR_PIN,    INPUT);
  pinMode(TRIG_PIN,  OUTPUT);
  pinMode(ECHO_PIN,  INPUT);
  digitalWrite(RELAY_PIN, LOW);

  dht.begin();

  // ── WiFi via WiFiManager ──────────────────────
  WiFiManager wm;
  wm.setConfigPortalTimeout(180);
  if (!wm.autoConnect("HomeEase-Setup", "homeease123")) {
    Serial.println("WiFi failed, restarting...");
    ESP.restart();
  }
  Serial.println("WiFi connected: " + WiFi.localIP().toString());

  // ── Firebase anonymous auth ───────────────────
  config.api_key      = API_KEY;
  config.database_url = DATABASE_URL;
  config.token_status_callback = tokenStatusCallback; // from TokenHelper.h

  Firebase.signUp(&config, &auth, "", "");
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  Serial.print("Connecting to Firebase");
  int retries = 0;
  while (!Firebase.ready() && retries < 20) {
    Serial.print(".");
    delay(500);
    retries++;
  }

  if (Firebase.ready()) {
    Serial.println("\nFirebase connected!");
    Firebase.RTDB.setBool(&fbdo,
      "/devices/" + String(DEVICE_ID) + "/online", true);
  } else {
    Serial.println("\nFirebase timeout — continuing anyway");
  }
}

void loop() {
  if (!Firebase.ready()) {
    delay(1000);
    return;
  }

  unsigned long now = millis();
  String base       = "/devices/" + String(DEVICE_ID);

  // ── 1. Read auto light mode ───────────────────
  if (Firebase.RTDB.getBool(&fbdo, base + "/automation/presenceEnabled")) {
    autoLightEnabled = fbdo.boolData();
  }

  // ── 2. IR sensor ──────────────────────────────
  bool irDetected = digitalRead(IR_PIN) == LOW;

  // ── 3. Ultrasonic ─────────────────────────────
  float distance     = readDistance();
  bool ultraDetected = (distance > 0 && distance < PRESENCE_DISTANCE);

  bool currentPresence = irDetected || ultraDetected;

  if (currentPresence) {
    lastPresenceTime = now;
    if (!personPresent) {
      personPresent = true;
      Firebase.RTDB.setBool(&fbdo, base + "/presence", true);
      Serial.println("Person detected!");

      if (autoLightEnabled) {
        digitalWrite(RELAY_PIN, HIGH);
        Firebase.RTDB.setBool(&fbdo, base + "/relay", true);
        Serial.println("Auto light ON");
      }
    }
  } else {
    if (personPresent &&
        (now - lastPresenceTime > AUTO_LIGHT_TIMEOUT)) {
      personPresent = false;
      Firebase.RTDB.setBool(&fbdo, base + "/presence", false);
      Serial.println("No person — presence cleared");

      if (autoLightEnabled) {
        digitalWrite(RELAY_PIN, LOW);
        Firebase.RTDB.setBool(&fbdo, base + "/relay", false);
        Serial.println("Auto light OFF");
      }
    }
  }

  // ── 4. Manual relay override ──────────────────
  if (!autoLightEnabled) {
    if (Firebase.RTDB.getBool(&fbdoRelay, base + "/relay")) {
      bool relayState = fbdoRelay.boolData();
      if (relayState != lastRelayState) {
        digitalWrite(RELAY_PIN, relayState ? HIGH : LOW);
        lastRelayState = relayState;
        Serial.println(relayState ? "Manual relay ON" : "Manual relay OFF");
      }
    }
  }

  // ── 5. Sensor upload every 3 seconds ─────────
  if (now - lastSensorUpdate >= SENSOR_INTERVAL) {
    lastSensorUpdate = now;

    float temp     = dht.readTemperature();
    float humidity = dht.readHumidity();
    if (!isnan(temp) && !isnan(humidity)) {
      Firebase.RTDB.setFloat(&fbdo, base + "/temperature", temp);
      Firebase.RTDB.setFloat(&fbdo, base + "/humidity",    humidity);
      Serial.printf("Temp: %.1f°C  Hum: %.1f%%\n", temp, humidity);
    } else {
      Serial.println("DHT read failed");
    }

    int gasVal       = analogRead(GAS_PIN);
    String gasStatus = gasVal > GAS_THRESHOLD ? "danger" : "safe";
    Firebase.RTDB.setString(&fbdo, base + "/gas", gasStatus);
    Serial.printf("Gas: %d (%s)\n", gasVal, gasStatus.c_str());

    if (distance > 0) {
      Firebase.RTDB.setFloat(&fbdo, base + "/distance", distance);
      Serial.printf("Distance: %.1f cm\n", distance);
    }
  }

  delay(200);
}