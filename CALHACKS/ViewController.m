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

@interface ViewController ()

@end

#define dWidth self.view.frame.size.width
#define dHeight self.view.frame.size.height

@implementation ViewController
{
    AVCaptureStillImageOutput* stillImageOutput;
    UIImageView* capturedView;
    UIButton* capture;
    UILabel* label;
}

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetHigh;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
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
    
    
    [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(capture:) userInfo:nil repeats:YES];
    
    

    // Do any additional setup after loading the view, typically from a nib.
}


-(void) capture:(NSTimer*)timer
{
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
             
             NSLog(@"%d",encodedString.length);
             
             
             encodedString = [encodedString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             
             //         NSLog(encodedString);
             
             NSString *post = [NSString stringWithFormat:@"image=%@",encodedString];
             NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
         
         MMXUser *currentUser = [MMXUser currentUser];
         NSLog(@"capturing");
         
         [MMXChannel channelForName:@"life" isPublic:YES success:^(MMXChannel *channel) {
//             NSDictionary *messageContent = @{@"message":@"gax"};
//             [channel publish:messageContent success:^(MMXMessage *message) {
//                 NSLog(@"Successfully published to channel %@",channel.name);
//             } failure:^(NSError *error) {
//                 NSLog(@"Error publishing to channel %@\nError = %@",channel.name,error);
//             }];
             
             
             MMXChannel *sfGiantsChannel = channel;
             NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
             dateComponents.hour = -10;
             
             NSCalendar *theCalendar = [NSCalendar currentCalendar];
             NSDate *now = [NSDate date];
             NSDate *anHourAgo = [theCalendar dateByAddingComponents:dateComponents toDate:now options:0];
             
             [sfGiantsChannel messagesBetweenStartDate:anHourAgo
                                               endDate:now
                                                 limit:10
                                                offset:0
                                             ascending:NO
                                               success:^(int totalCount, NSArray *messages) {
                                                   for(int i = 0; i < messages.count; i++)
                                                   {
                                                       MMXMessage* m = messages[i];
                                                       NSLog(@"%@",[m.messageContent objectForKey:@"message"]);
                                                   }
                                               } failure:^(NSError *error) {
                                                   
                                               }];
             
         } failure:^(NSError *error) {
             //Failure
         }];

         
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
