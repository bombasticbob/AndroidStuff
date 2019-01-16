// MessageBox.java - Copyright 2019 by Stewart~Frazier Tools, Inc.
//
// You have permission to use this as you see fit provided you do not
// claim to be its author.
//
// This class implements a modified (3D) button.  You can use the
// class name in your layout, changing the name 'Button' in the
// xml to 'SkButton' (or the full class name, such as
// 'com.your.application.SkButton').
//
// The button will be drawn with a 3D border around it, which shifts
// from an 'outie' to an 'innie' when you click or tap on it, as long
// as the 'tap/click' state remains in effect.  It generally provides
// really good visual indication of the click or tap.
//
// And it's 3D Skeuomorphic, and *NOT* 2D FLATTY McFLATFACE FLATSO!!!
// (the 'Sk' in the name is for 'Skeuomorphic')
//
// The highlight and shadow colors are shades of grey of my choice.
// You might want to query themes and/or make them adjustable.
//


// modify this next line for your project, as needed
//package com.your.application;

// imports needed for this particular class.
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.support.v7.widget.AppCompatButton;
import android.util.AttributeSet;
import android.view.MotionEvent;

public class SkButton extends AppCompatButton
{
  public boolean fDrawState = false;
  public boolean fClickState = false;

  public SkButton(Context context)
  {
    super(context);
  }

  public SkButton(Context context, AttributeSet attrs)
  {
    super(context, attrs);
  }

  public SkButton(Context context, AttributeSet attrs, int defStyleAttr)
  {
    super(context, attrs, defStyleAttr);
  }

  @Override
  public boolean onTouchEvent(MotionEvent event)
  {
    if(event.getAction() == MotionEvent.ACTION_DOWN)
    {
      fDrawState = true;
      fClickState = true;
      invalidate();
    }
    else if(event.getAction() == MotionEvent.ACTION_UP)
    {
      fDrawState = false;
      invalidate();
    }

    return super.onTouchEvent(event);
  }

  @Override
  protected void onDraw(Canvas canvas)
  {
    super.onDraw(canvas);

    // TODO:  draw 3D-looking border, either 'innie' 0or 'outie'

    // if 'fClickState' is true, the click/draw state has changed
    // to a 'click' state and I have not re-drawn the button yet.

    int r = this.getRight();
    int l = this.getLeft();
    int t = this.getTop();
    int b = this.getBottom();


    // because the canvas uses relative coordinates, adjust them here
    // so that left/top is zero, right/bottom is width/height
    b = b - t;
    t = 0;
    r = r - l;
    l = 0;

    // create 'Paint' objects with color info
    Paint blk = new Paint();
    blk.setARGB(255,0,0,0); // non-transparent black for border

    Paint gr1 = new Paint();
    Paint gr2 = new Paint();

    if(fClickState || fDrawState) // either pressed or I didn't draw 'pressed' yet
    {
      // draw as an 'innie'
      gr2.setARGB(255,92,92,92); // grey 2
      gr1.setARGB(255,208,208,208); // grey 1
    }
    else
    {
      // draw as an 'outie'
      gr1.setARGB(255,92,92,92); // grey 1
      gr2.setARGB(255,208,208,208); // grey 2
    }

    // black lines all around (border)
    canvas.drawLine(l,t, r-1, t, blk);
    canvas.drawLine(r-1,t, r-1, b-1, blk);
    canvas.drawLine(l-1,b-1, l, b-1, blk);
    canvas.drawLine(l,b-1, l, t, blk);

    //dark grey shadows (for outie; innie is light grey)
    canvas.drawLine(l+1,b-2, r-2, b-2, gr1);
    canvas.drawLine(l+2,b-3, r-2, b-3, gr1);
    canvas.drawLine(l+3,b-4, r-2, b-4, gr1);
    canvas.drawLine(l+4,b-5, r-2, b-5, gr1);

    canvas.drawLine(r-2,t+1, r-2, b-2, gr1);
    canvas.drawLine(r-3,t+2, r-3, b-2, gr1);
    canvas.drawLine(r-4,t+3, r-4, b-2, gr1);
    canvas.drawLine(r-5,t+4, r-5, b-2, gr1);

    //light grey highlights (for outie; innie is dark grey)
    canvas.drawLine(l+1,t+1, r-2, t+1, gr2);
    canvas.drawLine(l+1,t+2, r-3, t+2, gr2);
    canvas.drawLine(l+1,t+3, r-4, t+3, gr2);
    canvas.drawLine(l+1,t+4, r-5, t+4, gr2);

    canvas.drawLine(l+1,t+1, l+1, b-2, gr2);
    canvas.drawLine(l+2,t+1, l+2, b-3, gr2);
    canvas.drawLine(l+3,t+1, l+3, b-4, gr2);
    canvas.drawLine(l+4,t+1, l+4, b-5, gr2);

    // if click state set, schedule a re-draw with the corrected values
    // this ensures that tapping before painting can respond will still
    // generate 2 sets of re-draws, one for press, one for release

    if(fClickState)
    {
      if(!fDrawState) // did not draw the 'pressed' state
      {
        postInvalidate(); // invalidate so it re-paints - again - asynchronously
      }

      fClickState = false;
    }
  }
}

