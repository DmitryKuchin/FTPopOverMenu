//
//  FTPopOverMenu.m
//  FTPopOverMenu
//
//  Created by liufengting on 16/4/5.
//  Copyright © 2016年 liufengting ( https://github.com/liufengting ). All rights reserved.
//

#import "FTPopOverMenu.h"

// changeable
#define FTDefaultMargin                     4.f
#define FTDefaultMenuTextMargin             6.f
#define FTDefaultMenuIconMargin             6.f
#define FTDefaultMenuCornerRadius           5.f
#define FTDefaultAnimationDuration          0.2
#define FTDefaultBackgroundColor            [UIColor clearColor]
#define FTDefaultTintColor                  [UIColor colorWithRed:80/255.f green:80/255.f blue:80/255.f alpha:1.f]
#define FTDefaultTextColor                  [UIColor whiteColor]
#define FTDefaultSelectedTextColor          [UIColor redColor]
#define FTDefaultCellSelectedBackgroundColor    [UIColor grayColor]
#define FTDefaultSeparatorColor             [UIColor grayColor]
#define FTDefaultMenuFont                   [UIFont systemFontOfSize:14.f]
#define FTDefaultMenuWidth                  120.f
#define FTDefaultMenuIconSize               24.f
#define FTDefaultMenuRowHeight              40.f
#define FTDefaultMenuBorderWidth            0.8
#define FTDefaultMenuArrowWidth             8.f
#define FTDefaultMenuArrowHeight            10.f
#define FTDefaultMenuArrowWidth_R           12.f
#define FTDefaultMenuArrowHeight_R          12.f
#define FTDefaultMenuArrowRoundRadius       4.f
#define FTDefaultShadowColor                [UIColor blackColor]
#define FTDefaultShadowRadius               5.f
#define FTDefaultShadowOpacity              0.f
#define FTDefaultShadowOffsetX              0.f
#define FTDefaultShadowOffsetY              2.f


static NSString  *const FTPopOverMenuTableViewCellIndentifier = @"FTPopOverMenuTableViewCellIndentifier";
static NSString  *const FTPopOverMenuImageCacheDirectory = @"com.FTPopOverMenuImageCache";
/**
 *  FTPopOverMenuArrowDirection
 */
typedef NS_ENUM(NSUInteger, FTPopOverMenuArrowDirection) {
    /**
     *  Up
     */
    FTPopOverMenuArrowDirectionUp,
    /**
     *  Down
     */
    FTPopOverMenuArrowDirectionDown,
};

#pragma mark - FTPopOverMenuModel

@implementation FTPopOverMenuModel

- (instancetype)initWithTitle:(NSString *)title image:(id)image selected:(BOOL)selected {
    self = [super init];
    if (self) {
        self.title = title;
        self.image = image;
        self.selected = selected;
    }
    return self;
}

@end

#pragma mark - FTPopOverMenuConfiguration

@interface FTPopOverMenuConfiguration ()

@end

@implementation FTPopOverMenuConfiguration

+ (FTPopOverMenuConfiguration *)defaultConfiguration {
    FTPopOverMenuConfiguration *configuration = [[FTPopOverMenuConfiguration alloc] init];
    return configuration;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.menuRowHeight = FTDefaultMenuRowHeight;
        self.menuWidth = FTDefaultMenuWidth;
        self.menuCornerRadius = FTDefaultMenuCornerRadius;
        self.textColor = FTDefaultTextColor;
        self.textFont = FTDefaultMenuFont;
        self.backgroundColor = FTDefaultTintColor;
        self.borderColor = FTDefaultTintColor;
        self.borderWidth = FTDefaultMenuBorderWidth;
        self.textAlignment = NSTextAlignmentLeft;
        self.separatorInset = UIEdgeInsetsMake(0, FTDefaultMenuTextMargin, 0, FTDefaultMenuTextMargin);
        self.ignoreImageOriginalColor = NO;
        self.allowRoundedArrow = NO;
        self.menuTextMargin = FTDefaultMenuTextMargin;
        self.menuIconMargin = FTDefaultMenuIconMargin;
        self.animationDuration = FTDefaultAnimationDuration;
        self.selectedTextColor = FTDefaultSelectedTextColor;
        self.selectedCellBackgroundColor = FTDefaultCellSelectedBackgroundColor;
        self.separatorColor = FTDefaultSeparatorColor;
        self.shadowColor = FTDefaultShadowColor;
        self.shadowRadius = FTDefaultShadowRadius;
        self.shadowOpacity = FTDefaultShadowOpacity;
        self.shadowOffsetX = FTDefaultShadowOffsetX;
        self.shadowOffsetY = FTDefaultShadowOffsetY;
        self.coverBackgroundColor = FTDefaultBackgroundColor;
    }
    return self;
}

@end

#pragma mark - FTPopOverMenuCell

