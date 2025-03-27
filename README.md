# PokerWidget

`PokerWidget` is a customizable Flutter widget that displays a horizontally scrollable card deck with smooth animations, scaling effects, and saturation adjustments based on the distance between cards.

## Features
- Smooth scrolling with drag gestures
- Auto-snapping to the nearest card when released
- Dynamic scaling for focused cards
- Adjustable card spacing, size, and corner radius
- Gradual desaturation effect for distant cards

## Installation
Add the `PokerWidget` class to your Flutter project:

```dart
import 'poker_widget.dart';
```

## Usage
```dart
PokerWidget(
  itemBuilder: (context, index) => Image.network('src',
    height: 250,
    fit: BoxFit.fitHeight,
  ),
  length: 5,
  width: 300,
  height: 200,
  ratio: 0.7,
  radius: 12.0,
)
```

### Parameters
| Parameter       | Type                     | Description                           |
|-----------------|--------------------------|---------------------------------------|
| `itemBuilder`   | `IndexedWidgetBuilder`   | Builder function for each card        |
| `onChanged`     | `ValueChanged<int>`      | Callback when index changed           |
| `length`        | `int`                    | Total number of cards                 |
| `width`         | `double`                 | Total width of the PokerWidget        |
| `height`        | `double`                 | Height of the PokerWidget             |
| `ratio`         | `double`                 | Width-to-height ratio of active cards |
| `radius`        | `double`                 | Corner radius for rounded cards       |

## Customization
- **Animation Speed:** Adjust the animation duration in the `_animationController` declaration.
- **Scaling Effect:** Modify the scale factor inside `TransformCard`.
- **Saturation Effect:** Tweak the `getSaturationColorFilter` method to customize the grayscale intensity.

## Example
```dart
PokerWidget(
  itemBuilder: (context, index) => Image.network('src',
    height: 250,
    fit: BoxFit.fitHeight,
  ),
  length: 10,
  width: 400,
  height: 250,
)
```

## License
This project is licensed under the MIT License. Feel free to modify and distribute it for your own needs.

## Contributions
Contributions are welcome! Feel free to submit pull requests or report issues.

