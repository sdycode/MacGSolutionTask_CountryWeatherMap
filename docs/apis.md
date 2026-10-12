
**1. Countries: World Bank API** (has a list endpoint, a detail endpoint, and latitude/longitude)

```
List:   https://api.worldbank.org/v2/country?format=json&per_page=300
Detail: https://api.worldbank.org/v2/country/IN?format=json            
```


<br />

**2. Weather: Open-Meteo** (takes latitude and longitude)

```
https://api.open-meteo.com/v1/forecast?latitude=28.63&longitude=77.22&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code
```

**Bonus: flag images, FlagCDN** (uses the `iso2Code` from World Bank)

```
https://flagcdn.com/w160/in.png
```

<br />

<br />
































































1.1 ] 

https\://api.worldbank.org/v2/country?format=json\&per\_page=300\
\[

&#x20; {

&#x20;   "page": 1,

&#x20;   "pages": 1,

&#x20;   "per\_page": "300",

&#x20;   "total": 296

&#x20; },

&#x20; \[

&#x20;   {

&#x20;     "id": "ABW",

&#x20;     "iso2Code": "AW",

&#x20;     "name": "Aruba",

&#x20;     "region": {

&#x20;       "id": "LCN",

&#x20;       "iso2code": "ZJ",

&#x20;       "value": "Latin America & Caribbean "

&#x20;     },

&#x20;     "adminregion": {

&#x20;       "id": "",

&#x20;       "iso2code": "",

&#x20;       "value": ""

&#x20;     },

&#x20;     "incomeLevel": {

&#x20;       "id": "HIC",

&#x20;       "iso2code": "XD",

&#x20;       "value": "High income"

&#x20;     },

&#x20;     "lendingType": {

&#x20;       "id": "LNX",

&#x20;       "iso2code": "XX",

&#x20;       "value": "Not classified"

&#x20;     },

&#x20;     "capitalCity": "Oranjestad",

&#x20;     "longitude": "-70.0167",

&#x20;     "latitude": "12.5167"

&#x20;   },

&#x20;   {

&#x20;     "id": "AFE",

&#x20;     "iso2Code": "ZH",

&#x20;     "name": "Africa Eastern and Southern",

&#x20;     "region": {

&#x20;       "id": "NA",

&#x20;       "iso2code": "NA",

&#x20;       "value": "Aggregates"

&#x20;     },

&#x20;     "adminregion": {

&#x20;       "id": "",

&#x20;       "iso2code": "",

&#x20;       "value": ""

&#x20;     },

&#x20;     "incomeLevel": {

&#x20;       "id": "NA",

&#x20;       "iso2code": "NA",

&#x20;       "value": "Aggregates"

&#x20;     },

&#x20;     "lendingType": {

&#x20;       "id": "",

&#x20;       "iso2code": "",

&#x20;       "value": "Aggregates"

&#x20;     },

&#x20;     "capitalCity": "",

&#x20;     "longitude": "",

&#x20;     "latitude": ""

&#x20;   },


}

&#x20; ]

]

---

1.2 ] https\://api.worldbank.org/v2/country/IN?format=json

\[

&#x20; {

&#x20;   "page": 1,

&#x20;   "pages": 1,

&#x20;   "per\_page": "50",

&#x20;   "total": 1

&#x20; },

&#x20; \[

&#x20;   {

&#x20;     "id": "USA",

&#x20;     "iso2Code": "US",

&#x20;     "name": "United States",

&#x20;     "region": {

&#x20;       "id": "NAC",

&#x20;       "iso2code": "XU",

&#x20;       "value": "North America"

&#x20;     },

&#x20;     "adminregion": {

&#x20;       "id": "",

&#x20;       "iso2code": "",

&#x20;       "value": ""

&#x20;     },

&#x20;     "incomeLevel": {

&#x20;       "id": "HIC",

&#x20;       "iso2code": "XD",

&#x20;       "value": "High income"

&#x20;     },

&#x20;     "lendingType": {

&#x20;       "id": "LNX",

&#x20;       "iso2code": "XX",

&#x20;       "value": "Not classified"

&#x20;     },

&#x20;     "capitalCity": "Washington D.C.",

&#x20;     "longitude": "-77.032",

&#x20;     "latitude": "38.8895"

&#x20;   }

&#x20; ]

]

<br />

---

2 ] 

https\://api.open-meteo.com/v1/forecast?latitude=28.63\&longitude=77.22\&current=temperature\_2m,relative\_humidity\_2m,wind\_speed\_10m,weather\_code

{

&#x20; "latitude": 50.65026,

&#x20; "longitude": 77.23404,

&#x20; "generationtime\_ms": 1.789689064025879,

&#x20; "utc\_offset\_seconds": 0,

&#x20; "timezone": "GMT",

&#x20; "timezone\_abbreviation": "GMT",

&#x20; "elevation": 336.0,

&#x20; "current\_units": {

&#x20;   "time": "iso8601",

&#x20;   "interval": "seconds",

&#x20;   "temperature\_2m": "°C",

&#x20;   "relative\_humidity\_2m": "%",

&#x20;   "wind\_speed\_10m": "km/h",

&#x20;   "weather\_code": "wmo code"

&#x20; },

&#x20; "current": {

&#x20;   "time": "2026-10-10T14:45",

&#x20;   "interval": 900,

&#x20;   "temperature\_2m": 4.8,

&#x20;   "relative\_humidity\_2m": 67,

&#x20;   "wind\_speed\_10m": 6.1,

&#x20;   "weather\_code": 0

&#x20; }

}

---