@interface FTPopOverMenuCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *menuNameLabel;

@end

@implementation FTPopOverMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                     menuName:(NSString *)menuName
                    menuImage:(id)menuImage
                     selected:(BOOL)selected
                configuration:(FTPopOverMenuConfiguration *)configuration {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self setupWithMenuName:menuName menuImage:menuImage selected:selected configuration:configuration];
    }
    return self;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _iconImageView.backgroundColor = [UIColor clearColor];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImageView;
}

- (UILabel *)menuNameLabel {
    if (!_menuNameLabel) {
        _menuNameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _menuNameLabel.backgroundColor = [UIColor clearColor];
    }
    return _menuNameLabel;
}

- (void)setupWithMenuName:(NSString *)menuName menuImage:(id)menuImage selected:(BOOL)selected configuration:(FTPopOverMenuConfiguration *)configuration {
    CGFloat margin = (configuration.menuRowHeight - FTDefaultMenuIconSize)/2.f;
    CGRect iconImageRect = CGRectMake(configuration.menuIconMargin, margin, FTDefaultMenuIconSize, FTDefaultMenuIconSize);
    CGFloat menuNameX = iconImageRect.origin.x + iconImageRect.size.width + configuration.menuTextMargin;
    CGRect menuNameRect = CGRectMake(menuNameX, 0, configuration.menuWidth - menuNameX - configuration.menuTextMargin, configuration.menuRowHeight);
    
    if (!menuImage) {
        menuNameRect = CGRectMake(configuration.menuTextMargin, 0, configuration.menuWidth - configuration.menuTextMargin*2, configuration.menuRowHeight);
    }else{
        self.iconImageView.frame = iconImageRect;
        self.iconImageView.tintColor = configuration.textColor;
        
        [self getImageWithResource:menuImage
                        completion:^(UIImage *image) {
            if (configuration.ignoreImageOriginalColor) {
                image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.iconImageView.image = image;
            });
        }];
        [self.contentView addSubview:self.iconImageView];
    }
    self.menuNameLabel.frame = menuNameRect;
    self.menuNameLabel.font = configuration.textFont;
    self.menuNameLabel.textColor = configuration.textColor;
    self.menuNameLabel.textAlignment = configuration.textAlignment;
    self.menuNameLabel.text = menuName;
    [self.contentView addSubview:self.menuNameLabel];
    
    if (selected) {
        self.menuNameLabel.textColor = configuration.selectedTextColor;
        self.backgroundColor = configuration.selectedCellBackgroundColor;
    }
}

/**
 get image from local or remote
 
 @param resource image reource
 @param completion get image back
 */
- (void)getImageWithResource:(id)resource completion:(void (^)(UIImage *image))completion {
    if ([resource isKindOfClass:[UIImage class]]) {
        completion(resource);
    }else if ([resource isKindOfClass:[NSString class]]) {
        if ([resource hasPrefix:@"http"]) {
            [self downloadImageWithURL:[NSURL URLWithString:resource] completion:completion];
        }else{
            completion([UIImage imageNamed:resource]);
        }
    }else if ([resource isKindOfClass:[NSURL class]]) {
        [self downloadImageWithURL:resource completion:completion];
    }else{
        NSLog(@"Image resource not recougnized.");
        completion(nil);
    }
}

/**
 download image if needed, cache image into disk if needed.
 
 @param url imageURL
 @param completion get image back
 */
- (void)downloadImageWithURL:(NSURL *)url completion:(void (^)(UIImage *image))completion {
    if ([self isExitImageForImageURL:url]) {
        NSString *filePath = [self filePathForImageURL:url];
        completion([UIImage imageWithContentsOfFile:filePath]);
    }else{
        // download
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            if (image) {
                NSData *data = UIImagePNGRepresentation(image);
                [data writeToFile:[self filePathForImageURL:url] atomically:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(image);
                });
            }
        });
    }
}

/**
 return if the image is downloaded and cached before
 
 @param url imageURL
 @return if the image is downloaded and cached before
 */
- (BOOL)isExitImageForImageURL:(NSURL *)url {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self filePathForImageURL:url]];
}

/**
 get local disk cash filePath for imageurl
 
 @param url imageURL
 @return filePath
 */
- (NSString *)filePathForImageURL:(NSURL *)url {
    NSString *diskCachePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:FTPopOverMenuImageCacheDirectory];
    if(![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath]){
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:@{}
                                                        error:&error];
    }
    NSData *data = [url.absoluteString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *pathComponent = [data base64EncodedStringWithOptions:NSUTF8StringEncoding];
    NSString *filePath = [diskCachePath stringByAppendingPathComponent:pathComponent];
    return filePath;
}

@end



#pragma mark - FTPopOverMenuView

