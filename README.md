# UICheckbox with Indeterminate State

This project is a demonstration of the check box with indeterminate state. This app was developed using the latest iOS 13.3 SDK and Swift 5.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. 

#### IDE

The project was created using Xcode 11.4.

#### Using UICheckbox in your view

When creating an instance of the checkbox view you will need to provide it with a data. The data is a dictionary with an array as its value. The value could be any value provived it conforms to the `Labelable` protocol.

```swift
struct Item: Labelable {
    var title: String
}
```

The title will be used as the lable of the checkbox items.

Below is an example of how you would create and use an instance of the checkbox view. You can see in the code sample that we have created the data for the checkbox then passed it on the initializer. Then, we called the `embedInContainer(container: self.view)`method to add the view as a subview of any superview and it will automatically setup the autolayout constraints. By now this is ready to be viewed on a simulator.

```swift
var checkbox: UICheckbox<Item>!
let sample = [
            "PARENT1": [Item(title: "item1"), Item(title: "item2")],
            "PARENT2": [Item(title: "item1"), Item(title: "item2")]
        ]
        
        checkbox = UICheckbox(items: sample)
        checkbox.embedInContainer(container: self.view)
```

#### Checkbox Item Styling

A checkbox item has multiple states and each state can have different styles or background colors. The view already has a default style while you have the option to create your own style and pass it in the view instance. All you need to do is create a class or struct that conforms to the `CheckBoxStyle` protocol. For now the protocol is very simple. On future versions we may consider adding the font style.

```swift
protocol CheckBoxStyle {
    func indeterminateStyle() -> UIColor
    func defaultStyle() -> UIColor
    func selectedStyle() -> UIColor
}
```

Once you already have you custom style just set it to the style property of the view.

```Swift
checkbox.checkBoxItemStyle = CustomCheckboxStyle()
```

### Running on the Simulator

Open the project in Xcode and select the destination device then click Run.

## Built With

* Vanilla Swift 

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Naz Mariano** -  [LinkedIn](https://www.linkedin.com/in/iamnaz/)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

