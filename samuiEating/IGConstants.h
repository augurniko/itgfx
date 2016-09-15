//
//  IGConstants.h
//  samuiEating
//
//  Created by Mac on 17/04/2016.
//  Copyright © 2016 Nicolas Demogue. All rights reserved.
//

#ifndef IGConstants_h
#define IGConstants_h

// To do
// Set Facebook account
// Set application name
// Set Discount picture
// Picture place ratio : 1.5 --> 375 x 250
// Picture list ratio : 1.81 --> 335 x 185




// FACEBOOK ID PLACE //
// Dining on the rock : 212147928844560
// 

#define IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

// IT Grafix images url adress
#define     URL_ITGRAFIX_PHP_REQUEST    @"http://localhost:8888/ITGrafix/"//@"https://samuirestaurantguide.com/app/getJsonForDate.php"//@"http://localhost:8888/ITGrafix/"//
#define     URL_ITGRAFIX_PICT           @"https://www.samuirestaurantguide.com/wp-content/uploads/2016/01/"
#define     URL_ITGRAFIX_VIGNETTE       @""//https://www.samuirestaurantguide.com/wp-content/uploads/"
#define     URL_ITGRAFIX_WEB            @"http://www.google.com"//@"https://www.samuirestaurantguide.com"

#define     URL_PICTURE_FACEBOOK        @"https://graph.facebook.com/%@/picture?type=normal"

// Meteo url
#define     URL_METEO                   @"http://www.yr.no/place/Thailand/Surat_Thani/Ko_Samui/forecast.xml"
#define     URL_METEO_BY_HOUR           @"http://www.yr.no/place/Thailand/Surat_Thani/Ko_Samui/forecast_hour_by_hour.xml"

// MAIN --> LIST TYPE
#define     TYPE_NORMAL                 0
#define     TYPE_FAVORIT                1
#define     TYPE_DISCOUNT               2

// Facebook request
#define FACEBOOK_REQUEST                @"id,name,email,picture"

// String list for app
#define     STR_NO_INTERNET             @"You don't have internet connexion !"
#define     STR_FACEBOOK_LOGIN          @"Facebook login"
#define     STR_FACEBOOK_LOGOUT         @"Facebook logout"
#define     STR_FACEBOOK_REQUIRED       @"You must to be connected for access to this option"
#define     STR_NO_DISCOUNT             @"We don't have any promotion in this time"
#define     STR_FIRST_LAUNCH            @"You must have internet connexion for the first launch !"
#define     STR_SERVER_ERROR            @"Cannot connect to the server !"
#define     STR_NO_FAVORIT              @"You don't have favorit"
#define     STR_WELCOME_GUEST           @"Please sign up to enjoy discounts on your favorite restaurants in Samui"
#define     STR_WELCOME_FACEBOOK        @"Looking for a restaurant near you? Look no further."

#define     TIMER_FADE_IN               1.0

// my HK Guide

#endif /* IGConstants_h */