@interface FTPopOverMenuView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *menuTableView;
@property (nonatomic, strong) NSArray *menuStringArray;
@property (nonatomic, strong) NSArray *menuImageArray;
@property (nonatomic, assign) FTPopOverMenuArrowDirection arrowDirection;
@property (nonatomic, strong) FTPopOverMenuDoneBlock doneBlock;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, strong) FTPopOverMenuConfiguration *config;

@end

@implementation FTPopOverMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (FTPopOverMenuConfiguration *)config {
    if (!_config) {
        _config = [FTPopOverMenuConfiguration defaultConfiguration];
    }
    return _config;
}

- (UITableView *)menuTableView {
    if (!_menuTableView) {
        _menuTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _menuTableView.backgroundColor = FTDefaultBackgroundColor;
        _menuTableView.separatorColor = self.config.separatorColor;
        _menuTableView.layer.cornerRadius = FTDefaultMenuCornerRadius;
        _menuTableView.scrollEnabled = NO;
        _menuTableView.clipsToBounds = YES;
        _menuTableView.delegate = self;
        _menuTableView.dataSource = self;
        [self addSubview:_menuTableView];
    }
    return _menuTableView;
}

- (CGFloat)menuArrowWidth {
    return self.config.allowRoundedArrow ? FTDefaultMenuArrowWidth_R : FTDefaultMenuArrowWidth;
}

- (CGFloat)menuArrowHeight {
    return self.config.allowRoundedArrow ? FTDefaultMenuArrowHeight_R : FTDefaultMenuArrowHeight;
}

- (void)showWithFrame:(CGRect )frame
           anglePoint:(CGPoint )anglePoint
        withNameArray:(NSArray *)nameArray
       imageNameArray:(NSArray *)imageNameArray
     shouldAutoScroll:(BOOL)shouldAutoScroll
               config:(FTPopOverMenuConfiguration *)config
       arrowDirection:(FTPopOverMenuArrowDirection)arrowDirection
            doneBlock:(FTPopOverMenuDoneBlock)doneBlock {
    self.frame = frame;
    self.config = config ? config : [FTPopOverMenuConfiguration defaultConfiguration];
    _menuStringArray = nameArray;
    _menuImageArray = imageNameArray;
    _arrowDirection = arrowDirection;
    self.doneBlock = doneBlock;
    self.menuTableView.scrollEnabled = shouldAutoScroll;
    self.menuTableView.layer.cornerRadius = self.config.menuCornerRadius;
    
    CGRect menuRect = CGRectMake(0, self.menuArrowHeight, self.frame.size.width, self.frame.size.height - self.menuArrowHeight);
    if (_arrowDirection == FTPopOverMenuArrowDirectionDown) {
        menuRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - self.menuArrowHeight);
    }
    [self.menuTableView setFrame:menuRect];
    [self.menuTableView reloadData];
    
    [self drawBackgroundLayerWithAnglePoint:anglePoint];
}

