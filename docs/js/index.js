/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

var isAppForeground = true;
var backCounter = 0;
var admobid = {};
if( /(android)/i.test(navigator.userAgent) ) {
    admobid = { // for Android
        banner : "ca-app-pub-9018029357773039/7849846505",
        interstitial : "ca-app-pub-9018029357773039/1663712106"
	};
} else if(/(ipod|iphone|ipad)/i.test(navigator.userAgent)) {
	admobid = { // for iOS
        banner : "ca-app-pub-9018029357773039/7849846505",
        interstitial : "ca-app-pub-9018029357773039/1663712106"
	};
} else {
	admobid = { // for Windows Phone
        banner : "ca-app-pub-9018029357773039/7849846505",
        interstitial : "ca-app-pub-9018029357773039/1663712106"
	};
}
var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
        document.addEventListener('backbutton', this.onBackButton, false);
        // document.addEventListener('admob.banner.events.LOAD_FAIL', this.onLoadFail, function (event) {});
//        document.addEventListener('bannerreceive', this.onBannerReceive, false);
        // document.addEventListener(admob.events.onAdLoaded, onAdLoaded);
        // document.addEventListener(admob.events.onAdOpened, function (e) {});
        // document.addEventListener(admob.events.onAdClosed, function (e) {});
        // document.addEventListener(admob.events.onAdLeftApplication, function (e) {});
        // document.addEventListener(admob.events.onInAppPurchaseRequested, function (e) {});
        // document.addEventListener(admob.events.onAdFailedToLoad, function (e) {});
    },
    onConfirm: function(idx) {
        if (idx == 2) {
            navigator.app.exitApp();
        } else {
            backCounter = 0;
        }
    },
    onAdLoaded: function() {
        if (e.adType === admob.AD_TYPE.INTERSTITIAL) {
            admob.showInterstitialAd();
            showNextInterstitial = setTimeout(function() {
                admob.requestInterstitialAd();
            }, 2 * 60 * 1000); // 2 minutes
        }
    },
    // onLoadFail: function(event) {
    //     console.dir(event);
    // },
    onBackButton: function() {
        backCounter += 1;
        navigator.notification.confirm("アプリを終了しますか？", app.onConfirm, "終了メニュー", ["キャンセル", "終了"]);

    },
    onDeviceReady: function() {
        // if ( window.plugins && window.plugins.AdMob ) {
        //     // AdMob.createBanner( {
        //     //     adId: admobid.banner,
        //     //     position: AdMob.AD_POSITION.BOTTOM_CENTER,
        //     //     isTesting: true,
        //     //     overlap: false,
        //     //     offsetTopBar: false,
        //     //     bgColor: 'black'
        //     // } );

        //     // admob.banner.config({
        //     //     id: admobid.banner,
        //     //     isTesting: false,
        //     //     autoShow: true
        //     // });
        //     // admob.banner.prepare();
        //     // admob.banner.show();
        //     // admob.interstitial.config({
        //     //     id: admobid.interstitial,
        //     //     isTesting: true,
        //     //     autoShow: false,
        //     // });
        //     // admob.interstitial.prepare();
        //     // admob.interstitial.show();

        //     app.receivedEvent();
        // } else {
		    // alert( 'AdMob plugin not ready' ); return;
        // }
        FastClick.attach(document.body);
    },
    receivedEvent: function() {
        var bOverLap = false;
        if (device.version.search('4.1.') === 0) {
            bOverLap = true;
        }
        window.plugins.AdMob.setOptions({
            publisherId:      admobid.banner,
            interstitialAdId: admobid.interstitial,
            tappxIdiOs:       "",
            tappxIdAndroid:   "",
            tappxShare:       "",
            adSize:           window.plugins.AdMob.AD_SIZE.SMART_BANNER,
            bannerAtTop:      false,
            overlap:          bOverLap,
            offsetStatusBar:  false,
            isTesting:        false,
            adExtras :        {},
            autoShowBanner:   true,
            autoShowInterstitial: true
        });
        window.plugins.AdMob.createBannerView();
//        window.plugins.AdMob.requestInterstitial();
    }
};

app.initialize();
