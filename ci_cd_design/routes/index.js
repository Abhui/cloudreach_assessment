const express = require('express');
const router = express.Router();
var debug = require('debug')('test:server');
const fetch = require('node-fetch');
const API_KEY = process.env.API_KEY;

function convertKelvinToCelsius(k) {
    return Math.round((k - 273.15) * 100) / 100;
}

router.get('/', async function (req, res, next) {
    const cityName = req.query.cityName || 'London';
    debug('cityName: ', req.query.cityName);
    try {
        const data = await fetch(`https://api.openweathermap.org/data/2.5/weather?q=${cityName}&appid=${API_KEY}`);
        const json = await data.json();
        res.json({
            city:        cityName,
            temperature: convertKelvinToCelsius(json.main.temp)
        });
    } catch (error) {
        res.status(500);
        res.json({error: `could not retrieve data for ${cityName}`});
    }
});

module.exports = router;
