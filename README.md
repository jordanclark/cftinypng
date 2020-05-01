```
         __  _    _                                    
   ___  / _|| |_ (_) _ __   _   _  _ __   _ __    __ _ 
  / __|| |_ | __|| || '_ \ | | | || '_ \ | '_ \  / _` |
 | (__ |  _|| |_ | || | | || |_| || |_) || | | || (_| |
  \___||_|   \__||_||_| |_| \__, || .__/ |_| |_| \__, |
                            |___/ |_|            |___/ 
```
[![Build Status](https://travis-ci.com/jordanclark/cftinypng.svg?branch=master)](https://travis-ci.com/jordanclark/cftinypng)
[![testbox](https://img.shields.io/badge/tested%20with-textbox-brightgreen)](https://www.ortussolutions.com/products/testbox)
![Lucee 4.5](https://img.shields.io/badge/lucee-4.5-blue)
![Lucee 5.3](https://img.shields.io/badge/lucee-5.3-blue)
![Adobe ColdFusion 2018](https://img.shields.io/badge/coldfusion-2018-blue)
![Adobe ColdFusion 2016](https://img.shields.io/badge/coldfusion-2016-blue)
[![License](https://img.shields.io/badge/License-Apache2-brightgreen)](https://forgebox.io/view/cftinypng)

# cftinypng
TinyPNG.com ColdFusion Rest API Client

Super easy way to compress PNG & JPG images with this remote web service, free accounts include 500 operations per month. Signup at
https://tinypng.com/developers

## To Install
Run the following from commandbox:
`box install cftinypng`

## Example
```
tiny = new cftinypng.tinypng( apiKey= "..." );
result= tiny.shrinkUrl( "https://www.imagineer.ca/images/caricature.png" );
if( result.success ) {
	writeOutput( '<img src="#result.image#" width="#result.width#" height="#result.height#" />' );
}
// or
result= tiny.shrinkImage( "image.jpg" );
if( result.success ) {
	tiny.getImage( result.image, "./output.jpg" );
}
```

## Run Tests
Install testbox
```
box install
box testbox run
```

## Changes
* 2020-05-01 Testbox, Travis CI, Adobe Coldfusion Compatibility
* 2019-05-28 Open source release

## API documentation
https://tinypng.com/developers/reference

## License
Apache License, Version 2.0.