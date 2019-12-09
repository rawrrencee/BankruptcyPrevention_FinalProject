** Please run the .workspace file.

Storyboards:

1) Login
2) Register
3) Home
3A) Add Transaction
3B) Edit Transaction
3C) View Expense Image
4) Reports
5) Profile

Functions:

1) Login (Backdoor username/password: admin/1234)
- User enters username/password to login.
*Checks for empty username/password - alerts user if true.
- Connects to Google Firebase to login user.
*Converts user entered password to BCrypt hash and checks with hash on server.
*User logs in successfully if hash is verified.
*App sets UserDefaults (userID) for that session.

2) Register
- User can use email address + password to create an account.
*Checks for valid email addresses (example: must contain '@')
*Checks Firebase for existing email addresses - alerts user if already in use.

3) Home
- User sees a month amount: Sum of all expenses for the current month this year.
- User can add transaction to log his/her transaction.
- User can tap on the cell listing to edit his/her transaction.

3A) Add Transaction
- User enters amount and description of transaction in text.
*Checks if 'amount' contains only numbers/Checks if description is filled - alerts users if checks are not satisfied.
- User can add a photograph from Camera or image from Photo Library that represents the transaction.

3B) Edit Transaction
- User taps on the cell listing to edit the transaction.
- User can modify the information on a previous transaction they submitted.
*System completely tabulates the user's entries to repopulate the reports and the transaction table.
- User can view the stored photograph in a larger view. (3C)

3C) Image enlarged view
- User reaches this page when trying to view the image they have stored as part of their transaction.

4) Reports
- Displays a bar chart with the amount spent every month.
- User can zoom in and out with gestures to enlarge/shrink the bar charts.

5) Profile
- User can log out their session from this page.

Technologies used:
Firebase Firestore - user account information is stored here
CocoaPods (BCryptSwift, Material Design buttons and text fields, iOS Charts, iOS KeyboardManager - automatically moves the view to make space for keyboard)

Project Requirements:
Multiple Views - shown via the tab controller - Register/Login/Home/Reports/Add Transaction/Edit Transaction
CoreData - user data is stored in the local phone storage
CoreGraphics - Reports page
Additional Framework -  Camera/Photo Picker functionality
Networking - Firebase Firestore
