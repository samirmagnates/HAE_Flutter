//package com.flutter.hea;
//
//import android.content.Intent;
//import android.os.Bundle;
//import android.os.Handler;
//import android.os.Looper;
//import android.widget.Toast;
//
//import androidx.annotation.Nullable;
//import androidx.appcompat.app.AppCompatActivity;
//
//public class SplashScreen extends AppCompatActivity {
//
//    @Override
//    protected void onCreate(@Nullable Bundle savedInstanceState) {
//        super.onCreate(savedInstanceState);
//        setContentView(R.layout.activity_splash);
//        //Toast.makeText(this, "This is Splash", Toast.LENGTH_SHORT).show();
//        try {
//            Thread.sleep(5000);
//        } catch (InterruptedException e) {
//            e.printStackTrace();
//        }
//        new Handler(Looper.getMainLooper()).postAtTime(
//                new Runnable() {
//                    @Override
//                    public void run() {
//                        Intent intent = new Intent(SplashScreen.this,MainActivity.class);
//                        startActivity(intent);
//                        finish();
//                    }
//                }, 5000);
//    }
//}
