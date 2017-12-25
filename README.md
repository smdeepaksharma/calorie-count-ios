# calorie-count
iOS application

## Description
The app allows users to track count of calories, fat, protein and carbs they consume every day.
Records are stored per day so that user can view the statistics of a previous date.
Tap on the date in the navigation bar to change the date
Users has to select a meal type (Breakfast, Lunch or Dinner) and enter the food they eat for the corresponding meal.
You have three options to record a food item
1. Text search: Type in the food item to get suggestions. Pick the one you’re looking for. Enter the units and select a measure. (pounds, grams, kilograms etc.)
2. Capture it: Take a picture of the food item.
3. Bar code search: Scan the bar code on the food item
To view the nutrition details of a food, tap on any food item in the “My food list”. Before you can view the nutrition details you must add a food item to the “my food list”

## APIs and Libraries

API used to obtain food suggestions and nutrition details:
https://developer.edamam.com/

ML model used to predict the food item:
https://coreml.store/food101

Libraries used:
AlamoFire
SwiftyJSON
Barcode Scanner (https://github.com/hyperoslo/BarcodeScanner)
SQLite.swift