- (void)drawBackgroundLayerWithAnglePoint:(CGPoint)anglePoint {
    if (_backgroundLayer) {
        [_backgroundLayer removeFromSuperlayer];
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    BOOL allowRoundedArrow = self.config.allowRoundedArrow;
    CGFloat offset = 2.f*FTDefaultMenuArrowRoundRadius*sinf(M_PI_4/2.f);
    CGFloat roundcenterHeight = offset + FTDefaultMenuArrowRoundRadius*sqrtf(2.f);
    CGPoint roundcenterPoint = CGPointMake(anglePoint.x, roundcenterHeight);
    CGFloat menuCornerRadius = self.config.menuCornerRadius;
    switch (_arrowDirection) {
        case FTPopOverMenuArrowDirectionUp:{
            
            if (allowRoundedArrow) {
                [path addArcWithCenter:CGPointMake(anglePoint.x + self.menuArrowWidth, self.menuArrowHeight - 2.f*FTDefaultMenuArrowRoundRadius) radius:2.f*FTDefaultMenuArrowRoundRadius startAngle:M_PI_2 endAngle:M_PI_4*3.f clockwise:YES];
                [path addLineToPoint:CGPointMake(anglePoint.x + FTDefaultMenuArrowRoundRadius/sqrtf(2.f), roundcenterPoint.y - FTDefaultMenuArrowRoundRadius/sqrtf(2.f))];
                [path addArcWithCenter:roundcenterPoint radius:FTDefaultMenuArrowRoundRadius startAngle:M_PI_4*7.f endAngle:M_PI_4*5.f clockwise:NO];
                [path addLineToPoint:CGPointMake(anglePoint.x - self.menuArrowWidth + (offset * (1.f+1.f/sqrtf(2.f))), self.menuArrowHeight - offset/sqrtf(2.f))];
                [path addArcWithCenter:CGPointMake(anglePoint.x - self.menuArrowWidth, self.menuArrowHeight - 2.f*FTDefaultMenuArrowRoundRadius) radius:2.f*FTDefaultMenuArrowRoundRadius startAngle:M_PI_4 endAngle:M_PI_2 clockwise:YES];
            } else {
                [path moveToPoint:CGPointMake(anglePoint.x + self.menuArrowWidth, self.menuArrowHeight)];
                [path addLineToPoint:anglePoint];
                [path addLineToPoint:CGPointMake( anglePoint.x - self.menuArrowWidth, self.menuArrowHeight)];
            }
            
            [path addLineToPoint:CGPointMake(menuCornerRadius, self.menuArrowHeight)];
            [path addArcWithCenter:CGPointMake(menuCornerRadius, self.menuArrowHeight + menuCornerRadius) radius:menuCornerRadius startAngle:-M_PI_2 endAngle:-M_PI clockwise:NO];
            [path addLineToPoint:CGPointMake( 0, self.bounds.size.height - menuCornerRadius)];
            [path addArcWithCenter:CGPointMake(menuCornerRadius, self.bounds.size.height - menuCornerRadius) radius:menuCornerRadius startAngle:M_PI endAngle:M_PI_2 clockwise:NO];
            [path addLineToPoint:CGPointMake( self.bounds.size.width - menuCornerRadius, self.bounds.size.height)];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - menuCornerRadius, self.bounds.size.height - menuCornerRadius) radius:menuCornerRadius startAngle:M_PI_2 endAngle:0 clockwise:NO];
            [path addLineToPoint:CGPointMake(self.bounds.size.width , menuCornerRadius + self.menuArrowHeight)];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - menuCornerRadius, menuCornerRadius + self.menuArrowHeight) radius:menuCornerRadius startAngle:0 endAngle:-M_PI_2 clockwise:NO];
            [path closePath];
            
        }break;
        case FTPopOverMenuArrowDirectionDown:{
            
            roundcenterPoint = CGPointMake(anglePoint.x, anglePoint.y - roundcenterHeight);
            
            if (allowRoundedArrow) {
                [path addArcWithCenter:CGPointMake(anglePoint.x + self.menuArrowWidth, anglePoint.y - self.menuArrowHeight + 2.f*FTDefaultMenuArrowRoundRadius) radius:2.f*FTDefaultMenuArrowRoundRadius startAngle:M_PI_2*3 endAngle:M_PI_4*5.f clockwise:NO];
                [path addLineToPoint:CGPointMake(anglePoint.x + FTDefaultMenuArrowRoundRadius/sqrtf(2.f), roundcenterPoint.y + FTDefaultMenuArrowRoundRadius/sqrtf(2.f))];
                [path addArcWithCenter:roundcenterPoint radius:FTDefaultMenuArrowRoundRadius startAngle:M_PI_4 endAngle:M_PI_4*3.f clockwise:YES];
                [path addLineToPoint:CGPointMake(anglePoint.x - self.menuArrowWidth + (offset * (1.f+1.f/sqrtf(2.f))), anglePoint.y - self.menuArrowHeight + offset/sqrtf(2.f))];
                [path addArcWithCenter:CGPointMake(anglePoint.x - self.menuArrowWidth, anglePoint.y - self.menuArrowHeight + 2.f*FTDefaultMenuArrowRoundRadius) radius:2.f*FTDefaultMenuArrowRoundRadius startAngle:M_PI_4*7 endAngle:M_PI_2*3 clockwise:NO];
            } else {
                [path moveToPoint:CGPointMake(anglePoint.x + self.menuArrowWidth, anglePoint.y - self.menuArrowHeight)];
                [path addLineToPoint:anglePoint];
                [path addLineToPoint:CGPointMake( anglePoint.x - self.menuArrowWidth, anglePoint.y - self.menuArrowHeight)];
            }
            
            [path addLineToPoint:CGPointMake( menuCornerRadius, anglePoint.y - self.menuArrowHeight)];
            [path addArcWithCenter:CGPointMake(menuCornerRadius, anglePoint.y - self.menuArrowHeight - menuCornerRadius) radius:menuCornerRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
            [path addLineToPoint:CGPointMake( 0, menuCornerRadius)];
            [path addArcWithCenter:CGPointMake(menuCornerRadius, menuCornerRadius) radius:menuCornerRadius startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
            [path addLineToPoint:CGPointMake( self.bounds.size.width - menuCornerRadius, 0)];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - menuCornerRadius, menuCornerRadius) radius:menuCornerRadius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
            [path addLineToPoint:CGPointMake(self.bounds.size.width , anglePoint.y - (menuCornerRadius + self.menuArrowHeight))];
            [path addArcWithCenter:CGPointMake(self.bounds.size.width - menuCornerRadius, anglePoint.y - (menuCornerRadius + self.menuArrowHeight)) radius:menuCornerRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
            [path closePath];
            
        }break;
        default:
            break;
    }
    
    _backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.path = path.CGPath;
    _backgroundLayer.lineWidth = self.config.borderWidth;
    _backgroundLayer.fillColor = self.config.backgroundColor.CGColor;
    _backgroundLayer.strokeColor = self.config.borderColor.CGColor;
    _backgroundLayer.shadowOpacity = self.config.shadowOpacity;
    _backgroundLayer.shadowColor = self.config.shadowColor.CGColor;
    _backgroundLayer.shadowRadius = self.config.shadowRadius;
    _backgroundLayer.shadowOffset = CGSizeMake(self.config.shadowOffsetX, self.config.shadowOffsetY);
    [self.layer insertSublayer:_backgroundLayer atIndex:0];
}


