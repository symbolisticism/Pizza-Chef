# Pizza Chef
This is a pizza ordering application. You can create pizzas, view them in your cart, update them in your cart, and delete them if you want to start from scratch.

<div style="display: flex; justify-content: space-between; flex-wrap: wrap;">
  <img src="assets\documentation\home.png" alt="Home Screen" width="300"/>
  <img src="assets\documentation\nav_drawer.png" alt="Navigation Drawer" width="300"/>
  <img src="assets\documentation\blank_order.png" alt="Blank Order Screen" width="300"/>
  <img src="assets\documentation\empty_cart.png" alt="Empty Cart" width="300"/>
  <img src="assets\documentation\filled_order.png" alt="Filled Order Screen" width="300"/>
  <img src="assets\documentation\pizza_added.png" alt="Pizza Added" width="300"/>
  <img src="assets\documentation\filled_cart.png" alt="Filled Cart" width="300"/>
  <img src="assets\documentation\update_pizza.png" alt="Update Pizza" width="300"/>
  <img src="assets\documentation\updated_pizza.png" alt="Updated Pizza" width="300"/>
  <img src="assets\documentation\delete_dialog.png" alt="Delete Pizza Dialog" width="300"/>
  <img src="assets\documentation\pizza_deleted.png" alt="Deleted Pizza" width="300"/>
</div>


# Accessing the Pizza Chef app

## 1. Install on a mobile phone (Android)

### Prerequisites
This app is only available on Android. To download the app to your Android device, ensure that you have your device, a Windows PC, and a cable connecting your device to your Windows PC. Plug the cable into your device, and plug the other end of the cable into your PC before beginning.

If you are downloading the app onto a mobile device, the simplest way to do this is to use the `app-release.apk` file in the repository.

### Instructions

1. Locate the file named `pizza-chef.apk` in the repository above and click on it.
<img src="assets/documentation/adb_download.png"/>

2. On the page it brings you to, there is a menu button with three dots near the top right corner. Click on that.
<img src="assets/documentation/menu_button.png"/>

3. On the menu that appears underneath it, click on the button that says "Download".
<img src="assets/documentation/download_button.png"/>

4. The file will be downloaded to the location you choose in your system. *Make note of where it gets downloaded because you'll need the file path for the next step. I downloaded it to my `Downloads` directory under my user.*
5. Press the Windows key or click on start on your PC
6. In the search bar that appears, type in `command`, and click on the app named "Command Prompt" that appears underneath.
<img src="assets/documentation/command_prompt.png"/>

7. When the command prompt window opens, navigate to the directory in which your downloaded APK resides. For me, I am changing to the `Downloads` directory. 
8. Once in the right directory, run the command `adb install pizza-chef.apk`, where "pizza-chef.apk" should be the name of the file you downloaded. If it is not, type in the name of the APK as it is in your file system.
<img src="assets/documentation/commands_to_download.png"/>

9. If you've done all that correctly, you will see a message stating that the streamed install is in progress, followed by a success message. You are now ready to open and interact with the app on your Android phone.
<img src="assets/documentation/install_success.png"/>

