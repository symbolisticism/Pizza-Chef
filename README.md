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