#pragma mark - UITableViewDelegate,UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.config.menuRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _menuStringArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id menuImage;
    BOOL selected = NO;
    if (_menuImageArray.count - 1 >= indexPath.row) {
        menuImage = _menuImageArray[indexPath.row];
    }
    NSString *title = [NSString string];
    id object = _menuStringArray[indexPath.row];
    if ([object isKindOfClass:[FTPopOverMenuModel class]]) {
        title = ((FTPopOverMenuModel *)object).title;
        menuImage = ((FTPopOverMenuModel *)object).image;
        selected = ((FTPopOverMenuModel *)object).selected;
    }else{
        title = [NSString stringWithFormat:@"%@", object];
    }
    
    FTPopOverMenuCell *menuCell = [[FTPopOverMenuCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                          reuseIdentifier:FTPopOverMenuTableViewCellIndentifier
                                                                 menuName:title
                                                                menuImage:menuImage
                                                                 selected:selected
                                                            configuration:self.config];
    if (indexPath.row == _menuStringArray.count-1) {
        menuCell.separatorInset = UIEdgeInsetsMake(0, self.bounds.size.width, 0, 0);
    }else{
        menuCell.separatorInset = self.config.separatorInset;
    }
    return menuCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id object = _menuStringArray[indexPath.row];
    if ([object isKindOfClass:[FTPopOverMenuModel class]]) {
        [_menuStringArray enumerateObjectsUsingBlock:^(FTPopOverMenuModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.selected = idx == indexPath.row;
        }];
        [self.menuTableView reloadData];
    }
    
    if (self.doneBlock) {
        self.doneBlock(indexPath.row);
    }
}

@end


#pragma mark - FTPopOverMenu

@interface FTPopOverMenu () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIWindow *callingWindow;

@property (nonatomic, strong) UIView * backgroundView;
@property (nonatomic, strong) FTPopOverMenuView *popMenuView;
@property (nonatomic, strong) FTPopOverMenuDoneBlock doneBlock;
@property (nonatomic, strong) FTPopOverMenuDismissBlock dismissBlock;

@property (nonatomic, strong) UIView *sender;
@property (nonatomic, assign) CGRect senderFrame;
@property (nonatomic, strong) NSArray<NSString*> *menuArray;
@property (nonatomic, strong) NSArray<NSString*> *menuImageArray;
@property (nonatomic, assign) BOOL isCurrentlyOnScreen;
@property (nonatomic, strong) FTPopOverMenuConfiguration *config;

@property (nonatomic, assign) CGFloat keyboardOffset;

@end

@implementation FTPopOverMenu

+ (FTPopOverMenu *)sharedInstance {
    static dispatch_once_t once = 0;
    static FTPopOverMenu *shared;
    dispatch_once(&once, ^{ shared = [[FTPopOverMenu alloc] init]; });
    return shared;
}

#pragma mark - Public Method

+ (void) showForSender:(UIView *)sender
              delegate:(id<FTPopOverMenuDelegate>)delegate
         withMenuArray:(NSArray *)menuArray
             doneBlock:(FTPopOverMenuDoneBlock)doneBlock
          dismissBlock:(FTPopOverMenuDismissBlock)dismissBlock {
    [[self sharedInstance] showForSender:sender delegate:delegate window:nil senderFrame:CGRectNull keyboardOffset:0.0 withMenu:menuArray imageNameArray:nil config:nil doneBlock:doneBlock dismissBlock:dismissBlock];
}

+ (void) showForSender:(UIView *)sender
              delegate:(id<FTPopOverMenuDelegate>)delegate
        keyboardOffset:(CGFloat)keyboardOffset
         withMenuArray:(NSArray *)menuArray
            imageArray:(NSArray *)imageArray
             doneBlock:(FTPopOverMenuDoneBlock)doneBlock
          dismissBlock:(FTPopOverMenuDismissBlock)dismissBlock {
    [[self sharedInstance] showForSender:sender delegate:delegate window:nil senderFrame:CGRectNull keyboardOffset:keyboardOffset withMenu:menuArray imageNameArray:imageArray config:nil doneBlock:doneBlock dismissBlock:dismissBlock];
}

