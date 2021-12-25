//
// Created by cyc on 2021/12/20.
//

#include <jni.h>
#include <string>
#include <hilog/log.h>

extern "C"
JNIEXPORT jstring JNICALL Java_ml_nn2ai_ohosndk_slice_MainAbilitySlice_stringFromRust(JNIEnv* env, jobject  obj);

extern "C"
JNIEXPORT jstring JNICALL
Java_ml_nn2ai_ohosndk_slice_MainAbilitySlice_stringFromJNI(JNIEnv* env, jobject obj) {
    return Java_ml_nn2ai_ohosndk_slice_MainAbilitySlice_stringFromRust(env, obj);
}
