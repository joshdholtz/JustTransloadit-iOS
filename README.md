# JustTransloadit for iOS

A simple implmentation for the Transloadit API

### Features
- Posting an assembly with a key, template id, data, and mime type
- Getting and polling completion on an assembly

### Dependencies
- [AFNetworking](https://github.com/AFNetworking/AFNetworking)

## Installation

### Drop-in Classes
Clone the repository and drop in the .h and .m files from the "Classes" directory into your project.

### CocoaPods
JustTransloadit-iOS is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod 'JustTransloadit-iOS', :git => 'https://github.com/joshdholtz/JustTransloadit-iOS.git'

## Examples

### POST Assembly

This example takes a template id, data, and mime type and posts it to the Transloadit API.

```objc
// Define your key and template id (this should probs get stored as a constants or something, ya know?)
NSString *key = @"<your-key>";
NSString *templateId = @"<your-template-id>";

// Create your data and mime type (we are using an image here)
NSData *imageData = UIImageJPEGRepresentation(self.imageToUpload, 0.6f);
NSString *mimeType = @"image/jpg";

// Create your TransloaditRequestOperation (its a subclass of AFHTTPRequestOperation) by passing in your awesome data from above
TransloaditRequestOperation *requestOperation = [TransloaditRequestOperation assemblyPOST:key withTemplateId:templateId withData:imageData withMimeType:mimeType];

// Set the upload progress block
[requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
    CGFloat progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    NSLog(@"Progress - %f", progress);
}];

// Set the completion blocks - cause this is what its all about
[requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"POST Success - %@", responseObject);
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"POST Error - %@", error);
}];

// Add the operation to the queue to get things going
[[NSOperationQueue mainQueue] addOperation:requestOperation];

NSLog(@"Started upload");

```

### GET Assembly

This example takes an assembly url (from an assembly that was already been posted) and polls it for 'ASSEMBLY_COMPLETED'.

```objc

// This should probably come from the POST assebly response
NSString *assemblyUrl = @"your-assembly-url";

// Poll for result
TransloaditRequestOperation *pollRequest = [TransloaditRequestOperation assemblyGET:assemblyUrl withPollInterval:5 withMaxTries:5];
[pollRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

    // Your assembly has been processed :)
    NSLog(@"POLL Success - %@", responseObject);
    
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"POLL Error - %@", error);
}];

// Add the operation to the queue to get things going
[[NSOperationQueue mainQueue] addOperation:pollRequest];

```

### POST Assembly and poll for completed

This example takes a template id, data, and mime type and posts it to the Transloadit API and then polls the assembly url for 'ASSEMBLY_COMPLETED'.

```objc
// Define your key and template id (this should probs get stored as a constants or something, ya know?)
NSString *key = @"<your-key>";
NSString *templateId = @"<your-template-id>";

// Create your data and mime type (we are using an image here)
NSData *imageData = UIImageJPEGRepresentation(self.imageToUpload, 0.6f);
NSString *mimeType = @"image/jpg";

// Create your TransloaditRequestOperation (its a subclass of AFHTTPRequestOperation) by passing in your awesome data from above
TransloaditRequestOperation *requestOperation = [TransloaditRequestOperation assemblyPOST:key withTemplateId:templateId withData:imageData withMimeType:mimeType withPollInterval:5 withMaxTries:5];

// Set the upload progress block
[requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
    CGFloat progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    NSLog(@"Progress - %f", progress);
}];

// Set the completion blocks - cause this is what its all about
[requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    
    // Your assembly and been posted and processed :)
    NSLog(@"POST Success - %@", responseObject);
    
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"POST Error - %@", error);
}];

// Add the operation to the queue to get things going
[[NSOperationQueue mainQueue] addOperation:requestOperation];f

```

## Author

Josh Holtz, me@joshholtz.com, [@joshdholtz](https://twitter.com/joshdholtz)

## License

JustTransloadit-iOS is available under the MIT license. See the LICENSE file for more info.

