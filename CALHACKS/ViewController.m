//
//  ViewController.m
//  CALHACKS
//
//  Created by Kevin Frans on 10/9/15.
//  Copyright © 2015 Kevin Frans. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/CGImageProperties.h>
#import <MMX/MMX.h>
#import "ClarifaiClient.h"
#import <CoreLocation/CoreLocation.h>
#import <CloudSight/CloudSight.h>

static NSString * const kAppID = @"vM05qo55uhZard2dL4BixmMm4WsHIl6CsGCTgS_7";
static NSString * const kAppSecret = @"rx4oPPiXiCWNRVcoJ0huLz02cKiQUZtq5JPVrhjM";

@interface ViewController ()
@property (strong, nonatomic) ClarifaiClient *client;

@end

#define dWidth self.view.frame.size.width
#define dHeight self.view.frame.size.height

@implementation ViewController
{
    AVCaptureStillImageOutput* stillImageOutput;
    UIImageView* capturedView;
    UIButton* capture;
    UILabel* label;
    int count;
}

- (ClarifaiClient *)client {
    if (!_client) {
        _client = [[ClarifaiClient alloc] initWithAppID:kAppID appSecret:kAppSecret];
        // Uncomment this to request embeddings. Contact us to enable embeddings for your app:
        // _client.enableEmbed = YES;
    }
    return _client;
}

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetHigh;
    AVCaptureDevice *device = [self frontCamera];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [session addInput:input];
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    newCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    newCaptureVideoPreviewLayer.frame = CGRectMake(0, 0, dWidth, dHeight);
    //    newCaptureVideoPreviewLayer.la
    [self.view.layer addSublayer:newCaptureVideoPreviewLayer];
    [session startRunning];
    
    //    capturedView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, dWidth, dHeight)];
    //    //    capturedView.image = image;
    //    [self.view addSubview:capturedView];
    
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    [session addOutput:stillImageOutput];
    
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    
    count = 3;
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 500, dWidth, 100)];
    label.text = @"3";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:60];
    [self.view addSubview:label];
    
    
    

    // Do any additional setup after loading the view, typically from a nib.
}

-(void) tick:(NSTimer*)timer
{
    count = count - 1;
    label.text = [NSString stringWithFormat:@"%d",count];
    if(count == 0)
    {
        count = 10;
        [self capture];
    }
}


-(void) capture
{
    
    UIView* v = [[UIView alloc] initWithFrame: CGRectMake(0, 0, dWidth, dHeight)];
    [self.view addSubview: v];
    v.backgroundColor = [UIColor whiteColor];
    [UIView animateWithDuration:0.2 delay:0.0 options:
     UIViewAnimationOptionCurveEaseIn animations:^{
         v.backgroundColor = [UIColor clearColor];
     } completion:^ (BOOL completed) {
         [v removeFromSuperview];
     }];
    
    
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"snap"]+1 forKey:@"snap"];
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
        {
            break;
        }
    }
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments)
         {
             // Do something with the attachments.
             //             NSLog(@"attachements: %@", exifAttachments);
         } else {
             NSLog(@"no attachments");
         }
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
             
             NSData *imageData2 = UIImageJPEGRepresentation(image, 0.0);
             NSString *encodedString = [imageData2 base64Encoding];
         
//             NSLog(@"%d",encodedString.length);
         
             
//             encodedString = [encodedString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
         
             //         NSLog(encodedString);
             
//             NSString *post = [NSString stringWithFormat:@"encoded_data=%@",encodedString];
//             NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
         
         MMXUser *currentUser = [MMXUser currentUser];
//         NSLog(@"capturing %@",encodedString);
         
         [CloudSightConnection sharedInstance].consumerKey = @"w63eVgBk6UKS5zsK2ATaTA";
         [CloudSightConnection sharedInstance].consumerSecret = @"EM8y1gD50g-PaBNVudqxuA";
         
         CloudSightQuery *query = [[CloudSightQuery alloc] initWithImage:imageData2
                                                              atLocation:CGPointMake(image.size.width/2, image.size.height/2)
                                                            withDelegate:self
                                                             atPlacemark: nil
                                                            withDeviceId:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
         
         [query start];

         
         
         [self.client recognizeJpegs:@[imageData2] completion:^(NSArray *results, NSError *error) {
             // Handle the response from Clarifai. This happens asynchronously.
             if (error) {
                 NSLog(@"Error: %@", error);
                 NSLog(@"Sorry, there was an error recognizing the image.");
             } else {
                 ClarifaiResult *result = results.firstObject;
                 
                 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result.tags options:0 error:nil];
                 
                 NSLog([NSString stringWithFormat:@"Tags:\n%@",
                                       [result.tags componentsJoinedByString:@", "]]);
                 
                 [MMXChannel channelForName:@"life" isPublic:YES success:^(MMXChannel *channel) {
                     NSDictionary *messageContent = @{@"photo":encodedString,@"tags":[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]};
                     [channel publish:messageContent success:^(MMXMessage *message) {
                         NSLog(@"Successfully published to channel %@",channel.name);
                     } failure:^(NSError *error) {
                         NSLog(@"Error publishing to channel %@\nError = %@",channel.name,error);
                     }];
                     
                     
                 } failure:^(NSError *error) {
                     //Failure
                 }];

             }
//             self.button.enabled = YES;
         }];
         

         
     }];
}

- (void)cloudSightQueryDidFinishUploading:(CloudSightQuery *)query
{
    NSLog(@"uploaded");
}

- (void)cloudSightQueryDidFinishIdentifying:(CloudSightQuery *)query {
    if (query.skipReason != nil) {
        NSLog(@"Skipped: %@", query.skipReason);
    } else {
        NSLog(@"Identified: %@", query.title);
    }
}

- (void)cloudSightQueryDidFail:(CloudSightQuery *)query withError:(NSError *)error {
    NSLog(@"Error: %@", error);
}


-(void) sendRequest:(NSURLRequest*) request
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error)
         {
             NSLog(@"Error,%@", [error localizedDescription]);
         }
         else
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 //                 bg.backgroundColor = [UIColor blueColor];
                 NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
             });
         }
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
