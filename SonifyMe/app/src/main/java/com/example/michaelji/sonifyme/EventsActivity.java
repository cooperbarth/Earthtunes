package com.example.michaelji.sonifyme;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Spinner;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class EventsActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setTheme(R.style.AppTheme);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_events);

        Spinner spinner = findViewById(R.id.spinner2);
        // Create an ArrayAdapter using the string array and a default spinner layout
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(this,
                R.array.events_array, android.R.layout.simple_spinner_item);
        // Specify the layout to use when the list of choices appears
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        // Apply the adapter to the spinner
        spinner.setAdapter(adapter);
    }

    public void setSelected(View v)
    {
        Spinner spinner = findViewById(R.id.spinner2);
        int selected = spinner.getSelectedItemPosition();

        int locate = 0;

        String day = "01 01 2001";

        String time = "00:00";

        String dur = "4";
        switch (selected)
        {
            case 0: {
                day = "06 02 2017";
                break;
            }
            case 1: {
                day = "11 07 2016";
                time = "01:00";
                break;
            }
            case 2: {
                day = "07 06 2017";
                time = "06:00";
                break;
            }
            case 3: {
                day = "05 04 2018";
                time = "22:00";
                break;
            }
            case 4: {
                day = "07 08 2018";
                time = "16:00";
                break;
            }
            case 5: {
                day = "07 24 2018";
                time = "13:00";
                break;
            }
            default: {

            }
        }

        SimpleDateFormat df = new SimpleDateFormat("MM dd yyyy");
        Date date = null;
        try{
            date = df.parse(day);
        }
        catch(Exception e)
        {
            e.printStackTrace();
        }
        long epoch = date.getTime();

        Intent intent = new Intent(EventsActivity.this, InputActivity.class);
        intent.putExtra("location", locate);
        intent.putExtra("time", time);
        intent.putExtra("date", epoch);
        intent.putExtra("duration", dur);
        startActivity(intent);
    }
}
