//
//  OBAppDelegate.m
//  ColorGraph
//
//  Created by Ondra Beneš on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OBAppDelegate.h"
#import "OBEvolution.h"

@implementation OBAppDelegate

@synthesize window = _window;
@synthesize progressWindow, progress;
@synthesize populationSize, generations, bestIndividuals;
@synthesize fitnessLabel;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	self.generations = 500;
	self.populationSize = 100;
	self.bestIndividuals = 50;
}

- (IBAction)runEvolution:(id)sender {
//	[NSApp beginSheet:progressWindow modalForWindow:_window modalDelegate:self didEndSelector:nil contextInfo:nil];
	
	OBEvolution *evolution = [[[OBEvolution alloc] init] autorelease];
	evolution.progressIndicator = self.progress;
	evolution.generations = self.generations;
	evolution.populationSize = self.populationSize;
	evolution.bestIndividuals = self.bestIndividuals;
	evolution.bestFitness = self.fitnessLabel;
	[evolution runEvolution];
}

- (IBAction)stopEvolution:(id)sender {
	
	[NSApp endSheet:progressWindow returnCode:0];
	[progressWindow orderOut:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (void)dealloc {
    [super dealloc];
}

@end
