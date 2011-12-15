//
//  Twister.h
//  ColoringGraph
//
//  Created by Ondra Beneš on 11/28/11.
//  Copyright (c) 2011 FIT VUTBR. All rights reserved.
//

#import <Foundation/Foundation.h>
#define lengthMersenneTwister 624

@interface Twister : NSObject {
	unsigned mersenneTwister[lengthMersenneTwister]; /* the array for the state vector  */
	unsigned generationCounter;
}

-(BOOL)initializeGenerator:(NSUInteger)seed;
-(BOOL)regenerateMersenneTwister;
-(NSArray *)mersenneTwister;
-(NSNumber *)generation;
-(BOOL)setMersenneTwister:(NSArray *)seed generation:(NSNumber *)generation;
-(BOOL)randomBOOLValue;
-(NSUInteger)randomUnsignedIntValue;
-(int)randomIntValue;
-(int)randomIntValueBetweenStart:(int)start andStop:(int)stop;
-(double)randomDoubleValue;
-(double)randomDoubleValueBetweenStart:(double)start andStop:(double)stop;
-(NSNumber *)randomBOOLNumber;
-(NSNumber *)randomUnsignedIntNumberStart:(unsigned)start andStop:(unsigned)stop;
-(NSNumber *)randomIntNumber;
-(NSNumber *)randomIntNumberBetweenStart:(int)start andStop:(int)stop;
-(NSNumber *)randomDoubleNumber;
-(NSNumber *)randomDoubleNumberBetweenStart:(double)start andStop:(double)stop;
-(void)printSizeOfPrimitiveTypes;
-(void)testAlpha;
-(void)testBeta;
-(void)testGamma;
-(void)runTests;
@end