+ (void) showForSender:(UIView *)sender
              delegate:(id<FTPopOverMenuDelegate>)delegate
        keyboardOffset:(CGFloat)keyboardOffset
         withMenuArray:(NSArray *)menuArray
            imageArray:(NSArray *)imageArray
         configuration:(FTPopOverMenuConfiguration *)configuration
             doneBlock:(FTPopOverMenuDoneBlock)doneBlock
          dismissBlock:(FTPopOverMenuDismissBlock)dismissBlock {
    [[self sharedInstance] showForSender:sender delegate:delegate window:nil senderFrame:CGRectNull keyboardOffset:keyboardOffset withMenu:menuArray imageNameArray:imageArray config:configuration doneBlock:doneBlock dismissBlock:dismissBlock];
}

+ (void) showFromEvent:(UIEvent *)event
              delegate:(id<FTPopOverMenuDelegate>)delegate
         withMenuArray:(NSArray *)menuArray
             doneBlock:(FTPopOverMenuDoneBlock)doneBlock
          dismissBlock:(FTPopOverMenuDismissBlock)dismissBlock {
    [[self sharedInstance] showForSender:[event.allTouches.anyObject view] delegate:delegate window:event.allTouches.anyObject.window senderFrame:CGRectNull keyboardOffset:0.0 withMenu:menuArray imageNameArray:nil config:nil doneBlock:doneBlock dismissBlock:dismissBlock];
}

+ (void) showFromEvent:(UIEvent *)event
              delegate:(id<FTPopOverMenuDelegate>)delegate
         withMenuArray:(NSArray *)menuArray
            imageArray:(NSArray *)imageArray
             doneBlock:(FTPopOverMenuDoneBlock)doneBlock
          dismissBlock:(FTPopOverMenuDismissBlock)dismissBlock {
    [[self sharedInstance] showForSender:[event.allTouches.anyObject view] delegate:delegate window:event.allTouches.anyObject.window senderFrame:CGRectNull keyboardOffset:0.0 withMenu:menuArray imageNameArray:imageArray config:nil doneBlock:doneBlock dismissBlock:dismissBlock];
}

+ (void) showFromEvent:(UIEvent *)event delegate:(id<FTPopOverMenuDelegate>)delegate
        keyboardOffset:(CGFloat)keyboardOffset
         withMenuArray:(NSArray *)menuArray
            imageArray:(NSArray *)imageArray
         configuration:(FTPopOverMenuConfiguration *)configuration
             doneBlock:(FTPopOverMenuDoneBlock)doneBlock
          dismissBlock:(FTPopOverMenuDismissBlock)dismissBlock {
    [[self sharedInstance] showForSender:[event.allTouches.anyObject view] delegate:delegate window:event.allTouches.anyObject.window senderFrame:CGRectNull keyboardOffset:keyboardOffset withMenu:menuArray imageNameArray:imageArray config:configuration doneBlock:doneBlock dismissBlock:dismissBlock];
}

+ (void) showFromSenderFrame:(CGRect )senderFrame
                    delegate:(id<FTPopOverMenuDelegate>)delegate
               withMenuArray:(NSArray *)menuArray
                   doneBlock:(FTPopOverMenuDoneBlock)doneBlock
                dismissBlock:(FTPopOverMenuDismissBlock)dismissBlock {
    [[self sharedInstance] showForSender:nil delegate:delegate window:nil senderFrame:senderFrame keyboardOffset:0.0 withMenu:menuArray imageNameArray:nil config:nil doneBlock:doneBlock dismissBlock:dismissBlock];
}

+ (void) showFromSenderFrame:(CGRect )senderFrame
                    delegate:(id<FTPopOverMenuDelegate>)delegate
               withMenuArray:(NSArray *)menuArray
                  imageArray:(NSArray *)imageArray
                   doneBlock:(FTPopOverMenuDoneBlock)doneBlock
                dismissBlock:(FTPopOverMenuDismissBlock)dismissBlock {
    [[self sharedInstance] showForSender:nil delegate:delegate window:nil senderFrame:senderFrame keyboardOffset:0.0 withMenu:menuArray imageNameArray:imageArray config:nil doneBlock:doneBlock dismissBlock:dismissBlock];
}

+ (void) showFromSenderFrame:(CGRect )senderFrame
                    delegate:(id<FTPopOverMenuDelegate>)delegate
              keyboardOffset:(CGFloat)keyboardOffset
               withMenuArray:(NSArray *)menuArray
                  imageArray:(NSArray *)imageArray
               configuration:(FTPopOverMenuConfiguration *)configuration
                   doneBlock:(FTPopOverMenuDoneBlock)doneBlock
                dismissBlock:(FTPopOverMenuDismissBlock)dismissBlock {
    [[self sharedInstance] showForSender:nil delegate:delegate window:nil senderFrame:senderFrame keyboardOffset:keyboardOffset withMenu:menuArray imageNameArray:imageArray config:configuration doneBlock:doneBlock dismissBlock:dismissBlock];
}