## 2. On the web
To access the web version of the Pizza Chef app, open [this link](https://pizza-chef-873cf.web.app).

# Running Tests Locally
*Note: All instructions for running tests are written with the assumption that the user is using a Windows computer running Windows 11.*

To run these tests, we will be using Flutter's built-in test suite, which we will be accessing through the command line.

1. To run the automated test script locally, download the GitHub repository to your computer. You can do this by clicking the 'Code' button near the top right of the screen.
<img src="assets/running_tests/code_button.png"/>

2. Then, click 'Download Zip' from the menu that appears.
<img src="assets/running_tests/download_zip_button.png"/>
If prompted, choose a place to save the zip folder and a name for it. I have chosen to save mine to my Downloads folder and leave the default name. 
*Note: If you are not prompted to choose a place where it should be downloaded, check your Downloads folder.*
<img src="assets/running_tests/save_zip_to_downloads.png"/>

3. Next, open your File Explorer and locate your newly downloaded zip folder. Click on it once, then right click on it and select 'Extract All' from the menu that appears.
<img src="assets\running_tests\right_click_on_folder.png"/>
The file structure of the extracted folder will be:  `Project Name > Project Name > Project Files`. 
You need to navigate down to the second `Project Name` level, but still one directory above the `Project Files`. You can navigate one directory deeper by double clicking on a folder. If you've navigated to the correct directory, you will see the name of the project in the search bar above and only one folder in your current directory with the same name as above.
<img src="assets\running_tests\right_click_copy_as_path.png"/>

4. When you're in the right directory, click on the folder once, then right click it. In the menu that appears, click 'Copy as Path'.

5. Next, open your terminal application by pressing and holding the Windows key and then pressing the 'R' key.
In the dialog box that appears, ensure that 'cmd' is entered into the text box labeled 'Open', and then click 'OK'.
<img src="assets\running_tests\cmd_box.png"/>

6. Your terminal application will open. Using that path you copied from step 4, enter `cd <copied path>` and then press 'Enter'. Then type `flutter test` and press 'Enter'
<img src="assets\running_tests\paste_path_and_run_test.png"/>

7. You will see the project download all the necessary dependencies needed for the app, and then you will see the tests run. Once the tests have completed, you will see a message that reads, "All tests passed!"
<img src="assets\running_tests\running_tests1.png"/>
<img src="assets\running_tests\all_tests_passed.png"/>

# Overview of the Application
This app makes use of the Flutter framework, which is a modular tool that helps developers create beautiful and interactive apps for phones, tablets, and computers that work on virtually all platforms. For state management and data persistence, Google Firebase provides a simple interface for writing and reading from a NoSQL database.

The app is capable of creating pizza orders. In the tech world, an app like this one is often referred to as a CRUD application because it revolves around the ability to **C**reate, **R**ead, **U**pdate, and **D**elete information. In the app, users can do all those things with individual pizzas to create their ideal pizza order.

# My Thought Process Behind Technical Choices
## Environment and Tools
For my environment, I used VS Code because of its abundant extensions and coding helps that accelerate the development process. I built the app using the Flutter framework because it is the one I'm most familiar with, which allowed me to conceptualize and build the app fairly quickly. Firebase was a natural choice after deciding to use Flutter because they were designed to interact with each other, since they are both Google products. That means that integrating and getting started with using Firebase is a quick and simple process.

## Navigation
For the app's navigation, I started out using the traditional method of pushing screens onto the stack and popping them off to return. I quickly realized that that would complicate loading a saved state when the app was closed and re-opened, so I refactored my navigation to always push a replacement screen onto the stack. I also added a navigation drawer on the left side of the application to decentralize the navigation. 

## Saving State
I decided to save the following state variables:
1. Last used screen
2. Values last entered for pizza creation
3. Time since last app startup

My reasoning for saving the last used screen was to return the user to that screen if they closed the app and reopened it within a relatively short timeframe. 

The last-entered values for the pizza creation ensure that if the app closes or is closed during pizza creation, the user can pick up where they left off if they reopen the app within a relatively short time frame. This state is only loaded when the app is closed and reopens to the order form page because it is assumed that a user will not purposefully navigate away from the order form until they have finished their order.

Knowing the time since the app last started assists in knowing whether to refresh the state. It is not easy in code to tell the difference between when an app is closed or refreshed. The developer has to make certain assumptions and build the app around them. I worked around this problem by always logging the time when the app starts up. If the app starts up and notices that more than 5 minutes have passed since the app was last opened, it is assumed that the user purposefully closed the app the last time, and so the state is refreshed. 

## Running Tests
Because Flutter offers a built-in framework for testing the application, I used that to minimize costs in time to integrate a different test suite.