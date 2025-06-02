# AppleEffortScorePicker
Offers a drop-in SwiftUI component for Apple’s missing HealthKit effort score picker. As of iOS 18 and watchOS 11, Apple provides an API to read and write the effort of a HealthKit Workout, but doesn’t include a UI component for users to select a value. This library fills that gap.

| iOS Demo | watchOS Demo |
|:--------:|:------------:|
| ![iOS Demo](https://github.com/user-attachments/assets/9721711e-95c4-4757-8046-9079cd9555fb) | ![watchOS Demo](https://github.com/user-attachments/assets/b5df77c3-74cc-40d5-ab61-07d2434a37ea) |

# Features
-	UI/UX that closely mimics Apple’s native design on watchOS/iOS
-	Simplified `HKHealthStore` APIs to fetch and save effort scores for workouts
-	Localized in 40 languages
-	Ready-to-use UI components:
	  -	`AppleEffortScoreCell`: A cell for displaying effort scores in workout summaries
	  -	`EffortScorePickerView`: A horizontal picker for selecting effort scores
	  -	`EffortScorePickerList`: A vertical picker alternative for selecting effort scores

# Requirements
iOS 18.0+ or watchOS 11.0+ (but the package can be imported into projects that support older OS versions)
	
# How To
- Add this library as a SPM to your project
- Add `import AppleEffortScorePicker` in your view
- Add the `AppleEffortScoreCell` to your workout summary (or any other view)

# Demo
Check out the included demo app to see the components in action. The demo showcases all available UI components and demonstrates how to integrate with HealthKit.

# How Apple Showcases the Feature
[![Apple showcasing the workout effort picker](https://img.youtube.com/vi/SGPTKzZVpbc/hqdefault.jpg)](https://www.youtube.com/shorts/watch?v=SGPTKzZVpbc)
