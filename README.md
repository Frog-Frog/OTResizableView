# OTResizableView

## Description
OTResizableView is a UIView library that can be resized with fingers.

## Features
・Resize
・Keep aspect resize
・Move
・Change color

## Demo
![OTResizableVIewDemo.gif](https://qiita-image-store.s3.amazonaws.com/0/152335/4247576c-8532-e632-c335-6445634904b7.gif "OTResizableVIewDemo.gif")
 
## Usage

```swift

import OTResizableView

let resizableView = OTResizableView(contentView: yourView)
resizableView.delegate = self;
        
// If you want to change resizableView colors, you can customize here.

view.addSubview(resizableView)


```

## Install

### CocoaPods  
Add this to your Podfile.

```PodFile
pod 'OTResizableView'
```

### Carthage  
Add this to your Cartfile.

```Cartfile
github "PKPK-Carnage/OTResizableView"
```

## Help

If you want to support this framework, you can do these things.

* Please let us know if you have any requests for me.

	I will do my best to live up to your expectations.

* You can make contribute code, issues and pull requests.
	
	I promise to confirm them.

## Licence

[MIT](https://github.com/PKPK-Carnage/OTResizableView/blob/master/LICENSE)

## Author

[PKPK-Carnage🦎](https://github.com/PKPK-Carnage)
