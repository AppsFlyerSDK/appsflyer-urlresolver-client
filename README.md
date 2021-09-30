<img src="https://raw.githubusercontent.com/AppsFlyerSDK/appsflyer-capacitor-plugin/main/assets/AFLogo_primary.png"  width="600" >

# AppsFlyer URL Resolver

🛠 In order for us to provide optimal support, we would kindly ask you to submit any issues to support@appsflyer.com

*When submitting an issue please specify your AppsFlyer sign-up (account) email , your app ID , production steps, logs, code snippets and any additional relevant information.*

## Table of content
- [Description](#Description)
- [Installation](#Installation)
     - [Android Installation](#AndroidInstallation)
     - [iOS Installation](#iOSInstallation)
- [API](#API)
    - [Android API](#AndroidAPI)
    - [iOS API](#iOSAPI)
- [Debug](#Debug)

## <a id="Description"> Description  
write here description of the library

## <a id="Installation"> Installation  
 ### <a id="AndroidInstallation"> Android  
 Install the Android SDK using Gradle. <br>
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
In the application  `build.gradle`  file, add the  [latest Android SDK](https://mvnrepository.com/artifact/com.appsflyer/af-android-sdk)  package:
```groovy  
   dependencies {  
         implementation 'com.github.pazlavi:AppsFlyerResolver:0.0.1-V6'
   }  
```
<!---
Add it in your root build.gradle at the end of repositories:  
```groovy  
   allprojects {  
      repositories {  
         ...  
         maven { url 'https://jitpack.io' }  
      }  
   }  
```  
Add the dependency  
  
```groovy  
   dependencies {  
         implementation 'com.github.pazlavi:AppsFlyerResolver:0.0.1-V6'
   }  
```
-->
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

We're introducing two alternatives APIs to implement the URL resolving.
* `resolve` - Kotlin implementation that should be used inside a coroutine.
* `resolveSync` -  Java synchronized implementation.

### `resolve`
**Method signature**
```kotlin
suspend fun resolve(url: String?,maxRedirections: Int = 10): String?
```
**Description**
Resolve a given URL. 
This function will perform redirects until to final URL or up to the maximum redirects. The function will return the last URL address.
* Run this function only from a coroutine or another suspend function.
* `null` URL will return `null`. 
* Not a vailid URL will return the input to the function (`url` parameter).

**Input arguments**
|Type|Name|Description|
|--|--|--|
|String?|url|The URL to resolve|
|Int|maxRedirections|The maximum redirections to relove. The default value is 10 Redirections|

**Returns**
Optional String

**Example**
```kotlin
   override fun onDeepLinking(deepLinkResult: DeepLinkResult) {
        if (deepLinkResult.status == DeepLinkResult.Status.FOUND) {
            runBlocking(Dispatchers.IO) {
                val url = URLResolver().resolve(deepLinkResult.deepLink?.deepLinkValue)
                Log.d(TAG, "final URL: $url")
            }
        }
    }
```

### `resolveSync`
**Method signature**
```kotlin
fun resolveSync(url: String?,maxRedirections: Int = 10): String?
```
```java
public String resolveSync(String url, int maxRedirections);
```
 **Description**
Resolve a given URL. 
This function will perform redirects until to final URL or up to the maximum redirects. The function will return the last URL address.
* This is a synchronize function that will block your code.
* `null` URL will return `null`. 
* Not a vailid URL will return the input to the function (`url` parameter).

**Input arguments**
|Type|Name|Description|
|--|--|--|
|String?|url|The URL to resolve|
|Int|maxRedirections|The maximum redirections to relove. The default value is 10 Redirections |

**Returns**
Optional String

**Example**
```java
        @Override
        public void onDeepLinking(@NonNull DeepLinkResult deepLinkResult) {
            if (deepLinkResult.getStatus() == DeepLinkResult.Status.FOUND) {
                String url = new URLResolver().resolveSync(deepLinkResult.getDeepLink().getDeepLinkValue(), 8);
                Log.d(TAG, "final URL: " + url);

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
* `nil` URL will return `nill`. 
* Not a vailid URL will return the input to the function (`url` parameter).

**Input arguments**
|Type|Name|Description|
|--|--|--|
|String?|url|The URL to resolve|
|Int|maxRedirections|The maximum redirections to relove. The default value is 10 Redirections|
|@escaping (String?) ->  Void|completionHandler|Completion handler that will return the result as a optional string| 

**Returns**
Void

**Example**
```swift
 func didResolveDeepLink(_ result: DeepLinkResult) {
        if result.status == .found{
            URLResolver().resolve(url: result.deepLink?.deeplinkValue, maxRedirections: 9){ res in
                print("The URL is: \(res ?? "nil")")
            }
        }
    }
```

## <a id="Debug"> Debug  
You can enable the SDK logs by using the `setDebug` setter. 
* The logs are disabled by default.
* The setter returns the URLResolver instance.

### Android
```Kotlin
URLResolver().setDebug(true)
```

### iOS
```swift
URLResolver().setDebug(true)
```

