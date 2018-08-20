package com.example.michaelji.sonifyme;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.support.v4.app.DialogFragment;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.CalendarView;
import android.widget.EditText;
import android.widget.Spinner;

import java.io.BufferedInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;
import java.text.ParseException;
import java.util.Calendar;
import java.util.Date;
import java.text.SimpleDateFormat;

public class InputActivity extends AppCompatActivity {

    public final static String EXTRA_MESSAGE = "com.example.michaelji.sonifyme.MESSAGE";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_input);

        Spinner spinner = (Spinner) findViewById(R.id.spinner);
        // Create an ArrayAdapter using the string array and a default spinner layout
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(this,
                R.array.locations_array, android.R.layout.simple_spinner_item);
        // Specify the layout to use when the list of choices appears
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        // Apply the adapter to the spinner
        spinner.setAdapter(adapter);

        CalendarView calendar = (CalendarView) findViewById(R.id.calendarView2);
        calendar.setMaxDate(calendar.getDate());
        calendar.setOnDateChangeListener( new CalendarView.OnDateChangeListener() {
            public void onSelectedDayChange(CalendarView view, int year, int month, int dayOfMonth) {
                month++;
                String date = Integer.toString(month) + "/" + Integer.toString(dayOfMonth) + "/" + Integer.toString(year);
                long millis = 0;
                try{
                    millis = new SimpleDateFormat("MM/dd/yyyy").parse(date).getTime();
                }
                catch (ParseException e)
                {
                    return;
                }

                view.setDate(millis);
            }//met
        });
    }

    @Override
    protected void onStart()
    {
        super.onStart();
        Intent intent = getIntent();
        boolean errored = intent.getBooleanExtra(EXTRA_MESSAGE, false);
        if(errored)
        {
            errored = false;
            DownloadErrorDialogFragment error = new DownloadErrorDialogFragment();
            error.show(getSupportFragmentManager(),"error");
        }
    }

    /** Called when the user taps the Send button */
    public void sendMessage(View view) {
        Intent intent = new Intent(InputActivity.this, LoadingActivity.class);
        Intent malintent = new Intent( this, ErrorActivity.class);


        Spinner spinner = (Spinner) findViewById(R.id.spinner);
        String locate = (String) spinner.getSelectedItem();
        String duration = "-1";
        String time = "-1";

        EditText timeText = (EditText) findViewById(R.id.TimeText);
        time = timeText.getText().toString();
        EditText durationText = (EditText) findViewById(R.id.DurationText);
        duration = durationText.getText().toString();

        CalendarView calendar = (CalendarView) findViewById(R.id.calendarView2);
        long dateLong = calendar.getDate();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String date = sdf.format(new Date(dateLong));

        if(time.equals("") || duration.equals("")) {
            InputErrorDialogFragment error = new InputErrorDialogFragment();
            error.show(getSupportFragmentManager(),"error");
            //startActivity(malintent);
        } else {
            String[] url = getUrl(locate, duration, time, date);

            new DownloadFile().execute(url[0] + "audio");
            new DownloadImage().execute(url[0] + "plot");

            intent.putExtra(EXTRA_MESSAGE, locate);
            startActivity(intent);
        }
    }

    public void toDisplay ()
    {
        Intent intent = new Intent(InputActivity.this, DisplayActivity.class);

        Spinner spinner = (Spinner) findViewById(R.id.spinner);
        String locate = (String) spinner.getSelectedItem();

        intent.putExtra(EXTRA_MESSAGE, locate);
        startActivity(intent);
    }

    public static class InputErrorDialogFragment extends DialogFragment {
        @Override
        public Dialog onCreateDialog(Bundle savedInstanceState) {
            // Use the Builder class for convenient dialog construction
            AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
            builder.setTitle("Input error");
            builder.setMessage("You are missing inputs.")
                    .setNeutralButton("Close", new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            dismiss();
                        }
                    });
            // Create the AlertDialog object and return it
            return builder.create();
        }
    }

    public static class DownloadErrorDialogFragment extends DialogFragment {
        @Override
        public Dialog onCreateDialog(Bundle savedInstanceState) {
            // Use the Builder class for convenient dialog construction
            AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
            builder.setTitle("ERROR 404");
            builder.setMessage("The data could not be found. It may be unavailable due to station downtime or issues. Check your inputs")
                    .setNeutralButton("Close", new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            dismiss();
                        }
                    });
            // Create the AlertDialog object and return it
            return builder.create();
        }
    }

    public String[] getUrl(String loc, String dur, String time, String date)
    {
        int duration = Integer.parseInt(dur);
        duration *= 3600;
        dur = Integer.toString(duration);

        time = time + ":00";

        String soundname, station, net, location, channel;
        switch (loc) {
            case "Ryerson (IL,USA)": {
                soundname = "ryerson";
                station = "L44A";
                net = "TA";
                location = "--";
                channel = "BHZ";
                break;
            }
            case "Yellowstone (WY,USA)": {
                soundname = "yellowstone";
                station = "H17A";
                net = "TA";
                location = "--";
                channel = "BHZ";
                break;
            }
            case "Antarctica": {
                soundname = "antarctica";
                station = "BELA";
                net = "AI";
                location = "04";
                channel = "BHZ";
                break;
            }
            case "Cachiyuyo, Chile": {
                soundname = "chile";
                station = "LCO";
                net = "IU";
                location = "10";
                channel = "BHZ";
                break;
            }
            case "Anchorage (AK,USA)": {
                soundname = "alaska";
                station = "SSN";
                net = "AK";
                location = "--";
                channel = "BHZ";
                break;
            }
            case "Kyoto, Japan": {
                soundname = "japan";
                station = "JWT";
                net = "JP";
                location = "--";
                channel = "BHZ";
                break;
            }
            case "London, UK": {
                soundname = "london";
                station = "HMNX";
                net = "GB";
                location = "--";
                channel = "BHZ";
                break;
            }
            case "Ar Rayn, Saudi Arabia": {
                soundname = "saudiarabia";
                station = "RAYN";
                net = "II";
                location = "10";
                channel = "BHZ";
                break;
            }
            case "Addis Ababa, Ethiopia": {
                soundname = "ethiopia";
                station = "FURI";
                net = "IU";
                location = "00";
                channel = "BHZ";
                break;
            }
            default: {
                soundname = "ryerson";
                station = "L44A";
                net = "TA";
                location = "--";
                channel = "BHZ";
            }

        }
        String type = net + "&sta=" + station + "&loc=" + location + "&cha=" + channel;
        String when = "&starttime=" + date + "T" + time + "&duration=" + dur;
        String[] out = {"http://service.iris.edu/irisws/timeseries/1/query?net=" + type + when + "&demean=true&scale=auto&output=", soundname};
        return out;
    }

    public class DownloadFile extends AsyncTask<String, Integer, String> {
        @Override
        protected String doInBackground(String... file) {
            int count;
            try {
                URL url = new URL(file[0]);
                URLConnection conexion = url.openConnection();
                conexion.connect();
                // this will be useful so that you can show a tipical 0-100% progress bar
                int lenghtOfFile = conexion.getContentLength();

                // downlod the file
                InputStream input = new BufferedInputStream(url.openStream());
                OutputStream output;
                output = new FileOutputStream(getApplicationContext().getFilesDir().getPath() + "/" + "sound.wav");
                //Environment.getExternalStorageDirectory().getPath() + "/ryerson.wav");


                //output = new FileOutputStream(getApplicationContext().getFilesDir().getPath() + "/" + file[1] + ".png");

                byte data[] = new byte[1024];

                long total = 0;

                while ((count = input.read(data)) != -1) {
                    total += count;
                    // publishing the progress....
                    publishProgress((int) (total * 100 / lenghtOfFile));
                    output.write(data, 0, count);
                }

                output.flush();
                output.close();
                input.close();
            } catch (Exception e) {
                System.out.println(e.getMessage());
            }
            return null;
        }

    }

    public void saveImage(Context context, Bitmap b, String imageName) {
        FileOutputStream foStream;
        try {
            foStream = context.openFileOutput(imageName, Context.MODE_PRIVATE);
            b.compress(Bitmap.CompressFormat.PNG, 100, foStream);
            foStream.close();
        } catch (Exception e) {
            Log.d("saveImage", "Exception 2, Something went wrong!");
            e.printStackTrace();
        }
    }

    private class DownloadImage extends AsyncTask<String, Void, Bitmap> {
        private String TAG = "DownloadImage";
        private boolean errored = false;
        private Bitmap downloadImageBitmap(String sUrl) {
            Bitmap bitmap = null;
            try {
                InputStream inputStream = new URL(sUrl).openStream();   // Download Image from URL
                bitmap = BitmapFactory.decodeStream(inputStream);       // Decode Bitmap
                inputStream.close();
            } catch (Exception e) {
                errored = true;
                Log.d(TAG, "Exception 1, Something went wrong!");
                e.printStackTrace();
            }
            return bitmap;
        }

        @Override
        protected Bitmap doInBackground(String... params) {
            return downloadImageBitmap(params[0]);
        }

        protected void onPostExecute(Bitmap result) {
            if(errored)
            {
                Intent intent = new Intent(InputActivity.this, InputActivity.class);
                intent.putExtra(EXTRA_MESSAGE, true);
                startActivity(intent);
            } else {
                saveImage(getApplicationContext(), result, "graph.png");
                toDisplay();
            }
        }
    }
}


