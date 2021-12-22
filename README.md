# VirtualJoystick
 JoyStickView *joyStickView = [[JoyStickView alloc]initWithFrame:CGRectMake(100, 200, 124, 124)];
    joyStickView.delegate = self;
    [self.view addSubview:joyStickView];
    

- (void)rudderView:(JoyStickView *)rudder didUpdateDragLocation:(CGPoint)dragPoint{
    NSLog(@"x点坐标%.1f----y点坐标%.1f",dragPoint.x,dragPoint.y);
}
