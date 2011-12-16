//
//  OBAppDelegate.h
//  ColorGraph
//
//  Created by Ondra Beneš on 12/13/11.
//  Copyright (c) 2011 FIT VUTBR. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OBAppDelegate : NSObject <NSApplicationDelegate>

// GUI
@property (assign) IBOutlet NSWindow *window, *progressWindow, *resultWindow;
@property (assign) IBOutlet NSProgressIndicator *progress;
@property (assign) IBOutlet NSTextField *fitnessLabel;
@property (assign) IBOutlet NSTextField *progressLabel;
@property (assign) IBOutlet NSTextField *fitnessResult;

// evolution
@property (readwrite) NSInteger populationSize;
@property (readwrite) NSInteger generations;
@property (readwrite) NSInteger bestIndividuals;
@property (assign) float mutationProperty;
@property (assign) float mutationSwitch;

// file
@property (copy) NSString *filename;

// gui
- (IBAction)dismissResults:(id)sender;
- (void) showResultForFitness:(NSUInteger)fitness;

// file
- (IBAction)openFile:(id)sender;

// evolution
- (IBAction)runEvolution:(id)sender;
- (IBAction)stopEvolution:(id)sender;

@end
