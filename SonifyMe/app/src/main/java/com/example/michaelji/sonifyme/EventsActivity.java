package com.example.michaelji.sonifyme;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CalendarView;
import android.widget.EditText;
import android.widget.Spinner;

import java.util.Calendar;

public class EventsActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_events);

        Spinner spinner = (Spinner) findViewById(R.id.spinner2);
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

        long day = Calendar.getInstance().getTimeInMillis();

        String time = "00:00";

        String dur = "4";
        switch (selected)
        {
            case 0: {
                day = 1496361600;
                break;
            }
            case 1: {
                day = 1478476800;
                time = "01:00";
                break;
            }
            case 2: {
                day = 1499299200;
                time = "06:00";
                break;
            }
            case 3: {
                day = 1525392000;
                time = "22:00";
                break;
            }
            case 4: {
                day = 1531008000;
                time = "16:00";
                break;
            }
            case 5: {
                day = 1532390400;
                time = "13:00";
                break;
            }
            default: {

            }
        }

        Intent intent = new Intent(EventsActivity.this, InputActivity.class);
        intent.putExtra("location", locate);
        intent.putExtra("time", time);
        intent.putExtra("date", day);
        intent.putExtra("duration", dur);
        startActivity(intent);
    }
}
