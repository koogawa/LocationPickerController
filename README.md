# LocationPickerController

Simple location picker with a built in maps. The selected item can be returned to the calling controller as a `CLLocationCoordinate2D`.

![](./demo.gif)

## Usage

1. Link `CoreLocation.framework` and `MapKit.framework` to your project
2. Fill in `NSLocationWhenInUseUsageDescription` in your Info.plist
3. Import `CoreLocation` and `LocationPickerController`
4. Initialize the LocationPickerController
5. Push the controller

```swift
import CoreLocation
import LocationPickerController
```

```swift
let viewController = LocationPickerController(success: {
    [weak self] (coordinate: CLLocationCoordinate2D) -> Void in
    self?.locationLabel.text = "".appendingFormat("%.4f, %.4f",
        coordinate.latitude, coordinate.longitude)
    })
let navigationController = UINavigationController(rootViewController: viewController)
self.present(navigationController, animated: true, completion: nil)
```

## Installation

LocationPickerController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "LocationPickerController"
```


## Requirements

Swift 4.0 / iOS 8.0+

## Creator

[Kosuke Ogawa](https://twitter.com/koogawa)
 
## License

LocationPickerController is available under the MIT license. See the LICENSE file for more info.


 
