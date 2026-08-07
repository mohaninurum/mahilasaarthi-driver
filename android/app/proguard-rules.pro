-dontwarn com.phonepe.phonepe_payment_sdk.PhonePePaymentSdk

# Play Console Optimization & Obfuscation Rules
# Allows R8 to change the access modifiers of classes and methods to enable more aggressive optimization/inlining
-allowaccessmodification

# Repackages all obfuscated classes into the root package, hiding your original folder/package structure
-repackageclasses ''
