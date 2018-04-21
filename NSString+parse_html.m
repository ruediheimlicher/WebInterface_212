//
//  NSString+parse_html.m
//  WebInterface
//
//  Created by Ruedi Heimlicher on 19.04.2018.
//

#import "NSString+parse_html.h"

@implementation NSString (parse_html)
- (NSString *)removeHTML {
   
   static NSRegularExpression *regexp;
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
      regexp = [NSRegularExpression regularExpressionWithPattern:@"<[^>]+>" options:kNilOptions error:nil];
   });
   
   return [regexp stringByReplacingMatchesInString:self
                                           options:kNilOptions
                                             range:NSMakeRange(0, self.length)
                                      withTemplate:@""];
}
@end
