import QtQuick 2.15
import QtQuick.Controls 2.15
import "../js/traductor.js" as Traduc
import "../js/GetInfoApi.js" as GetInfoApi
import "../js/geoCoordinates.js" as GeoCoordinates
import "../js/GetCity.js" as GetCity
import "../js/GetModelWeather.js" as GetModelWeather

Item {
  signal dataChanged // Definir el signal aquí

  function obtener(texto, indice) {
    var palabras = texto.split(/\s+/); // Divide el texto en palabras utilizando el espacio como separador
    return palabras[indice - 1]; // El índice - 1 porque los índices comienzan desde 0 en JavaScript
  }

  function fahrenheit(temp) {
    if (temperatureUnit == 0) {
      return temp;
    } else {
      return Math.round((temp * 9 / 5) + 32);
    }
  }

  property string useCoordinatesIp: plasmoid.configuration.useCoordinatesIp
  property string latitudeC: plasmoid.configuration.latitudeC
  property string longitudeC: plasmoid.configuration.longitudeC
  property string temperatureUnit: plasmoid.configuration.temperatureUnit

  property string latitude: (useCoordinatesIp === "true") ? latitudeIP : (latitudeC === "0") ? latitudeIP : latitudeC
  property string longitud: (useCoordinatesIp === "true") ? longitudIP : (longitudeC === "0") ? longitudIP : longitudeC

  property var observerCoordenates: latitude + longitud

  property int currentTime: Number(Qt.formatDateTime(new Date(), "h"))

  property string datosweather: "0"


  property string day: (Qt.formatDateTime(new Date(), "yyyy-MM-dd"))
  property string therday: Qt.formatDateTime(new Date(new Date().getTime() + (numberOfDays * 24 * 60 * 60 * 1000)), "yyyy-MM-dd")
  property int numberOfDays: 6
  property string temperaturaActual: fahrenheit(obtener(datosweather, 1))
  property string codeleng: ((Qt.locale().name)[0] + (Qt.locale().name)[1])
  property string codeweather: obtener(datosweather, 4)
  property string codeweatherTomorrow: obtener(forecastWeather, 2)
  property string codeweatherDayAftertomorrow: obtener(forecastWeather, 3)
  property string codeweatherTwoDaysAfterTomorrow: obtener(forecastWeather, 4)
  property string minweatherCurrent: fahrenheit(obtener(datosweather, 2))
  property string maxweatherCurrent: fahrenheit(obtener(datosweather, 3))
  property string minweatherTomorrow: twoMin
  property string maxweatherTomorrow: twoMax
  property string minweatherDayAftertomorrow: threeMin
  property string maxweatherDayAftertomorrow: threeMax
  property string minweatherTwoDaysAfterTomorrow: fourMax
  property string maxweatherTwoDaysAfterTomorrow: fourMax
  property string iconWeatherCurrent: asingicon(codeweather)



  property string completeCoordinates: ""
  property string latitudeIP: completeCoordinates.substring(0, (completeCoordinates.indexOf(' ')) - 1)
  property string longitudIP: completeCoordinates.substring(completeCoordinates.indexOf(' ') + 1)



  Component.onCompleted: {
    updateWeather(2);
  }


  function getCoordinatesWithIp() {
    GeoCoordinates.obtenerCoordenadas(function(result) {
      completeCoordinates = result;
    });
  }


  function getWeatherApi() {
    GetInfoApi.obtenerDatosClimaticos(latitude, longitud, day, currentTime, function(result) {
      datosweather = result;
      retry.start()
    });
  }

  function asingicon(x, b) {
    let wmocodes = {
      0: "clear",
      1: "few-clouds",
      2: "few-clouds",
      3: "clouds",
      51: "showers-scattered",
      53: "showers-scattered",
      55: "showers-scattered",
      56: "showers-scattered",
      57: "showers-scattered",
      61: "showers",
      63: "showers",
      65: "showers",
      66: "showers-scattered",
      67: "showers",
      71: "snow-scattered",
      73: "snow",
      75: "snow",
      77: "hail",
      80: "showers",
      81: "showers",
      82: "showers",
      85: "snow-scattered",
      86: "snow",
      95: "storm",
      96: "storm",
      99: "storm",
    };
    var cicloOfDay = isday();
    var iconName = "weather-" + (wmocodes[x] || "unknown");
    var iconNamePresicion = cicloOfDay === "day" ? iconName : iconName + "-" + cicloOfDay;
    return b === "preciso" ? iconNamePresicion : iconName;
  }

  function isday() {
    var timeActual = Number(Qt.formatDateTime(new Date(), "h"));
    if (timeActual < 6) {
      if (timeActual > 19) {
        return "night";
      } else {
        return "day";
      }
    } else {
      return "day";
    }
  }

  function updateWeather(x) {
    if (x === 2) {
      if (useCoordinatesIp === "true") {
        getCoordinatesWithIp();
      } else {
        if (latitudeC === "0" || longitudC === "0") {
          getCoordinatesWithIp();
        }
      }
    }
    getWeatherApi();
  }

  Timer {
    id: retry
    interval: 5000
    running: false
    repeat: false
    onTriggered: {
      if (datosweather === "failed 0") {
        if (latitudeC === "0" || longitudC === "0") {
          getCoordinatesWithIp();
        }
        getWeatherApi();
      }
      if (city === "") {
        getCityFuncion();
      }
    }
  }

  onDatosweatherChanged: {
    checkDataReady()
  }

  function checkDataReady() {
    // Verificar si forecastWeather y datosweather están disponibles
    if (forecastWeather !== "0" && datosweather !== "0") {
      dataChanged(); // Emitir el signal dataChanged cuando los datos estén listos
    }
  }

  Timer {
    id: weatherupdate
    interval: 900000
    running: true
    repeat: true
    onTriggered: {
      updateWeather(1);
    }
  }



  onObserverCoordenatesChanged: updateWeather(2)
}

