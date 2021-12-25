extern crate jni;

use jni::JNIEnv;
use jni::objects::JClass;
use jni::sys::jstring;

#[no_mangle]
#[allow(non_snake_case)]
pub extern "C" fn Java_ml_nn2ai_ohosndk_slice_MainAbilitySlice_stringFromRust(
    env: JNIEnv,
    _class: JClass
) -> jstring
{
    let s = String::from("Hello from Rust");
    // Then we have to create a new Java string to return. Again, more info
    // in the `strings` module.
    let output = env.new_string(&s).expect("Couldn't create java string!");

    // Finally, extract the raw pointer to return.
    output.into_inner()
}
