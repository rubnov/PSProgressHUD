PSProgressHUD
=============

iOS Progress HUD that animates a custom set of images. 


## Set up

1. Copy PSProgressHUD.h and PSProgressHUD.m into your Xcode project.

2. Copy (your own) HUD images to your project's `images.xcassets` 

3. In **PSProgressHUD.h**, set `kPSHudImageNameFormat` and `kPSHudImageNumbers` to match your image names.

**Note: 
**
Your HUD images should use a common base-name and increasing numbers: 

	image01.png 
	image02.png 
	image03.png
	... 


## Usage 

To show the HUD: 

`[PSProgressHUD show] `

To dismiss the HUD:

`[PSProgressHUD dismiss] `



## Sample project
Shows the HUD in action. Take a look.
