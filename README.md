# VirtualTourist
This app allows users specify travel locations around the world, and create virtual photo albums for each location. The locations and photo albums will be stored in Core Data.
The app will have two view controller scenes.
Travel Locations Map View: 
* Allows the user to drop pins around the world
* Photo Album View: Allows the users to download and edit an album for a location

<img src="https://lh4.googleusercontent.com/IoTiaZiXeSggp_emr1yOrRHLPVwGm0qDcaDgqdDpRBZFHn02w6731e4HFhnmmupld6pmYyQgCQGmtac0q7AT_7Dj7xt6TsyKDbUF5iqsGIAzbwT-b6FSY5Q6Bw9NpWcriQLCvgI" width="263" height="500">  <img src="https://lh5.googleusercontent.com/VSpJv_4lE2sEH5AV_Utaet7cyPrSUqhCbDegDyKXXsTTwtbKPMk4FwpM30ixF-tYdlXqb4gj1vAurg5mA4pKYfeeCKWOWyFTWUPK1iCIUrFUp6GkB5KmG1ktnpPgbGZ2Q6CyXSQ" width="263" height="500">

### Travel Locations Map

When the app first starts it will open to the map view. Users will be able to zoom and scroll around the map using standard pinch and drag gestures.
The center of the map and the zoom level should be persistent. If the app is turned off, the map should return to the same state when it is turned on again.
Tapping and holding the map drops a new pin. Users can place any number of pins on the map.
When a pin is tapped, the app will navigate to the Photo Album view associated with the pin.

### Photo Album

If the user taps a pin that does not yet have a photo album, the app will download Flickr images associated with the latitude and longitude of the pin.
If no images are found a “No Images” label will be displayed.
If there are images, then they will be displayed in a collection view.
While the images are downloading, the photo album is in a temporary “downloading” state in which the New Collection button is disabled. The app should determine how many images are available for the pin location, and display a placeholder image for each.
