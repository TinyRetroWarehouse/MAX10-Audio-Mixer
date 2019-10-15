#include <SPI.h>
#include <WiFi.h>
#include <FS.h>
#include <ESPAsyncWebServer.h>
#include <SPIFFS.h>

#define WRITE_FLAG 0b10000000

AsyncWebServer server(80);

IPAddress ipServer(192, 168, 0, 120);
IPAddress ipGateway(0, 0, 0, 0);

char packetBuffer[128];

String AP_SSID = "XXXX";
String AP_PASS = "XXXXXXXX";

SPISettings mySPISettings = SPISettings(100000, MSBFIRST, SPI_MODE1);

void setVol(int ch,int val){
  digitalWrite(5,LOW);
  Serial.print("setVol ch:");
  Serial.print(ch);
  SPI.transfer(ch | WRITE_FLAG);
  Serial.print(" val:");
  Serial.println(val);
  SPI.transfer(val);
  digitalWrite(5,HIGH);
}

byte getVol(int ch){
  digitalWrite(5,LOW);
  Serial.print("getVol ch:");
  Serial.print(ch);
  SPI.transfer(ch);
  Serial.print(" val:");
  int rtn = SPI.transfer(0);
  Serial.println(rtn);
  digitalWrite(5,HIGH);
  return rtn;
}
void handle_getVol(AsyncWebServerRequest *request) {
  // Mode,Slot,AP_SSID,AP_PASS
  String html = "{";
  int i;
  for(i = 0; i < 32; i++){
    html += "\"ch";
    html += i;
    html += "\":";
    html += getVol(i);
    html += ",";
    delay(10);
  }
  html += "\"success\":true}";
  Serial.println(html);
  request->send(200, "application/json", html);
}

void handle_setVol(AsyncWebServerRequest *request) {
  if (request->hasParam("ch") && request->hasParam("vol")) {
    int ch = request->getParam("ch")->value().toInt();
    int vol = request->getParam("vol")->value().toInt();
    setVol(ch,vol);
    request->send(200, "application/json", "{\"success\":true}");
  }else{
    request->send(400, "application/json", "{\"success\":false}");
  }
}

void handleNotFound(AsyncWebServerRequest *request) {
  if (! handleFileRead(request,request->url())) {
    if (! handleFileRead(request, request->url())) {
      //  ファイルが見つかりません
      Serial.println("404 not found");
      request->send(404, "text/plain", "File not found in Dongbeino...");
    }
  }
}

//  MIMEタイプを推定
String getContentType(String filename) {
  if (filename.endsWith(".html") || filename.endsWith(".htm")) return "text/html";
  else if (filename.endsWith(".css")) return "text/css";
  else if (filename.endsWith(".js")) return "application/javascript";
  else if (filename.endsWith(".png")) return "image/png";
  else if (filename.endsWith(".gif")) return "image/gif";
  else if (filename.endsWith(".jpg")) return "image/jpeg";
  else return "text/plain";
}
//  SPIFSS のファイルをクライアントに転送する
bool handleFileRead(AsyncWebServerRequest *request, String path) {
  Serial.println("handleFileRead: trying to read " + path);
  // パス指定されたファイルがあればクライアントに送信する
  if (path.endsWith("/")) path += "index.html";
  String contentType = getContentType(path);
  if (SPIFFS.exists(path)) {
    Serial.println("handleFileRead: sending " + path);
    request->send(SPIFFS, path, contentType);
    Serial.println("handleFileRead: sent " + path);
    return true;
  }
  else {
    return false;
  }
}


void setup()
{
  int i;
  Serial.begin(115200);
  //FS Init
  if (!SPIFFS.begin(true)) {
    Serial.println("SPIFFS Mount Failed");
    return;
  }

  //Wi-Fi Connect
  WiFi.mode(WIFI_STA);
  WiFi.begin(AP_SSID.c_str(), AP_PASS.c_str());
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }
  Serial.println("Wi-Fi Connected");

  SPI.begin();
  pinMode(5,OUTPUT);
  digitalWrite(5,HIGH);
  SPI.beginTransaction(mySPISettings);
  
  server.on("/getvol", HTTP_GET, handle_getVol);
  server.on("/setvol", HTTP_GET, handle_setVol);
  
  server.onNotFound(handleNotFound);
  server.begin();
}

void loop()
{
}
