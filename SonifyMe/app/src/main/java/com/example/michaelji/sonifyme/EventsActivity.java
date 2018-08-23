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

        String dur = "2";
        switch (selected)
        {
            case 0: {
                locate = 0;
                day = 1496361600;
            }
            case 1: {

            }
            case 2: {

            }
            case 3: {

            }
            case 4: {

            }
            case 5: {

            }
            default: {

            }
        }

        Intent intent = new Intent(EventsActivity.this, InputActivity.class);
        startActivity(intent);
    }
}
