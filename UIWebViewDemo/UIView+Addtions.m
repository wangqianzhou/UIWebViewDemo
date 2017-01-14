#import "UIView+Addtions.h"

@implementation UIView (Frame)

- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)setCenterX:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setMaxX:(CGFloat)maxX {
    CGRect frame = self.frame;
    frame.size.width = self.x + self.width;
    self.frame = frame;
}

- (CGFloat)maxX {
    return self.x + self.width;
}

- (void)setMaxY:(CGFloat)maxY {
    CGRect frame = self.frame;
    frame.size.width = self.y + self.height;
    self.frame = frame;
}

- (CGFloat)maxY {
    return self.y + self.height;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setTop:(CGFloat)top {
    self.frame = CGRectMake(self.x, top, self.width, self.height);
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setLeft:(CGFloat)left {
    self.frame = CGRectMake(self.x, self.y, self.width, self.height);
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setBottom:(CGFloat)bottom {
    self.frame = CGRectMake(self.x, bottom - self.y, self.width, self.height);
}

- (CGFloat)bottom {
    return  self.y + self.height;
}

- (void)setRight:(CGFloat)right {
    self.frame = CGRectMake(right - self.width, self.y, self.width, self.height);
}

- (CGFloat)right {
    return self.x + self.width;
}

@end
