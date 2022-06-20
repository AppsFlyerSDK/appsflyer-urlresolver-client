
<img src="https://raw.githubusercontent.com/AppsFlyerSDK/appsflyer-capacitor-plugin/main/assets/AFLogo_primary.png"  width="600" >

# AppsFlyer URL Resolver

The AppsFlyer URLResolver library is a simple tool to perform redirections of a URL and get a final URL from it. 

## Table of contents
- [Installation](#Installation)
     - [Android Installation](#AndroidInstallation)
     - [iOS Installation](#iOSInstallation)
- [API](#API)
    - [Android API](#AndroidAPI)
    - [iOS API](#iOSAPI)
- [Debug](#Debug)
- [Support](#Support)


## <a id="Installation"> Installation  
 ### <a id="AndroidInstallation"> Android  
 Install the URLResolver library using Gradle. <br>
 **Step 1: Declare repositories**  
In the Project `build.gradle` file, declare the `mavenCentral` repository:
```groovy
 allprojects {  
      repositories {  
           mavenCentral()
      }  
   }  
```
**Step 2: Add dependency**
In the application  `build.gradle`  file, add the dependency to [latest version of library](https://mvnrepository.com/artifact/com.appsflyer/appsflyer-url-resolver):
```groovy  
   dependencies {  
      implementation 'com.appsflyer:appsflyer-url-resolver:1.0.0'
   }  
```
 ### <a id="iOSInstallation"> iOS  
 #### <u>Swift Package Manger (SPM)</u>
 **Step 1: Navigate to Add Package Dependency**  
In Xcode, go to **File** > **Add Packages** 

**Step 2: Add iOS SDK GitHub repository**  
Enter the AppsFlyer SDK GitHub repository:  
`https://github.com/AppsFlyerSDK/AppsFlyerURLResolver.git`

**Step 3: Select SDK version**

**Step 4: Add AppsFlyerURLResolver to desired Target**
 
 #### <u>Cocoapods</u>
 **Step 1: Download CocoaPods**  
[Download and install](https://guides.cocoapods.org/using/getting-started.html#installation)  the latest version of CocoaPods.

**Step 2: Add dependencies**  
Add the  [latest version of  `AppsFlyerURLResolver`](https://github.com/AppsFlyerSDK/AppsFlyerURLResolver/releases/latest)  to your project's Podfile:

```
pod 'AppsFlyerURLResolver'
```

**Step 3: Install dependencies**  
In your terminal, navigate to your project's root folder and run  `pod install`.

**Step 4: Open Xcode workspace**  
In Xcode, use the  `.xcworkspace`  file to open the project from this point forward, instead of the  `.xcodeproj`  file.

 #### <u>Carthage</u>
**Step 1: Install Carthage**  
[Install](https://github.com/Carthage/Carthage#installing-carthage)  the latest version of Carthage.

**Step 2: Add dependencies**  
Add the following line to your  `Cartfile` :
```
github "AppsFlyerSDK/AppsFlyerURLResolver" ~> 1.0.0
```
## <a id="API">API
### <a id="AndroidAPI">Android

### `resolve`
**Method signature**
```kotlin
fun resolve(url: String?,maxRedirections: Int = 10, urlResolverListener: URLResolverListener): String?
```
**Description**
Resolve a given URL. 
This function will perform redirects until it gets to the final URL or up to the maximum redirects. The function will return the last URL address.
* `null` URL will return `null`. 
* An invalid URL will return the original input (passed in the `url` parameter).

**Input arguments**
|Type|Name|Description|
|--|--|--|
|String?|url|The URL to resolve|
|Int|maxRedirections|The maximum redirections to relove. The default value is 10 Redirections|
|URLResolverListener|urlResolverListener|The listener for the output of the URL resolving


**Example**
```kotlin
  override fun onDeepLinking(deepLinkResult: DeepLinkResult) {
        if (deepLinkResult.status == DeepLinkResult.Status.FOUND) {
            URLResolver().resolve(deepLinkResult.deepLink?.deepLinkValue, 5, object : URLResolverListener {
            override fun onComplete(url: String?) {
            	Log.d(TAG, "final URL: $url")
            }
        })
        }
    }
```

### <a id="iOSAPI">iOS
### `resolve`
**Method signature**
```swift
resolve(url: String?, maxRedirections: Int  =  10 , completionHandler: @escaping (String?) ->  Void)
```
**Description**
Resolve a given URL. 
This function will perform redirects until to final URL or up to the maximum redirects. The function will return the last URL address using the completion handler.
* `nil` URL will return `nil`. 
* Not a vailid URL will return the input to the function (`url` parameter).

**Input arguments**
|Type|Name|Description|
|--|--|--|
|String?|url|The URL to resolve|
|Int|maxRedirections|The maximum redirections to relove. The default value is 10 Redirections|
|@escaping (String?) ->  Void|completionHandler|Completion handler that will return the result as a optional string| 


**Example**
```swift
  // add this import
 import AppsFlyerURLResolver
    
 func didResolveDeepLink(_ result: DeepLinkResult) {
        if result.status == .found{
            URLResolver().resolve(url: result.deepLink?.deeplinkValue, maxRedirections: 9){ res in
                print("The URL is: \(res ?? "nil")")
            }
        }
    }
```

### `resolveJSRedirection`
**Method signature**
```swift
resolveJSRedirection(url: String?, completionHandler :  @escaping (String?) -> Void)
```
**Description**<br>
Some esp's return a JS code which redirect to the real link according to the platform. This api extract the link from the JS code and returns it to the `completion handler` for forther redirections.
* `nil` URL will return `nil`. 
* Not a vailid URL will return the input to the function (`url` parameter).

**Input arguments**
|Type|Name|Description|
|--|--|--|
|String?|url|The URL to resolve|
|@escaping (String?) ->  Void|completionHandler|Completion handler that will return the result as a optional string| 


**Example**
```swift
  // add this import
 import AppsFlyerURLResolver
    
URLResolver().resolveJSRedirection(url: "my-esp-url"){ res in
    print("The URL is: \(res ?? "nil")")
}
```
## <a id="Debug"> Debug  
The logs are disabled by default. 
You can enable the debugging logs by adding `true`  as the argument for the URLResolver() constructor.

### Android
```Kotlin
URLResolver(true)
```

### iOS
```swift
URLResolver(isDebug: true)
```


## <a id="Support"> Support 

🛠 In order for us to provide optimal support, we would kindly ask you to submit any issues to support@appsflyer.com

*When submitting an issue please specify your AppsFlyer sign-up (account) email , your app ID , production steps, logs, code snippets and any additional relevant information.*
