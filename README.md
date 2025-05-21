# AppleEffortScorePicker
Offers a drop-in SwiftUI component for Apple’s missing HealthKit effort score picker.
As of iOS 18 and watchOS 11 Apple offers an API to read and write the effort of a HealthKit Workout.
Unfortunately we only get the API, there's no UI component for the user to actually pick a value.

# Features
- UI/ UX mimiks the one offered by Apple on watchOS/ iOS as close as possible
- Simplified `HKHealthStore` APIs to fetch and save the effort score for a given workout
- Localized in 40 Languages
- UI Components (as seen in the Apple Workout App on watchOS or the iOS Fitness App):
  - `AppleEffortScoreCell`: A cell that can be shown in a workout summary
  - EffortScorePickerView: A view that shows a horizontal picker
  - EffortScorePickerList: A list that shows a vertical picker

# How To
- Add this library as a SPM to your project
- Add `import AppleEffortScorePicker` in your view
- Add the `AppleEffortScoreCell` to your workout summary (or any other view)

# Demo
Check out the Demo contained in this package to see it in action.

# Apple Clip
Apple advertises the feature including UI on watchOS and iOS here
[![Watch the video](https://img.youtube.com/vi/SGPTKzZVpbc/maxresdefault.jpg)](https://www.youtube.com/watch?v=SGPTKzZVpbc)