+(void)dismiss {
    [[self sharedInstance] dismiss];
}

#pragma mark - Private Methods

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onChangeStatusBarOrientationNotification:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

- (FTPopOverMenuConfiguration *)config {
    if (!_config) {
        _config = [FTPopOverMenuConfiguration defaultConfiguration];
    }
    return _config;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc ]initWithFrame:[UIScreen mainScreen].bounds];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackgroundViewTapped:)];
        tap.delegate = self;
        [_backgroundView addGestureRecognizer:tap];
        _backgroundView.backgroundColor = FTDefaultBackgroundColor;
    }
    return _backgroundView;
}

- (FTPopOverMenuView *)popMenuView {
    if (!_popMenuView) {
        _popMenuView = [[FTPopOverMenuView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _popMenuView.alpha = 0;
    }
    return _popMenuView;
}

- (CGFloat)menuArrowWidth {
    return self.config.allowRoundedArrow ? FTDefaultMenuArrowWidth_R : FTDefaultMenuArrowWidth;
}

- (CGFloat)menuArrowHeight {
    return self.config.allowRoundedArrow ? FTDefaultMenuArrowHeight_R : FTDefaultMenuArrowHeight;
}

- (CGFloat)widthScreen {
    return UIScreen.mainScreen.bounds.size.width;
}

- (CGFloat)heightScreen {
    return UIScreen.mainScreen.bounds.size.height - self.keyboardOffset;
}

- (void)onChangeStatusBarOrientationNotification:(NSNotification *)notification {
    if (self.isCurrentlyOnScreen) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self adjustPopOverMenu];
        });
    }
}

- (void) showForSender:(UIView *)sender
              delegate:(id<FTPopOverMenuDelegate>)delegate
                window:(UIWindow*)window
           senderFrame:(CGRect )senderFrame
        keyboardOffset:(CGFloat)keyboardOffset
              withMenu:(NSArray *)menuArray
        imageNameArray:(NSArray *)imageNameArray
                config:(FTPopOverMenuConfiguration *)config
             doneBlock:(FTPopOverMenuDoneBlock)doneBlock
          dismissBlock:(FTPopOverMenuDismissBlock)dismissBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.config = config ? config : [FTPopOverMenuConfiguration defaultConfiguration];
        self.callingWindow = window;
        self.delegate = delegate;
        [self.backgroundView addSubview:self.popMenuView];
        
        self.sender = sender;
        self.keyboardOffset = keyboardOffset;
        self.senderFrame = senderFrame;
        self.menuArray = menuArray;
        self.menuImageArray = imageNameArray;
        self.doneBlock = doneBlock;
        self.dismissBlock = dismissBlock;
        
        [self adjustPopOverMenu];
        if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(FTPopOverMenuDelegate)] && [self.delegate respondsToSelector:@selector(presentSetupMenu:)]) {
            [self.delegate presentSetupMenu:self.backgroundView];
        }
    });
}

- (void)adjustPopOverMenu {
    self.backgroundView.backgroundColor = self.config.coverBackgroundColor;
    [self.backgroundView setFrame:CGRectMake(0, 0, self.widthScreen, self.heightScreen)];
    
    CGRect senderRect ;
    
    if (self.sender) {
        senderRect = [self.sender.superview convertRect:self.sender.frame toView:self.backgroundView];
        // if run into touch problems on nav bar, use the fowllowing line.
        //        senderRect.origin.y = MAX(64-senderRect.origin.y, senderRect.origin.y);
    } else {
        senderRect = self.senderFrame;
    }
    if (senderRect.origin.y > self.heightScreen) {
        senderRect.origin.y = self.heightScreen;
    }
    
    CGFloat menuHeight = self.config.menuRowHeight * self.menuArray.count + self.menuArrowHeight;
    CGPoint menuArrowPoint = CGPointMake(senderRect.origin.x + (senderRect.size.width)/2, 0);
    CGFloat menuX = 0;
    CGRect menuRect = CGRectZero;
    BOOL shouldAutoScroll = NO;
    FTPopOverMenuArrowDirection arrowDirection;
    
    if (senderRect.origin.y + senderRect.size.height/2  < self.heightScreen/2) {
        arrowDirection = FTPopOverMenuArrowDirectionUp;
        menuArrowPoint.y = 0;
    }else{
        arrowDirection = FTPopOverMenuArrowDirectionDown;
        menuArrowPoint.y = menuHeight;
    }
    
    if (menuArrowPoint.x + self.config.menuWidth/2 + FTDefaultMargin > self.widthScreen) {
        menuArrowPoint.x = MIN(menuArrowPoint.x - (self.widthScreen - self.config.menuWidth - FTDefaultMargin), self.config.menuWidth - self.menuArrowWidth - FTDefaultMargin);
        menuX = self.widthScreen - self.config.menuWidth - FTDefaultMargin;
    }else if ( menuArrowPoint.x - self.config.menuWidth/2 - FTDefaultMargin < 0){
        menuArrowPoint.x = MAX( FTDefaultMenuCornerRadius + self.menuArrowWidth, menuArrowPoint.x - FTDefaultMargin);
        menuX = FTDefaultMargin;
    }else{
        menuArrowPoint.x = self.config.menuWidth/2;
        menuX = senderRect.origin.x + (senderRect.size.width)/2 - self.config.menuWidth/2;
    }
    
    if (arrowDirection == FTPopOverMenuArrowDirectionUp) {
        menuRect = CGRectMake(menuX, (senderRect.origin.y + senderRect.size.height), self.config.menuWidth, menuHeight);
        // if too long and is out of screen
        if (menuRect.origin.y + menuRect.size.height > self.heightScreen) {
            menuRect = CGRectMake(menuX, (senderRect.origin.y + senderRect.size.height), self.config.menuWidth, self.heightScreen - menuRect.origin.y - FTDefaultMargin);
            shouldAutoScroll = YES;
        }
    }else{
        
        menuRect = CGRectMake(menuX, (senderRect.origin.y - menuHeight), self.config.menuWidth, menuHeight);
        // if too long and is out of screen
        if (menuRect.origin.y  < 0) {
            menuRect = CGRectMake(menuX, FTDefaultMargin, self.config.menuWidth, senderRect.origin.y - FTDefaultMargin);
            menuArrowPoint.y = senderRect.origin.y;
            shouldAutoScroll = YES;
        }
    }
    
    [self prepareToShowWithMenuRect:menuRect
                     menuArrowPoint:menuArrowPoint
                   shouldAutoScroll:shouldAutoScroll
                     arrowDirection:arrowDirection];
    
    
    [self show];
}

