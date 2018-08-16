package com.example.michaelji.sonifyme;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaPlayer;
import android.os.Handler;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;

import java.io.FileInputStream;

public class DisplayActivity extends AppCompatActivity {

    public static MediaPlayer mediaPlayer = new MediaPlayer();
    Handler seekHandler = new Handler();


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_display);

        // Get the Intent that started this activity and extract the string
        Intent intent = getIntent();
        String locate = intent.getStringExtra(InputActivity.EXTRA_MESSAGE);

        // Capture the layout's TextView and set the string as its text
        TextView textView = findViewById(R.id.textView);
        textView.setText(locate);

        String audioPath = getApplicationContext().getFilesDir().getPath() + "/"  + locate + ".wav";
        try {
            mediaPlayer.setDataSource(audioPath);
            mediaPlayer.prepare();
        } catch (Exception e) {
            e.printStackTrace();
        }

        ImageView im = findViewById(R.id.imageView);
        im.setImageBitmap(loadImageBitmap(getApplicationContext(), "graph.png"));

        SeekBar seek = findViewById(R.id.seekBar);
        seek.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            boolean wasPlaying = false;

            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if(fromUser)
                    mediaPlayer.seekTo(progress);
            }

            public void onStartTrackingTouch(SeekBar seekBar) {
                if(mediaPlayer.isPlaying()) {
                    wasPlaying = true;
                }
                mediaPlayer.pause();
                seekHandler.removeCallbacks(moveSeekBarThread);
            }

            public void onStopTrackingTouch(SeekBar seekBar) {
                if(wasPlaying) {
                    mediaPlayer.start();
                    seekHandler.postDelayed(moveSeekBarThread, 0); //cal the thread after 100 milliseconds
                    wasPlaying = false;
                }
            }
        });
        seek.setMax(mediaPlayer.getDuration());
        seek.setProgress(mediaPlayer.getCurrentPosition());

    }

    private Runnable moveSeekBarThread = new Runnable() {
        public void run() {
            if(mediaPlayer.isPlaying()){
                SeekBar seekbar = findViewById(R.id.seekBar);
                int mediaPos_new = mediaPlayer.getCurrentPosition();
                seekbar.setProgress(mediaPos_new);

                seekHandler.postDelayed(this, 100); //Looping the thread after 0.1 second
            }
            else if(mediaPlayer.getCurrentPosition()==mediaPlayer.getDuration())
            {
                SeekBar seekbar = findViewById(R.id.seekBar);
                seekbar.setProgress(seekbar.getMax());
            }

        }
    };

    public Bitmap loadImageBitmap(Context context, String imageName) {
        Bitmap bitmap = null;
        FileInputStream fiStream;
        try {
            fiStream    = context.openFileInput(imageName);
            bitmap      = BitmapFactory.decodeStream(fiStream);
            fiStream.close();
        } catch (Exception e) {
            Log.d("saveImage", "Exception 3, Something went wrong!");
            e.printStackTrace();
        }
        return bitmap;
    }

    public void playPause(View view) {
        if(mediaPlayer.isPlaying()){
            mediaPlayer.pause();
            seekHandler.removeCallbacks(moveSeekBarThread);
        } else {
            mediaPlayer.start();
            seekHandler.postDelayed(moveSeekBarThread, 0); //cal the thread after 100 milliseconds
        }
    }

    public void jumpForward(View view) {
        mediaPlayer.seekTo(mediaPlayer.getCurrentPosition() + 10000);
    }

    public void jumpBackward(View view) {
        mediaPlayer.seekTo(mediaPlayer.getCurrentPosition() - 10000);
    }
}
