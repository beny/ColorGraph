//
//  OBAppDelegate.h
//  ColorGraph
//
//  Created by Ondra Beneš on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OBAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window, *progressWindow, *resultWindow;
@property (assign) IBOutlet NSProgressIndicator *progress;
@property (assign) IBOutlet NSTextField *fitnessLabel;
@property (assign) IBOutlet NSTextField *progressLabel;
@property (assign) IBOutlet NSTextField *fitnessResult;

@property (readwrite) NSInteger populationSize;
@property (readwrite) NSInteger generations;
@property (readwrite) NSInteger bestIndividuals;

- (IBAction)runEvolution:(id)sender;
- (IBAction)stopEvolution:(id)sender;
- (IBAction)dismissResults:(id)sender;
- (void) showResultForFitness:(NSUInteger)fitness;

@end
