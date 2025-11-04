function getNameCity(latitude, longitud, leng, callback) {
    let url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitud}&accept-language=${leng}`;

    let req = new XMLHttpRequest();
    req.open("GET", url, true);

    req.onreadystatechange = function () {
        if (req.readyState === 4) {
            if (req.status === 200) {
                let datos = JSON.parse(req.responseText);
                let address = datos.address;
                let city = address.city;
                let county = address.county;
                let state = address.state;
                let full = city ? city : state ? county : ""
                console.log(full);
                callback(full);
            } else {
                console.error(`Error en la solicitud: ${req.status}`);
            }
        }
    };

    req.send();
}
