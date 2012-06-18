//
//  FlickrImage.h
//  FlickrPlaces
//
//  Created by ace on 13/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrService.h"

@interface FlickrImage : UIImage

+(UIImage*) imageForPhoto:(NSDictionary *)photo format:(FlickrPhotoFormat)format;

@end