- (void)prepareToShowWithMenuRect:(CGRect)menuRect menuArrowPoint:(CGPoint)menuArrowPoint shouldAutoScroll:(BOOL)shouldAutoScroll arrowDirection:(FTPopOverMenuArrowDirection)arrowDirection {
    CGPoint anchorPoint = CGPointMake(menuArrowPoint.x/menuRect.size.width, 0);
    if (arrowDirection == FTPopOverMenuArrowDirectionDown) {
        anchorPoint = CGPointMake(menuArrowPoint.x/menuRect.size.width, 1);
    }
    _popMenuView.transform = CGAffineTransformMakeScale(1, 1);
    
    [_popMenuView showWithFrame:menuRect
                     anglePoint:menuArrowPoint
                  withNameArray:self.menuArray
                 imageNameArray:self.menuImageArray
               shouldAutoScroll:shouldAutoScroll
                         config:self.config
                 arrowDirection:arrowDirection
                      doneBlock:^(NSInteger selectedIndex) {
        [self doneActionWithSelectedIndex:selectedIndex];
    }];
    
    [self setAnchorPoint:anchorPoint forView:_popMenuView];
    
    _popMenuView.transform = CGAffineTransformMakeScale(0.1, 0.1);
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x,
                                   view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
                                   view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:_popMenuView];
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }else if (CGRectContainsPoint(CGRectMake(0, 0, self.config.menuWidth, self.config.menuRowHeight), point)) {
        [self doneActionWithSelectedIndex:0];
        return NO;
    }
    return YES;
}

#pragma mark - onBackgroundViewTapped

- (void)onBackgroundViewTapped:(UIGestureRecognizer *)gesture {
    [self dismiss];
}

#pragma mark - show animation

- (void)show {
    self.isCurrentlyOnScreen = YES;
    [UIView animateWithDuration:FTDefaultAnimationDuration
                     animations:^{
        for (UIView *view in [self.backgroundView subviews]) {
            view.alpha = 1;
            view.transform = CGAffineTransformMakeScale(1, 1);
        }
    }];
}

#pragma mark - dismiss animation

- (void)dismiss {
    self.isCurrentlyOnScreen = NO;
    [self doneActionWithSelectedIndex:-1];
}

#pragma mark - doneActionWithSelectedIndex

- (void)doneActionWithSelectedIndex:(NSInteger)selectedIndex {
    [UIView animateWithDuration:FTDefaultAnimationDuration
                     animations:^{
        for (UIView *view in [self.backgroundView subviews]) {
            view.alpha = 0;
            view.transform = CGAffineTransformMakeScale(0.1, 0.1);
        }
    }completion:^(BOOL finished) {
        if (finished) {
            for (UIView *view in [self.backgroundView subviews]) {
                [view removeFromSuperview];
            }
            [self.backgroundView removeFromSuperview];
            if (selectedIndex < 0) {
                if (self.dismissBlock) {
                    self.dismissBlock();
                }
            }else{
                if (self.doneBlock) {
                    self.doneBlock(selectedIndex);
                }
            }
        }
    }];
}

@end
