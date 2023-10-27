/* Copyright 2018 ID R&D Inc. All Rights Reserved. */

/*!
 @header antispoof.h
 @brief Voice anti-spoofing result header file.
 */

#import <Foundation/Foundation.h>

__attribute__((visibility("default")))
/*!
 @deprecated Use LivenessResult returned by LivenessEngine API instead.
 @interface AntispoofResult

 @brief The AntispoofResult interface.
 An interface for a result of spoofing detection procedure.
 */
@interface AntispoofResult : NSObject

/*!
 @brief Human score.
 */
@property(nonatomic, assign) float score;

/*!
 @brief Replay attack score.
 */
@property(nonatomic, assign) float score_Replay;

/*!
 @brief Text-to-speech attack score.
 */
@property(nonatomic, assign) float score_TTS;

/*!
 @brief Voice conversion attack score.
 */
@property(nonatomic, assign) float score_VC;

/*!
 @brief Message that explains the reason for audio input to be unsuitable for spoof check.
 */
@property(strong, nonatomic, nonnull) NSString* unsuitableInputMessage;

- (NSString* _Nonnull)description;

@end
