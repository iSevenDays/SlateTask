# SlateTask
SlateTask

1. Set initial location or wait for new location
2. Start tracking default geofence area with the default radius at the current GPS location
3. When map is moved, geofence area is updated
4. Current location pin location is set in simulator debug settings (Simulator - Debug - Location - Custom location)


In order to use Wi-Fi detect capability on iOS 12
We need to add Wi-Fi capability from the documentation here https://stackoverflow.com/questions/50767946/systemconfiguration-captivenetwork-doesnt-work-on-ios-12
Unfortunately, my Apple ID doesn't support this.
Then, you should edit WiFi network name.

ServiceProvider.instance.geofenceService.startMonitoring(forRegion: monitoredRegion, inWiFiNetwork: "Apple")

![Inside](/Screenshots/inside.jpg?raw=true "Inside")

![Outside](/Screenshots/outside.jpg?raw=true "Outside")